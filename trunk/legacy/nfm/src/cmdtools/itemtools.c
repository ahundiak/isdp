#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMitemfiles.h"
#include "MEMstruct.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "NFMfto_buf.h"

/* #include "NFMmfb.h" */

long NFMset_item_status (cat_name, item_name, item_rev,
                         item_no, file_status, lock_flag, plus_str)

/*** 
  This function will set n_status of an item based on item_no or item_name and
  item_rev.

  Notes: item_name and item_rev need to be set to NULL if not used as input.
         item_no needs to be set to -1 if not used.

         possible values for lock_flag:
           NFM_NO_LOCK -- ex: used for rollback if command fails
           NFM_LOCK_COMMIT -- ex: used for putting right status back after the
                                  command is successful
           NFM_COMMIT_ONLY -- ex: use this option if the values need to be 
                                  checked before the status can be set.
***/

char    *cat_name;
char    *item_name;  /* I: if item_name and item_rev contain values, item_no */
char    *item_rev;   /*    does not need to have input value */
long    item_no;     /* I: if item_no contains a value, item_name and item_rev*/
                     /*    do not need to have input values */
char    *file_status;
int     lock_flag; 
char    *plus_str;

{
  char    sql_str[1024];
  char    *fname="NFMset_item_status";
  long    status;

  _NFMdebug ((fname, "ENTER: Cat[%s] Item[%s] ItemRev[%s] ItemNo[%d]\n\
                      Status[%s] Lock[%d]\n",
             cat_name, item_name, item_rev, item_no, file_status, lock_flag));

  if (item_no == MINUS_ONE)
  {
    _NFMdebug ((fname, "build a query based on item name and item revision\n"));  
    if ( !strcmp (item_name, "\0") || !strcmp (item_rev, "\0") )
    {
      _NFMdebug ( (fname, "Invalid input in item name [%s] or item rev [%s]\n",
                  item_name, item_rev) );
      ERRload_struct (NFM, NFM_E_INCOMPLETE_INFORMATION, "%s%s",
                      "set file status", "either item name or item revision");
      return (NFM_E_INCOMPLETE_INFORMATION);
    }
    if (!strlen (file_status))
    {
      sprintf (sql_str, "update %s set n_status = NULL %s %s '%s' %s '%s'",
             cat_name, plus_str,
             "where n_itemname = ", item_name,
             "and n_itemrev = ", item_rev);  
    }
    else
    {
      sprintf (sql_str, "update %s set n_status = '%s' %s %s '%s' %s '%s'",
             cat_name, file_status, plus_str,
             "where n_itemname = ", item_name,
             "and n_itemrev = ", item_rev);  
    }
  }
  else
  {
    _NFMdebug ( (fname, "build query based on item number\n"));

    if (! strlen (file_status))
    {
      sprintf (sql_str, "update %s SET n_status = NULL %s WHERE n_itemno = %d ",
             cat_name, plus_str, item_no);
    }
    else
    {
      sprintf (sql_str, "update %s SET n_status = '%s' %s WHERE n_itemno = %d ",
             cat_name, file_status, plus_str, item_no);
    }
  }

  if (lock_flag == NFM_LOCK_COMMIT || lock_flag == NFM_LOCK_NO_COMMIT)
  {
    status = NFMlock_table (cat_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
      return (status);
    }
  }

  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt (%s) failed 0x%.8x\n", sql_str) );
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (status);
  }

  if (lock_flag == NFM_LOCK_COMMIT || lock_flag == NFM_COMMIT_ONLY)
  {
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status) );
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
  }
  _NFMdebug ( (fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}  

long NFMretrieve_values (sql_str, ret_type, ret_str, ret_value, ret_list)

/***

  This function will execute query using sql_str and return the retrieved
  information based on ret_type. If ret_type = NFM_RETURN_STR, return as string.
  If ret_type = NFM_RETURN_VALUE, return as long. 
  If ret_type = NFM_RETURN_MEMPTR, return as MEMptr.

  Note: if ret_type = NFM_RETURN_MEMPTR, calling function needs to free
        the "ret_list".

  CHANGE HISTORY:

    10/30/91 mfb creation.

***/

char *sql_str;
long ret_type;
char *ret_str;
long *ret_value;
MEMptr *ret_list;

{
  char *fname="NFMretrieve_values";
  char **data;
  long status;


  _NFMdebug ((fname, "ENTER: sql_str = %s ret_type %d\n", sql_str, ret_type));

  status = SQLquery (sql_str, ret_list, MEM_SIZE);
  if (status == SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ((fname, "no value found/retrieved\n"));
    MEMclose (ret_list);
    if (ret_type == NFM_RETURN_VALUE)
    {
      *ret_value = -1;
      return (status); /* add NFM_NO_VALUE_FOUND after 2.3.1 deliver */
    }
    else if (ret_type == NFM_RETURN_STR)
    {
      strcpy (ret_str, "\0");
      return (status);
    }
    else
    {
      return (status);
    }
  }
  else if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ((fname, "SQLquery(%s) failed 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    return (NFM_E_SQL_QUERY);
  }
  status = MEMbuild_array (*ret_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array (catalog no)0x%.8x\n",status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }
  if (ret_type == NFM_RETURN_STR)
  {
    data = (char **) (*ret_list)->data_ptr;
    strcpy (ret_str, data[0]);
    _NFMdebug ((fname, "data[0] [%s], ret_str [%s]\n", data[0], ret_str));
    status = MEMclose (ret_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (NFM_E_MEM);
    }
  }
  else if (ret_type == NFM_RETURN_VALUE)
  {
    data = (char **) (*ret_list)->data_ptr;
    *ret_value = atol (data[0]);
    _NFMdebug ((fname, "data[0] [%s], ret_value [%d]\n", data[0], *ret_value));
    status = MEMclose (ret_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose (catalog number) 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (NFM_E_MEM);
    }
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long _NFMbuild_working_buffer_format (format, count, list)

struct NFMbuf_format *format;
long count;
MEMptr list;

/***
  This function will build a buffer format based on input "format".

  CHANGE HISTORY:

    10/31/91 mfb creation
***/

{
  char *fname="_NFMbuild_working_buffer_format";
  int x;
  long status;

  _NFMdebug ((fname, "ENTER: build %d format to %ld\n",
                      count, list));

  for (x = 0; x < count; x ++)
  {
    status = MEMwrite_format (list, (format+x)->attr_name, 
                                    (format+x)->data_type);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (status);
    }
  }

  _NFMdebug ((fname, "EXIT: succefful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMcheck_catalog_attributes (item_name, item_rev, list, command)

/***

  This function checkes the values of n_status, n_archivestate, n_itemlock,
  and n_pendingflag for the specified command.

  CHANGE HISTORY:

    05/11/92 mfb creation.

***/

char *item_name, *item_rev;
MEMptr list;
long command;

{
  char *fname="NFMcheck_catalog_attributes";
  char **data;

  _NFMdebug ((fname, "ENTER: command %d\n", command));

  data = (char **)list->data_ptr;
  switch (command)
  {
    case NFM_CHECK_OUT:
      if (strlen(data[1]) &&  (strcmp(data[1], "I")))
      {
        _NFMload_error_message (item_name, item_rev, NFM_CHECK_OUT,
           NFM_ITEM,  data[1], "");
        _NFMdebug ( (fname, "Cannot checkout item because file status = %s\n",
                     data[1]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      if (strlen (data[2]) && ! strcmp (data[2], "A") )
      {
        _NFMload_error_message (item_name, item_rev, NFM_CHECK_OUT, 
            NFM_ITEM, data[2], "");
        _NFMdebug ( (fname, "Cannot checkout item because archive state = %s\n",
                data[2]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      if (strcmp (data[3], "N"))
      {
        ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        return (NFM_E_ITEM_LOCKED);
      }

      if (strlen (data[4]))
      {
        ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name);
        _NFMdebug ((fname, "Cannot checkout item because pending flag = %s\n", 
                    data[4]));
        return (NFM_E_ITEM_FLAGGED);
      }
      break;
    case NFM_DELETE_FILE_FROM_ITEM:
      if (strlen (data[2]) && !strcmp (data[2], "A"))
      {
        _NFMload_error_message (item_name, item_rev, NFM_DEFINE_FILE, 
                            NFM_DELETE_FILE_FROM_ITEM, data[2], "");
        _NFMdebug ( (fname, 
                "Cannot define file info because archive state = %s\n",
                data[2]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      if (!strcmp(data[1],"") || !strcmp(data[1],"I") )
      {
        _NFMdebug ( (fname, "It is ok to delete file(s) from this item\n"));
      }
      else
      {
        _NFMload_error_message (item_name, item_rev, NFM_DEFINE_FILE,
          NFM_DELETE_FILE_FROM_ITEM, data[1], "");
        _NFMdebug ( (fname, "Item status [%s], not allowed to delete files\n",
                   data[1]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      if (strcmp (data[3], "N"))
      {
        ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        _NFMdebug ((fname, "Cannot define file info because lock = %s\n", 
                data[3]));
        return (NFM_E_ITEM_LOCKED);
      }

      if (strlen (data[4]))
      { 
        if (!strcmp (data[4], "ID") )
        {
          _NFMdebug ((fname, "flagged for delete files,OK to continue\n"));
        }
        else
        {
          ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name);
          _NFMdebug ((fname, 
            "Cannot define file info because pending flag = %s\n",
            data[4]));
          return (NFM_E_ITEM_FLAGGED);
        }
      }
      break;
    case NFM_CHANGE_FILE_INFORMATION:
      if (strcmp (data[3], "N"))
      {
        ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        _NFMdebug ((fname, "Cannot define file info because lock = %s\n", 
                data[3]));
        return (NFM_E_ITEM_LOCKED);
      }
      if (strlen (data[4]))
      {
        ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name);
        _NFMdebug ((fname, 
          "Cannot define file info because pending flag = %s\n",
                  data[4]));
        return (NFM_E_ITEM_FLAGGED);
      }
      if ( !strcmp(data[1],"TI") || !strcmp(data[1],"TO") ||
           !strcmp(data[1],"TF") || !strcmp(data[1],"TM") )
      {
        _NFMload_error_message (item_name, item_rev, NFM_DEFINE_FILE, 
          NFM_CHANGE_FILE_INFORMATION, data[1], "");
        _NFMdebug ( (fname, "Item status [%s], not allowed to change file\n",
                   data[1]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      break;
    case NFM_ADD_FILE_TO_ITEM:
      if (strcmp (data[3], "N"))
      {
        ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        _NFMdebug ((fname, "Cannot define file info because lock = %s\n", 
                data[3]));
        return (NFM_E_ITEM_LOCKED);
      }
      if (strlen (data[4]))
      {
        ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name);
        _NFMdebug ((fname, 
          "Cannot define file info because pending flag = %s\n",
                  data[4]));
        return (NFM_E_ITEM_FLAGGED);
      }
      if (!strcmp(data[1],"") || !strcmp(data[1],"O") ||
          !strcmp(data[1],"ON") ||
          !strcmp(data[1],"S") || !strcmp(data[1],"SN") ||
          !strcmp(data[1],"M") || !strcmp(data[1],"MN") )
      {
        _NFMdebug ( (fname, "It is ok to add file(s) to this item\n") );
      }
      else 
      {
        _NFMload_error_message (item_name, item_rev, NFM_DEFINE_FILE,
                              NFM_ADD_FILE_TO_ITEM,   data[1], "");
        _NFMdebug ( (fname, "Item status [%s], not allowed to add files\n",
                     data[1]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      break;
    case NFM_PLOT_ITEM:
    case NFM_COPYFILES:
      if (!strlen(data[1]) || !strcmp (data[1], "ON") )
      {
        _NFMload_error_message (item_name, item_rev, command, NFM_ITEM,
                            data[1], "");
        _NFMdebug ( (fname, "Cannot plot item because file status = %s\n",
                 data[1]) );
        return (NFM_E_BAD_FILE_STATUS);
      }
      if (strlen (data[2]) && ! strcmp (data[2], "A") )
      {
        _NFMload_error_message (item_name, item_rev, command, NFM_ITEM,
                            data[2], "");
        _NFMdebug ( (fname, "Cannot plot item because archive state = %s\n",
                    data[2]) );
        return (NFM_E_BAD_ARCHIVE_FLAG);
      }

      if (!strcmp (data[3], "Y"))
      {
        ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
        _NFMdebug ((fname, "Cannot plot item because lock = %s\n", 
                    data[3]));
        return (NFM_E_ITEM_LOCKED);
      }
      if (strlen (data[4]) && strcmp (data[4], "IB") && 
          strcmp (data[4], "SB") && strcmp (data[4], "PB") )
      {
        _NFMload_error_message (item_name, item_rev, command, NFM_ITEM,
                       data[4], "");
        _NFMdebug ((fname, "Cannot plot item because pending flag = %s\n",
                    data[4]));
        return (NFM_E_ITEM_FLAGGED);
      }
      break;
    default:
      _NFMdebug ((fname, "Invalid requested command\n"));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                      "Invalid command requested"); 
      return (NFM_E_MESSAGE);
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMcommon_queries (cat_name, w_clause, ret_string, ret_value, ret_list,
                        query_type, return_type, lock_flag)

/***

  This function contains most commonly used queries in file transfer code.

  Note:
    query_type == NFM_ITEM_QUERY,
         pre_str1 = "select n_itemno, n_status, n_archivestate, n_itemlock, 
                     n_pendingflag, n_versionlimit from",

    query_type == NFM_ITEM_FILE_QUERY
         pre_str2 = "select n_fileno, n_filenum, n_filetype, n_fileversion, 
                     n_fileco, n_cifilesize, n_cifilename,
                     n_cisano, n_cofilename, n_cosano, n_cidate, n_codate,
                     n_ciuser, n_couser, n_fileclass, n_archiveno from",

    query_type == NFM_CAT_QUERY
         pre_str3 = "select n_catalogno, n_catalogname from nfmcatalogs where ",

    query_type == NFM_LFM_QUERY
         pre_str4 = "select n_co, n_copy, n_ref, n_fileversion, n_nfs,
                     n_cisano, n_mountpoint fromnfmsafiles 
                     where ",

  CHANGE HISTORY

    05/11/92 mfb creation. (CI/CO/CP need to incorporate this function later)
                 
***/

char *cat_name, *w_clause;
char *ret_string;
long *ret_value;
MEMptr *ret_list;
long query_type, return_type, lock_flag;

{
  char *fname="NFMcommon_query";
  char sql_str[1024];
  long status;
  long NFMretrieve_values ();
  char *pre_str1="select n_itemno, n_status, n_archivestate, n_itemlock, n_pendingflag, n_versionlimit from";
  char *pre_str2="select n_fileno, n_filenum, n_filetype, n_fileversion, n_fileco, n_cifilesize, n_cifilename, n_cisano, n_cofilename, n_cosano, n_cidate, n_codate, n_ciuser, n_couser, n_fileclass, n_archiveno from";
  char *pre_str3="select n_catalogno, n_catalogname from nfmcatalogs where ";
  char *pre_str4="select n_co, n_copy, n_ref, n_fileversion, n_nfs, n_cisano, n_mountpoint from nfmsafiles where ";

  _NFMdebug ((fname, "ENTER: query_type[%d], where_clause [%s]\n\
             return_type [%d] lock_flag [%d]\n",
             query_type, w_clause, return_type, lock_flag));

  switch (query_type)
  {
    case NFM_ITEM_QUERY:
      sprintf (sql_str, "%s %s %s", pre_str1, cat_name, w_clause);
      break;
    case NFM_ITEM_FILE_QUERY:
      sprintf (sql_str, "%s f_%s %s", pre_str2, cat_name, w_clause);
      break;
    case NFM_CAT_QUERY:
      sprintf (sql_str, "%s %s", pre_str3, w_clause);
      break;
    case NFM_LFM_QUERY:
      sprintf (sql_str, "%s %s", pre_str4, w_clause);
      break;
    default:
      _NFMdebug ((fname, "invalid query requested\n"));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                      "Invalid query requested");
      return (NFM_E_MESSAGE);
  }
      
  if (lock_flag == NFM_LOCK_NO_COMMIT ||
      lock_flag == NFM_LOCK_COMMIT      )
  {
    status = NFMlock_table (cat_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", cat_name, status));
      return (status);
    }
  }
  status = NFMretrieve_values (sql_str, return_type, ret_string,
            ret_value, ret_list);
  if (status == SQL_I_NO_ROWS_FOUND)
  {
    _NFMdebug ((fname, "NFMretrieve_values: 0x%.8x (no row found)\n", status));
    return (status);
  }
  else if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMretrieve_values: 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve information");
    return (status);
  }

  if (lock_flag == NFM_LOCK_COMMIT)
  {
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&ret_list);
      _NFMdebug ((fname, "SQLstmt failed 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
  }
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long _NFMrollback_and_undo_buffer (command, operand, file_list, lfm_list,
                               files_info,  catalog_name, catalog_no, 
                               item_no, wsano, 
                               type)

long command, operand;
MEMptr file_list;             /* buffer returned from NFMfileserver */
struct NFMlfm_file *lfm_list; /* info retrieved from nfmsafiles */
MEMptr files_info;            /* info from f_<catalog> */
char *catalog_name;
long catalog_no, item_no, wsano;
long type;                    /* possible values:
                                 NFM_RLBK_LFM1: 
                                 NFM_RLBK_LFM2_FCAT:
                                 NFM_RLBK_FCAT:
                                 NFM_RLBK_LFM1_FCAT:
                              */


{
  char *fname="_NFMrollback_and_undo_buffer";
  char **data, **data1;
  char **column, **format;
  char sql_str[1024];
  int x, index;
  int i_fileversion, i_ciuser, i_cidate, i_cosano, i_couser, i_codate, i_fileco;
  int q_fileversion=3;

  _NFMdebug ((fname, "ENTER: command = %d, operand = %d type = %d\n",
              command, operand, type));

  if (file_list != (MEMptr) NULL)
    data = (char **) file_list->data_ptr;
  if (files_info != (MEMptr) NULL)
    data1 = (char **) files_info->data_ptr;

  switch (command)
  {
    case NFM_CHECK_OUT:
      if (operand == NFM_ITEM)
      {
        
        if ((type == NFM_RLBK_LFM1 || type == NFM_RLBK_LFM1_FCAT) &&
            (lfm_list != (struct NFMlfm_file *) NULL))
        {
          /*
          the copy item files (using nfs) was done before checkout requested,
          nfmsafiles has n_nfs set to 'Y', but some file(s) was/were pulled down
          physically before something went wrong, need to update nfmsafiles.
          */

          for ( x = 1; x < file_list->rows; x ++)
          {
            index = file_list->columns * x;
            if ((lfm_list+x-1)->action == NFM_UPDATE_CO &&
                atol (data[index+FTO_STATUS1]) == NFM_TRANSFERED &&
                !strcmp (data[index+FTO_NFS], "Y")                    )
            {
              sprintf (sql_str, "%s %s %d %s %d %s %d %s '%s'",
                     "update nfmsafiles set n_nfs = NULL, n_cisano = NULL,",
                     "n_mountpoint = NULL where n_sano =", wsano,
                     "and n_catalogno = ", catalog_no, "and n_itemno = ",
                     item_no, "and n_filename = ", data[index+FTO_COFILENAME]);
              SQLstmt (sql_str);
            }
          }
        }

        if ((type == NFM_RLBK_FCAT || type == NFM_RLBK_LFM1_FCAT ||
            type == NFM_RLBK_LFM2_FCAT ) &&
            (files_info != (MEMptr) NULL) )
        {
          /* the command went wrong after f_<catalog> was updated, need to
             rollback */
          sprintf (sql_str, 
            "%s f_%s %s %s %d %s %s",
            "update", catalog_name, "set n_cosano = NULL, n_couser = NULL,",
            "n_codate = NULL, n_fileco = 'N' where n_itemnum = ", item_no,
            "and n_fileversion = ", data1[q_fileversion]);
          SQLstmt (sql_str);
        } 

        if ((type == NFM_RLBK_LFM2_FCAT) &&
            (lfm_list != (struct NFMlfm_file *) NULL))
        {
          /* the command went wrong after nfmsafiles is updated partially/
             entirely */

          for ( x = 1; x < file_list->rows; x ++)
          {
            index = file_list->columns * x;
            if ((lfm_list+x-1)->action == NFM_UPDATE_CO)
            {
              sprintf (sql_str, "%s %s %d %s %d %s %d %s '%s'",
                     "update nfmsafiles set n_co = 'N', n_nfs = NULL,",
                     "n_cisano = NULL, n_mountpoint = NULL where n_sano =", 
                     wsano,
                     "and n_catalogno = ", catalog_no, "and n_itemno = ",
                     item_no, "and n_filename = ", data[index+FTO_COFILENAME]);
              SQLstmt (sql_str);
            }
            else
            {
              sprintf (sql_str, "%s %s %d %s %d %s '%s'",
                    "delete from nfmsafiles where n_copy = 'N' and n_ref = 0",
                    "and n_catalogno = ", catalog_no, 
                    "and n_itemno =",
                    item_no, "and n_filename = ", 
                    data[index+FTO_COFILENAME]);
              SQLstmt (sql_str);
            }
          }
        }

        if (lfm_list != (struct NFMlfm_file *) NULL)
        {
          for ( x = 1; x < file_list->rows; x ++)
          {
            /* don't remove file(s), if the file(s) has/have been copied */

            index = file_list->columns * x;
            if ((lfm_list+x-1)->action == NFM_UPDATE_CO &&
                (atol(data[index+FTO_STATUS1]) == NFM_TRANSFERED ||
                 atol(data[index+FTO_STATUS1]) == NFM_NFSED)        )
              MEMwrite_data (file_list, "", x+1, FTO_STATUS1+1);
          }
        }
      }
      break;
    case NFM_CHECK_IN:
      column = (char **) files_info->column_ptr;
      format = (char **) files_info->format_ptr;

      for (x = 0; x < files_info->columns; x ++)
      {
        if (!strcmp (column[x], "n_fileversion"))
          i_fileversion = x;
        else if (!strcmp (column[x], "n_ciuser"))
          i_ciuser = x;
        else if (!strcmp (column[x], "n_cidate"))
          i_cidate = x;
        else if (!strcmp (column[x], "n_cosano"))
          i_cosano = x;
        else if (!strcmp (column[x], "n_couser"))
          i_couser = x;
        else if (!strcmp (column[x], "n_codate"))
          i_codate = x;
        else if (!strcmp (column[x], "n_fileco"))
          i_fileco = x;
      }
      if (type == NFM_RLBK_FCAT_NT)
      {
        _NFMdebug ((fname, 
          "clean up the record(s) in f_<catalog> for NFM_NO_TRANSFER\n"));

        sprintf (sql_str, 
          "%s f_%s %s %s %s '%s' %s '%s' %s '%s' %s '%s' %s '%s' %s %d%s %s",
          "update", catalog_name, "set n_cosano =", data1[i_cosano],
          "n_couser =", data1[i_couser], "n_codate =", 
          data1[i_codate], "n_ciuser =", data1[i_ciuser],
          "n_cidate =", data1[i_cidate], "n_fileco =",
          data1[i_fileco], "where n_itemnum =", item_no, 
          "and n_fileversion =", data1[i_fileversion]);

        SQLstmt (sql_str);
      }
      break;
  }
  _NFMdebug ((fname, "EXIT: successfule 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
