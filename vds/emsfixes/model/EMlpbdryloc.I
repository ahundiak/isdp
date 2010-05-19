/* $Id: EMlpbdryloc.I,v 1.1 2001/08/25 14:41:06 ramarao Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vds/emsfixes/model/EMlpbdryloc.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: EMlpbdryloc.I,v $
 *      Revision 1.1  2001/08/25 14:41:06  ramarao
 *      Fixed a locate problem TR# 5355.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/25/01        Rama Rao        Fixed locate problem. TR# 5355.
 ***************************************************************************/
/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This implementaton can be invoked stand-alone or by the loop/loopset of
    which this loop is a child. Depending on the option specified, the
    requisite locate operation is performed - primarily, whether this is a hit
    or miss, location (and possible creation) of the model-space counterpart,
    and location of this loop itself.

  BUGS

    EMSlcopt_uvelem option returns the correct objid/osnum of this loop. The
     rest of the data in the locate structure is junk.
    Only top-down processing is done.

  HISTORY

    AMD :  08/16/92  :  Added support for location of loops with seam
                        edges, when the LOCATE_LOOP option is set
    AMD :  09/11/91  :  Added support for direct location of loops.
                        Filtering out already located loops is done
                        here.
    WBC :  04/30/91  :  If an associative model-space counterpart exists in
                        the same object space as the loop, use it.
    WBC :  04/25/91  :  Now constructing the associative model-space
                        counterparts in the "active" module space instead of
                        the module space the loop is in (because of reference
                        files).
    SA  :  05/10/90  :  Modified to process additional return codes
			from EMlocatecvbuffs() to handle odd behavior of
			action-handler when "auto-accept" is enabled during
			locate.
    SM  : 12-Dec-89  :  If option is 'hit or miss' ignore error causing edges
			in the hope of causing a hit with some other
			edge. This is to allow the surface to be located
			inspite of the edge errors.
    PP  : 10/12/89   :  Changed arguments to EMloop_eligible.
    PP  : 09/20/89   :  Loop eligibility is determined by calling a function
                        which looks at information stored in the DPB 
                        instead of looking at a static flag.
    SS  :  06/21/89  :  Taking care of reference file attached edges. The
                        problem was that in EMlocatecvbuffs, transient OS
                        was not recognized as a reference file attachment
                        and the display would not be honored if this
                        edges level was off in that window for the master file.
    SS  :  12/06/88  :  Modified so that on model-space-element locate,
			if a model-space counterpart is present, it is
			used dierectly in the locate.
    SS  :  05/10/88  :  Modification  to support the location of the loop
                         and it's model-space countepart.
    SS  :  03/27/88  :  Creation
*/

class implementation EMSloop;

#include "EMS.h"
#include "msdef.h"
#include "emsdef.h"
#include "EMSlcdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "EMSaction.h"

/*
 * This constant is an estimate of the maximum number of edges that
 * will be found in loops. This number is used to define arrays to hold
 * edge information. If the number of edges exceeds this number then
 * mallocs will have to ne performed for the arrays.
 */

#define MAX_EDGE_COUNT 10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern IGRlong EFlocate_action_handler();

extern OMuword OPP_EMSgraloop_class_id;

from EMSedge import EMget_props_type, EMget_bcxyz_geom;

