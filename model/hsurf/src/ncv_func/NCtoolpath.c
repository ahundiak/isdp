
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "hnmilling.h"
#include "hnerror.h"
#include "hntoolpath.h"
#include "hnsimulate.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hsdisplay.h"
#include "hstiler.h"
#include "hnmill.h"

#include "HSpr_ncv_fun.h"

/*--------------------------
 *  for function
 *     get_curve_sampling_points
 */

#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "HSpr_tiler_f.h"

#include "bstypes.h"
#include "bscvarreval.h"

/*----------------------------*/

#define ZERO_TOL  1.0e-5

#define ABS(x)    (((x) > 0.0) ? (x) : -(x))


/**********************
 * EXTERNAL VARIABLES *
 **********************/

extern struct NC_error_flags    NCerror_flags;
extern struct NC_toolpath_data  NCtoolpath_data;
extern struct NC_window_parms   NCwindow;

/******/
extern struct NC_sim_data   NCsim_data;
/******/


/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRpoint    *ncv_toolpath;     /* the current toolpath */
static IGRpoint    *ncv_orient_vec;   /* the current orientation vector array */
static IGRint      ncv_step_number;   /* the current step number */
static IGRint      ncv_total_steps;   /* the size of the current toolpath */


/*
 *  Prototype declaration for static functions
 */


#if defined (__)
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


/* NCtoolpath.c */
static void CreateRotMatrix __(( IGRdouble *vector,
                                 IGRdouble *x,
                                 IGRdouble *y,
                                 IGRdouble *z));

#if defined(__cplusplus)
}
#endif


#undef __


/*---CreateRotMatrix---------------------------------------------------------*/

/*
Rotation matrix to convert from local (tool) to global coord. system
   (x[0] y[0] z[0])
   (x[1] y[1] z[1])
   (x[2] y[2] z[2])
*/

static void CreateRotMatrix( IGRdouble *vector,
                             IGRdouble *x,
                             IGRdouble *y,
                             IGRdouble *z )

{
   IGRint     i;
   IGRdouble  size = 0.0;


/***
fprintf(stderr, "INC CRM; NORMx=%f, NORMy=%f, NORMz=%f\n",
vector[0], vector[1], vector[2]);
***/

   if ((ABS(vector[0]) < ZERO_TOL) &&
       (ABS(vector[1]) < ZERO_TOL) &&
       (ABS(vector[2]) < ZERO_TOL))
   {
      vector[2]=1.0;
   }

   for (i = 0; i < 3; i++)
   {
      size += vector[i] * vector[i];
   }

   size = sqrt (size);

   for (i = 0; i < 3; i++)
   {
      z[i] = vector[i] / size;
   }

   if (ABS(z[2]) > (1.0 - ZERO_TOL))
   {
      x[0] = 1.0;
      x[1] = 0.0;
      x[2] = 0.0;
      y[0] = 0.0;
      y[1] = z[2];
      y[2] = 0.0;
   }
   else
   {
      IGRdouble denominator;

      denominator = sqrt (z[0] * z[0] + z[1] * z[1]);

      x[0] = - z[1] / denominator;
      x[1] =   z[0] / denominator;
      x[2] =   0.0;

      y[0] = - z[0] * z[2] / denominator;
      y[1] = - z[1] * z[2] / denominator;
      y[2] =   denominator;
  }
}


/*-----NCinit_toolpath--------------------------------------------------------*/

void NCinit_toolpath( IGRpoint start )

/*
 * ABSTRACT:   NCinit_toolpath initializes toolpath-related data.
 *
 * HISTORY:   09/13/88   Created.         C. M. Jablonski
 *
 */

{
   NCtoolpath_data.end_of_toolpath = TRUE;
   ncv_toolpath = NULL;
   ncv_orient_vec = NULL;
}


/*-----NCcleanup_toolpath-----------------------------------------------------*/

void NCcleanup_toolpath(void)

/*
 * ABSTRACT:   NCcleanup_toolpath frees all memory associated with the toolpath.
 *
 * HISTORY:   09/13/88   Created.         C. M. Jablonski
 *
 */

{
   if (ncv_toolpath)
   {
      free (ncv_toolpath);
      ncv_toolpath = NULL;
   }

   if (ncv_orient_vec)
   {
      free (ncv_orient_vec);
      ncv_orient_vec = NULL;
   }
}


/*-----NCinit_toolpath_position-----------------------------------------------*/

void NCinit_toolpath_position( IGRpoint start_loc,
                               IGRpoint start_norm )

/*
 * ABSTRACT:   NCinit_toolpath_position initializes the tool location and
 *             orientation.
 *
 * HISTORY:   09/13/88   Created.         C. M. Jablonski
 *
 */

