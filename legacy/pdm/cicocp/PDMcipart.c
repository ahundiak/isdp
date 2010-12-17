#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "WFstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "PDUerror.h"
#include                "PDUnode.h"
#include                "PDUstorage.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"


extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;


long PDMcheckin_item (catalog_name, catalog_no, item_name, item_revision,
                      working_area, wf_info, operation)

char *catalog_name; /* item's catalog */
long catalog_no;
char *item_name; /* item's name */
char *item_revision; /* item's revision */
char *working_area; /* check in from for the 1st time checkin */
struct NFMwf_info wf_info; /* I: turn on/off validation and set_to_state */
struct NFMoperation operation; /* I: file transfer mode */

{
  char *fname="NFMcheckin_item";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[2048], sub_str[1024], row_str[1024];
  char move_move_str[10], first_temp_str[10], temp_str[10], temp_str1[10];
  char **data, **data1, **column, **format;
  char file_status[NFM_STATUS+1], file_status1[NFM_STATUS+1],
       file_co[NFM_FILECO+1];
  char datetime_str[NFM_DATE+1];
  char datetime[NFM_DATE+1], filename[NFM_CIFILENAME+1];
  char temp_datetime[NFM_DATE+1];
  char dumb_str[10], type_m_file[NFM_COFILENAME+1];
  int  x, y, count, index, first_time, first_move=0, move_move=0;
  int  sto_no;
  int type_m=0, archive_no=0;
  int i_fileno, i_itemnum, i_filenum, i_cofilename, i_fileversion, i_filetype,
      i_fileclass, i_restoreflag, i_archiveno, i_cisano, i_cifilename,
      i_ciuser, i_cidate, i_cifilesize, i_cocomment, i_cosano, i_couser,
      i_codate, i_fileco, i_convertind;
  long micro, m_set=0;
  long file_version, max_file_no, file_no;
  long version_limit = 1, purge_limit;
  long item_no, status, degree;
  long dumb_value, fs_net_id;
  long no_move_file_warning=0, no_file_warning=0;
  MEMptr list=NULL, dumb_list= NULL, file_list=NULL;
  struct NFMsto_info *sto_list;
  struct NFMitem_entry item_entry;
  i_fileno = 0; i_itemnum = 0; i_filenum = 0; 
  i_cofilename = 0; i_fileversion = 0; i_filetype = 0;
  i_fileclass = 0; i_restoreflag = 0; i_archiveno = 0; 
  i_cisano = 0; i_cifilename = 0;
  i_ciuser = 0; i_cidate = 0; i_cifilesize = 0; i_cocomment = 0; 
  i_cosano = 0; i_couser = 0;
  i_codate = 0; i_fileco = 0; i_convertind = 0;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] item_name[%s] item_rev[%s]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] user_name [%s]\n", 
                       catalog_name, item_name,
                       item_revision, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation.transfer, operation.delete, operation.purge,
                       NFMglobal.NFMusername));

  sprintf (fcat_name, "f_%s", catalog_name);

  if (strlen(PDMpart.n_status)) first_time = 0;
      else first_time = 1;
  item_no = PDMpart.n_itemno;
   strcpy(file_status, PDMpart.n_status);

 version_limit = PDMpart.n_versionlimit;

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    return (status);
  }

  /* retrieve item's information from f_<catalog> */

  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
               status = PDM_I_COULD_NOT_LOCK_TABLE;
         _PDMdebug(fname,  "LOCK %s SQLstmt failed status %d\n",  fcat_name, status);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    return (status);
                 }
           }
    }

  sprintf (sql_str, "%s %s %s %d %s %s %s %d %s",
          "select * from",
           fcat_name, "where n_itemnum =", item_no, 
           "and n_fileversion = (select max(n_fileversion) from", 
           fcat_name, "where n_itemnum =", item_no, ")");

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                    "Failed to retrieve item's information");
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "MEMbuild_array (fileversion info) 0x%.8x\n", status));
    return (NFM_E_MESSAGE);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
    return (NFM_E_SQL_STMT);
  }

  /* assign the index based on the query */

  column = (char **) list->column_ptr;
  format = (char **) list->format_ptr;

  for (x = 0; x < list->columns; x ++)
  {
    if (!strcmp (column[x], "n_fileno"))
      i_fileno = x;
    else if (!strcmp (column[x], "n_itemnum"))
      i_itemnum = x;
    else if (!strcmp (column[x], "n_filenum"))
      i_filenum = x;
    else if (!strcmp (column[x], "n_cofilename"))
      i_cofilename = x;
    else if (!strcmp (column[x], "n_fileversion"))
      i_fileversion = x;
    else if (!strcmp (column[x], "n_filetype"))
      i_filetype = x;
    else if (!strcmp (column[x], "n_fileclass"))
      i_fileclass = x;
    else if (!strcmp (column[x], "n_restoreflag"))
      i_restoreflag = x;
    else if (!strcmp (column[x], "n_archiveno"))
      i_archiveno = x;
    else if (!strcmp (column[x], "n_cisano"))
      i_cisano = x;
    else if (!strcmp (column[x], "n_cifilename"))
      i_cifilename = x;
    else if (!strcmp (column[x], "n_ciuser"))
      i_ciuser = x;
    else if (!strcmp (column[x], "n_cidate"))
      i_cidate = x;
    else if (!strcmp (column[x], "n_cifilesize"))
      i_cifilesize = x;
    else if (!strcmp (column[x], "n_cocomment"))
      i_cocomment = x;
    else if (!strcmp (column[x], "n_cosano"))
      i_cosano = x;
    else if (!strcmp (column[x], "n_couser"))
      i_couser = x;
    else if (!strcmp (column[x], "n_codate"))
      i_codate = x;
    else if (!strcmp (column[x], "n_fileco"))
      i_fileco = x;
    else if (!strcmp (column[x], "n_convertind"))
      i_convertind = x;
  }

  data = (char **) list->data_ptr;

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("info from f_<catalog>", list, _NFMdebug_st.NFMdebug_file);
                
  file_version = atol (data[i_fileversion]);

  _NFMdebug ((fname, "file status: [%s] %s check the checked-out-user\n",
              file_status, (first_time? "DO NOT" : "DO")));
  if (!first_time && strcmp (data[i_couser], NFMglobal.NFMusername))
  {
    MEMclose (&list);
    degree = 3;
    ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", "check in the item", 
         "item");
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "Not the checkout user \n"));
    return (NFM_E_NOT_CO_USER);
  }
 
  /* get date and time */

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_datetime failed 0x%.8x\n", status));
    return (status);
  }

  _NFMdebug ((fname, "datetime = %s\n", datetime));

  /* get storage area information */


  sto_list = (struct NFMsto_info *) calloc ((list->rows) + 1, 
              sizeof (struct NFMsto_info));

  if (!first_time)
  {
     sto_list->sano = atol (data[i_cosano]);
     _NFMdebug ((fname, "This is NOT first time checkin, FROM = CO = %d\n",
                  sto_list->sano));
  }
  else 
    strcpy (sto_list->saname, working_area);

  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano), 
           sto_list->nodename, sto_list->username, sto_list->passwd,
           sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
           sto_list->partition, sto_list->nfs, sto_list->compress, 
           sto_list->machid, sto_list->opsys, sto_list->tcpip, sto_list->xns,
           sto_list->decnet, sto_list->netware);

  if (status != NFM_S_SUCCESS)
  {
    degree = 3;
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMget_storage_info failed 0x%.8x\n", status));
    return (status);
  }
