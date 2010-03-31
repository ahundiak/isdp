/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsolid;

#include "EMS.h"
# include "OMmacros.h" /* For OM_BLOCK_MOVE */
# include "EMSconstruct.h" /* for EMS_S_SOLID_HOLE ... */
# include "bserr.h" 
# include "bsparameters.h"  /* For BSTOLSQLENVEC */
# include <stdio.h>
#include "ma.h"
#include "maptlnpro.h"
#include "bsdistptpts.h"

# define MAX_NO_ATTEMPTS 3
# define DEBUG 0

from EMSsubbs import EMclassify_ray;

%safe
static IGRboolean EFreturn_location ();
%endsafe

%safe
static IGRint EFreturn_unique ();
%endsafe

method EMpoint_locate (IGRlong *EMmsg; struct GRmd_env *env;
                       IGRushort options;
                       IGRpoint inpoint; IGRpoint range[2]; 
                       IGRulong *location)

/* ************************************************************************* 

Description
     This method determines the location of a point with respect to a solid.
     It return location as 
         EMS_S_ONSOLID : if the point is lying on the solid
         EMS_S_INSOLID : if the point is lying inside the solid
         EMS_S_OUTSOLID: if the point is lyint outside the solid
         EMS_S_UNKNOWN : if the point location was unknown.

     Input
       env - module environment of thesolid
       options - Currently not used.
       inpoint - point which needs to be classified
       range - Range of the solid if known, or else set to NULL.         

     Output
       location - The location of the inpoint.
       EMmsg : completion code


Notes
  Upon exit the completion code will be one of the following
   EMS_S_Success : if successful
   EMS_E_SurfaceError : if there was an error in getting the range of
                        the solid.
   EMS_E_MAerror : if there was an error in projecting the inpoint onto
                   the ray.
   EMS_E_Intersect : if there was an error while intersecting the curve
                     and the surface.
   EMS_E_Fail : if there is general failure

History
   12/14/87 : PP  : Creation
   07/01/89 : BL  : Modified EMsort_by_parameter() static state, therefore, I
		    can use this function; also did some changes to make this 
		    function more efficient.
   09/13/89 : PP  : Modified the routine to not barf if an error occurs. 
                    Instead it would try again until max no of tries is reached.
   07/16/92 : AMD : Removed ANSI compilation errors.
   04/08/93 : NP  : Modified EMsort_by_parameter() to make it more flexible by
                    allowing some parameters to be passed as NULL.
   07/01/93 : Sudha Modified for BSprototypes ansification
   11/01/93 : NP  : Wrong array index was used to check for point eqality. All
                    pts ON solid were being classified as OUT.
   01/03/94 : NP  : Moved function EMsort_by_parameter to file EMgenfunc.C.
   08/25/94 : Sanjay : Fixed a abr (Array Bounds Read) which was occuring while
                       calling EFreturn_unique function.
  ************************************************************************* */
 
