DROP TABLE IF EXISTS equipment_maintenance, maintenance, equipment, payment, attendance, schedule, facility, class, instructor, member, membership_type CASCADE;
-- membership_type
CREATE TABLE membership_type (
    membership_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    monthly_fee DECIMAL(10,2) CHECK (monthly_fee >= 0),
    access_level INT
);

-- member
CREATE TABLE member (
    member_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    join_date DATE CHECK (join_date > '2026-01-01'),
    membership_type_id INT NOT NULL,
    FOREIGN KEY (membership_type_id) REFERENCES membership_type(membership_type_id)
);

-- instructor
CREATE TABLE instructor (
    instructor_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialization VARCHAR(50),
    certification VARCHAR(50)
);

-- class
CREATE TABLE class (
    class_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    difficulty VARCHAR(20)
);

-- facility
CREATE TABLE facility (
    facility_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_name VARCHAR(50) NOT NULL UNIQUE,
    capacity INT NOT NULL CHECK (capacity > 0),
    equipment_type VARCHAR(100)
);

-- schedule
CREATE TABLE schedule (
    schedule_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class_id INT NOT NULL,
    instructor_id INT NOT NULL,
    facility_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    CHECK (end_time > start_time),
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id),
    FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
);

-- attendance
CREATE TABLE attendance (
    attendance_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL,
    schedule_id INT NOT NULL,
    status VARCHAR(20),
    FOREIGN KEY (member_id) REFERENCES member(member_id),
    FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id),
    UNIQUE (member_id, schedule_id)
);

-- payment
CREATE TABLE payment (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (amount >= 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30),
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);

-- equipment
CREATE TABLE equipment (
    equipment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    facility_id INT NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    status VARCHAR(20),
    FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
);

-- maintenance
CREATE TABLE maintenance (
    maintenance_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    maintenance_date DATE NOT NULL CHECK (maintenance_date > '2026-01-01'),
    description TEXT,
    cost DECIMAL(10,2) CHECK (cost >= 0)
);

-- equipment_maintenance
CREATE TABLE equipment_maintenance (
    eq_maint_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    equipment_id INT NOT NULL,
    maintenance_id INT NOT NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    FOREIGN KEY (maintenance_id) REFERENCES maintenance(maintenance_id)
);