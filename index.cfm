<cfinclude template="build.cfm">

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

			
			<table class="table">
				<thead>
					<tr>
						<th>First</th>
						<th>Last</th>
						<th>Email</th>
						<th>Admin</th>
						<th>Reset</th>
					</tr>
  				</thead>

				<cfloop query="qUsers">
					<tr>
						<td>
							#$.editor.create(
								table = 'users'
								,update_column = 'firstname'
								,pk_col = 'id'
								,pk_id = qUsers.id
								,the_value = qUsers.firstname
							)#
						</td>
						<td>
							#$.editor.create(
								table = 'users'
								,update_column = 'surname'
								,pk_col = 'id'
								,pk_id = qUsers.id
								,the_value = qUsers.surname
							)#
						</td>
						<td>
							#$.editor.create(
								table = 'users'
								,update_column = 'email'
								,pk_col = 'id'
								,pk_id = qUsers.id
								,the_value = qUsers.email
							)#
						</td>
						<td>
							#$.editor.create(
								table = 'users'
								,update_column = 'is_admin'
								,pk_col = 'id'
								,pk_id = qUsers.id
								,the_value = qUsers.is_admin
							)#
						</td>
						<td>
							#$.editor.create(
								table = 'users'
								,update_column = 'reset_password'
								,pk_col = 'id'
								,pk_id = qUsers.id
								,the_value = qUsers.reset_password
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