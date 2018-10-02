<!--- Test Query Data // Start --->
<!--- <cfquery name="qUsers">
	SELECT 	*
	FROM 	users
</cfquery> --->

<!--- Courses with a related module that will turn into a <select> element --->
<cfquery name="qCourses">
	SELECT 	c.*, m.id as module_id, m.title as module_title
	FROM 	courses c
	JOIN	modules m on m.id = c.module_id
</cfquery>
<!--- Test Query Data // End --->




<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
	<meta name="viewport" content="width=device-width, initial-scale=1"/>
	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
	<title>CF Inline Editor</title>
	<!-- Bootstrap -->
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css" />
	<!--- Fontawesome --->
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.3.1/css/all.css">

	<!--- Select2 --->
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.5/css/select2.min.css">


	<!-- IMPO :: Custom inline editor style -->
	<link rel="stylesheet" href="style.css" />
</head>
<body>
	<div class="container">
		<div class="row">
			<div class="col-12 p-0 pb-5">			
				<h1>CF Inline Editor</h1>
			</div>			
			
			<!--- Manual --->
			<!--- 
			<div class="js-inline-editor" title="Click to edit" data-original="This is just a dummy container and is not connected to a database table.">
				This is just a dummy container and is not connected to a database table.
			</div>

			


			<div class="w-100 mt-3 mb-3">
				#$.editor.create(
					table = 'users'
					,update_column = 'firstname'
					,pk_col = 'id'
					,pk_id = 3
					,the_value = 'The value to be edited'
				)#
			</div> 
			--->

			<p> The below table is connected to the CIPCI Courses table on the dev server</p>

			<!--- Courses with related module --->
			<legend>Courses</legend>
			<table class="table">
				<thead>
					<tr>
						<th>Description (string)</th>
						<th>Course Module (Select)</th>
						<th title="A custom date input should be created. This is only using the 'string' editor function">Date (uses string)</th>
						<th title="A custom NUMBER input should be created. This is only using the 'string' editor function">MAX Attempts (uses string)</th>
					</tr>
  				</thead>

				<cfloop query="qCourses">
					<cfset table = 'courses'>
					<cfset pk_col = 'id'>

					<tr>
						<td>
							#$.editor.create(
								table = table
								,update_column = 'description'
								,pk_col = 'id'
								,pk_id = qCourses.id
								,the_value = qCourses.description
							)#
						</td>
						<td>
							#$.editor.create_select_editor(
								table = table
								,update_column = 'module_id'
								,pk_col = pk_col
								,pk_id = qCourses.id

								,the_value = qCourses.module_title
								,the_value_id = qCourses.module_id

								,related_table = 'modules'
								,related_table_pk_id = 'id'
								,related_table_col = 'title'
							)#
						</td>
						<td>
							#$.editor.create(
								table = table
								,update_column = 'date_updated'
								,pk_col = 'id'
								,pk_id = qCourses.id
								,the_value = qCourses.date_updated
							)#
						</td>
						<td>
							#$.editor.create(
								table = table
								,update_column = 'max_attempts_allowed'
								,pk_col = 'id'
								,pk_id = qCourses.id
								,the_value = qCourses.max_attempts_allowed
							)#
						</td>
					</tr>
				</cfloop>
			</table>


		</div>
	</div>


	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/js/bootstrap.bundle.min.js"></script>
	
	<!--- Alert --->
	<script src="https://cdn.jsdelivr.net/npm/sweetalert2@7.28.2/dist/sweetalert2.all.min.js"></script>

	<!--- IMPO :: Custom inline editor script --->
	<script src="script.js"></script>
</body>
</html>
</cfoutput>