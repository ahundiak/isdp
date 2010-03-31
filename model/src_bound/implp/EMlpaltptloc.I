/* ###################   APOGEE COMPILED   ################## */
/*
History
	SM			Creation.
	SM	13-Mar-89	Modified to use the ray ENDING
				at the input point instead of a ray BEGINING
				at the input point (as was being done
				before). This change will enable to resolve
				sorting ambiguity using the loop type and
				knowing the fact that begin point of the
				ray is definetly outside the loop. The loop
				type however may not always be correct (for
				e.g when called from EMlpinit). In such cases
				the option EMS_PTLOC_NOLOOPTYPE should
				be set to supress the ambiguity removal logic.
				Also increased MAX_NUM_RAYS from 5 to 10.
*/
class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"
#include "emsinterdef.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"

#define	MAX_NUM_RAYS	10

#ifndef DEBUG
#define DEBUG		0
#endif

#if DEBUG
#include <stdio.h>
#endif

static void EMclassify_point(num_inters, inters, location, last, lp_props)
IGRint			num_inters;
struct EMSpypoint	*inters;
struct EMSptloc_info	*location;
IGRboolean		last;
IGRushort	lp_props;
{

 struct EMSpypoint	*keyinters;
 IGRint			i;
 IGRushort	intprops;

 keyinters = inters;
 if(last)
   for(i=0; i<num_inters-1; i++) keyinters = keyinters->next;
 intprops = keyinters->props;

 if(last)
  {
   if(intprops & EMS_PYPT_ATSTART) location->location = EMS_L_ONEDGE;
   else if(intprops & EMS_PYPT_AREAHOLE)
    {
     if(lp_props & EMLP_PLOOP) location->location = EMS_L_OUTSIDE;
     else location->location = EMS_L_INSIDE;
    }
   else if(intprops & EMS_PYPT_HOLEAREA)
    {
     if(lp_props & EMLP_PLOOP) location->location = EMS_L_INSIDE;
     else location->location = EMS_L_OUTSIDE;
    }
   else location->location = EMS_L_UNKNWN;
  }
 else
  {
   if(intprops & EMS_PYPT_ATSTART) location->location = EMS_L_ONEDGE;
   else if(intprops & EMS_PYPT_AREAHOLE)
    {
     if(lp_props & EMLP_PLOOP) location->location = EMS_L_INSIDE;
     else location->location = EMS_L_OUTSIDE;
    }
   else if(intprops & EMS_PYPT_HOLEAREA)
    {
     if(lp_props & EMLP_PLOOP) location->location = EMS_L_OUTSIDE;
     else location->location = EMS_L_INSIDE;
    }
   else location->location = EMS_L_UNKNWN;
  }
}


method EMalternate_pt_location(IGRlong *EMmsg;
			       IGRdouble *point;
			       struct EMSptloc_info *location;
			       struct EMSpartolbasis *partolbasis)
{
  IGRlong		sts;
  struct IGRpolyline	ray_poly;
  IGRdouble		ray_point[2][2];
  IGRushort	trim_options;
  IGRint		num_inters, ray_num, size, toginfo, j;
  IGRboolean		rlw_get_better_line();
  IGRdouble		mindist_from_bdry;
  struct IGRline	in_line;
  IGRdouble		point1_3d[3], point2_3d[3], uvlentol;
  IGRdouble		ray_3d[2][3], loop_range_3d[2][3], poly_range[4];
  void 			EM2dbx();
  struct EMSsfintedpar	*myinters;
  struct EMSpypoint	*polyinters;
  IGRuint	callinx;
  IGRboolean		good = FALSE;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  myinters = NULL;
  polyinters = NULL;
  location->location = EMS_L_UNKNWN;
  location->loop_id = my_id;
  in_line.point1 = point1_3d;
  in_line.point2 = point2_3d;
  size = 2 * sizeof(IGRdouble);
  OM_BLOCK_MOVE(point, point1_3d, size);
  point1_3d[2] = 0.0;
  OM_BLOCK_MOVE(ME.EMSloop->range, loop_range_3d[0], size);
  OM_BLOCK_MOVE(&ME.EMSloop->range[2], loop_range_3d[1], size);
  loop_range_3d[0][2] = loop_range_3d[1][2] = 0.0;

  /* Increment the loop range by parametric space extents. Both the 
     extremes of the ray should now be definetly outside the loop.
  */
  loop_range_3d[0][0] -= (Uhigh - Ulow);
  loop_range_3d[0][1] -= (Vhigh - Vlow);

  loop_range_3d[1][0] += (Uhigh - Ulow);
  loop_range_3d[1][1] += (Vhigh - Vlow);

  ray_poly.num_points = 2;
  ray_poly.points = (IGRdouble *) ray_point;

  trim_options = EMS_INTER_CUTTING | EMS_INTER_STARTPT | EMS_INTER_STOPPT |
                 EMS_INTER_REMZEROEND;

