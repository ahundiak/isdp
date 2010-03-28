/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_center_of_conic
  
  Notes:   This function will accept a GRid of a conic element and 
           return the center point for the element.

  History: 11/03/90  jjc  Creation
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


IGRlong CO_center_of_conic(
                 msg,
                 p_grid,
                 cen_pt ) 

IGRlong     * msg;         /* O -  return code  */
struct GRid * p_grid;      /* I -  GRid of line */
IGRdouble   * cen_pt;      /* O -  center point of conic */

{
IGRlong                status;
OM_S_OBJID             mod_id;
OMuword                mod_os;
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
 *  get the center point from the arc data structure
 */
cen_pt[0] = arc.origin[0];
cen_pt[1] = arc.origin[1];
cen_pt[2] = arc.origin[2];

/***********************************
   may be needed if we want to allow an input string coord_type that will
   specify the units for the output cen_pt

num = 3;
status = co$cvt_value_to_value(msg             = msg,
                               unit_type       = GRIO_DISTANCE,
                               osnum           = mod_os,
                               alias_to_cvt_to = coord_type,
                               num_vals        = num,
                               values_in       = cen_pt,
                               values_out      = cen_pt );
*************************************/
  
quit:
return(status);

}            
            
end implementation Root;
