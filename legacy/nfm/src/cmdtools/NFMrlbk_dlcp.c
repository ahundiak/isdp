#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMitems.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMfto_buf.h"

long NFMrollback_delete_copied_files_status (items_list)

struct NFMitem_entry *items_list;

{
  char *fname="NFMrollback_delete_copied_files_status";
  char sql_str[1024];
  long status;

  struct NFMitem_entry *item_head;

  _NFMdebug ((fname, "ENTER:\n"));
  for (item_head = items_list; item_head != (struct NFMitem_entry * ) NULL;
       item_head = item_head->next_item )
  {
    _NFMdebug ((fname,
              "cat[%s no %d] item[%s.%s no %d] [%d] files associated\n",
              item_head->cat_name, item_head->cat_no, item_head->item_name,
              item_head->item_rev, item_head->item_no));
    if (strcmp (item_head->status, "NN"))
    {
      _NFMdebug ((fname, "rollback delete_copied_files status\n"));
      sprintf (sql_str, "%s %s %s '%s' %s %d",
               "update", item_head->cat_name, "set n_status =",
               item_head->status, "where n_itemno =", item_head->item_no);
      status = NFMlock_table (item_head->cat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
      }
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, "SQLstmt: (%s) 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (status);
      }

      SQLstmt ("COMMIT WORK");
    }
  }

  _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
