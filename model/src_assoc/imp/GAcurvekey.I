class implementation GAcurve;

#include "OMmacros.h"
#include "EMSkey.h"
#include "REcurve.h"
#include "EMSopt.h" /* FOR dpr options */
#include "EMSprop.h"
#include <stdio.h>
#include "emsedgedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "exmacros.h"

extern GRclassid OPP_EMSedge_class_id;
extern GRclassid OPP_EMSloop_class_id;

from EMSsurface import EMgetactiveid;
from EMSsurface import EMisactive;
from EMSsurface import EMmake_active_state;
from EMSsurface import EMtranslate_id_key;
from EMSedge import EMset_props, EMget_props_type, EMget_bcxyz_geom;
from EMSloop import EMset_props;

from EMScreator import EMgive_count_based_key;

method EMstore_key_from_id(IGRlong *EMmsg;
                           IGRuint options;
                           unsigned char *ret_key)

/* ****************************************************************
Description

 This message is used to store the key based on the objid that may
 be stored in the instance data and that which is likely to change
 during recomputation. The only reason for this message is to cause
 an optimization of index storage when the parent child connections
 exist in the same file. This message is sent by NDcompute_node 
 at EMAsurface before recomputation.

Arguments
 EMmsg: Completion code
 options : The following options are supported. 
         EMS_OPT_STORE_KEY : Only causes the storage of the key. The id
                             is destroyed.
         EMS_OPT_STORE_ID :  Also additional causes the storage of the id.
         If no options are specified only key is stored if the component
         object is not in a reference file. If the component object is
         in a reference file then both key and id are stored.
                               
 key : If non-NULL then key is optionally returned. Currently not
       supported
 
History
 Creation : WBC : 06/07/91
****************************************************************** */
{
 IGRlong status;
 IGRint key_size;
 IGRuint info_size;
 OM_S_CHANSELECT father;
 struct EMSkey *key = NULL;
 struct EMSlong_key *long_key = NULL;
 struct EMSnoncountkey *noncount_st = NULL;
 struct GRmd_env md_env;
 struct GRid creator_GRid, created_GRid;
 OMuint parent_count = 0;
 char *info;
 IGRuint type;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

/*
 * If the type is not one of the below just return success.
 * pp 11/08/91
 */

 switch (ME.EMSassoc->type)
 {
  case EMSmsc_key:
  case EMSmsc_id_key:
  case EMSmsc_id:
  case EMSmsc_match_failed:
  case EMSmsc_noncount_key:
  case EMSmsc_long_key:
   break;

  default:
   return (OM_S_SUCCESS);
 }

 if (!options) options = EMS_OPT_STORE_KEY;
 else
  options |= EMS_OPT_STORE_KEY;
/*
 * If I already have the key then return success, do not recompute.
 */

 if ((ME.EMSassoc->type == EMSmsc_key) ||
     (ME.EMSassoc->type == EMSmsc_id_key)||
     (ME.EMSassoc->type == EMSmsc_long_key))
  return (OM_S_SUCCESS);

 status = om$make_chanselect(channame = "NDfather.father",
                             p_chanselect = &father);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror,wrapup);

/*
 * We are assuming that the object id is correct and are trying to
 * generate key from the object id.
 */

 creator_GRid.objid = NULL_OBJID;

/*
 * Initialise mdid and osnum.
 */

 md_env.md_id.objid = NULL_OBJID;
 md_env.md_id.osnum = OM_Gw_current_OS;

/*
 status = om$send (msg = message NDnode.ASreturn_go(&creator_GRid,
                         &md_env.md_env.matrix_type,
                          md_env.md_env.matrix),
                   p_chanselect = &father,
                   from = 0,
                   to = 0);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);
*/

/*
 * This change is done to work with ACconst and other entities related to the
 * macro machinery.
 * pp 06/08/92
 */
 status = om$get_channel_count(objid = my_id, p_chanselect = &father, 
          count = &parent_count);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 if(parent_count)
  {
   status = om$get_objid_at_index(objid = my_id,
                                p_chanselect = &father,
                                index = 0,
                                objidaddr = &creator_GRid.objid,
                                osnumaddr = &creator_GRid.osnum);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  }

