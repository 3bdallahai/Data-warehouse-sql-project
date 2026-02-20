/*
============================================
Create Database and Schema
============================================

Script Purpose:
Create a new database called "DataWarehouse". 
It checks if the database exists before creating. If exists it drops the database and create again.
the script also create 3 Schemas (bronze - silver - gold)
*/

USE master;
GO

--Drop and recreate the "DataWarehouse" database
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--Create the "DataWarehouse" database
CREATE DATABASE DataWarehouse;
GO


USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO