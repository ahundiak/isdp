#include "NFMerrordef.h"
#include <stdio.h>
#include <sys/stat.h>
#include "PDUerror.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "MSGstruct.h"
#include "PDMproto.h"


#define NFM_TEMP_SIZE1 12

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern char   glob_var[100];


long PDMcopy_part_files (working_area, copy_bufr,success_bufr,failure_bufr )
/*** 
 
  This function will copy a given set of files.
  This is written for assembly structure, attach of a sub assembly, and
  attach of a atomic part.


    1/10/92 - Kumar 
***/
char *working_area;
MEMptr copy_bufr;
MEMptr success_bufr;
MEMptr failure_bufr;

{
  char *fname="PDMcopy_part_files";
  char sql_str[1024];
  char row_str[3048];
  char msg_str[512];
  char dumb_str[1];
  char **data, **file_data, **file_data1, **copy_data, **temp_data,**column_ptr;
  char **file_column;
  char filename[NFM_COFILENAME+1], answer[5];
  char nodename[NFM_NODENAME+1], username[NFM_USERNAME+1],
       passwd[NFM_PASSWD+1], pathname[NFM_PATHNAME+1],
       devicetype[NFM_DEVICETYPE+1], machid[NFM_MACHID+1],
       opsys[NFM_OPSYS+1], tcpip[NFM_TCPIP+1], xns[NFM_XNS+1],
       decnet[NFM_DECNET+1], netware[NFM_NETWARE+1],
       plattername [NFM_PLATTERNAME+1], partition[NFM_PARTITION+1],
       nfs[NFM_NFS+1], compress[NFM_COMPRESS+1];
  int x, y, z, nxi;
  int n1,n2,n3,n4,n5,n6,xi,i;
  int index;
  int i_catno, i_itemnum, i_type, i_fileno, i_filenum, i_fileversion,
      i_filetype, i_fileco, i_cifilename, i_cofilename,
      i_cisano, i_status1;
  long  sano = 0, sto_no;
  long status, status1, dumb_value, fmgr_status;
  MEMptr file_list = NULL, files_info = NULL ;
  MEMptr temp_list = NULL, list = NULL,fmgr_bufr = NULL ;
  struct NFMsto_info  *sto_list = NULL;
  struct NFMbuf_format *format;
  struct stat    file_status;


    temp_list = (MEMptr) NULL;
    list = (MEMptr) NULL;
  _PDMdebug ( fname, "ENTER: working_area[%s] \n", working_area);


  status = MEMbuild_array(copy_bufr);
  if(status != MEM_S_SUCCESS)
   {
    _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
    return (status);
    }
  copy_data = (char **)copy_bufr->data_ptr;
  column_ptr = (char **)copy_bufr->column_ptr;
        n1 = -1;
        n2 = -1;
        n3 = -1;
        n4 = -1;
        n5 = -1;
        n6 = -1;
   
      for(i=0; i < copy_bufr->columns; i++)
       {
                if (!strcmp(column_ptr[i], "n_catalogno"))
                        n1 = i;
                else if (!strcmp(column_ptr[i], "n_itemno"))
                        n2 = i;
                else if (!strcmp(column_ptr[i], "n_catalogname"))
                        n3 = i;
                else if (!strcmp(column_ptr[i], "n_itemname"))
                        n4 = i;
                else if (!strcmp(column_ptr[i], "n_itemrev"))
                        n5 = i;
                else if (!strcmp(column_ptr[i], "n_cofilename"))
                        n6 = i;
        } 
if (n1 == -1 || n2 == -1 ||
            n3 == -1 || n4 == -1 ||
            n5 == -1 || n6 == -1 ){
                _PDMdebug(fname, " %s %s \n",
                        "PDMcopy_part_files : ", "Failed to set offsets");
                return (PDM_E_BUFFER_FORMAT);
        }
  status = PDMstop_transaction (1200);
  if (status != PDM_S_SUCCESS)
  {
    _PDMdebug (fname, "PDMstop_transaction: 0x%.8x\n", status);
    return (status);
  }

PDMupdate_dots();
  /* get storage area information */

  status = NFMget_storage_info (working_area, &sano, nodename, username, passwd,
                                pathname, devicetype, plattername, partition,
                                nfs, compress, machid, opsys, tcpip,
                                xns, decnet, netware);
  if (status != NFM_S_SUCCESS)
  {
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status);
    return (status);
  }