/* end pp */

 status = om$send (msg = message GAcurve.GAget_msc_component(EMmsg,
                                                          &created_GRid.objid,
                                                          &created_GRid.osnum),
                   targetid = my_id);
 EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);
 
/*
 * This means the match has failed.
 */

 if ( (created_GRid.objid == NULL_OBJID) || (creator_GRid.objid == NULL_OBJID))
 {
  return (OM_S_SUCCESS);
 }

 if(ME.EMSassoc->type == EMSmsc_noncount_key)
   {
     status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
				 NULL, &type, &info_size, NULL),
                   targetid = my_id);
     EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

     if(info_size)
       {
	 info = (char *) alloca (info_size);
	 EMerr_hndlr(!info, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
       }
     else
       {
	 *EMmsg = EMS_E_InvalidArg;
	 goto wrapup;
       }
     status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                                  NULL, &type, &info_size, &info),
		       targetid = my_id);
     EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     
     noncount_st = (struct EMSnoncountkey *)info;
   }
 status=
 EFtranslate_id_key(EMmsg, EMS_OPT_KEY_FROM_ID, &md_env, &created_GRid.objid,
                    &creator_GRid,&key_size,NULL);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 status = om$send (msg = message EMSsurface.EMtranslate_id_key(EMmsg,
                         EMS_OPT_KEY_FROM_ID,
                         &md_env,
                         &created_GRid.objid,
                         &key_size,
                         NULL),
                   targetid = creator_GRid.objid);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
*/
                   
                           
/*
 * Alloc maximum size.
 */

 info_size = (sizeof (struct EMSlong_key) + key_size);
 if(ME.EMSassoc->type == EMSmsc_noncount_key)
   info_size = info_size + noncount_st->size;

 long_key = (struct EMSlong_key *) alloca (info_size);
 if (!long_key) goto wrapup;

 key = (struct EMSkey *) long_key->key_info;

 if( ME.EMSassoc->type == EMSmsc_noncount_key)
 {
   /* Fill the long key with non count information */
   char *ptr;
   long_key->noncount_st.item_type = noncount_st->item_type;
   long_key->noncount_st.info_type = noncount_st->info_type;
   long_key->noncount_st.offset = sizeof(struct EMSlong_key ) + key_size;

   ptr = (char *)((char *)long_key + sizeof(struct EMSlong_key ) + key_size);
   memcpy(ptr, noncount_st->key , noncount_st->size );
 }
 else 
 {
   long_key->noncount_st.item_type = -1;
   long_key->noncount_st.info_type = -1;
   long_key->noncount_st.offset =  -1;
 }
/*
 status = om$send (msg = message EMSsurface.EMtranslate_id_key(EMmsg,
                         EMS_OPT_KEY_FROM_ID,
                         &md_env,
                         &created_GRid.objid,
                         &key_size,
                         (IGRchar **) &key),
                   targetid = creator_GRid.objid);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
*/
 status=
 EFtranslate_id_key(EMmsg, EMS_OPT_KEY_FROM_ID, &md_env, &created_GRid.objid,
                    &creator_GRid, &key_size,&key);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if ((options & EMS_OPT_STORE_KEY) &&
     (options & EMS_OPT_STORE_ID))
 {
  type = EMSmsc_long_key;
  long_key->objid = created_GRid.objid;

  status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         type,info_size,
                         (char *) long_key),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else if (options & EMS_OPT_STORE_KEY)
 {
  status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_key,key_size,
                         (char *) long_key->key_info),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 EMWRAPUP (*EMmsg,status, "EMstore_key_from_id error");
 return (status);
}


method EMstore_id_from_key(IGRlong *EMmsg;
                           IGRuint options;
                           OM_S_OBJID *ret_objid)
