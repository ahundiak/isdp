#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

/* ------- declaration and arguments ---------------------------------------- */

int get_signed_double (dbl, token, token_str, src_file, line)

  double * dbl;		/* double value returned */
  int	 * token;	/* input token */
  char	 * token_str;	/* token string if more than one char */
  FILE	 * src_file;	/* source file pointer */
  int	 * line;	/* source line number counter */

{
  char	  negative = 0;	/* flag: saw leading - */

  extern double atof ();


/* ------- code ------------------------------------------------------------- */

/* check leading sign */
  switch (* token)
    {
      case '+':
        * token = get_token (token_str, src_file, line);
        break;
      case '-':
        negative = 1;
        * token = get_token (token_str, src_file, line);
        break;
      default:
        break;
    }

/* get double */
  if (* token == 'f' || * token == 'e' || * token == 'i')
    {
      * dbl = atof (token_str);
      if (negative) * dbl = - * dbl;
    }
  else return HSplot_error;

  return HSplot_success;
} /* get_signed_double */
