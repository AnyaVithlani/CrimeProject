-- Starting with street datasets from 2014 -2018 in the met police and city of london. 
--Formatted data which had inccorectly imported into correct rows. 
--Cast the month into year and month so could later be used to analyse by these two seperately. 

if object_id ('police data') is not null 
drop table [police data]



select 
	[Crime ID]
	,datepart(mm, cast([Month]+'-01' as date)) as [month]
	,datepart(yyyy, cast([Month]+'-01' as date)) as [year]
	,[Reported by]
	,[Falls within]
	,[Longitude]
	,[latitude]
	,[location]
	,[LSOA name] as[LSOA code]
	,[Crime type] as[LSOA name]
	,[Last outcome category]as [Crime type]
	,context as [last outcome category]
into [police data]
from street 
where 1=1
	and [crime type] ='Hillingdon 009E'
	or [crime type] = 'Hillingdon 011C'

union all
select 
	[Crime ID]
	,datepart(mm, cast([Month]+'-01' as date)) as [month]
	,datepart(yyyy, cast([Month]+'-01' as date)) as [year]
	,[Reported by]
	,[Falls within]
	,[Longitude]
	,[Latitude]
	,[Location]
	,[LSOA code]
	,[LSOA name]
	,[Crime type]
	,[Last outcome category]
from street 
where 1=1
	and [crime type] !='Hillingdon 009E'
	and [crime type] != 'Hillingdon 011C'

-- Adding a crime id for this database
-- Changing the LSOA names into borough names so could crimes could be paired and analysed according to borough data 
-- Cleansing last outcome category column 
-- Filtering out city of London 
-- Filtering out 2014 so to focus on more relavent years 
-- Filtering by the two most relevant crime types

if object_id ('crimes_considered') is not null 
drop table crimes_considered

;with cte as (
 
Select 


	row_number() over(order by year) [Crime Id]
	,concat([year],'-',month) [month]
	,[crime type]
	,[Longitude]
	,[latitude]
	,[location]
	
	,case 
		when [LSOA name] like '%Barnet%' 
			then 'Barnet'
		when [LSOA name] like '%Barking and Dagenham%' 
			then 'Barking and Dagenham'
		when [LSOA name] like '%Bexley%' 
			then 'Bexley'
		when [LSOA name] like '%Brent%' 
			then 'Brent'
		when [LSOA name] like '%Bromley%' 
			then 'Bromley'
		when [LSOA name] like 'Camden%' 
			then 'Camden'
		when [LSOA name] like '%City of London%' 
			then 'City of London'
		when [LSOA name] like '%Croydon%' 
			then 'Croydon'
		when [LSOA name] like '%Ealing%' 
			then 'Ealing' 
		when [LSOA name] like '%Enfield%' 
			then 'Enfield'
		when [LSOA name] like 'Greenwich%' 
			then 'Greenwich'
		when [LSOA name] like 'Hackney%'
			 then 'Hackney'
		when [LSOA name] like 'Haringey%'
			 then 'Haringey'
		when [LSOA name] like 'Harrow%' 
			then 'Harrow'
		when [LSOA name] like 'Havering%' 
			then 'Havering'
		when [LSOA name] like 'Hammersmith and Fulham%' 
			then 'Hammersmith and Fulham'
		when [LSOA name] like 'Hillingdon%' 
			then 'Hillingdon'
		when [LSOA name] like 'Hounslow%' 
			then 'Hounslow'
		when [LSOA name] like 'Islington%' 
			then 'Islington'
		when [LSOA name] like 'Kensington and Chelsea%' 
			then 'Kensington and Chelsea'
		when [LSOA name] like 'Kingston upon Thames%' 
			then 'Kingston upon Thames'
		when [LSOA name] like 'Lambeth%' 
			then 'Lambeth'
		when [LSOA name] like 'Lewisham%'
			 then 'Lewisham'
		when [LSOA name] like 'Merton%' 
			then 'Merton'
		when [LSOA name] like 'Redbridge%' 
			then 'Redbridge'
		when [LSOA name] like 'Richmond upon Thames%' 
			then 'Richmond upon Thames'
		when [LSOA name] like 'Southwark%' 
			then 'Southwark'
		when [LSOA name] like 'Sutton%' 
			then 'Sutton'
		when [LSOA name] like 'Tower Hamlets%' 
			then 'Tower Hamlets'
		when [LSOA name] like 'Waltham Forest%' 
			then 'Waltham Forest'
		when [LSOA name] like 'Wandsworth%' 
			then 'Wandsworth'
		when [LSOA name] like 'Westminster%'
			 then 'Westminster'
		when [LSOA name] like 'Newham%' 
			then 'Newham'

	
	else 'FIX'
		end [borough]
		,replace( [last outcome category],',','') [outcome]


from [dbo].[police data])


