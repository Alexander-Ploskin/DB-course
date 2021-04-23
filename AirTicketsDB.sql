CREATE DATABASE AirTickets;

CREATE TABLE Producers(
    Name CHAR(20) PRIMARY KEY
);

CREATE TABLE Models(
    Producer CHAR(20) REFERENCES Producers(Name) NOT NULL,
    Name CHAR(20) NOT NULL,
    FullName CHAR(41) GENERATED ALWAYS AS (Producer || ' ' || Name) STORED PRIMARY KEY
);

CREATE TABLE Planes(
    Id CHAR(7) PRIMARY KEY,
    Model CHAR(41) REFERENCES Models(FullName)
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
    ICAOCode CHAR(4) PRIMARY KEY,
    IATACode CHAR(3) NOT NULL,
    Place CHAR(20) REFERENCES Places(Name) NOT NULL
);

CREATE TABLE Flights(
    Id CHAR(6) PRIMARY KEY,
    Plane CHAR(10) REFERENCES Planes(Id) NOT NULL,
    DepartureAirport CHAR(4) REFERENCES Airports(ICAOCode) NOT NULL,
    ArrivalAirport CHAR(4) REFERENCES Airports(ICAOCode) NOT NULL,
    DepartureDate TIMESTAMP WITH TIME ZONE NOT NULL,
    FlightTime INTERVAL NOT NULL,
    TicketCost MONEY NOT NULL,
    TotalSeats INT NOT NULl CHECK (TotalSeats >= 0) NOT NULL,
    FreeSeats INT CHECK (FreeSeats <= TotalSeats AND FreeSeats >= 0) NOT NULL
);

CREATE TABLE Passengers(
    Flight CHAR(6) REFERENCES Flights(Id) NOT NULL,
    Customer CHAR(20) REFERENCES Customers(PassportId) NOT NULL,
    PRIMARY KEY (Flight, Customer)
);

CREATE TABLE Archive(
    Id CHAR(6) PRIMARY KEY,
    DepartureDate TIMESTAMP WITH TIME ZONE NOT NULL,
    TotalTickets INT NOT NULL CHECK (TotalTickets >= 0) NOT NULL,
    SoldTickets INT NOT NULL CHECK (SoldTickets >= 0 AND SoldTickets <= TotalTickets) NOT NUll
);

--Initialization of aircraft producers
INSERT INTO Producers VALUES ('Boeing');
INSERT INTO Producers VALUES ('Airbus');
INSERT INTO Producers VALUES ('Sukhoi');

--Initialization of models
INSERT INTO Models(Producer, Name) VALUES('Boeing', '777X');
INSERT INTO Models(Producer, Name) VALUES('Boeing', '747SP');
INSERT INTO Models(Producer, Name) VALUES('Airbus', 'A220');
INSERT INTO Models(Producer, Name) VALUES('Airbus', 'A330');
INSERT INTO Models(Producer, Name) VALUES('Sukhoi', 'Superjet 100');

--Initialization of planes
INSERT INTO Planes VALUES ('RA-7045', 'Boeing 777X');
INSERT INTO Planes VALUES ('RA-7046', 'Boeing 777X');
INSERT INTO Planes VALUES ('RA-8943', 'Sukhoi Superjet 100');
INSERT INTO Planes VALUES ('RA-6532', 'Airbus A220');

--Initialization of places
INSERT INTO Places(Name) VALUES ('Saint-Petersburg');
INSERT INTO Places(Name) VALUES ('Voronezh');
INSERT INTO Places(Name) VALUES ('Munich');
INSERT INTO Places(Name) VALUES ('Istanbul');
INSERT INTO Places(Name) VALUES ('Kuala-Lumpur');

--Initialization of airports
INSERT INTO Airports VALUES ('ULLI', 'LED', 'Saint-Petersburg');
INSERT INTO Airports VALUES ('UUOO', 'VOZ', 'Voronezh');
INSERT INTO Airports VALUES ('EDDM', 'MUC', 'Munich');
INSERT INTO Airports VALUES ('LTFM', 'IST', 'Istanbul');
INSERT INTO Airports VALUES ('LTFJ', 'SAW', 'Istanbul');
INSERT INTO Airports VALUES ('WMKK', 'KUL', 'Kuala-Lumpur');

--Initialization of customers
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

--Initialization of flights
INSERT INTO Flights VALUES ('SU-321', 'RA-7045', 'ULLI', 'EDDM', 'April 13 04:05:06 2021 MSK', '0 4:05:00', 4000, 150, 150);
INSERT INTO Flights VALUES ('SU-300', 'RA-7046', 'ULLI', 'UUOO', 'April 13 17:00:00 2021 MSK', '0 2:05:00', 2500, 150, 150);
INSERT INTO Flights VALUES ('SU-911', 'RA-8943', 'UUOO', 'LTFM', 'April 13 23:30:00 2021 MSK', '0 3:24:00', 7000, 100, 100);

--Initialization of passengers
INSERT INTO Passengers VALUES ('SU-321', '12 21 123456');
INSERT INTO Passengers VALUES ('SU-321', '12 21 123453');
INSERT INTO Passengers VALUES ('SU-321', '32 43 413423');
INSERT INTO Passengers VALUES ('SU-321', '12 21 123451');
INSERT INTO Passengers VALUES ('SU-300', '12 21 123451');
INSERT INTO Passengers VALUES ('SU-300', '12 21 123452');
INSERT INTO Passengers VALUES ('SU-300', '32 43 413424');
INSERT INTO Passengers VALUES ('SU-300', '12 21 123455');
INSERT INTO Passengers VALUES ('SU-300', '12 21 123457');
INSERT INTO Passengers VALUES ('SU-300', '32 43 413428');
INSERT INTO Passengers VALUES ('SU-911', '12 21 123455');
INSERT INTO Passengers VALUES ('SU-911', '12 21 123457');
INSERT INTO Passengers VALUES ('SU-911', '32 43 413428');
INSERT INTO Passengers VALUES ('SU-911', '12 21 123459');
INSERT INTO Passengers VALUES ('SU-911', '12 21 123450');
INSERT INTO Passengers VALUES ('SU-911', '32 43 413400');


--1.Amount of sold tickets to flights from LED to MUC
WITH LED AS (SELECT ICAOCode FROM Airports WHERE Airports.IATACode = 'LED'),
     MUC AS (SELECT ICAOCode FROM Airports WHERE Airports.IATACode = 'MUC')
SELECT SUM(TotalSeats - FreeSeats) FROM Flights, LED, MUC
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

