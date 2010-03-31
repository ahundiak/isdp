class implementation EMSpointer;

#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "asbox.h"
#include "EMSkey.h"
#include "EMSopt.h" /* FOR dpr options */
#include <stdio.h>

from EMSsurface import EMgetactiveid;
from EMSsurface import EMisactive;
from EMSsurface import EMmake_active_state;
from EMScreator import EMtranslate_id_key,
                       EMgive_count_based_key,
                       EMgive_noncount_based_key;

extern GRclassid OPP_GRcompcurve_class_id;

method EMstore_key_from_id(IGRlong *EMmsg;
                           IGRuint options;
                           unsigned char *ret_key)

/******************************************************************
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
 Creation : PP : 05/14/91
****************************************************************** */
{
 IGRlong status;
 IGRuint type, mytype, my_size,temp_size,temp_options,otype;
 IGRint key_size = 0,info_size;
 OM_S_CHANSELECT father;
 struct EMSkey *key = NULL;
 struct EMSnoncountkey *noncount_st = NULL;
 struct GRmd_env md_env;
 struct GRid creator_GRid, created_GRid;
 struct EMSlong_key *long_key = NULL;
 IGRuint info_type ;
 char *info; 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 temp_options = options | EMS_OPT_STORE_KEY;

/*
 * If I already have the key then return success, do not recompute.
 */

 status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg, NULL, &mytype,
                         &my_size,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if ((mytype == EMS_ASobject_key)|| (mytype == EMS_ASkey_and_id)
     || (mytype == EMS_ASlong_key))
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
 status = om$send (msg = message NDnode.ASreturn_go(&creator_GRid,
                         &md_env.md_env.matrix_type,
                          md_env.md_env.matrix),
                   p_chanselect = &father,
                   from = 0,
                   to = 0);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);
*/

/*
 * This change to work with ACconst and other entities related to the
 * macro machinery.
 * pp 06/08/92
 */

 status = om$get_objid_at_index(objid = my_id,
                                p_chanselect = &father,
                                index = 0,
                                objidaddr = &creator_GRid.objid,
                                osnumaddr = &creator_GRid.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

/* end pp */

 status = om$send (msg = message NDnode.ASreturn_go(&created_GRid,
                         &md_env.md_env.matrix_type,
                          md_env.md_env.matrix),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);
 
/*
 * This means the match has failed.
 */

 if (created_GRid.objid == NULL_OBJID)
  return (OM_S_SUCCESS);
 status =
 EFtranslate_id_key(EMmsg, EMS_OPT_KEY_FROM_ID, &md_env, &created_GRid.objid,
                    &creator_GRid,&key_size,NULL);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 info_type = EMS_SEGMT_NONE;

 info = (char *)stackalloc(my_size);

 status = 
 om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg,
			NULL,&otype,&temp_size, &info),
		targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

/*
 * Alloc maximum size.
 */

 info_size = (sizeof (struct EMSlong_key) + key_size);

 if(mytype == EMS_ASnoncount_key)
   {
     noncount_st = (struct EMSnoncountkey *) info;
     info_size = info_size  + noncount_st->size;
   }

 long_key = (struct EMSlong_key *) stackalloc (info_size);
 if (!long_key) goto wrapup;

 key = (struct EMSkey *) long_key->key_info;

 if( mytype == EMS_ASnoncount_key)
 {
   /* Fill the long key with non count information */
   char *ptr;
   noncount_st = (struct EMSnoncountkey *) info;
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

 status =
 EFtranslate_id_key(EMmsg, EMS_OPT_KEY_FROM_ID, &md_env, &created_GRid.objid,
                    &creator_GRid, &key_size,&key);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if ((temp_options & EMS_OPT_STORE_KEY) &&
     (temp_options & EMS_OPT_STORE_ID))
 {
  type = EMS_ASlong_key;
  long_key->objid = created_GRid.objid;

  status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                         type,(info_size),
                          (char *)long_key),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else if (temp_options & EMS_OPT_STORE_KEY)
 {
  	type = EMS_ASobject_key;
  	status = 
	om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                         type,key_size,
                          (char *)long_key->key_info),
                   targetid = my_id);
  	EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:
 if (long_key) stackfree (long_key);
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
 Creation : PP : 05/14/91
