/*Exercise 1
1a) 
How much space is used by a single record
remaining space: 4096 - 250 = 3846 bytes
total records: 3846 / 24 = 160 records/page
total pages: 100,000 records / 160 records/page = 625 pages

1b)
Calculate the time taken to perform a table scan, linear scan
through the table Rel1
linear scan: 625 pages * 150msec = 93750ms

1c)
calculate the time taken using the primary index
SELECT C
FROM Rel1
WHERE A = ’AQG’ AND (B BETWEEN ’WPQ’ AND ’XYZ’);

data records for AQG: 100000/100 = 1000
1000 * 10% = 100 records
each page stores 100 records, we need 3 pages
3 pages * 150msec = 450ms

Exercise 2
There are many valid choices here! For a query like “give names of authors born after 1940” an index
on birthyear would be useful.
CREATE INDEX author_birthyear_idx on Author(birthyear)

*/
