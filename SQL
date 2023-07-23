CREATE SCHEMA public;

ALTER SCHEMA public OWNER TO postgres;
COMMENT ON SCHEMA public IS 'standard public schema';

CREATE TYPE public.activity_type AS ENUM (
    'lecture',
    'tutorial',
    'computer_lab',
    'lab',
    'office_hours'
);
ALTER TYPE public.activity_type OWNER TO postgres;

--
CREATE TYPE public.course_dependency_mode_type AS ENUM (
    'required',
    'recommended'
);
ALTER TYPE public.course_dependency_mode_type OWNER TO postgres;

--

CREATE TYPE public.isarelation AS ENUM (
    'Professor',
    'Student',
    'LabStaff'
);
ALTER TYPE public.isarelation OWNER TO postgres;
--


CREATE TYPE public.level_type AS ENUM (
    'A',
    'B',
    'C',
    'D'
);
ALTER TYPE public.level_type OWNER TO postgres;
--


CREATE TYPE public.rank_type AS ENUM (
    'full',
    'associate',
    'assistant',
    'lecturer'
);
ALTER TYPE public.rank_type OWNER TO postgres;
--

CREATE TYPE public.register_status_type AS ENUM (
    'proposed',
    'requested',
    'approved',
    'rejected',
    'pass',
    'fail'
);
ALTER TYPE public.register_status_type OWNER TO postgres;
--

CREATE TYPE public.role_type AS ENUM (
    'responsible',
    'participant'
);
ALTER TYPE public.role_type OWNER TO postgres;
--


CREATE TYPE public.rolee AS ENUM (
    'responsible',
    'participant'
);
ALTER TYPE public.rolee OWNER TO postgres;
--


CREATE TYPE public.roomtype AS ENUM (
    'lecture_room',
    'computer_room',
    'lab_room',
    'office'
);
ALTER TYPE public.roomtype OWNER TO postgres;
--


CREATE TYPE public.semester_season_type AS ENUM (
    'winter',
    'spring'
);
ALTER TYPE public.semester_season_type OWNER TO postgres;
--

CREATE TYPE public.semester_status_type AS ENUM (
    'past',
    'present',
    'future'
);
ALTER TYPE public.semester_status_type OWNER TO postgres;
--


CREATE FUNCTION public.activities_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
holder integer;
BEGIN

--select * from "participates" where start_time = 11 and end_time = 13 and weekday = 2 and room_id = '145Π52' and course_code = 'ΦΥΣ 102' and serial_number = 10;


	IF (TG_OP = 'UPDATE') THEN
	
	--check cases for start time update
	--if both has changed
	if new.start_time <> old.start_time and new.end_time <> old.end_time and new.start_time <= new.end_time - 1 then
		holder:=1;
		update "participates"
	set start_time = new.start_time, end_time = new.end_time
	where start_time = old.start_time and end_time = old.end_time and weekday = old.weekday and room_id = old.room_id and course_code = old.course_code and serial_number = old.serial_number;

	raise notice 'successful update of start and end time 1';
	
	--if only start time has changed
	
	elsif new.start_time <> old.start_time and new.start_time <= old.end_time - 1 then
	holder:=2;
	update "participates"
	set start_time = new.start_time
	where start_time = old.start_time and end_time = old.end_time and weekday = old.weekday and room_id = old.room_id and course_code = old.course_code and serial_number = old.serial_number;

	raise notice 'successful update of start time 1';
	
	--if only end time has changed
	
	elsif new.end_time <> old.end_time and new.end_time >= old.start_time + 1 then
	holder:=3;
	update "participates"
	set end_time = new.end_time
	where start_time = old.start_time and end_time = old.end_time and weekday = old.weekday and room_id = old.room_id and course_code = old.course_code and serial_number = old.serial_number;
	
	raise exception 'successful update of end time 1';
	
	elsif (new.start_time <> old.start_time) or (new.end_time <> old.end_time) then
	holder:=4;
	raise exception 'invalid update of start and end time ';
	
	end if;
	
	--check cases for week day update
	if new.weekday <> old.weekday and new.weekday >0 and new.weekday <6 then
	
	
		if holder = 1 then
	update "participates"
	set weekday = new.weekday
	where start_time = new.start_time and end_time = new.end_time and weekday = old.weekday and room_id = old.room_id and coursecode = old.course_code and serial_number = old.serial_number;

elsif holder = 2 then
update "participates"
	set weekday = new.weekday
	where start_time = new.start_time and end_time = old.end_time and weekday = old.weekday and room_id = old.room_id and coursecode = old.course_code and serial_number = old.serial_number;

elsif holder = 3 then

update "participates"
	set weekday = new.weekday
	where start_time = old.start_time and end_time = new.end_time and weekday = old.weekday and room_id = old.room_id and coursecode = old.course_code and serial_number = old.serial_number;

		
	end if;
		
	raise notice 'successful update of week day';
	
		elsif  (new.weekday <> old.weekday) and (new.weekday <0 or new.weekday >6) then
		
			raise exception 'invalid week day';
			
		end if;
	
	

		if new.room_id not in (select room_id from "LearningActivity" where start_time = new.start_time and end_time = new.end_time and weekday = new.weekday) then

raise notice 'room of new activity is available';

elsif new.room_id in (select room_id from "LearningActivity" where start_time = new.start_time and end_time = new.end_time and weekday = new.weekday) then
raise exception 'room of new activity is not available';

end if;		 
	ELSIF (TG_OP = 'INSERT') THEN
	if new.start_time > new.end_time - 1 then
	raise exception 'invalid insert of start time or end time';
	end if;

	if new.weekday <0 or new.weekday >6 then
	raise exception 'invalid insert of week day';
	end if;
		if new.room_id not in (select room_id from "LearningActivity" where start_time = new.start_time and end_time = new.end_time and weekday = new.weekday) and new.start_time <= new.end_time - 1 and new.weekday >0 and new.weekday <=6 then
raise notice 'room of new activity is available';
raise notice 'successful insert of new record';

elsif new.room_id in (select room_id from "LearningActivity" where start_time = new.start_time and end_time = new.end_time and weekday = new.weekday) then
raise exception 'room of new activity at start time: %, end time: %, week day: % is not available', new.start_time, new.end_time, new.weekday;

end if;	 
	END IF;
	return new;
END;
$$;
ALTER FUNCTION public.activities_update() OWNER TO postgres;

--


CREATE FUNCTION public.adapt_surname(surname character, sex character) RETURNS character
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
result character(50);
BEGIN
result = surname;
IF right(surname,2)<>'ΗΣ' THEN
RAISE NOTICE 'Cannot handle this surname';
ELSIF sex='F' THEN
result = left(surname,-1);
ELSIF sex<>'M' THEN
RAISE NOTICE 'Wrong sex parameter';
END IF;
RETURN result;
END;
$$;
ALTER FUNCTION public.adapt_surname(surname character, sex character) OWNER TO postgres;
--


