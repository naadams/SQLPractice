--
-- @StudentID: 
--
--
-- Designed for PostgreSQL 9.x with PostGIS

-- Enable PostGIS in the current DB
CREATE EXTENSION IF NOT EXISTS POSTGIS;

-- Write your SQL here.
-- adding Geom column to the university_applicants table type POINT
SELECT AddGeometryColumn('university_applicants', 'geom', 27700, 'POINT', 2)

-- Easting relates to the longitude or X coordinate and Northing refers to latitude
-- or the Y coordinate. These values need to be converted to an floating number to
-- convert them using MakePoint. Then you set the SRID which was given. 
UPDATE university_applicants 
SET geom = ST_SetSRID(ST_MakePoint("Easting" ::float, "Northing":: float),27700);

-- english_regions, uk_lad and university_applicants all contain geom columns
-- type geometry, so i'll create spatial indicies on those columns using GIST.
-- as a point of contention i'll drop the indicies first if they already exist.
DROP INDEX IF EXISTS uni_app_idx;
DROP INDEX IF EXISTS uk_lad_idx;
DROP INDEX IF EXISTS eng_reg_idx;
CREATE INDEX uni_app_idx ON university_applicants USING GIST (geom);
CREATE INDEX uk_lad_idx ON uk_lad USING GIST (geom);
CREATE INDEX eng_reg_idx ON english_regions USING GIST (geom);

--This section contains the SQL queries and answers to parts A to N

--A.) 
select count("SEX") as n_applicants
from university_applicants
where "SEX" = 'F' or "SEX" = 'M' ;
-- There are 39,228 Male and Female applicants

--B.) count each ethnic group from the university_applicants table
-- then add a group by function to group them together appropriately
select "EthnicGroup", count("EthnicGroup") as n_groups
from university_applicants
group by "EthnicGroup";
-- Refused = 134, BorBB = 4076, Mixed = 763, White = 7248, CorOEB = 620
-- AorAB = 3059, NotKnown = 23340

--C.) Count only the ethnic groups that are non white AorAB BorBB and CorOEB
select count("EthnicGroup") as non_white_applicants
from university_applicants
where "EthnicGroup" = 'BorBB' or "EthnicGroup" = 'CorOEB'
	or "EthnicGroup" = 'AorAB' ;
-- 7755 non-white ethnic applicants

--D.) Need to count all the ID's for Males with A/AS qualification
select count("ID") as male_a_level_qual_apps
from university_applicants
where "SEX" = 'M' and "Post-confActualQual"= 'A/AS level'
;
-- 4090 male applicants with A/AS level qualification 

--E.) searched the table first to find the name for the group with
-- no formal qualification known as "Student has no formal qualification"
-- A group by check of ModeOfStudy shows only FullTime and PartTime students
-- exist in this table, so the selections were White, FullTime and no qualification
select count("ID") as no_qual
from university_applicants
where "EthnicGroup" = 'White' and "Post-confActualQual"= 'Student has no formal qualification'
	and "ModeOfStudy" = 'FullTime'
-- Query returns 2 results

--F.) Select only distinct post codes from university_applicants
-- then group together the OR statement for ethnic groups and SEX in parenthisis
select distinct "PCODE"
from university_applicants
where "Post-confActualQual" = 'UK first degree with honours' 
	and ("SEX" = 'F' or "EthnicGroup" = 'CorOEB');
	-- 1489 unique post codes.

--G.) Join the regions and applicants on their geometry using a spatial join
-- Only take records from the table for Males and region labels that are not London
select count(ua."ID") as male_not_london
	from english_regions as er, university_applicants as ua
	where ST_Contains(er.geom,ua.geom)
	and ua."SEX" = 'M'
	and er.geo_label != 'London'
	;
	-- 5425 Male applicants not from London
	
--H.) Spatial join uk_lad and applicants table, group by the names of 
-- the local area districts, and then count ID's from the UA table for
-- each LAD.  Rename the count and order by it and sort it desc so the 
-- highest total is first and limit the results by 1.
select count(ua."ID") as applicants, lad.geo_label
	from uk_lad as lad, university_applicants as ua
	where ST_Contains(lad.geom, ua.geom)
	group by lad.geo_label 
	order by applicants desc
	limit 1
	;
	-- Greenwich with 2243 applicants
	
--I.) Very similar to previous query, change the spatial join to the
-- english regions table, group by the region, order by the number of
-- applicants in each region and then flip the way you sort to ASC
-- so that the lowest number is on top and limit the results to 1
select count(ua."ID") as applicants, er.geo_label
	from english_regions as er, university_applicants as ua
	where ST_Contains(er.geom, ua.geom)
	group by er.geo_label 
	order by applicants asc
	limit 1;
	-- 196 in the North East region

--J.) count the applicant id's after spatial joining regions and applicants
-- on geom.  Make sure the region is set = to London
select count(ua."ID") as apps_from_london
	from english_regions as er, university_applicants as ua
	where ST_Contains(er.geom,ua.geom)
	and er.geo_label = 'London'
	;
	-- answer is 24936 applicants from London

--K.) equi join uk_lad and occupation on geo_code as both tables contain it
-- order the tables by the MDSO occupation type, desc and keep the top 10

select lad.geo_label, ot."MDSO", lad.geom
	from uk_lad as lad, occupation_type as ot
	where lad.geo_code = ot."GEO_CODE"
	order by ot."MDSO" desc limit 10;
	
-- 	Wealden, Bournemouth, Reigate and Banstead, South Cambridgeshire, Derby
-- Bath and North East Somerset, Dacorum, Mid Sussex, Colchester, Newham

--L.)Doesn't return any scottish or NI LAD applicants.
select count(ua."ID") as applicants, --count ID's from applicants
	lad.geo_label as LocalAreaDistricts, er.geo_label as EnglishRegions --rename columns
	from uk_lad as lad, university_applicants as ua, english_regions as er --rename tables
	where ST_Contains(lad.geom, ua.geom)	
	and ST_Contains(er.geom, ua.geom)-- Spatial Joins
	group by lad.geo_label, er.geo_label -- 
	having count(ua."ID") < 10 -- take only LAD's with <10 applicants
	order by applicants -- orders them by # of applicants
	desc
	;
	-- Returned 77 LADs within the English Regions that have <10 applicants
--M.)
select count(ua."ID") as applicants, lad.geom, lad.geo_label
	from uk_lad as lad, university_applicants as ua --rename tables
	where ST_Contains(lad.geom, ua.geom) -- Spatial Join
	group by lad.geo_label, lad.geom -- group by both the LAD name and geometry
	having count(ua."ID") > 500 -- make sure there are more than 500 applicants
	order by applicants desc -- order by the highest total of applicants first
	;
-- Greenwich, Newham, Lewisham, Bexley, Tower Hamlets, Southwark, Croydon
-- Redbridge, Medway, Bromley, Waltham Forest, Barking and Dagenham, Lambeth
-- Enfield, Hackney, Brent, Haringey, Ealing, Wandsworth

--N.)English regions with the least amount of nonwhite female applicants outside of London
select count(ua."ID") as applicants, er.geo_label
from university_applicants as ua, english_regions as er
where ST_Contains(er.geom,ua.geom)
and ua."EthnicGroup" != 'White' and er.geo_label != 'London' and ua."SEX"= 'F'
group by er.geo_label
order by applicants asc
limit 3;

