#include <stdio.h>
#include <memory.h>
#include "SQLerrordef.h"
#include "PDUris_incl.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

extern struct NFMglobal_st NFMglobal ;
extern PDMexec_ptr PDMexec;
extern int      PDMdebug_on;
extern char PDM_DEBUG_FILE[];
extern char PDMdynamic_table[20];


/* Kumar - 10/2/92 */

long PDMprepare_change_parametric_catalog 
   (
   long      user_id,
   char      *cat_name,
   MEMptr    *loc_attr, 
   MEMptr    *loc_data,
   MEMptr    *loc_list,
   MEMptr    *attr_list, 
   MEMptr    *data_list,
   MEMptr    *value_list,
   char      **dyn_table,
   MEMptr    *dynamic_attr,
   MEMptr    *dynamic_data,
   MEMptr    *dynamic_list
   )

{
char *fname = "PDMprepare_change_parametric_catalog";
char  sql_str[240],loc_name[20], **data=NULL;
long  status;
int   cat_no;
MEMptr bufr=NULL;

     _PDMdebug(fname,"ENTER\n");
     *loc_attr = NULL;
     *loc_data = NULL;
     *loc_list = NULL;
     *attr_list = NULL;
     *data_list = NULL;
     *value_list = NULL;
     *dynamic_attr = NULL;
     *dynamic_data = NULL;
     *dynamic_list = NULL;

     status = NFMget_catalog_no (user_id, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Get Catalog No : status = <0x%.8x>\n", status);
        return (NFM_E_BAD_CATALOG) ;
      }

      status = NFMquery_changeto_loc_attributes(user_id, loc_name,cat_name,
                              loc_attr, loc_data, loc_list); 
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "NFMquery_changeto_loc_attr : status = <0x%.8x>\n", status);
        return (status) ;
      }
      status = NFMquery_change_table_information(user_id,"CATALOG",
                    cat_name, attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "NFMquery_change_table_info : status = <0x%.8x>\n", status);
        return (status) ;
      }

         sprintf(sql_str,"SELECT p_dyntable FROM pdmcatalogs WHERE n_catalogno = %d", cat_no);
             status = SQLquery(sql_str,&bufr,512);
              if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
               {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               return (status) ;
                }
          if(status == SQL_I_NO_ROWS_FOUND)
             return (PDM_S_SUCCESS);

           status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
           {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               return (status) ;
           }
           data = (char **) bufr->data_ptr;

         if(!strcmp(data[0],"") || data[0] == NULL)
           {
            MEMclose(&bufr);
            return(PDM_S_SUCCESS);
            }
           *dyn_table = (char *) malloc (21);
          strcpy(*dyn_table,data[0]);
           
          if(strcmp(*dyn_table,""))
          {
     status = NFMquery_change_table_information (user_id, data[0],data[0],dynamic_attr, dynamic_data, dynamic_list);
            if (status  != NFM_S_SUCCESS)
            {
                _PDMdebug(fname, "NFMquery_change_table_information = %d\n",
                                        status);
                return (PDM_E_GET_ATTRIBUTES);
             }
           }
          MEMclose(&bufr);
     _PDMdebug(fname,"EXIT\n");
     return(PDM_S_SUCCESS);
}
                                
/* 

   Kumar Narayanan  -  10/5/93

*/

