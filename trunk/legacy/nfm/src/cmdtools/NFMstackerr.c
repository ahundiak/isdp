#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMfto_buf.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMstruct.h"


#define NFM_I_CATNO 0
#define NFM_I_ITEMNO 1
#define NFM_I_TYPE 2
#define NFM_I_STATUS1 11

long special_msg = 0;

long _NFMstack_error_from_buffer (list, catalog_name, item_name, item_rev, 
                                  operation, list1)

/***
  This function will stack all the errors from different files.
***/


MEMptr list;
char *catalog_name;
char *item_name;
char *item_rev;
long operation;
MEMptr list1;

{
  char *fname="NFMstack_error_from_buffer";
  char **data, **data1;
  char operation_str[20];
  char temp_error[1024];
  char tmp_str[1024];
  char copath[NFM_PATHNAME+1];
  char cofilename[NFM_COFILENAME+1];
  int x, index, y, index1;
  int fatal; 
  long ret_status=NFM_E_FAILURE;
  long transfer_status;

  _NFMdebug ((fname, "ENTER: operation [%d] list addr [%ld] list addr [%ld] special %d\n",
              operation, list, list1, special_msg));
  fatal = 0;

  if (operation == NFM_CHECK_IN)
    strcpy (operation_str, " Check In ");
  else if (operation == NFM_CHECK_OUT)
    strcpy (operation_str, " Check Out");
  else if (operation == NFM_COPYFILES)
    strcpy (operation_str, " Copy files");
  else if (operation == NFM_CANCEL_CHECK_OUT)
    strcpy (operation_str, " Cancel Check Out");


  data = (char **) list->data_ptr;

  strncpy (copath, data[FTO_PATHNAME], NFM_PATHNAME);
  _NFMdebug ((fname, "copath [%s]\n", copath));
  _DMins_bs (copath, NFM_PATHNAME);
  _NFMdebug ((fname, "after insert, copath [%s]\n", copath));

  if (list1 != (MEMptr) NULL)
    data1 = (char **) list1->data_ptr;
  else 
    data1 = 0;
  for (x = 1, y = 0; x < list->rows; x ++, y++)
  {
    index = x * list->columns;

    if (data1 == 0)
      index1 = 0;
    else
      index1 = y * list1->columns;

    transfer_status = atol (data[index+FTO_STATUS1]);

    if ( ( (operation == NFM_CHECK_OUT || operation == NFM_CHECK_IN ||
            operation == NFM_COPYFILES) && 
           transfer_status != NFM_TRANSFERED &&
           transfer_status != NFM_MOVE_TRANSFERED
         ) 
         ||
         ( operation == NFM_CANCEL_CHECK_OUT &&
           transfer_status != NFM_REMOVED
         ) 
         ||
         ( operation == NFM_MOVE_CHECKED_OUT_FILES &&
           transfer_status != NFM_TRANSFERED
         )
       )
    {
      _NFMdebug ((fname, "move %s failed 0x%.8x\n", data[index+FTO_COFILENAME],
                         transfer_status ));
      if (!data1)
      {
        fatal = 1;
      }
      else if (strcmp (data1[index1+NFM_I_TYPE], "S") &&
               operation != NFM_COPYFILES)
      {
        index1 = y * list1->columns;
        _NFMdebug ((fname, "cat %s item %s type %s failed to have File Move.\n",
                    data1[index1+NFM_I_CATNO], data1[index1+NFM_I_ITEMNO],
                    data1[index1+NFM_I_TYPE]));
        fatal = 1;  
      }
      else 
      {
      }

      switch (transfer_status)
      {
        case NFM_E_CI_FILENAME_EXISTS:
          ERRload_struct (NFM, NFM_E_CI_FILENAME_EXISTS, "", NULL);
          NFMlog_message ();
          _NFMdebug ((fname, "Checked-in-filename already exits in cisano\n"));
          break;
        case NFM_E_LFM_NFS_EXISTS_LOCALLY:
          if (strlen (data[index+FTO_COFILENAME]))
            ERRload_struct (NFM, NFM_E_LFM_EXISTS_LOCALLY, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          else
            ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
          NFMlog_message ();
          _NFMdebug ((fname, "CO filename [%s] exist locally\n",
                              data[index+FTO_COFILENAME]));
          break;
        case NFM_E_LFM_EXISTS_LOCALLY:
          if (strlen (data[index+FTO_COFILENAME]))
            ERRload_struct (NFM, NFM_E_LFM_EXISTS_LOCALLY, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          else
            ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
          NFMlog_message ();
          _NFMdebug ((fname, "CO filename [%s] exist locally\n",
                              data[index+FTO_COFILENAME]));
          break;
        case NFM_E_NO_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_NO_CI_FILENAME, "%s%s",
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "CI filename [%s] has 0 length\n",
                              data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_STAT_CI_FILENAME:
          if (atol (data[index+FTO_STATUS2]) == 2)
            ERRload_struct (NFM, NFM_E_COI_STATUS_NULL, "%s%s",
                            data[index+FTO_ITEMNAME],
                            data[index+FTO_REV]);
          else
            ERRload_struct (NFM, NFM_E_STAT_CI_FILENAME, "%s%s",
                          data[index+FTO_PATHNAME],
                          data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "stat %s failed \n", data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FOPEN_READ_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FOPEN_READ_CI_FILENAME, "%s%s",
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "fopen w/read only for %s/%s failed\n",
                             data[index+FTO_PATHNAME], 
                             data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_MALLOC_TEMP_FS2:
          ERRload_struct (NFM, NFM_E_MALLOC_TEMP_FS2, "%s%s%s%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "NFM_E_MALLOC_TEMP_FS2, temp block required\n"));
          break;
        case NFM_E_FREAD_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FREAD_CI_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to read block of cifilename\n"));
          break;
        case NFM_E_FOPEN_WRITE_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FOPEN_WRITE_CI_FILENAME, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "fopen w/write %s/%s failed\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FWRITE_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FWRITE_CI_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to write block of cifilename\n"));
          break;
        case NFM_E_SET_UTIME_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_SET_UTIME_CI_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, 
                      "failed to set time after modifying %s last time\n",
                      data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_SET_CHMOD_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_SET_CHMOD_CI_FILENAME, 
                          "%s%s%s%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chmod for %s\n",
                             data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_SET_CHOWN_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_SET_CHOWN_CI_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chown for %s\n", 
                          data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_BAD_SIZE_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_BAD_SIZE_CI_FILENAME, 
                          "%s%s%s%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "%s size does not match %s\n",
                          data[index+FTO_CIFILENAME], 
                          data[index+FTO_COFILENAME]));
          break;
        case NFM_E_MEM_BUILD_ARRAY_BUFFER:
          ERRload_struct (NFM, NFM_E_MEM_BUILD_ARRAY_BUFFER, "%s",
                          operation_str);
          NFMlog_message ();
          _NFMdebug ((fname, "MEMbuild_array failed\n"));
          break;
        case NFM_E_NET_DECRYPT_CI_LOCATION:
          ERRload_struct (NFM, NFM_E_NET_DECRYPT_CI_LOCATION, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Passwrod decryption failed\n"));
          break;
        case NFM_E_UNKNOWN_CI_NODENAME:
          ERRload_struct (NFM, NFM_E_UNKNOWN_CI_NODENAME, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "nodename %s is not in the clearinghouse\n",
                             data[index+FTO_NODENAME]));
          break;
        case NFM_E_BAD_TLI_PORT_FS1_FS2:
          ERRload_struct (NFM, NFM_E_FREAD_CI_FILENAME, "%s%s%s%s%s",
                          data[index+FTO_STATUS2], 
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "port %s used for connecting is < 0\n",
                      data[index+FTO_STATUS2]));
          break;
        case NFM_E_UNKNOWN_PROTOCOL_FS1_FS2:
          ERRload_struct (NFM, NFM_E_UNKNOWN_PROTOCOL_FS1_FS2, "%s%s%s%s%s",
                          data[index+FTO_STATUS2], 
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "protocol %s is unknown\n",
                      data[index+FTO_STATUS2]));
          break;
        case NFM_E_TLI_CONNECT_FS1_FS2:
          if (special_msg)
            ERRload_struct (NFM, NFM_E_TLI_CONNECT_FS1_FS2, "%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME]);
          else
            ERRload_struct (NFM, NFM_E_TLI_CONNECT_FS1_FS2, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "connection failed\n"));
          ret_status = NFM_E_TLI_CONNECT_FS1_FS2;
          break;
        case NFM_E_TLI_SEND_FS1_FS2:
          ERRload_struct (NFM, NFM_E_TLI_SEND_FS1_FS2, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Buffer send failed\n"));
          break;
        case NFM_E_TLI_RECEIVE_SIZE_FS1_FS2:
          ERRload_struct (NFM, NFM_E_TLI_RECEIVE_SIZE_FS1_FS2, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "receive size failed\n"));
          break;
        case NFM_E_TLI_RECEIVE_FS1_FS2:
          ERRload_struct (NFM, NFM_E_TLI_RECEIVE_FS1_FS2, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "buffer receive failed\n"));
          break;
        case NFM_E_FMU_CONNECT_FS1_FS2:
          ERRload_struct (NFM, NFM_E_FMU_CONNECT_FS1_FS2, "%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "connect failed for fmu CI location\n"));
          break;
        case NFM_E_APPEND_CO:
          ERRload_struct (NFM, NFM_E_APPEND_CO, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed toe append [%s] to [%s]\n",
                       copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_APPEND_CI:
          ERRload_struct (NFM, NFM_E_APPEND_CI, "%s%s",
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed toe append [%s] to [%s]\n",
                       data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_LFM_FILE_EXISTS:
          ERRload_struct (NFM, NFM_E_LFM_FILE_EXISTS, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "%s already EXIST at %s\n",
                          data[index+FTO_COFILENAME], copath));
          break;
        case NFM_E_NO_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_NO_CO_FILENAME, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "[%s] has 0 length \n", 
                          data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FOPEN_WRITE_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FOPEN_WRITE_CO_FILENAME, "%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "fopen w/write failed for %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_MALLOC_TEMP_FS1:
          ERRload_struct (NFM, NFM_E_MALLOC_TEMP_FS1, "%s%s%s%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, 
                      "Temp blk required to read/receive a part of %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FWRITE_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FWRITE_CO_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to write block %s/%s\n",
                         data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]));
          break;
        case NFM_E_SET_UTIME_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_SET_UTIME_CO_FILENAME, 
                          "%s%s%s%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to set time for %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_SET_CHMOD_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_SET_CHMOD_CO_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to chmod for %s/%s",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_SET_CHOWN_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_SET_CHOWN_CO_FILENAME, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to chown for  %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_BAD_SIZE_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_BAD_SIZE_CO_FILENAME, 
                          "%s%s%s%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "size %s does not match size %s\n",
                              data[index+FTO_CIFILENAME], 
                              data[index+FTO_COFILENAME]));
          break;
        case NFM_E_STAT_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_STAT_CO_FILENAME, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Stat failed for %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FOPEN_READ_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FOPEN_READ_CO_FILENAME, 
                          "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_STATUS2]);
          NFMlog_message ();
          _NFMdebug ((fname, "fopen w/read failed for %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FREAD_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_BAD_SIZE_CO_FILENAME, 
                          "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to read block of %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FMU_RECEIVE_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FMU_RECEIVE_CO_FILENAME, 
                          "%s%s%s%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fmu receive check out %s/%s\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_BAD_CO_FILE_SIZE:
          ERRload_struct (NFM, NFM_E_BAD_CO_FILE_SIZE, 
                          "%s%s%s%s%s",
                          data[index+FTO_STATUS2], 
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "size %s/%s is bad\n",
                              copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FTP_FOPEN_WRITE_F_SCRIPT:
          ERRload_struct (NFM, NFM_E_FTP_FOPEN_WRITE_F_SCRIPT, 
                          "%s%s%s%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, 
                      "Failed to open script file in /usr/tmp for writing\n"));
          break;
        case NFM_E_FTP_FWRITE_F_SCRIPT:
          ERRload_struct (NFM, NFM_E_FTP_FWRITE_F_SCRIPT, 
                          "%s%s%s%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to write to the script file\n"));
          break;
        case NFM_E_FTP_FOPEN_WRITE_F_SHELL:
          ERRload_struct (NFM, NFM_E_FTP_FOPEN_WRITE_F_SHELL, 
                          "%s%s%s%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, 
                      "Failed to open shell file in /usr/tmp for writing\n"));
          break;
        case NFM_E_FTP_FWRITE_F_SHELL:
          ERRload_struct (NFM, NFM_E_FTP_FWRITE_F_SHELL, 
                          "%s%s%s%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to write to the shell file\n"));
          break;
        case NFM_E_FTP_REC_CO_FILENAME:
          /* there is a problem with loading this error msg, the following
             is a kludge, come back and investigate after pload */
          sprintf (temp_error, 
            "%s [%s] %s [%s] %s [%s] %s [%s] %s [%s] %s [%s]",
            "Filetransfer was in progress using FTP. Failed to send local file",
            data[index+FTO_COFILENAME], "to", data[index+FTO_CIFILENAME],
            "between node", data[FTO_NODENAME], "directory", 
            data[index+FTO_PATHNAME], "and node", data[index+FTO_NODENAME],
            "directory", data[index+FTO_PATHNAME]);

          ERRload_struct (NFM, NFM_E_MESSAGE, 
                          "%s", temp_error);

          NFMlog_message ();
          _NFMdebug ((fname, "Ftp receive failed for %s/%s\n",
                          copath, data[index+FTO_COFILENAME]));
                              
          break;
        case NFM_E_FMU_SEND_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FMU_SEND_CO_FILENAME, 
                          "%s%s%s%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to fmu send check out %s/%s\n",
                              copath, 
                              data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FTP_SEND_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FTP_SEND_CO_FILENAME, 
                          "%s%s%s%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Ftp send failed for %s/%s\n",
                              copath, 
                              data[index+FTO_COFILENAME]));
          break;
        case NFM_E_NONCLIX_SPLIT_COPY_BUFFER:
          ERRload_struct (NFM, NFM_E_NONCLIX_SPLIT_COPY_BUFFER, 
                          "%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "MEMsplit_copy_buffer failed on server for a nonclix co location\n"));
          break;
        case NFM_E_NONCLIX_BUILD_ARRAY:
          ERRload_struct (NFM, NFM_E_NONCLIX_BUILD_ARRAY, "%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "MEMbuild_array failed on server for a nonclix co location\n"));
          break;
        case NFM_E_NONCLIX_WRITE_DATA_SA_INF:
          ERRload_struct (NFM, NFM_E_NONCLIX_WRITE_DATA_SA_INF, "%s",
                          data[index+FTO_STATUS2]);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "MEMwrite_data failed to enter col info for local sa\n"));
          break;
        case NFM_E_NONCLIX_WRITE_DATA_TEMP_N:
          ERRload_struct (NFM, NFM_E_NONCLIX_WRITE_DATA_TEMP_N, "%s",
                          data[index+FTO_STATUS2]);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "MEMwrite_data failed to enter temporary cofilename\n"));
          break;
        case NFM_E_DECRYPT_NONCLIX:
          ERRload_struct (NFM, NFM_E_DECRYPT_NONCLIX, "%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD]);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to decrypt passwd for nonclix co location\n"));
          break;
        case NFM_E_FMU_CONNECT_NONCLIX:
          ERRload_struct (NFM, NFM_E_FMU_CONNECT_NONCLIX, "%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD]);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to connect to nonclix fmu co location\n"));
          break;
        case NFM_E_FTP_CHECK_LOCAL:
          ERRload_struct (NFM, NFM_E_FTP_CHECK_LOCAL, "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD], data[index+FTO_COFILENAME], 
                          copath);
        
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to do LFM check at nonclix ftp co location\n"));
          break;
        case NFM_E_FTP_SEND_NONCLIX:
          ERRload_struct (NFM, NFM_E_FTP_SEND_NONCLIX, "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD], data[index+FTO_COFILENAME], 
                          copath);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to send temp file to nonclix FTP co location\n"));
          break;
        case NFM_E_FMU_CHECK_LOCAL:
          ERRload_struct (NFM, NFM_E_FMU_CHECK_LOCAL, "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD], data[index+FTO_COFILENAME], 
                          copath);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to do LFM check at nonclix fmu co location\n"));
          break;
        case NFM_E_FMU_SEND_NONCLIX:
          ERRload_struct (NFM, NFM_E_FMU_SEND_NONCLIX, "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD], data[index+FTO_COFILENAME], 
                          copath);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to send temp file to nonclix FMU co location\n"));
          break;
        case NFM_E_FTP_RECEIVE_NONCLIX:
          ERRload_struct (NFM, NFM_E_FTP_RECEIVE_NONCLIX, "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD], data[index+FTO_COFILENAME], 
                          copath);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to receive cofilename to temp file from ftp nonclix co loc\n"
          ));
          break;
        case NFM_E_FMU_RECEIVE_NONCLIX:
          ERRload_struct (NFM, NFM_E_FMU_CHECK_LOCAL, "%s%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          data[FTO_PASSWD], data[index+FTO_COFILENAME], 
                          copath);
          NFMlog_message ();
          _NFMdebug ((fname, 
          "Failed to receive cofilename to temp file from fmu nonclix co loc\n"
          ));
          break;
        case NFM_E_UNLINK_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_UNLINK_CO_FILENAME, "%s%s",
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "unlink failed for %s/%s\n",
                      copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FTP_DELETE_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FTP_DELETE_CO_FILENAME, "%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to delete %s/%s\n",
                      copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FMU_SET_READ_ONLY:
          ERRload_struct (NFM, NFM_E_FMU_SET_READ_ONLY, "%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to set to read only for %s/%s\n",
                      copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FMU_DELETE_CO_FILENAME:
          ERRload_struct (NFM, NFM_E_FMU_DELETE_CO_FILENAME, "%s%s%s%s",
                          data[FTO_NODENAME], data[FTO_USERNAME],
                          copath, data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to delete %s/%s\n",
                      copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_REMOVE_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_REMOVE_CI_FILENAME, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to delete  %s/%s\n",
                      data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_CONNECT_CI_LOCATION:
          ERRload_struct (NFM, NFM_E_CONNECT_CI_LOCATION, "%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to connect to CI location\n"));
          break;
        case NFM_E_TLI_CONNECT_FS1:
          ERRload_struct (NFM, NFM_E_TLI_CONNECT_FS1, "%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "connect failed\n"));
          break;
        case NFM_E_TLI_SEND_FS1:
          ERRload_struct (NFM, NFM_E_TLI_SEND_FS1, "%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "buffer send failed\n"));
          break;
        case NFM_E_TLI_RECEIVE_SIZE_FS1:
          ERRload_struct (NFM, NFM_E_TLI_RECEIVE_SIZE_FS1, "%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "receive size failed\n"));
          break;
        case NFM_E_TLI_RECEIVE_FS1:
          ERRload_struct (NFM, NFM_E_TLI_RECEIVE_FS1, "%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[FTO_NODENAME], data[FTO_USERNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "buffer receive failed\n"));
          break;
        case NFM_E_FMU_DELETE_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FMU_DELETE_CI_FILENAME, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to delete %s/%s\n",
                         data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_UNAME_CI_LOCATION:
          ERRload_struct (NFM, NFM_E_UNAME_CI_LOCATION, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "uname failed for %s\n",
                          data[index+FTO_PATHNAME]));
          break;
        case NFM_E_UNLINK_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_UNLINK_CI_FILENAME, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to unlink %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_APPEND_FILEOLD:
          ERRload_struct (NFM, NFM_E_APPEND_FILEOLD, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "unable to append %s to %s\n",
                          data[index+FTO_FILEOLD], data[index+FTO_PATHNAME]));
          break;
        case NFM_E_NO_FILEOLD:
          ERRload_struct (NFM, NFM_E_NO_FILEOLD, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "%s/%s has 0 length\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_UNLINK_FILEOLD:
          ERRload_struct (NFM, NFM_E_UNLINK_FILEOLD, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to unlink %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_FOPEN_READ_FILEOLD:
          ERRload_struct (NFM, NFM_E_FOPEN_READ_FILEOLD, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fopen w /read  %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_FOPEN_WRITE_FILEOLD:
          ERRload_struct (NFM, NFM_E_FOPEN_WRITE_FILEOLD, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fopen w /write %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_STAT_FILEOLD:
          ERRload_struct (NFM, NFM_E_STAT_FILEOLD, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "stat failed for %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_FREAD_FILEOLD:
          ERRload_struct (NFM, NFM_E_FREAD_FILEOLD, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to read block  %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_FWRITE_FILEOLD:
          ERRload_struct (NFM, NFM_E_FWRITE_FILEOLD, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to write block %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_SET_UTIME_FILEOLD:
          ERRload_struct (NFM, NFM_E_SET_UTIME_FILEOLD, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to set time for %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_SET_CHMOD_FILEOLD:
          ERRload_struct (NFM, NFM_E_SET_CHMOD_FILEOLD, "%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD],
                          data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "stat failed for %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_SET_CHOWN_FILEOLD:
          ERRload_struct (NFM, NFM_E_SET_CHOWN_FILEOLD, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chown %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_BAD_SIZE_FILEOLD:
          ERRload_struct (NFM, NFM_E_BAD_SIZE_FILEOLD, "%s%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD],
                          data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "size %s does not match %s\n",
                          data[index+FTO_CIFILENAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_FTP_DELETE_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FTP_DELETE_CI_FILENAME, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to delete %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_FILEOLD]));
          break;
        case NFM_E_RENAME_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_RENAME_CI_FILENAME, "%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_COFILENAME],
                          data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to rename  %s/%s\n",
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_RENAME_APPEND_CI_FROM:
          ERRload_struct (NFM, NFM_E_RENAME_APPEND_CI_FROM, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to append %s to %s\n",
                           data[index+FTO_CIFILENAME],
                          data[index+FTO_PATHNAME]));
          break;
        case NFM_E_RENAME_APPEND_CI_TO:
          ERRload_struct (NFM, NFM_E_RENAME_APPEND_CI_TO, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to append %s to %s\n",
                           data[index+FTO_CIFILENAME],
                          data[index+FTO_PATHNAME]));
          break;
        case NFM_E_RENAME_NO_CI_FROM:
          ERRload_struct (NFM, NFM_E_RENAME_NO_CI_FROM, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "from file [%s] has 0 name length",
                           data[index+FTO_COFILENAME]));
          break;
        case NFM_E_RENAME_NO_CI_TO:
          ERRload_struct (NFM, NFM_E_RENAME_NO_CI_TO, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "to file  [%s] has 0 length \n",
                           data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_UNLINK_CI_FROM:
          ERRload_struct (NFM, NFM_E_UNLINK_CI_FROM, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to unlink %s/%s\n",
                           copath,
                           data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FOPEN_READ_CI_FROM:
          ERRload_struct (NFM, NFM_E_FOPEN_READ_CI_FROM, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fopen w /read  %s/%s\n",
                          copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FOPEN_WRITE_CI_FROM:
          ERRload_struct (NFM, NFM_E_FOPEN_WRITE_CI_FROM, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fopen w/write  %s/%s\n",
                          copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_STAT_CI_FROM:
          ERRload_struct (NFM, NFM_E_STAT_CI_FROM, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "stat failed  %s/%s\n",
                          copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FREAD_CI_FROM:
          ERRload_struct (NFM, NFM_E_FREAD_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to read block of source %s/%s\n",
                         copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_FWRITE_CI_FROM:
          ERRload_struct (NFM, NFM_E_FWRITE_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fwrite  %s/%s\n",
                         copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_SET_UTIME_CI_FROM:
          ERRload_struct (NFM, NFM_E_SET_UTIME_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to set time for  %s/%s\n",
                        copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_SET_CHMOD_CI_FROM:
          ERRload_struct (NFM, NFM_E_SET_CHMOD_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chmod for  %s/%s\n",
                        copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_SET_CHOWN_CI_FROM:
          ERRload_struct (NFM, NFM_E_SET_CHOWN_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chown for  %s/%s\n",
                        copath, data[index+FTO_COFILENAME]));
          break;
        case NFM_E_BAD_SIZE_CI_FROM:
          ERRload_struct (NFM, NFM_E_BAD_SIZE_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_COFILENAME],
                        data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "size %s != size %sn",
                        data[index+FTO_COFILENAME], 
                        data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_UNLINK_CI_TO:
          ERRload_struct (NFM, NFM_E_UNLINK_CI_TO, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to unlink %s/%s\n",
                           data[index+FTO_PATHNAME],
                           data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FOPEN_READ_CI_TO:
          ERRload_struct (NFM, NFM_E_FOPEN_READ_CI_FROM, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fopen w /read  %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FOPEN_WRITE_CI_TO:
          ERRload_struct (NFM, NFM_E_FOPEN_WRITE_CI_TO, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fopen w/write  %s/%s\n",
                         data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_STAT_CI_TO:
          ERRload_struct (NFM, NFM_E_STAT_CI_TO, "%s%s%s%s%s",
                          data[index+FTO_STATUS2],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "stat failed  %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FREAD_CI_TO:
          ERRload_struct (NFM, NFM_E_FREAD_CI_TO, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to read block of source %s/%s\n",
                         data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FWRITE_CI_TO:
          ERRload_struct (NFM, NFM_E_FWRITE_CI_TO, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to fwrite  %s/%s\n",
                         data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_SET_UTIME_CI_TO:
          ERRload_struct (NFM, NFM_E_SET_UTIME_CI_TO, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to set time for  %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_SET_CHMOD_CI_TO:
          ERRload_struct (NFM, NFM_E_SET_CHMOD_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chmod for  %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_SET_CHOWN_CI_TO:
          ERRload_struct (NFM, NFM_E_SET_CHOWN_CI_TO, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to chown for  %s/%s\n",
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_BAD_SIZE_CI_TO:
          ERRload_struct (NFM, NFM_E_BAD_SIZE_CI_FROM, "%s%s%s%s%s%s",
                         data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                        data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                        data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "size %s != size %sn",
                        data[index+FTO_COFILENAME], 
                        data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FTP_RENAME_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FTP_RENAME_CI_FILENAME, "%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_COFILENAME],
                          data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to rename %s\n", 
                      data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FMU_CONNECT_CI_LOCATION:
          ERRload_struct (NFM, NFM_E_FMU_CONNECT_CI_LOCATION, "%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PASSWD], data[index+FTO_PATHNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "connect failed for CI location  %s\n"));
          break;
        case NFM_E_FMU_RENAME_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_FMU_RENAME_CI_FILENAME, "%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_COFILENAME],
                          data[index+FTO_CIFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to rename %s\n", 
                      data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_CHANGE_COPY_ROW:
          ERRload_struct (NFM, NFM_E_CHANGE_COPY_ROW, "%s%s%s%s%s%s",
                          data[index+FTO_STATUS2], data[index+FTO_STATUS3],
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          copath, data[index+FTO_PATHNAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "Failed to change copy row \n"));
          break;
        case NFM_E_FMU_UNDO_RENAME_CI_FILENA:
          ERRload_struct (NFM, NFM_E_FMU_UNDO_RENAME_CI_FILENA, "%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                          data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to undo %s\n", 
                      data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_FTP_UNDO_RENAME_CI_FILENA:
          ERRload_struct (NFM, NFM_E_FTP_UNDO_RENAME_CI_FILENA, "%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                          data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to undo %s\n", 
                      data[index+FTO_CIFILENAME]));
          break;
        case NFM_E_UNDO_RENAME_CI_FILENAME:
          ERRload_struct (NFM, NFM_E_UNDO_RENAME_CI_FILENAME, "%s%s%s%s%s",
                          data[index+FTO_NODENAME], data[index+FTO_USERNAME],
                          data[index+FTO_PATHNAME], data[index+FTO_CIFILENAME],
                          data[index+FTO_COFILENAME]);
          NFMlog_message ();
          _NFMdebug ((fname, "failed to undo rename checkin %s\n", 
                      data[index+FTO_CIFILENAME]));
          break;
      }
    }
  }  

  if (fatal)
  {
    _NFMdebug ((fname, 
     "operation: %s, and fatal error occured %.8x\n",
                operation_str, ret_status));
    return (ret_status);
  }
 
  _NFMdebug ((fname, "EXIT 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
