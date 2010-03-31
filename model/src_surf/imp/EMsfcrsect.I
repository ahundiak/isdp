/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method takes the cross section of a surface with a given
        plane. The cross section must be clsed.
        
Arguments

        construcut_list         input           Construct list for the plane
                                                to be constructed.
        plane                   input           Cross section plane
						definition. If NULL a valid
						plane id must be passed in
						via the argument
						plane_id.
        my_env                  input           Environment info of solid.
        plane_id                input/output    GRobjid of the plane 
                                                constructed. 
	impoptions		input		see include/emsimpdef.h
						options supported
						EMImpBnd_WantStatMsg
						EMImpBnd_PreciseTrim.
Return Values

        EMS_S_Success           All went well.
        EMS_E_Fail              Severe error constructing the plane.
        EMS_E_NoDynamicMemory   Just what it says.
        EMS_I_NoIntersection    The plane does not intersect the solid.
        EMS_E_IntersectClosure  The intersections produced were not closed
                                (They must be for solid-plane intersection).
                                
History
        SM      31-Apr-87       Design and Creation.
	SM	25-Mar-88	Moved the message from EMSsolid to EMSsurface
				This will allow cross section of any surface
				as long as it is closed.
	SM	04-Apr-88	Call EMfix_sfint_uvtrace for both inters
				list to cause refinement of
				intersections and existing linear edges.
	SM	04-Aug-88	Use BSTOLLENVEC instead of 2*BSTOLCHRDHT
				for tracing.
	SM	07-Nov-88	Avoid closure test and sending of input
				props during EMlpinit.
	SM	07-Dec-88	Argument change in EMSloop.EMtoggle_type.
	SM	15-Feb-89	During second attempt use 2*cht for tracing
				model space data.
        Jack    31-May-91       Removed the initial loopset from the plane
                                so the new loopset can be connected.  This
                                change is for 2.0.1 horizon loops.  


*/
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emserr.h"
#include "bsparameters.h"
#include "bserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emslpinitdef.h"
#include "emsimpdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

extern OMuword OPP_EMSplane_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from EMSloopset import EMnesting,EMtreemod;
from EMSloop import EMgivenestinfo,EMtreemod, EMlpinit, EMreverse;
from EMSloop import EMtoggle_type, EMset_props;
from EMSsubbs import EMpartolbasis;

method EMcross_section(
         IGRlong *EMmsg;
         struct GRvg_construct *construct_list;
         struct IGRplane *plane;
         struct GRmd_env *my_env;
         GRobjid *plane_id;
	 IGRushort impoptions)
{
 IGRlong                 sts, num_inters = 0, i, j, k, rc;
 GRrange                 my_range;
 IGRboolean              world, want_status_messages, 
 			 plane_constructed_here = FALSE, inrange;
 struct IGRbsp_surface   plane_to_intersect;
 struct EMSinters        *inters[2];
 IGRint                  EMsfintloops(), num_nest_loops, num_loops;
 GRobjid                 **loop_sf = NULL, **endedges = NULL, loopset, 
 			 *nest_loops = NULL, 
			 loc_plane_id = NULL_OBJID;
 struct EMSsfintedpar    ***intparms = NULL;
 IGRdouble               **par_tol = NULL, u_knots[4],v_knots[4], *mat;
 extern void             EMinters_data_free(), EMinters_free(), 
 			 EMsfinttrace_free(), EMsfintloops_free(), 
 			 BSplptnorrg(), EMsfintedpar_free();
 IGRpoint                plane_poles[4];
 struct EMSpartolbasis   partolbasis;
 IGRshort                *mattyp;
 IGRushort 	 outworld_opt,trim_opt,outparam_opt, inters_opt,
        		 lpinit_options = NULL, togtype_options = NULL;
 struct EMSnest_info     nesting;
 GRspacenum 		 plane_os;
 struct GRmd_env 	 *plane_env;
 extern IGRlong		 EMintersect_surfaces();
 struct EMSsftracedata	 trace[2];
 struct EMSintobj	 *intobj_loc;	
 struct EMSdataselect    other_data;
 struct GRid             other_obj, my_GRid;
 OM_S_CHANSELECT 	 to_loopset, to_surface, to_loops;
 IGRboolean save_pathway_trim, save_pathway_orient;
 

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 world = TRUE;
 loop_sf = NULL;
 endedges = NULL;
 intparms = NULL;
 par_tol = NULL;
 mattyp = &my_env->md_env.matrix_type;
 mat = my_env->md_env.matrix;
 plane_env = (struct GRmd_env *) construct_list->env_info;
 plane_os = plane_env->md_id.osnum;
 want_status_messages = impoptions & EMImpBnd_WantStatMsg;
 if(!plane_id) plane_id = (GRobjid *) &loc_plane_id;
 for (i=0; i<2; i++)
  {
   inters[i] = NULL;
   trace[i].num_grps = 0;
   trace[i].num_subgrps_grp = NULL;
   trace[i].num_elems_subgrp = NULL;
   trace[i].elems = NULL;
   trace[i].subgrp_rev = NULL;
   trace[i].elem_rev = NULL;
   trace[i].grp_closed = NULL;
   trace[i].subgrp_closed = NULL;
  }
 nest_loops = NULL;

 if(plane) 
  {
   if(want_status_messages) ex$message(msgnumb = EMS_I_GeneratingPlane)
   sts = om$send(msg=message EMSsurface.GRgetrang
                        (EMmsg,mattyp,mat,&world,my_range),
                        targetid = my_id);
   if(!(1&*EMmsg&sts)) {*EMmsg = EMS_E_Fail; goto wrapup;}
   else *EMmsg = EMS_S_Success;

    /* Get the plane definition which encompases the surface range.
    */
   plane_to_intersect.poles = (IGRdouble *) plane_poles;
   plane_to_intersect.u_knots = u_knots;
   plane_to_intersect.v_knots = v_knots;

   BSplptnorrg(my_range,&my_range[3],plane->point,plane->normal,1.1,
                &inrange,&plane_to_intersect,&rc);
   if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
   else *EMmsg = EMS_S_Success;


   sts = om$construct(classid = OPP_EMSplane_class_id,
		       osnum = plane_os, 
                        p_objid = plane_id);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   construct_list->geometry = (IGRchar *) &plane_to_intersect;

   sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
			targetos = plane_os, targetid = *plane_id);

   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup)
   else *EMmsg = EMS_S_Success;
   plane_constructed_here = TRUE;
  }
 else if(IF_NULL_OBJID(*plane_id)) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

 other_obj.objid = *plane_id;
 other_obj.osnum = plane_os;

 /* if the plane has a loopset at this point we want to delete it
    since we will create a new one later.
  */   
 sts = om$send(msg = message EMSsurface.EMdelete_boundary(
                                        EMmsg,
                                        plane_env,
                                       &(plane_env->md_id),
                                       &other_obj),
               targetid = *plane_id,                                         
               targetos =  plane_os);