long PDMchange_parametric_catalog 
   (
   long      user_id,
   MEMptr    loc_attr, 
   MEMptr    loc_data,
   MEMptr    attr_list, 
   MEMptr    data_list,
   MEMptr    value_list,
   char      *dyn_table,
   MEMptr    dynamic_attr,
   MEMptr    dynamic_data,
   MEMptr    dynamic_list
   )
   {
     char    *fname = "PDMchange_parametric_catalog" ;
     long     status, atol ();
     char     **column, **data, **data1, sql_str[512];
     long     a, b, i ;
     long     x, y, count;
     int      n_catalogno, dyn_no;
     char     cat_name [100],pdc_tbl[25], pdc_tbl1[27], cat_name_old [100];
     long     NFMupdate_loc_entry ();
     long     NFMreset_loc_entry () ;

     _PDMdebug (fname, "ENTER\n");
 
     strcpy(PDMdynamic_table,"");
     status = MEMbuild_array (loc_attr);
     if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status) ;
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (loc_data);
     if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status);
        return (NFM_E_MEM);
      }

     column = (char **) loc_attr -> column_ptr;
     data   = (char **) loc_attr -> data_ptr;

     data1  = (char **) loc_data -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < loc_attr -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }
       

     i = -1;

     for (x = 0; x < loc_attr -> rows; ++x)
      {
        count = loc_attr -> columns * x;
 
        if (! strcmp (data [count + a], "n_catalogname"))  i = x;
      }

     sprintf (cat_name,     "%s", data1 [i]);
     sprintf (cat_name_old, "%s", data1 [(loc_data -> columns) + i]);

    status = PDMget_table_no(cat_name_old,"catalog",&n_catalogno);
    if(status != PDM_S_SUCCESS)
    {
            _PDMdebug(fname,"\tPDMget_table_no failed : status %d\n",status);
                return(PDM_E_CATALOG_NOT_FOUND);
    }
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Stop Transaction : status = <0x%.8x>\n", status);
        return (status);
      }
     status = NFMchange_table (user_id, "CATALOG", cat_name,
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "Create Cat : status = <0x%.8x>\n", status);
        return (status);
      }

 if(dynamic_attr != NULL) {
    _PDMdebug(fname,"dyn_table =  %s\n",dyn_table);
    if( dyn_table != NULL && strcmp(dyn_table,"") && strlen(dyn_table))
          strcpy(pdc_tbl,dyn_table);
    else strcpy(pdc_tbl,cat_name);
        _PDMdebug(fname,"pdc_tbl =  %s\n",pdc_tbl);

    status = PDMget_table_no(pdc_tbl,pdc_tbl,&dyn_no);
    if(status != PDM_S_SUCCESS)
      {
        _PDMdebug (fname, "Failed with %s.%s\n", pdc_tbl, pdc_tbl);
        PDMconvert_to_lower(pdc_tbl, pdc_tbl1);
        _PDMdebug (fname, "trying with %s.%s\n", pdc_tbl1, pdc_tbl1);
        status = PDMget_table_no(pdc_tbl1,pdc_tbl1,&dyn_no);
         _PDMdebug (fname, "PDMget_table_no : status = <0x%.8x>\n", status);
        if(status == PDM_E_TABLE_NOT_FOUND)
         {
          _PDMdebug (fname, "Failed with %s.%s\n", pdc_tbl1, pdc_tbl1);
          _PDMdebug (fname, "trying with %s.%s\n", pdc_tbl, pdc_tbl1);
          status = PDMget_table_no(pdc_tbl,pdc_tbl1,&dyn_no);
          _PDMdebug (fname, "PDMget_table_no : status = <0x%.8x>\n", status);
          if(status == PDM_E_TABLE_NOT_FOUND)
            {
             _PDMdebug (fname, "Failed with %s.%s; Calling NFMcreate_table\n", 
                                                   pdc_tbl, pdc_tbl1);
             status = NFMcreate_table (user_id, pdc_tbl,pdc_tbl,"PDM", 
                                       dynamic_attr, dynamic_data,dynamic_list);
                if (status != NFM_S_SUCCESS)
                  {
                   /*
                   NFMreset_change_table (user_id, "CATALOG", cat_name, 
                   attr_list, data_list, value_list);
                   */
                   NFMrollback_transaction (0);
                   _PDMdebug(fname,"NFMcreate_table failed : %d\n",status);
                   return(status);
                   }
                strcpy(PDMdynamic_table,pdc_tbl);
                   }
           else if(status == PDM_S_SUCCESS)
              {
              status = NFMchange_table(user_id,pdc_tbl1, pdc_tbl,dynamic_attr,
                                  dynamic_data,dynamic_list);
               if (status != NFM_S_SUCCESS)
               {
                   NFMrollback_transaction (0);
                  _PDMdebug(fname,"NFMchange_table failed : %d\n",status);
                   /*
                   NFMreset_change_table (user_id, "CATALOG", cat_name, 
                   attr_list, data_list, value_list);
                   */
                   NFMreset_change_table(user_id,pdc_tbl, pdc_tbl,
                  dynamic_attr,dynamic_data,dynamic_list);
                   return(status);
                     }
              strcpy(PDMdynamic_table,pdc_tbl);
              }
          }
       else if(status == PDM_S_SUCCESS)
        {
         status = NFMchange_table(user_id,pdc_tbl1, pdc_tbl1,dynamic_attr,
                                  dynamic_data,dynamic_list);
          if (status != NFM_S_SUCCESS)
             {
              NFMrollback_transaction (0);
             _PDMdebug(fname,"NFMchange_table failed : %d\n",status);
              /*
              NFMreset_change_table (user_id, "CATALOG", cat_name, 
              attr_list, data_list, value_list);
              */
              NFMreset_change_table(user_id,pdc_tbl, pdc_tbl,
             dynamic_attr,dynamic_data,dynamic_list);
              return(status);
              }
          strcpy(PDMdynamic_table,pdc_tbl);
         }
       }
       else if(status == PDM_S_SUCCESS)
        {
         status = NFMchange_table(user_id,pdc_tbl, pdc_tbl,dynamic_attr,
                                  dynamic_data,dynamic_list);
          if (status != NFM_S_SUCCESS)
             {
              NFMrollback_transaction (0);
             _PDMdebug(fname,"NFMchange_table failed : %d\n",status);
              NFMreset_change_table (user_id, "CATALOG", cat_name, 
              attr_list, data_list, value_list);
              NFMreset_change_table(user_id,pdc_tbl, pdc_tbl,
             dynamic_attr,dynamic_data,dynamic_list);
              return(status);
               }
          strcpy(PDMdynamic_table,pdc_tbl);
         }

    sql_str[0] = '\0';
    sprintf(sql_str,"%s %s %d", "DELETE FROM pdmbommap ","WHERE n_catalogno = ",
        n_catalogno);
    SQLstmt(sql_str);

     status = NFMupdate_loc_entry (user_id, loc_attr, loc_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list, data_list, value_list);
        NFMreset_change_table (user_id, pdc_tbl, pdc_tbl, 
        dynamic_attr,dynamic_data,dynamic_list);
        _PDMdebug (fname, "Add Loc Entry : status = <0x%.8x>\n", status);
        return (status);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {

        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list, data_list, value_list);
        NFMreset_change_table (user_id, pdc_tbl, pdc_tbl, 
        dynamic_attr,dynamic_data,dynamic_list);
	NFMreset_loc_entry (user_id, loc_attr, loc_data);
        _PDMdebug (fname, "Start Transaction : status = <0x%.8x>\n",
        status);
        return (status);
      }

     }
     _PDMdebug (fname, "SUCCESSFUL\n");
     return (PDM_S_SUCCESS);
   }

