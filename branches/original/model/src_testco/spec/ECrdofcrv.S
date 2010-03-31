/* ###################   APOGEE COMPILED   ################## */
class specification ECrdofcrv (1:0) of ECelement;

/*
 * Abstract:
 *	This  class defines data used in the command 
 *	object which measures the radius of curvature.
 * History
 *  dm : ??/??/?? : Creation
 *  pp : 09/25/89 : Added support for outputting curvature for curves
 *                  and surfaces on demand.
 */

#include "FI.h"

#define SAVE 1
#define RAD_OF_CRV 12
#define CURVATURE 13
#define GAUSSIAN 13
#define MEAN 14
#define PRINCIPAL_MAX 15
#define PRINCIPAL_MIN 16
#define ABSOLUTE 17

#define   CURVE    0
#define   SURFACE  1

instance ECrdofcrv
{
  IGRdouble	max_radius;		/* Maximum radius length     */
  IGRpoint	prj_point[2];		/* Projected start, end  points */ 
  IGRlong	clines, slines[2];	/* Number of lines to output */
  IGRint	num_pts;            /* Index for the point array */
  IGRint	num_lines;          /* Index for the line array  */
  IGRchar       type;               /* Type of output desired    */
  IGRchar	action;             /* action for the action table */
  struct	GRparms start_pt, mid_pt, end_pt; /* parameter pts */
  IGRint        curvature_type;
  IGRchar      form_displayed;
  IGRchar      form_initiated;
  Form         form1;                                
};
message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

override init, execute,wakeup,sleep,delete;

/*
 * Motivation:
 *	Need to override the init so can initialize the 
 *	action and then call the overridden init. Need 
 *	to override the execute because that is where the 
 *	heart of the program recedes.
 *      wakeup and sleep are overriden to properly handle display and
 *      erasure of the status display form.
 *      Delete has been overriden to delete the form object if it exists.
 */
	
override status_disp;
/*
 * To display the status display form.
 */

end specification ECrdofcrv;
