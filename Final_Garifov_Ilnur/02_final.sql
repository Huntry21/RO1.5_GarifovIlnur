-- ============================================================================
-- PART 1: Schema Initialization & Table Creation (IF NOT EXISTS)
-- ============================================================================

-- (run this block manually in psql or pgAdmin connected to the default 'postgres' db, NOT inside a transaction)
-- DROP DATABASE IF EXISTS airline;
-- CREATE DATABASE airline;

CREATE SCHEMA IF NOT EXISTS airline_schema;

-- 1. Airports Reference Table
CREATE TABLE IF NOT EXISTS airline_schema.airports (
    airport_id SERIAL PRIMARY KEY,
    airport_code VARCHAR(3) UNIQUE NOT NULL,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

-- 2. Aircrafts Reference Table
CREATE TABLE IF NOT EXISTS airline_schema.aircrafts (
    aircraft_id SERIAL PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0)
);

-- 3. Crews Reference Table
CREATE TABLE IF NOT EXISTS airline_schema.crews (
    crew_id SERIAL PRIMARY KEY,
    crew_code VARCHAR(20) UNIQUE NOT NULL
);

-- 4. Airline Staff Personnel
CREATE TABLE IF NOT EXISTS airline_schema.staff (
    staff_id SERIAL PRIMARY KEY,
    "name" VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) GENERATED ALWAYS AS ("name" || ' ' || surname) STORED,
    "role" VARCHAR(50) NOT NULL CHECK ("role" IN ('Pilot', 'Flight Attendant'))
);

-- 5. Junction Table: Flight Crew Members Allocation (Many-to-Many)
CREATE TABLE IF NOT EXISTS airline_schema.flight_crew (
    flight_crew_id SERIAL PRIMARY KEY,
    crew_id INT NOT NULL REFERENCES airline_schema.crews(crew_id),
    staff_id INT NOT NULL REFERENCES airline_schema.staff(staff_id),
    CONSTRAINT unique_crew_staff UNIQUE (crew_id, staff_id)
);

-- 6. Flight Routes
CREATE TABLE IF NOT EXISTS airline_schema.routes (
    route_id SERIAL PRIMARY KEY,
    departure_airport_id INT NOT NULL REFERENCES airline_schema.airports(airport_id),
    arrival_airport_id INT NOT NULL REFERENCES airline_schema.airports(airport_id),
    distance_km INT CHECK (distance_km > 0),
    CONSTRAINT check_distinct_airports CHECK (departure_airport_id != arrival_airport_id)
);

-- 7. Specific Scheduled Flights
CREATE TABLE IF NOT EXISTS airline_schema.flights (
    flight_id SERIAL PRIMARY KEY,
    route_id INT NOT NULL REFERENCES airline_schema.routes(route_id),
    aircraft_id INT NOT NULL REFERENCES airline_schema.aircrafts(aircraft_id),
    crew_id INT NOT NULL REFERENCES airline_schema.crews(crew_id),
    departure_time TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled' 
        CHECK (status IN ('Scheduled', 'Delayed', 'Departed', 'Arrived', 'Cancelled'))
);

-- 8. Passengers Directory
CREATE TABLE IF NOT EXISTS airline_schema.passengers (
    passenger_id SERIAL PRIMARY KEY,
    "name" VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20) UNIQUE NOT NULL
);

-- 9. Flight Tickets Booking
CREATE TABLE IF NOT EXISTS airline_schema.tickets (
    ticket_id SERIAL PRIMARY KEY,
    passenger_id INT NOT NULL REFERENCES airline_schema.passengers(passenger_id),
    flight_id INT NOT NULL REFERENCES airline_schema.flights(flight_id),
    seat_number VARCHAR(10) NOT NULL,
    CONSTRAINT unique_seat_per_flight UNIQUE (flight_id, seat_number)
);

