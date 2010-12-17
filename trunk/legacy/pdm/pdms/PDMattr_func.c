#include "NFMerrordef.h"
#include <stdio.h>
#include "PDUerror.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"
#include        <sys/types.h>
#include        <sys/stat.h>




#define NFM_TEMP_SIZE1 12



extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];

long PDMmap_attribute_functions (n_catalogname, working_area, functions )


/*** 
 
  This function will map attribute with functions during create catalog.
  The attribute functions will be ppl files of ems. These files are also to be
  moved during create catalog time.


    9/1/92 - Kumar 
***/
char  *n_catalogname;
char  *working_area;
MEMptr  functions;

{
  char *fname="PDMmap_attribute_functions";
  char row_str[3048];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char nodename1[NFM_NODENAME+1], username1[NFM_USERNAME+1],
       passwd1[NFM_PASSWD+1], pathname1[NFM_PATHNAME+1],
       devicetype1[NFM_DEVICETYPE+1], machid1[NFM_MACHID+1],
       opsys1[NFM_OPSYS+1], tcpip1[NFM_TCPIP+1], xns1[NFM_XNS+1],
       decnet1[NFM_DECNET+1], netware1[NFM_NETWARE+1],
       plattername1 [NFM_PLATTERNAME+1], partition1[NFM_PARTITION+1],
       nfs1[NFM_NFS+1], compress1[NFM_COMPRESS+1];
  long  sano = 0, sano1 = 0;
  long status;
  int  i, nxi;
  char  **func_data;
  MEMptr file_list = NULL;
  MEMptr delete_list = NULL;
  MEMptr function = NULL;
  struct stat file_status;
  char   func_file[NFM_PATHNAME+NFM_REPORTFILE+2];


  _PDMdebug ( fname, "ENTER: working_area[%s] \n", working_area);

    status = MEMbuild_array (functions);
     if(status != MEM_S_SUCCESS)
        {
            _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", 
                status);
             return (status);
         }

        if(functions->rows == 0)
            return(PDM_S_SUCCESS);
       
      func_data = (char **) functions->data_ptr;

  /* get to(checkin) storage area information */

  status = NFMget_storage_info ("PDM Functions", &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", "functionsslib",
                status);
    return (status);
  }

  /* get working storage area information */

  status = NFMget_storage_info(working_area, &sano1, nodename1, username1,
                     passwd1, pathname1, devicetype1, plattername1, partition1,
                         nfs1, compress1, machid1, opsys1, tcpip1,
                         xns1, decnet1, netware1);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status);
    return (status);
  }

  _PDMdebug (fname, "prepare file transfer buffer\n");

 status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
  } 
 status = NFMbuild_fto_buffer (&delete_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
    MEMclose (&file_list);
    MEMclose (&delete_list);
    return (status);
  } 

  row_str[0]='\0';
  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano,
  nodename, username, passwd, pathname, devicetype, plattername, partition,
  nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
  "\1\1\1\1\1\1\1\1\1");

  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
  }
   
    row_str[0]='\0';

