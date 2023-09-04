Write a single query to report all status updates for  the user 'Kevin Allen' by joining status and user.
Output Column: status_time, text
Order by: status_time increasing


SELECT status_time, text
FROM status
JOIN user ON user.id = status.user_id
WHERE user.name = 'Kevin Allen'
ORDER BY status_time ASC;


================

Write a single query to report all status updates for  the user 'Kevin Allen' by joining status and user on the above database schema.
Output Column: status_time, text
Order by: status_time increasing

SELECT status_time, text
FROM status
JOIN users ON users.userid = status.userid
WHERE users.name = 'Kevin Allen'
ORDER BY status_time ASC;


==============
Write a query to find all users who satisfy one of the following conditions:
        - the user's name starts with a 'J' and they were born before and including 1980
        - the user's name starts with an 'M' and they were born after 1980 (excluding 1980)
 Output columns: name, birthdate
 Order by: name ascending

 SELECT name, birthdate
FROM users
WHERE (name LIKE 'J%' AND birthdate <= '1980-01-01')
   OR (name LIKE 'M%' AND birthdate > '1980-01-01')
ORDER BY name ASC;


===========

SQL "with" clause can be used to simplify queries. It essentially allows
specifying temporary tables to be used during the rest of the query. See Section
3.8.6 (6th Edition) for some examples.

Write a query to find the name(s) of the user(s) with the largest number of friends. We have provided
a part of the query to build a temporary table.

Output columns: name, num_friends
Order by name ascending.

WITH friend_counts AS (
    SELECT userid1 AS userid, COUNT(*) AS num_friends
    FROM friends
    GROUP BY userid1
    UNION
    SELECT userid2 AS userid, COUNT(*) AS num_friends
    FROM friends
    GROUP BY userid2
)
SELECT name, num_friends
FROM users
JOIN friend_counts ON users.userid = friend_counts.userid
WHERE num_friends = (SELECT MAX(num_friends) FROM friend_counts)
ORDER BY name ASC;


==============
List the names of the users who posted no status updates. Hint: Use "not in".
Output Columns: name
Order by name ascending

SELECT name
FROM users
WHERE userid NOT IN (SELECT userid FROM status)
ORDER BY name ASC;


=============
Write a query to output a list of users and their friends, such that the friend has an
upcoming birthday within next 15 days.  Assume today is Sept 10, 2021
(so look for birthdays between Sept 11 and Sept 25, both inclusive). You can hardcode
that if you'd like.
Output: username, friendname, friendbirthdate
Order by: username, friendname ascending

SELECT u1.name AS username, u2.name AS friendname, u2.birthdate AS friendbirthdate
FROM friends
JOIN users AS u1 ON friends.userid1 = u1.userid
JOIN users AS u2 ON friends.userid2 = u2.userid
WHERE u2.birthdate BETWEEN '2021-09-11' AND '2021-09-25'
ORDER BY username, friendname ASC;

===========
For each user who has posted at least two status updates, count the
average amount of time between his or her status updates in seconds.
Order the results in the increasing order by the userid.

Output columns: userid, gapseconds
Order by: userid

SELECT userid, AVG(TIMESTAMPDIFF(SECOND, s1.status_time, s2.status_time)) AS gapseconds
FROM (SELECT userid, status_time,
             LAG(status_time, 1) OVER (PARTITION BY userid ORDER BY status_time) AS prev_status_time
      FROM status) AS s1
JOIN (SELECT userid, status_time,
             LAG(status_time, 1) OVER (PARTITION BY userid ORDER BY status_time) AS prev_status_time
      FROM status) AS s2 ON s1.userid = s2.userid AND s1.prev_status_time = s2.status_time
GROUP BY userid
HAVING COUNT(*) >= 2
ORDER BY userid ASC;

Answer the above query for PostgreSQL syntax.

SELECT userid, AVG(EXTRACT(EPOCH FROM (s1.status_time - s2.status_time))) AS gapseconds
FROM (SELECT userid, status_time,
             LAG(status_time, 1) OVER (PARTITION BY userid ORDER BY status_time) AS prev_status_time
      FROM status) AS s1
JOIN (SELECT userid, status_time,
             LAG(status_time, 1) OVER (PARTITION BY userid ORDER BY status_time) AS prev_status_time
      FROM status) AS s2 ON s1.userid = s2.userid AND s1.prev_status_time = s2.status_time
