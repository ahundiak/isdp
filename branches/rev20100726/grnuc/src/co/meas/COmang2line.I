/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_meas_angle_two_lines
  
 
  Notes:   This function accepts two GRids of line segments and outputs 
           the angle between them.  An additional point is used to 
           determine in which quadrant to measure the angle.

           In true mode, the lines must intersect.
   
  History: 11/08/90  jjc  Creation
*/

class implementation Root;
#include "coimport.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "ex.h"
#include "dp.h"
#include "gr.h"
#include "ma.h"
#include "maerr.h"
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

extern    IGRboolean    MAang3pt(),
                        MAptplproj(),
                        MA2lnisect(),
                        MAbcendpts();

from      GRvg  import  GRgenabsg;

IGRlong  CO_meas_angle_two_lines ( msg,
                                   p_grid1,
                                   p_grid2,
                                   quad_pt,
                                   proj,
                                   window_id,
                                   angle_type,
                                   p_angle )


IGRlong     * msg;        /*  O -  return code                                */
struct GRid * p_grid1;    /*  I -  GRid of first line                         */
struct GRid * p_grid2;    /*  I -  GRid of second line                        */
IGRdouble   * quad_pt;    /*  I -  identifies quadrant for angle              */
IGRboolean    proj;       /*  I -  indicate true(0) or apparent(1) projection */
GRobjid       window_id;  /*  I -  window object id for apparent projection   */
IGRchar     * angle_type; /*  I -  NULL(default) => angle in radians
                                   a type        => angle in angle_type units
                                   unknown type  => angle in radians          */
IGRdouble   * p_angle;    /*  O -  angle measured between the two lines       */




{
IGRlong                status;
struct GRid            window_grid;
struct var_list        var_list[2]; 
IGRdouble              point_on_plane[3];
IGRvector              view_vector;
IGRdouble              end1_pt1[3],
                       end2_pt1[3],
                       end1_pt2[3],
                       end2_pt2[3],
                       end1pj_pt1[3],
                       end2pj_pt1[3],
                       end1pj_pt2[3],
                       end2pj_pt2[3],
                       quadpj_pt[3],
                       first_pt[3],
                       second_pt[3],
                       isect_pt[3],
                       return_angle[3],
                       parm1,
                       parm2,
                       first_parm,
                       second_parm,
                       tol; 
struct IGRplane        view_plane;
IGRboolean             b_status; 
IGRlong                which_err;
OM_S_OBJID             mod_id;
OMuword                mod_os;
IGRlong                 return_size,
                       num;
struct IGRline         line1,
                       line2;
struct GRmd_env        mod_env;                        
IGRlong                bytes_ret,
                       num_bytes;
IGRchar               *ptr1,
                      *ptr2;
struct IGRbsp_curve   *line1_ptr,
                      *line2_ptr;


status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );

window_grid.objid = window_id;
window_grid.osnum = mod_os;

num_bytes = sizeof( struct GRmd_env );
status = gr$get_module_env(  msg    =  msg,
                             sizbuf = &num_bytes,
                             buffer = &mod_env,
                             nret   = &bytes_ret ); 


/*
 * generate the abstract geometry of first line
 */
status = om$send(msg = message GRvg.GRgenabsg( msg,         
                                              &mod_env.md_env.matrix_type,
                                               mod_env.md_env.matrix,
                                              &ptr1),
            senderid = NULL_OBJID,
            targetid = p_grid1->objid,
            targetos = p_grid1->osnum);
  
_m_check2q(status,*msg);

line1_ptr = (struct IGRbsp_curve *) ptr1;

/* get the endpoints of the line */
b_status = MAbcendpts( msg,
                       line1_ptr,
                       end1_pt1,
                       end2_pt1 );



/*
 * generate the abstract geometry of second line
 */
