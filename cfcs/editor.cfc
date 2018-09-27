<cfcomponent>

	<cffunction name="create" returntype="string" hint="Returns a span containing the item with the attributes needed to make it editable">
		<cfargument name="table" type="string" required="true">
		<cfargument name="update_column" type="string" required="true">
		<cfargument name="pk_col" type="string" required="true">
		<cfargument name="pk_id" type="numeric" required="true">
		<cfargument name="the_value" type="string" required="true">
		<cfargument name="related_table" type="string" required="false" default="">

		<!--- Format is {yyyyddmm-hhnnss|||table|||update_column|||pk_col|||pk_id|||related_table}. We add the date part to ensure the value created is unique every time --->
		<!--- Note the first param is used to further randomise the encrypted value along with the app reloaded secret key --->
		<!--- <cfset LOCAL.encrypted_val = encrypt(
			 		dateTimeFormat( now(),'yyyyddmm-hhnnss' )
			 		& '|||' & ARGUMENTS.table
			 		& '|||' & ARGUMENTS.update_column
			 		& '|||' & ARGUMENTS.pk_col
			 		& '|||' & ARGUMENTS.pk_id
			 		& '|||' & ARGUMENTS.related_table
		 		, application.secret_key, 'DESede', 'Base64'
		 	)> --->
		<cfset LOCAL.encrypted_val = encrypt(
			 		dateTimeFormat( now(),'yyyyddmm-hhnnss' )
			 		& '|||' & ARGUMENTS.table
			 		& '|||' & ARGUMENTS.update_column
			 		& '|||' & ARGUMENTS.pk_col
			 		& '|||' & ARGUMENTS.pk_id
			 		& '|||' & ARGUMENTS.related_table
		 		, application.secret_key, 'AES', 'Base64'
		 	)>

		<!--- <cfset LOCAL.return_val = '<span class="js-inline-editor" title="Click to edit" data-original-value="#arguments.the_value#" data-encrypted-val="#local.encrypted_val#">#arguments.the_value#</span>'> --->
		<cfset LOCAL.return_val = '<span class="js-inline-editor-container"><span class="js-inline-editor" title="Click to edit" data-original-value="#arguments.the_value#" data-encrypted-val="#local.encrypted_val#">#arguments.the_value#</span></span>'>

		<cfreturn LOCAL.return_val>
	</cffunction>


	<cffunction name="save" returntype="struct" hint="Pass in a key. Decrypt and try to save to the DB">
		<cfargument name="encrypted_val" type="string" required="true">
		<cfargument name="the_value" type="string" required="true">

		<!--- Assume success --->
		<cfset local.return_obj.success = true>
		<cfset local.return_obj.message = "">

		<cftry>
			<!--- Try to decrypt and return the user ID. If not just return zero --->
		 	<!--- <cfset LOCAL.decrypted_list = decrypt( arguments.encrypted_val, application.secret_key, 'DESede', 'Base64')> --->
		 	<cfset LOCAL.decrypted_list = decrypt( arguments.encrypted_val, application.secret_key, 'AES', 'Base64')>

		 	<!--- <cfdump var="#LOCAL.decrypted_list#"> --->

			<!--- Format is {yyyyddmm-hhnnss|||table|||update_column|||pk_id|||related_table}. We add the date part to ensure the value created is unique every time --->
		 	<cfset LOCAL.table = listGetAt(LOCAL.decrypted_list, 2, '|||')>
		 	<cfset LOCAL.update_column = listGetAt(LOCAL.decrypted_list, 3, '|||')>
		 	<cfset LOCAL.pk_col = listGetAt(LOCAL.decrypted_list, 4, '|||')>
		 	<cfset LOCAL.pk_id = listGetAt(LOCAL.decrypted_list, 5, '|||')>

	
		 	<!--- Do the SQL update 
		 			= encryptbypassphrase('#LOCAL.pass#', CONVERT(VARBINARY(MAX), <cfqueryparam value="#ARGUMENTS.the_value#" cfsqltype="nvarchar">)) --->
		 	<cfquery name="local.q">
		 		UPDATE 	#local.table#
		 		SET 	#local.update_column# = <cfqueryparam value="#arguments.the_value#" cfsqltype="longnvarchar">
		 		WHERE 	#local.pk_col# = <cfqueryparam value="#local.pk_id#" cfsqltype="longnvarchar">
		 	</cfquery>

		 	<!--- For FDI CRM - Get the related table value (if it exists) --->
		 	<!--- 
		 	<cfif LOCAL.decrypted_list EQ 6>
		 		<cfset LOCAL.related_table = listGetAt(LOCAL.decrypted_list, 6, '|||')>

			 	<!--- Do the SQL update of the related table --->
			 	<cfquery name="local.q">
			 		UPDATE 	#local.related_table#
			 		SET 	last_updated_date = #now()#
			 		WHERE 	#local.pk_col# = <cfqueryparam value="#local.pk_id#" cfsqltype="integer">
			 	</cfquery>
		 	</cfif>
		 	--->

		 	<!--- <cfdump var="#local#"> --->

		<cfcatch type="any">
			<cfset local.return_obj.success = false>
			<cfset local.return_obj.message = cfcatch.message>
		</cfcatch>
		</cftry>

		<!--- If we get to here it has been successful --->
		<cfreturn local.return_obj>
	</cffunction>

</cfcomponent>