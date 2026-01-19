# Baby Names SQL Analytics (MySQL)

**Author:** Marina Lumbley

SQL portfolio project showing CTEs and window functions (DENSE_RANK, LAG) on U.S. baby-name data.

## Files
- create_baby_names_db.sql: database setup + CSV import
- SQL showcase.sql: runs all analytics queries

## Requirements
- MySQL 8.0+ (Server) and mysql client (or MySQL Workbench)
- Dataset file: names_data.csv (same folder as the scripts, or use an absolute path)

## Setup (run once)
1) Enable LOCAL INFILE:
   - In a MySQL session: SET GLOBAL local_infile = 1;
   - Client-side: use mysql --local-infile=1 (or enable in Workbench preferences)
2) In create_baby_names_db.sql, update the LOAD DATA LOCAL INFILE path to your local names_data.csv.

### Run from CLI
From the repo folder:

1) Build and load the database:
   mysql --local-infile=1 -u <user> -p < create_baby_names_db.sql

2) Execute the analysis queries:
   mysql -u <user> -p baby_names_db < "SQL showcase.sql"

### Run from MySQL Workbench
- Open create_baby_names_db.sql and execute (lightning button)
- Then open SQL showcase.sql and execute

## Data expectations
CSV columns (in order): State, Gender, Year, Name, Births. If your CSV has a header row, add: IGNORE 1 LINES to the LOAD DATA statement.

## Common issues
- ERROR 3948 / local_infile disabled: enable server local_infile and run the client with --local-infile=1.
- Secure-file-priv restrictions: prefer LOCAL INFILE, or move the CSV into the server-approved directory.
- Line endings: if you see load errors on Windows, try LINES TERMINATED BY '\r\n' in the LOAD DATA clause.

## Skills demonstrated
- Data modeling: fact/lookup tables (names, regions)
- Data ingestion: bulk load from CSV
- Analytics SQL: CTEs, window functions, ranking, time-series comparisons, and geo segmentation
