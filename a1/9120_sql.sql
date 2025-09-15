DROP TABLE IF EXISTS remove;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS listening_stat;
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS contribute;
DROP TABLE IF EXISTS album;
DROP TABLE IF EXISTS track;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS person;

DROP FUNCTION IF EXISTS update_age(); 
DROP FUNCTION IF EXISTS duplicate_playlist_name();

/*
Previous codes are done for testing.
Won't be listing out all the domain constraints, key constraints,
and referential integrity constraints that are obvious
*/
CREATE TABLE person (
  person_id         CHAR(9),
  full_name         VARCHAR(100) NOT NULL,
  login_password    VARCHAR(100) NOT NULL,
  phone_number      VARCHAR(20),
  unique_login_name VARCHAR(60) NOT NULL UNIQUE,

  PRIMARY KEY(person_id)
);

/* 
Semantic Integrity check assumning minimum user's age is 10
years old and can't be over 100
*/
CREATE TABLE customer (
  person_id        CHAR(9),
  customer_id      CHAR(9) unique,
  age              INTEGER NOT NULL CHECK (age > 10 AND age < 100),
  date_of_birth    DATE NOT NULL,

  PRIMARY KEY (person_id, customer_id),
  FOREIGN KEY (person_id) REFERENCES person(person_id)
) INHERITS (person);
/* 
This function updates a customer's age everytime we make changes to
a customer's row as well as inserting a new customer to the table
*/
CREATE OR REPLACE FUNCTION update_age()
RETURNS TRIGGER AS $$
BEGIN
    NEW.age := DATE_PART('year', AGE(NEW.date_of_birth));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER age_trigger
BEFORE INSERT OR UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION update_age();

/*
artist is a subclass of person using table inheritance
*/
CREATE TABLE artist (
  person_id    CHAR(9),
  artist_id    CHAR(9) UNIQUE,
  
  PRIMARY KEY(person_id, artist_id),
  FOREIGN KEY(person_id) REFERENCES person(person_id)
) INHERITS (person);

/*
staff is a subclass of person using table inheritance,
semantic integrity constraints compensation is between 0 and
200000
*/
CREATE TABLE staff (
  person_id    CHAR(9),
  staff_id     CHAR(9) unique,
  address      VARCHAR(200),
  compensation INTEGER NOT NULL CHECK (compensation > 0 and compensation < 200000),

  PRIMARY KEY(person_id, staff_id),
  FOREIGN KEY(person_id) REFERENCES person(person_id)
) INHERITS (person);

/*
We used list to create multivalue genre(s),
domain constraints title not null,
semantic integrity cosntraint to check duration is
not negative, legal_restrictions_age can be null or
greater than 0
*/
CREATE TABLE track (
  track_id      INTEGER,
  title         VARCHAR(200) NOT NULL,
  genre         TEXT[],
  duration      INTEGER NOT NULL CHECK (duration > 0),
  legal_restrictions_age INTEGER CHECK(legal_restrictions_age IS NULL OR legal_restrictions_age >= 0),

  PRIMARY KEY (track_id)
);

/*
Domain constraints that album name should have values
*/
CREATE TABLE album (
  album_id      INTEGER,
  track_id      INTEGER,
  album_name    VARCHAR(200) NOT NULL,
  is_most_popular BOOL NOT NULL,

  PRIMARY KEY (album_id, track_id),
  FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE
);

/*
Domain constraint artist's role shouldn't be empty if he
is part of the contribution for a track
*/
CREATE TABLE contribute (
  track_id     INTEGER,
  artist_id    CHAR(9),
  artist_role  VARCHAR(60) NOT NULL,

  PRIMARY KEY (track_id, artist_id, artist_role),
  FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE,
  FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON DELETE CASCADE
);

/*
Key constraint that playlist_name is unique across all playlists,
key constraint two tracks in a the same playlist shouldn't have the same order
*/
CREATE TABLE playlist (
  playlist_id    INTEGER,
  customer_id    CHAR(9),
  track_id       INTEGER,
  playlist_name  VARCHAR(120) NOT NULL,
  playlist_create_time    TIMESTAMP NOT NULL,
  track_order         INTEGER NOT NULL,

  UNIQUE(playlist_id, track_order),

  PRIMARY KEY (playlist_id),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
  FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE
);

/*
This function checks if a customer have two playlists with the same name
*/
CREATE OR REPLACE FUNCTION duplicate_playlist_name()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM playlist
        WHERE customer_id = NEW.customer_id
          AND playlist_name = NEW.playlist_name
    ) THEN
        RETURN NULL; 
    END IF;
    RETURN NEW;  
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unqiue_playlist_name
BEFORE INSERT OR UPDATE ON playlist
FOR EACH ROW
EXECUTE FUNCTION duplicate_playlist_name();

/*
We use delete on delete cascade to make sure that if we delete
the track, or customer, then the following rows in the listening_stat
would also be deleted
*/
CREATE TABLE listening_stat (
  track_id      INTEGER,
  customer_id     CHAR(9),
  listen_count  INTEGER NOT NULL CHECK (listen_count >= 0),
  PRIMARY KEY (track_id, customer_id),
  FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);

/*	
Semantic intgegrity check the user should only give a rating between 1 and 5
*/
CREATE TABLE review (
  customer_id   CHAR(9),
  track_id      INTEGER,
  create_time_date   TIMESTAMP NOT NULL,
  short_review  VARCHAR(500),
  point_scale   INTEGER NOT NULL CHECK (point_scale BETWEEN 1 AND 5),

  PRIMARY KEY (customer_id, track_id),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
  FOREIGN KEY (track_id) REFERENCES track(track_id) ON DELETE CASCADE
);

