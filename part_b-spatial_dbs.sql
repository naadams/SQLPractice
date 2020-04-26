--
-- @StudentID: 
--
--
-- Designed for PostgreSQL 9.x with PostGIS

-- Enable PostGIS in the current DB
CREATE EXTENSION IF NOT EXISTS POSTGIS;

-- Write your SQL here.

DROP TABLE IF EXISTS gulf_states;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS donations;
DROP TABLE IF EXISTS hurricanes;
DROP TABLE IF EXISTS meteorologists;

--Using as SRID of 4269 as it equals NAD83 and the gulf states are in north america 
CREATE TABLE gulf_states(
	state_id	 integer	PRIMARY KEY,
	state_name   text		UNIQUE NOT NULL,
	geom		 geometry(Polygon, 4269) NOT NULL
);

-- foreign key of region to reference regions, represents 1 to many relationship
-- 1 state can have many cities but a city can only be in one state
CREATE TABLE cities(
	city_id		 integer	PRIMARY KEY,
	city_name 	 text		UNIQUE NOT NULL,
	population	 integer	NOT NULL,
	state_name	 text		REFERENCES gulf_states(state_name),-- foreign key
	geom 		 geometry(Point, 4269)  NOT NULL
);

--One to many relationship with cities so a foreign key is created
-- 1 city can receive multiple donations, but each donation can only go to one city
CREATE TABLE donations(
	donation_id 	integer	PRIMARY KEY,
	person_donated  text	NOT NULL,
	amount_donated  float  	NOT NULL,
	year_donated	integer, 
	city_donated_to	text 	REFERENCES cities(city_name)
);
-- different hurricanes that made landfall along gulf, year they occurred, type and intensity
CREATE TABLE hurricanes(
	hurricane_id  integer  PRIMARY KEY,
	hurricane_name	text,
	month_occured varchar(10),  --month of landfall
	year_occured  integer	NOT NULL,
	category	  integer	CHECK (category >=0 and category <= 5), -- graded on a scale of 0 to 5 with 5 being most intense
	monetary_damage	float	CHECK (monetary_damage >= 0),--Amount of destruction caused in bilions
	inj_death		integer,  -- injuries or deaths caused by disaster
	geom          geometry(LINESTRING, 4269) --geometry for paths of storms 
);

-- Many to Many relationship between hurricanes and cities calls for a new table to relate them
CREATE TABLE city_hurricanes(
	hurricane_id		integer		NOT NULL REFERENCES hurricanes(hurricane_id),
	city_id			integer		NOT NULL REFERENCES cities(city_id),
	PRIMARY KEY (hurricane_id, city_id)
);

-- forecasters names and genders
CREATE TABLE meteorologists(
	met_id		integer 	PRIMARY KEY,
	first_name	text		NOT NULL,
	last_name   text		NOT NULL,
	gender		varchar(1)  --M or F 
);

-- Many to Many relationship between the hurricanes and the meteorologists forecasting them
-- each meteorologist can forecast multiple storms and each storm can have multiple forecasters
-- inlcluded an accuracy attribute as a decimal to represent the % accuracy at which
-- they forecasted, better forecasted storms could cause less inj_death
CREATE TABLE hurricane_forecast(
	met_id		integer		NOT NULL REFERENCES meteorologists(met_id), --foreign key
	hur_forecasted	integer		NOT NULL REFERENCES hurricanes(hurricane_id), -- foreign key
	accuracy	decimal(3,2),  --allows for values up to 1.00 to be stored which would equal 100%
	PRIMARY KEY (met_id, hur_forecasted)
);

