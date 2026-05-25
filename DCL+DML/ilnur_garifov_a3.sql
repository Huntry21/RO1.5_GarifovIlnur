reset role;

drop user if exists db_admin_user;
drop user if exists db_reader_user;
drop role if exists gym_admin;
drop role if exists gym_readonly;

create role gym_admin;
create role gym_readonly;

grant usage on schema public to gym_admin;
grant usage on schema public to gym_readonly;

grant select, insert, update, delete on all tables in schema public to gym_admin;
grant select on all tables in schema public to gym_readonly;

create user db_admin_user with password 'AdminSecure123!';
grant gym_admin to db_admin_user;

create user db_reader_user with password 'ReaderSecure123!';
grant gym_readonly to db_reader_user;

revoke update, delete on all tables in schema public from gym_readonly;


set role db_admin_user;
select current_user;
select count(*) from member; 

insert into membership_type (type_name, monthly_fee, access_level) values ('Verification Type', 0.00, 1);
insert into member (first_name, last_name, email, phone, join_date, membership_type_id) values ('V', 'V', 'v@v.com', '0', '2026-02-01', (select membership_type_id from membership_type where type_name = 'Verification Type'));
update member set first_name = 'V2' where email = 'v@v.com';
delete from member where email = 'v@v.com';

reset role;

set role db_reader_user;
select current_user;
select count(*) from member;

begin;

rollback;

begin;

rollback;

begin;

rollback;

reset role;

truncate table equipment_maintenance, maintenance, equipment, payment, attendance, schedule, facility, class, instructor, member, membership_type restart identity cascade;

insert into membership_type (type_name, monthly_fee, access_level) values
('Standard Monthly', 15000.00, 1),
('Premium Pass', 25000.00, 2),
('VIP All-Access', 45000.00, 3),
('Student Discount', 10000.00, 1),
('Weekend Warrior', 12000.00, 1);

insert into member (first_name, last_name, email, phone, join_date, membership_type_id) values
('Askar', 'Amanov', 'askar@example.kz', '+77015551122', '2026-01-15', (select membership_type_id from membership_type where type_name = 'Standard Monthly')),
('Zarina', 'Sainova', 'zarina@example.kz', '+77025552233', '2026-01-20', (select membership_type_id from membership_type where type_name = 'Premium Pass')),
('Timur', 'Kasymov', 'timur@example.kz', '+77035553344', '2026-02-01', (select membership_type_id from membership_type where type_name = 'VIP All-Access')),
('Aruzhan', 'Serikova', 'aruzhan@example.kz', '+77045554455', '2026-02-10', (select membership_type_id from membership_type where type_name = 'Student Discount')),
('Daniyar', 'Isaev', 'daniyar@example.kz', '+77055555566', '2026-02-15', (select membership_type_id from membership_type where type_name = 'Weekend Warrior'));

insert into instructor (first_name, last_name, specialization, certification) values
('Alex', 'Jones', 'Bodybuilding', 'IFBB Pro'),
('Elena', 'Petrova', 'Yoga & Pilates', 'RYT-500'),
('Daulet', 'Saparov', 'CrossFit', 'CrossFit Level 3'),
('Anna', 'Smith', 'Cardio & Cycling', 'Spinning Instructor Gold'),
('Murat', 'Ospanov', 'Martial Arts', 'Black Belt 2nd Dan');

insert into class (class_name, description, difficulty) values
('Power Lifting', 'Heavy barbell training focusing on core lifts', 'Hard'),
('Vinyasa Flow', 'Dynamic yoga practice synchronizing breath with movement', 'Medium'),
('CrossFit WOD', 'High intensity functional fitness workout of the day', 'Hard'),
('Spin Intensity', 'High-energy indoor cycling routine', 'Medium'),
('Intro to Boxing', 'Basic punches, footwork, and conditioning', 'Easy');

insert into facility (room_name, capacity, equipment_type) values
('Main Gym Floor', 100, 'Free weights, cables, Smith machines'),
('Yoga Studio', 20, 'Mats, blocks, straps, wall ropes'),
('CrossFit Box', 30, 'Rigs, bumper plates, kettles, rowers'),
('Cycle Room', 25, 'Stationary bikes, sound system'),
('Combat Zone', 15, 'Heavy bags, mats, speed bags');

insert into schedule (class_id, instructor_id, facility_id, start_time, end_time) values
(
    (select class_id from class where class_name = 'Power Lifting'),
    (select instructor_id from instructor where last_name = 'Jones'),
    (select facility_id from facility where room_name = 'Main Gym Floor'),
    '2026-06-01 09:00:00', '2026-06-01 10:30:00'
),
(
    (select class_id from class where class_name = 'Vinyasa Flow'),
    (select instructor_id from instructor where last_name = 'Petrova'),
    (select facility_id from facility where room_name = 'Yoga Studio'),
    '2026-06-01 18:00:00', '2026-06-01 19:00:00'
),
(
    (select class_id from class where class_name = 'CrossFit WOD'),
    (select instructor_id from instructor where last_name = 'Saparov'),
    (select facility_id from facility where room_name = 'CrossFit Box'),
    '2026-06-02 07:00:00', '2026-06-02 08:00:00'
),
(
    (select class_id from class where class_name = 'Spin Intensity'),
    (select instructor_id from instructor where last_name = 'Smith'),
    (select facility_id from facility where room_name = 'Cycle Room'),
    '2026-06-02 19:00:00', '2026-06-02 20:00:00'
),
(
    (select class_id from class where class_name = 'Intro to Boxing'),
    (select instructor_id from instructor where last_name = 'Ospanov'),
    (select facility_id from facility where room_name = 'Combat Zone'),
    '2026-06-03 12:00:00', '2026-06-03 13:00:00'
);

