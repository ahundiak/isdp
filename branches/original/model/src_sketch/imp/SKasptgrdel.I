class implementation SKasptgrnd;

# define MAX_OBJ 10

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
 IGRlong             OM_stat;
 struct GRid list; 
 IGRint cnt;

 *msg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 list.objid = NULL_OBJID;
 OM_stat = om$send (msg = message NDnode.NDget_objects(ND_ROOT,&list,1,
                          NULL,0,OM_K_MAXINT,&cnt),
                    targetid = my_id);
 EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);

 if (list.objid != NULL_OBJID)
   {
   OM_stat = om$send (msg = message NDnode.NDdisconnect(1,&list),
                     targetid = my_id);
   EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);
   }

 OM_stat = om$send (mode = OM_e_wrt_parent,
                    msg = message SKasptgrnd.GRdelete (msg, md_env),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP (*msg, OM_stat, "SKasptgrnd.GRdelete");
  return (OM_stat);
} /*  GRdelete() */

end implementation SKasptgrnd;

