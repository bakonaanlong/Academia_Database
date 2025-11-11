# Student Academic Record System (SARS)  
**A Complete MySQL Database Schema for Managing Students, Courses, Grades & GPA**

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)
![Status](https://img.shields.io/badge/status-production%20ready-green)

---

## Overview

This is a **fully automated, production-ready** relational database system designed for educational institutions (universities, polytechnics, colleges). It handles:

- Student registration & enrollment
- Course management
- Grade entry & automatic GPA calculation
- Academic session/semester tracking
- Audit trail for grade changes
- Data integrity via triggers & cascading cleanup

> **No manual GPA calculation required** — everything is handled by **triggers** and **stored procedures**.

---

## Database Structure

### Core Tables

| Table | Purpose |
|------|--------|
| `students` | Student profile & academic status |
| `departments` | Academic departments |
| `faculties` | Groups of departments |
| `programs` | Academic programs (e.g., B.Sc Computer Science) |
| `staff` | Lecturers, HODs, Admins |
| `courses` | Course catalog |
| `academic_sessions` | e.g., 2023/2024 |
| `semesters` | First/Second semester per session |
| `course_registrations` | Student course enrollment |
| `course_allocations` | Lecturer-to-course assignment |
| `grade_scale` | Grading policy (e.g., 70–100 = A) |
| `grades` | CA, Exam, Total, Grade, GP |
| `gpa_records` | Auto-calculated GPA per semester |
| `transcripts` | Official transcript records |
| `audit_log` | Full audit trail of grade changes |

---

## Key Features

| Feature | How It Works |
|-------|-------------|
| **Auto Grade Row** | Every course registration creates a `grades` row with `0.00` |
| **Auto Grade Letter & GP** | On score entry → lookup `grade_scale` → update `grade`, `grade_point` |
| **Auto GPA Calculation** | Any grade change → recalculate **entire semester GPA** |
| **Only One Current Session/Semester** | Triggers enforce `is_current = TRUE` exclusivity |
| **Audit Trail** | Every grade insert/update/delete logged in JSON |
| **Clean Deletion** | Delete student → removes all related records |

---

## Triggers & Automation (Full Explanation)

### 1. `trg_after_grade_insert` / `trg_after_grade_update`
- **When**: After inserting or updating a row in `grades`
- **Action**: Calls `update_grade_and_gpa(registration_id)`
- **Result**: 
  - Calculates `total_score`
  - Assigns correct `grade` and `grade_point` from `grade_scale`
  - Sets `remarks` (`Pass` / `Fail`)
  - Recalculates **entire GPA** for that semester

---

### 2. `trg_after_registration_insert`
- **When**: Student registers for a course
- **Action**: Auto-creates a `grades` row with `0.00` and `Pending`
- **Why**: Lecturers can immediately input scores

---

### 3. `trg_after_registration_delete`
- **When**: Course registration is dropped
- **Action**: Deletes associated `grades` row
- **Result**: No orphan data

---

### 4. `trg_before_student_delete`
- **When**: A student record is deleted
- **Action**: 
  - Deletes all `course_registrations`
  - Deletes all `gpa_records`
  - Deletes all `transcripts`
- **Result**: Full data cleanup, no FK errors

---

### 5. `trg_after_session_insert` / `trg_after_session_update`
- **When**: A session is marked `is_current = TRUE`
- **Action**: Sets all other sessions to `is_current = FALSE`
- **Result**: Only **one active session** at a time

---

### 6. `trg_after_semester_insert` / `trg_after_semester_update`
- Same logic as sessions but for **semesters**
- Ensures only **one current semester**

---

### 7. Grade Audit Triggers (`trg_audit_grades_*`)
- **INSERT**: Logs new grade values
- **UPDATE**: Logs old + new values
- **DELETE**: Logs deleted values
- **Stored in**: `audit_log` table as JSON
- **Use case**: Fraud detection, compliance, dispute resolution

---

## Stored Procedures

### `update_grade_and_gpa(reg_id INT)`
1. Fetch student, semester, and course credit units
2. Compute `total = ca_score + exam_score`
3. Lookup `grade` and `grade_point` from `grade_scale`
4. Update `grades` row
5. Call `recalculate_gpa()`

### `recalculate_gpa(stu_id INT, sem_id INT)`
1. Sum:  
   - `total_credit_units`  
   - `total_grade_points = Σ(credit_units × grade_point)`
2. Insert or update `gpa_records`
3. MySQL auto-computes `gpa = total_grade_points / total_credit_units`

---

## File Structure

```
/
├── schema.sql              -- Full table creation (no indexes)
├── indexes.sql             -- All performance indexes
├── triggers.sql            -- All triggers + stored procedures
├── sample_data.sql         -- Optional: insert sample records
└── README.md               -- This file
```

---

## Setup Instructions

### 1. Create Database
```sql
CREATE DATABASE sars_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sars_db;
```

### 2. Run Scripts in Order
```bash
mysql -u root -p sars_db < schema.sql
mysql -u root -p sars_db < indexes.sql
mysql -u root -p sars_db < triggers.sql
```

---

## Sample Queries

### Get Student Transcript
```sql
SELECT 
    s.matric_number, s.first_name, s.last_name,
    c.course_code, c.course_title, c.credit_units,
    g.ca_score, g.exam_score, g.total_score, g.grade, g.grade_point,
    gp.gpa
FROM students s
JOIN course_registrations cr ON s.student_id = cr.student_id
JOIN courses c ON cr.course_id = c.course_id
JOIN grades g ON cr.registration_id = g.registration_id
JOIN gpa_records gp ON cr.student_id = gp.student_id AND cr.semester_id = gp.semester_id
WHERE s.matric_number = 'CSC/2020/001';
```

### Current Semester GPA (All Students)
```sql
SELECT 
    s.matric_number, s.last_name, s.first_name,
    gp.gpa, gp.total_credit_units
FROM gpa_records gp
JOIN students s ON gp.student_id = s.student_id
JOIN semesters sem ON gp.semester_id = sem.semester_id
WHERE sem.is_current = TRUE
ORDER BY gp.gpa DESC;
```

---

## Security & Best Practices

- Use **parameterized queries** in your app
- Restrict direct `grades` table access — use API
- Log `changed_by` in audit (modify trigger to accept `CURRENT_USER`)
- Backup `audit_log` regularly

---

## Contributing

1. Fork the repo
2. Create a feature branch
3. Submit a pull request

---

## License

[MIT License](LICENSE) – Free to use, modify, and distribute.

---

## Author

**Built with precision for academic excellence**  
*November 11, 2025*

---

> **"Automate the routine. Empower the academic."**  
> — SARS Database Philosophy

--- 

**Star this repo if you found it helpful!**  
Need a frontend? API? Let me know!
