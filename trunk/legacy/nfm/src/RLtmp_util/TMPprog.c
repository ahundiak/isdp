#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NFMstruct.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMapi.h" 
#include "NFMitems.h"
#include "NFMversion.h"
#include "ERR.h"
#include "NFMsysstruct.h"

extern struct NFMuser_info_struct NFMuser_info ;
extern long silent_mode ;


long TMPprogram ()
{
  char *fname = "TMPprogram"  ;
  long  status ;
  long  TMPtables();
  long  user_id;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMcheck_30version () ;
 if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname,  "Failure : Erroneous version\n")) ;
    return (status) ;
  }

  NFMuser_info.uid = getuid () ;
  NFMuser_info.gid = getgid () ;

  _NFMdebug ((fname, "Initialized the uid to <%d> and gid to <%d>\n",
          NFMuser_info.uid, NFMuser_info.gid)) ;

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
   {
     _NFMdebug((fname, "NFMstop_transaction : <0x%.8x>\n", status));
     return(status);
    }

  status =  TMPtables() ;
  if (status != NFM_S_SUCCESS)
   {
     NFMrollback_transaction(0);
     _NFMdebug ((fname, "Add Loc Entry : status = <0x%.8x>\n", status));
     return (status);
    }
   
   status = NFMstart_transaction(0);
   if (status !=NFM_S_SUCCESS)
     {
      NFMrollback_transaction(0);
      _NFMdebug ((fname, "Commit Work : status = <0x%.8x>\n", status));
      return(status);
     }
     
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long TMPtables ()
{
  char *fname = "TMPtables" ;
  long status ;
  long status1, ret_status ;
  long  attrno;
  long  tableno;
  long  seqno;
  long  table;
  long tab_value;
  long  _NFMget_next_slot();
  long   i;
  char sql_str [512] ;
  char str_sql[1024];
  char qry_str[1024];
  char sql_string[1024];
  char **data;
  MEMptr buffer=NULL; 
  MEMptr buf=NULL;
  MEMptr return_buffer=NULL; 
  _NFMdebug((fname, "Enter\n"));


  status = NFMstop_transaction (0);
  if (status !=NFM_S_SUCCESS)
   {
      _NFMdebug((fname, "NFMstop_transaction :<%0x%.8x>\n", status));
      return(status);
   }

  sprintf(qry_str, "select n_tableno from nfmattributes");

  ret_status = SQLquery(qry_str, &buf, MEM_SIZE);
/*
  if((ret_status != SQL_S_SUCCESS) && (ret_status!= SQL_I_NO_ROWS_FOUND))
    {
       MEMclose(&buf);
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);

     }

  data = (char**) buf->data_ptr;
  
  strcpy(tab_value, atol(data[0]));
 
  _NFMdebug((fname, " tab_value %d\n", tab_value));*/

  sprintf(str_sql, " select * from nfmtables \
         where (n_tablename = 'catalog'  and n_identifier = 'REDLINE') \
         or (n_tablename='f_catalog' \
            and n_identifier ='REDLINE')");

    status = SQLquery (str_sql, &buffer, MEM_SIZE) ;
  
    _NFMdebug ((fname, " enter here\n"));

    if((status != SQL_S_SUCCESS) && (status!= SQL_I_NO_ROWS_FOUND))
    {
       MEMclose(&buffer);
       ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_QUERY);

     }

    status1 = MEMbuild_array (buffer);
    if(status1 != MEM_S_SUCCESS)
     {
       _NFMdebug((fname, "MEMbuild_arry = <0x%.8x>\n", status));
       MEMclose(&buffer);
       return(status1);
     }
   /* MEMprint_buffer ("buffer", buffer, "/dev/console");*/
    
    if(status == SQL_I_NO_ROWS_FOUND)
    {
       status = _NFMget_next_slot ("nfmtables", "n_tableno", &tableno);
     
       if (status != NFM_S_SUCCESS)
       {
        _NFMdebug ((fname, "Failure : status = <0x%.8x\n", status));
        return (status);
       }

     _NFMdebug((fname, "TABLENO  is <%d>\n", tableno));

     sprintf (str_sql, "insert into nfmtables (n_tableno, n_tablename,\
          n_tabletype, n_identifier) values (%d, 'catalog', 't_basic', \
             'REDLINE')", tableno);
         status = SQLstmt (str_sql) ;

         if (status != SQL_S_SUCCESS)
          {
            NFMrollback_transaction(0);
            ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
            _NFMdebug((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
            return(NFM_E_SQL_STMT);
           }

        _NFMdebug((fname, " tableno1 %d \n",  tableno));

       status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);      
     
        sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_itemno', 'Item Number','integer',1,\
               'N', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM', null ,null ,null)",
               attrno, tableno);

         status = SQLstmt (str_sql) ;
         if (status != SQL_S_SUCCESS)
         {
          NFMrollback_transaction(0);
          ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug((fname, "SQL Stmt Syntax : status1 = <0x%.8x>\n", status));
            return(NFM_E_SQL_STMT);
          }

      status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

      sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_itemname', 'Item Name','char(22)',2,\
               'Y', 'Y', 'N', 'N', 'N', 'Y','Y', 'NFM', null ,null,null)",
               attrno, tableno);

       status = SQLstmt (str_sql) ;
       if (status != SQL_S_SUCCESS)
        {
          NFMrollback_transaction(0);
          ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug((fname, "SQL Stmt Syntax : status2 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
         }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_itemrev', 'Revision','char(15)',3,\
               'Y', 'Y', 'N', 'N', 'N', 'Y','Y', 'NFM',null,null, null)",
               attrno, tableno);

    status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status3 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
      }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_itemdesc', 'Description','char(40)',4,\
               'Y', 'Y', 'Y', 'N', 'Y', 'N','N', 'NFM',null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status4 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_setindicator', 'Set','char(1)',5,\
               'Y', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM',null,null, null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
      NFMrollback_transaction(0);
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL Stmt Syntax : status5 = <0x%.8x>\n", status));
      return(NFM_E_SQL_STMT);
     }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_versionlimit', 'Version Limit','integer',6,\
               'Y', 'Y', 'Y', 'N', 'N', 'N','N', 'NFM',null, null,null)",
              attrno,tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status6 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_status', 'File Status','char(2)',7,\
               'Y', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM',null,null,null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status7 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_pendingflag', 'Pending Flag','char(2)',8,\
               'Y', 'N', 'N', 'N', 'Y', 'N','N', 'NFM',null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
      NFMrollback_transaction(0);
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL Stmt Syntax : status8 = <0x%.8x>\n", status));
      return(NFM_E_SQL_STMT);
     }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_itemlock', 'Locked','char(1)',9,\
               'Y', 'N', 'N', 'N', 'N', 'N','N', 'NFM',null, null, null)",
               attrno, tableno);

    status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
      NFMrollback_transaction(0);
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL Stmt Syntax : status9 = <0x%.8x>\n", status));
      return(NFM_E_SQL_STMT);
     }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_aclno', 'Acl','integer',10,\
               'Y', 'Y', 'N', 'N', 'N', 'N','N', 'NFM',null, null,null)",
               attrno, tableno);

    status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status10 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
     }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_stateno', 'State','integer',11,\
               'Y', 'N', 'N', 'N', 'N', 'N','N', 'NFM',null, null,null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status11 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_prevstateno', 'Previous State','integer',12,\
               'Y', 'N', 'N', 'N', 'Y', 'N','N', 'NFM',null,null,null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status13 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_creator', 'Creator','char(14)',13,\
               'Y', 'N', 'N', 'N', 'N', 'N','N', 'NFM',null, null,null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status14 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

       status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_creationdate', 'Creation Date/Time',\
              'timestamp',14,\
               'Y', 'N', 'N', 'N', 'N', 'N','N', 'NFM',null,null, null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status15 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_updater', 'Updater','char(14)',15,\
               'Y', 'N', 'N', 'N', 'Y', 'N','N', 'NFM',null, null,null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status16 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_updatedate', 'Update Date/Time',\
              'timestamp',16,\
               'Y', 'N', 'N', 'N', 'N', 'N','N', 'NFM',null,null,null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status17 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_colevel', 'Set Level','integer',17,\
               'N', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM',null, null,null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
   if (status != SQL_S_SUCCESS)
    {
      NFMrollback_transaction(0);
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL Stmt Syntax : status18 = <0x%.8x>\n", status));
      return(NFM_E_SQL_STMT);
    }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_archivestate', 'Archive State',\
              'char(1)',18,\
               'Y', 'N', 'N', 'N', 'Y', 'N','N', 'NFM',null, null,null)",
               attrno, tableno);

    status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status19 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
     }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_iconname', 'Looking Glass Icon Name',\
              'char(40)',19,\
               'N', 'N', 'N', 'Y', 'N', 'N','N', 'NFM',null,null, null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status20 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_lgfiletype', 'Looking Glass File Type',\
              'integer',20,\
               'N', 'N', 'N', 'Y', 'N', 'N','N', 'NFM',null, null, null)",
               attrno, tableno);

      status = SQLstmt (str_sql) ;
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction(0);
         ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug((fname, "SQL Stmt Syntax : status21 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }


     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_detitemno', 'Detail File Item Number',\
              'integer',21,\
               'Y', 'Y', 'Y', 'Y', 'Y', 'Y','Y', 'NFM',null, null, null)",
               attrno, tableno);

      status = SQLstmt (str_sql) ;
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction(0);
         ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug((fname, "SQL Stmt Syntax : status21 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }


     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_detfileno', 'Detail File File Number',\
              'integer',22,\
               'Y', 'Y', 'Y', 'Y', 'Y', 'Y','Y', 'NFM',null, null, null)",
               attrno, tableno);

      status = SQLstmt (str_sql) ;
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction(0);
         ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug((fname, "SQL Stmt Syntax : status21 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }


     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, " insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_redlayerno', 'Redline Layer Number',\
              'integer',23,\
               'Y', 'Y', 'Y', 'Y', 'Y', 'Y','Y', 'NFM',null, null, null)",
               attrno, tableno);

      status = SQLstmt (str_sql) ;
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction(0);
         ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug((fname, "SQL Stmt Syntax : status21 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'd_color', 'Color',\
              'integer',24,\
               'Y', 'Y', 'Y', 'N', 'N', 'Y','Y', 'NFM', null, null, null)",
               attrno, tableno);

      status = SQLstmt (str_sql) ;
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction(0);
         ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug((fname, "SQL Stmt Syntax : status42 = <0x%.8x>\n", status));
         return(NFM_E_SQL_STMT);
       }

      status = _NFMget_next_slot ("nfmtables", "n_tableno", &tableno);
           
      if (status != NFM_S_SUCCESS)
       {
        _NFMdebug ((fname, "Failure : status = <0x%.8x\n", status));
        return (status1);
       }
      _NFMdebug((fname, "f_tableno is <%d>\n", tableno));

       sprintf (str_sql, "insert into nfmtables (n_tableno, n_tablename,\
         n_tabletype, n_identifier) values (%d, 'f_catalog', 't_basic', \
        'REDLINE')", tableno);
       status = SQLstmt (str_sql) ;
       if (status != SQL_S_SUCCESS)
        {
          NFMrollback_transaction(0);
          ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug((fname, "SQL Stmt Syntax : status22 = <0x%.8x>\n", status));
          return(NFM_E_SQL_STMT);
         }

      _NFMdebug((fname, " tableno1 %d \n",  tableno));

       if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
        {
         _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
         return (NFM_E_SQL_STMT) ;
        }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_fileno', 'File Number', 'integer',1,\
               'N', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM',null,null,null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status23 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_itemnum', 'Item Number', 'integer',2,\
               'N', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM', null, null,null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status24 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql,"insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_filenum', 'File Position', 'integer',3,\
               'N', 'N', 'N', 'N', 'N', 'N','N', 'NFM', null, null, null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status25 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cofilename', 'Local File Name', \
              'char(14)',4,\
               'Y', 'Y', 'Y', 'N', 'Y', 'U','U', 'NFM', null, null, null)",
              attrno, tableno);

    status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status26 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
     }

    status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_fileversion', 'Version',\
              'integer',5,\
               'Y', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM',null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status27 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_filetype', 'File Type',\
              'char(5)',6,\
               'Y', 'Y', 'Y', 'N', 'Y', 'U','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
   if (status != SQL_S_SUCCESS)
    {
      NFMrollback_transaction(0);
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL Stmt Syntax : status28 = <0x%.8x>\n", status));
      return(NFM_E_SQL_STMT);
     }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_fileclass', 'File Class',\
              'char(1)',7,\
               'Y', 'N', 'N', 'N', 'N', 'Y','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status29 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_restoreflag', 'Restore Flag',\
              'char(2)',8,\
               'Y', 'N', 'N', 'N', 'Y', 'N','N', 'NFM',null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status30 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_archiveno', 'Archive Number',\
              'integer',9,\
               'N', 'N', 'N', 'N', 'Y', 'N','N', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status31 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cisano', 'Internal Location',\
              'integer',10,\
               'Y', 'Y', 'Y', 'N', 'Y', 'U','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status32 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cifilename', 'Internal File Name',\
              'char(14)',11,\
               'Y', 'Y', 'Y', 'N', 'Y', 'U','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status33 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_ciuser', 'Check In User',\
              'char(14)',12,\
               'Y', 'N', 'N', 'N', 'Y', 'Y','N', 'NFM',null,null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status34 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cidate', 'Check In Date/Time',\
              'timestamp',13,\
               'Y', 'N', 'N', 'N', 'Y', 'Y','N', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status35 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cifilesize', 'File Size',\
              'integer',14,\
               'Y', 'N', 'N', 'N', 'Y', 'Y','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status36 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cocomment', 'Check Out Comment',\
              'char(40)',15,\
               'Y', 'N', 'Y', 'N', 'Y', 'N','U', 'NFM',null, null, null)",
               attrno, tableno);

         status = SQLstmt (str_sql) ;

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_cosano', 'Working Location',\
              'integer',16,\
               'Y', 'N', 'N', 'N', 'Y', 'Y','U', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status37 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_couser', 'Check Out User',\
              'char(14)',17,\
               'Y', 'N', 'N', 'N', 'Y', 'Y','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status38 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_codate', 'Check Out Date/Time',\
              'timestamp',18,\
               'Y', 'N', 'N', 'N', 'Y', 'N','Y', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
    if (status != SQL_S_SUCCESS)
     {
       NFMrollback_transaction(0);
       ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug((fname, "SQL Stmt Syntax : status39 = <0x%.8x>\n", status));
       return(NFM_E_SQL_STMT);
     }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_fileco', 'Check Out Flag',\
              'char(1)',19,\
               'Y', 'N', 'N', 'N', 'Y', 'Y','Y', 'NFM', null, null, null)",
              attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status40 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
      }

     status = _NFMget_next_slot ("nfmattributes", "n_attrno", &attrno);

     sprintf( str_sql, "insert into nfmattributes (n_attrno, n_tableno,\
              n_name, n_synonym, n_datatype, n_seqno, n_read, n_write,\
              n_update, n_delete, n_null,  n_checkin, n_checkout,\
              n_application, n_lattrno, n_jointable, n_joinattrno) \
              values ( %d, %d, 'n_convertind', 'Convert Indicator',\
              'char(10)',20,\
               'N', 'N', 'N', 'N', 'Y', 'N','N', 'NFM', null, null, null)",
               attrno, tableno);

     status = SQLstmt (str_sql) ;
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction(0);
        ERRload_struct(NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug((fname, "SQL Stmt Syntax : status41 = <0x%.8x>\n", status));
        return(NFM_E_SQL_STMT);
       }

}
    strcpy (sql_string,   "SELECT n_description FROM nfmsyscat WHERE\
             n_infotype = 'VERSION'") ;
    status = SQLquery (sql_string,   &return_buffer,   MEM_SIZE) ;
    if (status != SQL_S_SUCCESS)
    {
        ERRload_struct (NFM,   NFM_E_SQL_QUERY,  "",   "") ;
        _NFMdebug ((fname,   "Failure : status = <0x%.8x>\n", 
            status)) ;
        return (NFM_E_SQL_QUERY) ;
    }

    sprintf ( sql_string,  "UPDATE nfmsyscat SET n_description = '%s'\
                  where n_infotype = 'VERSION'",  NFMversion);
    status = SQLexec_imm (sql_string);
     if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
      {
         ERRload_struct (NFM,  NFM_E_MESSAGE,  "%s",  "Updating NFM revision failed") ;
          return (NFM_E_MESSAGE) ;
      }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMget_next_slot (tablename, columnname, next_slot)
     char *tablename ;
     char *columnname ;
     long *next_slot ;
{
  char *fname = "_NFMget_next_slot" ;
  long status ;
  char sql_str [1024] ;
  MEMptr sql_buffer = NULL ;
  char **data ;

  _NFMdebug ((fname, "tablename <%s> : columnname <%s>\n",
	      tablename, columnname)) ;
  sprintf (sql_str, "select MAX(%s) from %s",
	   columnname, tablename) ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", 
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) sql_buffer -> data_ptr ;

  *next_slot = atol (data[0]) + 1 ;

  MEMclose (&sql_buffer) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


