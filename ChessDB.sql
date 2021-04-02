CREATE DATABASE chess;

CREATE TABLE Chessman(
    id serial primary key,
    class char(20) check (class in ('king', 'queen', 'rook', 'bishop', 'knight', 'pawn')) NOT NULL,
    color char(20) check (color in ('white', 'black')) NOT NULL
);

CREATE TABLE Chessboard(
    chessman_id int primary key references chessman(id),
    x char check (x between 'A' and 'H') NOT NULL,
    y int check (y between 1 and 8) NOT NULL,
    UNIQUE (x, y)
);

--Inserts chessmen with specified class and both color to the table
CREATE OR REPLACE PROCEDURE insert_chessmen (chessman_class char(20), count int)
LANGUAGE plpgsql
as $$
    begin
        FOR i in 1..count loop
            INSERT INTO  Chessman(class, color) values (chessman_class, 'white');
            INSERT INTO  Chessman(class, color) values (chessman_class, 'black');
        end loop;
    end
$$;

--Initializes set of chess figures
CREATE OR REPLACE PROCEDURE init_figures ()
LANGUAGE plpgsql
as $$
    begin
        call insert_chessmen('pawn', 8);
        call insert_chessmen('knight', 2);
        call insert_chessmen('bishop', 2);
        call insert_chessmen('rook', 2);
        call insert_chessmen('queen', 1);
        call insert_chessmen('king', 1);
    end
$$;

