create function fn_noNegSalaries()
returns int
as 
begin

	declare @ret int = 0
	if exists(select *
				from tblEmpPosition
				where Salary <= 0
				)

	begin
	set @ret = 1
	end
	
return @ret
end

alter table tblempposition
add constraint ck_noNegSalaries
check (dbo.fn_noNegSalaries() = 0)