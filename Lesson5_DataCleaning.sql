/* In the accounts table, there is a column holding the website for each company.
The last three digits specify what type of web address they are using.Pull these
extensions and provide how many of each website type exist in the accounts table.*/

WITH t1 AS (
	SELECT website, RIGHT(website, 3) website_extension
	FROM accounts
)
SELECT website_extension, COUNT(website_extension)
FROM t1
GROUP BY website_extension
ORDER BY 1


/* There is much debate about how much the name (or even the first letter of a company name)
matters. Use the accounts table to pull the first letter of each company name to see the
distribution of company names that begin with each letter (or number).*/

SELECT LEFT(name,1) first_letter, COUNT(LEFT(name,1))
FROM accounts
GROUP BY first_letter
ORDER BY 2 DESC

/*Use the accounts table and a CASE statement to create two groups: one group of 
company names that start with a number and a second group of those company names 
that start with a letter. What proportion of company names start with a letter?*/

WITH t1 AS (
	SELECT CASE WHEN LEFT(name,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'number'
			ELSE 'letter' END first_char_is
	FROM accounts
)
SELECT first_char_is, COUNT(first_char_is)
FROM t1
GROUP BY first_char_is


/*Consider vowels as a, e, i, o, and u. What proportion of company names start with
a vowel, and what percent start with anything else?*/

WITH t1 AS (
	SELECT CASE WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 'vowel'
			ELSE 'not_vowel' END first_char_is
	FROM accounts
)
SELECT first_char_is, COUNT(first_char_is)
FROM t1
GROUP BY first_char_is


/*Use the accounts table to create first and last name columns that hold the first and 
last names for the primary_poc.*/

SELECT primary_poc, LEFT(primary_poc, STRPOS(primary_poc,' ')-1) first_name,
		RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
FROM accounts

/*Now see if you can do the same thing for every rep name in the sales_reps table.
Again provide first and last name columns.*/

SELECT name, SPLIT_PART(name, ' ' , 1) first_name,
		SPLIT_PART(name, ' ' , 2) last_name
FROM sales_reps


/*Each company in the accounts table wants to create an email address for each primary_poc.
The email address should be the first name of the primary_poc . last name primary_poc @ 
company name .com.*/

WITH t1 AS (
	SELECT name, primary_poc, LEFT(primary_poc, STRPOS(primary_poc,' ')-1) first_name,
		RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
	FROM accounts
)
SELECT primary_poc, name, first_name || '.' || last_name || '@' || name || '.com' email
FROM t1


/*You may have noticed that in the previous solution some of the company names include spaces,
which will certainly not work in an email address. See if you can create an email address
that will work by removing all of the spaces in the account name, but otherwise your solution
should be just as in question 1.*/

WITH t1 AS (
	SELECT name, primary_poc, LEFT(primary_poc, STRPOS(primary_poc,' ')-1) first_name,
		RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
	FROM accounts
)
SELECT primary_poc, name, CONCAT(first_name, '.', last_name, '@', REPLACE(name,' ',''), '.com') email
FROM t1


/*We would also like to create an initial password, which they will change after their first log in.
The first password will be the first letter of the primary_poc's first name (lowercase), then the 
last letter of their first name (lowercase), the first letter of their last name (lowercase), the
last letter of their last name (lowercase), the number of letters in their first name, the number
of letters in their last name, and then the name of the company they are working with, all
capitalized with no spaces.*/

WITH t1 AS (
	SELECT name, primary_poc, LEFT(primary_poc, STRPOS(primary_poc,' ')-1) first_name,
		RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) last_name
	FROM accounts
)
SELECT first_name, last_name, name, LOWER(LEFT(first_name, 1)) || LOWER(RIGHT(first_name, 1)) ||
		LOWER(LEFT(last_name, 1)) || LOWER(RIGHT(last_name, 1)) || LENGTH(first_name) ||
		LENGTH(last_name) || UPPER(REPLACE(name, ' ','')) initial_password
FROM t1

/*Write a query to look at the top 10 rows to understand the columns and the raw data in the dataset
called sf_crime_data*/

SELECT *
FROM sf_crime_data
LIMIT 10

/*Write a query to change the date into the correct SQL date format*/

SELECT date, 
	CAST(SUBSTRING(date from 7 for 4) || '-' ||
	SUBSTRING(date from 1 for 2) || '-' ||
    SUBSTRING(date from 4 for 2) as DATE) 
FROM sf_crime_data

/*Use COALESCE to fill in the accounts.id column with the account.id for the NULL value for the
table??*/
/*Use COALESCE to fill in the orders.accounts_id column with the account.id for the NULL value for the
table??*/
/*Use COALESCE to fill in each of the qty and usd columns with 0 for the
table??*/