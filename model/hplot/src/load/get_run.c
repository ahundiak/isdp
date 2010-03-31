#include "odi.h"
#include <stdio.h>
#include "HPdef.h"


/* ------- declaration and arguments ---------------------------------------- */

int get_run (num, token, token_str, src_file, out_file, line)

  uint16 * num;		/* how many doubles were gotten */
  int	 * token;	/* input token */
  char	 * token_str;	/* token string if more than one char */
  FILE	 * src_file;	/* source file pointer */
  FILE	 * out_file;	/* output file pointer */
  int	 * line;	/* source line number counter */

/* -------

   Outline:
     get double values of the form: [{] dbl dbl ... [}]
     first token is given as argument
     get leading bracket, if any
     get doubles, return count if num arg given
     get trailing bracket, if any
     write double values to output file if file pointer given

   History:
     19-Apr-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  double  dbl;			/* a double value */
  int	  status;		/* return code from called functions */
  int	  j;			/* counter */
  char	  got_bracket = 0;	/* flag: letter of leading bracket */
  char	  ok = 1;		/* flag: operation ok */


/* ------- code ------------------------------------------------------------- */

/* get leading bracket */
  switch (* token)
    {
      case '{':
      case '(':
      case '[':
        got_bracket = * token;
        * token = get_token (token_str, src_file, line);
        break;
      case 'e':
      case 'f':
      case 'i':
        break;
      default:
        fprintf (stderr, "line %d: expected open bracket or double, got %s\n",
            * line, token_str);
        return HSplot_error;
    }

/* get doubles, write them out if file given, return number if requested */
  for (j = 0; ; ++ j)
    {
      status = get_signed_double (& dbl, token, token_str, src_file, line);
      if( status ) break;

      if (out_file)
        {
          status = fwrite (& dbl, sizeof (double), 1, out_file);
          if (status <= 0) return HSplot_error;
        }
      * token = get_token (token_str, src_file, line);
    }
  if (num) * num = j;

/* check trailing bracket */
  if (got_bracket)
    {
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
      * token = get_token (token_str, src_file, line);
    }

  return HSplot_success;
} /* get_run */
