# Airline Management Database System

An end-to-end relational database solution designed to model and manage corporate airline operations, including airports, aircraft fleets, flight schedules, crews, passengers, and ticket distribution systems. The project is implemented in PostgreSQL and adheres to 3rd Normal Form (3NF) relational standards.

## Project Structure

The project consists of the following foundational artifacts:
1. **Conceptual Model**: A high-level entity diagram defining core business domains.
2. **Logical Model**: A fully mapped diagram designed in Lucidchart showcasing explicit datatypes, constraints (`NOT NULL`, `UNIQUE`, `CHECK`), and relative cardinality scales.
3. **Physical Script**: An executable, robust, and re-runnable SQL file optimizing safe data operations, access control, and hierarchical queries.

---

## Relational Schema Architecture

The relational structure isolates operations inside a dedicated `airline_schema` containing 10 specialized tables:

* **airports**: System directory for international travel points (`airport_code`, name, city).
* **aircrafts**: Fleet infrastructure trackers managing configurations and total seating limits.
* **crews**: Centralized organizational identifiers for active flight crews.
* **staff**: Employee records isolating roles (`Pilot`, `Flight Attendant`) alongside auto-computed `GENERATED ALWAYS` full name values.
* **flight_crew**: A balanced junction table handling Many-to-Many employee allocations.
* **routes**: Geographic trajectory profiles enforcing specific constraints to prevent identical origin-destination records.
* **flights**: Operational calendar linking routes, physical aircraft, assigned crews, schedules, and dynamic tracking states.
* **passengers**: Customer identification logs securing localized passport records.
* **tickets**: Transaction records allocating verified cabin seating arrangements to specific passengers.
* **ticket_prices**: A strictly enforced One-to-One (1:1) mapping table recording financial breakups, base rates, fixed taxation variables, and automated system total calculations.

---

## SQL Features Implemented

* **Idempotent Execution**: Comprehensive integration of `IF NOT EXISTS` and `ON CONFLICT DO NOTHING` guards enabling reliable script re-runs.
* **Data Integrity Controls**: Standardized relational checks preventing zero-capacities, empty data configurations, and erroneous routing assignments.
* **Calculated Fields**: Real-time evaluation of data parameters (`STORED` expressions) ensuring immediate transactional calculations.
* **Data Control Language (DCL)**: Practical encapsulation of user role permissions (`airline_manager_readonly`) granting structural access layers without compromising administrative profiles.
* **Hierarchical Reporting**: Multi-table inner joins synthesizing complex relational structures into clean, business-oriented analytical views.

---

## Getting Started

### Prerequisites
* PostgreSQL 13+
* pgAdmin 4 or any compatible SQL client

### Setup Instructions
1.  Connect to your PostgreSQL server using your preferred administrative account (e.g., `postgres`).
2.  Create a target database named **`airline`** if it does not already exist:
    ```sql
    CREATE DATABASE "airline";
    ```
3.  Open the Query Tool directly inside the newly created `airline` database instance.
4.  Copy the contents of the physical script file, paste it into the editor window, and execute (`F5`).
5.  Review the query output pane to inspect both the computational notifications and the compiled multi-table execution report generated under the restricted manager context.