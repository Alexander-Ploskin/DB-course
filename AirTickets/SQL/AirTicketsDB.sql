CREATE DATABASE AirTickets;

CREATE TABLE Producers(
    Name CHAR(20) PRIMARY KEY
);

INSERT INTO Producers VALUES ('Boeing');
INSERT INTO Producers VALUES ('Airbus');
INSERT INTO Producers VALUES ('Sukhoi');

CREATE TABLE Models(
    Producer CHAR(20) REFERENCES Producers(Name) NOT NULL,
    Name CHAR(20) NOT NULL,
    FullName CHAR(41) GENERATED ALWAYS AS (Producer || ' ' || Name) STORED PRIMARY KEY
);

INSERT INTO Models(Producer, Name) VALUES('Boeing', '777X');
INSERT INTO Models(Producer, Name) VALUES('Boeing', '747SP');
INSERT INTO Models(Producer, Name) VALUES('Airbus', 'A220');
INSERT INTO Models(Producer, Name) VALUES('Airbus', 'A330');
INSERT INTO Models(Producer, Name) VALUES('Sukhoi', 'Superjet 100');

CREATE TABLE Planes(
    Id CHAR(7) PRIMARY KEY,
    Model CHAR(41) REFERENCES Models(FullName)
);

INSERT INTO Planes VALUES ('RA-7045', 'Boeing 777X');
INSERT INTO Planes VALUES ('RA-7046', 'Boeing 777X');
INSERT INTO Planes VALUES ('RA-8943', 'Sukhoi Superjet 100');
INSERT INTO Planes VALUES ('RA-6532', 'Airbus A220');
INSERT INTO Planes VALUES ('RA-7891', 'Boeing 777X');
INSERT INTO Planes VALUES ('RA-7131', 'Boeing 747SP');
INSERT INTO Planes VALUES ('RA-8231', 'Sukhoi Superjet 100');
INSERT INTO Planes VALUES ('RA-6522', 'Airbus A330');

CREATE TABLE Customers(
    PassportId CHAR(20) PRIMARY KEY,
    Name CHAR(20) NOT NULL,
    Surname CHAR(20) NOT NULL,
    Patronymic CHAR(20)
);

INSERT INTO Customers VALUES ('12 21 123456', 'Constantine', 'Palaiologos', NULL);
INSERT INTO Customers VALUES ('12 21 123453', 'Mehmed', 'Ottoman', NUll);
INSERT INTO Customers VALUES ('32 43 413423', 'Kemal', 'Ataturk', NUll);
INSERT INTO Customers VALUES ('12 21 123451', 'Ivan', 'Rurikovich', 'Vasilevich');
INSERT INTO Customers VALUES ('12 21 123452', 'Pyotr', 'Romanov', 'Alexeevich');
INSERT INTO Customers VALUES ('32 43 413424', 'Patrice', 'Lumumba', NUll);
INSERT INTO Customers VALUES ('12 21 123455', 'Paul', 'Kagame', NUll);
INSERT INTO Customers VALUES ('12 21 123457', 'Miguel', 'Cervantes', NUll);
INSERT INTO Customers VALUES ('32 43 413428', 'Oliver', 'Cromwell', NUll);
INSERT INTO Customers VALUES ('12 21 123459', 'Friedrich', 'Hohenzollern', NUll);
INSERT INTO Customers VALUES ('12 21 123450', 'Mykhailo', 'Hrushevsky', 'Serhiiovych');
INSERT INTO Customers VALUES ('32 43 413400', 'Casimir', 'Piast', NUll);
INSERT INTO Customers VALUES ('12 33 123456', 'Douglas', 'MacArthur', NULL);
INSERT INTO Customers VALUES ('12 33 123453', 'Alexei', 'Ermolov', 'Petrovich');
INSERT INTO Customers VALUES ('32 34 413423', 'Juan', 'Peron', NUll);
INSERT INTO Customers VALUES ('12 43 123451', 'Ulysses', 'Grant', NULL);
INSERT INTO Customers VALUES ('12 27 123452', 'Joseph', 'Fouche', NULL);
INSERT INTO Customers VALUES ('32 78 413424', ' Georges Jacques', 'Danton', NUll);
INSERT INTO Customers VALUES ('12 90 123455', 'Jean-Paul', 'Marat', NUll);
INSERT INTO Customers VALUES ('12 01 123457', 'Oswald', 'Mosley', NUll);
INSERT INTO Customers VALUES ('32 40 413428', 'Philippe', 'Petain', NUll);
INSERT INTO Customers VALUES ('12 23 123459', 'Ruhollah','Khomeini', NUll);

