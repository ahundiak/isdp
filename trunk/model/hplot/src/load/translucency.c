#include "odi.h"
#include <stdio.h>
#include "HPdef.h"

#define if_token(x) if (!strcmp (tok_str, x))


/* ------- declaration and arguments ---------------------------------------- */

int translucency (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

/* -------

   Outline:
     if token is keyword "grid", set grid value, integer
     else token must be translucency value, integer

   History:
     21-Apr-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  tok_str [200];	/* token string if more than one char */
  uint8	  command [2];		/* current command being processed */
  uint8	  value;		/* translucency grid or value */


/* ------- code ------------------------------------------------------------- */

/* get keyword to determine if set translucency grid or value */
  token = get_token (tok_str, src_file, line);
  if_token ("grid")
    {
/* translucency grid value */
      token = get_token (tok_str, src_file, line);
      command [0] = SETUP_COMMAND;
      command [1] = SET_TRANSLUCENCY_GRID;
    }
  else
    {
/* translucency value */
      command [0] = BASIC_ATTR_COMMAND;
      command [1] = SET_ACTIVE_TRANSLUCENCY;
    }

  if (token != 'i')
    {
      fprintf (stderr, "line %d: expected translucency value, got \"%s\"\n",
          * line, tok_str);
      return HSplot_error;
    }
  value = atoi (tok_str);
  status = fwrite (command, sizeof (uint8), 2, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& value, sizeof (value), 1, out_file);
  if (status <= 0) return HSplot_error;

/* check end of command */
  token = get_token (tok_str, src_file, line);
  if (token != ';')
    {
      fprintf (stderr,
          "line %d: expected ';' for translucency command, got \"%s\"\n",
          * line, tok_str);
      return HSplot_error;
    }

  return HSplot_success;
} /* translucency */
