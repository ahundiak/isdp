/*
 * Functions in this file help close Add/Remove profile
 *
 *  HISTORY
 *
 *  SAM      06/??/94       Creation.
 *  Sanjay   09/30/94       Fixed a bug in knot vector generation in Convert
 *                          PolytoCurve routine.
 *  Sanjay   10/??/94       Revolved Support.
 *  Sanjay   12/15/94       Fixed a crash problem, which will happen doing 
 *                          an invalid operation.
 *  Sanjay   06/06/95       "CheckCoplanarCase" returns TRUE only if the 
 *                          profile is fully lying inside the plane it is 
 *                          contained.
 *  Sanjay   06/28/95       Coplanar case should be checked up even in finite
 *                          symmetric case. 
 *  Sanjay   08/31/95       All intobjs from the P-LOOP edges will be ignored
 *                          because of concavity, then stop processing here and
 *                          go to the general algorithm.   
 *  Usha     10/09/97       "CheckCoplanarCase is not always giving the correct
 *   Kiran                   results. so the profile is made Bspline curve and
 *                           checked at frequent intervals before assigning the
 *                           coplanar flag. the results observed are very good
 *                           and solves the problem for group of cases rather
 *                           than the tr 119528493...(root cause). This addition *                           of code generally will not any old cases as it is
 *                           only an enhancement.
 */

class implementation Root;

%safe
#include <math.h>
%endsafe
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"
#include "EMSasfeatdef.h"
#include "emsbool.h"
#include "emscvexten.h"
#include "EC_I.h"
#include "msmacros.h"
#include "emsmacros.h"
#include "emsmapdef.h"
#include "emsedgedef.h"
#include "madef.h"

// Prototypes

#include "bscveval.h"
#include "bsconic.h"
#include "bsvalues.h"
#include "bsdistptpts.h"
#include "bsptlngen.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bsarclen.h"
#include "mabctoar.h"
#include "maartobc.h"
#include "bsmergarrcv.h"
#include "bscvarreval.h"
#include "bscvkttol2.h"
#include "bsarclen.h"
#include "bsdistptpt.h"  
#include "bsfreecv.h"
#include "bscvcv_int.h"
#include "bscv_slfint.h"
#include "bspolyxttpt.h"
#include "mabcendpts.h"
#include "bscv_endpt.h"
#include "bsalloccv.h"
#include "bsmdistptcv.h"
#include "bsbx2.h"
#include "bsmklnintbx.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bssfarrevn.h"
#include "bsprptonsf.h"  
#include "bsplptnorrg.h"
#include "bscvkttol2.h"
#include "bsarclen.h"
#include "bscvtstclsd.h"
#include "bsrev_cv.h"
#include "bscv_copy.h"
#include "bspartofcv.h"
#include "maptplpro.h"
#include "bsproj0.h"
#include "bsarclnparc.h"
#include "maidmx.h"


#include "addrmopts.h"
#include "addprot.h"

// Debug includes

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#define OUTSIDE	0
#define INSIDE 	1

// imports 

from GRgraphics		import GRcopy, GRxform, GRdelete, GRgetrang, GRconstruct, GRchgprops;
from GRconnector 	import GRdisconn, GRrigidconn;
from GRowner 		import GRget_number_components, GRget_components;
from GRvg		import GRgetsize, GRgetgeom, GRpostabsg, GRgeomprops, GRdetplane, EMptatpr, EMpratpt;
from EMSloopset		import EMget_loops;
from GRcurve 		import EMcrvslfint, GRendpts, GRptextend, EMcrvcrvint, GRrevparm, EMpartofcv;
from EMSloop		import EMmake_lb_loop, EMget_props, EMpt_location, EMget_edges;
from EMSedge		import EMget_props_type;
from EMSsurface		import EMsfsfint;
from GRcompcurve	import EMmakecomp;
      
// extern classids

extern OMuword 	OPP_GRcompcurve_class_id, OPP_EMSloop_class_id, OPP_EMSplane_class_id,
		OPP_GR3dlineseg_class_id, OPP_EMScomposite_class_id, OPP_GRbcsubbc_class_id;

// extern function declarations

extern IGRint GRabsg_del_by_objid();
extern IGRint EMdupdata();
extern IGRboolean EMprepdupdata();

%safe
static void GetIntobjA(struct EMSintobj **, int, IGRboolean); 
static IGRboolean OutCurvesContiguous(IGRlong *,IGRint,struct EMSdataselect *);
%endsafe

#ifdef __STDC__
#argsused
#elseif
/*ARGSUSED*/
#endif

#define UV_SAMPLE_POINT	0.5
#define	DELTA_ANGLE 	(M_PI / 2.0) /* ninety degrees */
#define ARCLEN_FACTOR 	20

/*
 * Function IGRboolean IntersectSplitIntobjs()
 * 
 * intobjs of inters1 are intersected with intobjs of inters2. 
 * Intersecting intobjs are split at the intersection points.
 */

#define FIRST 0

IGRboolean IntersectSplitIntobjs(
IGRlong			*msg,
IGRdouble		uvtol, //ptolb.tol
IGRboolean		endsofA_and_Aunmodified,
struct EMSinters 	*intersA,
struct EMSinters	*intersB,
struct GRmd_env		*env,
IGRboolean		*intersected)
{
  IGRint                sts=OM_S_SUCCESS, num_inters=0, i=0, num_intersA=0, 
                        num_intersB=0, num_intobjA=0;
  IGRlong               loc_msg=EMS_S_Success;
  struct EMSintobj	*intobjA = NULL, *intobjB = NULL,
  			*intobjBnext = NULL, *t1=NULL, *t2=NULL;
  struct EMSpypoint	*pyptA = NULL, *pyptB = NULL, *pypt = NULL;
  struct IntobjInfo	**infoA = NULL, **infoB = NULL, 
                        *intobjAmoreinfo = NULL, *intobjBmoreinfo = NULL;
  
  void			EFget_intersection_points(), EMpypoint_free(),
  			EMsortpypts();
  IGRboolean		EMmsplit_sf_intobj_uv();

  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  loc_msg = EMS_S_Success;
  *intersected = FALSE;
  
  intobjA = intersA->cvs;
  num_intobjA = FIRST;
 
  while(intobjA) 
  {
    intobjB = intersB->cvs;
    
    while(intobjB)
    {
      intobjBnext = intobjB->next;
      num_inters  = 0;
      num_intersA = 0;
      num_intersB = 0;
      
      EFget_intersection_points(&loc_msg, uvtol, NULL, NULL,
      				&intobjA->this_uvintobj, intobjA->reversed,
      				&intobjB->this_uvintobj, intobjB->reversed,
      				&num_inters, &pyptA, &pyptB);
      EMerr_hndlr (EMSerror(loc_msg), *msg, EMS_E_Fail, wrapup);

      if(num_inters)
      {
        EMsortpypts(&loc_msg, &pyptA, (short)num_inters, NULL, &uvtol);
        add$status( test = EMSerror(loc_msg), msg = *msg, code = EMS_E_Fail,
            str = "IntersectSplitIntobjs : EMsortpypts error",
            action = GOTO_VALUE, value = wrapup ); 

        EMsortpypts(&loc_msg, &pyptB, (short)num_inters, NULL, &uvtol);
        add$status( test = EMSerror(loc_msg), msg = *msg, code = EMS_E_Fail,
            str = "IntersectSplitIntobjs : EMsortpypts error",
            action = GOTO_VALUE, value = wrapup ); 
        
        num_intersA = num_inters; pypt = pyptA;
        for(i = 0; i < num_inters; i ++)
        {
          if(pypt->props & EMS_PYPT_ATSTART || pypt->props & EMS_PYPT_ATSTOP)
            num_intersA--; pypt = pypt->next;
        }
        
        if(num_intersA) 
        {
          if(endsofA_and_Aunmodified &&  OM_Gf_verbose_warning)
          printf("WARNING: Coplanar case, intersA (profile) end being split\n");

          intobjAmoreinfo = (struct IntobjInfo *) intobjA->more_info;
          intobjA->more_info = NULL;

	  EMmsplit_sf_intobj_uv(&loc_msg, NULL, &env->md_env, intobjA, pyptA, NULL, FALSE); 
        add$status( test = EMSerror(loc_msg), msg = *msg, code = EMS_E_Fail,
            str = "IntersectSplitIntobjs : EMmsplit_sf_intobj_uv error",
            action = GOTO_VALUE, value = wrapup ); 
 	  
          intobjA->more_info = (char *)intobjAmoreinfo;
 	  AllocateMoreInfo(num_intersA, &infoA, (struct IntobjInfo *)intobjA->more_info);          

	  t1 = intobjA->next;
	  for(i=0; i<num_intersA; i++)
	  {
	    t1->more_info = (char *) infoA[i]; 
	    t1 = t1->next;
	  } 	  
        }

        num_intersB = num_inters; pypt = pyptB;
        for(i = 0; i < num_inters; i ++)
        {
          if(pypt->props & EMS_PYPT_ATSTART || pypt->props & EMS_PYPT_ATSTOP)
            num_intersB--; pypt = pypt->next;
        }

        if(num_intersB) 
        {
          intobjBmoreinfo = (struct IntobjInfo *) intobjB->more_info;
          intobjB->more_info = NULL;

      	  EMmsplit_sf_intobj_uv(&loc_msg, NULL, &env->md_env, intobjB, pyptB, NULL, FALSE);
          add$status( test = EMSerror(loc_msg), msg = *msg, code = EMS_E_Fail,
              str = "IntersectSplitIntobjs : EMmsplit_sf_intobj_uv error",
              action = GOTO_VALUE, value = wrapup ); 
          
          intobjB->more_info = (char *) intobjBmoreinfo;
 	  AllocateMoreInfo(num_inters, &infoB, (struct IntobjInfo *)intobjB->more_info); 	

	  t2 = intobjB->next;
	  for(i=0; i<num_intersB; i++)
	  {
	    t2->more_info = (char *) infoB[i]; 
	    t2 = t2->next;
	  } 	   	  
        }

        if(pyptA) { EMpypoint_free(pyptA, MAXINT);  pyptA = NULL; }
        if(pyptB) { EMpypoint_free(pyptB, MAXINT);  pyptB = NULL; }
        
        *intersected = TRUE;

      } // if (num_inters)
         
      if(num_intersB)
        intobjB = intobjBnext;
      else
        intobjB = intobjB->next;

    } // while intobjB
  
    GetIntobjA(&intobjA, num_intobjA, endsofA_and_Aunmodified); 
    num_intobjA++;

  } // while intobjA
    
wrapup:

  if(pyptA) { EMpypoint_free(pyptA, MAXINT);  pyptA = NULL; }
  if(pyptB) { EMpypoint_free(pyptB, MAXINT);  pyptB = NULL; }

  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;

}

/*
 * Function GetIntobjA();
 */
  

/*
 * Function GetIntobjA();
 */
static void  GetIntobjA(
struct EMSintobj	**intobjA, 
int			num_intobjA, 
IGRboolean		endsofA_and_Aunmodified)
{
  struct EMSintobj *intobj=NULL;
  
  intobj = *intobjA;

  if(endsofA_and_Aunmodified)
  {
    if(num_intobjA == FIRST)
      while( intobj->next)
        intobj = intobj->next;    
    else
      intobj = intobj->next;
  }
  else
    intobj = intobj->next;

  *intobjA = intobj;

  return;
}
/*
 * Function AllocateMoreInfo();
 */
void AllocateMoreInfo(
IGRint 			num,
struct IntobjInfo 	***info,
struct IntobjInfo	*copy_info)
{
  IGRint i=0;
  struct IntobjInfo *this_info = NULL;
  
  (*info) = (struct IntobjInfo **) om$malloc(size = num*sizeof(struct IntobjInfo *));
  
  for(i = 0; i < num; i++) {

    this_info = (struct IntobjInfo *)om$malloc(size = sizeof(struct IntobjInfo));
    (*info)[i] = this_info;
    if(copy_info) { 
      this_info->creator = copy_info->creator; 
      this_info->convex  = copy_info->convex;
    }
  }   
}

/*
 * Function MapProfileOnPlaneWrapper()
 */



struct EMSintobj *MapProfileOnPlaneWrapper(
IGRlong 		*msg,
struct GRmd_env 	*profenv,
struct GRid 		*sfgrid, 
struct IGRbsp_surface 	*sfgeom, 
struct EMSpartolbasis 	*ptolb,
struct GRid 		*the_ploop,
struct GRid 		*profgrid,
IGRdouble 		chtol,
IGRboolean 		convex,
struct EMSinters 	**inters)
{
  IGRint 		sts=OM_S_SUCCESS, num_components=0, i=0, 
                        num_innerlps = 0;
  OMuint 		obj_count=0, num_lps=0;
  IGRlong 		msg_loc=EMS_S_Success, cv_size=0;
  GRclassid 		profclass;
  struct GRid 		*components = NULL;
  struct GRid 		ls_grid;
  GRobjid		*innerlps = NULL;
  struct EMSintobj 	*this_intobj = NULL;
  IGRboolean 		ok, cut = FALSE;
  struct IGRbsp_curve 	*cv_geom = NULL;    
  struct IntobjInfo 	*more_info = NULL;
  OM_S_CHANSELECT 	to_loopset;
  OM_S_OBJECT_LINKAGE   comm_list[1];
  struct EMSintobj 	*tmp_intobj = NULL;

  IGRshort 		is_planar=FALSE;
  IGRint 		num_out_cvs=0, mklistind=0;
  IGRushort 		options=0;
  struct EMSdataselect 	*uv_data=NULL, *xyz_data=NULL, *tmp_xyz_data=NULL, 
                        *tmp_uv_data=NULL;
  IGRuchar 		out_curve_type=0;

  IGRboolean 		EFmap_the_curve();
  struct EMSintobj*	EMmakeintlist();
  void			EMsfintedpar_free(), EMdataselect_data_free();
  
  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;
    
  sts = om$get_classid(objid = profgrid->objid, osnum = profgrid->osnum,
                       p_classid = &profclass);
                   
  if(om$is_ancestry_valid(subclassid = profclass,
  			  superclassid = OPP_GRcompcurve_class_id) == OM_S_SUCCESS)
  {
    sts = om$send(msg = message GRowner.GRget_number_components(
               		&msg_loc, &num_components),
                  targetid = profgrid->objid,
                  targetos = profgrid->osnum,
                  senderid = profgrid->objid);
    add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_CurveError,
        str = "MapProfileOnPlaneWrapper : GRget_number_components error",
        action = GOTO_VALUE, value = wrapup ); 

    components = (struct GRid *) alloca(num_components*sizeof(struct GRid));
    add$status( test = !components, msg = *msg, code = EMS_E_NoDynamicMemory,
        str = "MapProfileOnPlaneWrapper : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup ); 

    sts = om$send(msg = message GRowner.GRget_components (&msg_loc,
                          profenv, components, num_components,
                          (IGRint *)&obj_count, 0, num_components-1),
                          targetid = profgrid->objid,
                          targetos = profgrid->osnum,
                          senderid = profgrid->objid);
    add$status( test = (!components || (obj_count != num_components)), 
        msg = *msg, code = EMS_E_Fail,
        str = "MapProfileOnPlaneWrapper : GRget_components error",
        action = GOTO_VALUE, value = wrapup ); 

  }     /* If composite-curve */
  else {
    
    num_components = 1;
    components = profgrid;
  } /* If single curve */

 
  if(the_ploop)
  {
    EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
    om$get_channel_objects(objid = sfgrid->objid, osnum = sfgrid->osnum,
  		           p_chanselect = &to_loopset, count = &num_lps,
			   size = 1, list = comm_list);
    add$status( test = (num_lps != 1), msg = *msg, code = EMS_E_Fail,
        str = "MapProfileOnPlaneWrapper : om$get_channel_objects error",
        action = GOTO_VALUE, value = wrapup );
    
    ls_grid.objid = comm_list[0].S_objid;
    ls_grid.osnum = sfgrid->osnum;
  
    ok = RemoveInnerLoops(the_ploop, innerlps, &num_innerlps, &cut);
    if(!ok) {
    
      if(cut) { printf("We cut the inners but now we have a problem\n");
                goto wrapup; }
    }
  }
  else
  {
    ls_grid.objid = NULL_OBJID;
    ls_grid.osnum = sfgrid->osnum;
  }
  
  for(i=0; i < num_components; i++)
  {
    sts = om$send(msg = message GRvg.GRgetsize(&msg_loc, 
    			  &(profenv->md_env.matrix_type), profenv->md_env.matrix,
                           &cv_size),
                     senderid = profgrid->objid,
                     targetid = components[i].objid,
                     targetos = components[i].osnum);
    add$status( test = ! (1 & sts & msg_loc), msg = *msg, code = EMS_E_Fail,
        str = "MapProfileOnPlaneWrapper : GRvg.GRgetsize error",
        action = GOTO_VALUE, value = wrapup );
      
    cv_geom = NULL;        
    cv_geom = (struct IGRbsp_curve *) alloca((OMuint)cv_size);
    add$status( test = ! cv_geom, msg = *msg, code = EMS_E_NoDynamicMemory,
        str = "MapProfileOnPlaneWrapper : Insufficient  Memory",
        action = GOTO_VALUE, value = wrapup );

    sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                         &profenv->md_env.matrix_type,
                         profenv->md_env.matrix,
                         (IGRchar *)cv_geom),
                  senderid = NULL_OBJID,
                  targetid = components[i].objid,
                  targetos = components[i].osnum);
    add$status( test = ! (1 & sts & msg_loc), msg = *msg, code = EMS_E_Fail,
        str = "MapProfileOnPlaneWrapper : GRvg.GRgetgeom error",
        action = GOTO_VALUE, value = wrapup );
        
    xyz_data = uv_data = NULL;
    num_out_cvs = 0;