status = om$send(msg = message GRvg.GRgenabsg( msg,         
                                              &mod_env.md_env.matrix_type,
                                               mod_env.md_env.matrix,
                                              &ptr2),
            senderid = NULL_OBJID,
            targetid = p_grid2->objid,
            targetos = p_grid2->osnum);
  
_m_check2q(status,*msg);

line2_ptr = (struct IGRbsp_curve *) ptr2;

/* get the endpoints of the line */
b_status = MAbcendpts( msg,
                       line2_ptr,
                       end1_pt2,
                       end2_pt2 );






if(proj)
{

  view_plane.point = point_on_plane;
  view_plane.normal = view_vector;

   
  var_list[0].var            =  VIEW_PLANE;
  var_list[0].var_ptr        =  (IGRchar *)(&view_plane);
  var_list[0].num_bytes      =  sizeof(struct IGRplane);
  var_list[0].bytes_returned =  &return_size;

  var_list[1].var = END_PARAM;
 
  /* fill out the var_list */
  status = dp$inq_set_gragad( msg          =  msg,
                              osnum        =  window_grid.osnum,
                              gragad_objid =  window_grid.objid,
                              which_error  = &which_err, 
                              var_list     =  var_list );
  _m_check2q(status,*msg);

  /* project the four endpoints and the quad point to the view plane */
  b_status = MAptplproj( msg,
                         end1_pt1,
                        &view_plane,
                         end1pj_pt1 );  

  _m_check_boolq(b_status);
                          
  b_status = MAptplproj( msg,
                         end2_pt1,
                        &view_plane,
                         end2pj_pt1 );  
  _m_check_boolq(b_status);

  b_status = MAptplproj( msg,
                         end1_pt2,
                        &view_plane,
                         end1pj_pt2 );  
  _m_check_boolq(b_status);


  b_status = MAptplproj( msg,
                         end2_pt2,
                        &view_plane,
                         end2pj_pt2 );  
  _m_check_boolq(b_status);


  b_status = MAptplproj( msg,
                         quad_pt,
                        &view_plane,
                         quadpj_pt );  
  _m_check_boolq(b_status);

line1.point1 = end1pj_pt1;
line1.point2 = end2pj_pt1;

line2.point1 = end1pj_pt2;
line2.point2 = end2pj_pt2;

}
else
{
line1.point1 = end1_pt1;
line1.point2 = end2_pt1;

line2.point1 = end1_pt2;
line2.point2 = end2_pt2;
   
}

/* First I will find the intersect point of the two lines.  This will be the
   vertex point of the angle.  Then project the quad point onto each line.
   These two points will define the second and third points for the angle.
 */

tol = .000001;
b_status = MA2lnisect( msg,
                      &line1,
                      &line2,
                      &tol,
                       isect_pt,
                      &parm1,
                      &parm2 );  
if(!proj)
  if( *msg == MSFAIL )
   {
    /* the lines don't intersect in true mode therefore no solution */
    *msg = MANOSOLUTION; 
    status = OM_E_ERROR;
    goto quit;
   }


b_status = MAptlnproj( msg,
                      (proj) ? quadpj_pt : quad_pt,
                      &line1,
                       first_pt,
                      &first_parm ); 
_m_check_boolq(b_status);


b_status = MAptlnproj( msg,
                      (proj) ? quadpj_pt : quad_pt,
                      &line2,
                       second_pt,
                      &second_parm ); 
_m_check_boolq(b_status);                       


  
b_status = MAang3pt( msg,
                     first_pt,
                     isect_pt,
                     second_pt,
                     return_angle );
_m_check_boolq(b_status);

*p_angle = ( return_angle[0] > PI ) ? (2 * PI) - return_angle[0] : return_angle[0];

num = 1;
status = co$cvt_value_to_value(msg             = msg,
                               unit_type       = GRIO_ANGLE ,
                               osnum           = window_grid.osnum,
                               alias_to_cvt_to = angle_type,
                               num_vals        = num,
                               values_in       = p_angle,
                               values_out      = p_angle );


quit:
return(status);

}            
            
end implementation Root;