/*

  Kumar Narayanan - 10/10/93

*/

long PDMchange_view_catalog 
   (
   long      user_id,
   MEMptr    loc_attr,
   MEMptr    loc_data,
   MEMptr    attr_list, 
   MEMptr    data_list,
   MEMptr    value_list,
   char      *dyn_table,
   MEMptr    dynamic_attr,
   MEMptr    dynamic_data,
   MEMptr    dynamic_list
   )
{
     char    *fname = "PDMchange_view_catalog" ;
     long     status, atol ();
     char     **column, **data, **data1, sql_str[512];
     long     a, b, i ;
     long     x, y, count;
     int      n_catalogno, dyn_no;
     char     cat_name [100],pdc_tbl[25], pdc_tbl1[26], cat_name_old [100];
     long     NFMupdate_loc_entry ();
     long     NFMreset_loc_entry () ;

     _PDMdebug (fname, "ENTER\n");
/* Added support of dynamic table for view catalog */ 
     PDMdynamic_table [0] = '\0';

     status = MEMbuild_array (loc_attr);
     if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status) ;
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (loc_data);
     if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status);
        return (NFM_E_MEM);
      }

     column = (char **) loc_attr -> column_ptr;
     data   = (char **) loc_attr -> data_ptr;

     data1  = (char **) loc_data -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < loc_attr -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }
       

     i = -1;

     for (x = 0; x < loc_attr -> rows; ++x)
      {
        count = loc_attr -> columns * x;
 
        if (! strcmp (data [count + a], "n_catalogname"))  i = x;
      }

     sprintf (cat_name,     "%s", data1 [i]);
     sprintf (cat_name_old, "%s", data1 [(loc_data -> columns) + i]);

    status = PDMget_table_no(cat_name_old,"pdmview",&n_catalogno);
    if(status != PDM_S_SUCCESS)
    {
            _PDMdebug(fname,"\tPDMget_table_no failed : status %d\n",status);
                return(PDM_E_CATALOG_NOT_FOUND);
    }
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Stop Transaction : status = <0x%.8x>\n", status);
        return (status);
      }
     status = NFMchange_template (cat_name, "PDMVIEW", "PDM",
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "Create Cat : status = <0x%.8x>\n", status);
        return (status);
      }

 if(dynamic_attr != NULL)
    {
         _PDMdebug(fname,"Dynamic table : %s\n",dyn_table);
        if( dyn_table != NULL && strcmp(dyn_table,"") && strlen(dyn_table))
        strcpy(pdc_tbl,dyn_table);
        else  sprintf(pdc_tbl,"y_%s",cat_name);

    status = PDMget_table_no(pdc_tbl,pdc_tbl,&dyn_no);
    if(status != PDM_S_SUCCESS)
    {
        _PDMdebug (fname, "Failed with %s.%s\n", pdc_tbl, pdc_tbl);
     PDMconvert_to_lower(pdc_tbl, pdc_tbl1);
        _PDMdebug (fname, "trying with %s.%s\n", pdc_tbl1, pdc_tbl1);
     status = PDMget_table_no(pdc_tbl1,pdc_tbl1,&dyn_no);
     _PDMdebug (fname, "PDMget_table_no : status = <0x%.8x>\n", status);
     if(status == PDM_E_TABLE_NOT_FOUND)
         {
          _PDMdebug (fname, "Failed with %s.%s\n", pdc_tbl1, pdc_tbl1);
          _PDMdebug (fname, "trying with %s.%s\n", pdc_tbl, pdc_tbl1);
          status = PDMget_table_no(pdc_tbl,pdc_tbl1,&dyn_no);
          _PDMdebug (fname, "PDMget_table_no : status = <0x%.8x>\n", status);
           if(status == PDM_E_TABLE_NOT_FOUND)
             {
             _PDMdebug (fname, "Failed with %s.%s; Calling NFMcreate_table\n", 
                                                   pdc_tbl, pdc_tbl1);
             status = NFMcreate_table (user_id, pdc_tbl,pdc_tbl,"PDM", 
                                       dynamic_attr, dynamic_data,dynamic_list);
                if (status != NFM_S_SUCCESS)
                  {
                   NFMrollback_transaction (0);
                   _PDMdebug(fname,"NFMcreate_table failed : %d\n",status);
                   return(status);
                   }
             strcpy(PDMdynamic_table,pdc_tbl);
              }
              else if (status == PDM_S_SUCCESS)
               {
               status = NFMchange_table(user_id,pdc_tbl1, pdc_tbl,dynamic_attr,
                                   dynamic_data,dynamic_list);
               if (status != NFM_S_SUCCESS)
                   {
                  NFMrollback_transaction (0);
                 _PDMdebug(fname,"NFMchange_table failed : %d\n",status);
                  NFMreset_change_table(user_id,pdc_tbl, pdc_tbl,
                  dynamic_attr,dynamic_data,dynamic_list);
                  return(status);
                   }
               }
             strcpy(PDMdynamic_table,pdc_tbl);
              }
        else
           {
         status = NFMchange_table(user_id,pdc_tbl1, pdc_tbl1,dynamic_attr,
                                  dynamic_data,dynamic_list);
          if (status != NFM_S_SUCCESS)
             {
              NFMrollback_transaction (0);
             _PDMdebug(fname,"NFMchange_table failed : %d\n",status);
              NFMreset_change_table(user_id,pdc_tbl, pdc_tbl,
             dynamic_attr,dynamic_data,dynamic_list);
              return(status);
              }
             strcpy(PDMdynamic_table,pdc_tbl);
            }
     }
     else if(status == PDM_S_SUCCESS)
        {
         status = NFMchange_table(user_id,pdc_tbl, pdc_tbl,dynamic_attr,
                                  dynamic_data,dynamic_list);
          if (status != NFM_S_SUCCESS)
             {
              NFMrollback_transaction (0);
             _PDMdebug(fname,"NFMchange_table failed : %d\n",status);
              NFMreset_change_table(user_id,pdc_tbl, pdc_tbl,
             dynamic_attr,dynamic_data,dynamic_list);
              return(status);
              }
             strcpy(PDMdynamic_table,pdc_tbl);
         }
    }

    sql_str[0] = '\0';
