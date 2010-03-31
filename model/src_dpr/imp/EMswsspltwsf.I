/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method splits a surface/composite surface/solid with another
surface. The result is the host object receiving this message representing
one side of the split entity and a copy representing the other side. The
two complementary pieces will be connected on the one-to-one channel
'to_mirror_image' defined by this class. The two pieces are open two
independent modifications thereafter. For the response of the two pieces
to different messages see the specification file for this class.

Arguments
	cons_list	input	required for topology objects to be constructed
	to_split	input	surface/comp surf/solid which is to be split.
	split_with	input	surface to split with. These objects and
				the EMSsfspltwsf object receiving this message
				must exist in the same object space.
	bool_options		input	See include/emssfintdef.h (EMSsfbool_opt..)
	env		input	environment info of the objects involved.
	status_str	input	Will show status of processing if wanted.
	intobj		output	Intersection curves output as a graphic group
				if EMSsfbool_opt_outinters is set.
	auxobj		output	Bad points (endpoints of the intersections
				pieces with gaps) returned as a graphic group
				if EMSsfbool_opt_outaux is set.
	display_ids	output	ids of surfaces modified are returned here
				if EMSsfbool_opt_noredraw is set.
	display_count	output	Number of entries returned in display_ids.
	

Return Values
	The return values are similar to those returned by the method 
EMSsfboolean.EMjoiningBoolean.
	A severity level of FATL indicates a failure with operands 
corrupted. 

History
	SM	10-Jan-89	Creation.
	SS	12-Aug-89	Changed the function from EMbool_validate to
				EMsfint_topology_validate.
	SM	26-Feb-90	the statement
				tracetol = double_chk ? lentol
						      : BSEXTRACTPAR..
				was causing tracetol to be 1 when double_chk
				was FALSE. Fixed it.
				Also second call to EMupdate_gradat was passing
				inters[1] instead of inters[0] as it should
				have. This caused gradata on copied surfaces
				to remain out of date.
	SM	27-Mar-90	Modified such that if some intersections
				were deletable (due to coincedent planes)
				in the first run, the second boolean does
				an intersection again.
				Also in the normal case, modified such that
				EMintersect..() function is called even the
				second time, except that the sfsfint is
				skipped. This is to get, data fixing even
				on the second list.
*/

class implementation EMSsfspltwsf;

#include "EMS.h"
#include <string.h>
#include "emsbool.h"
#include "EMSmsgassist.h"	/* EMS_SeverityLevel, FATL */
#include "EMSprop.h"		/* EMsws_IsOriginal */
#include "EMSopt.h"		/* EMsws_MaintainHistory */
#include "emssfintdef.h"
#include "emsdattyp.h"
#include "emssfint.h"
#include "emsinter.h"
#include "OMmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

from EMSloopset import EMget_loops;
from EMSgradata import EMupdate;
from EMSsubbs import EMpartolbasis;

#define MaxNumSurfs	50

#ifndef DEBUG
#define DEBUG	0
#endif

%safe
static void		EMfixInt();
static	void		EMupdate_gradata();
%endsafe

extern OMuword OPP_EMSsolid_class_id, OPP_EMSsfspltwsf_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;