/*
  sprintf (row_str, 
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1%\1100\12030\1\1\1", sano1, nodename1, username1, passwd1, pathname1, devicetype1, plattername1, partition1, nfs1, compress1, machid1, opsys1, tcpip1, xns1, decnet1, netware1,file_name,file_name);
 */

   for (i=0; i <  functions->rows; i++)

     {
        nxi = i * functions->columns;
       if(!strcmp(func_data[nxi+1],func_data[nxi+2])) 
          {
          func_file[0] = '\0';
          sprintf(func_file, "%s/%s", pathname1, func_data[nxi+1]);
             status = stat(func_file, &file_status);
             if (status == 0) /* file exists */
                {
                _PDMdebug(fname, "Update the function file %s\n", func_file);
                }
             else
                 {
            _PDMdebug(fname, "Update not neccessary for file %s\n", func_file);
                continue; 
                 }
           }
       if(strcmp(func_data[nxi+1],func_data[nxi+2]))
       {
      function = NULL;
     sprintf(row_str, "SELECT n_catalogname FROM  pdmfnattrmap  where n_catalogname != '%s' and n_filename = '%s'", n_catalogname, func_data[nxi+1]);
       status = SQLquery(row_str, &function,512);
           MEMclose(&function);
     if(status == SQL_I_NO_ROWS_FOUND)
     {
  sprintf (row_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1", sano, nodename, username, passwd, pathname, devicetype, plattername, partition, nfs, compress, machid, opsys, tcpip, xns, decnet, netware,func_data[nxi+1],func_data[nxi + 1]);
  _PDMdebug (fname, "MEMwrite %s\n", row_str);
     strcat(row_str,"\1");
      strcat(row_str,"100\1");
       strcat(row_str,"2044\1\1\1");
  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (delete_list, row_str);
  if (status != MEM_S_SUCCESS)
       {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    MEMclose (&delete_list);
    return (status);
        }
       }
      }
  sprintf (row_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1", sano1, nodename1, username1, passwd1, pathname1, devicetype1, plattername1, partition1, nfs1, compress1, machid1, opsys1, tcpip1, xns1, decnet1, netware1,func_data[nxi+2],func_data[nxi + 2]);
  _PDMdebug (fname, "MEMwrite %s\n", row_str);
     strcat(row_str,"\1");
      strcat(row_str,"100\1");
       strcat(row_str,"2030\1\1\1");
  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
   }

   }
if(PDMdebug_on)
{
MEMprint_buffer("file_list",file_list,PDM_DEBUG_FILE);
MEMprint_buffer("delete_list",delete_list,PDM_DEBUG_FILE);
 }

/* Move the file using NFMlistener */

  status = _NFMfs_recv_files (&file_list);
  if (status != NFM_S_SUCCESS)
  {
      _PDMdebug (fname, "_NFMfs_recv_files 0x%.8x\n", status);
      _NFMfs_undo_recv_files (&file_list);
      return (status);
  }


    status = NFMfs_chg_files (&delete_list);
    if (status != NFM_S_SUCCESS)
      _PDMdebug (fname, "NFMfs_chg_files 0x%.8x\n", status);


  for (i=0; i <  functions->rows; i++) {
   nxi = i * functions->columns;
   row_str [0] = '\0';
   strcpy(row_str, "");
    PDMconvert_to_lower(func_data[nxi], func_data[nxi]);
   sprintf (row_str, "UPDATE %s SET %s = '%s' WHERE %s = '%s' AND %s = '%s'",
                "pdmfnattrmap", "n_filename",
                func_data [nxi + 2], "n_catalogname", n_catalogname, "n_name",
                func_data[nxi]);

    _PDMdebug(fname, "update_str: %s\n",row_str);

    status = SQLstmt(row_str);
    if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
      _PDMdebug (fname, "SQLstmt 0x%.8x\n", status);
      _NFMfs_undo_recv_files (&file_list);
      return (status);
           }

    if (status == SQL_I_NO_ROWS_FOUND ) {
    sprintf(row_str, "insert into %s ( %s ) values ('%s', '%s', '%s')",
           "pdmfnattrmap", "n_catalogname, n_name, n_filename",
            n_catalogname, func_data[nxi], func_data[nxi+2]);
    _PDMdebug(fname, "update_str: %s\n",row_str);
    status = SQLstmt(row_str);
    if(status != SQL_S_SUCCESS) {
      _PDMdebug (fname, "SQLstmt 0x%.8x\n", status);
      _NFMfs_undo_recv_files (&file_list);
      return (status);
           }
        }
    }
  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
   _PDMdebug (fname, "MEMclose 0x%.8x\n", status);

  status = MEMclose (&delete_list);
  if (status != MEM_S_SUCCESS)
   _PDMdebug (fname, "MEMclose 0x%.8x\n", status);

  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", PDM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}


