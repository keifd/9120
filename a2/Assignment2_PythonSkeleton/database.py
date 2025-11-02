#!/usr/bin/env python3
import psycopg2

#####################################################
##  Database Connection
#####################################################

def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "y25s2c9120_yche0038"
    passwd = "chenyuhao0829"
    myHost = "awsprddbs4836.shared.sydney.edu.au"

    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)
        return conn

    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    
'''
Validate user login credentials against the database
Login comparison is case insensitive, password comparison is case sensitive
Parameters:
    login: login ID
    password: User password
Returns:
    [login, firstName, lastName, role] if valid, None if invalid
'''
def checkLogin(login, password):
    conn = openConnection()
    cur = conn.cursor()

    sql = """
    SELECT login, firstName, lastName, role
    FROM Account
    WHERE login = %s AND password = %s;
    """
    cur.execute(sql, (login, password))
    row = cur.fetchone()

    cur.close()
    conn.close()

    if row:
        return list(row)
    else:
        return None

"""
Retrieve all tracks from the database with associated artist information and average ratings
Returns:
    List of dictionaries containing track information:
        - trackid: Track ID
        - title: Track title
        - duration: Track duration
        - age_restriction: Boolean indicating if track has age restrictions
        - singer_name: Full name of the singer
        - composer_name: Full name of the composer
        - avg_rating: Average rating from all reviews (0 if no reviews)
"""
def list_tracks(): 
    try:
        conn = openConnection()
        cur = conn.cursor()
        sql = """
        SELECT t.id AS trackid, 
               t.title, 
               t.duration, 
               t.age_restriction, 
               (s_acc.firstname || ' ' || s_acc.lastname) AS singer_name,
               (c_acc.firstname || ' ' || c_acc.lastname) AS composer_name,
               get_average_rating(t.id) AS avg_rating
        FROM Track t
        LEFT JOIN Artist s_art ON s_art.login = t.singer
        LEFT JOIN Account s_acc ON s_acc.login = s_art.login
        LEFT JOIN Artist c_art ON c_art.login = t.composer
        LEFT JOIN Account c_acc ON c_acc.login = c_art.login
        LEFT JOIN Review r ON r.trackID = t.id
        GROUP BY
            t.id, t.title, t.duration, t.age_restriction, s_acc.firstname, s_acc.lastname, c_acc.firstname, c_acc.lastname
        ORDER BY t.id
        """
        cur.execute(sql)
        row = cur.fetchall()
        tracks = []
        for a in row:
            trackid = a[0]
            title = a[1]
            duration = a[2]
            age = a[3]
            singer_name = a[4]
            composer_name = a[5]
            avg_rating = a[6]
            if duration is not None:
                duration_text = f"{float(duration):.2f}"
            else:
                duration_text = ''
            if avg_rating is None:
                avg_txt = '0'
            else:
                avg_flo = float(avg_rating)
                if avg_flo == 0.0:
                    avg_txt = '0'
                else:
                    avg_txt = f"{avg_flo:.2f}"
            if singer_name is None:
                singer_txt = ''
            else:
                singer_txt = singer_name
            
            if composer_name is not None:
                composer_text = composer_name
            else:
                composer_text = ''
        
            
            tracks.append({
                'trackid':trackid,
                'title': title,
                'duration': duration_text,
                'age_restriction': age,
                'singer_name': singer_txt,
                'composer_name': composer_text,
                'avg_rating':avg_txt
            }
            )
        cur.close()
        conn.close()
        return tracks 
    except Exception as e:
        print("SQL ERROR in function list_tracks")
        print(e)
        return None

"""
Retrieve all users from the database
Returns:
    List of dictionaries containing user information:
        - login: User login ID
        - firstname: User's first name
        - lastname: User's last name
        - email: User's email address
        - role: User's role (Customer, Artist, Staff)
"""
def list_users(): 
   
    conn = openConnection()
    cur = conn.cursor()
    sql = """
    SELECT login, firstName, lastName, email, role
    FROM Account;
    """
    cur.execute(sql)
    rows = cur.fetchall()

    users = []
    for row in rows:
        users.append({
            'login': row[0],
            'firstName': row[1],
            'lastName': row[2],
            'email': row[3],
            'role': row[4]
        })
    
    cur.close()
    conn.close()
    
    return users

