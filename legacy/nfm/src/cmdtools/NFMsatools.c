#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "NFMitems.h"


long NFMget_storage_info (sa_name, sa_no, nodename, username, passwd, pathname,
                          devicetype, plattername, partition, nfs, compress,
                          machid, opsys, tcpip, xns, decnet, netware)

/***
  This function will retrieve the information from nfmstoragearea and
  nfmnodes table based on sa_name or sa_no.(use this function to retrieve
  information of a storage AREA)

  Notes: all the output variables need to have memory alocated from
  calling function.


***/

char *sa_name;  /* I/O: Storage area name. If not given, information will be
                        retrieved based on sa_no, and sa_name will be filled
                        with the data from database */
long *sa_no;    /* I/O: Storage area number. If not given, information will be
                        retrieved based on sa_name, and sa_no will be filled
                        with the data from database */
char *nodename; /* O: */ 
char *username; /* O: */
char *passwd; /* O: */
char *pathname; /* O: */
char *devicetype; /* O: */
char *plattername; /* O: */
char *partition; /* O: */
char *nfs; /* O: */
char *compress; /* O: */
char *machid; /* O: */
char *opsys; /* O: */
char *tcpip; /* O: */
char *xns; /* O: */
char *decnet; /* O: */
char *netware; /* O: */

{
  char *fname="NFMget_storage_info";
  char sql_str[1024];
  char **data;
  char temp_str[10];
  long status;
  MEMptr list=NULL;
 
  _NFMdebug ((fname, "ENTER: sa_name[%s] sa_no[%d]\n", sa_name, *sa_no));

  if (*sa_no > 0)
  {
    sprintf (sql_str, "%s %s %s %s %s %d",
            "select n_saname, n_username, n_passwd, n_pathname, ",
            "n_devicetype, n_plattername, n_partition, nfmstoragearea.n_nfs,", 
            "n_compress, n_nodename, n_machid, n_opsys, n_xns, n_tcpip,",
            "n_decnet, n_netware from nfmstoragearea, nfmnodes where",
            "nfmstoragearea.n_nodeno = nfmnodes.n_nodeno and n_sano = ",
            *sa_no);
  }
  else if (strlen (sa_name))
  {
    sprintf (sql_str, "%s %s %s %s %s '%s'",
            "select n_sano, n_username, n_passwd, n_pathname, ",
            "n_devicetype, n_plattername, n_partition, nfmstoragearea.n_nfs,", 
            "n_compress, n_nodename, n_machid, n_opsys, n_xns, n_tcpip,",
            "n_decnet, n_netware from nfmstoragearea, nfmnodes where",
            "nfmstoragearea.n_nodeno = nfmnodes.n_nodeno and n_saname = ",
            sa_name);
  }
  else
  {
    _NFMdebug ((fname, "Invalid input in sa_name[%s] and sa_no[%d]\n",
                sa_name, sa_no));
    ERRload_struct (NFM, NFM_E_INCOMPLETE_INFORMATION, "%s%s",
                    "get storage area information", 
                    "storage area name and/or number");
    return (NFM_E_INCOMPLETE_INFORMATION);
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      sprintf (temp_str, "%d", *sa_no);
      ERRload_struct (NFM, NFM_E_NO_SA, "%s",
                      (*sa_no > 0 ? temp_str: sa_name));
      return (NFM_E_NO_SA);
    }
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL); 
    return (NFM_E_SQL_QUERY);
  }
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMbuild_array (storage information) 0x%.8x\n",status));
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;
  if (*sa_no < 1)
  {
    *sa_no = atol (data[0]);
  }
  else
  {
    strcpy (sa_name, data[0]);
  }
  strcpy (username, data[1]);
  strcpy (passwd, data[2]);
  strcpy (pathname, data[3]);
  strcpy (devicetype, data[4]);
  strcpy (plattername, data[5]);
  strcpy (partition, data[6]);
  strcpy (nfs, data[7]);
  strcpy (compress, data[8]);

  strcpy (nodename, data[9]);
  strcpy (machid, data[10]);
  strcpy (opsys, data[11]);
  strcpy (xns, data[12]);
  strcpy (tcpip, data[13]);
  strcpy (decnet, data[14]);  
  strcpy (netware, data[15]);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose  0x%.8x\n",status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }
  
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n\
              saname [%s] sano [%d] username [%s]\n\
              pathname[%s] nodename [%s]\n", 
              NFM_S_SUCCESS, sa_name, *sa_no, username, pathname, nodename ));
  return (NFM_S_SUCCESS);
}

long NFMget_storages_information (sto_list, sto_no, type)

/***
  This function will retrieve the information from nfmstoragearea and
  nfmnodes table based on sa_name or sa_no. (use this function to retrieve
  information for storage AREAS)

  Note: make sure sto_list is initialized to NULL. Every entry in sto_list
        has to be unique, i.e. no duplicate sanames or sanos.


***/

struct NFMsto_info *sto_list;
long sto_no;
long type; /* I: 0: based on storage area names,
                 1: based on storage area numbers */ 
                