method EMsplit_with_surface(IGRlong *EMmsg;
			     struct GRvg_construct *cons_list;
			     GRobjid to_split, split_with;
			     IGRushort	bool_options, splt_options;
			     struct GRmd_env *env;
			     IGRchar *status_str;
			     GRobjid *intobj, *auxobj, **display_ids;
			     IGRint *display_count)
{
 IGRlong		sts, rc;
 GRobjid		to_split_copy = NULL_OBJID, 
			split_with_copy = NULL_OBJID, 
			my_copy = NULL_OBJID;
 OMuword		to_split_classid;
 IGRboolean		issolid = FALSE, compress = FALSE, 
			double_chk = FALSE, intersect_again = FALSE;
 enum EMSbooltype	bool_type;
 IGRshort		*mat_type;
 IGRdouble		*matrix, lentol, tracetol;
 OM_S_CHANSELECT	to_mirror_image;
 IGRboolean		to_split_is_single_surface = FALSE, 
			split_with_is_single_surface = FALSE, 
			undo_on_error = FALSE, redraw_on_error = FALSE;
			
 IGRint			i, num_inters = 0, 
			num_surfs = 0, 
			num_edges = 0,
			sw_num_surfs = 0, 
			sw_num_edges = 0;
			
 struct GRid		*orig_surfs = NULL, 
			*copy_surfs = NULL,
			*sw_orig_surfs = NULL, 
			*sw_copy_surfs = NULL, 
			orig_surf_buff[MaxNumSurfs], 
			copy_surf_buff[MaxNumSurfs], 
			sw_orig_surf_buff[MaxNumSurfs], 
			sw_copy_surf_buff[MaxNumSurfs], 
			*orig_edges = NULL, 
			*copy_edges = NULL, 
			*sw_orig_edges = NULL, 
			*sw_copy_edges = NULL, 
			sf1id, sf2id, my_GRid, copy_GRid, sf1copyid, sf2copyid;
			
 struct EMSinters	*inters[2];
			
 extern void		EMsfintedpar_free(), EMinters_data_free(), 
			EMinters_free(), EMgetLeafNodes(), EMgetActiveEdges();
 enum GRdpmode		display_mode;
 struct EMSdataselect	sf2data;
 struct EMSsftracedata  sftrace[2];
 extern IGRlong 	EMintersect_surfaces(), 
			EMboolean_surfaces_w_intersection(),
			EMsfint_topology_validate();
 IGRchar 		*loc_status_str, status_str_mem[MS_MAX_MSG_LENGTH+1];
 IGRushort 	inters_opt, outworld_opt, outparam_opt, trim_opt;
 extern void 		EMsfinttrace(), EMsfinttrace_free(), 
			EMsfintedpar_free();
 struct EMSsfintloopsdata sfintloopsdata[2];
 IGRchar dot[2];
 struct GRvg_construct loc_cons_list;
 IGRboolean save_pathway_trim, save_pathway_orient;
 extern IGRboolean	IGEstop();
 extern IGRlong		EMmake_chanselect();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 mat_type = &env->md_env.matrix_type;
 matrix = env->md_env.matrix;
 orig_surfs = (struct GRid *) orig_surf_buff;
 copy_surfs = (struct GRid *) copy_surf_buff;
 sw_orig_surfs = (struct GRid *) sw_orig_surf_buff;
 sw_copy_surfs = (struct GRid *) sw_copy_surf_buff;
 sf1id.osnum = OM_Gw_current_OS;
 sf1id.objid = to_split;
 sf2id.osnum = OM_Gw_current_OS;
 sf2id.objid = split_with;
 sf2data.datatype = EMSdata_object;
 sf2data.data.object = &sf2id;
 bool_type = EMSbool_difference;
 bool_options &= ~EMSsfbool_opt_display;
 bool_options &= ~EMSsfbool_opt_noredraw;
 my_GRid.osnum = OM_Gw_current_OS;
 my_GRid.objid = my_id;
 loc_cons_list = *cons_list;
 loc_cons_list.display = NULL;
 compress = splt_options & EMsws_MaintainHistory ? FALSE : TRUE;

 /* Are we splitting a compsurf or a solid ? 
 */
 sts = om$get_classid(objid = to_split, p_classid = &to_split_classid);
 if (to_split_classid == OPP_EMSsolid_class_id || 
     om$is_ancestry_valid (subclassid = to_split_classid,
           superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS)
    issolid = TRUE;

 /* If not splitting a solid, we will treat this as a 'save side' operation
    on a surface, using another surface. Since this will consume the 'split
    with' surface, make a copy of the input surface.
 */
 if(!issolid)
  {
   sts = om$send(msg = message GRgraphics.GRcopy(EMmsg, env, env, &split_with),
					targetid = split_with);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
   sf2id.objid = split_with;
  }

 /* Create loopsets on the operands if not already present.
 */
 sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, &env->md_env, 
		     NULL, NULL, NULL, NULL), targetid = to_split);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);
 sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, &env->md_env, 
		     NULL, NULL, NULL, NULL), targetid = split_with);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopsetError, wrapup);

 BSEXTRACTPAR (&rc, BSTOLCHRDHT, lentol);
 lentol += lentol;
 outworld_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;

 outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                EMSINT_ORIENT_OUTPUT ;
 if (status_str) strcpy (dot, ".");

 /* Obtain the valid intersections for performing the boolean.
 */
 while(TRUE)
  {
   if (status_str)
    {
     if (double_chk)
      {
       strcpy (status_str_mem, "Special ");
       strcat (status_str_mem, status_str);
      }
     else
       strcpy (status_str_mem, status_str);
     loc_status_str = status_str_mem;
    }
  else
    loc_status_str = NULL;
   for (i=0; i<2; i++)
    {
     inters[i] = NULL;
     sftrace[i].num_grps = 0;
     sftrace[i].num_subgrps_grp = NULL;
     sftrace[i].num_elems_subgrp = NULL;
     sftrace[i].elems = NULL;
     sftrace[i].subgrp_rev = NULL;
     sftrace[i].elem_rev = NULL;
     sftrace[i].grp_closed = NULL;
     sftrace[i].subgrp_closed = NULL;

     sfintloopsdata[i].loop_sf = NULL;
     sfintloopsdata[i].endedges = NULL;
     sfintloopsdata[i].intedpars = NULL;
     sfintloopsdata[i].sfpartolb = NULL;
     sfintloopsdata[i].sfintloops_alloced = FALSE;
     sfintloopsdata[i].numedsplit = 0;     
     sfintloopsdata[i].commed_k_exists = TRUE;
     sfintloopsdata[i].nocommed_k_exists = FALSE;
    }

   trim_opt = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
            EMSINT_TRIM_COPLANAR |
            (double_chk ? EMSINT_TRIM_MOREPRECISE | EMSINT_TRIM_PROCOVERLAP 
                        : NULL);
   inters_opt = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
                EMS_SFINT_PUSHBADCOINC | EMS_SFINT_REVERSESECONDINT |
              (double_chk ? NULL : EMS_SFINT_MUSTNOAMBIGUOUS) |
              (issolid ? EMS_SFINT_MUSTCLOSE : NULL) | EMS_SFINT_MARKEDDELINFO
               | (double_chk ? EMS_SFINT_DOUBLECHECK : NULL);

   if(bool_options & EMSsfbool_opt_HandleStop)
    inters_opt |= EMS_SFINT_HANDLESTOP;

   if(double_chk) tracetol = lentol;
   else BSEXTRACTPAR (&rc, BSTOLLENVEC, tracetol);

   save_pathway_trim = _pathway_trim;
   save_pathway_orient = _pathway_orient;
   _pathway_trim = 0;
   _pathway_orient = 0;

   num_inters = 0;
   sts = EMintersect_surfaces (EMmsg, &sf1id, &env->md_env, 1,
             &sf2data, &env->md_env, inters_opt, outworld_opt, outparam_opt,
             trim_opt, cons_list, &num_inters, 
             &inters[0], &inters[1], &sftrace[0], &sftrace[1], intobj, auxobj,
             loc_status_str);

   _pathway_trim = save_pathway_trim;
   _pathway_orient = save_pathway_orient;

   if(*EMmsg == EMS_I_Interrupt) goto wrapup;
   if(*EMmsg == EMS_I_Clipped) intersect_again = TRUE;
   else intersect_again = FALSE;
   EMerr_hndlr (!EMSerror(*EMmsg) && (!num_inters || !inters[0] || !inters[1]),
 		*EMmsg, EMS_I_NoIntersection, wrapup);
   if (!EMSerror (*EMmsg))
    {
     if(!issolid)
      {
       bool_options |= EMSsfbool_opt_OpenIntPossible |
                       EMSsfbool_opt_SingleTopology;
       bool_type = EMSbool_saveside;
      }

     sts = EMsfint_topology_validate(EMmsg, &env->md_env, inters[0], inters[1],
		&sftrace[0], &sftrace[1], bool_options,
		&sfintloopsdata[0], &sfintloopsdata[1]);
    }
   if(*EMmsg == EMS_I_Interrupt) goto wrapup;
   if (EMSerror (*EMmsg) && EMS_SeverityLevel (*EMmsg) != FATL && !double_chk)
    {
     for (i=0; i<=1; i++)
      {
       if(inters[i])
        {
         EMinters_data_free (&rc, inters[i], MAXINT, NULL, EMsfintedpar_free);
         EMinters_free (inters[i], MAXINT);
        }

       EMsfinttrace_free (&rc, sftrace[i].num_grps, sftrace[i].num_subgrps_grp,
	 sftrace[i].num_elems_subgrp, sftrace[i].elems, sftrace[i].subgrp_rev,
	 sftrace[i].elem_rev, sftrace[i].grp_closed, sftrace[i].subgrp_closed);
       if (sfintloopsdata[i].sfintloops_alloced)
         EMsfintloops_free (sfintloopsdata[i].loop_sf, 
			    sfintloopsdata[i].endedges, 
			    sfintloopsdata[i].intedpars,
       			    sfintloopsdata[i].sfpartolb);
      }
     double_chk = TRUE;
    }
   else break;

  } /* while(TRUE) */

 if(!(1&*EMmsg&sts)) goto wrapup;


 /* We now have valid intersections to perform a boolean operation.
 */

 if (loc_status_str)
  {
   strcat (loc_status_str, dot);
   ex$message(in_buff = loc_status_str, field = ERROR_FIELD)
  }

 EMgetLeafNodes(EMmsg, &orig_surfs, &num_surfs, MaxNumSurfs, &sf1id, 
		&to_split_is_single_surface, env);
		
 if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}

 if(bool_options & EMSsfbool_opt_HandleStop)
  {
   if(IGEstop()) {*EMmsg = EMS_I_Interrupt; goto wrapup;}
  }

 sts = EMdupinters(EMmsg, NULL, NULL, TRUE, FALSE, &sf1id, &sf1copyid, 
	 compress, env, &loc_cons_list, NULL, NULL, 0, NULL, NULL, 0);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
 to_split_copy = sf1copyid.objid;

 if(to_split_is_single_surface)
  {
   copy_surfs[0].objid = to_split_copy;
   copy_surfs[0].osnum = OM_Gw_current_OS;
  }
 else
  {
   /* If we are multiply splitting the copy of the previous split can be
      converted into a boolean class.
   */
   if( !compress && 
       ((to_split_classid == OPP_EMSsfspltwsf_class_id) ||
     ((sts = om$is_ancestry_valid(superclassid = OPP_EMSsfspltwsf_class_id, 
			subclassid = to_split_classid)) == OM_S_SUCCESS)))
    {
     sts = om$send(msg = message EMSdpr.EMchangeClass(EMmsg, NULL, NULL), 
			targetid = to_split_copy);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);			
    }

   EMgetLeafNodes(EMmsg, &copy_surfs, &num_surfs, MaxNumSurfs, &sf1copyid, 
		  NULL, env);
		
   if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}
  }

 /* Get all the edges from the original leaf nodes and then similarly from
    their copies. This will give the correspondence between the original
    edges and their copies. We are doing this AFTER a possible compress
    because edge ids may change during compress tree.
 */
 EMgetActiveEdges(EMmsg, &num_edges, &orig_edges, num_surfs, orig_surfs);
 if(!(1&*EMmsg)) goto wrapup;

 EMgetActiveEdges(EMmsg, &num_edges, &copy_edges, num_surfs, copy_surfs);
 if(!(1&*EMmsg)) goto wrapup;


 /* Repeat the above performance for the surface to split_with.
 */
 EMgetLeafNodes(EMmsg, &sw_orig_surfs, &sw_num_surfs, MaxNumSurfs, &sf2id, 
		&split_with_is_single_surface, env);
 if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}

 /* I am passing local construct list (same as input construct list except
    the display field being NULL), because the function puts new
    symbology if construct_list.display is non NULL. I want the exact copy
    of the original object including the symbology.
 */
 if(bool_options & EMSsfbool_opt_HandleStop)
  {
   if(IGEstop()) {*EMmsg = EMS_I_Interrupt; goto wrapup;}
  }

 sts = EMdupinters(EMmsg, NULL, NULL, TRUE, FALSE, &sf2id, &sf2copyid, 
	 compress, env, &loc_cons_list, NULL, NULL, 0, NULL, NULL, 0);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
 split_with_copy = sf2copyid.objid;

 if(split_with_is_single_surface)
  {
   sw_copy_surfs[0].objid = split_with_copy;
   sw_copy_surfs[0].osnum = OM_Gw_current_OS;
  }
 else
  {
   IGRboolean	dummy;

   EMgetLeafNodes(EMmsg, &sw_copy_surfs, &sw_num_surfs, MaxNumSurfs, 
		&sf2copyid, &dummy, env);
   if(!(1&*EMmsg)) {*EMmsg = EMS_E_Fail; goto wrapup;}
  }

 EMgetActiveEdges(EMmsg, &sw_num_edges, &sw_orig_edges, 
		  sw_num_surfs, sw_orig_surfs);
 if(!(1&*EMmsg)) goto wrapup;

 EMgetActiveEdges(EMmsg, &sw_num_edges, &sw_copy_edges, 
		  sw_num_surfs, sw_copy_surfs);
 if(!(1&*EMmsg)) goto wrapup;


 /* Reverse the orientation of the copied surface to indicate that the solid
    part for that surface is on the side opposite to that of the input
    surface.
 */
 sts = om$send(msg = message EMSsurface.EMrevorient(EMmsg), 
			targetid = split_with_copy);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

 if(!compress)
  ME.EMSsfspltwsf->splt_props = EMsws_HistoryKept;
 else
  ME.EMSsfspltwsf->splt_props = NULL;
 sts = om$send(msg = message GRgraphics.GRcopy(EMmsg, env, env, &my_copy), 
					targetid = my_id);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

 ME.EMSsfspltwsf->splt_props |= EMsws_IsOriginal;

 /* erase the surfaces to be used for splitting.
 */
 display_mode = GRbehe;
 sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                             mat_type, matrix, &display_mode,
                             &env->md_id), targetid = split_with);
 EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
 redraw_on_error = TRUE;
 sts = EMboolean_surfaces_w_intersection(EMmsg, &my_GRid, bool_type, 
		env, to_split, 1, &split_with,
		inters[0], inters[1], 
		&sftrace[0], &sftrace[1], 
		&sfintloopsdata[0], &sfintloopsdata[1],
		bool_options, 
		display_count, display_ids, loc_status_str);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(*EMmsg == EMS_I_Interrupt) goto wrapup;

 /* Any error after this point would warrant a undo since the original solid
    has already been worked upon.
 */