-- 10. Ticket Pricing Details (1:1 Relationship via UNIQUE Constraint)
CREATE TABLE IF NOT EXISTS airline_schema.ticket_prices (
    price_id SERIAL PRIMARY KEY,
    ticket_id INT UNIQUE NOT NULL REFERENCES airline_schema.tickets(ticket_id),
    base_fare NUMERIC(10, 2) NOT NULL CHECK (base_fare >= 0),
    tax_amount NUMERIC(10, 2) NOT NULL DEFAULT 1500.00 CHECK (tax_amount >= 0),
    total_price NUMERIC(10, 2) GENERATED ALWAYS AS (base_fare + tax_amount) STORED
);

-- ============================================================================
-- PART 2: Data Seeding (INSERT with Duplicate Prevention)
-- ============================================================================

-- Seeding Airports
INSERT INTO airline_schema.airports (airport_code, airport_name, city) VALUES
('GUW', 'ATMA Atyrau International Airport', 'Atyrau'),
('ALA', 'Almaty International Airport', 'Almaty'),
('NQZ', 'Nursultan Nazarbayev International Airport', 'Astana')
ON CONFLICT (airport_code) DO NOTHING;

-- Seeding Aircrafts
INSERT INTO airline_schema.aircrafts (model, capacity) 
SELECT 'Airbus A321neo', 220 WHERE NOT EXISTS (SELECT 1 FROM airline_schema.aircrafts WHERE model = 'Airbus A321neo');
INSERT INTO airline_schema.aircrafts (model, capacity) 
SELECT 'Boeing 737 MAX 8', 186 WHERE NOT EXISTS (SELECT 1 FROM airline_schema.aircrafts WHERE model = 'Boeing 737 MAX 8');

-- Seeding Crews
INSERT INTO airline_schema.crews (crew_code) VALUES
('CREW-A321-01'),
('CREW-B737-02')
ON CONFLICT (crew_code) DO NOTHING;

-- Seeding Staff Personnel
INSERT INTO airline_schema.staff ("name", surname, "role")
SELECT 'Arman', 'Ibragimov', 'Pilot' WHERE NOT EXISTS (SELECT 1 FROM airline_schema.staff WHERE surname = 'Ibragimov');
INSERT INTO airline_schema.staff ("name", surname, "role")
SELECT 'Dana', 'Saparova', 'Flight Attendant' WHERE NOT EXISTS (SELECT 1 FROM airline_schema.staff WHERE surname = 'Saparova');

-- Allocating Staff into Crews
INSERT INTO airline_schema.flight_crew (crew_id, staff_id)
SELECT 1, 1 WHERE NOT EXISTS (SELECT 1 FROM airline_schema.flight_crew WHERE crew_id = 1 AND staff_id = 1);
INSERT INTO airline_schema.flight_crew (crew_id, staff_id)
SELECT 1, 2 WHERE NOT EXISTS (SELECT 1 FROM airline_schema.flight_crew WHERE crew_id = 1 AND staff_id = 2);

-- Seeding Routes
INSERT INTO airline_schema.routes (departure_airport_id, arrival_airport_id, distance_km)
SELECT 1, 2, 2000 WHERE NOT EXISTS (SELECT 1 FROM airline_schema.routes WHERE departure_airport_id = 1 AND arrival_airport_id = 2);

-- Seeding Flights
INSERT INTO airline_schema.flights (route_id, aircraft_id, crew_id, departure_time, status)
SELECT 1, 1, 1, '2026-06-15 09:30:00', 'Scheduled' 
WHERE NOT EXISTS (SELECT 1 FROM airline_schema.flights WHERE departure_time = '2026-06-15 09:30:00');

-- Seeding Passengers
INSERT INTO airline_schema.passengers ("name", surname, passport_number) VALUES
('Dias', 'Yermekov', 'N12345678'),
('Ilyas', 'Kuznetsov', 'N87654321')
ON CONFLICT (passport_number) DO NOTHING;

-- Seeding Tickets with explicit ID assignment to guarantee re-runnability
INSERT INTO airline_schema.tickets (ticket_id, passenger_id, flight_id, seat_number)
SELECT 1, 1, 1, '01A' WHERE NOT EXISTS (SELECT 1 FROM airline_schema.tickets WHERE ticket_id = 1);
INSERT INTO airline_schema.tickets (ticket_id, passenger_id, flight_id, seat_number)
SELECT 2, 2, 1, '12B' WHERE NOT EXISTS (SELECT 1 FROM airline_schema.tickets WHERE ticket_id = 2);

