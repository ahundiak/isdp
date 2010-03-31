/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method is used to remove/delete the unwanted loops left over
    after an operation that has topologically altered this loopset.
    For example, a Boolean operation or the imposition of a new boundary
    on this surface would cause the loopset to change in topology. The
    unwanted loops or the pieces of loops that continue to be nested in this
    loopset alongside the new loops or boundaries are cleaned up by this
    method. 

    An important characteristic of this method is that it performs a
    topological cleanup. That is, if a loop or a piece of a loop is deemed
    removable/deletable, even the topologically adjacent loop, if one exists,
    is removed/deleted. This adjacent loop might be on a different surface.

    If the delete option is chosen, the loops to be cleaned up are issued
    a Root.delete message. If this option is set to FALSE, such loops are
    merely removed from the loopset and this information is returned in
    linked list - 'sfloops'. If this method causes the removal/deletion of all
    the loops associated with a given surface, the surface itself is
    removed from it's parent or is deleted, depending on the option. If
    removed, this information is returned in the linked list - 'owncomps'.

    The resultant loopset is checked to see if it toggles correctly
    (P-C-P-..). If it does not, the erring loop is checked for degeneracy
    and if found to be so, the loop type is toggled on it. If the loop
    is non-degenerate an error code is returned.

  ARGUMENTS

    numsfs		- The number of surfaces that were affected by
                          this cleanup. Relevant only if the delete option
                          is FALSE.
    sfloops		- The linked list that contains information on
                          the loops that were removed from each of the
                          surfaces. Only if the delete option is FALSE.
    numowners		- The number of surface-owners that had surfaces
                          removed from them. Only if the delete option
                          is FALSE.
    owncomps		- The linked list containing information on the
                          surfaces removed from each of the owners.
                          Only if the delete option is FALSE.
    delete		- If TRUE, the cleaned up components are deleted,
			  else they are removed and returned in the linked
                          lists.

  NOTES

    This method alters the following property bits on the loops that are
    removed:
      EMLP_ACTIVE is turned off
      EMLP_SPLIT  is turned off if it was on.
    Further, loops in this loopset have the following changes made on their
    property mask:
      EMLP_NEW is turned off if it was on.
      EMLP_PLOOP bit is checked to see if the outermost loops represent
       areas and the nesting reflects a toggling from area-hole-area...
       If this rule does not hold out, each of the erring loops is
       checked for degeneracy and if found to be degenerate, the bit is
       simply toggled. But if such loops are not degenerate then an error
       code is returned.

    Though surfaces may be removed (those left with zero loops), none
    of their property bits are changed. This is left as the responsibilty
    of the caller. Atleast the following bits should be turned off:
      GRIS_LOCATABLE and
      GRIS_DISPLAYABLE 

  ASSUMPTION

    The loop that has pieces of it used up to form new loops, has it's
    split-bit turned on. All newly formed loops have their new-bit turned
    on. The active-bit is on for all the loops that are to be cleaned
    up.

  SEE ALSO
   
    The files containing the EMlpcleanup and the EMlptplydelete methods.

  HISTORY
    NP  :  12-08-93  :  Delete bad/invalid loops if the new option 
                        "EMtplydel_DelInvalidLoops" is passed in. Do not error
                        out. Earlier, we simply used to error out if an invalid
                        loop was encountered. 
    SM  :  07-01-93  :  Moved the areatol computation into the function
                        EMgetareatol(), in the same file.
   Taps :  07-07-92  :  Set the new loop as P_LOOP if it's a degenerate loop.
			Found this while investigating TR 92n4119.
    SM  :  07-Dec-88 :	Argument change for EMSloop.EMtoggle_type.
    SS  :  05/23/88  :  Added the check for loop-degeneracy before toggling
                        the loop-type.
    SS  :  01/08/88  :  Added the post-processing step to check the toggling
                        of loop-type while traversing down the tree.
    SS  :  03/01/87  :  Creation
*/
    
class implementation EMSloopset;

#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"
#include "emstplydel.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSloop_class_id;

from EMSloop import EMlpcleanup, EMset_props, EMget_loops;
from EMSloop import EMtoggle_type, EMreverse, EMtreemod;
from EMSedge import EMreverse;

