
-- 1 --

-- Create database `credit_card_classification`
--

DROP DATABASE IF EXISTS `credit_card_classification`;
CREATE DATABASE `credit_card_classification`;
USE `credit_card_classification`;

-- 2 --
-- Table credit_card_data with the same columns as given in the csv file. 
--
--Structure for table `credit_card_data`
--

DROP TABLE IF EXISTS `credit_card_data`;
CREATE TABLE `credit_card_data` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `offer_accepted` VARCHAR(6),
  `reward` VARCHAR(255),
  `mailer_type` VARCHAR(255),
  `income_level` VARCHAR(255),
  `nr_of_bank_accounts_open` int(11) DEFAULT NULL,
  `overdraft_protection` VARCHAR(6),
  `credit_rating` VARCHAR(255),
  `credit_cards_held` int(11) DEFAULT NULL,
  `nr_of_homes_owned` int(11) DEFAULT NULL,
  `household_size` int(11) DEFAULT NULL,
  `own_your_home` VARCHAR(6),
  `average_balance` float DEFAULT NULL,
  `balance_q1` float DEFAULT NULL,
  `balance_q2` float DEFAULT NULL,
  `balance_q3` float DEFAULT NULL,
  `balance_q4` float DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

#TRUNCATE TABLE credit_card_data;

select * from credit_card_data;

-- 3 --
-- Importing the data from the csv file into the table. 
-- 
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/creditcardmarketing.csv' 
INTO TABLE credit_card_data 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"';

-- 4 --
-- Select all the data from table credit_card_data to check if the data was imported correctly.
select * from credit_card_data;

-- 5 --
-- Use the alter table command to drop the column q4_balance from the database, as we would not use it in the analysis with SQL. 
-- Select all the data from the table to verify if the command worked. Limit your returned results to 10.
alter table credit_card_data
drop column balance_q4;

select * 
from credit_card_data
limit 10;

-- 6 --
-- Use sql query to find how many rows of data you have.
select count(*)
from credit_card_data;

-- 7 --
-- Now we will try to find the unique values in some of the categorical columns:
-- What are the unique values in the column Offer_accepted?
select distinct(offer_accepted)
from credit_card_data;

-- What are the unique values in the column Reward?
select distinct(reward)
from credit_card_data;

-- What are the unique values in the column mailer_type?
select distinct(mailer_type)
from credit_card_data;

-- What are the unique values in the column credit_cards_held?
select distinct(credit_cards_held)
from credit_card_data;

-- What are the unique values in the column household_size?
select distinct(household_size)
from credit_card_data;

-- 8 --
-- Arrange the data in a decreasing order by the average_balance of the house. 
-- Return only the customer_number of the top 10 customers with the highest average_balances in your data.
select customer_id, average_balance
from credit_card_data
order by average_balance DESC
limit 10;

select customer_id, average_balance
from credit_card_data
where average_balance = '0';

-- 9 --
-- What is the average balance of all the customers in your data
select round(avg(average_balance),2) as avg_balance_all_customers
from credit_card_data;

-- 10 -- 
-- In this exercise we will use simple group by to check the properties of some of the categorical variables in our data. 
-- Note wherever average_balance is asked, please take the average of the column average_balance:

-- What is the average balance of the customers grouped by Income Level? The returned result should have only two columns, 
-- income level and Average balance of the customers. Use an alias to change the name of the second column.
select income_level, sum(average_balance) as average_balance_of_customers
from credit_card_data
group by income_level
order by average_balance_of_customers DESC;

-- What is the average balance of the customers grouped by number_of_bank_accounts_open? 
-- The returned result should have only two columns, number_of_bank_accounts_open and Average balance of the customers. 
-- Use an alias to change the name of the second column.
select nr_of_bank_accounts_open, sum(average_balance) as average_balance_of_customers
from credit_card_data
group by nr_of_bank_accounts_open
order by average_balance_of_customers DESC;

-- What is the average number of credit cards held by customers for each of the credit card ratings? 
-- The returned result should have only two columns, rating and average number of credit cards held. 
-- Use an alias to change the name of the second column.
select distinct(credit_cards_held)
from credit_card_data;

select credit_rating, avg(credit_cards_held) as average_credit_cards_held
from credit_card_data
group by credit_rating
order by average_credit_cards_held DESC;

-- Is there any correlation between the columns credit_cards_held and number_of_bank_accounts_open? 
-- You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. 
-- Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
select nr_of_bank_accounts_open, round(avg(credit_cards_held),2) as credit_cards_held from credit_card_data
group by nr_of_bank_accounts_open
order by nr_of_bank_accounts_open;
# they have a positive correlation

-- 11 --
/* Your managers are only interested in the customers with the following properties:
Credit rating medium or high
Credit cards held 2 or less
Owns their own home
Household size 3 or more

For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them? 
Can you filter the customers who accepted the offers here?
*/
select customer_id, credit_rating, credit_cards_held, own_your_home, household_size, offer_accepted
from credit_card_data
where credit_rating in ('Medium','High') 
and credit_cards_held <= 2 
and own_your_home = 'Yes'
and household_size >= 3
order by offer_accepted DESC;

-- 12 --
-- our managers want to find out the list of customers whose average balance is less than the average balance of all the customers in the database. 
-- Write a query to show them the list of such customers. You might need to use a subquery for this problem.
select round(avg(average_balance),2) as avg_balance_all_customers
from credit_card_data;

select customer_id, average_balance 
from credit_card_data
where average_balance < (select round(avg(average_balance),2) from credit_card_data)
order by average_balance DESC;

-- 13 --
-- Since this is something that the senior management is regularly interested in, create a view of the same query.
drop view if exists average_balance_customer;
create or replace view average_balance_customer as
select customer_id, average_balance 
from credit_card_data
where average_balance < (select round(avg(average_balance),2) from credit_card_data)
order by average_balance DESC;

select * from average_balance_customer;

-- 14 --
-- What is the number of people who accepted the offer vs number of people who did not?
select count(customer_id) as nr_of_customers, offer_accepted
from credit_card_data
where offer_accepted = 'Yes';

select count(customer_id) as nr_of_customers, offer_accepted
from credit_card_data
where offer_accepted = 'No';

-- 15 --
-- Your managers are more interested in customers with a credit rating of high or medium. 
-- What is the difference in average balances of the customers with high credit card rating and low credit card rating?
-- CHECK!!
select credit_rating, round(avg(average_balance),2) as average_balance_customers 
from credit_card_data
group by credit_rating
having credit_rating in ('High', 'Low');

-- 16 --
-- In the database, which all types of communication (mailer_type) were used and with how many customers?
select mailer_type, count(customer_id) as nr_of_customers
from credit_card_data
group by mailer_type
order by nr_of_customers DESC;

-- 17 --
-- Provide the details of the customer that is the 11th least Q1_balance in your database. PLEASE EXPLAIN 11th LEAST??
select balance_q1
from credit_card_data
order by balance_q1;

select customer_id, balance_q1, ranks 
from (select *, dense_rank() over (order by balance_q1 ASC) as ranks
from credit_card_data) sub
where ranks = 11;