/*
    options = EMMapBnd_StrokeIfNeeded  | EMMapBnd_WantBadCurves | 
              EMMapBnd_NoValidate | EMMapBnd_NoRmvColEds | 
    	      EMMapBnd_ClipBdryArea | EMMapBnd_RmvDegenCvs;
*/    
    options = EMMapBnd_StrokeIfNeeded  | EMMapBnd_WantBadCurves | 
              EMMapBnd_NoValidate | EMMapBnd_NoRmvColEds | 
    	      EMMapBnd_RmvDegenCvs;

    if(!the_ploop) options |= EMMapBnd_NoClip;
    is_planar = EMS_O_Planar;

    /*
     * What IFF the comp curve is coincident with the loopset ?
     * In such a case what are the num out curves ? I assume 
     * coincident single curve not broken in to more curves because
     * coincidence with the P-loop in which it is contained is OK
     * as long as this curve does not have cutting type intersection!!!
     */  
    EFmap_the_curve(components[i], (struct IGRbsp_curve *)cv_geom, sfgeom,
	            ls_grid, &chtol, ptolb, options, &is_planar, 
		    &num_out_cvs, &uv_data, &xyz_data, &out_curve_type,
		    NULL, FALSE, &msg_loc);

    if (num_out_cvs == 0) continue;

    if (num_out_cvs > 1)
    {
      ok = OutCurvesContiguous(&msg_loc, num_out_cvs, xyz_data);
      add$status(test = !ok , msg = *msg, code = EMS_E_Fail,
	  str = "MapProfileOnPlaneWrapper; OutcurvesContiguous: >1 output curves, NOT CONTIGUOUS",
           action = GOTO_VALUE, value = wrapup); 

      add$status(test = !(1&msg_loc) , msg = *msg, code = EMS_E_Fail,
	  str = "MapProfileOnPlaneWrapper: OutcurvesContiguous failure",
           action = GOTO_VALUE, value = wrapup); 
    }
   
    for(mklistind = 0; mklistind < num_out_cvs; mklistind++)
    {
      tmp_xyz_data = NULL; tmp_uv_data = NULL;
     
      if(num_out_cvs > 1)
      {
        tmp_xyz_data = (struct EMSdataselect *) om$malloc(size = sizeof(struct EMSdataselect));

        ok = EMprepdupdata(&msg_loc, &xyz_data[mklistind], tmp_xyz_data);
        add$status(test = !ok, msg = *msg, code = EMS_E_Fail,
		str = "MapProfileOnPlaneWrapper: EMprepdupdata failure",
		action = GOTO_VALUE, value = wrapup);
 
        sts = EMdupdata(&msg_loc, &xyz_data[mklistind], tmp_xyz_data, NULL, 
			NULL, FALSE, FALSE);
        add$status(test = !(1&sts), msg = *msg, code = EMS_E_Fail,
		str = "MapProfileOnPlaneWrapper: EMdupdata failure",
		action = GOTO_VALUE, value = wrapup);
      
        tmp_uv_data = (struct EMSdataselect *) om$malloc(size = sizeof(struct EMSdataselect));

        ok = EMprepdupdata(&msg_loc, &uv_data[mklistind], tmp_uv_data);
        add$status(test = !ok, msg = *msg, code = EMS_E_Fail,
		str = "MapProfileOnPlaneWrapper: EMprepdupdata failure",
		action = GOTO_VALUE, value = wrapup);
 
        sts = EMdupdata(&msg_loc, &uv_data[mklistind], tmp_uv_data, NULL, NULL,
		      FALSE, FALSE);
        add$status(test = !(1&sts), msg = *msg, code = EMS_E_Fail,
		str = "MapProfileOnPlaneWrapper: EMdupdata failure",
		action = GOTO_VALUE, value = wrapup);
      
      } // if num_out_cvs > 1
      else
      {
        tmp_xyz_data = xyz_data;
        tmp_uv_data = uv_data;
      }

      tmp_intobj = EMmakeintlist(&msg_loc, inters, NULL, sfgrid, NULL,
 	            NULL, NULL, NULL, NULL, 
	            tmp_xyz_data, tmp_uv_data,
		    NULL, FALSE, NULL, NULL, NULL, NULL, NULL,
                    &out_curve_type, NULL, TRUE, FALSE);
      add$status( test = !(1&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "MapProfileOnPlaneWrapper : EMmakeintlist error", 
          action = GOTO_VALUE, value = wrapup );

      tmp_intobj->props |= EMSintobj_marked;   

      more_info = (struct IntobjInfo *)om$malloc(size = sizeof(struct IntobjInfo));
      more_info->creator = components[i].objid;
      more_info->convex = convex;
    
      EMsfintedpar_free(tmp_intobj->more_info, NULL); 
      tmp_intobj->more_info = (IGRchar *) more_info;
    
      if(!this_intobj)
  	this_intobj = tmp_intobj;
    
    } // for all the curves

    if(num_out_cvs > 1)
    {
      if(uv_data) EMdataselect_data_free(&msg_loc, uv_data, num_out_cvs);
      uv_data = NULL;

      if(xyz_data) EMdataselect_data_free(&msg_loc, xyz_data, num_out_cvs);
      xyz_data = NULL;
    }
 } // for all the profile components
      

wrapup:
  if(the_ploop)
  {
    if(cut) { 
      if(num_innerlps)
      {
        ok = AddInnerLoops(the_ploop, innerlps, num_innerlps);
        if(innerlps) { om$dealloc(ptr = innerlps); innerlps = NULL; }
        add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
            str = "MapProfileOnPlaneWrapper : AddInnerLoops error",
            action = RET_VALUE, value = NULL );
      } 
      else 
        add$status( test = TRUE, msg = *msg, code = EMS_E_Fail,
            str = "MapProfileOnPlaneWrapper : No Inner Loops",
            action = RET_VALUE, value = NULL );
    }
  }
    
  if(!(1&*msg)) {
    
    if(tmp_uv_data) EMdataselect_data_free(&msg_loc, tmp_uv_data, 1);
    if(tmp_xyz_data) EMdataselect_data_free(&msg_loc, tmp_xyz_data, 1);
    if(uv_data) EMdataselect_data_free(&msg_loc, uv_data, num_out_cvs);
    if(xyz_data) EMdataselect_data_free(&msg_loc, xyz_data, num_out_cvs);
    
    return NULL;
  }

  return(this_intobj);
}

/*
 * Function returns TRUE if the xyzdatas are contiguous
 */

static IGRboolean OutCurvesContiguous(
IGRlong *msg,
IGRint numcvs, 
struct EMSdataselect *xyzdata)
{
  IGRshort mattyp=2;
  IGRmatrix mat;
  IGRint numpts = 1, i=0, sts=OM_S_SUCCESS, ind=0;
  IGRdouble start[6], stop[6], tollenvec=0, tolsq=0;
  IGRboolean ok=TRUE; 
  IGRlong  loc_msg=EMS_S_Success;
  BSrc rc=TRUE;

  *msg = EMS_S_Success;

  BSEXTRACTPAR(&loc_msg, BSTOLLENVEC, tollenvec);
  
  tolsq = tollenvec * tollenvec;

  ok = MAidmx(&loc_msg, mat);
  mattyp = MAIDMX;

  sts = EMgetendpts_xyz(&loc_msg, mattyp, mat, &xyzdata[0], FALSE,
	                numpts, &start[0], &stop[0]);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
            str = "OutCurvesContiguous: EMgetendpts_xyz() failure",
            action = RET_VALUE, value = FALSE );
  
  for(i = 1; i < numcvs; i++)
  {
    ind = i%2; 
 
    sts = EMgetendpts_xyz(&loc_msg, mattyp, mat, &xyzdata[i], FALSE,
			  numpts, &start[ind], &stop[ind]);
    
    add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
            str = "OutCurvesContiguous: EMgetendpts_xyz() failure",
            action = RET_VALUE, value = FALSE );
  
    if(BSdistptpts(&rc, &stop[0], &start[3]) <  tolsq)
      continue;
    
    if(BSdistptpts(&rc, &start[0], &start[3]) <  tolsq)
      continue;

    if(BSdistptpts(&rc, &start[0], &stop[3]) <  tolsq)
      continue;

    if(BSdistptpts(&rc, &stop[0], &stop[3]) <  tolsq)
      continue;

    return FALSE;
      
  } 
  
  return TRUE;
}

/*
 * Function RemoveInnerLoops()
 */

IGRboolean RemoveInnerLoops(
struct GRid	*the_ploop, 
GRobjid 	*inner,
IGRint 		*count,
IGRboolean 	*cut)
{
  IGRlong msg = EMS_S_Success;
  IGRint  sts = OM_S_SUCCESS, depth = 1, size = 0, i=0;
  OM_S_CHANSELECT to_outter, to_inner;  

  *cut = FALSE;
  inner = NULL;
  *count = 0;

  sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  if(!(1&sts)) return FALSE;
  sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  if(!(1&sts)) return FALSE;  

  sts = om$send(msg = message EMSloopset.EMget_loops(
				&msg, EMS_OPT_ALL, &depth, &inner, NULL, &size, count),
		        senderid = the_ploop->objid,
 			targetos = the_ploop->osnum,
 			targetid = the_ploop->objid);

  if(!(1&sts&msg)) return FALSE;
  if(!*count) return TRUE;
  
  *cut = TRUE;
  
  for(i = 0; i < *count; i++) {

    sts = om$send(msg=message Root.disconnect(
    			to_outter, the_ploop->objid, the_ploop->osnum, to_inner),
                  senderid = the_ploop->objid,
                  targetos = the_ploop->osnum,
                  targetid=inner[i]);
    if(!(1&sts)) { printf("Problem while disconnecting\n"); 
    		   return FALSE; }
  }

 return TRUE;

}

/*
 * Function AddInnerLoops()
 */

IGRboolean AddInnerLoops(
struct GRid 	*the_ploop,
GRobjid		*inner,
IGRint 		count)

{
  IGRint i=0, sts = OM_S_SUCCESS;
  OM_S_CHANSELECT to_outter, to_inner;

  sts = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  if(!(1&sts)) return FALSE;
  sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  if(!(1&sts)) return FALSE;  
  
  for(i = 0; i < count; i++) {
    sts = om$send(msg=message Root.connect(to_outter, 0, the_ploop->objid, 
                         the_ploop->osnum, to_inner, 0),
                  senderid = the_ploop->objid,
                  targetos = the_ploop->osnum,
                  targetid=inner[i]);
    if(!(1&sts)) { printf("Problem while connecting\n"); 
    		   return FALSE; }                  
  }

  return TRUE;
}
  
/*
 * Function FixSelfIntersectingEndObjects()
 */

IGRlong FixSelfIntersectingEndObjects(
IGRlong			*EFmsg,
struct GRid 		*compcv,
struct GRmd_env 	*md_env,
struct GRvg_construct 	*const_list)
{
  IGRlong sts=OM_S_SUCCESS, msg_loc=EMS_S_Success, i=0;
  IGRint num_comps=0;
  GRobjid *comps=NULL, firstcv=NULL_OBJID, lastcv=NULL_OBJID;
  IGRboolean is_composite = FALSE;
  IGRshort mattyp=2;
  IGRdouble bastol=0;
  GRspacenum os=0;
  IGRlong num_slots=0, num_cvslots=0, num_cvints=0; 
  IGRlong num_intcv1=0, num_intcv2=0, *num_intcv=NULL;
  struct GRparms *intcv1=NULL, *intcv2=NULL, **intcv=NULL;
  IGRdouble *xyz_pts1=NULL, *xyz_pts2=NULL, **xyz_pts=NULL;
  struct GRid cvid[2];
  BSrc rc=BSSUCC;
  IGRdouble *mat=NULL;
  IGRboolean  trim1=FALSE, trim2=FALSE, bssts=TRUE, done = FALSE;
  IGRdouble trimpar1=0, trimpar2=0, *trimpar=NULL;
  IGRpoint junkpt, trimpt1, trimpt2, *trimpt=NULL, endpt1, endpt2, *endpt=NULL;
  IGRpoint final_endpt;
  struct IGRbsp_curve *cv = NULL;

  IGRint EMgetvggeom();
  void EFget_lowest_components(), EMsort_by_parameter();

  *EFmsg = EMS_S_Success;
   sts   = OM_S_SUCCESS;

 /* INITIALIZATIONS */

 num_comps = 0;
 comps = NULL;
 intcv1 = intcv2 = NULL; 
 xyz_pts1 = xyz_pts2 = NULL;
 
 os = compcv->osnum;
 mat = md_env->md_env.matrix;
 mattyp = md_env->md_env.matrix_type;

 BSEXTRACTPAR(&msg_loc, BSTOLBASIS, bastol);

  num_comps = 0;
  comps = NULL;
  is_composite = FALSE;

 (void) EFget_lowest_components(&msg_loc, compcv, &num_comps, &comps, 
                                &is_composite, NULL, NULL);
 add$status( test = !(1&msg_loc), msg = *EFmsg, code = EMS_E_Fail,
     str = "FixSelfIntersectingEndObjects : EFget_lowest_components error",
     action = GOTO_VALUE, value = wrapup );

  if((num_comps == 1) || !is_composite)
  {
    num_intcv   = &num_intcv1;
    intcv       = &intcv1;
    xyz_pts     = &xyz_pts1;
  
    *intcv        = NULL;
    *num_intcv    = 0;
    *xyz_pts      = NULL;
    num_cvints  = 0;
    num_slots   = 0;
    num_cvslots = 0;    
    sts = om$send(msg = message GRcurve.EMcrvslfint(&msg_loc, const_list,
                             &(md_env->md_env), &num_slots, num_intcv, NULL, intcv, 
                             xyz_pts, &num_cvslots, &num_cvints, NULL, NULL),
                     senderid = compcv->objid,
                     targetid = compcv->objid,
                     targetos = compcv->osnum);
    add$status( test = !(1&sts&msg_loc), msg = *EFmsg, code = EMS_E_Fail,
        str = "FixSelfIntersectingEndObjects : EMcrvsrfint error",
        action = GOTO_VALUE, value = wrapup );

    add$status( test = (((*num_intcv != 1) && (*num_intcv != 3))), msg = *EFmsg, 
        code = EMS_E_Fail,
        str = "FixSelfIntersectingEndObjects : Number of Intersection curves is not equal to either one or three.",
        action = GOTO_VALUE, value = wrapup );
    /* sort the intersection paramters on the curve in increasing order.*/

    if (*intcv)
    {
      EMsort_by_parameter (NULL, *intcv, (IGRdouble *)NULL, NULL, (IGRint)*num_intcv);

      if(*num_intcv == 1)
      {

        trimpar1 = intcv1[0].u; 
        trimpt1[0] = xyz_pts1[0];
        trimpt1[1] = xyz_pts1[1];
        trimpt1[2] = xyz_pts1[2];	 	
       
        trimpar2 = intcv1[1].u;
        trimpt2[0] = xyz_pts1[0];
        trimpt2[1] = xyz_pts1[1];
        trimpt2[2] = xyz_pts1[2];	 	      	
      }
      else // *num_intcv == 3
      {
 	sts = EMgetvggeom(&msg_loc, &mattyp, mat, compcv, (IGRchar **)&cv, NULL);
        add$status( test = !(1&sts&msg_loc), msg = *EFmsg, code = EMS_E_Fail,
            str = "FixSelfIntersectingEndObjects : EMgetvggeom error",
            action = GOTO_VALUE, value = wrapup );
        
        trimpar1 = intcv1[1].u;
	
        BScveval(cv, trimpar1, (IGRint)0, &trimpt1, &rc);
        add$status( test = (rc != BSSUCC), msg = *EFmsg, code = EMS_E_BSerror,
            str = "FixSelfIntersectingEndObjects : BScveval error",
            action = GOTO_VALUE, value = wrapup );
       
        trimpar2 = intcv1[4].u;
        trimpt2[0] = trimpt1[0];
        trimpt2[1] = trimpt1[1];
        trimpt2[2] = trimpt2[2];	 	      	
      }
    
      bssts = ExtractCurve(&msg_loc, compcv, md_env, NULL, 
      			   trimpar1, trimpar2, trimpt1);
      add$status( test = !bssts, msg = *EFmsg, code = EMS_E_Fail,
            str = "FixSelfIntersectingEndObjects : ExtractCurve error",
            action = GOTO_VALUE, value = wrapup );
      
      done = TRUE;
    }    
  }
  else
  {
    firstcv = comps[0];
    lastcv  = comps[num_comps-1];
    cvid[0].objid = firstcv;
    cvid[1].objid = lastcv;
    cvid[0].osnum = cvid[1].osnum = compcv->osnum;

    /* next intersect the end components with the incomng curve */

    trim1 = trim2 = FALSE; /* ASSUME we dont have to trim either end */
    for (i=0; i<2; i++)
    {
      num_intcv   = (i==0? &num_intcv1  : &num_intcv2);
      intcv       = (i==0? &intcv1      : &intcv2);
      xyz_pts     = (i==0? &xyz_pts1    : &xyz_pts2);
  
      *intcv        = NULL;
      *num_intcv    = 0;
      *xyz_pts      = NULL;
      num_cvints  = 0;
      num_slots   = 0;
      num_cvslots = 0;

      /* Ignore curve overlap. Get only the intersection points */
      sts = om$send(msg = message GRcurve.EMcrvcrvint(&msg_loc, const_list,
                               &(md_env->md_env), NULL, compcv, 
                               &(md_env->md_env), TRUE, 
                               &num_slots, num_intcv, NULL, intcv, NULL, 
                               xyz_pts, &num_cvslots, &num_cvints, NULL, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = cvid[i].objid,
                       targetos = cvid[i].osnum);
      add$status( test = !(1&sts&msg_loc), msg = *EFmsg, code = EMS_E_Fail,
            str = "FixSelfIntersectingEndObjects : EMcrvcrvint error",
            action = GOTO_VALUE, value = wrapup );

      /* sort the intersection paramters on the curve in increasing order.*/

      if (*intcv)
      {
         EMsort_by_parameter (NULL, *intcv, *xyz_pts, NULL, (IGRint)*num_intcv);
      }

      /* Now, as we move OUTWARDS on the composite curve (stoppt->startpt for
       * "firstcv" and startpt->stoppt for "lastcv") we pick the self-intersection
       * point which is highest for the firstcv and lowest for the lastcv and 
       * use that as the trim point.
       */
      if (i==0)
      {
        if (intcv1) /*if "firstcv" finds an intersection with the rest of the cv*/
        { 
          IGRint pos = num_intcv1-1;
          trimpar1 = intcv1[pos].u;
  	  trimpt1[0] = xyz_pts1[3*pos];
  	  trimpt1[1] = xyz_pts1[3*pos+1];
	  trimpt1[2] = xyz_pts1[3*pos+2];	 	
      	  trim1 = TRUE;
        }
      }
      else
      {
        if (intcv2) /* if "lastcv" finds an intersection with the rest of the cv*/
        { 
          trimpar2 = intcv2[0].u;
	  trimpt2[0] = xyz_pts2[0];
	  trimpt2[1] = xyz_pts2[1];
	  trimpt2[2] = xyz_pts2[2];	 	      	
          trim2 = TRUE;
        }
      }

      /* Also calc. the endpt of this component that will possibly be trimmed off.
       * This will be the "startpt" of the first component and the "endpt" of
       * the last.
       */

      sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                                  &mattyp, mat,
                                  (i==0? endpt1 : junkpt), 
                                  (i==0? junkpt : endpt2)), 
                           senderid = NULL_OBJID,
                           targetid = cvid[i].objid,
                           targetos = cvid[i].osnum);
      add$status( test = !(1&sts&msg_loc), msg = *EFmsg, code = EMS_E_Fail,
            str = "FixSelfIntersectingEndObjects : GRendpts error",
            action = GOTO_VALUE, value = wrapup );
    }

    /* Since a self intersecting curve is coming in here, we better HAVE an
     * intersection on AT LEAST one of the end components.
     */
    
    add$status( test = (!num_intcv1 && !num_intcv2), msg = *EFmsg, 
        code = EMS_E_Fail,
        str = "FixSelfIntersectingEndObjects : No. of intersection curves is zero.",
        action = GOTO_VALUE, value = wrapup );

  
    /* send each end, the message to extend/distend it to the trim point */ 