/* ****************************************************************
Description

 This message is used to store the objid based on the key that may
 be stored in the instance data.

Arguments
 EMmsg: Completion code
 options : Currently if this is set to NULL, then the following is true.
           if the pointer points to an object in a reference file then
           both id and key are stored,
           If the pointer does not point to an object in a reference file
           then only id is stored.
 key : If non-NULL then objid is optionally returned.
 
History
 06/10/91 : WBC : Creation
 03/24/93 : WBC : Changed so that if the edge's type is freeform but
                  the MSC's type is either line segment of line string,
                  we get the edge's xyz geometry and see if it is
                  compatible with the MSC type.  If so, we won't error
                  out with a topology mismatch.
 01/10/94 : WBC : If a topology mismatch occurs and this MSC is in
                  the master OS and the MSC has no dependents, delete
                  it.  This is done to clean up some unneeded MSCs.
****************************************************************** */
{
 IGRlong status;
 char *info = NULL;
 IGRuint type, info_size, temp_size,new_key_size = 0;
 IGRint key_size = 0;
 OM_S_CHANSELECT father;
 struct EMSobjid_key *objid_key = NULL;
 struct EMSkey *key = NULL;
 struct EMSnoncountkey *noncount_st = NULL;
 struct EMSlong_key *long_key = NULL;
 struct GRmd_env md_env;
 struct GRid creator_GRid;
 struct IGRbsp_curve bc_geom;
 OM_S_OBJID component_objid;
 GRclassid classid;
 OMuint parent_count = 0;
 struct GRid my_grid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 bc_geom.poles = NULL;
 bc_geom.knots = NULL;
 bc_geom.weights = NULL;

/*
 * If the type is not one of the below just return success.
 * pp 11/08/91
 */

 switch (ME.EMSassoc->type)
 {
  case EMSmsc_key:
  case EMSmsc_id_key:
  case EMSmsc_id:
  case EMSmsc_match_failed:
  case EMSmsc_long_key:
  case EMSmsc_noncount_key:
  break;

  default:
   return (OM_S_SUCCESS);
 }

 if (!options) options = EMS_OPT_STORE_ID;
 else
  options |= EMS_OPT_STORE_ID;

 status = om$make_chanselect(channame = "NDfather.father",
                             p_chanselect = &father);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror,wrapup);

/*
 * Initialise mdid and osnum.
 */

 gr$get_module_env(buffer = &md_env);
 md_env.md_id.objid = NULL_OBJID;
 md_env.md_id.osnum = OM_Gw_current_OS;

/*
 * We are assuming that the key is correct and we are trying to
 * generate objid from the key.
 */

/*
 status = om$send (msg = message NDnode.ASreturn_go(&creator_GRid,
                         &md_env.md_env.matrix_type,
                          md_env.md_env.matrix),
                   p_chanselect = &father,
                   from = 0,
                   to = 0);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);
*/

