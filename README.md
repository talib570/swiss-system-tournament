# swiss-system-tournament
An application written in **python** backed by **postgresql** database
to implement the [Swiss-system tournament simulation.](https://en.wikipedia.org/wiki/Swiss-system_tournament)

### Requirements
 - Python 2.7
 - PostgreSQL

### Setting up project
To configure the project you'll first need to setup the database.
Now, login to postgresql cli mode using the command
```
  psql
```
then type in the following command to import the database:
```
  \i tournament.sql
```
then simply clone the repo using
```
 git clone https://github.com/talib570/swiss-system-tournament.git
```
cd into the folder `swiss-system-tournament`
```
  cd swiss-system-tournament
```
then type the following command
```
  python tournament_test.py
```

**Note:**
The project also uses contextlib module of python to perform common tasks.
```
def get_cursor():
    """ Responsible for opening and closing database connection"""
    conn = connect()
    cur = conn.cursor()

    try:
        yeild cur
    except:
        raise
    else:
        conn.commit()
    finally:
        cur.close()
        conn.close()
```
What this does is basically it allows us to remove code duplication. Now
we can simply run the queries like this without opening and closing database
connection for every query:
```
    with get_cursor() as cursor:
        cursor.execute("DELETE FROM match_report;")
```

### CHANGELOG
 - Updated the tournament.sql file which includes DB schema and views.
 - Updated tournament.py file to pass all the testcases
   written in tournament_test.py

###### Date: 17 Oct, 2015
 - Added contectlib module for eliminating redundancy in database
   connection code.
 - Removed `UNIQUE` constraint from `name` column of `players` table
 - Removed `NOT NULL` from `PRIMARY KEY` columns
 - Updated `List Comprehensions` in `playerStanding` function in tournament.py

### License
 - Please see the file called LICENSE.