INSERT INTO gulf_states(state_id, state_name, geom)
VALUES	(1, 'Florida', ST_GeomFromText('POLYGON((-87.6050 30.9988, -86.5613 30.9964, -85.5313 31.0035, -85.1193 31.0012, -85.0012 31.0023, -84.9847 30.9364, -84.9367 30.8845, -84.9271 30.8409, -84.9257 30.7902, -84.9147 30.7489, -84.8611 30.6993, -84.4272 30.6911, -83.5991 30.6509, -82.5595 30.5895, -82.2134 30.5682, -82.2134 30.5315,
			-82.1997 30.3883, -82.1544 30.3598, -82.0638 30.3598, -82.0226 30.4877, -82.0473 30.6308, -82.0514 30.6757, -82.0377 30.7111, -82.0514 30.7371, -82.0102 30.7678, -82.0322 30.7914, -81.9717 30.7997, -81.9608 30.8244, -81.8893 30.8056, -81.8372 30.7914, -81.7960 30.7796, -81.6696 30.7536,
			-81.6051 30.7289, -81.5666 30.7324, -81.5295 30.7229, -81.4856 30.7253, -81.4609 30.7111, -81.4169 30.7088, -81.2274 30.7064, -81.2357 30.4345, -81.1725 30.3160, -81.0379 29.7763, -80.5861 28.8603, -80.3650 28.4771, -80.3815 28.1882, -79.9255 27.1789, -79.8198 26.8425, -79.9118 26.1394,
			-79.9997 25.5115, -80.3815 24.8802, -80.8704 24.5384, -81.9250 24.3959, -82.2066 24.4496, -82.3137 24.5484, -82.1997 24.6982, -81.3977 25.2112, -81.4622 25.6019, -81.9456 25.9235, -82.2876 26.3439, -82.5307 26.9098, -82.8342 27.3315, -83.0182 27.7565, -83.0017 28.0574, -82.8548 28.6098,
			-83.0264 28.9697, -83.2050 29.0478, -83.5318 29.4157, -83.9767 29.9133, -84.1072 29.8930, -84.4409 29.6940, -85.0465 29.4551, -85.3610 29.4946, -85.5807 29.7262, -86.1946 30.1594, -86.8510 30.2175, -87.5171 30.1499, -87.4429 30.3006, -87.3750 30.4256, -87.3743 30.4830, -87.3907 30.5658,
			-87.4004 30.6344, -87.4141 30.6763, -87.5253 30.7702, -87.6256 30.8527, -87.5912 30.9470, -87.5912 30.9682, -87.6050 30.9964, -87.6050 30.9988))', 4269)),
		(2, 'Mississippi', ST_GeomFromText('POLYGON((-90.3049 35.0041, -88.1955 35.0075, -88.0994 34.8882, -88.1241 34.7044, -88.2573 33.6661, -88.4756 31.8939, -88.4180 30.8657, -88.3850 30.1594, -88.8327 30.0905, -89.1870 30.2104, -89.4919 30.1570, -89.5757 30.1796, -89.6457 30.3326, -89.7748 30.5232,
			-89.8531 30.6663, -89.7377 30.9988, -91.6287 30.9988, -91.5601 31.0341, -91.6273 31.1106, -91.5916 31.1658, -91.6589 31.2304, -91.6452 31.2656, -91.5436 31.2609, -91.5271 31.3724, -91.5161 31.4099, -91.5120 31.5071, -91.4502 31.5692, -91.5147 31.6230, -91.3966 31.6253, -91.3513 31.7936,
			-91.2744 31.8589, -91.1673 31.9755, -91.0767 32.0267, -91.0767 32.1198, -91.0437 32.1942, -91.0107 32.2221, -90.9132 32.3150, -91.0313 32.3742, -91.0217 32.4263, -91.0986 32.4634, -91.0080 32.6070, -91.1096 32.5746, -91.1536 32.6394, -91.1426 32.7226, -91.1426 32.7873, -91.1536 32.8519,
			-91.1206 32.8796, -91.2195 32.9257, -91.2085 32.9995, -91.2016 33.0444, -91.2016 33.1192, -91.1041 33.1835, -91.1536 33.3397, -91.1646 33.4223, -91.2291 33.4337, -91.2524 33.5414, -91.1838 33.6135, -91.2524 33.6878, -91.1261 33.6969, -91.1426 33.7883, -91.0437 33.7700, -91.0327 33.8339,
			-91.0657 33.8795, -91.0876 33.9434, -90.9998 33.9889, -90.9229 34.0253, -90.9009 34.0891, -90.9668 34.1345, -90.9119 34.1709, -90.8501 34.1345, -90.9338 34.2277, -90.8267 34.2833, -90.6921 34.3434, -90.6509 34.3774, -90.6152 34.3978, -90.5589 34.4432, -90.5740 34.5179, -90.5823 34.5880,
			-90.5356 34.7506, -90.5136 34.7913, -90.4532 34.8780, -90.3543 34.8476, -90.2911 34.8702, -90.3062 35.0041, -90.3049 35.0041))', 4269)),
		(3, 'Alabama', ST_GeomFromText('POLYGON((-88.1955 35.0041, -85.6068 34.9918, -85.1756 32.8404, -84.8927 32.2593, -85.0342 32.1535, -85.1358 31.7947, -85.0438 31.5200, -85.0836 31.3384, -85.1070 31.2093, -84.9944 31.0023, -87.6009 30.9953, -87.5926 30.9423, -87.6256 30.8539, -87.4072 30.6745, -87.3688 30.4404, -87.5240 30.1463, -88.3864 30.1546, -88.4743 31.8939, -88.1021 34.8938, -88.1721 34.9479, -88.1461 34.9107, -88.1955 35.0041))', 4269)),
		(4, 'Louisiana', ST_GeomFromText('POLYGON((-94.043 33.0225, -93.0048 33.0179, -91.1646 33.0087, -91.2209 32.9269, -91.122 32.8773, -91.1481 32.8358,  -91.1412 32.7642, -91.1536 32.6382, -91.1069 32.5804, -91.008 32.6093,-91.0904 32.4588, -91.0355 32.4379, -91.0286 32.3742, -90.9064 32.315, -90.9723 32.2616, -91.0464 32.1942, -91.0739 32.1198, -91.0464 32.0593, -91.1014 31.9918, -91.1865 31.9498, -91.3101 31.8262, -91.3527 31.7947, -91.3925 31.623, -91.5134 31.6218, -91.431 31.5668, -91.5161 31.513, -91.5244 31.3701, -91.5477 31.2598, -91.6425 31.2692, -91.6603 31.2328, -91.5848 31.1917, -91.6287 31.1047, -91.5614 31.0318, -91.6397 30.9988, -89.7336 31.0012, -89.8517 30.6686, -89.7858 30.5386, -89.6347 30.3148, -89.5688 30.1807, -89.496 30.1582, -89.1843 30.214, -89.0373 30.1463, -88.8354 30.0905, -88.7421 29.8383, -88.8712 29.5758, -88.9371 29.1833, -89.0359 28.9649, -89.2282 28.8832, -89.4754 28.9048, -89.7418 29.121, -90.1126 28.9529, -90.6619 28.912, -91.0355 28.9553, -91.3211 29.121, -91.9061 29.2864, -92.7452 29.43, -93.8177 29.6009, 
			-93.8631 29.6749, -93.8933 29.737, -93.9304 29.793, -93.9276 29.8216, -93.837 29.8883, -93.7985 29.9811, -93.7601 30.0144, -93.7106 30.0691, -93.7354 30.0929, -93.6996 30.1166, -93.7271 30.1997, -93.7106 30.2899, -93.7656 30.335, -93.7601 30.3871, -93.6914 30.4416, -93.7106 30.5102, -93.7463 30.5433, -93.7106 30.5954, -93.6914 30.5906, -93.6859 30.6545, -93.6365 30.6781, -93.62 30.7513, -93.5925 30.789, -93.5513 30.815, -93.5623 30.8645, -93.5788 30.8881, -93.5541 30.9187, -93.5294 30.9423, -93.576 31.0082, -93.5101 31.0318, -93.5596 31.0906, -93.5321 31.1211, -93.5349 31.1799, -93.5953 31.1658, -93.6282 31.2292, -93.6118 31.2668, -93.6859 31.3044, -93.6694 31.3888, -93.7051 31.424, -93.6859 31.4427, -93.7573 31.4755, -93.7189 31.5083, -93.804 31.5411, -93.8425 31.6113, -93.8205 31.6581, -93.7985 31.7071, -93.848 31.8029, -93.9029 31.8892, -93.9606 31.9149, -94.043	32.0081, -94.043 32.7041, -94.043 33.0225))', 4269)),
		(5, 'Texas', ST_GeomFromText('POLYGON((-106.5715  31.8659, -106.5042  31.7504, -106.3092  31.6242, -106.2103  31.4638, -106.0181  31.3912, -105.7874  31.1846, -105.5663  31.0012, -105.4015  30.8456, -105.0032  30.6462, -104.8521  30.3847, -104.7437  30.2591, -104.6915  30.0738, -104.6777  29.9169, -104.5679  29.7644,
			-104.5280  29.6475, -104.4044  29.5603, -104.2067  29.4719, -104.1559  29.3834, -103.9774  29.2948, -103.9128  29.2804, -103.8208  29.2481, -103.5640  29.1378, -103.4692  29.0682, -103.3154  29.0105, -103.1616  28.9601, -103.0957  29.0177, -103.0298  29.1330, -102.8677  29.2157, -102.8979  29.2565, -102.8375  29.3570,
			-102.8004  29.4898, -102.7002  29.6881, -102.5134  29.7691, -102.3843  29.7596, -102.3047  29.8788, -102.1509  29.7834, -101.7004  29.7572, -101.4917  29.7644, -101.2939  29.6308, -101.2582  29.5269, -101.0056  29.3642, -100.9204  29.3056, -100.7707  29.1642, -100.7007  29.0946, -100.6306  28.9012, -100.4974  28.6593,
			-100.3601  28.4675, -100.2969  28.2778, -100.1733  28.1882, -100.0195  28.0526, -99.9344  27.9435, -99.8438  27.7638, -99.7119  27.6641, -99.4812  27.4839, -99.5375  27.3059, -99.4290  27.1948, -99.4455  27.0175, -99.3164  26.8829, -99.2065  26.6867, -99.0967  26.4116, -98.8138  26.3574, -98.6668  26.2257,
			-98.5474  26.2343, -98.3276  26.1357, -98.1697  26.0457, -97.9143  26.0518, -97.6643  26.0050, -97.4020  25.8419, -97.3526  25.9074, -97.0148  25.9679, -97.0697  26.1789, -97.2249  26.8253, -97.0752  27.4230, -96.6096  28.0599, -95.9285  28.4228, -95.3036  28.7568, -94.7296  29.0742, -94.3355  29.3810,
			-93.8205  29.6021, -93.9317  29.8013, -93.8136  29.9157, -93.7230  30.0489, -93.6996  30.1214, -93.7216  30.2021, -93.7038  30.2792, -93.7628  30.3278, -93.7587  30.3835, -93.7010  30.4380, -93.7024  30.5079, -93.7299  30.5362, -93.6694  30.6296, -93.6090  30.7466, -93.5527  30.8114, -93.5747  30.8834,
			-93.5307  30.9376, -93.5074  31.0318, -93.5266  31.0812, -93.5335  31.1787, -93.5980  31.1670, -93.6832  31.3055, -93.6708  31.3830, -93.6887  31.4369, -93.7202  31.5107, -93.8315  31.5820, -93.8123  31.6440, -93.8232  31.7188, -93.8342  31.7936, -93.8782  31.8309, -93.9221  31.8869, -93.9661  31.9335,
			-94.0430  32.0081, -94.0430  33.4681, -94.0430  33.5414, -94.1528  33.5689, -94.1968  33.5872, -94.2627  33.5872, -94.3176  33.5689, -94.3945  33.5597, -94.4275  33.5780, -94.4275  33.6055, -94.4495  33.6421, -94.4879  33.6329, -94.5236  33.6421, -94.6637  33.6695, -94.7461  33.7061, -94.8999  33.7791,
			-95.0757  33.8818, -95.1526  33.9251, -95.2254  33.9604, -95.2858  33.8750, -95.5399  33.8841, -95.7568  33.8887, -95.8420  33.8408, -96.0274  33.8556, -96.3528  33.6901, -96.6179  33.8442, -96.5836  33.8898, -96.6673  33.8955, -96.7538  33.8179, -96.8335  33.8613, -96.8774  33.8613, -96.9159  33.9388,
			-97.0917  33.7392, -97.1645  33.7449, -97.2180  33.8978, -97.3746  33.8225, -97.4611  33.8305, -97.4460  33.8761, -97.6945  33.9798, -97.8648  33.8476, -97.9651  33.8978, -98.0983  34.0299, -98.1752  34.1141, -98.3743  34.1425, -98.4773  34.0640, -98.5529  34.1209, -98.7520  34.1232, -98.9539  34.2095,
			-99.0637  34.2073, -99.1832  34.2141, -99.2505  34.3593, -99.3823  34.4613, -99.4318  34.3774, -99.5718  34.4160, -99.6158  34.3706, -99.8094  34.4726, -99.9934  34.5631, -100.0017  36.4975, -103.0408  36.5008, -103.0655  32.0011, -106.6168  32.0023, -106.5715  31.8659))', 4269))
