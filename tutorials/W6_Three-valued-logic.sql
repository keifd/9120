

/*
Exercise 1
a) a = 10
select everything that if a = 10, doesn't matter what the other is

b) a = 10 or b = 20
all values where a takes 10 and b can take any value including NULL
and
all values where b takes 20 and a can take any value including NULL

c) a = 10 and b = 20
only for (10, 20)

d) a < 10 AND NOT b = 20
a < 10 and not NULL, NOT b = 20 and not NULL

*/

/*Exercise 2
a) Which lecturers (by id and name) have taught both ’INFO2120’ and ’INFO3404’?
Write a SQL query to answer this question using a SET operator.
*/
SELECT id, name
FROM academicstaff JOIN uosoffering ON instructorid
WHERE uoscode = 'INFO2120'
INTERSECT
SELECT id, name
FROM academicstaff JOIN uosoffering ON instructorid
WHERE uoscode = 'INFO3404';

/*
b) Which lecturers (by id and name) have taught both ’INFO2120’ and ’INFO3404’? Answer
this using a sub-query without SET operators. Make sure your result doesn’t include
duplicates.
*/
SELECT id, name
FROM academicstaff a
JOIN uosoffering ON a.id = instructorid
WHERE uoscode = 'INFO2120'
AND a.id in (
	SELECT instructorid
	FROM uosoffering
	WHERE uoscode = 'INFO3404'
);
/* using group by*/
SELECT id, name
FROM academicstaff JOIN uosoffering ON instructorid
WHERE uoscode = 'INFO2120'or uoscode = 'INFO3404'
GROUP BY id, name
HAVING COUNT(DISTINCT uoscode) = 2


/* c) Write a SQL query to give the student IDs of all students who have enrolled in only one
lecture using GROUP BY, and order the result by student ID. A lecture is a unit_of_study
in a semester of a year.*/
SELECT studid
FROM transcript
GROUP BY studid
HAVING COUNT(*) = 1
ORDER BY studid;

/*d) Write a SQL query to give the names of all students who have enrolled in only one
lecture using a sub-query. A lecture is a unit_of_study in a semester of a year*/
SELECT name
FROM student
WHERE studid IN(
	SELECT studid
	FROM transcript
	GROUP BY studid
	HAVING COUNT(*) = 1
);

/*e) Write a SQL query to give the student IDs and names of all students who have enrolled
in only one lecture without using a sub-query, and order the result by student ID. A
lecture is a unit_of_study in a semester of a year.*/
SELECT transcript.studid, student.name
FROM transcript
JOIN student ON transcript.studid = student.studid
GROUP BY transcript.studid, student.name
HAVING COUNT(*) = 1
ORDER BY transcript.studid;

/*f) Write a SQL query to give the names of all students who have enrolled in only one
lecture without using a sub-query. A lecture is a unit_of_study in a semester of a year.*/
SELECT name
FROM transcript NATURAL JOIN student
GROUP BY studid, name
HAVING COUNT(*) = 1

/*g) [Advanced, Optional] Write a SQL query to give the student IDs of all students who have
enrolled in only one unit_of_study, and order the result by student ID. Note that, a
student can enrol in the same unit_of_study multiple times, which is still counted as one
unit_of_study.*/
SELECT studid
FROM transcript
GROUP BY studid
HAVING COUNT(DISTINCT uoscode) = 1
ORDER BY studid;

/*h) [Advanced, Optional] Write a SQL query to give the student IDs and names of all
students who have enrolled in only one unit_of_study, and order the result by student
ID. Note that, a student can enrol in the same unit_of_study multiple times, which is still
counted as one unit_of_study.*/
SELECT studid, name
FROM transcript NATURAL JOIN student
GROUP BY studid, name
HAVING COUNT(DISTINCT uoscode) = 1
ORDER BY studid

	










DROP TABLE IF EXISTS R;

CREATE TABLE R (
	a integer,
	b integer
);

INSERT INTO R VALUES (1, 1);
INSERT INTO R VALUES (1, NULL);
INSERT INTO R VALUES (10, 20);
INSERT INTO R VALUES (10, NULL);
INSERT INTO R VALUES (NULL, 20);
INSERT INTO R VALUES (NULL, NULL);

COMMIT;

SELECT * FROM R;

/*select column a where a is not null*/
SELECT a
FROM R
WHERE a IS NOT NULL

/*using group by and having*/
SELECT a
FROM r
WHERE a IS NOT NULL
GROUP BY a
HAVING COUNT(*) = 2

/*nested quereies*/
SELECT *
FROM (
	SELECT *
	FROM r
	WHERE a IS NULL
	) AS SUB
WHERE b is NULL