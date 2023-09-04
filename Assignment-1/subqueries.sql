select *
from users
where users.userid in 
    (select userid 
     from status
     group by userid
     having count(*) > 5);

with temp as
    (select userid 
     from status
     group by userid
     having count(*) > 5)
select *
from users
where users.userid in (select userid from temp);

select *
from users
where exists
    (select userid
     from status
     where status.userid = users.userid
     group by userid
     having count(*) > 5);