    for (i=0; i<2; i++)
    {
      if (i==0? !trim1 : !trim2) /* if this component is NOT to be trimmed */
        continue;

      endpt      = (i==0? &endpt1     : &endpt2);
      trimpar    = (i==0? &trimpar1   : &trimpar2);
      trimpt     = (i==0? &trimpt1    : &trimpt2);
   
      /* We have the correct trim point. Modify the component */
      sts = om$send (msg = message GRcurve.GRptextend (&msg_loc, md_env, *endpt,
                         *trimpt, final_endpt),
                     senderid = NULL_OBJID,
                     targetid = cvid[i].objid,
                     targetos = cvid[i].osnum);
      add$status( test = !(1&sts&msg_loc), msg = *EFmsg,  code = EMS_E_Fail,
          str = "FixSelfIntersectingEndObjects : GRptextend error",
          action = GOTO_VALUE, value = wrapup );

      if (BSdistptpts(&rc, *trimpt, final_endpt) > (bastol * bastol))
         add$status( test = TRUE, msg = *EFmsg,  code = EMS_E_Fail,
             str = "FixSelfIntersectingEndObjects : BSdistptpts error",
             action = GOTO_VALUE, value = wrapup );
        
      done = TRUE;
    }
  }
 
  if(done && is_composite)  // GRpostabsg already done for non-composites
  {
    struct GRpost_info 	info; 
    GRobjid 		newid;

    info.construct_flag = FALSE ;
              
    sts = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
    				md_env, &info, (IGRchar *)NULL, &newid),
   		  senderid = compcv->objid,
                  targetid = compcv->objid,
                  targetos = compcv->osnum);
    add$status( test = !(1&sts&msg_loc), msg = *EFmsg,  code = EMS_E_Fail,
        str = "FixSelfIntersectingEndObjects : GRvg.GRpostabsg error",
        action = GOTO_VALUE, value = wrapup );
 
    if( newid == compcv->objid )
      GRabsg_del_by_objid( &compcv->objid, &compcv->osnum );
  }
  
wrapup:
  if (cv)
    { om$dealloc(ptr = cv); cv = NULL;}
  if (comps)
    {om$dealloc (ptr=comps);}
  if (intcv1)
    {om$dealloc (ptr=intcv1);}
  if (intcv2)
    {om$dealloc (ptr=intcv2);}
  if (xyz_pts1)
    {om$dealloc (ptr=xyz_pts1);}
  if (xyz_pts2)
    {om$dealloc (ptr=xyz_pts2);}

  EMWRAPUP (*EFmsg, sts, "In FixSelfIntersectingEndObjects");
   
  return(sts);
}

/*
 * Function ExtendLinearCurve() 
 */

IGRboolean ExtendLinearCurve(
IGRlong			*msg,
struct GRid		*grid,
struct GRmd_env		*env,
struct IGRbsp_curve	*cv,
IGRboolean		ZEROEND,
IGRdouble		*newpt)
{
  struct IGRbsp_curve	*this = NULL;
  IGRlong		loc_msg=EMS_S_Success, cv_size=0;
  IGRint		sts=OM_S_SUCCESS;
  IGRdouble		*thispt = NULL;
  
  *msg = EMS_S_Success;

  if(cv) 
    this = cv;
  else
  {
    sts = om$send(msg = message GRvg.GRgetsize(&loc_msg, 
    			  &env->md_env.matrix_type, env->md_env.matrix,
                           &cv_size),
                  senderid = grid->objid,
                  targetid = grid->objid,
                  targetos = grid->osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg,  code = EMS_E_Fail,
        str = "ExtendLinearCurve : GRvg.GRgetsize error",
        action = GOTO_VALUE, value = wrapup );
      
    this = (struct IGRbsp_curve *) alloca((OMuint)cv_size);
    add$status( test = !this, msg = *msg,  code = EMS_E_NoDynamicMemory,
        str = "ExtendLinearCurve : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup );

    sts = om$send(msg = message GRvg.GRgetgeom(&loc_msg,
                         &env->md_env.matrix_type,
                         env->md_env.matrix,
                         (IGRchar *)this),
                  senderid = grid->objid,
                  targetid = grid->objid,
                  targetos = grid->osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg,  code = EMS_E_Fail,
        str = "ExtendLinearCurve : GRvg.GRgetgeom error",
        action = GOTO_VALUE, value = wrapup );
  }

  if(ZEROEND)
    thispt = &(this->poles[0]);
  else
    thispt = &(this->poles[3*(this->num_poles-1)]);
      
  thispt[0] = newpt[0]; 
  thispt[1] = newpt[1]; 
  thispt[2] = newpt[2];
        
  if(grid)
  {
    struct GRpost_info 	info; 
    GRobjid 		newid=NULL_OBJID;

    info.construct_flag = FALSE ;
              
    sts = om$send(msg = message GRvg.GRpostabsg(&loc_msg,
    				env, &info, (IGRchar *)this, &newid),
                  senderid = grid->objid,
                  targetid = grid->objid,
                  targetos = grid->osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg,  code = EMS_E_Fail,
        str = "ExtendLinearCurve : GRvg.GRpostabsg error",
        action = GOTO_VALUE, value = wrapup );

    if( newid == grid->objid )
       GRabsg_del_by_objid( &grid->objid, &grid->osnum );
  }
  
wrapup:
  
  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;  
}


/*
 * Function FixOneCurve()
 */

IGRboolean ExtractCurve(
IGRlong			*msg,
struct GRid		*grid,
struct GRmd_env		*env,
struct IGRbsp_curve	**cv,
IGRdouble		par1,
IGRdouble		par2,
IGRdouble		*phy_closedpt)
{
  struct IGRbsp_curve	*this=NULL, *new=NULL;
  IGRlong		loc_msg=EMS_S_Success, cv_size=0, num_poles=0;
  IGRint		sts=OM_S_SUCCESS;
  BSrc			rc=BSSUCC;
  IGRboolean		bssts=TRUE;
  IGRdouble		endpts[6], bastol=0;
  
  *msg = EMS_S_Success;

  if(cv) 
    this = *cv;
  else
  {
    sts = om$send(msg = message GRvg.GRgetsize(&loc_msg, 
    			  &env->md_env.matrix_type, env->md_env.matrix,
                           &cv_size),
                  senderid = grid->objid,
                  targetid = grid->objid,
                  targetos = grid->osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg,  code = EMS_E_Fail,
        str = "ExtractCurve : GRvg.GRgetsize error",
        action = GOTO_VALUE, value = wrapup );
      
    this = (struct IGRbsp_curve *) alloca((OMuint)cv_size);
    add$status( test = !this, msg = *msg,  code = EMS_E_NoDynamicMemory,
        str = "ExtractCurve : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup );

    sts = om$send(msg = message GRvg.GRgetgeom(&loc_msg,
                         &env->md_env.matrix_type,
                         env->md_env.matrix,
                         (IGRchar *)this),
                  senderid = grid->objid,
                  targetid = grid->objid,
                  targetos = grid->osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg,  code = EMS_E_Fail,
        str = "ExtractCurve : GRvg.GRgetgeom error",
        action = GOTO_VALUE, value = wrapup );
  }

  num_poles = this->num_poles + 2 * this->order - 1;
  
  (void) BSalloccv(this->order, num_poles, this->rational, 
                  this->num_boundaries, &new, &rc);
  add$status( test = (rc != BSSUCC), msg = *msg,  code = EMS_E_BSerror,
        str = "ExtractCurve : BSalloccv error",
        action = GOTO_VALUE, value = wrapup );
 
  bssts = BSpartofcv(&rc, this, par1,(IGRdouble)(par1+par2)/2.0, par2, new);
  add$status( test = !bssts || (rc != BSSUCC), msg = *msg,  code = EMS_E_Fail,
        str = "ExtractCurve : BSpartofcv error",
        action = GOTO_VALUE, value = wrapup );
  
  if(phy_closedpt)
  {
    bssts = MAbcendpts(&rc, new, &endpts[0], &endpts[3]);
    add$status( test = !bssts || (rc != MSSUCC), msg = *msg,  code = EMS_E_Fail,
        str = "ExtractCurve : MAbcendpts error",
        action = GOTO_VALUE, value = wrapup );

    BSEXTRACTPAR(&rc, BSTOLBASIS, bastol);
  
    if(BSdistptpts(&rc, &endpts[0], phy_closedpt) > (bastol * bastol))
    {
      add$status( test = TRUE, msg = *msg,  code = EMS_E_Fail,
          str = "ExtractCurve : BSdistptpts error",
          action = GOTO_VALUE, value = wrapup );
    }

    if(BSdistptpts(&rc, &endpts[3], phy_closedpt) > (bastol * bastol))
    {
      add$status( test = TRUE, msg = *msg,  code = EMS_E_Fail,
          str = "ExtractCurve : BSdistptpts error",
          action = GOTO_VALUE, value = wrapup );
    }
  }
  
  if(cv) 
  {
    BSfreecv(&rc, *cv);
    *cv = new;
  }
  else
  {
    struct GRpost_info 	info; 
    GRobjid 		newid;

    info.construct_flag = FALSE ;
              
    sts = om$send(msg = message GRvg.GRpostabsg(&loc_msg,
    				env, &info, (IGRchar *)new, &newid),
                  senderid = grid->objid,
                  targetid = grid->objid,
                  targetos = grid->osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg,  code = EMS_E_Fail,
        str = "ExtractCurve : GRvg.GRpostabsg error",
        action = GOTO_VALUE, value = wrapup );

    if( newid == grid->objid )
       GRabsg_del_by_objid( &grid->objid, &grid->osnum );
  }
  
wrapup:
  
  if(!(1&*msg))
  {
    if(new) { BSfreecv(&rc, new); new = NULL; }    

    return FALSE;
  }  
  else
    return TRUE;
}

/*
 * Function ExtendEndCurves
 */


IGRlong ExtendEndCurves(
IGRlong 	 	*msg,
struct IGRbsp_curve	**geoms,
IGRboolean		check_from,
IGRboolean		check_to,
IGRuchar		*types,
IGRint	                num_geoms,
IGRboolean              closure,
IGRdouble           	*ext_dist,/*NULL, if it has to be calc. acc to options*/
IGRdouble               *ext_vec, /*NULL, if end tangents are to be used */
GRrange			range,
struct GRid		*sfid,
struct GRmd_env		*modenvsf,
IGRboolean		*self_intersection,
struct IGRbsp_curve	**added_geom)
{
 BSrc          rc=BSSUCC;
 IGRint        i=0, j=0, type=0, num_comps=0;
 IGRlong       sts=OM_S_SUCCESS, msg_loc=EMS_S_Success;
 IGRdouble     par=0, *vec=NULL, *dist=NULL, cht=0;
 IGRdouble     start_dist=0, end_dist=0;
 IGRboolean    status=TRUE;
 GRobjid       *comps=NULL;
 IGRpoint      cv_startpt, cv_endpt, junkpt, points[2][3], ext_pt;
 IGRpoint      endpt;
 IGRvector     tangent, start_tangent, end_tangent;

 struct GRparms        *cv_pars=NULL;
 struct IGRbsp_curve   *current_geom=NULL;
 struct IGRbsp_curve   *cvgeom=NULL, *cv_array[2];
 struct IGRbsp_curve   line_geom,
                       *merged_cv=NULL, *new=NULL;
 double TOLLENVEC=0;
 IGRboolean ret=TRUE;
 IGRdouble endpt_dist=0;

 IGRlong      		EFextend_to_bounds();
 
 /*
  * Initialisation
  */
  *msg   = EMS_S_Success;
  sts = OM_S_SUCCESS;
 
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht);
  BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, TOLLENVEC);  	  	        	
  
  /* INITIALIZATIONS */

  if (self_intersection)
     *self_intersection = FALSE; /* assume */
  cv_pars   = NULL;
  num_comps = 0;
  comps     = NULL;
  merged_cv = NULL;

  ret = MAbcendpts(&msg_loc, geoms[0], junkpt, cv_endpt);
  add$status( test = !ret || (msg_loc != MSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "ExtendEndCurves : MAbcendpts error",
      action = GOTO_VALUE, value = ret_end );
  
  ret = MAbcendpts(&msg_loc, geoms[num_geoms-1], cv_startpt, junkpt);
  add$status( test = !ret || (msg_loc != MSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "ExtendEndCurves : MAbcendpts error",
      action = GOTO_VALUE, value = ret_end );

  endpt_dist = BSdistptpt(&msg_loc, cv_startpt, cv_endpt); /* always BSSUCC*/ 
  add$status( test = endpt_dist < TOLLENVEC, msg = *msg,code = EMS_E_InvalidArg,
      str = "ExtendEndCurves : BSdistptpt error",
      action = GOTO_VALUE, value = ret_end );
  
  /* get extend dist for either end  ONLY if "ext_dist" is not input */
  for (i=0; i<2 && !ext_dist; i++)
  {
     vec = (IGRdouble *) (ext_vec ? (i==0? &ext_vec[0] : &ext_vec[3]) : NULL);
     dist = (i==0? &end_dist : &start_dist);
     cvgeom = (i==0? geoms[0] : geoms[num_geoms-1]);

     if (vec)
        OM_BLOCK_MOVE (vec, tangent, sizeof (IGRvector));
     else
     {
        /* get the outward tangent to the curve */
        par = (i==0? 1.0 : 0.0);
        (void) BScvarreval(&rc,cvgeom,&par,1,1,(IGRdouble *)points);
        for (j=0; j<3; j++)
           tangent[j] = (points[0][1][j]) * (i==0? 1.0 : -1.0) ;
     }

     BSnorvec(&rc, tangent); /* always BSSUCC */

     OM_BLOCK_MOVE (tangent, (i==0? end_tangent : start_tangent),
                           sizeof (IGRvector)); /* for later use below */

     /* get the endpt which we need to get extension distance for */
     par = (i==0? 1.0 : 0.0);
     (void) BScvarreval(&rc,cvgeom,&par,1,0,(IGRdouble *)points);
     for (j=0; j<3; j++)
       endpt[j] = points[0][0][j];

     /* Find the extention of the endpt of the input curve upto range 
      * box, and along the outward tangent calculated above.
      */

     sts = EFextend_to_bounds (&msg_loc, modenvsf, endpt, 
                                range, sfid, tangent, ext_pt);
     add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "ExtendEndCurves : EFextend_to_bounds error",
      action = GOTO_VALUE, value = ret_end );
 
     /* find extension dist*/
     if (msg_loc == EMS_I_NoSolution) /* bounding box behind endpt */
       *dist = 0.0;
     else
        *dist = BSdistptpt( &rc, endpt, ext_pt); /* always BSSUCC*/

     *dist += 10 * cht; /* just in case */

  }/*for*/

  for (i=0; i<2; i++)
  {
     /* This end curve has to be merged with a linear extention 
      * segment. 
      */
     
     current_geom = (i==0? geoms[0] : geoms[num_geoms-1]);

     /* the tangent vector has been normalized above */
     for (j=0; j<3; j++)
       ext_pt[j] = (i==0? cv_endpt[j]: cv_startpt[j])  + 
                   ((i==0? end_tangent[j] : start_tangent[j]) * 
                                    (i==0? end_dist : start_dist));
     if(types)
     {
       if(types[i] == EMlinesegment)
       {
         ret = ExtendLinearCurve(&msg_loc, NULL, NULL, current_geom, 
         			 (i==0?FALSE:TRUE), ext_pt);
         add$status( test = !ret, msg = *msg, code = EMS_E_Fail,
             str = "ExtendEndCurves : ExtendLinearCurve error",
             action = GOTO_VALUE, value = ret_end );
         
         continue;
       }
     }
     
     line_geom.poles = (IGRdouble *) alloca (2 * sizeof(IGRpoint));
     line_geom.knots = (IGRdouble *) alloca (4 * sizeof(IGRdouble));

     /* create the geometry parametrized in the direction of the curve*/
     status = BSptlngen(&rc, 
                (i==0? cv_endpt : ext_pt), (i==0?  ext_pt : cv_startpt), 
                &line_geom, &type);
     add$status( test = (rc!=BSSUCC)||(type!=BSCLINE), msg = *msg, 
         code = EMS_E_BSerror, str = "ExtendEndCurves : BSptlngen error",
         action = GOTO_VALUE, value = ret_end );

     /* merge the two curves */
     
     cv_array[0] = (i==0? current_geom : &line_geom);
     cv_array[1] = (i==0? &line_geom : current_geom);

     (void) BSmergarrcv(2,cv_array,&merged_cv,&rc);
     add$status( test = (rc!=BSSUCC), msg = *msg, 
         code = EMS_E_BSerror, str = "ExtendEndCurves : BSmergarrcv error",
         action = GOTO_VALUE, value = ret_end );
     
     if (merged_cv)
     {
       BSfreecv(&rc, current_geom);
       geoms[(i==0) ? 0 : num_geoms-1] = merged_cv;       
     }

  }/*for*/
  
  if(check_from)
  {
    ret = FixOneEnd(&msg_loc, &geoms[0], FALSE);
    add$status( test = !ret, msg = *msg, 
        code = EMS_E_Fail, str = "ExtendEndCurves : FixOneEnd error",
        action = GOTO_VALUE, value = ret_end );
  }
  
  if(check_to)
  {
    ret = FixOneEnd(&msg_loc, &geoms[1], TRUE);
    add$status( test = !ret, msg = *msg, 
        code = EMS_E_Fail, str = "ExtendEndCurves : FixOneEnd error",
        action = GOTO_VALUE, value = ret_end );
  }

  if(self_intersection || closure)
  {
    *self_intersection = FALSE;

    // WHAT ABOUT phy closed ?

    sts = FixSelfIntersectingEndGeoms(&msg_loc, geoms, num_geoms, self_intersection);
    add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail, 
        str = "ExtendEndCurves : FixSelfIntersectingEndGeoms error",
        action = GOTO_VALUE, value = ret_end );
  }
  
  /* add a new component if asked for, to close off the curve */
  if (closure && !*self_intersection)
  {
     /* get the endpts of the "to be output" composite/simple curve */
     ret = MAbcendpts(&msg_loc, geoms[0], junkpt, cv_endpt);
     add$status( test = (!ret || (msg_loc != MSSUCC)), msg = *msg, 
         code = EMS_E_Fail, str = "ExtendEndCurves : MAbcendpts error",
         action = GOTO_VALUE, value = ret_end );
  
     ret = MAbcendpts(&msg_loc, geoms[num_geoms-1], cv_startpt, junkpt);
     add$status( test = (!ret || (msg_loc != MSSUCC)), msg = *msg, 
         code = EMS_E_Fail, str = "ExtendEndCurves : MAbcendpts error",
         action = GOTO_VALUE, value = ret_end );

     endpt_dist = BSdistptpt(&msg_loc, cv_startpt, cv_endpt); /* always BSSUCC*/ 
     if(endpt_dist < TOLLENVEC) goto ret_end;
      
     new = (struct IGRbsp_curve *) om$malloc(size = sizeof(struct IGRbsp_curve));
                
     new->poles = (IGRdouble *) om$malloc (size = 2 * sizeof(IGRpoint));
     new->knots = (IGRdouble *) om$malloc (size = 4 * sizeof(IGRdouble));

     /* create the geometry parametrized in the direction of the curve*/
     status = BSptlngen(&rc, cv_endpt, cv_startpt, new, &type);
     add$status( test = (rc!=BSSUCC)||(type!=BSCLINE), msg = *msg, 
         code = EMS_E_BSerror, str = "ExtendEndCurves : BSptlngen error",
         action = GOTO_VALUE, value = ret_end );
     
     *added_geom = new;
  }

ret_end:    

  if (comps)
    om$dealloc (ptr=comps);
  if (cv_pars)
     om$dealloc (ptr=cv_pars);

  EMWRAPUP (*msg, sts, "In ExtendEndCurves");
  return(sts);
}

/*
 * FUnction FixOneEnd()
 */

