--Calculates discount for every agency customer based on the formula
CREATE OR REPLACE VIEW Discount
AS SELECT DISTINCT Passengers.Customer, CASE WHEN A.Flights >= 40 THEN 20
			       					ELSE (A.Flights / 10 * 5)
			       					END
FROM Passengers, (SELECT Customer, (COUNT(*)) AS Flights
		  		  FROM passengers
		  		  GROUP BY Customer) AS A
WHERE Passengers.Customer = A.Customer;

--Returns table which contains average occupancy for every month of last year
CREATE OR REPLACE FUNCTION GetAverageOccupancy(AirportA CHAR(3), AirportB CHAR(3))
RETURNS TABLE (
	AverageOccupancy FLOAT,
	MonthNumber TEXT
)
LANGUAGE plpgsql AS
$$
BEGIN
RETURN QUERY WITH OccupancyTable AS 
	(SELECT (CAST(Archive.SoldTickets AS float) / Archive.TotalTickets) AS Occupancy, to_char(DepartureDate, 'MM') AS FlightMonth 
	FROM Archive LEFT JOIN Schedule ON FlightNumber = ID
	WHERE (Schedule.DepartureAirport = AirportA) and (Schedule.ArrivalAirport = AirPortB))
SELECT AVG(Occupancy) AS AverAgeOccupancy, FlightMonth FROM OccupancyTable GROUP BY FlightMonth;
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

--Returns the shortest time of transfer awaiting between two flights
CREATE OR REPLACE FUNCTION GetTransferTime(FirstFlightID CHAR(6), SecondFlightID CHAR(6))
RETURNS INTERVAL
LANGUAGE plpgsql AS
$$
BEGIN
RETURN (
	SELECT ((B.DepartureTime - '00:00:00') + (INTERVAL '24' HOUR) * 
	((B.WeekdayNumber - A.WeekdayNumber + 7) % 7)
	- A.DepartureTime - A.FlightTime)
	FROM Schedule A LEFT JOIN Schedule B 
	ON (A.ArrivalAirport = B.DepartureAirport) WHERE A.ID = FirstFlightID AND B.ID = SecondFlightID
);
END;
$$;

--Gets list of routes from A to B from the cheapest to the most expensive
CREATE OR REPLACE FUNCTION GetCheapFlights(
	StartPoint CHAR(6), 
	FinalPoint CHAR(6),
	MaxTransferTime INTERVAL
) RETURNS TABLE(
	FirstFlight CHAR(6),
	SecondFlight CHAR(6),
	FlightCost MONEY
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
		(SELECT A.ID AS FirstFlight, B.ID AS Secondflight, (A.TicketCost + B.TicketCost) AS FlightCost
		FROM schedule A JOIN schedule B 
		ON (A.ArrivalAirport = B.DepartureAirport) and (A.DepartureAirport = StartPoint) and (B.ArrivalAirport = FinalPoint)
		 WHERE GetTransferTime(A.ID, B.ID) BETWEEN INTERVAL '0' HOUR AND MaxTransferTime
		ORDER BY FlightCost ASC)
		UNION
		(SELECT ID as FirstFlight, null as SecondFlight, schedule.TicketCost FROM schedule
		 WHERE DepartureAirport = StartPoint and ArrivalAirport = FinalPoint);
END;
$$;