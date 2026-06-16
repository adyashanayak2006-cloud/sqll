SELECT first_name, last_name, department, salary
FROM employees;

SELECT first_name,
       salary,
       salary * 1.10 AS new_salary
FROM employees;

SELECT *
FROM employees
WHERE department = 'Sales';

SELECT *
FROM employees
WHERE salary > 50000;

SELECT *
FROM employees
WHERE salary BETWEEN 40000 AND 60000;

SELECT *
FROM employees
WHERE hire_date BETWEEN '2023-01-01' AND '2023-12-31';

SELECT *
FROM employees
WHERE last_name LIKE 'S%';

SELECT *
FROM employees
WHERE department = 'Marketing'
  AND salary > 50000;

SELECT *
FROM employees
WHERE manager_id IS NULL;

SELECT first_name, department, salary
FROM employees
ORDER BY department ASC, salary DESC;

SELECT *
FROM employees
LIMIT 10;

SELECT
    COUNT(*) AS total_filtered,
    MIN(salary) AS min_salary,
    MAX(hire_date) AS latest_hire
FROM employees
WHERE department = 'Sales'
  AND hire_date BETWEEN '1990-01-01' AND '1999-12-31'
  AND last_name LIKE 'S%';