select * into crimes_considered from cte 
where borough != 'FIX'
and borough != 'City of London'
and [crime type] = 'Violence and Sexual Offences'
or [crime type] = 'public order'
and [month] not like '%2014%'

-- compiling borough and ethncity data to create a diversity table 
-- creating percentages of the number of migrants out of total population 
-- creating percentage of non-white population 
-- combining all aspects of diversity data to create a diversity scale and a percentage for each borough 


if object_id ('new_diversity') is not null
drop table new_diversity 


select 
	d.code
	,[Area name]
	,[Inner/ Outer London]
	,[GLA Population Estimate 2017] [total population]
	,[mixed]+[Asian]+[Black]+[other] [non-white population]
	,d.[Net international migration (2015)]
	,[Largest migrant population arrived during 2015/16]
	,d.[% of resident population born abroad (2015)]
	,d.[% people aged 3+ whose main language is not English (2011 Census]
	,d.[% of pupils whose first language is not English (2015)]
	,round([Net international migration (2015)]/[GLA Population Estimate 2017] *100 ,2) [% of international migrants out of total population]
	,round (([mixed]+[Asian]+[Black]+[other]),2) [% of non-white population]
	
	
	,round (([% of resident population born abroad (2015)]
	+(round (([mixed]+[Asian]+[Black]+[other]),2))
	+[% people aged 3+ whose main language is not English (2011 Census]
	+[% of pupils whose first language is not English (2015)]
	+(round([Net international migration (2015)]/[GLA Population Estimate 2017] *100 ,2)))/4,2)

	 [diversity scale percentage]



into new_diversity 	
from [dbo].[boroughs]d

join [dbo].[ethnicity]e
on d.[Area name]=e.[Local authority]


where [Area name] != 'city of london'

-- creatign a crime and diveristy table by combining diversity table, crimes considered and results data 
-- this table will act a base to build a fact table from


if object_id ('crime and diversity') is not null 
drop table [crime and diversity]

select 
	c.[Crime ID]
	,month
	
	,d.[Area name]
	,c.[crime type]
	,case 
		when [diversity scale percentage] between 10 and 31 then 1
		when [diversity scale percentage] between 31 and 35 then 2
		when [diversity scale percentage] between 35 and 40 then 3
		when [diversity scale percentage] between 40 and 65 then 4
		end [diversity group flag]
	,r.[R/L] [Brexit Result]
into [Crime and diversity]
from  new_diversity d
right outer join [crimes_considered] c
	on d.[Area name]=c.borough
join results r
	on r.[Local authority] =d.[Area name]

-- creating dim tables:

-- dimcrime_type
select distinct 
row_number()  over (order by [crime type]) [crime type key]
,[crime type] 
into [dimcrime_type]
from [Crime and diversity]
group by [crime type]


-- dimdates 
-- building using recursive cte
if object_id ('DimDate') is not null
begin 
	drop table DimDate
end

;with cte 
as 
(
select 
	cast('1997-07-29' as date) as dt 
	,year(cast('1997-07-29' as date)) yr
	,month(cast('1997-07-29' as date)) mnth
	,datepart(dd,cast('1997-07-29' as date)) dy 
	,datename(dw,cast('1997-07-29' as date)) daynm
	,case 
		when datename(dw,cast('1997-07-29' as date)) in('Saturday','Sunday')
		then 0
		else 1
	end [weekday flag]
	,case 
		when month(cast('1997-07-29' as date)) in (12,1,2)
		then 'Winter'
		when month(cast('1997-07-29' as date)) in (3,4,5)
		then 'Spring'
		when month(cast('1997-07-29' as date)) in (6,7,8)
		then 'Summer'
		else 'Autumn'
	end [season]
union all 
select 
	 dateadd(dd,1,dt) 
	,year(dateadd(dd,1,dt))
	,month(dateadd(dd,1,dt))
	,datepart(dd,dateadd(dd,1,dt))
	,datename(dw,dateadd(dd,1,dt))
	,case 
		when datename(dw,dateadd(dd,1,dt)) in('Saturday','Sunday')
		then 0
		else 1
	end [weekday flag]
	,case 
		when month(dateadd(dd,1,dt)) in (12,1,2)
		then 'Winter'
		when month(dateadd(dd,1,dt)) in (3,4,5)
		then 'Spring'
		when month(dateadd(dd,1,dt)) in (6,7,8)
		then 'Summer'
		else 'Autumn'
	end [season]
from  cte
where dateadd(dd,1,dt) <dateadd (yy,1,getdate())
)

select * 
into DimDate
from cte

option (maxrecursion 0)


-- building upon intial dimdate table 
--removing columns that were not relevent for this data 
if object_id ('dimdates') is not null
drop table dimdates


select distinct
	concat( yr,'-',mnth) [month]
	 ,yr
	 ,mnth
	,case
		 when dt <'2016-07-01'
		 then 'pre-vote'
		 else 'post-vote'
		 end [vote status]
	,case 
		when dt< '2016-02-01'
		then 'pre-campaign'
		else 'post-campaign'
		end [campaign status] 
	,season
into [dimdates]
 
from kubrick.[dbo].[DimDate]




-- dimborough
; with cte as (
SELECT row_number() over (order by [new code]) [borough key]
      ,b.[Area name]
      ,b.[Inner/ Outer London]
      ,[GLA Population Estimate 2017]
      ,b.[Net international migration (2015)]
      ,b.[% of resident population born abroad (2015)]
      ,[Largest migrant population by country of birth (2011)]
      ,round([% of largest migrant population (2011)],2) [% of largest migrant population (2011)]
    
   
      ,b.[% people aged 3+ whose main language is not English (2011 Census]
      ,[Overseas nationals entering the UK (NINo), (2015/16)]
      ,[New migrant (NINo) rates, (2015/16)]
      ,b.[Largest migrant population arrived during 2015/16]
      ,[Second largest migrant population arrived during 2015/16]
      ,[Third largest migrant population arrived during 2015/16]
      ,b.[% of pupils whose first language is not English (2015)]
     
      ,[% of international migrants out of total population]
      ,[% of non-white population]
      ,[diversity scale percentage]
      ,r. [R/L]  [Brexit Result]
      ,r.[Winning Percentage]
	
  FROM [new_diversity] d
  join boroughs b 
	 on d.[Area name] = b.[Area name]
  join results r
	 on r.[Local authority] = b.[Area name])


 select distinct
	c.* 
	,count(*) over (partition by f.[borough key]) [crime count]
 into dimborough
 from cte c
inner join [dbo].[Crime and diversity]  f
on c.[Area name] = f.[Area name]



-- dimdiversity 
;with cte as 
(select distinct 
	dd. * 
	,count (f.[crime id]) over (partition by dd.[diversity group flag]) [total]
	,case 
		when d.[yr]='2015' then count (f.[crime id]) over (partition by dd.[diversity group flag],d.yr) 
	   
	end [total 2015]
	

from dimdiversity_U dd
join crime_fact f
	on dd.[diversity group flag] =f.[diversity group flag]

join [dbo].[dimdates] d
on f.month =d.month)

 ,cte2 as (
select distinct dd.* 
 
    ,[total 2015]
	,case 
		when d.[yr]='2016' then count (f.[crime id]) over (partition by dd.[diversity group flag],d.yr) 
	   
	end [total 2016]
	
from cte c
join dimdiversity_u dd 
on c.[diversity group flag] = dd.[diversity group flag]
join crime_fact f
	on dd.[diversity group flag] =f.[diversity group flag]
join [dbo].[dimdates] d
on f.month =d.month

where [total 2015] is not null )
,cte3 as (
select distinct 
	dd.*
	  ,[total 2015]
	  ,[total 2016]
	,case 
		when d.[yr]='2017' then count (f.[crime id]) over (partition by dd.[diversity group flag],d.yr) 
	   
	end [total 2017]
	

from cte2 c
join dimdiversity_u dd 
on c.[diversity group flag] = dd.[diversity group flag]
join crime_fact f
	on dd.[diversity group flag] =f.[diversity group flag]
join [dbo].[dimdates] d
on f.month =d.month
where [total 2016] is not null)

select * 
INTO dimdiversity 
from cte3 
where [total 2017] is not null 



-- crime_fact 
-- combining dim tables as well as geo table from alteryx 

if object_id ('crime_fact') is not null 
drop table crime_fact

select 
	cd.[Crime ID]
	,dd.month
	,b.[borough key]
	,c.[crime type key]
	,d.[diversity group flag]
	,cc.longitude 
	,cc.latitude 
	,Centroid [spatial info]


into crime_fact
from [Crime and diversity] cd
 join dimdates dd
	on cd.Month = dd.month 
join dimborough b
	on cd.[Area name] = b.[Area Name]
join dimcrime_type c
	on cd.[crime type] =c.[crime type]
join dimdiversity d
	on cd.[diversity group flag] = d.[diversity group flag]
join crimes_considered cc
	on cc.[crime id] = cd.[crime id]
	join geo g
on cd.[Crime ID] = g.[Crime ID]











