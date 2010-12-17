#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"


long PDMquery_catalog_attributes (cat_name,
                    attr_list, data_list, value_list)
   char     *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
       char *fname = "NFMquery_catalog_attributes" ;
     long     status;
     char     s[1024];

     sprintf(s, "Cat  Name = <%s>\n", cat_name );
     PDMdebug(s);

status = _NFMget_table_attr (cat_name,  attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Table attr : status = <0x%.8x>\n, status")) ;
         return (status) ;
       }

     status = _NFMget_data_value (*attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);
      }
     sprintf(s, "PDMquery_catalog_attributes:SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
     PDMdebug(s);
     return (NFM_S_SUCCESS);
   }


 long PDMget_user_name (user_id, user_no, user_name)
   long    user_id;
   long    user_no;
   char    *user_name;
   {
     long    status;
     char    sql_str [256];
     char    **data;
     char    s[1024];
     MEMptr  bufr=NULL;

     user_name [0] = '\0';

     sprintf(s,"USER NAME : User Id   = <%d>  ", user_id  );
      PDMdebug(s);
     sprintf(s, "USER NAME : User No   = <%d>  ", user_no  );
      PDMdebug(s);
      if (user_id == 0603)
       {
           sprintf (user_name, "%s", "INGR MAINT");
       }
      else
       {
        sprintf (sql_str, "SELECT n_username FROM nfmusers WHERE n_userno = %d",  user_no);

     status = SQLquery(sql_str,&bufr,512);

     if (status != SQL_S_SUCCESS)
      {
        if (status == SQL_I_NO_ROWS_FOUND)
         {
           /* status = NFMerror (NFM_E_BAD_USER); */
           status = ERRload_struct (NFM, NFM_E_BAD_USER, "", NULL);
           return (NFM_E_BAD_USER);
         }

        return (status);
      }
       status = MEMbuild_array(bufr);
        if(status != MEM_S_SUCCESS)
          {
              return(NFM_E_BAD_USER);
          }
       data = (char **)bufr->data_ptr; 
       strcpy(user_name,data[0]);
       MEMclose(&bufr);
       }

     _NFM_str ("USER NAME : User Name = <%s>\n", user_name);

     sprintf (s,"USER NAME : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      PDMdebug(s);
     return (NFM_S_SUCCESS);
   }

