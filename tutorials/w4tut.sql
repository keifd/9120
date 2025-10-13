/*Exercise 2
a) Find the title and publicationYear of all books

b) Find all publisher names whos address is New York

c) Find author names that wrote book with title A first dicource in Database system

d) Find all publisher's address who published the book with title Database or Data Management

Exercise 3
a) 𝜋title 𝜎publisher = "Acme Publishers"(Book)

b) 𝜋aname 𝜎isbn = "044445551"(Wrote)

c) 𝜋aname 𝜎publisher = "Acme Publishers"(Wrote ⋈ Book)

d) 𝜋aname(Author) - (𝜋aname 𝜎publisher = "Acme Publishers"(Wrote ⋈ Book))

*/

/*Exercise 1 SQL
List the names of all students who took units INFO2005 or INFO2120
*/
SELECT s.name
FROM student s, transcript t
WHERE s.studid = t.studid AND
(t.uoscode = 'INFO2005' OR t.uoscode = 'INFO2120');


SELECT s.name
FROM student s JOIN transcript t ON s.studid = t.studid
WHERE t.uoscode = 'INFO2005' OR t.uoscode = 'INFO2120';