PDMupdate_dots();
  status = MEMopen (&files_info, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
      return (status);
  }

  format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1,
                              NFM_TEMP_SIZE1 * sizeof (struct NFMbuf_format));
  if (!format)
  {
    MEMclose (&files_info);
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
    return (status);
  }

  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemnum");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_type");
  strcpy ((format+2)->data_type, "char(1)");
  strcpy ((format+3)->attr_name, "n_fileno");
  strcpy ((format+3)->data_type, "integer");
  strcpy ((format+4)->attr_name, "n_filenum");
  strcpy ((format+4)->data_type, "integer");
  strcpy ((format+5)->attr_name, "n_fileversion");
  strcpy ((format+5)->data_type, "integer");
  strcpy ((format+6)->attr_name, "n_filetype");
  strcpy ((format+6)->data_type, "char(5)");
  strcpy ((format+7)->attr_name, "n_fileco");
  strcpy ((format+7)->data_type, "char(1)");
  strcpy ((format+8)->attr_name, "n_cisano");
  strcpy ((format+8)->data_type, "integer");
  strcpy ((format+9)->attr_name, "n_cifilename");
  strcpy ((format+9)->data_type, "char(14)");
  strcpy ((format+10)->attr_name, "n_cofilename");
  strcpy ((format+10)->data_type, "char(14)");
  strcpy ((format+11)->attr_name, "n_status1");
  strcpy ((format+11)->data_type, "char(2)");

  status = _NFMbuild_working_buffer_format
                            (format, NFM_TEMP_SIZE1, files_info);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&files_info);
    PDMrollback_transaction (1200);
    free (format);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
    return (status);
  }

  status = PDMcreate_fmgr_bufr(&fmgr_bufr);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&files_info);
    MEMclose (&fmgr_bufr);
    PDMrollback_transaction (1200);
    free (format);
    _PDMdebug (fname, "MEMopen 0x%.8x\n", status);
    return (status);
  }