****************************************************************** */
{
 IGRlong status;
 char *info = NULL;
 IGRuint type, temp_options;
 IGRuint key_size = 0,info_size,temp_size;
 IGRuint new_key_size;
 OM_S_CHANSELECT father;
 struct EMSobjid_key *objid_key = NULL;
 struct EMSkey *key = NULL;
 struct GRmd_env md_env;
 struct GRid creator_GRid,my_grid;
 OM_S_OBJID component_objid;
 struct EMSlong_key *long_key  = NULL;
 struct EMSnoncountkey *noncount_st = NULL;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;


 temp_options = options | EMS_OPT_STORE_ID;

 status = om$make_chanselect(channame = "NDfather.father",
                             p_chanselect = &father);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror,wrapup);

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
 * This change to work with ACconst and other entities related to the
 * macro machinery.
 * pp 06/08/92
 */

 status = om$get_objid_at_index(objid = my_id,
                                p_chanselect = &father,
                                index = 0,
                                objidaddr = &creator_GRid.objid,
                                osnumaddr = &creator_GRid.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

/* end pp */

 component_objid = NULL_OBJID;

 status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg,
                         NULL, &type, &info_size, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (info_size)
 {
  info = (char *) stackalloc (info_size);
  EMerr_hndlr(!info, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg,
                         NULL, &type, &info_size, &info),
                   targetid = my_id);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  if (type == EMS_ASkey_and_id)
  {
    key_size = (info_size - sizeof (struct EMSobjid_key));

    if(info_size < sizeof (struct EMSobjid_key))
      key_size = info_size;

    objid_key = (struct EMSobjid_key *)info;
    key = (struct EMSkey *) objid_key->key_info;
  }
  else if (type == EMS_ASobject_key)
  {
    key_size = info_size;
    key = (struct EMSkey *) info;
  }
  else if (type == EMS_ASlong_key)
  {
    long_key = (struct EMSlong_key *) info;
    key = (struct EMSkey *)long_key->key_info;

    /* Sanity checks for instance corruption */

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
	      limits we assume it is correct*/
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

    if( long_key->noncount_st.offset >0)
    {

      key_size = (long_key->noncount_st.offset - sizeof (struct EMSlong_key));

      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;

      new_key_size = key_size;
      status =
      om$send(msg = message EMScreator.EMgive_count_based_key( EMmsg, options, 
  						  &my_grid,
						  &new_key_size,
						  (char *)key),
	      targetid = creator_GRid.objid,
	      targetos = creator_GRid.osnum);
      if( (status & 1) && (new_key_size != key_size))
        {
  	  key = (struct EMSkey *) stackalloc(new_key_size);
	  status =
	  om$send(msg=message EMScreator.EMgive_count_based_key(EMmsg, options,
						     &my_grid,
						     &new_key_size,
						     (char *)key),
		targetid = creator_GRid.objid,
		targetos = creator_GRid.osnum);
        }    
    }
    else
    {
	key_size = info_size - sizeof (struct EMSlong_key);
    }
  }
  else
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }


 status =
 EFtranslate_id_key(EMmsg, EMS_OPT_ID_FROM_KEY, &md_env, &component_objid,
                    &creator_GRid, &key_size,&key);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


/*
 * Topology matching failure. Store the key and the objid.
 */

 if (component_objid == NULL_OBJID)
 {
  temp_options |= EMS_OPT_STORE_KEY;

  if (OM_Gf_verbose_warning)
   fprintf (stderr,"Topology mismatch %d \n", my_id);
  type = 0;
 }

/* if compute failed , store just key why id */
 if ((temp_options & EMS_OPT_STORE_KEY) &&
     (temp_options & EMS_OPT_STORE_ID))
 {
  struct EMSobjid_key *objid_key_new = NULL;
  unsigned int objid_key_size;
  
  if(type != EMS_ASlong_key)
  {
   objid_key_size = sizeof (struct EMSobjid_key) + key_size;

   objid_key_new = (struct EMSobjid_key *) stackalloc(objid_key_size);
   EMerr_hndlr(!objid_key_new, *EMmsg, EMS_E_InvalidArg, wrapup);
   objid_key_new->objid = component_objid;
   OM_BLOCK_MOVE(key, objid_key_new->key_info, key_size);

   type = EMS_ASkey_and_id;

   status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                         type,objid_key_size,
                         (char *) objid_key_new),
                   targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  else
  {
   long_key->objid  = component_objid;
   type = EMS_ASlong_key;
   status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                         type,info_size,
                         (char *) long_key),
                   targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  }
 }
 else if (temp_options & EMS_OPT_STORE_ID)
 {
   if( type == EMS_ASlong_key && long_key->noncount_st.offset > 0 )
     {
       char *ptr1;
       int st_size;
       type = EMS_ASnoncount_key;
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
       om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg,
				NULL,type,temp_size,(char *)noncount_st),
		targetid = my_id);
       EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
   else
     {
       type = EMS_ASobject_id;
       status = 
       om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                         type,sizeof (OM_S_OBJID),
                         (char *) &component_objid),
                   targetid = my_id);
       EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
 }
wrapup:
 if (info) stackfree (info);
 EMWRAPUP (*EMmsg,status, "EMstore_id_from_key error");
 return (status);
}

method EMpass(IGRlong *EMmsg; unsigned int options; OM_p_MESSAGE messg)