insert into attendance (member_id, schedule_id, status) values
(
    (select member_id from member where email = 'askar@example.kz'),
    (select s.schedule_id from schedule s join class c on s.class_id = c.class_id where c.class_name = 'Power Lifting'),
    'attended'
),
(
    (select member_id from member where email = 'zarina@example.kz'),
    (select s.schedule_id from schedule s join class c on s.class_id = c.class_id where c.class_name = 'Vinyasa Flow'),
    'attended'
),
(
    (select member_id from member where email = 'timur@example.kz'),
    (select s.schedule_id from schedule s join class c on s.class_id = c.class_id where c.class_name = 'CrossFit WOD'),
    'no-show'
),
(
    (select member_id from member where email = 'aruzhan@example.kz'),
    (select s.schedule_id from schedule s join class c on s.class_id = c.class_id where c.class_name = 'Spin Intensity'),
    'attended'
),
(
    (select member_id from member where email = 'daniyar@example.kz'),
    (select s.schedule_id from schedule s join class c on s.class_id = c.class_id where c.class_name = 'Intro to Boxing'),
    'cancelled'
);

insert into payment (member_id, amount, payment_date, payment_method) values
((select member_id from member where email = 'askar@example.kz'), 15000.00, '2026-01-15 10:00:00', 'credit_card'),
((select member_id from member where email = 'zarina@example.kz'), 25000.00, '2026-01-20 14:30:00', 'cash'),
((select member_id from member where email = 'timur@example.kz'), 45000.00, '2026-02-01 09:15:00', 'bank_transfer'),
((select member_id from member where email = 'aruzhan@example.kz'), 10000.00, '2026-02-10 11:00:00', 'credit_card'),
((select member_id from member where email = 'daniyar@example.kz'), 12000.00, '2026-02-15 16:45:00', 'mobile_payment');

insert into equipment (facility_id, equipment_name, status) values
((select facility_id from facility where room_name = 'Main Gym Floor'), 'Olympic Barbell Rogue 20kg', 'active'),
((select facility_id from facility where room_name = 'Main Gym Floor'), 'Power Cage Rack', 'active'),
((select facility_id from facility where room_name = 'CrossFit Box'), 'Concept2 RowErg', 'out_of_order'),
((select facility_id from facility where room_name = 'Cycle Room'), 'Stages SC3 Indoor Bike', 'active'),
((select facility_id from facility where room_name = 'Combat Zone'), 'Everlast 100lb Heavy Bag', 'damaged');

insert into maintenance (maintenance_date, description, cost) values
('2026-02-10', 'Replaced chain and monitor batteries on rower', 25000.00),
('2026-02-12', 'Re-stitched leather hanging loops on heavy bag', 5000.00),
('2026-03-01', 'General lubrication and bolt tightening of cycling bikes', 15000.00),
('2026-03-05', 'Re-calibrated weight stack pulley wires', 35000.00),
('2026-03-10', 'Deep clean and sanitization of yoga mats', 8000.00);

insert into equipment_maintenance (equipment_id, maintenance_id) values
(
    (select equipment_id from equipment where equipment_name = 'Concept2 RowErg'),
    (select maintenance_id from maintenance where description = 'Replaced chain and monitor batteries on rower')
),
(
    (select equipment_id from equipment where equipment_name = 'Everlast 100lb Heavy Bag'),
    (select maintenance_id from maintenance where description = 'Re-stitched leather hanging loops on heavy bag')
),
(
    (select equipment_id from equipment where equipment_name = 'Stages SC3 Indoor Bike'),
    (select maintenance_id from maintenance where description = 'General lubrication and bolt tightening of cycling bikes')
),
(
    (select equipment_id from equipment where equipment_name = 'Olympic Barbell Rogue 20kg'),
    (select maintenance_id from maintenance where description = 'Re-calibrated weight stack pulley wires')
),
(
    (select equipment_id from equipment where equipment_name = 'Power Cage Rack'),
    (select maintenance_id from maintenance where description = 'Deep clean and sanitization of yoga mats')
);

select count(*) from membership_type where monthly_fee > 20000.00;

update membership_type 
set monthly_fee = monthly_fee * 1.05 
where monthly_fee > 20000.00;

select count(*) from equipment where status = 'damaged';

update equipment 
set status = 'under_maintenance' 
where status = 'damaged';

select count(*) 
from attendance a
join schedule s on a.schedule_id = s.schedule_id
join class c on s.class_id = c.class_id
where c.difficulty = 'Hard' and a.status = 'no-show';

update attendance a
set status = 'excused'
from schedule s
join class c on s.class_id = c.class_id
where a.schedule_id = s.schedule_id 
  and c.difficulty = 'Hard' 
  and a.status = 'no-show';

begin;

delete from attendance 
where status = 'cancelled';

select count(*) from attendance;

rollback;