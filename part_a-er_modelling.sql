--
-- @StudentID: 
--
--
-- Designed for PostgreSQL 9.x with PostGIS

-- Enable PostGIS in the current DB
CREATE EXTENSION IF NOT EXISTS POSTGIS;

-- Write your SQL here.
DROP TABLE IF EXISTS clinics;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS diseases;
DROP TABLE IF EXISTS patients_diseases;

-- Address could be broken into further catagories. 
CREATE TABLE clinics(
	clinic_id	    integer		PRIMARY KEY,
	name			text		NOT NULL
	street		    text		NOT NULL,
	city			text		NOT NULL,
	post_code		text		NOT NULL,
	geo_location    geometry(Point, 27700) NOT NULL,	
	catchment_area	geometry(Polygon, 27700) NOT NULL
);
-- Clinics have a 1 to Many relationship with doctors, requiring a foreign key in 
-- the doctors table
CREATE TABLE doctors(
	doc_id			  integer	PRIMARY KEY,
	first_name 		  text		NOT NULL,
	last_name  	      text		NOT NULL,
	date_of_birth	  date 		NOT NULL,
	specialty		  text		NOT NULL,
	clinic_worked_in  integer	REFERENCES clinics(clinic_id)--Foreign Key
);

--Clinics have a 1 to Many relationship with patients, requiring a foreign key
-- in the patients table to relate the two tables.
CREATE TABLE patients(
	pat_id				integer		PRIMARY KEY,
	first_name			text		NOT NULL,
	last_name			text		NOT NULL,
	date_of_birth		date		NOT NULL,
	date_of_death		date,
	gender				varchar(1) 	NOT NULL, --Can be M or F (O for other)
	street				text		NOT NULL,
	city				text		NOT NULL,
	post_code			text		NOT NULL
	address_geom	    geometry(Point, 27700) 	NOT NULL,
	clinic_attended		integer 	REFERENCES clinics(clinic_id) --foreign key
	);

CREATE TABLE diseases(
	disease_id			integer		PRIMARY KEY,
	disease_type		varchar(20)	NOT NULL,
	severity_level		varchar(6) 	NOT NULL, --Low, Medium, High 
	mortality_rate		decimal(3,2),  --allows for values up to 1.00 to be stored which would equal 100%
);

--Many to Many relationship between the patients and diseases requires the creation
-- of a new table with a unique primary key pair.
CREATE TABLE patients_diseases(
	pat_id				integer  NOT NULL REFERENCES patients(pat_id), -- foreign key
	disease_id			integer  NOT NULL REFERENCES diseases(disease_id), -- foreign key
	start_date			date 	 NOT NULL,
	end_date			date, 	 
	PRIMARY KEY (pat_id, disease_id)
	CONSTRAINT chk_date CHECK(end_date >= start_date)-- check on the dates to ensure the end date isnt imputted before the start date
);


	
-- should be able to use date to identify mutliple instances of contracting a disease_id
-- using another column for the year contracted seems redundant and violates 1st normal form

INSERT INTO clinics(clinic_id, name, street, city, post_code, geo_location, catchment_area)
VALUES	(1, 'Manchester Royal Infirmary', 'Oxford St.', 'Manchester', 'M13 9WL',
		 ST_GeomFromText('POINT(-2.231480 53.464081)', 27700), ST_GeomFromText('POLYGON((-2.2355529698842247 53.45674815579344, -2.2368833455556114 53.467811189034514, -2.2114345464223106 53.467811189034514, -2.2105333241933067 53.456007110607224, -2.2355529698842247 53.45674815579344))', 27700)),
		(2, 'North Manchester General Hospital', 'Delaunays Rd', 'Manchester', 'M8 5RB', 
		 ST_GeomFromText('POINT(-2.231410 53.519032)', 27700), ST_GeomFromText('POLYGON((-2.245517569407184 53.52428629288716, -2.245689230784137 53.511324011123314, -2.2005422886454653 53.512548963305925, -2.2032888706767153 53.52500063405208, -2.245517569407184 53.52428629288716 ))', 27700)),
		(3, 'St Thomas Hospital', 'Westminster Bridge Rd', 'London', 'SE1 7EH',
		ST_GeomFromText('POINT(-0.113120 51.499439)', 27700), ST_GeomFromText('POLYGON((-0.14769755790189265 51.52111158053667, -0.1315613884682989 51.49033927324885, -0.0951691765542364 51.49888922100836, -0.1270294189453125 51.51942532808189, -0.14769755790189265 51.52111158053667))', 27700)),
		(4, 'Bristol Royal Infirmary', 'Marlborough St', 'Bristol', 'BS2 8HW', 
		ST_GeomFromText('POINT(-2.593560 51.459751)', 27700),ST_GeomFromText('POLYGON((-2.603620172556475 51.465028455383205, -2.6018177280984673 51.453049189085014, -2.578900934275225 51.45401192487387, -2.5839649448953423 51.465723584131425, -2.603620172556475 51.465028455383205))',27700))
		;

