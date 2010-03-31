/* #################   APOGEE  COMPILED   ######################### */
/*
DESCRIPTION

  This function validates an edge using a set of validation rules.
  If a defect is found, it is displayed (hilited) and a corrective
  action (if there is one) is printed. The user can then either
  take the corrective action or ignore it.

HISTORY

  RV 	03/11/88	Creation
  SM	23-Nov-88	Added code to check for EMSsplit objects owning the
			edge in steady state (criteria for invalidity)
			and offer the corrective action as deleting
			them.
  SM	02-Dec-88	If common edge is inactive report as defect and offer
			corrective action as disconnecting them. Also if
			common edge is inactive do not perform reverse connect
			and degeneracy type tests since the common edge has
			no path to its surface. Treat the case same as no
			common edge.
 SM	06-Feb-89	If an edge is not degenerate and has been marked
			as such, perform the test again with cht as the
			degeneracy tolerance. This is because after the 'make
			composite' operation the function 'EFmksolid' uses
			cht to test the remaining connectable edges for
			degeneracy (I am not sure why) and marks them as
			such. These kinds of edges later fault out when a
			tighter tolerance (bastol) is used for degeneracy
			check.
 SM	12-Feb-89	Use sample size of 2 (instead of 4) for common edge
			matching because that is the size used to stitch
			the edges to begin with. If we allow stitching to
			succeed based on this sample size, it is conflicting
			to come back and fault the connection during
			validation.
 SM	29-Aug-89	Use 2*cht as tolerance for edge matching. Booleans
			use this tol during special processing. So two split
			points on two edges can be off by 2*cht hence
			the partedge endpoints (which result out of the
			boolean) will potentailly be within that tol
			even if they are part natural/bs edges.
 SM     22-Jul-92       Added following checks -
                        1) An edge should be owned by ONLY one active
                           loop - if not no corrective action known.
                        2) The active loop of the edge must be the last
                           on the edge-to-loop channel- If not correct the
                           channel connection.

 Sudha  06/04/93       modified to include BSprototype header files

*/

class implementation EMSedge;

#include <stdio.h>
#include <ctype.h>
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "EMSobjmgrdef.h"	/* EMScp.. defs for MSC */
#include "EMSlcdef.h"
#include "bsparameters.h"
#include "bschangepar.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define ObBuff	20

from EMSsubbs import EMgetbsdef;
from EMSloop import EMget_props, EMactivate_loop;

extern OMuword OPP_EMSnatedge_class_id, OPP_EMSdumedge_class_id,
               OPP_EMSpartedge_class_id, OPP_EMSptedge_class_id, 
	       OPP_EMSsplit_class_id;
	
