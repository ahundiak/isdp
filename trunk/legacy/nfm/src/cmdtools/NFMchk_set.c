#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMcheck_item_setindicator (user_id, cat_name, item_no)
   long     user_id;
   char     *cat_name;
   long     item_no;
   {
     static char *fname = "NFMcheck_item_setindicator" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n",
		 cat_name, item_no));

     sprintf (sql_str, "WHERE %s = %d", "n_itemno", item_no);

     status = NFMget_attr_value (user_id, cat_name, "n_setindicator",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status != NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
           _NFMdebug ((fname, "No SUch Item : status = <0x%.8x>\n", NFM_E_BAD_ITEM));
           return (NFM_E_BAD_ITEM);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     if ( strlen (value))
      {
           ERRload_struct (NFM, NFM_E_SET, "", NULL);
        _NFMdebug ((fname, "Item Is A Set : status = <0x%.8x>\n", NFM_E_SET));
        return (NFM_E_SET);
      }
     else
      {
           ERRload_struct (NFM, NFM_E_NOT_SET, "", NULL);
        _NFMdebug ((fname, "Item Not A Set : status = <0x%.8x>\n", NFM_E_NOT_SET));
        return (NFM_E_NOT_SET);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }
