CREATE DATABASE Academia;
USE Academia;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    faculty_id INT,
    hod_id INT
);

CREATE TABLE faculties (
    faculty_id INT PRIMARY KEY AUTO_INCREMENT,
    faculty_name VARCHAR(100) NOT NULL
);

CREATE TABLE programs (
    program_id INT PRIMARY KEY AUTO_INCREMENT,
    program_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    duration_years INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    department_id INT NOT NULL,
    role ENUM('Lecturer','HOD','Admin','Dean','Staff') NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    matric_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    date_of_birth DATE,
    gender ENUM('M','F','Other'),
    department_id INT NOT NULL,
    program_id INT NOT NULL,
    entry_year YEAR NOT NULL,
    current_level INT DEFAULT 100,
    graduation_status ENUM('Active','Graduated','Suspended','Withdrawn') DEFAULT 'Active',
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    credit_units INT NOT NULL,
    department_id INT NOT NULL,
    level INT NOT NULL,
    semester ENUM('First','Second') NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE academic_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    session_name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE
);

CREATE TABLE semesters (
    semester_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    semester_type ENUM('First','Second') NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (session_id) REFERENCES academic_sessions(session_id)
);

CREATE TABLE course_registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    registration_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Registered','Dropped','Auditing') DEFAULT 'Registered',
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
    UNIQUE (student_id, course_id, semester_id)
);

CREATE TABLE course_allocations (
    allocation_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    staff_id INT NOT NULL,
    semester_id INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
    UNIQUE (course_id, semester_id)
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    registration_id INT NOT NULL,
    ca_score DECIMAL(5,2) DEFAULT 0.00,
    exam_score DECIMAL(5,2) DEFAULT 0.00,
    total_score DECIMAL(5,2) GENERATED ALWAYS AS (ca_score + exam_score) STORED,
    grade CHAR(2),
    grade_point DECIMAL(3,2),
    remarks VARCHAR(50),
    FOREIGN KEY (registration_id) REFERENCES course_registrations(registration_id)
);

CREATE TABLE gpa_records (
    gpa_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    semester_id INT NOT NULL,
    total_credit_units INT NOT NULL,
    total_grade_points DECIMAL(6,2) NOT NULL,
    gpa DECIMAL(4,2) GENERATED ALWAYS AS (total_grade_points / total_credit_units) STORED,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
    UNIQUE (student_id, semester_id)
);

CREATE TABLE transcripts (
    transcript_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    generated_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    session_id INT NOT NULL,
    cgpa DECIMAL(4,2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (session_id) REFERENCES academic_sessions(session_id)
);

CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action VARCHAR(10) NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by INT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (changed_by) REFERENCES staff(staff_id)
);

ALTER TABLE departments 
ADD FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id),
ADD FOREIGN KEY (hod_id) REFERENCES staff(staff_id);