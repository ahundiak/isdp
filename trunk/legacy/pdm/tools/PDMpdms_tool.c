#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "PDMdbs_err.h"
#include                "MEMstruct.h"
#include                "PDUerror.h"
#include "NFMapi.h"
#include "NFMstruct.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static char     s[1024];
static long     status;
extern PDMexec_ptr PDMexec;


int
PDMvalidate_attribute(attribute_name, table_no)
        char           *attribute_name;
        int             table_no;
{
        MEMptr          bufr1 = NULL;
        char            sql_str[1024];
/* APOGEE START char          **data; APOGEE END */

        PDMdebug("ENTER:PDMvalidate_attribute\n");
        sprintf(sql_str, "%s %s '%s' %s %d",
                "SELECT n_attrno FROM nfmattributes ",
                "WHERE n_name = ", attribute_name,
                "AND n_tableno = ", table_no);
        status = SQLquery(sql_str, &bufr1, 512);
        if (status == SQL_S_SUCCESS) {
                MEMclose(&bufr1);
                PDMdebug("attribute exists\n");
                return (PDM_E_ATTR_EXISTS);
        }
        if (status == SQL_I_NO_ROWS_FOUND) {
                sprintf(s, "SQLquery failed status %d\n", status);
                PDMdebug(s);
                MEMclose(&bufr1);
                return (PDM_E_SQL_QUERY);
        }
        MEMclose(&bufr1);
        PDMdebug("EXIT:PDMvalidate_attribute\n");
        return (PDM_S_SUCCESS);
}

long PDMcreate_data_buffer
(
MEMptr  attr_buffer,
MEMptr  *data_buffer
)
{
int             i ;
int     nx1, nx2;
int             rows,cols;
int     name_offset, dtype_offset;
char    **data,**column;
char    dummy_row[1024];
MEMptr  tmp_bufr = NULL;
long    status;
char     *fname = "PDMcreate_data_buffer";

_PDMdebug(fname,"ENTER:\n");

/* create data_buffer  */

    status = MEMbuild_array(attr_buffer);
    if(status != MEM_S_SUCCESS)
    {
     _PDMdebug(fname,"\tMEMbuild_array failed status = %d",status);
      return(PDM_E_BUILD_ARRAY);
    }
    rows = attr_buffer->rows;
    cols = attr_buffer->columns;
    data = (char **)attr_buffer->data_ptr;
    column = (char **)attr_buffer->column_ptr;
    name_offset = -1;
    dtype_offset = -1;

   /* find offsets of n_name and n_datatype in the attr_buffer */

     for(i=0;i<cols;i++)
     {
       if(!strcmp(column[i],"n_name")) name_offset = i;
       else if(!strcmp(column[i],"n_datatype")) dtype_offset = i;
       if(name_offset != -1 && dtype_offset != -1)
                           break;
       }
       if(name_offset == -1 || dtype_offset == -1)
        {
       _PDMdebug(fname,"\tInput buffer format is invalid\n");
       return(PDM_E_BUFFER_FORMAT);
        }
   status = MEMopen(&tmp_bufr,2048);
    if(status != MEM_S_SUCCESS)
    {
        _PDMdebug(fname,"\tMEMopen failed status = %d",status);
        return(PDM_E_OPEN_BUFFER);
    }
    for(i=0;i<rows;i++)
    {
       nx1 = i * cols + name_offset;
       nx2 = i * cols + dtype_offset;
       status = MEMwrite_format(tmp_bufr,data[nx1],data[nx2]);
       if(status != MEM_S_SUCCESS)
       {
        _PDMdebug(fname,"\tMEMwrite_format failed status = %d",status);
        MEMclose(&tmp_bufr);
        status = PDM_E_WRITE_FORMAT;
        return (status);
       }
     }
    strcpy(dummy_row,"");
    for(i=0;i<rows;i++) strcat(dummy_row,"\1");
    status = MEMwrite(tmp_bufr,dummy_row);
    if(status != MEM_S_SUCCESS)
    {
        _PDMdebug(fname,"\tMEMwrite failed status = %d\n",status);
        MEMclose(&tmp_bufr);
        return(PDM_E_WRITE_ROW);
    }
    status = MEMwrite(tmp_bufr,dummy_row);
    if(status != MEM_S_SUCCESS)
    {
     _PDMdebug(fname,"\tMEMwrite failed status = %d\n",status);
        MEMclose(&tmp_bufr);
        return (PDM_E_WRITE_ROW);
    }
    *data_buffer = tmp_bufr;
    _PDMdebug(fname,"EXIT:\n");
    return (PDM_S_SUCCESS);
}


/* To be more specific about error message in create catalog - kumar */

int PDMparse_for_illegal_char(char *string)
{
int index;

 for(index=0; (string[index] != NULL & string[index] != '\0'); index++)
      {
      switch(string[index])
       {
        case '%':
        case ' ':
        case '*':
        case '~':
        case '!':
        case '\\':
        case '//':
        case '=':
        case '&':
        case '`':
               return(1);
        default:
              break;
        }
       }
      return(0);
}

/* Dynamic table for a given catalog - Kumar Narayanan */

