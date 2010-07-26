/* #######################    APOGEE COMPILED   ######################## */
/*
  Name:    CO_measure_angle_3pts
  
  Notes:   This function will accept three points to define an angle
           and output that angle.

  History: 11/01/90  jjc  Creation
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

extern    IGRboolean    MAang3pt();
extern    IGRboolean    MAptplproj();

IGRlong CO_measure_angle_3pts(
                    msg,
                    first_pt,
                    vertex_pt,
                    axis_pt,
                    proj,
                    window_id,
                    angle_type,
                    p_angle )

IGRlong    *msg;
IGRdouble  *first_pt,
           *vertex_pt,
           *axis_pt;
IGRboolean  proj;           
GRobjid     window_id;
IGRchar    *angle_type;
IGRdouble  *p_angle;

{
IGRlong                status;
struct GRid            window_grid;
struct var_list        var_list[2]; 
IGRdouble              point_on_plane[3];
IGRvector              view_vector;
IGRdouble              firstpj_pt[3],
                       vertexpj_pt[3],
                       axispj_pt[3],
                       return_angle[3];
struct IGRplane        view_plane;
IGRboolean             b_status; 
IGRlong                which_err, return_size;
OM_S_OBJID             mod_id;
OMuword                mod_os;
IGRint                 num;


window_grid.objid = window_id;

status = ex$get_cur_mod( id    = &mod_id,
                         osnum = &mod_os );

window_grid.osnum = mod_os;

if(proj)
{
  /* need to project the three points to the view plane */

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

  /* project the first angle point onto the view plane */
  b_status = MAptplproj( msg,
                         first_pt,
                        &view_plane,
                         firstpj_pt );  

  _m_check_boolq(b_status);
                          
  /* project the angle vertex point onto the viewplane */
  b_status = MAptplproj( msg,
                         vertex_pt,
                        &view_plane,
                         vertexpj_pt );  
  _m_check_boolq(b_status);

  /* project the angle axis point onto the viewplane */
  b_status = MAptplproj( msg,
                         axis_pt,
                        &view_plane,
                         axispj_pt );  
  _m_check_boolq(b_status);

}  
else
{
  firstpj_pt[0]  = first_pt[0];
  firstpj_pt[1]  = first_pt[1];
  firstpj_pt[2]  = first_pt[2];
  
  vertexpj_pt[0] = vertex_pt[0];
  vertexpj_pt[1] = vertex_pt[1];
  vertexpj_pt[2] = vertex_pt[2];
  
  axispj_pt[0]   = axis_pt[0];
  axispj_pt[1]   = axis_pt[1];
  axispj_pt[2]   = axis_pt[2];
}
  
b_status = MAang3pt( msg,
                     firstpj_pt,
                     vertexpj_pt,
                     axispj_pt,
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
            