CREATE FUNCTION public.check_type(amkaa integer, typee character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
     DECLARE
	 isfound boolean = false;
     BEGIN
       IF typee = 'Student' THEN
          select count(*)=1 into isfound FROM "Student" s WHERE s.amka = amkaa;
       ELSIF typee = 'Professor' THEN
          select count(*)=1 into isfound FROM "Professor" p WHERE p.amka = amkaa;
	    ELSIF typee = 'LabStaff' THEN
          select count(*)=1 into isfound FROM "LabStaff" l WHERE l.amka = amkaa;
       END IF;
       RETURN isfound;
     END;
  $$;


ALTER FUNCTION public.check_type(amkaa integer, typee character varying) OWNER TO postgres;
--


CREATE FUNCTION public.create_am(year integer, num integer) RETURNS character
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
RETURN concat(year::character(4),lpad(num::text,6,'0'));
END;
$$;
ALTER FUNCTION public.create_am(year integer, num integer) OWNER TO postgres;
--


CREATE FUNCTION public.fillfinalgrades() RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
UPDATE "Register"
SET final_grade = ceil(random()* (10-1 + 1) + 1);
END;
$$;
ALTER FUNCTION public.fillfinalgrades() OWNER TO postgres;
--


CREATE FUNCTION public.filllabgrades() RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN
UPDATE "Register"
SET lab_grade = ceil(random()* (10-1 + 1) + 1);
END;
$$;
ALTER FUNCTION public.filllabgrades() OWNER TO postgres;
--


CREATE FUNCTION public.insert_1000_students_per_year(yearstart integer, yearfinish integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	year integer;
	round integer;
BEGIN
	FOR year in yearstart..yearfinish LOOP
		FOR round in 1..5 LOOP
			PERFORM insert_students(year,200,200*(round-1)+1);
		END LOOP;
	END LOOP;
END;
$$;
ALTER FUNCTION public.insert_1000_students_per_year(yearstart integer, yearfinish integer) OWNER TO postgres;
--


CREATE FUNCTION public.insert_participates(n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
counter INTEGER := 0 ; --counter of the loop
startt integer;
endd integer;
amkaR integer;
j numeric:=1;
yearInt integer;
ch character varying;
nameR  character varying;
random_role role_type;
roleAsType character varying;
activ activity_type;
activAsCh character varying;
BEGIN
--none insertion
IF (n < 1)
THEN RETURN  ;
END IF;

LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
j := j + 0.5 ;
yearInt:=(select  nextval('"year_seq"') );
startt:=(select nextval('"start_time"')::integer);
--select different start time and insert a logical number of end time
case
when startt<15 then endd=startt+2;
when startt<20 then endd=startt+1;
else endd=20;
end case;
--choose random role
random_role:=(SELECT role
FROM (
SELECT unnest(enum_range(NULL::role_type)) as role
)rol
ORDER BY random()
LIMIT 1 );
--convert from enum to character
roleAsType:=(select cast(random_role as character varying));



nameR:=(SELECT name from random_names(floor(random()* (0+ 808000000) )::integer) limit 1 );

activ:=(SELECT activity_type
FROM (
SELECT unnest(enum_range(NULL::activity_type)) as activity_type
)ac
ORDER BY random()
LIMIT 1);
activAsCh:=(select cast(activ as character varying));
case
when(roleAsType='participant') then
ch=(select concat ('s' ,(select create_am  from create_am(yearInt ,
(select cast ( nextval('"student_am"') as integer )))),'@isc.tuc.gr'));
when(activAsCh like '%lab') then
ch=(select concat ('l' ,(select create_am from create_am((select nextval('"year_seq"')::integer),
(select cast (nextval('"labstaff_am"') as integer )) )),'@isc.tuc.gr'));
else ch=(select concat ('p' ,(select create_am  from create_am(
(select nextval('"year_seq"')::integer),(select cast (nextval('"prof_am"') as integer )))),
'@isc.tuc.gr'));
end case;
--choose professor student or labstaff amka
case
when (activAsCh like '%lab') then amkaR=nextval('"LabStaff_amka_seq"')::integer;
when roleAsType='responsible' then amkaR=nextval('"Professor_amka_seq"')::integer;
else amkaR=nextval('"Student_amka_seq"')::integer;
end case;

insert into "participates"
values(
--role
random_role,
--amka
amkaR,
--email
ch,
--name
nameR,
--father_name
(SELECT name
from  random_names(20000)  
where sex like 'M'
limit 1),
--surname
(select adapt_surname
from adapt_surname((select surname
from random_surnames(20)
limit 1),
(SELECT sex  
FROM "Name"
where name=nameR)
  )
),
--activity_type
activ,
--start_time
startt,
--end_time
endd,
--weekday
(select * from random_weekday(j)),
--type
'verified')
ON CONFLICT(amka) Do
UPDATE
SET amka=nextval('"LabStaff_amka_seq"')::integer;
end loop;
END;
$$;
ALTER FUNCTION public.insert_participates(n integer) OWNER TO postgres;
--


CREATE FUNCTION public.insert_participates2(n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
counter INTEGER := 0 ; --counter of the loop
startt integer;
endd integer;
amkaR integer;
j numeric:=1;
yearInt integer;
ch character varying;
nameR  character varying;
random_role role_type;
roleAsType character varying;
activ activity_type;
activAsCh character varying;
isaRel isaRelation;
tempweek integer;
ser_num integer;
c_code character varying;
r_id character varying;
BEGIN
--none insertion
IF (n < 1)
THEN RETURN  ;
END IF;

LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
j := j + 0.5 ;

--choose random role
random_role:=(SELECT role
FROM (
SELECT unnest(enum_range(NULL::role_type)) as role
)rol
ORDER BY random()
LIMIT 1 );
--convert from enum to character
roleAsType:=(select cast(random_role as character varying));
--random_role:=(SELECT role FROM ( SELECT unnest(enum_range(NULL::role_type)) as role)r ORDER BY random() LIMIT 1);



activ:=(SELECT activity_type
FROM (
SELECT unnest(enum_range(NULL::activity_type)) as activity_type
)ac
ORDER BY random()
LIMIT 1);
activAsCh:=(select cast(activ as character varying));


isaRel:=(SELECT type_ FROM ( SELECT unnest(enum_range(NULL::isaRelation)) as type_)isa ORDER BY random() LIMIT 1);
  
IF isaRel = 'Student' THEN
          amkaR:=(select amka
from "Student" 
order by random() limit 1);

       ELSIF isaRel = 'Professor' THEN
	   amkaR:=(select amka
from "Professor" 
order by random() limit 1);
 
	    ELSIF isaRel = 'LabStaff' THEN
		amkaR:=(select amka
from "LabStaff" 
order by random() limit 1);

       END IF;
	   
--tempweek := (select * from random_weekday(j));

startt := (select start_time
from "LearningActivity" 
order by random() limit 1);

endd := (select end_time
from "LearningActivity" 
where start_time = startt
order by random() limit 1);

tempweek := (select weekday
from "LearningActivity" 
where start_time = startt and end_time = endd
order by random() limit 1);

r_id := (select room_id
from "LearningActivity"
where start_time = startt and end_time = endd and weekday = tempweek
order by random() limit 1);

c_code:=(select course_code
from "LearningActivity"
where start_time = startt and end_time = endd and weekday = tempweek and room_id = r_id
order by random() limit 1);

ser_num:=(select serial_number
from "LearningActivity" 
where start_time = startt and end_time = endd and weekday = tempweek and room_id = r_id and course_code = c_code
order by random() limit 1);

if (select exists(select 1 from "participates" where amka = amkaR and start_time = startt and end_time = endd and weekday = tempweek and serial_number = ser_num and course_code = c_code)) = true then
continue;
end if;

--if (select exists(select 1 from "participates" where amka = amkaR)) = true then
--continue;
--end if;

insert into "participates"
values(
--role
random_role,
--amka
amkaR,
--start_time
startt,
--end_time
endd,
--weekday
tempweek,
--room_id
r_id ,
--course_code
c_code,
--serial_number
ser_num,
--type
isaRel
);

end loop;
END;
$$;
ALTER FUNCTION public.insert_participates2(n integer) OWNER TO postgres;
--

CREATE FUNCTION public.insert_students(year integer, num integer, startam integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	CREATE SEQUENCE IF NOT EXISTS am_sequence;
	PERFORM setval('am_sequence',startam,false);
		
	INSERT INTO "Student"(amka,name,father_name,surname,email,am,entry_date)
	SELECT nextval('amka_sequence'), n.name, f.father_name,
		adapt_surname(s.surname,n.sex),
		currval('amka_sequence')::text||'@ced.tuc.gr', 
		create_am(year,nextval('am_sequence')::integer), 
					(year::text||'-09-01')::date
	FROM random_names(num) n NATURAL JOIN random_surnames(num) s 
		NATURAL JOIN random_father_names(num) f;
	
END;
$$;


ALTER FUNCTION public.insert_students(year integer, num integer, startam integer) OWNER TO postgres;
--


CREATE FUNCTION public.insertelementsinparticipates() RETURNS void
    LANGUAGE plpgsql
    AS $$

declare 
activ activity_type:=(SELECT activity_type
FROM (
SELECT unnest(enum_range(NULL::activity_type)) as activity_type
)ac
ORDER BY random()
LIMIT 1);
--------------------
name text:='spiros';--random_names(1);
--------------------
surname text:='pisso';--random_surnames(1);
--------------------
father_name text:='spi';--random_names(1);
--------------------
email text:= concat(name, '@hotmail.com');
--------------------
am integer := floor(random()* (10000-1 + 1) + 1);
--------------------
begin 

for j in 1..500 loop


if j>300 then
insert into Participates values('participant', am, email,name,father_name, surname, 'lecture', 9, 5, 'monday', 'Student');

elsif j>150 then
insert into Participates values('responsible', am, email,name,father_name, surname, 'lecture', 9, 5, 'monday', 'LabStaff');

elsif j>=1 then
insert into Participates values('responsible', am, email,name,father_name, surname, 'lecture', 9, 5, 'monday', 'Professor');
end if;
end loop;
end; $$;

ALTER FUNCTION public.insertelementsinparticipates() OWNER TO postgres;

--

CREATE FUNCTION public.insertelementsinroom() RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
j integer :=1;
begin
for i in 1..50
loop
if i<10 then
insert into Room values(concat('145Π5',i),'lecture_room', (nextval('"room_capacity_seq"')::integer));
elsif i<=15 then
insert into Room values(concat('PC_ROOM',i),'computer_room',33);
elsif i<=25 then
insert into Room values(concat('LAB',i),'lab_room',16);
elsif i<=50 then
insert into Room values(concat('OFFICE',i),'office',j+1);
end if;
end loop;
end; $$;


ALTER FUNCTION public.insertelementsinroom() OWNER TO postgres;

--


CREATE FUNCTION public.insertlearningactivity(n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
counter INTEGER := 0 ; --counter of the loop
j numeric:=1;--counter for choosing random weekday from the function random_weekday
 startt integer;
 endd integer;
-- random_role character varying;
activ activity_type;
course character(7);
lab_hours integer;
lecture_hours integer;
tutorial_hours integer;
place character varying;
tempweek integer;
BEGIN
--none insertion
IF (n < 1) THEN
RETURN ;
END IF;
LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
j := j + 0.5 ;

 course:=(select course_code  from "Course" order by random() limit 1);
lab_hours:=(select co.lab_hours from "Course" co where co.course_code=course);
lecture_hours:=(select co.lecture_hours from "Course" co where co.course_code=course);
tutorial_hours:=(select co.tutorial_hours from "Course" co where co.course_code=course);
 case
 when n<20 and lab_hours!=0 then activ='computer_lab';
 when n>20 and lab_hours!=0 then activ='lab';
 when lecture_hours!=0 then activ='lecture';
 when tutorial_hours!=0 then activ='tutorial';
 else activ='office_hours';
 end case;

case
when activ='computer_lab' then place=(select room_id from "room" where room_id like 'PC%' order by random() limit 1);
when activ='lab' then place=(select room_id from "room" where room_id like 'LAB%' order by random() limit 1);
when activ='lecture' or activ='tutorial' then  place=(select room_id from "room" where room_id like '145%' order by random() limit 1);
else  place=(select room_id from "room" where room_id like 'OFFICE%' order by random() limit 1);
end case;

 startt:=(select nextval('"start_time"')::integer);
-- --random_role:=(SELECT role FROM ( SELECT unnest(enum_range(NULL::role_type)) as role)rol ORDER BY random() LIMIT 1);

 case
 when startt<15 then endd=startt+2;
 when startt<20 then endd=startt+1;
else endd=20;
end case;

tempweek:=(select * from random_weekday(j) );

if (select exists(select 1 from "LearningActivity" where weekday = tempweek and start_time = startt and end_time = endd)) = true then
continue;
end if;

insert into "LearningActivity"
values(
--activity_type
activ,
---start_time
startt,
--end time
endd,
--weekday
tempweek,--(select * from random_weekday(j) ),
--takesplace
place,
---participant
(select amka from "participates" order by random() limit 1),
--containsCourse
course
);
END LOOP ;


END;
$$;


ALTER FUNCTION public.insertlearningactivity(n integer) OWNER TO postgres;

--

CREATE FUNCTION public.insertlearningactivity2(n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
counter INTEGER := 0 ; --counter of the loop
j numeric:=1;--counter for choosing random weekday from the function random_weekday
 startt integer;
 endd integer;
-- random_role character varying;
activ activity_type;
course character(7);
lab_hours integer;
lecture_hours integer;
tutorial_hours integer;
place character varying;
tempweek integer;
ser_num integer;
c_code character varying;
BEGIN
--none insertion
IF (n < 1) THEN
RETURN ;
END IF;
LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
j := j + 0.5 ;

 course:=(select course_code  from "Course" order by random() limit 1);
lab_hours:=(select co.lab_hours from "Course" co where co.course_code=course);
lecture_hours:=(select co.lecture_hours from "Course" co where co.course_code=course);
tutorial_hours:=(select co.tutorial_hours from "Course" co where co.course_code=course);
 case
 when n<20 and lab_hours!=0 then activ='computer_lab';
 when n>20 and lab_hours!=0 then activ='lab';
 when lecture_hours!=0 then activ='lecture';
 when tutorial_hours!=0 then activ='tutorial';
 else activ='office_hours';
 end case;

case
when activ='computer_lab' then place=(select room_id from "room" where room_id like 'PC%' order by random() limit 1);
when activ='lab' then place=(select room_id from "room" where room_id like 'LAB%' order by random() limit 1);
when activ='lecture' or activ='tutorial' then  place=(select room_id from "room" where room_id like '145%' order by random() limit 1);
else  place=(select room_id from "room" where room_id like 'OFFICE%' order by random() limit 1);
end case;

 startt:=(select nextval('"start_time"')::integer);
-- --random_role:=(SELECT role FROM ( SELECT unnest(enum_range(NULL::role_type)) as role)rol ORDER BY random() LIMIT 1);

 case
 when startt<15 then endd=startt+2;
 when startt<20 then endd=startt+1;
else endd=20;
end case;

tempweek:=(select * from random_weekday(j) );

c_code:=(select course_code
from "CourseRun" 
order by random() limit 1);

ser_num:=(select serial_number
from "CourseRun" 
where course_code = c_code
order by random() limit 1);

if (select exists(select 1 from "LearningActivity" where weekday = tempweek and start_time = startt and end_time = endd and course_code = c_code and serial_number = ser_num and room_id = place)) = true then
continue;
end if;

--if (select exists(select 1 from "LearningActivity" where weekday = tempweek and start_time = startt and end_time = endd)) = true then
--continue;
--end if;

insert into "LearningActivity"
values(
--activity_type
(SELECT myletter FROM unnest(enum_range(NULL::activity_type)) myletter ORDER BY random() LIMIT 1),
---start_time
startt,
--end time
endd,
--weekday
tempweek,--(select * from random_weekday(j) ),
--takesplace
place,
	
--course_code
c_code,--(select course_code from "Course" order by random() limit 1),
	

--serial number
ser_num--(select serial_number from "CourseRun" order by random() limit 1)
);
END LOOP ;

END;
$$;


ALTER FUNCTION public.insertlearningactivity2(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.query_3_1_insertlabstaff(n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    declare
nam character varying;
counter INTEGER := 0 ; --counter of the loop/of the inserts in the table of labstaff
BEGIN
--none insertion
IF (n < 1) THEN
RETURN  ;
END IF;

LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
--select random name
nam:= (SELECT name
  from random_names(floor(random()* (0+ 808000000) )::integer)
  limit 1 );
insert into "LabStaff"
values(
--amka
(SELECT MAX(amka+1)
FROM (
SELECT amka
FROM "LabStaff"
GROUP BY amka)
s),
--name
                nam,
--fathers name
(SELECT name
from  random_names(20000)--random number  
where sex like 'M'
limit 1),
--surname
(select adapt_surname
from adapt_surname((select surname
from random_surnames(n)
limit 1),
(SELECT sex  
FROM "Name"
where name=nam)
  )
),
--email
(select concat ('l' ,
(select create_am
from create_am((select nextval('"year_seq"')::integer),
(select cast (nextval('"labstaff_am"') as integer ))
  )),
'@isc.tuc.gr')
),
--labWorks
(SELECT floor(random()* 10 + 1 )),
--rank
(SELECT rank
FROM ( SELECT unnest(enum_range(NULL::level_type)) as rank)sub
ORDER BY random()
LIMIT 1)
);
END LOOP ;


END;
$$;


ALTER FUNCTION public.query_3_1_insertlabstaff(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.query_3_1_insertprofessor(n integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    declare
Proname  character varying :='';
counter INTEGER := 0 ; --counter of the loop/of the inserts in the table of professors
BEGIN
--none insertion
IF (n < 1) THEN
RETURN  ;
END IF;

LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
--pick random name
Proname:= (SELECT name
  from random_names(floor(random()* (0+ 808000000) )::integer)
  limit 1 );
insert into "Professor"
values(
--amka
(SELECT MAX(amka+1)
FROM (
SELECT amka
FROM "Professor"
GROUP BY amka)
s),
--name
                Proname,
--fathers name
(SELECT name
from  random_names(20000)  --random number to find a random name with sex='M' means male
where sex like 'M'
limit 1),
--surname
(select adapt_surname
from adapt_surname((select surname
from random_surnames(n)
limit 1),
(SELECT sex  
FROM "Name"
where name=Proname)
  )
),
--email
(select concat ('p' ,
(select create_am
from create_am((select nextval('"year_seq"')::integer),
(select cast (nextval('"prof_am"') as integer ))
  )),
'@isc.tuc.gr')
),
--labJoins
(SELECT floor(random()* (10 + 1) )),
--rank
(SELECT rank FROM (
SELECT unnest(enum_range(NULL::rank_type)) as rank)sub
ORDER BY random()
LIMIT 1)
);
END LOOP ;


END;
$$;


ALTER FUNCTION public.query_3_1_insertprofessor(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.query_3_1_insertstudent(n integer, yearint integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    declare
Stuname character varying;
counter integer := 0 ; --counter of the loop/of the inserts in the table of student
BEGIN
--if none insertion
IF (n < 1) THEN
RETURN  ;
END IF;

LOOP
EXIT WHEN counter = n ;
counter := counter + 1 ;
--select random name
Stuname:= (SELECT name
  from random_names(floor(random()* (0+ 808000000) )::integer)
  limit 1 );
insert into "Student"
values(
--amka
(SELECT MAX(amka+1)
FROM (
SELECT amka
FROM "Student"
GROUP BY amka)
s),
--name
                Stuname,
--father's name
(SELECT name
from  random_names(20000)  --random number to take a random name with sex='M' means male
where sex like 'M'
limit 1),
--surname
(select adapt_surname
from adapt_surname((select surname
from random_surnames(n)
limit 1),
(SELECT sex  
FROM "Name"
where name=Stuname)
  )
),
--email
(select concat ('s' ,
(select create_am
from create_am(yearInt ,
(select cast ( nextval('"student_am"') as integer ))
  )
),
'@isc.tuc.gr')
),
--am
(select create_am
from create_am(yearInt,
(select cast (nextval('"student_am"') as integer)))
),
--enty date
(select to_date((concat (to_char(yearInt, '9999') ,'-09-10')), 'YYYY-MM-DD') )
);
END LOOP ;


END;
$$;


ALTER FUNCTION public.query_3_1_insertstudent(n integer, yearint integer) OWNER TO postgres;

--


CREATE FUNCTION public.query_3_2(season public.semester_season_type) RETURNS void
    LANGUAGE plpgsql
    AS $$

begin 

------------------------- update exam grades from Register -------------------------
UPDATE "Register"
SET exam_grade = ceil(random()* (10-1 + 1) + 1)
FROM "Register" reg , "Course" cour
where reg.course_code = cour.course_code and cour.typical_season = season and reg.exam_grade = null;
------------------------------------------------------------------------------------

-------------------------- update lab grades from Register --------------

UPDATE "Register"

SET lab_grade = ceil(random()* (10-1 + 1) + 1)

FROM "Register" reg , "Course" cour
where reg.course_code = cour.course_code and cour.typical_season = season and reg.lab_grade < 5;
----------------------------------------------------
end; $$;


ALTER FUNCTION public.query_3_2(season public.semester_season_type) OWNER TO postgres;

--


CREATE FUNCTION public.query_3_3(course character) RETURNS void
    LANGUAGE plpgsql
    AS $$
	DECLARE
	lab_hours int:=(select this.lab_hours
					from "Course" this
					where this.course_code=course );
	lecture_hours int:=(select this.lecture_hours
						from "Course" this
						where this.course_code=course);
	tutorial_hours int:=(select this.tutorial_hours
						 from "Course" this
						 where this.course_code=course);
	startt int;
	room character varying;
	j numeric:=(SELECT random() * 100);
	week smallint;
	ser integer;

begin
--check if the course doesnt have hours for lecture
if (lecture_hours!=0 and
	case
	--the insertion already exists
	when( 'lecture_hours'=ANY(select  cast (activity_type as character varying) as type_ac
								from "LearningActivity"
								where course_code=course
		) )then false
	--if the table is empty
	when ( select count(course_code)
	  		from "LearningActivity"
			where course_code=course)=0 then true
	else false end)  
	then startt:=(select nextval('"start_time"')::integer);

	--check bounds for picking right hours
	  if (startt+lecture_hours>20) then
	  	startt:=8;
	  end if;
	week:= (select random_weekday(j));
	room:= (select ro.room_id
	  		from "room" ro
	 		where ro.room_type='lecture_room'
	  		order by random()
	  		limit 1 );
	ser:=(	select cr.serial_number
	 	  	from "CourseRun" cr
	 	   	where cr.course_code=course
		 	order by random()
		 	limit 1 );

	--find available room in a specific weekday, start_time and end_time
	WHILE (select 1
	  from "LearningActivity" la
	  where la.start_time=startt
	  and la.end_time=startt+lecture_hours
	  and la.weekday=week
	  and la.room_id=room)= 1
	LOOP
	--check bounds
	if (startt+tutorial_hours>20) then
	startt:=8;
	else  
	startt:=startt+1;
	week:=week+1;
end if;
END LOOP;
--insert lecture
insert into "LearningActivity"
values('lecture',startt,startt+lecture_hours,week,room,course,ser)
on conflict do nothing;
end if;

--check if the course doesnt have hours for lab or the insertion already exists
if (lab_hours!=0 and
case
--the insertion already exists
when('lab_hours'=ANY(select  cast (activity_type as character varying) as type_ac
from "LearningActivity"
where course_code=course
) )then false
--if the table is empty
when ( select count(course_code)
  from "LearningActivity"
where course_code=course)=1 then true else false end)  then
--find random hours and day
j :=(SELECT random() * 100);
startt:=(select nextval('"start_time"')::integer);
--check bounds
  if (startt+lab_hours>20) then
  startt:=8;
  end if;
week:= (select random_weekday(j));
room:= (select ro.room_id from "room" ro where ro.room_type='lab_room' order by random() limit 1 );
ser:=(select cr.serial_number from "CourseRun" cr where cr.course_code=course order by random() limit 1 );
WHILE (select 1
  from "LearningActivity" la
  where la.start_time=startt
  and la.end_time=startt+lab_hours
  and la.weekday=week
  and la.room_id=room)= 1 LOOP
--check bounds
if (startt+tutorial_hours>20) then
startt:=8;
else  
startt:=startt+1;
week:=week+1;
end if;
END LOOP;
--insert lab
 insert into "LearningActivity"
values('lab',startt,startt+lab_hours,week,room,course,ser)
  on conflict do nothing;
end if;

--check if the course doesnt have hours for tutorial or the insertion already exists
if (tutorial_hours!=0 and case
--the insertion already exists
when('tutorial_hours'=ANY(select  cast (activity_type as character varying) as type_ac
from "LearningActivity"
where course_code=course
) )then false
--if the table is empty
when ( select count(course_code)
  from "LearningActivity"
where course_code=course)=2 then true
else false end)  then
--find random hours and day
j :=(SELECT random() * 100);
startt:=(select nextval('"start_time"')::integer);
--check bounds for picking right hours
  if (startt+lecture_hours>20) then
  startt:=8;
  end if;
week:= (select random_weekday(j));
room:=  (select ro.room_id from "room" ro where ro.room_type='lecture_room' order by random() limit 1 );
ser:=(select cr.serial_number from "CourseRun" cr where cr.course_code=course order by serial_number limit 1 );
WHILE (select 1
  from "LearningActivity" la
  where la.start_time=startt
  and la.end_time=startt+tutorial_hours
  and la.weekday=week
  and la.room_id=room)= 1 LOOP
--check bounds
if (startt+tutorial_hours>20) then
startt:=8;
else  
startt:=startt+1;
week:=week+1;
end if;
END LOOP;
--insert tutorial
 insert into "LearningActivity"
 values('tutorial',startt,startt+tutorial_hours,week,room,course,ser)
 on conflict do nothing;
end if;
end;
$$;


ALTER FUNCTION public.query_3_3(course character) OWNER TO postgres;

--


CREATE FUNCTION public.query_4_1() RETURNS TABLE(name character, surname character, amka integer, capacity integer)
    LANGUAGE plpgsql
    AS $$
begin
return query
select pr.name, pr.surname, pr.amka,  r.capacity
FROM ("Professor" pr natural join "participates" par) join  "room" r using(room_id)
where r.capacity>=30 
union
select ls.name, ls. surname, ls.amka, r.capacity
FROM ("LabStaff" ls natural join "participates" par) join  "room" r using(room_id)
where r.capacity>=30;
 
	  
END;
$$;


ALTER FUNCTION public.query_4_1() OWNER TO postgres;

--


CREATE FUNCTION public.query_4_10(mincap integer, maxcap integer) RETURNS TABLE(amka integer)
    LANGUAGE plpgsql
    AS $$
     DECLARE
-- room character varying ;
begin
return query

select par.amka
from "participates" par
where par.type_='Professor'
and par.room_id=ANY((select sel.room_id
from "room" sel
where sel.capacity>=minCap
and sel.capacity<=maxCap
and sel.room_type='lecture_room'));

end;
$$;


ALTER FUNCTION public.query_4_10(mincap integer, maxcap integer) OWNER TO postgres;

--

CREATE FUNCTION public.query_4_2() RETURNS TABLE(name character, surname character, course_code character varying, weekday smallint, start_time integer, end_time integer)
    LANGUAGE plpgsql
    AS $$
begin
return query
select pr.name, pr.surname,la.course_code, la.weekday, la.start_time, la.end_time
FROM ("Professor" pr natural join "participates" par) natural join ("LearningActivity" la natural join "CourseRun" run)-- using(course_code))
where la.activity_type = 'office_hours' and run.semesterrunsin=(select semester_id from "Semester" where semester_status='present')
order by pr.name, pr.surname;

END;
$$;


ALTER FUNCTION public.query_4_2() OWNER TO postgres;

--


CREATE FUNCTION public.query_4_3(gr_categ text, season public.semester_season_type) RETURNS TABLE(course_title character, exam_grade numeric)
    LANGUAGE plpgsql
    AS $$
begin

if gr_categ = 'exam_grade' then
return query
select cour.course_title, reg.exam_grade
FROM "Register" reg , "Course" cour
where reg.course_code = cour.course_code and cour.typical_season = season and reg.exam_grade>=ALL
(select reg.exam_grade from "Register" reg , "Course" cour where cour.typical_season = season group by reg.course_code,reg.exam_grade)
group by cour.course_title, reg.exam_grade
order by reg.exam_grade desc ;

elsif gr_categ = 'final_grade' then
return query
select cour.course_title, reg.final_grade
FROM "Register" reg , "Course" cour
where reg.course_code = cour.course_code and cour.typical_season = season and reg.final_grade>=ALL
(select reg.final_grade from "Register" reg , "Course" cour where cour.typical_season = season group by reg.course_code,reg.final_grade)
group by cour.course_title, reg.final_grade
order by reg.final_grade desc ;

elsif gr_categ = 'lab_grade' then
return query
select cour.course_title, reg.lab_grade
FROM "Register" reg , "Course" cour
where reg.course_code = cour.course_code and cour.typical_season = season and reg.lab_grade>=ALL
(select reg.lab_grade from "Register" reg , "Course" cour where cour.typical_season = season group by reg.course_code,reg.lab_grade)
group by cour.course_title, reg.lab_grade
order by reg.lab_grade desc ;

end if;

END;
$$;


ALTER FUNCTION public.query_4_3(gr_categ text, season public.semester_season_type) OWNER TO postgres;

--


CREATE FUNCTION public.query_4_4() RETURNS TABLE(am character, entry_date date)
    LANGUAGE plpgsql
    AS $$
begin
return query
select s.am, s.entry_date
FROM ("Student" s join "participates" par using(amka))-- natural join "LearningActivity" la
where par.room_id in (

select room_id
FROM "CourseRun" run join ("LearningActivity" la join  "room" r using (room_id)) using (course_code)
where run.semesterrunsin=(select semester_id from "Semester" where semester_status='present') and r.room_type = 'computer_room');

END;
$$;


ALTER FUNCTION public.query_4_4() OWNER TO postgres;

--


CREATE FUNCTION public.query_4_5() RETURNS TABLE(course_code character varying, yesorno text)
    LANGUAGE plpgsql
    AS $$
 
BEGIN
return query
SELECT distinct
                la.course_code , yesno(la.course_code)
from(select * from
                "LearningActivity" pr
            WHERE
                (pr.start_time)>=16
and
(select co.obligatory
from  "Course" co where co.course_code=pr.course_code)='true'
)as la

  union
  select cou.course_code,yesno(cou.course_code)  
  from (
select *
from "Course" co
where co.obligatory='true'
)as cou;


END;
$$;

ALTER FUNCTION public.query_4_5() OWNER TO postgres;

--


CREATE FUNCTION public.query_4_6() RETURNS TABLE(course_code character, course_title character)
    LANGUAGE plpgsql
    AS $$
   
BEGIN
return query
Select course.course_code,course.course_title
from(
select *
from "Course" co
where co.lab_hours<>0
and co.obligatory='true'
    and (select la.room_id  
  from "LearningActivity" la  
where la.course_code=co.course_code limit 1)not like 'LAB%'
)as course
--check if the course is in the running semester
join "CourseRun" run on run.course_code=course.course_code
where run.semesterrunsin=(select semester_id from "Semester" where semester_status='present');

END;
$$;


ALTER FUNCTION public.query_4_6() OWNER TO postgres;

--

CREATE FUNCTION public.query_4_7() RETURNS TABLE(amka integer, surname character, name character, totalhoursofwork integer)
    LANGUAGE plpgsql
    AS $$
begin
return query
select staff.amka,staff.surname,staff.name,(select par.end_time-par.start_time from "participates" par where staff.amka=par.amka)
from "LabStaff" staff
join "participates" part on staff.amka=part.amka
--filter in this semester
 join "Semester" sm on sm.semester_id=(select cr.semesterrunsin
     from "CourseRun" cr
   where cr.course_code=part.course_code
    and cr.serial_number=part.serial_number)where sm.semester_status='present'
union
--union with the ones that have 0 hours of work!
select distinct staf.amka,staf.surname,staf.name,0
from "LabStaff" staf;
END;
$$;


ALTER FUNCTION public.query_4_7() OWNER TO postgres;

--


CREATE FUNCTION public.query_4_8() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
     DECLARE
room character varying;
begin

room:=(select mxi.room from(
select distinct count(course_code) as num,room_id as room from "LearningActivity" group by room_id order by num DESC limit 1) mxi );
return room;
END;
  $$;


ALTER FUNCTION public.query_4_8() OWNER TO postgres;

--


CREATE FUNCTION public.query_4_9() RETURNS TABLE(r_id character varying, dayt smallint, startt integer, endt integer)
    LANGUAGE plpgsql
    AS $$
declare
dayTime smallint;
--find start of the first class of the week in that classroom
sTime integer;
--find end of the first class of the week in that classroom
eTime integer;
keepStart integer;
tempT integer;
maxi integer;
keepEnd integer;
keepDAY smallint;
num integer:=0;
room character varying;
counter INTEGER := (select count(*) from "room" ) ; --counter of the loop
BEGIN
--none insertion of rooms
IF (counter =0) THEN
RETURN  ;
END IF;

LOOP
EXIT WHEN num = counter ;  
room:=(select room_id from "room" limit 1 offset num);
dayTime:=(select la.weekday from "LearningActivity" la where la.room_id=room order by la.weekday limit 1);
sTime :=(select ml.start_time
  from "LearningActivity" ml
  where ml.room_id=room
  and ml.weekday=dayTime
  order by start_time
  limit 1);
eTime:=(select ml.end_time
from "LearningActivity" ml
where ml.room_id=room
and ml.weekday=dayTime
and ml.start_time=sTime limit 1);
keepStart:=sTime;
maxi:=eTime-sTime;
keepEnd:=eTime;
keepDAY:=dayTime;
sTime=eTime;
raise notice '%',room;

WHILE ( dayTime<=6)  LOOP
tempT:=(select la.start_time from "LearningActivity" la where la.start_time =sTime and la.room_id=room and la.weekday=dayTime);
--at the end of the lesson does it start a new one?
if (tempT!=0) then
 eTime:=(select ml.end_time
from "LearningActivity" ml
where ml.room_id=room
and ml.weekday=dayTime
and ml.start_time=sTime );

if ((maxi<maxi+eTime-sTime) and (maxi!=0)) then
maxi:=maxi+eTime-sTime;
keepStart:=eTime-maxi;
keepEnd:=eTime;
keepDay=dayTime;
end if;

sTime:=eTime;
else
 sTime:=sTime+1;
end if;
if (sTime>20) then
dayTime:=dayTime+1;
sTime:=8;
maxi:=0;
end if;
END LOOP;

--fix the returning table
R_id:=room;
DayT:=keepDay;
startT:=keepStart;
endT:=keepEnd;

num := num +1 ;
--if there is no record for that room in the rows of the room
 if (DayT is not null)  then
return next;
end if;
end loop;
end;
$$;


ALTER FUNCTION public.query_4_9() OWNER TO postgres;

--


CREATE FUNCTION public.random_father_names(n integer) RETURNS TABLE(father_name character, id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT nam.name as father_name, row_number() OVER ()::integer
	FROM (SELECT "Name".name 
		FROM "Name" 
		WHERE "Name".sex='M'
		ORDER BY random() LIMIT n) as nam;
END;
$$;


ALTER FUNCTION public.random_father_names(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.random_names(n integer) RETURNS TABLE(name character, sex character, id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT nam.name, nam.sex, row_number() OVER ()::integer
FROM (SELECT "Name".name, "Name".sex
FROM "Name"
ORDER BY random() LIMIT n) as nam;
END;
$$;


ALTER FUNCTION public.random_names(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.random_surnames(n integer) RETURNS TABLE(surname character, id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT snam.surname, row_number() OVER ()::integer
FROM (SELECT "Surname".surname
FROM "Surname"
WHERE right("Surname".surname,2)='ΗΣ'
ORDER BY random() LIMIT n) as snam;
END;
$$;


ALTER FUNCTION public.random_surnames(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.random_surnames2(n integer) RETURNS TABLE(surname character, id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT snam.surname, row_number() OVER ()::integer
	FROM (SELECT "Surname".surname 
		FROM "Surname"
		WHERE right("Surname".surname,2)='ΗΣ' 
		ORDER BY random() LIMIT n) as snam;
END;
$$;


ALTER FUNCTION public.random_surnames2(n integer) OWNER TO postgres;

--


CREATE FUNCTION public.random_weekday(n numeric) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
if (n<0) THEN
RETURN  0;
END IF;

if n<5 then
return 1;
elsif n<10 then
return 2;
elsif n<15 then
return 3;
elsif n<20 then
return 4;
elsif n<25 then
return 5;
elsif n<30 then
return 6;
else
return 0;
end if;
END;
$$;


ALTER FUNCTION public.random_weekday(n numeric) OWNER TO postgres;

--


CREATE FUNCTION public.retsernumccode(OUT c_code character varying, OUT ser_num integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin

c_code:=(select course_code
from "CourseRun" 
order by random() limit 1);

ser_num:=(select serial_number
from "CourseRun" 
where course_code = c_code
order by random() limit 1);

END;
$$;


ALTER FUNCTION public.retsernumccode(OUT c_code character varying, OUT ser_num integer) OWNER TO postgres;

--

CREATE FUNCTION public.trigger_5_1() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
course character varying;
allHours bigint;
difer bigint;
lab bigint;
computer_lab bigint;
labor bigint;
labo integer;
BEGIN
CASE TG_OP
when 'INSERT' THEN
if exists(select par.amka
  from "participates" par
where par.amka=new.amka
  and par.start_time=new.start_time
and par.end_time=new.end_time
and par.weekday=new.weekday) then
raise EXCEPTION 'Having another activity!Cannot insert!';
return old;
else
return new;
end if;
WHEN 'UPDATE' THEN
if (new.amka<>old.amka) then
if (select par.amka
  from "participates" par
where par.start_time=new.start_time
and par.end_time=new.end_time
and par.weekday=new.weekday)=new.amka
then
raise EXCEPTION 'Having another activity!';
else
update "participates"
set role=new.role
where amka=new.amka
and start_time = new.start_time
and end_time = new.end_time
and weekday = new.weekday
and room_id = new.room_id
and course_code = new.course_code
and serial_number = new.serial_number
and type_=new.type_;
raise notice'ok';
return new;
end if;
end if;

end case;
--second bullet------------------------------------------------------------------------------------------
  CASE TG_OP
  when 'UPDATE' then
 if (new.course_code<>old.course_code) then
 course:=(new.course_code);
 else course:=(old.course_code);
 end if;
if ( new.type_='Student' or
old.type_='Student' and
(select lab_hours
from "Course"
where course_code=course)<>0) then
lab:=(case when (select sum((la.end_time)-(la.start_time))as labo
  from "LearningActivity" la
  where exists(select 1
from  "LearningActivity" la
where  la.course_code=course and la.activity_type ='lab' limit 1)) is null then 0 else labo end);
 raise notice'%',lab;

  computer_lab:=(case when (select (sum((la.end_time)-(la.start_time)))as labor
  from "LearningActivity" la
  where  la.activity_type='computer_lab'
  and la.course_code=course) is null then 0 else labor end);
 raise notice'%',computer_lab;

 allHours:=lab+computer_lab;
 --raise notice'%',allHours;
difer:=(select co.lab_hours from "Course" co where co.course_code=course)-allHours;
-- raise notice'%',difer;
  if (allHours<=(select co.lab_hours from "Course" co where co.course_code=course)) then
if (new.end_time-new.start_time<=difer) then
return new;
end if;
end if;

raise exception '1fgdsgsdg';
--
else
raise exception '2';
end if;

 end case;

-- return old;
end;
$$;


ALTER FUNCTION public.trigger_5_1() OWNER TO postgres;

--

CREATE FUNCTION public.trigger_updatable_for_views() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
BEGIN
CASE TG_OP
when 'INSERT' THEN
return old;
raise exception 'Cannot insert!';
when 'DELETE' THEN
return old;
raise exception 'Cannot delete!';
WHEN 'UPDATE' THEN
--change in name of lab
IF (new.lab_title<>old.lab_title) then
--update lab
update Lab
set lab_title=new.lab_title
where sector_code=old.sector_code
and  lab_code= old.lab_code
and lab_description = old.lab_description
and profdirects = old.profdirects;
--update courseRun
update CourseRun
set labuses=new.labuses
where course_code=old.course_code
and serial_number=old.serial_number
and exam_min=old.exam_min
and lab_min =old.lab_min
and exam_percantage=old.exam_percantage
and semesterrunsin=old.semesterrunsin
and amka_prof1=old.amka_prof1
and amka_prof2=old.amka_prof2;
return new;
-- change in the name of the labstaff
elsif (new.fullname<>old.fullname) then
update "LabStaff"
set surname=(select regexp_split_to_table(new.fullname, E'\\s+') limit 1)
where name=(select regexp_split_to_table(new.fullname, E'\\s+') limit 1 offset 2)
and amka=old.amka
and email=old.email
and labworks=old.labworks
and level=old.level;
return new;
else
return old;
raise exception 'Cannot update!';
end if;
end case;
end;
$$;


ALTER FUNCTION public.trigger_updatable_for_views() OWNER TO postgres;

--


CREATE FUNCTION public.yesno(course character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
n text;
BEGIN
case
when (select distinct lea.course_code
 from "LearningActivity" lea where lea.course_code = course and lea.start_time>=16 and (select co.obligatory from "Course" co where co.course_code=course)='true')=course
then n='ΝΑΙ' ;
else n='OXI';
end case;
return n;
END;
$$;


ALTER FUNCTION public.yesno(course character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--


CREATE TABLE public."Course" (
    course_code character(7) NOT NULL,
    course_title character(100) NOT NULL,
    units smallint NOT NULL,
    ects smallint NOT NULL,
    weight real NOT NULL,
    lecture_hours smallint NOT NULL,
    tutorial_hours smallint NOT NULL,
    lab_hours smallint NOT NULL,
    typical_year smallint NOT NULL,
    typical_season public.semester_season_type NOT NULL,
    obligatory boolean NOT NULL,
    course_description character varying
);


ALTER TABLE public."Course" OWNER TO postgres;

--


CREATE TABLE public."CourseRun" (
    course_code character(7) NOT NULL,
    serial_number integer NOT NULL,
    exam_min numeric,
    lab_min numeric,
    exam_percentage numeric,
    labuses integer,
    semesterrunsin integer NOT NULL,
    amka_prof1 integer NOT NULL,
    amka_prof2 integer
);


ALTER TABLE public."CourseRun" OWNER TO postgres;

--

CREATE SEQUENCE public."CourseRun_serial_number_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CourseRun_serial_number_seq" OWNER TO postgres;

--


ALTER SEQUENCE public."CourseRun_serial_number_seq" OWNED BY public."CourseRun".serial_number;


--


CREATE TABLE public."Course_depends" (
    dependent character(7) NOT NULL,
    main character(7) NOT NULL,
    mode public.course_dependency_mode_type
);


ALTER TABLE public."Course_depends" OWNER TO postgres;

--

CREATE TABLE public."Covers" (
    lab_code integer NOT NULL,
    field_code character(3) NOT NULL
);


ALTER TABLE public."Covers" OWNER TO postgres;

--


CREATE TABLE public."Diploma" (
    amka integer NOT NULL,
    thesis_grade numeric,
    thesis_title character varying,
    diploma_grade numeric,
    graduation_date date,
    diploma_num integer,
    amka_super integer,
    amka_mem1 integer,
    amka_mem2 integer
);


ALTER TABLE public."Diploma" OWNER TO postgres;

--


CREATE TABLE public."Field" (
    code character(3) NOT NULL,
    title character(100) NOT NULL
);


ALTER TABLE public."Field" OWNER TO postgres;

--


CREATE TABLE public."Graduation_rules" (
    min_courses integer,
    min_units integer,
    year_rules integer NOT NULL
);


ALTER TABLE public."Graduation_rules" OWNER TO postgres;

--


CREATE TABLE public."Lab" (
    lab_code integer NOT NULL,
    sector_code integer NOT NULL,
    lab_title character(100) NOT NULL,
    lab_description character varying,
    profdirects integer
);


ALTER TABLE public."Lab" OWNER TO postgres;

--


CREATE TABLE public."LabStaff" (
    amka integer NOT NULL,
    name character(30) NOT NULL,
    father_name character(30) NOT NULL,
    surname character(30) NOT NULL,
    email character(30),
    labworks integer,
    level public.level_type NOT NULL
);


ALTER TABLE public."LabStaff" OWNER TO postgres;

--


CREATE SEQUENCE public."LabStaff_amka_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."LabStaff_amka_seq" OWNER TO postgres;

--


ALTER SEQUENCE public."LabStaff_amka_seq" OWNED BY public."LabStaff".amka;


--


CREATE TABLE public."LearningActivity" (
    activity_type public.activity_type NOT NULL,
    start_time integer NOT NULL,
    end_time integer NOT NULL,
    weekday smallint NOT NULL,
    room_id character varying NOT NULL,
    course_code character varying NOT NULL,
    serial_number integer NOT NULL
);


ALTER TABLE public."LearningActivity" OWNER TO postgres;

--

CREATE TABLE public."Name" (
    name character(30) NOT NULL,
    sex character(1) NOT NULL
);


ALTER TABLE public."Name" OWNER TO postgres;

--


CREATE TABLE public."Professor" (
    amka integer NOT NULL,
    name character(30) NOT NULL,
    father_name character(30) NOT NULL,
    surname character(30) NOT NULL,
    email character(30),
    "labJoins" integer,
    rank public.rank_type NOT NULL
);


ALTER TABLE public."Professor" OWNER TO postgres;

--


CREATE SEQUENCE public."Professor_amka_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Professor_amka_seq" OWNER TO postgres;

--


ALTER SEQUENCE public."Professor_amka_seq" OWNED BY public."Professor".amka;


--


CREATE TABLE public."Register" (
    amka integer NOT NULL,
    serial_number integer NOT NULL,
    course_code character(7) NOT NULL,
    exam_grade numeric,
    final_grade numeric,
    lab_grade numeric,
    register_status public.register_status_type
);


ALTER TABLE public."Register" OWNER TO postgres;

--


CREATE TABLE public."Sector" (
    sector_code integer NOT NULL,
    sector_title character(100) NOT NULL,
    sector_description character varying
);


ALTER TABLE public."Sector" OWNER TO postgres;

--


CREATE TABLE public."Semester" (
    semester_id integer NOT NULL,
    academic_year integer,
    academic_season public.semester_season_type,
    start_date date,
    end_date date,
    semester_status public.semester_status_type NOT NULL
);


ALTER TABLE public."Semester" OWNER TO postgres;

--


CREATE TABLE public."Student" (
    amka integer NOT NULL,
    name character(30) NOT NULL,
    father_name character(30) NOT NULL,
    surname character(30),
    email character(30),
    am character(10),
    entry_date date
);


ALTER TABLE public."Student" OWNER TO postgres;

--


CREATE SEQUENCE public."Student_amka_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Student_amka_seq" OWNER TO postgres;

--


ALTER SEQUENCE public."Student_amka_seq" OWNED BY public."Student".amka;


--


CREATE TABLE public."Supports" (
    amka integer NOT NULL,
    serial_number integer NOT NULL,
    course_code character(7) NOT NULL
);


ALTER TABLE public."Supports" OWNER TO postgres;

--


CREATE TABLE public."Surname" (
    surname character(50) NOT NULL
);


ALTER TABLE public."Surname" OWNER TO postgres;

--


CREATE SEQUENCE public.am_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.am_sequence OWNER TO postgres;

--


CREATE SEQUENCE public.amka_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.amka_sequence OWNER TO postgres;

--

CREATE SEQUENCE public.diploma_num
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.diploma_num OWNER TO postgres;

--


CREATE SEQUENCE public.ergasia
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ergasia OWNER TO postgres;

--


CREATE SEQUENCE public.labstaff_am
    START WITH 30000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.labstaff_am OWNER TO postgres;

--


CREATE TABLE public.participates (
    role public.role_type,
    amka integer NOT NULL,
    start_time integer NOT NULL,
    end_time integer NOT NULL,
    weekday smallint NOT NULL,
    room_id character varying NOT NULL,
    course_code character varying NOT NULL,
    serial_number integer NOT NULL,
    type_ character varying(10),
    CONSTRAINT checktype CHECK (public.check_type(amka, type_))
);


ALTER TABLE public.participates OWNER TO postgres;

--


CREATE SEQUENCE public.prof_am
    START WITH 20000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prof_am OWNER TO postgres;

--


CREATE TABLE public.room (
    room_id character varying NOT NULL,
    room_type public.roomtype NOT NULL,
    capacity integer
);


ALTER TABLE public.room OWNER TO postgres;

--


CREATE SEQUENCE public.room_capacity_seq
    START WITH 10
    INCREMENT BY 50
    MINVALUE 5
    MAXVALUE 200
    CACHE 1
    CYCLE;


ALTER TABLE public.room_capacity_seq OWNER TO postgres;

--


CREATE SEQUENCE public.serial_number
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.serial_number OWNER TO postgres;

--


CREATE SEQUENCE public.start_time
    START WITH 17
    INCREMENT BY 1
    MINVALUE 8
    MAXVALUE 19
    CACHE 1
    CYCLE;


ALTER TABLE public.start_time OWNER TO postgres;

--


CREATE SEQUENCE public.student_am
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_am OWNER TO postgres;

--


CREATE SEQUENCE public.time_room_seq
    START WITH 14
    INCREMENT BY 1
    MINVALUE 8
    MAXVALUE 20
    CACHE 1
    CYCLE;


ALTER TABLE public.time_room_seq OWNER TO postgres;

--

CREATE VIEW public.updatable_view_1 AS
 SELECT stu.amka,
    stu.thesis_grade,
    stu.thesis_title,
    stu.diploma_grade,
    stu.graduation_date,
    stu.diploma_num,
    stu.amka_super,
    stu.amka_mem1,
    stu.amka_mem2
   FROM public."Diploma" stu
  WHERE (stu.diploma_grade > (6)::numeric)
  WITH CASCADED CHECK OPTION;


ALTER TABLE public.updatable_view_1 OWNER TO postgres;

--


COMMENT ON VIEW public.updatable_view_1 IS 'find how many students take their diploma with more than 6 in their grade';


--

CREATE VIEW public.updatable_view_2 AS
 SELECT course.course_code,
    lab.lab_title,
    (((staff.surname)::text || ' '::text) || (staff.name)::text) AS fullname,
    staff.email,
    par.weekday,
    par.start_time,
    par.end_time,
    par.room_id
   FROM (((public."CourseRun" course
     JOIN public."Lab" lab ON (((lab.lab_code = course.labuses) AND (course.course_code ~~ 'ΠΛΗ%'::text) AND (course.serial_number = ( SELECT "Semester".semester_id
           FROM public."Semester"
          WHERE ("Semester".semester_status = 'present'::public.semester_status_type))))))
     JOIN public.participates par ON ((((par.course_code)::bpchar = course.course_code) AND ((par.type_)::text = 'LabStaff'::text) AND ((par.room_id)::text ~~ '%LAB%'::text))))
     JOIN public."LabStaff" staff ON ((staff.amka = par.amka)))
  ORDER BY par.weekday, par.start_time;


ALTER TABLE public.updatable_view_2 OWNER TO postgres;

--


CREATE VIEW public.view_6_1 AS
 SELECT pr.course_code,
    cr.semesterrunsin,
    count(*) AS count
   FROM (( SELECT r.course_code,
            r.serial_number,
            count(*) AS count
           FROM public."Register" r
          WHERE (r.lab_grade > (8)::numeric)
          GROUP BY r.course_code, r.serial_number) pr
     JOIN public."CourseRun" cr ON ((cr.serial_number = pr.serial_number)))
  GROUP BY pr.course_code, cr.semesterrunsin;


ALTER TABLE public.view_6_1 OWNER TO postgres;

--

CREATE VIEW public.view_6_2 AS
 SELECT rlo.room_id AS id,
    rlo.weekday,
    rlo.start_time AS start,
    rlo.end_time AS "end",
    (((prof.surname)::text || ' '::text) || (prof.name)::text) AS fullname,
    rlo.course_code AS code
   FROM (( SELECT ro.room_id,
            ro.weekday,
            ro.start_time,
            ro.end_time,
            ro.course_code
           FROM public."LearningActivity" ro
          WHERE ((ro.course_code)::bpchar IN ( SELECT co.course_code
                   FROM public."CourseRun" co
                  WHERE (co.serial_number = ( SELECT sem.semester_id
                           FROM public."Semester" sem
                          WHERE (sem.semester_status = 'present'::public.semester_status_type)))))) rlo
     JOIN public."Professor" prof ON ((prof.amka IN ( SELECT par.amka
           FROM public.participates par
          WHERE (((par.course_code)::text = (rlo.course_code)::text) AND ((par.type_)::text ~~ 'Professor'::text))))))
  ORDER BY rlo.room_id, rlo.weekday;


ALTER TABLE public.view_6_2 OWNER TO postgres;
--


CREATE SEQUENCE public.year_seq
    START WITH 2009
    INCREMENT BY 1
    MINVALUE 2009
    MAXVALUE 2020
    CACHE 1
    CYCLE;


ALTER TABLE public.year_seq OWNER TO postgres;

SELECT pg_catalog.setval('public."CourseRun_serial_number_seq"', 1, true);


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 210
-- Name: LabStaff_amka_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."LabStaff_amka_seq"', 1107, true);


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 214
-- Name: Professor_amka_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Professor_amka_seq"', 755, true);


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 219
-- Name: Student_amka_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Student_amka_seq"', 776, true);


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 222
-- Name: am_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.am_sequence', 1000, true);


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 223
-- Name: amka_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.amka_sequence', 199999, true);


--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 224
-- Name: diploma_num; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diploma_num', 5, true);


--
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 225
-- Name: ergasia; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ergasia', 1, false);


--
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 226
-- Name: labstaff_am; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.labstaff_am', 30488, true);


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 228
-- Name: prof_am; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prof_am', 20820, true);


--
-- TOC entry 3323 (class 0 OID 0)
-- Dependencies: 230
-- Name: room_capacity_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.room_capacity_seq', 5, true);


--
-- TOC entry 3324 (class 0 OID 0)
-- Dependencies: 231
-- Name: serial_number; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.serial_number', 24, true);


--
-- TOC entry 3325 (class 0 OID 0)
-- Dependencies: 232
-- Name: start_time; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.start_time', 13, true);


--
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 233
-- Name: student_am; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_am', 1367, true);


--
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 234
-- Name: time_room_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.time_room_seq', 9, true);


--
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 239
-- Name: year_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.year_seq', 2013, true);


--
-- TOC entry 3060 (class 2606 OID 17679)
-- Name: CourseRun CourseRun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CourseRun"
    ADD CONSTRAINT "CourseRun_pkey" PRIMARY KEY (course_code, serial_number);


--
-- TOC entry 3062 (class 2606 OID 17681)
-- Name: Course_depends Course_depends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Course_depends"
    ADD CONSTRAINT "Course_depends_pkey" PRIMARY KEY (dependent, main);


--
-- TOC entry 3058 (class 2606 OID 17683)
-- Name: Course Course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Course"
    ADD CONSTRAINT "Course_pkey" PRIMARY KEY (course_code);


--
-- TOC entry 3070 (class 2606 OID 17685)
-- Name: Diploma Diploma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT "Diploma_pkey" PRIMARY KEY (amka);


--
-- TOC entry 3072 (class 2606 OID 17687)
-- Name: Field Fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Field"
    ADD CONSTRAINT "Fields_pkey" PRIMARY KEY (code);


--
-- TOC entry 3074 (class 2606 OID 17689)
-- Name: Graduation_rules Graduation_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Graduation_rules"
    ADD CONSTRAINT "Graduation_rules_pkey" PRIMARY KEY (year_rules);


--
-- TOC entry 3079 (class 2606 OID 17691)
-- Name: LabStaff LabStaff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LabStaff"
    ADD CONSTRAINT "LabStaff_pkey" PRIMARY KEY (amka);


--
-- TOC entry 3066 (class 2606 OID 17693)
-- Name: Covers Lab_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Covers"
    ADD CONSTRAINT "Lab_fields_pkey" PRIMARY KEY (field_code, lab_code);


--
-- TOC entry 3076 (class 2606 OID 17695)
-- Name: Lab Lab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lab"
    ADD CONSTRAINT "Lab_pkey" PRIMARY KEY (lab_code);


--
-- TOC entry 3081 (class 2606 OID 17697)
-- Name: LearningActivity LearningActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LearningActivity"
    ADD CONSTRAINT "LearningActivity_pkey" PRIMARY KEY (start_time, end_time, weekday, serial_number, course_code, room_id);


--
-- TOC entry 3083 (class 2606 OID 17699)
-- Name: Name Names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Name"
    ADD CONSTRAINT "Names_pkey" PRIMARY KEY (name);


--
-- TOC entry 3085 (class 2606 OID 17701)
-- Name: Professor Professor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Professor"
    ADD CONSTRAINT "Professor_pkey" PRIMARY KEY (amka);


--
-- TOC entry 3087 (class 2606 OID 17703)
-- Name: Register Register_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Register"
    ADD CONSTRAINT "Register_pkey" PRIMARY KEY (course_code, serial_number, amka);


--
-- TOC entry 3089 (class 2606 OID 17705)
-- Name: Sector Sector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sector"
    ADD CONSTRAINT "Sector_pkey" PRIMARY KEY (sector_code);


--
-- TOC entry 3091 (class 2606 OID 17707)
-- Name: Semester Semester_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Semester"
    ADD CONSTRAINT "Semester_pkey" PRIMARY KEY (semester_id);


--
-- TOC entry 3093 (class 2606 OID 17709)
-- Name: Student Student_am_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Student"
    ADD CONSTRAINT "Student_am_key" UNIQUE (am);


--
-- TOC entry 3095 (class 2606 OID 17711)
-- Name: Student Student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Student"
    ADD CONSTRAINT "Student_pkey" PRIMARY KEY (amka);


--
-- TOC entry 3098 (class 2606 OID 17713)
-- Name: Supports Supports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supports"
    ADD CONSTRAINT "Supports_pkey" PRIMARY KEY (amka, serial_number, course_code);


--
-- TOC entry 3100 (class 2606 OID 17715)
-- Name: Surname Surnames_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Surname"
    ADD CONSTRAINT "Surnames_pkey" PRIMARY KEY (surname);


--
-- TOC entry 3102 (class 2606 OID 17717)
-- Name: participates participates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participates
    ADD CONSTRAINT participates_pkey PRIMARY KEY (amka, serial_number, course_code, weekday, start_time, end_time, room_id);


--
-- TOC entry 3104 (class 2606 OID 17719)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_id);


--
-- TOC entry 3063 (class 1259 OID 17720)
-- Name: fk_course_depends_dependent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fk_course_depends_dependent ON public."Course_depends" USING btree (dependent);


--
-- TOC entry 3064 (class 1259 OID 17721)
-- Name: fk_course_depends_main; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fk_course_depends_main ON public."Course_depends" USING btree (main);


--
-- TOC entry 3067 (class 1259 OID 17722)
-- Name: fk_lab_field_lab_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fk_lab_field_lab_code ON public."Covers" USING btree (lab_code);


--
-- TOC entry 3068 (class 1259 OID 17723)
-- Name: fk_lab_fields_field_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fk_lab_fields_field_code ON public."Covers" USING btree (field_code);


--
-- TOC entry 3077 (class 1259 OID 17724)
-- Name: fk_lab_sector_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fk_lab_sector_code ON public."Lab" USING btree (sector_code);


--
-- TOC entry 3096 (class 1259 OID 17725)
-- Name: student_name_b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX student_name_b ON public."Student" USING btree (name);

ALTER TABLE public."Student" CLUSTER ON student_name_b;


--
-- TOC entry 3130 (class 2620 OID 17726)
-- Name: participates q5_1_tr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER q5_1_tr BEFORE INSERT OR UPDATE ON public.participates FOR EACH ROW EXECUTE FUNCTION public.trigger_5_1();


--
-- TOC entry 3129 (class 2620 OID 17727)
-- Name: LearningActivity q5_2_tr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER q5_2_tr BEFORE INSERT OR UPDATE ON public."LearningActivity" FOR EACH ROW EXECUTE FUNCTION public.activities_update();


--
-- TOC entry 3131 (class 2620 OID 17728)
-- Name: updatable_view_2 triggerof_updatable2; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER triggerof_updatable2 INSTEAD OF UPDATE ON public.updatable_view_2 FOR EACH ROW EXECUTE FUNCTION public.trigger_updatable_for_views();


--
-- TOC entry 3105 (class 2606 OID 17729)
-- Name: CourseRun CourseRun_amka_prof1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CourseRun"
    ADD CONSTRAINT "CourseRun_amka_prof1_fkey" FOREIGN KEY (amka_prof1) REFERENCES public."Professor"(amka);


--
-- TOC entry 3106 (class 2606 OID 17734)
-- Name: CourseRun CourseRun_amka_prof2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CourseRun"
    ADD CONSTRAINT "CourseRun_amka_prof2_fkey" FOREIGN KEY (amka_prof2) REFERENCES public."Professor"(amka);


--
-- TOC entry 3107 (class 2606 OID 17739)
-- Name: CourseRun CourseRun_course_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CourseRun"
    ADD CONSTRAINT "CourseRun_course_code_fkey" FOREIGN KEY (course_code) REFERENCES public."Course"(course_code);


--
-- TOC entry 3108 (class 2606 OID 17744)
-- Name: CourseRun CourseRun_labuses_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CourseRun"
    ADD CONSTRAINT "CourseRun_labuses_fkey" FOREIGN KEY (labuses) REFERENCES public."Lab"(lab_code);


--
-- TOC entry 3109 (class 2606 OID 17749)
-- Name: CourseRun CourseRun_semesterrunsin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CourseRun"
    ADD CONSTRAINT "CourseRun_semesterrunsin_fkey" FOREIGN KEY (semesterrunsin) REFERENCES public."Semester"(semester_id);


--
-- TOC entry 3114 (class 2606 OID 17754)
-- Name: Diploma Diploma_amka_mem1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT "Diploma_amka_mem1_fkey" FOREIGN KEY (amka_mem1) REFERENCES public."Professor"(amka);
--

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT "Diploma_amka_mem2_fkey" FOREIGN KEY (amka_mem2) REFERENCES public."Professor"(amka);
--
ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT "Diploma_amka_student_fkey" FOREIGN KEY (amka) REFERENCES public."Student"(amka);

--

ALTER TABLE ONLY public."Diploma"
    ADD CONSTRAINT "Diploma_amka_super_fkey" FOREIGN KEY (amka_super) REFERENCES public."Professor"(amka);

--

ALTER TABLE ONLY public."LabStaff"
    ADD CONSTRAINT "LabStaff_labworks_fkey" FOREIGN KEY (labworks) REFERENCES public."Lab"(lab_code);
--


ALTER TABLE ONLY public."Covers"
    ADD CONSTRAINT "Lab_fields_field_code_fkey" FOREIGN KEY (field_code) REFERENCES public."Field"(code) MATCH FULL NOT VALID;

--


ALTER TABLE ONLY public."Covers"
    ADD CONSTRAINT "Lab_fields_lab_code_fkey" FOREIGN KEY (lab_code) REFERENCES public."Lab"(lab_code) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;

--
ALTER TABLE ONLY public."Lab"
    ADD CONSTRAINT "Lab_profdirects_fkey" FOREIGN KEY (profdirects) REFERENCES public."Professor"(amka);
--

ALTER TABLE ONLY public."Lab"
    ADD CONSTRAINT "Lab_sector_code_fkey" FOREIGN KEY (sector_code) REFERENCES public."Sector"(sector_code) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
--
ALTER TABLE ONLY public."Professor"
    ADD CONSTRAINT "Professor_labJoins_fkey" FOREIGN KEY ("labJoins") REFERENCES public."Lab"(lab_code);
--

ALTER TABLE ONLY public."Register"
    ADD CONSTRAINT "Register_amka_fkey" FOREIGN KEY (amka) REFERENCES public."Student"(amka);
--

ALTER TABLE ONLY public."Register"
    ADD CONSTRAINT "Register_course_run_fkey" FOREIGN KEY (course_code, serial_number) REFERENCES public."CourseRun"(course_code, serial_number) ON UPDATE CASCADE ON DELETE CASCADE;
--

ALTER TABLE ONLY public."Supports"
    ADD CONSTRAINT "Supports_amka_fkey" FOREIGN KEY (amka) REFERENCES public."LabStaff"(amka);
--

ALTER TABLE ONLY public."Supports"
    ADD CONSTRAINT "Supports_course_code_fkey" FOREIGN KEY (course_code, serial_number) REFERENCES public."CourseRun"(course_code, serial_number);

--
ALTER TABLE ONLY public."LearningActivity"
    ADD CONSTRAINT courserun_fkey FOREIGN KEY (serial_number, course_code) REFERENCES public."CourseRun"(serial_number, course_code);

--

ALTER TABLE ONLY public."Course_depends"
    ADD CONSTRAINT dependent FOREIGN KEY (dependent) REFERENCES public."Course"(course_code) ON UPDATE CASCADE ON DELETE CASCADE;

--

ALTER TABLE ONLY public.participates
    ADD CONSTRAINT learningactivity_fkey FOREIGN KEY (serial_number, course_code, weekday, start_time, end_time, room_id) REFERENCES public."LearningActivity"(serial_number, course_code, weekday, start_time, end_time, room_id);

--

ALTER TABLE ONLY public."Course_depends"
    ADD CONSTRAINT main FOREIGN KEY (main) REFERENCES public."Course"(course_code) ON UPDATE CASCADE ON DELETE CASCADE;


--


ALTER TABLE ONLY public."LearningActivity"
    ADD CONSTRAINT room_fk FOREIGN KEY (room_id) REFERENCES public.room(room_id);
