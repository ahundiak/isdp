#include "odi.h"
#include <stdio.h>
#include "HPdef.h"


/* ------- declaration and arguments ---------------------------------------- */

int get_points_array (num_u, num_v, token, token_str, src_file, out_file, line)

  uint32	* num_u;	/* number of u rows */
  uint32	* num_v;	/* number in each row */
  int		* token;	/* input token */
  char		* token_str;	/* token string if more than one char */
  FILE		* src_file;	/* source file pointer */
  FILE		* out_file;	/* output file pointer */
  int		* line;		/* source line number counter */

/* -------

   Outline:
     get points array of the form: { <points> } { <points> } ...
     first token is given as argument
     write values to output file if file pointer given
     else return counts

   History:
     25-May-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;	/* return code from called functions */
  uint32  j;		/* counter */


/* ------- code ------------------------------------------------------------- */

  for (;;)
    {
      if (* token != '{') break;
      * token = get_token (token_str, src_file, line);

/* write out points if file given, else count */
      if (out_file)
        {
          status = get_points (NULL, token, token_str, src_file, out_file,
              line, '}');
          if( status ) return HSplot_error;
        }
      else
        {
          ++ * num_u;
          j = 0;
          status = get_points (&j, token, token_str, src_file, NULL, line, '}');
          if( status ) return HSplot_error;
          if (* num_v)
            {
              if (* num_v != j)
                {
                  fprintf (stderr, "line %d: expected %d points, got %d\n",
                      * line, * num_v, j);
                  return HSplot_error;
                }
            }
          else * num_v = j;
        }

      if (* token != '}')
        {
          fprintf (stderr, "line %d: expected end bracket -- got \"%s\"\n",
              * line, token_str);
          return HSplot_error;
        }
      * token = get_token (token_str, src_file, line);
    }

  return HSplot_success;
} /* get_points_array */
