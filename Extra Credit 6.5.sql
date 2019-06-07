
--> which customers had have had more than 3 jobs before 
-->2018 that also ordered at least 12,000 worth of lawn prodycts in 2019

select CustFname, CustLname, Count(J.JobsID)
from Job J
join Customer C on J.CustID = C.CUstID
where J.JobBeginDate <= 'Jan 01, 2018'
and C.CustID in
				(select C.CustID
				from  Job J
				join Customer C on J.CustID = C.CUstID
				join [Order] O on J.JobID = O.JobId
				join [Line_Item] LI on O.OrderID = LI.OrderID
				join Product P on O.ProductID = P.ProductID
				join Product PT on P.ProductTypeID = PT.ProductTypeID
				where PT.ProductTypeName = 'Lawn products'
				group by C.CustID
				having Sum(P.Price) >= 12000)

group by Count(J.JobsID)
having Count(J.JobsID) >= 3


--> which jobs have used fewer than 4 experts that also 
-->had fewer than 4 tools returned as 'damaged'

select J.JobName, J.JobDescr, count(ES.EmpID)
from Job J
join Cust_JOB_Task CJT on J.JobID = CJT.JobID
join Employee_SKILL ES on CJT.EmpSkillID = ES.EmpSKillID
join [Level] L on ES.LevelID = L.LevelID
where L.LevelName = 'Experts'
and CJT.JobTaskID in 
			(select CJT.JobTaskID
			from Cust_JOB_Task CJT
			join Job J on J.JobID = CJT.JobID
			join Tool on CJT.ToolID = Tool.ToolID
			join Tool_Condition TC on Tool.ToolID = TC.ToolID
			join Condition C on TC.ConditionID = C.ConditionID
			where C.ConditionName = 'damaged'
			and TC.BeginDate between J.JobBeginDate and J.JobEndDate)
group by count(ES.EmpID)
having count(ES.EmpID) < 4


--> how many tasks were assigned to apprenticese that involved power tools that
--> were jobs that generated more than 25,000 in sales

select Count(TaskID)
from Task T
join Cust_JOB_Task CJT on T.TaskID = CJT.TaskID
join Employee_Skill ES on CJT.EmpSkillID = ES.EmpSkillID
join Employee E on ES.EmpID = E.EmpID
join EmployeePosition EP on E.EmpID = EP.EmpID
join Position P on EP.PositionID = P.PositionID
join Tool on CJT.ToolID = Tool.ToolID
join Tool_Type TT on Tool.ToolTypeID = TT.ToolTypeID
where TT.ToolTypeName = 'power tool'
and P.PositionName = 'apprentice'
and CJT.JObTaskID IN 
				
					(select CJT.JobTaskID
					from Cust_JOB_Task CJT
					join Job J on J.JobID = CJT.JobID
					join [Order] O on J.JobID = O.JobID
					join Line_Item LI on O.OrderID = LI.OrderID
					join Product Pr on LI.ProductID = Pr.ProductID
					where Sum(Pr.Price * LI.Qty) > 25000)
group by Count(taskID)
