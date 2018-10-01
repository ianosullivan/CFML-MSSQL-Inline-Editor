<!--- Test query --->
<cfquery name="qUsers">
	SELECT 	*
	FROM 	users
</cfquery>

<!--- Courses --->
<cfquery name="qCourses">
	SELECT 	c.*, m.id as module_id, m.title as module_title
	FROM 	courses c
	JOIN	modules m on m.id = c.module_id
</cfquery>