INSERT INTO doctors(doc_id, first_name, last_name, date_of_birth, specialty, clinic_worked_in)
VALUES	(1, 'Steve', 'Irwin', '1972-11-14', 'psychology', 2),
		(2, 'James', 'Harden', '1984-06-19', 'dermatology', 4),
		(3, 'Oliver', 'Jenner', '1945-03-12', 'cardiology', 1),
		(4, 'James', 'Black', '1965-12-19', 'radiology', 3),
		(5, 'Anthony', 'Rizzo', '1973-04-19', 'oncology', 3)
		;

INSERT INTO patients(pat_id, first_name, last_name, date_of_birth,date_of_death, gender,
					 street, city, post_code, address_geom, clinic_attended)
VALUES	(1, 'Russell', 'Westbrook', '1982-09-14', NULL, 'M', '116 Burton Ave', 'Manchester', 'M20 1LP', ST_GeomFromText('POINT(-2.239600,53.429510)', 27700), 1),
		(2, 'Clint', 'Capela', '1991-08-08', NULL, 'M', '31 Princes Park Ave', 'London', 'NW11 0JR', ST_GeomFromText('POINT(-0.207910 51.581150)', 27700), 3),
		(3, 'Kari', 'Day', '1932-05-21', '2018-05-29', 'F', 'Ambleside Rd', 'Windermere', 'LA 23 1LP',  ST_GeomFromText('POINT(-2.911660 54.382970)', 27700), 2),
		(4, 'Emily', 'Poole', '1995-02-09', NULL, 'F', '25 High St.', 'Hawick', 'TD9 9BU', ST_GeomFromText('POINT(-2.788000 55.422250)', 27700), 4),
		(5, 'Ryan', 'Marshall', '1978-07-09', '2019-01-02', 'M', '37 Fore St.', 'Exeter', 'EX3 0HR', ST_GeomFromText('POINT(-3.465170 50.681970)', 27700), 4),
		(6, 'Eric', 'Gordon', '1995-01-29', NULL, 'M', 'Southfield', 'Malmesbury', 'SN16 0PU', ST_GeomFromText('POINT(-2.210370 51.566660)', 27700), 3)
		;

INSERT INTO diseases(disease_id, disease_type, severity_level, mortality_rate, patient_affected)
VALUES	(1, 'flue', 'Medium', '0.33'),
		(2, 'cancer', 'High', '0.72'),
		(3, 'Chrons',  'Low', '0.11'),
		(4, 'diabetes', 'Medium', '0.35'),
		(5, 'Lupus', 'High', '0.88'),
		(6, 'Asmtha', 'Low', '0.08'),
		(7, 'Heart Disease', 'Medium', '0.56')
		;

INSERT INTO patients_diseases(pat_id, disease_id, start_date, end_date)
VALUES	(1, 3, '1998-03-14', '1999-05-25'),
		(2, 1, '2003-08-10', '2003-09-11'),
		(3, 3, '1965-02-19', '1975-04-23'),
		(4, 2, '2010-12-19', NULL),
		(5, 7, '2000-10-12', NULL),
		(6, 5, '2005-09-15', NULL),
		(2, 4, '2008-02-04', NULL),
		(4, 6, '2012-04-09', '2018-01-01')
		;