CREATE TABLE Places(
    Name CHAR(30) PRIMARY KEY
);

INSERT INTO Places(Name) VALUES ('Saint-Petersburg');
INSERT INTO Places(Name) VALUES ('Voronezh');
INSERT INTO Places(Name) VALUES ('Munich');
INSERT INTO Places(Name) VALUES ('Istanbul');
INSERT INTO Places(Name) VALUES ('Kuala-Lumpur');

CREATE TABLE Airports(
    ICAOCode CHAR(4) PRIMARY KEY,
    IATACode CHAR(3) NOT NULL,
    Place CHAR(20) REFERENCES Places(Name) NOT NULL
);

INSERT INTO Airports VALUES ('ULLI', 'LED', 'Saint-Petersburg');
INSERT INTO Airports VALUES ('UUOO', 'VOZ', 'Voronezh');
INSERT INTO Airports VALUES ('EDDM', 'MUC', 'Munich');
INSERT INTO Airports VALUES ('LTFM', 'IST', 'Istanbul');
INSERT INTO Airports VALUES ('LTFJ', 'SAW', 'Istanbul');
INSERT INTO Airports VALUES ('WMKK', 'KUL', 'Kuala-Lumpur');

CREATE TABLE Routes(
    Id CHAR(6) PRIMARY KEY,
    DepartureAirport CHAR(4) REFERENCES Airports(ICAOCode) NOT NULL,
    ArrivalAirport CHAR(4) REFERENCES Airports(ICAOCode) NOT NULL
);

--Saint-Petersburg - Munich
INSERT INTO Routes VALUES ('SU-321', 'ULLI', 'EDDM');
INSERT INTO Routes VALUES ('SU-312', 'EDDM', 'ULLI');

--Saint-Petersburg - Voronezh
INSERT INTO Routes VALUES ('SU-300', 'ULLI', 'UUOO');
INSERT INTO Routes VALUES ('SU-305', 'UUOO', 'ULLI');

--Saint-Petersburg - Kuala-Lumpur
INSERT INTO Routes VALUES ('FA-001', 'ULLI', 'WMKK');
INSERT INTO Routes VALUES ('FA-100', 'WMKK', 'ULLI');

--Voronezh - Istanbul
INSERT INTO Routes VALUES ('SU-911', 'UUOO', 'LTFM');
INSERT INTO Routes VALUES ('SU-199', 'LTFM', 'UUOO');

--Saint-Petersburg - Istanbul
INSERT INTO Routes VALUES ('SU-020', 'ULLI', 'LTFM');
INSERT INTO Routes VALUES ('SU-202', 'LTFM', 'ULLI');

--Voronezh - Istanbul(2)
INSERT INTO Routes VALUES ('TA-111', 'UUOO','LTFJ');
INSERT INTO Routes VALUES ('TA-222', 'LTFJ', 'UUOO');

--Istanbul(2) - Kuala-Lumpur
INSERT INTO Routes VALUES ('FA-111', 'LTFJ', 'WMKK');
INSERT INTO Routes VALUES ('FA-112', 'WMKK', 'LTFJ');

--Istanbul - Kuala-Lumpur
INSERT INTO Routes VALUES ('FA-441', 'LTFJ', 'WMKK');
INSERT INTO Routes VALUES ('FA-442', 'WMKK', 'LTFJ');

--Munich - Istanbul
INSERT INTO Routes VALUES ('LH-321', 'EDDM', 'LTFJ');
INSERT INTO Routes VALUES ('LH-312', 'LTFJ', 'EDDM');

--Voronezh - Istanbul
INSERT INTO Routes VALUES ('SU-121', 'UUOO', 'LTFJ');
INSERT INTO Routes VALUES ('LH-212', 'LTFJ', 'UUOO');

