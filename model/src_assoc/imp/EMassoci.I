/*
History

         ??     ??      Creation.
         SM    9/11/92  Changed all 'alloca's to 'malloc's for information
                        that is returned back.
         NP    10/3/92  Get "loc_obj_info" only if "loc_obj_info_size" is 
                        non-zero for this object.
         PP    25/3/93  Deleted EMreport,EMreport_defaults and EMupdate
*/
class implementation EMSassoc;

#include "OMmacros.h"
#include "nddef.h"
#include "gocmacros.h"

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_EMSparamvc_class_id, OPP_EMSparampt_class_id;
extern GRclassid OPP_EMSparamvl_class_id;


from EMSparamgm import EMgetgeom, EMgeomhandle;
from EMSsurface import EMfix_creator_id;

method EMpack_paraminfo (IGRlong *msg; IGRushort opts;
                         struct EMSassoc_params *param_info;
                         IGRint *obj_type;
                         IGRchar **obj_info; IGRint *obj_info_size;
                         IGRint *num_parents;
                         struct GRid **parents, **asparents;
                         struct GRmd_env **md_envs;
                         OM_p_MESSAGE target_messg;
                         enum OM_e_wrt_flag target_messg_wrt_flag)
{
  IGRchar *loc_obj_info = NULL;
  IGRuint loc_obj_type, loc_obj_info_size;
  IGRint i, loc_num_parents;
  IGRlong msg_loc, stat_OM;
  struct GRid *loc_parents = NULL, *loc_asparents = NULL;
  struct GRmd_env *loc_md_envs = NULL;
  OM_S_OBJECT_LINKAGE *loc_parents_objlist = NULL;
  OM_S_CHANSELECT chan_to_father;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the information from the VLA
   */