IGRboolean FixOneEnd(
IGRlong			*msg,
struct IGRbsp_curve	**cv,
IGRboolean		ZEROEND)
{
  BSrc		rc=BSSUCC;
  IGRdouble 	knot_tol=0;
  IGRdouble 	bastol=0, cht=0, delta=0, arclen=0, target_arclen=0, testpar=0,
  		midpar=0, trimpar=0, *overc=NULL, *overd=NULL, 
  		*overe=NULL,  *overf=NULL, *par1=NULL, *par2=NULL;
  IGRint 	n_int=0, numb_crvs=0;
  IGRboolean 	ok=TRUE;
  IGRlong	loc_msg=EMS_S_Success;

  

/* INITIALIZATIONS */

  *msg = EMS_S_Success;
  BSEXTRACTPAR(&rc, BSTOLBASIS, bastol);
  BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);

  ok = BScv_slfint(&rc, *cv, (IGRint *)&n_int, &par1, &par2,
                   (IGRint *)&numb_crvs, &overc, &overd, &overe, &overf);
  add$status( test = (rc!=BSSUCC) || !ok, msg = *msg, code = EMS_E_Fail, 
      str = "FixOneEnd : BScv_slfint error",
      action = GOTO_VALUE, value = wrapup );
  add$status( test = n_int > 1, msg = *msg, code = EMS_E_Fail, 
      str = "FixOneEnd : Number of interesections is greater than one.",
      action = GOTO_VALUE, value = wrapup );
  
  if(n_int)
  {
    BScvkttol2((*cv)->order, (*cv)->knots, (*cv)->num_poles, 
               (*cv)->poles, (*cv)->weights, &knot_tol, &rc);
    add$status( test =(rc != BSSUCC), msg = *msg, code = EMS_E_BSerror, 
        str = "FixOneEnd : BScvkttol2 error",
        action = GOTO_VALUE, value = wrapup );

    delta = knot_tol * cht / bastol;
    delta *= (ZEROEND ? 1.0 : -1.0); /* depending on which dir we want to move */
      
    target_arclen = ARCLEN_FACTOR * cht;
    arclen = 0.0; /* to start the while loop */
    testpar = (ZEROEND ? par1[0] : par2[0]);

    while (arclen < target_arclen)
    {
     /* Move the trim point some more and calc. the total moved distance*/
      testpar += delta; 
      midpar = (testpar + (ZEROEND ? par1[0] : par2[0]))/2.0; /* 'cos we dont have closed curves*/
      BSarclen(&rc, &ok, *cv, &testpar, &trimpar, &midpar, &arclen);
      add$status( test =(rc != BSSUCC) || !ok, msg = *msg, code = EMS_E_BSerror,
          str = "FixOneEnd : BSarclen error",
          action = GOTO_VALUE, value = wrapup );
    }

    /* Now move the final testpar to "*trimpt". */
    trimpar = testpar;
  
    ok = ExtractCurve(&loc_msg, NULL, NULL, cv, 
  		     (ZEROEND ? trimpar : 0), (ZEROEND ? 1.0 : trimpar), NULL);
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "FixOneEnd : ExtractCurve error",
        action = GOTO_VALUE, value = wrapup );
  }
  
wrapup:

  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
 * Function FixSelfIntersectingEndGeoms();
 */

IGRlong FixSelfIntersectingEndGeoms(
IGRlong			*msg,
struct IGRbsp_curve 	**geoms,
IGRint 			num_geoms,
IGRboolean 		*self_int)
{
  IGRdouble bastol=0;
  BSrc rc=BSSUCC;
  IGRint n_int=0, n_over=0, index1=0, parindex=0;
  IGRdouble *int_pts1=NULL, *par1=NULL, *par2=NULL, closedpt[3];
  IGRdouble *overend_pts=NULL, *over1=NULL, *over2=NULL;
  struct IGRbsp_curve *this_geom=NULL;

  IGRdouble 	*overc = NULL, *overd = NULL, *overe = NULL,  *overf = NULL;
  IGRint    	numb_crvs=0;
  IGRboolean 	status=TRUE;
  IGRlong	loc_msg=EMS_S_Success;

  IGRdouble *par = NULL;
  struct IGRbsp_curve *new_geom = NULL;
  IGRboolean ret=TRUE;
  IGRlong max_poles=0;
  IGRdouble endpts[6], *this_endpt=NULL, *ext_pt=NULL, newend[3], 
            *int_pts2 = NULL, *int_pts = NULL; 
  struct GRparms *parms1 = NULL, *parms2 = NULL, *parms = NULL;

  void EMsort_by_parameter();

/* INITIALIZATIONS */

  BSEXTRACTPAR(&rc, BSTOLBASIS, bastol);

  *self_int = FALSE;
 
  if(num_geoms == 1) // Take only one intersection point, ignore if many.
  {
    
    status = BScv_slfint(&rc, geoms[0], (IGRint *)&n_int, &par1, &par2,
                         (IGRint *)&numb_crvs, &overc, &overd, &overe, &overf);
   
    BScveval(geoms[0], par1[0], 0, (IGRpoint *)closedpt, &rc);
    add$status( test = (rc!=BSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "FixSelfIntersectingEndGeoms : BScveval error",
      action = GOTO_VALUE, value = wrapup );

    // This is for extending a curve for coplanar case
    // Hence it cannot have more that one intersection

    add$status( test = (n_int > 1), msg = *msg, code = EMS_E_Fail,
      str = "FixSelfIntersectingEndGeoms : No. of intersections is greater than one.",
      action = GOTO_VALUE, value = wrapup );

    if(n_int)
    {
      status = ExtractCurve(&loc_msg, NULL, NULL, &(geoms[0]), par1[0], par2[0], closedpt);
      add$status( test = !status, msg = *msg, code = EMS_E_Fail,
          str = "FixSelfIntersectingEndGeoms : ExtractCurve error",
          action = GOTO_VALUE, value = wrapup );

      *self_int = TRUE;      
    }
  }
  else 
  {
    status = BScvcv_int(&rc, geoms[0], geoms[num_geoms-1], &n_int, &int_pts1, 
     	  		&par1, &par2, (IGRlong *)&n_over, &overend_pts, &over1, &over2);
    add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
        str = "FixSelfIntersectingEndGeoms : BScvcv_int error",
        action = GOTO_VALUE, value = wrapup );
    
    if(n_int)
    {
      IGRdouble partol;      
      IGRint	i, starti, stopi;
      IGRboolean start, stop;
            
      starti = 0; stopi = 0; start = FALSE; stop = FALSE;
            
      BSEXTRACTPAR(&rc, BSTOLPARAM, partol);      

      for(i = 0; i < n_int; i++)
      {
        if(par1[i] < partol) {
          start = TRUE;
          starti = i;
        }

        if(par2[i] > (1.0-partol)) {
          stop = TRUE;
          stopi = i;
        }
      }
      
      if(start && stop)
      {
        add$status( test = (starti != stopi), msg = *msg, code = EMS_E_Fail,
            str = "FixSelfIntersectingEndGeoms : (strari != stopi) error",
            action = GOTO_VALUE, value = wrapup );

        for(i = starti; i < n_int-1; i++)
        {
          par1[i] = par1[i+1]; par2[i] = par2[i+1];

	  int_pts1[3*i] = int_pts1[3*(i+1)];
	  int_pts1[3*i+1] = int_pts1[3*(i+1)+1];
	  int_pts1[3*i+2] = int_pts1[3*(i+1)+2];	  	  
        }

        n_int--;
      }
      else if(start || stop)
      {
        printf("Intersection at either first is 0.0 or last is 1.0 not both true\n");
        *msg = EMS_E_Fail; 
        goto wrapup;
      }
    }

    if(n_int)
    {
      *self_int = TRUE;
    
      parms1 = (struct GRparms *) om$malloc(size = n_int*sizeof(struct GRparms));
      parms2 = (struct GRparms *) om$malloc(size = n_int*sizeof(struct GRparms));      
    
      int_pts2 = (IGRdouble *) om$malloc(size = n_int * 3* sizeof(IGRdouble));
      OM_BLOCK_MOVE(int_pts1, int_pts2, n_int*3*sizeof(IGRdouble));
      
      for(index1 = 0; index1 < 2; index1++) 
      {
        this_geom = (index1==0? geoms[0] : geoms[num_geoms-1]);
        parms = (index1==0? parms1 : parms2);        
        par = (index1==0? par1 : par2);
        
        int_pts = (index1==0? int_pts1 : int_pts2);        
                        
        for(parindex = 0; parindex < n_int; parindex++)
          parms[parindex].u = par[parindex];
      
        EMsort_by_parameter (NULL, parms, int_pts, NULL, (IGRint)n_int);

        if(this_geom->rational)
          max_poles = this_geom->num_poles + 6 * (2 * this_geom->order -1);
        else
          max_poles = this_geom->num_poles + 3 * (2 * this_geom->order -1);

        new_geom = NULL;
        (void) BSalloccv(this_geom->order, max_poles, this_geom->rational, 
                         this_geom->num_boundaries, &new_geom, &rc);
        add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
            str = "FixSelfIntersectingEndGeoms : BSalloccv error",
            action = GOTO_VALUE, value = wrapup );

        ret = MAbcendpts(&rc, this_geom, &endpts[0], &endpts[3]);
        add$status( test = !ret || (rc != MSSUCC), msg = *msg,code = EMS_E_Fail,
            str = "FixSelfIntersectingEndGeoms : MAbcendpts error",
            action = GOTO_VALUE, value = wrapup );
        
        this_endpt = (index1 == 0? &endpts[0] : &endpts[3]);
        ext_pt = (index1 == 0? &int_pts[0] : &int_pts[3*(n_int-1)]);

        ret = BSpolyxttpt (&rc, this_geom, this_endpt, ext_pt, new_geom);
        add$status( test = !ret || (rc != BSSUCC), msg = *msg,code = EMS_E_Fail,
            str = "FixSelfIntersectingEndGeoms : BSpolyxttpt error",
            action = GOTO_VALUE, value = wrapup );
        
        ret = BScv_endpt(&rc, new_geom, ext_pt, newend);
        add$status( test = !ret, msg = *msg,code = EMS_E_Fail,
            str = "FixSelfIntersectingEndGeoms : BScv_endpt error",
            action = GOTO_VALUE, value = wrapup );

        if(BSdistptpts(&rc, ext_pt, newend) > (bastol * bastol))
        {
          add$status( test = TRUE, msg = *msg,code = EMS_E_Fail,
              str = "FixSelfIntersectingEndGeoms : BSdistptpts error",
              action = GOTO_VALUE, value = wrapup );
        }
        
        BSfreecv(&rc, this_geom);
        geoms[(index1==0) ? 0 : num_geoms-1] = new_geom; 

      } // for the two components
    }  // if (n_int)
  } // if num_geoms > 1

wrapup:

  if(int_pts1) { om$dealloc(ptr = int_pts1); int_pts1 = NULL; }
  if(int_pts2) { om$dealloc(ptr = int_pts2); int_pts2 = NULL; }  
  if(par1) { om$dealloc(ptr = par1); par1 = NULL; }     	
  if(par2) { om$dealloc(ptr = par2); par2 = NULL; }
  if(overend_pts) { om$dealloc(ptr = overend_pts); overend_pts = NULL; }
  if(over1) { om$dealloc(ptr = over1); over1 = NULL; }
  if(over2) { om$dealloc(ptr = over2); over2 = NULL; }
  if(parms2) { om$dealloc(ptr = parms2); parms2 = NULL;}
  if(parms1) { om$dealloc(ptr = parms1); parms1 = NULL;}  

  if(overc) { om$dealloc(ptr = overc); overc = NULL; }
  if(overd) { om$dealloc(ptr = overd); overd = NULL; }
  if(overe) { om$dealloc(ptr = overe); overe = NULL; }
  if(overf) { om$dealloc(ptr = overf); overf = NULL; }      


  if(!(1&*msg)) 
    return FALSE;
  else
    return TRUE;

}

/*
 * Function UnMarkIntobj(): Called before trace
 * This functions unmarks the profile extended intobjs
 * 
 * Can be called after trace to check if the profile
 * is clipped if the profile is clipped at both the
 * ends then endsONmarked is FALSE;
 */

IGRboolean UnMarkIntobj(
IGRlong		 *msg,
IGRdouble	 *ends,
struct EMSinters *inters,
IGRboolean       *nomark,
IGRboolean	 *endsONmarked)
{

  struct EMSintobj    *tmp_intobj = inters->cvs;
  struct IGRbsp_curve *cv = NULL, *alloccv = NULL;
  IGRdouble           *parms = NULL, *intvls = NULL, mdist=0, cht=0;
  IGRshort            n_parms, n_intvls;
  BSrc                rc=BSSUCC;
  IGRboolean	      ok=TRUE;
  IGRlong	      loc_msg=EMS_S_Success;
  	
  *msg = EMS_S_Success;
  *nomark = TRUE;
  *endsONmarked = FALSE;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht);  

  while(tmp_intobj) {

    if(tmp_intobj->props & EMSintobj_marked) {
      
      *nomark = FALSE;
      
      if(tmp_intobj->this_xyzintobj.datatype == EMSdata_poly3d)
      {
        ok = ConvertPolyToCurve(&loc_msg, tmp_intobj->this_xyzintobj.data.poly, 
        			(IGRboolean)FALSE, &alloccv); 
        cv = alloccv;
      }
      else
      	cv = tmp_intobj->this_xyzintobj.data.curve;
     
      n_intvls = n_parms = 0; mdist = 0.0; 

      BSmdistptcv(cv, &ends[0], &n_intvls, &n_parms, &parms, &mdist, &intvls, &rc);
      add$status( test = (rc != BSSUCC), msg = *msg,code = EMS_E_BSerror,
          str = "UnMarkIntobj : BSmdistptcv error",
          action = GOTO_VALUE, value = wrapup );
     
      if(parms)  { om$dealloc(ptr = parms); parms = NULL; }
      if(intvls) { om$dealloc(ptr = intvls); intvls = NULL; }
 
      
      if(mdist > cht) {
        n_intvls = n_parms = 0; mdist = 0.0; 

        BSmdistptcv(cv, &ends[3], &n_intvls, &n_parms, &parms, &mdist, &intvls, &rc);
        add$status( test = (rc != BSSUCC), msg = *msg,code = EMS_E_BSerror,
            str = "UnMarkIntobj : BSmdistptcv error",
            action = GOTO_VALUE, value = wrapup );
        
        if(parms)  { om$dealloc(ptr = parms); parms = NULL; }
        if(intvls) { om$dealloc(ptr = intvls); intvls = NULL; }
        
        if(mdist > cht)
          tmp_intobj->props &= ~EMSintobj_marked;
        else
          *endsONmarked = TRUE;
      } 
      else
        *endsONmarked = TRUE;
    }
    tmp_intobj = tmp_intobj->next;

    if(alloccv) { BSfreecv(&rc, alloccv); alloccv = NULL; }    
  }

wrapup:
  
  if(alloccv) { BSfreecv(&rc, alloccv); alloccv = NULL; }
  
  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;  
}

/*
 * SingleConvexIntobj, numcc_intobjs are two.
 */

IGRboolean TwoIntobjsExtend(
IGRlong	            *msg,
IGRvector	    NORMAL,
struct GRmd_env	    *env_cvs,
struct EMSintobj    **cc_intobjs, //Don't follow the next chain run a FOR LOOP
struct GRid	    *sl,
struct GRmd_env	    *envsl,
struct IGRbsp_curve ***comp_cvs,
IGRuchar	    **comp_types,
IGRint		    *num_comps,
IGRboolean	    *extended)
{
  struct EMSintobj 	*this = NULL, *first = NULL, *second = NULL;
  struct IntobjInfo 	*firstinfo = NULL, *secondinfo = NULL;
  IGRlong 		loc_msg=EMS_S_Success, ret=EMS_S_Success;
  struct IGRbsp_curve 	*cv = NULL, *new_geom = NULL, *thiscv = NULL;
  IGRboolean 		self_int=FALSE, ok=TRUE, bounded=FALSE, coincide=FALSE,
                        approach=FALSE; 
  IGRdouble 		tgts[6];
  GRrange 		range; 
  IGRdouble 		pars[2]; 
  IGRint                n_pars=0;
  IGRdouble 		mat_vecs[6], cvpts[6], diag=0;
  BSrc			rc=BSSUCC;
  
  *msg = EMS_S_Success;
  *extended = FALSE;
    
  first  = cc_intobjs[0];
  second = cc_intobjs[1];
  
  firstinfo  = (struct IntobjInfo *)first->more_info;
  secondinfo = (struct IntobjInfo *)second->more_info;  
  
  add$status( test = !firstinfo->convex && !secondinfo->convex, msg = *msg, 
      code = EMS_E_Fail,
      str = "TwoIntobjsExtend : Adjacent concave Intobjs.",
      action = GOTO_VALUE, value = wrapup );
  
  if(firstinfo->convex && secondinfo->convex)
  {
    thiscv = NULL;
    ok = GetCurveFromIntobj(&loc_msg, first, FALSE, FALSE, &thiscv);
    add$status( test = !ok, msg = *msg, code = EMS_E_OMerror,
        str = "TwoIntobjsExtend : GetCurveFromIntobj error",
        action = GOTO_VALUE, value = wrapup );

    (*comp_cvs)[0] = thiscv;

    thiscv = NULL;
    ok = GetCurveFromIntobj(&loc_msg, second, FALSE, FALSE, &thiscv);
    add$status( test = !ok, msg = *msg, code = EMS_E_OMerror,
        str = "TwoIntobjsExtend : GetCurveFromIntobj error",
        action = GOTO_VALUE, value = wrapup );
        
    (*comp_cvs)[1] = thiscv;
    
    (*comp_types)[0] = first->curve_type;
    (*comp_types)[1] = second->curve_type;    
    
    *num_comps = 2;
    goto wrapup;
  }
  
  if(firstinfo->convex)
    this = first;
  else
    this = second;

  thiscv = NULL;
  ok = GetCurveFromIntobj(&loc_msg, this, FALSE, FALSE, &thiscv);
  add$status( test = !ok, msg = *msg, code = EMS_E_OMerror,
      str = "TwoIntobjsExtend : GetCurveFromIntobj error",
      action = GOTO_VALUE, value = wrapup );

  cv = thiscv;
   
  ok = IsProfileUnbounded(&loc_msg, NULL,  env_cvs, &cv, tgts, &bounded, &coincide);
  add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
      str = "TwoIntobjsExtend : IsProfileUnbounded error",
      action = GOTO_VALUE, value = wrapup );

  ok = GetSurfaceRtreeRange (sl->objid, sl->osnum, envsl, range);
  add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
              str = "TwoIntobjExtend : GetSurfaceRtreeRange error", 
              action = GOTO_VALUE, value = wrapup );
 
  diag = BSdistptpt(&rc, &range[0], &range[3]);        
  add$status( test = rc != BSSUCC, msg = *msg, code = EMS_E_Fail,
      str = "TwoIntobjsExtend : BSdistptpt error",
      action = GOTO_VALUE, value = wrapup );
  
  // for !bounded (converging or diverging)  BUT WE TAKE IT DIVERGING
  
  approach = TRUE;

  pars[0] = 0.0; pars[1] = 1.0; n_pars = 2;   
  
  if(coincide)
  {
    ok = MatVecs(&loc_msg, NORMAL, (struct GRid *)NULL, env_cvs, &cv, (IGRboolean)FALSE, pars, 
                 n_pars, mat_vecs, cvpts);        
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "TwoIntobjsExtend : MatVecs error",
        action = GOTO_VALUE, value = wrapup );
    
    ok = MatVecsApproach(&loc_msg, cvpts, mat_vecs, &approach);
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "TwoIntobjsExtend : MatVecsApproach error",
        action = GOTO_VALUE, value = wrapup );
  }
  
  if(approach)
  {
    (*comp_types)[0] = this->curve_type;
    
    ret = ExtendEndCurves(&loc_msg, &cv, FALSE, FALSE, *comp_types, 1, TRUE, NULL, 
    			  NULL, range, sl, envsl, &self_int, &new_geom);
    add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "TwoIntobjsExtend : ExtendEndCurves error",
        action = GOTO_VALUE, value = wrapup );

    (*comp_cvs)[0] = cv;
    (*comp_cvs)[1] = (self_int ? NULL : new_geom);
    
    (*comp_types)[0] = ((this->curve_type == EMlinesegment) ? EMlinesegment : EMfreeform_curve);
    (*comp_types)[1] = (self_int ? EMfreeform_curve : EMlinesegment);

    *num_comps = (self_int ? 1 : 2);          
  }
  else
  {
    ok = MatVecs(&loc_msg, NORMAL, (struct GRid *) NULL, env_cvs, &cv, (IGRboolean)FALSE, 
                            pars, n_pars, mat_vecs, cvpts);        
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "TwoIntobjsExtend : MatVecs error",
        action = GOTO_VALUE, value = wrapup );

    ret = ExtendEndCurves(&loc_msg, &cv, FALSE, FALSE, NULL, 1, FALSE, NULL, mat_vecs, 
		         range, sl, envsl, &self_int, NULL);
    add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "TwoIntobjsExtend : ExtendEndCurves error",
        action = GOTO_VALUE, value = wrapup );
    
    if(self_int)
    {
      *num_comps = 1;
      (*comp_cvs)[0] = cv;
      (*comp_types)[0] = EMfreeform_curve;
    }
    else
    {
      ok = MatVecs(&loc_msg, NORMAL, (struct GRid *)NULL, env_cvs, &cv, (IGRboolean)FALSE, 
                   pars, n_pars, mat_vecs, cvpts);        
      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "TwoIntobjsExtend : MatVecs error",
          action = GOTO_VALUE, value = wrapup );

      EM3dbxinc(range, diag);      

      ret = ExtendEndCurves(&loc_msg, &cv, FALSE, FALSE, NULL, 1, TRUE, NULL, mat_vecs, 
  		           range, sl, envsl, &self_int, &new_geom);
      add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
          str = "TwoIntobjsExtend : ExtendEndCurves error",
          action = GOTO_VALUE, value = wrapup );
    
      (*comp_cvs)[0] = cv;
      (*comp_cvs)[1] = (self_int ? NULL : new_geom);
      *num_comps = (self_int ? 1 : 2);          

      (*comp_types)[0] = EMfreeform_curve;      
      (*comp_types)[1] = (self_int ? EMfreeform_curve : EMlinesegment);      
      
    }  // if not self intersecting
  }  // if not approaching
  
  *extended = TRUE;
  