GROUP BY userid
HAVING COUNT(*) >= 2
ORDER BY userid ASC;


==========

Generate a list - (birthyear, num-users) - containing the years
in which the users in the database were born, and the number of users
born in each year.

However, your output here should have all years between 1940 and 2000 both inclusive,
with 0 counts if no users were born that year

Do this for PostgreSQL syntax.

Output columns: birthyear, num_users
Order by birthyear

SELECT EXTRACT(YEAR FROM birthdate) AS birthyear, COUNT(*) AS num_users
FROM users
WHERE birthdate BETWEEN '1940-01-01' AND '2000-12-31'
GROUP BY birthyear
ORDER BY birthyear ASC;

The above query won't have any output if there is no user in the database for a particular year.

SELECT years.year AS birthyear, COUNT(users.birthdate) AS num_users
FROM (SELECT 1940 + generate_series(0, 60) AS year) AS years
LEFT JOIN users ON EXTRACT(YEAR FROM users.birthdate) = years.year
GROUP BY birthyear
ORDER BY birthyear ASC;


=========

Find the name of the group with the maximum number of members. There may be more than one answer.

SELECT name, COUNT(*) AS num_members
FROM groups
JOIN members ON groups.groupid = members.groupid
GROUP BY name
HAVING num_members = (SELECT MAX(num_members) FROM (SELECT COUNT(*) AS num_members FROM members GROUP BY groupid) AS member_counts)
ORDER BY name ASC;


===========

Write a query to find the names of all users that "Michael Smith" is friends with or follows.
The output should be a list of names, with a second column that takes values: "friends", or "follows"
Some names might appear twice

SELECT u.name AS username, 'friends' AS relationship
FROM friends f
JOIN users u ON f.userid2 = u.userid
WHERE f.userid1 = (SELECT userid FROM users WHERE name = 'Michael Smith')

UNION

SELECT u.name AS username, 'follows' AS relationship
FROM follows f
JOIN users u ON f.userid2 = u.userid
WHERE f.userid1 = (SELECT userid FROM users WHERE name = 'Michael Smith')
ORDER BY username ASC;


==========
Write a query to count for each user, the number of other users that they are both friends with and follow.

SELECT f.userid1, COUNT(DISTINCT f.userid2) AS common_friends
FROM friends f
JOIN follows f2 ON f.userid1 = f2.userid1 AND f.userid2 = f2.userid2
GROUP BY f.userid1
ORDER BY f.userid1 ASC;


=============
Find the pairs of users that were born closest to each other (there are no two users with the 
same birthdate). There may be multiple answers.

For any pair, the output should only contain one row such that username1 < username2

Output columns: username1, username2 
Order by: username1


SELECT u1.name AS username1, u2.name AS username2
FROM users u1
JOIN users u2 ON ABS(EXTRACT(EPOCH FROM u1.birthdate) - EXTRACT(EPOCH FROM u2.birthdate)) = (SELECT MIN(ABS(EXTRACT(EPOCH FROM u1.birthdate) - EXTRACT(EPOCH FROM u2.birthdate))) FROM users)
WHERE u1.name < u2.name
ORDER BY username1 ASC;


=============
For each user, calculate the number of friends and the number of followers.
Note that a user with no friends will not appear in the friends table, and same
goes for follows table. But 0 counts should still be appropriately recorded.

Output columns: userid, name, num_friends, num_followers
Order by: userid

SELECT u.userid, u.name,
    COALESCE(f.num_friends, 0) AS num_friends,
    COALESCE(fo.num_followers, 0) AS num_followers
FROM users u
LEFT JOIN (SELECT userid1, COUNT(*) AS num_friends FROM friends GROUP BY userid1) AS f ON u.userid = f.userid1
LEFT JOIN (SELECT userid2, COUNT(*) AS num_followers FROM follows GROUP BY userid2) AS fo ON u.userid = fo.userid2
ORDER BY u.userid ASC;

============
Find all users who are not followed by anyone who is a member of the group:
'University of Maryland, College Park USA'
You can hard code the group id: 'group36'

HINT: Use Set Operation "Not Exists"

Output column order: name
Order by name ascending

SELECT u.name
FROM users u
WHERE NOT EXISTS (SELECT * FROM follows f
                  JOIN members m ON f.userid1 = m.userid
                  JOIN groups g ON m.groupid = g.groupid
                  WHERE u.userid = f.userid2
                  AND g.groupid = 'group36')
ORDER BY u.name ASC;