--Munich - Istanbul
INSERT INTO Routes VALUES ('LH-342', 'EDDM', 'LTFJ');
INSERT INTO Routes VALUES ('LH-343', 'LTFJ', 'EDDM');

--Munich - Voronezh
INSERT INTO Routes VALUES ('SU-310', 'EDDM', 'UUOO');
INSERT INTO Routes VALUES ('SU-315', 'UUOO', 'EDDM');

CREATE TABLE Archive(
    ID SERIAL PRIMARY KEY,
    Route CHAR(6) REFERENCES Routes(ID) NOT NULL,
    DepartureDate TIMESTAMP NOT NULL,
    FlightTime INTERVAL NOT NULL,
    TicketCost MONEY NOT NULL,
    TotalTickets INT NOT NULl CHECK (TotalTickets >= 0) NOT NULL,
    SoldTickets INT CHECK (SoldTickets <= TotalTickets AND SoldTickets >= 0) NOT NULL
);

INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('SU-321', 'April 13 14:00:00 2021', '2:30:00', 10000, 150, 120);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('LH-321', 'April 13 18:00:00 2021', '3:00:00', 5000, 100, 50);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('FA-441', 'April 13 22:40:00 2021', '8:00:00', 20010, 300, 270);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('LH-321', 'April 13 14:00:00 2020', '2:30:00', 12000, 75, 70);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('FA-441', 'April 13 14:00:00 2020', '2:30:00', 13000, 210, 200);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('SU-020', 'April 15 14:00:00 2021', '3:30:00', 11200, 250, 220);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('SU-300', 'April 2 01:00:00 2021', '2:30:00', 4500, 150, 145);

INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('LH-321', 'April 10 1:00:00 2021', '2:00:00', 5000, 100, 80);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('FA-441', 'April 10 4:00:00 2021', '2:00:00', 15000, 100, 80);

INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('TA-111', 'December 10 1:00:00 2020', '1:00:00', 1000, 100, 90);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('SU-121', 'December 5 1:00:00 2020', '1:00:00', 1000, 100, 80);

INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('TA-111', 'November 10 1:00:00 2020', '1:00:00', 1000, 100, 50);
INSERT INTO Archive(Route, DepartureDate, FlightTime, TicketCost, TotalTickets, SoldTickets) VALUES ('SU-121', 'November 5 1:00:00 2020', '1:00:00', 1000, 100, 100);

CREATE TABLE Schedule(
    ID SERIAL PRIMARY KEY,
    Route CHAR(6) REFERENCES Routes(ID) NOT NULL,
    DepartureDate TIMESTAMP NOT NULL,
    FlightTime INTERVAL NOT NULL,
    TicketCost MONEY NOT NULL,
    TotalSeats INT NOT NULl CHECK (TotalSeats >= 0) NOT NULL,
    FreeSeats INT CHECK (FreeSeats <= TotalSeats AND FreeSeats >= 0) NOT NULL
);

INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-321', 'July 1 1:00:00 2021', '2:00:00', 7000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('LH-321', 'July 1 4:30:00 2021', '1:30:00', 5000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('FA-441', 'July 1 11:00:00 2021', '8:00:00', 15000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-300', 'July 1 1:00:00 2021', '2:00:00', 3000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-121', 'July 1 7:00:00 2021', '2:00:00', 4500, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-020', 'July 1 7:00:00 2021', '3:00:00', 10000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('FA-001', 'July 1 9:00:00 2021', '10:00:00', 20000, 100, 100);

INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-321', 'July 2 1:00:00 2021', '2:00:00', 7000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('LH-321', 'July 2 4:30:00 2021', '1:30:00', 5000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('FA-441', 'July 2 11:00:00 2021', '8:00:00', 15000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-300', 'July 2 1:00:00 2021', '2:00:00', 3000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-121', 'July 2 7:00:00 2021', '2:00:00', 4500, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-020', 'July 2 7:00:00 2021', '3:00:00', 80000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('FA-001', 'July 2 9:00:00 2021', '10:00:00', 5000, 100, 100);

INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-321', 'June 29 1:00:00 2021', '2:00:00', 700, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('LH-321', 'June 29 4:30:00 2021', '1:30:00', 500, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('FA-441', 'June 29 11:00:00 2021', '8:00:00', 1500, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-300', 'June 29 1:00:00 2021', '2:00:00', 300, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-121', 'June 29 7:00:00 2021', '2:00:00', 400, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('SU-020', 'June 29 7:00:00 2021', '3:00:00', 1000, 100, 100);
INSERT INTO Schedule(Route, DepartureDate, FlightTime, TicketCost, TotalSeats, FreeSeats) VALUES ('FA-001', 'June 29 9:00:00 2021', '10:00:00', 20000, 100, 100);

CREATE TABLE Ticket(
    Flight INT REFERENCES Schedule(ID) NOT NULL,
    Customer CHAR(20) REFERENCES Customers(PassportId) NOT NULL,
    PRIMARY KEY (Flight, Customer)
);

CREATE TABLE ArchiveTicket(
    Flight INT REFERENCES Archive(ID) NOT NULL ,
    Customer CHAR(20) REFERENCES Customers(PASSPORTID) NOT NULL,
    PRIMARY KEY (Flight, Customer)
);
-----------------------------------------------------

--1.Amount of sold tickets to flights from LED to MUC
WITH LED AS (SELECT ICAOCode FROM Airports WHERE Airports.IATACode = 'LED'),
     MUC AS (SELECT ICAOCode FROM Airports WHERE Airports.IATACode = 'MUC')
SELECT SUM(SoldTickets) FROM Archive LEFT JOIN Routes ON Route = Routes.Id, LED, MUC
WHERE DepartureAirport = LED.ICAOCode AND ArrivalAirport = MUC.ICAOCode;

--2.Top 10 passengers by the number of flights
SELECT Name, Surname, Count(Customer) AS NumberOfFlights
FROM Passengers LEFT JOIN Customers on Passengers.Customer = Customers.PassportId GROUP BY Customer, Name, Surname
ORDER BY NumberOfFlights DESC FETCH FIRST 10 ROWS ONLY;

--3.The most popular flight direction from Saint-Petersburg
SELECT Name, COUNT(*) AS NumberOfFlights FROM  Flights LEFT JOIN Airports ON Flights.ArrivalAirport = Airports.ICAOCode
LEFT JOIN Places ON Airports.Place = Places.Name WHERE Flights.DepartureAirport = 'ULLI' GROUP BY Name
ORDER BY NumberOfFlights DESC FETCH FIRST 1 ROWS ONLY;

--4.The most popular airport for transfers
WITH RESULT AS(WITH HELP AS (SELECT ArrivalAirport, Customer, (DepartureDate + FlightTime) AS ArrivalTime  FROM
Flights LEFT JOIN Passengers on Flights.Id = Passengers.Flight)
SELECT DepartureAirport FROM HELP, Flights LEFT JOIN Passengers on Flights.Id = Passengers.Flight
WHERE DepartureAirport = HELP.ArrivalAirport AND Passengers.Customer = HELP.Customer AND HELP.ArrivalTime < DepartureDate
) SELECT Place, IATACode, Count(*) AS Count FROM RESULT LEFT JOIN Airports ON DepartureAirport = Airports.ICAOCode GROUP BY DepartureAirport, Place, IATACode;

--5.The average time of transfer for the last quarter
WITH HELP AS (SELECT ArrivalAirport, Customer, (DepartureDate + FlightTime) AS ArrivalTime  FROM
Flights LEFT JOIN Passengers on Flights.Id = Passengers.Flight)
SELECT avg(DepartureDate - HELP.ArrivalTime) AS AverageTransferTime FROM HELP, Flights LEFT JOIN Passengers on Flights.Id = Passengers.Flight
WHERE DepartureAirport = HELP.ArrivalAirport AND Passengers.Customer = HELP.Customer AND HELP.ArrivalTime < DepartureDate AND current_timestamp - Flights.DepartureDate < '90 0:00:00' GROUP BY DepartureDate - HELP.ArrivalTime;


