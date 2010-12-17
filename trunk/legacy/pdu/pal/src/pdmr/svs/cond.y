%{
	extern	char	yytext[];
	extern  char	exp_cond[MAX_SVS_COND_LEN];	
	extern	int	NoExp, result[];

	int	i, j, val, type;
	char	c_temp[32*2], col_nam[32*2], operator[8];
%}
%start whole_condition
%token _c_column_name 
%token _c_greater _c_greater_equal _c_less _c_less_equal _c_equal
%token _c_un_equal _c_not_equal _c_not _c_between _c_not_between _c_in _c_like
%token _c_multiply _c_divide _c_add _c_subtract
%token _c_open _c_close
%token _c_is _c_null _c_string _c_int_value _c_real_value
%token _c_comma
%token _c_outside_or _c_outside_and
%%
whole_condition	: complex_condition
		  { return (1); }
		  |
		  condition
		  { return (0) ; }

complex_condition : complex_condition conj condition
		    { NoExp++; }
		    |
		    condition
		    { NoExp++; }

conj		:  _c_outside_or 
		   |
		   _c_outside_and
		   { strcat (exp_cond, " && "); }

condition 	:  expression oper expression
		   { strcat (exp_cond, "~");
		     result[NoExp] = (Expression (val, operator, exp_cond));
	           }
		  |
		   expression 
		   { strcpy (col_nam, c_temp); }
		   _c_not_between 
		   { strcat (exp_cond, " <= "); }
	           expression conj 
		   { strcat (exp_cond, " || ");
		     strcat (exp_cond, col_nam);
		     strcat (exp_cond, " >= ");
	           }
		   expression
		   { strcat (exp_cond, "~");
		     result[NoExp] = (Between (type, "<=", exp_cond));
		   }
		   |
		   expression 
		   { strcpy (col_nam, c_temp); }
		   _c_between 
		   { strcat (exp_cond, " >= "); }
	           expression conj 
		   { strcat (exp_cond, " && ");
		     strcat (exp_cond, col_nam);
		     strcat (exp_cond, " <= ");
		   }
		   expression
		   { 
		     strcat (exp_cond, "~");
    		     result[NoExp] = (Between (type, ">=", exp_cond));
		   }
		  |
		   expression _c_in 
		   { strcat (exp_cond, " in "); }
		   _c_open 
		   { strcat (exp_cond, " ( "); }
		   value_list _c_close
		   { strcat (exp_cond, " ) ");
		     strcat (exp_cond, "~");
		     result[NoExp] = (InValueList (1, exp_cond));
		   }
		  |
		   expression _c_not 
      		   { strcat (exp_cond, " not "); }
		   _c_in 
      		   { strcat (exp_cond, " in "); }
		   _c_open 
		   { strcat (exp_cond, " ( "); }
		   value_list _c_close
		   { strcat (exp_cond, " ) "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (InValueList (0, exp_cond));
		   }
		  |
		   expression _c_is 
		   { strcat (exp_cond, " is "); }
		   _c_not 
		   { strcat (exp_cond, " not "); }
		   _c_null
		   { strcat (exp_cond, " null "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (IsNull (0, exp_cond));
		   }
		  |
		   expression _c_is 
		   { strcat (exp_cond, " is "); }
		   _c_null
		   { strcat (exp_cond, " null "); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (IsNull (1, exp_cond));
		   }
		  |
		   expression _c_not _c_like  
		   { strcat (exp_cond, " != "); }
		   _c_string 
		   { strcat (exp_cond, yytext); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (LikeString (0, exp_cond));
		   }
		  |
		   expression
		   _c_like  
		   { strcat (exp_cond, " = "); }
		   _c_string 
		   { strcat (exp_cond, yytext); 
		     strcat (exp_cond, "~");
		     result[NoExp] = (LikeString (1, exp_cond));
		   }
		  |
		   expression _c_equal
		  { strcat (exp_cond, " = "); }  
		   _c_string
		  { strcat (exp_cond, yytext); 
		    strcat (exp_cond, "~");
		    strcpy (operator, "=");
		    result[NoExp] = (StringExpression (operator, exp_cond));
		   }
		   |
		   expression _c_not_equal
		  { strcat (exp_cond, " != "); }  
		  _c_string
		  { strcat (exp_cond, yytext); 
		     strcat (exp_cond, "~");
		    strcpy (operator, "!=");
		    result[NoExp] = (StringExpression (operator, exp_cond));
		   }

expression	: expression oper operand
		  |
		  operand

operand		: value
		  |
		  _c_column_name
		  { 
		    strcpy (exp_cond, yytext); 
		    strcpy (c_temp, yytext);
		  }

oper 		: _c_greater
		  { strcat (exp_cond,  " > "); 
		    val = 0;
		    strcpy (operator, ">");
		  }
		  |
		  _c_greater_equal
		  { strcat (exp_cond,  " >= "); 
		    val = 1;
		    strcpy (operator, ">=");
		  }
		  |
		  _c_less
		  { strcat (exp_cond,  " < "); 
		    val = 2;
		    strcpy (operator, "<");
		  }
		  |
		  _c_less_equal
		  { strcat (exp_cond,  " <= "); 
		    val = 3;
		    strcpy (operator, "<=");
		  }
		  |
		  _c_un_equal
		  { strcat (exp_cond,  " <> "); 
		    val =4;
		    strcpy (operator, "<>");
		  }
		  |
		  _c_not_equal
		  { strcat (exp_cond,  " != "); 
		    val = 5;
		    strcpy (operator, "!=");
		  }
		  |
		  _c_equal
		  { strcat (exp_cond,  " = "); 
		    val = 6;
		    strcpy (operator, "=");
		  }

value_list	: value_list _c_comma 
		  {strcat (exp_cond, ","); }
		  value
		  |
		  value

value		: _c_int_value
		  { strcat (exp_cond,  yytext);
		    type = 0;
		  }
		  |
		  _c_real_value
		  { strcat (exp_cond,  yytext); 
		    type = 0;
		  }
		  |
		  _c_string
		  { strcat (exp_cond, yytext);
		    type = 1;
		  }
%%
yyerror(str)
char	*str;
{
	fprintf (stderr, "Error -> %s\n", exp_cond);
	return (-2);
} 
