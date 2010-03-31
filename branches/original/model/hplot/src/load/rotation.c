#include "odi.h"
#include <stdio.h>
#include "HPdef.h"


#define if_token(x) if (!strcmp (tok_str, x))


/* ------- declaration and arguments ---------------------------------------- */

int rotation (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

/* -------

   Outline:
     handle keywords:
       rotation:  4x4 matrix value

   History:
     21-SHP-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  tok_str [200];	/* token string if more than one char */
  uint8	  command [2];		/* current command being processed */


/* ------- code ------------------------------------------------------------- */

/* set rotation matrix, 4x4 */
  command [0] = BASIC_ATTR_COMMAND;
  command [1] = SET_ACTIVE_ROTATION_MATRIX;
  status = fwrite (command, sizeof (uint8), 2, out_file);
  if (status <= 0) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

/* check end of command */
  token = get_token (tok_str, src_file, line);
  if (token != ';')
    {
      fprintf (stderr, "line %d: expected ';' for rotation, got \"%s\"\n",
          * line, tok_str);
      return HSplot_error;
    }

  return HSplot_success;
} /* rotation */


/* ------- declaration and arguments ---------------------------------------- */

int post_rotation (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

/* -------

   Outline:
     handle keywords:
       post_rotation:  4x4 matrix value

   History:
     21-SHP-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  tok_str [200];	/* token string if more than one char */
  uint8	  command [2];		/* current command being processed */


/* ------- code ------------------------------------------------------------- */

/* set post_rotation matrix, 4x4 */
  command [0] = BASIC_ATTR_COMMAND;
  command [1] = SET_ACTIVE_POST_ROTATION_MATRIX;
  status = fwrite (command, sizeof (uint8), 2, out_file);
  if (status <= 0) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

/* check end of command */
  token = get_token (tok_str, src_file, line);
  if (token != ';')
    {
      fprintf (stderr, "line %d: expected ';' for post_rotation, got \"%s\"\n",
          * line, tok_str);
      return HSplot_error;
    }

  return HSplot_success;
} /* post_rotation */

/*---viewport_to_wld-----------------------------------------------*/

int viewport_to_wld (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

/* -------

   Outline:
     handle keywords:
       viewport_to_wld:  4x4 matrix value

   History:
     21-SHP-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  tok_str [200];	/* token string if more than one char */
  uint8	  command [2];		/* current command being processed */


/* ------- code ------------------------------------------------------------- */

/* set rotation matrix, 4x4 */
  command [0] = BASIC_ATTR_COMMAND;
  command [1] = SET_VIEWPORT_TO_WLD_MATRIX;
  status = fwrite (command, sizeof (uint8), 2, out_file);
  if (status <= 0) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

  token = get_token (tok_str, src_file, line);
  status = get_doubles (4, NULL, &token, tok_str, src_file, out_file, line);
  if( status ) return HSplot_error;

/* check end of command */
  token = get_token (tok_str, src_file, line);
  if (token != ';')
    {
      fprintf (stderr, "line %d: expected ';' for viewport_to_wld, got \"%s\"\n",
          * line, tok_str);
      return HSplot_error;
    }

  return HSplot_success;
} /* viewport_to_wld */


