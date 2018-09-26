<cfcontent type="application/json"/>
<cfscript>
obj = $.editor.save(
			FORM.encrypted_val,
			FORM.the_value
		);
</cfscript>
<cfoutput>
{
	"result": #obj.success#,
	"message": "#obj.message#"
}
</cfoutput>