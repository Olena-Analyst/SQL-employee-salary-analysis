/* 1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.*/
SELECT YEAR(sal.from_date) AS YearForSalary,
	   ROUND(AVG(sal.salary),2) AS AverageSalary
FROM employees.salaries sal 
GROUP BY YearForSalary
HAVING YearForSalary BETWEEN MIN(YearForSalary) AND 2005
ORDER BY YearForSalary
;

------------------------------------------------------------------

/*2. Покажіть середню зарплату співробітників по кожному відділу.
 Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників*/
SELECT demp.dept_no AS DepNo,
       ROUND(AVG(sal.salary), 2) AS AvgSalary
FROM employees.salaries sal
     INNER JOIN employees.dept_emp demp 
         ON sal.emp_no = demp.emp_no 
WHERE CURRENT_DATE BETWEEN demp.from_date AND demp.to_date
  AND CURRENT_DATE BETWEEN sal.from_date AND sal.to_date
GROUP BY DepNo
ORDER BY DepNo;
-------------------------------------------------------------------------

/*3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік*/
SELECT demp.dept_no AS DepNo,
	   YEAR(sal.from_date) AS YearForSalary,
	   ROUND(AVG(sal.salary),2) AS AvgSalary
FROM employees.salaries sal 
	 INNER JOIN employees.dept_emp demp ON sal.emp_no = demp.emp_no
GROUP BY  demp.dept_no,
		  YEAR(sal.from_date)
ORDER BY demp.dept_no
;
---------------------------------------------------------------

/*4. Покажіть відділи в яких зараз працює більше 15000 співробітників.*/
SELECT dep.dept_no AS DepNo,
	   dep.dept_name AS Dapertment,
       COUNT(demp.emp_no) AS EmpNo
FROM employees.dept_emp demp
	 INNER JOIN employees.departments dep ON demp.dept_no = dep.dept_no 
WHERE CURRENT_DATE BETWEEN demp.from_date AND demp.to_date
GROUP BY dep.dept_name
HAVING EmpNo >= 15000 
ORDER BY DepNo;
----------------------------------------------------------------

/*5. Для менеджера який працює найдовше покажіть
 йогo номер, відділ, дату прийому на роботу, прізвище*/
SELECT demp.emp_no AS EmpNo,
       demp.dept_no AS DeptNo,
       emp.hire_date AS HireDate,
       emp.last_name AS LastName
	FROM employees.dept_manager demp
    INNER JOIN employees.employees emp ON demp.emp_no = emp.emp_no 
    WHERE CURRENT_DATE BETWEEN demp.from_date AND demp.to_date
ORDER BY HireDate
LIMIT 1;
-------------------------------------------------------------

/*6. Покажіть топ-10 діючих співробітників компанії з 
найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.*/
	WITH AvgDeptSalary AS (
    SELECT demp.dept_no AS DeptNo,
		   AVG(sal.salary) AS AvgSalary
    FROM employees.salaries sal
        INNER JOIN employees.dept_emp demp ON sal.emp_no = demp.emp_no AND demp.to_date > CURDATE()
    WHERE sal.to_date > CURDATE() 
    GROUP BY demp.dept_no
),
 EmployeeSalaryDiff AS (
    SELECT emp.emp_no AS EmpNo,
           emp.first_name AS FName,
           emp.last_name AS LName,
           demp.dept_no AS DeptNo,
           sal.salary AS Salary,
           ROUND(sal.salary - AvgDeptSalary.AvgSalary, 2) AS SalaryDiff
    FROM employees.salaries sal
        INNER JOIN employees.dept_emp demp ON sal.emp_no = demp.emp_no AND demp.to_date > CURDATE()
        INNER JOIN employees.employees emp ON sal.emp_no = emp.emp_no
        INNER JOIN AvgDeptSalary ON demp.dept_no = AvgDeptSalary.DeptNo
    WHERE sal.to_date > CURDATE()      
)
SELECT EmpNo,
	   FName,
       LName,
       DeptNo,
       Salary,
       SalaryDiff
FROM EmployeeSalaryDiff
ORDER BY SalaryDiff DESC
LIMIT 10;
---------------------------------------------------------------

/*7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести 
відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату 
коли він став менеджером відділу*/
WITH RankManager AS (
    SELECT demp.dept_no AS DeptNo,
           emp.last_name AS LName,
           emp.first_name AS FName,
           emp.hire_date AS HireDate,
           demp.from_date AS ManStartDate,
        ROW_NUMBER() OVER (PARTITION BY demp.dept_no ORDER BY demp.from_date) AS ManagerRank
    FROM 
        employees.dept_manager demp
        INNER JOIN employees.employees emp ON demp.emp_no = emp.emp_no
)
SELECT DeptNo,
	   LName,
       FName,
       HireDate,
       ManStartDate
