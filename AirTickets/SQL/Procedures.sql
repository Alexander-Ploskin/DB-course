 --Returns information about transfer flights
CREATE OR REPLACE FUNCTION GetOneOrTwoTransferRoutes(MaxTransferTime INTERVAL, StartDay DATE, StartAirport CHAR(3), FinishAirport CHAR(3))
RETURNS TABLE (
	FirstFlight CHAR(6),
	SecondFlight CHAR(6),
	ThirdFlight CHAR(6)
)
LANGUAGE plpgsql AS
$$
BEGIN
RETURN QUERY (
	SELECT DISTINCT
	WITH OneTransfer AS
	(SELECT A.ID AS FirstFlight, )
 	A.DepartureAirport AS StartPoint,
	A.ArrivalAirport AS TransferPoint,
 	B.ArrivalAirport AS FinishPoint,
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
		 WHERE CheckTransfer(A.ID, B.ID, MaxTransferTime)
		ORDER BY FlightCost ASC)
		UNION
		(SELECT ID as FirstFlight, null as SecondFlight, schedule.TicketCost FROM schedule
		 WHERE DepartureAirport = StartPoint and ArrivalAirport = FinalPoint);
END;
$$;

--Gets routes from A to B with one or two transitions in journey time order
CREATE OR REPLACE FUNCTION GetFastFlights(
	StartPoint CHAR(6), 
	FinalPoint CHAR(6),
	FlightDate DATE,
	MaxTransferTime INTERVAL
) RETURNS TABLE(
	FirstFlight CHAR(6),
	SecondFlight CHAR(6),
	ThirdFlight CHAR(6),
	TotalFlightTime INTERVAL
)
LANGUAGE plpgsql AS
$$
BEGIN
	RETURN QUERY
		(SELECT A.ID AS FirstFlight, B.ID AS SecondFlight, C.ID AS ThirdFlight,
		((C.DepartureTime + C.FlightTime - '00:00:00') + (INTERVAL '24' HOUR) * ((C.WeekdayNumber - A.WeekdayNumber) % 7) - A.DepartureTime) AS TotalFlightTime
		FROM Schedule A JOIN Schedule B 
		ON (A.ArrivalAirport = B.DepartureAirport) AND (A.DepartureAirport = StartPoint) AND (B.ArrivalAirport = FinalPoint)
		JOIN Schedule C
		ON (B.ArrivalAirport = C.DepartureAirport) AND (B.DepartureAirport = StartPoint) AND (C.ArrivalAirport = FinalPoint)
		WHERE CheckTransfer(A.ID, B.ID, MaxTransferTime) AND CheckTransfer(B.ID, C.ID, MaxTransferTime)
		ORDER BY TotalFlightTime ASC)
		UNION
		(SELECT A.ID AS FirstFlight, B.ID AS SecondFlight, NULL AS ThirdFlight,
		((B.DepartureTime + B.FlightTime - '00:00:00')+ (INTERVAL '24' HOUR) * ((B.WeekdayNumber - A.WeekdayNumber) % 7) - A.DepartureTime) AS TotalFlightTime
		FROM Schedule A JOIN Schedule B 
		ON (A.ArrivalAirport = B.DepartureAirport) and (A.DepartureAirport = StartPoint) and (B.ArrivalAirport = FinalPoint)
		WHERE CheckTransfer(A.ID, B.ID, MaxTransferTime)
		ORDER BY TotalFlightTime ASC)
		UNION
		(SELECT ID AS FirstFlight, NULL AS SecondFlight, NULL AS ThirdFlight, Schedule.FlightTime FROM Schedule
		WHERE DepartureAirport = StartPoint and ArrivalAirport = FinalPoint);
END;
$$;