===============
Write a single query to rank the "groups" by the number of members, with the group
with the highest number of members getting rank 1.
If there are ties, the two (or more) groups should get the same "rank", and next ranks
should be skipped.

Write this for PostgreSQL.

SELECT g.name, g.num_members, DENSE_RANK() OVER (ORDER BY g.num_members DESC) AS rank
FROM (SELECT g.name, COUNT(m.userid) AS num_members
      FROM groups g
      LEFT JOIN members m ON g.groupid = m.groupid
      GROUP BY g.name) AS g
ORDER BY rank ASC;

==========
Use window functions to construct a query to associate the average number
followers for each "joined" year, with each user.

Write this for PostgreSQL.

SELECT u.userid, u.name, u.joined, AVG(fo.num_followers) OVER (PARTITION BY EXTRACT(YEAR FROM u.joined)) AS avg_followers
FROM users u
LEFT JOIN (SELECT userid2, COUNT(*) AS num_followers FROM follows GROUP BY userid2) AS fo ON u.userid = fo.userid2
ORDER BY u.userid ASC;


==============
Write a function that takes in a userid as input, and returns the number of friends for
that user.

Function signature: num_friends(in varchar, out num_friends bigint)

CREATE OR REPLACE FUNCTION num_friends(userid varchar)
RETURNS bigint AS
$$
BEGIN
    RETURN (SELECT COUNT(*)
            FROM friends
            WHERE userid1 = userid);
END;
$$
LANGUAGE plpgsql;


==============
Write a PostgreSQL function that takes in an userid as input, and returns a JSON string with
the details of friends and followers of that user.

So SQL query: select user_details('user0');
should return a single tuple with a single attribute of type string/varchar as:
{ "userid": "user0", "name": "Anthony Roberts", "friends": [{"name": "Anthony Taylor"}, {"name": "Betty Garcia"}, {"name": "Betty Hernandez"}, {"name": "Betty Lewis"}, {"name": "Betty Lopez"}, {"name": "Betty Parker"}, {"name": "Betty Thomas"}, {"name": "Brian Jackson"}, {"name": "Brian King"}, {"name": "Brian Robinson"}, {"name": "Daniel Lewis"}, {"n ame": "Deborah Turner"}, {"name": "Donald Adams"}, {"name": "Donald Thompson"}, {"name": "Donald Walker"}, {"name": "Dorothy Gonzalez"}, {"name": "James Mitchell"}, {"name": "Ja son Phillips"}, {"name": "Jeff White"}, {"name": "Kevin Allen"}, {"name": "Kimberly Allen"}], "follows": [{"name": "Betty Thomas"}, {"name": "David Anderson"}, {"name": "Edward Green"}, {"name": "Elizabeth Jones"}, {"name": "Nancy Gonzalez"}, {"name": "Richard Perez"}, {"name": "Ronald Garcia"}]}

Within "friends" and "follows", the entries should be ordered by name.

You should use PL/pgSQL for this purpose -- writing this purely in SQL is somewhat cumbersome.
i.e., your function should have LANGUAGE plpgsql at the end.

Function signature: user_details(in varchar, out details_json varchar)


CREATE OR REPLACE FUNCTION user_details(userid varchar)
RETURNS varchar AS
$$
DECLARE
    user_json text;
    friends_json text;
    follows_json text;
BEGIN
    SELECT row_to_json(u.*)
    INTO user_json
    FROM (SELECT userid, name FROM users WHERE userid = userid) u;

    SELECT array_to_json(array_agg(row_to_json(f.*)))
    INTO friends_json
    FROM (SELECT u.name
          FROM friends f
          JOIN users u ON f.userid2 = u.userid
          WHERE f.userid1 = userid
          ORDER BY u.name) f;

    SELECT array_to_json(array_agg(row_to_json(f.*)))
    INTO follows_json
    FROM (SELECT u.name
          FROM follows f
          JOIN users u ON f.userid2 = u.userid
          WHERE f.userid1 = userid
          ORDER BY u.name) f;

    RETURN '{"userid": ' || user_json || ', "friends": ' || friends_json || ', "follows": ' || follows_json || '}';
END;
$$
LANGUAGE plpgsql;


==============
Create a new table using: 
         create table influencers as 
             select u.userid, u.name, count(userid1) as num_followers
             from users u join follows f on (u.userid = f.userid2)
             group by u.userid, u.name
             having count(userid1) > 10;

