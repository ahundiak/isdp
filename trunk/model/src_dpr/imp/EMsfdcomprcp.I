/* ###################   APOGEE COMPILED   ################## */
/*
Notes
        This method copies the surface and its active topology only. When
sent to a DPR state, it will copy only the leaf nodes (with their respective
active topologies) and not the save state information or any any other 
intermediate state. Thus it is equivalent to a copy followed by a compress.
Though its apparent use is best for EMSsfdpr subclasses, this message  is
defined at EMSsurface so that the caller does not have to distinguish between
a surface with history and one without. All surfaces not subclassed off
EMSsfdpr will simply copy themselves, as if they received GRcopy message.

Arguments
        my_env, cp_env  input   env info for element and its copy.
        new_id          output  copy id.
        options         input   Currently ignored.
History
        SM      15-Jun-89       Creation.
        SM      06-Jul-89       Added bdry_options and sf_options arguments
                                to EMSsurface.EMintcopy
        DLB     06/02/91        Fix up creator id in topology.
*/
class implementation EMSsfdpr;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMcp.h"
#include "EMSopt.h"

extern OMuword OPP_EMSsfsolid_class_id,
               OPP_EMSgensolid_class_id,
               OPP_EMSgencompsf_class_id, 
               OPP_EMSsldpr_class_id, 
               OPP_EMSsfdpr_class_id;

#define MaxSurfs        20

method EMcompressed_copy(IGRlong *EMmsg; struct GRmd_env *my_env, *cp_env;
                       GRobjid *new_id; IGRushort options)
{
 IGRlong         sts;
 IGRint          count, bufsize, i;
 struct GRid     prim_id;
 IGRshort        action;
 OMuword         construct_class, my_classid;
 struct GRid     origSurfsBuff[MaxSurfs], copySurfsBuff[MaxSurfs], 
                 *origSurfs, *copySurfs;
 GRspacenum      osnum;
 struct EMcp_info   copy_info;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 origSurfs = origSurfsBuff;
 copySurfs = copySurfsBuff;
 bufsize = MaxSurfs;
 osnum = cp_env->md_id.osnum;
 copy_info.num_entries = 0;
 copy_info.array_size = 0;
 copy_info.objid_array = NULL;
 
 sts = om$send(msg = message GRowner.GRget_number_components(EMmsg, &count),
                   targetid = my_id);
 if (!(1 & sts & *EMmsg)) goto wrapup;     

 if(count > MaxSurfs)  
  {
   origSurfs = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   copySurfs = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   EMerr_hndlr(!origSurfs||!copySurfs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   bufsize = count;
  }

 count = 0;
 sts = om$send(msg = message GRowner.GRget_components
                   (EMmsg, my_env, origSurfs, bufsize, &count, 0, MAXINT), 
                        targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* copy all the surfaces and the active topology for each.
 */
 for(i=0; i<count; i++)
  {
   copySurfs[i].osnum = osnum;
   sts = om$send(msg = message EMSsurface.EMintcopy(EMmsg, my_env, cp_env,
                        &copySurfs[i].objid, &copy_info, 
                        EMS_COPY_ACTIVETOPOLOGY, NULL), 
                        targetid = origSurfs[i].objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

/****************************************
 for(i=0; i<count; i++)
  {
   sts = om$send(msg = message EMSsurface.EMcompress_top(EMmsg, cp_env), 
                targetid = copySurfs[i].objid, targetos = osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
***************************************/

 /* construct appropriate primitive object and connect all the surfaces to
    it.
 */
 sts = om$get_classid(object = me, p_classid = &my_classid);
 if (! (1 & sts)) goto wrapup;
 
 sts = om$is_ancestry_valid(subclassid = my_classid,
                                superclassid = OPP_EMSsldpr_class_id);
 if (! (1 & sts)) goto wrapup;

 if ((sts == OM_S_SUCCESS) || (my_classid == OPP_EMSsldpr_class_id))
 {
   if (count == 1) construct_class = OPP_EMSsfsolid_class_id;
   else construct_class = OPP_EMSgensolid_class_id;
 }
 else
 {
   sts = om$is_ancestry_valid(subclassid = my_classid,
                                  superclassid = OPP_EMSsfdpr_class_id);
   if (! (1 & sts)) goto wrapup;
 
   if ((sts == OM_S_SUCCESS) || (my_classid == OPP_EMSsfdpr_class_id))
   {
     if (count == 1) construct_class = NULL;

     else construct_class = OPP_EMSgencompsf_class_id;
   }
   else
   {
     *EMmsg = EMS_E_InvalidSend; 
     goto wrapup;
   }
 }

 prim_id.osnum = osnum;

 if (construct_class)
 {
  IGRlong junk = MAXINT;

   sts = om$construct(classid = construct_class, p_objid = &prim_id.objid, 
                        osnum = osnum);
   if (! (1 & sts)) goto wrapup;
   
   for(i=0; i<count; i++)
   {
    sts = om$send(msg = message GRconnector.GRrigidconn
                (EMmsg, &prim_id, &junk), targetid = copySurfs[i].objid, 
                        targetos = osnum);
    if (!(1 & sts & *EMmsg)) goto wrapup;
   }

   action = TRUE;
   sts = om$send(msg = message GRvg.GRchgprops(EMmsg, &action,
                         &ME.GRgraphics->properties),
                   targetid = prim_id.objid, targetos = osnum);
   if (! (1 & sts & *EMmsg)) goto wrapup;                   
 }
 else
   prim_id = copySurfs[0];
 
 *new_id = prim_id.objid;

 sts = om$send(msg = message EMSsurface.EMfix_creator_id(EMmsg, NULL,
                     *new_id, NULL),
               targetid = *new_id, targetos = prim_id.osnum);

wrapup:
  if (copy_info.objid_array) om$dealloc (ptr = copy_info.objid_array);
  EMWRAPUP(*EMmsg, sts, "In EMSsfdpr.EMcompressed_copy")
  return (sts);
}
end implementation EMSsfdpr;
