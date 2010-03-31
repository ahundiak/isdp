#include "odi.h"
#include <stdio.h>
#include "HPdef.h"


#define is_token(x) (!strcmp (tok_str, x))
#define if_token(x) if (is_token (x))


/* ------- declaration and arguments ---------------------------------------- */

int line_element (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

/* -------

   Outline:
     handle keywords:
       style:  integer value
         -or-
       width:  unsigned short value
         -or-
       points

   History:
     21-Apr-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  double  width;		/* line width value */
  long	  pos;			/* input file position */
  uint32  num_points = 0;	/* number of points in element */
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  tok_str [200];	/* token string if more than one char */
  uint8	  command [2];		/* current command being processed */
  uint16  style;		/* line style index */
  uint16  level = 0;		/* graphic level number */
  char	  is_element = 0;	/* flag: is line element */


/* ------- code ------------------------------------------------------------- */

/* get keyword to determine which command */
  token = get_token (tok_str, src_file, line);

  if_token ("style")
    {
/* line style int */
      token = get_token (tok_str, src_file, line);
      if (token != 'i')
        {
          fprintf (stderr, "line %d: expected line style index, got \"%s\"\n",
              * line, tok_str);
          return HSplot_error;
        }
      style = atoi (tok_str);

/* write command id, style index */
      command [0] = BASIC_ATTR_COMMAND;
      command [1] = SET_ACTIVE_LINE_STYLE;
      status = fwrite (command, sizeof (uint8), 2, out_file);
      if (status <= 0) return HSplot_error;
      status = fwrite (& style, sizeof (style), 1, out_file);
      if (status <= 0) return HSplot_error;

/* get end of command token */
      token = get_token (tok_str, src_file, line);
    }
  else if_token ("width")
    {
/* line width u16 */
      token = get_token (tok_str, src_file, line);

	sscanf( tok_str, "%lf", &width );

/* write command id, style index */
      command [0] = BASIC_ATTR_COMMAND;
      command [1] = SET_ACTIVE_LINE_WIDTH;
      status = fwrite (command, sizeof (uint8), 2, out_file);
      if (status <= 0) return HSplot_error;
      status = fwrite (& width, sizeof (width), 1, out_file);
      if (status <= 0) return HSplot_error;

/* get end of command token */
      token = get_token (tok_str, src_file, line);
    }
  else
    {
      is_element = 1;

/* handle phrase "level int" */
      if (is_token ("level") || is_token ("group"))
        {
          token = get_token (tok_str, src_file, line);
          if (token != 'i')
            {
              fprintf (stderr, "line %d: expected level number, got \"%s\"\n",
                  * line, tok_str);
              return HSplot_error;
            }

/* save level number, get next token */
          level = atoi (tok_str);
          token = get_token (tok_str, src_file, line);
        }

/* get number of points in line */
      pos = ftell (src_file);
      status = get_points (& num_points, &token, tok_str, src_file, NULL, line,
          ';');
      if( status ) return HSplot_error;
    }

/* check end of command */
  if (token != ';')
    {
      fprintf (stderr, "line %d: expected ';' for line command, got \"%s\"\n",
          * line, tok_str);
      return HSplot_error;
    }

/* if was line element, write it out */
  if (is_element)
    {
    }

  return HSplot_success;
} /* line_element */