long PDMcopy_catalog_functions
(char *template_cat,
 char *target_cat
)
/*** 
 
  This function will map attribute with functions during create catalog.
  The attribute functions will be ppl files of ems. These files are also to be
  moved during create catalog time.


    9/1/92 - Kumar 
***/
{
  char *fname="PDMcopy_catalog_functions";
  char row_str[512];
  long status;
  int  i, nxi;
  char  **func_data;
  MEMptr functions = NULL;


  _PDMdebug ( fname, "ENTER:  \n");

        sprintf(row_str, "select n_name, n_filename from pdmfnattrmap where n_catalogname = '%s'", template_cat);
          _PDMdebug(fname,"SQLstmt: %s\n",row_str);
         status = SQLquery(row_str,&functions,512);
         if(status != SQL_S_SUCCESS)
          {
             if(status == SQL_I_NO_ROWS_FOUND)
               {
                 MEMclose(&functions);
            _PDMdebug (fname, "Exit - No functions to map \n"); 
                 return(PDM_S_SUCCESS);
               }
            _PDMdebug (fname, "SQLquery failed status 0x%.8x\n", 
                status);
             return (status);
          }
    status = MEMbuild_array (functions);
     if(status != MEM_S_SUCCESS)
        {
            _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", 
                status);
             return (status);
         }

        if(functions->rows == 0)
            return(PDM_S_SUCCESS);
       
      func_data = (char **) functions->data_ptr;

   for (i=0; i <  functions->rows; i++)

     {
        nxi = i * functions->columns;

strcpy(row_str, "");
        sprintf(row_str, "insert into pdmfnattrmap (n_catalogname, n_name, n_filename ) values ('%s', '%s', '%s')",
                          target_cat,
                          func_data[nxi], func_data[nxi+1]);

          _PDMdebug(fname,"SQLstmt: %s\n",row_str);
       status = SQLstmt(row_str);
        if(status != SQL_S_SUCCESS)
          {
      _PDMdebug (fname, "SQLstmt 0x%.8x\n", status);
      return (status);
           }
      
    }
  status = MEMclose (&functions);
  if (status != MEM_S_SUCCESS)
   _PDMdebug (fname, "MEMclose 0x%.8x\n", status);

  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", PDM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}

long PDMmove_functions (n_catalogname, working_area, functions )


/*** 
 
  This function will move all attribute functions during add part time.
  The attribute functions will be ppl files of ems. 


    9/1/92 - Kumar 
***/
char  *n_catalogname;
char  *working_area;
MEMptr  *functions;

{
  char *fname="PDMmove_functions";
  char row_str[3048];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  char nodename1[NFM_NODENAME+1], username1[NFM_USERNAME+1],
       passwd1[NFM_PASSWD+1], pathname1[NFM_PATHNAME+1],
       devicetype1[NFM_DEVICETYPE+1], machid1[NFM_MACHID+1],
       opsys1[NFM_OPSYS+1], tcpip1[NFM_TCPIP+1], xns1[NFM_XNS+1],
       decnet1[NFM_DECNET+1], netware1[NFM_NETWARE+1],
       plattername1 [NFM_PLATTERNAME+1], partition1[NFM_PARTITION+1],
       nfs1[NFM_NFS+1], compress1[NFM_COMPRESS+1];
  long  sano = 0, sano1 = 0;
  long status;
  int  i, nxi=0;
  char  **func_data;
  MEMptr file_list = NULL;


  _PDMdebug ( fname, "ENTER: working_area[%s] \n", working_area);


strcpy(row_str, "");
        sprintf(row_str, "SELECT n_name , n_filename FROM  pdmfnattrmap  where n_catalogname = '%s'",
                          n_catalogname);

          *functions = NULL;

          _PDMdebug(fname,"SQLstmt: %s\n",row_str);
       status = SQLquery(row_str, functions,512);
        if(status != SQL_S_SUCCESS)
          {
      _PDMdebug (fname, "SQLstmt 0x%.8x\n", status);
           if(status == SQL_I_NO_ROWS_FOUND)
             {
                MEMclose(functions); *functions = NULL;
                return(PDM_S_SUCCESS);
             }
      return (status);
           }

if(PDMdebug_on)
{
MEMprint_buffer("functions",*functions,PDM_DEBUG_FILE);
 }
    status = MEMbuild_array (*functions);
     if(status != MEM_S_SUCCESS)
        {
            _PDMdebug (fname, "functions-MEMbuild_array 0x%.8x\n", 
                status);
             return (status);
         }

        if((*functions)->rows == 0)
            return(PDM_S_SUCCESS);
       
      func_data = (char **) (*functions)->data_ptr;

  /* get working storage area information */

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", "functionsslib",
                status);
    return (status);
  }

  /* get PDM Functions storage area information */

  status = NFMget_storage_info("PDM Functions", &sano1, nodename1, username1,
                     passwd1, pathname1, devicetype1, plattername1, partition1,
                         nfs1, compress1, machid1, opsys1, tcpip1,
                         xns1, decnet1, netware1);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status);
    return (status);
  }

  _PDMdebug (fname, "prepare file transfer buffer\n");

 status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
  } 

    row_str[0]='\0';
  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano,
  nodename, username, passwd, pathname, devicetype, plattername, partition,
  nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
  "\1\1\1\1\1\1\1\1\1");

  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
  }
   
    row_str[0]='\0';

