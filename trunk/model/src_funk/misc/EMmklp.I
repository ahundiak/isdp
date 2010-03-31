/*
DESCRIPTION:

This function creates a loop from the given intersection group and adds it 
to the loopset as an active loop.

void EMcreate_loop_from_int_group(msg, p_intobj, p_loopset, p_alt_uvtol, 
				  p_alt_xyztol, p_const_list, p_loop_props,
				  options)

IGRlong			*msg           - Error Return Code             (O)
struct EMSintobj	*p_intobj      - Pointer to 1st element of the
					 closed intersection group 
					 used to create new loop       (I)
GRobjid			*p_loopset     - Loopset on which the loop is
					 to be nested (Optional)
					 Extracted from surf if not
				         input                         (I)
IGRdouble		*p_alt_uvtol, 
			*p_alt_xyztol  - uv and xyz Tol (Optional)
					 Defaults to Basis tol         (I)
struct GRvg_construct	*p_const_list; - Construction list info        (I)
IGRushort		*p_loop_props; - Loop properties (Optional)    (I)
IGRshort		options	       - Options		       (I)
					 Currently Supported:
					 EMS_opt_mklp_ConnectAtLastIndex
					     This option forces the new
					     loop to be connected at the
					     "end" index of its parent loop
					     or loopset as the case may be.

HISTORY:

  ashok :       Oct-28-1992             Creation
  ashok :	Jun-20-1993		Added the "options" parameter and
					introduced the option
					EMS_opt_mklp_ConnectAtLastIndex. This
					is required whenever the newly created
					loop is to be connected to its "nesting"
					parent at its last channel index. The
					need arose because the EMtreemod()
					message always connects the new loop
					at its zero'th index.
					(in the case of "offset surface"
					this option  used to maintain same 
					toplogical position of the loop as its
					couterpart loop in the original surface)
  ashok		Nov-25-1993		Check if created loop intersects with
					parent or siblings. If so error out.
  sudhakar      Dec-21-1993             Send proper options to the "EMobint"
                                        message so as not to count touching
                                        intersections as intersections.
*/

class implementation EMSloop;

#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emssfint.h"
#include "emslpinitdef.h"

#define U 0
#define V 1
#define W 2

#define FIRST  0
#define SECOND 1

#define START  0
#define STOP   1

#define THIS  0
#define OTHER 1

from EMSloopset import EMtreemod;
from EMSloopset import EMnesting;
from EMSsubbs   import EMpartolbasis;
from EMSedge    import EMset_props;

void EMcreate_loop_from_int_group(msg, p_start_intobj, p_loopset, p_alt_uvtol, 
				  p_alt_xyztol, p_const_list, p_loop_props,
				  options)