{
  char *fname="NFMget_storages_information";
  char temp_str[10];
  char sql_str[1024];
  char **data;
  int x, y, or, index;
  long status;
  MEMptr list=NULL;
  long _NFMprint_storages_information ();
 
  _NFMdebug ((fname, "ENTER: retrieve <= %d storage areas info, type = %d\n",
              sto_no, type));
  if (sto_no < 1)
  {
    _NFMdebug ((fname, 
                "EXIT: there is not ANY storage information to retrieve\n"));
    return (NFM_S_SUCCESS); /* COME BACK AND CHANGE TO
                               NFM_I_NOTHING_TO_RETRIEVE */
  }

  if (type)
  {
    sprintf (sql_str, "%s %s %s %s %s %s",
            "select n_sano, n_saname, n_username, n_passwd,",
            "n_pathname, n_devicetype, n_plattername, n_partition,",
            "nfmstoragearea.n_nfs,", 
            "n_compress, n_nodename, n_machid, n_opsys, n_xns, n_tcpip,",
            "n_decnet, n_netware from nfmstoragearea, nfmnodes where ",
            "(nfmstoragearea.n_nodeno = nfmnodes.n_nodeno) and (");
    for (x = 0, or = 0; x < sto_no; x++)
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_sano =");
      sprintf (temp_str, "%d", (sto_list+x)->sano);
      strcat (sql_str, temp_str);
    }
    strcat (sql_str, ")");
  }
  else 
  {
    sprintf (sql_str, "%s %s %s %s %s %s",
            "select n_sano, n_saname, n_username, n_passwd,",
            "n_pathname, n_devicetype, n_plattername, n_partition,",
            "nfmstoragearea.n_nfs,", 
            "n_compress, n_nodename, n_machid, n_opsys, n_xns, n_tcpip,",
            "n_decnet, n_netware from nfmstoragearea, nfmnodes where",
            "(nfmstoragearea.n_nodeno = nfmnodes.n_nodeno) and (");
    for (x = 0, or = 0; x < sto_no; x++)
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_saname = '");
      strcat (sql_str, (sto_list+x)->saname);
      strcat (sql_str, "'");
    }
    strcat (sql_str, ")");
  }

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to get storage area information");
    return (NFM_E_MESSAGE);
  }
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ((fname, "MEMbuild_array (storage information) 0x%.8x\n",status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }
 
  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x++)
  {
    index = list->columns * x;
    for (y = 0; y < sto_no; y ++)
    {
      if ( (atol (data[index]) == (sto_list+y)->sano) ||
           !strcmp(data[index+1], (sto_list+y)->saname)    )
          break;
    }
    (sto_list+y)->sano = atol (data[index+0]);
    strcpy ((sto_list+y)->saname, data[index+1]);
    strcpy ((sto_list+y)->username, data[index+2]);
    strcpy ((sto_list+y)->passwd, data[index+3]);
    strcpy ((sto_list+y)->pathname, data[index+4]);
    strcpy ((sto_list+y)->devicetype, data[index+5]);
    strcpy ((sto_list+y)->plattername, data[index+6]);
    strcpy ((sto_list+y)->partition, data[index+7]);
    strcpy ((sto_list+y)->nfs, data[index+8]);
    strcpy ((sto_list+y)->compress, data[index+9]);

    strcpy ((sto_list+y)->nodename, data[index+10]);
    strcpy ((sto_list+y)->machid, data[index+11]);
    strcpy ((sto_list+y)->opsys, data[index+12]);
    strcpy ((sto_list+y)->xns, data[index+13]);
    strcpy ((sto_list+y)->tcpip, data[index+14]);
    strcpy ((sto_list+y)->decnet, data[index+15]);  
    strcpy ((sto_list+y)->netware, data[index+16]);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose (info from nfmstoragearea) 0x%.8x\n",status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  if (_NFMdebug_st.NFMdebug_on)
    _NFMprint_storages_information (sto_list, sto_no);
  
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long _NFMprint_storages_information (sto_list, sto_no)

/***

***/

struct NFMsto_info *sto_list;
long sto_no;

{

  char *fname="_NFMprint_storages_information";
  int x;
 
  _NFMdebug ((fname, "ENTER: print out  %d storage areas info\n", sto_no));

  for (x = 0; x < sto_no; x++)
  {
    _NFMdebug ((fname, "*** (sto_list+x)->sano = %d, \n\
                       (sto_list+x)->saname = %s,  \n\
                       (sto_list+x)->username = %s,  \n\
                       (sto_list+x)->passwd = %s,  \n\
                       (sto_list+x)->pathname = %s,  \n\
                       (sto_list+x)->devicetype = %s, \n\
                       (sto_list+x)->plattername = %s, \n\
                       (sto_list+x)->partition = %s,  \n\
                       (sto_list+x)->nfs = %s,  \n\
                       (sto_list+x)->compress = %s, \n\
                       (sto_list+x)->nodename = %s, \n\
                       (sto_list+x)->machid = %s, \n\
                       (sto_list+x)->opsys = %s, \n\
                       (sto_list+x)->xns = %s,  \n\
                       (sto_list+x)->tcpip = %s, \n\
                       (sto_list+x)->decnet = %s, \n\
                       (sto_list+x)->netware = %s ******* \n",
    (sto_list+x)->sano,
    (sto_list+x)->saname, 
    (sto_list+x)->username, 
    (sto_list+x)->passwd, 
    (sto_list+x)->pathname, 
    (sto_list+x)->devicetype,
    (sto_list+x)->plattername,
    (sto_list+x)->partition, 
    (sto_list+x)->nfs, 
    (sto_list+x)->compress,

    (sto_list+x)->nodename,
    (sto_list+x)->machid,
    (sto_list+x)->opsys,
    (sto_list+x)->xns, 
    (sto_list+x)->tcpip,
    (sto_list+x)->decnet,
    (sto_list+x)->netware))

  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
