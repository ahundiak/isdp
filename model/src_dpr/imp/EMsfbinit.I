/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"

method EMboolinit (IGRlong *msg; GRobjid solid1; IGRint num_solids;
                 GRobjid *solid2; 
                 union EMSssi_table *ssibuff; 
                 struct GRvg_construct *const_args; 
                 enum EMSbooltype bool_type)
/*
Description
    This method will take care of the initialization of a global mod
    state.  This includes storing the savestate info (putSSI),
    connecting itself to the components that it was made from,
    setting its properties bits.

Returned values

    EMS_S_Success if all is well.

History
    03/03/92    DLB Added EFfix_parent_child_relationship call to fix up
                    assoc graph when an associative surface is removed.
    04/22/91    DLB If not all solids are connected to comps chan, connect'em
                    up (will happen if operation generates the opnd).
    02/21/90    DLB Check for EMS_I_InvalidCase set in EMfix_SSI and return
                    the same to the sender.
    06/21/89    DLB The bool_type may have a bit set (DISJ_DUE_TO_RETRY)
                    indicating the operation type specified is due to a retry
                    of an intersecting boolean.  Note that this bit will only
                    be set if the op type is disjoint.

    19 Apr 1989 jBk Moved send to self of EMget_operation_type to
                    beginning so can use disjointSurfaces to avoid
                    EMfixSSI for disjoint booleans since some of them
                    now input a valid SSI table to this message.

    14 Dec 1988 jBk Since for EMSbool_delDisjArea the SSI does not
                    need to be fixed, I now branch around the send of
                    EMfix_SSI to myself when I am this type.

    14 Apr 1988 jBk Use EMget_operation_type to determine if an
                    orientation reversal is necessary.
                    Moved some logic around and updated some
                    comments.
    
    04 Dec 1987 jBk Added EMSbool_hollowDif check for reversal of
                    orientation.

    04 Nov 1987 DLB Modified for version 1.1.0. Removed range
                    computation.

    29 Jul 1987 SM  Added check for EMSbool_saveside.

    06 May 1987 AIC Changed RMT data type.

    30 Apr 1987 DLB Added send to fix RMT method.  See the comments
                    as to why.

    12 Apr 1987 DLB Added code for setting props correctly and
                    computing and storing range.

    ?? ??? 1987 SM  Creation.
*/ 
{
  IGRlong         msg_loc, ownersIndex;
  IGRint          stat_OM, i;
  OMuint          count;
  GRobjid         connect_solid;           
  struct GRid     my_GRid;
  OM_S_CHANSELECT chan_to_comps;
  IGRchar         *errmsg = "EMSsfboolean.EMgminit";
  IGRboolean      reverseOrientation, attachNullSymbol, disjointSurfaces,
                  disj_due_to_retry, fix_returned_invalid=FALSE;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (bool_type & DISJ_DUE_TO_RETRY)
  {
    /*This is a disjoint op due to a retry.  Reset the bit in bool_type since
     * the type is check further down in the code.
     */
    disj_due_to_retry = TRUE;
    bool_type &= ~DISJ_DUE_TO_RETRY;
  }
  else
  {
    disj_due_to_retry = FALSE;
  }

  /*
  Fix the RMT -- must do this since the surfaces that were
  removed by the boolean also had all of their loops removed. So
  this routine puts those back and collapses the RMT arrays.

  When I am type EMSbool_delDisjArea, the SSI (formerly called
  RMT) does not need to be fixed.
  */

    stat_OM = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            msg,
            &bool_type,
            NULL,
            NULL,
            &reverseOrientation,
            &attachNullSymbol,
            &disjointSurfaces,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        ),
        targetid = my_id
    );

    if (EMSerror (stat_OM) OR EMSerror (*msg))
    {
        stat_OM = OM_E_ABORT;
        *msg = EMS_E_Fail;
        goto ret_end;
    }

  if (bool_type ISNT EMSbool_delDisjArea AND NOT disjointSurfaces)
  {
    stat_OM = om$send (
        msg = message EMSsfboolean.EMfix_SSI (
            &msg_loc, ssibuff, const_args->env_info
        ),
        targetid = my_id
    );
    EMomerr_hndlr (stat_OM, ret_end, errmsg);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (msg_loc == EMS_I_InvalidCase) fix_returned_invalid = TRUE;
  }

  /*
   * Initialize the save state information table.
   */

  stat_OM = om$send (msg = message EMSdpr.EMputSSI (&msg_loc,
                           ssibuff), 
                     targetid = my_id);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);


  if (ssibuff)
  {/*Handle case of removing an associative surface from a composite*/
    struct EMSboolssi_table *my_info;
    GRobjid                 *sfout_id;
    IGRint                  ii, jj;

    my_info = &ssibuff->bool_info;
    sfout_id = my_info->surface_out_ids;

    for(ii=0; ii<my_info->num_composites; ii++)
    {
      for(jj=0; jj<my_info->num_surfaces_out[ii]; jj++, *sfout_id++)
      {
        stat_OM = EFfix_parent_child_relationship(msg, 
                            *sfout_id, my_info->composite_ids[ii],
                            OM_Gw_current_OS, TRUE, NULL);
        if (!(1 & stat_OM & *msg)) goto ret_end;
      }
    }
  }

  /*
   * Connect the input solids to this object
   */

  chan_to_comps.type = OM_e_addr;
  chan_to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  /*The boolean could have been done by a re-execute in which case the 
   * component objects would already be there.
   */
  stat_OM = om$get_channel_count(object = me,
                                 p_chanselect = &chan_to_comps, 
                                 count = &count);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);  

  if (count != num_solids + 1)
  {
    OM_S_MESSAGE                        packedRigidconnMessage;
    struct GRconnector_GRrigidconn_Msg  rigidconnArglist;
    OM_S_OBJID *idptr;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    ownersIndex = OM_K_MAXINT;

    rigidconnArglist.msg = &msg_loc;
    rigidconnArglist.owners_id = &my_GRid;
    rigidconnArglist.owners_index = &ownersIndex;
    om$make_message(classname = "GRconnector",
                    methodname = "GRrigidconn",
                    size = sizeof(rigidconnArglist),
                    p_arglist = &rigidconnArglist,
                    p_msg = &packedRigidconnMessage);

    for (i = 0, connect_solid = solid1, idptr = solid2;
         i <= num_solids;
         i++, connect_solid = *idptr++)
    {
        /*DLB - 4/22/91*/
        stat_OM = om$is_objid_on_channel(object_c = me,
                                         p_chanselect = &chan_to_comps,
                                         objid = connect_solid);
        if (stat_OM == OM_S_SUCCESS) continue;
        else stat_OM = OM_S_SUCCESS;

        if(IF_NULL_OBJID(connect_solid)) continue;
        stat_OM = om$send(msg = &packedRigidconnMessage,
                          targetid = connect_solid);
        EMomerr_hndlr (stat_OM, ret_end, errmsg);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        if(!num_solids) break; /* AMD : 02/04/1992 */
    }
  }

  /*
   * Set the 'dpr' properties appropriately. Then,
   * set the 'GRvg' properties using the construct-list
   * sent in. Some of these properties, need to be propogated
   * right through to the surface.
   */

  /*Set the properties. -DLB*/
  ME.EMSdpr->dpr_props = EMSIS_ACTIVE_STATE | EMSIS_ACTIVE_PATH;    
 
  /*Set the vg props. -DLB*/
  ME.GRgraphics->properties = const_args->properties | 
                        GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  /*Set the operation type to indicate the type of operation that made me.*/
  ME.EMSsfboolean->operation = bool_type;

  /*Set the bit if disjoint due to retry.*/
  if (disj_due_to_retry) ME.EMSsfboolean->operation |= DISJ_DUE_TO_RETRY;

  /*
   * If the Boolean operation is one of the following, the
   * right-hand operands need to have their surfaces' orientation
   * reversed in sense.
   */

    if (disjointSurfaces)
    {
        if (attachNullSymbol)
        {
            stat_OM = om$send (
                msg = message EMSsfboolean.EMattachNullSymbol (
                    &msg_loc,
                    const_args
                ),
                targetid = my_id
            );

            EMomerr_hndlr (stat_OM, ret_end, errmsg);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }

        /* for disjoint operations, this message is followed
            by an EMactivate message.  Reversals of
            orientations must be performed here. */
    }
    else /* not disjointSurfaces */
    {
        if (reverseOrientation)
        {
            OM_S_MESSAGE                      packedRevorientMessage;
            struct EMSsurface_EMrevorient_Msg revorientArglist;
            OM_S_OBJID *s2ptr;
            int ii;

/*
            packedRevorientMessage =
                message EMSsurface.EMrevorient (&msg_loc);
*/

            revorientArglist.EMmsg = &msg_loc;
            om$make_message(classname = "EMSsurface",
                            methodname = "EMrevorient",
                            size = sizeof(revorientArglist),
                            p_arglist = &revorientArglist,
                            p_msg = &packedRevorientMessage);

            for (ii = 0, s2ptr = solid2; ii < num_solids; ii++)    
            {
                stat_OM = om$send (
                    msg = &packedRevorientMessage,
                    targetid = *s2ptr++
                );
                EMomerr_hndlr (stat_OM, ret_end, errmsg);
                EMerr_hndlr
                    (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            }
        } /* end if reverseOrientation */
    } /* end not disjointSurfaces */

  {
   /*Set my last states active bits off - these could be primitive
    * composites so I ignore UNKNOWN_MSG warning. -- DLB
    */
    IGRboolean action = FALSE;
    IGRushort mask = EMSIS_ACTIVE_STATE;

    stat_OM = om$send(msg = message EMSdpr.EMsetprops(&msg_loc, &action, 
                            &mask),
                      p_chanselect = &chan_to_comps);
    if(stat_OM != OM_W_UNKNOWN_MSG)
    {
      EMomerr_hndlr (stat_OM, ret_end, errmsg);
      EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
      stat_OM = OM_S_SUCCESS; /*fix the return code*/
  }

  /*Store the chord height tolerance used to compute me. -DLB*/
  {
    IGRboolean status;
    IGRlong bs_msg;

    status = BSEXTRACTPAR(&bs_msg, BSTOLCHRDHT, ME.EMSsfboolean->cht);
    if (!status) {*msg = EMS_E_BSerror;goto ret_end;}
  }

 ret_end:
  if ((1 & stat_OM & *msg) && fix_returned_invalid) *msg = EMS_I_InvalidCase;

  EMWRAPUP_MSG (*msg, stat_OM, errmsg);
  return (stat_OM);
}
end implementation EMSsfboolean;
