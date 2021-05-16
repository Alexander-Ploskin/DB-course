--Trigger function which updates number of free seats on the flight if ticket was bought or returned
CREATE OR REPLACE FUNCTION sale_trigger() RETURNS trigger AS $sale_trigger$
DECLARE freeseats INT;
BEGIN
    IF NEW IS NULL THEN
        SELECT Flights.TotalTickets - Flights.SoldTickets INTO freeseats FROM Flights
	    WHERE FlightNumber = old.FlightNumber and DepartureDate = old.DepartureDate;

	    UPDATE Flights SET SoldTickets = Flights.SoldTickets - 1
		WHERE FlightNumber = old.FlightNumber and DepartureDate = old.DepartureDate;
        RETURN OLD;
    ELSE
        SELECT Flights.TotalTickets - Flights.SoldTickets INTO freeseats FROM Flights
	    WHERE FlightNumber = new.FlightNumber and DepartureDate = new.DepartureDate;

	    IF freeseats = 0
	        THEN RAISE EXCEPTION 'All tickets for this flight are already sold';
	    ELSE UPDATE Flights SET SoldTickets = Flights.SoldTickets + 1
		    WHERE FlightNumber = new.FlightNumber and DepartureDate = new.DepartureDate;
	    END IF;

        RETURN NEW;
    end if;

END;
$sale_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sale_trigger ON Passengers;
CREATE TRIGGER sale_trigger BEFORE INSERT OR DELETE ON Passengers FOR EACH ROW EXECUTE PROCEDURE sale_trigger();