method EMvalidate(IGRlong *EMmsg; struct GRmd_env *mod_info;
		  IGRchar *surf_geom;
		  GRobjid *cancer; IGRushort *option;
		  IGRchar *objinfo, *ioptr)
{
  IGRint sts, i;
  IGRint   edges_in_loop = 0;
  OMuint   count;
  IGRlong rc;
  OM_S_CHANSELECT chan_to_owner, chan_to_common, to_loop_comps;
  IGRchar obj_info[256];
  GRobjid loop_id = NULL_OBJID, comm_surf = NULL_OBJID;
  struct GRid my_GRid;
  IGRboolean continu = TRUE, rev_connect, correct, is_xyz_closed, is_degen, 
		commed_active = TRUE, defective = FALSE, ignore_common =FALSE;
  IGRushort props_0, props_1, partner_props;
  struct IGRbsp_surface surf_def;
  OMuword	my_classid;
  GRobjid		srfid = NULL_OBJID;
  extern IGRboolean	IGEstop();
  OM_S_OBJECT_LINKAGE	comm, *myloops = NULL;
  GRobjid		commid = NULL_OBJID;
  IGRdouble		disq_tol, cht_tol;
  IGRboolean isptedge = FALSE;
  
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  if(!(continu = !(IGEstop()))) goto wrapup;
  BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol);

  sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg, &srfid, NULL),
			targetid = my_id);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_LoopError,wrapup);

  if(!objinfo)
   {
    /* Keep the following sprintf statements as they are.
    */
    if(IF_NULL_OBJID(srfid))
     sprintf(obj_info, "Edge (id=%d) (props=0x%x)\n             No path to surface", my_id, ME.EMSedge->ed_props);
    else
     sprintf(obj_info, "Edge (id=%d) (props=0x%x)\n             On surface = %d osnum %d", my_id, ME.EMSedge->ed_props, srfid, my_GRid.osnum);
   }
  else
   strcpy(obj_info, objinfo);

  chan_to_owner.type = OM_e_addr;
  chan_to_owner.u_sel.addr = &ME.EMSedge->to_owner;

  chan_to_common.type = OM_e_addr;
  chan_to_common.u_sel.addr = &ME.EMSedge->to_common_edge;

  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_loop_comps);
  EMomerr_exit (sts, wrapup);

  sts = om$get_classid(objid = my_id, p_classid = &my_classid);
  if( !(1&sts)) goto wrapup;

  if( (my_classid == OPP_EMSptedge_class_id) ||
      ((sts = om$is_ancestry_valid(subclassid = my_classid, 
	superclassid = OPP_EMSptedge_class_id)) == OM_S_SUCCESS))
	isptedge = TRUE;
  else sts = OM_S_SUCCESS;

  /* Check for EMSsplit objects 
  */
  {
   OMuint	count = 0;
   OM_S_OBJECT_LINKAGE	*objs = NULL, objsbuff[ObBuff];
   OMuword	junk;
   IGRboolean	bad = FALSE;

   sts = om$get_channel_count(object = me, p_chanselect = &chan_to_owner, 
			      count = &count);
   if(count)
    {
     if(count > ObBuff)
       objs = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count * sizeof(OM_S_OBJECT_LINKAGE));
     else objs = objsbuff;

     EMerr_hndlr(!objs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     sts = om$get_channel_objects(object = me, p_chanselect = &chan_to_owner, 
			    list = objs, size = count, count = &count);
     EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
     for(i=0; i<count; i++)
      {
       sts = om$get_classid(objid = objs[i].S_objid, p_classid = &junk);
       if(junk == OPP_EMSsplit_class_id)              
        {bad = TRUE; break;}
      }
     if(bad)
      {
       sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Owned by EMSsplit object(s)",
		    "Delete the EMSsplit object(s)", &continu, &correct, NULL, 
		 option, ioptr, NULL);
       EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
       if(!correct) defective = TRUE;
       if (correct)
        {
	 for(i=0; i<count; i++)
	  {
           sts = om$get_classid(objid = objs[i].S_objid, p_classid = &junk);
           if(junk == OPP_EMSsplit_class_id)
             sts = om$send(msg = message Root.delete(TRUE), 
		       targetid = objs[i].S_objid, senderid = objs[i].S_objid);
	  }
        }
       if (!continu) goto wrapup;

      }/*if(bad)*/

      if(objs && (objs != objsbuff)) om$dealloc(ptr = objs);

     } /* if(count) */

  }

  if(IF_NULL_OBJID(srfid))
   {
    /* Don't try to display the edge since no path to the surface.
       So send NULL for grid to the function.
    */
    sts = EMvalidate_io(EMmsg, mod_info, NULL, obj_info, 
		"No path to the surface", NULL,
		&continu, &correct, NULL, option, ioptr, NULL);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
    defective = TRUE;
    if (!continu) goto wrapup;
   }

  sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg,
					&loop_id),
			my_id, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

  if(!IF_NULL_OBJID(loop_id))
   {
    sts = om$get_channel_count (objid = loop_id, p_chanselect =
             &to_loop_comps, count = (OMuint *)&edges_in_loop);
    EMomerr_exit (sts, wrapup);
   }

  if(!isptedge)
   {
    sts = om$send (msg = message EMSedge.EMtst_degn (EMmsg, 
          (struct IGRbsp_surface *) surf_geom,
				NULL_OBJID, &mod_info->md_env, &is_degen),
		     targetid = my_id);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  else is_degen = TRUE;

  if ((ME.EMSedge->ed_props & EMED_DEGENERATE) && !is_degen)
  {
     /*
      * need to do the test for degeneracy with cht_tol instead of 
      * dis_tol. Since the math function BStstcvdegn uses BSTOLSQLENVEC,
      * change that to cht_tol*cht_tol, temporarily.
      */
     BSEXTRACTPAR(&rc, BSTOLSQLENVEC, disq_tol);
     BSchangepar(&rc, BSTOLSQLENVEC, cht_tol*cht_tol);
     if (rc != BSSUCC) goto wrapup;
     sts = om$send (msg = message EMSedge.EMtst_degn (EMmsg, 
            (struct IGRbsp_surface *) surf_geom,
				NULL_OBJID, &mod_info->md_env, &is_degen),
		     targetid = my_id);
     BSchangepar(&rc, BSTOLSQLENVEC, disq_tol);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
     if ((ME.EMSedge->ed_props & EMED_DEGENERATE) && !is_degen)
      {
       sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect degeneracy",
		    "Turn the bit off", &continu, &correct, 
		NULL, option, ioptr, NULL);
       EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
       if (correct) ME.EMSedge->ed_props &= (~ EMED_DEGENERATE);
       else defective = TRUE;
       if (!continu) goto wrapup;
      }
  }
  else if (!(ME.EMSedge->ed_props & EMED_DEGENERATE) && is_degen)
  {
   sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect degeneracy",
		    "Turn the bit on", &continu, &correct, NULL, 
		option, ioptr, NULL);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
   if (correct) ME.EMSedge->ed_props |= EMED_DEGENERATE;
   else defective = TRUE;
   if (!continu) goto wrapup;
  }

  if (!(ME.EMSedge->ed_props & EMED_DEGENERATE) &&
      !(ME.EMSedge->ed_props & EMED_SEAM))
  {
    sts = om$send(msg = message EMSedge.EMtst_xyz_clsd(EMmsg,
				(struct IGRbsp_surface *) surf_geom, 
				NULL_OBJID, &mod_info->md_env,
				&is_xyz_closed),
			targetid = my_id);

    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
    if ((is_xyz_closed && !(ME.EMSedge->ed_props & EMED_XYZ_CLOSED))
				||
        (!is_xyz_closed && (ME.EMSedge->ed_props & EMED_XYZ_CLOSED)))
    {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect xyz-closure flag", is_xyz_closed ? "Turn the bit on"
		: "Turn the bit off", &continu, &correct, NULL, option, ioptr, 
		 NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
      {
	if (is_xyz_closed) ME.EMSedge->ed_props |= EMED_XYZ_CLOSED;
	else ME.EMSedge->ed_props &= (~ EMED_XYZ_CLOSED);	 	  
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
    }
  }

  if (edges_in_loop == 1)
  {
    if ( (ME.EMSedge->ed_props & EMED_OPEN) &&
         (!(ME.EMSedge->ed_props & EMED_DEGENERATE)))
    {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Open, single edge in loop",
	  "Flag it as closed", &continu, &correct, NULL, option, ioptr, 
	  NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct) ME.EMSedge->ed_props &= (~ EMED_OPEN);
      else defective = TRUE;
      if (!continu) goto wrapup;
    }
  }
