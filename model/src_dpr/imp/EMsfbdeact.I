/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;
/*
Description
    This method will deactivate me if I am an active state.  This is
    done by changing topology and/or geometry I have saved with what
    is currently active.

Algorithm
    Get the SSI table.
    Take out in_loops if option == EMS_UNDO_SAVE else delete them.
    Put in out_loops.
    Put in out_surfaces at composite_index.
    Set properties in the surfaces ON.
    If option==EMS_UNDO_SAVE set my active bit OFF else delete
    myself.

Returned values
    EMS_S_SUCCESS if all is well.

History
    12/20/93    WBC Added another validity check to make sure sf_out objects
                    were actually surfaces (TR#119309313).
    04/06/92    SM  Pass &partolbasis.tol instead of &partolbasis to
                    EMSsubbs.EMpartolbasis
    03/24/92    SM  While dealing with loops removed and added
		    skip any invalid oids encountered. Erroring out halfway
		    through is going to hose the model anyway, so skipping
		    invalid oids may actually help. 
    03/03/92    DLB Added EFfix_parent_child_relationship call to fix up
                    assoc graph when an associative surface is removed.
    05/23/89    DLB Removed the RI deletion code.  This will be done via
                    the EMrecomputeinfodelete message sent by EMundo.  The
                    main reason for such a change is that the unevaluation
                    code sends a deactivate with delete option but wants to
                    keep all recompute info.

    18 Apr 1989 jBk Added boolean variable "display" to cut down on
                    pointer dereferencing and bitwise operations.

                    Differentiation between EMjoiningDeactivate and
                    EMdisjointDeactivate removed to make EMdeactivate
                    handle both now that SSI tables are returned
                    consistently from EMgetSSI, whether or not the
                    internal representation of the SSI table is
                    consistent in the instance data of the object.

    28 Dec 1988 jBk Fixed mistake in conversion from explicit
                    assignment of a message to the usage of
                    om$make_message.

    13 Sep 1988 AIC Replaced explicit assignment of message to
                    om$make_message.

    07/26/88    DLB Added code to (re)set surface bit to inactive.
    06/01/88    DLB I did something but I don't remember what!!
    14-Apr-1988 jBk Use EMget_operation_type to determine if an
                    orientation reversal is necessary.
                    Subdivided into EMactivate, EMjoiningActivate and
                    EMdisjointActivate.
    03/08/88    DLB Modified for selective display.
    04-Dec-1987 jBk Added orientation reversal for EMSbool_hollowDif.
    11/05/87    DLB Modified for version 1.1.0.
    29-Jul-1987 SM  Added check for EMSbool_saveside and deletion of
                    plane for the same.
    04/??/87    DLB Take care of reverse orient for difference
                    operation and SSI changes.
    ??-???-1987 SM  Creation date.
*/

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"

/* DPR_DISPLAY_BUFF_INCR */
#include "emsdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from EMSloop import EMtreemod,EMgivenestinfo,EMactivate_loop;
from EMSsubbs import EMpartolbasis, EMpassloop;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset import EMnesting,EMtreemod, EMtoglpactive;
from EMSloop import EMset_props;

extern OMuword OPP_EMSsfboolean_class_id, OPP_EMSsolid_class_id;
extern OMuword OPP_EMSloop_class_id, OPP_EMSsurface_class_id;

method EMjoiningDeactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids;
    IGRint *display_count
)
{
    *EMmsg = EMS_E_Fail;

    return OM_E_MSGNOTSUPP;
}

method EMdisjointDeactivate (
    IGRlong *EMmsg;
    struct GRmd_env *env;
    IGRshort option;
    IGRboolean emptySet, firstOnly, allButFirst, lastOnly
)
{
    *EMmsg = EMS_E_Fail;

    return OM_E_MSGNOTSUPP;
}

#include "grdpbdef.h"
#include "grdpbmacros.h"

method EMdeactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                       sts, *owner_index, msg_loc;
  IGRint                        i,j;
  GRobjid                       *lp_in,*lp_out,lpset,*sf_out,
                                planeid = NULL_OBJID;
  union EMSssi_table            *ssi;
  struct EMSboolssi_table       *my_info;
  union EMSri_table             *ri = NULL;
  enum EMSbooltype              exact_type;
  struct EMSnest_info           nesting;
  struct GRid                   owner_GRid;
  OM_S_CHANSELECT               to_loopset,to_comps;
  struct EMSpartolbasis         partolbasis;
  IGRboolean                    world, delete;
  IGRushort             	props, ls_props, lp_props, ed_props;
  IGRboolean display;
  IGRboolean                    reverseOrientation, disjointSurfaces, emptySet;
  OMuword                       dumosnum;
  struct GRmd_env 		disenv;
  IGRint 			env_size=sizeof(struct GRmd_env), nret;
  OM_S_OBJECT_LINKAGE	        *actlps = NULL;
    
  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  ssi = NULL;
  ri = NULL;

  gr$get_display_env(msg = &msg_loc,
                     sizbuf = &env_size,
                     buffer = &disenv,
                     nret = &nret);
  if (!(1&msg_loc)) goto wrapup;

  delete = (*option&EMS_UNDO_SAVE) ? FALSE : TRUE;
  display = *option & EMS_DO_DISPLAY;
  owner_GRid.objid = my_id;
  owner_GRid.osnum = OM_Gw_current_OS;

  sts = om$send (
    msg = message EMSsfboolean.EMget_operation_type (
        EMmsg,
        NULL,
        &exact_type,
        NULL,
        &reverseOrientation,
        &emptySet,
        &disjointSurfaces,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    ),
    targetid = my_id
  );

  if (EMSerror (sts) OR EMSerror (*EMmsg))
  {
    sts = OM_E_ABORT;
    *EMmsg = EMS_E_Fail;
    goto wrapup;
  }

  sts = om$make_chanselect(channame="EMSsubbs.to_loopset",
                           p_chanselect=&to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  sts = om$make_chanselect(chanaddr=&ME.GRcmpowner->to_components,
                           p_chanselect=&to_comps);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  /*Send a message to myself to get the SSI table.-DLB*/
  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  if (emptySet)
  {
    /* disconnect, deactivate, undraw and save null symbol id */

    struct GRid nullSymbolGRid;
    IGRint nsgCount;

/*
    send wrt message for class EMScomposite because I
    do not want the EMSsfdpr implementation of this
    message; that is, I do not necessarily want
    leaves but actual children 
*/

    sts = om$send (
        mode = OM_e_wrt_message,
        msg = message EMScomposite.GRget_components (
            EMmsg,
            env,
            &nullSymbolGRid,
            1,
            &nsgCount,
            0,
            OM_K_MAXINT
        ),
        targetid = my_id
    );

    if (EMSokay (sts) AND EMSokay (*EMmsg) AND nsgCount IS 1)
    {
        /* got id */

        sts = om$send (
            msg = message GRconnector.GRdisconn (
                EMmsg,
                &owner_GRid
            ),
            targetid = nullSymbolGRid.objid
        );

        if (EMSokay (sts) AND EMSokay (*EMmsg))
        {
            /* disconnected */

            if (NOT delete) me^^EMSdpr.ids[0] = nullSymbolGRid.objid;

            if (display)
            {
                enum GRdpmode eraseNS = GRbehe;

                sts = om$send (
                    msg = message GRgraphics.GRdisplay (
                        EMmsg,
                        &disenv.md_env.matrix_type,
                        disenv.md_env.matrix,
                        &eraseNS,
                        &disenv.md_id
                    ),
                    targetid = nullSymbolGRid.objid
                );

            } /* fi display */

        } /* fi disconnected */

        if (EMSokay (sts) AND EMSokay (*EMmsg))
        {
            /* delete or set properties */

            if (delete)
            {
                sts = om$send (
                    msg = message GRgraphics.GRdelete (
                        EMmsg,
                        env
                    ),
                    targetid = nullSymbolGRid.objid
                );
            }
            else
            {
                IGRshort on_off = FALSE;
                IGRshort props =
                    GRIS_LOCATABLE | GRIS_DISPLAYABLE;

                sts = om$send (
                    msg = message GRvg.GRchgprops (
                        EMmsg,
                        &on_off,
                        &props
                    ),
                    targetid = nullSymbolGRid.objid
                );
            }

        } /* fi delete or set properties */

    } /* fi got id */

    if (NOT (EMSokay (sts) AND EMSokay (*EMmsg) AND nsgCount IS 1))
    {
        sts = OM_E_ABORT;
        *EMmsg = EMS_E_Fail;
    }

  } /* fi disconnect, deactivate, undraw and save null symbol id */

  /*Take out the 'in_loops' from the corresponding loopsets if the
   * option is SAVE. Else delete them.
   */
  my_info = &ssi->bool_info;
  lp_in = my_info->region_in_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;

  if (display && 
      exact_type == EMSbool_saveside &&
      EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                        OPP_EMSsolid_class_id, FALSE))
  {
    /*Got a solid ipss so the plane is on the channel*/
    planeid = NULL_OBJID;
    sts = om$get_objid_at_index(object = me,
                                p_chanselect = &to_comps,
                                index = 1,
                                objidaddr = &planeid,
                                osnumaddr = &dumosnum);
    if (planeid != NULL_OBJID)
    {
      if (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)
      {
        /*I'm unevaluated so erase the saveside plane.*/
        enum GRdpmode display_mode = GRbehe;   /*DECLARE*/
 
        sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                            &disenv.md_env.matrix_type, 
                            disenv.md_env.matrix, &display_mode,
                            &disenv.md_id),
                      targetid = planeid);
        EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
      }
      else if (!delete) planeid = NULL_OBJID;
    }
  }

  for(i=0;i<my_info->num_surfaces;i++)
   {
    if (!EFisAncestryValid(EMmsg, my_info->surface_ids[i], 
	    OM_Gw_current_OS, OPP_EMSsurface_class_id, TRUE))
     {
      lp_in += my_info->num_regions_in[i];
      continue;
     }

     /*Erase the surfaces that will be modified by the deact -DLB*/
     if (display)
     {
       IGRint     inx;                  /*DECL*/
       IGRboolean got_it = FALSE;

       /*Has this surface already been erased?*/
       for (inx=0; inx<*display_count; inx++)
       {
         if ( (*display_ids)[inx] == my_info->surface_ids[i] )
         {
            got_it = TRUE;
            break;
         }
       }

       if ( (!got_it) && (EFisAncestryValid(EMmsg, my_info->surface_ids[i], 
	    OM_Gw_current_OS, OPP_EMSsurface_class_id, TRUE)))
       {    
         enum GRdpmode display_mode = GRbehe;   /*DECLARE*/

         /*Have a surface not yet erased.*/          
         sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                             &disenv.md_env.matrix_type, 
                             disenv.md_env.matrix, &display_mode,
                             &disenv.md_id),
                       targetid = my_info->surface_ids[i]);
         EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
 
         /*Store this surface that was erased (modified) -DLB*/
         /* Note that the plane id was gotten from above.*/
         if (my_info->surface_ids[i] != planeid)
         {
           EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                               BUFF_INCR, sizeof(GRobjid));
           if (!(1 & *EMmsg)) goto wrapup;

           (*display_ids)[*display_count] = my_info->surface_ids[i];
           (*display_count)++;
         }
       }    
     }

     ls_props = NULL | EMLS_NATURAL;
     if(my_info->num_regions_in[i])
      {
        sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                      senderid=my_info->surface_ids[i],
                      p_chanselect=&to_loopset);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
      }
     for(j=0;j<my_info->num_regions_in[i];j++)
      {
       if (!EFisAncestryValid(EMmsg, *lp_in, OM_Gw_current_OS, 
	   OPP_EMSloop_class_id, TRUE))
        {
	 lp_in++;
	 continue;
        }

        sts = om$send(msg=message EMSloop.EMtreemod
                          (EMmsg,&nesting,(delete?DELETE:EXTRACT),NULL),
                      targetid = *lp_in);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);*/

        if (!delete)
         {
           IGRshort prop_option = EMS_O_OFF;
 
           props = EMLP_ACTIVE;
           sts = om$send(msg = message EMSloop.EMset_props(EMmsg, props,
                              prop_option),
                        targetid = *lp_in);
           /*if (! (1 & sts & *EMmsg)) goto wrapup;*/
         }
        lp_in++;
      }

      /*After taking out the loops added by this state a loopset may become
       * natural again. The bit of such loopsets need to be set ON again.
       */
      if(my_info->num_regions_in[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                             (EMmsg, &ls_props, &lp_props, &ed_props), 
                       targetid = lpset);
         /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);*/
       }

   } /*  for(i=0;i<my_info->num_surfaces;i++) */

  /*Put in the 'out_loops' into the respective loopsets*/
  lp_out = my_info->region_out_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;

  for(i=0;i<my_info->num_surfaces;i++)
   {
    if (!EFisAncestryValid(EMmsg, my_info->surface_ids[i], 
	    OM_Gw_current_OS, OPP_EMSsurface_class_id, TRUE))
     {
      lp_out += my_info->num_regions_out[i];
      continue;
     }

     ls_props = NULL | EMLS_NATURAL;
     if(my_info->num_regions_out[i])
      {
        world = TRUE;
        partolbasis.tol = 0.00000001;
        sts = om$send(msg=message EMSsubbs.EMpartolbasis
                         (EMmsg,&env->md_env.matrix_type,env->md_env.matrix,
                          &world,FALSE,&partolbasis.tol),
                      targetid = my_info->surface_ids[i]);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);*/

        partolbasis.mattyp = &env->md_env.matrix_type;
        partolbasis.mat = env->md_env.matrix;
        partolbasis.in_world = TRUE;
        partolbasis.is_valid = TRUE;
        sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                      senderid=my_info->surface_ids[i],
                      p_chanselect=&to_loopset);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);*/
      }

     for(j=0;j<my_info->num_regions_out[i];j++)
      {
       IGRboolean activate = TRUE;
       GRobjid thislp, thised;
       GRspacenum thisedos;
       OMuint num_edges = 0;
       IGRint idx, num_actlps = 0, inx;
       IGRlong rc;
       OM_S_CHANSELECT	    to_edges;

       if (!EFisAncestryValid(EMmsg, *lp_out, OM_Gw_current_OS, 
	   OPP_EMSloop_class_id, TRUE))
        {
	 lp_out++;
	 continue;
        }

       /* The activate loop message was being sent indiscriminately to all 
          loops added by this node. If one of these loops is later taken out
          by some other operation, activating it here is incorrect. Added a 
          check to activate a loop only if none of its edges are currently 
          owned by some other active loop. This possibility exists only if 
          there is a owner.
          SM 4/27/93
       */
       EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);

       thislp = *lp_out;
	
       sts = om$get_channel_count(objid = thislp, 
             p_chanselect = &to_edges, count = &num_edges);
       EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);
       for(idx = 0; idx<num_edges; idx++)
        {
         sts = om$get_objid_at_index(objid = thislp, 
	       p_chanselect = &to_edges, index = idx, objidaddr = &thised,
	       osnumaddr = &thisedos);
         EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

         /* How many active loops own this edge?
         */
         if(actlps) om$dealloc(ptr = actlps);
         actlps = NULL;
         num_actlps = 0;

         sts = EMcount_loops(&rc, thised, &num_actlps, &actlps, 
               EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_LoopError,wrapup);

         for(inx = 0; inx<num_actlps; inx++)
          if(!IF_EQ_OBJID(thislp, actlps[inx].S_objid))
           {
	    activate = FALSE;
	    break;
           }
         if(!activate) break;

        } /* for(idx = 0; idx<num_edges; idx++) */

       if(activate)
        sts = om$send(msg = message EMSloop.EMactivate_loop(EMmsg),
                         targetid = *lp_out);

        sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
                      targetid= *lp_out);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);*/
        sts = om$send(msg=message EMSloopset.EMnesting
                          (EMmsg,&nesting,&partolbasis),
                      targetid=lpset);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);*/
        if(IF_EQ_OBJID(lpset,nesting.parent))
          sts = om$send(msg=message EMSloopset.EMtreemod
                            (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = lpset);
        else
          sts = om$send(msg=message EMSloop.EMtreemod
                            (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = nesting.parent);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);*/

        lp_out++;

      } /* for(j=0;j<my_info->num_regions_out[i];j++) */


     /* After all the loops have been put back in the corresponding
      * loopset can become natural again. If so the bit needs to be set ON.
      */ 
     if(my_info->num_regions_out[i])
      {
        sts = om$send(msg = message EMSboundary.EMcheck_props
                            (EMmsg, &ls_props, &lp_props, &ed_props), 
                      targetid = lpset);
        /*EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);*/
      }

   } /* for(i=0;i<my_info->num_surfaces;i++) */

  /*
   * If the Boolean operation is one of the following, the
   * right-hand operands need to have their surfaces' orientation
   * reversed in sense.
   */

  if (reverseOrientation && !(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    sts = om$send (
        msg = message EMSsurface.EMrevorient (EMmsg), 
        p_chanselect = &to_comps,
        from = 1
    );

    /*EMerr_hndlr (!(1 & sts & *EMmsg), *EMmsg, *EMmsg, wrapup);*/
  }

  /*Put in the 'out_surfaces' and make them locatable and displayable.
   * NOTE:
   *       DUE TO THE FACT THAT THE SURFACES MUST BE CONNECTED AT THE 
   *       PROPER OWNERS INDEX, CARE MUST BE EXERCISED WHEN RECONNECTING
   *       THE SURFACES.  NAMELY, SINCE THE OWNERS CHANNEL IS A RELATIVELY
   *       ORDERED CHANNEL, THE SURFACES MUST BE CONNECTED IN THE REVERSE
   *       ORDER THAT THEY WERE REMOVED.  THIS REQUIRES THAT THE ARRAY OF
   *       SURFACE OUT IDS BE TRAVERSED FROM END TO BEGINNING. 
   */

  /*Find the total number of surfs removed.*/
  j = 0;
  for (i = 0; i < my_info->num_composites; i ++)
    j += my_info->num_surfaces_out[i];

  sf_out = &my_info->surface_out_ids[j-1];
  owner_index = (IGRlong *) &my_info->composite_indices[j-1];

  for(i=my_info->num_composites-1; i>=0; i--)
   {
     owner_GRid.objid = my_info->composite_ids[i];     

     for(j=my_info->num_surfaces_out[i]-1; j>=0; j--)
      {
        if (!EFisAncestryValid(EMmsg, *sf_out, OM_Gw_current_OS,
                               OPP_EMSsurface_class_id, TRUE))
        {
            owner_index--;
            sf_out--;
            continue;
        }

        if (NOT disjointSurfaces)
        {
            /*
                set all the loops in the removed surface to
                active; we do not do this for disjoint surfaces
                because theirs are never toggled to be inactive
            */

            sts = om$send(msg = message EMSsubbs.EMpassloop(EMmsg, 
                            message EMSloopset.EMtoglpactive(EMmsg)),
                          targetid = *sf_out);
            /*EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);*/
        }

        /*Reconnect removed surfaces at proper owners index.*/
        sts = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                            &owner_GRid, owner_index),
                      targetid = *sf_out);
        /*EMerr_hndlr(!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);*/

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_ON);
        /*EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);*/

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              owner_GRid.objid, 
                                              OM_Gw_current_OS, FALSE, NULL);
        /*if (!(1 & sts & *EMmsg)) goto wrapup;*/

        if (display)
        {
          /*Store the out ids in the array.*/
         
          EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                              BUFF_INCR, sizeof(GRobjid));
          /*if (!(1 & *EMmsg)) goto wrapup;*/

          (*display_ids)[*display_count] = *sf_out;
          (*display_count)++;
        }

        owner_index--;
        sf_out--;
      }
   }

  wrapup:
    if(actlps) om$dealloc(ptr = actlps);
    if (ssi) om$dealloc(ptr = ssi);
    if (ri) om$dealloc(ptr = ri);
    EMWRAPUP(*EMmsg,sts,"In EMSsfboolean.EMdeactivate")
    *EMmsg = EMS_S_Success;
    return(OM_S_SUCCESS);
}

end implementation EMSsfboolean;
