--code for post http://rvvincelli.github.io/55555/05/05/impala-incremental-updates/

CREATE DATABASE IF NOT EXISTS dealership;

USE dealership;

--Create the base table:
--1   jeep    red     1988-01-12
--2   auto    blue    1988-01-13
--3   moto    yellow  2001-01-09
CREATE EXTERNAL TABLE IF NOT EXISTS cars(
       id STRING,
       type STRING,
       color STRING,
       matriculation_year TIMESTAMP
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/ricky/dealership/cars/base_table';

--Create the delta table
--1   jeep    brown   1988-01-12
--2   auto    green   1988-01-13
CREATE EXTERNAL TABLE cars_new(
       id STRING,
       type STRING,
       color STRING,
       matriculation_year TIMESTAMP
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/ricky/dealership/cars/delta_of_the_day';

--The current macchine table represents the 'old' dataset, it will be:
CREATE TABLE cars_old AS SELECT * FROM cars;
DROP TABLE cars;

--Updated table:
--1   jeep    brown   1988-01-12
--2   auto    green   1988-01-13
--3   moto    yellow  2001-01-09
CREATE TABLE cars 
AS 
    SELECT *
    FROM cars_old
    WHERE id NOT IN (
        SELECT id
        FROM cars_new
    )
    UNION (
        SELECT *
        FROM cars_new
    );

DROP TABLE cars_new;
DROP TABLE cars_old;
