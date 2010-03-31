/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    The following function may be used to perform a locate on a curve
    buffer (or a set of contiguous curve buffers - forming a composite
    curve). The actual object (and the leaf object) that is returned
    (on acceptance) in the GRlc_cvl locate structure is to be treated as
    invalid. The rest of the information about the locate is valid though
    (the parameter of the hit, etc). The message will be set to EMS_I_Found
    if user-acceptance occurred, else if the locate cycle has been interrupted
    an EMS_I_Interrupt is set, else it is set to EMS_I_NotFound. On error,
    the message contains the bad return code. In addition, if user-input
    dictates a stop to the search, for whatever reason (acceptance, kill-stack,
    etc.), the return code of the function is set to TRUE, else it is FALSE.

    Optionally, the curve-object corresponding to the input curve-buffer(s)
    may be passed in (else this argument is NULL_OBJID). In this case, this
    object is used in the call to the action-handler (as opposed to a
    transient object being generated). The object returned in the GRlc_cvl
    locate structure in this case will be the one thus passed in. If more
    than one curve-buffer is input, the curve-object is assumed to be the
    composite. In this mode, the action handler gets called with the 
    option - add_all (otherwise it is called with the option add_nopost).

  BUGS
   
    A kludge has been put in, until the action - add_nopost - is supported
    in every action-handler there is and every action-handler thereafter.
    The graphics-properties of the transient GRcompcurve that is constructed
    if there are more than 1 curve buffers, are not set.

  RETURN VALUE

    If the curve(s) were not accepted by the user, a message 
      - EMS_I_NotFound, is returned.
    If the accept/reject phase was interrupted by command-stacking, 
      - EMS_I_Interrupt, is returned.
    If the curve(s) were accepted
      - EMS_I_Found, is returned.
    If a previously stacked object is accepted
      - EMS_I_FoundOther is returned.
    If the passed curve is put on the locate stack by action-handler
      - EMS_I_AutoStk is returned.

    On error, one of these error codes is returned:
      - EMS_E_Fail
      - EMS_E_NoDynamicMemory
      - EMS_E_EdgeError
      - EMS_E_CurveError

  HISTORY
   Allen: 16-Apr-93  :  Modified to compare members of GRid structure
			instead of using memcmp(), since memcmp() will
			include the padding in the structure in the
			comparison.
   Jack : 22-Feb-93  :  Modified the geometric property checks.  We had
                        cases where linesegs were getting marked as freeform
                        curves, then this routine would change them to linestrings.
                        If an edge has only 2 poles, it is order 2 and it is non-
                        rational, I make it a lineseg.  Also put in a check to 
                        avoid creating a linestring that is rational.  Also,
                        added the argsused thing since parameter range_key is not
                        used and was causing a warning.
    SA  :  05/10/90  :  Modified to return two new return-codes viz.
			EMS_I_FoundOther and EMS_I_AutoStk.
    SS  :  05/04/89  :  Stopped checking explicitly for LCptlocact()
			as a special action-handler with add_nopost
			supported. Now assuming that this option
			is not supported in any action-handler.
    rlw :  01/30/89  :  Added geometric property checks
    SS  :  12/06/88  :  Optionally the curve-object can also be passed
                        in.
    SS  :  05/09/88  :  Changed the argument list to accept a set of 
                        geometrically contiguous curve buffers.
    SS  :  04/04/88  :  Creation
*/

class implementation Root;
#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "emsdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "emsedgedef.h"

/*
 * Constant defining a reasonable number of curve buffers that can be
 * expected to be input at the same time. If the number exceeds this
 * constant, mallocs will have to be performed to hold the array.
 */

#define MAX_NUM_CURVES 10

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern IGRboolean GRabsg_del_all();
extern GRclassid OPP_GRcompcurve_class_id;
extern IGRlong EFget_curve_shell_obj();

from GRgraphics import GRconstruct;
from GRowner import GRdrop;
from GRcompcurve import EMmakecomp;
from GRvg import GRpostabsg, GRgeomprops;

#argsused
IGRboolean EMlocatecvbuffs (msg, numcv, cv, cvobj, cvtype, cvsymb, cvattr,
                            cvl, range_key, lcin, lcout)
