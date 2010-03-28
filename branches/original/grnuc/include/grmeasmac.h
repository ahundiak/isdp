#ifndef grmeasmac_include
#define grmeasmac_include

#include "godef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "cimacros.h"
#include "cisend.h"
#include "grerr.h"
#include "msdef.h"
#include "exdef.h"
#include "exmacros.h"




extern int GRdpb_get();
extern IGRboolean MA2ptdis();
#ifndef PPL
extern int (*OM_GA_primitives[])();
#endif
extern int EX_findmod();
extern int DImain();
extern int DIfast_trans();

int meas_size,meas_ret_size,OMmsg;


struct GRmd_env *meas_env,meas_md_env;
struct GRid *mod,id;

double proj_pt[3];
struct GRparms proj_parms;

/*
Abstract
        This macro is used to retrieve the distance between a point
        and an object.

Synopsis

IGRlong         *ret_msg   O     return code 
struct GRmd_env *env_info  I     the module environment information
                                 if not specified, the active
                                 module environment will be used
IGRpoint         point     I     the input point
struct GRid     *object_id I     the input object id 
IGRdouble       *distance  O     the distance from the point to the object

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$meas_dist_pt_to_object
                        (ret_msg, 
                         env_info=NULL,
                         point,
                         object_id,
                         distance)
{
#  if (! om$specified(env_info)) 
   {
               meas_size=sizeof(meas_md_env);
               gr$get_module_env(msg=(ret_msg),
                                 sizbuf=&meas_size,
                                 buffer=&meas_md_env,
                                 nret=&meas_ret_size);

        meas_env=&meas_md_env;
    }
#   else 
    {
        meas_env=env_info;
    }
#   endif
    
    OMmsg=ci$send(msg = message GRgraphics.GRptproject
                ((ret_msg),&meas_env->md_env.matrix_type,
                 meas_env->md_env.matrix,(point),proj_pt,&proj_parms),
            targetid = (object_id)->objid,  
            targetos = (object_id)->osnum);

    if ( 1 & OMmsg & *(ret_msg))
    {
        MA2ptdis(ret_msg,point,proj_pt,(distance));
    }

}
#endomdef

/*
Abstract
        This macro is used to retrieve the arclength of an object

Synopsis

IGRlong         *ret_msg    O     return code 
struct GRmd_env *env_info   I     the module environment information
                                  if not specified, the active
                                  module environment will be used
struct GRid     *object_id  I     the input object id 
IGRdouble       *arclength  O     the arclength of the object

Return Values
        MSSUCC  -- successful completion
        MSFAIL  -- failure
*/

#omdef gr$get_arc_length(ret_msg,
                         env_info=NULL,
                         object_id,
                         length)
{
        
#  if (! om$specified(env_info)) 
   {
               meas_size=sizeof(meas_md_env);
               gr$get_module_env(msg=(ret_msg),
                                 sizbuf=&meas_size,
                                 buffer=&meas_md_env,
                                 nret=&meas_ret_size);

        meas_env=&meas_md_env;
    }
#   else 
    {
        meas_env=env_info;
    }
#   endif

    OMmsg=ci$send(
        msg=message GRcurve.GRtotlength((ret_msg),&meas_env->md_env.matrix_type,
                meas_env->md_env.matrix,(length)),
        targetid=(object_id)->objid,
        targetos=(object_id)->osnum);

    if (! (1 & OMmsg))
    {
        *(ret_msg)=MSFAIL;
    }
}
#endomdef

/* 
Abstract
    This macro accepts an associative parameter and outputs its
evaluated result

Arguments
IGRlong      *ret_msg        O          The return message
                   MSSUCC               successful completion
                   DIR_W_NAME_NOT_FOUND name NOT found
                   DIR_E_OVFLOW         overflow error
                   DIR_E_SYNTAX         syntax error
                   DIR_E_ABORT          directory error
                   MSFAIL               no value for parameter
IGRchar      *param_in       I          The input parameter value
struct GRid  *module_id      I          The module the parameter is
                                        stored in
IGRdouble    *output_value   O          the output value
*/

#omdef gr$get_assoc_param(ret_msg,
                          param_in,
                          module_id=NULL,
                          output_value)

{
#   if (! om$specified(module_id))
    {
        ex$get_cur_mod(id=&meas_md_env.md_id.objid,
                       osnum=&meas_md_env.md_id.osnum);
        mod = &meas_md_env.md_id;        
    }
#   else
    {
        mod = module_id;
    }
#endif

    OMmsg= di$translate ( objname=param_in,
                          p_objid=&id.objid,
                          p_osnum = &id.osnum);

    *(output_value) = 0.0;

    if ( 1 & OMmsg)
    {
       OMmsg = ci$send (msg = message expression.NDgive_value( (output_value)),
                        targetid = id.objid,
                        targetos = id.osnum);

            if (! (1 & OMmsg))
            {
                *(ret_msg) = MSFAIL;
            }
    }
}

