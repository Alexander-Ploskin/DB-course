CREATE DATABASE AirTickets;

CREATE TABLE Producers(
    Name CHAR(20) PRIMARY KEY
);

CREATE TABLE Models(
    Producer CHAR(20) REFERENCES Producers(Name) ON DELETE CASCADE NOT NULL,
    Name CHAR(20) NOT NULL,
    FullName CHAR(41) GENERATED ALWAYS AS (Producer || ' ' || Name) STORED PRIMARY KEY
);

CREATE TABLE Planes(
    Id CHAR(7) PRIMARY KEY,
    Model CHAR(41) REFERENCES Models(FullName) ON DELETE CASCADE NOT NULL
);

CREATE TABLE Customers(
    PassportId CHAR(20) PRIMARY KEY,
    Name CHAR(20) NOT NULL,
    Surname CHAR(20) NOT NULL,
    Patronymic CHAR(20)
);

CREATE TABLE Places(
    Name CHAR(30) PRIMARY KEY
);

CREATE TABLE Airports(
    IATACode CHAR(3) PRIMARY KEY,
    Place CHAR(20) REFERENCES Places(Name) ON DELETE CASCADE NOT NULL
);

CREATE TABLE Schedule(
    ID CHAR(6) PRIMARY KEY,
    DepartureAirport CHAR(3) REFERENCES Airports(IATACode) ON DELETE CASCADE NOT NULL,
	ArrivalAirport CHAR(3) REFERENCES Airports(IATACode) ON DELETE CASCADE NOT NULL,
	WeekdayNumber INT CHECK(WeekdayNumber >= 1 AND WeekdayNumber <= 7) NOT NULL,
	DepartureTime TIME NOT NULL,
    FlightTime INTERVAL NOT NULL,
	TotalTickets INT CHECK (TotalTickets >= 0) NOT NULL,
	Plane CHAR(7) REFERENCES Planes(Id) ON DELETE CASCADE NOT NULL,
    TicketCost MONEY NOT NULL
);

CREATE TABLE Flights(
	FlightNumber CHAR(6) REFERENCES Schedule(ID) ON DELETE CASCADE NOT NULL,
	SoldTickets INT CHECK (SoldTickets >= 0) NOT NULL,
	DepartureDate DATE NOT NULL,
	PRIMARY KEY (FlightNumber, DepartureDate)
);

--Day of week constraint on the flights and archive tables
CREATE OR REPLACE FUNCTION CheckThatSoldTicketsLessThanTotal(FlightID CHAR(6), SoldTickets INT)
RETURNS BOOL
LANGUAGE plpgsql AS
$$
BEGIN
RETURN ((SELECT SoldTickets FROM Schedule WHERE ID = FlightID) >= SoldTickets);
END;
$$;

ALTER TABLE Flights
ADD CONSTRAINT SoldTickets CHECK(CheckThatSoldTicketsLessThanTotal(FlightNumber, SoldTickets));

--Day of week constraint on the flights and archive tables
CREATE OR REPLACE FUNCTION CheckDayOfWeek(FlightID CHAR(6), FlightDate DATE)
RETURNS BOOL
LANGUAGE plpgsql AS
$$
BEGIN
RETURN ((SELECT WeekdayNumber FROM Schedule WHERE ID = FlightID) = (SELECT EXTRACT(DOW FROM DATE (FlightDate))));
END;
$$;

ALTER TABLE Flights
ADD CONSTRAINT WeekdayNumber CHECK(CheckDayOfWeek(FlightNumber, DepartureDate));

CREATE TABLE Archive(
	FlightNumber CHAR(6) REFERENCES Schedule(ID) ON DELETE CASCADE NOT NULL,
	Plane CHAR(7) REFERENCES Planes(Id) ON DELETE CASCADE NOT NULL,
	TotalTickets INT CHECK (TotalTickets >= 0) NOT NULL,
	SoldTickets INT CHECK (SoldTickets BETWEEN 0 AND TotalTickets) NOT NULL,
	DepartureDate DATE CHECK (DepartureDate < NOW()) NOT NULL,
	PRIMARY KEY (FlightNumber, DepartureDate)
);

ALTER TABLE Archive
ADD CONSTRAINT WeekdayNumber CHECK(CheckDayOfWeek(FlightNumber, DepartureDate));

CREATE OR REPLACE FUNCTION CheckFlight(FlightID CHAR(6), FlightDate DATE)
RETURNS BOOL
LANGUAGE plpgsql AS
$$
BEGIN
RETURN (
	((SELECT COUNT(*) FROM Archive WHERE Archive.FlightNumber = FlightNumber AND Archive.DepartureDate = DepartureDate) > 0)
	OR ((SELECT COUNT(*) FROM Flights WHERE Flights.FlightNumber = FlightNumber AND Flights.DepartureDate = DepartureDate) > 0)
	);
END;
$$;

CREATE TABLE Passengers(
	Customer CHAR(20) REFERENCES Customers(PassportId) ON DELETE CASCADE NOT NULL,
	FlightNumber CHAR(6) REFERENCES Schedule(ID) ON DELETE CASCADE NOT NULL,
	DepartureDate DATE NOT NULL,
	PRIMARY KEY (FlightNumber, DepartureDate, Customer)
);

ALTER TABLE Passengers
ADD CONSTRAINT FlightExists CHECK(CheckFlight(FlightNumber, DepartureDate));