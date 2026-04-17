WITH RECURSIVE DeptHierarchy AS (
    SELECT dept_id, dept_name, 1 AS depth
    FROM Departments
    WHERE dept_id IN (SELECT DISTINCT dept_id FROM Employees WHERE manager_id IS NULL)
    
    UNION ALL
    
    SELECT d.dept_id, d.dept_name, dh.depth + 1
    FROM Departments d
    INNER JOIN DeptHierarchy dh ON d.dept_id = dh.dept_id + 1
    WHERE dh.depth < 5
),
SalaryStats AS (
    SELECT 
        dept_id, 
        SUM(salary) as dept_total, 
        AVG(salary) as dept_avg,
        COUNT(*) as employee_count
    FROM Employees
    GROUP BY dept_id
)
SELECT 
    dh.dept_name,
    dh.depth,
    ss.employee_count,
    FORMAT(ss.dept_total, 2) as Total_Payroll,
    FORMAT(ss.dept_avg, 2) as Average_Salary,
    ROUND((ss.dept_total / (SELECT SUM(salary) FROM Employees) * 100), 2) as Budget_Weight
FROM DeptHierarchy dh
LEFT JOIN SalaryStats ss ON dh.dept_id = ss.dept_id
ORDER BY dh.depth, ss.dept_total DESC;
