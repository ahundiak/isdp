#include "odi.h"
#include <stdio.h>
#include "HPdef.h"



#define if_token(x) if (!strcmp (tok_str, x))


/* ------- declaration and arguments ---------------------------------------- */

int get_points (num_points, token, tok_str, src_file, out_file, line, end_token)

  uint32 * num_points;	/* number of points seen */
  int	 * token;	/* input token */
  char	 * tok_str;	/* token string if more than one char */
  FILE	 * src_file;	/* source file pointer */
  FILE	 * out_file;	/* output file pointer */
  int	 * line;	/* source line number counter */
  int	   end_token;	/* token to stop at */

/* -------

   Outline:
     keywords:
       points: point values, write to output if file given
       poles:  same

   History:
     21-Apr-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */


/* ------- code ------------------------------------------------------------- */

  while (* token != end_token && * token != EOF)
    {
/* ignore words "points" and "poles" */
      if_token ("points")
        {}
      else if_token ("poles")
        {}

/* stop if some other word */
      else if (* token == 'w')
        break;

/* better be a 3d point, count/write them */
      else
        {
          status = get_doubles (3, NULL, token, tok_str, src_file,
              out_file, line);
          if( status ) return HSplot_error;
          if (num_points) ++ * num_points;
        }

      * token = get_token (tok_str, src_file, line);
    }

  return HSplot_success;
} /* get_points */
