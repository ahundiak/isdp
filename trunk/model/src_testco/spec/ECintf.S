/* ###################   APOGEE COMPILED   ################## */
class specification ECintf (1:0) of COconst;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "OMlimits.h" 
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"

/*
Abstract:
  COmmand object for interference analysis

History:
  SM	05-Jun-89	Creation.
*/
 

instance ECintf
{
 IGRint            num_located,              /*total num elements*/ 
		   num_ornted;
 IGRint		   num_sets;
 variable IGRint   num_in_set[2];
 variable struct GRlc_info set_info[2];
 struct GRlc_stack locate_stack;            /*for locate purposes*/
 struct GRevent    locate_event;            /*for locate purposes*/
 variable struct GRlc_info  locate_info[2];     /*located eleinfo*/
 variable IGRboolean reversed[2];
 IGRchar           filename[MAX_CHAR], savefile[MAX_CHAR]; 
 IGRboolean	   add_to_set,
		   stdreportonly, 
		   nocurves, 
		   novol, 
		   noarea, 
		   plpts_input;
 IGRpoint	points[4];
 IGRpoint	plane_point;
 IGRvector	plane_normal;
 struct IGRplane plane;
};

override delete, init, execute, wakeup, sleep;

end specification ECintf;