/*  Added this code to facilitate updating n_fileco for
    all the files if there are multiple files MaC 051994 */
    SQLstmt ("COMMIT WORK");
    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
 /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
      MEMclose (&list);
      degree = 3;
               status = PDM_I_COULD_NOT_LOCK_TABLE;
         _PDMdebug(fname,  "LOCK %s SQLstmt failed status %d\n",  fcat_name, status);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    return (status);
                 }
           }
    }
    for (x = 0; x < list->rows; x++)
    {
      count = list->columns * x;
      if (strlen (data[count+i_fileco]))
        strcpy (file_co, "N");
      else
        strcpy (file_co, "");

      sprintf (sql_str, 
               "%s %s %s %s '%s', %s '%s', %s '%s' %s %d %s %s", 
               "update", fcat_name, "set n_cosano = NULL, n_couser = NULL,",
               "n_codate = NULL, n_ciuser =", NFMglobal.NFMusername,
               "n_cidate = timestamp",
               datetime, "n_fileco =", file_co, "where n_itemnum =",
               item_no, "and n_fileversion =", data[count+i_fileversion] ); 
      
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        MEMclose(&list);
        degree = 3;
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        return ( NFM_E_SQL_STMT);
      } 
    }
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMrollback_and_undo_buffer (NFM_CHECK_IN, NFM_ITEM,
                                    NULL, NULL, list, catalog_name, 0,
                                    item_no, 0, NFM_RLBK_FCAT_NT);
      MEMclose(&list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
      return ( NFM_E_SQL_STMT);
    }
  /* if operation.transfer == NFM_NO_TRANSFER, update <catalog> & f_<catalog> */

  if (operation.transfer == NFM_NO_TRANSFER ||
      (list->rows == 1 && atol (data[i_fileversion]) == 0 && 
        !strlen(data[i_cofilename]) ))
  {
    _NFMdebug ((fname, "%s\n",
                ((operation.transfer == 0)? 
                  "operation.transfer == NFM_NO_TRANSFER":
                  "Item does not have associated files") ));

    /* Make sure the following is correct */
    if (! strcmp (file_status, "O") || !strcmp(file_status, "S"))
    {
      strcpy (file_status1, "I");
      no_move_file_warning = 1;
    }
    else
    {
      strcpy (file_status1, "");
      no_file_warning = 1;
    }
 
    status = NFMset_item_status (catalog_name, "", "", item_no, 
                                 file_status1, NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      _NFMrollback_and_undo_buffer (NFM_CHECK_IN, NFM_ITEM,
                                    NULL, NULL, list, catalog_name, 0,
                                    item_no, 0, NFM_RLBK_FCAT_NT);
      MEMclose (&list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
      return (status);
    }

    NFMstart_transaction (0);
 
    MEMclose (&list);
       
    if (no_move_file_warning)
    {
      _NFMdebug ((fname, "EXIT: operation == NFM_NO_TRANSFER\n"));
      ERRload_struct (NFM, NFM_W_NO_FILE_MOVE, "", NULL);
      return (NFM_W_NO_FILE_MOVE);
    }
    else if (no_file_warning)
    {
      _NFMdebug ((fname, "EXIT: no file associated\n"));
      ERRload_struct (NFM, NFM_W_NO_FILE, "", NULL);
      return (NFM_W_NO_FILE);
    }
    _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }
  else  /* operation = NFM_TRANSFER */
  { 
    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
      MEMclose(&list);
      MEMclose(&file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }

    sprintf (row_str,
     "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
     sto_list->sano, sto_list->nodename, sto_list->username, 
     sto_list->passwd, sto_list->pathname, sto_list->devicetype, 
     sto_list->plattername,
     sto_list->partition, sto_list->nfs,/* mountpoint */
     sto_list->compress, sto_list->machid, sto_list->opsys, 
     sto_list->tcpip, sto_list->xns, sto_list->decnet,
     sto_list->netware, "\1\1\1\1\1\1\1\1\1");

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
      return (NFM_E_MEM);
    }

    for (x = 0, sto_no = 1; x < list->rows; x ++)
    {
      index = list->columns * x;
      _NFMdebug ((fname, "data[index+i_cisano] = %s\n",
                            data[index+i_cisano]));

      /* check to see if the cisano already on the list */

      for (y = 0; y < sto_no ; y++)
      {
        _NFMdebug ( (fname, "(sto_list+%d)->sano: %d\n", y,
                    (sto_list+y)->sano));
        if ( (sto_list+y)->sano  == atol (data[index + i_cisano]) )
        {
          _NFMdebug ( (fname, "storage_area_no found in sto_list \n") );
          break;
        }
      }
      if (y >= sto_no)
      {
        _NFMdebug ((fname, "n_cisano not found in the list, add to it \n"));
        (sto_list+sto_no)->sano  = atol (data[index+i_cisano]);
        sto_no++;
      }
    }

    status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
      MEMclose (&list);
      MEMclose(&file_list);
      degree = 3;
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }

    SQLstmt ("COMMIT WORK");

    if (catalog_no < 1)
    {
      if (wf_info.workflow)
      {
        catalog_no = WFinfo.catalog_no;
      }
      else
      {
         status = PDMris_get_catno(catalog_name, &catalog_no);
        if (status != PDM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
          MEMclose (&list);
          MEMclose(&file_list);
          degree = 3;
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          return (NFM_E_SQL_QUERY);
        }
      }
    }

    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
       /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
              MEMclose (&list);
              MEMclose (&file_list);
               degree = 3;
               status = PDM_I_COULD_NOT_LOCK_TABLE;
         _PDMdebug(fname,  "LOCK %s SQLstmt failed status %d\n",  fcat_name, status);
    _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
    _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
    return (status);
                 }
           }
    }

    sprintf (sql_str, "select max(n_fileno) from %s", fcat_name);

    status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                                 &file_no, &dumb_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "MEMbuild_array (max(fileno)) 0x%.8x\n", status));
      return (NFM_E_SQL_QUERY);
    }
    max_file_no = file_no;
    _NFMdebug ((fname, "file_no %d max_file_no %d\n", file_no,
                       max_file_no));

    sprintf (temp_str, "%d", NFM_MOVE); /* for FTO_STATUS1 in the buffer going
                                           to FS */
    sprintf (first_temp_str, "%d", 2052);
    sprintf (move_move_str, "%d", NFM_MOVE_MOVE);
    for (x = 0; x < list->rows; x++)
    {
      index = list->columns * x;

      sprintf (sql_str, "%s %s %s %s %s ",
               "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
               "n_fileversion, n_fileclass, n_filetype, n_fileco,",
               "n_cifilename, n_cisano, n_ciuser, n_cidate, n_cofilename");

      sprintf (sub_str, "%s (%d, %d, %s, %d, '%s', '%s', \
               '%s', '%s', %s, '%s', timestamp '%s', '%s'",
               ") values ", 
               ++max_file_no, item_no, data[index+i_filenum], file_version+1, 
               data[index+i_fileclass], data[index+i_filetype], 
               "N", data[index+i_cifilename], 
               data[index+i_cisano], NFMglobal.NFMusername, datetime, 
               data[index+i_cofilename]);

      /* this is an unecessary check put in for ??? application for dummy 
         reason */

      if (!strlen(data[index+i_cisano]))
      {
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                        "Check-in-storage-area is not valid");
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "CI-sano is not valid \n"));
        return (NFM_E_MESSAGE);
      }

      for (y = 0; y < list->columns; y ++)
      {
        /* take care of UDA */
        if ( y == i_fileno || y == i_itemnum || y == i_filenum ||
             y == i_cofilename || y == i_fileversion || y == i_filetype ||
             y == i_fileclass || y == i_restoreflag || y == i_archiveno ||
             y == i_cisano || y == i_cifilename || y == i_ciuser ||
             y == i_cidate || y == i_cifilesize || y == i_cocomment ||
             y == i_cosano || y == i_couser || y == i_codate ||
             y == i_fileco || y == i_convertind )
          continue;
        else
        {
          if (strlen (data[index+y]))
          {
            strcat (sql_str, ",");
            strcat (sql_str, column[y]);
     
            if (!strncmp (format[y], "char", 4))
            {
              strcat (sub_str, ", '");
              strcat (sub_str, data[index+y]);
              strcat (sub_str, "'");
            }
            else if (!strcmp (format[y], "integer"))
            {
              strcat (sub_str, ",");
              strcat (sub_str, data[index+y]);
            }
            else
            {
              NFMascii_to_timestamp_format (data[index+y], temp_datetime);
              strcat (sub_str, ", timestamp '");
              strcat (sub_str, temp_datetime);
              strcat (sub_str, "'");
            }
          }
        }
      }
      strcat (sql_str, sub_str);
      strcat (sql_str, ")");

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
      
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
        return (status);
      } 

    /*
      if (strlen (data[index+i_fileco]))
      {
         update the record that has file checked out 
        sprintf (sql_str,
                 "%s %s %s %s %d %s %d %s %s", 
                 "update", fcat_name, "set n_fileco = 'N'", 
                 "where n_itemnum =", item_no, "and n_fileversion =",
                 file_version, "and n_filenum =", data[index+i_filenum]); 

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          MEMclose (&list);
          MEMclose (&file_list);
          degree = 3;
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          _NFMdebug ((fname, "SQLstmt(%s) failed 0x%.8x\n", sql_str, status));
          return ( NFM_E_SQL_STMT);
        }
      }
     */

      /* check in TO storage area information */
      for (y = 0; y < sto_no; y ++)
      {
        _NFMdebug ((fname, "(sto_list+%d)->sano = %d\n",
                             y, (sto_list+y)->sano));
        if ((sto_list+y)->sano == atol (data[index+i_cisano]))
        {
          _NFMdebug ((fname, "found match in sto_list\n"));
          sprintf (row_str,
           "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
           (sto_list+y)->sano,
           (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
           (sto_list+y)->pathname, (sto_list+y)->devicetype,
           (sto_list+y)->plattername,
           (sto_list+y)->partition, (sto_list+y)->nfs,
           (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
           (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
           (sto_list+y)->netware);
          break;
        }
      }
      if (y >= sto_no)
      {
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 3;
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "invalid cisano\n"));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Invalid check-in-storage");
        return ( NFM_E_MESSAGE);
      }

      sprintf (temp_str1, "%d", max_file_no);
      strcat (row_str, temp_str1); strcat (row_str, "\1");
      if (strlen (data[index+i_cifilename]))
      {
        if (first_time)
        {
          strcpy (filename, "\0");
          first_move = 1;
        }
        else
        {
          status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, 
                                    atol(data[index+i_fileno]), 
                                    filename);
          if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
            MEMclose (&list);
            MEMclose (&file_list);
            degree = 3;
            _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
            return (status);
          }
          move_move = 1;
        }
        strcat (row_str, filename); strcat (row_str, "\1");
        strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
      }
      else
      {
        strcat (row_str, "\1");
        status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, max_file_no,
                                    filename);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
          MEMclose (&list);
          MEMclose (&file_list);
          degree = 3;
          _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1");
      }
      strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
      if (! strcmp (data[index+i_filetype], "M"))
      {
        type_m = 1;
        strcpy (type_m_file, data[index+i_cofilename]);
      }
      strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
      if (first_move)
      {
        strcat (row_str, first_temp_str);
        first_move = 0;
      }
      else if (move_move)
      {
        strcat (row_str, move_move_str);
        move_move = 0;
      }
      else
        strcat (row_str, temp_str); 
      strcat (row_str, "\1\1\1");

      _NFMdebug ((fname, "row_str:\n\
      %s\n", row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 3;
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        return (NFM_E_MEM);
      }
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
      return ( NFM_E_SQL_STMT);
    }

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file transfer buffer", file_list, 
                        _NFMdebug_st.NFMdebug_file);

    /* move the files */
    status = _NFMfs_send_files (&file_list, &fs_net_id, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMfs_send_files 0x%.8x\n", status));
      MEMbuild_array (file_list);
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file transfer buffer", file_list, 
                          _NFMdebug_st.NFMdebug_file);
      NFMopen_message_buffer ();
      _NFMstack_error_from_buffer (file_list, catalog_name, item_name, 
                                   item_revision, NFM_CHECK_IN, (MEMptr) NULL);
      NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      /* update the record that has file checked out */
      sprintf (sql_str,
        "%s %s %s %s %d %s %d %s",
        "update", fcat_name, "set n_fileco = 'Y'",
        "where n_itemnum =", item_no, "and n_fileversion =",
        file_version, "and n_fileco = 'N'");
      SQLstmt (sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      /* mms - I do not know what is been loaded here ??? */
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (status);
    }


    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file transfer buffer", file_list, 
                        _NFMdebug_st.NFMdebug_file);

    status = MEMbuild_array (file_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      return (NFM_E_MEM);
    }

    data1 = (char **) file_list->data_ptr;
    for (x = 1; x < file_list->rows; x++)
    {
      index = file_list->columns * x;
      _NFMdebug ((fname, "Update the cifilesize\n"));
      sprintf (sql_str, "%s %s %s %s , n_fileco = 'N' %s %s",
               "update", fcat_name, "set n_cifilesize =",
               data1[index+FTO_CIFILESIZE], "where n_fileno =",
               data1[index+FTO_FILENO]);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
    /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = SQLstmt (sql_str);
                if (status != SQL_S_SUCCESS){
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = SQLstmt (sql_str);
                if (status != SQL_S_SUCCESS){
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
               status = PDM_I_COULD_NOT_LOCK_TABLE;
    _PDMdebug(fname,  "LOCK SQLstmt failed status %d\n",  status);
        NFMdisconnect (&fs_net_id);
        _NFMfs_undo_send_files (&file_list);
        /* COME BACK AND FIX THIS */
        NFMlock_table (fcat_name);
        sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
        SQLstmt(sql_str);
        SQLstmt ("COMMIT WORK");
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 3;
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
        return ( NFM_E_SQL_STMT);
        }
       }
      }
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      /* COME BACK AND FIX THIS */
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
      return ( NFM_E_SQL_STMT);
    }
    /* 01/29/92 special case: if filetype == M" */

    if (type_m)
    {
      _NFMdebug ((fname, "One of the file is type M\n"));
      dumb_value = 1;
      status = NFMbuild_microstation_set (catalog_name, catalog_no,
                item_no, type_m_file, &micro, *sto_list);
      if (status == NFM_I_ITEM_PROMOTED_TO_MS_SET)
      {
        _NFMdebug ((fname, "the item is promoted into a set\n"));
        m_set =1;
      }
      else if (status != NFM_S_SUCCESS)
      {
        NFMlock_table (fcat_name);
        sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no,
               "and n_fileversion = ", file_version+1);
        SQLstmt(sql_str);
        SQLstmt ("COMMIT WORK");  
        NFMdisconnect (&fs_net_id);
        _NFMfs_undo_send_files (&file_list);
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 3;
	/* mms - I do not load what is loaded here ??? */
        _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
        _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
        NFMundo_microstation_set (catalog_name, catalog_no, item_no, micro);
        return (status);
      }
      SQLstmt ("COMMIT WORK");
    }
 
    status = NFMset_item_status (catalog_name, "", "", item_no, "I",
                                 NFM_LOCK_COMMIT, "");
    if (status != NFM_S_SUCCESS)
    {
      /* COME BACK AND FIX THIS */
      NFMlock_table (fcat_name);
      sprintf (sql_str, "%s %s %s %d %s %d",
               "delete from", fcat_name, "where n_itemnum = ", item_no, 
               "and n_fileversion = ", file_version+1);
      SQLstmt(sql_str);
      SQLstmt ("COMMIT WORK");
      NFMdisconnect (&fs_net_id);
      _NFMfs_undo_send_files (&file_list);
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 3;
      /* mms - I do not what is loaded here */
      _NFMcleanup (&degree, wf_info, catalog_name, item_no, file_status);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", catalog_name, status));
      NFMundo_microstation_set (catalog_name, catalog_no, item_no, micro);
      return (status);
    }
  }

  if (NFMglobal.load_item_file == NFM_LOAD_ITEM_FILE)
  {
    _NFMdebug ((fname, "Load processed items/files info into global\n"));
    strcpy (item_entry.cat_name, catalog_name);
    item_entry.cat_no = catalog_no;
    strcpy (item_entry.item_name, item_name);
    strcpy (item_entry.item_rev, item_revision);
    strcpy (item_entry.status, file_status);
    item_entry.item_no = item_no;
    item_entry.files = list->rows;
    item_entry.next_item = (struct NFMitem_entry *) NULL;
    item_entry.next_file = (struct NFMfile_entry *) NULL;
    for (x = 0; x < list->rows;  x++)
    {
      status = MEMwrite_data (list, datetime, x + 1, i_cidate);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite_data: 0x%.8x\n", status));
      }
    }
    NFMload_item_file_information (NFM_ITEM, list, file_list, &item_entry,
       (struct NFMset_member*) NULL);
  }

  /* At this point, the checkin is considered successful. The following
     code is designated for cleaning up */

  /* if operation.delete == NFM_NO_DELETE, don't delete from files,
     dont do anything */

  /* else if operation.delete == NFM_CONDITIONAL_DELETE, build buffer
     consulting local file manager */

   if (operation.delete == NFM_DELETE_FILES)
  {
    /* delete files */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file to delete:", file_list, 
                           _NFMdebug_st.NFMdebug_file);
    status = NFMrm_co_files (&file_list, fs_net_id);
    if (status != NFM_S_SUCCESS)
    {        
      _NFMdebug ((fname, "NFMrm_co_files: 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
    }
  }
  else if (operation.delete == NFM_NO_DELETE && 
           (operation.transfer == NFM_CONDITIONAL_TRANSFER ||
            operation.transfer == NFM_TRANSFER) )
  {
    status = NFMdisconnect (&fs_net_id);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMdisconnect: 0x%.8x\n", status));
      MEMclose (&list);
      MEMclose (&file_list);
      degree = 1;
      /* ignore error */
      ERRload_struct (NFM, NFM_S_SUCCESS, "", "") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      return (status);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("info from f_<catalog>", list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("info from file_server", file_list, 
                    _NFMdebug_st.NFMdebug_file);
  }

  MEMclose (&list);
  MEMclose (&file_list);

  /* if operation.purge == NFM_PURGE, purge the internal files and records */
  if (operation.purge == NFM_PURGE)
  {
    /* if versionlimit not given, default to 1 and WARN the user */

    status = NFMbuild_fto_buffer (&file_list, 0);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
      degree = 2;
      /* ignore error */
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      return (status);
    }

    SQLstmt ("COMMIT WORK");
    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
       /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
          status = PDM_I_COULD_NOT_LOCK_TABLE;
    _PDMdebug(fname,  "LOCK %s SQLstmt failed status %d\n",  fcat_name, status);
      degree = 2;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Lock Table Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      MEMclose (&file_list);
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
      return (status);
      }
     }
    }

    if (version_limit > 0)
      purge_limit = version_limit;
    else
      purge_limit = 1;