/*************************************
  else
  {
    if (!(ME.EMSedge->ed_props & EMED_OPEN) && !isptedge)
    {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Closed, non-single edge in loop",
		  "Flag it as open", &continu, &correct, NULL, 
		  option, ioptr, NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct) ME.EMSedge->ed_props |= EMED_OPEN;
      else defective = TRUE;
      if (!continu)  goto wrapup;
    }
  }
*************************************/

  sts = om$get_channel_objects (object = me,  p_chanselect =
             &chan_to_common, list = &comm, size = 1, count = &count);
  EMomerr_exit (sts, wrapup);
  commid = comm.S_objid;

  if(count)
   {
    GRobjid		comm_loopid = NULL_OBJID;

    sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg,
					&comm_loopid),
			commid, 0, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

    if( (!(ME.EMSedge->ed_props & EMED_DEGENERATE)) &&
        (IF_NULL_OBJID(comm_loopid)))
     {
      IGRint lpcount = 0;

      sts = EMcount_loops(&rc, commid, &lpcount, NULL, NULL, NULL, NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

      if(lpcount == 1)
       {
        sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg,
  	      &comm_loopid), commid, 0, OM_K_MAXINT, NULL, NULL, NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
       }
      else comm_loopid = NULL_OBJID;

      commed_active = FALSE;
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
	    "Common edge inactive", 
	    IF_NULL_OBJID(comm_loopid) ? "Disconnect common edges"
	                               : "Activate the loop", &continu, 
	     &correct, NULL, option, ioptr, NULL);
	
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
       {
	if(IF_NULL_OBJID(comm_loopid))
	 {
	  sts = om$send(msg = message Root.wild_disconnect(chan_to_common), 
				targetid = my_id);
          EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
          sts = om$send(msg = message EMSedge.EMset_props(EMmsg, 
			EMED_SUBORDINATE, EMS_O_OFF),
		      targetid = commid);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
	  ME.EMSedge->ed_props &= ~EMED_SUBORDINATE;
	 }
	else
	 {
          sts = om$send(msg = message EMSloop.EMactivate_loop(EMmsg), 
	        targetid = comm_loopid);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
          commed_active = TRUE;
         }
       }
      else defective = TRUE;
      if (!continu)  goto wrapup;
     }


    sts = om$send(msg = message EMSedge.EMgetsurface_info
          (EMmsg, &comm_surf, NULL), targetid = commid);
    EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

    if( (!(ME.EMSedge->ed_props & EMED_DEGENERATE)) &&
        (IF_NULL_OBJID(comm_surf)))
     {
      commed_active = FALSE;
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
	     "Common edge has no path to its surface", 
	     "Disconnect common edges", &continu, &correct, NULL, 
		 option, ioptr, NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
       {
	sts = om$send(msg = message Root.wild_disconnect(chan_to_common), 
				targetid = my_id);
        EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
        sts = om$send(msg = message EMSedge.EMset_props(EMmsg, 
			EMED_SUBORDINATE, EMS_O_OFF),
		      targetid = commid);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
	ME.EMSedge->ed_props &= ~EMED_SUBORDINATE;
       }
      else defective = TRUE;
      if (!continu)  goto wrapup;
     }

   } /* if(count) */

  if( (*option & EMSvalidateNonSubEdge) && 
      (ME.EMSedge->ed_props & EMED_SUBORDINATE)) ignore_common = TRUE;

   count = 0;
   sts = om$get_channel_objects (object = me,  p_chanselect =
             &chan_to_common, list = &comm, size = 1, count = &count);
   EMomerr_exit (sts, wrapup);
   commid = comm.S_objid;

  if (count && commed_active && !ignore_common)
  {
    sts = om$send(msg = message EMSedge.EMget_props(EMmsg, 
					&partner_props),
		      targetid = commid);
    EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

    if (!(partner_props & EMED_DEGENERATE) && !(partner_props & EMED_SEAM) &&
	!(ME.EMSedge->ed_props & EMED_DEGENERATE) &&
	!(ME.EMSedge->ed_props & EMED_SEAM))
    {
      sts = om$send(msg = message EMSedge.EMtst_xyz_clsd(EMmsg,
				NULL, NULL_OBJID, &mod_info->md_env,
				&is_xyz_closed),
		      targetid = commid);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

      if ((is_xyz_closed && !(partner_props & EMED_XYZ_CLOSED))
				||
          (!is_xyz_closed && (partner_props & EMED_XYZ_CLOSED)))
      {
        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect xyz closure flag on common edge",
		is_xyz_closed ? "Turn the bit on" : "Turn the bit off", 
		&continu, &correct, NULL, option, ioptr, 
		NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if (correct)
        {
          sts = om$send(msg = message EMSedge.EMset_props(EMmsg, 
					EMED_XYZ_CLOSED,
					is_xyz_closed ? EMS_O_ON : EMS_O_OFF),
		      targetid = commid);
          EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

	  if (is_xyz_closed) partner_props |= EMED_XYZ_CLOSED;
	  else partner_props &= (~ EMED_XYZ_CLOSED);	 	  
        }
        else defective = TRUE;
        if (!continu) goto wrapup;
      }
     sts = om$send(msg = message EMSedge.EMtst_reversibility(EMmsg,
					&rev_connect, my_id,
					NULL_OBJID, NULL_OBJID,
					ME.EMSedge->ed_props & EMED_SEAM,
					mod_info),
			targetid = commid);
     EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

     if ((rev_connect && !(ME.EMSedge->ed_props & EMED_REVERSE_CONNECT))
				||
        (!rev_connect && (ME.EMSedge->ed_props & EMED_REVERSE_CONNECT)))
     {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Incorrect reverse connect flag",
		rev_connect ? "Turn the bit on" : "Turn the bit off", 
		&continu, &correct, NULL, option, ioptr, NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct)
      {
	if (rev_connect) ME.EMSedge->ed_props |= EMED_REVERSE_CONNECT;
	else ME.EMSedge->ed_props &= (~ EMED_REVERSE_CONNECT);	 	  

        sts = om$send(msg = message EMSedge.EMset_props(EMmsg, 
					EMED_REVERSE_CONNECT,
					rev_connect ? EMS_O_ON : EMS_O_OFF),
			  targetid = commid);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

	if (rev_connect) partner_props |= EMED_REVERSE_CONNECT;
	else partner_props &= (~ EMED_REVERSE_CONNECT);	 	  
      }
      else defective = TRUE;
      if (!continu) goto wrapup;
     }

    if(!IF_NULL_OBJID(srfid))
     {
      sts = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, &surf_def),
				targetid = srfid);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);
   
      props_0 = surf_def.pos_orient ? 0x1 : 0x0;

      sts = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, &surf_def),
				targetid = comm_surf);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_SurfaceError,wrapup);
   
      props_1 = surf_def.pos_orient ? 0x1 : 0x0;

      if (((ME.EMSedge->ed_props & EMED_REVERSE_CONNECT) &&
					 (props_0 ^ props_1)) ||
        (!(ME.EMSedge->ed_props & EMED_REVERSE_CONNECT) && 
					!(props_0 ^ props_1)))
      {
       sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Bad surface orientations across connection", NULL, 
		 &continu, &correct, NULL, option, ioptr, NULL);
       EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
       defective = TRUE;
       if (!continu) goto wrapup;
      }

     }/* if(!IF_NULL_OBJID(srfid)) */

    if (*option & EMSvalidateEdgeMatch)
    {
      struct IGRbsp_curve	my_geom, partner_geom, *cv;
      IGRdouble			sti_tol;
      IGRint			sample_size, num_misses, num_hits, i;
      IGRdouble			bsovlap0[2], bsovlap1[2];

      my_geom.poles = NULL;
      my_geom.knots = NULL;
      my_geom.weights = NULL;
      my_geom.bdrys = NULL;

      sts = om$send (msg = message EMSedge.EMget_bcxyz_geom (EMmsg,
		   	 &mod_info->md_env, NULL, 
		         (struct IGRbsp_surface *) surf_geom, 0, OM_K_MAXINT,
			ME.EMSedge->ed_props & EMED_REVERSED ? TRUE : FALSE,
				 NULL, &my_geom),   
		     targetid = my_id);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

      partner_geom.poles = NULL;
      partner_geom.knots = NULL;
      partner_geom.weights = NULL;
      partner_geom.bdrys = NULL;

      sts = om$send (msg = message EMSedge.EMget_bcxyz_geom (EMmsg,
		   	 &mod_info->md_env, NULL, NULL, 0, OM_K_MAXINT,
			partner_props & EMED_REVERSED ? TRUE : FALSE,
				 NULL, &partner_geom),   
		  targetid = commid);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

      bsovlap0[0] = bsovlap1[0] = 0;
      bsovlap0[1] = bsovlap1[1] = 1;
      sample_size = 2; /*4;*/
      sti_tol = 2*cht_tol;

      sts = EMvalcv_ovlap(EMmsg, &my_geom, &partner_geom, bsovlap0, bsovlap1,
			 sample_size, &num_hits, &num_misses, sti_tol,
			 NULL, NULL, NULL);
      EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      if (num_misses > num_hits)
      {
        IGRboolean supress = FALSE;
	
        sts = EMvalcv_ovlap(EMmsg, &my_geom, &partner_geom, bsovlap0, bsovlap1,
			 sample_size, &num_hits, &num_misses, sti_tol,
			 EMSvalovlap_DisplayMisses | 
			 EMSvalovlap_WriteMissSummary,
			 NULL, NULL);
        EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);

        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
			"Common-edge does not match", NULL, 
			&continu, &correct, &supress, option, ioptr, NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if(supress) *option &= ~EMSvalidateEdgeMatch;
        defective = TRUE;
        if (!continu) goto wrapup;
      }
    for(i=0; i<2; i++)
     {
      cv = i ? &my_geom : &partner_geom;
      if(cv->poles) om$dealloc(ptr = cv->poles);
      if(cv->knots) om$dealloc(ptr = cv->knots);
      if(cv->weights && cv->rational) om$dealloc(ptr = cv->weights);
     }

    } /* if validate edge match */

   } /* if non deg non seam pair */

  }   /* I have a common edge  */
  else if(!count)
  {
   if((*option & EMSvalidateSolid)&&!(ME.EMSedge->ed_props & EMED_DEGENERATE))
   {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Connectable edge on solid", NULL, &continu, &correct, NULL, 
		option, ioptr, NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      defective = TRUE;
      if (!continu) goto wrapup;
   }
   if (ME.EMSedge->ed_props & EMED_SUBORDINATE)
   {
      sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Unconnected dominant edge",
		    "Make it non dominant", &continu, &correct, NULL, 
		option, ioptr, NULL);
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
      if (correct) ME.EMSedge->ed_props &= (~ EMED_SUBORDINATE);
      else defective = TRUE;
      if (!continu) goto wrapup;
   }
  }  /* I do not have a common edge */


 {
  if (my_classid == OPP_EMSnatedge_class_id)
  {
      if (!(me->ed_props & EMED_NATURAL))
      {
        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Incorrect Natural flag",
		    "Flag it", &continu, &correct, NULL, 
		    option, ioptr, NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if (correct) ME.EMSedge->ed_props |= EMED_NATURAL;
        else defective = TRUE;
        if (!continu) goto wrapup;
      }
  
  } /* if (my_classid == OPP_EMSnatedge_class_id) */

  else if( (sts = om$is_ancestry_valid(subclassid = my_classid, 
		superclassid = OPP_EMSpartedge_class_id)) != OM_S_SUCCESS)
  {
      if (me->ed_props & EMED_NATURAL)
      {
        sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Incorrect Natural flag",
		    "Turn the natural-bit off", &continu, &correct, NULL, 
		   option, ioptr, NULL);
        EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
        if (correct) ME.EMSedge->ed_props &= (~ EMED_NATURAL);
        else defective = TRUE;
        if (!continu) goto wrapup;
      }
  }

 }

  if(ME.EMSedge->ed_props & EMED_MSCEXISTS)
  {
   GRobjid           MSCid = NULL_OBJID;

   sts = om$send(msg = message EMSboundary.EMgetxyzobj(EMmsg,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &MSCid),
                 targetid = my_id);

   if(!(1&*EMmsg&sts)) goto wrapup;

   if(IF_NULL_OBJID(MSCid) || ((sts = om$is_objid_valid(objid = MSCid)) !=
				OM_S_SUCCESS))
    {
     sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Incorrect MSC flag",
           "Turn the bit off", &continu, &correct, NULL, option, ioptr, NULL);
     EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
     if (correct) ME.EMSedge->ed_props &= (~ EMED_MSCEXISTS);
     else defective = TRUE;
     if (!continu) goto wrapup;
    }
  }


  /* Do the active loop validation. In steady state an edge should be owned
     by ONLY one active loop and that active loop MUST be at the last
     index on the edge-to-loop channel.
     SM 22-Jul-92.
  */
  {
   IGRint    num_actlp = 0, num_lp = 0, i, edidx;
   IGRushort lpprops;
   GRobjid   actlp = NULL_OBJID;

   sts = EMcount_loops(&rc, my_id, &num_actlp, NULL, EMLP_ACTIVE, NULL, NULL);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
   if(num_actlp > 1)
    {
     sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		"Edge owned by multiple active loops", NULL, &continu, 
		 &correct, NULL, option, ioptr, NULL);
     EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
     defective = TRUE;
     if (!continu) goto wrapup;
    }
   else if(num_actlp)
    {
     /* Get all the loops. Make sure last loop on the channel is active.
        The 'EMcount_loops' function retuns the loop ids in the REVERSE
        order wrt their channel indices. So the last loop on the edge->loop
        channel will be the first one in the array.
     */
     sts = EMcount_loops(&rc, my_id, &num_lp, &myloops, NULL, NULL, NULL);
     EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
     sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
           targetid = myloops[0].S_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(!(lpprops & EMLP_ACTIVE))
      {
       sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
		   "Incorrect index of active loop on the edge->loop channel",
           "Correct the index", &continu, &correct, NULL, option, ioptr, NULL);
       EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
       if (correct)
        {
	 /* Find the active loop. Disconnect it from me and reconnect it
	    at the last index. It is IMPORTANT to maintain the index of the
	    edge on the loop->edge channel. We are simply changing the index
	    on one side of the channel (the edge->loop side).
	 */
         for(i=0; i<num_lp; i++)
          {
           sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
                 targetid = myloops[i].S_objid);
           if(!(1&*EMmsg&sts)) goto wrapup;
           if(lpprops & EMLP_ACTIVE)
            {
	     actlp = myloops[i].S_objid;
	     break;
            }
          }
         EMerr_hndlr(IF_NULL_OBJID(actlp), *EMmsg, EMS_E_Fail, wrapup);
     
         /* Store edge index, to reuse.
         */          
         sts = om$get_index(objid_c = actlp, p_chanselect = &to_loop_comps, 
               objid = my_id, indexaddr = (OMuint *)&edidx);
         if(!(1&sts)) goto wrapup;

         sts = om$send(msg = message Root.disconnect(to_loop_comps, my_id, 
               OM_Gw_current_OS, chan_to_owner), targetid = actlp);
         if(!(1&sts)) goto wrapup;

         /* Reconnect
         */
         sts = om$send(msg = message Root.connect(to_loop_comps, MAXINT, 
               my_id, OM_Gw_current_OS, chan_to_owner, edidx), 
               targetid = actlp);
         if(!(1&sts)) goto wrapup;
        }
       else defective = TRUE;
       if (!continu) goto wrapup;
      }
    }
  }

 if((ME.EMSedge->ed_props & EMED_NATURAL) && (ME.EMSedge->ed_props & EMED_ISO))
  {
   sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
         "Incorrect Iso flag on a natural edge",
         "Turn the Iso bit off", &continu, &correct, NULL, 
		   option, ioptr, NULL);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
   if (correct) ME.EMSedge->ed_props &= (~ EMED_ISO);
   else defective = TRUE;
   if (!continu) goto wrapup;
  }

wrapup :

 if(myloops) om$dealloc(ptr = myloops);
 if(!(1&*EMmsg&sts))
  {
   sts = EMvalidate_io(EMmsg, mod_info, &my_GRid, obj_info, 
 	 "Error in validation", NULL, &continu, &correct, NULL, option, ioptr,
	  NULL);
   defective = TRUE;
   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
  }

  if(defective)
   {
    *cancer = my_id;
    *EMmsg = EMS_I_EdgeError;
   }
  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMvalidate")
  if(!continu || (*EMmsg == EMS_I_Interrupt)) 
   {*EMmsg = EMS_I_Interrupt; return (OM_I_STOP_SENDING);}
  else return (sts);
}


end implementation EMSedge;