FROM RankManager
WHERE ManagerRank = 2;
--------------------------------------------------------------------

/*ДИЗАЙН БАЗИ ДАНИХ
1. Створіть базу даних для управління курсами. База має включати наступні таблиці:
- students: student_no, teacher_no, course_no, student_name, email, birth_date.
- teachers: teacher_no, teacher_name, phone_no
- courses: course_no, course_name, start_date, end_date*/

DROP DATABASE CourseManagement;
CREATE DATABASE IF NOT EXISTS CourseManagement;

USE CourseManagement;

CREATE TABLE Courses (
    course_no INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100),
    start_date DATE,
    end_date DATE
);

CREATE TABLE Teachers (
    teacher_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100),
    phone_no VARCHAR(15)
);

CREATE TABLE Students (
    student_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_no INT NOT NULL,
    course_no INT NOT NULL,
    student_name VARCHAR(100),
    email VARCHAR(100),
    birth_date DATE,
    FOREIGN KEY (teacher_no) REFERENCES teachers(teacher_no),
    FOREIGN KEY (course_no) REFERENCES courses(course_no)
);

DESCRIBE courses; 
DESCRIBE teachers;
DESCRIBE Students;
---------------------
 
 /*2. Додайте будь-які данні (7-10 рядків) в кожну таблицю.
3. По кожному викладачу покажіть кількість студентів з якими він працював
4. Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки) 
5. Напишіть запит який виведе дублюючі рядки в таблиці students*/
START TRANSACTION;

INSERT INTO courses (course_no, course_name, start_date, end_date) VALUES 
(1, 'Математика', '2025-01-10', '2025-05-31'),
(2, 'Укр. мова', '2025-01-10', '2025-05-31'),
(3, 'Укр. література', '2025-01-10', '2025-05-31'),
(4, 'Історія України', '2025-01-10', '2025-05-31'),
(5, 'Біологія', '2025-01-10', '2025-05-31'),
(6, 'Фізика', '2025-01-10', '2025-05-31'),
(7, 'Хімія', '2025-01-10', '2025-05-31');

SELECT *
FROM courses;
------------------------------------------------------------

INSERT INTO teachers (teacher_no, teacher_name, phone_no) VALUES 
(1, 'Наталія', '044-123-45-67'),
(2, 'Ігор', '044-234-56-78'),
(3, 'Оксана', '044-345-67-89'),
(4, 'Богдан', '044-456-78-90'),
(5, 'Катерина', '044-567-89-01'),
(6, 'Мирослав', '044-678-90-12'),
(7, 'Ольга', '044-789-01-23');

SELECT *
FROM teachers;
-----------------------------------------------------------

INSERT INTO students (teacher_no, course_no, student_name, email, birth_date) VALUES 
(1, 1, 'Іван', 'ivan@example.com', '2000-01-01'),
(2, 2, 'Олена', 'olena@example.com', '2001-08-27'),
(3, 3, 'Роман', 'roman@example.com', '2001-03-25'),
(4, 4, 'Світлана', 'svitlana@example.com', '2000-04-26'),
(5, 5, 'Костянтин', 'kostyantyn@example.com', '2003-10-18'),
(6, 6, 'Петро', 'petro@example.com', '2002-11-13'),
(7, 7, 'Богдана', 'bogdana@example.com', '2003-12-25');

COMMIT;

SELECT *
FROM students;
---------------------------------------------------------------------

/*По кожному викладачу покажіть кількість студентів з якими він працював*/
SELECT tc.teacher_name AS Teacher,
	   COUNT(st.student_no) AS CountStudent,
	   st.student_name AS StName
FROM students st
	 INNER JOIN teachers tc ON st.teacher_no = tc.teacher_no
GROUP BY tc.teacher_name,	
		 st.student_name;
--------------------------------------------------------------------------

/* Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки) */
INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
SELECT teacher_no, course_no, student_name, email, birth_date
FROM students
LIMIT 3;

SELECT *
FROM students;
-------------------------------------------------------------------

/*Напишіть запит який виведе дублюючі рядки в таблиці students*/
SELECT st.teacher_no AS Teacher,
       course_no AS Cours,
       st.student_name AS StName,
	   email,
       birth_date,
	   COUNT(st.student_name) AS StudentName        
FROM students st 
GROUP BY st.teacher_no, 
         course_no, 
         st.student_name, 
	     email,
         birth_date
HAVING StudentName > 1;

