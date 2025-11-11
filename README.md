# Student Academic Record System (SARS)  
**A Complete MySQL Database Schema for Managing Students, Courses, Grades & GPA**

---
![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)

---

## Overview

This is a **fully automated, production-ready** relational database system designed for a university. It handles:

- Student registration & enrollment
- Course management
- Grade entry & automatic GPA calculation
- Academic session/semester tracking
- Audit trail for grade changes
- Data integrity via triggers & cascading cleanup

> **No manual GPA calculation required** — everything is handled by the **triggers** and **stored procedures** I have created.

---

## Database Structure

### Core Tables

| Table | Purpose |
|------|--------|
| `students` | Student profile & academic status |
| `departments` | Academic departments |
| `faculties` | Groups of departments |
| `programs` | Academic programs (e.g., B.Sc Software Eng) |
| `staff` | Lecturers, HODs, Admins |
| `courses` | Course catalog |
| `academic_sessions` | e.g., 2023/2024 |
| `semesters` | First/Second semester per session |
| `course_registrations` | Student course enrollment |
| `course_allocations` | Lecturer-to-course assignment |
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
├── academia_database.sql              -- Full table creation
├── README.md               -- This file
├── academia_indexes.sql             -- All performance indexes
└──  academia_triggers+stored_procedures.sql            -- All triggers + stored procedures

```

---