/*
 * This change is done to work with ACconst and other entities related to the
 * macro machinery.
 * pp 06/08/92
 */

 status = om$get_channel_count(objid = my_id, p_chanselect = &father,
          count = &parent_count);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 if(!parent_count) 
  return(OM_S_SUCCESS);

 status = om$get_objid_at_index(objid = my_id,
                                p_chanselect = &father,
                                index = 0,
                                objidaddr = &creator_GRid.objid,
                                osnumaddr = &creator_GRid.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

/* end pp */

 component_objid = NULL_OBJID;

 status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &type, &info_size, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (info_size)
 {
  info = (char *) alloca (info_size);
  EMerr_hndlr(!info, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &type, &info_size, &info),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (type == EMSmsc_key)
 {
   key_size = info_size;
   key = (struct EMSkey *) info;
 }
 else if (type == EMSmsc_id_key)
   {
     key_size = (info_size - sizeof (struct EMSobjid_key));
     objid_key = (struct EMSobjid_key *) info;
     key = (struct EMSkey *) objid_key->key_info;
   }
 else if( type == EMSmsc_long_key)
   {
     long_key = (struct EMSlong_key *)info;
     key = (struct EMSkey *)long_key->key_info;

     /* BEGIN SANITY CHECK */
     if( long_key->noncount_st.info_type == -1 ||
	long_key->noncount_st.info_type == 0)
       {
	 long_key->noncount_st.offset = -1;
       }
     else
       {
	 if(long_key->noncount_st.info_type == EMS_SEGMT_TAG)
	   {
	     long_key->noncount_st.offset = info_size - sizeof (long int);
	   }
	 else if(long_key->noncount_st.offset > sizeof(struct EMSkey) && 
		 long_key->noncount_st.offset <= info_size)
	   {
	     /* If the type of the extra information saved is segment NAME
		we will enter here, Since this informations is within the 
		limits we assume it is correct
	      */
	     ;
	   }
	 else
	   {
	     /* Should never enter this case.
		May enter here if the tag type was SEGMT_NAME and
		offset is corrupted.
		*/
	     long_key->noncount_st.offset = -1;
	   }
       }
     /* END SANITY CHECK -GVK */
     /****************************************************************/
     
     if(long_key->noncount_st.offset >0)
       {
	 key_size =
	   (long_key->noncount_st.offset - sizeof(struct EMSlong_key));
	 
	 my_grid.objid = my_id;
	 my_grid.osnum = OM_Gw_current_OS;
	 new_key_size = key_size;

	 status =
	 om$send(msg = message EMScreator.EMgive_count_based_key(
						       EMmsg,
						       EMS_CREATE_MSCS,
						       &my_grid,
						       &new_key_size,
						       (char *)key),
		 targetid = creator_GRid.objid,
		 targetos = creator_GRid.osnum);
	 if((status &1) && (new_key_size != key_size))
	    {
	      key = (struct EMSkey *) stackalloc(new_key_size);

	      status =
	      om$send(msg = message EMScreator.EMgive_count_based_key(
						       EMmsg,
						       EMS_CREATE_MSCS,
						       &my_grid,
						       &new_key_size,
						       (char *)key),
		      targetid = creator_GRid.objid,
		      targetos = creator_GRid.osnum);
	      if(status &1)
		{
		  key_size = new_key_size;
		}
	    }
       }
     else
       key_size = info_size - sizeof(struct EMSlong_key);
       }
 else
   {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
   }

/*
 status = om$send (msg = message EMSsurface.EMtranslate_id_key(EMmsg,
                         EMS_OPT_ID_FROM_KEY,
                         &md_env,
                         &component_objid,
                         &key_size,
                         (IGRchar **) &key),
                   targetid = creator_GRid.objid);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
*/

 status=
 EFtranslate_id_key(EMmsg, EMS_OPT_ID_FROM_KEY, &md_env, &component_objid,
                    &creator_GRid, &key_size,&key);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Topology matching failure. Store the key and the objid.
 */

 if (component_objid == NULL_OBJID)
 {
  int        num_children;
  GRspacenum masterfile_osnum;

  if (OM_Gf_verbose_warning)
   fprintf (stderr,"Topology mismatch %d \n", my_id);

  /* if this MSC is in the master OS and has no dependents, delete it; this
   * is done as a way to clean up some unneeded MSCs
   */

  ex$get_cur_mod(osnum = &masterfile_osnum);

  if (OM_Gw_current_OS == masterfile_osnum)
  {
   status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN, NULL, 0,
                                                       NULL, 0, OM_K_MAXINT,
                                                       &num_children),
                    targetid = my_id);

   if ((status & 1) &&
       (num_children == 0))
   {
    status = om$send(msg = message GRgraphics.GRdelete(EMmsg, &md_env),
                     targetid = my_id);

    if (1 & status & *EMmsg)
     goto wrapup;
   }

   status = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
  }

  options |= EMS_OPT_STORE_KEY;  /* if not deleting the MSC, store its key */
 }
 else
 {
  IGRuchar type, my_edge_type;
/*
 * Check if the component is an edge. If not checking for edge types is
 * not necessary.
 * TR92N2690
 * Prasad 03/11/92
 */

  if (EFisAncestryValid(EMmsg, component_objid, OM_Gw_current_OS, 
                           OPP_EMSedge_class_id, FALSE))
  {
   status = om$send (msg = message EMSedge.EMget_props_type(EMmsg,
                            NULL, &type),
                    targetid = component_objid);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   EFget_the_edge_type_for_an_object(my_id, OM_Gw_current_OS,NULL,
                                    &my_edge_type);

/*
 * If my classid is not the same as the classid based on the edge type
 * then we should consider this as a topology mismatch.
 */
/* If the edge's type is EMfreeform_curve and the MSC is a line segment
 * or line string, get the xyz geometry of the edge and check whether its
 * curve order and number of poles are compatible with the MSC.  If so, we
 * don't have a topology mismatch.  This check is necessary since MSCs
 * are created based on a freeform edge's geometry info (see EMgetxyzobj).
 * WBC 03/24/93
 */

    if ((my_edge_type != type) && (my_edge_type != EMfreeform_curve))
    {
     IGRboolean topo_mismatch = TRUE;
     IGRlong rc, locsts;

     if ((type == EMfreeform_curve) &&
         ((my_edge_type == EMlinesegment) ||
          (my_edge_type == EMlinestring)))
     {
      locsts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&rc,
                                             &md_env.md_env,
                                             NULL, NULL, 0, OM_K_MAXINT,
                                             FALSE, NULL, &bc_geom),
                       targetid = component_objid,
                       targetos = creator_GRid.osnum);

      if ((1 & locsts & rc) &&
          (bc_geom.order == 2) &&
          (! bc_geom.rational) &&
          ((my_edge_type == EMlinestring) ||
           (bc_geom.num_poles == 2)))
       topo_mismatch = FALSE;
     }

     if ((type == EMlinesegment) && (my_edge_type == EMlinestring))
       topo_mismatch = FALSE;

     if (topo_mismatch)
     {
      component_objid = NULL_OBJID;
      options |= EMS_OPT_STORE_KEY;
      if (OM_Gf_verbose_warning)
        fprintf (stderr,"Curve type topology mismatch %d \n", my_id);
     }
    }
   }
  }

 
 if (component_objid != NULL_OBJID)
 {
   /* set the MSCEXISTS bit in the MSC's edge or loop */

   status = om$get_classid(objid = component_objid,
                           p_classid = &classid);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Fixed a minor bug here occuring due to om$is_ancestry_valid returning
 * invalid ancestry (which is non-zero) if the component_objid was a loop.
 * The following code existed before the modification: 
 * if (om$is_ancestry_valid(superclassid = OPP_EMSedge_class_id)
 * pp 06/30/91
 */
   if (om$is_ancestry_valid(superclassid = OPP_EMSedge_class_id,
                            subclassid = classid) == (OM_S_SUCCESS))
   {
     status = om$send(msg = message EMSedge.EMset_props(EMmsg, EMED_MSCEXISTS,
                                                        1),
                      targetid = component_objid);
   }
   else if (om$is_ancestry_valid(superclassid = OPP_EMSloop_class_id,
                                 subclassid = classid) == (OM_S_SUCCESS))
   {
     status = om$send(msg = message EMSloop.EMset_props(EMmsg, EMLP_MSCEXISTS,
                                                        1),
                      targetid = component_objid);
   }
   else
    status = OM_E_ABORT;

   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 type = 0;


 if ((options & EMS_OPT_STORE_KEY) &&
     (options & EMS_OPT_STORE_ID))
 {
  struct EMSobjid_key *objid_key_new = NULL;
  unsigned int objid_key_size;

  if(type != EMSmsc_long_key)
    {
      objid_key_size = sizeof (struct EMSobjid_key) + key_size;

      objid_key_new = (struct EMSobjid_key *) alloca(objid_key_size);
      EMerr_hndlr(!objid_key_new, *EMmsg, EMS_E_InvalidArg, wrapup);
      objid_key_new->objid = component_objid;
      OM_BLOCK_MOVE(key, objid_key_new->key_info, key_size);

      status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_id_key,objid_key_size,
                         (char *) objid_key_new),
			targetid = my_id);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    }
  else
    {
      long_key->objid = component_objid;
      status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_long_key,info_size,
                         (char *) long_key),
			targetid = my_id);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
    }
 }
 else if (options & EMS_OPT_STORE_ID)
 {
   if(type == EMSmsc_long_key && long_key->noncount_st.offset >0)
     {
       char *ptr1;
       int st_size;
       type = EMSmsc_noncount_key;
       st_size = info_size - long_key->noncount_st.offset;
       temp_size = sizeof(struct EMSnoncountkey) + st_size;

       noncount_st = (struct EMSnoncountkey *)stackalloc(temp_size);
       
       ptr1 = (char *)((char *) long_key + long_key->noncount_st.offset);

       status = 
       EFput_noncount_info(&noncount_st,&temp_size,component_objid,
			   ptr1,
			   &st_size,
			   long_key->noncount_st.info_type,
			   long_key->noncount_st.item_type);

       status =
       om$send (msg = message EMSassoc.EMput_info(EMmsg,
				NULL,type,temp_size,(char *)noncount_st),
		targetid = my_id);
       EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
   else
     {
       status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_id,sizeof (OM_S_OBJID),
                         (char *) &component_objid),
		       targetid = my_id);
       EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
 }

 if (ret_objid)
  *ret_objid = component_objid;