-- Seeding Ticket Prices only if the corresponding parent ticket exists
INSERT INTO airline_schema.ticket_prices (ticket_id, base_fare)
SELECT 1, 45000.00 
WHERE EXISTS (SELECT 1 FROM airline_schema.tickets WHERE ticket_id = 1)
  AND NOT EXISTS (SELECT 1 FROM airline_schema.ticket_prices WHERE ticket_id = 1);

INSERT INTO airline_schema.ticket_prices (ticket_id, base_fare)
SELECT 2, 32000.00 
WHERE EXISTS (SELECT 1 FROM airline_schema.tickets WHERE ticket_id = 2)
  AND NOT EXISTS (SELECT 1 FROM airline_schema.ticket_prices WHERE ticket_id = 2);

-- ============================================================================
-- PART 3: Demonstration of DML Operations (UPDATE & DELETE)
-- ============================================================================

-- Updating flight departure time and status
UPDATE airline_schema.flights 
SET departure_time = '2026-06-15 11:00:00', status = 'Delayed'
WHERE flight_id = 1;

-- Updating ticket pricing details
UPDATE airline_schema.ticket_prices
SET base_fare = base_fare + 5000.00
WHERE ticket_id = 1;

-- Safe deletion demonstrations to preserve data hierarchy on subsequent runs
DELETE FROM airline_schema.ticket_prices WHERE ticket_id = 2;
DELETE FROM airline_schema.tickets WHERE ticket_id = 2;

-- ============================================================================
-- PART 4: Access Control & Role Management (DCL Block)
-- ============================================================================

-- Creating a Read-Only Manager role if it does not exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'airline_manager_readonly') THEN
        CREATE ROLE airline_manager_readonly WITH LOGIN PASSWORD 'SecurePass123';
    END IF;
END $$;

-- Granting explicit connection permission to the current database
GRANT CONNECT ON DATABASE "airline" TO airline_manager_readonly;

-- Granting read-only permissions to the created manager role on airline schema
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.role_table_grants 
        WHERE grantee = 'airline_manager_readonly' 
        AND table_schema = 'airline_schema' 
        AND privilege_type = 'SELECT'
    ) THEN
        GRANT USAGE ON SCHEMA airline_schema TO airline_manager_readonly;
        GRANT SELECT ON ALL TABLES IN SCHEMA airline_schema TO airline_manager_readonly;
    END IF;
END $$;

-- ============================================================================
-- PART 5: Data Fetching and Verification (Complex SELECT Query)
-- ============================================================================

-- Switching the execution context to the read-only role to verify restrictions
SET ROLE airline_manager_readonly;

-- Executing complex multi-table JOIN query to showcase operational workflow
SELECT 
    f.flight_id,
    a.airport_code AS "From",
    a2.airport_code AS "To",
    s.full_name AS "Pilot Name",
    p.passport_number,
    t.seat_number,
    tp.total_price
FROM airline_schema.flights f
JOIN airline_schema.routes r ON f.route_id = r.route_id
JOIN airline_schema.airports a ON r.departure_airport_id = a.airport_id
JOIN airline_schema.airports a2 ON r.arrival_airport_id = a2.airport_id
JOIN airline_schema.crews c ON f.crew_id = c.crew_id
JOIN airline_schema.flight_crew fc ON c.crew_id = fc.crew_id
JOIN airline_schema.staff s ON fc.staff_id = s.staff_id AND s.role = 'Pilot'
JOIN airline_schema.tickets t ON f.flight_id = t.flight_id
JOIN airline_schema.passengers p ON t.passenger_id = p.passenger_id
JOIN airline_schema.ticket_prices tp ON t.ticket_id = tp.ticket_id;

-- Resetting the execution role back to the administrative session defaults
RESET ROLE;