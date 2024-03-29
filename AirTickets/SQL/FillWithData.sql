INSERT INTO Producers VALUES ('Boeing'),
('Airbus'),
('Sukhoi');

INSERT INTO Models(Producer, Name) VALUES('Boeing', '777X'),
('Boeing', '747SP'),
('Airbus', 'A220'),
('Airbus', 'A330'),
('Sukhoi', 'Superjet 100');

INSERT INTO Planes VALUES ('RA-7045', 'Boeing 777X'),
('RA-7046', 'Boeing 777X'),
('RA-8943', 'Sukhoi Superjet 100'),
('RA-6532', 'Airbus A220'),
('RA-7891', 'Boeing 777X'),
('RA-7131', 'Boeing 747SP'),
('RA-8231', 'Sukhoi Superjet 100'),
('RA-6522', 'Airbus A330');

INSERT INTO Customers VALUES ('0', 'Constantine', 'Palaiologos', NULL),
('1', 'Mehmed', 'Ottoman', NUll),
('2', 'Kemal', 'Ataturk', NUll),
('3', 'Ivan', 'Rurikovich', 'Vasilevich'),
('4', 'Pyotr', 'Romanov', 'Alexeevich'),
('5', 'Patrice', 'Lumumba', NUll),
('6', 'Paul', 'Kagame', NUll),	
('7', 'Miguel', 'Cervantes', NUll),
('8', 'Oliver', 'Cromwell', NUll),
('9', 'Friedrich', 'Hohenzollern', NUll),
('10', 'Mykhailo', 'Hrushevsky', 'Serhiiovych'),
('11', 'Casimir', 'Piast', NUll),
('12', 'Douglas', 'MacArthur', NULL),
('13', 'Alexei', 'Ermolov', 'Petrovich'),
('14', 'Juan', 'Peron', NUll),
('15', 'Ulysses', 'Grant', NULL),
('16', 'Joseph', 'Fouche', NULL),
('17', ' Georges Jacques', 'Danton', NUll),
('18', 'Jean-Paul', 'Marat', NUll),
('19', 'Oswald', 'Mosley', NUll),
('20', 'Philippe', 'Petain', NUll),
('21', 'Ruhollah','Khomeini', NUll);

INSERT INTO Places(Name) VALUES ('Saint-Petersburg'),
('Voronezh'),
('Munich'),
('Istanbul'),
('Kuala-Lumpur');

INSERT INTO Airports VALUES ('LED', 'Saint-Petersburg'),
('VOZ', 'Voronezh'),
('MUC', 'Munich'),
('IST', 'Istanbul'),
('SAW', 'Istanbul'),
('KUL', 'Kuala-Lumpur');

INSERT INTO Schedule VALUES
('SU-220', 'LED', 'MUC', 1, '20:00:00', '3:30:00', 220, 'RA-7046', 4500),
('LH-220', 'MUC', 'LED', 1, '14:00:00', '3:30:00', 110, 'RA-8943', 5500),
('SU-100', 'LED', 'MUC', 2, '15:00:00', '3:15:00', 150,'RA-6532', 6500),
('LH-100', 'MUC', 'LED', 2, '10:00:00', '3:15:00', 100,'RA-7891', 6000),
('TA-020', 'IST', 'MUC', 1, '20:00:00', '3:30:00', 120, 'RA-7131', 4500),
('LH-020', 'MUC', 'IST', 2, '14:00:00', '3:30:00', 50, 'RA-8231', 5500),
('SU-212', 'LED', 'VOZ', 1, '13:00:00', '2:30:00', 300, 'RA-6522', 3000),
	('SU-121', 'VOZ', 'LED', 3, '12:00:00', '2:30:00', 240, 'RA-7046', 3000),
('SU-001', 'LED', 'IST', 1, '20:00:00', '4:00:00', 245, 'RA-8943', 4500),
('TA-100', 'IST', 'LED', 1, '14:00:00', '4:00:00', 140, 'RA-6532', 5500),
('SU-101', 'LED', 'SAW', 2, '20:00:00', '4:00:00', 120, 'RA-7891', 4500),
('TA-010', 'SAW', 'LED', 2, '14:00:00', '4:00:00', 130, 'RA-7131', 5500),
('SU-111', 'VOZ', 'IST', 1, '20:00:00', '2:30:00', 200, 'RA-7131', 4500),
('SU-112', 'IST', 'VOZ', 1, '14:00:00', '2:30:00', 250, 'RA-8231', 5500),
('SU-300', 'LED', 'KUL', 4, '08:00:00', '10:00:00', 300, 'RA-7046', 35000),
('SU-301', 'LED', 'VOZ', 4, '18:00:00', '02:00:00', 100, 'RA-8231', 3500),
('SU-302', 'VOZ', 'IST', 4, '22:00:00', '03:00:00', 200, 'RA-8943', 8000),
('SU-303', 'IST', 'KUL', 5, '05:00:00', '06:00:00', 450, 'RA-6532', 10000),
('SU-304', 'LED', 'MUC', 4, '01:00:00', '04:00:00', 150, 'RA-7131', 7000),
('SU-305', 'MUC', 'KUL', 4, '10:00:00', '12:00:00', 300, 'RA-7046', 20000),
('SU-306', 'MUC', 'IST', 4, '06:00:00', '01:30:00', 300, 'RA-6532', 5000);

