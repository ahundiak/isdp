
%{
#include <stdio.h>
#include <math.h>

#ifndef SUNOS 
#include <ctype.h>
#else
#undef output
#endif
#include "OMminimum.h"
#include "OMtypes.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "gotextdef.h"
#include "dimerror.h"
#ifdef SUNOS 
#define output(c) putc(c, dmout)
#endif
#undef input
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):((inpindx < inpsize)?inpbuf[inpindx++]:EOF))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)

static char *inpbuf, *outbuf;
static struct GRid *expbuf;
static int  inpindx, outindx, expindx;
static int  inpsize, outsize, expsize, errsts;
static double cnv_fact;

#define DOUBLE_FORMAT	0
#define INTEGER_FORMAT	1
#define STRING_FORMAT	2
#define NEWLINE_FORMAT	3
#define CHAR_FORMAT	4
#define check_status(sts) if (!(sts & 1)) return(sts);

%}

DBLFORMAT	%[0-9]*[.]?[0-9]*[l]f
STRFORMAT	%[0-9]*s
INTFORMAT	%[0-9]*[l]?d
NEWLINE		\n

%%

{DBLFORMAT}	{
			errsts = DMformat(yytext, DOUBLE_FORMAT);
			check_status(errsts);
		}

{INTFORMAT}	{
			errsts = DMformat(yytext, INTEGER_FORMAT);
			check_status(errsts);
		}

{STRFORMAT}	{
			errsts = DMformat(yytext, STRING_FORMAT);
			check_status(errsts);
		}

{NEWLINE}	{
			errsts = DMformat(yytext, NEWLINE_FORMAT);
			check_status(errsts);
		}

.		{
			errsts = DMformat(yytext, CHAR_FORMAT);
			check_status(errsts);
		}

%%

/*------------- DMparse_txexpr ----------------------------

	This function takes as input a text expression
	in standard printf format and replaces the expanders
	(%s, %lf etc.,) with the corresponding expressions.

	Arguments:
	----------

	char *input_expr	(I)	Input text expression
	int   input_size	(I)	size of the input expression
	struct GRid list[]	(I)	list of expression ids
	int   count		(I)	number of expression ids
	char *output_expr	(O)	output text expression buffer
	short  *output_size	(I/O)	size of the output expression
					replaced by the bytes filled
	double conv_factor	(I)	conversion factor to change
					the expression value from
					system units to dim units.

-------------------------------------------------------------*/

DMparse_txexpr(input_expr,  input_size, list, count,
	       output_expr, output_size, conv_factor)
char *input_expr;
int   input_size;
struct GRid list[];
int   count;
char *output_expr;
short  *output_size;
double conv_factor;
{
	inpbuf  = input_expr;
	inpsize = input_size;
	inpindx = 0;

	outbuf  = output_expr;
	outsize = *output_size;
	outindx = 0;

	expbuf  = list;
	expsize = count;
	expindx = 0;

	cnv_fact = conv_factor;

	errsts = DIM_S_SUCCESS;
	yylex();
	*output_size = outindx;

	return(errsts);
}

yywrap()
{
	return(1);
}

/*
  Jaikish T.G   3/9/97  added the function roundn() to avoid inconsistent
                        rounding of the value to the desired digit.
*/

void roundn (double *val,int acc)
{
 int i,j;
 double fact1,fact2;

 fact1 = pow(10.0,(double)acc + 1.0);
 fact2 = fact1/10.0;


 i = (int)(*val);
 j = fact1 * (*val - i);

 if ((j%10)>=5)
    j = j/10 + 1;
 else
    j = j/10;
 *val = i + ((double)j)/fact2;
}

DMformat(s, type)
char *s;
int type;
{
	int  status, len;
	double d;
	char buf[128],*ptr;
	int acc,dot;

	if (type == CHAR_FORMAT)
	{
		if (outindx < outsize)
		{
			outbuf[outindx++] = s[0];
			return(DIM_S_SUCCESS);
		}
		else	return(DIM_E_BUFSIZE);
	}

	if (type == NEWLINE_FORMAT)
	{
		if ((outindx + 1) < outsize)
		{
			outbuf[outindx++] = ESC;
			outbuf[outindx++] = 10;
			return(DIM_S_SUCCESS);
		}
		else	return(DIM_E_BUFSIZE);
	}

	if (expindx >= expsize)
		return(DIM_E_EXPSIZE);

	switch (type)
	{
		case DOUBLE_FORMAT:

		status = DMgive_value(expbuf[expindx++], &d);
		check_status(status);
		dot = (int)'.';
		ptr = (char *)strchr(s,dot);
		ptr++;
		acc = atoi(ptr);
		roundn(&d,acc);
		d *= cnv_fact;
		len = sprintf(buf, s, d);
		buf[len] = '\0';
		break;

		case INTEGER_FORMAT:

		status = DMgive_value(expbuf[expindx++], &d);
		check_status(status);
		d *= cnv_fact;
		len = sprintf(buf, s, (int)(d + 1e-14));
		buf[len] = '\0';
		break;

		case STRING_FORMAT:

		status = DMgive_formula(expbuf[expindx++], buf);
		check_status(status);
		len = strlen(buf);
		break;

		default:
		return(DIM_E_INVFORMAT);
	}

	if ((outindx + len) < outsize)
	{
		memcpy(&outbuf[outindx], buf, len);
		outindx += len;
		return(DIM_S_SUCCESS);
	}
	else	return(DIM_E_BUFSIZE);
}