"""
Retrieve all reviews from the database with associated track and customer information
Returns:
    List of dictionaries containing review information:
        - reviewid: Review ID
        - track_title: Title of the reviewed track
        - rating: Review rating (1-5)
        - content: Review content text
        - customer_login: Login ID of the reviewer
        - customer_name: Full name of the reviewer
        - review_date: Date when the review was written
"""
def list_reviews(): 
    
    conn = openConnection()
    cur = conn.cursor()

    sql = """
    SELECT 
        r.reviewID,
        r.trackID,
        t.title,
        r.rating,
        r.content,
        r.customerID,
        a.firstname,
        a.lastname,
        r.reviewDate
    FROM Review r
    JOIN Track t ON t.id = r.trackID
    JOIN Customer c ON c.login = r.customerID
    JOIN Account a ON a.login = c.login
    ORDER BY r.reviewDate DESC, r.reviewID DESC;
    """

    cur.execute(sql)
    rows = cur.fetchall()

    reviews = []

    for row in rows:
        if row[6]:
            first = row[6]
        else:
            first = ""

        if row[7]:
            last = row[7]
        else:
            last = ""

        customer_name = (first + " " + last).strip()

        review_date = ""
        if row[8]:
            try:
                review_date = row[8].strftime("%d-%m-%Y")
            except Exception as e:
                review_date = str(row[8])

        review = {
            'reviewid': row[0],
            'trackid': row[1],
            'track_title': row[2],    
            'rating': row[3],
            'content': row[4],
            'customer_login': row[5],  
            'customer_name': customer_name, 
            'review_date': review_date       
        }
        reviews.append(review)

    cur.close()
    conn.close()

    return reviews

"""
Search for tracks based on a search string
Parameters:
    searchString: Search term to find matching tracks
Returns:
    List of dictionaries containing matching track information:
        - trackid: Track ID
        - title: Track title
        - duration: Track duration
        - age_restriction: Boolean indicating if track has age restrictions
        - singer_name: Full name of the singer
        - composer_name: Full name of the composer
        - avg_rating: Average rating from all reviews (0 if no reviews)
"""
def find_tracks(searchString):
    try:
        conn = openConnection()
        cur = conn.cursor()
        search = "%" + searchString +"%"
        sql = """
        SELECT t.id AS trackid, 
               t.title, 
               t.duration, 
               t.age_restriction, 
               (s_acc.firstname || ' ' || s_acc.lastname) AS singer_name,
               (c_acc.firstname || ' ' || c_acc.lastname) AS composer_name,
               COALESCE(AVG(r.rating), 0) AS avg_rating
        FROM Track t
        LEFT JOIN Artist s_art ON s_art.login = t.singer
        LEFT JOIN Account s_acc ON s_acc.login = s_art.login
        LEFT JOIN Artist c_art ON c_art.login = t.composer
        LEFT JOIN Account c_acc ON c_acc.login = c_art.login
        LEFT JOIN Review r ON r.trackID = t.id
        WHERE t.title ILIKE %s
        GROUP BY
            t.id, t.title, t.duration, t.age_restriction, s_acc.firstname, s_acc.lastname, c_acc.firstname, c_acc.lastname
        ORDER BY t.id,avg_rating DESC
        """
        cur.execute(sql, (search,))
        row = cur.fetchall()
        tracks = []
        for a in row:
            trackid = a[0]
            title = a[1]
            duration = a[2]
            age = a[3]
            singer_name = a[4]
            composer_name = a[5]
            avg_rating = a[6]
            if duration is not None:
                duration_text = f"{float(duration):.2f}"
            else:
                duration_text = ''
            
            if avg_rating is None:
                avg_txt = '0'
            else:
                avg_flo = float(avg_rating)
                if avg_flo == 0.0:
                    avg_txt = '0'
                else:
                    avg_txt = f"{avg_flo:.2f}"
                
            if singer_name is None:
                singer_txt = ''
            else:
                singer_txt = singer_name
            
            if composer_name is not None:
                composer_text = composer_name
            else:
                composer_text = ''
        
            
            tracks.append({
                'trackid':trackid,
                'title': title,
                'duration': duration_text,
                'age_restriction': age,
                'singer_name': singer_txt,
                'composer_name': composer_text,
                'avg_rating':avg_txt
            }
            )
        cur.close()
        conn.close()
        return tracks 
    except Exception as e:
        print("SQL ERROR in function find_tracks")
        print(e)
        return None

"""
Add a new user to the database
Parameters:
    login: User's login ID
    firstname: User's first name
    lastname: User's last name
    password: User's password
    email: User's email address (can be empty)
    role: User's role (Customer, Artist, Staff)
Returns:
    True if user added successfully, False if error occurred
"""
def add_user(login, firstname, lastname, password, email, role):
    try:
        conn = openConnection()
        cur = conn.cursor()
        sql = """
        INSERT INTO Account
        (login, firstname, lastname, password, email, role)
        VALUES
        (%s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (login, firstname, lastname, password, email, role))
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        return False

"""
Add a new review to the database
Parameters:
    trackid: ID of the track being reviewed
    rating: Review rating (1-5)
    customer_login: Login ID of the customer writing the review
    content: Review content text (can be null)
    review_date: Date when the review was written