INSERT INTO Flights VALUES
('SU-220', 0, '2021-05-24'),
('SU-220', 0, '2021-05-31'),
('LH-020', 0, '2021-06-01'),
('SU-220', 0, '2021-06-07'),
('LH-020', 0, '2021-06-08'),
('SU-220', 0, '2021-06-14'),
('LH-020', 0, '2021-06-15'),
('SU-220', 0, '2021-06-21'),
('LH-020', 0, '2021-06-22'),
('SU-220', 0, '2021-06-28'),
('LH-020', 0, '2021-06-29');

INSERT INTO Passengers VALUES
('0', 'SU-220', '2021-05-24'),
('0', 'SU-220', '2021-05-31'),
('0', 'SU-220', '2021-06-07'),
('0', 'SU-220', '2021-06-14'),
('0', 'LH-220', '2021-05-25'),
('0', 'LH-220', '2021-06-01'),
('0', 'LH-220', '2021-06-08'),
('0', 'LH-220', '2021-06-15'),
('1', 'SU-220', '2021-05-24'),
('2', 'SU-220', '2021-05-24'),
('3', 'SU-220', '2021-05-24');

INSERT INTO Archive VALUES
('SU-220', 'RA-7046', 150, 100, '2021-05-10'),
('SU-220', 'RA-7046', 150, 120, '2021-05-03'),
('LH-220', 'RA-8943', 110, 110, '2021-05-10'),
('LH-220', 'RA-8943', 110, 10, '2021-05-03'),
('SU-212', 'RA-7131', 110, 110, '2021-05-03'),
('SU-001', 'RA-7046', 150, 50, '2021-04-05'),
('SU-101', 'RA-7046', 150, 150, '2021-04-06'),
('LH-020', 'RA-7046', 150, 50, '2021-05-11'),
('SU-111', 'RA-7046', 150, 150, '2021-05-03'),
('SU-220', 'RA-7046', 150, 100, '2021-03-01'),
('SU-220', 'RA-7046', 150, 110, '2021-03-29'),
('SU-220', 'RA-7046', 150, 120, '2021-03-22'),
('SU-220', 'RA-7046', 150, 130, '2021-03-15'),
('SU-220', 'RA-7046', 150, 140, '2021-03-08'),
('LH-220', 'RA-7046', 150, 150, '2021-03-01'),
('LH-220', 'RA-7046', 150, 140, '2021-03-29'),
('LH-220', 'RA-7046', 150, 130, '2021-03-22'),
('LH-220', 'RA-7046', 150, 120, '2021-03-15'),
('LH-220', 'RA-7046', 150, 100, '2021-03-08');

INSERT INTO Passengers VALUES
('0', 'SU-220', '2021-05-10'),
('1', 'SU-220', '2021-05-10'),
('2', 'SU-220', '2021-05-10'),
('3', 'SU-220', '2021-05-10'),
('7', 'LH-220', '2021-05-10'),
('8', 'LH-220', '2021-05-10'),
('9', 'LH-220', '2021-05-10'),
('10', 'LH-220', '2021-05-10'),
('4', 'SU-220', '2021-05-03'),
('5', 'SU-220', '2021-05-03'),
('6', 'SU-220', '2021-05-03'),
('7', 'SU-220', '2021-05-03'),
('4', 'LH-220', '2021-05-03'),
('5', 'LH-220', '2021-05-03'),
('4', 'SU-220', '2021-05-10'),
('5', 'SU-220', '2021-05-10'),
('11', 'SU-212', '2021-05-03'),
('12', 'SU-212', '2021-05-03'),
('0', 'SU-001', '2021-04-05'),
('1', 'SU-001', '2021-04-05'),
('2', 'SU-001', '2021-04-05'),
('3', 'SU-001', '2021-04-05'),
('0', 'SU-101', '2021-04-06'),
('1', 'SU-101', '2021-04-06'),
('2', 'SU-101', '2021-04-06'),
('3', 'SU-101', '2021-04-06'),
('11', 'SU-111', '2021-05-03'),
('12', 'SU-111', '2021-05-03'),
('0', 'LH-020', '2021-05-11'),
('1', 'LH-020', '2021-05-11'),
('2', 'LH-020', '2021-05-11'),
('3', 'LH-020', '2021-05-11'),
('0', 'SU-220', '2021-03-01'),
('0', 'SU-220', '2021-03-08'),
('0', 'SU-220', '2021-03-15'),
('0', 'SU-220', '2021-03-22'),
('0', 'SU-220', '2021-03-29'),
('0', 'LH-220', '2021-03-01'),
('0', 'LH-220', '2021-03-08'),
('0', 'LH-220', '2021-03-15'),
('0', 'LH-220', '2021-03-22'),
('0', 'LH-220', '2021-03-29');