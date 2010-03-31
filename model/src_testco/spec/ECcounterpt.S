/* ###################   APOGEE COMPILED   ################## */
class specification ECcounterpt (1:0) of COconst;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#include "ex.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"

#include "dp.h"         
#include "lcdef.h"    
#include "lc.h"
#include "EMSfeadef.h"  /* for struct part_data */

/*
Abstract:

This is a command object class for the construct operation of countersink(s) 
and counterbore(s).  No subclasses should exist from ECcounterpart.

History:
‚
BL  07/28/89	Creation date.
BL  06/15/90	Moved struct part_data to EMSfeadef.h and also converted 
		the EMpunch_counterpart and EMmake_part messages to 
		EMSfea_bool class
Tapadia 04/19/91 Added cen_pt_eve. Changed hole_dia, hole_depth, bottom_angle,
		 drill_dia & angle_or_depth from IGRdouble to struct GRevent.
Tapadia 05/01/91 Added associative in the instance data.
*/
 

instance ECcounterpt
{
    IGRboolean  pick_center;  /* for locating base center use */
    IGRboolean  show_center;  /* for display center point use */
    IGRboolean  axis_normal;  /* indicate if axis is normal to surface */
    IGRboolean  go_through;  /* the index of the hole depth */
    IGRboolean  flat_bottom; /* for finite hole depth use */
    IGRboolean	planar;	/* surface planarity indicator */
    IGRboolean	associative;	/* for associative placement */
    IGRchar  dia_status[30];  /* for hole diameter status */
    IGRchar  depth_status[30];  /* for hole depth status */
    IGRushort  const_state;	/* for undo, redo state use */
    IGRuint  num_parts;
    IGRdouble  drill_depth; /* the drill depth < hole depth */
    variable struct part_data  part[10];
    struct GRlc_stack  locate_stack;	/* for locate purpose */
    struct GRevent  locate_event;	/* for locate purpose */
    struct GRlc_info  surf_info;     /* located circle info */
    struct GRid	 solid_id;		/* solid id of the active owner */
    struct GRid  construct_id;		/* obj id after boolean op */
    variable struct GRevent cen_pt_eve[10];
    struct GRevent  hole_dia; 	/* hole diameter */
    struct GRevent  hole_depth;	/* hole depth */
    struct GRevent  bottom_angle;	/* bootom angle for blind hole */
    struct GRevent  drill_dia;	/* counter bore/sink diameter */
    struct GRevent  angle_or_depth;	/* depth or angle */
};

override  init,
	  execute, 
	  wakeup,
	  sleep,
	  delete;

end specification ECcounterpt;
