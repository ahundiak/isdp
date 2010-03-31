/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;
#include "EMS.h"
#include "asbox.h" /* For NULL_GRID */
#include "nddef.h" /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "emserr.h"
#include "EMSasdef.h" /* For EMS_no_const_assoc */
#include <stdio.h>
#include "string.h"
#include "OMmacros.h"
#include "gocmacros.h"

extern IGRboolean WANT_POST220_BEHAVIOR;

method EMinit_associative_function (IGRlong *EMmsg;
                                    IGRushort options;
                                    IGRint num_parents;
                                    struct EMSobject_info *parent_info;
                                    IGRchar *function_name;
                                    IGRuint size;
                                    IGRchar *recomp_info;
                                    struct GRvg_construct *construct_list;
                                    GRobjid *new_objid)
/* ***********************************************************************
Description
 This method constructs the source objects for each parent and connects
 them to me (dummy object). The parents are connected in the order in which
 they appear in the list array. In this sense it is similar to 
 init_associative.

 Instead of calling construct_associative it calls the function that
 the caller passed in through the function_name field. During recomputation,
 the same function is called.

Arguments
  Input
  options: ubiquitous argument. Currently not supported and is set to
           NULL.
  num_parents : number of parents.
  parent_info : GRid and module environment of parents.
  function_name : The name of the function which should be called during
                  construction and recomputation
  size : Size of recomputation data. If there does not exist
         any recomputation data then the same may be set to NULL. 
  recomp_info: character pointer to internal data. An EMput_info is message
         is sent with recomp_info as argument for storage of the same
         into the vla. If there does not exist any internal data then
         the same should be set to NULL.
  construct_list : Construction information

 Output
  new_objid : Objid of the associative entity that is constructed.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

History
 Creation : PP 10/21/91
 30th Sep' 94 :  Sanjay  : Fix for TR# 19421901, 119422814, 119422882 : 
                           This is a crucial fix as it affects the recompute
                           flow of any associative object placed by calling
                           this method. It is related to storing the recompute
                           information. As the stackalloc() function does not
                           guarantee that the returned pointer is aligned on
                           8 byte boundary. So, the pointer needs to be aligned
                           before the recompute info. posted into it.  
************************************************************************** */

