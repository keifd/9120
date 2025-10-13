/*Exercise 2. Flight Booking Schema*/
CREATE TABLE Plane (
plane_Id VARCHAR(8),
category CHAR(9) NOT NULL CHECK (category IN ('jet', 'turboprop')),
capacity INTEGER NOT NULL,
PRIMARY KEY plane_Id
);

CREATE TABLE Flight (
flight_Id INTEGER,
plane_Id VARCHAR(8),
departs DATE NOT NULL,
origin VARCHAR(20) NOT NULL,
destination VARCHAR(20) NOT NULL,
PRIMARY KEY flight_Id,
FOREIGN KEY plane_id REFERENCES Plane DELETE NO ACTION
);

ALTER TABLE Flight ADD CONSTRAINT one_flight_per_day UNQIUE(plane_Id, departs);

/*Exercise 3 Populating the DB*/
INSERT INTO TABLE Plane ('12345678', 'jet', 10);
UPDATE Plane SET category VALUES 'turboprop' WHERE plane_Id = '12345678';
DELETE FROM Plane WHERE  plane_Id = '12345678';