;
INSERT INTO cities(city_id, city_name, state_name, population, geom)
VALUES	(1, 'Miami', 'Florida', 400000, ST_GeomFromText('POINT(-80.194702 25.775080)', 4269)),
		(2, 'New Orleans', 'Louisiana', 393292, ST_GeomFromText('POINT(-90.071533 29.951065)', 4269)),
		(3, 'Houston', 'Texas', 2313000, ST_GeomFromText('POINT(-95.369507 29.760799)', 4269)),
		(4, 'Pensacola', 'Florida', 52713, ST_GeomFromText('POINT(-87.216911 30.421309)', 4269)),
		(5, 'Mobile', 'Alabama', 195110, ST_GeomFromText('POINT(-88.039894 30.695366)', 4269)),
		(6, 'Biloxi', 'Mississippi', 45968, ST_GeomFromText('POINT(-88.887093 30.392830)', 4269)),
		(7, 'Beaumont', 'Texas', 119114, ST_GeomFromText('POINT(-94.126556 30.080173)', 4269)),
		(8, 'Tampa', 'Florida', 385430, ST_GeomFromText('POINT(-82.457176 27.950575)', 4269)),	
		(9, 'Panama City', 'Florida', 36986, ST_GeomFromText('POINT(-85.660210 30.158813)', 4269)),
		(10, 'New Iberia', 'Louisiana', 30617, ST_GeomFromText('POINT(-91.816980 30.002560 )', 4269))