Create a new trigger that:  
         When a tuple is inserted in the follows relation, appropriately modifies influencers.
         Specifically:
             If the userid2 for the new follows tuple is already present in influencers,
                 then the num_followers should be increased appropriately.
             If the userid2 for the new follows tuple is NOT present in influencers, 
                 then it should check whether the addition of the new follower makes the user
                 an influencer, and add the entry to influencers table.

As per PostgreSQL syntax, you have to write two different statements -- queries[6] should be the CREATE FUNCTION statement,   
and queries[7] should be the CREATE TRIGGER statement.


-- Query 1: Create the `influencers` table
CREATE TABLE influencers AS
SELECT u.userid, u.name, COUNT(userid1) AS num_followers
FROM users u
JOIN follows f ON u.userid = f.userid2
GROUP BY u.userid, u.name
HAVING COUNT(userid1) > 10;

-- Query 2: Create the trigger
CREATE TRIGGER update_influencers
AFTER INSERT ON follows
FOR EACH ROW
EXECUTE PROCEDURE update_influencers_func();

-- Query 3: Create the function called by the trigger
CREATE OR REPLACE FUNCTION update_influencers_func()
RETURNS TRIGGER AS
$$
BEGIN
    -- If the userid2 for the new follows tuple is already present in influencers,
    -- then the num_followers should be increased appropriately.
    IF EXISTS (SELECT * FROM influencers WHERE userid = NEW.userid2) THEN
        UPDATE influencers
        SET num_followers = num_followers + 1
        WHERE userid = NEW.userid2;
    -- If the userid2 for the new follows tuple is NOT present in influencers,
    -- then it should check whether the addition of the new follower makes the user
    -- an influencer


=====================
Recursion can be used in our database to find all users a user is connected with through
others (i.e., friends of friends, friends of friends of friends, etc).

However, our friends table has so much connectivity that the result is somewhat meaningless
(everyone is connected to everyone).

Hence, we will use a smaller friends table for this query.
Use the following query to create a smaller friends table:
       select f.userid1, f.userid2 into friends_small from friends f, users u1, users u2 where f.userid1 = u1.userid and f.userid2 = u2.userid and abs(extract(year from u1.birthdate) - extract(year from u2.birthdate)) < 5;

Complete the below partial query to find all the other users that they are
connected to through other users through the "friends_small" table.

Make sure you don't list a user as their own friend.

There should be 1972 rows in the output.

Output columns: name1, userid1, name2, userid2
Output order: name1, name2

WITH RECURSIVE friends_recursive(name1, userid1, name2, userid2) AS (
    SELECT u1.name, u1.userid, u2.name, u2.userid
    FROM users u1
    INNER JOIN friends_small f ON u1.userid = f.userid1
    INNER JOIN users u2 ON f.userid2 = u2.userid
    WHERE u1.userid != u2.userid
    UNION ALL
    SELECT fr.name1, fr.userid1, u.name, u.userid
    FROM friends_recursive fr
    INNER JOIN friends_small f ON fr.userid2 = f.userid1
    INNER JOIN users u ON f.userid2 = u.userid
    WHERE fr.userid1 != u.userid
)
SELECT DISTINCT name1, userid1, name2, userid2
FROM friends_recursive
ORDER BY name1, name2;


===========
Write an interesting SQL assignment question on the above schema.

Write a query to find the names of all users who have at least one mutual friend with "Michael Smith" and are not friends with him.

Output columns: name
Output order: name ascending

HINT: You can use EXISTS and NOT EXISTS in this query.

===============
Give me something more difficult.

Write a function that takes in a userid as input, and outputs the name of the user and the names of the five users who are most similar to that user in terms of mutual friends. If the user has less than five friends, the function should output the names of all the user's friends.

The function should use the following formula to calculate the similarity score between two users:

similarity_score = (number of mutual friends) / (number of friends of user1 + number of friends of user2 - number of mutual friends)

The function should output the five users with the highest similarity scores, in descending order.

Function signature: find_most_similar(in varchar, out name varchar, out similar1 varchar, out similar2 varchar, out similar3 varchar, out similar4 varchar, out similar5 varchar)

Use PL/pgSQL for this purpose.

HINT: You can use a recursive CTE to find the mutual friends of a user.


==========
That's too difficult. Perhaps something in between?

Write a query to find the names of all users who are friends with both "Michael Smith" and "John Johnson".

Output columns: name
Output order: name ascending

