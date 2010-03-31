#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "exsysdep.h"
#include "ems_plot_def.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "hpmsg.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"

/*------------------------------
 *  for function
 *     HSconv_double
 *     HSconv_int
 *     HSconv_short
 */

#include "HSrle.h"
#include "hsanimate.h"
#include "HSpr_rle_uti.h"

#define MAX_POLE_SIZE 1000000

/*--- read_nurb_surface --------------------------------------------------*/

/*
NAME
   read_nurb_surface
        
KEYWORDS
   HSplot
   read
   surface
        
DESCRIPTION
   read nurb surface from the shaded plotfile
        
PARAMETERS
   file_ptr :(IN)    : File pointer for the shaded plotfile
   surface  :(IN/OUT): Buffer in which to store the surface
   bdry_curves :(OUT)   : Place to store the boundary curves
   curves_size :(OUT)   : number of boundary curves
   surface_type :(OUT)   : type of surface

FUNCTIONS CALLED
   free
   fread
   HSconv_short (Sun only)
   HSconv_int (Sun only)
   HSconv_double (Sun only)
   malloc
   calloc
   create_knot_vector
   read_nurb_curve
        
HISTORY
   ??/??/?? M. Lanier
      Created
*/

IGRint read_nurb_surface (FILE * file_ptr,
                          struct IGRbsp_surface * surface,
                          struct IGRbsp_curve ** bdry_curves,
                          IGRint * curves_size,
                          IGRint * surface_type)

   {
   IGRint    status;         /* return code from called functions */
   IGRint    nec_pole_size;  /* necesary pole size (u * v * sizeof) */
   IGRshort  flags;          /* flags word as read from file */
   IGRint    i;              /* counter */
   IGRint    num_poles;      /* total number of poles (u * v) */
   IGRshort  sf_type;        /* surface type code */

   IGRint    surf_pole_size; /* size of surf poles buffer (in points) */
   IGRint    u_knot_size;    /* size of surf knots buffer -- u direction */
   IGRint    v_knot_size;    /* size of surf knots buffer -- v direction */
   IGRint    weight_size;    /* size of surf weights buffer */

   IGRint    nb;

   struct IGRbsp_curve *bdry_curve_ptr; /* pointer for reading bdry curves */

   /* free old boundaries, if any */

   if (surface->bdrys)
      {
      for (i = 0; i < surface->num_boundaries; i++)
         if ((char *) surface->bdrys[i].points)
            {
            free ((char *) surface->bdrys[i].points);
            }

      free ((char *) surface->bdrys);
      surface->bdrys = NULL;
      }

   /* calculate current buffer sizes == surf number rounded up to nearest 100 */

   surf_pole_size = ((surface->u_num_poles * surface->v_num_poles + 99) / 100) * 100;

   u_knot_size = ((surface->u_num_knots + 99) / 100) * 100;
   v_knot_size = ((surface->v_num_knots + 99) / 100) * 100;

   if (surface->weights)
      weight_size = surf_pole_size;
   else
      weight_size = 0;

   /* read order */

   status = fread ((IGRchar *) & surface->u_order, sizeof (IGRshort), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfUOrdr;

   status = fread ((IGRchar *) & surface->v_order, sizeof (IGRshort), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfVOrdr;

#  ifdef BIG_ENDIAN
   HSconv_short (&surface->u_order, 1);
   HSconv_short (&surface->v_order, 1);
#  endif

   /* read flags and distribute them */

   status = fread ((IGRchar *) & flags, sizeof (IGRshort), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfFlgs;

#  ifdef BIG_ENDIAN
   HSconv_short (&flags, 1);
#  endif

   surface->u_periodic = (flags & SF_U_PERIODIC_M) != 0;
   surface->v_periodic = (flags & SF_V_PERIODIC_M) != 0;
   surface->u_non_uniform = (flags & SF_U_NON_UNIFORM_M) != 0;
   surface->v_non_uniform = (flags & SF_V_NON_UNIFORM_M) != 0;
   surface->rational = (flags & SF_RATIONAL_M) != 0;
   surface->planar = (flags & SF_PLANAR_M) != 0;
   surface->u_phy_closed = (flags & SF_U_CLOSED_M) != 0;
   surface->v_phy_closed = (flags & SF_V_CLOSED_M) != 0;
   surface->pos_orient = (flags & SF_ORIENTATION_M) != 0;
   surface->on_off = (flags & SF_SOLID_HOLE_M) != 0;


   /* Read surface type */

   status = fread ((IGRchar *) & sf_type, sizeof (IGRshort), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfTyp;

#  ifdef BIG_ENDIAN
   HSconv_short (&sf_type, 1);
#  endif

   *surface_type = sf_type;


   /* read number of poles */

   status = fread ((IGRchar *) & surface->u_num_poles, sizeof (IGRlong), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfNmUPls;

   status = fread ((IGRchar *) & surface->v_num_poles, sizeof (IGRlong), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfNmVPls;

#  ifdef BIG_ENDIAN
   HSconv_int ((int *) (&surface->u_num_poles), 1);
   HSconv_int ((int *) (&surface->v_num_poles), 1);
#  endif

   /* If the num_poles is greater than the max allowable, then the value */
   /* is assued to be bad (06/23/97 - Mike Lanier) */

   if( surface->u_num_poles > MAX_POLE_SIZE ) return HP_F_RdSrfNmUPls;
   if( surface->v_num_poles > MAX_POLE_SIZE ) return HP_F_RdSrfNmVPls;

   /* read the number of boundaries */

   status = fread ((IGRchar *) & surface->num_boundaries, sizeof (IGRshort), 1, file_ptr);
   if (status <= 0) return HP_F_RdSrfNmBdrys;

#  ifdef BIG_ENDIAN
   HSconv_short (&surface->num_boundaries, 1);
#  endif

   /* check that poles will fit in buffer provided, alloc new if not */

   num_poles = surface->u_num_poles * surface->v_num_poles;
   nec_pole_size = num_poles * 3;

   if (num_poles > surf_pole_size)
      {
      surf_pole_size = ((num_poles + 99) / 100) * 100;

      if (surface->poles) free ((char *) surface->poles);

      surface->poles = (IGRdouble *) malloc (surf_pole_size * 3 * sizeof (IGRdouble));
      }

   /* read poles */

   status = fread ((IGRchar *) surface->poles, sizeof (IGRdouble), nec_pole_size, file_ptr);
   if (status <= 0) return HP_F_RdSrfPls;

#  ifdef BIG_ENDIAN
   HSconv_double (surface->poles, nec_pole_size);
#  endif

   /* check that the u-knots will fit in buffer provided, alloc new if not */

   surface->u_num_knots = surface->u_order + surface->u_num_poles;

   if (surface->u_num_knots > u_knot_size)
      {
      u_knot_size = ((surface->u_num_knots + 99) / 100) * 100;

      if (surface->u_knots) free ((char *) surface->u_knots);

      surface->u_knots = (IGRdouble *) malloc (u_knot_size * sizeof (IGRdouble));
      }

   /* Read the u_knots if the surface is u-non-uniform. If the surface is */
   /* u-uniform, then the knot vector will be calculated.  */

   if (surface->u_non_uniform)
      {
      status = fread ((IGRchar *) surface->u_knots, sizeof (IGRdouble), surface->u_num_knots, file_ptr);
      if (status <= 0) return HP_F_RdSrfUKnts;

#     ifdef BIG_ENDIAN
      HSconv_double (surface->u_knots, surface->u_num_knots);
#     endif
      }

   else
      create_knot_vector( surface->u_knots,
                          surface->u_order,
                          surface->u_num_poles);


   /* check that the v-knots will fit in buffer provided, alloc new if not */

   surface->v_num_knots = surface->v_order + surface->v_num_poles;

   if (surface->v_num_knots > v_knot_size)
      {
      v_knot_size = ((surface->v_num_knots + 99) / 100) * 100;

      if (surface->v_knots) free ((char *) surface->v_knots);

      surface->v_knots = (IGRdouble *) malloc (v_knot_size * sizeof (IGRdouble));
      }

   /* Read the v_knots if the surface is v-non-uniform. If the surface is */
   /* v-uniform, then the knot vector will be calculated.  */

   if (surface->v_non_uniform)
      {
      status = fread ((IGRchar *) surface->v_knots, sizeof (IGRdouble), surface->v_num_knots, file_ptr);
      if (status <= 0) return HP_F_RdSrfVKnts;

#     ifdef BIG_ENDIAN
      HSconv_double (surface->v_knots, surface->v_num_knots);
#     endif
      }

   else
      create_knot_vector( surface->v_knots,
                          surface->v_order,
                          surface->v_num_poles);


   /*
    * read weights if rational
    */

   if (surface->rational)
      {

      /*
       * check that weights will fit in buffer provided, alloc new if not
       */

      if (num_poles > weight_size)
         {
         weight_size = ((num_poles + 99) / 100) * 100;

         if (surface->weights) free ((IGRchar *) surface->weights);

         surface->weights = (IGRdouble *) malloc (weight_size * sizeof (IGRdouble));
         }

      status = fread ((IGRchar *) surface->weights, sizeof (IGRdouble), num_poles, file_ptr);
      if (status <= 0) return HP_F_RdSrfWghts;

#     ifdef BIG_ENDIAN
      HSconv_double (surface->weights, num_poles);
#     endif
      }

   /* Read the boundaries. Since the boundaries are stored in the metafile as */
   /* NURB curves, we read the IGRbsp_curve(s) into our surface definition. */
   /* Anybody who calls this read function must be aware that the */
   /* IGRbsp_surface does not have the boundary definitions yet and must */
   /* convert the boundaries to IGRbsp_bdry_pts (u,v linestring format) */
   /* before calling gpipe, etc.  */

   if (surface->num_boundaries)
      {
      if (surface->num_boundaries > *curves_size)
         {
         if (*bdry_curves)
            {
            bdry_curve_ptr = *bdry_curves;
            for (i = 0; i < (*curves_size); i++, bdry_curve_ptr++)
               {
               if (bdry_curve_ptr->poles) free (bdry_curve_ptr->poles);
               if (bdry_curve_ptr->knots) free (bdry_curve_ptr->knots);
               if (bdry_curve_ptr->weights) free (bdry_curve_ptr->weights);
               }

            free ((IGRchar *) * bdry_curves);
            }

         /*
          * use calloc so that curve sizes will be zero and pointers null
          */

         *curves_size = surface->num_boundaries;

         *bdry_curves = (struct IGRbsp_curve *) calloc( *curves_size,
                                                        sizeof (struct IGRbsp_curve));
         }

      bdry_curve_ptr = *bdry_curves;
      nb = surface->num_boundaries;
      for (i = 0; i < surface->num_boundaries; i++)
         {
         status = read_nurb_curve (file_ptr, 2, bdry_curve_ptr, NULL, NULL);

         if (bdry_curve_ptr->order > 1)
            bdry_curve_ptr++;
         else
            surface->num_boundaries--;

         if (status)
            {
            fprintf (stderr, "boundary read error\n");
            return (HSplot_error);
            }
         }

      } /* end if (surface->num_boundaries) */

   return HSplot_success;
   }
