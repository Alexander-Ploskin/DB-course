--1.Amount of sold tickets to flights from LED to MUC
SELECT COUNT(*) SoldTickets
FROM Passengers LEFT JOIN Schedule ON Passengers.FlightNumber = Schedule.ID
WHERE DepartureDate >= NOW() - INTERVAL '1' Month AND Schedule.DepartureAirport = 'LED' AND Schedule.ArrivalAirport = 'MUC';

--2.Top 10 passengers by the number of flights
SELECT Name, Surname, Count(Customer) AS NumberOfFlights
FROM Passengers LEFT JOIN Customers on Passengers.Customer = Customers.PassportId GROUP BY Customer, Name, Surname
ORDER BY NumberOfFlights DESC FETCH FIRST 10 ROWS ONLY;

--3.The most popular flight direction from Saint-Petersburg
 SELECT Place, Count(*) AS Frequency FROM Passengers
 LEFT JOIN Schedule ON Passengers.FlightNumber =  Schedule.ID 
 LEFT JOIN Airports ON ArrivalAirport = Airports.IATACode
 WHERE schedule.DepartureAirport = 'LED'
 GROUP BY Place ORDER BY frequency DESC FETCH FIRST 1 ROWS ONLY;

--4.The most popular airport for transfers
SELECT TransferPoint, Frequency FROM GetOneTransferFlightsInfo(INTERVAL '1' DAY)
GROUP BY TransferPoint, Frequency ORDER BY Frequency DESC FETCH FIRST 1 ROWS ONLY;

--5.The average time of transfer for the last quarter
SELECT AVG(TransferTime) AS AverageTransferTime FROM GetOneTransferFlightsInfo(INTERVAL '1' DAY)
WHERE (CURRENT_DATE  - DepartureDate) < 90;