Returns:
    True if review added successfully, False if error occurred
"""
def add_review(trackid, rating, customer_login, content, review_date):
   
    try:
        conn = openConnection()
        cur = conn.cursor()
        sql = """
        INSERT INTO Review (trackID, content, rating, customerID, reviewDate)
        VALUES 
        (%s, %s, %s, %s, %s)
        """
        cur.execute(sql, (trackid, content, rating, customer_login, review_date))
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        return False

"""
Update an existing track in the database
Parameters:
    trackid: ID of the track to update
    title: Updated track title
    duration: Updated track duration
    age_restriction: Updated age restriction setting
    singer_login: Updated singer's login ID (must exist as Artist, case insensitive)
    composer_login: Updated composer's login ID (must exist as Artist, case insensitive)
Returns:
    True if track updated successfully, False if error occurred
"""
def update_track(trackid, title, duration, age_restriction, singer_login, composer_login):
    conn = None
    cur = None
    try:
        conn = openConnection()
        cur = conn.cursor()

        duration_value = None
        if duration is not None:
            duration_text = str(duration)
            if duration_text != "":
                try:
                    duration_value = float(duration_text)
                except ValueError:
                    return False

        age_value = age_restriction
        if isinstance(age_value, str):
            normalized_age = age_value.lower()
            if normalized_age == "":
                age_value = None
            else:
                age_value = normalized_age in ("true", "t", "1", "yes", "y")

        singer_value = None
        if singer_login is not None:
            singer_text = str(singer_login).strip()
            if singer_text != "":
                cur.execute(
                    """
                    SELECT ar.login
                    FROM Artist ar
                    JOIN Account acc ON acc.login = ar.login
                    WHERE LOWER(ar.login) = LOWER(%s)
                       OR LOWER(TRIM(COALESCE(acc.firstname, '') || ' ' || COALESCE(acc.lastname, ''))) = LOWER(TRIM(%s))
                    """,
                    (singer_text, singer_text)
                )
                singer_row = cur.fetchone()
                if singer_row is None:
                    return False
                singer_value = singer_row[0]

        composer_value = None
        if composer_login is not None:
            composer_text = str(composer_login).strip()
            if composer_text != "":
                cur.execute(
                    """
                    SELECT ar.login
                    FROM Artist ar
                    JOIN Account acc ON acc.login = ar.login
                    WHERE LOWER(ar.login) = LOWER(%s)
                       OR LOWER(TRIM(COALESCE(acc.firstname, '') || ' ' || COALESCE(acc.lastname, ''))) = LOWER(TRIM(%s))
                    """,
                    (composer_text, composer_text)
                )
                composer_row = cur.fetchone()
                if composer_row is None:
                    return False
                composer_value = composer_row[0]

        sql = """
        UPDATE Track
        SET title = %s, duration = %s, age_restriction= %s, composer = %s,singer = %s
        WHERE id = %s
        """
        cur.execute(sql, (title, duration_value, age_value, composer_value, singer_value, trackid))
        conn.commit()
        cur.close()
        conn.close()
        return cur.rowcount == 1
    except Exception as e:
        print("SQL ERROR in function update_track")
        print(e)
        return False


"""
Update an existing review in the database
If update is successful, the review date will be updated to the current date
Parameters:
    reviewid: ID of the review to update
    rating: Updated review rating (1-5)
    content: Updated review content text (can be null)
Returns:
    True if review updated successfully, False if error occurred
"""
def update_review(reviewid, rating, content):
    try:
        conn = openConnection()
        cur = conn.cursor()
        sql = """
        UPDATE Review
        SET rating = %s,
            content = %s
        WHERE reviewID = %s
        """
        cur.execute(sql, (rating, content, reviewid))
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        return False
"""
Update an existing user in the database
Parameters:
    user_login: Login ID of the user to update
    firstname: Updated user's first name
    lastname: Updated user's last name
    email: Updated user's email address (can be null)
Returns:
    True if user updated successfully, False if error occurred
"""
def update_user(user_login, firstname, lastname ,email):
    try:
        conn = openConnection()
        cur = conn.cursor()
        sql  = """
        UPDATE Account
        SET firstname = %s, lastname = %s, email = %s
        WHERE login = %s
        """
        cur.execute(sql, (firstname, lastname, email, user_login))
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        return False
