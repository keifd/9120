/*
a) Express the above functional dependencies in
simple English

I. destination, departs, airline -> gate
An airline never runs more than one flight departing at the same time and destination

II. gate → airline
each airline departs from a single gate

III. contact → name
each contact number is owned by at most one VIP

IV. name, departs → gate, pickup
An VIP cannot depart at two gate at the sametime and cannot be picked up from more than one location for a departure

V. gate, departs → destination
each flight departs at one gate and goes to a single destination

2C）Explain whether it is a loseless-join decomposition to decompose the relation into the following:
R1 and R2 share gate, but gate is not a superkey, so it is not lossless decomposition.

3D) Give a lossless-join decomposition of the original relation into BCNF relations.
R1(gate, airline)
R2(destination, departs, gate, name, contact, pickup)
R3(contact, name)
R4(destination, departs, gate, contact, pickup)
R5(gate, departs, destination)
R6(departs, gate, contact, pickup)

R1, R3, R5, R6 are all BCNF. And there's no more FD's when a
non-key controls other attributes

*/


BEGIN;
DROP TABLE IF EXISTS VipTransfers;

CREATE TABLE VipTransfers (
	destination VARCHAR(20),
	departs		DATE,
	airline		VARCHAR(20),
	gate		INTEGER,
	name		VARCHAR(30),
	contact		VARCHAR(10),
	pickup		INTEGER
);

INSERT INTO VipTransfers VALUES ('Berlin',TO_DATE('11:25 01/06/2012', 'HH24:MI DD/MM/YYYY'),'Lufthansa',3,'Justin Thyme','0413456789',1);
INSERT INTO VipTransfers VALUES ('Madrid',TO_DATE('14:30 01/07/2012', 'HH24:MI DD/MM/YYYY'),'Iberian',4,'Willy Makit','0497699256',2);
INSERT INTO VipTransfers VALUES ('London',TO_DATE('06:10 03/05/2012', 'HH24:MI DD/MM/YYYY'),'British Airways',5,'Hugo First','0433574387',5);
INSERT INTO VipTransfers VALUES ('Moscow',TO_DATE('17:50 01/07/2012', 'HH24:MI DD/MM/YYYY'),'Aeroflot',6,'Rick OhChet','0435647833',7);
INSERT INTO VipTransfers VALUES ('Berlin',TO_DATE('11:25 01/06/2012', 'HH24:MI DD/MM/YYYY'),'Qantas',1,'Dick Taite','0469254233',4);
INSERT INTO VipTransfers VALUES ('Kuala Lumpur',TO_DATE('14:30 01/07/2012', 'HH24:MI DD/MM/YYYY'),'Cathay',7,'Hugo First','0433574387',2);
INSERT INTO VipTransfers VALUES ('Singapore',TO_DATE('06:10 03/05/2012', 'HH24:MI DD/MM/YYYY'),'Qantas',2,'Willy Makit','0497699256',1);
INSERT INTO VipTransfers VALUES ('London',TO_DATE('17:50 01/07/2012', 'HH24:MI DD/MM/YYYY'),'Lufthansa',3,'Justin Thyme','0413456789',4);
COMMIT;

CREATE TABLE R1 AS
SELECT DISTINCT gate, airline
FROM vipTransfers;

CREATE TABLE R2 AS
SELECT DISTINCT destination, departs, gate, name, contact, pickup
FROM vipTransfers;

CREATE TABLE R3 AS
SELECT DISTINCT contact, name
FROM R2;

CREATE TABLE R4 AS
SELECT DISTINCT destination, departs, gate, contact, pickup
FROM R2;

CREATE TABLE R5 AS
SELECT DISTINCT gate, departs, destination
FROM R4;

CREATE TABLE R6 AS
SELECT DISTINCT departs, gate, contact, pickup
FROM R4;

select * from ((R5 natural join R6) natural join R1) natural join R3;

DROP TABLE IF EXISTS R1;
DROP TABLE IF EXISTS R2;
DROP TABLE IF EXISTS R3;
DROP TABLE IF EXISTS R4;
DROP TABLE IF EXISTS R5;
DROP TABLE IF EXISTS R6;

select * from R2
select * from R1
select * from R4