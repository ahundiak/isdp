class implementation EMSsfunitesf;

/*
HISTORY

  07/14/92  : AMD :  Creation

*/

#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#if DEBUG
#define ERRORs(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERRORs(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif

extern OMuword OPP_EMSsfunitesf_class_id, OPP_EMSslunitesf_class_id,
               OPP_NDnodein_class_id, OPP_EMSsolid_class_id;

extern OM_S_OBJID current_creator;

IGRlong EFmerge_coincident_surfaces( EMmsg, construct_list, 
                     active_GRid, num_surfs, surfs, result)
IGRlong *EMmsg;
struct GRvg_construct construct_list;
struct GRid  active_GRid;
IGRint num_surfs;
struct GRid *surfs;
struct GRid *result;
{
 IGRushort                options;
 IGRint                   i, sts, num_parents;
 struct EMSobject_info    *parents = NULL;
 IGRboolean               recompute, state;
 GRclassid                classid;
 IGRint                   sizbuf, msg_loc, nret; 
 struct GRmd_env          buff_env;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 options = NULL;

   if (result->objid == NULL_OBJID)
    {
        recompute = FALSE;

        result->osnum = active_GRid.osnum;

        sts = om$get_classid(osnum = active_GRid.osnum,
                             objid = active_GRid.objid,
                             p_classid = &classid);

        sts = om$is_ancestry_valid(
                superclassid = OPP_EMSsolid_class_id,
                subclassid = classid);

        if (sts == OM_S_SUCCESS || classid == OPP_EMSsolid_class_id)
         sts = om$construct(classid = OPP_EMSslunitesf_class_id,
                            osnum = result->osnum,
                            p_objid = &result->objid);
        else
         sts = om$construct(classid = OPP_EMSsfunitesf_class_id,
                            osnum = result->osnum,
                            p_objid = &result->objid);
        ERRORs(sts, EMS_S_Success,
        "EFmerge_coincident_surfaces : om$construct", wrapup);

        current_creator = result->objid;

    }
    else
    {
        recompute = TRUE;
    }

    /* Reformat the parent information for the init message.  */

    num_parents = num_surfs + 1;
    parents = (struct EMSobject_info *)
	      alloca(sizeof(struct EMSobject_info) * num_parents);

    for (i = 0; i < num_surfs; i++)
    {
        parents[i].grid = surfs[i];
        parents[i].env =  *construct_list.env_info;
    }

    if (!recompute)
    {
        parents[num_parents - 1].grid = active_GRid;
        parents[num_parents - 1].env = *construct_list.env_info;
    }
    else
    {
        parents[num_parents - 1].grid.objid = NULL_OBJID;
    }

    sts = om$send(msg = message EMSassoc.EMinit_associative
                       (EMmsg,              /* return code */
                        options,            /* options */
		        num_parents,        /* number of parents */
			parents,            /* parent information */
                        EMS_ASno_type,      /* type not needed at this class */
			NULL,               /* size of info to store */
                        NULL,               /* recompute info */
			&construct_list),   /* construction parameters */
                  senderid = NULL_OBJID,
		  targetid = result->objid,
		  targetos = result->osnum);

    gr$get_associative_flag( buffer = &state );

    sizbuf = sizeof(struct GRmd_env);
 
    gr$get_module_env ( msg = &msg_loc,
                         sizbuf = &sizbuf,
                         buffer = &buff_env,
                         nret = &nret );

    if(!state)
    {
     IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
     loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg,
                             result, &buff_env),
                       senderid = NULL_OBJID,
                       targetid = result->objid,
                       targetos = result->osnum);
     if (!(1 & loc_msg & loc_sts)) {sts=loc_sts; *EMmsg=loc_msg; 
           goto wrapup;}
    }
     
    ERRORs(sts, *EMmsg, 
    "EFmerge_coincident_surfaces : EMinit_associative", wrapup);

wrapup:

 current_creator = NULL_OBJID;
 EMWRAPUP(*EMmsg, sts, "EFunitesf")
 return (sts);

}

end implementation EMSsfunitesf;
 