wrapup:

  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
 * GetCurveFromIntobj()
 */

IGRboolean GetCurveFromIntobj(
IGRlong			*msg,
struct EMSintobj	*intobj,
IGRboolean		uv,
IGRboolean		WantReversed,
struct IGRbsp_curve	**curve)
{
  struct EMSdataselect	*data = NULL;
  struct IGRbsp_curve	*cvptr = NULL;
  IGRboolean	       	ok=TRUE;
  IGRlong		loc_msg=EMS_S_Success;
  BSrc			rc=BSSUCC;
  
  *msg = EMS_S_Success;
  
  data = (uv ? &(intobj->this_uvintobj) : &(intobj->this_xyzintobj));
  
  if((data->datatype == EMSdata_poly2d) || (data->datatype == EMSdata_poly3d))
  {
    ok = ConvertPolyToCurve(&loc_msg, data->data.poly, (uv ? TRUE : FALSE), curve);
    add$status( test = !ok, msg = *msg, code = EMS_E_OMerror,
          str = "GetCurveFromIntobj : ConvertPolyToCurve error",
          action = GOTO_VALUE, value = wrapup );
      
  }
  else 
  {
    cvptr = data->data.curve;
      
    (void) BSalloccv(cvptr->order, cvptr->num_poles, cvptr->rational, 
                     cvptr->num_boundaries, curve, &rc);
    add$status( test = rc != BSSUCC, msg = *msg, code = EMS_E_BSerror,
          str = "GetCurveFromIntobj : BSalloccv error",
          action = GOTO_VALUE, value = wrapup );
      
    ok = BScv_copy(&rc, cvptr, *curve);
    add$status( test = (!ok || rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
          str = "GetCurveFromIntobj : BScv_copy error",
          action = GOTO_VALUE, value = wrapup );
  }

  if(WantReversed)
  {
    if(intobj->reversed) 
    {
      ok = BSrev_cv(&rc, *curve);
      add$status( test = (!ok || rc != BSSUCC), msg = *msg,code = EMS_E_BSerror,
          str = "GetCurveFromIntobj : BSrev_cv error",
          action = GOTO_VALUE, value = wrapup );
      EMerr_hndlr((!ok || rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);
    }
  }

wrapup:

  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
 * Function IgnoreConcaveIntobjs() 
 */

// WHAT ABOUT intobjs reversed ?

#define IGNORE	1
#define ARBIT   99
  			    
IGRboolean IgnoreConcaveIntobjs(
IGRlong	            *msg,
IGRvector	    NORMAL,
struct GRmd_env	    *env_cvs,
struct EMSintobj    **cc_intobjs, //Don't follow the next chain run a FOR LOOP
IGRint		    numcc_intobjs,
struct GRid	    *sl,
struct GRmd_env	    *envsl,
struct IGRbsp_curve ***comp_cvs,
IGRuchar	    **comp_types,
IGRint		    *num_comps,
IGRboolean	    *extended)
{
  IGRint 		i=0, iloc=0;
  struct EMSintobj 	*cur = NULL;
  struct IntobjInfo 	*info = NULL;
  IGRlong 		loc_msg=EMS_S_Success, ret=EMS_S_Success;
  struct IGRbsp_curve 	*ext_cvs[2], *new_geom = NULL, **tmp_cvs = NULL, *thiscv = NULL;
  IGRboolean 		self_int=FALSE, ok=TRUE, allcvx=FALSE, 
                        check_from=FALSE, check_to=FALSE;
  IGRint		*info_array = NULL, *ext_from = NULL, *ext_to = NULL,
     			num_ext=0;
  IGRuchar		*loc_types = NULL, types[2];
        
  *msg = EMS_S_Success;
  *num_comps = 0;
  *extended = FALSE;
  
  (*comp_cvs)=(struct IGRbsp_curve **) om$malloc(size = 2*numcc_intobjs*sizeof(struct IGRbsp_curve *));

  (*comp_types) = (IGRuchar *) om$malloc(size = 2*numcc_intobjs*sizeof(IGRuchar));  
  
  for(i = 0; i < 2*numcc_intobjs; i++)
    (*comp_cvs)[i] = NULL;
  
  if(numcc_intobjs == 2)
  {
     ok = TwoIntobjsExtend(msg, NORMAL, env_cvs, cc_intobjs, 
     			   sl, envsl, comp_cvs, comp_types, num_comps, extended);
     add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
         str = "IgnoreConcaveIntobjs : TwoIntobjsExtend error",
         action = GOTO_VALUE, value = wrapup );
  }
  else
  {
    info_array = (IGRint *) alloca(numcc_intobjs * sizeof(IGRint));
  
    tmp_cvs = (struct IGRbsp_curve **) alloca(2*numcc_intobjs*sizeof(struct IGRbsp_curve *));
    loc_types = (IGRuchar *) alloca(2*numcc_intobjs*sizeof(IGRuchar));    
    
    for(i = 0; i < 2*numcc_intobjs; i++) {
      tmp_cvs[i] = NULL;
      loc_types[i] = ARBIT;
    }
      
    for(i = 0; i < numcc_intobjs; i++)
    {
      cur = cc_intobjs[i];
      info = (struct IntobjInfo *) cur->more_info;
      
      if(info->convex)
        info_array[i] = 1;
      else
        info_array[i] = 0;

    } //running to get the convex, concave info

    ok = IgnoreExtendInfo(info_array, numcc_intobjs, &ext_from, &ext_to,
    			  &num_ext, &allcvx);
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "IgnoreConcaveIntobjs : IgnoreExtendInfo error",
        action = GOTO_VALUE, value = wrapup );
    
    if(allcvx)
    {
      for(i = 0; i < numcc_intobjs; i++) {

        thiscv = NULL;
        ok = GetCurveFromIntobj(&loc_msg, cc_intobjs[i], FALSE, FALSE, &thiscv);
        add$status( test = !ok, msg = *msg, code = EMS_E_OMerror,
            str = "IgnoreConcaveIntobjs : GetCurveFromIntobj error",
            action = GOTO_VALUE, value = wrapup );

      	(*comp_cvs)[i] = thiscv;
        (*comp_types)[i] = cc_intobjs[i]->curve_type;

      }
    
      *num_comps = numcc_intobjs;
      goto wrapup;

    } //if allcvx
      
    for(i = 0; i < numcc_intobjs; i++)
    {
      cur = cc_intobjs[i];
      info = (struct IntobjInfo *) cur->more_info;
      if(info->convex)
      {
        thiscv = NULL;
        ok = GetCurveFromIntobj(&loc_msg, cc_intobjs[i], FALSE, TRUE, &thiscv);
        add$status( test = !ok, msg = *msg, code = EMS_E_OMerror,
            str = "IgnoreConcaveIntobjs : GetCurveFromIntobj error",
            action = GOTO_VALUE, value = wrapup );
  
        tmp_cvs[2*i] = thiscv;
        loc_types[2*i] = cc_intobjs[i]->curve_type;
      }
    } //running to get the curves
    
    for(i = 0; i < num_ext; i++)
    {
      ext_cvs[0] = tmp_cvs[2*ext_from[i]];
      ext_cvs[1] = tmp_cvs[2*ext_to[i]];

      types[0] = loc_types[2*ext_from[i]];
      types[1] = loc_types[2*ext_to[i]];
            
      self_int = TRUE; //Want to know if the geoms self_intersect after closing
      
      check_from = FALSE; check_to = FALSE;
      
      for(iloc = 0; iloc < i; iloc++)
      {
        if(ext_from[i] == ext_to[iloc])
          check_from = TRUE;
          
        if(ext_to[i] == ext_from[iloc])
          check_from = TRUE;          
      }
        
      new_geom = NULL; 
      ret = ExtendEndCurves(&loc_msg, ext_cvs, check_from, check_to, types, (IGRint)2,
      			    TRUE, NULL, NULL, NULL, sl, envsl, &self_int, &new_geom);
      add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_OMerror,
          str = "IgnoreConcaveIntobjs : ExtendEndCurves error",
          action = GOTO_VALUE, value = wrapup );
      
      tmp_cvs[2*ext_from[i]] = ext_cvs[0];
      tmp_cvs[2*ext_to[i]] = ext_cvs[1];

      loc_types[2*ext_from[i]] = ((types[0] == EMlinesegment) ? EMlinesegment : EMfreeform_curve);
      loc_types[2*ext_to[i]] = ((types[1] == EMlinesegment) ? EMlinesegment : EMfreeform_curve);;
      
      if(!self_int && new_geom) {

        tmp_cvs[2*ext_from[i]+1] = new_geom;
        loc_types[2*ext_from[i]+1] = EMlinesegment;
        
      }

    } // for all the extensions
    
    *num_comps = 0;

    for(i = 0; i < 2*numcc_intobjs; i ++)
    {
      if(tmp_cvs[i]) {
        
        (*comp_cvs)[*num_comps] = tmp_cvs[i];
        (*comp_types)[*num_comps] = loc_types[i];        
        
        (*num_comps)++;
      }
    }
    
  } //if the number is > 2

  *extended = TRUE;

wrapup:

  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

#define CONVEX	1
#define CONCAVE 0

/*
 * Function IgnoreExtendInfo()
 */

IGRboolean IgnoreExtendInfo(
IGRint			*info_array,
IGRint			num_info,
IGRint			**ext_from,
IGRint			**ext_to,
IGRint			*num_ext,
IGRboolean		*allcvx)
{
  IGRint	i=0, AllCVX=0, AllCNC=0;
  IGRint	*tmp_array = NULL, num_tmp_array = 0;
  
  tmp_array = (IGRint *) alloca(num_info * sizeof(IGRint));
  
  AllCVX = CONVEX;
  AllCNC = CONCAVE;
  
  num_tmp_array = 0;
  
  for(i = 0; i < num_info; i++) {
   
   AllCVX *= info_array[i];
   AllCNC |= info_array[i];
   
   if(info_array[i]) {
     
     tmp_array[num_tmp_array] = i;
     num_tmp_array++;
   }
  }

  if(AllCVX == CONVEX) {
    *allcvx = TRUE;
    return TRUE;
  }
  else
    *allcvx = FALSE;
  
  if(AllCNC == CONCAVE) 
    return FALSE;

  *ext_from = (IGRint *) om$malloc(size = num_tmp_array * sizeof(IGRint));
  *ext_to = (IGRint *) om$malloc(size = num_tmp_array * sizeof(IGRint));  
  
  *num_ext = 0;
    
  for(i = 0; i < num_tmp_array; i++)
  {
    if( ((i+1) % num_tmp_array) == 0)
    {
      if( (tmp_array[i]-tmp_array[0]) <  (num_info -1))
      {
        (*ext_from)[*num_ext] = tmp_array[i];
        (*ext_to)[*num_ext] = tmp_array[0];      
        *num_ext += 1;
      }
    }
    else
    {
      if(tmp_array[i+1] > (tmp_array[i] + 1))
      {
        (*ext_from)[*num_ext] = tmp_array[i];
        (*ext_to)[*num_ext] = tmp_array[i+1];      
        *num_ext += 1;
      }
    }
  }

  return TRUE;  

}
/*
 * Function TraceIntobjs()
 */


IGRboolean TraceIntobjs(
IGRlong		 *msg,
struct GRmd_env  *env,
struct EMSinters **inters,
struct EMSintobj ***cc_intobjs,
IGRint		 *numcc_intobjs)
{
  IGRint                i=0, j=0, num_elems=0;
  IGRlong               loc_msg=EMS_S_Success, ret=EMS_S_Success;
  struct EMSsftracedata trace;
  IGRboolean            sfinttrace_alloced = FALSE, gotit = FALSE;
  struct EMSintobj      *tmp_intobj = NULL, *start_intobj = NULL;
  IGRushort		inters_opts=0;

  void		EMsfinttrace_free();
  IGRlong	EMintersect_surfaces();
    
  *msg = EMS_S_Success;
  *cc_intobjs = NULL;
  *numcc_intobjs = 0;
  memset(&trace, 0, sizeof(struct EMSsftracedata));
  
  inters_opts = EMS_SFINT_SKIPSFINT | EMS_SFINT_SKIPFIXING;

  tmp_intobj = (*inters)->cvs;

   while(tmp_intobj) {

     tmp_intobj->fwd = NULL;  tmp_intobj->bwd = NULL;
     tmp_intobj->props |= EMSintobj_nontriminfo;
          
     tmp_intobj = tmp_intobj->next;
   }
                     
  trace.num_grps = 0;
  ret = EMintersect_surfaces(&loc_msg, NULL, &env->md_env, 0, NULL, NULL,
                             inters_opts, NULL, NULL, NULL, NULL,
                             NULL, inters, NULL,  &trace, NULL,
                             NULL, NULL, NULL);
  add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "TraceIntobjs : EMintersect_surfaces error",
      action = GOTO_VALUE, value = wrapup );
  sfinttrace_alloced = TRUE;
  
  for(i = 0; i < trace.num_grps; i++) {
    if(trace.grp_closed[i]) {
      for(j = 0; j < trace.num_subgrps_grp[i]; j++) {
        if(trace.subgrp_closed[i][j]) {
          start_intobj = tmp_intobj = trace.elems[i][j];
          while(tmp_intobj) {
            if(tmp_intobj->props & EMSintobj_marked) {
              gotit = TRUE;
	      goto gotit;
            }
            tmp_intobj = tmp_intobj->next;
          }
        }
      }
    }
  }
  
gotit:

  if(gotit) {
    
    num_elems = trace.num_elems_subgrp[i][j];    
    (*cc_intobjs) = (struct EMSintobj **) om$malloc(size = num_elems * sizeof(struct EMSintobj *));
    tmp_intobj = start_intobj;
    for(num_elems = 0; num_elems < trace.num_elems_subgrp[i][j]; num_elems++) {
      
      (*cc_intobjs)[num_elems] = tmp_intobj;
      tmp_intobj = tmp_intobj->next;
    }
    *numcc_intobjs = trace.num_elems_subgrp[i][j];
  }

wrapup:

  if(sfinttrace_alloced) {
    EMsfinttrace_free (&loc_msg, 
		       trace.num_grps,
                       trace.num_subgrps_grp,
                       trace.num_elems_subgrp,
                       trace.elems,
                       trace.subgrp_rev,
                       trace.elem_rev,
                       trace.grp_closed,
                       trace.subgrp_closed);
    if(!(1&loc_msg)) *msg = EMS_E_Fail;
  }

  
  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
 * Funcion ConvertPolyToCurve
 */

IGRboolean ConvertPolyToCurve(
IGRlong			*msg,
struct IGRpolyline	*poly,
IGRboolean		twoD,
struct IGRbsp_curve 	**curve)
{
  BSrc			rc=BSSUCC;
  IGRdouble 		delta=0, dist_tolsq=0, dist=0;
  IGRint		i=0;
  struct IGRbsp_curve	*loc_curve = NULL;
  
  *msg = EMS_S_Success;
  
  (void) BSalloccv((IGRshort)2, poly->num_points, (IGRshort)0, (IGRshort)0, 
                   &loc_curve, &rc);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "ConvertPolyToCurve : BSalloccv error",
      action = GOTO_VALUE, value = wrapup );
  
  loc_curve->num_poles   = poly->num_points;
  loc_curve->order       = 2;
  loc_curve->num_knots   = poly->num_points + 2;
  loc_curve->periodic    = (IGRboolean) FALSE;
  loc_curve->non_uniform = (IGRboolean) FALSE;
  loc_curve->rational    = (IGRboolean) FALSE;

  loc_curve->num_boundaries = (IGRshort) 0;
  loc_curve->bdrys = (IGRdouble *) NULL;

  
  delta = 1.0/(poly->num_points-1);
  
  loc_curve->num_knots = poly->num_points+2;
    
  for(i = 0; i < poly->num_points; i++)
  {
    loc_curve->poles[3*i] = poly->points[ twoD ? 2*i : 3*i];
    loc_curve->poles[3*i+1] = poly->points[twoD ? (2*i+1) : (3*i+1)];    
    loc_curve->poles[3*i+2] = (twoD ? 0.0 : poly->points[3*i+2]);
  }

