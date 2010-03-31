/* ###################   ANSI   COMPILED   ################## */
class implementation EMSpointer;

#define INITIAL 10
#define INCREMENT 100
#include <stdio.h>
#include "grdpbdef.h"
#include "grdpbmacros.h" /* For gr$get_module_env */
#define DEBUG 1

from EMSdpr import EMredo;
%safe
static int key_list_size = 0;
static int num_in_key_list = 0;
static struct GRid *key_list = NULL;
static int redo_list_size = 0;
static int num_in_redo_list = 0;
static struct GRid *redo_list = NULL;
%endsafe

/*
 * This function adds/deletes add_GRid from the key list. Each of the
 * members of the key list are sent a message to update their keys based
 * on the object id.
 * Currently the following options are supported:
 * EMS_OPT_ADD : Adds the add_GRid to the key list if it is not already
 *               there.
 * EMS_OPT_REMOVE : Removes the add_GRid to the key list.
 */

void EFupdate_key_list(EMmsg, options, add_GRid)
IGRlong *EMmsg;
IGRuint options;
struct GRid *add_GRid;
{
 IGRint i;
 *EMmsg = EMS_S_Success;

 if (options & EMS_OPT_ADD)
 {
  if (key_list_size < (num_in_key_list + 1))
  {
   if (!key_list)
   {
    key_list = (struct GRid *) malloc (sizeof (struct GRid) *
                                      INITIAL);
    EMerr_hndlr(!key_list, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
    key_list_size = INITIAL;
   }
   else
   {
    key_list = (struct GRid *) realloc (key_list, sizeof (struct GRid) *
                                      (INCREMENT + key_list_size));
    EMerr_hndlr(!key_list, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
    key_list_size += INCREMENT;
   }
  }

   key_list[num_in_key_list] = *add_GRid;
   ++(num_in_key_list);
 }
 else if (options & EMS_OPT_REMOVE)
 {
  for (i=0;i<num_in_key_list;i++)
  {
    if ((key_list[i].objid == add_GRid->objid) &&
        (key_list[i].osnum == add_GRid->osnum))
    {
     key_list[i].objid = NULL_OBJID;
     break;
    }
  }
 }

wrapup:
 return;
}

void EFupdate_redo_list(EMmsg, options, add_GRid)
IGRlong *EMmsg;
IGRuint options;
struct GRid *add_GRid;
{
 IGRint i;
 *EMmsg = EMS_S_Success;


 if (options & EMS_OPT_ADD)
 {
/*
 * Check to see if it is already there.
 */
  for (i=0;i<num_in_redo_list;i++)
  {
    if ((redo_list[i].objid != NULL_OBJID) &&
       (redo_list[i].objid == add_GRid->objid) &&
       (redo_list[i].osnum == add_GRid->osnum))
    return;
  }

  if (redo_list_size < (num_in_redo_list + 1))
  {
   if (!redo_list)
   {
    redo_list = (struct GRid *) malloc (sizeof (struct GRid) *
                                      INITIAL);
    EMerr_hndlr(!redo_list, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
    redo_list_size = INITIAL;
   }
   else
   {
    redo_list = (struct GRid *) realloc (redo_list, sizeof (struct GRid) *
                                      (INCREMENT + redo_list_size));
    EMerr_hndlr(!redo_list, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
    redo_list_size += INCREMENT;
   }
  }

   redo_list[num_in_redo_list] = *add_GRid;
   ++(num_in_redo_list);
 }
 else if (options & EMS_OPT_REMOVE)
 {
  for (i=0;i<num_in_redo_list;i++)
  {
    if ((redo_list[i].objid == add_GRid->objid) &&
        (redo_list[i].osnum == add_GRid->osnum))
    {
     redo_list[i].objid = NULL_OBJID;
     break;
    }
  }
 }

wrapup:
 return;
}

void EFprocess_redo_list(EMmsg, options)
IGRlong *EMmsg;
IGRuint options;
{
 unsigned short option = NULL;
 IGRint i, error = FALSE;
 IGRint status;
 IGRint sizbuf, nret;
 struct GRmd_env md_env;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
/*
 * Redo with an identity matrix.
 */
 sizbuf = sizeof(struct GRmd_env);

 gr$get_module_env ( msg = EMmsg,
                     sizbuf = &sizbuf,
                     buffer = &md_env,
                     nret = &nret );

 for (i=0;i<num_in_redo_list;i++)
 {
   if (redo_list[i].objid != NULL_OBJID)
   {
#if DEBUG
 fprintf (stderr,"Processing redo of %d \n", redo_list[i].objid);
#endif

    status = om$send (msg = message EMSdpr.EMredo(EMmsg, &option,
                            &md_env,NULL,NULL,NULL),
                      senderid = NULL_OBJID,
                      targetid = redo_list[i].objid,
                      targetos = redo_list[i].osnum);
    if (!status)
    {
#if DEBUG
      fprintf (stderr,"Redo failed on %d \n", redo_list[i].objid);
#endif
      status = 1;
      *EMmsg = 1;
      error = TRUE;
    }
   }
 }
 num_in_redo_list = 0;

wrapup:
 if (error) *EMmsg = EMS_E_Fail;
 return;
}

void EFprocess_key_list (EMmsg, options)
IGRlong *EMmsg;
IGRuint options;
{
 IGRint i, error = FALSE;
 IGRlong status;
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 for (i=0;i<num_in_key_list;i++)
 {
  if (key_list[i].objid != NULL_OBJID)
  {
#if DEBUG
 fprintf (stderr,"Processing key %d \n", key_list[i].objid);
#endif
   status = om$send (msg = message EMSpointerA.EMstore_key_from_id(EMmsg, 
                           EMS_OPT_CHECK_ACTIVE | EMS_OPT_STORE_ID |
                           EMS_OPT_STORE_KEY,
                           NULL),
                    senderid = NULL_OBJID,
                    targetid = key_list[i].objid,
                    targetos = key_list[i].osnum);
   if (!(1&status&*EMmsg))
   {
#if DEBUG
    fprintf (stderr,"Error processing pointer id %d \n", key_list[i].objid);
#endif
    status = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    error = TRUE;
   }
  }
 }

 num_in_key_list = 0;
 EFprocess_redo_list(EMmsg,NULL);

wrapup:
 if (error) *EMmsg = EMS_E_Fail;
 return;
}

end implementation EMSpointer;