/*
    sprintf(sql_str,"%s %s %d", "DELETE FROM pdmbommap ","WHERE n_catalogno = ",
        n_catalogno);
    SQLstmt(sql_str);
*/

     status = NFMupdate_loc_entry (user_id, loc_attr, loc_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        NFMreset_change_table (user_id, pdc_tbl, pdc_tbl, 
        dynamic_attr,dynamic_data,dynamic_list);
        _PDMdebug (fname, "Add Loc Entry : status = <0x%.8x>\n", status);
        return (status);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {

        NFMreset_change_table (user_id, pdc_tbl, pdc_tbl, 
        dynamic_attr,dynamic_data,dynamic_list);
	NFMreset_loc_entry (user_id, loc_attr, loc_data);
        _PDMdebug (fname, "Start Transaction : status = <0x%.8x>\n",
        status);
        return (status);
      }

     _PDMdebug (fname, "SUCCESSFUL\n");
     return (PDM_S_SUCCESS);
}


/* 

Kumar Narayanan  - 10/18/92

*/

 long PDMdelete_parametric_catalog 
(
long user_id,
char  *cat_name, 
long  *cat_no
)
   {
     static char *fname = "PDMdelete_parametric_catalog" ;
     long     status;
     char     del_str[240];
     MEMptr   dyn_bufr = NULL, cat_bufr = NULL;
     char     **dyn_data; 
     long     NFMcheck_catalog_empty ();
     long     _NFMcheck_cat_no_mapping () ;
     long     NFMdelete_loc_entry ();

     *cat_no = 0;

     _PDMdebug (fname, "Cat  Name = <%s>\n", cat_name );

     status = NFMget_catalog_no (user_id, cat_name, cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Get Catalog No : status = <0x%.8x>\n", status);
        return (NFM_E_BAD_CATALOG) ;
      }

     status = NFMcheck_catalog_empty (user_id, cat_name);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Catalog not Empty  : Any deleting all the entries in the cat\n");
      sprintf(del_str,"DELETE FROM %s",cat_name);
       status = SQLstmt(del_str);
      }

     status = _NFMcheck_cat_no_mapping (user_id, *cat_no) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fname, "Cat Mappings exist\n", status) ;
	 return (status) ;
       }

     status = NFMdelete_table (user_id, "CATALOG", cat_name);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
        return (status);
      }

      sprintf(del_str,"SELECT p_dyntable FROM pdmcatalogs where n_catalogno = %d", *cat_no);
        status = SQLquery(del_str,&dyn_bufr,512);
         if(status == SQL_S_SUCCESS)
          {
           status = MEMbuild_array (dyn_bufr);
            if(status != MEM_S_SUCCESS)
             {
        _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
        return (status);
             } 
             dyn_data = (char **) dyn_bufr->data_ptr;
           sprintf(del_str,"SELECT n_catalogno FROM pdmcatalogs WHERE p_dyntable = '%s'", dyn_data[0]);
            status = SQLquery(del_str, &cat_bufr,512);
            if(status == SQL_S_SUCCESS)
             {
              status = MEMbuild_array (cat_bufr);
              if(status != MEM_S_SUCCESS)
              {
              _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
               return (status);
               } 
               if(cat_bufr->rows == 1)
               {
                 PDMconvert_to_lower(dyn_data[0], dyn_data[0]);
                 status = NFMdelete_table (user_id, dyn_data[0], dyn_data[0]);
                 if (status != NFM_S_SUCCESS)
                 {
                _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
                 return (status);
                }
               }
              }
               MEMclose(&cat_bufr);
               MEMclose(&dyn_bufr);
             }
                       