method EMbdrylocate (IGRlong *msg; struct EMSsfinfo *sfinfo;
                     struct EMSlcinput *lcin;
                     struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key;
                     struct EMSlcoutput *lcout)
{
  IGRboolean stopproc, lpreverse, procloop, hit, refattach;
  IGRboolean (*user_eligfunc)();
  IGRuchar cvtypes_mem[MAX_EDGE_COUNT], *cvtypes;
  IGRushort options, edprops;
  OMuint edcount;
  IGRint i, j, relinx;
  IGRlong stat_OM, msg_loc, lcmsg, temp_msg, *cvlmsg;
  IGRlong sizebuffer, nbytes_ret;
  GRobjid cvobj;
  struct IGResbc esbc;
  struct IGRbsp_curve edcvs_mem[MAX_EDGE_COUNT], *edcvs;
  struct EMSboundary_EMbdrylocate_Msg bdryloc_args;
  struct EMSedge_EMget_props_type_Msg getprops_args;
  struct EMSedge_EMget_bcxyz_geom_Msg bcxyz_args;
  struct GRid *lpcvobj, lpcvobj_mem;
  struct GRid my_GRid;
  struct GRmd_env module_env;
  OM_S_CHANSELECT chan_to_inner;
  OM_S_CHANSELECT chan_to_comps;
  OM_S_MESSAGE messg1, messg2;
  void EMchglocobj(), EMchgstkobj();
  extern IGRboolean EMlocatecvbuffs(), EMhitcvbuff();
  extern IGRboolean EMloop_eligiblen();
  extern IGRboolean EFloop_curves_locatable();
  extern IGRlong GRcheckref();
  OMuword               my_classid;
  IGRboolean locate_seam_edge = FALSE;

  /*
   * Initialize some of the local 
   * variables.
   */

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  cvtypes = NULL;
  edcvs = NULL;
  for (i=0; i<MAX_EDGE_COUNT; i++)
    {
    edcvs_mem[i].poles = NULL;
    edcvs_mem[i].knots = NULL;
    edcvs_mem[i].weights = NULL;
    }

  chan_to_comps.type = OM_e_addr;
  chan_to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;

  stat_OM = om$get_channel_count (object = me, 
             p_chanselect = &chan_to_comps, count = &edcount);
  EMomerr_exit (stat_OM, ret_end);

  /* AMD  :   09/11/91 */ 

  if (cvl->action_handler == ((IGRint (*) ())EFlocate_action_handler))
  {
   struct EMSaction_handler     *do_not_locate=NULL;

   do_not_locate = (struct EMSaction_handler *) cvl->act_parms;
   if ((do_not_locate->option == LOCATE_LOOP) 
                    && (do_not_locate->num_objects))
    {
     for (i=0; i<do_not_locate->num_objects; i++)
      if(( do_not_locate->objects.id[i].objid == my_id ) &&
         ( do_not_locate->objects.id[i].osnum == OM_Gw_current_OS))
              goto ret_end;
     }
    if (do_not_locate->option == LOCATE_LOOP) 
                         locate_seam_edge = TRUE;
   }
      
  /*
   * Process this loop. This only if this message is being sent
   * to locate a boundary element and loop-locate flag is on.
   * Also, only process if not an ancestor of EMSgraloop.
   */
  stat_OM = om$get_classid( objid = my_id,
                            p_classid = &my_classid );    