#if DEBUG
 printf("\nFirst boolean successful\n");
#endif

 undo_on_error = TRUE;
 EMupdate_gradata(inters[0], orig_surfs, num_surfs, &env->md_env);

 /* duplicate the intersections. Reverse the orientations of inters1 since
    the solid part of the surface to split with is now reversed.
 */
 if(inters[0])
  {
   if(intersect_again)
    {
     EMinters_data_free (&rc, inters[0], MAXINT, NULL, EMsfintedpar_free);
     EMinters_free (inters[0], MAXINT);
     inters[0] = NULL;
    }
   else
    {
     sts = EMdupinters(EMmsg, &inters[0], NULL, TRUE, FALSE, &sf1id, NULL, 
		  compress, env, cons_list, orig_surfs, copy_surfs, num_surfs, 
		  orig_edges, copy_edges, num_edges);
     if(!(1&*EMmsg&sts)) goto wrapup;

     EMfixInt(EMmsg, inters[0], TRUE, TRUE);
     if(!(1&*EMmsg)) goto wrapup;
    }
  }

 if(inters[1])
  {
   if(intersect_again)
    {
     EMinters_data_free (&rc, inters[1], MAXINT, NULL, EMsfintedpar_free);
     EMinters_free (inters[1], MAXINT);
     inters[1] = NULL;
    }
   else
    {
     sts = EMdupinters(EMmsg, &inters[1], NULL, TRUE, FALSE, &sf2id, NULL, 
	   compress, env, cons_list, sw_orig_surfs, sw_copy_surfs, 
	   sw_num_surfs, sw_orig_edges, sw_copy_edges, sw_num_edges);
     if(!(1&*EMmsg&sts)) goto wrapup;

     EMfixInt(EMmsg, inters[1], 
              bool_options & EMSsfbool_opt_SingleTopology ? FALSE : TRUE, 
              FALSE);
     if(!(1&*EMmsg)) goto wrapup;
    }
  }

 /* Retrace the reversed intersection data. I call the intersection function
    again and request it to skip sfsfint, so as to get refinement, topology
    trace etc.
 */  
 for (i=0; i<2; i++)
  {
   EMsfinttrace_free (EMmsg, sftrace[i].num_grps, sftrace[i].num_subgrps_grp, 
	sftrace[i].num_elems_subgrp, sftrace[i].elems, sftrace[i].subgrp_rev, 
	sftrace[i].elem_rev, sftrace[i].grp_closed, sftrace[i].subgrp_closed);
	
   sftrace[i].num_grps = 0;
   sftrace[i].num_subgrps_grp = NULL;
   sftrace[i].num_elems_subgrp = NULL;
   sftrace[i].elems = NULL;
   sftrace[i].subgrp_rev = NULL;
   sftrace[i].elem_rev = NULL;
   sftrace[i].grp_closed = NULL;
   sftrace[i].subgrp_closed = NULL;
  }

 num_inters = 0;
 if(!intersect_again) inters_opt |= EMS_SFINT_SKIPSFINT;
 sf1id.osnum = OM_Gw_current_OS;
 sf1id.objid = to_split_copy;
 sf2id.osnum = OM_Gw_current_OS;
 sf2id.objid = split_with_copy;
 sf2data.datatype = EMSdata_object;
 sf2data.data.object = &sf2id;