IGRlong			*msg;
struct EMSintobj	*p_start_intobj;
GRobjid			*p_loopset;
IGRdouble		*p_alt_uvtol, *p_alt_xyztol;
struct GRvg_construct	*p_const_list;
IGRushort		*p_loop_props;
IGRshort		options;
{
  IGRlong		stat_OM, msg_loc;
  IGRshort		*mattyp;
  IGRushort		add_props;
  IGRint		inxlim, i, num_int;
  OMuint		count;
  IGRboolean		true,is_open_edge=FALSE;
  IGRdouble		uvtol, xyztol, **sfpartols, *mat;
  GRobjid		**loops_and_sfs, **end_edges;
  struct GRmd_env	*env;
  struct GRid		this_sf;
  struct EMSpartolbasis	partolbasis;
  struct EMSintobj	*tmp_intobj, *p_intobj;
  struct EMSinters	*p_inters, *save_p_inters;
  struct EMSsfintedpar	***intedpars;
  struct EMSsftracedata	sftrace;
  struct EMSnest_info	nest_info;
  OM_S_CHANSELECT 	chan_to_loopset, to_inner, to_outter, to_loops;
  OM_S_OBJECT_LINKAGE	comm_list[1];

     *msg = EMS_S_Success;
     stat_OM = OM_S_SUCCESS;
     env = p_const_list->env_info;
     mattyp = &env->md_env.matrix_type;
     mat = env->md_env.matrix;
     partolbasis.in_world = TRUE;
     partolbasis.mattyp = mattyp;
     partolbasis.mat = mat;
     p_intobj = p_start_intobj;

    if(p_alt_xyztol)
	xyztol = *p_alt_xyztol;
    else
        BSEXTRACTPAR (&msg_loc, BSTOLBASIS, xyztol);

    stat_OM = EMmake_chanselect(EMSloop_to_inner, &to_inner);
    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
    stat_OM = EMmake_chanselect(EMSloop_to_outter, &to_outter);
    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
    stat_OM = EMmake_chanselect(EMSloopset_to_loops, &to_loops);
    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
    stat_OM = EMmake_chanselect(EMSsubbs_to_loopset, &chan_to_loopset);
    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

    /*
     * The incoming  intersections are in contiguous order and
     * this may be re-inforced by setting the continuity pointers. Also,
     * convert the uv-data into EMSedges and set edge properties such as
     * EMED_OPEN, EMED_XYZ_CLOSED and EMED_SEAM if needed.
     */

    p_inters = p_intobj->this_obj_node;
    this_sf = p_inters->this_obj;
    tmp_intobj = p_intobj;

    while (p_intobj->next)
    {
      add_props = 0;
      is_open_edge = TRUE;
      p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
      p_intobj->props |= EMSintobj_fwd_connectuv;
      p_intobj->fwd = p_intobj->next;

      p_intobj->fwd->props &= ~EMSintobj_bwd_noconnectuv;
      p_intobj->fwd->props |= EMSintobj_bwd_connectuv;
      p_intobj->fwd->bwd = p_intobj;
      EMconvert_to_edge (&msg_loc, p_intobj, this_sf.osnum);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      add_props = EMED_OPEN;
      if(p_intobj->props & EMSintobj_xyz_closed) add_props |= EMED_XYZ_CLOSED;
      if(p_intobj->props & EMSintobj_seam) add_props |= EMED_SEAM;

      stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                           add_props, EMS_O_ON),
                senderid = NULL_OBJID,
                targetos = p_intobj->this_uvintobj.data.object->osnum,
                targetid = p_intobj->this_uvintobj.data.object->objid);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

      if (p_intobj->other_intobj_node)
      {
        EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, 
			   this_sf.osnum);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      }
      p_intobj = p_intobj->next;
    }

    p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
    p_intobj->props |= EMSintobj_fwd_connectuv;
    p_intobj->fwd = tmp_intobj;

    tmp_intobj->props &= ~EMSintobj_bwd_noconnectuv;
    tmp_intobj->props |= EMSintobj_bwd_connectuv;
    tmp_intobj->bwd = p_intobj;
 
    EMconvert_to_edge (&msg_loc, p_intobj, this_sf.osnum);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    add_props = 0;
    if(is_open_edge) add_props |= EMED_OPEN;
    if(p_intobj->props & EMSintobj_xyz_closed) add_props |= EMED_XYZ_CLOSED;
    if(p_intobj->props & EMSintobj_seam) add_props |= EMED_SEAM;
    stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc,
                                     add_props, EMS_O_ON),
       	               senderid = NULL_OBJID,
                       targetos = p_intobj->this_uvintobj.data.object->osnum,
                       targetid = p_intobj->this_uvintobj.data.object->objid);

    if (p_intobj->other_intobj_node)
    {
      EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, 
			 this_sf.osnum);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

    /*
     * Trace again and this time we should get a closed, single group. 
     * This group is converted to a loop and imposed as the
     * new boundary on the fillet surface.
     */

    if(!p_alt_uvtol)
    {
      om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc, mattyp, mat,
       		     &true, TRUE, &uvtol),
	       senderid = NULL_OBJID,
	       targetos = this_sf.osnum,
	       targetid = this_sf.objid);
    }
    else
      uvtol = *p_alt_uvtol;

    save_p_inters = p_inters->next;
    p_inters->next = NULL;

    sftrace.num_grps = 0;
    EMsfinttrace (&msg_loc, mattyp, mat, p_inters, &uvtol, &xyztol,
     &sftrace.num_grps, &sftrace.num_subgrps_grp, &sftrace.num_elems_subgrp,
     &sftrace.elems, &sftrace.subgrp_rev, &sftrace.elem_rev,
     &sftrace.grp_closed, &sftrace.subgrp_closed);
    p_inters->next = save_p_inters;    
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    EMerr_hndlr (sftrace.num_grps != 1 || !sftrace.grp_closed[FIRST] || 
     sftrace.num_subgrps_grp[FIRST] != 1 || !sftrace.subgrp_closed[FIRST] ||
     sftrace.subgrp_rev[FIRST][FIRST],
     *msg, EMS_E_Fail, ret_end);
    inxlim = sftrace.num_elems_subgrp[FIRST][FIRST];
    for (i=0; i<inxlim; i++)
      {EMerr_hndlr (sftrace.elem_rev[FIRST][FIRST][i], *msg,
        EMS_E_IntersectOrient, ret_end);}

