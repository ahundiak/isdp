#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "MSGstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"


extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern char NFM_DM_NODENAME[NFM_NODENAME+1];

long NFMpccancel_check_out_item (catalog_name, catalog_no,item_name, 
                               item_revision, wf_info, operation)

/***
  This function will cancel a checked out item with its associated files.


  CHANGE HISTORY:
    01/03/92 mfb Creation.
***/


char *catalog_name;  /* I: item's catalog */
long catalog_no;
char *item_name;     /* I: item's name */
char *item_revision; /* I: item's revision */
struct NFMwf_info wf_info; /* I: turn on/off validation and set_to_state */
struct NFMoperation operation; /* I: same value as NFMcheckout_item is called */

{
  char *fname="NFMcnacel_check_out_item";
  char sql_str[1024], row_str[3072], temp_str[1024];
  char fcat_name[NFM_CATALOGNAME+3];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1], 
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1], 
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1], 
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1], 
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1], 
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char working_area[NFM_SANAME+1];
  char **data, **data1;
  char file_status1[NFM_STATUS+1];
  char file_status[NFM_STATUS+1],
       file_co[NFM_FILECO+1];
  char dumb_str[1024], error_msg[1024];
  char itemdesc[NFM_ITEMDESC+1];
  long  x, index, nothing, count;
  long i_fileno, i_filenum, i_fileversion, i_filetype, i_fileco, i_cifilesize, 
      i_cifilename, i_cofilename, i_cosano, i_couser;
  int subsystem;
  long i_ref, i_cp;
  long file_version, error_no;
  long item_no;
  long status;
  long sano=0;
  long add_to_lfm = 0;
  long degree;
  long dumb_value;
  MEMptr list=NULL, list1=NULL, file_list=NULL, dumb_list=NULL;
  struct NFMlfm_file *lfm_files;
  struct NFMsto_info *sto_list;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] user name [%s]\n",
                       catalog_name, item_name,
                       item_revision, 
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation.transfer, operation.delete, operation.purge,
                       NFMglobal.NFMusername));

  sprintf (fcat_name, "f_%s", catalog_name);

  /* set autocommit off */
  status = NFMstop_transaction (0); 
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMstop_transaction: 0x%.8x\n", status) );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  /* check the wf_info.workflow and take proper actions, such as validating.
     if validating fails, needs to call set_to_state */

  if (wf_info.workflow)
  {
    status = WFvalidate_user_access (NFMglobal.NFMuserid, wf_info.command,
             wf_info.workflow_name, wf_info.project_name,
             catalog_name, item_name, item_revision);
    if (status != NFM_S_SUCCESS)
    {
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      ERRget_message (error_msg);
      ERRget_number (&error_no, &subsystem);
      NFMset_wf_state (wf_info.app_name, error_no, error_msg);
      _NFMdebug ((fname, "WFvalidate_user_access 0x%.8x\n", status));
      if (DM_MANAGER)
       _DMdo_nothing ();
      return (status);
    }
  }

  /* lock <catalog> and retrieve the item information, check the file status,
     if the item is eligible to be checked out, set file status == TO, commit*/ 

  status = NFMlock_table (catalog_name);
  if (status != NFM_S_SUCCESS)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ( (fname, "NFMlock_table (%s) failed 0x%.8x\n", 
                 catalog_name, status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  sprintf (sql_str, "%s %s %s '%s' %s '%s'",
   "select n_itemno, n_status, n_itemdesc from",
    catalog_name, "where n_itemname = ", item_name, "and n_itemrev = ",
    item_revision);

  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str, 
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 1;
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ( (fname, "MEMbuild_array (list contains item info) 0x%.8x\n",
                 status) );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  data = (char **)list->data_ptr;
  item_no = atol (data[0]);
  strcpy (file_status, data[1]);
  strcpy (itemdesc, data[2]);
  
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    degree = 1;
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ( (fname, "MEMclose (list contains item information)0x%.8x",
                 status) );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (!strlen(file_status) || (strcmp(file_status, "O") &&
                               strcmp(file_status, "ON"))   )
  {
    _NFMload_error_message (item_name, item_revision, NFM_CANCEL_CHECK_OUT, 
                      NFM_ITEM, file_status, "");
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ( (fname, "Cannot checkout item because file status = %s\n",
                 file_status) );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_BAD_FILE_STATUS);
  }  

  status = NFMset_item_status (catalog_name, "", "", item_no, "TI", 
           NFM_NO_LOCK, "");
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ( (fname, "NFMset_item_status [%d] [%s] failed 0x%.8x\n",
                 item_no, "TO") );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    degree = 3;
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);

    _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status) );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  /* At this point the command is considered succesful */

  /* lock f_<catalog> and retrieve the file information */
 
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);

    _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  sprintf (sql_str, "%s %s %s %s %s %d %s %s %s %d %s",
           "select n_fileno, n_filenum, n_fileversion, n_filetype,", 
           "n_fileco, n_cifilesize, n_cifilename,",
           "n_cosano, n_cofilename, n_couser from", fcat_name,
           "where n_itemnum =", item_no,
           "and n_fileversion = (select max(n_fileversion) from ", fcat_name,
           "where n_itemnum = ", item_no, ")");

  i_fileno = 0; i_filenum = 1; i_fileversion = 2; i_filetype = 3;
  i_fileco = 4; i_cifilesize = 5; i_cifilename = 6; i_cosano = 7;
  i_cofilename = 8; i_couser = 9;


  _NFMdebug ( (fname, "exec qry: %s\n", sql_str) );

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ( (fname, "MEMbuild_array (fileversion & pendingflag)0x%.8x\n",
                 status) );
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);

    _NFMdebug ( (fname, "SQLstmt (COMMIT WORK)failed 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  data = (char **) list->data_ptr;
  file_version = atol (data[2]);
  sano = atol (data[i_cosano]);

  if (strcmp (data[i_couser], NFMglobal.NFMusername))
  {
    _NFMdebug ((fname, "Check-out-user[%s] != check-out-user[%s]\n",
                data[i_couser], NFMglobal.NFMusername));
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_CO_CCOI_USER, "", NULL);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_CO_CCOI_USER);
  }

  _NFMdebug ((fname, "retrieved max(fileversion) [%d] \n", file_version));

  /* retrieve the storage area information */

  working_area[0] = '\0';
  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip, xns,
                                decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (DM_MANAGER && strcmp (nodename, NFM_DM_NODENAME) ) 
  {
    MEMclose (&list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "File was checked out to a differne PC\n"));
    if (DM_MANAGER)
      _DMdo_nothing ();
    ERRload_struct (NFM, NFM_E_CI_FROM_DIFF_PC, "", NULL);
    return (NFM_E_CI_FROM_DIFF_PC);
  }
  if (!DM_MANAGER && (strcmp (machid, "PC") == 0) &&
                     (strcmp (opsys, "WINDOS") == 0 ) )
  {
    MEMclose (&list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, 
     "Cannot use NFMinterface to cancel an item that was checked using DMM\n"));
    ERRload_struct (NFM, NFM_E_NFM_CLIENT_CCO_PC, "", NULL);
    return (NFM_E_NFM_CLIENT_CCO_PC);
  }

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list);
    _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", fcat_name,status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  _NFMdebug ((fname, "Update the record(s) in %s\n", fcat_name));

  /* COME BACK AND FIX THIS: how to update n_fileco????? */
  
  lfm_files = (struct NFMlfm_file *) calloc (list->rows,
                 sizeof (struct NFMlfm_file));
  if (lfm_files == (struct NFMlfm_file *) NULL)
  {
    _NFMdebug ((fname, "Failed to malloc\n"));
    MEMclose (&list);
    degree = 1;
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
        "Failed to allocate memory");
    _NFMcleanup (&degree, wf_info, "", "", "");
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (NFM_E_MALLOC);
  }

  /* prepare buffer for the file server */
  /* 1st row for in_from_storage_area */

  status = _DMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
    MEMclose(&list);
    MEMclose(&file_list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  _NFMdebug ((fname, "sano = %d\n", sano));
  sprintf (row_str,
   "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
   sano,
   nodename, username, passwd, pathname, devicetype, plattername,
   partition, nfs,/* mountpoint */compress, machid, opsys, tcpip, xns, decnet,
   netware, "\1\1\1\1\1\1\1\1\1\1\1\1\1");

   _NFMdebug ((fname, "MEMwrite %s\n", row_str));

   status = MEMwrite (file_list, row_str);
   if (status != MEM_S_SUCCESS)
   {
     _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
     MEMclose (&list);
     MEMclose(&file_list);
     degree = 3;
     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
     _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
     if (DM_MANAGER)
      _DMdo_nothing ();
     return (status);
  }
  if (catalog_no < 1)
  {
    sprintf (sql_str, "%s '%s'",
               "select n_catalogno from nfmcatalogs where n_catalogname =",
               catalog_name);
    status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &catalog_no, &dumb_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      MEMclose (&list);
      MEMclose(&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
     _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
     if (DM_MANAGER)
      _DMdo_nothing ();
      return (status);
    }
  }

  for (x = 0; x < list->rows; x++)
  {
    index = list->columns * x;
    sprintf (temp_str, "%d", NFM_DELETE_FILE); 
    /* NEED COME BACK TO MAKE THIS MORE EFFICIENT */
    count = list->columns * x;
    if (strlen (data[count+i_fileco]))
    { 
      strcpy (file_co, "N");
    }
    else if (atol (data[index+i_fileversion]) > 0)
    {
      /* a file has been associated with the item while item is checked-out.
         issue an error to the user. (possible solution: 
           a. delete the file from the item
           b. checkin this item
      */
      /* rollback in _NFMcleanup should take care of executed sql in this
         "for loop", since no "COMMIT WORK" is issued after the table was 
         locked before the "for loop" */
      MEMclose(&list);
      MEMclose(&file_list);
      degree = 3;
      if (DM_MANAGER)
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
         "Associated a file to the document while the document was checked out");
      else
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
         "Associated a file to the item while the item was checked out");


      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
      if (DM_MANAGER)
      _DMdo_nothing ();
      return (NFM_E_MESSAGE);
    }
    else
    {
      strcpy (file_co, "");
      strcpy (temp_str, "");
    }
    if (operation.transfer != NFM_NO_TRANSFER)
    {
      i_ref = 2; i_cp = 1;
      sprintf (sql_str, "%s %d %s '%s' %s %d %s %d %s %s %s %s",
             "select n_co, n_copy, n_ref from nfmsafiles where n_sano =", 
             sano,
             "and n_filename =", data[index+i_cofilename],
             "and n_catalogno =",
             catalog_no, "and n_itemno =", item_no, "and n_filenum =",
             data[index+i_filenum],
             "and n_fileversion =", data[index+i_fileversion]);

      _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      status = SQLquery (sql_str, &list1, MEM_SIZE);
      if (status == SQL_S_SUCCESS)
      {
        status = MEMbuild_array (list1);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMbuild_array: 0x%.8x\n", status));
          free (lfm_files);
          MEMclose (&list);
          MEMclose (&list1);
          degree = 3;
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
             _DMdo_nothing ();
          return (status);
        }
         
        data1 = (char **) list1->data_ptr;
        if (strcmp (data1[i_cp], "N") || atol(data1[i_ref]) > 0)
        { 
          _NFMdebug ((fname, "The item has been copied before, NO DELETE\n"));
          (lfm_files+x)->action = 1; 
          sprintf (temp_str, "%d", NFM_READ_ONLY);
        }
        else
          (lfm_files+x)->action = -1; /* need to delete the record in LFM */
         
        status = MEMclose (&list1);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
          free (lfm_files);
          MEMclose (&list);
          degree = 3;
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          if (DM_MANAGER)
            _DMdo_nothing ();
          return (status);
        }
      }
      else if ( status == SQL_I_NO_ROWS_FOUND)
      {
        (lfm_files+x)->action = 0; /* no entry in the table */
        add_to_lfm ++;
      }
      else
      {
        _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
        free (lfm_files);
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&file_list);
        _NFMfree_linked_lists (sto_list, NULL);
        degree = 3;
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        if (DM_MANAGER)
           _DMdo_nothing ();
        return (status);
      }
    }
    strcpy (row_str, "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1");
    strcat (row_str, data[index+i_fileno]); strcat (row_str, "\1");
    strcat (row_str, "\1\1");
    strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
    strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
    strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
    strcat (row_str, temp_str); strcat (row_str, "\1\1\1");

    if (DM_MANAGER)
    {
      sprintf (dumb_str, "%s\1%d\1%s\1%s\1%s\1", catalog_name, item_no, 
               item_revision, item_name, itemdesc);
      strcat (row_str, dumb_str);
    }
    else
    {
      strcat (row_str, "\1\1\1\1\1");
    }

    _NFMdebug ((fname, "row_str:%s\n", row_str));
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
      MEMclose (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      if (DM_MANAGER)
        _DMdo_nothing ();
      return (status);
    }
  }

  sprintf (sql_str, 
           "%s %s %s %s %s '%s' %s %d %s %s", 
           "update", fcat_name, "set n_cosano = NULL, n_couser = '',",
           "n_codate = NULL,", 
           "n_fileco =", file_co, "where n_itemnum =",
           item_no, "and n_fileversion =", data[index+i_fileversion] ); 
      
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    /* rollback in _NFMcleanup should take care of executed sql in this
         "for loop", since no "COMMIT WORK" is issued after the table was 
         locked before the "for loop" */

      MEMclose(&list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
      if (DM_MANAGER)
        _DMdo_nothing ();
      return (status);
  } 
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    /* rollback as check-in with no file transfer */
    _NFMrollback_and_undo_buffer (NFM_CHECK_IN, NFM_ITEM, 
                                  NULL, NULL, list, catalog_name, 0,
                                  item_no, 0, NFM_RLBK_FCAT_NT);
    MEMclose(&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (strcmp (file_status, "ON"))
    strcpy (file_status1, "I");
  else
    strcpy (file_status1, "");
 
  status = NFMset_item_status (catalog_name, "", "", item_no, 
                               file_status1, NFM_LOCK_COMMIT, "");
  if (status != NFM_S_SUCCESS)
  {
    /* rollback as check-in with no file transfer */
    _NFMrollback_and_undo_buffer (NFM_CHECK_IN, NFM_ITEM, 
                                  NULL, NULL, list, catalog_name, 0,
                                  item_no, 0, NFM_RLBK_FCAT_NT);
    MEMclose (&list);
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
    if (DM_MANAGER)
      _DMdo_nothing ();
    return (status);
  }

  if (operation.transfer == NFM_NO_TRANSFER)
  {
    _NFMdebug ((fname, "EXIT: (operation == NFM_NO_TRANSFER 0x%.8x\n", status));
    return (NFM_S_SUCCESS);
  }

  /* at this point cancel check out item is considered as successful */

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list, 
                       _NFMdebug_st.NFMdebug_file);

  /* move the files */
  if (DM_MANAGER)
    status = DMrm_co_files (&file_list, 0);
  else
    status = NFMpcrm_co_files (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMpcrm_co_files 0x%.8x\n", status));
    MEMbuild_array (file_list);
    MEMclose (&list);
    MEMclose (&file_list);
    degree = 1;
    ERRload_struct (NFM, NFM_W_MESSAGE, "%s",
       "Failed to remove local files");
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    return (status);
  }
  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file transfer buffer", file_list, 
                      _NFMdebug_st.NFMdebug_file);

  if (operation.transfer == NFM_TRANSFER)
  {
    _NFMdebug ((fname, "EXIT: (operation == NFM_TRANSFER) 0x%.8x\n", status));
    return (NFM_S_SUCCESS);
  }

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    MEMclose (&list);
    MEMclose (&file_list);
    degree = 1;
    ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error");
    _NFMcleanup (&degree, wf_info, "", "", "");
    return (status);
  }

  sprintf (sql_str, "%s %d %s %d %s %d %s %d %s",
             "update nfmsafiles set n_co = 'N' where n_sano =",
             sano, "and n_catalogno =", catalog_no, "and n_itemno =",
             item_no, "and n_fileversion =", file_version, "and (");
  for (x = 0, nothing = 1; x < list->rows; x ++)
  {
    index = x * list->columns;
    if ((lfm_files+x)->action == 1)
    {
      if (!nothing)
        strcat (sql_str, "or");
      else
        nothing = 0;
      strcat (sql_str, "(n_filenum = ");
      strcat (sql_str, data[index+i_filenum]);
      strcat (sql_str, "and n_filename = '");
      strcat (sql_str, data[index+i_cofilename]);
      strcat (sql_str, "')");
    }
  }
  strcat (sql_str, ")");
  if (!nothing)
  {
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (&file_list);
      free (lfm_files);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
/* mms -      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); */
      return (status);
    }
  }
  sprintf (sql_str, "%s %d %s %d %s %d %s %d %s",
           "delete from nfmsafiles where n_sano =",
           sano, "and n_catalogno =", catalog_no, "and n_itemno =",
           item_no, "and n_fileversion =", file_version, "and (");
  for (x = 0, nothing = 1; x < list->rows; x ++)
  {
    index = x * list->columns;
    if ((lfm_files+x)->action == -1)
    {
      if (!nothing)
        strcat (sql_str, "or");
      else
        nothing = 0;
      strcat (sql_str, "(n_filenum = ");
      strcat (sql_str, data[index+i_filenum]);
      strcat (sql_str, "and n_filename = '");
      strcat (sql_str, data[index+i_cofilename]);
      strcat (sql_str, "')");
    }
  }
  strcat (sql_str, ")");
  if (!nothing)
  {
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (&file_list);
      free (lfm_files);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
/* mms -      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL); */
      return (status);
    }
  }
  free (lfm_files);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&file_list);
    free (lfm_files);
    degree = 1;
    ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
    _NFMcleanup (&degree, wf_info, "", "", "");
/* mms -     ERRload_struct (NFM, NFM_E_MEM, "", NULL); */
    return (status);
  }
  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
  {
    free (lfm_files);
    degree = 1;
    ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
    _NFMcleanup (&degree, wf_info, "", "", "");
/* mms -     ERRload_struct (NFM, NFM_E_MEM, "", NULL); */
    return (status);
  }

  status = NFMstart_transaction (0); 
  if (status != NFM_S_SUCCESS)
    _NFMdebug ( (fname, "NFMstop_transaction: 0x%.8x\n", status) );

  if (wf_info.workflow)
  {
    status = ERRget_message (error_msg);
    if (status != ERR_S_SUCCESS)
      _NFMdebug ((fname, "ERRget_message: 0x%.8x\n", status));
    ERRget_number (&error_no, &subsystem);
    if (status != ERR_S_SUCCESS)
      _NFMdebug ((fname, "ERRget_number: 0x%.8x\n", status));

    status = NFMset_wf_state (wf_info.app_name, error_no, error_msg);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMset_wf_state 0x%.8x\n", status));
    }
  }

  _NFMdebug ((fname, "EXIT: successfully 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