--Places all chessmen of specified type to all positions on the line with specified step
CREATE OR REPLACE PROCEDURE place_chessmen(required_class char(20), white_line_number int, initial_pos int, step int)
LANGUAGE plpgsql
as $$
    declare
    chessman_record int;
    i int := initial_pos;
    x_positions char[] := array['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    begin
        for chessman_record in
            select id from chessman where class = required_class and color = 'white'
        loop
            insert into  Chessboard values (chessman_record, x_positions[i], white_line_number);
            i := i + step;
        end loop;
        i := initial_pos;
        for chessman_record in
            select id from chessman where class = required_class and color = 'black'
        loop
            insert into  Chessboard values (chessman_record, x_positions[i], 9 - white_line_number);
            i := i + step;
        end loop;
    end
$$;

--Initializes chessboard
CREATE OR REPLACE PROCEDURE init_board()
LANGUAGE plpgsql
as $$
    begin
        call place_chessmen('pawn', 2, 1, 1);
        call place_chessmen('rook', 1, 1, 7);
        call place_chessmen('knight', 1, 2, 5);
        call place_chessmen('bishop', 1, 3, 3);
        call place_chessmen('queen', 1, 4, 0);
        call place_chessmen('king', 1, 5, 0);
    end
$$;

--Initializes new chess game
CREATE OR REPLACE PROCEDURE init_game ()
LANGUAGE plpgsql
as $$
    begin
        TRUNCATE Chessman CASCADE;
        TRUNCATE Chessboard;
        call init_figures();
        call init_board();
    end
$$;

call init_game();

-- 1.Amount of figures on the board
SELECT count(*) FROM Chessboard;

-- 2.Ids of figures which class starts with k
SELECT id FROM Chessman WHERE substring(class, 1, 1) = 'k';

-- 3.Table of all types with the amount of figures being in that class
SELECT class, count(*) AS count FROM chessman GROUP BY class;

--4.Ids of all white pawns on the board
SELECT id FROM Chessboard LEFT JOIN Chessman ON chessman_id = id WHERE color='white' and class = 'pawn';

--5.Class and color of chessmen on the main diagonal
SELECT class, color from Chessman LEFT JOIN Chessboard ON chessman_id = id WHERE ascii(x) - ascii('A')= y - 1;

--6.Amount of player's figures on the board
SELECT color, count(*) as count from chessman LEFT JOIN Chessboard on id = chessman_id GROUP BY color;

--7.Types of black chessmen on the board
SELECT class from Chessman LEFT JOIN Chessboard on id = chessman_id where color = 'black' GROUP BY class;

--8.Types of black figures on the board with amount
SELECT class, count(*) as count from Chessman LEFT JOIN Chessboard on id = chessman_id where color = 'black' GROUP BY class;

 --9.Chessman classes which have not less than two instances on the board
SELECT class from Chessman LEFT JOIN  Chessboard on id = chessman_id GROUP BY class HAVING count(*) > 1;

--10.Color with maximum amount of chessmen on the board
WITH A AS (SELECT color, COUNT(Chessman) count FROM Chessman LEFT JOIN Chessboard on id = chessman_id GROUP BY color)
SELECT * FROM A WHERE count = (SELECT MAX(count) FROM A);

--11.Figures on a rook path
WITH Rook_coords AS (SELECT DISTINCT X, Y FROM Chessman LEFT JOIN Chessboard on id = chessman_id WHERE class = 'rook')
SELECT id FROM Chessman, Chessboard, Rook_coords WHERE id = chessman_id AND (Chessboard.x = Rook_coords.x OR Chessboard.y = Rook_coords.y);

--12.Colors of players who have all pawns on the board
SELECT color from Chessman LEFT JOIN Chessboard on id = chessman_id GROUP BY class, color HAVING count(*) = 8 and class = 'pawn';

--Preparing to 13
SELECT * INTO ChessBoard2 FROM Chessboard;
DELETE FROM ChessBoard2 WHERE x = 'A' and y = '1';

--13.Chessmen who turned from first state to second
SELECT DISTINCT id FROM Chessman, Chessboard, ChessBoard2 WHERE
(id = Chessboard.chessman_id AND id = ChessBoard2.chessman_id AND (Chessboard.x <> Chessboard2.x OR Chessboard.y <> ChessBoard2.y))
OR (EXISTS(SELECT * FROM ChessBoard where id = Chessboard.chessman_id) AND NOT EXISTS(SELECT * FROM ChessBoard2 where id = Chessboard2.chessman_id));

--14.Chessmen in 5x5 square around black king
WITH bkCoords AS (SELECT x, y FROM Chessman LEFT JOIN  Chessboard on id = chessman_id WHERE class = 'king' AND color = 'black')
SELECT id FROM Chessman, Chessboard, bkCoords WHERE id = chessman_id AND abs(Chessboard.y - bkCoords.y) BETWEEN 0 AND 2
AND abs(ascii(Chessboard.x) - ascii(bkCoords.x)) BETWEEN 0 AND 2 AND (class <> 'king' or color <> 'black');

--15.Chessmen with minimum distance from white king
WITH Distance AS(
    WITH wkCoords AS (SELECT x, y FROM Chessman LEFT JOIN Chessboard on id = chessman_id WHERE class = 'king' and color = 'white')
	SELECT id, abs(Chessboard.y - wkCoords.y) + abs(ascii(Chessboard.x) - ascii(wkCoords.x)) AS value
	FROM Chessman, Chessboard, wkCoords WHERE id = chessman_id AND (class <> 'king' or color <> 'white'))
SELECT id FROM Distance WHERE Distance.value = (SELECT MIN(Distance.value) FROM Distance);

--Procedure which moves chessman with the specified id into new position
CREATE OR REPLACE PROCEDURE move_figure(prevX char, prevY int, newX char, newY int)
LANGUAGE plpgsql
AS $$
DECLARE figureColor char(20);
DECLARE colorOnNewPosition char(20);
DECLARE figureId int;
BEGIN
   BEGIN
       SELECT chessman_id INTO figureId FROM Chessboard LEFT JOIN Chessman ON chessman_id = id
       WHERE x = prevX and y = prevY;
   END;
   BEGIN --Receive color of chessman on the new position
       SELECT color INTO figureColor FROM Chessboard LEFT JOIN Chessman ON chessman_id = id
       WHERE id = figureId;
   END;
   BEGIN --Receive color of moving chessman
       SELECT color INTO colorOnNewPosition FROM Chessboard LEFT JOIN Chessman ON chessman_id = id
       WHERE x = newX and y = newY;
   END;
   IF figureId IS NOT NULL AND newX BETWEEN 'A' AND 'H' AND newY BETWEEN 1 AND 8 THEN
       IF colorOnNewPosition = 'black' OR colorOnNewPosition = 'white' THEN
           IF figureColor != colorOnNewPosition THEN
			    DELETE FROM Chessboard WHERE x = newX AND y = newY;
			    UPDATE Chessboard SET x = newX, y = newY WHERE chessman_id = figureId;
           END IF;
	ELSE
		UPDATE Chessboard SET x = newX, y = newY WHERE chessman_id = figureId;
	END IF;
   END IF;
END
$$;

--State of the board before any moving
SELECT chessman_id, x, y, class, color from Chessman left join Chessboard on id = chessman_id;
DROP TABLE InitialChessboard;
SELECT * INTO InitialChessboard FROM Chessboard;

SELECT DISTINCT id, color, class, Chessboard.x AS newX, Chessboard.y as newY FROM Chessman, Chessboard, InitialChessboard WHERE
(id = Chessboard.chessman_id AND id = InitialChessboard.chessman_id AND (Chessboard.x <> InitialChessboard.x OR Chessboard.y <> InitialChessboard.y))
OR (EXISTS(SELECT * FROM ChessBoard where id = Chessboard.chessman_id) AND NOT EXISTS(SELECT * FROM InitialChessboard where id = InitialChessboard.chessman_id));

--Examples of usage of the moving function:
--1.Invalid call, specified previous position doesn't exist
call move_figure('A', 20, 'B', 3);

--2.Invalid call, specified new position doesn't exist
call move_figure('A', 1, 'B', 10);

--3.Move figure into a free position
call move_figure('A', 1, 'B', 4);

--4.Move figure into a position occupied by a figure of the same color
call move_figure('B', 4, 'A', 2);

--5.Move figure into a position occupied by a figure of the opposite color
call move_figure('A', 2, 'A', 8);

DROP TABLE MoveLog;
CREATE TABLE MoveLog(
    id SERIAL PRIMARY KEY,
    chessman_id INT NOT NULL,
    previous_x CHAR CHECK (previous_x BETWEEN 'A' AND 'H'),
    previous_y INT CHECK (previous_y BETWEEN 1 AND 8),
    new_x CHAR CHECK (new_x BETWEEN 'A' AND 'H'),
    new_y INT CHECK (new_y BETWEEN 1 AND 8)
);

--Trigger function which saves turn data into the MoveLog table
CREATE OR REPLACE FUNCTION move_trigger() RETURNS trigger AS $move_trigger$
DECLARE prev_x CHAR;
DECLARE prev_y INT;
BEGIN
    IF NEW IS NULL THEN --Deletion case
		INSERT INTO MoveLog(chessman_id, previous_x, previous_y, new_x, new_y) VALUES (OLD.chessman_id, OLD.x, OLD.y, null, null);
		RETURN OLD;
	ELSE
	    IF OLD IS NULL THEN --New figure on the board case
            INSERT INTO MoveLog(chessman_id, previous_x, previous_y, new_x, new_y) VALUES (NEW.chessman_id, null, null, NEW.x, NEW.y);
        ELSE --Moving figure on the board case
            prev_x := OLD.x;
            prev_y := OLD.y;
		    INSERT INTO MoveLog(chessman_id, previous_x, previous_y, new_x, new_y) VALUES (NEW.chessman_id, prev_x, prev_y, NEW.x, NEW.y);
        END IF;
		RETURN NEW;
	END IF;
END;
$move_trigger$ LANGUAGE plpgsql;

--Move trigger initialization
DROP TRIGGER IF EXISTS move_trigger ON Chessboard;
CREATE TRIGGER move_trigger AFTER INSERT OR DELETE OR UPDATE ON Chessboard FOR EACH ROW EXECUTE PROCEDURE move_trigger();

TRUNCATE MoveLog;

--Few examples:

--1.New figures on the board case
call init_game();

--2.Simple moving case
call move_figure('E', 2, 'E', 4);

--3.Moving with deletion case
call move_figure('A', 2, 'A', 8);

--Data in the move log
SELECT * FROM MoveLog;