  if((stat_OM = om$is_ancestry_valid(subclassid = my_classid, 
                superclassid = OPP_EMSgraloop_class_id))!= OM_S_SUCCESS)
   {
  options = lcin->options;
  if  (EFloop_curves_locatable() &&
      (options & EMSlcopt_xyzelem || options & EMSlcopt_uvelem))
    {
    /*
     * The request is to explicitly locate an element and process
     * it for return, as the located element. 
     */

    user_eligfunc = lcin->eligfunc;
    if ((user_eligfunc ? 
         (*user_eligfunc) (my_id, cvl, lcin->eligfunc_args) : 
         EMloop_eligiblen (options, edcount, me->lp_props, cvl->classes,
         &my_GRid)))
      {
      /*
       * This loop has passed the filtering test and is eligible.
       * Obtain the model-space geometries of all the edges of this
       * loop. Get the curve types too. If the locally allocated array
       * is not big enough to handle the number of edges, malloc the 
       * space for it.
       */

      if (edcount > MAX_EDGE_COUNT)
        {
        edcvs = (struct IGRbsp_curve *) om$malloc (size = edcount *
                 sizeof (struct IGRbsp_curve));
        cvtypes = (IGRuchar *) om$malloc (size = edcount *
                   sizeof (IGRuchar));
        EMerr_hndlr (!cvtypes || !edcvs, *msg, EMS_E_NoDynamicMemory,
         ret_end);

        for (i=0; i<edcount; i++)
          {
          edcvs[i].poles = NULL;
          edcvs[i].knots = NULL;
          edcvs[i].weights = NULL;
          }
        }
      else
        {
        edcvs = edcvs_mem;
        cvtypes = cvtypes_mem;
        }

      getprops_args.EMmsg = &msg_loc;
      getprops_args.props = &edprops;
      stat_OM = om$make_message (classname = "EMSedge", 
                 methodname = "EMget_props_type", 
                 size = sizeof (getprops_args), p_arglist = &getprops_args,
                 p_msg = &messg1);
      EMomerr_exit (stat_OM, ret_end);

      bcxyz_args.EMmsg = &msg_loc;
      bcxyz_args.mdenv = &cvl->module.md_env;
      bcxyz_args.srf_id = &sfinfo->id;
      bcxyz_args.srf_geom = sfinfo->geom;
      bcxyz_args.from_spaninx = 0;
      bcxyz_args.num_spans = MAXINT;
      bcxyz_args.reverse = FALSE;
      bcxyz_args.partinfo = NULL;
      stat_OM = om$make_message (classname = "EMSedge", 
                 methodname = "EMget_bcxyz_geom", 
                 size = sizeof (bcxyz_args), p_arglist = &bcxyz_args,
                 p_msg = &messg2);
      EMomerr_exit (stat_OM, ret_end);

      procloop = TRUE;
      lpreverse = ME.EMSloop->lp_props & EMLP_REVERSED;
      for (i=0, j=edcount-1; i<edcount; i++, j--)
        {
        relinx = lpreverse ? j : i;

        getprops_args.type = &cvtypes[i];
        stat_OM = om$send (msg = &messg1, p_chanselect = &chan_to_comps,
                   from = relinx, to = relinx);
        EMomerr_exit (stat_OM, ret_end);

        /*
         * If any of these edges is a seam-edge, the model-space counterpart
         * composite cannot be formed. The reasoning for this is as
         * follows: The seam edges are not really edges but more like 
         * rule lines. Therefore, should not be handled here. Without
         * these edges, the loop does not make sense.
         */

        if ((edprops & EMED_SEAM) && (!locate_seam_edge))
          procloop = FALSE;

        bcxyz_args.curve = &edcvs[i];
        stat_OM = om$send (msg = &messg2, p_chanselect = &chan_to_comps,
                   from = relinx, to = relinx);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        }

      /*
       * If it has been determined that this loop should not be processed,
       * continue the processing with the edges. Else, of course, process
       * this loop.
       */

      if (!procloop)
        goto edges_send;

      /*
       * Check if there is a hit on this loop at all. If not, proceed
       * to process the inner loops, if any.
       */

      hit = FALSE;
      for (i=0; i<edcount; i++)
        {
        hit = EMhitcvbuff (&msg_loc, &edcvs[i], cvtypes[i], cvl, lcin,
               lcout);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        if (hit)
          break;
        }
      if (!hit)
        goto inner_send;

      /*
       * Call the function that would invoke the action-handler and
       * select-handler for curve-buffers. If xyz-element locate is on
       * and this loop has a model-space counterpart, pass that to the
       * function. If this edge is in a reference file attachment,
       * construct the model-space counterpart and then pass that to the
       * function. This is done so that the display mechanism (for
       * accept/reject can recognize this object as in a reference file
       * attachement and can behave the way it behaves for such attachements).
       * The current module environment is sent to EMgetxyzobj because it
       * is used to get the geometry of the edge in the context the edge
       * exists in.
       */

      esbc.is_polydis = FALSE;
      esbc.is_curvedis = TRUE;

      sizebuffer = sizeof(struct GRmd_env);
      gr$get_module_env(msg = &msg_loc,
                        sizbuf = &sizebuffer,
                        buffer = &module_env,
                        nret = &nbytes_ret);

      GRcheckref(&temp_msg, &cvl->module.md_env.matrix_type,
                 cvl->module.md_env.matrix, NULL, &OM_Gw_current_OS);
      if (temp_msg == MSSUCC)
        refattach = TRUE;
      else
        refattach = FALSE;

      if (refattach ||
          (options & EMSlcopt_xyzelem &&
           ME.EMSloop->lp_props & EMLP_MSCEXISTS))
        {
        lpcvobj_mem.osnum = OM_Gw_current_OS;
        stat_OM = om$send (msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                   NULL, &module_env.md_env, edcvs, cvtypes,
                   &sfinfo->symb, &esbc, lpcvobj_mem.osnum,
                   &lpcvobj_mem.objid), targetid = my_id);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

	/* Following Error check is done for TR# 5355 - Rama Rao */
        EMerr_hndlr(IF_NULL_OBJID(lpcvobj_mem.objid), *msg, 
                        EMS_E_EdgeError, ret_end);
        lpcvobj = &lpcvobj_mem;
        }
      else
        lpcvobj = NULL;

      lcin->options |= EMSlcopt_skipgeomchk;
      stopproc = EMlocatecvbuffs (&lcmsg, edcount, edcvs, lpcvobj, cvtypes, 
                  &sfinfo->symb, &esbc, cvl, range_key, lcin, lcout);
      lcin->options &= ~EMSlcopt_skipgeomchk;
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      /*
       * If user acceptance is detected, return the model-space
       * counterpart (which may have to be created if one did not exist) or
       * return this loop id itself, whichever is indicated by the options.
       */
	/* Added two more message keys. These can be returned when locate
	   is on "auto-accept" mode.

	   EMS_I_FoundOther: This is returned when the user accepts another
			     object which was picked up by the action-handler
			     from stack.
	   EMS_I_AutoStk   : This is returned when the action handler just 
	   		     puts the object on stack. 
							- Ashok -
	*/

      if (lcmsg == EMS_I_Found      || lcmsg == EMS_I_Interrupt || 
	  lcmsg == EMS_I_FoundOther || lcmsg == EMS_I_AutoStk)
        {
        /*
         * This loop has either been accepted by the user or the locate
         * accept/reject cycle has been stacked. Process to change
         * the located object-id or the locate-stack to reflect the
         * correct object.
         */
   
        if (options & EMSlcopt_xyzelem)
          {
          /*
           * This loop's model-space counterpart must be returned as a
           * GRcompcurve object. Send a message to obtain my model-space
           * couterpart if one currently exists or create one.
           */

          stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj (&msg_loc,
                             NULL, &module_env.md_env, edcvs,
   		             cvtypes, &sfinfo->symb, &esbc, OM_Gw_current_OS,
                             &cvobj), targetid = my_id);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

          if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther)
            {
            /* User has accepted this composite curve. In the GRlc_info
             * structure, replace the located-object id with the new one
             * just obtatined and post it into the cvl-structure for return.
             */
	    /* Modified to do the above only when the accepted object is
	       myself (ie my counterpart). This check is required because
	       a stacked object could have been accepted by the user.
								     -Ashok-
	    */
	    if(lcmsg == EMS_I_Found)
	      {
              lcout->locobj.located_obj.objid = cvobj;
              lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
              EMchglocobj (&msg_loc, cvl, 1, &lcout->locobj);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	      }
            *msg = EMS_I_Found;
            }
          else
            {
            /*
             * The accept/reject is not yet complete. Replace the temporary
             * (shell) object in the locate-stack of the locate-argument
             * with the more permanent "cvobj". After this point control
             * does not return here but continues with the GRlocate message
             * of the "cvobj" if the command was interrupted. After that 
	     * point control is back with the command-object.
             */
            lcout->locobj.located_obj.objid = cvobj;
            lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
            EMchgstkobj (&msg_loc, cvl, &lcout->locobj);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if(lcmsg == EMS_I_Interrupt) *msg = EMS_I_Interrupt;
            }
          }
        else
          {
          /*
           * The object to be returned as the located object is this
           * loop itself. So change the located-object in the cvl-structure
           * to reflect this. The entire GRlc_info structure has to be
           * initialized with uv-relevant information.
	   *
	   * Not Implemented....HOPEFULLY CONTROL NEVER GETS HERE FOR 1.3.x
           */

           /*  	  
	   *msg = EMS_E_Fail;
	   goto ret_end;		 added by ashok - 11/May/90 */

          if (lcmsg == EMS_I_Found || lcmsg == EMS_I_FoundOther)
            {
	    if (lcmsg == EMS_I_Found)
	      {
              lcout->locobj.located_obj.objid = my_id;
              lcout->locobj.located_obj.osnum = OM_Gw_current_OS;
              EMchglocobj (&msg_loc, cvl, 1, &lcout->locobj);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
	      }
            *msg = EMS_I_Found;
            }
          else
            {
            EMclearstack (&msg_loc, cvl);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (lcmsg == EMS_I_Interrupt)
              *msg = EMS_I_Interrupt;
            }
          }
        }

