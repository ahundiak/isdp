/* ###################   APOGEE COMPILED   ################## */

class implementation EMSassoc;
method NDgive_structure (IGRlong *EMmsg; struct ret_struct *str;
                         struct GRmd_env *md_env)
/* ********************************************************
Description
 This override returns the type in str->type as other_generic.

History
 Creation : PP :03/08/91
*********************************************************** */
{
 *EMmsg = MSSUCC;
 str->type = other_generic;
 return (OM_S_SUCCESS);
}

/*********************************************************
Description
 This override returns itself as the associative object if
 there is no context object else it creates a source object.
 This method was copied from ASnode's implementiation.

History
 Creation : WBC :04/24/91
*********************************************************** */

method NDmake_source(IGRlong *msg; struct GRid *located_obj,*context;
                     char *path; GRspacenum as_osnum; struct GRid *as)
{
IGRlong status;
struct GRid go;

*msg = MSFAIL;

if(context->objid == NULL_OBJID)
  {
   if(as_osnum != OM_Gw_current_OS) return (OM_W_ABORT);
   as->objid = located_obj->objid;
   as->osnum = located_obj->osnum;
   *msg = MSSUCC;
   status = OM_S_SUCCESS;
  }
else
  {
    status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
                      targetid = located_obj->objid,
                      targetos = located_obj->osnum);
    if(!(status&1)) go = *located_obj;

    status = ASmake_source_from_go(msg,&go,context,as_osnum,as);
  }
return(status);
}

method NDdelete(struct GRmd_env *md_env)
/* **********************************************************

Description
 Send a GRgraphics.GRdelete message to myself.

History
 Creation : PP : 06/15/91
 
  *********************************************************** */
{
 IGRlong EMmsg;

 EMmsg = EMS_S_Success;

 om$send (msg = message GRgraphics.GRdelete(&EMmsg, md_env),
                    targetid = my_id);

 return (OM_S_SUCCESS);
}

method NDget_state ( IGRchar *n_state )
/* **********************************************************
Description
 Return a state of 0.

History
 Creation : PP : 06/15/91
 
  *********************************************************** */
{
 *n_state = 0;
 return (OM_S_SUCCESS);
}

method NDchg_state( IGRchar mask,n_state)
/* **********************************************************
Description
 Just return success. We do not allow anybody to cause us to change
 state. 

History
 Creation : PP : 06/15/91
 
  *********************************************************** */
{
 return (OM_S_SUCCESS);
}

end implementation EMSassoc;
