<cfcomponent output="false">

	<cfset THIS.datasource = "cipci"/>


	<!--- Layout manager --->
	<cffunction name="OnRequestStart" returntype="boolean" output="true">
		<cfargument
			name="template"
			type="string"
			required="true"
			hint="I am the template requested by the user."
			/>

		<!--- If reload is called or application is in full reload mode then run onApplicationStart to reload all singletons --->
    	<cfif structKeyExists(url, "APPReload") OR structKeyExists(url, "ar")>
            <!--- Create an exclusive lock to make this call thread safe --->
            <cflock name="reloadApp" timeout="60" type="exclusive">

				<!--- Reload the app --->
				<cfset onApplicationStart() />
			</cflock>
		</cfif>

		<cfreturn true/>
	</cffunction>


	<!--- Only reason this is here is to create a global variable for CFC calls --->
	<cffunction name="OnRequest" access="public" returntype="void" output="true" hint="Fires after pre page processing is complete.">
        <!--- Define arguments. --->
        <cfargument name="TargetPage" type="string" required="true"/>

		<!--- Set global '$' shorthand variable to access local components --->
		<cfif IsDefined("application.cfcs")>
			<cfset $ = application.cfcs>

		<cfelse>
			<!--- Might need to restart/reload the application and then reset --->
			<cfset onApplicationStart() />
			<cfset $ = application.cfcs>
		</cfif>

		<!--- Create a shorthand for the server functions --->
		<cfset SF = server.functions>

		<!--- Include the requested page. --->
		<cfinclude template="#ARGUMENTS.TargetPage#" />

		<!--- Return out. --->
		<cfreturn />
    </cffunction>


	<!--- Call this by passing 'APPReload' into the URL --->
	<cffunction name="onApplicationStart" output="false">

		<!--- Clear the application scope to ensure it is cleared out --->
		<cfset StructClear(application)>
	
		<!--- Generate a new secret key for every Appreload. 
			This will cause the decryption to fail AFTER the users session has expired
			It should fail gracefully and it should empty the cookie so it is correctly populated after next successful login.
			By having a new secret key generated for every AppReload this can be used as a way to force users to log back into the system AFTER their session has expired
			Note: Ensure the AppReload code comes BEFORE the check_client_variable code
		--->
		<cfset application.secret_key = generateSecretKey('DESede')> 


		<!--- Define the local scope. --->
		<cfset local = {} />

		<!--- Define request settings. --->
		<cfsetting showdebugoutput="false" />

		<!---
			Set the value of the web root. Since we know that this
			template (Application.cfc) is in the web root for this
			application, all we have to do is figure out the
			difference between this template and the requested
			template. Every directory difference will require our
			webroot to have a "../" in it.
		--->

		<!---
			Get the current (Application.cfc) directory path based
			on the current template path.
		--->
		<cfset local.basePath = getDirectoryFromPath(
			getCurrentTemplatePath()
			) />

		<!---
			Get the target (script_name) directory path based on
			expanded script name.
		--->
		<cfset local.targetPath = getDirectoryFromPath(
			expandPath( CGI.script_name )
			) />

		<!---
			Now that we have both paths, all we have to do is
			find the difference in path. We can treat the paths
			as slash-delimmited lists. To do this, let's calculate
			the depth of sub directories.
		--->
		<cfset local.requestDepth = (
			listLen( local.targetPath, "\/" ) -
			listLen( local.basePath, "\/" )
			) />

		<!---
			With the request depth, we can easily create our
			web root by repeating "../" the appropriate number
			of times.
		--->
		<cfset APPLICATION.settings.webRoot = repeatString(
			"../",
			local.requestDepth
			) />

		<!---
			Changed by Ian O'Sullivan so that it will work for localhost development environment also.
			replaced cgi.server_name with cgi.http_host as it picks up the port also.
		--->
		<cfset APPLICATION.settings.site_URL = (
			( cgi.HTTPS IS "on" ? "https://" : "http://" ) &
			cgi.http_host &
			reReplace(
				getDirectoryFromPath( CGI.script_name ),
				"([^\\/]+[\\/]){#local.requestDepth#}$",
				"",
				"one"
				)
			) />
		
		<!--- The physical site root --->
		<cfset APPLICATION.settings.site_root = GetDirectoryFromPath(GETCurrentTemplatePath())>
		<!--- The site folder (used in error email) --->
		<cfset APPLICATION.settings.site_folder = ListLast(APPLICATION.settings.site_root, '\')>

		<!--- Dynamically create components --->
		<cfset CreateComponents()>
	</cffunction>


	<cffunction name="CreateComponents" hint="Create ColdFusion components by looping through the directory">
		<cfset cfcs_relative_path = "cfcs">

		<cfset componenet_path = listChangeDelims(cfcs_relative_path,'.','/\')> <!--- The path for the <cfobject> below needs dots not slashes --->
		<cfset cfcs_full_path = getDirectoryFromPath(getCurrentTemplatePath()) & cfcs_relative_path>
		
		<cfdirectory directory="#cfcs_full_path#" name="cfc_list">

		<cfset application.cfcs = StructNew()>

		<cfloop query="cfc_list">
			<!--- Skip folders --->
			<cfif cfc_list.type EQ "file">
				<cfset file_extension = right(cfc_list.name, 4)>
			
				<!--- Only create components for '.cfc' files --->
				<cfif file_extension EQ ".cfc">
					<cfset cfc_name = mid( name, 1, len(name)-4 )>

					<!--- If you find any rogue characters in the component name skip it. Only aplha, number and underscores allowed --->
					<cfif !reFind('[^A-Za-z0-9_]',cfc_name)>
						<cfobject component="#componenet_path#.#cfc_name#" name="application.cfcs.#cfc_name#">
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>


</cfcomponent>