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

CREATE OR REPLACE FUNCTION GetTransferTime(FirstFlightID CHAR(6), SecondFlightID CHAR(6))
RETURNS INTERVAL
LANGUAGE plpgsql AS
$$
BEGIN
RETURN (
	SELECT ((B.DepartureTime - '00:00:00') + (INTERVAL '24' HOUR) * 
	(LEAST((ABS(B.WeekdayNumber - A.WeekdayNumber) % 7), (ABS(B.WeekdayNumber + 7 - A.WeekdayNumber) % 7), (ABS(B.WeekdayNumber - 6 - A.WeekdayNumber) % 7)))
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
	FlightDate DATE,
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