#if DEBUG
 if( !(inters_opt & EMS_SFINT_SKIPSFINT))
  printf("Intersecting surfaces again\n");
#endif
 save_pathway_trim = _pathway_trim;
 save_pathway_orient = _pathway_orient;
 _pathway_trim = 0;
 _pathway_orient = 0;

 sts = EMintersect_surfaces (EMmsg, &sf1id, &env->md_env, 1,
             &sf2data, &env->md_env, inters_opt, outworld_opt, outparam_opt,
             trim_opt, cons_list, &num_inters, &inters[0], &inters[1], 
	     &sftrace[0], &sftrace[1], NULL, NULL, NULL);

 _pathway_trim = save_pathway_trim;
 _pathway_orient = save_pathway_orient;

 if(*EMmsg == EMS_I_Interrupt) goto wrapup;
 if(!(1&*EMmsg&sts)) goto wrapup;
  
 copy_GRid.osnum = OM_Gw_current_OS;
 copy_GRid.objid = my_copy;
 sts = EMboolean_surfaces_w_intersection(EMmsg, &copy_GRid, bool_type,
		env, to_split_copy, 1, &split_with_copy, inters[0], 
		inters[1], &sftrace[0], &sftrace[1], NULL, NULL, bool_options, 
		display_count, display_ids, loc_status_str);
 if(*EMmsg == EMS_I_Interrupt) goto wrapup;
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMupdate_gradata(inters[0], copy_surfs, num_surfs, &env->md_env);

 /* We now have two globally modified solids/surfaces. One with entire design
    tree representing one half of the original solid/surface and the other
    with only the last operational history, representing the other half
    of the original solid/surface. We now connect them.
 */
 sts = EMmake_chanselect(EMSsfspltwsf_to_mirror_image, &to_mirror_image);
 if(!(1&sts)) goto wrapup;

 sts = om$send(msg = message Root.connect(to_mirror_image, NULL, my_id, 
				OM_Gw_current_OS, to_mirror_image, NULL), 
			senderid = my_id, targetid = my_copy);
 if(!(1&sts)) goto wrapup;

 /* redraw the surfaces used for splitting.
 */
 {
  display_mode = GRbd;
  sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                             mat_type, matrix, &display_mode,
                             &env->md_id), targetid = split_with);
  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
  redraw_on_error = FALSE;
  sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                             mat_type, matrix, &display_mode,
                             &env->md_id), targetid = split_with_copy);
  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
 }

