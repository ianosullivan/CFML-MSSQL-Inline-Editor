<cfcomponent>

	<!--- These are the delimeters between a key-value pair and a list item --->
	<cfset variables.key_value_delimeter = '~~'> 
	<cfset variables.list_delimeter = '|||'>


	<cffunction name="create" returntype="string" hint="Returns a span containing the item with the attributes needed to make it editable">
		<cfargument name="table" type="string" required="true">
		<cfargument name="update_column" type="string" required="true">
		<cfargument name="pk_col" type="string" required="true">
		<cfargument name="pk_id" type="numeric" required="true">
		<cfargument name="the_value" type="string" required="true">
		<cfargument name="related_table" type="string" required="false" default="">

		<!--- Make a list of key-values --->
		<cfset local.key_value_list	= 
			"random_time" & variables.key_value_delimeter & dateTimeFormat( now(),'yyyyddmm-hhnnss' ) & variables.list_delimeter &
			"table" & variables.key_value_delimeter & ARGUMENTS.table & variables.list_delimeter &
			"update_column" & variables.key_value_delimeter & ARGUMENTS.update_column & variables.list_delimeter &
			"pk_col" & variables.key_value_delimeter & ARGUMENTS.pk_col & variables.list_delimeter &
			"pk_id" & variables.key_value_delimeter & ARGUMENTS.pk_id & variables.list_delimeter &
			"related_table" & variables.key_value_delimeter & ARGUMENTS.related_table
		>

		<!--- Now encrypt the list that will be stored as a data attribute on the span --->
		<cfset LOCAL.encrypted_val = encrypt(local.key_value_list, application.secret_key, 'AES', 'Base64')>

		<!--- Create the span to be returned for output with the encrypted attribute --->
		<cfsavecontent variable="local.return_html">
		<cfoutput>
			<span class="js-inline-editor-container">
				<span class="js-inline-editor" title="Click to edit" data-original-value="#arguments.the_value#" data-sull="#local.encrypted_val#">#arguments.the_value#</span>
			</span>
		</cfoutput>
		</cfsavecontent>

		<cfreturn LOCAL.return_html>
	</cffunction>


	<cffunction name="save" returntype="struct" hint="Pass in a key. Decrypt and try to save to the DB. Used for Editors and for Selects">
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

		 	<!--- Transform the decrypted list into a struct for use below --->
		 	<cfset local.obj = listToStruct(LOCAL.decrypted_list, variables.key_value_delimeter, variables.list_delimeter)>
			<!--- <cfdump var="#local.obj#"> --->

		 	<cfquery name="local.q">
		 		UPDATE 	#local.obj.table#
		 		SET 	#local.obj.update_column# = <cfqueryparam value="#arguments.the_value#" cfsqltype="longnvarchar">
		 		WHERE 	#local.obj.pk_col# = <cfqueryparam value="#local.obj.pk_id#" cfsqltype="longnvarchar">
		 	</cfquery>			

			<!--- Old way using lists instead of a struct...
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
			--->
		<cfcatch type="any">
			<cfset local.return_obj.success = false>
			<cfset local.return_obj.message = cfcatch.message>
		</cfcatch>
		</cftry>

		<!--- If we get to here it has been successful --->
		<cfreturn local.return_obj>
	</cffunction>


	<cffunction name="create_select_editor" returntype="string" hint="Returns a span containing the item with the attributes needed to make it editable and turn it into a <select> via the build_select() function below">
		<cfargument name="table" type="string" required="true">
		<cfargument name="update_column" type="string" required="true">
		<cfargument name="pk_col" type="string" required="true">
		<cfargument name="pk_id" type="numeric" required="true">

		<cfargument name="the_value" type="string" required="true">
		<cfargument name="the_value_id" type="numeric" required="true">

		<cfargument name="related_table" type="string" required="true">
		<cfargument name="related_table_pk_id" type="string" required="true">
		<cfargument name="related_table_col" type="string" required="true">

		<!--- 
		<cfset LOCAL.encrypted_val = encrypt(
		 		dateTimeFormat( now(),'yyyyddmm-hhnnss' )
		 		& '|||' & ARGUMENTS.table
		 		& '|||' & ARGUMENTS.update_column
		 		& '|||' & ARGUMENTS.pk_col
		 		& '|||' & ARGUMENTS.pk_id
		 		& '|||' & ARGUMENTS.related_table
		 		& '|||' & ARGUMENTS.related_table_pk_id
	 		, application.secret_key, 'AES', 'Base64'
	 	)> --->

		<!--- Make a list of key-values --->
		<cfset local.key_value_list	= 
			"random_time" & variables.key_value_delimeter & dateTimeFormat( now(),'yyyyddmm-hhnnss' ) & variables.list_delimeter &
			"table" & variables.key_value_delimeter & ARGUMENTS.table & variables.list_delimeter &
			"update_column" & variables.key_value_delimeter & ARGUMENTS.update_column & variables.list_delimeter &
			"pk_col" & variables.key_value_delimeter & ARGUMENTS.pk_col & variables.list_delimeter &
			"pk_id" & variables.key_value_delimeter & ARGUMENTS.pk_id & variables.list_delimeter &

			"the_value_id" & variables.key_value_delimeter & ARGUMENTS.the_value_id & variables.list_delimeter &

			"related_table" & variables.key_value_delimeter & ARGUMENTS.related_table & variables.list_delimeter &
			"related_table_pk_id" & variables.key_value_delimeter & ARGUMENTS.related_table_pk_id & variables.list_delimeter &
			"related_table_col" & variables.key_value_delimeter & ARGUMENTS.related_table_col
		>

		<!--- Now encrypt the list that will be stored as a data attribute on the span --->
		<cfset local.encrypted_val = encrypt(local.key_value_list, application.secret_key, 'AES', 'Base64')>

		<cfsavecontent variable="local.return_html">
			<cfoutput>
			<span class="js-inline-select" data-original-value="#arguments.the_value#" data-sull="#local.encrypted_val#" title="Click to select new value">
				<span>#arguments.the_value#</span>
			</span>
			</cfoutput>
		</cfsavecontent>

		<cfreturn LOCAL.return_html>
	</cffunction>


	<cffunction name="make_select" returntype="string" hint="Pass in the encrypted val. Decrypt and build the <select> from it">
		<cfargument name="encrypted_val" type="string" required="true">

		<!--- Try to decrypt and return the user ID. If not just return zero --->
	 	<!--- <cfset LOCAL.decrypted_list = decrypt( arguments.encrypted_val, application.secret_key, 'DESede', 'Base64')> --->
	 	<cfset local.decrypted_list = decrypt( arguments.encrypted_val, application.secret_key, 'AES', 'Base64')>
	 	<!--- <cfdump var="#local.decrypted_list#"> --->

	 	<!--- Transform the decrypted list into a struct for use below --->
	 	<cfset local.obj = listToStruct(LOCAL.decrypted_list, variables.key_value_delimeter, variables.list_delimeter)>
		<!--- <cfdump var="#local.obj#"> --->

		<!--- SELECT From the related table --->
	 	<cfquery name="local.qryRelatedData">
	 		SELECT 		#local.obj.related_table_pk_id#, #local.obj.related_table_col#
	 		FROM 		#local.obj.related_table#
	 		ORDER BY 	#local.obj.related_table_col# ASC
	 	</cfquery>			

	 	<!--- Build the Select --->
		<cfsavecontent variable="local.return_html">
		<cfoutput>
			<select <!--- multiple="multiple" ---> class="form-control">
				<!--- Loop over the related table and output the ID and the text value --->
				<cfloop query="local.qryRelatedData">
					<!--- Get the id and the text value using the syntax query['column'][row] --->
					<cfset local.id_val = local.qryRelatedData['#local.obj.related_table_pk_id#'][local.qryRelatedData.currentrow]>
					<cfset local.text_val = local.qryRelatedData['#local.obj.related_table_col#'][local.qryRelatedData.currentrow]>

					<!--- Select the current 'value_id' --->
					<option value="#local.id_val#" <cfif local.id_val EQ local.obj.the_value_id>selected</cfif>>
						#local.text_val#
					</option>
				</cfloop>
			</select>
		</cfoutput>
		</cfsavecontent>

		<cfreturn local.return_html>
	</cffunction>


	<cffunction name="save_select" returntype="struct" hint="Pass in a key. Decrypt and try to save to the DB. Used for Editors and for Selects">
		<cfargument name="encrypted_val" type="string" required="true">
		<cfargument name="the_value_id" type="string" required="true">

		<!--- Assume success --->
		<cfset local.return_obj.success = true>
		<cfset local.return_obj.message = local.return_obj.new_select_span = ""> <!--- set default empty --->

		<cftry>
			<!--- Try to decrypt and return the user ID. If not just return zero --->
		 	<!--- <cfset LOCAL.decrypted_list = decrypt( arguments.encrypted_val, application.secret_key, 'DESede', 'Base64')> --->
		 	<cfset LOCAL.decrypted_list = decrypt( arguments.encrypted_val, application.secret_key, 'AES', 'Base64')>

		 	<!--- <cfdump var="#LOCAL.decrypted_list#"> --->

		 	<!--- Transform the decrypted list into a struct for use below --->
		 	<cfset local.obj = listToStruct(LOCAL.decrypted_list, variables.key_value_delimeter, variables.list_delimeter)>
			<!--- <cfdump var="#local.obj#"> --->

		 	<cfquery name="local.q">
		 		UPDATE 	#local.obj.table#
		 		SET 	#local.obj.update_column# = <cfqueryparam value="#arguments.the_value_id#" cfsqltype="longnvarchar">
		 		WHERE 	#local.obj.pk_col# = <cfqueryparam value="#local.obj.pk_id#" cfsqltype="longnvarchar">
		 	</cfquery>			

		 	<!--- Need to get the text value so we can recreate the select <span> element --->
		 	<cfquery name="local.qVal">
		 		SELECT 	#local.obj.related_table_col# as the_text_value
		 		FROM 	#local.obj.related_table#
		 		WHERE 	#local.obj.related_table_pk_id# = <cfqueryparam value="#arguments.the_value_id#" cfsqltype="longnvarchar">
		 	</cfquery>			

		 	<!--- We need to create a new select span element --->
		 	<cfset local.return_obj.new_select_span = create_select_editor(
				local.obj.table,
				local.obj.update_column,
				local.obj.pk_col,
				local.obj.pk_id,

				local.qVal.the_text_value,
				arguments.the_value_id,

				local.obj.related_table,
				local.obj.related_table_pk_id,
				local.obj.related_table_col
		 	)>

		 	<!--- Need to serialize the span for the JSON object --->
			<cfset local.return_obj.new_select_span = urlencodedformat(local.return_obj.new_select_span)>

			<!--- <cfdump var="#local.return_obj.new_select_span#"> --->

			<!--- Old way using lists instead of a struct...
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

			 	<!--- <cfdump var="#local#"> --->--->
		<cfcatch type="any">
			<cfset local.return_obj.success = false>
			<cfset local.return_obj.message = cfcatch.message>
		</cfcatch>
		</cftry>

		<!--- If we get to here it has been successful --->
		<cfreturn local.return_obj>
	</cffunction>


	<cfscript>
	/**
	 * https://cflib.org/udf/listToStruct
	 * Converts a delimited list of key/value pairs to a structure.
	 * v2 mod by James Moberg
	 * 
	 * @param list      List of key/value pairs to initialize the structure with.  Format follows key=value. (Required)
	 * @param delimiter      Delimiter seperating the key/value pairs.  Default is the comma. (Optional)
	 * @return Returns a structure. 
	 * @author Rob Brooks-Bilson (rbils@amkor.com) 
	 * @version 2, April 1, 2010 
	 */
	function listToStruct(list, key_val_delimiter='=', list_delimiter=','){
		local.myStruct = structNew();
		local.i = 1;
		// local.array_of_list = arrayNew(1);
		local.array_of_list = listToArray(list, arguments.list_delimiter);

		for (local.i; local.i <= arrayLen(local.array_of_list); local.i++){
			if (! structKeyExists(local.myStruct, trim(ListFirst(local.array_of_list[i], arguments.key_val_delimiter)))) {
				structInsert(local.myStruct, trim(ListFirst(local.array_of_list[i], arguments.key_val_delimiter)), trim(ListLast(local.array_of_list[i], arguments.key_val_delimiter)));
			}
		}
		return local.myStruct;
	}
	</cfscript>
</cfcomponent>