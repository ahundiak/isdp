%start separ 
%%
[A-Za-z][A-Za-z0-9_]*		{
				ECHO;
				return (_c_column_name);
			}
[\.][A][N][D][\.]			{
				ECHO;
				return (_c_outside_and);
			}
[\.][O][R][\.]			{
				ECHO;
				return (_c_outside_or);
			}

[\.][G][E][\.]				{
				ECHO;
				return (_c_greater_equal);
			}
[\.][G][T][\.]				{
				ECHO;
				return (_c_greater);
			}
[\.][L][E][\.]				{
				ECHO;
				return (_c_less_equal);
			}
[\.][L][T][\.]				{
				ECHO;
				return (_c_less);
			}
[\.][E][Q][\.]				{
				ECHO;
				return (_c_equal);
			}
[\.][N][E][\.]				{
				ECHO;
				return (_c_not_equal);
			}
[N][O][T]			{
				ECHO;
				return (_c_not);
			}
[0-9]+				{
				ECHO;
				return (_c_int_value);
			}

[0-9][0-9]*\.[0-9][0-9]*	{
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
%%

yywrap ()
{
	return (1);
}
