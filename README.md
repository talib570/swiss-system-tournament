# swiss-system-tournament
An application written in **python** backed by **postgresql** database to implement the [Swiss-system tournament simulation.](https://en.wikipedia.org/wiki/Swiss-system_tournament)

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

###CHANGELOG
 - Updated the tournament.sql file which includes DB schema and views.
 - Updated tournament.py file to pass all the testcases written in tournament_test.py

### License
 - Please see the file called LICENSE.