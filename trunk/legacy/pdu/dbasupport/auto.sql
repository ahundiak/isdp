create table manufacturer
	(
	mfr_name		char(20),
	address			char(20),
	city			char(15),
	state			char(2),
	zipcode			char(5),
	phone			char(18),
	mslink			integer not null
	);

create table parts
	(
	part_num		char(10),
	part_name		char(25),
	mfr_name		char(20),
	description1            char(40),
	description2            char(40),
	price			double,
	stock_units		smallint,
	su_container	        char(10),
	price_su		double,
	num_su			smallint,
	shelf_quantity		smallint,
	quantity_required	smallint,
	wholesale_su		double,
	mslink			integer not null
	);

create table sale
	(
	part_num		char(10),
	saleprice		double,
	saleprice_su		double,
	mslink			integer not null
	);

create table mscodelist
	(
	table_name		char(32),
	column_name		char(32),
	join_table		char(32),
	code_column		char(32),
	text_column		char(32),
	index_column		char(32),
	index_value		integer,
	mslink			integer not null
	);

create table mscatalog
	(
	tablename		char(32),
	entitynum		integer,
	screenform		char(64),
	reporttable		char(64),
	sqlreview		char(240),
	fencefilter		char(240),
	key_columns		char(50),
	nextocc			integer,
	mslink			integer not null
	);


INSERT INTO mscatalog VALUES
   ('manufacturer', 1, ' ', ' ', ' ', ' ', ' ', 10, 1);

INSERT INTO mscatalog VALUES
   ('parts', 2, ' ', ' ', ' ', ' ', ' ', 50, 2);

INSERT INTO mscatalog VALUES
   ('sale', 3, ' ', ' ', ' ', ' ', ' ', 10, 3);

INSERT INTO manufacturer VALUES
 ('GoodTire', '213 Everett St', 'Akron', 'OH', '44316', '216-794-8075', 1);

INSERT INTO manufacturer VALUES
 ('PureOil', '3420 Brunswick Rd', 'Piscataway', 'NJ', '08854', '201-885-1289', 
2);

INSERT INTO manufacturer VALUES
 ('Penn Oil', '446 Penn Pl', 'Houston', 'TX', '77252', '713-236-1289', 3);

INSERT INTO manufacturer VALUES
 ('Snap-EZ Tools', '2600 80th St', 'Kenosha', 'WI', '53140', '414-654-4543', 4);

INSERT INTO manufacturer VALUES
 ('Armstrong Tires', '397 Sargent Dr', 'New Haven', 'CT', '06507',
'203-562-1100', 5);

INSERT INTO manufacturer VALUES
 ('GEC Electronics', '1899 Easton Ave', 'Stamford', 'CT', '06904', 
'203-965-3249', 6);

INSERT INTO manufacturer VALUES
 ('Electro-Lite Battery', '401 East 40th St', 'Chattanooga', 'TN', '37401', 
'615-866-8789', 7);

INSERT INTO manufacturer VALUES
 ('Envirochem Corp.', '2030 Jordan Center', 'Midland', 'MI', '48640', 
'517-637-9876', 8);

INSERT INTO manufacturer VALUES
 ('IB Industries', 'One Madison Center', 'Chicago', 'IL', '60601', 
'312-565-8729', 9);


INSERT INTO parts VALUES
 ('GT175/13', 'Talon GT Radial', 'GoodTire', '175/70HR13 All-Weather Radial', 
' ', 44.00, 4, 'per set', 168.00, 4, 1, 20, 110.00, 1);

INSERT INTO parts VALUES
 ('GT185/13', 'Talon GT Radial', 'GoodTire', '185/70HR13 All-Weather Radial', 
' ', 50.00, 4, 'per set', 189.00, 5, 1, 20, 120.00, 2);

INSERT INTO parts VALUES
 ('GT195/14', 'Talon GT Radial', 'GoodTire', '195/60HR14 All-Weather Radial', 
' ', 56.00, 4, 'per set', 220.00, 3, 1, 20, 150.00, 3);

INSERT INTO parts VALUES
 ('ST205/15', 'Talon ST Radial', 'GoodTire', '205/60HR15 Performance Radial', 
' ', 86.00, 4, 'per set', 330.00, 2, 1, 20, 240.00, 4);

INSERT INTO parts VALUES
 ('ST235/15', 'Talon ST Radial', 'GoodTire', '235/70HR15 Performance Radial', 
' ', 86.00, 4, 'per set', 330.00, 2, 1, 20, 240.00, 5);

