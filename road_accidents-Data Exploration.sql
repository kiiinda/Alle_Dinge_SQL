-- Dataset from Kaggle:"https://www.kaggle.com/datasets/tsiaras/uk-road-safety-accidents-and-vehicles/data"--

-------------------------------------------------------------------------------------------------------------
--create database
--Import CSV files to the database as tables
--Conduct exploratory data analysis and answer some questions with SQL
--------------------------------------------------------------------------------------------------------------
--Urban vs Rural areas: how many accidents have occurred
select  Area , count(Accident_Index) as  #_of_Accidents
from accident
group by Area 
order by #_of_Accidents


--Day of the week with highest accidents
select  Day_of_Week, count(Accident_Index) as #_of_Accidents
from Accident
group by Day_of_Week
order by #_of_Accidents desc


--Avg age of vehicle involved in an accident based on their type
select vehicle_type, COUNT(Accident_Index) as #_of_Accidents, avg(age_of_vehicle) as average_year
from Vehicle
	where age_of_vehicle is not null 
group by Vehicle_Type
order by  #_of_Accidents desc


--Severity of accident based on weather conditions
select Weather_Conditions, COUNT(Accident_Severity) as #_of_cases
	from accident 
	where  Accident_Severity = 'fatal' and Weather_Conditions <> 'Data missing or out of range'
	group by  Weather_Conditions
	order by #_of_cases desc

--DECLARE @severity varchar(100)
--set @severity = 'Fatal'

--select Weather_Conditions, COUNT(Accident_Severity) as #_of_cases
--	from accident 
--	where Accident_Severity = @severity and Weather_Conditions <> 'Data missing or out of range'
--		group by  Weather_Conditions
--		order by #_of_cases desc



--do accidents often involve impact on the left-hand side
update vehicle
set hand_drive = 'RHS'
where hand_drive = 'No'

update vehicle
set hand_drive = 'LHS'
where hand_drive = 'Yes'

select Hand_Drive, count(Accident_Index) as #_of_accidents
from vehicle
where Hand_Drive <> 'Data missing or out of range' and  Hand_Drive is not null
	group by Hand_Drive

	
--Identify any trends in accidents based on the age of the vehicle
select AgeGroup, count(Accident_Index) as #_of_accidents, avg(Age_of_Vehicle) as average_year
from (
select
	[Accident_Index],
	[Age_of_Vehicle],
	case when 	[Age_of_Vehicle] between 0 and 5 then 'New'
		 when 	[Age_of_Vehicle] between 6 and 10 then 'Average'
		 else 'Old'
	end as AgeGroup
from vehicle
where Age_of_Vehicle is not null
) as subquery
group by AgeGroup
order by #_of_accidents 


--avg age of vehicle involved in accidents, considering daylight and point of impact
DECLARE @impact varchar(100)
DECLARE @light varchar(100)
set @impact = 'Nearside'
set @light = 'Daylight'

select acc.Light_Conditions, v.Point_of_Impact, AVG(v.Age_of_Vehicle) as average_Vage
from accident acc 
	join vehicle v on acc.Accident_Index = v.Accident_Index
	where Light_Conditions = @light and Point_of_Impact = @impact
	group by acc.Light_Conditions, v.Point_of_Impact

	
--Relationship between journey purposes and severity of accidents
select v.Journey_Purpose, count(acc.Accident_Severity) as accidents,
		case
			when count(acc.Accident_Severity) between 0 and 1000 then 'Low' 
			when count(acc.Accident_Severity) between 1001 and 3000 then 'Moderate' 
			else 'High'
		end as 'intensity'
from vehicle v
	join accident acc on v.Accident_Index = acc.Accident_Index
	group by v.Journey_Purpose
	order by accidents desc