{
   IGRdouble   normal[3];
   IGRdouble   rot[3][3];

   NCtoolpath_data.curr_location[0] = start_loc[0];
   NCtoolpath_data.next_location[0] = start_loc[0];
 
   NCtoolpath_data.curr_location[1] = start_loc[1];
   NCtoolpath_data.next_location[1] = start_loc[1];

   NCtoolpath_data.curr_location[2] = start_loc[2];
   NCtoolpath_data.next_location[2] = start_loc[2];

   if (NCtoolpath_data.five_axis)
   {
      NCtoolpath_data.curr_orient_vec[0] = start_norm[0];
      NCtoolpath_data.next_orient_vec[0] = start_norm[0];

      NCtoolpath_data.curr_orient_vec[1] = start_norm[1];
      NCtoolpath_data.next_orient_vec[1] = start_norm[1];

      NCtoolpath_data.curr_orient_vec[2] = start_norm[2];
      NCtoolpath_data.next_orient_vec[2] = start_norm[2];

      /* Update orientation parameters */
      normal[0] = start_norm[0];
      normal[1] = start_norm[1];
      normal[2] = start_norm[2];
      CreateRotMatrix( normal, rot[0], rot[1], rot[2] );
      NCchange_orientation( rot );
   }
}


/*-----NCupdate_toolpath_position---------------------------------------------*/

void NCupdate_toolpath_position(void)

/*
 * ABSTRACT:   NCupdate_toolpath_position changes the current location and
 *             orientation.
 *
 * HISTORY:   09/13/88   Created.         C. M. Jablonski
 *
 */

{
   IGRdouble   normal[3];
   IGRdouble   rot[3][3];

   NCtoolpath_data.curr_location[0] = NCtoolpath_data.next_location[0];
   NCtoolpath_data.curr_location[1] = NCtoolpath_data.next_location[1];
   NCtoolpath_data.curr_location[2] = NCtoolpath_data.next_location[2];

   if (NCtoolpath_data.five_axis)
   {
      NCtoolpath_data.curr_orient_vec[0] = NCtoolpath_data.next_orient_vec[0];
      NCtoolpath_data.curr_orient_vec[1] = NCtoolpath_data.next_orient_vec[1];
      NCtoolpath_data.curr_orient_vec[2] = NCtoolpath_data.next_orient_vec[2];

      /* Update orientation parameters */
      normal[0] = NCtoolpath_data.curr_orient_vec[0];
      normal[1] = NCtoolpath_data.curr_orient_vec[1];
      normal[2] = NCtoolpath_data.curr_orient_vec[2];

      CreateRotMatrix( NCtoolpath_data.curr_orient_vec,
                       rot[0],
                       rot[1],
                       rot[2] );
      NCchange_orientation( rot );

      /* Rotate the tool to the new orientation */
      if (NCsim_data.simulation_mode) NCupdate_sim_location();

   }
}


/*-----NCset_tax_toolpath-----------------------------------------------------*/

void NCset_tax_toolpath( struct IGRbsp_curve *curve )

/*
 * ABSTRACT:   NCset_tax_toolpath updates the THREE-AXIS sub_toolpath.
 *
 * HISTORY:   09/13/88   Created.         C. M. Jablonski
 *
 */

{
   IGRlong      rc;
   IGRdouble   *cvpoints;


   /*
    * Cleanup previous toolpath data.
    */
   NCcleanup_toolpath();

   /*
    * Set the five_axis flag.
    */
   NCtoolpath_data.five_axis = FALSE;

   /*
    * Stroke the curve to a linestring.
    */
   get_curve_sampling_points ( curve,
                               NCwindow.win_tol,
                               &ncv_total_steps,
                               &cvpoints );

   if (ncv_toolpath = (IGRpoint *)malloc(ncv_total_steps * sizeof(IGRpoint)))
   {
      BScvarreval ( &rc, curve, cvpoints, ncv_total_steps, 0, (IGRdouble *)ncv_toolpath );


      /*
       * If first step equals current location, skip it.
       */

      if ( (NCtoolpath_data.curr_location[0]==ncv_toolpath[0][0]) &&
           (NCtoolpath_data.curr_location[1]==ncv_toolpath[0][1]) &&
           (NCtoolpath_data.curr_location[2]==ncv_toolpath[0][2]) )
      {
         ncv_step_number = 1;
      }
      else
      {
          ncv_step_number = 0;
      }

      NCtoolpath_data.end_of_toolpath = (ncv_step_number>=ncv_total_steps);
   }
   else
   {
      NCerror_flags.memory_fault = TRUE;   /* could not allocate toolpath */
   }


   /*
    * Free local memory.
    */

   if (cvpoints)
   {
      free (cvpoints);
   }
}