PDMupdate_dots();
  free (format);

  i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
  i_fileversion = 5; i_filetype = 6; i_fileco = 7; i_cisano = 8;
  i_cifilename = 9; i_cofilename = 10; i_status1 = 11;

    
  for (x = 0; x < copy_bufr->rows; x++ )
  {
      xi = x * copy_bufr->columns;
    /* prepare buffer for file transfer */

    _PDMdebug (fname,
              "prepare to retrieve the information from f_<%s>\n",
                                    copy_data[xi+n3]);
    sql_str[0] = '\0';
    sprintf (sql_str, "%s %s f_%s %s %s %s '%s' %s %s f_%s %s %s %s",
             "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
             "n_cisano, n_cifilename, n_cofilename from", 
             copy_data[xi+n3], 
             "where n_itemnum =", 
             copy_data[xi+n2], 
             "and n_cofilename = ",
             copy_data[xi+n6],"and n_fileversion =",
             "(select max(n_fileversion) from ", 
             copy_data[xi+n3], 
             "where n_itemnum =", 
             copy_data[xi+n2], ")");
    
    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                                 dumb_value, &list);
    if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fname, "Part %s %s of of catalog not found\n", copy_data[xi+n4],copy_data[xi+n5], copy_data[xi+n3]);
     MEMclose (&list);
           row_str[0] = '\0';
       sprintf(row_str,"%s\1%d\1",copy_data[xi+n6],PDM_E_PART_NOT_CHECKEDIN);
         status = MEMwrite(failure_bufr,row_str);
          if (status != MEM_S_SUCCESS)
    _PDMdebug (fname,"MEMwrite failes status %s\n",status);
       continue;
    }
    PDMupdate_dots();
   /* Validate for the view and checked in atleast once */
    status = PDMval_part_for_copy (copy_data[xi+n3], 
                                 atoi(copy_data[xi+n2]));
    if (status != PDM_S_SUCCESS)
    {
      _PDMdebug (fname, "Part %s %s of %s catalog not found\n", copy_data[xi+n4],copy_data[xi+n5], copy_data[xi+n3]);
     MEMclose (&list);
           row_str[0] = '\0';
        if(status == PDM_E_NO_VALID_VIEWS)
       sprintf(row_str,"%s\1%s\1",copy_data[xi+n6],"NO ORIGIN DEFINED");
       else
       sprintf(row_str,"%s\1%s\1",copy_data[xi+n6],"PART NOT CHECKED IN");
         status = MEMwrite(failure_bufr,row_str);
          if (status != MEM_S_SUCCESS)
    _PDMdebug (fname,"MEMwrite failes status %s\n",status);
       continue;
    }
    MEMbuild_array(list);
   file_data = (char **) list->data_ptr;
   fmgr_status = PDM_I_FILE_MOVE;

   fmgr_status = PDMcheck_fmgr_attach(sano,copy_data[xi+n6],atoi(copy_data[xi+n1]),atoi(copy_data[xi+n2]),atoi(file_data[1]),atoi(file_data[2]));
        _PDMdebug(fname,"FMGR status %d\n",status);
         if(fmgr_status == PDM_I_FILE_MOVE) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0] = '\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1] ,file_data[2],file_data[5],copy_data[xi+n6],  "MOVE");
        status = MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
            }
        else if(fmgr_status == PDM_I_REF_UPDATE) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0] = '\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1], copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6], "REF_UPDATE");
        status = MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
               MEMclose(&list);
      list = (MEMptr) NULL;
               continue;
            }
        else if(fmgr_status == PDM_I_CHECK_OUT) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0] = '\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6],  "CHECKOUT");
        status = MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
               MEMclose(&list);
      list = (MEMptr) NULL;
               continue;
            }
        else if(fmgr_status == PDM_I_VERSION_UPDATE) 
          {
              /* MEMwrite on to fmgr_bufr */
             sql_str[0] = '\0';
sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1", copy_data[xi+n1],  copy_data[xi+n2],file_data[1],file_data[2],file_data[5],copy_data[xi+n6],  "VERSION_UPDATE");
     status =   MEMwrite(fmgr_bufr,sql_str);
               if(status != MEM_S_SUCCESS)
                {
                MEMclose (&files_info);
                MEMclose (&fmgr_bufr);
                MEMclose (&list);
                PDMrollback_transaction (1200);
                 _PDMdebug (fname, "MEMerror 0x%.8x\n", status);
                return (status);
                }
            }
    _PDMdebug (fname, 
                "write the files information of this item to files_info\n");
  if((fmgr_status == PDM_I_VERSION_UPDATE) || (fmgr_status == PDM_I_FILE_MOVE))
  {
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;
      sprintf (row_str, "%s\1%s\1%s\1",
               copy_data[xi+n1], copy_data[xi+n2], "S");
      for (z = 0; z < list->columns; z ++)
      {
        strcat (row_str, file_data[index+z]);
        strcat (row_str, "\1");
      }
      strcat (row_str, "\1");
      _PDMdebug (fname, "row_str %s\n", row_str);
      status = MEMwrite (files_info, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
        MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
        PDMrollback_transaction (1200);
        return (status);
      }
    }
   }
    PDMupdate_dots();
    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      PDMrollback_transaction (1200);
      return (status);
    }
      list = (MEMptr) NULL;
  }

  if(files_info->rows > 0)
  {
  status = MEMbuild_array (files_info);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fname, "MEM_S_SUCCESS 0x%.8x\n", status);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    PDMrollback_transaction (1200);
    return (status);
  }
  if(PDMdebug_on)
       MEMprint_buffer("files_info",files_info,PDM_DEBUG_FILE);
  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMbuild_fto_buffer 0x%.8x\n", status);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    PDMrollback_transaction (1200);
    return (status);
  }
  
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
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    MEMclose (&file_list);
    PDMrollback_transaction (1200);
    return (status);
  }
   
  sto_list = (struct NFMsto_info *) calloc (files_info->rows,
                      (files_info->rows +1 ) * sizeof(struct NFMsto_info));

  if (!sto_list)
  {
    _NFMfree_linked_lists (sto_list, NULL);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    MEMclose (&file_list);
    _PDMdebug  (fname, "calloc sto_list failed\n") ;
    return (NFM_E_MALLOC);
  }

  sto_list->sano = sano;
  strcpy (sto_list->nodename, nodename);
  strcpy (sto_list->username, username);
  strcpy (sto_list->passwd, passwd);
  strcpy (sto_list->pathname, pathname);
  strcpy (sto_list->devicetype, devicetype);
  strcpy (sto_list->plattername, plattername);
  strcpy (sto_list->partition, partition);
  strcpy (sto_list->nfs, nfs);
  strcpy (sto_list->compress, compress);
  strcpy (sto_list->machid, machid);
  strcpy (sto_list->opsys, opsys);
  strcpy (sto_list->tcpip, tcpip);
  strcpy (sto_list->xns, xns);
  strcpy (sto_list->decnet, decnet);
  strcpy (sto_list->netware, netware);
  
  data = (char **) files_info->data_ptr;

    PDMupdate_dots();
  for (x = 0, sto_no = 1; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    _PDMdebug (fname, "data[index+i_cisano] = %s\n", 
                          data[index+i_cisano]);

    /* check to see if the cisano already on the list */

    for (y = 0; y < sto_no ; y++)
    {
      _PDMdebug  (fname, "(sto_list+%d)->sano: %d\n", y,
                  (sto_list+y)->sano);
      if ( (sto_list+y)->sano  == atol (data[index + i_cisano]) )
      {
        _PDMdebug (fname, "storage_area_no found in sto_list \n" );
        break;
      }
    }
    if (y >= sto_no)
    {
      _PDMdebug (fname, "n_cisano not found in the list, add to it \n");
      _PDMdebug (fname, "n_cisano %s add  \n", data[index+i_cisano]);
      (sto_list+sto_no)->sano  = atol (data[index+i_cisano]);
      sto_no++;
    }
  }


  /* at this point, I have a list of storage nos, so retrieve all the
     information from nfmstoragearea and nfmnodes table. */

  status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists (sto_list, NULL);
    MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
    MEMclose (&file_list);
    PDMrollback_transaction (1200);
    _PDMdebug (fname, "NFMget_storages_information 0x%.8x\n", status);
    return (status);
  }

    PDMupdate_dots();
  _PDMdebug (fname, "prepare file transfer buffer\n");
  for (x = 0; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
     sql_str[0] = '\0';
    sprintf (sql_str, 
               "%s %s %d %s '%s' %s %s %s %s %s %s ",
               "select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint,",
               "n_fileversion from nfmsafiles where n_sano =", sano, 
               "and n_filename =",
               data[index+i_cofilename], "and n_catalogno =", 
               data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
               "and n_filenum =", data[index+i_filenum]);

    status = SQLquery (sql_str, &temp_list, MEM_SIZE);
    if (status == SQL_S_SUCCESS)
    {
      status = MEMbuild_array (temp_list);
      if (status != MEM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, NULL);
        MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
        MEMclose (&file_list);
        MEMclose (&temp_list);
        PDMrollback_transaction (1200);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }

      temp_data = (char **) temp_list->data_ptr;
/*
      _PDMdebug (fname, "retrieved a row from LFM, co[%s] cp[%s] ref[%s]\n",
                  temp_data[i_co], temp_data[i_cp], temp_data[i_ref]);
*/
    }
    else if (status == SQL_I_NO_ROWS_FOUND)
    {
       /* add to the table */
    }
    else  
    {
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      MEMclose (&file_list);
      PDMrollback_transaction (1200);
      _PDMdebug (fname, "SQLquery 0x%.8x\n", status);
      return (status);
    }
    _PDMdebug (fname, "Try to find cisano [%s] in sto_list\n",
                data[index+i_cisano]);
    _PDMdebug (fname, "sto_no [%d] \n",sto_no);
    row_str[0] = '\0';
    for (y = 0; y < sto_no; y ++)
    {
      _PDMdebug (fname, "(sto_list+%d)->sano = %d\n",
                          y, (sto_list+y)->sano);
      if ((sto_list+y)->sano == atol (data[index+i_cisano]))
      {
        _PDMdebug (fname, "found match in sto_list\n");
        _PDMdebug (fname, "%d\n", (sto_list+y)->sano);
        _PDMdebug (fname, "%s\n", (sto_list+y)->nodename);
        _PDMdebug (fname, "%s\n", (sto_list+y)->username);
        _PDMdebug (fname, "%s\n", (sto_list+y)->passwd);
        _PDMdebug (fname, "%s\n", (sto_list+y)->pathname);
        _PDMdebug (fname, "%s\n", (sto_list+y)->devicetype);
        _PDMdebug (fname, "%s\n", (sto_list+y)->plattername);
        _PDMdebug (fname, "%s\n", (sto_list+y)->partition);
        _PDMdebug (fname, "%s\n", (sto_list+y)->nfs);
        _PDMdebug (fname, "%s\n", (sto_list+y)->compress);
        _PDMdebug (fname, "%s\n", (sto_list+y)->machid);
        _PDMdebug (fname, "%s\n", (sto_list+y)->opsys);
        _PDMdebug (fname, "%s\n", (sto_list+y)->tcpip);
        _PDMdebug (fname, "%s\n", (sto_list+y)->xns);
        _PDMdebug (fname, "%s\n", (sto_list+y)->decnet);
        _PDMdebug (fname, "%s\n", (sto_list+y)->netware);
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
        _PDMdebug (fname, "Row_str %s\n", row_str);
        break;
      }
    } 
    if (y >= sto_no)
    {
      _PDMdebug (fname, "check-in-to storage area incorrect\n");
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      PDMrollback_transaction (1200);
      return (status);
    }
    if (strlen (data[index+i_fileno]))
    {
    strcat (row_str, data[index+i_fileno]); 
     strcat (row_str, "\1");
      }
     else strcat (row_str, "\1");
    strcat (row_str, "\1"); /* n_fileold */
    if (strlen (data[index+i_cifilename]))
    {
      strcat (row_str, data[index+i_cifilename]);
     strcat (row_str, "\1");
    }
    else 
    {
      status = NFMnew_file_name (0, atol(data[index+i_catno]),
                                 atol(data[index+i_fileno]), filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, NULL);
        MEMclose (&files_info);
        MEMclose (&file_list);
      MEMclose (&fmgr_bufr);
        MEMclose (&temp_list);
        PDMrollback_transaction (1200);
        _PDMdebug (fname, "NFMget_file_name 0x%.8x\n", status);
        return (status);
      }
      strcat (row_str, filename); 
     strcat (row_str, "\1");
    } 
    if (strlen (data[index+i_cofilename]))
    {
  /* Added by kumar to check for the override of the local filename 
     4.3.93 */
     
   status1 = stat ( data[index+i_cofilename], &file_status );
  if (!status1)
    {
      _PDMdebug (fname, "File not known to PDM, but with the same filename as the file n_cofilename if found in cwd : <%s>\n", data[index+i_cofilename]);
      sprintf(msg_str,"Another <%s> is already local", data[index+i_cofilename]);
     UI_status (msg_str);
     sprintf(msg_str,"<%s> is not managed my PDM, overwrite (y/n)? [y]", data[index+i_cofilename]);
     UI_prompt (msg_str);
     strcpy(answer,"Y");
     do
       {
        status = PDUget_keyin(answer);

        if ((strlen(answer) > 0) &&
            (strcmp(answer,"y")) && 
            (strcmp(answer,"Y")) &&
            (strcmp(answer,"n")) &&
            (strcmp(answer,"N")))
            {
             status = PDM_E_INVALID_INPUT;
            }
       }
      while (status == PDM_E_INVALID_INPUT);
      UI_prompt ("");

      if(!strncmp(answer,"N", 1) || !strncmp(answer,"n",1)) 
        {
      _PDMdebug (fname, "Aborting command becuase of : <%s>\n", data[index+i_cofilename]);
        _NFMfree_linked_lists (sto_list, NULL);
        MEMclose (&files_info);
        MEMclose (&file_list);
      MEMclose (&fmgr_bufr);
        MEMclose (&temp_list);
        PDMrollback_transaction (1200);
        return(PDM_E_CMD_CANCELLED);
        }
    }
    strcat (row_str, data[index+i_cofilename]);
     strcat (row_str, "\1");
    }
     else  strcat (row_str, "\1");
    if (strlen (data[index+i_filetype]))
    {
    strcat (row_str, data[index+i_filetype]); 
     strcat (row_str, "\1");
    }
     else strcat (row_str, "\1");
    /* if (strlen (data[index+i_cifilesize]))
     strcat (row_str, data[index+i_cifilesize]);  
     else  */
          strcat (row_str, "100\1"); 
      strcat (row_str, "2033\1\1\1");

    _PDMdebug (fname, "row_str %s\n", row_str);
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fname, "MEMwrite 0x%.8x\n", status);
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      MEMclose (&file_list);
      PDMrollback_transaction (1200);
      return (status);
    }
  } /* prepare file transfer buffer */