  for(i=0; i<2; i++)
     loc_curve->knots[i] = 0.0;
  for(i=2; i<poly->num_points; i++)
     loc_curve->knots[i] =  loc_curve->knots[i-1] + delta;
  for(i=poly->num_points; i<poly->num_points+2; i++)
     loc_curve->knots[i] = 1.0;

  BSEXTRACTPAR(&rc, BSTOLSQLENVEC, dist_tolsq);
  
  dist = BSdistptpts(&rc, poly->points, 
  		     &poly->points[twoD ? 2*(poly->num_points-1) : 3*(poly->num_points-1)] );
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "ConvertPolyToCurve : BSdistptpts error",
      action = GOTO_VALUE, value = wrapup );
  
  if(dist <  dist_tolsq)
    loc_curve->phy_closed = TRUE;
  else
    loc_curve->phy_closed = FALSE;

  if( loc_curve->num_poles > 3 )
     BStst_plan( (IGRint) loc_curve->num_poles, loc_curve->poles,
                 (IGRdouble *)NULL, &loc_curve->planar, &rc);
  else
     loc_curve->planar = (IGRboolean) TRUE;
    
wrapup:
  if(!(1&*msg))
    return FALSE;
  else {
    *curve = loc_curve;
    return TRUE;  
  }
}


/*
 * Function IsProfileUnbounded()
 */

IGRboolean IsProfileUnbounded(
IGRlong		    *msg,
struct GRid	    *prof_grid,
struct GRmd_env	    *env,
struct IGRbsp_curve **cc,	//cc is used if supplied, else malloced,returned (merged if composite)
IGRdouble	    *end_tangents,  // 6 doubles
IGRboolean          *bounded,
IGRboolean	    *coincide)
{
  IGRlong 	      loc_msg=EMS_S_Success;
  struct IGRbsp_curve *cv = NULL;
  BSrc		      rc=BSSUCC;
  IGRdouble	      par[2], pts[2][2][3], dotp=0, TOLLENVEC=0, tmp[3];
  IGRboolean	      alloced = FALSE;  
   
  IGRint	      sts=OM_S_SUCCESS, EMgetvggeom();
  
  *msg = EMS_S_Success;
  *bounded = TRUE;
  *coincide = FALSE;  
  
  if(*cc)
    cv = *cc;
  else
  {
    sts = EMgetvggeom(&loc_msg, &env->md_env.matrix_type, env->md_env.matrix,
                      prof_grid, (IGRchar **)&cv, NULL);
    add$status( test = !(1&loc_msg&sts), msg = *msg, code = EMS_E_Fail,
        str = "IsProfileUnbounded : EMgetvggeom error",
        action = GOTO_VALUE, value = wrapup );
    alloced = TRUE;
    *cc = cv;
  }

  par[0] = 0.0; par[1] = 1.0;
  
  BScvarreval(&rc, cv, par, 2, 1, (IGRdouble *)&pts[0]);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "IsProfileUnbounded : BScvarreval error",
      action = GOTO_VALUE, value = wrapup );

  pts[0][1][0] *= -1.0; pts[0][1][1] *= -1.0; pts[0][1][2] *= -1.0;
  tmp[0] = pts[0][1][0]; tmp[1] = pts[0][1][1]; tmp[2] = pts[0][1][2];
  
  BSnorvec(&rc, tmp);
  end_tangents[0] = tmp[0]; end_tangents[1] = tmp[1]; end_tangents[2] = tmp[2];   

  tmp[0] = pts[1][1][0]; tmp[1] = pts[1][1][1]; tmp[2] = pts[1][1][2];
  BSnorvec(&rc, tmp);  
  end_tangents[3] = tmp[0]; end_tangents[4] = tmp[1]; end_tangents[5] = tmp[2];   
  
  BSEXTRACTPAR(&rc, BSTOLLENVEC, TOLLENVEC);
  dotp = BSdotp(&rc, &end_tangents[0], &end_tangents[3]);  
  
  if(dotp <  -(1.0-TOLLENVEC))
    *bounded = FALSE;
  else
  {
    *bounded = TRUE;

    if(dotp > (1.0-TOLLENVEC))
       *coincide = TRUE;    
  }

wrapup:

  if(!(1&*msg)) {

    if(alloced) 
      if(cv) { om$dealloc(ptr = cv); cv = NULL; *cc = NULL; }

    return FALSE;
  }
  else
    return TRUE;  
}		
	
/*
 * Function ProjVecOpposing()
 * 
 * For co-planar case, checks if the projection vector is 
 * opposing the pos-orieted normal or not
 */

IGRboolean ProjVecOpposing(
IGRlong		      *msg,
IGRvector	      proj,
struct IGRbsp_surface *cop_surf,
IGRboolean	      *oppose)
{
  IGRdouble u = UV_SAMPLE_POINT, v = UV_SAMPLE_POINT, dotp=0, cht=0;
  IGRpoint  sf_point;
  IGRvector sf_normal;  
  BSrc      rc=BSSUCC;
  IGRvector uproj;
  
  *msg = EMS_S_Success;
  *oppose = TRUE;
  
  BSsfarrevn(&rc, cop_surf, (IGRint)1, &u, (IGRint )1, &v, sf_point, sf_normal);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "ProjVecOpposing : BSsfarrevn error",
      action = GOTO_VALUE, value = wrapup );

  if(!cop_surf->pos_orient)
  { sf_normal[0] *= -1.0; sf_normal[1] *= -1.0; sf_normal[2] *= -1.0; }
  BSnorvec(&rc, sf_normal);
  
  uproj[0] = proj[0]; uproj[1] = proj[1]; uproj[2] = proj[2];
  BSnorvec(&rc, uproj);  
  
  dotp = BSdotp(&rc, uproj, sf_normal);  
  BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht); 
  
  if(dotp > cht)
    *oppose = TRUE;
  else
    *oppose = FALSE;
  
wrapup:

  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

/*
 * Function MatVecsApproach() is called only when the
 * end tangents are coinciding
 */

IGRboolean MatVecsApproach(
IGRlong		*msg,
IGRdouble	*cvpts,		// start and end point
IGRdouble	*matvecs,	//Matvecs at these points
IGRboolean      *approach)
{
  IGRvector	start_end;
  IGRdouble	dotp=0, TOLLENVEC=0;
  BSrc		rc=BSSUCC;
  
  *msg = EMS_S_Success;
  *approach = TRUE;
    
  start_end[0] = cvpts[3] - cvpts[0];
  start_end[1] = cvpts[4] - cvpts[1];
  start_end[2] = cvpts[5] - cvpts[2];    
  
  BSnorvec(&rc, start_end);
  
  dotp = BSdotp(&rc, start_end, matvecs);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "MatVecsApproach : BSdotp error",
      action = GOTO_VALUE, value = wrapup );

  BSEXTRACTPAR(&rc, BSTOLLENVEC, TOLLENVEC);  
  
  if(dotp > TOLLENVEC)
    *approach = TRUE;
  else
    *approach = FALSE;
  
wrapup:

  if(!(1&*msg))
    return FALSE;
  else
    return FALSE;    
}

/*
 * Gives the unit mat vectors at ends
 */

IGRboolean MatVecs(
IGRlong		      *msg,
IGRvector	      NORMAL,
struct GRid	      *prof,
struct GRmd_env	      *env,
struct IGRbsp_curve   **profcv,
IGRboolean	      reversed,
IGRdouble	      *pars,
IGRint		      num_pars,
IGRdouble	      *matvecs,
IGRdouble             *cvpts)
{
  IGRint 		sts=OM_S_SUCCESS, i=0, j=0;
  IGRlong 		loc_msg=EMS_S_Success;
  struct IGRbsp_curve 	*curve = NULL;
  IGRboolean 		bssts, alloced = FALSE;
  BSrc			rc=BSSUCC;
  IGRdouble		pts[6];
  IGRvector             tangent, mat_vec;

  IGRint		EMgetvggeom();
  
  *msg = EMS_S_Success;
  
  if(*profcv)
    curve = *profcv;
  else
  {
    sts = EMgetvggeom(&loc_msg, &env->md_env.matrix_type, env->md_env.matrix,
                      prof, (IGRchar **)&curve, NULL);
    add$status( test = !(1&loc_msg&sts), msg = *msg, code = EMS_E_Fail,
        str = "MatVecs : EMgetvggeom error",
        action = GOTO_VALUE, value = wrapup );
    *profcv = curve;
    alloced = TRUE;
  }
  
  for(i = 0; i < num_pars; i++) {

    BScvarreval(&rc, curve, &pars[i], 1, 1, (IGRdouble *)pts);
    add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
        str = "MatVecs : BScvarreval error",
        action = GOTO_VALUE, value = wrapup );
    
    cvpts[3*i]     = pts[0];
    cvpts[(3*i)+1] = pts[1]; 
    cvpts[(3*i)+2]   = pts[2];
    
    for(j = 0; j < 3; j++)
      tangent[j] = pts[3+j] * (reversed ? -1.0 : 1.0);
    
    BSnorvec(&rc, tangent);
  
    bssts = BScrossp(&rc, tangent, NORMAL,  mat_vec);
    add$status( test = !bssts || (rc != BSSUCC),msg = *msg,code = EMS_E_BSerror,
        str = "MatVecs : BScrossp error",
        action = GOTO_VALUE, value = wrapup );

    BSnorvec(&rc, mat_vec);

    matvecs[(3*i)] = mat_vec[0]; 
    matvecs[(3*i)+1] = mat_vec[1]; 
    matvecs[(3*i)+2] = mat_vec[2];
  }
  
wrapup:

  if(!(1&*msg)) {

    if(alloced)
      if(curve) { om$dealloc(ptr = curve); curve = NULL; *profcv = NULL; }    
      
    return FALSE;
  }
  else
    return TRUE;
}

/*
 * 
 */

#define NonCoplanar 0
#define CoplanarP   1
#define CoplanarC   2

/*
 * Function ProcessCoplanar() 
 */


IGRboolean ProcessCoplanar(
IGRlong			*msg,
IGRvector		NORMAL,
IGRdouble		*ENDS,
struct GRvg_construct   *const_args,
struct GRid     	*prof,
IGRboolean		reversed,
struct GRmd_env 	*envcv,
struct GRid	 	*sl,
struct GRmd_env 	*envsl,
struct GRid		*the_plane,
struct IGRbsp_surface 	*plane,
struct EMSpartolbasis   *ptolb,
struct GRid		*the_ploop,
IGRboolean		*self_int,
struct GRid		*newprof,
IGRboolean		*extended)
{
  IGRlong 		loc_msg=EMS_S_Success, ret=EMS_S_Success, 
                        tot_num_poles=0;
  IGRdouble     	u_val=0, v_val=0, startpt[3], endpt[3], uv[2];
  BSrc			rc=BSSUCC;
  IGRvector     	sf_normal;
  IGRpoint		sf_point;
  IGRdouble		refplane_dot_solidplane=0, cht=0; 
  struct GRid		copy_profid;
  GRobjid		tmp_md_id=NULL_OBJID;
  IGRlong 		ext_opts = EMS_EXT_LINEAR | EMS_EXT_TO_BOUNDING_BOX;
  IGRboolean 		self_intersection = FALSE, is_convex=FALSE, ok=TRUE, 
                        cutAB=FALSE, nomark=FALSE, endsONmarked=FALSE, 
                        intersMerged = FALSE, revEdges = FALSE, 
                        all_int_ignored=FALSE, found=FALSE;
  GRrange               sfrange;
  struct EMSinters     	*intersA = NULL, *intersB = NULL, *inters = NULL;
  struct EMSintobj      *start_intobj = NULL, *this_intobj = NULL, 
  			**cctrace_intobjs = NULL, *intobjptr = NULL;
  struct IGRbsp_curve   **chosen_comps = NULL, **alt_comps = NULL, **comp_cvs = NULL;
  IGRuchar		*cvtypes = NULL, *ignoretypes = NULL, *chosentypes = NULL;
  IGRint                num_edges_alloc = 0, num_edges = 0, sts=OM_S_SUCCESS; 
  struct GRid           *edges = NULL;
  IGRint 	        edindex = 0, numcc_intobjs = 0, num_comps = 0, num_chosen = 0, i=0;
  IGRuchar 		type=0;
  struct IntobjInfo 	*edge_info = NULL;

  void			EMsfintedpar_free();
  IGRlong		EFextend_curve_by_option(), EFget_edge_info();
  void			EMmergeinters(), EMinters_data_free(), EMinters_free();
  struct EMSintobj*	EFmkint_from_edge();	

  		  
  *msg = EMS_S_Success;
  *extended = FALSE;
  
  newprof->objid = NULL_OBJID;
  BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 
  u_val = v_val = UV_SAMPLE_POINT;
  
  BSsfarrevn(&rc, plane, (IGRint)1, &u_val, (IGRint )1, &v_val, sf_point, sf_normal);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "ProcessCoplanar : BSsfarrevn error",
      action = GOTO_VALUE, value = wrapup );
		
  BSnorvec(&rc, sf_normal);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : BSnorvec error",
      action = GOTO_VALUE, value = wrapup );
		
  refplane_dot_solidplane = BSdotp(&rc, NORMAL, sf_normal);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : BSdotp error",
      action = GOTO_VALUE, value = wrapup );
    
  copy_profid.osnum = envcv->md_id.osnum;
  tmp_md_id = const_args->env_info->md_id.objid;
  const_args->env_info->md_id.objid = NULL_OBJID;

  tot_num_poles = plane->u_num_poles * plane->v_num_poles;		

  BSbx2(&rc, &tot_num_poles, (IGRpoint *)plane->poles,
        (plane->rational ? plane->weights : NULL), sfrange, &sfrange[3]);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : BSbx2 error",
      action = GOTO_VALUE, value = wrapup );