/* At the end of trace 'p_start_intobj' need not be immediately connected
   to the 'inters' node. So resequence the intobjs so that it is still
   the first intobj
*/
    tmp_intobj = (struct EMSintobj *) p_inters->cvs;
    while(tmp_intobj)
    {
	if(tmp_intobj == p_start_intobj)
	{
	   tmp_intobj->bwd->next = NULL;
	   while(tmp_intobj->next)
	      tmp_intobj = tmp_intobj->next;
	   tmp_intobj->next = tmp_intobj->fwd;
	   p_inters->cvs = p_start_intobj;
    	   sftrace.elems[0][0] = p_start_intobj;
	   break;
	}
        tmp_intobj = tmp_intobj->next;
    }
/*
#ifdef DEBUG
printf(" Before: %x		After: \n", p_start_intobj);
tmp_intobj=sftrace.elems[0][0];
for(i=0;i<sftrace.num_elems_subgrp[FIRST][FIRST];i++, tmp_intobj=tmp_intobj->next)
    printf("                              %x\n", tmp_intobj);
#endif
*/
/*  Create a loop out of the contiguous intobjs. Set option to make
    the common edge connection between edges if common edge ("other_intobj")
    exists.
*/
    EMsfintloops (&msg_loc, mattyp, mat, this_sf.osnum, &uvtol,
     sftrace.num_grps, sftrace.num_subgrps_grp, sftrace.num_elems_subgrp,
     sftrace.elems, sftrace.subgrp_rev, sftrace.elem_rev,
     sftrace.grp_closed, sftrace.subgrp_closed, 
     TRUE, FALSE, &loops_and_sfs, &end_edges, &intedpars, &sfpartols);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    nest_info.loopid = loops_and_sfs[FIRST][FIRST];
    EMsfintloops_free (loops_and_sfs, end_edges, intedpars, sfpartols);

/* Now we have the loop object. EMsfintloops() would have marked the loop
   as "new". Reset this property.
*/
    stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc, EMLP_NEW,
               EMS_O_OFF), 
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = nest_info.loopid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if(!p_loopset)
    {
      count = 0;
      om$get_channel_objects (objid = this_sf.objid,
	    osnum = this_sf.osnum,
            p_chanselect = &chan_to_loopset, count = &count, size = 1,
            list = comm_list);
      EMerr_hndlr (count != 1, *msg, EMS_E_Fail, ret_end);
      p_loopset = &comm_list[FIRST].S_objid;
    }

    partolbasis.is_valid = TRUE;
    partolbasis.tol = uvtol;
    nest_info.lp_props = EMLP_ACTIVE | (p_loop_props ? *p_loop_props : NULL);

