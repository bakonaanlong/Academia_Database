USE Academia;

DELIMITER $$

CREATE TRIGGER trg_after_grade_insert
AFTER INSERT ON grades
FOR EACH ROW
BEGIN
    CALL update_grade_and_gpa(NEW.registration_id);
END$$

CREATE TRIGGER trg_after_grade_update
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    CALL update_grade_and_gpa(NEW.registration_id);
END$$

CREATE TRIGGER trg_after_registration_insert
AFTER INSERT ON course_registrations
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM grades WHERE registration_id = NEW.registration_id) THEN
        INSERT INTO grades (registration_id, ca_score, exam_score, total_score, grade, grade_point, remarks)
        VALUES (NEW.registration_id, 0.00, 0.00, 0.00, NULL, NULL, 'Pending');
    END IF;
END$$

CREATE TRIGGER trg_after_registration_delete
AFTER DELETE ON course_registrations
FOR EACH ROW
BEGIN
    DELETE FROM grades WHERE registration_id = OLD.registration_id;
END$$

CREATE TRIGGER trg_before_student_delete
BEFORE DELETE ON students
FOR EACH ROW
BEGIN
    DELETE FROM course_registrations WHERE student_id = OLD.student_id;
    DELETE FROM gpa_records WHERE student_id = OLD.student_id;
    DELETE FROM transcripts WHERE student_id = OLD.student_id;
END$$

CREATE TRIGGER trg_after_session_insert
AFTER INSERT ON academic_sessions
FOR EACH ROW
BEGIN
    IF NEW.is_current = TRUE THEN
        UPDATE academic_sessions SET is_current = FALSE WHERE session_id != NEW.session_id AND is_current = TRUE;
    END IF;
END$$

CREATE TRIGGER trg_after_session_update
AFTER UPDATE ON academic_sessions
FOR EACH ROW
BEGIN
    IF NEW.is_current = TRUE AND OLD.is_current = FALSE THEN
        UPDATE academic_sessions SET is_current = FALSE WHERE session_id != NEW.session_id;
    END IF;
END$$

CREATE TRIGGER trg_after_semester_insert
AFTER INSERT ON semesters
FOR EACH ROW
BEGIN
    IF NEW.is_current = TRUE THEN
        UPDATE semesters 
        SET is_current = FALSE 
        WHERE semester_id != NEW.semester_id 
          AND is_current = TRUE;
    END IF;
END$$

CREATE TRIGGER trg_after_semester_update
AFTER UPDATE ON semesters
FOR EACH ROW
BEGIN
    IF NEW.is_current = TRUE AND OLD.is_current = FALSE THEN
        UPDATE semesters 
        SET is_current = FALSE 
        WHERE semester_id != NEW.semester_id;
    END IF;
END$$

CREATE TRIGGER trg_audit_grades_insert
AFTER INSERT ON grades
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, new_values, changed_by, changed_at)
    VALUES ('grades', NEW.grade_id, 'INSERT', 
            JSON_OBJECT(
                'registration_id', NEW.registration_id,
                'ca_score', NEW.ca_score,
                'exam_score', NEW.exam_score,
                'total_score', NEW.total_score,
                'grade', NEW.grade,
                'grade_point', NEW.grade_point
            ),
            NULL, NOW());
END$$

CREATE TRIGGER trg_audit_grades_update
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by, changed_at)
    VALUES ('grades', NEW.grade_id, 'UPDATE',
            JSON_OBJECT(
                'ca_score', OLD.ca_score,
                'exam_score', OLD.exam_score,
                'total_score', OLD.total_score,
                'grade', OLD.grade,
                'grade_point', OLD.grade_point
            ),
            JSON_OBJECT(
                'ca_score', NEW.ca_score,
                'exam_score', NEW.exam_score,
                'total_score', NEW.total_score,
                'grade', NEW.grade,
                'grade_point', NEW.grade_point
            ),
            NULL, NOW());
END$$

CREATE TRIGGER trg_audit_grades_delete
AFTER DELETE ON grades
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_values, changed_by, changed_at)
    VALUES ('grades', OLD.grade_id, 'DELETE',
            JSON_OBJECT(
                'registration_id', OLD.registration_id,
                'ca_score', OLD.ca_score,
                'exam_score', OLD.exam_score,
                'total_score', OLD.total_score,
                'grade', OLD.grade,
                'grade_point', OLD.grade_point
            ),
            NULL, NOW());
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_grade_and_gpa(IN reg_id INT)
BEGIN
    DECLARE total DECIMAL(5,2);
    DECLARE reg_student_id INT;
    DECLARE reg_semester_id INT;
    DECLARE course_credits INT;
    DECLARE current_grade CHAR(2);
    DECLARE current_gp DECIMAL(3,2);

    SELECT cr.student_id, cr.semester_id, c.credit_units
    INTO reg_student_id, reg_semester_id, course_credits
    FROM course_registrations cr
    JOIN courses c ON cr.course_id = c.course_id
    WHERE cr.registration_id = reg_id;

    SELECT ca_score + exam_score INTO total
    FROM grades WHERE registration_id = reg_id;

    SELECT grade, grade_point INTO current_grade, current_gp
    FROM grade_scale
    WHERE total BETWEEN min_score AND max_score
    ORDER BY min_score DESC LIMIT 1;

    UPDATE grades
    SET total_score = total,
        grade = current_grade,
        grade_point = current_gp,
        remarks = IF(total >= 40, 'Pass', 'Fail')
    WHERE registration_id = reg_id;

    CALL recalculate_gpa(reg_student_id, reg_semester_id);
END$$

CREATE PROCEDURE recalculate_gpa(IN stu_id INT, IN sem_id INT)
BEGIN
    DECLARE total_cu INT DEFAULT 0;
    DECLARE total_gp DECIMAL(6,2) DEFAULT 0.00;

    SELECT 
        COALESCE(SUM(c.credit_units), 0),
        COALESCE(SUM(c.credit_units * g.grade_point), 0)
    INTO total_cu, total_gp
    FROM course_registrations cr
    JOIN courses c ON cr.course_id = c.course_id
    JOIN grades g ON cr.registration_id = g.registration_id
    WHERE cr.student_id = stu_id 
      AND cr.semester_id = sem_id
      AND g.total_score IS NOT NULL;

    IF total_cu > 0 THEN
        INSERT INTO gpa_records (student_id, semester_id, total_credit_units, total_grade_points)
        VALUES (stu_id, sem_id, total_cu, total_gp)
        ON DUPLICATE KEY UPDATE
            total_credit_units = total_cu,
            total_grade_points = total_gp;
    END IF;
END$$

DELIMITER ;