sprintf(del_str,"DELETE FROM pdmfnattrmap where n_catalogname = '%s'",cat_name);
       status = SQLstmt(del_str);
         if(status != SQL_S_SUCCESS)
         {
       _PDMdebug (fname, "No function-attr map for this catalog : status = <0x%.8x>\n", status);
         }

sprintf(del_str,"DELETE FROM pdmparamloc where n_catalogname = '%s'",cat_name);
       status = SQLstmt(del_str);
         if(status != SQL_S_SUCCESS)
         {
       _PDMdebug (fname, "No pdmparamloc entry for this catalog : status = <0x%.8x>\n", status);
         }
sprintf(del_str,"DELETE FROM pdmparameters where n_catalogname = '%s'",cat_name);
       status = SQLstmt(del_str);
         if(status != SQL_S_SUCCESS)
         {
       _PDMdebug (fname, "No pdmparameters for this catalog : status = <0x%.8x>\n", status);
         }
      sprintf(del_str,"DELETE FROM pdmcatalogs where n_catalogno = %d",*cat_no);
       status = SQLstmt(del_str);
         if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
         {
       _PDMdebug (fname, "Empty Catalog : status = <0x%.8x>\n", status);
        return (NFM_E_NOT_EMPTY_CAT);
         }

     status = NFMdelete_loc_entry (user_id, *cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Delete Loc Entry : status = <0x%.8x>\n", status);
        return (status);
      }
 

     _PDMdebug (fname, "Cat No = <%d> : SUCCESSFUL\n", *cat_no);

     return (PDM_S_SUCCESS);
 }