/*  Intersect the cross section plane with the solid.
*/
 outworld_opt = EMSINT_OUTPUT_WORLD;

 other_data.datatype = EMSdata_object;
 other_data.data.object = &other_obj;

 outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;
		
 trim_opt = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA | EMSINT_TRIM_COPLANAR;
	
 inters_opt = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTCLOSE | 
	      EMS_SFINT_AUTODOUBLECHECK;
	
 if(want_status_messages) ex$message(msgnumb = EMS_I_IntersectingSurfs)

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 sts = OM_S_SUCCESS;

 save_pathway_trim = _pathway_trim;
 save_pathway_orient = _pathway_orient;
 _pathway_trim = 0;
 _pathway_orient = 0;

 rc = EMintersect_surfaces(EMmsg, &my_GRid, &my_env->md_env, 1, &other_data,
				&plane_env->md_env, inters_opt, outworld_opt, 
				outparam_opt, trim_opt, construct_list,
				&num_inters, &inters[0], &inters[1], 
				&trace[0], &trace[1], NULL, NULL, NULL);

 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;

 EMerr_hndlr(!inters[0] || !inters[1], *EMmsg, 
	     EMS_I_NoIntersection, wrapup);
 if(!(1&*EMmsg&rc)) goto wrapup;

 /* Since the intersection data is not oriented, some elements may be deemed
    reversed by trace. Apply this information to the data by toggling the
    corresponding intobj's reversed flag. Later when the edge is constructed
    this flag is going to determine its direction.
 */
 num_loops = 0;
 for (i=0; i<trace[1].num_grps; i++)
  {
	
   if(!trace[1].grp_closed[i])
    {
     *EMmsg = EMS_E_IntersectClosure;
     sts = OM_S_SUCCESS;
     goto wrapup;
    }

   for (j=0; j<trace[1].num_subgrps_grp[i]; j++)
    {
     num_loops++;
     intobj_loc = trace[1].elems[i][j]; 
     for (k=0; k<trace[1].num_elems_subgrp[i][j]; k++)
      {
       if (trace[1].elem_rev[i][j][k])
        intobj_loc->reversed = !intobj_loc->reversed;
       intobj_loc = intobj_loc->next;
      }
    }
  }

 mattyp = &plane_env->md_env.matrix_type;
 mat = plane_env->md_env.matrix;

 /* Create the loops out of the intersections.
 */
 sts = EMsfintloops(EMmsg, mattyp, mat, plane_os, NULL, 
	  trace[1].num_grps, trace[1].num_subgrps_grp, 
	  trace[1].num_elems_subgrp, trace[1].elems,
	  trace[1].subgrp_rev, trace[1].elem_rev, trace[1].grp_closed, 
	  trace[1].subgrp_closed, FALSE, FALSE, &loop_sf, &endedges, &intparms,
	  &par_tol);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

 nest_loops = (GRobjid *) om$malloc(size = num_loops * sizeof(GRobjid));
 EMerr_hndlr(!nest_loops, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
                
 num_nest_loops = 0;
 for(i=0;i<trace[1].num_grps;i++)
  {
   for(j=0, k=0;j< 2 * trace[1].num_subgrps_grp[i];j+=2, k++)
    {
     if(trace[1].subgrp_rev[i][k])
      {
       sts = om$send(msg = message EMSloop.EMreverse(EMmsg),
				targetos = plane_os, 
                                targetid = loop_sf[i][j]);
       EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
      }
     nest_loops[num_nest_loops++] = loop_sf[i][j];
    }
  }

/* Connect an empty loopset to the newly constructed plane.
*/
 sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 sts = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
 sts = om$construct(classid=OPP_EMSloopset_class_id, osnum = plane_os, 
                           p_objid = &loopset);
 EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);
 sts = om$send(msg=message Root.connect(to_surface,NULL,*plane_id,
                                plane_os,to_loopset,NULL),
                                targetid=loopset, targetos = plane_os);
 EMerr_hndlr(!sts,*EMmsg,EMS_E_OMerror,wrapup);