/********************************************************************
Description 
 This message will send the incoming message to the object that the
 pointer is pointing to.

Arguments
 *EMmsg : Completion code
 options : Currently unused
 messg: The message that has to be passed.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail :    If there is a failure whose exact cause could not be
                 determined.
 EMS_I_Fail :    If the message could not be delivered due to a topology
                 matching failure.

History
 pp : 07/25/91 : Creation

************************************************************************ */
{
 IGRlong status;
 struct GRid component_GRid;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 component_GRid.objid = NULL_OBJID;

 status = om$send (msg = message NDnode.ASreturn_go(&component_GRid,
                         NULL,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 if (component_GRid.objid == NULL_OBJID)
  *EMmsg = EMS_I_Fail;
 else
  return (om$send (msg = messg,
                   targetid = component_GRid.objid,
                   targetos = component_GRid.osnum));


wrapup:
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

 status = om$send(msg = message EMSpointer.EMget_pointer_info(EMmsg, NULL, 
          &type, NULL, NULL), targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 
 if ( (type == EMS_ASkey_and_id) || (type == EMS_ASobject_key))
  temp_options |= EMS_OPT_STORE_KEY;

 type = EMS_ASobject_id;
 status = om$send (msg = message EMSpointer.EMput_pointer_info(EMmsg, NULL,
                         EMS_ASobject_id, sizeof (OM_S_OBJID),
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


EFtranslate_id_key(EMmsg, options, env, component, creator_GRid,
                   key_size,key)
IGRlong *EMmsg;
IGRuint options;
struct GRmd_env *env;
OM_S_OBJID *component;
struct GRid *creator_GRid;
IGRint *key_size;
struct EMSkey **key;
{
 IGRint key_count;
 IGRint status;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$send (msg = message EMScreator.EMtranslate_id_key(EMmsg,
                         options,
                         env,
                         component,
                         key_size,
                         (char **)key),
                   senderid = NULL_OBJID,
                   targetid = creator_GRid->objid,
                   targetos = creator_GRid->osnum);
/*
 * If the creator does not understand this message (eg ACconst, ACmodel etc)
 * then call the function directly
 */
 if ((status == OM_W_REJECTED_METHOD) || (status == OM_W_UNKNOWN_MSG))
 {
  status = OM_S_SUCCESS;

  if (options & EMS_OPT_KEY_FROM_ID)
  {
   status = OM_S_SUCCESS;
   key_count=0;
   EFgenerate_key_from_id(EMmsg, *component,
                         creator_GRid->osnum, creator_GRid->objid,
                         &key_count, (IGRchar **) key,0,NULL);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   if (key_size)
    *key_size = sizeof (struct EMSkey) * key_count;
  }
  else if (options & EMS_OPT_ID_FROM_KEY)
  {
   EMerr_hndlr(!key, *EMmsg, EMS_E_InvalidArg, wrapup);
   key_count = (*key_size) / (sizeof (struct EMSkey));
   EFgenerate_id_from_key(EMmsg, creator_GRid->objid,
                         creator_GRid->osnum, key_count, *key,
                         component,NULL);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
 }
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 wrapup:
   return (status);
}

EMget_noncount_key_from_info(type,info_size,info,info_type,info_key,size)
IGRint type,info_size, *info_type, *size;
char *info,**info_key;
{
  struct EMSnoncountkey *noncount_st;
  struct EMStmp_key *tmp_st;
  struct EMSlong_key *long_key;

  if(type != EMS_ASnoncount_key && type != EMS_ASlong_key)
    return(FALSE);
  if(type == EMS_ASnoncount_key)
    {
      noncount_st = (struct EMSnoncountkey *)info;
      *info_key = noncount_st->key;
      *info_type = noncount_st->info_type;
      *size = noncount_st->size;
    }
  else 
    {
      long_key = (struct EMSlong_key *)info;
      tmp_st = &long_key->noncount_st;
      *info_key = (char *)long_key + tmp_st->offset;
      *info_type = tmp_st->info_type;
      *size  = info_size - tmp_st->offset;
    }
  return(TRUE);
}

EFput_noncount_info(out_key,out_key_size,objid,non_count_info,
		    non_count_size,info_type,item_type)
char **out_key;
int *out_key_size;
char *non_count_info;
int  *non_count_size;
int info_type, item_type;
OM_S_OBJID objid;
{
  int size;
  struct EMSnoncountkey *non_count_st;

  size = sizeof(struct EMSnoncountkey) + (*non_count_size);

  if(!*out_key)
    {
      *out_key = (char *) malloc(size);
      if(*out_key == NULL)  return(FALSE);
    }

  *out_key_size = size;
  non_count_st = (struct EMSnoncountkey *) (*out_key);
  non_count_st->objid = objid;
  non_count_st->info_type = info_type;
  non_count_st->item_type = item_type;
  non_count_st->size = (*non_count_size);
  memcpy(non_count_st->key,non_count_info,non_count_st->size);

  return(TRUE);
}		    

EMcheckfor_offset_corruption(long_key,info_size)
     struct EMSlong_key *long_key;
     IGRint info_size;
{
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
	     limits we assume it is correct*/
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
  return(TRUE);
}
end implementation EMSpointer;
