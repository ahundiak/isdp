#include <stdio.h>
#include "odi.h"
#include "HPdef.h"

#define	HPload_F_WRITERR	-1
#define	HPload_F_READERR	-2
#define	HPload_F_SEEKERR	-3



/* ------- declaration and arguments ---------------------------------------- */

int get_doubles (num, dbl, token, token_str, src_file, out_file, line)

  int	  num;		/* how many doubles to get */
  double  dbl [];	/* double values returned (if specified) */
  int	* token;	/* input token */
  char	* token_str;	/* token string if more than one char */
  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

{
  double  a_dbl;		/* local double value */
  int	  status;		/* return code from called functions */
  int	  j;			/* counter */
  char	  got_bracket = 0;	/* flag: saw leading bracket */
  char	  ok;			/* flag: operation ok */


/* ------- code ------------------------------------------------------------- */

/* ignore leading brackets */
  switch (* token)
    {
      case '{':
      case '(':
      case '[':
        got_bracket = * token;
        * token = get_token (token_str, src_file, line);
        break;
      default:
        break;
    }

/* get num doubles */
  for (j = 0; j < num; ++ j)
    {
      status = get_signed_double (& a_dbl, token, token_str, src_file, line);
      if( status )
        {
          fprintf (stderr, "line %d: expected double value, got %s\n",
              * line, token_str);
          return HSplot_error;
        }
      
/* return values if requested */
      if (dbl) 
      	{
      	dbl [j] = a_dbl;
	}
	
/* write out doubles if file given */
      if (out_file)
        {
          status = fwrite (& a_dbl, sizeof (double), 1, out_file);
          if (status <= 0) return HSplot_error;
        }

/* get another token if needed */
      if (j < (num - 1)) * token = get_token (token_str, src_file, line);
    }

/* check trailing bracket */
  if (got_bracket)
    {
      * token = get_token (token_str, src_file, line);
      switch (* token)
        {
          case '}':
            ok = got_bracket == '{';
            break;
          case ')':
            ok = got_bracket == '(';
            break;
          case ']':
            ok = got_bracket == '[';
            break;
          default:
            ok = 0;
            break;
        }
      if (! ok)
        {
          fprintf (stderr, "line %d: mismatched brackets -- %c %s\n", * line,
              got_bracket, token_str);
          return HSplot_error;
        }
    }

  return HSplot_success;
} /* get_doubles */
