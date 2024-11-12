CREATE DATABASE my_database;
use my_database;
show tables;

select * from data1;

select * from data2;

-- number of rows into our dataset

select count(*) from data1;
select count(*) from data2;

-- dataset for jharkhand and bihar

select * from data1 where state in ('Jharkhand' ,'Bihar');

-- population of India

select sum(Population) as Populat from data2;

-- avg growth 

select state,avg(growth)*100 avg_growth from data1 group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by avg_sex_ratio desc;

-- avg literacy rate
 
select state,round(avg(literacy),0) avg_literacy_ratio from data1 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio


select state,avg(growth)*100 avg_growth from data1 group by state order by avg_growth desc limit 3;


-- bottom 3 state showing lowest sex ratio

select state, round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by avg_sex_ratio asc limit 3;


-- top and bottom 3 states in literacy state


create table topstates
(state nvarchar(255),
  topstate float);

insert into topstates
select state,round(avg(literacy),0) avg_literacy_ratio from data1 
group by state order by avg_literacy_ratio desc;

select * from topstates order by topstates.topstate desc limit 3;

drop table if exists #bottomstates;

create table bottomstates
(state nvarchar(255),
  bottomstate float);

insert into bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from data1 
group by state order by avg_literacy_ratio desc;

select * from bottomstates order by bottomstates.bottomstate asc limit 3;

-- union opertor

select * from (
select * from topstates order by topstates.topstate desc limit 3) a

union

select * from (
select * from bottomstates order by bottomstates.bottomstate asc limit 3) b;


-- states starting with letter a

select distinct state from data1 where lower(state) like 'a%' or lower(state) like 'b%';

select distinct state from data1 where lower(state) like 'a%' and lower(state) like '%m';


-- joining both table

-- total males and females

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from data1 a inner join data2 b on a.district=b.district ) c) d
group by d.state;

-- total literacy rate


select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from data1 a 
inner join data2 b on a.district=b.district) d) c
group by c.state;

-- population in previous census


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from data1 a inner join data2 b on a.district=b.district) d) e
group by e.state)m;


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from data1 a inner join data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from data2)z) r on q.keyy=r.keyy)g;