IGRlong *msg;
IGRint numcv;
struct IGRbsp_curve *cv;
struct GRid *cvobj;
IGRuchar *cvtype;
struct GRsymbology *cvsymb;
struct IGResbc *cvattr;
struct GRlc_cvl *cvl;
OM_p_KEY_DESC range_key;
struct EMSlcinput *lcin;
struct EMSlcoutput *lcout;
{
  IGRboolean hit, stopproc;
  IGRushort options;
  IGRint i;
  IGRlong *cvlmsg, msg_loc, stat_OM;
  struct GRid prime_transobj, transcvobj_mem[MAX_NUM_CURVES], *transcvobj;
  enum EMSuser_responses locresp;
  OM_S_CHANSELECT chan_to_comps;


  void EMgetclresp();
  IGRboolean EMhitcvbuff(), EFget_classid_for_an_edge_type();
  IGRlong EMgettrshobj_byinx();


  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;
  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;

  options = lcin->options;
  stopproc = FALSE;
  prime_transobj.objid = NULL_OBJID;
  transcvobj = NULL;

  /*
   * Perform a geometric check (unless it has been inhibited by the options
   * passed in) to see if any of the curve-buffers are within locate tolerance
   * of the user input. If not then exit.
   */

  if (! (options & EMSlcopt_skipgeomchk))
    {
    hit = FALSE;
    for (i=0; i<numcv; i++)
      {
      hit = EMhitcvbuff (&msg_loc, &cv[i], cvtype[i], cvl, lcin, lcout);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      if (hit)
        break;
      }
    if (!hit)
      goto ret_end;
    }

  /*
   * Either a transient curve-object has to be contructed or the one passed
   * in has to be used to go through the action-handler. The module information
   * in either case is the same as the one passed in through the GRlc_cvl
   * structure.
   */

  OM_BLOCK_MOVE (&cvl->module, &lcout->locobj.module_info,
   sizeof (struct GRmd_env));

