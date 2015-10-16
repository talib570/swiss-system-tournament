#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2
from contextlib import contextmanager

def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


@contextmanager
def get_cursor():
    """ Responsible for opening and closing database connection"""
    conn = connect()
    cursor = conn.cursor()
    
    try:
        yield cursor
    except:
        raise
    else:
        conn.commit()
    finally:
        cursor.close()
        conn.close()


def deleteMatches():
    """Remove all the match records from the database."""
    
    # Deletes all matches
    with get_cursor() as cur:
        cur.execute("DELETE FROM match_report;")


def deletePlayers():
    """Remove all the player records from the database."""

    # Deletes all players
    with get_cursor() as cur:
        cur.execute("DELETE FROM players;")


def countPlayers():
    """Returns the number of players currently registered."""
    
    # Gets players count
    with get_cursor() as cur:
        cur.execute("select count(id) from players")

        # Fetches result from cursur
        count = cur.fetchall()[0]    
    
    return count[0]


def registerPlayer(name):
    """Adds a player to the tournament database.
  
    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)
  
    Args:
      name: the player's full name (need not be unique).
    """
    
    # Inserts new player in database
    with get_cursor() as cursor:
        cursor.execute("INSERT INTO players(name) VALUES (%s);", [name])


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """

    # Initializes empty list
    result = []
    
    # Gets match report
    with get_cursor() as cur:
        cur.execute("select * from get_summary;")

        # Loops through result and puts values in list
        result += [(int(row[0]), 
                    str(row[1]), 
                    int(row[2]), 
                    int(row[3])) 
                    for row in cur.fetchall()]
    return result


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    
    # Used round and tournament so provided 
    # hardcoded values, will update in next version
    record = (1, winner, loser, winner, 1)
    
    # Puts data into match_report table
    with get_cursor() as cursor:
        cursor.execute("INSERT INTO match_report "+
                    "(tournament_id, player1_id, player2_id, winner, match_round)"+
                    " VALUES ('%s','%s','%s','%s','%s');", record)
 
 
def swissPairings():
    """Returns a list of pairs of players for the next round of a match.
  
    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.
  
    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    
    # Pulls players current standings
    standings = playerStandings()
    
    # Initializes empty pairing list
    pairings = []
    
    # Loops through result current standings
    for x in range(0, len(standings)):
        
        # As the result is in order by max score
        # For every second iteration we put the two opponents in list
        if x%2==0:
            pairings += [(standings[x][0], 
                          standings[x][1],
                          standings[x+1][0], 
                          standings[x+1][1])]
    return pairings