/* To facilitate purging...MaC 041494 ...
    sprintf (sql_str, "%s %s %s %s %d %s %d %s",
      "select n_fileno, n_cifilename, n_cisano, n_fileversion, n_fileco,",
      "n_archiveno from",
           fcat_name, "where n_fileversion <=",
           file_version + 1 - purge_limit, "and n_itemnum =",
           item_no, "and n_fileco = 'N'");
*/
    sprintf (sql_str, "%s %s %s %s %d %s %d ",
      "select n_fileno, n_cifilename, n_cisano, n_fileversion, n_fileco,",
      "n_archiveno from",
           fcat_name, "where n_fileversion <=",
           file_version + 1 - purge_limit, "and n_itemnum =",
           item_no );

    status = SQLquery(sql_str, &list, MEM_SIZE);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "No rows qualified for purging\n"));
      MEMclose (&file_list);
      MEMclose (&list);
      goto CIIpurge_record;
    }
    else if (status != SQL_S_SUCCESS)
    {
      MEMclose (&file_list);
      MEMclose (&list);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
/* mms      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL); */
      return (NFM_E_SQL_QUERY);
    }

    SQLstmt ("COMMIT WORK");

    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&file_list);
      MEMclose (&list);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "MEMbuild_array (fileversion info) 0x%.8x\n", status));
      return (NFM_E_MEM);
    }

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);

    sprintf (temp_str, "%d", NFM_PURGE_FILE);
    data = (char **) list->data_ptr;
    for (x = 0, archive_no = 0; x < list->rows; x++)
    {
      index = list->columns * x;

      /* purge  storage area information */
      for (y = 0; y < sto_no; y ++)
      {
        _NFMdebug ((fname, "(sto_list+%d)->sano = %d\n",
                             y, (sto_list+y)->sano));
        if ((sto_list+y)->sano == atol (data[index+2]))
        {
          _NFMdebug ((fname, "found match in sto_list\n"));
          sprintf (row_str,
           "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
           (sto_list+y)->sano,
           (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
           (sto_list+y)->pathname, (sto_list+y)->devicetype,
           (sto_list+y)->plattername,
           (sto_list+y)->partition, (sto_list+y)->nfs,
           (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
           (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
           (sto_list+y)->netware);
          break;
        }
      }

      if (strlen (data[index+5]))
        archive_no = 1;

      strcat (row_str, data[index]); strcat (row_str, "\1");
      strcat (row_str, "\1");
      status = NFMget_file_name (NFMglobal.NFMuserid, catalog_no, 
                                 atol(data[index]), filename);
      if (status != NFM_S_SUCCESS)
      {
        MEMclose (&file_list);
        MEMclose (&list);
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        degree = 1;
	ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, temp_str); strcat (row_str, "\1\1\1");

      _NFMdebug ((fname, "MEMwrite [%s]\n",
                          row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
        MEMclose (&list);
        MEMclose (&file_list);
        degree = 1;
	ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "Memory Error") ;
        _NFMcleanup (&degree, wf_info, "", "", "");
        return (NFM_E_MEM);
      }
    }
    /* move the files */

    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

    status = NFMfs_purge (&file_list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMfs_purge 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
      if (_NFMdebug_st.NFMdebug_on)
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    }

    MEMclose (&list);
    MEMclose (&file_list);
    _NFMfree_linked_lists (sto_list, NULL);

    status = NFMlock_table (fcat_name);
    if (status != NFM_S_SUCCESS)
    {
       /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = NFMlock_table (fcat_name);
                if (status != NFM_S_SUCCESS){
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
               status = PDM_I_COULD_NOT_LOCK_TABLE;
  _PDMdebug(fname,  "LOCK %s SQLstmt failed status %d\n",  fcat_name, status);
      degree = 1;
      ERRload_struct (NFM, NFM_W_MESSAGE, "%s", "SQL Error") ;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "NFMlock_table(%s) 0x%.8x\n", fcat_name, status));
      return (status);
       }
       }
      }

    CIIpurge_record:
    sprintf (sql_str, "%s %s %s %d %s %d %s",
           "delete from", fcat_name, "where n_fileversion <=", 
           file_version + 1 - purge_limit, "and n_itemnum =", 
           item_no, "and n_archiveno is NULL"); 

    SQLstmt (sql_str);

    if (archive_no)
    {
      sprintf (sql_str, "%s %s %s %d %s %d %s",
           "update", fcat_name, "set n_fileco = 'O' where n_fileversion <=", 
           file_version + 1 - purge_limit, "and n_itemnum =", 
           item_no, "and n_archiveno > 0"); 

      SQLstmt (sql_str);
    }

    SQLstmt ("COMMIT WORK");

  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction: 0x%.8x\n", status));

  _NFMdebug ((fname, "EXIT: successfully 0x%.8x\n\
                            version = %d, ms_set = %d\n", 
                            NFM_S_SUCCESS, version_limit, m_set));
  if (version_limit < 1)
  {
    ERRload_struct (NFM, NFM_W_INVALID_VERSION_LIMIT, "%d",
                    version_limit);  
    return (NFM_W_INVALID_VERSION_LIMIT);
  }
  else if (m_set)
    return (NFM_I_ITEM_PROMOTED_TO_MS_SET);

  return (NFM_S_SUCCESS);
}