INSERT INTO parts VALUES
 ('Z195/15', 'Daytona Zero', 'Armstrong Tires', '195/50ZR15 High-Performance', 
' ', 112.00, 4, 'per set', 435.00, 4, 1, 20, 340.00, 6);

INSERT INTO parts VALUES
 ('Z205/15', 'Daytona Zero', 'Armstrong Tires', '205/50ZR15 High-Performance', 
' ', 132.00, 4, 'per set', 505.00, 3, 1, 20, 380.00, 7);

INSERT INTO parts VALUES
 ('Z235/16', 'Daytona Zero', 'Armstrong Tires', '235/50ZR16 High-Performance', 
' ', 160.00, 4, 'per set', 614.00, 3, 1, 20, 480.00, 8);

INSERT INTO parts VALUES
 ('PO-1030', 'Turbo Motor Oil', 'PureOil', '10W-30 High-Detergent', 
' ', 1.120000, 12, 'per case', 12.890000, 12, 18, 200, 7.990000, 9);

INSERT INTO parts VALUES
 ('PO-1040', 'Turbo Motor Oil', 'PureOil', '10W-40 High-Detergent', 
' ', 1.120000, 12, 'per case', 12.890000, 15, 11, 200, 7.990000, 10);

INSERT INTO parts VALUES
 ('PO-2050', 'Turbo Motor Oil', 'PureOil', '20W-50 High-Detergent', 
' ', 1.220000, 12, 'per case', 13.890000, 13, 14, 200, 8.490000, 11);

INSERT INTO parts VALUES
 ('PO113', 'Quality Oil Filter', 'PureOil', 'Ford 2.3l 78-82, Ford 3.0l 76-84', 
'Merc 2.3l 78-82, Merc 3.0l 76-84', 2.790000, 12, 'per box', 32.790000, 0, 12, 
24, 22.190000, 12);

INSERT INTO parts VALUES
 ('PO124', 'Quality Oil Filter', 'PureOil', 'Ford 5.0l 77-89, Ford 289 64-71', 
'Merc 5.0l 77-89', 2.790000, 12, 'per box', 32.790000, 12, 3, 24, 22.190000, 
13);

INSERT INTO parts VALUES
 ('POF100', 'Quality-F Oil Filter', 'PureOil', 'VW 1.7l 75-81, VW 1.8l 82-89', 
'Audi 1.7l 75-81, Audi 1.8l 82-89', 3.290000, 12, 'per box', 38.790000, 
14, 8, 24, 23.290000, 14);

INSERT INTO parts VALUES
 ('POF200', 'Quality-F Oil Filter', 'PureOil', 'MB 3.0l 81-89, MB 5.6l 77-89', 
' ', 4.290000, 12, 'per box', 50.190000, 19, 8, 24, 25.190000, 15);

INSERT INTO parts VALUES
 ('Penn-1030', 'Penn Motor Oil', 'Penn Oil', '10W-30 High-Detergent', 
' ', 1.020000, 12, 'per case', 11.890000, 11, 11, 200, 6.490000, 16);

INSERT INTO parts VALUES
 ('Penn-1040', 'Penn Motor Oil', 'Penn Oil', '10W-40 High-Detergent', 
' ', 1.020000, 12, 'per case', 11.890000, 12, 21, 200, 6.490000, 17);

INSERT INTO parts VALUES
 ('Penn-2050', 'Penn Motor Oil', 'Penn Oil', '20W-50 High-Detergent', 
' ', 1.120000, 12, 'per case', 12.890000, 14, 18, 200, 6.690000, 18);

INSERT INTO parts VALUES
 ('PH20', 'Penn Oil Filter', 'Penn Oil', 'Honda 2.0l 82-89', 
'Mitsu 2.0l 87-89', 2.590000, 12, 'per box', 30.790000, 20, 21, 24, 
21.190000, 19);

INSERT INTO parts VALUES
 ('PH16', 'Penn Oil Filter', 'Penn Oil', 'Honda 1.5l 74-89, Honda 1.6l 82-89', 
'Mitsu 1.6l 82-89', 2.490000, 12, 'per box', 28.880000, 20, 14, 24, 
21.190000, 20);

INSERT INTO parts VALUES
 ('PH300', 'Penn Oil Filter', 'Penn Oil', 'Nissan 3.0l 85-89', 
'Acura 3.0l 86-89', 3.290000, 12, 'per box', 38.790000, 7, 5, 24, 
22.290000, 21);

