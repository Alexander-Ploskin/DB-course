--Calculates discount for every agency customer based on the formula
CREATE OR REPLACE VIEW Discount
AS SELECT DISTINCT Passengers.Customer, CASE WHEN A.Flights >= 40 THEN 20
			       					ELSE (A.Flights / 10 * 5)
			       					END
FROM Passengers, (SELECT Customer, (COUNT(*)) AS Flights
		  		  FROM passengers
		  		  GROUP BY Customer) AS A
WHERE Passengers.Customer = A.Customer

--Returns table which contains average occupancy for every month of last year
CREATE OR REPLACE FUNCTION GetAverageOccupancy(AirportA CHAR(20), AirportB CHAR(20))
RETURNS TABLE (
	AverageOccupancy FLOAT,
	MonthNumber TEXT
)
LANGUAGE plpgsql AS
$$
BEGIN
RETURN QUERY (WITH occupancy_table AS 
	(SELECT CAST(Archive.SoldTickets AS float) / archive.TotalTickets AS occupancy, to_char(DepartureDate, 'MM') AS flight_month 
	FROM archive NATURAL JOIN schedule 
	WHERE (schedule.DepartureAirport = AirportA) and (schedule.ArrivalAirport = AirPortB))
SELECT AVG(occupancy), flight_month FROM occupancy_table GROUP BY flight_month);
END;
$$;

--Returns full information about flight
CREATE OR REPLACE VIEW FlightInfo
AS SELECT DISTINCT Passengers.DepartureDate + Schedule.DepartureTime as FullDepartureTime,
 Passengers.DepartureDate + Schedule.DepartureTime + Schedule.FlightTime as FullArrivalTime,
 Schedule.DepartureAirport as DepartureAirport, Schedule.ArrivalAirport as ArrivalAirport,
 Passengers.Customer as CustomerID
 FROM Passengers LEFT JOIN Schedule ON Schedule.ID = Passengers.FlightNumber;
 
 --Returns information about transfer flights
CREATE OR REPLACE FUNCTION GetOneTransferFlightsInfo(MaxTransferTime INTERVAL)
RETURNS TABLE (
	StartPoint CHAR(3),
	TransferPoint CHAR(3),
	FinishPoint CHAR(3),
	Frequency BIGINT,
	TransferTime INTERVAL,
	DepartureDate Date
)
LANGUAGE plpgsql AS
$$
BEGIN
RETURN QUERY (
	SELECT DISTINCT 
 	A.DepartureAirport AS StartPoint,
	A.ArrivalAirport AS TransferPoint,
 	B.ArrivalAirport AS FinishPoint,
	Count(*) AS Frequency,
	(B.FullDepartureTime - A.FullArrivalTime) AS TransferTime,
	DATE(A.FullDepartureTime) AS DepartureDate
	FROM FlightInfo A JOIN FlightInfo B ON 
	(B.DepartureAirport = A.ArrivalAirport) 
	AND (A.CustomerID = B.CustomerID)
	AND (B.FullDepartureTime - A.FullArrivalTime BETWEEN INTERVAL '0' SECOND AND MaxTransferTime)
	AND A.DepartureAirport <> B.ArrivalAirport
	GROUP BY StartPoint, TransferPoint, FinishPoint, TransferTime, DepartureDate ORDER BY Frequency);
END;
$$;

--Returns is it possible to do transition between two flights with max transfer time
CREATE OR REPLACE FUNCTION CheckTransfer(FirstFlightID CHAR(6), SecondFlightID CHAR(6), MaxTransferTime INTERVAL)
RETURNS BOOL
LANGUAGE plpgsql AS
$$
DECLARE
FirstFlightDeparture CHAR(3);
SecondFlightDeparture CHAR(3);
FirstFlightDestination CHAR(3);
SecondFlightDestination CHAR(3);
FirstFlightWeekdayNumber INT;
SecondFlightWeekdayNumber INT;
FirstFlightArrivalTime TIME;
SecondFlightDepartureTime TIME;
BEGIN
SELECT DepartureAirport, ArrivalAirport, WeekdayNumber, DepartureTime + FlightTime INTO
FirstFlightDeparture, FirstFlightDestination, FirstFlightWeekdayNumber, FirstFlightArrivalTime 
FROM Schedule WHERE ID = FirstFlightID;
SELECT DepartureAirport, ArrivalAirport, WeekdayNumber, DepartureTime INTO
SecondFlightDeparture, SecondFlightDestination, SecondFlightWeekdayNumber, SecondFlightDepartureTime 
FROM Schedule WHERE ID = SecondFlightID;
RETURN 
((SecondFlightDepartureTime - '00:00:00') + 
 (INTERVAL '24' HOUR) * ((SecondFlightWeekdayNumber - FirstFlightWeekdayNumber) % 7) - FirstFlightArrivalTime
BETWEEN INTERVAL '0' HOUR AND MaxTransferTime) 
AND (FirstFlightDeparture <> SecondFlightDestination) AND (FirstFlightDestination = SecondFlightDeparture);
END;
$$;