#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "RPSdef.h"
#include "NFMsacdef.h"
#include "NFMRextern.h"
#include "NFMdef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFIcommands.h"
#include "NFIerrordef.h"


extern MSGptr NFMmsg_ptr;


long ADMpurge_activity (user_id,out_list)
long      user_id;
MEMptr    *out_list;
{
   long  status = 0;
   int   i;
   int  NO_ROW_FUND;
   char  qry_str[1024];

  static char *fname = "ADMpurge_activity";
  
  _NFMdebug (( fname,"ENTER\n"));

/* check if the out_list pointer is NULL */

   if (out_list == MEMPTRNULL)
    {
      _NFMdebug((fname, "MEMptr list address is <%d>\n", out_list));
      status = ERRload_struct(NFM, NFM_E_NULL_OUTPUT_MEMPTR, "%s", "Output Buffer ptr");

        if(status!=ERR_S_SUCCESS)
          _NFMdebug((fname, "ERRload_struct status= <0x%.8x>\n", status));
     }

/*  make sure that the list is NULL as we will fill new info here */
    if (*out_list != MEMNULL)
    {

      _NFMdebug((fname, "List is non empty List=<0x%.8x>\n", *out_list));
      _NFMdebug((fname,  "MEMclose on List =<0x%.8x>\n", *out_list));
      MEMclose(out_list);
    }
   NO_ROW_FUND = 0;

   strcpy (qry_str, "SELECT n_date FROM nfmactivity");

   if((status = SQLquery(qry_str, out_list, MEM_SIZE))!=SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "qry_str status is <0x%.8x>\n", status));
        MEMclose(out_list);
        if(status == SQL_I_NO_ROWS_FOUND)
         {
            NO_ROW_FUND = 1;
            ERRload_struct(NFM, SQL_I_NO_ROWS_FOUND, "%s","Found No Data.");
           /*if(status!=ERR_S_SUCCESS)*/
           _NFMdebug((fname, "NFM_E_NO_ROWS_FOUND <0x%.8x>\n", status));
           return(SQL_I_NO_ROWS_FOUND);
         }
     }
   
   MEMclose(out_list);

   strcpy (qry_str, "SELECT MIN(n_date) FROM nfmactivity");

   if((status = SQLquery(qry_str, out_list, MEM_SIZE))!=SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "qry_str status is <0x%.8x>\n", status));
        MEMclose(out_list);
/*
        if(status == SQL_I_NO_ROWS_FOUND)
         {
            NO_ROW_FUND = 1;
            status = ERRload_struct(NFM, SQL_I_NO_ROWS_FOUND, "%s","ADMpurge_activity");
           if(status!=ERR_S_SUCCESS)
           _NFMdebug((fname, "NFM_E_NO_ROWS_FOUND <0x%.8x>\n", status));
           return(SQL_I_NO_ROWS_FOUND);
         }
*/
/*        else
         {
         if(status!=ERR_S_SUCCESS)
         _NFMdebug((fname, "ERRload_struct status= <0x%.8x>\n", status));

       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);

         }*/
     }

      if (NO_ROW_FUND==1)
      {
        status = ERRload_struct(NFM,NFM_E_FAILURE,"%s%s","ADMactivity","Found No Data.");
       if(status!=ERR_S_SUCCESS)
       _NFMdebug((fname, "NFM_E_FAILURE <0x%.8x>\n", status));
       return(NFM_E_FAILURE);
     }
    _NFMdebug((fname, "EXIT >> SUCCESSFUL\n"));
    return(NFM_S_SUCCESS);
}

