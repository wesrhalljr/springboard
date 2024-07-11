/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name
FROM Facilities
WHERE membercost >0
LIMIT 0 , 1000


/* Q2: How many facilities do not charge a fee to members? */
ELECT COUNT(*)
FROM facilities
WHERE membercost = 0;
5


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost >0
AND membercost < ( 0.20 * monthlymaintenance )
LIMIT 0 , 1000

facid	name	        membercost	monthlymaintenance	
0       Tennis Court 1	   5.0	        200
1	    Tennis Court 2	   5.0	        200
4	    Massage Room 1	   9.9	        3000
5	    Massage Room 2	   9.9	        3000
6	    Squash Court	   3.5	        80


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM facilities
WHERE facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthly_maintenance,
       CASE
           WHEN monthly_maintenance > 100 THEN 'expensive'
           ELSE 'cheap'
       END AS cost_label
FROM facilities;

	             monthly        cost
name             maintenance	label	
Tennis Court 1	 200	        expensive
Tennis Court 2	 200	        expensive
Badminton Court	 50	            cheap
Table Tennis	 10	            cheap
Massage Room 1	 3000	        expensive
Massage Room 2	 3000	        expensive
Squash Court	 80	            cheap
Snooker Table	 15	            cheap
Pool Table	     15	            cheap


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members);

Answer: Darren Smith

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT (
Members.firstname || ' ' || Members.surname
) AS member_name, Facilities.name AS court_name
FROM Bookings
JOIN Members ON Bookings.memid = Members.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE 'Tennis Courts%'
ORDER BY member_name

No names returned



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
firstname || ' ' || surname AS member,
name AS facility,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM members
INNER JOIN bookings
ON members.memid = bookings.memid
INNER JOIN facilities
ON bookings.facid = facilities.facid
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT
firstname || ' ' || surname AS member,
name AS facility,
cost
FROM
(SELECT
firstname,
surname,
name,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost,
starttime
FROM members
INNER JOIN bookings
ON members.memid = bookings.memid
INNER JOIN facilities
ON bookings.facid = facilities.facid) AS inner_table
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND cost > 30
ORDER BY cost DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
name,
revenue
FROM
(SELECT
name,
SUM(CASE WHEN memid = 0 THEN guestcost * slots ELSE membercost * slots END) AS revenue
FROM cd.bookings INNER JOIN cd.facilities
ON cd.bookings.facid = cd.facilities.facid
GROUP BY name) AS inner_table
WHERE revenue < 1000
ORDER BY revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT concat(m.firstname,' ',m.surname) as Recommended_By,
concat(rcmd.firstname,' ',rcmd.surname) as Member
FROM Members m
inner join Members rcmd on rcmd.recommendedby = m.memid
WHERE m.memid > 0 
order by m.surname,m.firstname,rcmd.surname,rcmd.surname

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name,concat(m.firstname,' ',m.surname) as Member,
count(f.name) as bookings
FROM Members m
inner join Bookings bk on bk.memid = m.memid
inner join Facilities f on f.facid = bk.facid
where m.memid>0
group by f.name,concat(m.firstname,' ',m.surname)
order by f.name,m.surname,m.firstname 


/* Q13: Find the facilities usage by month, but not guests */
SELECT f.name,concat(m.firstname,' ',m.surname) as Member,
count(f.name) as bookings,

sum(case when month(starttime) = 1 then 1 else 0 end) as Jan,
sum(case when month(starttime) = 2 then 1 else 0 end) as Feb,
sum(case when month(starttime) = 3 then 1 else 0 end) as Mar,
sum(case when month(starttime) = 4 then 1 else 0 end) as Apr,
sum(case when month(starttime) = 5 then 1 else 0 end) as May,
sum(case when month(starttime) = 6 then 1 else 0 end) as Jun,
sum(case when month(starttime) = 7 then 1 else 0 end) as Jul,
sum(case when month(starttime) = 8 then 1 else 0 end) as Aug,
sum(case when month(starttime) = 9 then 1 else 0 end) as Sep,
sum(case when month(starttime) = 10 then 1 else 0 end) as Oct,
sum(case when month(starttime) = 11 then 1 else 0 end) as Nov,
sum(case when month(starttime) = 12 then 1 else 0 end) as Decm

FROM Members m
inner join Bookings bk on bk.memid = m.memid
inner join Facilities f on f.facid = bk.facid
where m.memid>0
and year(starttime) = 2012
