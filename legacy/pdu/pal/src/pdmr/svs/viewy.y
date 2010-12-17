%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#define	DEBUG 0
#define TRUE	1
#define	FALSE	0
	extern	char	yytext[];
	extern  char	ViewTable[MAX_SVS_PARAMS][MAX_SVS_COND][MAX_SVS_COND_LEN];
	extern	int	NoParams, NoRows, i, j, NoTables;
	extern	char	ViewParamList[MAX_SVS_PARAMS][SVS_NAME_LEN], TableColList[MAX_SVS_PARAMS][SVS_NAME_LEN*2];

	static	int	i, j, row = 0, col = 0, no_table_cols, no_view_cols;
 	static	char	SVStemp[32], arith_oper[4], expression[132], smpl_cnd[132];
 	static	short	table_cols;
	static	int	startRHS, tndx;
	static	char	LHScol[66], RHScol[66], *tbl1, *col1, *tbl2, *col2;
	static	char	tstr[512];
%}
%start view_definition
%token _create _view _view_table_name  _as _select _column_name _from
%token _where _inside_and _inside_inside_and _greater _greater_equal _less _less_equal _equal
%token _un_equal _not_equal _not _between _in _like
%token _multiply _divide _add _subtract
%token _open _close _inside_open _inside_close
%token _is _null _string _int_value _real_value
%token _comma
%token _outside_or _inside_or _outside_and
%%
view_definition	: { 
		   row = 0;
		   NoTables = 0;
		   for (i = 0; i < MAX_SVS_PARAMS; i++)
			TableColList[i][0] = '\0';
		  }
		  _create _view _view_table_name 
		  _open 
		  { i = 0; } 
		  view_col_list _close
		  { NoParams = i; }
		  _as _select
		  { i = 0 ; }
		  table_col_list 
		  { no_table_cols = i; }
		  _from
		  table_name_list
		  where_part

where_part	: _where
		  where_clause
		  {
			NoRows = row;
			PrintResult ();
		  }
		  |

view_col_list	: view_col_list _comma _view_table_name
		  { 
			ToLower (yytext);
			strcpy (ViewParamList[i++], yytext); 
		  }
		  |
		  _view_table_name
		  { 
			ToLower (yytext);
			strcpy (ViewParamList[i++], yytext); 
		  }

table_col_list  : table_col_list _comma table_cols
		  { i++; }
		  |
		  table_cols
		  { i++; }

table_cols	: table_cols  arith_oper { strcat (TableColList[i], arith_oper); }
		  column_or_value 
		  |
		  column_or_value

column_or_value	: _column_name
		  { 
		    ToLower (yytext);
		    strcat (TableColList[i], yytext); 
		  }
		  |
		  values

values 		: _int_value
		  { strcat (TableColList[i],  yytext);}
		  |
		  _real_value
		  { strcat (TableColList[i],  yytext); }

arith_oper	: _add
		  { 
			strcpy (arith_oper, " + "); 
		  }
		  |
		  _subtract
		  { 
			strcpy (arith_oper, " - "); 
		  }	
		  |
		  _multiply
		  { 
			strcpy (arith_oper, " * "); 
		  }
		  |
		  _divide
		  { 
			strcpy (arith_oper, " / "); 
		  }

where_clause 	: where_clause conj selection_criteria
		  |
		  selection_criteria

selection_criteria : _open 
		     { row ++ ; }
		     select_lines _close
		     |
		     select_lines

select_lines	:    select_lines _inside_or
		     line
		     |
		     line

line		:  line conj thecondition
		   |
		   thecondition
		   { col++; }

thecondition	:  _inside_open multicondition _inside_close
		   |
		   multicondition

multicondition	:  multicondition _inside_inside_and condition
		   |
		   condition

condition 	:  expression oper expression
	   	  |
		   expression _between 
		   { strcat (ViewTable[row][col], " between "); }
	           expression _inside_and 
		   { strcat (ViewTable[row][col], " and "); }
		   expression
		  |
		   expression _not _between 
		   { strcat (ViewTable[row][col], " not between "); }
	           expression _inside_and 
		   { strcat (ViewTable[row][col], " and "); }
		   expression
		  |
		   expression _in 
		   { strcat (ViewTable[row][col], " in "); }
		   _inside_open 
		   { strcat (ViewTable[row][col], " ( "); }
		   value_list _inside_close
		   { strcat (ViewTable[row][col], " ) "); }
		  |
		   expression _not 
      		   { strcat (ViewTable[row][col], " not "); }
		   _in 
      		   { strcat (ViewTable[row][col], " in "); }
		   _inside_open 
		   { strcat (ViewTable[row][col], " ( "); }
		   value_list _inside_close
		   { strcat (ViewTable[row][col], " ) "); }
		  |
		   expression _is 
		   { strcat (ViewTable[row][col], " is "); }
		   _not 
		   { strcat (ViewTable[row][col], " not "); }
		   _null
		   { strcat (ViewTable[row][col], " null "); }
		  |
		   expression _is 
		   { strcat (ViewTable[row][col], " is "); }
		   _null
		   { strcat (ViewTable[row][col], " null "); }
		  |
		   expression _not 
		   { strcat (ViewTable[row][col], " not "); }
		   _like  
		   { strcat (ViewTable[row][col], " like "); }
		   _string 
		   { strcat (ViewTable[row][col], yytext); }
		  |
		   expression
		   _like  
		   { strcat (ViewTable[row][col], " like "); }
		   _string 
		   { strcat (ViewTable[row][col], yytext); }
		  |
		   expression _equal
		  { startRHS = TRUE; strcat (ViewTable[row][col], " = "); }  
		   expression
		  { startRHS = FALSE; }
		  |
		   expression _not_equal
		  { strcat (ViewTable[row][col], " != "); }  
		   expression
		  |
		   expression _equal
		  { strcat (ViewTable[row][col], " = "); }  
		   _string
		  { strcat (ViewTable[row][col], yytext); }
		   |
		   expression _not_equal
		  { strcat (ViewTable[row][col], " != "); }  
		  _string
		  { strcat (ViewTable[row][col], yytext); }

