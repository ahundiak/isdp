#include "odi.h"
#include <stdio.h>
#include "HPdef.h"



#define if_token(x) if (!strcmp (tok_str, x))


/* ------- declaration and arguments ---------------------------------------- */

int rendering_mode (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

{
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  tok_str [200];	/* token string if more than one char */
  uint8	  command [2];		/* current command being processed */
  uint8	  mode;			/* rendering mode value */


/* ------- code ------------------------------------------------------------- */

/* get token, ignore if is keyword "mode" */
  token = get_token (tok_str, src_file, line);
  if_token ("mode") token = get_token (tok_str, src_file, line);

/* process mode value */
   mode = 127;
   while (token != EOF && token != ';')
    {
/* wireframe key */
      if_token ("wireframe")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 0;
        }

/* smooth shading key */
      else if_token ("smooth")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 1;
        }

/* constant shading key */
      else if_token ("constant")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 2;
        }

/* raster hidden line key */
      else if_token ("raster")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 3;
        }

/* filled hidden line key */
      else if_token ("filled")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 4;
        }

/* area fill key */
      else if_token ("area_fill")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 5;
        }

/* styled hidden raster key */
      else if_token ("styled")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 6;
        }

/* show hidden raster key */
      else if_token ("show")
        {
          if (mode != 127)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
          mode = 7;
        }

/* ignore */
      else if_token ("z_buffered")
        {
          if (mode == 0)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
        }

/* ignore */
      else if_token ("shading")
        {
          if (mode == 0)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
        }

/* ignore */
      else if_token ("hidden")
        {
          if (mode == 0)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
        }

/* ignore */
      else if_token ("line")
        {
          if (mode == 0)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
        }

/* ignore */
      else if_token ("edges")
        {
          if (mode == 0)
            {
              fprintf (stderr, "line %d: conflicting rendering modes\n", *line);
              return HSplot_error;
            }
        }

/* unknown word */
      else
        {
          fprintf (stderr, "line %d: expected rendering mode, got \"%s\"\n",
              * line, tok_str);
          return HSplot_error;
        }
      token = get_token (tok_str, src_file, line);
    }

/* write command: id, mode */
  command [0] = BASIC_ATTR_COMMAND;
  command [1] = SET_ACTIVE_RENDERING_MODE;
  status = fwrite (command, sizeof (uint8), 2, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& mode, sizeof (mode), 1, out_file);
  if (status <= 0) return HSplot_error;

  return HSplot_success;
} /* rendering_mode */


/*---tiling_tolerance--------------------------------------------*/

int tiling_tolerance(src_file, out_file, line)

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int		status;		/* return code from called functions */
	int		token;		/* input token */
	char		tok_str[200];	/* token string if more than one char */
	uint8		command[2];	/* current command being processed */
	double		tiling_tolerance;

	token = get_token (tok_str, src_file, line);
	if (token != 'f')
		{
		fprintf( stderr, "line %d: expected tiling_tolerance, got \"%s\"\n",
			*line, tok_str);
			
		return HSplot_error;
		}
		
	status = get_doubles( 1, &tiling_tolerance, &token, tok_str, src_file, NULL, line );

	/* write command id, style index */
	
	command [0] = BASIC_ATTR_COMMAND;
	command [1] = SET_ACTIVE_TILING_TOLERANCE;
	
	status = fwrite (command, sizeof (uint8), 2, out_file);
	if (status <= 0) return HSplot_error;
	
	status = fwrite (&tiling_tolerance, sizeof (tiling_tolerance), 1, out_file);
	if (status <= 0) return HSplot_error;


	/* get end of command token */

	token = get_token (tok_str, src_file, line);

	/* check end of command */

	if (token != ';')
		{
		fprintf (stderr, "line %d: expected ';' for line command, got \"%s\"\n",
			* line, tok_str);
			
		return HSplot_error;
		}

	return HSplot_success;
	}

/*---shading_accuracy--------------------------------------------*/

int shading_accuracy(src_file, out_file, line)

FILE	*src_file;	/* source file pointer */
FILE	*out_file;	/* output file pointer */
int	*line;		/* source line number counter */

	{
	int		status;		/* return code from called functions */
	int		token;		/* input token */
	char		tok_str[200];	/* token string if more than one char */
	uint8		command[2];	/* current command being processed */
	short		shading_accuracy;

	token = get_token (tok_str, src_file, line);
	if (token != 'i')
		{
		fprintf( stderr, "line %d: expected shading_accuracy, got \"%s\"\n",
			*line, tok_str);
			
		return HSplot_error;
		}
		
	status = get_doubles( 1, &shading_accuracy, &token, tok_str, src_file, NULL, line );

	/* write command id, style index */
	
	command [0] = BASIC_ATTR_COMMAND;
	command [1] = SET_ACTIVE_SHADING_ACCURACY;
	
	status = fwrite (command, sizeof (uint8), 2, out_file);
	if (status <= 0) return HSplot_error;
	
	status = fwrite (&shading_accuracy, sizeof (shading_accuracy), 1, out_file);
	if (status <= 0) return HSplot_error;


	/* get end of command token */

	token = get_token (tok_str, src_file, line);

	/* check end of command */

	if (token != ';')
		{
		fprintf (stderr, "line %d: expected ';' for line command, got \"%s\"\n",
			* line, tok_str);
			
		return HSplot_error;
		}

	return HSplot_success;
	}

