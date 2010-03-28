/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_meas_length_along
  
  Notes:   This function accepts a GRid and three points.  The 
           first two points define the start and end points for 
           the measurement and the dir_pt is a direction  point 
           required for closed elements.
           It outputs the true length along the element between 
           the start and end points.

  History: 11/04/90  jjc  Creation
*/

class implementation Root;
#include "coimport.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "bserr.h"
#include "bstypes.h"
#include "dp.h"
#include "ex.h"
#include "gr.h"
#include "ma.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h" 
#include "grdpbmacros.h"

/* externs */


/* imports */
from GRcurve    import GRarclength;
from GRvg       import GRgeomprops,
                       GRgenabsg;
from IGEgragad  import DPinrot;
from GRgraphics import GRlnproject;

IGRlong  CO_meas_length_along( msg,
                               p_grid,
                               start_pt,
                               end_pt,
                               dir_pt,
                               window_id,
                               p_length )
                               
                               
IGRlong     *    msg;        /*  O    return code                   */
struct GRid *    p_grid;     /*  I    GRid of element to measure    */
IGRdouble *      start_pt;   /*  I    start measurement point       */
IGRdouble *      end_pt;     /*  I    stop measurement point        */
IGRdouble *      dir_pt;     /*  I    direction point required for 
                                      closed elements               */
GRobjid          window_id;  /*  I    window id for view information */
IGRdouble *      p_length;   /*  O    length along element between 
                                      points                        */ 
                               
{
IGRlong                bytes_ret,
                       num_bytes,
                       status;
IGRchar               *ptr;
struct IGRbsp_curve   *ele_ptr;
struct GRprops         props;
struct GRparms         start_parm,
                       end_parm,
                       dir_parm;
struct GRmd_env        mod_env;
OM_S_OBJID             mod_id;
OMuword                mod_os;
struct GRid            window_grid;
IGRboolean             b_status;
IGRdouble              vwmat[16],
                       borepoints[6],
                       point_on_object[3],
                       startpj_pt[3],
                       endpj_pt[3],
                       dirpj_pt[3],
                       tparm;
struct IGRline         boreline;


status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );


num_bytes = sizeof( struct GRmd_env );
status = gr$get_module_env(  msg    =  msg,
                             sizbuf = &num_bytes,
                             buffer = &mod_env,
                             nret   = &bytes_ret ); 



status = om$send(
                 msg = message GRvg.GRgeomprops(
                               msg,
                              &mod_env.md_env.matrix_type,
                               mod_env.md_env.matrix,
                              &props ),
                 senderid = NULL_OBJID,
                 targetid = p_grid->objid,
                 targetos = p_grid->osnum );

_m_check2q(status,*msg);

/*
 * generate the abstract geometry of element
 */
status = om$send(msg = message GRvg.GRgenabsg( msg,         
                                              &mod_env.md_env.matrix_type,
                                               mod_env.md_env.matrix,
                                              &ptr),
            senderid = NULL_OBJID,
            targetid = p_grid->objid,
            targetos = p_grid->osnum);
  
_m_check2q(status,*msg);

ele_ptr = (struct IGRbsp_curve *) ptr;




window_grid.objid = window_id;
window_grid.osnum = mod_os;

/*  get view rotation matrix */
status = om$send(msg = message IGEgragad.DPinrot(
                                            msg,
                                            vwmat),
                    senderid = NULL_OBJID,
                    targetid = window_grid.objid,
                    targetos = window_grid.osnum );

/* create a boreline to project the rad_pt along */
boreline.point1 = &( borepoints[0] );
boreline.point2 = &( borepoints[3] );


/* get the u-parameter of the curve at the start point */
b_status = GRbrlnconstr( msg,
                         start_pt,
                         vwmat,
                        &boreline );                       
 

status = om$send(
                    msg = message GRgraphics.GRlnproject(
                          msg,
                         &mod_env.md_env.matrix_type,
                          mod_env.md_env.matrix,
                         &boreline,
                          point_on_object, /* not used */
                          startpj_pt,
                         &tparm,           /* not used */ 
                         &start_parm ),
                    senderid = NULL_OBJID,
                    targetid = p_grid->objid,
                    targetos = p_grid->osnum );


/* get the u-parameter of the curve at the end point */
b_status = GRbrlnconstr( msg,
                         end_pt,
                         vwmat,
                        &boreline );                       
 

status = om$send(
                    msg = message GRgraphics.GRlnproject(
                          msg,
                         &mod_env.md_env.matrix_type,
                          mod_env.md_env.matrix,
                         &boreline,
                          point_on_object, /* not used */
                          endpj_pt,
                         &tparm,           /* not used */ 
                         &end_parm ),
                    senderid = NULL_OBJID,
                    targetid = p_grid->objid,
                    targetos = p_grid->osnum );


if ( props.phy_closed )
 {
  /* get the u-parameter of the curve at the direction point */
  b_status = GRbrlnconstr( msg,
                           dir_pt,
                           vwmat,
                          &boreline );                       
 

  status = om$send(
                    msg = message GRgraphics.GRlnproject(
                          msg,
                         &mod_env.md_env.matrix_type,
                          mod_env.md_env.matrix,
                         &boreline,
                          point_on_object, /* not used */
                          dirpj_pt,
                         &tparm,           /* not used */ 
                         &dir_parm ),
                    senderid = NULL_OBJID,
                    targetid = p_grid->objid,
                    targetos = p_grid->osnum );

 }



status = om$send(
                 msg = message GRcurve.GRarclength(
                            msg,
                           &mod_env.md_env.matrix_type,
                            mod_env.md_env.matrix,
                            startpj_pt,
                            (props.phy_closed) ? dirpj_pt : startpj_pt,
                            endpj_pt,
                           &start_parm,
                            (props.phy_closed) ? &dir_parm : &start_parm,
                           &end_parm,
                            p_length ),
                 senderid = NULL_OBJID,
                 targetid = p_grid->objid,
                 targetos = p_grid->osnum );

/******************************* 
    this may be needed if we ever want to allow the user to specify a char
    string for the type of the returned distance

num = 1;
status = co$cvt_value_to_value(msg             = msg,
                               unit_type       = GRIO_DISTANCE,
                               osnum           = mod_os,
                               alias_to_cvt_to = unit_type,
                               num_vals        = num,
                               values_in       = p_length,
                               values_out      = p_length );
*******************************/
quit:
return(status);

}            

            
end implementation Root;