expression	: expression oper operand
		  |
		  operand
		  {
		  }
operand		: value
		  |
		  _column_name
		  { 
		    ToLower (yytext);
		    if (startRHS != TRUE)
		    {
			for (i = 0; i < no_table_cols; i++){
				if (!strcmp (TableColList[i], yytext)){
					col = i;
					break;
				}
			}
		    }
		    if (!strcmp(ViewTable[row][col], "")){
			    strcpy (ViewTable[row][col], yytext); 
if (DEBUG)
	printf ("ViewTable[%d][%d] = %s\n", row, col, ViewTable[row][col]);
			    strcpy (SVStemp, yytext);
			    strcpy (LHScol, yytext);
		    }
		    else {
			    if (startRHS == TRUE)
			    {
				/* 'tbl1.col1 = tbl2.col2' format.	*/
				/* Need to convert this to :		*/
				/* 'col1 in (select col2 from tbl2);' */

				/* 'tbl1.col1 = ' is already appended.	*/
				/* Go back to the beginning of this.	*/
				tndx = strlen (ViewTable[row][col]);
				/* Reach for the '.' in 'tbl1.col1'	*/
				while (ViewTable[row][col][--tndx] != '.');
				
				/* Reach for the space before 'tbl1'.	*/
				/* or the beginning.			*/
				while (!isspace(ViewTable[row][col][tndx]))
				{
					--tndx;
					if (tndx == 0)
						break;
				}

				/* If a space is found move to the char after space. */
				if (tndx != 0)
					tndx++;

				/* Append the query from here.	*/
				ViewTable[row][col][tndx] = '\0';
				strcpy (RHScol, yytext);
				strcat (LHScol, "~");
				strcat (RHScol, "~");
				tbl1 = strtok (LHScol, ".");
				col1 = strtok (NULL, "~");
				tbl2 = strtok (RHScol, ".");
				col2 = strtok (NULL, "~");
				sprintf (tstr,
				"%s.%s in ( select DISTINCT %s.%s from %s )",
				tbl1, col1, tbl2, col2, tbl2);
				strcat (ViewTable[row][col], tstr);
if (DEBUG)
	printf ("ViewTable[%d][%d] = %s\n", row, col, ViewTable[row][col]);
				startRHS = FALSE;
			    }
			    else
			    {
				strcat (ViewTable[row][col], " and ");
				strcat (ViewTable[row][col], yytext); 
if (DEBUG)
	printf ("ViewTable[%d][%d] = %s\n", row, col, ViewTable[row][col]);
				strcpy (SVStemp, yytext);
				strcpy (LHScol, yytext);
			    }
		    }
		  }

conj		: _outside_or
  		  { strcpy (ViewTable[row][no_table_cols],  " or "); }
		  |
		  _outside_and
  		  { strcpy (ViewTable[row][no_table_cols],  " and "); }
	          |
		  _inside_and
		  {
		  }
		  |
		  _inside_or
	          { 
		    strcpy (ViewTable[row][no_table_cols],  " or ");
		    row ++ ;
		  }
oper 		: _greater
		  { strcat (ViewTable[row][col],  " > "); }
		  |
		  _greater_equal
		  { strcat (ViewTable[row][col],  " >= "); }
		  |
		  _less
		  { strcat (ViewTable[row][col],  " < "); }
		  |
		  _less_equal
		  { strcat (ViewTable[row][col],  " <= "); }
		  |
		  _un_equal
		  { strcat (ViewTable[row][col],  " <> "); }
		  |
		  _not_equal
		  { strcat (ViewTable[row][col],  " != "); }
		  |
		  _equal
		  { startRHS = TRUE; strcat (ViewTable[row][col],  " = "); }

value_list	: value_list _comma 
		  {strcat (ViewTable[row][col], ","); }
		  value
		  |
		  value
		  {
		  }

value		: _int_value
		  { strcat (ViewTable[row][col],  yytext);}
		  |
		  _real_value
		  { strcat (ViewTable[row][col],  yytext); }
		  |
		  _string
		  { strcat (ViewTable[row][col],  yytext); }

table_name_list	: table_name_list _comma _view_table_name
		  {
			NoTables++;
		  }
		  |
		  _view_table_name
		  {
			NoTables++;
		  }
%%
yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", str);
	return (-2);
} 

ToLower (char *string)
{
	int	lenstr, chcnt;

	lenstr = strlen (string);
	for (chcnt = 0; chcnt < lenstr; chcnt++)
		string[chcnt] = (char) tolower ( (int) string[chcnt] );
}

PrintResult ()
{
if (DEBUG)	{
			printf ("******Successful******\n");
			printf ("No of rows = %d\n", row);
			printf ("No of table cols = %d\n", no_table_cols);
			printf ("No of view cols = %d\n", NoParams);
			for (i = 0; i <= no_table_cols; i++)
				printf ("%d) %s\n", i, TableColList[i]);

			for (i = 0; i <= NoParams; i++)
				printf ("%d) %s\n", i, ViewParamList[i]);

			for (i = 0; i <= row; i++) {
				for (j = 0; j < no_table_cols + 1; j++)
					printf ("%s - ", ViewTable[i][j]);
				printf ("\n");
			}
			printf ("\n\nFinished Printing\n");
		}
}
