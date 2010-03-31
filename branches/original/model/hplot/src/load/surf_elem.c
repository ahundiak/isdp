#include "odi.h"
#include <stdio.h>
#include "ems_plot_def.h"
#include "HPdef.h"


#define is_token(x) (!strcmp (token_str, x))
#define if_token(x) if (is_token (x))


/* ------- declaration and arguments ---------------------------------------- */

int surface_element (src_file, out_file, line)

  FILE	* src_file;	/* source file pointer */
  FILE	* out_file;	/* output file pointer */
  int	* line;		/* source line number counter */

/* -------

   Outline:

   History:
     24-May-88	LMB	created.
     12-SHP-88	LMB	added range elements.
     20-Dec-88	LMB	corrected surface element with range subtype.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */
  int	  token;		/* input token */
  char	  token_str [200];	/* token string if more than one char */
  int	  lct = 1;		/* local source line counter for second pass */
  long	  pole_pos= 0;		/* file position for poles */
  long	  u_knot_pos = 0;	/* file position for u knots */
  long	  v_knot_pos = 0;	/* file position for v knots */
  long	  weight_pos = 0;	/* file position for weights */
  long	  boundary_pos = 0;	/* file position for boundary curves */
  uint32  num_u_poles = 0;	/* number of poles in u direction */
  uint32  num_v_poles = 0;	/* number of poles in v direction */
  uint8	  command [2];		/* current command being processed */
  uint16  type = 0;		/* surface type */
  uint16  level = 0;		/* graphic level number */
  uint16  num_boundaries = 0;	/* number of curve boundaries */
  uint16  u_order = 0;		/* spline order in u direction */
  uint16  v_order = 0;		/* spline order in v direction */
  uint16  num_u_knots = 0;	/* number of knots in u direction */
  uint16  num_v_knots = 0;	/* number of knots in v direction */
  uint16  num_weights = 0;	/* number of weights */
  uint16  flags = 0;		/* surface flags */
  uint32  attrs_seen = 0;	/* flags: attributes seen in input */
  real64  range [6];		/* range if element has it */

/* attributes seen flags */
# define _level		1
# define _order		(1<<1)
# define _type		(1<<2)
# define _poles		(1<<3)
# define _u_knots	(1<<4)
# define _v_knots	(1<<5)
# define _weights	(1<<6)
# define _boundaries	(1<<7)
# define _u_periodic	(1<<8)
# define _v_periodic	(1<<9)
# define _u_non_uniform	(1<<10)
# define _v_non_uniform	(1<<11)
# define _rational	(1<<12)
# define _planar	(1<<13)
# define _u_closed	(1<<14)
# define _v_closed	(1<<15)
# define _orientation	(1<<16)
# define _solid_hole	(1<<17)
# define _range		(1<<18)


/* ------- code ------------------------------------------------------------- */