/* !!! REDUCE "diag" TO SOME VALUE MULTIPLE OF PARTOL OF SURFACE, A 
       BIGGER VALUE LIKE "diag" IS CAUSING THE PROFILES TO SELF-INTERSECT
       WE ARE BUMPING UP THE RANGE SO THAT THE MAPPING WILL GO THRU FINE

  diag = BSdistptpt(&rc, &sfrange[0], &sfrange[3]);       
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : BSdistptpt error",
      action = GOTO_VALUE, value = wrapup );
     
  EM3dbxinc(sfrange, diag/2.0);         
*/
		
  ret = EFextend_curve_by_option(&loc_msg, prof, envcv, ext_opts, FALSE,
    		 		 NULL, NULL, sfrange, NULL, envsl, 
    		 	         &self_intersection, const_args, &copy_profid);
    		
  const_args->env_info->md_id.objid = tmp_md_id;
  add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : EFextend_curve_by_option error",
      action = GOTO_VALUE, value = wrapup );
                
  if(refplane_dot_solidplane * (reversed  ? -1.0 : 1.0) < cht)
  {

/* Instead of reversing the profile components, reverse the intobjs
   of the edges at the time of extraction

    sts = om$send(msg = message GRcurve.GRrevparm(&loc_msg, envcv),
		  		senderid = copy_profid.objid,
		  		targetid = copy_profid.objid,
		  		targetos = copy_profid.osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : GRcurve.GRrevparm error",
        action = GOTO_VALUE, value = wrapup );
*/
    revEdges = TRUE;
  }

  if(self_intersection)
  {
    IGRboolean onsurf;
        
    ret = FixSelfIntersectingEndObjects(&loc_msg, &copy_profid, envcv, const_args);
    add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : FixSelfIntersectingEndObjects error",
        action = GOTO_VALUE, value = wrapup );
    
    sts = om$send(msg = message GRcurve.GRendpts(&loc_msg,
                                &envcv->md_env.matrix_type,
                                envcv->md_env.matrix,
                                startpt, endpt),
                senderid = copy_profid.objid,
                targetid = copy_profid.objid,
                targetos = copy_profid.osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : GRcurve.GRendpts error",
        action = GOTO_VALUE, value = wrapup );
    
    sts = BSprptonsf(&rc, plane, startpt, &uv[0], &uv[1], &onsurf);

    if((rc == BSSUCC) && onsurf)
    {
      struct EMSptloc_info loc_info;
      loc_info.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_BOXCHECK;
              
      sts = om$send(msg = message EMSloop.EMpt_location(&loc_msg, 
    	      			  uv, &loc_info, ptolb),
	            targetid = the_ploop->objid,
	            senderid = the_ploop->objid,
	            targetos = the_ploop->osnum);
      
      if((1&sts&loc_msg) && 
         ((loc_info.location == EMS_L_ONEDGE) || (loc_info.location == EMS_L_ONVRTX) ||
         (loc_info.location == EMS_L_INSIDE)))
      {
        newprof->objid = copy_profid.objid; newprof->osnum = copy_profid.osnum;         
        *self_int = TRUE; goto wrapup; //what about validating material add direction ?
      }
      else
      {
        *msg = EMS_E_Fail; goto wrapup;
      }   
    }
  }
  
  is_convex = TRUE;
		  		
  start_intobj = MapProfileOnPlaneWrapper(&loc_msg, envcv, the_plane, 
  			plane, ptolb, the_ploop, &copy_profid, cht, is_convex, 
			&intersA);
  add$status( test = !(1&loc_msg) , msg = *msg, 
      code = EMS_E_Fail,
      str = "ProcessCoplanar : MapProfileOnPlaneWrapper error",
      action = GOTO_VALUE, value = wrapup );

  sts = om$send(msg = message EMSloop.EMget_edges(&loc_msg, (IGRint)1,
	        	EMS_OPT_ALL, &edges, &num_edges_alloc, &num_edges),
	        senderid = the_ploop->objid,
                targetos = the_ploop->osnum,
                targetid = the_ploop->objid);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : EMSloop.EMget_edges error",
      action = GOTO_VALUE, value = wrapup );
		
  for(edindex = 0; edindex < num_edges; edindex++)
  {
    is_convex = FALSE;
		    
    ret = EFget_edge_info(&loc_msg, &envsl->md_env.matrix_type, envsl->md_env.matrix,
                          edges[edindex], NULL, NULL, NULL, NULL, &is_convex, NULL, 
                          NULL, NULL, NULL, NULL);
    add$status( test = !(1&ret&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : EFget_edge_info error",
        action = GOTO_VALUE, value = wrapup );

    this_intobj = EFmkint_from_edge(&loc_msg, *the_plane, edges[edindex], 
			FALSE, FALSE, revEdges, &envsl->md_env, &intersB);
    add$status( test = !this_intobj || (!(1&loc_msg)), msg = *msg, 
        code = EMS_E_Fail,
        str = "ProcessCoplanar : EFmkint_from_edge error",
        action = GOTO_VALUE, value = wrapup );
				    
    sts = om$send(msg = message EMSedge.EMget_props_type(&loc_msg, NULL, &type),
    		  senderid = edges[edindex].objid,
		  targetid = edges[edindex].objid,
		  targetos = edges[edindex].osnum);
    add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : EMSedge.EMget_props_type error",
        action = GOTO_VALUE, value = wrapup );
		  
    this_intobj->curve_type = type;

    edge_info = (struct IntobjInfo *)om$malloc(size = sizeof(struct IntobjInfo));
    add$status( test = !edge_info, msg = *msg, code = EMS_E_NoDynamicMemory,
        str = "ProcessCoplanar : Insufficient Memory",
        action = GOTO_VALUE, value = wrapup );
		  
    edge_info->creator = edges[edindex].objid;
    edge_info->convex = is_convex;
		  
    this_intobj->more_info = (IGRchar *) edge_info;

  }
 
  intersMerged = FALSE;

  if(intersA)
  {
    ok = IntersectSplitIntobjs(&loc_msg, ptolb->tol, TRUE, intersA, intersB, 
				envcv, &cutAB);
    add$status( test = !ok , msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : IntersectSplitIntobjs error",
        action = GOTO_VALUE, value = wrapup );
  
    if(!cutAB &&  OM_Gf_verbose_warning)
      printf("None of the coplanar edges got split");
    
    if(cutAB)
    {
      ok = UnMarkIntobj(&loc_msg, ENDS, intersA, &nomark, &endsONmarked);
      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : UnMarkIntobj error",
        action = GOTO_VALUE, value = wrapup );
        
        add$status(test = (nomark || !endsONmarked), msg = *msg, 
		   code = EMS_E_Fail, 
                   str = "Before trace, no mark OR original ends not on marked",
                   action = GOTO_VALUE, value = wrapup );
    } // if coplanar edges got split

    inters = intersA;
    while (inters)
    {
      intobjptr = inters->cvs;

      while (intobjptr)
      {
        intobjptr->props &= ~EMSintobj_tmpmarked;
        intobjptr = intobjptr->next;
      }

      inters = inters->next;
    }

    inters = intersB;
    while (inters)
    {
      intobjptr = inters->cvs;

      while (intobjptr)
      {
        intobjptr->props |= EMSintobj_tmpmarked;
        intobjptr = intobjptr->next;
      }

      inters = inters->next;
    }

    EMmergeinters(&loc_msg, &intersA, intersB);
    add$status( test = !(1&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "ProcessCoplanar : EMmergeinters error",
        action = GOTO_VALUE, value = wrapup );
    intersMerged = TRUE;  

  }  // if(intersA)
  else
  {
    inters = intersB;
    while (inters)
    {
      intobjptr = inters->cvs;

      while (intobjptr)
      {
        intobjptr->props |= EMSintobj_tmpmarked;
        intobjptr = intobjptr->next;
      }

      inters = inters->next;
    }

  }
  
  ok = TraceIntobjs(&loc_msg, envcv, (intersA ? &intersA : &intersB), 
		    &cctrace_intobjs, &numcc_intobjs);

  add$status( test = !ok || !(1&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : TraceIntobjs error",
      action = GOTO_VALUE, value = wrapup );

  ok = DeleteObject(&copy_profid.objid, envcv);  

  /*
   * Now, check whether all the intobjs arising out of the P_loop edges
   * need to be ignored because of concavity. If it is so, it is better
   * to go for the general algorithm. So, error out here and go to the
   * general algorithm.
   */ 

  all_int_ignored = TRUE;

  for (i=0; i<numcc_intobjs; i++)
  {
    edge_info = (struct IntobjInfo *) cctrace_intobjs[i]->more_info;

    if (edge_info->convex)
    {
      inters = intersA ? intersA : intersB;
      found = FALSE;

      while (inters)
      {
        intobjptr = inters->cvs;
        while (intobjptr)
        {
          if ((intobjptr->props & EMSintobj_tmpmarked) 
              && cctrace_intobjs[i] == intobjptr)
          {
            found = TRUE;
            break;
          }
          intobjptr = intobjptr->next;
        }
        if (found) break;
        inters = inters->next;
      }

      if (found)
      {
        all_int_ignored = FALSE;
        break;
      } 
    }
  }

  add$status( test = all_int_ignored, msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : Need to go to general algorithm.",
      action = GOTO_VALUE, value = wrapup );

 /*
  * Unset "tmpmarked" bit on all the intobjs.
  */
 inters = intersA ? intersA : intersB;
 while (inters)
 {
   intobjptr = inters->cvs;

   while (intobjptr)
   {
     intobjptr->props &= ~EMSintobj_tmpmarked;
     intobjptr = intobjptr->next;
   }

   inters = inters->next;
 }


/*
  ok = FALSE;
  Commented this code to avoid "Ignoring Concave Intobjs code". This will be
  included later after a second thought - Sanjay
*/
  ok = IgnoreConcaveIntobjs(&loc_msg, NORMAL, envcv, cctrace_intobjs, numcc_intobjs, 
  			    sl, envsl, &comp_cvs, &ignoretypes, &num_comps, extended);

  if(!ok || !(1&loc_msg) || !num_comps)
  {
    IGRint i;
    extern unsigned int OM_Gf_verbose_warning;
    struct IGRbsp_curve *thiscv = NULL;
   
    if( OM_Gf_verbose_warning ) 
      printf("IgnoreConcaveIntobjs failed, still proceeding\n");
    
    alt_comps=(struct IGRbsp_curve **)alloca(numcc_intobjs*sizeof(struct IGRbsp_curve *));
    cvtypes = (IGRuchar *)alloca(numcc_intobjs*sizeof(IGRuchar));
    
    for(i = 0; i < numcc_intobjs; i++) {

      intobjptr = cctrace_intobjs[i];

      thiscv = NULL;
      ok = GetCurveFromIntobj(&loc_msg, intobjptr, FALSE, FALSE, &thiscv);
      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "ProcessCoplanar : GetCurveFromIntobj error",
          action = GOTO_VALUE, value = wrapup );
  
      alt_comps[i] = thiscv;
      cvtypes[i] = intobjptr->curve_type;
    }
    num_chosen = numcc_intobjs;
        
    chosen_comps = alt_comps;
    chosentypes = cvtypes;
  }
  else
  {
    chosen_comps = comp_cvs; 
    num_chosen = num_comps;    
    chosentypes = ignoretypes;
  }
  
  ok = MakeCompFromIntobjs(&loc_msg, chosen_comps, chosentypes, num_chosen, 
  			   const_args, envcv, newprof);
  add$status( test = (!ok || !(1&loc_msg)), msg = *msg, code = EMS_E_Fail,
      str = "ProcessCoplanar : MakeCompFromIntobjs error",
      action = GOTO_VALUE, value = wrapup );


wrapup:

  if(cctrace_intobjs) { om$dealloc(ptr = cctrace_intobjs); cctrace_intobjs = NULL; }

  if(comp_cvs) 
  { 
    for(i = 0; i < num_comps; i++)
    {
      if(comp_cvs[i]) { BSfreecv(&rc, comp_cvs[i]); comp_cvs[i] = NULL; }
    }
    om$dealloc(ptr = comp_cvs); comp_cvs = NULL;
  }

  if(alt_comps)
  {
    for(i = 0; i < numcc_intobjs; i++)
    {
      if(alt_comps[i]) { BSfreecv(&rc, alt_comps[i]); alt_comps[i] = NULL; }
    }
  }
  
  if(ignoretypes) { om$dealloc(ptr = ignoretypes); ignoretypes = NULL; }  
  
  if(intersA)
  {
       EMinters_data_free(&loc_msg, intersA, (IGRint)0, NULL, NULL);
       EMinters_free(intersA, (IGRint)0);
  }     
   
  if(!intersMerged)
  {
    if(intersB)
    {
      EMinters_data_free(&loc_msg, intersB, (IGRint)0, NULL, NULL);
      EMinters_free(intersB, (IGRint)0);
    }
  }      

  if(!(1&*msg)) 
  {
    ok = DeleteObject(&copy_profid.objid, envcv);
    return FALSE;
  }
  else
    return TRUE;  
}

/*
 * Function MakeCompFromIntobjs()
 */ 

IGRboolean MakeCompFromIntobjs(
IGRlong			*msg,
struct IGRbsp_curve	**comps,
IGRuchar		*types,
IGRint			num_comps,
struct GRvg_construct   *const_args,
struct GRmd_env		*env,
struct GRid		*comp)
{
  
  IGRlong 		loc_msg=EMS_S_Success, rotten_one=0;
  OMuint		num = 0;
  IGRboolean		ok=TRUE;
  IGRint		sts=OM_S_SUCCESS;
  GRobjid 		mdid=NULL_OBJID, id=NULL_OBJID;
  struct IGRbsp_curve	*this = NULL;
  struct GRlc_info      *lc_info = NULL;
  
  OMuword		classid;
//struct GRpost_info	post_info;

  IGRlong 		EFget_classid_for_an_edge_type();
  
  *msg = EMS_S_Success;
  comp->objid = NULL_OBJID;
 
  mdid = const_args->env_info->md_id.objid;
  const_args->env_info->md_id.objid = NULL_OBJID;

  lc_info = (struct GRlc_info *) om$malloc(size = num_comps * sizeof(struct GRlc_info));
  add$status( test = !lc_info, msg = *msg, code = EMS_E_NoDynamicMemory,
      str = "MakeCompFromIntobjs : Insufficient Memory",
      action = GOTO_VALUE, value = wrapup );

  
  for(num = 0; num < num_comps; num++)
  {
    this = comps[num];
    
    loc_msg = EFget_classid_for_an_edge_type(&classid, types[num]);
    add$status( test = !(1&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "MakeCompFromIntobjs : EFget_classid_for_an_edge_type error",
        action = GOTO_VALUE, value = wrapup );
    
    const_args->geometry = (IGRchar *) this;

    sts = om$construct(classid = classid,
		       osnum   = env->md_id.osnum,
		       p_objid = &id,
		msg = message GRvg.GRconstruct(const_args));
    add$status( test = !(1&sts&(*(const_args->msg))), msg = *msg, 
        code = EMS_E_Fail,
        str = "MakeCompFromIntobjs : om$construct error",
        action = GOTO_VALUE, value = wrapup );

    const_args->geometry = (IGRchar *)NULL;    
    
    lc_info[num].located_obj.objid = id;
    lc_info[num].located_obj.osnum = env->md_id.osnum;
    
    OM_BLOCK_MOVE(env, &(lc_info[num].module_info), sizeof(struct GRmd_env));
  }

  if(num_comps == 1)
  {
    comp->objid = id;
    comp->osnum = env->md_id.osnum;
    goto wrapup;
  }
  
  sts = om$construct(classid = OPP_GRcompcurve_class_id,
  	 	     osnum   = env->md_id.osnum,
  	 	     p_objid = &comp->objid);
  add$status( test = !(1&sts), msg = *msg, code = EMS_E_Fail,
        str = "MakeCompFromIntobjs : om$construct error",
        action = GOTO_VALUE, value = wrapup );
  
  comp->osnum = env->md_id.osnum;
  sts = om$send(msg = message GRcompcurve.EMmakecomp(&loc_msg,
  			env, (IGRlong) num_comps, lc_info, &rotten_one),
                senderid = comp->objid,
                targetid = comp->objid,
                targetos = comp->osnum);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "MakeCompFromIntobjs : GRcompcurve.EMmakecomp error",
        action = GOTO_VALUE, value = wrapup );

/*

  post_info.construct_flag = FALSE;
  sts = om$send (msg = message GRvg.GRpostabsg(&loc_msg
                         env, &post_info, (IGRchar *)NULL, &junkid),
                 senderid = comp->objid,
                 targetid = comp->objid,
                 targetos = comp->osnum);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "MakeCompFromIntobjs : GRvg.GRpostabsg error",
        action = GOTO_VALUE, value = wrapup );

  if( junkid == comp->objid )
    GRabsg_del_by_objid( &comp->objid, &comp->osnum );


  sts = om$send(msg = message GRvg.GRgeomprops(&loc_msg,
                                &env->md_env.matrix_type,
                                env->md_env.matrix,
                                &props),
                senderid = comp->objid,
                targetid = comp->objid,
                targetos = comp->osnum);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
        str = "MakeCompFromIntobjs : GRvg.GRgeomprops error",
        action = GOTO_VALUE, value = wrapup );

  if(props.phy_closed)
    printf("DANGER: The comp curve for coplanar case is not closed\n");
*/
      
wrapup:

  const_args->env_info->md_id.objid = mdid;

  if(lc_info) { om$dealloc(ptr = lc_info); lc_info = NULL; }  
  
  if(!(1&*msg))
  {
    ok = DeleteObject(&comp->objid, env);
    
    return FALSE;
  }
  else
    return TRUE;
}
      

/*
 * Function CheckCoplanarCase()
 */

IGRboolean CheckCoplanarCase(
IGRlong			*msg,
IGRlong			feaopts,
struct GRid     	*prof,
struct GRmd_env 	*envcv,
struct GRid     	*sl,
struct GRmd_env 	*envsl,
IGRboolean      	*coplanar,      //output
struct GRid		*the_plane,
struct IGRbsp_surface 	**plane,        //output
struct EMSpartolbasis   *ptolb,         //output
struct GRid		*the_ploop)      //output
{
  IGRlong 		loc_msg=EMS_S_Success, ret=0;
  GRobjid  		*coincsurfs    = NULL;  
  IGRboolean		ok=TRUE;
  BSrc			rc=BSSUCC;
  IGRdouble             cht=0;
  IGRushort		*lpprops = NULL;
  GRobjid		*ploops = NULL;
  struct IGRbsp_surface *sfgeom = NULL;
  IGRlong               curve_size = 0;
  struct IGRbsp_curve   *prof_curve = NULL;
  IGRpoint              proj_point;
  IGRdouble             par;       
    
  IGRint		EMgetvggeom(), EFsspbtol_by_geom();
  
  *msg = EMS_S_Success;
  *coplanar = FALSE;
  *plane = NULL;
  the_plane->objid = NULL_OBJID;

  BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);  
      
  if(feaopts & EMSfeature_finite)
  {
    IGRint   num_coincsurfs = 0, sfindex;
    IGRint   sts	    = OM_S_SUCCESS;
    
    void		EMgetcoincsurfs();
      	  
    EMgetcoincsurfs(&loc_msg, envcv, prof, sl, &num_coincsurfs, &coincsurfs);
    add$status( test = !(1&loc_msg),msg = *msg, code = EMS_E_Fail,
        str = "CheckCoplanarCase : EMgetconicsurfs error",
        action = GOTO_VALUE, value = wrapup );
    
    if(num_coincsurfs)
    {
      struct GRid 		the_surf;
      OM_S_CHANSELECT           to_loopset;
      IGRint		        maxint = OM_K_MAXINT, size = 0, count = 0,
  	       		        lpindex, aindex, new_index;
      IGRdouble	                cvxyzpts[6], cvuvpts[4], uv_pts[6];
      IGRboolean		onsurf = FALSE, found = FALSE;
      IGRboolean                new_coplanar_flag = FALSE;
      struct EMSptloc_info      loc_info;
      GRrange                   prof_range, surf_range;


     sts = om$send( mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsize(&loc_msg,
                                &envcv->md_env.matrix_type,
                                envcv->md_env.matrix,
                                &curve_size),
                        senderid = prof->objid,
                        targetid = prof->objid,
                         targetos = prof->osnum);
 
      add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
          str = "CheckCoplanarCase : GRvg.GRgetsize error",
          action = GOTO_VALUE, value = wrapup );

 prof_curve = (struct IGRbsp_curve *) om$malloc (size = curve_size);

 sts= om$send (msg = message GRvg.GRgetgeom (&loc_msg,
                                        &envcv->md_env.matrix_type,
                                        envcv->md_env.matrix,
                                        (IGRchar *) prof_curve),
                              senderid = prof->objid,
                              targetid = prof->objid,
                              targetos = prof->osnum);
 
        add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
          str = "CheckCoplanarCase : GRvg.GRgetgeom error",
          action = GOTO_VALUE, value = wrapup );



      sts = om$send(msg = message GRcurve.GRendpts(&loc_msg,
       	      		&envcv->md_env.matrix_type, envcv->md_env.matrix,
  	       			&cvxyzpts[0], &cvxyzpts[3]),
  	  	    senderid = prof->objid,
  	  	    targetid = prof->objid,
  	  	    targetos = prof->osnum);
      add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
          str = "CheckCoplanarCase : GRcurve.GRendpts error",
          action = GOTO_VALUE, value = wrapup );

      /*
       * get the range box of the profile
       */
      ok = GetObjectRange (prof->objid, prof->osnum, envcv, prof_range);
      add$status (test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "CheckCoplanarCase : GetObjectRange error",
          action = GOTO_VALUE, value = wrapup);
  	  	        
      loc_msg = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
      add$status( test = !(1&loc_msg),msg = *msg, code = EMS_E_Fail,
          str = "CheckCoplanarCase : EMmake_chanselect error",
          action = GOTO_VALUE, value = wrapup );

      for(sfindex = 0; (sfindex < num_coincsurfs && !found); sfindex++)
      {
        /*
         * get the R-Tree Range box (tight range) of the surface and increase
         * it by chord height tolerance.
         */
	par = 0.250;
	if(new_coplanar_flag) new_coplanar_flag = FALSE;

        ok = GetSurfaceRtreeRange (coincsurfs[sfindex], sl->osnum, envsl, 
                                   surf_range);
        add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
                    str = "CheckCoplanarCase : GetSurfaceRtreeRange error",
                    action = GOTO_VALUE, value = wrapup );

        EM3dbxinc (surf_range, cht);

        /*
         * Check whether the profile range box is contained within the surface
         * range box. If not, move on to the different surface.
         */
        if (prof_range[0] <= surf_range[0] || prof_range[1] <= surf_range[1] ||
            prof_range[2] <= surf_range[2] || prof_range[3] >= surf_range[3] ||
            prof_range[4] >= surf_range[4] || prof_range[5] >= surf_range[5])
        {
          continue;
        }
     
	sts = om$send(msg = message EMSloopset.EMget_loops(&loc_msg, EMS_OPT_PLOOP,
				    &maxint, &ploops, &lpprops, &size, &count),
		      senderid = coincsurfs[sfindex],
 		      targetos = prof->osnum,
                      p_chanselect = &to_loopset);
        add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
            str = "CheckCoplanarCase : EMSloopset.EMget_loops error",
            action = GOTO_VALUE, value = wrapup );
	  			
	the_surf.objid = coincsurfs[sfindex]; the_surf.osnum = prof->osnum;
        
        sfgeom = NULL;
	sts = EMgetvggeom(&loc_msg, &envsl->md_env.matrix_type, envsl->md_env.matrix, 
	  	          &the_surf, (IGRchar **)&sfgeom, NULL);
        add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
            str = "CheckCoplanarCase : EMgetvggeom error",
            action = GOTO_VALUE, value = wrapup );

	ok = BSprptonsf(&rc, sfgeom, &cvxyzpts[0], &cvuvpts[0], &cvuvpts[1], &onsurf);
  	if(!ok || (rc != BSSUCC) || !onsurf) continue;
		
  	ok = BSprptonsf(&rc, sfgeom, &cvxyzpts[3], &cvuvpts[2], &cvuvpts[3], &onsurf);
  	if(!ok || (rc != BSSUCC) || !onsurf) continue;