      if (stopproc)
        {
        /*
         * User input or the locate function call has determined that
         * no more processing needs to be done. Control should immediately
         * return to the initiator of this locate.
         */

        stat_OM = OM_I_STOP_SENDING;
        goto ret_end;
        }
      }
    }
   }
  /*
   * Process the edges, by sending the message to them.
   * If the model-space geometry of the edges have been obtained,
   * these can be passed in to the edges, via the more_info field
   * of the EMSlcin structure.
   */

   /*
    * Send the message to the edges only if edge curves are locatable.
    * pp (02/12/89)
    * Removed this and added the check for edges in EMedbdryloc.I
    * pp (09/20/89)
    * If option is "hit or miss" ignore error from an edge and try the next
    * one so that surface is still located.
    * SM 12-Dec-89.
    */

  edges_send:

   bdryloc_args.msg = &msg_loc;
   bdryloc_args.sfinfo = sfinfo;
   bdryloc_args.lcin = lcin;
   bdryloc_args.cvl = cvl;
   bdryloc_args.range_key = range_key;
   bdryloc_args.lcout = lcout;
   stat_OM = om$make_message (classname = "EMSboundary", 
              methodname = "EMbdrylocate", size = sizeof (bdryloc_args),
              p_arglist = &bdryloc_args, p_msg = &messg1);
   EMomerr_exit (stat_OM, ret_end);

   lpreverse = ME.EMSloop->lp_props & EMLP_REVERSED;
   for (i=0, j=edcount-1; i<edcount; i++, j--)
    {
    relinx = lpreverse ? j : i;
    if (edcvs)
      lcin->more_info = (IGRchar *) &edcvs[i];
    stat_OM = om$send (msg = &messg1, p_chanselect = &chan_to_comps,
               from = relinx, to = relinx);
    lcin->more_info = NULL;
    if(!(options & EMSlcopt_hitormiss))
     {
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
     }
    if (stat_OM == OM_I_STOP_SENDING)
      goto ret_end;
    }
  /*
   * If no final decision has been made, send the
   * message to the inner loops.
   */

  inner_send:
  chan_to_inner.type = OM_e_addr;
  chan_to_inner.u_sel.addr = &ME.EMSloop->to_inner;

  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_inner);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (*msg), *msg, EMS_E_LoopError, ret_end);
  if (stat_OM == OM_I_STOP_SENDING)
    goto ret_end;

ret_end:
  if (edcvs)
    {
    for (i=0; i<edcount; i++)
      {
      if (edcvs[i].poles)
        om$dealloc (ptr = edcvs[i].poles);
      if (edcvs[i].knots)
        om$dealloc (ptr = edcvs[i].knots);
      if (edcvs[i].weights)
        om$dealloc (ptr = edcvs[i].weights);
      }
    if (edcount > MAX_EDGE_COUNT)
      om$dealloc (ptr = edcvs);
    }
  if (cvtypes && edcount > MAX_EDGE_COUNT)
    om$dealloc (ptr = cvtypes);

  EMWRAPUP (*msg, stat_OM, "EMSloop.EMbdrylocate");
  if (EMSerror (*msg))
    *cvlmsg = MSFAIL;
  return (stat_OM);
}

end implementation EMSloop;