if(PDMdebug_on)
{
MEMprint_buffer("file_list",file_list,PDM_DEBUG_FILE);
MEMprint_buffer("fmgr_bufr",fmgr_bufr,PDM_DEBUG_FILE);
 }

    PDMupdate_dots();
  status = _NFMfs_recv_files (&file_list);
  if (status != NFM_S_SUCCESS)
  {
      _PDMdebug (fname, "_NFMfs_recv_files 0x%.8x\n", status);
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&file_list);
      MEMclose (&fmgr_bufr);
      PDMrollback_transaction (1200);
      return (status);
  }

    PDMupdate_dots();
  } /* if there is any information in files_info */
  else
    {
    _PDMdebug (fname, "No files to move\n");
    }

  if(fmgr_bufr->rows > 0)
  {
  status = PDMupdate_fmgr_copy (sano,fmgr_bufr);
  if (status != PDM_S_SUCCESS)
   {
      _PDMdebug (fname, "PDMupdate_fmgr_copy 0x%.8x\n", status);
      _NFMfree_linked_lists (sto_list, NULL);
      MEMclose (&files_info);
      MEMclose (&fmgr_bufr);
      _NFMfs_undo_recv_files (&file_list);
      MEMclose (&file_list);
      PDMrollback_transaction (1200);
      return (status);
    }
    PDMupdate_dots();
   }
    if(PDMdebug_on)
    MEMprint_buffer("file_list",file_list,PDM_DEBUG_FILE);

    if(file_list != NULL)
    {
   status =  MEMbuild_array(file_list);
   if(status == MEM_S_SUCCESS)
    {
         file_data1 = (char **)file_list->data_ptr;
         file_column = (char **)file_list->column_ptr;
       
        for(i=0; i < file_list->columns; i++)
       {
                if (!strcmp(file_column[i], "n_cofilename")) n1 = i;
                else if (!strcmp(file_column[i], "n_status1")) n2 = i;
        }
      
       for(i=1; i < file_list->rows; i++)
          {
              nxi = i * file_list->columns;
               row_str[0] = '\0';
              if(atoi(file_data1[nxi+n2]) == 2035 || atoi(file_data1[nxi+n2]) == 2036)
              {
          sprintf(row_str,"%s\1%d\1",file_data1[nxi+n1],PDM_S_SUCCESS);
           MEMwrite(success_bufr,row_str);
               }
              else
               {
        sprintf(row_str,"%s\1%d\1",file_data1[nxi+n1],PDM_E_MOVE_FILE);
                  MEMwrite(failure_bufr,row_str);
                }
          }
       }
    }
               
  if(sto_list) status = _NFMfree_linked_lists (sto_list, NULL);
  if (status != NFM_S_SUCCESS)
    _PDMdebug (fname, "_NFMfree_linked_lists 0x%.8x\n", status);
 /*      
  if (file_list != NULL && files_info->rows > 0 && files_info->rows < 10000) status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS) _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
  if (files_info != NULL && files_info->rows  > 0 && files_info->rows < 10000) status = MEMclose (&files_info);
  if (status != MEM_S_SUCCESS) _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
 */
  if(fmgr_bufr != NULL && fmgr_bufr->rows > 0 && fmgr_bufr->rows < 10000) status =   MEMclose (&fmgr_bufr);
  if (status != MEM_S_SUCCESS) _PDMdebug (fname, "MEMclose 0x%.8x\n", status);

  status = PDMstart_transaction (1200);
  if (status != PDM_S_SUCCESS)
    _PDMdebug (fname, "PDMstart_transaction 0x%.8x\n", status);

    PDMupdate_dots();
  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}