/*
Assume that the staff must give a reason for each review
removal thus not null
*/
CREATE TABLE remove (
  customer_id   CHAR(9),
  track_id      INTEGER, 
  staff_id      CHAR(9),
  remove_date   DATE NOT NULL,
  remove_time   TIME NOT NULL,
  remove_reason VARCHAR(300) NOT NULL,
  PRIMARY KEY (customer_id, track_id, staff_id),
  FOREIGN KEY (customer_id, track_id)
    REFERENCES review(customer_id, track_id) ON DELETE CASCADE,
  FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

/* add some data - the following data is completely arbitray */
/* data could be generated */
-- person
INSERT INTO person (person_id, full_name, login_password, phone_number, unique_login_name)
VALUES 
('CUST00001', 'Alice Brown', 'pass123', '123-456-7890', 'alice_b'),
('ART000001', 'John Melody', 'melodypass', '555-234-5678', 'john_m'),
('STF000001', 'Karen Admin', 'securepass', '987-654-3210', 'karen_a'),
('CUST00002', 'Bob Smith', 'bobpass', '321-654-0987', 'bob_s'),
('ART000002', 'Emma Harmony', 'emmapass', '555-987-1234', 'emma_h'),
('STF000002', 'Tom Supervisor', 'tomsecure', '444-555-6666', 'tom_s');



-- customer
INSERT INTO customer (person_id, full_name, login_password, phone_number, unique_login_name,
                      customer_id, age, date_of_birth)
VALUES 
('CUST00001', 'Alice Brown', 'pass123', '123-456-7890', 'alice_b',
 'CUST00001', 20, '1995-09-13'),
('CUST00002', 'Bob Smith', 'bobpass', '321-654-0987', 'bob_s', 
 'CUST00002', 25, '2000-06-20');
 
 
-- artist
INSERT INTO artist (
    person_id, full_name, login_password, phone_number, unique_login_name,
    artist_id
) VALUES 
('ART000001', 'John Melody', 'melodypass', '555-234-5678', 'john_m', 'ART000001'),
('ART000002', 'Emma Harmony', 'emmapass', '555-987-1234', 'emma_h', 'ART000002');

-- staff
INSERT INTO staff (
    person_id, full_name, login_password, phone_number, unique_login_name,
    staff_id, address, compensation
) VALUES 
('STF000001', 'Karen Admin', 'securepass', '987-654-3210', 'karen_a',
 'STF000001', '42 Admin Lane, Metropolis, MA', 65000),
('STF000002', 'Tom Supervisor', 'tomsecure', '444-555-6666', 'tom_s',
 'STF000002', '99 Admin Blvd, Metropolis, MA', 72000);


-- track
INSERT INTO track (track_id, title, genre, duration, legal_restrictions_age)
VALUES 
(101, 'Golden Hour', ARRAY['Pop','Indie'], 240, NULL),
(102, 'Electric Pulse', ARRAY['Electronic','Dance'], 195, 18),
(103, 'Sunset Dreams', ARRAY['Jazz','Instrumental'], 300, 18),
(104, 'Bass Drop', ARRAY['EDM','Dance'], 210, 16);

-- album
INSERT INTO album (album_id, track_id, album_name, is_most_popular)
VALUES 
(1, 101, 'Golden Vibes', TRUE),
(2, 102, 'Night Energy', FALSE),
(3, 103, 'Evening Calm', TRUE),
(4, 104, 'Dance Mania', FALSE);


-- playlist
INSERT INTO playlist (
    playlist_id, customer_id, track_id, playlist_name, playlist_create_time, track_order
) VALUES 
(1, 'CUST00001', 101, 'Morning Chill', '2025-09-13 08:30:00', 1),
(2, 'CUST00001', 102, 'Night Hype', '2025-09-13 22:15:00', 1),
(3, 'CUST00002', 103, 'Evening Relax', '2025-09-13 19:00:00', 1),
(4, 'CUST00002', 104, 'Workout Pump', '2025-09-13 06:45:00', 1);

-- contribute
INSERT INTO contribute (track_id, artist_id, artist_role)
VALUES 
(101, 'ART000001', 'Singer'),
(102, 'ART000001', 'Producer'),
(103, 'ART000002', 'Composer'),
(104, 'ART000002', 'DJ');


-- listening_stat
INSERT INTO listening_stat (track_id, customer_id, listen_count)
VALUES 
(101, 'CUST00001', 34),
(102, 'CUST00001', 18),
(103, 'CUST00002', 12),
(104, 'CUST00002', 27);

-- review
INSERT INTO review (customer_id, track_id, create_time_date, short_review, point_scale)
VALUES 
('CUST00001', 101, '2025-09-13 12:00:00', 'Great vibe and rhythm!', 5),
('CUST00001', 102, '2025-09-13 21:00:00', 'Too intense but still good.', 3),
('CUST00002', 103, '2025-09-13 20:00:00', 'So relaxing and smooth!', 4),
('CUST00002', 104, '2025-09-13 07:30:00', 'Really pumps me up!', 5);

-- remove
INSERT INTO remove (customer_id, track_id, staff_id, remove_date, remove_time, remove_reason)
VALUES 
('CUST00001', 102, 'STF000001', '2025-09-13', '23:00:00', 'Review contained inappropriate language.'),
('CUST00002', 104, 'STF000002', '2025-09-13', '08:00:00', 'Explicit content in lyrics.');


/* for testing */
select * 
from person