wrapup:
 /* If there was an error delete all the copies made here. If the original
  * solid was already worked upon, undo the operation.
 */
 if( (!(1&*EMmsg&sts)) || (*EMmsg == EMS_I_NoIntersection) ||
	(*EMmsg == EMS_I_Interrupt))
  {
    if(!IF_NULL_OBJID(to_split_copy))
     sts = om$send(msg = message GRgraphics.GRdelete
			(&rc, env), targetid = to_split_copy);
			
    if(!IF_NULL_OBJID(split_with_copy))
     sts = om$send(msg = message GRgraphics.GRdelete
			(&rc, env), targetid = split_with_copy);
			
    if(!IF_NULL_OBJID(my_copy))
     sts = om$send(msg = message GRgraphics.GRdelete
			(&rc, env), targetid = my_copy);

    /* If the original surfaces used for splitting were erased but not redrawn
       we need to draw them now. If undo is to take place, the display of
       those surfaces will be handled by undo. So don't bother.
    */
    if(undo_on_error)
     {
      IGRushort undo_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
      IGRint num_dispsfs = 0, invoke_count = 0;
      GRobjid *dispsfids = NULL;

      sts = om$send (msg = message EMSdpr.EMundo (&rc, &undo_option, 
                env, NULL, NULL, NULL, &dispsfids, &num_dispsfs,
                &invoke_count), targetid = my_id);
      if(!(1&rc&sts)) *EMmsg = EMS_F_Fail;
     }
    else if(redraw_on_error)
     {
      display_mode = GRbd;
      sts = om$send(msg = message GRgraphics.GRdisplay(&rc,
                             mat_type, matrix, &display_mode,
                             &env->md_id), targetid = split_with);
     }
  }

