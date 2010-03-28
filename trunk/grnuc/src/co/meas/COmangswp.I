/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_measure_sweep_angle_conic
  
  Notes:   This function will accept a GRid of a conic element and 
           return the sweep angle for the entire element.

  History: 11/02/90  jjc  Creation
*/

class implementation Root;
#include "coimport.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h" 
#include "grdpbmacros.h"



from GRconic  import        GRgetarc;


IGRlong CO_measure_sweep_angle_conic(
                 msg,
                 p_grid,
                 angle_type,
                 p_angle ) 


IGRlong     * msg;         /* O -  return code  */
struct GRid * p_grid;      /* I -  GRid of line */
IGRchar     * angle_type;  /* I -  NULL(default) => angle in radians */ 
IGRdouble   * p_angle;     /* O -  sweep angle of conic */

{
IGRlong                status;
OM_S_OBJID             mod_id;
OMuword                mod_os;
IGRint                 num;
struct GRmd_env        mod_env;                       
IGRlong                bytes_ret,
                       num_bytes;
struct IGRarc          arc;


status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );


num_bytes = sizeof( struct GRmd_env );
status = gr$get_module_env(  msg    =  msg,
                             sizbuf = &num_bytes,
                             buffer = &mod_env,
                             nret   = &bytes_ret ); 

status = om$send( msg = message GRconic.GRgetarc(
                                        msg,
                                       &mod_env.md_env.matrix_type,
                                        mod_env.md_env.matrix,
                                       &arc ),
             senderid = NULL_OBJID,
             targetid = p_grid->objid,
             targetos = p_grid->osnum );
_m_check2q(status,*msg);

/*
 *  get the sweep angle from the arc data structure
 */
*p_angle = arc.sweep_angle;

  
num = 1;
status = co$cvt_value_to_value(msg             = msg,
                               unit_type       = GRIO_ANGLE ,
                               osnum           = mod_os,
                               alias_to_cvt_to = angle_type,
                               num_vals        = num,
                               values_in       = p_angle,
                               values_out      = p_angle );


quit:
return(status);

}            
            
end implementation Root;