INSERT INTO parts VALUES
 ('SCK1000', 'Socket Set', 'Snap-EZ Tools', '72-piece metric
 w/ spark plug wrench', ' ', 33.290000, 1, 'per box', 33.290000, 3, 1, 3, 
25.990000, 22);

INSERT INTO parts VALUES
 ('SCK2000', 'Socket Set', 'Snap-EZ Tools', '72-piece english
 w/ spark plug wrench', ' ', 33.290000, 1, 'per box', 33.290000, 2, 2, 3, 
25.990000, 23);

INSERT INTO parts VALUES
 ('WR38', 'Oil Filter Wrench', 'Snap-EZ Tools', 'late model Toyota and VW', 
' ', 3.290000, 12, 'per box', 38.290000, 3, 3, 10, 21.440000, 24);

INSERT INTO parts VALUES
 ('R200', 'Car Ramps', 'Snap-EZ Tools', '3-ton capacity, 2 ramps included', 
' ', 33.290000, 1, 'per box', 33.290000, 3, 1, 2, 19.840000, 25);

INSERT INTO parts VALUES
 ('J28', 'Hydraulic Jack', 'Snap-EZ Tools', '2-ton capacity', 
' ', 21.190000, 6, 'per box', 124.990000, 4, 2, 10, 67.840000, 26);

INSERT INTO parts VALUES
 ('3228-001', 'Fuse Set', 'GEC Electronics', '10 amp (2), 15 amp (2), 
20 amp (2)', '30 amp (4)', 3.190000, 100, 'per box', 319.00, 3, 10, 200, 
199.00, 27);

INSERT INTO parts VALUES
 ('3228-002', 'Fuse Set', 'GEC Electronics', '5 amp (2), 10 amp (2), 
15 amp (2)', '20 amp (2), 30 amp (2)', 3.190000, 100, 'per box', 319.00, 
3, 8, 200, 199.00, 28);

INSERT INTO parts VALUES
 ('3238-100', 'Spark Plug Wires', 'GEC Electronics', 'Ford 2.3l All', 
' ', 10.190000, 10, 'per box', 101.900000, 1, 2, 20, 59.900000, 29);

INSERT INTO parts VALUES
 ('3238-200', 'Spark Plug Wires', 'GEC Electronics', 'Ford 5.0l All', 
' ', 18.190000, 5, 'per box', 90.950000, 5, 3, 20, 49.900000, 30);

INSERT INTO parts VALUES
 ('3338-400', 'Spark Plug Wires', 'GEC Electronics', 'GM 2.5l All', 
' ', 10.190000, 10, 'per box', 101.900000, 1, 2, 20, 59.900000, 31);

INSERT INTO parts VALUES
 ('3238-800', 'Spark Plug Wires', 'GEC Electronics', 'GM 5.7l All', 
' ', 18.190000, 5, 'per box', 90.950000, 5, 4, 20, 49.900000, 32);

INSERT INTO parts VALUES
 ('ST-100', 'AM/FM Cassette Radio', 'GEC Electronics', '25 watts per channel', 
'Dolby, Auto Reverse', 188.190000, 1, 'per box', 188.190000, 8, 1, 4, 
129.990000, 33);

INSERT INTO parts VALUES
 ('AM-60', 'Stereo Amplifier', 'GEC Electronics', '60 watts per channel', 
' ', 100.190000, 1, 'per box', 100.190000, 1, 1, 4, 69.990000, 34);

INSERT INTO parts VALUES
 ('KR-600', 'Stereo Speakers', 'GEC Electronics', '6 x 9 triaxial (2)', 
'60 watts max', 89.190000, 1, 'per box', 89.190000, 8, 1, 6, 49.990000, 35);

INSERT INTO parts VALUES
 ('332-A-300', 'Auto Battery', 'Electro-Lite Battery', '300 amps', 
' ', 39.190000, 1, 'per box', 39.190000, 3, 1, 6, 24.980000, 36);

INSERT INTO parts VALUES
 ('332-A-400', 'Auto Battery', 'Electro-Lite Battery', '400 amps', 
' ', 49.190000, 1, 'per box', 49.190000, 3, 1, 8, 31.980000, 37);

INSERT INTO parts VALUES
 ('42APH', 'Liquid Car Wash', 'Envirochem Corp.', 'Recommended for clear coat', 
' ', 4.190000, 12, 'per box', 50.280000, 2, 3, 40, 28.280000, 38);

