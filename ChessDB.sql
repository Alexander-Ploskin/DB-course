CREATE DATABASE chess;

CREATE TABLE chessman(
    id serial primary key,
    class varchar(20) check (class in ('king', 'queen', 'rook', 'bishop', 'knight', 'pawn')) NOT NULL,
    color varchar(20) check (color in ('white', 'black')) NOT NULL,
    UNIQUE (class, color)
);

CREATE TABLE cell(
    chessman_id int primary key references chessman(id),
    y char check (y >= 'A' and y <= 'H') NOT NULL,
    x int check (x >= 1 and x <= 8) NOT NULL,
    UNIQUE (x, y)
);

INSERT INTO chessman(class, color) values ('knight', 'black');
INSERT INTO chessman(class, color) values ('knight', 'white');
INSERT INTO chessman(class, color) values ('king', 'black');
INSERT INTO chessman(class, color) values ('king', 'white');

INSERT INTO cell values ((SELECT chessman.id FROM chessman
WHERE (chessman.class = 'knight' and chessman.color = 'white') ), 'A', 1);