  if (! partolbasis->is_valid)
   {
    sts = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg, 
               NULL, partolbasis), targetid = my_id);
    EMerr_hndlr (!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
    partolbasis->is_valid = TRUE;
   }
  EFextract_par (BSTOLLENVEC, partolbasis->tol, &uvlentol, EMmsg);


  /* Start casting rays untill the input point has been classified or 
     we run out of rays, whichever is earlier.
  */
  for(ray_num = 0, callinx = 0; (ray_num < MAX_NUM_RAYS) &&
	(location->location == EMS_L_UNKNWN); ray_num++, callinx++)
   {
     good = FALSE; 
     location->location = EMS_L_UNKNWN;
     /* Generate an internal point for this loop.
     */
     sts = om$send(msg = message EMSloop.EMptinside
	     (EMmsg, &callinx, partolbasis, 1, point2_3d, &mindist_from_bdry), 
			targetid = my_id);
			
     /* Ignore error codes from the above method in the hope that atleast
	one ray will be right.
     */
     if(!(1&*EMmsg&sts))
      {
	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	continue;
      }
     point2_3d[2] = 0.0;

     /* Generate a ray */

     sts = rlw_get_better_line(loop_range_3d, &in_line, ray_3d, EMmsg);
     if(!(1&*EMmsg)) goto wrapup;

     /* Put the ray into the 2D polyline. The ray is clipped against
        the range box of the loop. The directed half ray is generated such 
        that it ENDS at the input point.
     */

     for(j=0; (j<2) && (location->location==EMS_L_UNKNWN); j++)
      {
       good = FALSE;
       location->location = EMS_L_UNKNWN;
       OM_BLOCK_MOVE(ray_3d[j], ray_point[0], size);
       OM_BLOCK_MOVE(point, ray_point[1], size);
       EM2dbx (2, ray_point, poly_range);
       EM2dbxinc (poly_range, uvlentol);

       /* Get the cutting intersections of the ray with the loop. */

       num_inters = 0;
       if(myinters) EMsfintedpar_free(myinters, NULL);
       if(polyinters) EMpypoint_free(polyinters, NULL);
       myinters = NULL;
       polyinters = NULL;
       sts = om$send(msg = message EMSloop.EMlppytrimint
				(EMmsg, &ray_poly, poly_range, partolbasis, 
				 1, trim_options, &num_inters, 
				 &myinters, &polyinters), 
				targetid = my_id);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
       if(!num_inters) continue;

       /* If the 'half' ray just considered does not produce any intersections
        then use the other half. We need to have atleast one intersection
        because the location needs to be determined based on the direction
        of the loop rather than number of intersections. This is required
        for methods like 'EMlpinit' which set the directional bit of the
        loops based on the location returned for a point which is known to
        be outside. 
       */
       toginfo = EMS_L_UNKNWN;
       EMsortpypts (EMmsg, &polyinters, 2, &toginfo, &uvlentol);
       EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       /* If the sorting was ambiguous because of some coincedent 
	   intersections, try the other half of the same ray.
       */
       if( (*EMmsg == EMS_I_Ambiguous) &&
           !(location->options & EMS_PTLOC_NOLOOPTYPE) &&
           (ray_num == MAX_NUM_RAYS - 1))
        {
         if(ME.EMSloop->lp_props & EMLP_PLOOP) toginfo = EMS_L_INHOLE;
         else toginfo = EMS_L_INAREA;
         EMsortpypts (EMmsg, &polyinters, 2, &toginfo, &uvlentol);
         EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
         if( (*EMmsg == EMS_I_Ambiguous) ||(*EMmsg == EMS_I_InvalidArg))
          location->location = EMS_L_UNKNWN;
         else good = TRUE;
        }
       else if( (*EMmsg != EMS_I_InvalidArg) &&
	        (*EMmsg != EMS_I_Ambiguous)) good = TRUE;
	
       if(good)
         EMclassify_point(num_inters, polyinters, location, TRUE, 
				ME.EMSloop->lp_props);
				
      } /* for(j=0; j<2; j++) */
 
   } /* for(ray_num = 0; ray_num < MAX_NUM_RAYS; ray_num++) */


wrapup:

#if DEBUG
 if(location->location != EMS_L_UNKNWN)
  fprintf(stderr, "\nLocation from ray index %d is %d", --ray_num, 
			location->location);
 else if(location->location == EMS_L_UNKNWN)
  fprintf(stderr, "\nUnknown Location after %d rays", ray_num);
	
 fprintf(stderr, "\n\n\n");
#endif

 if(myinters) EMsfintedpar_free(myinters, NULL);
 if(polyinters) EMpypoint_free(polyinters, NULL);

 EMWRAPUP(*EMmsg, sts, "In EMSloop.EMalternate_pt_location");
 return(sts);
}

end implementation EMSloop;

