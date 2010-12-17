#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMcheck_archive_state (user_id, cat_name, item_no)
   long    user_id;     
   char    *cat_name;
   long    item_no;
   {
     long    status;
     char    sql_str [1024], value [50];
     char    n_attr [50], n_dtype [50];

     _NFM_str ("CHK ARCH : Cat  Name = <%s>  ", cat_name);
     _NFM_num ("CHK ARCH : Item No   = <%d>\n", item_no );

     sprintf (sql_str, "WHERE %s = %d", "n_itemno", item_no);

     status = NFMget_attr_value (user_id, cat_name, "n_archivestate",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status != NFM_I_BAD_CONDITION)
         {
           status = ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
           _NFM_num ("CHK ARCH : No SUch Item : status = <0x%.8x>\n", NFM_E_BAD_ITEM);
           return (NFM_E_BAD_ITEM);
         }

        _NFM_num ("CHK ARCH : Get Attr Value : status = <0x%.8x>\n", status);
        return (status);
      }

     if (! strlen (value)) 
     {
       status = ERRload_struct (NFM, NFM_E_ITEM_NOT_BACKED_UP, "", NULL);
       status = NFM_E_ITEM_NOT_BACKED_UP;
     }
     else if (! strcmp (value, "A"))
     {
       status = ERRload_struct (NFM, NFM_E_ITEM_ARCHIVED, "", NULL);
       status = NFM_E_ITEM_ARCHIVED;
     }
     else if (! strcmp (value, "B"))
     {
       status = ERRload_struct (NFM, NFM_E_ITEM_BACKED_UP, "", NULL);
       status = NFM_E_ITEM_BACKED_UP;
     }
     else
     {
       status = ERRload_struct (NFM, NFM_E_UNKNOWN_ARCH_FLAG, "", NULL);
       status = NFM_E_UNKNOWN_ARCH_FLAG;
     }

     if (status != NFM_S_SUCCESS)
      {
        _NFM_num ("CHK ARCH : Item CO State : status = <0x%.8x>\n",
        status);
        return (status);
      }

     _NFM_num ("CHK ARCH : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
     return (NFM_S_SUCCESS);
   }