;

INSERT INTO donations(donation_id, person_donated, amount_donated, year_donated, city_donated_to)
VALUES  (1, 'Steve Irwin', 14000, 2008, 'Houston'),
		(2, 'Jonah Hill', 25000, 2005, 'New Orleans'),
		(3, 'Brad Pitt', 40000, 1992, 'Miami'),
		(4, 'Julia Roberts', 67000, 1998, 'New Orleans'),
		(5, 'Anne Hatheway', 75000, 2004, 'Tampa'),
		(6, 'Margot Robbie', 115000, 2017, 'Houston'),
		(7, 'Leonardo DiCaprio', 26000, 2004, 'Pensacola'),
		(8, 'Matt Damon', 16000, 1998, 'Biloxi'),
		(9, 'Rachel McAdams', 82000, 2017, 'Miami'),
		(10, 'Emily Blunt', 110000, 2019, 'Panama City')
;

INSERT INTO hurricanes(hurricane_id, hurricane_name, month_occured, year_occured,category, monetary_damage, inj_death, geom)
VALUES	(1, 'Andrew', 'August', 1992, 5, 27.3, 65, ST_GeomFromText('LINESTRING(-64.9 24.8, -65.9 25.3, -67 25.6, -68.3 25.8, -69.7 25.7, -71.1 25.6, -72.5 25.5, -74.2 25.4, -75.8 25.4, -76.6 25.4, -77.5 25.4, -77.8 25.4, -79.3 25.4, -80.3 25.5, -81.2 25.6, -83.1 25.8, -85 26.2, -86.7 26.6, -84 27.2, -84 27.8, -84 28.5, -84 29.2, -84 29.6, -84 30.1, -84 30.9, -84 31.5, -84 32.1, -84 32.8, -84 33.6, -84 34.4, -84 35.4)', 4269)),
		(2, 'Katrina', 'August', 2005, 3, 125, 1245, ST_GeomFromText('LINESTRING(-82.9 24.8, -83.3 24.7, -83.6 24.6, -84 24.4, -84.4 24.4, -84.6 24.4, -85 24.5, -85.4 24.5, -85.6 24.6, -85.9 24.8, -86.2 25, -86.8 25.1, -87.4 25.4, -87.7 25.7, -88.1 26, -88.6 26.5, -89 26.9, -89.1 27.2, -89.4 27.6, -89.5 27.9, -89.6 28.2, -89.6 28.8, -89.6 29.1, -89.6 29.7, -89.6 30.2, -89.6 30.8, -89.6 31.4, -89.6 31.9, -88.9 32.9, -88.5 33.5, -88.4 34.7, -87.5 36.3)',4269)),
		(3, 'Harvey', 'August', 2017, 3, 125, 68, ST_GeomFromText('LINESTRING(-92.6 22, -92.6 22.6, -92.8 23.2, -93 23.8, -93.3 24, -93.6 24.4, -93.9 24.7, -94.3 25, -94.6 25.2, -95.1 25.6, -95.4 25.9, -95.8 26.3, -96 26.7, -96.3 27.1, -96.4 27.2, -96.5 27.5, -96.7 27.7, -96.8 27.8, -97 28, -97 28.2, -97.2 28.5, -97.2 28.7, -97.3 28.9, -97.6 29.1, -97.6 29.1, -97.4 29.2, -97.3 29.3, -97.4 29.3, -97.7 29.2, -97.4 29, -97.2 29, -97 29, -96.8 28.9, -96.6 28.8, -96.4 28.7, -96.1 28.6, -96 28.5, -95.7 28.5, -95.5 28.2, -95.3 28.2, -95 28, -94.8 28.1, -94.3 28.4, -94.3 29.2, -93.9 28.7, -93.6 29, -93.4 29.8, -93.6 30.2, 
            -92.6 31.2, -92.3 31.7)', 4269)),
		(4, 'Irma', 'September', 2017, 4, 7.7, 92, ST_GeomFromText('LINESTRING(-60.5 17.2, -61.1 17.4, -61.8 17.7, -62.6 17.9, -63.3 18.1, -64 18.2, -64.7 18.5, -65.4 18.8, -66.1 19.1, -66.8 19.4, -67.7 19.7, -68.3 20, -69 20.1, -69.7 20.4, -70.4 20.7, -71.1 20.9, -71.8 21.1, -72.4 21.3, -73.3 21.5, -73.8 21.7, -74.7 21.8, -75.3 22, -76 22, -76.5 22.1, -77.2 22.2, -77.7 22.1, -78.2 22.3, -78.8 22.5, -79.6 22.6, -79.8 22.8, -80.2 23.1, -80.5 23.4, -80.8 23.3, -81 23.5, -81.3 23.7, -81.5 24.1, -81.5 24.5, -81.5 25, -81.8 25.6, -81.8 26.2, -81.7 26.7, -81.9 27.5, -82.2 28.2, -82.6 28.9, -82.9 29.5, -83.1 30.3, -83.6 30.8, -84 31.5,
			-84.4 31.9, -84.9 32.4)', 4269)),
		(5, 'Ivan', 'September', 2004, 3, 25, 92, ST_GeomFromText('LINESTRING(-67 13.1, -67.7 13.4, -68.4 13.4, -69.1 13.6, -69.5 13.7, -70 13.9, -70.7 14.2, -71.4 14.5, -72 14.8, -72.5 15, -72.8 15.2, -73.3 15.5, -73.8 15.7, -74.2 15.9, -74.7 16.3, -75.1 16.5, -75.8 16.8, -76.2 17, -76.2 17, -76.9 17.5, -77.3 17.4, -78 17.5, -78.4 17.7, -78.7 17.9, -79 18, -79.3 18.2, -79.7 18.2, -80 18.3, -80.4 18.4, -80.8 18.6, -81.2 18.8, -81.2 18.8, -81.5 19, -82.1 19.2, -82.5 19.3, -82.8 19.5, -83.2 19.7, -83.5 19.9, -83.9 20.2, -84.1 20.4, -84.4 20.6, -84.7 20.9, -84.9 21.3, -85.1 21.6, -85.4 22, -85.6 22.4, -86 22.6, -86.1 23.1, -86.2 23.4, -86.5 23.7, -86.6 24.2, -87 24.7, -87.2 25.1, -87.4 25.6, -87.8 26.1, -87.9 26.7, -88 27.3, -88.2 27.8, -88.3 28.4, -88.2 28.8, -88.2 29, -88.1 29.3, -87.8 30.2, -87.7 30.9, -87.7 31.6, -87.5 32, -87.1 32.6, -87.1 32.6, -87 33.1, -86.2 34.3, -89.3 26.9, -90 27.4, -90.8 27, -91.6 28.2, -92.1 28.9, -92.7 29.2, -92.8 29.3, -93 29.4, -93.3 29.7, -93.5 29.8, -94.4 30.2)', 4269)),
		(6, 'Georges', 'September', 1998, 2, 13.9, 604, ST_GeomFromText('LINESTRING(-50.6 14.4, -52 14.9, -53.5 15.4, -54.9 15.7, -56.3 16, -57.7 16.2, -59.2 16.4, -60.6 16.7, -62.1 17.1, -63.6 17.4, -65 17.8, -66.3 18.2, -67.4 18, -68.5 18.2, -69.7 18.6, -70.8 18.8, -72.1 19, -73.3 19.3, -74.3 19.8, -74.9 20.5, -76 20.8, -77.2 21.3, -78 21.9, -79 22.7, -80.2 23.4, -81.3 23.9, -82.4 24.6, -83.3 24.8, -84.2 25.2, -85.1 25.7, -85.9 26.2, -86.5 27, -87.2 27.6, -87.8 28.2, -88.3 28.8, -88.5 29.3, -88.7 29.8, -88.9 30.4, -88.9 30.6, -89 30.6, -88.4 30.6, -88.1 31, -87.5 30.9, -86.9 30.8, -86.3 30.7, -85.4 30.7, -84.2 30.6, -83 30.5, -81.8 30.5)', 4269)),
		(7, 'Rita', 'September', 2005, 2, 18.5, 125, ST_GeomFromText('LINESTRING(-72.7 22.2, -72.9 22.7, -73.3 22.9, -73.7 23, -74.3 22.7, -74.6 22.8, -75.2 23, -75.9 23.1, -76.5 23.3, -77 23.1, -77.8 23.3, -78.8 23.6, -79.5 23.7, -80.4 23.8, -81 23.8, -81.7 23.9, -82.2 24, -82.6 24, -83.2 24.1, -84 24.2, -84.6 24.3, -85.3 24.4, -85.9 24.3, -86.8 24.4, -86.8 24.5, -87.2 24.6, -87.6 24.8, -88 24.9, -88.3 25.2, -88.7 25.4, -89.2 25.5, -89.5 25.8, -89.9 26, -90.3 26.2, -90.6 26.4, -91 26.8, -91.5 27.1, -91.9 27.4, -92.2 27.8, -92.6 28.2, -92.9 28.5, -93 28.7, -93.2 29.1, -93.7 29.6, -93.9 29.9, -94.2 30.4, -94.3 31, -94.2 31.6, -94 32.1, -94 32.5, -93.9 33)', 4269)),
		(8, 'Charley', 'August', 2004, 4, 16.9, 20, ST_GeomFromText('LINESTRING(-66.3 13, -68.3 13.7, -69.7 14.5, -70.8 15.2, -71.8 15.7, -72.8 16, -73.8 16.4, -74.7 16.9, -75.4 16.9, -76.1 16.5, -76.8 16.6, -77.5 17, -78.2 17.2, -78.7 17.8, -79.2 18, -79.9 18.6, -80.5 19.2, -81.2 19.7, -81.5 20.4, -81.9 21.2, -82.3 21.7, -82.4 22.2, -82.6 23, -82.9 23.9, -82.9 24.3, -82.9 24.7, -82.8 25.2, -82.5 25.7, -82.4 26, -82.2 26.9, -81.8 27.7, -81.4 28.4, -81.1 29.1, -80.8 30.1, -80.5 31.2, -79.7 32.3, -79 33.2, -77.9 34.8, -77 36, -75.9 36.9, -74.9 37.9, -73.8 39.2, -73 40.8, -71 42, -69 43)', 4269)),
		(9, 'Michael', 'October', 2018, 5, 25.1, 43, ST_GeomFromText('LINESTRING(-86.9 19.2, -85.5 19.2, -85.4 19.9, -85.4 20, -85.5 20.1, -85.5 20.6, -85.1 20.9, -84.9 21.2, -85.1 21.7, -85.2 22.2, -85.2 22.7, -85.3 23.2, -85.7 23.6, -85.9 24.1, -86.1 24.5, -86.2 25, -86.4 25.4, -86.4 26, -86.5 26.6, -86.5 27.1, -86.6 27.7, -86.5 28.3, -86.3 29, -86 29.4, -85.5 30, -85.1 30.9, -84.5 31.5, -83.8 32.1, -83.2 32.7, -82.5 33.5, -81.8 34.1, -80.8 34.7, -80 35.7, -78.8 36.1, -77.8 36.5, -76.1 37.1, -75.1 37.3)', 4269)),
		(10,'Ike', 'September', 2008, 2, 38, 113, ST_GeomFromText('LINESTRING(-52.7 21.6, -53.2 21.7, -54.1 22.1, -55.8 22.7, -57 23.2, -58.2 23.6, -59.5 23.6, -61 23.7, -62.7 23.2, -64.1 22.9, -64.7 22.8, -65.6 22.6, -66.1 22.5, -67.1 22.4, -67.9 22, -68.8 21.9, -69.1 21.6, -69.7 21.4, -70.2 21.3, -70.9 21.2, -71.4 21.3, -72.2 21.1, -72.8 21, -73.4 21, -74 20.9, -74.6 21.1, -75.2 21.1, -75.8 21.1, -76.6 21.2, -77.3 21.2, -77.9 21.1, -78.5 21.1, -79.1 21.2, -79.7 21.4, -80.2 21.7, -80.8 21.8, -81.5 21.9, -82.1 22, -82.4 22.4, -83 22.6, -83.4 22.7, -83.8 22.9, -84 23.1, -84.3 23.2, -84.6 23.3, -84.9 23.5, -85.3 23.9, -85.3 23.9, -85.8 24.2, -86.1 24.5, -86.3 24.7, -86.7 24.9, -87.2 25, -87.6 25.2, -88 25.3, -88.4 25.5, -88.8 25.8, -89.4 26, -89.9 26.2, -90.4 26.3, -91.1 26.4, -91.6 26.7, -92.2 26.9, -92.6 27.2, -93.1 27.4, -93.5 27.7, -93.8 28.2, -94.3 28.4, -94.4 28.6, -94.5 28.9, -94.7 29.2, -95 29.7, -95.1 30.1, -95.3 30.5, -95.3 31, -95.4 31.6, -95.4 31.6, -95.3 32.4, -94.8 33.3, -93.9 34.3, -93.9 35.4, -92.5 36.4)', 4269))
;

INSERT INTO city_hurricanes(hurricane_id, city_id)
VALUES	(1, 1),
		(1, 4),
		(2, 2),
		(2, 6),
		(2, 5),
		(3, 3),
		(3, 10),
		(4, 5),
		(4, 9),
		(5, 5),
		(6, 6),
		(7, 7),
		(8, 4),
		(8, 8),
		(9, 9),
		(9, 5),
		(10,7)
		
;

INSERT INTO meteorologists(met_id, first_name, last_name, gender)
VALUES	(1, 'Rob', 'Navarro', 'M'),
		(2, 'Michael', 'Herrera','M'),
		(3, 'Aaron', 'Pina','M'),
		(4, 'Hannah', 'Kight', 'F'),
		(5, 'Samantha', 'Willis', 'F'),
		(6, 'Kaylen', 'Calvert', 'F'),
		(7, 'Colin', 'Perry', 'M'),
		(8, 'Stephanie', 'Stevenson', 'F'),
		(9, 'Heidi', 'Klum', 'F'),
		(10, 'Rob', 'Korty', 'M')
;

INSERT INTO hurricane_forecast(met_id, hur_forecasted, accuracy)
VALUES	(1, 3, .56),
		(1, 7, .78),
		(1, 10, .32),
		(2, 2, .45),
		(2, 7, .67),
		(3, 5, .89),
		(4, 2, .12),
		(4, 6, .45),
		(4, 5, .23),
		(5, 1, .63),
		(5, 4, .73),
		(6, 6, .95),
		(7, 5, .21),
		(7, 9, .80),
		(8, 4, .51),
		(8, 8, .71),
		(9, 9, .32),
		(9, 5, .59),
		(10, 1, .88),
		(10, 2, .85)
;

--Non-Spatial Queries
--1.) Which city had the most money donated to it and how much was the total.
select sum(amount_donated), city_donated_to
from donations
join cities on donations.city_donated_to = cities.city_name
group by city_donated_to
order by sum(amount_donated) desc
limit 1;
--Houston 129,000

--2.) What was the average accuracy for female forecasters
select avg(hf.accuracy) as accuracy
from hurricane_forecast as hf
join meteorologists on meteorologists.met_id = hf.met_id
where gender = 'F'
;
--52.4%

