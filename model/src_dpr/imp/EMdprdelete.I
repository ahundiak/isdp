/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "msdef.h" /* MS message codes */
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "EMSopt.h"

from EMSsurface import EMpostdelete;
from EMSparameter import EMparam_delete;
from NDnode import NDmove_to_root;

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)

/*
Description
     This method will delete the active state object which includes cleaning
     up all inactive next states, all local mod added surfaces and all
     surfaces at the primitive solid level.

Return values
     *msg  completion code - MSSUCC if successful
                           - MSFAIL (severe) if failure

Notes
     This method is written assuming that the first delete message sent
     will go to the active state in the tree.

Change history:
     gupta 11/26/86 : Creation date.
     DLB   03/24/87 mod for new class struct 1.0.0
     DLB   10/26/87 mod for version 1.1.0
     DLB   06/02/88 Added send to EMrecompinfodelete
     DLB   04/02/89 Changed so that if DPR is corrupt the delete will
                    continue.  This change will allow corrupt DPR's to be
                    compressed.
     SS    11/03/89 Added notification stuff
     DLB   04/19/91 Delete any EMSparameter object on parent channel.  This
                    abstract class wont have the parent channel and therefore
                    is a bit dirty but im going for a lean and mean impl.
                    rather than adding an override at EMSsfdpr (besides, siki
                    already added an EMSsurface message 8^)).
     PP    06/09/91 Added code for handling associative children.
     DLB   08/27/91 Delete ssi and ri only if not NULL.
*/
{
  IGRlong msg_loc;
  struct GRid my_GRid;
  extern IGRlong EFnotify_delete();


  *msg = MSSUCC;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  {
    OM_S_CHANSELECT to_father;
    EMmake_chanselect(NDfather_father, &to_father);
    om$send(msg = message EMSparameter.EMparam_delete(&msg_loc, md_env),
            p_chanselect = &to_father);
  }

  EFnotify_delete(&msg_loc,my_GRid,md_env);

  if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
  {
    /*Delete my save state stuff*/
    om$send(msg = message EMSdpr.EMsavestatedelete(msg, md_env, NULL),
            targetid = my_id);

    /*Delete my recompute info stuff*/
    om$send(msg = message EMSdpr.EMrecompinfodelete(msg, md_env, NULL, NULL),
            targetid = my_id);
  }

  /*Delete me and everyone below*/
  if (EMcheck_inhibit_postproc())
  {
    om$send (msg = message EMSsurface.EMpostdelete (&msg_loc, 
         EMS_POST_NOCOMPONENTS, md_env, OPPmargs, NULL), targetid = my_id);

    EMrestore_postproc();
  }


  om$send(mode = OM_e_wrt_message,
          msg = message EMScomposite.GRdelete(msg, md_env),
          targetid = my_id);

  return(OM_S_SUCCESS);
}
end implementation EMSdpr;
