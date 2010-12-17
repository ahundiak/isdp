#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMschema.h"
#include "NFMitemfiles.h" 
#include "NFMitems.h" 
#include "MEMstruct.h"


extern struct NFMactive *NFMactive_item;
extern MEMptr NFMactive_data_list;

long NFMreset_file_information (catalog_name, item_name, item_revision)

char *catalog_name;
char *item_name;
char *item_revision;

{

  char *fname="NFMreset_file_information";
  long status;

  _NFMdebug ((fname, "ENTER: catalog [%s] item [%s.%s]\n",
              catalog_name, item_name, item_revision));

  if (NFMactive_item->command == NFM_GET_FILE_INFO)
  {
    if (strcmp (NFMactive_item->cat_name, catalog_name) ||
        strcmp (NFMactive_item->item_name, item_name)   ||
        strcmp (NFMactive_item->item_rev, item_revision))
    {
      _NFMdebug ((fname, "Given input (catalog [%s] item [%s.%s])\n\
                 doesn't match the maintained information\n\
                 (catalog [%s] item [%s.%s])\n",
                catalog_name, item_name, item_revision,
                NFMactive_item->cat_name,
                NFMactive_item->item_name,
                NFMactive_item->item_rev));

      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "Failed to cancel file manipulation command");
                 
      return (NFM_E_RESET_FILE_INFORMATION);
    }
    else
    {
      status = NFMset_item_status (catalog_name, item_name, item_revision,
               NFMactive_item->item_no,
               NFMactive_item->file_status, NFM_LOCK_COMMIT, "");
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMset_item_status 0x%.8x\n", status));
      }
      free (NFMactive_item);
      status = MEMclose (&NFMactive_data_list);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }  
    }
  }
  else
  {
    _NFMdebug ((fname, 
               "Can't reset, last command wasn't NFMget_file_information\n")); 
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "Failed to cancel file manipulation command");
    return (NFM_E_RESET_FILE_INFORMATION);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