if(orig_surfs && (orig_surfs != orig_surf_buff))
  om$dealloc(ptr = orig_surfs);
if(copy_surfs && (copy_surfs != copy_surf_buff))
  om$dealloc(ptr = copy_surfs);
if(orig_edges) om$dealloc(ptr = orig_edges);
if(copy_edges) om$dealloc(ptr = copy_edges);

if(sw_orig_surfs && (sw_orig_surfs != sw_orig_surf_buff))
  om$dealloc(ptr = sw_orig_surfs);
if(sw_copy_surfs && (sw_copy_surfs != sw_copy_surf_buff))
  om$dealloc(ptr = sw_copy_surfs);
if(sw_orig_edges) om$dealloc(ptr = sw_orig_edges);
if(sw_copy_edges) om$dealloc(ptr = sw_copy_edges);
for (i=0; i<=1; i++)
 {
  if(inters[i])
   {
    EMinters_data_free (&rc, inters[i], MAXINT, NULL, EMsfintedpar_free);
    EMinters_free (inters[i], MAXINT);
   }
  EMsfinttrace_free (&rc, sftrace[i].num_grps, sftrace[i].num_subgrps_grp, 
     sftrace[i].num_elems_subgrp, sftrace[i].elems, sftrace[i].subgrp_rev, 
     sftrace[i].elem_rev, sftrace[i].grp_closed, sftrace[i].subgrp_closed);

  if (sfintloopsdata[i].sfintloops_alloced)
    EMsfintloops_free (sfintloopsdata[i].loop_sf, 
   		       sfintloopsdata[i].endedges, 
		       sfintloopsdata[i].intedpars,
       		       sfintloopsdata[i].sfpartolb);
 }