/* Nest all the intersection loops into the planes loopset
*/
 if(plane)
  sts = EFsspbtol_by_geom(EMmsg, &plane_to_intersect, &partolbasis.tol);
 else
  sts = om$send(msg = message EMSsubbs.EMpartolbasis
		(EMmsg, mattyp, mat, &world, TRUE, &partolbasis.tol), 
		targetid = *plane_id, targetos = plane_os);
			
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);

 partolbasis.in_world = TRUE;
 partolbasis.is_valid = TRUE;
 partolbasis.mattyp = mattyp;
 partolbasis.mat = mat;
   
 lpinit_options = EMLpInit_NoClosureTest | EMLpInit_IgnoreInProps |
		     EMLpInit_NoRange;
		
 for(j=0;j<num_nest_loops;j++)
  {
   sts = om$send(msg = message EMSloop.EMset_props
               (EMmsg, EMLP_NEW | EMLP_SPLIT | EMLP_OPEN, EMS_O_OFF), 
                                targetid = nest_loops[j], targetos = plane_os);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);

   sts = om$send(msg = message EMSloop.EMlpinit
                   (EMmsg, NULL, &partolbasis, lpinit_options), 
                  targetid = nest_loops[j], targetos = plane_os);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
        
   sts = om$send(msg=message EMSloop.EMgivenestinfo
                                (EMmsg,&nesting),targetid = nest_loops[j], 
				targetos = plane_os);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
   sts = om$send(msg=message EMSloopset.EMnesting
                        (EMmsg,&nesting,&partolbasis),targetid = loopset, 
			targetos = plane_os);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);     
   if(IF_EQ_OBJID(nesting.parent,loopset))
    sts = om$send(msg=message EMSloopset.EMtreemod
                                (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = nesting.parent, targetos = plane_os);
   else
    sts = om$send(msg=message EMSloop.EMtreemod
                                (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = nesting.parent, targetos = plane_os);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);     
  }

/* Make all the external loops in the new loopset, P loops and toggle types
   of all other loops under them.
*/
 sts = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
 togtype_options = EMTogType_SendInner;
 sts = om$send(msg = message EMSloop.EMtoggle_type
			(EMmsg,TRUE, FALSE, my_id, togtype_options, 
			NULL, NULL, NULL, NULL, NULL, NULL), 
			targetos = plane_os, 
                        senderid=loopset,p_chanselect=&to_loops);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
 for (i=0; i<2; i++)
  {
   if(inters[i])
    {
     EMinters_data_free (&rc, inters[i], MAXINT, NULL, EMsfintedpar_free);
     EMinters_free (inters[i], MAXINT);
    }

   EMsfinttrace_free (&rc, trace[i].num_grps,
     trace[i].num_subgrps_grp, trace[i].num_elems_subgrp,
     trace[i].elems, trace[i].subgrp_rev, trace[i].elem_rev,
     trace[i].grp_closed, trace[i].subgrp_closed);
  }

 if(loop_sf) EMsfintloops_free(loop_sf,endedges,intparms,par_tol);

 if(nest_loops) om$dealloc(ptr = nest_loops);

 /* In case of problems, delete the plane if it was constructed here
 */
 if( (!(1&*EMmsg&sts) || (*EMmsg == EMS_I_NoIntersection)) &&
     plane_constructed_here)
  {
   sts = om$send(msg = message GRgraphics.GRdelete
                        (&rc, construct_list->env_info), 
                        targetid = *plane_id, targetos = plane_os);
   *plane_id = NULL_OBJID;
  }

 EMWRAPUP(*EMmsg,sts,"In EMSsurface.EMcross_section");
 return(sts);
}

end implementation EMSsurface;