/* Initialize the loop by sending the EMlpinit message (P_Loop/C_Loop property
   will be set by this message). Setting 'options' to EMLpInit_NoClosureTest
   since we know loop is closed. This is a debatable point.
*/
    stat_OM = om$send (msg = message EMSloop.EMlpinit(&msg_loc, 
				     nest_info.lp_props, &partolbasis,
				     EMLpInit_NoClosureTest),
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = nest_info.loopid );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

/* Now determine if the Loop is to be nested directly under the loopset.
   If not get the actual parent (an existing loop in the loopset) under which
   it should be nested. Then, accordingly, the loop (child) is added to the
   parent using EMtreemod message.
*/
    stat_OM = om$send (msg = message EMSloop.EMgivenestinfo (&msg_loc,
              &nest_info), 
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = nest_info.loopid );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message EMSloopset.EMnesting (&msg_loc,
               &nest_info, &partolbasis),
	       senderid = NULL_OBJID,
	       targetos = this_sf.osnum,
               targetid = *p_loopset);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

/* Check if the new loop is intersecting with its parent or any of its
   siblings. If so error out. Need to investigate how expensive this
   check is as it may involve many edge-edge intersection tests. Pass
   appropriate options so as not to count "touching" intersections.
*/
    num_int = 0;
    stat_OM = om$send (msg = message EMSloop.EMobint (&msg_loc,
               &partolbasis, nest_info.parent, &partolbasis, 
               EMS_INTER_CUTTING | EMS_INTER_REMZEROEND | EMS_INTER_BDRYISAREA,
               &num_int,
	       NULL, NULL), 
	       senderid = NULL_OBJID,
	       targetos = this_sf.osnum,
               targetid = nest_info.loopid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
if(num_int > 0) printf(" EMmklp - Error - Intersecting Loops, num_int = %d\n",
                                                                    num_int);
#endif
    EMerr_hndlr (num_int > 0, *msg, EMS_E_Fail, ret_end); 

    if(nest_info.parent == *p_loopset)
    {
      stat_OM = om$send (msg = message EMSloopset.EMtreemod (&msg_loc,
                               &nest_info, ADD_CHILD, &partolbasis),
	                 senderid = NULL_OBJID,
	                 targetos = this_sf.osnum,
                         targetid = *p_loopset);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      if(options & EMS_opt_mklp_ConnectAtLastIndex)
      {
        stat_OM = om$send(msg=message Root.disconnect(to_loops,
                              nest_info.loopid, this_sf.osnum,to_outter),
	                  senderid = NULL_OBJID,
	                  targetos = this_sf.osnum,
                          targetid=*p_loopset);
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

        stat_OM = om$send(msg=message Root.connect(to_loops,NULL,
                              nest_info.loopid, this_sf.osnum,to_outter,
		  	      OM_K_MAXINT),
	                  senderid = NULL_OBJID,
	                  targetos = this_sf.osnum,
                          targetid = *p_loopset);
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
      }
    }
    else
    {
      stat_OM = om$send (msg = message EMSloop.EMtreemod (&msg_loc,
                               &nest_info, ADD_CHILD, &partolbasis),
	                 senderid = NULL_OBJID,
	                 targetos = this_sf.osnum,
                         targetid = nest_info.parent);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      if(options & EMS_opt_mklp_ConnectAtLastIndex)
      {
        stat_OM = om$send(msg=message Root.disconnect(to_inner,
                              nest_info.loopid, this_sf.osnum,to_outter),
	                  senderid = NULL_OBJID,
	                  targetos = this_sf.osnum,
                          targetid = nest_info.parent);
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

        stat_OM = om$send(msg=message Root.connect(to_inner,NULL,
                              nest_info.loopid, this_sf.osnum,to_outter,
			      OM_K_MAXINT),
	                  senderid = NULL_OBJID,
	                  targetos = this_sf.osnum,
                          targetid = nest_info.parent);
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
      }
    }


ret_end:

/* Deallocate trace-info structure */
    if(sftrace.num_grps)
       EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
       sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
       sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);

    EMWRAPUP(*msg, stat_OM, "EMcreate_loop_from_int_group");
    return;
}

end implementation EMSloop;