HINT: You can use INNER JOIN and EXISTS in this query.


==============
Give me 10 interesting SQL assignment questions on the above schema, in the increasing order of difficulty.

    Find the name(s) of the user(s) with the largest number of friends.

    Write a query to find the names of all users that "Michael Smith" is friends with or follows.

    For each user, calculate the number of friends and the number of followers.

    Find all users who are not followed by anyone who is a member of the group 'University of Maryland, College Park USA'.

    For each user who has posted at least two status updates, count the average amount of time between his or her status updates in seconds.

    Write a function that takes in a userid as input, and returns the number of friends for that user.

    Create a new table and trigger that keeps track of influencers (users with more than 10 followers) and updates the table when new follows tuples are inserted.

    Write a query to find the names of all users who have at least one mutual friend with "Michael Smith" and are not friends with him.

    Write a function that takes in a userid as input, and outputs the name of the user and the names of the five users who are most similar to that user in terms of mutual friends.

    Write a query to find the name(s) of the user(s) who has the most number of friends who are not friends with each other.


=============
On the following schema, give me 10 interesting SQL assignment questions in the increasing order of difficulty.
CREATE TABLE Users ( Id integer NOT NULL PRIMARY KEY, Reputation integer NOT NULL, CreationDate date NOT NULL, DisplayName varchar(40) NULL, Views integer NOT NULL, UpVotes integer NOT NULL, DownVotes integer NOT NULL);
CREATE TABLE PostTypes ( PostTypeId integer NOT NULL PRIMARY KEY, Description varchar(250) NULL);
CREATE TABLE Posts ( Id integer NOT NULL PRIMARY KEY, PostTypeId integer NOT NULL references PostTypes, Title varchar(250) NULL, AcceptedAnswerId integer NULL, ParentId integer NULL references Posts(Id), CreationDate date NOT NULL, Score integer NOT NULL, ViewCount integer NULL, OwnerUserId integer NOT NULL references Users(Id), LastEditorUserId integer NOT NULL references Users(Id), Tags varchar(250) NULL);
CREATE TABLE Badges ( Id integer NOT NULL Primary key, UserId integer NOT NULL references Users(Id), Name varchar(50) NOT NULL, Date date NOT NULL, Class integer NOT NULL);
CREATE TABLE Comments ( Id integer NOT NULL PRIMARY KEY, Text varchar(600) NOT NULL, PostId integer NOT NULL references posts(Id), Score integer NOT NULL, CreationDate date NOT NULL, UserId integer NOT NULL references Users(Id)); CREATE TABLE VoteTypes ( VoteTypeId integer NOT NULL PRIMARY KEY, Description varchar(100)); CREATE TABLE Votes ( Id integer PRIMARY KEY, PostId integer NOT NULL references posts(Id), VoteTypeId integer NOT NULL references VoteTypes(VoteTypeId), UserId integer NOT NULL references Users(Id), CreationDate date NULL, BountyAmount integer NULL);


Write a query to find the top 10 users with the highest reputation.
Output columns: DisplayName, Reputation
Order by: Reputation descending

Write a query to find the number of posts with each type of post type (i.e. post type id).
Output columns: PostTypeId, NumPosts
Order by: NumPosts descending

Write a query to find the number of users who have received badges of each class.
Output columns: BadgeClass, NumUsers
Order by: NumUsers descending

Write a query to find the average score of comments for each user.
Output columns: DisplayName, AvgCommentScore
Order by: AvgCommentScore descending

Write a query to find the average number of views per post for each user.
Output columns: DisplayName, AvgViewsPerPost
Order by: AvgViewsPerPost descending

Write a query to find the top 10 users with the most upvotes on their posts.
Output columns: DisplayName, TotalUpVotes
Order by: TotalUpVotes descending

Write a query to find the average number of downvotes per post for each user.
Output columns: DisplayName, AvgDownVotesPerPost
Order by: AvgDownVotesPerPost descending

Write a query to find the top 10 users who have received the most bounties on their posts.
Output columns: DisplayName, TotalBountyAmount
Order by: TotalBountyAmount descending

Write a query to find the average number of comments per post for each user.
Output columns: DisplayName, AvgNumCommentsPerPost
Order by: AvgNumCommentsPerPost descending

Write a query to find the top 10 users with the most accepted answers on their posts.
Output columns: DisplayName, TotalAcceptedAnswers
Order by: TotalAcceptedAnswers descending
