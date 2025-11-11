USE Academia;

CREATE INDEX idx_students_matric_number ON students(matric_number);
CREATE INDEX idx_students_last_name ON students(last_name);
CREATE INDEX idx_students_first_name ON students(first_name);
CREATE INDEX idx_students_department_id ON students(department_id);
CREATE INDEX idx_students_program_id ON students(program_id);
CREATE INDEX idx_students_entry_year ON students(entry_year);
CREATE INDEX idx_students_current_level ON students(current_level);
CREATE INDEX idx_students_graduation_status ON students(graduation_status);

CREATE INDEX idx_departments_department_name ON departments(department_name);
CREATE INDEX idx_departments_faculty_id ON departments(faculty_id);
CREATE INDEX idx_departments_hod_id ON departments(hod_id);

CREATE INDEX idx_faculties_faculty_name ON faculties(faculty_name);

CREATE INDEX idx_programs_program_name ON programs(program_name);
CREATE INDEX idx_programs_department_id ON programs(department_id);

CREATE INDEX idx_staff_last_name ON staff(last_name);
CREATE INDEX idx_staff_first_name ON staff(first_name);
CREATE INDEX idx_staff_department_id ON staff(department_id);
CREATE INDEX idx_staff_role ON staff(role);

CREATE INDEX idx_courses_course_code ON courses(course_code);
CREATE INDEX idx_courses_course_title ON courses(course_title);
CREATE INDEX idx_courses_department_id ON courses(department_id);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_semester ON courses(semester);
CREATE INDEX idx_courses_dept_level_sem ON courses(department_id, level, semester);

CREATE INDEX idx_academic_sessions_session_name ON academic_sessions(session_name);
CREATE INDEX idx_academic_sessions_start_date ON academic_sessions(start_date);
CREATE INDEX idx_academic_sessions_end_date ON academic_sessions(end_date);
CREATE INDEX idx_academic_sessions_is_current ON academic_sessions(is_current);

CREATE INDEX idx_semesters_session_id ON semesters(session_id);
CREATE INDEX idx_semesters_semester_type ON semesters(semester_type);
CREATE INDEX idx_semesters_is_current ON semesters(is_current);
CREATE INDEX idx_semesters_session_type ON semesters(session_id, semester_type);

CREATE INDEX idx_course_registrations_student_id ON course_registrations(student_id);
CREATE INDEX idx_course_registrations_course_id ON course_registrations(course_id);
CREATE INDEX idx_course_registrations_semester_id ON course_registrations(semester_id);
CREATE INDEX idx_course_registrations_status ON course_registrations(status);
CREATE INDEX idx_reg_student_semester ON course_registrations(student_id, semester_id);
CREATE INDEX idx_reg_course_semester ON course_registrations(course_id, semester_id);

CREATE INDEX idx_course_allocations_course_id ON course_allocations(course_id);
CREATE INDEX idx_course_allocations_staff_id ON course_allocations(staff_id);
CREATE INDEX idx_course_allocations_semester_id ON course_allocations(semester_id);
CREATE INDEX idx_alloc_course_semester ON course_allocations(course_id, semester_id);

CREATE INDEX idx_grades_registration_id ON grades(registration_id);
CREATE INDEX idx_grades_total_score ON grades(total_score);
CREATE INDEX idx_grades_grade ON grades(grade);
CREATE INDEX idx_grades_grade_point ON grades(grade_point);

CREATE INDEX idx_gpa_records_student_id ON gpa_records(student_id);
CREATE INDEX idx_gpa_records_semester_id ON gpa_records(semester_id);
CREATE INDEX idx_gpa_records_gpa ON gpa_records(gpa);
CREATE INDEX idx_gpa_student_semester ON gpa_records(student_id, semester_id);

CREATE INDEX idx_transcripts_student_id ON transcripts(student_id);
CREATE INDEX idx_transcripts_session_id ON transcripts(session_id);
CREATE INDEX idx_transcripts_generated_date ON transcripts(generated_date);
CREATE INDEX idx_transcripts_cgpa ON transcripts(cgpa);

CREATE INDEX idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX idx_audit_log_record_id ON audit_log(record_id);
CREATE INDEX idx_audit_log_action ON audit_log(action);
CREATE INDEX idx_audit_log_changed_by ON audit_log(changed_by);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at);
CREATE INDEX idx_audit_log_table_action ON audit_log(table_name, action);