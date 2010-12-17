#include "machine.h"
#include <stdio.h>
#include "DEBUG.h"
#include "MEMstruct.h"
#include "WFstruct.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "RPSdef.h"
#include "NFMsacdef.h"
#include "NFMRextern.h"
#include "NFMdef.h"
#include "ERR.h"
#include "NFIcommands.h"

extern MSGptr NFMmsg_ptr;


long ADMindex_comp ()
{
   long  status = 0;
   int   i;
   char  qry_str[1024], index_col[50];
   char  **data;
   MEMptr buffer=NULL;
   MEMptr return_buffer=NULL;
  static char *fname = "ADMindex_comp";
  
  _NFMdebug (( fname,"ENTER\n"));

  sprintf (qry_str, "SELECT nfmindex.%s, nfmindex.%s",
           "n_indexslot","n_tablename ");
  strcat(qry_str, "FROM NFMINDEX");

   status = SQLquery(qry_str, &buffer, MEM_SIZE);
   if((status != SQL_S_SUCCESS) && ((status) != SQL_I_NO_ROWS_FOUND))
    {
       MEMclose(&buffer);
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);

     }


    status = MEMbuild_array (buffer);

    if(status != MEM_S_SUCCESS)
    {
      _NFMdebug((fname, "MEMbuild_arry = <0x%.8x>\n", status));
      MEMclose(&buffer);
      return(status);
    }

    data = (char **) buffer->data_ptr;   

    for(i=0; i<buffer->rows; i++)
     {
       _NFMdebug((fname, "data : <0x%.8x>\n",i));

       if ( strcmp(data[i*buffer->columns + 1], "nfmacls") ==0)
         strcpy( index_col, "n_aclno");

       else if (strcmp(data[i*buffer->columns +1], "nfmarchives")==0)
         strcpy( index_col, "n_archiveno");

       else if (strcmp(data[i*buffer->columns +1], "nfmattributes")==0)
         strcpy( index_col, "n_attrno");

       else if (strcmp(data[i*buffer->columns +1], "nfmcatalogaclmap")==0)
         strcpy( index_col, "n_mapno");

       else if (strcmp(data[i*buffer->columns +1], "nfmcatalogs")==0)
         strcpy( index_col, "n_catalogno");

       else if (strcmp(data[i*buffer->columns +1], "nfmcatalogsamap")==0)
         strcpy( index_col, "n_mapno");

       else if (strcmp(data[i*buffer->columns +1], "nfmclasses")==0)
         strcpy( index_col, "n_classno");

       else if (strcmp(data[i*buffer->columns +1], "nfmcommands")==0)
         strcpy( index_col, "n_commandno");

       else if (strcmp(data[i*buffer->columns +1], "nfmlists")==0)
         strcpy( index_col, "n_listno");

       else if (strcmp(data[i*buffer->columns +1], "nfmnodes")==0)
         strcpy( index_col, "n_nodeno");

       else if (strcmp(data[i*buffer->columns +1], "nfmprograms")==0)
         strcpy( index_col, "n_programno");

       else if (strcmp(data[i*buffer->columns +1], "nfmprojectcit")==0)
         strcpy( index_col, "n_citno");

       else if (strcmp(data[i*buffer->columns +1], "nfmprojects")==0)
         strcpy( index_col, "n_projectno");

       else if (strcmp(data[i*buffer->columns +1], "nfmreports")==0)
         strcpy( index_col, "n_reportno");

       else if (strcmp(data[i*buffer->columns +1], "nfmsetcit")==0)
         strcpy( index_col, "n_citno");

       else if (strcmp(data[i*buffer->columns +1], "nfmstoragearea")==0)
         strcpy( index_col, "n_sano");

       else if (strcmp(data[i*buffer->columns +1], "nfmsysattributes")==0)
         strcpy( index_col, "n_attrno");

       else if (strcmp(data[i*buffer->columns +1], "nfmsyscat")==0)
         strcpy( index_col, "n_rowno");

       else if (strcmp(data[i*buffer->columns +1], "nfmtables")==0)
         strcpy( index_col, "n_tableno");

       else if (strcmp(data[i*buffer->columns +1], "nfmtransitions")==0)
         strcpy( index_col, "n_transitionno");

       else if (strcmp(data[i*buffer->columns +1], "nfmworkflow")==0)
         strcpy( index_col, "n_workflowno");

       else if (strncmp(data[i*buffer->columns +1], "f_",2)==0)
         strcpy( index_col, "n_fileno");

        else
         strcpy(index_col , "n_itemno"); 
                 
  sprintf(qry_str,"SELECT %s FROM %s WHERE %s=%s", index_col, 
            data[i*buffer->columns+1], index_col, data[i*buffer->columns]);

  status = SQLquery(qry_str, &return_buffer, MEM_SIZE);
  if((status != SQL_S_SUCCESS) && ((status) != SQL_I_NO_ROWS_FOUND))
   {
     MEMclose(&return_buffer);
     ERRload_struct (NFM, NFM_E_SQL_QUERY, "%s%s", index_col,data[i*buffer->columns+1]);
     _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
     return (NFM_E_SQL_QUERY);
   }

  if (status != SQL_I_NO_ROWS_FOUND)
   {
     sprintf (qry_str, "DELETE FROM nfmindex WHERE n_indexslot = %s", 
      data[i*buffer->columns]);
     status = SQLstmt (qry_str);
     sprintf(msg, "Deleting From <%s>.........", data[i*buffer->columns+1]);
     SCdisplay_msg (msg);    

     if (status != SQL_S_SUCCESS) 
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "",NULL) ;
       _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",  status));
       return (NFM_E_SQL_STMT);
      }
   }

   _NFMdebug ((fname, "EMPTY SLOT EXISTS : status = <0x%.8x>\n",status));

     MEMclose(&return_buffer);
  }
   MEMclose(&buffer);
   _NFMdebug((fname, "EXIT >> SUCCESSFUL\n"));
   return(NFM_S_SUCCESS);
}