EMWRAPUP(*EMmsg, sts, "EMSsfspltwsf.EMsplit_with_surface");
return(sts);

}



from EMSedge import EMset_props, EMgetbounds;
from EMSpartedge import EMputbounds;
extern OMuword OPP_EMSpartedge_class_id;

static void EMfixInt(EMmsg, inters, toggle_edrev, reverse)
IGRlong	*EMmsg;
struct EMSinters *inters;
IGRboolean toggle_edrev, reverse;
{
 IGRlong		sts;
 struct EMSinters	*this_inters;
 struct EMSintobj	*this_intobj;
 extern void		EMbreak_connection();
 extern IGRboolean	EFisAncestryValid();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 /* During the boolean processing, if the intobj->reversed flag is set, 
    the edges were reversed (set props). We need to toggle this bit in the
    copy to undo what the boolean did. For a partedge the bounds also need
    to be reversed.
    After undoing the affect of boolean processing on the intersection data
    we need to reverse the data if the reverse flag is TRUE.
 */

 this_inters = (struct EMSinters *) inters;
 while(this_inters)
  {
   this_intobj = (struct EMSintobj *) this_inters->cvs;
   while(this_intobj)
    {
     if(this_intobj->this_uvintobj.datatype == EMSdata_object)
      {
	GRobjid		junk;
	
	junk = (this_intobj->this_uvintobj.data.object)->objid;
	sts = om$send(msg = message EMSedge.EMset_props (EMmsg, 
		EMED_REVERSE_CONNECT, EMS_O_OFF), 
		targetid = junk, senderid = junk);
	if(!(1&*EMmsg&sts)) goto wrapup;
	if( (this_intobj->reversed) && toggle_edrev)
	 {
	  sts = om$send(msg = message EMSedge.EMset_props(EMmsg, EMED_REVERSED,
		 EMS_O_TOGGLE), targetid = junk, senderid = junk);
	  if(!(1&*EMmsg&sts)) goto wrapup;
	  if(EFisAncestryValid(EMmsg, junk, OM_Gw_current_OS, 
			       OPP_EMSpartedge_class_id, FALSE))
	   {
 	    struct EMSedgebound bounds[2], tmpbound;

	    sts = om$send(msg = message EMSedge.EMgetbounds(EMmsg, bounds), 
			targetid = junk, senderid = junk);
	    if(!(1&*EMmsg&sts)) goto wrapup;
	
            tmpbound = bounds[0];
            bounds[0] = bounds[1];
            bounds[1] = tmpbound;
            sts = om$send (msg = message EMSpartedge.EMputbounds (EMmsg,
                       bounds), targetid = junk, senderid = junk);
	    if(!(1&*EMmsg&sts)) goto wrapup;	
	   }
	
	 }
      }

     if(this_intobj->other_intobj_node) 
      EMbreak_connection(this_intobj->other_intobj_node);
       EMbreak_connection(this_intobj);
     if(reverse)
      {
	IGRboolean fwd_on = FALSE, bwd_on = FALSE;
	
       this_intobj->reversed = !this_intobj->reversed;
       if(this_intobj->props & EMSintobj_bwd_noconnectuv)
        {
	 this_intobj->props &= ~EMSintobj_bwd_noconnectuv;
	 fwd_on = TRUE;
        }
       if(this_intobj->props & EMSintobj_fwd_noconnectuv)
        {
	 this_intobj->props &= ~EMSintobj_fwd_noconnectuv;
	 bwd_on = TRUE;
        }

       if(fwd_on)
        this_intobj->props |= EMSintobj_fwd_noconnectuv;	 
       if(bwd_on)
        this_intobj->props |= EMSintobj_bwd_noconnectuv;	 

      }
     this_intobj = this_intobj->next;

    }
   this_inters = this_inters->next;
  }

wrapup:
return;
}