/* get keyword attributes to end of command ; */
  token = get_token (token_str, src_file, line);
  while (token != EOF && token != ';')
    {
/* save position in case of no-keyword pole specification */
      if (! (_poles & attrs_seen)) pole_pos = ftell (src_file);

/* get level number, save value */
      if (is_token ("group") || is_token ("level"))
        {
          if (_level & attrs_seen) goto dup_error;
          attrs_seen |= _level;

          token = get_token (token_str, src_file, line);
          if (token != 'i')
            {
              fprintf (stderr, "line %d: expected level number, got \"%s\"\n",
                  * line, token_str);
              return HSplot_error;
            }
          level = atoi (token_str);
        }

/* range box, 2 points */
      else if_token ("range")
        {
          if (_range & attrs_seen) goto dup_error;
          attrs_seen |= _range;

          token = get_token (token_str, src_file, line);
          status = get_doubles (3, range, & token, token_str, src_file,
                                NULL, line);
          if( status ) return HSplot_error;;

          token = get_token (token_str, src_file, line);
          status = get_doubles (3, & range [3], & token, token_str, src_file,
                                NULL, line);
          if( status ) return HSplot_error;;
        }

/* get order numbers, save values */
      else if_token ("order")
        {
          if (_order & attrs_seen) goto dup_error;
          attrs_seen |= _order;

          token = get_token (token_str, src_file, line);
          if (token != 'i')
            {
              fprintf (stderr, "line %d: expected u order value, got \"%s\"\n",
                  * line, token_str);
              return HSplot_error;
            }
          u_order = atoi (token_str);

          token = get_token (token_str, src_file, line);
          if (token != 'i')
            {
              fprintf (stderr, "line %d: expected v order value, got \"%s\"\n",
                  * line, token_str);
              return HSplot_error;
            }
          v_order = atoi (token_str);
        }

/* get type number, save value */
      else if_token ("type")
        {
          if (_type & attrs_seen) goto dup_error;
          attrs_seen |= _type;

          token = get_token (token_str, src_file, line);
          if (token != 'i')
            {
              fprintf (stderr, "line %d: expected type number, got \"%s\"\n",
                  * line, token_str);
              return HSplot_error;
            }
          type = atoi (token_str);
        }

/* get number of poles, no write */
      else if_token ("poles")
        {
          if (_poles & attrs_seen) goto dup_error;
          attrs_seen |= _poles;

          pole_pos = ftell (src_file);
          token = get_token (token_str, src_file, line);
          status = get_points_array (& num_v_poles, & num_u_poles, & token,
              token_str, src_file, NULL, line);
          if( status ) return HSplot_error;;
          continue;
        }

/* get number of u_knots, no write */
      else if_token ("u_knots")
        {
          if (_u_knots & attrs_seen) goto dup_error;
          attrs_seen |= _u_knots;

          u_knot_pos = ftell (src_file);
          token = get_token (token_str, src_file, line);
          status = get_run (& num_u_knots, & token, token_str, src_file,
              NULL, line);
          if( status ) return HSplot_error;;
          continue;
        }

/* get number of v_knots, no write */
      else if_token ("v_knots")
        {
          if (_v_knots & attrs_seen) goto dup_error;
          attrs_seen |= _v_knots;

          v_knot_pos = ftell (src_file);
          token = get_token (token_str, src_file, line);
          status = get_run (& num_v_knots, & token, token_str, src_file,
              NULL, line);
          if( status ) return HSplot_error;;
          continue;
        }

/* get number of weights, no write */
      else if_token ("weights")
        {
          if (_weights & attrs_seen) goto dup_error;
          attrs_seen |= _weights;

          weight_pos = ftell (src_file);
          token = get_token (token_str, src_file, line);
          status = get_run (& num_weights, & token, token_str, src_file,
              NULL, line);
          if( status ) return HSplot_error;;
          continue;
        }

/* get boundary curves */
      else if (is_token ("boundaries") || is_token ("boundary"))
        {
          if (_boundaries & attrs_seen) goto dup_error;
          attrs_seen |= _boundaries;

          boundary_pos = ftell (src_file);
          token = get_token (token_str, src_file, line);
          status = get_boundaries (& num_boundaries, & token, token_str,
              src_file, NULL, line);
          if( status ) return HSplot_error;;
          continue;
        }

/* flags */
      else if_token ("u_periodic")
        {
          attrs_seen |= _u_periodic;
          flags |= SF_U_PERIODIC_M;
        }
      else if_token ("v_periodic")
        {
          attrs_seen |= _v_periodic;
          flags |= SF_V_PERIODIC_M;
        }
      else if_token ("u_non_uniform")
        {
          attrs_seen |= _u_non_uniform;
          flags |= SF_U_NON_UNIFORM_M;
        }
      else if_token ("v_non_uniform")
        {
          attrs_seen |= _v_non_uniform;
          flags |= SF_V_NON_UNIFORM_M;
        }
      else if_token ("rational")
        {
          attrs_seen |= _rational;
          flags |= SF_RATIONAL_M;
        }
      else if_token ("planar")
        {
          attrs_seen |= _planar;
          flags |= SF_PLANAR_M;
        }
      else if_token ("u_closed")
        {
          attrs_seen |= _u_closed;
          flags |= SF_U_CLOSED_M;
        }
      else if_token ("v_closed")
        {
          attrs_seen |= _v_closed;
          flags |= SF_V_CLOSED_M;
        }
      else if_token ("orientation")
        {
          attrs_seen |= _orientation;
          flags |= SF_ORIENTATION_M;
        }
      else if_token ("solid_hole")
        {
          attrs_seen |= _solid_hole;
          flags |= SF_SOLID_HOLE_M;
        }

/* get number of poles, no write */
      else
        {
          if (_poles & attrs_seen) goto dup_error;
          attrs_seen |= _poles;

          status = get_points_array (& num_v_poles, & num_u_poles, & token,
              token_str, src_file, NULL, line);
          if( status ) return HSplot_error;;
          continue;
        }
      token = get_token (token_str, src_file, line);
    }