/*
  sprintf (row_str, 
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1%\1100\12030\1\1\1", sano1, nodename1, username1, passwd1, pathname1, devicetype1, plattername1, partition1, nfs1, compress1, machid1, opsys1, tcpip1, xns1, decnet1, netware1,file_name,file_name);
 */

   for (i=0; i <  (*functions)->rows; i++)

     {
        nxi = i * (*functions)->columns;

  sprintf (row_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1", sano1, nodename1, username1, passwd1, pathname1, devicetype1, plattername1, partition1, nfs1, compress1, machid1, opsys1, tcpip1, xns1, decnet1, netware1,func_data[nxi+1],func_data[nxi + 1]);
  _PDMdebug (fname, "MEMwrite %s\n", row_str);
     strcat(row_str,"\1");
      strcat(row_str,"100\1");
       strcat(row_str,"2030\1\1\1");
  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
   }

   }
if(PDMdebug_on)
{
MEMprint_buffer("file_list",file_list,PDM_DEBUG_FILE);
 }

/* Move the file using NFMlistener */

  status = _NFMfs_recv_files (&file_list);
  if (status != NFM_S_SUCCESS)
  {
      _PDMdebug (fname, "_NFMfs_recv_files 0x%.8x\n", status);
      _NFMfs_undo_recv_files (&file_list);
      return (status);
  }

  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
    _PDMdebug (fname, "MEMclose 0x%.8x\n", status);

  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", PDM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}

long PDMdelete_functions (n_catalogname, working_area )


/*** 
 
  This function will delete all attribute functions for a given
  catalog during delete catalog time.
  The attribute functions will be ppl files of ems. 


    9/1/92 - Kumar 
***/
char  *n_catalogname;
char  *working_area;

{
  char *fname="PDMdelete_functions";
  char row_str[3048];
  /*
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
 */
  char nodename1[NFM_NODENAME+1], username1[NFM_USERNAME+1],
       passwd1[NFM_PASSWD+1], pathname1[NFM_PATHNAME+1],
       devicetype1[NFM_DEVICETYPE+1], machid1[NFM_MACHID+1],
       opsys1[NFM_OPSYS+1], tcpip1[NFM_TCPIP+1], xns1[NFM_XNS+1],
       decnet1[NFM_DECNET+1], netware1[NFM_NETWARE+1],
       plattername1 [NFM_PLATTERNAME+1], partition1[NFM_PARTITION+1],
       nfs1[NFM_NFS+1], compress1[NFM_COMPRESS+1];
  long  sano1 = 0;
  long status;
  int  i, nxi=0;
  char  **func_data;
  MEMptr file_list = NULL, functions = NULL, function = NULL;


  _PDMdebug ( fname, "ENTER: working_area[%s] \n", working_area);


          functions = NULL;
      row_str[0] = '\0';
     sprintf(row_str, "SELECT n_name , n_filename FROM  pdmfnattrmap  where n_catalogname = '%s'", n_catalogname);
       status = SQLquery(row_str, &functions,512);
        if(status != SQL_S_SUCCESS)
          {
      _PDMdebug (fname, "SQLstmt 0x%.8x\n", status);
           if(status == SQL_I_NO_ROWS_FOUND)
             {
                MEMclose(&functions); functions = NULL;
                return(PDM_S_SUCCESS);
             }
      return (status);
         }

if(PDMdebug_on)
MEMprint_buffer("functions",functions,PDM_DEBUG_FILE);
    status = MEMbuild_array (functions);
     if(status != MEM_S_SUCCESS)
        {
            _PDMdebug (fname, "functions-MEMbuild_array 0x%.8x\n", 
                status);
             return (status);
         }

        if((functions)->rows == 0)
            return(PDM_S_SUCCESS);
       
      func_data = (char **) (functions)->data_ptr;

  /* get working storage area information 

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", "functionsslib",
                status);
    return (status);
  }
  */

  /* get PDM Functions storage area information */

  status = NFMget_storage_info("PDM Functions", &sano1, nodename1, username1,
                     passwd1, pathname1, devicetype1, plattername1, partition1,
                         nfs1, compress1, machid1, opsys1, tcpip1,
                         xns1, decnet1, netware1);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status);
    return (status);
  }

  _PDMdebug (fname, "prepare file transfer buffer\n");

 status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
  } 

  /*
    row_str[0]='\0';
  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sano,
  nodename, username, passwd, pathname, devicetype, plattername, partition,
  nfs, compress, machid, opsys, tcpip, xns, decnet, netware,
  "\1\1\1\1\1\1\1\1\1");

  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
  }
  */ 
    row_str[0]='\0';