/*

Kumar Narayanan - 10/20/93

*/

 long PDMdelete_view_catalog 
(
long user_id,
char  *cat_name, 
long  *cat_no
)
{
     static char *fname = "PDMdelete_view_catalog" ;
     long     status = PDM_S_SUCCESS;
     MEMptr   dyn_bufr = NULL, pdmcit = NULL, cat_bufr = NULL;
     char     **dyn_data = NULL; 
     char     del_str[512] = "", e_cat[21] = "", lower_dyn_table[21] = "";
     long     NFMcheck_catalog_empty ();
     long     _NFMcheck_cat_no_mapping () ;
     long     NFMdelete_loc_entry ();

     *cat_no = 0;

     _PDMdebug (fname, "Cat  Name = <%s>\n", cat_name );

     status = NFMget_catalog_no (user_id, cat_name, cat_no);
     if (status != NFM_S_SUCCESS)
      {
     _PDMdebug (fname, "Get Catalog No : status = <0x%.8x>\n", status);
      sprintf(e_cat,"e_%s",cat_name);
     status = NFMdelete_table (user_id, "CATALOG", e_cat);
     if (status != NFM_S_SUCCESS)
      {
      sprintf(del_str,"DELETE FROM e_%s",cat_name);
       status = SQLstmt(del_str);
     status = NFMdelete_table (user_id, "CATALOG", e_cat);
     if (status != NFM_S_SUCCESS)
        {
        _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
        return (status);
         }
      }
     status = NFMdelete_template ("PDMVIEW",cat_name,"PDM");
     if (status != NFM_S_SUCCESS)
      {
     _PDMdebug (fname, "Delete Template : status = <0x%.8x>\n", status);
        return (status);
      }
         if(status != NFM_S_SUCCESS)
        return (NFM_E_BAD_CATALOG) ;
         else return(PDM_S_SUCCESS);
      }
     sprintf(del_str,
       "SELECT p_citno FROM PDMCIT where n_catalogname = '%s'", cat_name);
       status = SQLquery(del_str, &pdmcit, 512);
       if(status == SQL_S_SUCCESS) {
         _PDMdebug (fname, "Catalog has parts in assy: status = <0x%.8x>\n", 
                                                        status);
         return(PDM_E_PART_OCCURS_IN_ASSEMBLY);
         }

    if (status != SQL_I_NO_ROWS_FOUND) {
      _PDMdebug (fname, "Failed getting where used : status = <0x%.8x>\n", 
                                                             status);
      return (status) ;
      }

    MEMclose(&pdmcit);
    _PDMdebug (fname, "None of the parts in this catalog exist in an assy\n");

     /*
     status = NFMcheck_catalog_empty (user_id, cat_name);
     if (status != NFM_S_SUCCESS)
      {
      sprintf(del_str,"DELETE FROM e_%s",cat_name);
       status = SQLstmt(del_str);
         if(status != SQL_S_SUCCESS)
         {
       _PDMdebug (fname, "Empty Catalog : status = <0x%.8x>\n", status);
        return (NFM_E_NOT_EMPTY_CAT);
         }
      }
     */

     status = _NFMcheck_cat_no_mapping (user_id, *cat_no) ;
     if (status != NFM_S_SUCCESS) {
	 _PDMdebug (fname, "Cat Mappings exist\n", status) ;
	 return (status) ;
       }

      sprintf(e_cat,"e_%s",cat_name);
     status = NFMdelete_table (user_id, "CATALOG", e_cat);
     if (status != NFM_S_SUCCESS)
      {
      sprintf(del_str,"DELETE FROM e_%s",cat_name);
       status = SQLstmt(del_str);
     status = NFMdelete_table (user_id, "CATALOG", e_cat);
     if (status != NFM_S_SUCCESS)
        {
        _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
        return (status);
         }
        _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
        return (status);
      }
     status = NFMdelete_template ("PDMVIEW",cat_name,"PDM");
     if (status != NFM_S_SUCCESS)
      {
     _PDMdebug (fname, "Delete Template : status = <0x%.8x>\n", status);
        return (status);
      }

     status = NFMdelete_loc_entry (user_id, *cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Delete Loc Entry : status = <0x%.8x>\n", status);
        return (status);
      }

      sprintf(del_str,
         "SELECT p_dyntable FROM pdmcatalogs where n_catalogno = %d", *cat_no);
      status = SQLquery(del_str,&dyn_bufr,512);
      if(status == SQL_S_SUCCESS)
          {
         status = MEMbuild_array (dyn_bufr);
         if(status != MEM_S_SUCCESS)
             {
           _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
           return (status);
             } 
         dyn_data = (char **) dyn_bufr->data_ptr;
         sprintf(del_str,
            "SELECT n_catalogno FROM pdmcatalogs WHERE p_dyntable = '%s'", 
                                                           dyn_data[0]);
         status = SQLquery(del_str, &cat_bufr,512);
         if(status == SQL_S_SUCCESS)
             {
           status = MEMbuild_array (cat_bufr);
           if(status != MEM_S_SUCCESS)
            {
            _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
             return (status);
             } 
           if(cat_bufr->rows == 1)
               {
              PDMconvert_to_lower(dyn_data[0], lower_dyn_table);
              status = NFMdelete_table (user_id, lower_dyn_table, dyn_data[0]);
              if (status != NFM_S_SUCCESS)
                 {
                _PDMdebug (fname, "Delete Table : status = <0x%.8x>\n", status);
                 return (status);
                }
               }
              }
          MEMclose(&cat_bufr);
          MEMclose(&dyn_bufr);
          }
                       
       sprintf(del_str,
              "DELETE FROM pdmfnattrmap where n_catalogname = '%s'",cat_name);
       status = SQLstmt(del_str);
       if(status != SQL_S_SUCCESS)
          {
           _PDMdebug (fname, 
             "No function-attr map for this catalog : status = <0x%.8x>\n", 
                                                                       status);
            }

       sprintf(del_str,
             "DELETE FROM pdmparamloc where n_catalogname = '%s'",cat_name);
       status = SQLstmt(del_str);
       if(status != SQL_S_SUCCESS)
         {
          _PDMdebug (fname, 
            "No pdmparamloc entry for this catalog : status = <0x%.8x>\n", 
                                                                      status);
         }
       sprintf(del_str,
                "DELETE FROM pdmparameters where n_catalogname = '%s'",
                                                                      cat_name);
       status = SQLstmt(del_str);
       if(status != SQL_S_SUCCESS)
         {
         _PDMdebug (fname, 
           "No pdmparameters for this catalog : status = <0x%.8x>\n", status);
         }
       sprintf(del_str,
            "DELETE FROM pdmcatalogs where n_catalogno = %d",*cat_no);
       status = SQLstmt(del_str);
       if(status != SQL_S_SUCCESS)
         {
          _PDMdebug (fname, "Empty Catalog : status = <0x%.8x>\n", status);
           return (NFM_E_NOT_EMPTY_CAT);
         }
 
      _PDMdebug (fname, "Cat No = <%d> : SUCCESSFUL\n", *cat_no);
     return (PDM_S_SUCCESS);
}