#endomdef

/* 
  gr$meas_dist_2_points

Abstract
   This macro accepts two points as input and outputs the true 
   distance between them.

Example
   status = gr$meas_dist_2_points ( msg       = &my_msg,
                                    point1_in =  pt1,
                                    point2_in =  pt2,  
                                    p_length  = &my_dist);

Arguments
   IGRlong   *     msg           O   return code
   IGRdouble *     point1_in     I   first measurement point
   IGRdouble *     point2_in     I   second measurement point
   IGRdouble *     p_length      O   distance between points in
                                      internal data base units
Return status:
   IGRboolean  status       MSSUCC - succeeds
                            MSFAIL - fails

History :  10/29/90  jjc  Created

*/
#omdef gr$meas_dist_2_points ( msg,
                               point1_in,
                               point2_in,
                               p_length )


MA2ptdis(  msg,
           point1_in,
           point2_in,
           p_length );            


  
#endomdef

/*
  gr$meas_angle_2pts

Abstract
   This macro accepts two points to define a line in a view.  It will
   output the angle between the line and the X axis.

   Note: 1.  Since the x-axis is derived from the window, this will 
             always be an apparent measurement.
         2.  The vertex point of the angle will be the point with the
             lesser y-value (with respect to the view).


Example
   status = gr$meas_angle_2pts( msg        = &msg,
                                first_pt   =  pt1,
                                second_pt  =  pt2,
                                window_id  =  win_id,
                                angle_type = "degrees",
                                p_angle    = &my_angle );

Arguments

   IGRlong   *    msg         O   return code 
   IGRdouble *    first_pt    I   first point of line
   IGRdouble *    second_pt   I   second point of line
   GRobjid        window_id   I   window objid  to use  for  x-axis
   IGRchar   *    angle_type  I   NULL(default) => angle in radians
                                  a type        => angle in angle_type units
                                  unknown type  => angle in  radians
   IGRdouble *    p_angle     O   angle between x-axis and two points 

Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails

History: 10/30/90  jjc  Created
*/
#omdef  gr$meas_angle_2pts( msg,
                            first_pt,
                            second_pt,
                            window_id,
                            angle_type = "radians",
                            p_angle )

CO_measure_angle_2pts(
                    msg,
                    first_pt,
                    second_pt,
                    window_id,
                    angle_type,
                    p_angle );    




#endomdef

/*
   gr$meas_angle_3pts

Abstract
     This macro accepts three points to define an angle and outputs the
     measured angle.
     Note: the measured angle will always be 180 degrees or less.

Example
   status = gr$meas_angle_3pts ( msg        = &msg,
                                 first_pt   =  pt1,
                                 vertex_pt  =  pt2,
                                 axis_pt    =  pt3,  
                                 proj       =  true_flag,
                                 window_id  =  wind_id,
                                 angle_type = "degrees",
                                 p_angle    = &my_angle );

Arguments
     IGRlong   *   msg         O -  return code
     IGRdouble *   first_pt    I -  first pt. of meas. angle
     IGRdouble *   vertex_pt   I -  vertex pt. of meas. angle
     IGRdouble *   axis_pt     I -  end of meas. angle
     IGRboolean    proj        I -  indicate true(0) or apparent(1) projection
     GRobjid       window_id   I -  window object id for apparent projection
     IGRchar   *   angle_type  I -  NULL(default) => angle in radians
                                    a type       => angle in angle_type units   
                                    unknown type => angle in radians
     IGRdouble *   p_angle     O -  angle measured by the three points

Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails

History: 11/01/90  jjc  Created
*/
#omdef  gr$meas_angle_3pts( msg,
                            first_pt,
                            vertex_pt,
                            axis_pt,
                            proj,
                            window_id,
                            angle_type = "radians",
                            p_angle )

CO_measure_angle_3pts(
                    msg,
                    first_pt,
                    vertex_pt,
                    axis_pt,
                    proj,
                    window_id,
                    angle_type,
                    p_angle );    




#endomdef

/*
  gr$meas_angle_line

Abstract
   This  macro accepts  a  GRid  of a  line  and  a window_id  to
   determine the x-axis of the view.  The line is projected onto 
   the view's XY plane.  The angle measured between the line and
   the X axis is output.

Example 
   status = gr$meas_angle_line ( msg        = &msg,
                                 p_grid     = &line_grid,
                                 window_id  =  wind_id,
                                 angle_type = "degrees",
                                 p_angle    = &angle);

Arguments
   IGRlong     * msg           O -  return code       
   struct GRid * p_grid        I -  GRid of line
   GRobjid       window_id     I -  window object id to supply x-axis
   IGRchar     * angle_type    I -  NULL(default) => angle in radians
                                    a type        => angle in angle_type units
                                    unknown type  => angle in radians
   IGRdouble   * p_angle       O -  angle measured between line and x-axis

Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails

History: 11/01/90  jjc          Created
         05/05/92  Carlos Removed 'status = '  
*/
#omdef gr$meas_angle_line ( msg,
                            p_grid,
                            window_id,
                            angle_type = "radians",
                            p_angle )