{
 IGRlong status,msg_loc;
 struct GRid my_GRid;
 IGRpoint range[2],line_pt;
 struct IGRbsp_curve ray;
 IGRpoint poles[2],range_buff[2];
 IGRdouble *range_ptr;
 IGRdouble t;
 IGRdouble knots[4];
 IGRdouble *xyz_pts,distsq, distsqtol;
 IGRboolean world = TRUE;
 IGRuint attempt_no = 0;
 IGRuint no_int_right, no_int_left;
 IGRboolean classification;
 IGRint index;
 IGRint cin;
 struct GRparms *my_int, *curve_int;
 struct IGRline rayline;
 IGRulong *inter_props = NULL;
 IGRlong total_int,pnt_slots = 0;
 IGRdouble uvpt[2];
 IGRint right_odd, left_odd, max_no_tries;
 IGRboolean reverse;

 extern void EFget_ray ();
 extern void EMsort_by_parameter ();


 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_int = NULL;
 curve_int = NULL;
 inter_props = NULL;
 xyz_pts = NULL;
 total_int = 0;

 ray.poles = (IGRdouble *) poles;
 ray.weights = NULL;
 ray.knots = (IGRdouble *) knots;
 ray.bdrys = NULL;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 *location = EMS_S_UNKNOWN;

 status = BSEXTRACTPAR (&msg_loc, BSTOLSQLENVEC, distsqtol);

 if ((IGRdouble *) range)
  range_ptr = (IGRdouble *)range;
 else
  range_ptr = (IGRdouble *)range_buff;

 status = om$send (msg = message GRvg.GRgetrang (EMmsg, 
                   &env->md_env.matrix_type, env->md_env.matrix, &world,
                   range_ptr),
             targetid = my_id,
             targetos = OM_Gw_current_OS);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

 max_no_tries = 0;

while ((max_no_tries < MAX_NO_ATTEMPTS) && (*location ==  EMS_S_UNKNOWN))
{
 EFget_ray (EMmsg, &my_GRid, env, range_ptr, inpoint, &attempt_no, &ray);
 EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup1);

 rayline.point1 = &ray.poles[0];
 rayline.point2 = &ray.poles[3];

 status = om$send (msg = message EMSsurface.EMcrvsrfint(EMmsg,NULL,&env->md_env,
                         &ray, NULL, NULL, FALSE, &pnt_slots, &total_int,
                         NULL, &my_int, &curve_int, &xyz_pts, &inter_props),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Intersect, wrapup1);

 if (total_int != 0)
 {
 EMsort_by_parameter (my_int, curve_int, xyz_pts, inter_props, total_int);

 status = MAptlnproj (EMmsg, inpoint, &rayline, line_pt, &t);
 EMerr_hndlr (!status, *EMmsg, EMS_E_MAerror, wrapup1);

 if (!(EFreturn_location (t, curve_int,total_int, &index)))
 {
   *EMmsg = EMS_E_InvalidCase;
   goto wrapup1;
 }

 if (index == -1)
 {
  cin = 0;
  reverse = FALSE;
  no_int_left = 0;
  no_int_right = EFreturn_unique (EMmsg, total_int, distsqtol, xyz_pts, 
                                  inter_props);
 }
 else if (index == total_int)
 {
  cin = total_int - 1;
  reverse = TRUE;
  no_int_right = 0;
  no_int_left = EFreturn_unique (EMmsg, total_int, distsqtol, xyz_pts,
                                 inter_props);
 }
 else
 {
  cin = index;
  reverse = TRUE;
  no_int_right = EFreturn_unique(EMmsg, index + 1, distsqtol, xyz_pts, 
                                 inter_props);
  no_int_left = EFreturn_unique(EMmsg, total_int - index - 1, distsqtol,
                                &xyz_pts[3*(index+1)], 
                                &inter_props[(index+1)]);
 }

 distsq = BSdistptpts (&msg_loc,  inpoint, &xyz_pts[3*cin]);
 if (distsq < distsqtol)
  *location = EMS_S_ONSOLID;
 else if (index != -1  && index != total_int)
 {
  distsq = BSdistptpts (&msg_loc, inpoint, &xyz_pts[3*(cin+1)]);
  if (distsq < distsqtol)
   *location = EMS_S_ONSOLID;
 }

 right_odd = no_int_right % 2;
 left_odd = no_int_left % 2;

 if ((right_odd == left_odd) && (*location != EMS_S_ONSOLID))
 {
 if (!(inter_props[cin] & EMS_L_ONVRTX) 
      && !(inter_props[cin] & EMS_L_ONEDGE))
 {
   uvpt[0] = my_int[cin].u;
   uvpt[1] = my_int[cin].v;

   status = om$send (msg = message EMSsubbs.EMclassify_ray (EMmsg,env,
                      &rayline, reverse, uvpt,NULL, &classification),
                     targetid = my_int[cin].leaf_id.objid,
                     targetos = my_int[cin].leaf_id.osnum);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup1);

   if (classification == EMS_S_SOLID_HOLE)
      *location = EMS_S_INSOLID;
     else if (classification == EMS_S_HOLE_SOLID)
      *location = EMS_S_OUTSOLID;
     else
      *location = EMS_S_UNKNOWN;
 }
 else if ((index !=  -1) && (index != total_int) &&
          !(inter_props[cin + 1] & EMS_L_ONVRTX) &&
          !(inter_props[cin + 1] & EMS_L_ONEDGE) && 
           (*location & EMS_S_UNKNOWN))
 {
  uvpt[0] = my_int[cin + 1].u;
  uvpt[1] = my_int[cin + 1].v;
   status = om$send (msg = message EMSsubbs.EMclassify_ray (EMmsg,env,
                           &rayline, FALSE, uvpt, NULL, &classification),
                     targetid = my_int[cin + 1].leaf_id.objid,
                     targetos = my_int[cin + 1].leaf_id.osnum);
   EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup1);

   if (classification == EMS_S_SOLID_HOLE)
    *location = EMS_S_INSOLID;
   else if (classification == EMS_S_HOLE_SOLID)
    *location = EMS_S_OUTSOLID;
   else 
    *location = EMS_S_UNKNOWN;
 }
}
}


