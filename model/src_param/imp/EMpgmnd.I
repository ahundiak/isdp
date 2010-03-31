class implementation EMSparamgm;

/*
  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "ma.h"
#include "maidmx.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern IGRboolean dynamics_in_progress;
extern OMuword OPP_GRnotify_class_id, OPP_EMSparampt_class_id;

method NDupdate(IGRint *msg;
                IGRint type;
                IGRint num_parents;
	        struct GRid *parents;
	        IGRint *parent_state;
	        struct GRid *context,*new_objid;
	        struct GRmd_env *md_env)
{
  IGRboolean reset_env=0, aflag=0;
  IGRshort mattyp;
  IGRlong stat_OM, msg_loc;
  IGRdouble *mat;
  struct EMSgeomdata newgm;
  struct GRmd_env save_env;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;

  aflag = pwIsActivationOn();
  if(aflag)
  {
    save_env = *md_env;
    reset_env = TRUE;
    pwGetActiveModuleEnv(md_env);
  }

  /*
   * If dynamics is in progress do not recompute; this tends to lock up 
   * the terminal. This is currently an incomplete solution. We need to have
   * the capability to remove nodes from the graph manager. Thus, if dynamics
   * is in progress we would prevent recomputation AND remove all dependent
   * nodes from the graph of recomputation.
   */

  if (!dynamics_in_progress)
  {
    stat_OM = om$send (msg = message EMSparamgm.EMsolve (&msg_loc, NULL,
               num_parents, parents, md_env, &newgm, NULL, NULL, NULL,
               NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * Post the new geometry back into my instance data
     */
    
    if (msg_loc == EMS_I_NoSolution)
    {
      ex$message (msgnumb = EMS_S_SolutionNotFound);
    }
    else
    {
      mattyp = md_env->md_env.matrix_type;
      mat = md_env->md_env.matrix;
      stat_OM = om$send (msg = message EMSparamgm.EMconstruct (&msg_loc, NULL,
                 &mattyp, mat, &newgm), targetid = my_id);    
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  }

ret_end:
  if(reset_env && aflag)
    *md_env = save_env;

  if (1&stat_OM&*msg)
   *msg = ND_COMP_SUCC;
  else
   *msg = ND_COMP_FAIL;
  EMWRAPUP (*msg, stat_OM, "EMpgmndcomp.I");
  return (stat_OM);
}

method NDdisplay(IGRint dp_type;enum GRdpmode mode;struct GRmd_env *env)
{
  IGRint status;
  IGRlong EMmsg;
  struct GRid mod_grid;
  IGRshort mat_type;
  IGRmatrix mat_ident;
  IGRdouble *mat;
 
  status = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;


  if(env == NULL)
   {
    mat_type = MAIDMX;
    MAidmx(&EMmsg,mat_ident);
    mat = mat_ident;
   }
  else
   { 
    mat_type = env->md_env.matrix_type;
    mat = env->md_env.matrix;
   }

   GRfindmod(&mod_grid);
   status = om$send(msg = message GRgraphics.GRdisplay(&EMmsg,
        		    &mat_type,mat,&mode,&mod_grid),
                    targetid = my_id);
   EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (EMmsg, status, "In SKexplicit:NDdisplay error");
 return(status);
}

method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
/*
 * This implementation returns itself as the graphic object. 
 * Changing the behaviour of this message may impact a lot of 
 * things.
 * pp 08/21/91
 */
{
 IGRlong         msg;
 struct GRmd_env mod_env;
 IGRint          sizbuf, nret;

 go->objid = my_id;
 go->osnum = OM_Gw_current_OS;


 if (matrix && mat_type)
 {
    sizbuf = sizeof(struct GRmd_env);

    gr$get_module_env ( msg = &msg,
                        sizbuf = &sizbuf,
                        buffer = &mod_env,
                            nret = &nret );

    *mat_type = mod_env.md_env.matrix_type;    

    memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
 }
  return (OM_S_SUCCESS);
}

method NDmake_source(IGRlong *msg;
		     struct GRid *located_obj,*context;char *path;
		     GRspacenum as_osnum; struct GRid *as)
{
 IGRlong status;
 OMuword my_classid;

 status = OM_S_SUCCESS;
 *msg = EMS_S_Success;
/*
 * We need to do this in order to prevent a database change.
 * If a cross-file reference connection is desired then, we
 * change the class of EMSparampt to be of a class which has
 * the notify channel.
 * Prasad 02/05/92
 */
 status = om$get_classid (objid = my_id,
                          p_classid = &my_classid);
 EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);

 if ((as_osnum != OM_Gw_current_OS) &&
     (my_classid == OPP_EMSparampt_class_id))
 {
   status = om$change_class (objid = my_id,
                             sd_override = OM_K_change_class_sd_override,
                             classname = "EMSparamptn");
   if (!(1&status)) goto wrapup;
 }

 {
   struct GRid owner, mygrid;

   mygrid.objid = my_id;
   mygrid.osnum = OM_Gw_current_OS;
   owner.objid  = NULL_OBJID;

   if (located_obj->objid == my_id
     &&  located_obj->osnum == as_osnum)
   {
    as->objid = my_id;
    as->osnum = OM_Gw_current_OS;

    *msg = OM_S_SUCCESS;
    return(OM_S_SUCCESS);
   }

   ASmake_source_from_go(msg,located_obj,context,as_osnum,as); 
 }

wrapup:
 return (status);
}

/*
  ABSTRACT

  This override makes sure that the message has an affect (moving myself
  to root) only and only if the parent being deleted is the one parent that
  I have. If I have other parents as well, the message behaves as a noop. 
  The reasoning is that, unlike other ND children, this particular object 
  can continue to have a valid existence as a child even with some parents 
  gone (under-constrained behaviour).


  ALGORITHM

  If this object has only one parent it is considered safe to assume that
  this message is coming from this parent (since this message is always
  sent from parent to child). So, this message invokes the default 
  implementation (essentially a parent-disconnect) iff number of parents
  is identically equal to 1.
  

  HISTORY

  SS  :  08/17/95  :  Creation
*/

method NDparent_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
)
{
  IGRlong stat_OM;
  IGRuint count;
  OM_S_CHANSELECT chan_to_parents;

  EMmake_chanselect (NDfather_father, &chan_to_parents);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
   count = &count);
  if (count == 1)
    stat_OM = om$send (mode = OM_e_wrt_parent, 
               msg = message EMSparamgm.NDparent_deleted (msg, count_deleted,
               list_deleted, new_obj, md_env), targetid = my_id);
  else
    stat_OM = OM_S_SUCCESS;

  return (stat_OM);
}

end implementation EMSparamgm;