/*-----NCset_fax_toolpath-----------------------------------------------------*/

void NCset_fax_toolpath( IGRint     num_points,
                         IGRdouble  *vert_array,
                         IGRdouble  *norm_array )

/*
 * ABSTRACT:   NCset_fax_toolpath updates the FIVE-AXIS sub_toolpath.
 *
 * HISTORY:   08/16/89   Created.         C. M. Jablonski
 *
 */

{
   /*
    * Cleanup previous toolpath data.
    */

   NCcleanup_toolpath();


   /*
    * If the previous toolpath was not five_axis, initialize the orientation.
    */

   if (!NCtoolpath_data.five_axis)
   {
      if (NCsim_data.simulation_mode)
      {
         free_simbuf();
      }
      NCtoolpath_data.five_axis = TRUE;
      NCinit_toolpath_position(NCtoolpath_data.curr_location, norm_array);
   }


   /*
    * Set the five_axis flag.
    */

   NCtoolpath_data.five_axis = TRUE;


   /*
    * Assign the toolpath and orientation array vectors.
    */

   ncv_total_steps = num_points;
   ncv_toolpath = (IGRpoint *) vert_array;
   ncv_orient_vec = (IGRpoint *) norm_array;


   /*
    * If first step equals current position, skip it.
    */

   if ( (NCtoolpath_data.curr_location[0]==ncv_toolpath[0][0]) &&
        (NCtoolpath_data.curr_location[1]==ncv_toolpath[0][1]) &&
        (NCtoolpath_data.curr_location[2]==ncv_toolpath[0][2]) &&
        (NCtoolpath_data.curr_orient_vec[0]==ncv_orient_vec[0][0]) &&
        (NCtoolpath_data.curr_orient_vec[1]==ncv_orient_vec[0][1]) &&
        (NCtoolpath_data.curr_orient_vec[2]==ncv_orient_vec[0][2]) )
   {
      ncv_step_number = 1;
   }
   else
   {
      ncv_step_number = 0;
   }

   NCtoolpath_data.end_of_toolpath = (ncv_step_number>=ncv_total_steps);
}


/*-----NCget_next_position----------------------------------------------------*/

IGRboolean NCget_next_position(void)

/*
 * ABSTRACT:   NCget_next_position sets the next location and orientation.
 *
 * HISTORY:   07/22/88   Created.         C. M. Jablonski
 *
 */

{
   NCtoolpath_data.next_location[0] = ncv_toolpath[ncv_step_number][0];
   NCtoolpath_data.next_location[1] = ncv_toolpath[ncv_step_number][1];
   NCtoolpath_data.next_location[2] = ncv_toolpath[ncv_step_number][2];

   if (NCtoolpath_data.five_axis)
   {
      NCtoolpath_data.next_orient_vec[0] = ncv_orient_vec[ncv_step_number][0];
      NCtoolpath_data.next_orient_vec[1] = ncv_orient_vec[ncv_step_number][1];
      NCtoolpath_data.next_orient_vec[2] = ncv_orient_vec[ncv_step_number][2];
   }

   NCtoolpath_data.end_of_toolpath = ((++ncv_step_number)>=ncv_total_steps);

   /* if the path curve is not degenerate return TRUE */
   if ((ABS(NCtoolpath_data.curr_location[0] - NCtoolpath_data.next_location[0]) > ZERO_TOL) ||
       (ABS(NCtoolpath_data.curr_location[1] - NCtoolpath_data.next_location[1]) > ZERO_TOL) ||
       (ABS(NCtoolpath_data.curr_location[2] - NCtoolpath_data.next_location[2]) > ZERO_TOL) ||
       ((NCtoolpath_data.five_axis) &&
        ((ABS(NCtoolpath_data.curr_orient_vec[0] - NCtoolpath_data.next_orient_vec[0]) > ZERO_TOL) ||
         (ABS(NCtoolpath_data.curr_orient_vec[1] - NCtoolpath_data.next_orient_vec[1]) > ZERO_TOL) ||
         (ABS(NCtoolpath_data.curr_orient_vec[2] - NCtoolpath_data.next_orient_vec[2]) > ZERO_TOL))))
   {
      return(TRUE);
   }
   /* else if this is the end of the path curve return FALSE */
   else if (NCtoolpath_data.end_of_toolpath)
   {
      return(FALSE);
   }
   /* else get the next location */
   else
   {
      return(NCget_next_position());
   }
}
