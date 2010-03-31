class implementation EMSsfcapsf;

/*
HISTORY

  11/14/92  : AMD :  Creation
  30 Nov 93 : AIC :  Fixed non-associative case. Options for this function
                     were being passed along to EMinit_associative,
                     which interprets its options differently.
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

extern OMuword OPP_EMSsfcapsf_class_id, OPP_EMSslcapsf_class_id,
               OPP_NDnodein_class_id, OPP_EMSsolid_class_id;

extern OM_S_OBJID current_creator;

IGRlong EFplace_solid_by_capping_surface
                             ( msg,
                               construct_list,
                               assoc_options,
                               active_GRid,
                               surface,
                               result )
IGRlong                 *msg;
struct GRvg_construct   construct_list;
IGRushort               assoc_options;
struct GRid             active_GRid;
struct EMSobject_info   *surface;
struct GRid             *result;
{
 IGRushort                options;
 IGRint                   sts, num_parents;
 struct EMSobject_info    *parents = NULL;
 IGRboolean               recompute;
 IGRint                   sizbuf, msg_loc, nret; 
 struct GRmd_env          buff_env;
 
 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 options = NULL;

   if (result->objid == NULL_OBJID)
    {
        recompute = FALSE;

        result->osnum = active_GRid.osnum;

        sts = om$construct(classid = OPP_EMSslcapsf_class_id,
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

    num_parents = 2;
    parents = (struct EMSobject_info *)
              alloca(sizeof(struct EMSobject_info) * num_parents);

    parents[0] = *surface;

    if (!recompute)
    {
        parents[1].grid = active_GRid;
        parents[1].env = *construct_list.env_info;
    }
    else
    {
        parents[1].grid.objid = NULL_OBJID;
    }

    sts = om$send(msg = message EMSassoc.EMinit_associative
                       (msg,                /* return code */
                        (assoc_options & EFfunc_PLACE_NON_ASSOC) ?
                            EMSinit_dont_connect_parents |
                            EMSinit_dont_store_recomp_info :
                            NULL,           /* options */
                        num_parents,        /* number of parents */
                        parents,            /* parent information */
                        EMS_ASno_type,      /* type not needed at this class */
                        NULL,               /* size of info to store */
                        NULL,               /* recompute info */
                        &construct_list),   /* construction parameters */
                  senderid = NULL_OBJID,
                  targetid = result->objid,
                  targetos = result->osnum);

    sizbuf = sizeof(struct GRmd_env);
 
    gr$get_module_env ( msg = &msg_loc,
                         sizbuf = &sizbuf,
                         buffer = &buff_env,
                         nret = &nret );

    if(assoc_options & EFfunc_PLACE_NON_ASSOC)
    {
     IGRlong loc_msg=EMS_S_Success, loc_sts=OM_S_SUCCESS;
     loc_sts = om$send(msg = message NDnode.NDmove_to_root(&loc_msg,
                             result, &buff_env),
                       senderid = NULL_OBJID,
                       targetid = result->objid,
                       targetos = result->osnum);
     if (!(1 & loc_msg & loc_sts)) {sts=loc_sts; *msg=loc_msg; 
           goto wrapup;}
    }
     
wrapup:

 current_creator = NULL_OBJID;
 EMWRAPUP(*msg, sts, "EFplace_solid_by_capping_surface")
 return (sts);
}

end implementation EMSsfcapsf;