{
 IGRshort action, graphics_props;
 IGRlong     status=OM_S_SUCCESS;
 IGRint type;
 IGRint func_name_size, tot_size, stack_size;
 struct GRid *source_list=NULL;
 IGRboolean save_broadcast_flag;
 IGRint (*func_ptr) (); 
 IGRchar *buff = NULL;
 OM_S_OBJID mod_new_id;
 extern IGRboolean ASbroadcast_in_progress;

 *EMmsg = EMS_S_Success;

 mod_new_id = NULL_OBJID;
 *new_objid = NULL_OBJID;
 source_list = (struct GRid *)stackalloc(sizeof(struct GRid) * num_parents);
 EMerr_hndlr(!source_list, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 /* Set the property GRIS_POST220_OBJECT on 2.4. For an
    explanation of this property see $GRNUC/include/godef.h.

    Sunit 5/19/93.
 */
 if(WANT_POST220_BEHAVIOR)
  {
   IGRboolean action = TRUE;
   IGRshort mask = GRIS_POST220_OBJECT;
   status = om$send(msg = message GRgraphics.GRchgprops(EMmsg, &action, 
            &mask), targetid = my_id);
  }

 status = om$send(msg = message EMSassoc.EMmake_source(EMmsg, NULL,
                        num_parents, parent_info, source_list),
                  targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (function_name)
  func_name_size = strlen(function_name)+1; /* +1 for NULL terminator */
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 type = 255;


 func_ptr = (int (*)())EMaddress_lookup(function_name);
 if (!func_ptr)
 {
  fprintf (stderr,"%s symbol does not exist in image\n");
  status = OM_E_ABORT;
  *EMmsg = EMS_E_Fail;
  goto wrapup;
 }

 save_broadcast_flag = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;

 status = (*func_ptr)(EMmsg, NULL,NULL_OBJID, my_id,num_parents,
                      (IGRchar *)source_list,
                      recomp_info,
                      construct_list, &mod_new_id);
 ASbroadcast_in_progress = save_broadcast_flag;
/*
 * Transform the object to associative if the function returns an
 * object which is non-associative. We need to do this to stick in
 * associative data into the vla for using during recompute.
 */

 if (!(EFisAncestryValid(EMmsg, mod_new_id,
                      OM_Gw_current_OS, OPP_EMSassoc_class_id, FALSE)))
 {
     struct GRid non_assoc_GRid;

     non_assoc_GRid.objid = mod_new_id;
     non_assoc_GRid.osnum = OM_Gw_current_OS;

     EFtransform_to_associative(EMmsg, NULL, &non_assoc_GRid);
     if (!(1&*EMmsg)) goto wrapup;
     mod_new_id = non_assoc_GRid.objid;
 }

/*
 * If the user has hit the stop button then we stop all processing
 * and goto wrapup.
 * pp 07/13/91
 */
  if (*EMmsg == EMS_I_Interrupt)
   goto wrapup;
/* end pp */
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

/*
 * If only one character is being added as part of the recomputation
 * info then we do not need to align it on the 8 byte boundary.
 * else compute the size so that the recomputation information
 * can be aligned on the 8 byte boundary.
 */

  if (size > 1)
   tot_size  = func_name_size + size + ( func_name_size % 8 ? 
              (8 - func_name_size % 8) : 0);
  else
   tot_size = func_name_size + 1;

/*
 * Add 8 more bytes, as it is not sure that 'stackalloc' is going to return
 * pointer aligned on 8 byte boundary - Sanjay
 */
  stack_size = tot_size + 8;

  buff = (IGRchar *) stackalloc(stack_size);
  EMerr_hndlr(!buff, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
/*
 * Align the pointer given by stackalloc() on 8 byte boundary.
 */ 
  buff = GRalign_bdry(8, buff);

  OM_BLOCK_MOVE(function_name, buff, func_name_size);

  if (recomp_info && (size == 1))
   OM_BLOCK_MOVE(recomp_info, &buff[func_name_size],size);
  else
  {
    IGRchar *temp_ptr;

    temp_ptr = &buff[func_name_size];

    temp_ptr = GRalign_bdry(8, temp_ptr);
    OM_BLOCK_MOVE(recomp_info,temp_ptr,size);
  }
/* end Sanjay */

  status = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL, type, 
                        tot_size, 
                        buff),
                    targetid = mod_new_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  action = 1;
  graphics_props = GRIS_ASSOCIATIVE;

  status = om$send (msg = message GRgraphics.GRchgprops(EMmsg,&action,
                          &graphics_props),
                    targetid = mod_new_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


  status = om$send(msg = message NDnode.NDconnect (num_parents,source_list,
                         NULL_GRID, ND_ADD), 
                   targetid = mod_new_id);
  EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Set the externally constrained bit.
 * pp 06/19/91
 */

 {
  IGRlong loc_sts=OM_S_SUCCESS, loc_msg=EMS_S_Success;

  loc_sts = om$send(msg = message EMSassoc.EMexternal_constraint_changed
                          (&loc_msg, EMext_const_chg_CHECK),
                    targetid = mod_new_id);
  if (!(1 & loc_sts & loc_msg)) {*EMmsg = loc_msg; goto wrapup;}
 }
 *new_objid = mod_new_id;


wrapup:

 /*
    Set the GRIS_POST220_OBJECT property again, just incase is was
    re-initialized.
    This is a straight lift from EMasinit.I where a similar
    thing is being done. In case of EMSagrp class of objects, the bit 
    GRIS_POST220_OBJECT is not being set - TR# 119526275 - Satya - 07/10/95 
 */
 if(WANT_POST220_BEHAVIOR)
  {
   IGRboolean action = TRUE;
   IGRshort mask = GRIS_POST220_OBJECT;
   IGRlong loc_msg;
   (void) om$send(msg = message GRgraphics.GRchgprops(&loc_msg, &action,
          &mask), targetid = mod_new_id);
  }

 if ((mod_new_id != NULL_OBJID) && (mod_new_id != my_id))
 {
  om$send (msg = message Root.delete(1),
           targetid = my_id);
 }

 if (!(1&status&*EMmsg) && (mod_new_id != NULL_OBJID))
 {
  IGRint l_msg;

  om$send (msg = message GRgraphics.GRdelete (
                (IGRlong *)&l_msg, construct_list->env_info),
           targetid = mod_new_id);
  *new_objid = NULL_OBJID;
 }
 EMWRAPUP (*EMmsg, status, "EMSassoc.init_associative_function")
 return (status);
}

/*
DLB - 10/15/92 SGI (IRIX) does not prepend "_" to front of function.
*/

IGRint EMaddress_lookup(function_name)
char *function_name;
{
#ifdef CLIX
 IGRchar temp_name[54];

 temp_name[0] = '\0';
 strcpy(temp_name,"_");
 strcat(temp_name,function_name);

 return (dload_address_lookup(temp_name));
#else
 return (dload_address_lookup(function_name)); 
#endif
}
end implementation EMSassoc;

