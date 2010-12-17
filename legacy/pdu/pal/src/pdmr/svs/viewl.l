/*	Modified int_value and real_value to include signs	*/
%start OUTERPAR INNERPAR
%%
[cC][rR][eE][aA][tT][eE]	{
				ECHO;
				return (_create);
			}
[vV][iI][eE][wW]		{
				ECHO;
				return (_view);
			}
[aA][sS]			{
				ECHO;
				return (_as);
			}
[sS][eE][lL][eE][cC][tT] 	{
			     	ECHO;
				return (_select);
			}
[A-Za-z][A-Za-z0-9_]*\.[A-Za-z][A-Za-z0-9_]* 	{
				ECHO;
				return (_column_name);
			}
[fF][rR][oO][mM]		{
				ECHO;
				return (_from);
			}
[wW][hH][eE][rR][eE]		{
				ECHO;
				return (_where);
			}
<INNERPAR>[aA][nN][dD]		{
				ECHO;
				return (_inside_inside_and);
			}
<OUTERPAR>[aA][nN][dD]		{
				ECHO;
				return (_inside_and);
			}
[aA][nN][dD]			{
				ECHO;
				return (_outside_and);
			}
<OUTERPAR>[oO][rR]			{
				ECHO;
				return (_inside_or);
			}
[oO][rR]			{
				ECHO;
				return (_outside_or);
			}

">="				{
				ECHO;
				return (_greater_equal);
			}
">"				{
				ECHO;
				return (_greater);
			}
"<="				{
				ECHO;
				return (_less_equal);
			}
"<"				{
				ECHO;
				return (_less);
			}
"="				{
				ECHO;
				return (_equal);
			}
"<>"				{
				ECHO;
				return (_un_equal);
			}
"!="				{
				ECHO;
				return (_not_equal);
			}
[nN][oO][tT]			{
				ECHO;
				return (_not);
			}
[bB][eE][tT][wW][eE][eE][nN]	{
				ECHO;
				return (_between);
			}
[iI][nN]			{
				ECHO;
				return (_in);
			}

[iI][sS]			{
				ECHO;
				return (_is);
			}

[nN][uU][lL][lL]		{
				ECHO;
				return (_null);
			}

[lL][iI][kK][eE]		{
				ECHO;
				return (_like);
			}
[+-]?[0-9]+				{
				ECHO;
				return (_int_value);
			}

[-+]?[0-9][0-9]*\.[0-9][0-9]*	{
				ECHO;
				return (_real_value);
			}
"*"				{
				ECHO;
				return (_multiply);
			}
"/"				{
				ECHO;
				return (_divide);
			}
"+"				{
				ECHO;
				return (_add);
			}
"-"				{
				ECHO;
				return (_subtract);
			}
","				{
				ECHO;
				return (_comma);
			}
<OUTERPAR>"("				{
				ECHO;
				BEGIN INNERPAR;
				return (_inside_open);
			}
"("				{
				ECHO;
				BEGIN OUTERPAR;
				return (_open);
			}
<INNERPAR>")"				{
				ECHO;
				BEGIN 0;
				BEGIN OUTERPAR;
				return (_inside_close);
			}
")"				{
				ECHO;
				BEGIN 0;
				return (_close);
			}
\'[\%\$\:\-\_ \.A-Za-z0-9/]*\'	{
				ECHO;
				return (_string);
			}
[A-Za-z][A-Za-z0-9_]*		{
				ECHO;
				return (_view_table_name);
			}
%%

yywrap ()
{
	printf ("%s\n", yytext);
	return (1);
}
