-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.


-- After applying the DROP DATABASE tournament command
-- I was still able to see the tables in it using
-- \d, so I've manually dropped all the tables as well
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS tournaments CASCADE;
DROP TABLE IF EXISTS tournament_players CASCADE;
DROP TABLE IF EXISTS match_report CASCADE;


-- Switches to default database to drop tournament DB
\c vagrant

-- Drops the database if it exists
DROP DATABASE IF EXISTS tournament;

-- Creates new database
CREATE DATABASE tournament;

-- Switches back to tournament database
\c tournament;

-- this table will store all players
-- and their bio data
-- also adds unique key constraint on name
CREATE TABLE players(
	id SERIAL PRIMARY KEY NOT NULL,
	name TEXT NOT NULL,
	UNIQUE (name)	
);

-- this table can store data about tournaments
-- like title, event year, country etc
CREATE TABLE tournaments(
	id SERIAL PRIMARY KEY NOT NULL,
	title TEXT NOT NULL
);

-- this will keep record of players associated 
-- with a particular tournament
CREATE TABLE tournament_players(
	id SERIAL PRIMARY KEY NOT NULL,
	tournament_id integer NOT NULL,
	player_id integer NOT NULL,
	CONSTRAINT fk_Tournament FOREIGN KEY (tournament_id)
	REFERENCES tournaments (id) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_Player FOREIGN KEY (player_id)
	REFERENCES players (id) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE
);

-- match_report table will save match fixes and 
-- their results, it is designed this way so that
-- it can also handle the match ties 0-0
-- in case of a tie both players will be given 
-- score 0-0
CREATE TABLE match_report(
	id SERIAL PRIMARY KEY NOT NULL,
	tournament_id integer NOT NULL,
	player1_id integer NOT NULL,
	player2_id integer NOT NULL,
	winner integer NOT NULL,
	match_round integer NOT NULL,
	CONSTRAINT fk_Tournament FOREIGN KEY (tournament_id)
	REFERENCES tournaments (id) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_Player1 FOREIGN KEY (player1_id)
	REFERENCES players (id) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_Player2 FOREIGN KEY (player2_id)
	REFERENCES players (id) MATCH SIMPLE
	ON UPDATE CASCADE ON DELETE CASCADE
);

-- Gets players with their win count
CREATE VIEW get_wins AS
	SELECT p.id, COUNT(m.winner) AS wins 
		FROM players p 
		LEFT JOIN match_report m ON p.id = m.winner 
		GROUP BY p.id ORDER BY wins DESC;

-- The next three view are little hacks I think
-- get_all_matches this view return 1 match for all players
-- even when they didn't
CREATE VIEW get_all_matches AS 
	SELECT p.id, COUNT(p.id) AS total_matches 
		FROM players p 
		LEFT JOIN match_report m ON m.player1_id = p.id
		OR m.player2_id = p.id GROUP BY p.id;

-- This one(get_match_status) returns nothing when player 
-- did not played any match
CREATE VIEW get_match_status AS 
	SELECT p.id, COUNT(m.player1_id) AS matches 
		FROM players p 
		JOIN match_report m ON m.player1_id = p.id OR m.player2_id = p.id 
		GROUP BY p.id;		

-- In get_matches we then compare the two VIEWS
-- and it returns the correct matches played by players
CREATE VIEW get_matches AS 
	SELECT g.id, 
		CASE WHEN gs.matches IS NULL THEN 0 
			ELSE gs.matches 
		END 
		FROM get_all_matches g 
		LEFT JOIN get_match_status gs ON gs.id = g.id;

-- get_summary this view gets the players summary for the tournament
CREATE VIEW get_summary AS
	SELECT p.id, p.name, get_wins.wins, 
		CASE WHEN get_matches.matches IS NULL THEN 0 
			ELSE get_matches.matches 
		END 
		FROM players p 
		JOIN get_wins ON p.id = get_wins.id 
		JOIN get_matches ON p.id = get_matches.id 
		ORDER BY wins DESC;

-- A manual insert query will be used by default for now!!
INSERT INTO tournaments(title) VALUES ('Test Match');