--3.) Who are the 3 leasr accurate hurricane forecasters
select avg(accuracy) as accuracy, first_name
from hurricane_forecast as hf
join meteorologists on meteorologists.met_id = hf.met_id
group by first_name
order by avg(accuracy) asc
limit 3 
;
-- Hannah 26.67% HEidi 45.5% Colin 50.5%

--4.) Which state has the most cities effected by hurricanes
select count(distinct city_name) as n_cities, state_name
from cities
group by state_name
order by n_cities desc
limit 1;
--Florida with 4

--5.)Which city has been effected by the most hurricanes
select count(hurricane_id) as n_hurricanes, city_name
from city_hurricanes
join cities on city_hurricanes.city_id = cities.city_id
group by city_name
order by n_hurricanes desc
limit 1;
--Mobile, AL

--6.) How much money in donations went to the state of florida
select sum(amount_donated)
from donations
join cities on cities.city_name = donations.city_donated_to
where state_name = 'Florida';
--333,000 dollarshu

--7.)  How much population was effected by storms forecasted by Rob Navarro
select sum(population)
from cities
join city_hurricanes on city_hurricanes.city_id=cities.city_id
join hurricane_forecast on hurricane_forecast.hur_forecasted = city_hurricanes.hurricane_id
where met_id = 1;
-- 2,581,845