  if (! cvobj)
    {
    /*
     * A curve-object corresponding to the input curve buffer is not passed in.
     * Obtain objects into which the geometry and other relevant data
     * may be posted. If there is more than one curve object, a composite
     * curve is made out of them and is treated as the locate-object. Else,
     * the single object itself is the located-object. This located-object is
     * the one that the action-handler works upon. These objects are lying in 
     * the transient object space. 
     */

    if (numcv > MAX_NUM_CURVES)
      {
      transcvobj = (struct GRid *) om$malloc (size = numcv * sizeof
                    (struct GRid));
      EMerr_hndlr (!transcvobj, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
    else
      transcvobj = transcvobj_mem;

    stat_OM = EFget_curve_shell_obj(&msg_loc, numcv, cv, cvtype, cvsymb,
                                    cvattr, &cvl->module.md_env, transcvobj,
                                    &prime_transobj);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    lcout->locobj.located_obj = prime_transobj;
    }
  else
    {
    /*
     * The curve-object corresponding to the curve-buffer(s) has been passed
     * in. Use that for the purposse of calling the action-handler.
     */

    lcout->locobj.located_obj = *cvobj;
    }

/*
 * Determine if this object is eligible based on the planar
 * and closure properties.  If not then pretend as if the
 * user rejected it.  rlw 01/30/89
 */
  {
   IGRboolean	further_checks_required = FALSE;
   IGRboolean	planar_only, non_planar_only, closed_only, open_only;
   IGRulong     requested_properties;

   requested_properties = cvl->attributes.obj_attr.properties;
   planar_only = ((requested_properties & LC_PLANAR_ONLY) ? 1 : 0);
   non_planar_only = ((requested_properties & LC_NON_PLANAR_ONLY) ? 1 : 0);
   if (planar_only ^ non_planar_only)
    further_checks_required = TRUE;
   closed_only = ((requested_properties & LC_PHY_CLOSED) ? 1 : 0);
   open_only = ((requested_properties & LC_PHY_OPEN) ? 1 : 0);
   if (closed_only ^ open_only)
    further_checks_required = TRUE;
   if (further_checks_required)
    {
     IGRboolean	reject_this_guy = FALSE;
     IGRlong	loc_msg, sts;
     struct	GRid *id;
     struct	GRprops properties;
     struct	GRmdenv_info *mdenv_info;

     id = &lcout->locobj.located_obj;
     if ((! cvobj) && (numcv > 1))   /* Post the shell composite */
      {
       GRobjid	new_objid;
       struct	GRpost_info post_info;

       post_info.construct_flag = TRUE;
       sts = om$send(
         msg = message GRvg.GRpostabsg(
          &loc_msg,
          &cvl->module,
          &post_info,
          NULL,
          &new_objid),
         senderid = NULL_OBJID,
         targetid = id->objid,
         targetos = id->osnum);
        EMomerr_exit (sts, ret_end);
        EMerr_hndlr (EMSerror(loc_msg), *msg, EMS_E_CurveError, ret_end);
      } /* if ((! cvobj) && (numcv > 1)) */
     mdenv_info = &cvl->module.md_env;
     sts = om$send(
       msg = message GRvg.GRgeomprops(
        &loc_msg,
        &mdenv_info->matrix_type,
        mdenv_info->matrix,
        &properties),
       senderid = NULL_OBJID,
       targetid = id->objid,
       targetos = id->osnum);
      EMomerr_exit (sts, ret_end);
      EMerr_hndlr (EMSerror(loc_msg), *msg, EMS_E_CurveError, ret_end);
     if (properties.planar)
      {
       if (non_planar_only)
        reject_this_guy = TRUE;
      }
     else
      {
       if (planar_only)
        reject_this_guy = TRUE;
      }
     if (properties.phy_closed)
      {
       if (open_only)
        reject_this_guy = TRUE;
      }
     else
      {
       if (closed_only)
        reject_this_guy = TRUE;
      }
     if (reject_this_guy)
      {
       *msg = EMS_I_NotFound;		/* Probably not necessary */
       GRabsg_del_all();		/* Don't know if this is necessary */
       goto ret_end;
      } /* if (reject_this_guy) */
    } /* if (further_checks_required) */
  }


  /*
   * Call the action-handler, giving the lc-info that has been initialized
   * through calls to the geometric-check function (and perhaps the message to
   * construct the transient object). The action option used is add_all,
   * that adds the specified object-id to the list. This list is used to
   * prevent multiple locates on the same object. But here, when transient
   * objects are being used, the same id can be reused with different
   * geometries. Here, use the macro lc$check_id with the option to delete
   * the entry in the list that was made during the action-handler call.
   * This kluge was to be avoided by the addition of an option - add_nopost -
   * to the action-handlers. But support of this has not been implemented.
   * Rather than wait for something that might never happen...
   */

  {
  enum GRlocate_action action;

  action = add_all;

  stat_OM = (*cvl->action_handler)(cvl->act_parms, &lcout->locobj,
             cvl->locate_args, &action);
  EMomerr_exit (stat_OM, ret_end);

  if (!cvobj)
    lc$check_id (rc = &msg_loc, objid = prime_transobj.objid, 
     osnum = prime_transobj.osnum, mode = LC_DEL_CHECK);

  GRabsg_del_all();
  }

  /*
   * If the return code from the action-handler indicated a stop to processing
   * set the appropriate return codes. Further, check to see if the
   * request to stop was because of acceptance by the user. If so, set
   * the return message correclty.
   *
   * Make some more checking for two additional return-codes viz. EMS_I_AutoStk
   * and EMS_I_FoundOther. -Ashok-
   */

  EMgetcvlresp (cvl, &locresp);
  if (locresp == EMSauto_stack)
    {
    *msg = EMS_I_AutoStk;
    goto ret_end;
    }

  if (stat_OM == OM_I_STOP_SENDING)
    {
    stopproc = TRUE;
    if (locresp == EMSuser_stack)
      *msg = EMS_I_Interrupt;
    else if (locresp == EMSuser_accept)
      {
      IGRint num_loc;
      struct GRlc_info loc_obj[2];
      void EMgetlocobj();

      num_loc = 1;
      EMgetlocobj (&msg_loc, cvl, &num_loc, loc_obj);
      if ((loc_obj[0].located_obj.objid == lcout->locobj.located_obj.objid) &&
          (loc_obj[0].located_obj.osnum == lcout->locobj.located_obj.osnum))
        *msg = EMS_I_Found;
      else
        *msg = EMS_I_FoundOther;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMlocatecvbuff");

  if (transcvobj && numcv > MAX_NUM_CURVES)
    om$dealloc (ptr = transcvobj);
  if (!IF_NULL_OBJID (prime_transobj.objid) && numcv > 1)
    {
    stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$send (msg = message Root.wild_disconnect (chan_to_comps),
               targetid = prime_transobj.objid, targetos = prime_transobj.osnum,
               senderid = NULL_OBJID);
    }

  EMWRAPUP (*msg, stat_OM, "EMlocatecvbuff");
  if (EMSerror (*msg))
    *cvlmsg = MSFAIL;
  return (stopproc);
}

end implementation Root;
