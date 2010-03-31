class implementation SKinterface;

#include "ma.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "EMcp.h"
#include <alloca.h>

from SKvariable import SKintcopy;

extern OMuword OPP_SKimplicit_class_id;

method SKgetconstrs (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars *in_vars;
                     IGRint *num_constrs, *num_constrs_mem;
                     struct SKconstrinfo **constrs)
{
 OM_S_CHANSELECT   if_mem_cnstrs;
 IGRlong  OM_stat;

 /* *************************************************************** */
 
 *msg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

  /*
   * If the options indicates that constraint handles are also eligible,
   * then invoke the default implementation.
   */

 if (opts & SK_GETCN_HNDL || opts & SK_GETCN_FIND)
   {
   OM_stat = om$send (mode = OM_e_wrt_parent,
              msg = message SKinterface.SKgetconstrs (msg, opts, in_vars,
              num_constrs, num_constrs_mem, constrs), targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);
   }

 EMmake_chanselect (SKinterface_to_member_constrs, &if_mem_cnstrs);
 OM_stat = om$send (msg = message SKinterface.SKgetconstrs (msg, 
                     opts, in_vars, num_constrs, num_constrs_mem, constrs),
                    p_chanselect = &if_mem_cnstrs);
 EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

 wrapup:
  EMWRAPUP (*msg, OM_stat, "SKinterface.SKgetconstrs");
  return (OM_stat);
}

method SKintcopy(
	IGRlong 	  *msg; 	
    IGRushort options;
	struct GRmd_env   *obj_mdenv;
	struct GRmd_env   *new_mdenv;
	GRobjid 	  *newobjid;
	struct EMcp_info  *copy_info)

		
{
   IGRboolean            cns_copy_exists;
   IGRlong               OM_stat;
   IGRlong   mthd_stat;
   GRobjid               copied_member_id;
   struct GRid           cnscp_GRid;
   OMuint       count;
   IGRint                i;
   OM_S_CHANSELECT       to_members, to_supers;
   void                  EMcpsearch ();

   /* ************************************************************** */

   *msg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &cns_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *msg, EMS_E_Fail, wrapup);
   if (cns_copy_exists) goto wrapup;

   OM_stat = om$send(mode = OM_e_wrt_message,
                msg = message SKconstraint.SKintcopy
                (&mthd_stat, options, obj_mdenv, new_mdenv, 
                  newobjid, copy_info), 
	    targetid = my_id);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);

   cnscp_GRid.objid = *newobjid;
   cnscp_GRid.osnum = new_mdenv->md_id.osnum;

   EMmake_chanselect(SKinterface_to_member_constrs, &to_members);
   EMmake_chanselect(SKconstraint_to_super_constrs, &to_supers);

    OM_stat = om$get_channel_count(object = me, 
                  p_chanselect = &to_members, count = &count);
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);


   for (i=0;i<count;i++)
   {
    OM_stat = om$send(msg = message SKconstraint.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                   &copied_member_id, copy_info), 
		    senderid = my_id, 
                    p_chanselect = &to_members,
		    from = i, to = i);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
    OM_stat = om$send (msg = message Root.connect(to_members,OM_K_MAXINT,
                          copied_member_id,new_mdenv->md_id.osnum, to_supers,
                          i),
                    targetid = *newobjid,
                    targetos = new_mdenv->md_id.osnum);
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
   }
wrapup:

     EMWRAPUP (*msg, OM_stat, "SKinterface.EMintcopy");
     return(OM_stat);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 OM_S_CHANSELECT  to_mem_cnstrs;
 IGRlong   OM_stat;

 *msg = MSSUCC;
 OM_stat = OM_S_SUCCESS;

 EMmake_chanselect (SKinterface_to_member_constrs, &to_mem_cnstrs);

 OM_stat = om$send (msg = message GRgraphics.GRgetobjinfo (msg, info),
                     p_chanselect = &to_mem_cnstrs, from = NULL, to = NULL);
 EMerr_hndlr (!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);

 wrapup:

 EMWRAPUP (*msg, OM_stat, "SKinterface.GRgetobjinfo");

 return(OM_stat);
}


method SKgetpseudovarlist (IGRlong *msg; IGRushort opts;
                           struct SKsolvevars **varlist)
{
 OM_S_CHANSELECT  to_mem_cnstrs;
 IGRlong   OM_stat;

 *msg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 EMmake_chanselect (SKinterface_to_member_constrs, &to_mem_cnstrs);

 OM_stat = om$send (msg = message SKconstraint.SKgetpseudovarlist (msg, opts,
            varlist), p_chanselect = &to_mem_cnstrs);
 EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

 wrapup:

 EMWRAPUP (*msg, OM_stat, "SKinterface.SKgetpseudovarlist");

 return(OM_stat);
}

method SKconnect_to_member (IGRlong *msg; IGRushort opts;
                            GRobjid member_cnstr; 
                            IGRint member_inx, interface_inx)
{
  OM_S_CHANSELECT chan_to_memcnstrs, chan_to_supercnstrs;

  *msg = EMS_S_Success;

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_memcnstrs);
  EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_supercnstrs);

  return (om$send (msg = message Root.connect (chan_to_memcnstrs, member_inx,
           member_cnstr, OM_Gw_current_OS, chan_to_supercnstrs, interface_inx),
           targetid = my_id));
}

method debug()
{
  IGRint i;
  OMuint count;
  OM_S_CHANSELECT chan_to_mem;
  OM_p_OBJECT_LINKAGE objlist;

  om$send (mode = OM_e_wrt_parent, msg = message SKinterface.debug(),
   targetid = my_id);

  EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_mem);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_mem,
   count = &count);
  fprintf (stderr, "\tNum members : %d\n", count);
  if (count)
    {
    objlist = (OM_p_OBJECT_LINKAGE) alloca (count * 
               sizeof (OM_S_OBJECT_LINKAGE));
    om$get_channel_objects (object = me, p_chanselect = &chan_to_mem,
     count = &count, list = objlist, size = count);
    for (i=0; i<count; i++)
      fprintf (stderr, "\t %d) Mem obj %d\n", i, objlist[i].S_objid);
    }

  return (OM_S_SUCCESS);
}

end implementation SKinterface;