INSERT INTO parts VALUES
 ('52APH', 'Car Wax', 'Envirochem Corp.', 'Recommended for clear coat', 
'Paste wax', 4.190000, 12, 'per box', 50.280000, 2, 5, 40, 28.280000, 39);

INSERT INTO parts VALUES
 ('54APH', 'Car Wax', 'Envirochem Corp.', 'Recommended for clear coat', 
'Gel wax', 4.190000, 12, 'per box', 50.280000, 2, 1, 40, 28.280000, 40);

INSERT INTO parts VALUES
 ('62APH', 'Upholstery Cleaner', 'Envirochem Corp.', 'For vinyl, cloth, 
and velour', ' ', 3.990000, 12, 'per box', 47.880000, 4, 6, 20, 26.290000, 41);

INSERT INTO parts VALUES
 ('72APH', 'Tire Cleaner', 'Envirochem Corp.', 'Rubber lubricant and sealer', 
' ', 3.990000, 12, 'per box', 47.880000, 1, 3, 30, 26.290000, 42);

INSERT INTO parts VALUES
 ('82APH', 'Protect-All Cleaner', 'Envirochem Corp.', 'Lubricant and sealer', 
'Prevents cracking and fading', 3.990000, 12, 'per box', 47.880000, 3, 6, 50, 
26.290000, 43);

INSERT INTO parts VALUES
 ('327-TR', 'Valve Covers', 'IB Industries', 'Chevrolet 327', 
'Chrome finish (2)', 23.990000, 2, 'per box', 47.980000, 4, 1, 4, 31.990000, 
44);

INSERT INTO parts VALUES
 ('350-TR', 'Valve Covers', 'IB Industries', 'Chevrolet 350', 
'Chrome finish (2)', 25.990000, 2, 'per box', 51.980000, 5, 1, 4, 32.990000, 
45);

INSERT INTO parts VALUES
 ('327-WP', 'Water Pump', 'IB Industries', 'Chevrolet 327', 
'Price includes exchange', 35.990000, 1, 'per box', 35.990000, 3, 0, 4, 
19.990000, 46);

INSERT INTO parts VALUES
 ('350-WP', 'Water Pump', 'IB Industries', 'Chevrolet 350', 
'Price includes exchange', 37.990000, 1, 'per box', 37.990000, 7, 0, 4, 
20.490000, 47);

INSERT INTO parts VALUES
 ('50-MC', 'Master Cylinder', 'IB Industries', 'Ford 5.0l (all)', 
'Price includes exchange', 23.990000, 1, 'per box', 23.990000, 3, 0, 4, 
11.990000, 48);

INSERT INTO parts VALUES
 ('200-MC', 'Master Cylinder', 'IB Industries', 'Ford 200 (all)', 
'Price includes exchange', 21.990000, 1, 'per box', 21.990000, 2, 0, 4, 
11.990000, 49);


INSERT INTO sale VALUES
 ('Z195/15', 100.00, 390.00, 1);

INSERT INTO sale VALUES
 ('Z235/16', 140.00, 540.00, 2);

INSERT INTO sale VALUES
 ('332-A-400', 39.190000, 39.190000, 3);

INSERT INTO sale VALUES
 ('KR-600', 74.990000, 74.990000, 4);

INSERT INTO sale VALUES
 ('ST-100', 159.990000, 159.990000, 5);

INSERT INTO sale VALUES
 ('AM-60', 88.990000, 88.990000, 6);

INSERT INTO sale VALUES
 ('42APH', 3.990000, 47.880000, 7);

INSERT INTO sale VALUES
 ('62APH', 3.790000, 45.480000, 8);

INSERT INTO sale VALUES
 ('72APH', 3.790000, 45.480000, 9);


create unique index m_nam_ix on manufacturer (mfr_name);
create unique index mslink_1 on manufacturer (mslink);
create index zip_ix on manufacturer (zipcode);
create unique index p_num_ix on parts (part_num);
create unique index mslink_2 on parts (mslink);
create index p_s_num_ix on sale (part_num);
create unique index mslink_3 on sale (mslink);
create index num_nam_ix on parts (part_num, part_name);

grant all on manufacturer to public;
grant all on parts to public;
grant all on sale to public;
grant all on mscodelist to public;
grant all on mscatalog to public;

create unique index mslink_4 on mscodelist (mslink);
create unique index mslink_5 on mscatalog (mslink);
