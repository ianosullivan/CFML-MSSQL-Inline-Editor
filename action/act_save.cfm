<cfcontent type="application/json"/>
<cfscript>
obj = $.editor.save(
			FORM.sull,
			FORM.the_value
		);
</cfscript>
<cfoutput>
{
	"result": #obj.success#,
	"message": "#obj.message#"
}
</cfoutput>