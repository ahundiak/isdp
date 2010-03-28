/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_measure_angle_line
  
  Notes:   This function will accept a GRid to define a line in a
           view and output the angle between the line and the view's 
           X axis.
           
  History:
	11/01/90	jjc	Creation
	03/30/92	Carlos	Rewritten so that it uses same function as 
				Measure Angle Line command and works for 
				any view orientation.
*/

class implementation Root;
#include "coimport.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "dp.h"
#include "ex.h"
#include "gr.h"
#include "ma.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h" 
#include "grdpbmacros.h"

extern    IGRboolean    MAang3pt();
extern    IGRboolean    MAptplproj();
extern    IGRboolean    MAbcendpts(); 
extern	  IGRlong	CO_ni_measure_line_angle();

from GRvg import        GRgenabsg;

IGRlong CO_measure_angle_line(
                 msg,
                 p_grid,
                 window_id,
                 angle_type,
                 p_angle ) 

IGRlong     * msg;         /* O -  return code  */
struct GRid * p_grid;      /* I -  GRid of line */
GRobjid       window_id;   /* I -  window object id to supply x-axis */
IGRchar     * angle_type;  /* I -  NULL(default) => angle in radians */ 
IGRdouble   * p_angle;     /* O -  angle measured between line and x-axis */

{
IGRlong                status;
struct GRid            window_grid;
IGRlong                first_pt[3],
                       second_pt[3];
IGRboolean             b_status; 
OM_S_OBJID             mod_id;
OMuword                mod_os;
struct GRmd_env        mod_env;                       
IGRlong                bytes_ret,
                       num_bytes;
IGRchar               *ptr;
struct IGRbsp_curve   *line_ptr;

struct GRevent	Events[2];
struct GRevent  *p_Events[2];
IGRchar		units[GRIO_MAX_ALIAS_SIZE];

status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );

window_grid.osnum = mod_os;
window_grid.objid = window_id;

num_bytes = sizeof( struct GRmd_env );
status = gr$get_module_env(  msg    =  msg,
                             sizbuf = &num_bytes,
                             buffer = &mod_env,
                             nret   = &bytes_ret ); 

/*
 * generate the abstract geometry of the line
 */
status = om$send(msg = message GRvg.GRgenabsg( msg,         
                                              &mod_env.md_env.matrix_type,
                                               mod_env.md_env.matrix,
                                              &ptr),
            senderid = NULL_OBJID,
            targetid = p_grid->objid,
            targetos = p_grid->osnum);
  
  _m_check2q(status,*msg);

line_ptr = (struct IGRbsp_curve *) ptr;

/* get the endpoints of the line */
b_status = MAbcendpts( msg,
                       line_ptr,
                       first_pt,
                       second_pt );
                       
/*
 * fill up Events with data needed by next
 * function.
 */
Events[0].event.button.osnum = window_grid.osnum;
Events[0].event.button.objid = window_grid.objid;

Events[0].event.button.x = first_pt[0];
Events[0].event.button.y = first_pt[1];
Events[0].event.button.z = first_pt[2];

Events[1].event.button.x = second_pt[0];
Events[1].event.button.y = second_pt[1];
Events[1].event.button.z = second_pt[2];

Events[0].located_object[0].geom_parms.u = 1; 

p_Events[0] = &Events[0];
p_Events[1] = &Events[1];

/*
 * call the function to measure the angle
 */
status = CO_ni_measure_line_angle (msg,
				&p_Events,
				&mod_env,
				p_angle, 
				units,
				NULL,	/* my_id  */
				NULL,	/* MyChannelStruct */
				p_grid);
				
/*
 * convert the angle from radians to degrees
 */

status = co$cvt_value_to_value(msg             = msg,
                               unit_type       = GRIO_ANGLE ,
                               osnum           = window_grid.osnum,
                               alias_to_cvt_to = angle_type,
                               num_vals        = 1,
                               values_in       = p_angle,
                               values_out      = p_angle );
                               
quit:
return(status);

}            
            
end implementation Root;