/* 

Kumar Narayanan  - 10/25/93

*/

long PDMprepare_change_view_catalog 
   (
   long      user_id,
   char      *cat_name,
   MEMptr    *loc_attr, 
   MEMptr    *loc_data,
   MEMptr    *loc_list,
   MEMptr    *attr_list, 
   MEMptr    *data_list,
   MEMptr    *value_list,
   char      **dyn_table,
   MEMptr    *dynamic_attr,
   MEMptr    *dynamic_data,
   MEMptr    *dynamic_list
   )

{
char *fname = "PDMprepare_change_view_catalog";
char  sql_str[240],loc_name[20], **data=NULL;
long status;
int   cat_no;
MEMptr bufr=NULL;

     _PDMdebug(fname,"ENTER\n");
     *loc_attr = NULL;
     *loc_data = NULL;
     *loc_list = NULL;
     *attr_list = NULL;
     *data_list = NULL;
     *value_list = NULL;
     *dynamic_attr = NULL;
     *dynamic_data = NULL;
     *dynamic_list = NULL;

     status = NFMget_catalog_no (user_id, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Get Catalog No : status = <0x%.8x>\n", status);
        return (NFM_E_BAD_CATALOG) ;
      }

      status = NFMquery_changeto_loc_attributes(user_id, loc_name,cat_name,
                              loc_attr, loc_data, loc_list); 
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "NFMquery_changeto_loc_attr : status = <0x%.8x>\n", status);
        return (status) ;
      }
      status = NFMquery_change_template_information ("PDMVIEW", 
          cat_name, "PDM", attr_list, data_list, value_list); 
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "NFMquery_change_table_info : status = <0x%.8x>\n", status);
        return (status) ;
      }

         sprintf(sql_str,"SELECT p_dyntable FROM pdmcatalogs WHERE n_catalogno = %d", cat_no);
             status = SQLquery(sql_str,&bufr,512);
              if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
               {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               return (status) ;
                }
          if(status == SQL_I_NO_ROWS_FOUND)
             return (PDM_S_SUCCESS);

           status = MEMbuild_array(bufr);
           if(status != MEM_S_SUCCESS)
           {
              _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
               return (status) ;
           }
           data = (char **) bufr->data_ptr;

         if(!strcmp(data[0],"") || data[0] == NULL)
           {
            MEMclose(&bufr);
            return(PDM_S_SUCCESS);
            }
           *dyn_table = (char *) malloc (21);
          strcpy(*dyn_table,data[0]);
           
          if(strcmp(*dyn_table,""))
          {
     status = NFMquery_change_table_information (user_id, data[0],data[0],dynamic_attr, dynamic_data, dynamic_list);
            if (status  != NFM_S_SUCCESS)
            {
                _PDMdebug(fname, "NFMquery_change_table_information = %d\n",
                                        status);
                return (PDM_E_GET_ATTRIBUTES);
             }
           }
          MEMclose(&bufr);
     _PDMdebug(fname,"EXIT\n");
     return(PDM_S_SUCCESS);
}
                                
