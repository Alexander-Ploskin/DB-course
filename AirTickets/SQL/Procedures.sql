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
		(A.FlightTime + GetTransferTime(A.ID, B.ID) + GetTransferTime(B.ID, C.ID) + C.FlightTime) AS TotalFlightTime
		FROM Schedule A JOIN Schedule B 
		ON (A.ArrivalAirport = B.DepartureAirport) AND (A.DepartureAirport = StartPoint) AND (B.ArrivalAirport = FinalPoint)
		JOIN Schedule C
		ON (B.ArrivalAirport = C.DepartureAirport) AND (B.DepartureAirport = StartPoint) AND (C.ArrivalAirport = FinalPoint)
		WHERE GetTransferTime(A.ID, B.ID) BETWEEN INTERVAL '0' HOUR AND MaxTransferTime 
		AND GetTransferTime(B.ID, C.ID) BETWEEN INTERVAL '0' HOUR AND MaxTransferTime 
		ORDER BY TotalFlightTime ASC)
		UNION
		(SELECT A.ID AS FirstFlight, B.ID AS SecondFlight, NULL AS ThirdFlight,
		(A.FlightTime + GetTransferTime(A.ID, B.ID) + B.FlightTime) AS TotalFlightTime
		FROM Schedule A JOIN Schedule B 
		ON (A.ArrivalAirport = B.DepartureAirport) and (A.DepartureAirport = StartPoint) and (B.ArrivalAirport = FinalPoint)
		WHERE GetTransferTime(A.ID, B.ID) BETWEEN INTERVAL '0' HOUR AND MaxTransferTime 
		ORDER BY TotalFlightTime ASC)
		UNION
		(SELECT ID AS FirstFlight, NULL AS SecondFlight, NULL AS ThirdFlight, Schedule.FlightTime FROM Schedule
		WHERE DepartureAirport = StartPoint and ArrivalAirport = FinalPoint) ORDER BY TotalFlightTime ASC;
END;
$$;