wrapup1:

 ++attempt_no;
 ++max_no_tries;

#if DEBUG
 fprintf(stderr,"Number of tries done = %d \n\n", max_no_tries );
#endif

 if (my_int) om$dealloc (ptr = my_int);
 if (curve_int) om$dealloc (ptr = curve_int);
 if (inter_props) om$dealloc (ptr = inter_props);
 if (xyz_pts) om$dealloc(ptr = xyz_pts);
 my_int = NULL;
 curve_int = NULL;
 pnt_slots = 0;
 total_int = 0;
 inter_props = NULL;
 xyz_pts = NULL;
}
 
wrapup:

 EMWRAPUP (*EMmsg, status, "In EMSsolid : EMpoint_locate error");
 if (my_int) om$dealloc (ptr = my_int);
 if (curve_int) om$dealloc (ptr = curve_int);
 if (inter_props) om$dealloc (ptr = inter_props);
 if (xyz_pts) om$dealloc(ptr = xyz_pts);
 return (status);
}


static IGRint EFreturn_unique (msg_loc, total_no, distsqtol, pts,props)
IGRlong *msg_loc;
IGRint total_no;
IGRdouble distsqtol;
IGRdouble *pts;
IGRulong *props;

{
 IGRshort i;
 IGRint count;
 IGRdouble distsq;

 count = 1;

for (i=0; i < total_no - 1 ;i++)
 {
 distsq = BSdistptpts (msg_loc,  &pts[3*i], &pts[3*(i+1)]);
 if (distsq > distsqtol)
   ++count;
 else
 {
   props[i] |= props[i+1];
   props[i+1] |= props[i];
 }
}

 *msg_loc = EMS_S_Success;
 
return (count);

}
 

static IGRboolean EFreturn_location (t, curve_int, total_int, index)
IGRdouble t;
struct GRparms *curve_int; 
IGRlong total_int;
IGRint *index;
{
 IGRboolean found;
 IGRshort i;

 found = FALSE;
 i=0;
 while (i < total_int && !found)
 {
  if (i)
  {
   if ((curve_int[i].u - t ) * (curve_int[i-1].u - t)  <= 0)
   {
    found = TRUE;
    *index = i - 1;
   }
  }
  else
  {
   if (t <= curve_int[i].u)
   {
    found = TRUE;
    *index = -1;
   }
  }
  ++i;
 }

 if (!found)
 {
  if (t >= curve_int[total_int - 1].u)
  {
   found = TRUE;
   *index = total_int;
  }
 }

return (found);
}

end implementation EMSsolid;