--Trigger function which updates number of free seats on the flight if ticket was bought or returned
CREATE OR REPLACE FUNCTION sale_trigger() RETURNS trigger AS $sale_trigger$
DECLARE freeseats INT;
BEGIN
    IF NEW IS NULL THEN
        SELECT Flights.FreeSeats INTO freeseats FROM Flights
	    WHERE Id = old.Flight;

	    UPDATE flights SET FreeSeats = flights.freeseats + 1
		    WHERE Id = old.Flight;
        RETURN OLD;
    ELSE
        SELECT Flights.FreeSeats INTO freeseats FROM Flights
	    WHERE Id = new.Flight;

	    IF freeseats = 0
	        THEN RAISE EXCEPTION 'All tickets for this flight are already sold';
	    ELSE UPDATE flights SET FreeSeats = flights.freeseats - 1
		    WHERE Id = new.Flight;
	    END IF;

        RETURN NEW;
    end if;

END;
$sale_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sale_trigger ON Passengers;
CREATE TRIGGER sale_trigger BEFORE INSERT OR DELETE ON Passengers FOR EACH ROW EXECUTE PROCEDURE sale_trigger();

INSERT INTO Passengers VALUES ('SU-321', '32 43 413400');
DELETE FROM Passengers WHERE Customer = '32 43 413400';

SELECT * FROM Flights;

CREATE OR REPLACE FUNCTION get_place_by_airport_code(ICAO CHAR(4)) RETURNS CHAR(20)
AS $$
    DECLARE result CHAR(20);
    BEGIN
        SELECT Name INTO result FROM Airports LEFT JOIN Places ON Airports.Place = Places.Name WHERE Airports.ICAOCode = ICAO;
        RETURN result;
    END;
$$ LANGUAGE plpgsql;

DROP FUNCTION get_routes(departure_date DATE, departure_place CHAR, arrival_place CHAR);

--Returns all possible routes to go from A to B with no more than two transfer
CREATE OR REPLACE FUNCTION get_routes(departure_date DATE, departure_place CHAR(20), arrival_place CHAR(20))
RETURNS TABLE (
    FirstId CHAR(6),
    SecondId CHAR(6),
    RouteTime1 INTERVAL,
    RouteTime2 INTERVAL
)
AS $$
BEGIN
    RETURN QUERY
    SELECT Flights.Id, NULLIF(1,1), Flights.FlightTime, NULLIF(1,1)
    FROM Flights
    WHERE departure_date = date(Flights.DepartureDate)
    AND get_place_by_airport_code(Flights.DepartureAirport) = departure_place
    AND get_place_by_airport_code(Flights.ArrivalAirport) = arrival_place; --UNION ALL
    --WITH FinalFlights AS(SELECT * FROM Flights WHERE get_place_by_airport_code(ArrivalAirport) = arrival_place
    --AND get_place_by_airport_code(DepartureAirport) <> departure_place)--Flights which arrives into the arrival airports except

END;
$$ LANGUAGE plpgsql;

select * FROM get_routes('April 13, 2021', 'Saint-Petersburg', 'Istanbul');

WITH FinalFlights AS(SELECT * FROM Flights WHERE get_place_by_airport_code(ArrivalAirport) = 'Istanbul'
    AND get_place_by_airport_code(DepartureAirport) <> 'Saint-Petersburg')--Flights which arrives into the arrival airports except flights from departure airport
    SELECT Flights.Id, FinalFlights.Id, Flights.FlightTime, FinalFlights.FlightTime
    FROM FinalFlights FULL OUTER JOIN Flights ON Flights.DepartureAirport = FinalFlights.DepartureAirport;

--Calculates discount for every agency customer based on the formula
CREATE OR REPLACE VIEW Discount
AS SELECT DISTINCT Passengers.Customer, CASE WHEN A.flights >= 40 THEN 20
			       					ELSE (A.flights / 10 * 5)
			       					END
FROM passengers, (SELECT Customer, (COUNT(*)) AS flights
		  		  FROM passengers
		  		  GROUP BY Customer) AS A
WHERE passengers.Customer = A.Customer

SELECT * FROM discount;

CREATE OR REPLACE VIEW AverageOccupancy
AS SELECT avg(SoldTickets / Archive.TotalTickets) FROM Archive GROUP BY SoldTickets / Archive.TotalTickets;

SELECT * FROM AverageOccupancy;
