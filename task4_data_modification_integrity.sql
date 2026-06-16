 Data Modification & Integrity - Complete Breakdown
Dataset: Employees Sample Database (MySQL)
Practice Approach: Create a sandbox table to avoid modifying production data
-- Create practice table
CREATE TABLE employee_sandbox AS
SELECT * FROM employees LIMIT 1000;
Hands-on Exercises
1. INSERT: Add New Employees
-- Single record
INSERT INTO employee_sandbox
(emp_no, birth_date, first_name, last_name, gender, hire_date)
VALUES
(500001, '1995-08-14', 'Emma', 'Johnson', 'F', '2023-06-01');
-- Bulk insert
INSERT INTO employee_sandbox VALUES
(500002, '1990-11-03', 'Liam', 'Smith', 'M', '2023-06-01'),
(500003, '1988-04-22', 'Olivia', 'Brown', 'F', '2023-06-01');
-- Verify
SELECT * FROM employee_sandbox
WHERE emp_no >= 500000;
2. UPDATE: Modify Existing Records
-- Correct name spelling
UPDATE employee_sandbox
SET first_name = 'Amelia'
WHERE emp_no = 500003;
-- Department transfer simulation
UPDATE employee_sandbox
SET hire_date = '2023-07-15'
WHERE first_name = 'Georgi'
AND last_name = 'Facello';
-- Verify
SELECT * FROM employee_sandbox
WHERE first_name IN ('Amelia','Georgi');
3. DELETE: Remove Records
-- Delete test records
DELETE FROM employee_sandbox
WHERE hire_date = '2023-06-01'
AND emp_no > 500000;
-- Verify deletion
SELECT COUNT(*) FROM employee_sandbox
WHERE emp_no > 500000; -- Should return 0
Constraint Enforcement
Primary Key Violation
-- Attempt duplicate employee number
INSERT INTO employee_sandbox
VALUES (10001, '1953-09-02', 'John', 'Doe', 'M', '1986-06-26');
/* Error:
Duplicate entry '10001' for key 'PRIMARY'
*/
Foreign Key Enforcement
-- Create related tables
CREATE TABLE salary_sandbox AS SELECT * FROM salaries LIMIT 1000;
ALTER TABLE salary_sandbox ADD PRIMARY KEY (emp_no, from_date);
-- Add foreign key constraint
ALTER TABLE salary_sandbox
ADD CONSTRAINT fk_emp
FOREIGN KEY (emp_no) REFERENCES employee_sandbox(emp_no);
-- Attempt invalid insert
INSERT INTO salary_sandbox
VALUES (999999, 80000, '2023-01-01', '9999-01-01');
/* Error:
Cannot add or update a child row: a foreign key constraint fails
(`employees`.`salary_sandbox`, CONSTRAINT `fk_emp` FOREIGN KEY (`emp_no`)
REFERENCES `employee_sandbox` (`emp_no`))
*/
Transaction Control
Atomic Update Example
START TRANSACTION;
-- 1. Update name
UPDATE employee_sandbox
SET first_name = 'Alexander'
WHERE emp_no = 10002;
-- 2. Simulate salary update
INSERT INTO salary_sandbox
VALUES (10002, 75000, CURDATE(), '9999-01-01');
-- Verify changes before commit
SELECT * FROM employee_sandbox WHERE emp_no = 10002;
SELECT * FROM salary_sandbox WHERE emp_no = 10002;
-- Undo changes
ROLLBACK;
-- Verify rollback
SELECT * FROM employee_sandbox WHERE emp_no = 10002;
Savepoints
START TRANSACTION;
-- Initial update
UPDATE employee_sandbox
SET hire_date = '2023-01-01'
WHERE emp_no = 10003;
SAVEPOINT sp1;
-- Risky operation
DELETE FROM employee_sandbox
WHERE first_name LIKE 'A%'; -- Deletes 200+ records
-- Revert to savepoint
ROLLBACK TO SAVEPOINT sp1;
COMMIT; -- Only saves hire_date update
Data Validation Framework
Pre/Post Change Checks
# Python Pseudocode for Data Integrity Testing
def update_employee(emp_no, new_name):
# Pre-check
old_record = execute_query("SELECT * FROM employee_sandbox WHERE emp_no = ?",
emp_no)
# Execute update
execute_query("UPDATE employee_sandbox SET first_name = ? WHERE emp_no = ?",
(new_name, emp_no))
# Post-validation
new_record = execute_query("SELECT * FROM employee_sandbox WHERE emp_no = ?",
emp_no)
if old_record['gender'] != new_record['gender']: # Immutable attribute
rollback_changes()
raise IntegrityError("Gender cannot be modified")
log_change(old_record, new_record)
Consistency Queries
-- Pre-update snapshot
CREATE TABLE pre_update AS
SELECT * FROM employee_sandbox;
-- After modifications
SELECT
(SELECT COUNT(*) FROM pre_update) AS old_count,
(SELECT COUNT(*) FROM employee_sandbox) AS new_count,
old_count - new_count AS delta;
Constraint Management
Adding Constraints
-- Add unique email constraint
ALTER TABLE employee_sandbox
ADD COLUMN email VARCHAR(255);
ALTER TABLE employee_sandbox
ADD CONSTRAINT uc_email UNIQUE (email);
-- Test violation
UPDATE employee_sandbox
SET email = 'test@company.com'
WHERE emp_no = 10001;
UPDATE employee_sandbox
SET email = 'test@company.com'
WHERE emp_no = 10002; -- Fails
Constraint Removal
-- Remove foreign key temporarily
ALTER TABLE salary_sandbox
DROP FOREIGN KEY fk_emp;
-- Bulk load historical data
LOAD DATA INFILE 'legacy_salaries.csv'
INTO TABLE salary_sandbox;
-- Re-enable constraint
ALTER TABLE salary_sandbox
ADD CONSTRAINT fk_emp
FOREIGN KEY (emp_no)
REFERENCES employee_sandbox(emp_no)
ON DELETE CASCADE;
Real-World Scenarios
Scenario 1: Department Consolidation
START TRANSACTION;
-- 1. Move all HR employees to People Ops
UPDATE dept_emp
SET dept_no = (SELECT dept_no FROM departments WHERE dept_name = 'People Ops')
WHERE dept_no = (SELECT dept_no FROM departments WHERE dept_name = 'Human
Resources')
AND to_date > CURDATE();
-- 2. Archive old department
DELETE FROM departments
WHERE dept_name = 'Human Resources';
-- Verify no active employees in HR
SELECT COUNT(*) FROM dept_emp
WHERE dept_no = 'd007' -- Original HR dept_no
AND to_date > CURDATE(); -- Should be 0
COMMIT;
Scenario 2: GDPR Data Purge
-- Create deletion log
CREATE TABLE deletion_audit (
emp_no INT PRIMARY KEY,
delete_date DATE
);
BEGIN;
-- Record before deletion
INSERT INTO deletion_audit
SELECT emp_no, CURDATE()
FROM employee_sandbox
WHERE hire_date < '1990-01-01';
-- Cascade delete
DELETE FROM employee_sandbox
WHERE hire_date < '1990-01-01';
-- Verify
SELECT COUNT(*) FROM employee_sandbox
WHERE hire_date < '1990-01-01'; -- Should be 0
COMMIT;
Progression Metrics
Success Checklist:
● Performs 10+ CRUD operations with 100% constraint compliance
● Implements transactions for complex operations
● Designs pre/post validation checks
● Resolves real-world scenarios (GDPR, mergers)
Failure Patterns:
● Constraint violations in >5% of operations
● Unlogged data changes
● Transactions left uncommitted
● 0.1% data inconsistency post-migration
💡 Expert Tip: "Always test DELETE/UPDATEs with SELECT first. Add --dry-run flags to
your SQL scripts during development!"
- Chief Data Architect, Financial Institution
Next Task: Task 5: Stored Procedures & Automation →
Data Manipulation → Automation based on AWS Database Specialty objectives
