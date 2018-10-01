<cfcontent type="application/json"/>
<cfscript>
obj = $.editor.save_select(
	FORM.sull,
	FORM.the_value_id
);
</cfscript>
<cfoutput>
{
	"result": #obj.success#,
	"message": "#obj.message#",
	"new_select_span": "#obj.new_select_span#"
}
</cfoutput>