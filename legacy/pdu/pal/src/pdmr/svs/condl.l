%start separ 
%%
[sS][eE][lL][eE][cC][tT]	{
			     	ECHO;
				return (_c_select);
			}
[dD][iI][sS][tT][iI][nN][cC][tT]	{
				ECHO;
				return (_c_distinct);
			}
[A-Za-z][A-Za-z0-9_]*\.[A-Za-z][A-Za-z0-9_]* 	{
				ECHO;
				return (_c_column_name);
			}
[fF][rR][oO][mM]		{
				ECHO;
				return (_c_from);
			}
[aA][nN][dD]			{
				ECHO;
				return (_c_outside_and);
			}
[oO][rR]			{
				ECHO;
				return (_c_outside_or);
			}

">="				{
				ECHO;
				return (_c_greater_equal);
			}
">"				{
				ECHO;
				return (_c_greater);
			}
"<="				{
				ECHO;
				return (_c_less_equal);
			}
"<"				{
				ECHO;
				return (_c_less);
			}
"="				{
				ECHO;
				return (_c_equal);
			}
"<>"				{
				ECHO;
				return (_c_un_equal);
			}
"!="				{
				ECHO;
				return (_c_not_equal);
			}
[bB][eE][tT][wW][eE][eE][nN]	{
				ECHO;
				return (_c_between);
			}
[iI][nN]			{
				ECHO;
				return (_c_in);
			}

[iI][sS]			{
				ECHO;
				return (_c_is);
			}

[nN][uU][lL][lL]		{
				ECHO;
				return (_c_null);
			}

[lL][iI][kK][eE]		{
				ECHO;
				return (_c_like);
			}
[nN][oO][tT]			{
				ECHO;
				return (_c_not);
			}
[nN][oO][tT][ \t]+[bB][eE][tT][wW][eE][eE][nN]	{
				ECHO;
				return (_c_not_between);
			}
[+-]?[0-9]+				{
				ECHO;
				return (_c_int_value);
			}

[+-]?[0-9][0-9]*\.[0-9][0-9]*	{
				ECHO;
				return (_c_real_value);
			}
"*"				{
				ECHO;
				return (_c_multiply);
			}
"/"				{
				ECHO;
				return (_c_divide);
			}
"+"				{
				ECHO;
				return (_c_add);
			}
"-"				{
				ECHO;
				return (_c_subtract);
			}
","				{
				ECHO;
				return (_c_comma);
			}
"("				{
				ECHO;
				BEGIN separ;
				return (_c_open);
			}
")"				{
				ECHO;
				BEGIN 0;
				return (_c_close);
			}
\'[A-Za-z0-9][A-Za-z0-9]*\'			{
				ECHO;
				return (_c_string);
			}
[A-Za-z][A-Za-z0-9_]*		{
				ECHO;
				return (_c_table_name);
			}
%%

yywrap ()
{
	return (1);
}