/*
  sprintf (row_str, 
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1%\1100\12030\1\1\1", sano1, nodename1, username1, passwd1, pathname1, devicetype1, plattername1, partition1, nfs1, compress1, machid1, opsys1, tcpip1, xns1, decnet1, netware1,file_name,file_name);
 */

   for (i=0; i <  (functions)->rows; i++)
     {
      row_str[0] = '\0';
      function = NULL;
     sprintf(row_str, "SELECT n_catalogname , n_name FROM  pdmfnattrmap  where n_catalogname != '%s' and n_filename = '%s'", n_catalogname, func_data[nxi+1]);
       status = SQLquery(row_str, &function,512);
        if(status == SQL_S_SUCCESS)
          {
           MEMclose(&function);
   _PDMdebug (fname, "Function file %s used in catalog \n", func_data[nxi +1]);
          continue;
          }
          MEMclose(&function);
        nxi = i * (functions)->columns;

  sprintf (row_str, "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1", sano1, nodename1, username1, passwd1, pathname1, devicetype1, plattername1, partition1, nfs1, compress1, machid1, opsys1, tcpip1, xns1, decnet1, netware1,func_data[nxi+1],func_data[nxi + 1]);
  _PDMdebug (fname, "MEMwrite %s\n", row_str);
     strcat(row_str,"\1");
      strcat(row_str,"100\1");
       strcat(row_str,"2044\1\1\1");
  _PDMdebug (fname, "MEMwrite %s\n", row_str);

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
    MEMclose (&file_list);
    return (status);
   }

   }
if(PDMdebug_on)
{
MEMprint_buffer("file_list",file_list,PDM_DEBUG_FILE);
 }

/* Move the file using NFMlistener */

status = NFMfs_chg_files (&file_list);
    if (status != NFM_S_SUCCESS)
      _PDMdebug (fname, "NFMfs_chg_files 0x%.8x\n", status);

  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
    _PDMdebug (fname, "MEMclose 0x%.8x\n", status);

  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", PDM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}

long PDMquery_attribute_functions(char *n_catalogname, MEMptr *functions)
{
long status;
char row_str[512];
char *fname = "PDMquery_attribute_functions";

      _PDMdebug(fname,"Enter");
     sprintf(row_str, "SELECT n_name, n_filename,n_filename FROM  pdmfnattrmap  where n_catalogname = '%s'", n_catalogname);

       *functions = NULL;
      _PDMdebug(fname,"SQLstmt: %s\n",row_str);
      status = SQLquery(row_str, functions,512);
      if(status != SQL_S_SUCCESS)
      {
      _PDMdebug (fname, "SQLstmt 0x%.8x\n", status);
      if(status == SQL_I_NO_ROWS_FOUND)
         {
           MEMclose(functions); *functions = NULL;
           return(PDM_S_SUCCESS);
         }
      return (status);
      }
      _PDMdebug(fname,"Exit");
      return(PDM_S_SUCCESS);
}