long PDMdyntable_for_catalog(char ** dyn_table)
{

MEMptr dyn_bufr = NULL;
char   **dyn_data = NULL;
char   del_str[512];
char   *fname = "PDMdyntable_for_catalog";

       _PDMdebug(fname,"Enter:\n");
/*
sprintf(del_str,"SELECT t2.p_dyntable FROM nfmcatalogs t1,pdmcatalogs t2 where t1.n_catalogno = t2.n_catalogno AND t1.n_catalogname = '%s'", PDMexec->catalog);
*/
        sprintf(del_str,"SELECT t2.p_dyntable FROM nfmcatalogs t1, \
          pdmcatalogs t2 where t1.n_catalogno = t2.n_catalogno  \
          AND t1.n_catalogname = '%s' AND NOT (t2.p_dyntable is NULL) ", 
              PDMexec->catalog);
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
              *dyn_table = (char *) malloc(21);
              strcpy(*dyn_table, dyn_data[0]);
           _PDMdebug (fname, "Dynamic table for %s = %s\n", PDMexec->catalog,
                                           *dyn_table);
           }
            else *dyn_table = NULL;
       _PDMdebug(fname,"Exit:\n");
   return(PDM_S_SUCCESS);
}

int PDMquery_catalogno_type(char *catalog, int *catno, char *type)
{
        char            *fname = "PDMquery_catalogno_type";
        long            status;
        char            sql_str[512];
        MEMptr          bufr = NULL;
        char             **data;

        _PDMdebug(fname, "ENTER:\n");
        sprintf(sql_str,"SELECT n_catalogno, n_type FROM nfmcatalogs WHERE n_catalogname = '%s' ",catalog);
        status = SQLquery(sql_str,&bufr,512);
        if (status != SQL_S_SUCCESS)
         {
         if(status == SQL_I_NO_ROWS_FOUND)
           {
            MEMclose(&bufr);
       sprintf(sql_str, "SELECT n_itemname FROM %s WHERE n_itemname = '100' ",
            catalog);
        status = SQLquery(sql_str,&bufr,512);
        if(status == SQL_I_NO_ROWS_FOUND)
         {
            MEMclose(&bufr);
            PDMconvert_to_lower(catalog,catalog);
        sprintf(sql_str,"SELECT n_catalogno, n_type FROM nfmcatalogs WHERE n_catalogname = '%s' ",catalog);
        status = SQLquery(sql_str,&bufr,512);
          if (status == SQL_S_SUCCESS)
            {
             status  = MEMbuild_array(bufr);
                 if (status != MEM_S_SUCCESS)
                 {
                 MEMclose(&bufr);
                _PDMdebug(fname, "MEMbuild_array failed %d\n", status);
                return (status);
                 }
          data = (char **) bufr->data_ptr;
          strcpy(type,data[1]);
           *catno = atoi(data[0]);
          _PDMdebug (fname, "catno[%d], type[%s]\n", *catno, type);

            MEMclose(&bufr);
              _PDMdebug(fname,"EXIT:CATALOG FOUND\n");
                return(PDM_S_SUCCESS);
             }
             else
              {
      MEMclose(&bufr);
                _PDMdebug(fname, "PDMquery_catalog_type failed %d\n", status);
                 return (PDM_E_CATALOG_NOT_FOUND);
              }
            }
            else
               {
                MEMclose(&bufr);
                _PDMdebug(fname, "PDMquery_catalog_type failed %d\n", status);
                 return (PDM_E_CATALOG_NOT_FOUND);
               }
            }
status = _PDMget_db_error (status);
return (status);
           }
        status  = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                         MEMclose(&bufr);
                _PDMdebug(fname, "MEMbuild_array failed %d\n", status);
                return (status);
        }
          data = (char **) bufr->data_ptr;
          strcpy(type, data[1]);
           *catno = atoi(data[0]);
          MEMclose(&bufr);
        _PDMdebug(fname, "EXIT:\n");
        return(PDM_S_SUCCESS);
}


/* Kumar - 2/24/92 Freeing the query_info struct */

 PDMfree_query_info_struct (query_info)
       struct  NFMquery_info query_info;
  {
    char *fname = "PDMfree_query_info_struct" ;

      if((query_info.where_clause) && (strlen(query_info.where_clause)))
      {
        PDMdebug("freeing query_info.where_clause\n");
        free (query_info.where_clause) ;
      }
      if((query_info.from_clause) && (strlen(query_info.from_clause)))
      {
        PDMdebug("freeing query_info.from_clause\n");
        free (query_info.from_clause) ;
      }
      if((query_info.order_by_clause) && (strlen(query_info.order_by_clause)))
      {
        PDMdebug("freeing query_info.order_by_clause\n");
        free (query_info.order_by_clause) ;
      }
      if((query_info.select_clause) && (strlen(query_info.select_clause)))
      {
        PDMdebug("freeing query_info.select_clause\n");
        free (query_info.select_clause) ;
      }

    _PDMdebug (fname, "%s\n","SUCCESSFUL") ;
  }


/* Kumar - 2/24/92 Freeing the query_info struct */

     PDMinit_query_info_struct (query_info)
           struct  NFMquery_info *query_info;
      {
        char *fname = "PDMinit_query_info_struct" ;

           query_info->where_clause  = NULL;
           query_info->from_clause = NULL ;
           query_info->order_by_clause = NULL ;
           query_info->select_clause = NULL ;

      _PDMdebug (fname, "%s\n","SUCCESSFUL") ;
    }