/* check for required things: order and poles */
  if (! (_order & attrs_seen))
    {
      fprintf (stderr, "line %d: surface orders not specified\n", * line);
      return HSplot_error;
    }
  if (! (_poles & attrs_seen))
    {
      fprintf (stderr, "line %d: no pole for surface\n", * line);
      return HSplot_error;
    }

/* need knots if non-uniform */
  if (_u_non_uniform & attrs_seen)
    {
      if (num_u_knots != (u_order + num_u_poles))
        {
          fprintf (stderr, "line %d: need %d u knots for surface\n", * line,
              u_order + num_u_poles);
          return HSplot_error;
        }
    }

/* need knots if non-uniform */
  if (_v_non_uniform & attrs_seen)
    {
      if (num_v_knots != (v_order + num_v_poles))
        {
          fprintf (stderr, "line %d: need %d v knots for surface\n", * line,
              v_order + num_v_poles);
          return HSplot_error;
        }
    }

/* need weights if rational */
  if (_rational & attrs_seen)
    {
      if (num_weights != num_u_poles * num_v_poles)
        {
          fprintf (stderr, "line %d: need %d weights for surface\n", * line,
               num_u_poles * num_v_poles);
          return HSplot_error;
        }
    }

/* write command: id, level, range if needed, orders, flags, type, */
/*                number of poles, num bdrys */

  if( _range & attrs_seen )
    {
      command [0] = PRIMITIVE_COMMAND;
      command [1] = NURB_SURFACE_WITH_RANGE;
    }
  else
    {
      command [0] = PRIMITIVE_COMMAND;
      command [1] = NURB_SURFACE;
    }
    
  status = fwrite (command, sizeof (uint8), 2, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& level, sizeof (level), 1, out_file);
  if (status <= 0) return HSplot_error;
  if (_range & attrs_seen)
    {
      status = fwrite (range, sizeof (real64), 6, out_file);
      if (status <= 0) return HSplot_error;
    }
  status = fwrite (& u_order, sizeof (u_order), 1, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& v_order, sizeof (v_order), 1, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& flags, sizeof (flags), 1, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& type, sizeof (type), 1, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& num_u_poles, sizeof (num_u_poles), 1, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& num_v_poles, sizeof (num_v_poles), 1, out_file);
  if (status <= 0) return HSplot_error;
  status = fwrite (& num_boundaries, sizeof (num_boundaries), 1, out_file);
  if (status <= 0) return HSplot_error;

/* write poles */
  status = fseek (src_file, pole_pos, 0);
  token = get_token (token_str, src_file, & lct);
  status = get_points_array (NULL, NULL, & token, token_str, src_file,
      out_file, & lct);
  if( status ) return HSplot_error;;

/* write u_knots if needed */
  if (_u_non_uniform & attrs_seen)
    {
      status = fseek (src_file, u_knot_pos, 0);
      token = get_token (token_str, src_file, & lct);
      status = get_run (NULL, & token, token_str, src_file, out_file, & lct);
      if( status ) return HSplot_error;;
    }

/* write v_knots if needed */
  if (_v_non_uniform & attrs_seen)
    {
      status = fseek (src_file, v_knot_pos, 0);
      token = get_token (token_str, src_file, & lct);
      status = get_run (NULL, & token, token_str, src_file, out_file, & lct);
      if( status ) return HSplot_error;;
    }

/* write weights if needed */
  if (_rational & attrs_seen)
    {
      status = fseek (src_file, weight_pos, 0);
      token = get_token (token_str, src_file, & lct);
      status = get_run (NULL, & token, token_str, src_file, out_file, & lct);
      if( status ) return HSplot_error;;
    }

/* if boundaries, do it now */
  if (num_boundaries)
    {
      status = fseek (src_file, boundary_pos, 0);
      token = get_token (token_str, src_file, line);
      status = get_boundaries (NULL, & token, token_str, src_file, out_file,
          & lct);
      if( status ) return HSplot_error;;
    }

/* done */
  return HSplot_success;

/* duplicate error exit */
dup_error:
  fprintf (stderr, "line %d: duplicate surface attribute \"%s\"\n",
      * line, token_str);
  return HSplot_error;
} /* surface_element */