--Spatial Queries
--1.) Which two hurricanes intersected with Mississippi
select h.geom, h.hurricane_name
from hurricanes as h, gulf_states as gs
where ST_Intersects(gs.geom, h.geom)
and gs.state_name = 'Mississippi'
;
-- Georges and Katrina

--2.) Amount of damage done (in billions) by Hurricanes hitting Texas
select sum(h.monetary_damage)
from hurricanes as h, gulf_states as gs
where ST_Intersects(gs.geom, h.geom)
and gs.state_name = 'Texas'
;
--206.5 billion dollars

--3.) Which category hurricane had the highest death toll in florida
select h.category, sum(h.inj_death)
from hurricanes as h, gulf_states as gs
where ST_Intersects(gs.geom, h.geom)
and gs.state_name = 'Florida'
group by h.category
order by sum(h.inj_death) desc
;
-- Category 2 hurricanes caused 604 deaths in Florida

--4.) List the states in order of how many hurricanes have hit them
select count(gs.state_name), gs.state_name
from hurricanes as h, gulf_states as gs
where ST_Intersects(gs.geom, h.geom)
group by gs.state_name 
order by count(gs.state_name) desc
;

--5). WHich state has the highest monetary damage due to hurricanes
select sum(h.monetary_damage), gs.state_name
from hurricanes as h, gulf_states as gs
where ST_Intersects(gs.geom, h.geom)
group by gs.state_name
order by sum(h.monetary_damage) desc
limit 1
;
--Louisiana 293.5 billion (Katrina was a bad time)

--6). Which state had the highest population of people effected by non category 5 hurricanes
select sum(distinct c.population), gs.state_name --dont double count the pop for multiple hurricanes
from hurricanes as h, gulf_states as gs, cities as c
where ST_Contains(gs.geom, c.geom)
and ST_Intersects(gs.geom, h.geom)
and h.category !=5
group by gs.state_name
order by sum(c.population) desc-- you can flip this and sort by asc to find out the least people effected
limit 2-- See the top two
;
-- Texas had 2,432,114 people effected by hurricanes 2nd was florida with 875,129
-- Mississippi had the least at 45968

-- same query but only looking at category 5 hurricanes
select sum(distinct c.population), gs.state_name --dont double count the pop for multiple hurricanes
from hurricanes as h, gulf_states as gs, cities as c
where ST_Contains(gs.geom, c.geom)
and ST_Intersects(gs.geom, h.geom)
and h.category =5
group by gs.state_name
order by sum(c.population) desc-- you can flip this and sort by asc to find out the least people effected
limit 2-- See the top two
;
-- Florida and Alabama are the only ones affected thanks to Andrew.	