#include "EMSfrtdef.h"	/* EMS_O_RETRIM */
#include "emsdef.h"     /* MAXINT */

static void EMupdate_gradata(inters, sfid, numsfid, env)
struct EMSinters *inters;
struct GRid	*sfid;
IGRint 		numsfid;
struct GRmdenv_info *env;
{
 IGRlong		sts = OM_S_SUCCESS, rc = EMS_S_Success;
 OM_S_CHANSELECT	to_helpers, to_loopset;
 struct EMSinters	*this_inters;
 extern IGRlong		EMmake_chanselect();
 extern IGRlong		EFsspbtol_by_geom();
 struct EMSpartolbasis	partol;
 IGRboolean		world = TRUE;

 partol.mattyp = &env->matrix_type;
 partol.mat = env->matrix;
 partol.is_valid = TRUE;

 sts = EMmake_chanselect(EMSrequester_to_helpers, &to_helpers);

 if(inters)
  {
   this_inters = inters;
   while(this_inters)
    {
     if(this_inters->more_info)
      sts = EFsspbtol_by_geom(&rc, this_inters->more_info, &partol.tol);
     if(!(1&rc&sts) || !this_inters->more_info)
      {
       sts = om$send(msg = message EMSsubbs.EMpartolbasis(&rc, 
				&env->matrix_type, env->matrix, &world, 
				TRUE, &partol.tol), 
			senderid = this_inters->this_obj.objid, 
			targetid = this_inters->this_obj.objid);
       if(!(1&rc&sts)) partol.tol = 0.0000001;
      }
     sts = om$send(msg = message EMSgradata.EMupdate(&rc, &env->matrix_type,
		        env->matrix, NULL, 
			NULL, (struct IGRbsp_surface *) this_inters->more_info,
			NULL, NULL, &partol),  
			senderid = this_inters->this_obj.objid, 
			p_chanselect = &to_helpers);
     this_inters = this_inters->next;

    } /* while(this_inters) */

  } /* if(inters) */

 else if(sfid)
  {
   IGRint i, depth, num_loops;

   sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
   for(i=0; i<numsfid; i++)
    {
	
     /* All the loops on the surface may have been removed. If so gradata
	does not need to be updated.
     */
     num_loops = 0;
     depth = MAXINT;
     sts = om$send(msg = message EMSloopset.EMget_loops(&rc, EMS_OPT_ACTIVE, 
				&depth, NULL, NULL, NULL, &num_loops), 
		senderid = sfid[i].objid, p_chanselect = &to_loopset);
     if(!num_loops) continue;

     sts = om$send(msg = message EMSsubbs.EMpartolbasis(&rc, 
		&env->matrix_type, env->matrix, &world, TRUE, &partol.tol), 
			senderid = sfid[i].objid, targetid = sfid[i].objid);
     if(!(1&rc&sts)) partol.tol = 0.0000001;

     sts = om$send(msg = message EMSgradata.EMupdate(&rc, &env->matrix_type,
		        env->matrix, NULL, NULL, NULL, NULL, NULL, &partol), 
			senderid = sfid[i].objid, p_chanselect = &to_helpers);

    }/* for(i=0; i<numsfid; i++) */

  } /* else if(sfid) */

}

end implementation EMSsfspltwsf;