  if (param_info || obj_type || obj_info || obj_info_size)
    {
    stat_OM = om$send (msg = message EMSassoc.EMget_info (&msg_loc, NULL,
               &loc_obj_type, &loc_obj_info_size, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
   
    if (param_info)
      {
      param_info->obj_type = (IGRint) loc_obj_type;
      param_info->obj_info_size = (IGRint) loc_obj_info_size;
      }
    if (obj_type)
      *obj_type = (IGRint) loc_obj_type;
    if (obj_info_size)
      *obj_info_size = (IGRint) loc_obj_info_size;

    /* Depending on the implementation of the assoc object, it may not have
     * any info stored in its instance data. Therefore, "loc_obj_info_size"
     * from "EMSassoc.EMget_info" above will be zero. Therefore, the statements
     * in the "if" block below are executed ONLY if "loc_obj_info_size" is
     * non-zero. NP 10/3/92.
     */ 
    if ((param_info || obj_info) && loc_obj_info_size)
      {
      /*******
      loc_obj_info = (IGRchar *) alloca (loc_obj_info_size * sizeof (IGRchar));
      ********/
      loc_obj_info = (IGRchar *) om$malloc(size = loc_obj_info_size * 
                     sizeof (IGRchar));
      EMerr_hndlr (!loc_obj_info, *msg, EMS_E_NoDynamicMemory, ret_end);

      stat_OM = om$send (msg = message EMSassoc.EMget_info (&msg_loc, NULL,
                 NULL, NULL, &loc_obj_info), targetid = my_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

/************** SM 9/11/92
      if (param_info)
        param_info->obj_info = loc_obj_info;
      if (obj_info)
        *obj_info = loc_obj_info;
****************/
      if (param_info)
       {
        param_info->obj_info = loc_obj_info;
        loc_obj_info =  NULL;
       }
      if (obj_info)
       {
        if(param_info) *obj_info = param_info->obj_info;
        else *obj_info = loc_obj_info;
        loc_obj_info =  NULL;
       }
      }
    }

  /*
   * Obtain the information about the parents
   */

  if (param_info || num_parents || parents)
    {
    EMmake_chanselect (NDfather_father, &chan_to_father);
    om$get_channel_count (object = me, p_chanselect = &chan_to_father,
     count = (OMuint *)&loc_num_parents);

    if (param_info)
      param_info->num_parents = loc_num_parents;
    if (num_parents)
      *num_parents = loc_num_parents;

    if (loc_num_parents && (param_info || parents || asparents))
      {
      /*************
      loc_parents_objlist = (OM_p_OBJECT_LINKAGE) alloca (loc_num_parents *
                             sizeof (OM_S_OBJECT_LINKAGE));
      ************/
      loc_parents_objlist = (OM_p_OBJECT_LINKAGE) om$malloc (size = 
                            loc_num_parents * sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!loc_parents_objlist, *msg, EMS_E_NoDynamicMemory, ret_end);

      /*************
      loc_parents = (struct GRid *) alloca (loc_num_parents *
                     sizeof (struct GRid));
      *************/
      loc_parents = (struct GRid *) om$malloc(size = loc_num_parents *
                     sizeof (struct GRid));

      EMerr_hndlr (!loc_parents, *msg, EMS_E_NoDynamicMemory, ret_end);

      /************
      loc_asparents = (struct GRid *) alloca (loc_num_parents *
                       sizeof (struct GRid));
      ************/
      loc_asparents = (struct GRid *) om$malloc (size = loc_num_parents *
                       sizeof (struct GRid));
      EMerr_hndlr (!loc_asparents, *msg, EMS_E_NoDynamicMemory, ret_end);

      /*************
      loc_md_envs = (struct GRmd_env *) alloca (loc_num_parents *
                     sizeof (struct GRmd_env));
      ***********/
      loc_md_envs = (struct GRmd_env *) om$malloc (size = loc_num_parents *
                     sizeof (struct GRmd_env));
      EMerr_hndlr (!loc_md_envs, *msg, EMS_E_NoDynamicMemory, ret_end);

      stat_OM = om$get_channel_objects (object = me,
                 p_chanselect = &chan_to_father, count = (OMuint *)&loc_num_parents,
                 size = loc_num_parents, list = loc_parents_objlist);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

      for (i=0; i<loc_num_parents; i++) 
        {
        loc_asparents[i].objid = loc_parents_objlist[i].S_objid;
        loc_asparents[i].osnum = loc_parents_objlist[i].osnum;
        }

      if (param_info || parents || md_envs)
        {
        for (i=0; i<loc_num_parents; i++) 
          {
          stat_OM = om$send (msg = message NDnode.ASreturn_go (&loc_parents[i],
                     &loc_md_envs[i].md_env.matrix_type,
                     loc_md_envs[i].md_env.matrix),
                     targetid = loc_asparents[i].objid,
                     targetos = loc_asparents[i].osnum);
          EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
          }
        }
/*************************** SM 9/11/92
      if (param_info)
        {
        param_info->asparents = loc_asparents;
        param_info->parents = loc_parents;
        param_info->md_envs = loc_md_envs;
        }

      if (asparents)
        *asparents = loc_asparents;
      if (parents)
        *parents = loc_parents;
      if (md_envs)
        *md_envs = loc_md_envs;
************************************/

      if (param_info)
        {
        param_info->asparents = loc_asparents;
        loc_asparents = NULL;
        param_info->parents = loc_parents;
        loc_parents = NULL;
        param_info->md_envs = loc_md_envs;
        loc_md_envs = NULL;
        }

      if (asparents)
       {
        if(param_info) *asparents = param_info->asparents;
        else *asparents = loc_asparents;
        loc_asparents = NULL;
       }
      if (parents)
       {
        if(param_info) *parents = param_info->parents;
        else *parents = loc_parents;
        loc_parents = NULL;
       }
      if (md_envs)
       {
        if(param_info) *md_envs = param_info->md_envs;
        else *md_envs = loc_md_envs;
        loc_md_envs = NULL;
       }
      }
    }
  
  /*
   * Deliver the target message to myself
   */

  if (target_messg)
    om$send (mode = target_messg_wrt_flag, msg = target_messg,
     senderid = sender_id, targetid = my_id);

ret_end:
  if(loc_md_envs) om$dealloc(ptr = loc_md_envs);
  if(loc_parents) om$dealloc(ptr = loc_parents);
  if(loc_asparents) om$dealloc(ptr = loc_asparents);
  if(loc_obj_info) om$dealloc(ptr = loc_obj_info);
  if(loc_parents_objlist) om$dealloc(ptr = loc_parents_objlist);

  EMWRAPUP (*msg, stat_OM, "EMpack_paraminfo");
  return (stat_OM);
}

method EMcompute_postprocess()
{
 return (OM_S_SUCCESS);
}

method EMprocess_function_call(IGRlong *EMmsg;
                               IGRint cnt_type;
                               IGRint count;
                               struct GRid *list;
                               OM_S_OBJID *new_leafid;
                               struct GRmd_env *md_env;
                               IGRchar *info_ptr;
                               IGRint info_size;
                               struct GRvg_construct *construct_list)
/* ************************************************************************
Description
 This method does the needful to set up and call the associative function
 during recompute.

Arguments
 EMmsg :    I/O : Completion code
 cnt_type : I   : Compute type. Only relevant if the compute is taking
                  place from the macro. In such a case the value needs to be 
                  set to ND_COMP_FROM_MACRO else it is set to NULL.
 count    : I   : Number of parents
 list     : I   : List of parents
 md_env   : I   : Ubiquitous module environment
 new_leafid:I/O : Object id of the dummy object constructed. Either this
                  object is used and geometry is shoved into it or
                  a new object is returned.
 info_ptr  : I  : Pointer to recomputation information
 info_size : I  : Size of the recompute information
 construct_list : I : Construction information

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well
 EMS_E_Fail    : If there is some form of failure

History
 03/25/93 : PP : Consolidated duplicate code existing into one method
 07/02/93 : Carlos M. Diaz : Fixed problem with alignment when stripping 
                             the f. name from the VLA to obtain the recomp 
                             info.
 09/30/94 : Sanjay : Fixed problem with alignment.
************************************************************************ */


{
 IGRlong status;
 IGRint (*func_ptr) (); 
 extern IGRint EMaddress_lookup();
 OM_S_OBJID mod_leaf_id;
 IGRint func_name_length, recomp_info_size;
 IGRchar *recomp_info_ptr;
 IGRchar *temp_ptr;
 extern OM_S_OBJID current_creator;

 mod_leaf_id = NULL_OBJID;
 status = OM_S_SUCCESS;

 func_ptr = (int (*) ())EMaddress_lookup(info_ptr);
 if (!func_ptr)
 {
   fprintf (stderr,"%s symbol does not exist in image\n", info_ptr);
   *EMmsg = EMS_E_Fail;
   goto wrapup;
 }

 func_name_length = strlen(info_ptr)+1;

 if (info_size > func_name_length)
 {
  IGRint offset_size;

/*
 * Take into account size for alignment. Here we take advantage of the
 * knowledge that if the size of the recomputation information is only
 * one character then the storage function did not take care of aligning
 * the information on a 8 byte boundary.
 * The storage is done in the function EMinit_associative_function.
 * pp 08/02/93
 */

  if ((info_size - func_name_length) > 1)
  {
   offset_size = func_name_length % 8 ? 8 - (func_name_length % 8) : 0;
   recomp_info_size = info_size - func_name_length - offset_size;

   /*
    * allocate memory for temp_ptr taking into account the padding which is
    * required for aligning the pointer. Then align the pointer on 8 byte 
    * boundary - Sanjay
    */
   temp_ptr = (IGRchar *) stackalloc( (info_size + 8) );
   temp_ptr = GRalign_bdry(8, temp_ptr);

   OM_BLOCK_MOVE( info_ptr, temp_ptr, info_size );
   temp_ptr = &temp_ptr[func_name_length];
   temp_ptr = GRalign_bdry(8,temp_ptr);
  }
  else
  {
   recomp_info_size = 1;
   temp_ptr = &info_ptr[func_name_length];
  }

/* end pp */

  recomp_info_ptr = alloca (recomp_info_size);
  EMerr_hndlr(!recomp_info_ptr, *EMmsg, EMS_E_NoStackMemory,wrapup); 

  OM_BLOCK_MOVE(temp_ptr, recomp_info_ptr,
                recomp_info_size);
 }
 else
  recomp_info_ptr = NULL;

 current_creator = *new_leafid;

 status = (*func_ptr)(EMmsg, 
                        ((cnt_type & ND_COMP_FROM_MACRO) ?
                          NULL : EMSasconst_recompute),
                        ((cnt_type & ND_COMP_FROM_MACRO) ?
                          NULL_OBJID : my_id),
                       *new_leafid,count,
                      (IGRchar *)list,
                       recomp_info_ptr,
                      construct_list, &mod_leaf_id);
  current_creator = NULL_OBJID;
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if ((mod_leaf_id != NULL_OBJID) && (*new_leafid != mod_leaf_id))
   {
    om$send (msg = message Root.delete(1),
             targetid = *new_leafid);
    *new_leafid = mod_leaf_id;

    if (!(EFisAncestryValid(EMmsg, mod_leaf_id,
                        OM_Gw_current_OS, OPP_EMSassoc_class_id, FALSE)))
    {
     struct GRid non_assoc_GRid;

     non_assoc_GRid.objid = mod_leaf_id;
     non_assoc_GRid.osnum = OM_Gw_current_OS;

     EFtransform_to_associative(EMmsg, NULL, &non_assoc_GRid);
     if (!(1&*EMmsg)) goto wrapup;
     *new_leafid = non_assoc_GRid.objid;
    }

    if ((EFisAncestryValid(EMmsg, *new_leafid,
                        OM_Gw_current_OS, OPP_EMSsurface_class_id, FALSE)))
    {
     status = om$send (msg = message EMSsurface.EMfix_creator_id(EMmsg,NULL,
                            *new_leafid, NULL),
                      targetid = *new_leafid);
     EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    }
   }

   *new_leafid = mod_leaf_id;

wrapup:
 return (status);
}
end implementation EMSassoc;
