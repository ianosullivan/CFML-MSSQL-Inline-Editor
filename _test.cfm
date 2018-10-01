<!--- <cfscript>
	o = $.editor.listToStruct('a~~123456,b~~456,c~~good stuff,decent~~4567','~~');
	writeDump(o);


				writeOutput($.editor.create(
									table = 'users'
									,update_column = 'firstname'
									,pk_col = 'id'
									,pk_id = 3
									,the_value = 'The value to be edited'
								));
</cfscript>
 --->

 <!--- Courses --->
<!--- 
<cfquery name="qCourses">
	SELECT 	id, title
	FROM 	modules
</cfquery>

<cfdump var="#qCourses['id'][1]#">
<cfdump var="#qCourses['title'][1]#">
 --->


<cfset local.decrypted_list = decrypt( "8ygxSIszwKR5mShzjAZ4qR1H6GuoVPnXFUaZB3mCT3W6gDu6L6skCJjBoyx4spjYQwFMpUxX+vxfEj5fccyUszn9pGouWkf5RnfkdO8DsMR7CaTb+Zs+ntisURwiP+EZy5ulkvH0mnYJUkBqNXdysD1YNd3b1S3s4tbs6K+gXECPPsVZxBTR/BKepSNJTdC56KsSvB5xvYNFnmJbr0ZNIt7Xf2S+i5TetunPoF4nUDY=", application.secret_key, 'AES', 'Base64')>
<cfdump var="#local.decrypted_list#">

<!--- Transform the decrypted list into a struct for use below --->
<!--- <cfset local.obj = listToStruct(LOCAL.decrypted_list, variables.key_value_delimeter, variables.list_delimeter)>
<cfdump var="#local.obj#"> --->