method EMlscleanup (IGRlong *msg; IGRint *numsfs; 
                    struct EMSownercomp **sfloops; IGRint *numowners;
                    struct EMSownercomp **owncomps; 
		    IGRushort options)
{
  IGRushort props, *loop_props;
  IGRint tree_depth, buff_size, count, numtogloops, i;
  IGRlong msg_loc, send_rc, stat_OM;
  IGRdouble lparea = 0.0, areatol = 0.0;
  GRobjid *loop_ids, *togloops;
  GRclassid apply_classid;
  OM_S_CHANSELECT chan_to_loops;
  IGRushort togtype_options = NULL;
  void EMgetareatol();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  loop_ids = NULL;
  loop_props = NULL;
  togloops = NULL;

  chan_to_loops.type = OM_e_addr;
  chan_to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  /*
   * Get the object ids of the loops in this loopset and send a cleanup
   * message to each of them, provided the ids remain valid. This type
   * of sending is required since the connections inside the loop-tree
   * are dynamically changing and cannot be relied upon to propogate the
   * cleanup message.
   */

  tree_depth = MAXINT;
  buff_size = 0;
  count = 0;
  stat_OM = om$send (msg = message EMSloop.EMget_loops (&msg_loc,
             EMS_OPT_ALL, &tree_depth, &loop_ids, &loop_props, &buff_size,
             &count), p_chanselect = &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  for (i=0; i<count; i++)
    {
    stat_OM = om$is_objid_valid (objid = loop_ids[i]);
    if (stat_OM == OM_S_SUCCESS)
      {
      stat_OM = om$send (msg = message EMSloop.EMlpcleanup (&msg_loc, numsfs,
                 sfloops, numowners, owncomps, options), 
                 targetid = loop_ids[i]);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
      }
    else
      stat_OM = OM_S_SUCCESS;
    }

  /*
   * The bit in the properties word of the loops indicating that it was
   * newly created is reset, as the loop is no longer "new".
   */

  props = EMLP_NEW;
  apply_classid = OPP_EMSloop_class_id;
  stat_OM = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
             message EMSloop.EMset_props (&msg_loc, props, EMS_O_OFF),
             MAXINT, 1, &apply_classid, TRUE, NULL, NULL, NULL),
             p_chanselect = &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc | send_rc), *msg, EMS_E_LoopError, ret_end);

  /*
   * The toggle-type message is sent to return all those loops that do
   * not conform to area-hole toggling. The outermost loop(s)
   * are P-loops, a P-loop has only C-loops nested inside and a C-loop
   * has only P-loops nested inside. Such loops that fail this test,
   * are checked for degeneracy. If a loop is found to be degenerate,
   * it can safely be toggled without loss of integrity (it's edges should
   * not have to be toggled). But if the loop is not degenerate an error
   * condition has occurred.
   */

  numtogloops = 0;
  togtype_options = EMTogType_SendInner | EMTogType_NoAction;
  stat_OM = om$send (msg = message EMSloop.EMtoggle_type (&msg_loc, TRUE,
             FALSE, my_id, togtype_options, &numtogloops, &togloops, NULL, 
	     NULL, NULL, NULL),
             p_chanselect = &chan_to_loops);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  if (numtogloops)
   (void) EMgetareatol(&areatol, 
                       ME.EMSloopset->ls_props & EMLS_XYZ ? TRUE : FALSE);

  for (i=0; i<numtogloops; i++)
  {
    lparea = 0.0;
    stat_OM = om$send (msg = message EMSboundary.EMarea (&msg_loc,
               &lparea), targetid = togloops[i]);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

    /* This in an invalid case */
    if (fabs (lparea) > areatol)
    {  
       if (options & EMtplydel_DelInvalidLoops)
       {
         stat_OM = om$send(msg=message EMSloop.EMtreemod
                            (&msg_loc,NULL,DELETE,NULL),
                        targetid = togloops[i]);
         EMerr_hndlr (!(1&msg_loc&stat_OM), *msg, EMS_E_LoopError, ret_end);
       }
       else
       {
         EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);
       }
    }
    else
    {
      props = EMLP_PLOOP;
      stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc, props, 
			  EMS_O_ON),
		  targetid = togloops[i]);
      EMomerr_exit (stat_OM, ret_end);
    }
  }  

ret_end:
  if (loop_ids)
    om$dealloc (ptr = loop_ids);
  if (loop_props)
    om$dealloc (ptr = loop_props);
  if (togloops)
    om$dealloc (ptr = togloops);

  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMlscleanup");
  return (stat_OM);
}



/*
 * Compute a good area-tolerance. If the loopset is a model-space
 * loopset, chrdht is used as the basis else a factored param-tol
 * is used. The largest area that can be constructed by offsetting
 * the range by this tolerance is the areatol.
*/
void EMgetareatol(areatol, isxyz)
IGRdouble *areatol;
IGRboolean isxyz;
{
 IGRlong rc;
 IGRdouble lentol, chttol, plentol, factor;

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, chttol);
 if (isxyz)
  *areatol = 4 * chttol;
 else
  {
   BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
   factor = chttol / lentol;
   plentol = EMS_HIGH_UVLENTOL;
   *areatol = 4 * plentol * factor;
  }

}
end implementation EMSloopset;