CO_measure_angle_line ( msg,
                        p_grid,
                        window_id,
                        angle_type,
                        p_angle );

#endomdef


/*
  gr$meas_sweep_angle_conic

Abstract
   This macro will accept GRid of a conic element and return the sweep 
   angle for the entire element. 

Example
   status = gr$meas_sweep_angle_conic ( msg        = &msg,
                                        p_grid     = &my_grid,
                                        angle_type = "degrees",
                                        p_angle    = &my_angle )

Arguments
   IGRlong     *  msg         O   return code
   struct GRid *  p_grid      I   GRid of conic element to measure
   IGRchar     *  angle_type  I   NULL(default) => angle in radians
                                  a type        => angle in angle_type units   
                                  unknown type  => angle in radians
   IGRdouble   *  p_angle     O   sweep angle of conic element in 
                                    angle_type units


Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails

History: 11/02/90  jjc    Created
         05/05/92  Carlos Removed 'status = '
*/
#omdef gr$meas_sweep_angle_conic ( msg,
                                   p_grid,
                                   angle_type = "radians",
                                   p_angle )

CO_measure_sweep_angle_conic(
                    msg,
                    p_grid,
                    angle_type,
                    p_angle );
                                                                    
#endomdef


/*
  gr$center_of_conic

Abstract
   This macro accepts a GRid of a conic and outputs the center point of 
   the element.

Example
   status = gr$center_of_conic( msg     = &msg,
                                p_grid  = &arc_grid,
                                cen_pt  =  center_pt );

Arguments
   IGRlong     *    msg         O - return code
   struct GRid *    p_grid      I - GRid of element to measure
   IGRdouble   *    cen_pt      O - center point of element 


Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails

History: 11/03/90  jjc    Created
         05/05/92  Carlos Removed 'status = '
*/

#omdef gr$center_of_conic( msg,
                           p_grid,
                           cen_pt )
                           
CO_center_of_conic(
                   msg,
                   p_grid,
                   cen_pt );

#endomdef


/*
  gr$meas_angle_pts_arb_axis

Abstract
   This macro accepts 2 pairs of points to define 2 axes.  The measured
   angle is defined by two of the points and the intersection point of 
   the two axes.  The angle is specified by an input quadrant point.
   Note: in true mode, the implied axes must intersect.

Example
   status = gr$meas_angle_pts_arb_axis ( msg        = &msg,
                                         axis1_pt1  =  pt1, 
                                         axis1_pt2  =  pt2,
                                         axis2_pt1  =  pt3,
                                         axis2_pt2  =  pt4,
                                         quad_pt    =  qpt,
                                         proj       =  true_flag,
                                         window_id  =  wind_id,
                                         angle_type = "degrees",
                                         p_angle    = &my_angle );

Arguments
   IGRlong   *   msg          O -  return code 
   IGRdouble *   axis1_pt1    I -  origin of axis #1
   IGRdouble *   axis1_pt2    I -  end of axis #1
   IGRdouble *   axis2_pt1    I -  origin of axis #2
   IGRdouble *   axis2_pt2    I -  end of axis #2
   IGRdouble *   quad_pt      I -  identifies quadrant for angle
   IGRboolean    proj         I -  indicate true(0) or apparent(1) projection
   GRobjid       window_id    I -  window object id to supply x-axis
   IGRchar   *   angle_type   I -  NULL(default) => angle in radians
                                   a type        => angle in angle_type units   
                                   unknown type  => angle in radians
   IGRdouble *   p_angle      O -  angle measured between the two axes

Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails
   IGRlong  msg          MANOSOLUTION - if the implied axes do not intersect
                                        in true mode(proj = FALSE) there is
                                        no solution.   

History: 11/04/90  jjc    Created
         05/05/92  Carlos Removed `status = `
*/

#omdef gr$meas_angle_pts_arb_axis ( msg,
                                    axis1_pt1,
                                    axis1_pt2,
                                    axis2_pt1,
                                    axis2_pt2,
                                    quad_pt,
                                    proj       = TRUE,
                                    window_id,
                                    angle_type = "radians",
                                    p_angle )
                                    

CO_meas_angle_pts_arbaxis( msg,
                           axis1_pt1,
                           axis1_pt2,
                           axis2_pt1,
                           axis2_pt2,
                           quad_pt,
                           proj,
                           window_id,
                           angle_type,
                           p_angle );

