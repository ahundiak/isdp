%{
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define	AllocNCat(ptr, string) {					\
	ptr = (char *) realloc (ptr, 					\
	(strlen (ptr) + 1 + strlen (string) + 1) * sizeof (char));	\
									\
	if (ptr == NULL) {						\
		fprintf (stderr, "Unable To Allocate Memory\n");	\
		return (0);						\
	}								\
									\
	strcat (ptr, string);						\
}

	extern	char	yytext[];	/* Becomes DIN_yytext after compilation (see makefile )	*/
	extern  char	*DLexp_cond;	
	extern	int	NoExpressions, DLresult[];

/* 09/Aug/95 - raj. changed to static. Clash with 3.2 MODEL on SPARC
	int	i, j, val, type;
	char	c_temp[32*2], col_nam[32*2], operator[8];
*/
/* 04/Sep/95 - raj. Removed i, j and col_nam. Added PDUPAL_ prefix to the rest. */
	static int	/* i, j, */ PDUPAL_val, PDUPAL_type;
	static char	PDUPAL_c_temp[32*2], /* col_nam[32*2], */ PDUPAL_operator[8];
%}
%start whole_condition
%token _c_column_name 
%token _c_greater _c_greater_equal _c_less _c_less_equal _c_equal
%token _c_not_equal _c_not
%token _c_multiply _c_divide _c_add _c_subtract
%token _c_open _c_close
%token _c_string _c_int_value _c_real_value
%token _c_outside_or _c_outside_and
%%
whole_condition	: complex_condition
		  { return (1); }
		  |
		  condition
		  { return (0) ; }

complex_condition : complex_condition conj condition
		    { NoExpressions++; }
		    |
		    condition
		    { NoExpressions++; }

conj		:  _c_outside_or 
		   |
		   _c_outside_and
		   { AllocNCat (DLexp_cond, " && "); }

condition 	:  expression oper expression
		   { AllocNCat (DLexp_cond, "~");
		     DLExpression (PDUPAL_val, PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
	           }
		  |
		   expression _c_equal
		  { AllocNCat (DLexp_cond, " = "); }  
		   _c_string
		  { AllocNCat (DLexp_cond, yytext); 
		    AllocNCat (DLexp_cond, "~");
		    strcpy (PDUPAL_operator, "=");
		    DLStringExpression (PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
		   }
		   |
		   expression _c_not_equal
		  { AllocNCat (DLexp_cond, " != "); }  
		  _c_string
		  { AllocNCat (DLexp_cond, yytext); 
		     AllocNCat (DLexp_cond, "~");
		    strcpy (PDUPAL_operator, "!=");
		    DLStringExpression (PDUPAL_operator, DLexp_cond, &DLresult[NoExpressions]);
		     free ((char *)DLexp_cond);
		     DLexp_cond = NULL;
		   }

expression	: expression oper operand
		  |
		  operand

operand		: value
		  |
		  _c_column_name
		  { 
		    if (DLexp_cond != NULL)
		    	DLexp_cond = (char *) realloc (DLexp_cond, (strlen (yytext) + 1) * sizeof (char));
		    else
		    	DLexp_cond = (char *) malloc ((strlen (yytext) + 1) * sizeof (char));
		    if (DLexp_cond == NULL) {
			printf ("Unable To Allocate Memory\n");
			return (0);
		    }
		    strcpy (DLexp_cond, yytext); 
		    strcpy (PDUPAL_c_temp, yytext);
		  }

oper 		: _c_greater
		  { AllocNCat (DLexp_cond,  " > "); 
		    PDUPAL_val = 0;
		    strcpy (PDUPAL_operator, ">");
		  }
		  |
		  _c_greater_equal
		  { AllocNCat (DLexp_cond,  " >= "); 
		    PDUPAL_val = 1;
		    strcpy (PDUPAL_operator, ">=");
		  }
		  |
		  _c_less
		  { AllocNCat (DLexp_cond,  " < "); 
		    PDUPAL_val = 2;
		    strcpy (PDUPAL_operator, "<");
		  }
		  |
		  _c_less_equal
		  { AllocNCat (DLexp_cond,  " <= "); 
		    PDUPAL_val = 3;
		    strcpy (PDUPAL_operator, "<=");
		  }
		  |
		  _c_not_equal
		  { AllocNCat (DLexp_cond,  " != "); 
		    PDUPAL_val = 5;
		    strcpy (PDUPAL_operator, "!=");
		  }
		  |
		  _c_equal
		  { AllocNCat (DLexp_cond,  " = "); 
		    PDUPAL_val = 6;
		    strcpy (PDUPAL_operator, "=");
		  }

value		: _c_int_value
		  { AllocNCat (DLexp_cond,  yytext);
		    PDUPAL_type = 0;
		  }
		  |
		  _c_real_value
		  { AllocNCat (DLexp_cond,  yytext); 
		    PDUPAL_type = 0;
		  }
		  |
		  _c_string
		  { AllocNCat (DLexp_cond, yytext);
		    PDUPAL_type = 1;
		  }
%%
yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", DLexp_cond);
	return (-2);
} 