wrapup:

 if (bc_geom.poles)
     om$dealloc (ptr = bc_geom.poles);
 if (bc_geom.knots)
     om$dealloc (ptr = bc_geom.knots);
 if (bc_geom.weights)
     om$dealloc (ptr = bc_geom.weights);

 EMWRAPUP (*EMmsg,status, "EMstore_id_from_key error");
 return (status);
}



method EMstore_id(IGRlong *EMmsg;
                  IGRuint options;
                  OM_S_OBJID store_objid)
/* ****************************************************************
Description

 This message is used to store the objid in the instance data.

Arguments
 EMmsg: Completion code
 options : Currently if this is set to NULL, then the following is true.
           if the pointer points to an object in a reference file then
           both id and key are stored,
           If the pointer does not point to an object in a reference file
           then only id is stored.
 store_objid: The objid to be stored.
 
History
 Creation : SM : 06/01/92

Notes
If the pointer stores the key then it will be updated based on the new
id.

****************************************************************** */
{
 IGRlong status;
 IGRuint type, temp_options = NULL;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
          &type, NULL, NULL), targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 
 if ( (type == EMSmsc_id_key) || (type == EMSmsc_key))
  temp_options |= EMS_OPT_STORE_KEY;

 status = om$send (msg = message EMSassoc.EMput_info(EMmsg, NULL,
                         EMSmsc_id, sizeof (OM_S_OBJID),
                         (char *) &store_objid),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (temp_options & EMS_OPT_STORE_KEY)
   status = om$send(msg = message EMSpointerA.EMstore_key_from_id(EMmsg, 
            EMS_OPT_STORE_ID, NULL), targetid = my_id);

wrapup:
 EMWRAPUP (*EMmsg,status, "EMstore_id");
 return (status);
}
EMget_msc_noncount_key_from_info(type,info_size,info,info_type,info_key,size)
IGRint type,info_size, *info_type, *size;
char *info,**info_key;
{
  struct EMSnoncountkey *noncount_st;
  struct EMStmp_key *tmp_st;
  struct EMSlong_key *long_key;

  if(type == EMSmsc_noncount_key)
    {
      noncount_st = (struct EMSnoncountkey *)info;
      *info_key = noncount_st->key;
      *info_type = noncount_st->info_type;
      *size = noncount_st->size;
    }
  else if(type == EMSmsc_long_key)
    {
      long_key = (struct EMSlong_key *)info;
      tmp_st = &long_key->noncount_st;
      *info_key = (char *)long_key + tmp_st->offset;
      *info_type = tmp_st->info_type;
      *size  = info_size - tmp_st->offset;
    }
  else
    {
	*size = 0;
	return(FALSE);
    }
  return(TRUE);
}

end implementation GAcurve;