#endomdef

/*
  gr$meas_length_along_ele

Abstract
   This  macro accepts  a GRid  and three  points. The  first two
   points define the start and end points for the measurement and
   the dir_pt is a direction  point required for closed elements.
   It outputs the true length along the element between the start
   and end points.
   Note: The specified points need not lie on the element.  They will
         be projected onto the element with respect to the view.

Example
   status = gr$meas_length_along_ele( msg       = &msg,
                                      p_grid    = &my_grid,
                                      start_pt  =  pt1,
                                      end_pt    =  pt2, 
                                      dir_pt    =  dir_pt,
                                      window_id =  win_id,
                                      p_length  = &len );

Arguments
   IGRlong     *    msg         O    return code  
   struct GRid *    p_grid      I    GRid of element to measure
   IGRdouble   *    start_pt    I    start measurement point
   IGRdouble   *    end_pt      I    stop measurement point
   IGRdouble   *    dir_pt      I    direction point required for 
                                      closed elements 
   GRobjid          window_id   I    window id for view information
   IGRdouble   *    p_length    O    length along element between 
                                      points
Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails


History: 11/04/90  jjc    Created
         05/05/92  Carlos Removed 'status = '
*/
#omdef gr$meas_length_along_ele( msg,
                                 p_grid,
                                 start_pt,
                                 end_pt,
                                 dir_pt,
                                 window_id,
                                 p_length )
                                 
CO_meas_length_along( msg,
                      p_grid,
                      start_pt,
                      end_pt,
                      dir_pt,
                      window_id,
                      p_length );

#endomdef


/*
   gr$meas_radius

Abstract
   This macro accepts a GRid of an element and outputs the radius of the 
   element.  If the element is non-uniform, the radius of curvature at 
   an input point will be output.  This input point will be projected
   onto the element with repect to the view.  Note: for ellipse and 
   elliptical arc, the radius at the primary axis is output.

example
   status = gr$meas_radius( msg       = &msg,
                            p_grid    = &my_grid,
                            rad_pt    = pt1, 
                            window_id = win_id, 
                            p_radius  = &radius ); 

Arguments
   IGRlong     *   msg       O    return code
   struct GRid *   p_grid    I    GRid of element to measure
   IGRdouble   *   rad_pt    I    required if element is non-uniform
   GRobjid         window_id I    window object id (req if rad_pt specified)
   IGRdouble   *   p_radius  O    radius of element

Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails

History: 11/05/90  jjc    Created
         05/05/92  Carlos Removed 'status = '
*/
#omdef gr$meas_radius( msg,
                       p_grid,
                       rad_pt = NULL,
                       window_id = 0,
                       p_radius )

CO_measure_radius( msg,
                   p_grid,
                   rad_pt,
                   window_id,
                   p_radius ); 



#endomdef

/*
     gr$meas_angle_two_lines 

Abstract

     This macro accepts two GRids of line segments and outputs the angle
     between them.  An additional point is used to determine in which
     quadrant to measure the angle.

Example
   status = gr$meas_angle_two_lines ( msg        = &msg,
                                      p_grid1    = &line1_grid,
                                      p_grid2    = &line2_grid,
                                      quad_pt    =  pt1,
                                      proj       =  true_flag,
                                      window_id  =  wind_id,
                                      angle_type = "degrees",
                                      p_angle    = &angle );

Arguments
   IGRlong     * msg           O -  return code
   struct GRid * p_grid1       I -  GRid of first line
   struct GRid * p_grid2       I -  GRid of second line
   IGRdouble   * quad_pt       I -  identifies quadrant for angle
   IGRboolean    proj          I -  indicate true(0) or apparent(1) projection
   GRobjid       window_id     I -  window object id for apparent projection
   IGRchar     * angle_type    I -  NULL(default) => angle in radians
                                    a type        => angle in angle_type units
                                    unknown type  => angle in radians
   IGRdouble   * p_angle       O -  angle measured between the two lines

Return status:
   IGRlong  status       MSSUCC - succeeds
                         MSFAIL - fails
   IGRlong  msg          MANOSOLUTION - if the input lines do not intersect
                                        in true mode(proj = FALSE) there is
                                        no solution.   


History: 11/08/90  jjc  Created
         05/05/92  Carlos Removed 'status = '

*/
#omdef  gr$meas_angle_two_lines ( msg,
                                  p_grid1,
                                  p_grid2,
                                  quad_pt,
                                  proj = TRUE,
                                  window_id,
                                  angle_type = "radians",
                                  p_angle )


CO_meas_angle_two_lines ( msg,
                          p_grid1,
                          p_grid2,
                          quad_pt,
                          proj,
                          window_id,
                          angle_type,
                          p_angle );



#endomdef

#endif


