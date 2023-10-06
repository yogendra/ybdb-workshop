## Query tuning tips and tricks

### explain plan
```
\set ea 'explain(analyze, dist, verbose, costs, buffers, timing, summary)'
```

### count(aggregate) pushdown
``` sql
:ea select count(1) from track;
```

### distinct pushdown
```sql
:ea select distinct albumid from track where albumid>0;
```

### expression pushdown
```sql
:ea select * from track where upper(name) like 'THE TROOPER';
```

### hash index
```sql
:ea select * from track where albumid = 0;
```

### range index
```
:ea select * from track where albumid > 0;

create index track_albumid on track(albumid asc);

:ea select * from track where albumid > 0;
```

### covering index
```sql
:ea select * from track where albumid=1;

:ea select trackid, composer from track where albumid=1;

create index track_albumid_1 on track(albumid) include(trackid, composer);
```

### partial index
```
create index employee_city on employee(city) where city not in ('Lethbridge', 'Edmonton');

:ea select * from employee where city='Lethbridge';

:ea select * from employee where city='Calgary';
```

### index forward and backward scan
```sql
create index customer_repid on customer(supportrepid asc);

:ea select * from customer order by supportrepid;

:ea select * from customer order by supportrepid desc;
```

### hints
```sql
:ea
/*+Leading ( ( ( a t ) ar ) ) */
SELECT t.TrackId,
  t.Name AS track_name,
  a.Title AS album_title,
  ar.Name AS artist_name
FROM Track t
  INNER JOIN Album a ON t.AlbumId = a.AlbumId
  INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE t.TrackId = 5;

:ea
/*+Leading ( ( ar ( a t ) ) ) */
SELECT t.TrackId,
  t.Name AS track_name,
  a.Title AS album_title,
  ar.Name AS artist_name
FROM Track t
  INNER JOIN Album a ON t.AlbumId = a.AlbumId
  INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE t.TrackId = 5;
```

### batch nested loop
```sql
set yb_bnl_batch_size=512;

:ea
SELECT p.PlaylistId,
  p.Name AS playlist_name,
  t.Name AS track_name,
  ar.Name AS artist_name
FROM Playlist p
  INNER JOIN PlaylistTrack pt ON p.PlaylistId = pt.PlaylistId
  INNER JOIN Track t ON pt.TrackId = t.TrackId
  INNER JOIN Album a ON t.AlbumId = a.AlbumId
  INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE p.PlaylistId = 3;
```

### prepare statements
```sql
prepare employee_salary(int) as select ename, sal from emp where empno=$1;

execute employee_salary(7900);
```

### common table expression (cte)
```sql
with emp_evaluation_period as (
  select ename,
    deptno,
    hiredate,
    hiredate + case
      when job in ('MANAGER', 'PRESIDENT') then interval '3 month'
      else interval '4 weeks'
    end evaluation_end
  from emp
)
select *
from emp_evaluation_period e1
  join emp_evaluation_period e2 on (e1.ename > e2.ename)
  and (e1.deptno = e2.deptno)
where (e1.hiredate, e1.evaluation_end) overlaps (e2.hiredate, e2.evaluation_end);
```

### recursive cte
```sql
with recursive emp_manager as (
  select empno,
    ename,
    ename as path
  from emp
  where ename = 'JONES'
  union all
  select emp.empno,
    emp.ename,
    emp_manager.path || ' manages ' || emp.ename
  from emp
    join emp_manager on emp.mgr = emp_manager.empno
)
select * from emp_manager;
```

### window functions
```sql
select dname,
  ename,
  job,
  coalesce (
    'hired ' || to_char(
      hiredate - lag(hiredate) over (per_dept_hiredate),
      '999'
    ) || ' days after ' || lag(ename) over (per_dept_hiredate),
    format('(1st hire in %L)', dname)
  ) as "last hire in dept"
from emp
  join dept using(deptno) window per_dept_hiredate as (
    partition by dname
    order by hiredate
  )
order by dname,
  hiredate;
```

### group by
```sql
with groups as (
  select ntile(3) over (
      order by empno
    ) group_num,
    *
  from emp
)
select string_agg(format('<%s> %s', ename, email), ', ')
from groups group by group_num;
```

### procedure
```sql
-- create procedure
create or replace procedure commission_transfer(empno1 int, empno2 int, amount int) as $$
begin
update emp set comm=comm-commission_transfer.amount
  where empno=commission_transfer.empno1 and comm>commission_transfer.amount;
if not found then raise exception 'Cannot transfer % from %',amount,empno1; end if;
update emp set comm=comm+commission_transfer.amount
  where emp.empno=commission_transfer.empno2;
if not found then raise exception 'Cannot transfer from %',empno2; end if;
end;
$$ language plpgsql;

-- call the procedure
call commission_transfer(7521,7654,100);

-- select from emp
select * from emp where comm is not null;

-- call the procedure
call commission_transfer(7521,7654,1000000);
```

### triggers
```sql
-- add column
alter table dept add last_update timestamptz;

-- create trigger
create or replace function dept_last_update() returns trigger as $$
begin
  new.last_update:=transaction_timestamp();
  return new;
end;
$$ language plpgsql;

-- add trigger
create trigger dept_last_update
before update on dept
for each row
execute procedure dept_last_update();

-- select table
select deptno, dname, loc, last_update from dept;

-- update table
begin transaction;
update dept set loc='SUNNYVALE' where deptno=30;
select pg_sleep(3);
update dept set loc='SUNNYVALE' where deptno=40;
commit;

-- select table
select deptno, dname, loc, last_update from dept;
```

### materialized views
```sql
-- create materialized view
create materialized view report_sal_per_dept as
select deptno,
  dname,
  sum(sal) sal_per_dept,
  count(*) num_of_employees,
  string_agg(distinct job, ', ') distinct_jobs
from dept
  join emp using(deptno)
group by deptno,
  dname
order by deptno;

-- create index
create index report_sal_per_dept_sal on report_sal_per_dept(sal_per_dept desc);

-- refresh materialized view
refresh materialized view report_sal_per_dept;

-- select from materialized view
select *
from report_sal_per_dept
where sal_per_dept <= 10000
order by sal_per_dept;

-- explain plan
:ea
select *
from report_sal_per_dept
where sal_per_dept <= 10000
order by sal_per_dept;
```