/* At this stage we have profile's range completely circumscribed by surf_range
   and end points of the profile is with in the loop. These conditions are
   sufficient to say that the profile is completely inside the surface so that
   we can switch on the bit of Coplanar, first we have to find is there any
   point on the profile and not on the surface. This can be found by taking mid
   upar value of the curve and projecting it on to the surface, and checking
   for on_surf bit, this is a tedious process and takes lot of time if all the
   poles are checked so we have decided to check for only 3 poles for upar
   values equally distributed.
*/


   for(lpindex = 0; lpindex < 3; lpindex ++)
        {
          BScveval(prof_curve, par, 0, &proj_point, &rc);
 
        add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
            str = "CheckCoplanarCase : BScveval error",
            action = GOTO_VALUE, value = wrapup );
 
     ok=BSprptonsf(&rc,sfgeom, &proj_point[0], &uv_pts[2 * lpindex], &uv_pts[2 *
 lpindex + 1], &onsurf);
  if(!ok || (rc != BSSUCC) || !onsurf) { new_coplanar_flag = TRUE;
                                               break; }
        par += 0.25;
        }
        if(new_coplanar_flag) continue;


	for(lpindex = 0; (lpindex < count && !found); lpindex++)
	{
	  aindex = count - (lpindex+1);
				  
	  if(lpprops[aindex] & EMLP_ACTIVE) 
	  {
	    
            ret = EFsspbtol_by_geom(&loc_msg, sfgeom, &ptolb->tol);
            add$status( test = !(1&ret&loc_msg),msg = *msg, code = EMS_E_Fail,
                str = "CheckCoplanarCase : EMsspbtol_by_geom error",
                action = GOTO_VALUE, value = wrapup );

   	    ptolb->is_valid = TRUE; ptolb->in_world = TRUE;
   	    ptolb->mattyp = &envsl->md_env.matrix_type;
   	    ptolb->mat = (IGRdouble *) envsl->md_env.matrix;

  	    loc_info.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_BOXCHECK;

    	    sts = om$send(msg = message EMSloop.EMpt_location(&loc_msg, 
    	    				&cvuvpts[0], &loc_info, ptolb),
	                  targetid = ploops[aindex], senderid = ploops[aindex], 
			  targetos = prof->osnum);
            add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
                str = "CheckCoplanarCase : EMSloop.EMpt_location error",
                action = GOTO_VALUE, value = wrapup );

   	    if(loc_info.location == EMS_L_OUTSIDE) continue; 

	    /*
 	     * The pt is EMS_L_ONEDGE || EMS_L_ONVRTX || EMS_L_INSIDE 
 	     */

    	    sts = om$send(msg = message EMSloop.EMpt_location(&loc_msg, 
    					&cvuvpts[2], &loc_info, ptolb),
		          targetid = ploops[aindex], senderid = ploops[aindex], 
			  targetos = prof->osnum);
            add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
                str = "CheckCoplanarCase : EMSloop.EMpt_location error",
                action = GOTO_VALUE, value = wrapup );
     
   	    if(loc_info.location == EMS_L_OUTSIDE) continue; /* Go to the next loop */

           for(new_index = 0; new_index < 3; new_index++)
        {
        sts = om$send(msg = message EMSloop.EMpt_location(&loc_msg,
                            &uv_pts[2 * new_index], &loc_info, ptolb),
                            targetid = ploops[aindex],
                            senderid = ploops[aindex],
                            targetos = prof->osnum);
            add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
                str = "CheckCoplanarCase : EMSloop.EMpt_location error",
                action = GOTO_VALUE, value = wrapup );
 
            if(loc_info.location == EMS_L_OUTSIDE)
                {
                        new_coplanar_flag = TRUE;  /* Go to the next loop  */
                        break;
                }
        }
	if(new_coplanar_flag) continue;

	    found = TRUE;
	    the_ploop->objid = ploops[aindex]; the_ploop->osnum = prof->osnum;
	    the_plane->objid = the_surf.objid; the_plane->osnum = the_surf.osnum;	    
	    *plane = sfgeom;
	    *coplanar = TRUE;

          }//if active loop
        } // for all the loops	
        
        if(!found)
        {
          if(sfgeom)  { om$dealloc(ptr = sfgeom);  sfgeom = NULL; }        
          if(lpprops) { om$dealloc(ptr = lpprops); lpprops = NULL; }
          if(ploops)  { om$dealloc(ptr = ploops);  ploops = NULL; }
        }
      } //for all the surfaces
    } //if there are any coincident surfaces
  } //if this is finite symmetric

wrapup:
  
  if(coincsurfs) { om$dealloc(ptr = coincsurfs); coincsurfs = NULL; }
  if(lpprops)    { om$dealloc(ptr = lpprops);    lpprops = NULL; }
  if(ploops)     { om$dealloc(ptr = ploops);     ploops = NULL; }
  if(prof_curve) { om$dealloc(ptr = prof_curve); prof_curve = NULL; }

  if(!(1&*msg)) {
    
    if(sfgeom) 
      { om$dealloc(ptr = sfgeom); sfgeom = NULL; *plane = NULL; }

    return FALSE;
  } 
  else
    return TRUE;
}

void Copy(
GRobjid 	id)
{
  
  IGRint 	sts=OM_S_SUCCESS, size=0, ret_size=0;
  IGRlong	loc_msg=EMS_S_Success;
  GRobjid 		new_id=NULL_OBJID;
  struct GRmd_env	env;
  IGRboolean aflag;
  
  aflag = pwIsActivationOn();
  if (aflag)
  {
    pwGetActiveModuleEnv(&env);
  }
  else
  {

  size = sizeof(struct GRmd_env);
  
  gr$get_module_env(msg    = &loc_msg,
                    sizbuf = &size,
                    buffer = &env,
                      nret = &ret_size);
  } 
  sts = om$send(msg = message GRgraphics.GRcopy(&loc_msg,
                              &env, &env, &new_id),
                senderid = id,
                targetid = id,
                targetos = env.md_id.osnum);
                
  if(!(1&sts&loc_msg))
    printf("Copy failed for objid = %d\n", id);
  else
    printf("Copy id = %d\n", new_id);  

  return;
}

/*
 * Function MatAddInsideYesNo()
 * 
 * This is the extended, trimmed, closed profile which is not reverse 
 * parameterized according to the material removal direction
 */

#define TEST_PARAMETER  0.3789
#define TRIES		4

IGRboolean MatInsideYesNo(
IGRlong		*msg,
IGRvector	NORMAL,
struct GRid 	*prof_grid,
struct GRmd_env	*env,
IGRboolean  	reversed,
IGRboolean  	*inside
)
{
  IGRint 		sts = OM_S_SUCCESS, i=0, num_tries = 0;
  IGRlong 		loc_msg=EMS_S_Success;
  struct IGRbsp_curve 	*curve = NULL;
  IGRdouble 		par=0;
  IGRboolean 		bssts, loc_inside; 
  IGRpoint		min, max;
  BSrc			rc=BSSUCC;

  IGRint		EMgetvggeom();

  *msg = EMS_S_Success;
  *inside = TRUE;
                
  sts = EMgetvggeom(&loc_msg, &env->md_env.matrix_type, env->md_env.matrix,
                    prof_grid, (IGRchar **)&curve, NULL);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "MatInsideYesNo : EMgetvggeom error",
      action = GOTO_VALUE, value = wrapup );

  bssts = BSbx2(&rc, &curve->num_poles, (IGRpoint *)curve->poles, 
  		(curve->rational ? curve->weights : NULL),
  		min, max);
  add$status( test = (!bssts || (rc != BSSUCC)), msg = *msg, code = EMS_E_Fail,
      str = "MatInsideYesNo : BSbx2 error",
      action = GOTO_VALUE, value = wrapup );
    
  /*
   * evaluate the profile at an arbitrary parameter ( non-knot point )
   */

  for(i = curve->order-1; i < curve->num_poles; i++)
  {
    par = (curve->knots[i] + curve->knots[i+1]) / 2.0;
      if(par != curve->knots[i])
      {
        bssts = IntersectYesNo(&loc_msg, NORMAL, par, prof_grid, env, curve, reversed, 
                               min, max, &loc_inside);
        add$status( test = !bssts, msg = *msg, code = EMS_E_BSerror,
            str = "MatInsideYesNo : IntersectYesNo error",
            action = GOTO_VALUE, value = wrapup );
        num_tries++;
	*inside = loc_inside * *inside;
	if(num_tries == TRIES) break;
      }
   }  

   if(!num_tries) 
   {
     par = TEST_PARAMETER;
     bssts = IntersectYesNo(&loc_msg, NORMAL, par, prof_grid, env, curve, reversed, 
                            min, max, &loc_inside);     
     add$status( test = !bssts, msg = *msg, code = EMS_E_BSerror,
         str = "MatInsideYesNo : IntersectYesNo error",
         action = GOTO_VALUE, value = wrapup );
     *inside = loc_inside;
   }

  return TRUE;

wrapup:

  if(curve) { om$dealloc(ptr = curve); curve = NULL; }

  return FALSE;
}

/*
 * 
 */

IGRboolean IntersectYesNo(
IGRlong		    *msg,
IGRvector	    NORMAL,
IGRdouble 	    par, 
struct GRid	    *prof,
struct GRmd_env	    *env,
struct IGRbsp_curve *curve, 
IGRboolean	    reversed,
IGRdouble           *min, 
IGRdouble           *max, 
IGRboolean          *inside)
{
  IGRlong    loc_msg=EMS_S_Success;
  IGRdouble  mat_vec[3];
  IGRdouble  cht=0, tmp_pt[3], cvpt[3];
  IGRint     i=0, n_int = 0, n_par = 1, sts=OM_S_SUCCESS;
  IGRlong    n_over = 0;
  BSrc       rc=BSSUCC;
  IGRboolean bssts=TRUE;
  struct IGRbsp_curve line;

  IGRdouble  *par1 = NULL, *par2 = NULL;
  IGRdouble *over1 = NULL, *over2 = NULL;
  IGRdouble *end_pts = NULL, *int_pts = NULL;
  
  *msg = EMS_S_Success;
  memset (&line, 0, sizeof (struct IGRbsp_curve));

  bssts = MatVecs(&loc_msg, NORMAL, prof, env, &curve, reversed, &par, n_par, mat_vec, cvpt);
  add$status( test = !bssts, msg = *msg, code = EMS_E_Fail,
      str = "IntersectYesNo : MatVecs error",
      action = GOTO_VALUE, value = wrapup );

  sts = BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);  

  for(i = 0; i < 3; i++)
   tmp_pt[i] = cvpt[i] + 10.0 * cht * mat_vec[i];
 
  line.poles = (IGRdouble *) alloca(6 * sizeof(IGRdouble));
  line.knots = (IGRdouble *) alloca(4 * sizeof(IGRdouble));
   
  (void)BSmklnintbx(tmp_pt, mat_vec, min, max, FALSE, &line, &rc); 
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "IntersectYesNo : BSmklnintbx error",
      action = GOTO_VALUE, value = wrapup );
  
  bssts = BScvcv_int(&rc, curve, &line, &n_int, &int_pts, &par1, &par2,
             	     &n_over, &end_pts, &over1, &over2);
  add$status( test = (rc != BSSUCC), msg = *msg, code = EMS_E_BSerror,
      str = "IntersectYesNo : BScvcv_int error",
      action = GOTO_VALUE, value = wrapup );

  if(n_int % 2)
    *inside = TRUE;
  else
    *inside = FALSE;

return TRUE;

wrapup:
  if(par1) { om$dealloc(ptr = par1); par1 = NULL;}
  if(par2) { om$dealloc(ptr = par2); par2 = NULL;}  
  if(over1) { om$dealloc(ptr = over1); over1 = NULL;}
  if(over2) { om$dealloc(ptr = over2); over2 = NULL;}  
  if(end_pts) { om$dealloc(ptr = end_pts); end_pts = NULL;}  
  if(int_pts) { om$dealloc(ptr = int_pts); int_pts = NULL;}    

return FALSE;  
}

/*
 * Function CloseProfile()
 */

IGRboolean CloseProfile(
IGRlong			*msg,
struct GRid		*prof,
struct GRmd_env 	*env,
struct GRvg_construct 	*const_args,
struct GRid		*new_id,
IGRboolean		*self_int,
IGRboolean		*self_overl,
GRobjid			*closing_id)
{
  IGRlong loc_msg=EMS_S_Success;
  IGRint  sts=OM_S_SUCCESS, type=0;
  GRspacenum const_os;
  GRobjid mdid=NULL_OBJID, lineid=NULL_OBJID,  junkid=NULL_OBJID;
  IGRpoint cv_startpt, cv_endpt;
  struct IGRbsp_curve line_geom;
  BSrc rc=BSSUCC;
  IGRboolean is_composite=FALSE, ok=TRUE;
  struct GRpost_info post_info;
  struct GRprops props;
  OMuint count, index;

  IGRboolean		EFisAncestryValid();
  
  *msg = EMS_S_Success;
  const_os = const_args->env_info->md_id.osnum;  
  mdid = const_args->env_info->md_id.objid;    
  new_id->objid = NULL_OBJID;
  memset (&line_geom, 0, sizeof (struct IGRbsp_curve));
 
  if(self_int)
    *self_int = FALSE;
  
  if(self_overl)
    *self_overl = FALSE;
    
  sts = om$send(msg = message GRvg.GRgeomprops(&loc_msg,
                                &env->md_env.matrix_type,
                                env->md_env.matrix,
                                &props),
                senderid = prof->objid,
                targetid = prof->objid,
                targetos = prof->osnum);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "CloseProfile : GRvg.GRgeomprops error",
      action = GOTO_VALUE, value = wrapup );

  if(props.phy_closed) goto wrapup;
  
  new_id->osnum = const_os;
  is_composite = FALSE;

  sts = om$send(msg = message GRgraphics.GRcopy(&loc_msg,
                              env, const_args->env_info, &(new_id->objid)),
                senderid = prof->objid,
                targetid = prof->objid,
                targetos = prof->osnum);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "CloseProfile : GRgraphics.GRcopy error",
      action = GOTO_VALUE, value = wrapup );

  sts = om$send(msg = message GRcurve.GRendpts(&loc_msg,
                                &const_args->env_info->md_env.matrix_type,
                                const_args->env_info->md_env.matrix,
                                cv_startpt, cv_endpt),
                senderid = new_id->objid,
                targetid = new_id->objid,
                targetos = const_os);
  add$status( test = !(1&sts&loc_msg), msg = *msg, code = EMS_E_Fail,
      str = "CloseProfile : GRcurve.GRendpts error",
      action = GOTO_VALUE, value = wrapup );

  line_geom.poles = (IGRdouble *) alloca (2 * sizeof(IGRpoint));
  line_geom.knots = (IGRdouble *) alloca (4 * sizeof(IGRdouble)); 

  ok = BSptlngen(&rc, cv_endpt, cv_startpt, &line_geom, &type);
  add$status( test = (rc!=BSSUCC)||(type!=BSCLINE), msg = *msg, 
      code = EMS_E_BSerror,
      str = "CloseProfile : BSptlngen error",
      action = GOTO_VALUE, value = wrapup );

  const_args->geometry = (IGRchar *)(&line_geom);

  lineid = NULL_OBJID;
  sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
                         osnum = const_os,
                       p_objid = &lineid,
	  msg = message GRvg.GRconstruct(const_args));
  add$status( test = !(1&sts&(*(const_args->msg))),msg = *msg,code = EMS_E_Fail,
      str = "CloseProfile : om$construct error",
      action = GOTO_VALUE, value = wrapup );
  
  const_args->geometry = (IGRchar *)NULL;
  
  is_composite = EFisAncestryValid(&loc_msg, new_id->objid, new_id->osnum,
                                   OPP_EMScomposite_class_id, TRUE);
  if(is_composite)
  {
    OM_S_CHANSELECT to_components;

    EMmake_chanselect(GRcmpowner_to_components, &to_components);
            
    sts = om$get_channel_count (osnum = const_os,
                                objid = new_id->objid,
                         p_chanselect = &to_components,
                                count = &count); 
    add$status( test = !(1&sts),msg = *msg,code = EMS_E_OMerror,
        str = "CloseProfile : om$get_channel_count error",
        action = GOTO_VALUE, value = wrapup );

     index = count;

     sts = om$send (msg =  message GRconnector.GRrigidconn(&loc_msg,
                                   new_id, (IGRlong *)&index),
                    senderid = lineid,
                    targetid = lineid,
                    targetos = const_os);
     add$status( test = !(1&sts&loc_msg),msg = *msg,code = EMS_E_Fail,
         str = "CloseProfile : GRconnector.GRrigidconn error",
         action = GOTO_VALUE, value = wrapup );
  }
  else
  {
    GRobjid copyid;

    copyid = new_id->objid;
    sts = om$construct ( classid = OPP_GRcompcurve_class_id,
                           osnum = const_os,
                         p_objid = &(new_id->objid));
    add$status( test = !(1&sts&(*(const_args->msg))),msg = *msg,
        code = EMS_E_Fail,
        str = "CloseProfile : om$construct error",
        action = GOTO_VALUE, value = wrapup );

    index = 0;
    sts = om$send(msg =  message GRconnector.GRrigidconn(&loc_msg,
                                 new_id, (IGRlong *)&index),
                  senderid = copyid,
                  targetid = copyid,
                  targetos = const_os);
    add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
        str = "CloseProfile : GRconnector.GRrigidconn error",
        action = GOTO_VALUE, value = wrapup );

    index = 1;
    sts = om$send (msg =  message GRconnector.GRrigidconn(&loc_msg,
                                  new_id, (IGRlong *)&index),
                   senderid = lineid,
                   targetid = lineid,
                   targetos = const_os);
    add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
        str = "CloseProfile : GRconnector.GRrigidconn error",
        action = GOTO_VALUE, value = wrapup );
  }

  post_info.construct_flag = FALSE;
  sts = om$send (msg = message GRvg.GRpostabsg(&loc_msg,
                         env, &post_info, (IGRchar *)NULL, &junkid),
                 senderid = new_id->objid,
                 targetid = new_id->objid,
                 targetos = new_id->osnum);
  add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
      str = "CloseProfile : GRvg.GRpostabsg error",
      action = GOTO_VALUE, value = wrapup );

 if( junkid == new_id->objid )
       GRabsg_del_by_objid( &new_id->objid, &new_id->osnum );


  if(closing_id) *closing_id = lineid;
  
  /* now we check for self-intersection if asked for */
  if (self_int)
  {
    IGRlong num_inter_alloc_slots = 0;
    IGRlong num_inter = 0;
    IGRlong num_overl_alloc_slots = 0;
    IGRlong num_overl = 0;    
    
    sts = om$send(msg = message GRcurve.EMcrvslfint(&loc_msg, const_args,
       			       &const_args->env_info->md_env, &num_inter_alloc_slots,
                               &num_inter, NULL, NULL, NULL, &num_overl_alloc_slots, &num_overl, 
                               NULL, NULL),
                  senderid = new_id->objid,
                  targetid = new_id->objid,
                  targetos = new_id->osnum);
    add$status( test = !(1&sts&loc_msg),msg = *msg, code = EMS_E_Fail,
        str = "CloseProfile : GRcurve.EMcrvslfint error",
        action = GOTO_VALUE, value = wrapup );

    if(num_inter > 1)
     *self_int = TRUE;
    else 
     *self_int = FALSE;
    
    if(self_overl) {
      if(num_overl > 0)
       *self_overl = TRUE;
      else
       *self_overl = FALSE;
    }
  }

wrapup:
  if ((!(1&*msg)) && (new_id->objid != NULL_OBJID))
  {
    ok = DeleteObject(&new_id->objid, const_args->env_info);
  }
    
  const_args->env_info->md_id.objid = mdid;
  
  if(!(1&*msg))
    return FALSE;
  else
    return TRUE;
}

end implementation Root;

