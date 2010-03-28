/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_measure_radius
  
  Notes:   This function accepts GRid of an element and outputs the radius 
           of the element.  If the element is non-uniform, the radius of 
           curvature at an input point will be output.  For ellipse and 
           elliptical arc, the radius at the primary axis is output.


  History: 11/05/90  jjc  Creation
*/

class implementation Root;
#include "coimport.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
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
#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"


/* extern  void         BScvarrevc(); */
extern  IGRboolean   BSprptoncv();


from GRconic    import    GRgetarc;
from GRvg       import    GRgenabsg;
from IGEgragad  import    DPinrot;
from GRgraphics import    GRlnproject;

IGRlong CO_measure_radius(
                          msg,
                          p_grid,
                          rad_pt,
                          window_id,
                          p_radius )



IGRlong     * msg;         /* O -  return code  */
struct GRid * p_grid;      /* I -  GRid of line */
IGRdouble   * rad_pt;      /* I -  point on curve required if element 
                                   is non-uniform */ 
GRobjid       window_id;   /* I -  required if rad_pt is specified, 0 otherwise */
IGRdouble   * p_radius;    /* O -  radius of input element */

{
IGRlong                status;
OM_S_OBJID             mod_id;
OMuword                mod_os;
IGRint                 num_pars;
struct GRmd_env        mod_env;                       
IGRlong                bytes_ret,
                       num_bytes;
struct IGRarc          arc;
IGRchar               *ptr;
struct IGRbsp_curve   *ele_ptr;
struct GRparms         parm_on_line;
IGRdouble              curvature_val,
                       max_disp;
IGRpoint               out_point[1][2];
BSrc                   rc;
uword                  p_classid;
struct GRid            window_grid;
IGRdouble              vwmat[16];
IGRboolean             b_status;
struct IGRline         boreline;
IGRdouble              borepoints[6],
                       point_on_object[3],
                       point_on_line[3],
                       tparm;



status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );

num_bytes = sizeof( struct GRmd_env );
status = gr$get_module_env(  msg    =  msg,
                             sizbuf = &num_bytes,
                             buffer = &mod_env,
                             nret   = &bytes_ret ); 

status = om$get_classid( osnum = p_grid->osnum,
                         objid = p_grid->objid,
                         p_classid = &p_classid );


/* find out if the input element is a conic */
status = om$is_ancestry_valid( subclassid = p_classid,
                               superclassname = "GRconic" );


if( status == OM_S_SUCCESS )
 { /* we have a conic */

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
    *  get the radius at the primary axis from the arc data structure
    */
   *p_radius = arc.prim_axis;
 }
else
 { /* we don't have a conic */

   /*  get view rotation matrix */
   window_grid.objid = window_id;
   window_grid.osnum = mod_os;

   status = om$send(msg = message IGEgragad.DPinrot(
                                            msg,
                                            vwmat),
                    senderid = NULL_OBJID,
                    targetid = window_grid.objid,
                    targetos = window_grid.osnum );

   /* create a boreline to project the rad_pt along */
   boreline.point1 = &( borepoints[0] );
   boreline.point2 = &( borepoints[3] );

   b_status = GRbrlnconstr( msg,
                            rad_pt,
                            vwmat,
                           &boreline );                       
 

   status = om$send(
                    msg = message GRgraphics.GRlnproject(
                          msg,
                         &mod_env.md_env.matrix_type,
                          mod_env.md_env.matrix,
                         &boreline,
                          point_on_object, /* not used */
                          point_on_line,
                         &tparm,           /* not used */ 
                         &parm_on_line ),
                    senderid = NULL_OBJID,
                    targetid = p_grid->objid,
                    targetos = p_grid->osnum );


 
   status = om$send(msg = message GRvg.GRgenabsg( msg,         
                                                 &mod_env.md_env.matrix_type,
                                                  mod_env.md_env.matrix,
                                                 &ptr),
               senderid = NULL_OBJID,
               targetid = p_grid->objid,
               targetos = p_grid->osnum);
  
   _m_check2q(status,*msg);

   ele_ptr = (struct IGRbsp_curve *) ptr;

                 

   num_pars = 1;
   max_disp = MAXDOUBLE ; /* wouldn't want to limit out users */
   BScvarrevc( ele_ptr,
               num_pars,     
             &(parm_on_line.u), 
               max_disp,
              &curvature_val,
               p_radius,
               out_point,
              &rc );  
                
 } 


quit:
return(status);

}            
            
end implementation Root;
