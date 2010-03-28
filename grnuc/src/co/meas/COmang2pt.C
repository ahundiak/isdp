/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_measure_angle_2pts
  
  Notes:   This function will accept two points to define a line in a
           view and output the angle between the line and the view's 
           X axis.
  History: 10/30/90 jjc    Creation
  	   08/17/92 Carlos Rewritten to give right answer at any view 
  	   	orientation. Also uses same 'ni' function as the equivalent
  	   	command object.
*/
#include "coimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "ma.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igr.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"

IGRlong CO_measure_angle_2pts(
                 msg,
                 first_pt,
                 second_pt,
                 window_id,
                 angle_type,
                 p_angle ) 

IGRlong    *msg;
IGRdouble  *first_pt,
           *second_pt;
GRobjid     window_id;
IGRchar    *angle_type;
IGRdouble  *p_angle;

{
IGRlong                status;
IGRboolean             b_status; 
OM_S_OBJID             mod_id;
OMuword                mod_os;
IGRchar		       units[GRIO_MAX_ALIAS_SIZE];
struct GRevent	       Events[2];
struct GRevent	       *p_Events[2];

status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );

Events[0].event.button.objid = window_id;
Events[0].event.button.osnum = mod_os;
Events[0].event.button.x = first_pt[0];
Events[0].event.button.y = first_pt[1];
Events[0].event.button.z = first_pt[2];

Events[1].event.button.x = second_pt[0];
Events[1].event.button.y = second_pt[1];
Events[1].event.button.z = second_pt[2];
  
p_Events[0] = &Events[0];
p_Events[1] = &Events[1];

status = CO_ni_measure_angle_by_2_pts(
		msg, 	    
		p_Events,   
		p_angle,    
		units);

/* convert the angle from radians to degrees */

status = co$cvt_value_to_value(msg             = msg,
                               unit_type       = GRIO_ANGLE ,
                               osnum           = mod_os,
                               alias_to_cvt_to = angle_type,
                               num_vals        = 1,
                               values_in       = p_angle,
                               values_out      = p_angle );
                               
quit:
return(status);
}            
            
