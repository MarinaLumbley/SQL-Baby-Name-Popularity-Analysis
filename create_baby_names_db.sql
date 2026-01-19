/* 
---------------------------------------------------------------------------
Author: Marina
Script Purpose:
    - Initialize the baby_names_db schema from scratch.
    - Create the required tables (names, regions).
    - Load the full names dataset from a local CSV file.
    - Populate the regions lookup table with all state–region mappings.

Usage Instructions:
    - Run this script **once** to fully set up and populate the database.
    - Before running, update the file path in the 
          LOAD DATA LOCAL INFILE 
      command so it points to the CSV file in your **current directory**, 
      especially if this project is being cloned from GitHub.

Notes:
    - The script drops and recreates the schema, so it will overwrite 
      any existing baby_names_db database.
    - Ensure LOCAL INFILE is enabled in your MySQL configuration.
---------------------------------------------------------------------------
*/

SHOW VARIABLES LIKE 'local_infile';

DROP SCHEMA IF EXISTS baby_names_db;
CREATE SCHEMA baby_names_db;
USE baby_names_db;


CREATE TABLE names (
  State CHAR(2),
  Gender CHAR(1),
  Year INT,
  Name VARCHAR(45),
  Births INT);


CREATE TABLE regions (
  State CHAR(2),
  Region VARCHAR(45));


LOAD DATA LOCAL INFILE 'C:\\Users\\marin\\OneDrive\\Desktop\\Tableau\\SQL maven\\names_data.csv'
INTO TABLE names
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';


INSERT INTO regions VALUES ('AL', 'South'),
('AK', 'Pacific'),
('AZ', 'Mountain'),
('AR', 'South'),
('CA', 'Pacific'),
('CO', 'Mountain'),
('CT', 'New_England'),
('DC', 'Mid_Atlantic'),
('DE', 'South'),
('FL', 'South'),
('GA', 'South'),
('HI', 'Pacific'),
('ID', 'Mountain'),
('IL', 'Midwest'),
('IN', 'Midwest'),
('IA', 'Midwest'),
('KS', 'Midwest'),
('KY', 'South'),
('LA', 'South'),
('ME', 'New_England'),
('MD', 'South'),
('MA', 'New_England'),
('MN', 'Midwest'),
('MS', 'South'),
('MO', 'Midwest'),
('MT', 'Mountain'),
('NE', 'Midwest'),
('NV', 'Mountain'),
('NH', 'New England'),
('NJ', 'Mid_Atlantic'),
('NM', 'Mountain'),
('NY', 'Mid_Atlantic'),
('NC', 'South'),
('ND', 'Midwest'),
('OH', 'Midwest'),
('OK', 'South'),
('OR', 'Pacific'),
('PA', 'Mid_Atlantic'),
('RI', 'New_England'),
('SC', 'South'),
('SD', 'Midwest'),
('TN', 'South'),
('TX', 'South'),
('UT', 'Mountain'),
('VT', 'New_England'),
('VA', 'South'),
('WA', 'Pacific'),
('WV', 'South'),
('WI', 'Midwest'),
('WY', 'Mountain');
