---------------------------------
--- Social Network Data Set
---------------------------------
-- 1. Draw the query plan for the following query. Very briefly: how well did the
-- estimates match up the actual values?
with temp as (
        select name, count(*) as num_friends 
        from users, friends 
        where users.userid = friends.userid1 
        group by name)
select name, num_friends
from temp 
where num_friends = (select max(num_friends) from temp)
order by name;

-- 2. Draw the query plan for the following query. Very briefly: how well did the
-- estimates match up the actual values?
select name
from users u
where not exists (
        select userid1
        from follows
        where userid2 = u.userid
        intersect
        select u2.userid
        from users u2, members m
        where u2.userid = m.userid and m.groupid = 'group36'
        )
order by u.name;


---------------------------------
--- TPC-H Data Set
--- The first file in TPCH directory will load the entire dataset ("\i tpch-load.sql").
---------------------------------

-- 3. PostgreSQL does not do a good job with the second and third query in the
-- following set, taking more time for (2) than for (1). Explain.
explain analyze select * from lineitem, orders where o_orderkey = l_orderkey;
explain analyze select * from lineitem, orders 
        where extract(year from o_orderdate) = 1996 and o_orderkey = l_orderkey;
explain analyze select * from lineitem, orders 
        where extract(year from o_orderdate) = 1997 and o_orderkey = l_orderkey;

-- 4. Inspite of a very selective join condition (returning a total of 1844
-- rows), the following query does not execute efficiently. Why?  How may
-- you fix it? There is a very easy fix which PostgreSQL suprising does not
-- automatically employ. 
select count(*) from orders, lineitem where l_shipdate - o_orderdate = 1 
        and extract(year from o_orderdate) = 1992;

-- 5. For the following query, explain in some detail why the final result size
-- is underestimated in one case, and overestimated in the other. 
explain analyze select * from supplier,customer 
        where s_nationkey=c_nationkey and s_acctbal < 5000;
explain analyze select * from supplier,customer 
        where s_nationkey=c_nationkey and s_acctbal > 5000;
        
---------------------------------
--- Modified Social Network Database
--- Load using ("\i social_network_med.sql") -- this file does inserts one at a time, 
--- so will take some time to load
---------------------------------


-- 6. The following query takes too long to execute even with a selective predicate.
-- Rewrite the query to run faster by decorrelating it. 
explain analyze select userid from users where extract(year from birthdate) in (1990, 1991) 
           and 5 < (select count(*) from status where status.userid = users.userid)


--- 7. Decorrelate the following query by convering the semijoin (that may be used because of exists) to a
--- join (this can be done because of `userid` at the end (since userid is guaranteed to be distinct in the output).
--- PostgreSQL appears to execute this query reasonably well (a nested loops execution will be much worse) -- 
--- does it seem to do the decorrelation like above, or is it doing something else to achieve that performance?
explain analyze select userid from users u where
        exists(select *
                from friends f1, follows f2, members m
                where u.userid = f1.userid1 and f1.userid2 = f2.userid2 and u.userid = f2.userid1
                      and m.userid = f2.userid2 and m.groupid like 'group1%');

--- 8. PostgreSQL doesn't do a good job with the following query, taking about 14s on my machine.
--- (1) Explicitly decorrelate the query through use of a WITH (i.e., create a non-correlated temporary table using WITH). This seems to reduce the running time by a bit -- 10 on my machine.
--- (2) Use a "magic sets" approach to modify your WITH query to push in the condition on users. Be careful -- the result here may have duplicates (if two users who satisfy the condition both joined on the same date).
--- This reduced the running time to 347ms on my machine

explain analyze select joined from users u where
extract(year from u.birthdate) = 1990 and
5 < (select count(*)
        from friends f, status s, likes l, members m, users u2
        where u.userid = f.userid1 and s.userid = f.userid2 and l.userid = f.userid2 and m.userid = f.userid2 and extract(year from u2.birthdate) = 1990 and u2.userid =
        f.userid1);


====== SOLUTION
with temp as (
    select f.userid1 as userid, count(*) as c
    from friends f, status s, likes l, members m
    where s.userid = f.userid2 and l.userid = f.userid2 and m.userid = f.userid2 and extract(year from u2.birthdate) = 1990 
    group by f.userid1
    ) 
select joined from users u, temp t where
extract(year from u.birthdate) = 1990 and u.userid = t.userid and t.c > 5;

with temp as (
    select f.userid1 as userid, count(*) as c
    from friends f, status s, likes l, members m, users u2
    where s.userid = f.userid2 and l.userid = f.userid2 and m.userid = f.userid2 and extract(year from u2.birthdate) = 1990 and u2.userid = f.userid1
    group by f.userid1
    ) 
select joined from users u, temp t where
extract(year from u.birthdate) = 1990 and u.userid = t.userid and t.c > 5;
