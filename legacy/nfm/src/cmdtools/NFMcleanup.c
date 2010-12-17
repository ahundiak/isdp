#include "NFMuinc.h"

extern struct NFMglobal_st NFMglobal;

long _NFMcleanup (degree, wf_info, cat_name, item_no, file_status)

/***
    input "degree":
                                     ____take care of item status 
                                     |                   (ONLY 4 item level cmd)
                                     |__ take care of transaction
                                     ||
                                     VV
    00000000 00000000 00000000 00000111: 
                                    ^
                                    |_____ "COMMIT WORK"
                                                                           
***/

struct NFMdegree *degree; 
struct NFMwf_info wf_info;
char *cat_name;
long item_no;
char *file_status;
{
  char *fname="_NFMcleanup";
  char error_msg[1024];
  long error_no;
  long status;
  int subsystem;

  _NFMdebug ((fname, 
      "ENTER: degree->status %d, degree->transaction %d,degree->commit %d\n",
      degree->status , degree->transaction, degree->commit));

  if (wf_info.workflow)
  {
    _NFMdebug ((fname, "call NFMset_wf_state\n"));
    ERRget_message (error_msg);
    ERRget_number (&error_no, &subsystem);
    status = NFMset_wf_state (wf_info.app_name, error_no, error_msg);
    _NFMdebug ((fname, "NFMset_wf_state: 0x%.8x\n", status));
  }

  if (degree->status)
  {
    _NFMdebug ((fname, "call NFMset_item_status \n"));
    NFMset_item_status 
              (cat_name, "", "", item_no, file_status, NFM_NO_LOCK, "");
  }
  
  if (degree->commit)
  {
    _NFMdebug ((fname,  "COMMIT WORK\n"));
    SQLstmt ("COMMIT WORK");
  }

  if (degree->transaction)
  {
    _NFMdebug ((fname, "call NFMstart_transaction\n"));
    NFMstart_transaction(0);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));

  return (NFM_S_SUCCESS);
}

long _NFMfree_linked_lists (sto_list, set_list)

struct NFMsto_info *sto_list;
struct NFMset_member *set_list;

{
  char *fname="_NFMfree_linked_lists";
  struct NFMsto_info *remove_sto;
  struct NFMset_member *remove_set;

  _NFMdebug((fname,"ENTER\n"));
  _NFMdebug ((fname, "ENTER: sto_list [%ld], set_list[%ld]\n",
                     sto_list, set_list));


  if (sto_list != (struct NFMsto_info *) NULL)
  {
    _NFMdebug ((fname, "Free the sto_list, sizeof (struct NFMsto_info) = %d\n",
                sizeof(struct NFMsto_info)));

    for (; sto_list != (struct NFMsto_info *) NULL; )
    {
      remove_sto = sto_list;
      sto_list = sto_list->next;
      _NFMdebug ((fname, "Before REAL FREE: remove_sto == %ld\n", remove_sto));
      free (remove_sto);
    }
  }

  if (set_list != (struct NFMset_member *) NULL)
  {
    _NFMdebug ((fname, 
                "Free the set_list, sizeof (struct NFMset_member) = %d\n",
                sizeof(struct NFMset_member)));

    for (; set_list != (struct NFMset_member *) NULL; )
    {
      remove_set = set_list;
      set_list = set_list->next;
      _NFMdebug ((fname, "Before REAL FREE: remove_set == %ld\n", remove_set));
      free (remove_set);
    }
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long _NFMprint_linked_lists (sto_list, set_list)

struct NFMsto_info *sto_list;
struct NFMset_member *set_list;

{
  char *fname="_NFMprint_linked_lists";
  struct NFMsto_info *sto_head;
  struct NFMset_member *set_head;

  _NFMdebug ((fname, "ENTER: sto_list addr [%ld], set_list addr [%ld]\n",
                     sto_list, set_list));

  if (sto_list != (struct NFMsto_info *) NULL)
  {
    for (sto_head = sto_list; sto_head != (struct NFMsto_info *) NULL;
         sto_head = sto_head->next )
    {
      
      _NFMdebug ((fname, "sto_head->sano [%d] sto_head->saname [%s]\n\
                sto_head->nodename [%s] sto_head->username [%s]\n\
                sto_head->passwd [%s] sto_head->pathname [%s]\n\
                sto_head->plattername [%s] sto_head->devicetype [%s]\n\
                sto_head->partition [%s] sto_head->nfs [%s]\n\
                sto_head->compress [%s] sto_head->machid [%s]\n\
                sto_head->opsys [%s] sto_head->tcpip [%s]\n\
                sto_head->xns [%s] sto_head->decnet [%s]\n\
                sto_head->netware [%s] sto_head->next [%ld]\n",
                sto_head->sano, sto_head->saname,
                sto_head->nodename, sto_head->username,
                sto_head->passwd, sto_head->pathname,
                sto_head->plattername, sto_head->devicetype,
                sto_head->partition, sto_head->nfs,
                sto_head->compress, sto_head->machid,
                sto_head->opsys, sto_head->tcpip,
                sto_head->xns, sto_head->decnet,
                sto_head->netware, sto_head->next));
    }
  }

  if (set_list != (struct NFMset_member *) NULL)
  {
    for (set_head = set_list; set_head != (struct NFMset_member *) NULL;
         set_head = set_head->next )
    {
      
      _NFMdebug ((fname, "set_head->level [%d] set_head->citno [%d]\n\
                  set_head->type [%s] set_head->cat_no [%d]\n\
                  set_head->cat_name [%s] set_head->item_no [%d]\n\
                  set_head->file_status [%s] set_head->archive_state [%s]\n\
                  set_head->lock [%s], set_head->version_limit [%d]\n\
                  set_head->set_indicator [%s] set_head->pending_flag [%s]\n\
                  set_head->flag [%d] set_head->next [%ld]\n\
                  set_head->item_rev [%s]\n",
                  set_head->level, set_head->citno,
                  set_head->type, set_head->cat_no,
                  set_head->cat_name, set_head->item_no,
                  set_head->file_status, set_head->archive_state,
                  set_head->lock, set_head->version_limit,
                  set_head->set_indicator, set_head->pending_flag,
                  set_head->flag, set_head->next,
                  set_head->item_rev));
    }
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
