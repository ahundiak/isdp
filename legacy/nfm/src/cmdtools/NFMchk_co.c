#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#define      NULL    ((char *) 0)

 long NFMcheck_co_status (user_id, cat_name, item_no, state)
   long    user_id;     
   char    *cat_name;
   long    item_no;
   char    *state;
   {
     static char *fname = "NFMcheck_co_status" ;
     long    status;
     char    sql_str [1024];
 
     state [0] = 0;
     
     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n",
		 cat_name, item_no));

     sprintf (sql_str, "WHERE %s = %d", "n_itemno", item_no);

     status = NFMget_attr_value (user_id, cat_name, "n_status",
              sql_str, state);
     if (status != NFM_S_SUCCESS)
      {
        if (status != NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
           _NFMdebug ((fname, "No Such Item : status = <0x%.8x>\n",
           NFM_E_BAD_ITEM));
           return (NFM_E_BAD_ITEM);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

       if (! strlen (state)) 
       {
         ERRload_struct (NFM, NFM_E_NO_FILE, "", NULL);
         status = NFM_E_NO_FILE;
       }
       else if (! strcmp (state, "I"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_IN, "", NULL);
         status = NFM_E_ITEM_IN;
       }
       else if (! strcmp (state, "O"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_OUT, "", NULL);
         status = NFM_E_ITEM_OUT;
       }

       else if (! strcmp (state, "S")) 
       {
         ERRload_struct (NFM, NFM_E_SET_OUT, "", NULL);
         status = NFM_E_SET_OUT;
       }
       else if (! strcmp (state, "SN")) 
       {
         ERRload_struct (NFM, NFM_E_SET_OUT_NO_FILE, "", NULL);
         status = NFM_E_SET_OUT_NO_FILE;
       }

       else if (! strcmp (state, "M")) 
       {
         ERRload_struct (NFM, NFM_E_MEM_OUT, "", NULL);
         status = NFM_E_MEM_OUT;
       }
       else if (! strcmp (state, "MN"))
       {
         ERRload_struct (NFM, NFM_E_MEM_OUT_NO_FILE, "", NULL);
         status = NFM_E_MEM_OUT_NO_FILE;
       }

       else if (! strcmp (state, "TI"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_IN_TRANS, "", NULL);
         status = NFM_E_ITEM_IN_TRANS;
       }
       else if (! strcmp (state, "TO"))
       {
         ERRload_struct (NFM, NFM_E_ITEM_OUT_TRANS, "", NULL);
         status = NFM_E_ITEM_OUT_TRANS;
       }
       else if (! strcmp (state, "NI"))
       {
         ERRload_struct (NFM, NFM_E_NO_FILE_IN_TRANS, "", NULL);
         status = NFM_E_NO_FILE_IN_TRANS;
       }
       else if (! strcmp (state, "NO"))
       {
         ERRload_struct (NFM, NFM_E_NO_FILE_OUT_TRANS, "", NULL);
         status = NFM_E_NO_FILE_OUT_TRANS;
       }
       else if (! strncmp (state, "T", 1))
       {
         /* 2/18/93, take care of new "T_" values that were introduced with
                     I/NFM 3.x.x.x new commands */

         ERRload_struct (NFM, NFM_E_ITEM_IN_TRANS, "", NULL);
         status = NFM_E_ITEM_IN_TRANS;
       }
       else
       {
         ERRload_struct (NFM, NFM_E_UNKNOWN_CO_FLAG, "", NULL);
         status = NFM_E_UNKNOWN_CO_FLAG;
       }

       if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "Item CO Status = <%s> : status = <0x%.8x>\n",
		      state, status));
          return (status);
        }

      _NFMdebug ((fname, "Co Status = <%s> : SUCCESSFUL : status = <0x%.8x>\n",
		  state, NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

