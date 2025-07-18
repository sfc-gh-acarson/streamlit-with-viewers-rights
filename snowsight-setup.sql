----------------------------------
------------ 👤 Roles ------------
----------------------------------
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE SALES_ADMIN_ROLE;
CREATE OR REPLACE ROLE SALES_VIEWER_ROLE;

GRANT ROLE SALES_ADMIN_ROLE TO ROLE SYSADMIN;
GRANT ROLE SALES_VIEWER_ROLE TO ROLE SYSADMIN;

----------------------------------
---------- ⚙️ Warehouse ----------
----------------------------------
CREATE WAREHOUSE IF NOT EXISTS APPS_WH WITH WAREHOUSE_SIZE='Small';

----------------------------------
------- 📊 Source Objects --------
----------------------------------
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS APPS_DB;
CREATE SCHEMA IF NOT EXISTS APPS_DB.RCR WITH MANAGED ACCESS;

CREATE OR REPLACE TABLE SALES_DATA (
    ID NUMBER(38, 0) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 ORDER,
    REGION STRING,
    SALES_REP STRING,
    SALES_AMOUNT NUMBER,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO SALES_DATA (REGION, SALES_REP, SALES_AMOUNT)
VALUES 
  ('East', 'Alice', 12000),
  ('West', 'Bob', 15000),
  ('South', 'Carol', 20000),
  ('North', 'Dan', 11000),
  ('East', 'Ellen', 10400),
  ('West', 'Frank', 14750),
  ('South', 'Grace', 32000),
  ('North', 'Henry', 12300);

----------------------------------
-------- 🛡️ Privileges -----------
----------------------------------
GRANT USAGE ON DATABASE APPS_DB TO ROLE SALES_ADMIN_ROLE;
GRANT USAGE ON DATABASE APPS_DB TO ROLE SALES_VIEWER_ROLE;

GRANT USAGE ON SCHEMA APPS_DB.RCR TO ROLE SALES_ADMIN_ROLE;
GRANT USAGE ON SCHEMA APPS_DB.RCR TO ROLE SALES_VIEWER_ROLE;

GRANT USAGE ON WAREHOUSE APPS_WH TO ROLE SALES_ADMIN_ROLE;
GRANT USAGE ON WAREHOUSE APPS_WH TO ROLE SALES_VIEWER_ROLE;


GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE SALES_DATA TO ROLE SALES_ADMIN_ROLE;      -- <== CRUD privileges to Sales Admin 
GRANT SELECT ON TABLE SALES_DATA TO ROLE SALES_VIEWER_ROLE;                             -- <== SELECT privileges to Sales Viewer

----------------------------------
-------- 🚫 Caller Grants --------
----------------------------------

-- Enforces a Privilege Boundary Between App and Data
USE ROLE ACCOUNTADMIN;

GRANT 
    CALLER SELECT, INSERT, UPDATE, DELETE      -- <==== "CALLER" keyword ensures the privileges are only available at runtime
    ON TABLE SALES_DATA TO ROLE SYSADMIN;      -- <==== Application Owner

    
-- More scalable approach
GRANT ALL INHERITED CALLER PRIVILEGES 
    ON ALL TABLES IN ACCOUNT TO ROLE SYSADMIN; 
GRANT ALL INHERITED CALLER PRIVILEGES 
    ON ALL SCHEMAS IN ACCOUNT TO ROLE SYSADMIN;
 
    
USE ROLE ACCOUNTADMIN;
GRANT CALLER USAGE ON WAREHOUSE APPS_WH TO ROLE SYSADMIN;

---- Secondary Roles (if needed) ----
ALTER USER <user name> SET DEFAULT_SECONDARY_ROLES = ();
