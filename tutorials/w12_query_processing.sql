/*Exercise 1 Block nested loops join
A page has 4096 bytes, 3846 are avaliable
each data record is 24 bytes
3846 / 24 = 160 records per page
we have 100,000 records
100,000 / 160 = 625 pages
for b+tree its 75% of the records possible
160 * 0.75 = 120 records
100,000 / 120 = 834 pages

For Rel2
each data record is 16 bytes
3846 / 16 = 240 records
we have 50,000 records
50,000 / 240 = 209 pages
for 75 %
50,000 / 180 = 278 pages

block-nested loop join
834 + 834 * 278 = 232,686 I/Os


Exercise 2 Index-Nested loops join
bR + (|R| * c)
3 levels inclduing the leaf page
|R| number of tuples in R
834 + (100000)*3 = 300834 I/Os



