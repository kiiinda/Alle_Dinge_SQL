-- Dataset from kaggle:"https://www.kaggle.com/datasets/tsiaras/uk-road-safety-accidents-and-vehicles/data"--

-------------------------------------------------------------------------------------------------------------
--create database
--import csv files to the database as tables
--Conduct exploratory data analysis and answer some questions with SQL
--------------------------------------------------------------------------------------------------------------
--Urban vs Rural areas: how many accidents have occured
select  Area , count(Accident_Index) as  #_of_Accidents
from accident
group by Area 
order by count(Accident_Index)

--Day of week with highest accidents
select  Day_of_Week, count(Accident_Index) as #_of_Accidents
from Accident
group by Day_of_Week
order by #_of_Accidents desc



--Avg age of vehicle involved in accident based on their type
select vehicle_type, COUNT(Accident_Index) as #_of_Accidents, avg(age_of_vehicle) as average_year
from Vehicle
	where age_of_vehicle is not null 
group by Vehicle_Type
order by  #_of_Accidents desc


--Severity of accident based on weather conditions
DECLARE @severity varchar(100)
set @severity = 'Fatal'

select Weather_Conditions, COUNT(Accident_Severity) as #_of_cases
	from accident 
	where Accident_Severity = @severity and Weather_Conditions <> 'Data missing or out of range'
		group by  Weather_Conditions
		order by #_of_cases desc

	--select Weather_Conditions, COUNT(Accident_Severity) as #_of_cases, Accident_Severity
	--	from accident 
	--	where  Accident_Severity = 'fatal' and Weather_Conditions <> 'Data missing or out of range'
	--		group by  Weather_Conditions, Accident_Severity
	--		order by #_of_cases desc
