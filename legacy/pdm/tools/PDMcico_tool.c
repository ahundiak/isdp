#include                <stdio.h>
#include                <sys/types.h>
#include                <sys/times.h>
#include                "NFMstruct.h"
#include                "MSGstruct.h"
#include                "ERR.h"
#include                "PDUerror.h"
#include                "MEMstruct.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "SQLerrordef.h"
#include                "PDUris_incl.h"
#include                "NFMfile.h"
#include                "NFMfto_buf.h"
#include                "PDUstorage.h"
#include                "ERR.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"
#include                "PDUnode.h"
#include                "PDMmessage.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
static long     status;
static char     s[1024];
extern char   glob_var[100];
extern struct PDUstorage *storage;
extern struct NFMglobal_st NFMglobal;
extern struct sto_area_info STO_info;

/* additional declarations for NFM3.0 */
#include                "NFMschema.h"
#include                "NFMapi.h"
#include                "WFexterns.h"
struct NFMwf_info  PDMwf_info;
struct NFMoperation  *PDMoperation, *PDMlast_oper;

char glob_var[100];   /* ALR moved here from PDMsettools.c for API's */

PDMi_prepare_buffer1(attach_bufr)
	MEMptr         *attach_bufr;
{
	char            max_dtype[40];

	/* create the buffer */

	status = MEMopen(attach_bufr, 1024);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	status = PDMi_find_maxdatatype("n_catalogname", max_dtype);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_maxdatatype failed status %d\n",
			status);
		PDMdebug(s);
	}
	status = MEMwrite_format(*attach_bufr, "n_catalogname", max_dtype);
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = PDMi_find_maxdatatype("n_itemname", max_dtype);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_maxdatatype failed status %d\n",
			status);
		PDMdebug(s);
	}
	status = MEMwrite_format(*attach_bufr, "n_itemname", max_dtype);
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = PDMi_find_maxdatatype("p_partrev", max_dtype);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_find_maxdatatype failed status %d\n",
			status);
		PDMdebug(s);
	}
	status = MEMwrite_format(*attach_bufr, "n_itemrev", max_dtype);
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(*attach_bufr, "p_seqno", "integer");
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(*attach_bufr, "n_cofilename", "char(14)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(*attach_bufr, "p_parttype", "char(2)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(*attach_bufr, "n_citno", "integer");
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		MEMclose(attach_bufr);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(*attach_bufr, "n_fileco", "char(1)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	status = MEMwrite_format(*attach_bufr, "p_level", "integer");
	if (status != MEM_S_SUCCESS) {
		MEMclose(attach_bufr);
		sprintf(s, "MEMwrite_format failed status %d\n",
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	return (PDM_S_SUCCESS);
}

int PDMXXsa_info (sa_no)
int sa_no;
{
  /***
  This function queries the storage area information given the
  storage no, and stores in the global structure. (the name of the global
  variable should probably be changed to something generic.)

  CHANGE HISTORY:
    09/10/91
  ***/

  MEMptr  list = NULL;
  char    sql_str [1024];
  char    **data;

    PDMdebug ("ENTER: PDMXXsa_info\n" );

  sprintf (sql_str, 
 "%s %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s %s WHERE %s = %d %s", 
  "SELECT", 
  "NFMSTORAGEAREA.n_sano", 
  "NFMNODES.n_nodename", 
  "NFMSTORAGEAREA.n_username", 
  "NFMSTORAGEAREA.n_passwd", 
  "NFMSTORAGEAREA.n_pathname", 
  "NFMSTORAGEAREA.n_devicetype", 
  "NFMNODES.n_machid", 
  "NFMNODES.n_opsys", 
  "NFMNODES.n_tcpip", 
  "NFMNODES.n_xns", 
  "NFMNODES.n_decnet", 
  "FROM NFMSTORAGEAREA, NFMNODES", 
  "NFMSTORAGEAREA.n_sano", sa_no, 
  "AND NFMSTORAGEAREA.n_nodeno = NFMNODES.n_nodeno");

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if ((status) == SQL_I_NO_ROWS_FOUND)
    {
      sprintf (s, "PDMXXsa_info  : Bad Storage = <0x%.8x>\n", 
      NFM_E_BAD_ST_AREA);
      PDMdebug (s);
      return (NFM_E_BAD_ST_AREA);
    }
    sprintf (s, "PDMXXsa_info : Query Syntax  <0x%.8x>\n", 
    NFM_E_BAD_ST_AREA);
    PDMdebug (s);
    return ( NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    sprintf (s, "PDMXXsa_info : MEMbuild_array (list) <0x%.8x> ", NFM_E_MEM);
    PDMdebug (s);
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;
  STO_info.sano  = atol (data[0]);
  strcpy (STO_info.nodename, data[1]);
  strcpy (STO_info.username, data[2]);
  strcpy (STO_info.passwd, data[3]);
  strcpy (STO_info.pathname, data[4]);
  strcpy (STO_info.devicetype, data[5]);
  strcpy (STO_info.machid, data[6]);
  strcpy (STO_info.opsys, data[7]);
  strcpy (STO_info.tcpip, data[8]);
  strcpy (STO_info.xns, data[9]);
  strcpy (STO_info.decnet, data[10]);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    sprintf (s, "PDMXXsa_info :MEMclose (list): <0x%.8x>", status);
    PDMdebug (s);
    return (status);
  }

    PDMdebug ("EXIT: PDMXXsa_info\n" );
  return (NFM_S_SUCCESS);
}



int PDMget_file_list(user_id, catalog, partnum, revision, list)
long   user_id;
char   *catalog;
char   *partnum;
char   *revision;
MEMptr *list;
{
  char   write[500];
  char   node_name[50], user_name[50], passwd[50];
  char   path_name[50], device_type[10], mach_id[20];
  char   net_xns[10], net_tcp[10], op_sys[10], net_dec[10];
  static char *fn = "PDMget_file_list:";

    PDMdebug("ENTER: PDMget_file_list\n");

/* ANSI */
     catalog = NULL;
     partnum = NULL;
     revision = NULL;

     status = MEMopen (list, 512);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_catalogno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_itemno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_fileno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_sano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_nodename", "char(30)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_username", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_passwd", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_pathname", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_devicetype", "char(2)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_machid", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_opsys", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_tcpip", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_xns", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_decnet", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilename", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_filetype", "char(15)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilesize", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_status", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
      status = NFMget_sa_no_info(user_id, PDMpart.n_cisano, node_name, 
               user_name, passwd, path_name, device_type, mach_id, op_sys, 
               net_tcp, net_xns, net_dec);
         if(status != NFM_S_SUCCESS)
        {
         sprintf(s, "NFMget_sa_no_info failed status %d\n", status);
         PDMdebug(s);
         MEMclose(&list);
         return(PDM_E_BAD_STRG);
        } 
            
    sprintf(write, "%d\1%d\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1", PDMpart.n_catalogno, PDMpart.n_itemno, PDMpart.n_fileno, PDMpart.n_cisano, node_name, user_name, passwd, path_name, device_type, mach_id, op_sys, net_tcp, net_xns, net_dec, PDMpart.n_cifilename, PDMpart.n_cofilename, "", -1, "move");

       status = MEMwrite(*list, write);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr  : status = <0x%.8x>\n", status);
        return (status);
       }
      if(PDMdebug_on)
        MEMprint_buffer("list buffer", *list, PDM_DEBUG_FILE);

    

    PDMdebug("EXIT: PDMget_file_list\n");
       return(PDM_S_SUCCESS);


}


int PDMmake_data_buffer(list)
MEMptr *list;
{

  static char *fn = "PDMmake_data_buffer:";

    PDMdebug("ENTER: PDMmake_data_buffer\n");
     status = MEMopen (list, 512);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_catalogname", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_level", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_citno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_status", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_type", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_itemno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_itemname", "char(40)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_itemrev", "char(40)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_setindicator", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_status", "char(2)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_colevel", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_itemnum", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_fileno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_fileclass", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_filetype", "char(5)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_fileversion", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cisano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }


     status = MEMwrite_format (*list, "n_cifilename", "char(14)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilesize", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_ciuser", "char(14)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_cidate", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_citime", "char(8)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_fileco", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cosano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_cofilename", "char(14)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_couser", "char(14)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
           /* 
    sprintf(write, "%d\1%d\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1", PDMpart.n_catalogno, PDMpart.n_itemno, PDMpart.n_fileno, PDMpart.n_cisano, node_name, user_name, passwd, path_name, device_type, mach_id, op_sys, net_tcp, net_xns, net_dec, PDMpart.n_cifilename, PDMpart.n_cofilename, "", -1, "move");

       status = MEMwrite(*list, write);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr  : status = <0x%.8x>\n", status);
        return (status);
       }
      if(PDMdebug_on)
        MEMprint_buffer("list buffer", *list, PDM_DEBUG_FILE);
*/
    

    PDMdebug("EXIT: PDMmake_data_buffer\n");
       return(PDM_S_SUCCESS);


}

int PDMXmake_file_buffer(list)
MEMptr *list;
{
  static char *fn = "PDMXmake_file_buffer:";

    PDMdebug("ENTER: PDMXmake_file_buffer\n");
     status = MEMopen (list, 512);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_catalogno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_itemno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
     status = MEMwrite_format (*list, "n_fileno", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_sano", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_nodename", "char(30)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_username", "char(20)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_passwd", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_pathname", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_devicetype", "char(2)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_machid", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_opsys", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_tcpip", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_xns", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_decnet", "char(1)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilename", "char(50)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cofilename", "char(128)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_filetype", "char(15)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_cifilesize", "integer");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }

     status = MEMwrite_format (*list, "n_status", "char(10)");
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
        return (status);
      }
    PDMdebug("EXIT: PDMXmake_file_buffer\n");
       return(PDM_S_SUCCESS);
}


/* 
     This function is written to insert the nodename, passwd etc. into the
     buffer passed to _NFMmv_files function. Here, given sano, we calculate
     the information from database, and along the info int the passed buffer
     build another buffer and insert the complete info
     
     Did the above make any sense? ... I thought so..
*/

int PDMXload_sano_info (user_id, list)
int     user_id;
MEMptr *list;
{

	char	*fn = "PDMXload_sano_info";
	MEMptr	alt_bufr = NULL;
  	char   write[500];
  	char   node_name[50], user_name[50], passwd[50];
  	char   path_name[50], device_type[10], mach_id[20];
  	char   net_xns[10], net_tcp[10], op_sys[10], net_dec[10];
  	int    row, offset, sano;
  	char   **datal;
  	char   **columnl;
  	char   **datar;
  	char   **columnr;

    PDMdebug("ENTER: PDMXload_sano_info \n");

/*
     status = MEMopen (&alt_bufr, 512);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&alt_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
      }
*/

/* put the column names in the list buffer */

     status = PDMXmake_file_buffer (&alt_bufr);
     if (status != PDM_S_SUCCESS)
      {
        MEMclose (list);
        MEMclose (&alt_bufr);
        _PDMdebug (fn, "PDMXmake_file_buffer : status = <0x%.8x>\n", status);
        return (status);
       }

     status = MEMbuild_array (alt_bufr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&alt_bufr);
        MEMclose (list);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
       }

     status = MEMbuild_array (*list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        MEMclose (&alt_bufr);
        status = PDM_E_BUILD_ARRAY;
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (status);
       }
      datal = (char **) (*list)->data_ptr;
      columnl = (char **) (*list)->column_ptr;
      datar = (char **) alt_bufr->data_ptr;
      columnr = (char **) alt_bufr->column_ptr;

  for (row = 0; row < (*list)->rows; row++ ) {
      offset = row * (*list)->columns;
      sano = atol (datal[offset + 3]);
      _PDMdebug (fn, "cisano = %d\n", sano);
      status = NFMget_sa_no_info(user_id, sano, node_name, 
               user_name, passwd, path_name, device_type, mach_id, op_sys, 
               net_tcp, net_xns, net_dec);
         if(status != NFM_S_SUCCESS)
        {
         sprintf(s, "NFMget_sa_no_info failed status %d\n", status);
         PDMdebug(s);
         MEMclose(&list);
         return(PDM_E_BAD_STRG);
        }

     _PDMdebug (fn, 
"Node Name = <%s> : User Name = <%s> : Passwd = <%s> : Path Name = <%s> :\n\
 Device Type = <%s> : Mach Id = <%s> : Op Sys = <%s> : Tcp = <%s> :\n\
 Xns = <%s> : Dec = <%s>\n", 
                 node_name, user_name, passwd, path_name, 
                 device_type, mach_id, op_sys, net_tcp, net_xns, net_dec) ;


    sprintf(write, 
"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
datal[offset + 0], datal[offset + 1], datal[offset + 2], datal[offset + 3], 
node_name, user_name, passwd, path_name, device_type, mach_id, op_sys, net_tcp, 
net_xns, net_dec, datal[offset + 14], datal[offset + 15], "", "-1", 
 datal[offset + 18]);

_PDMdebug (fn, "row is :\n%s\n", write);

       status = MEMwrite(alt_bufr, write);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&alt_bufr);
        MEMclose (list);
        _PDMdebug (fn, "MEM Wr  : status = <0x%.8x>\n", status);
        return (status);
       }

     node_name [0] = '\0'; user_name   [0] = '\0'; passwd  [0] = '\0';
     path_name [0] = '\0'; device_type [0] = '\0';
     mach_id   [0] = '\0'; op_sys      [0] = '\0';
     net_tcp   [0] = '\0'; net_xns     [0] = '\0'; net_dec [0] = '\0';

   }
   *list = alt_bufr;
      if(PDMdebug_on)
        MEMprint_buffer("list buffer after  PDMXload_sano_info", 
                                               *list, PDM_DEBUG_FILE);

    PDMdebug("EXIT: PDMXload_sano_info \n");
    return (PDM_S_SUCCESS);
}


/* function to set wfinfo and operation structure */

int PDMset_info_oper_struct (catalog, p_partnum, p_revision)
char *catalog, *p_partnum, *p_revision;
{
 char	*fn="PDMset_info_oper_struct";

   _PDMdebug (fn, "ENTER:\n");
       PDMwf_info.workflow = NFM_NO_WORKFLOW;
       strcpy ( PDMwf_info.command , WFinfo.command_name) ;
       strcpy ( PDMwf_info.workflow_name , WFinfo.workflow_name) ;
       strcpy ( PDMwf_info.project_name , WFinfo.proj_name) ;
       strcpy ( PDMwf_info.app_name , "PDM") ;

 if(PDMdebug_on)
_PDMdebug(fn, "PDMwf_info.workflow = %d, PDMwf_info.command = %s, PDMwf_info.workflow_name = %s, PDMwf_info.project_name = %s, PDMwf_info.app_name = %s\n", PDMwf_info.workflow, PDMwf_info.command, PDMwf_info.workflow_name, PDMwf_info.project_name, PDMwf_info.app_name );

        status = PDMset_oper_struct (catalog, p_partnum, p_revision);
        if (status != PDM_S_SUCCESS) {
             _PDMdebug(fn, "PDMset_oper_struct failed status %d\n", status);
             return (status);
        }
   _PDMdebug (fn,"EXIT:\n");
 return (PDM_S_SUCCESS);
 }


int PDMset_oper_struct (catalog, p_partnum, p_revision)
char *catalog, *p_partnum, *p_revision;
{
 char	*fn = "PDMset_oper_struct";
   _PDMdebug (fn,"ENTER: \n");
 PDMoperation = PDMlast_oper = (struct NFMoperation *)
                                calloc (2, sizeof (struct NFMoperation));
       PDMoperation->transfer = NFM_TRANSFER;
       PDMoperation->delete = NFM_NO_DELETE;
       PDMoperation->purge = NFM_PURGE;
       strcpy (PDMoperation->catalog, catalog) ;
       strcpy (PDMoperation->item_name, p_partnum) ;
       strcpy (PDMoperation->item_rev, p_revision) ;
 if(PDMdebug_on)
_PDMdebug(fn, "PDMoperation->transfer = %d, PDMoperation->delete = %d, PDMoperation->purge = %d, PDMoperation->catalog = %s, PDMoperation->item_name = %s, PDMoperation->item_rev = %s\n", PDMoperation->transfer, PDMoperation->delete, PDMoperation->purge, catalog, p_partnum, p_revision);

   _PDMdebug (fn,"EXIT:\n");
 return (PDM_S_SUCCESS);
}


int PDMupdate_ncoout(catalog, itemno, upd_str)
char *catalog, *upd_str;
int  itemno;
{
   char  sql_str[250];

   _PDMdebug("ENTER:", "PDMupdate_ncoout\n");

  sql_str[0]='\0';

  sprintf(sql_str, "UPDATE %s SET n_status = '%s' WHERE n_itemno = %d", 
             catalog, upd_str, itemno);
  status = PDMris_stmt(sql_str);
   if (status != SQL_S_SUCCESS)
       {
        return(PDM_E_SQL_STMT);
         }
  
   PDMdebug("EXIT:", "PDMupdate_ncoout\n");
   return(PDM_S_SUCCESS);
}

int PDMreset_ncoout(catalog, itemno, old_coout)
char *catalog;
int  itemno;
char *old_coout;
{
  char	date[128];
  char	co_date[128];
  char	ci_date[128];
  char	*fn = "PDMreset_ncoout";
  char  *msg = NULL;
  int	res_status;
   PDMdebug("ENTER:PDMreset_ncoout\n");
  s[0] = '\0';
  date[0] = '\0';
  ci_date[0] = '\0';
  co_date[0] = '\0';

  _PDMdebug (fn, "catalog[%s] item[%d] coout[%s]\n",
                         catalog, itemno, old_coout);
   
 if(strlen(old_coout))
 {
  sprintf(s, "UPDATE %s SET n_status = '%s' WHERE n_itemno = %d", 
             catalog, old_coout, itemno);

  status = SQLstmt (s);
  if (status != SQL_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
      if (status == SQL_E_MESSAGE) {
          msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
          UI_status (msg);
          sleep (30);
          status = SQLstmt (s);
          if (status != SQL_S_SUCCESS) {
              UI_status (msg);
              sleep (30);
              status = SQLstmt (s);
              if (status != SQL_S_SUCCESS) {
                 msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
                 UI_status (msg);
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    _PDMdebug (fn,
                       "SQLstmt (%s) failed 0x%.8x\n", catalog, status);
                   return (status);
                     }
             }
        }
      else  {
     _PDMdebug (fn, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     return (status);
     }
    }


     strcpy (date, PDMpart.n_codate);
     res_status = NFMascii_to_timestamp_format (date, co_date) ;
     if (res_status != NFM_S_SUCCESS) {
              _PDMdebug (fn, "ascii to timestamp:status = <0x%.8x>\n", status);
              return (res_status) ;
        }

     _PDMdebug (fn, "co_date [%s]\n", co_date);

     strcpy (date, PDMpart.n_cidate);
     res_status = NFMascii_to_timestamp_format (date, ci_date) ;
     if (res_status != NFM_S_SUCCESS) {
              _PDMdebug (fn, "ascii to timestamp:res_status = <0x%.8x>\n", res_status);
              return (res_status) ;
        }

     _PDMdebug (fn, "ci_date [%s]\n", ci_date);



  sprintf(s, "UPDATE f_%s SET n_fileco = '%s', n_codate = TIMESTAMP '%s', n_couser = '%s', n_ciuser = '%s', n_cidate = TIMESTAMP '%s', n_cosano = %d  WHERE n_itemnum = %d", 
catalog, PDMpart.n_fileco, co_date, PDMpart.n_couser, PDMpart.n_ciuser, ci_date, PDMpart.n_cosano, itemno);
  }
 else 
  { 
  sprintf(s, "UPDATE %s SET n_status = '' WHERE n_itemno = %d", 
             catalog, itemno);
  }

  status = SQLstmt (s);
  if (status != SQL_S_SUCCESS) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
      if (status == SQL_E_MESSAGE) {
          msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
          UI_status (msg);
          sleep (30);
          status = SQLstmt (s);
          if (status != SQL_S_SUCCESS) {
              UI_status (msg);
              sleep (30);
              status = SQLstmt (s);
              if (status != SQL_S_SUCCESS) {
                 msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
                 UI_status (msg);
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    _PDMdebug (fn,
                       "SQLstmt (%s) failed 0x%.8x\n", catalog, status);
                   return (status);
                     }
             }
        }
      else  {
     _PDMdebug (fn, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     return (status);
     }
    }

 /* Necessary to commit the rollback. MaC 111993*/
  SQLstmt ("COMMIT WORK");
  
  
   PDMdebug("EXIT:PDMreset_ncoout\n");
   return(PDM_S_SUCCESS);
}

PDMupdate_dots()
{
strcat (glob_var, ".");
UI_status(glob_var);
}
    

PDMreset_dots()
{
glob_var[0] = '\0';
}
    


int PDMquery_catalog_part_rev_type (n_catalogno, n_itemno,
                              catalog, part_num, part_rev, part_type)
        int            n_catalogno;
        int            n_itemno;
        char           *catalog;
        char           *part_num;
        char           *part_rev;
        char           *part_type;
{
        char          **data;
        char            sql_str[512];
        MEMptr          bufr = NULL;

        long            status;

        PDMdebug("ENTER:PDMquery_catalog_part_rev\n");
        /* get n_catalogno */
         status = PDMris_get_catname(n_catalogno, catalog);
          if(status != SQL_S_SUCCESS)
           {
                sprintf(s, "SQLquery failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_SQL_QUERY);
            }

        sprintf(sql_str, "%s %s %s %d",
                "SELECT n_itemname, n_itemrev, p_parttype FROM ", catalog,
                "WHERE n_itemno = ", n_itemno);
        status = SQLquery(sql_str, &bufr, 512);
        if (status != SQL_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "SQLquery failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_SQL_QUERY);
        }
        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMbuild_array failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_BUILD_ARRAY);
        }
        data = (char **) bufr->data_ptr;
        strcpy(part_num, data[0]);
        strcpy(part_rev, data[1]);
        strcpy(part_type, data[2]);
        PDMdebug("EXIT:PDMquery_catalog_part_rev\n");
        return (PDM_S_SUCCESS);
}


int PDMget_mul_file(catalog, itemno, temp_bufr1)
char *catalog;
int  itemno;
MEMptr *temp_bufr1;
{
 char  sql_str[512];
 long  status;

sql_str[0] = '\0';

sprintf(sql_str," SELECT n_cofilename  FROM f_%s WHERE n_itemnum = %d AND n_fileversion = (SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d) ORDER BY n_cofilename",catalog, itemno, catalog, itemno);
   status = SQLquery(sql_str,temp_bufr1,512);
   if(status != SQL_S_SUCCESS)
   {
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 return(PDM_E_PART_NOT_FOUND);
                        default:
                                 return(PDM_E_SQL_QUERY);
                }
   }
   return(PDM_S_SUCCESS); 
}


int PDMget_new_files(catalog, itemno, temp_bufr1)
char *catalog;
int  itemno;
MEMptr *temp_bufr1;
{
 char  *fname = "PDMget_new_files";
 char  sql_str[512];
 long  status;

   sql_str[0] = '\0';
  _PDMdebug(fname,"Enter:");

sprintf(sql_str," SELECT n_cofilename  FROM f_%s WHERE n_itemnum = %d  AND (n_fileco is null or n_fileco = '') ORDER BY n_cofilename",catalog, itemno);
   status = SQLquery(sql_str,temp_bufr1,512);
   if(status != SQL_S_SUCCESS)
   {
                switch(status)
                {
                        case SQL_I_NO_ROWS_FOUND :
                                 return(PDM_E_PART_NOT_FOUND);
                        default:
                                 return(PDM_E_SQL_QUERY);
                }
   }
   _PDMdebug(fname,"Exit:");
   return(PDM_S_SUCCESS); 
}

/*
Given a filename and storage information; check to see
whether there exists such a file...
status returned: PDM_E_FILE_ALREADY_EXISTS
                 PDM_S_SUCCESS
*/

int PDMcheck_dup_sa_fname (filename, strg_name)
char           *filename;
char           *strg_name;
{
        char            *fn = "PDMcheck_dup_filename_sa";
        MEMptr          file_list = NULL;
/*      char            filename[NFM_COFILENAME + 1];*/
        char            nodename[NFM_NODENAME + 1], username[NFM_USERNAME + 1];
        char            passwd[NFM_PASSWD + 1], pathname[NFM_PATHNAME + 1];
        char            devicetype[NFM_DEVICETYPE + 1], machid[NFM_MACHID + 1];
        char            opsys[NFM_OPSYS + 1], tcpip[NFM_TCPIP + 1];
        char            xns[NFM_XNS + 1], decnet[NFM_DECNET + 1];
        char            netware[NFM_NETWARE + 1];
        char            plattername[NFM_PLATTERNAME + 1];
        char            partition[NFM_PARTITION + 1], nfs[NFM_NFS + 1];
        char            compress[NFM_COMPRESS + 1];
        char            row_str[1024];
        char            **data;
        long            sano = 0;
        int             file_col = 0;


    PDMdebug("ENTER:PDMcheck_dup_filename_sano\n");

    _PDMdebug (fn, "filename[%s], strg_name[%s]\n", filename, strg_name);

     /*create buffer */

    status = NFMbuild_fto_buffer(&file_list, 0);
    if (status != NFM_S_SUCCESS) {
      _PDMdebug(fn, "NFMbuild_fto_buffer 0x%.8x\n", status);
      return (status);
      }

    status = NFMget_storage_info("NFMFILES", &sano, nodename,
                               username, passwd, pathname, devicetype,
                               plattername, partition, nfs, compress,
                               machid, opsys, tcpip, xns, decnet, netware);

    if (status != NFM_S_SUCCESS) {
       PDMrollback_transaction(1200);
       _PDMdebug(fn, "NFMget_storage_info %s 0x%.8x\n", strg_name,
                          status);
       return (status);
       }

    sprintf(row_str,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1\1%s\1%s",
     sano,
     nodename, username, passwd, "/usr/tmp", devicetype, plattername, partition,
     nfs, compress, machid, opsys, tcpip, xns, decnet, netware, "XXX",
     "\1\1\1\1\1");

    _PDMdebug(fn, "MEMwrite %s\n", row_str);

    status = MEMwrite(file_list, row_str);
          if (status != MEM_S_SUCCESS) {
            _PDMdebug(fn, "MEMwrite 0x%.8x\n", status);
            MEMclose(&file_list);
            return (status);
            }

   /* Sano should be initialized to zero to use the storage area name 
       - Kumar 10.13.93
  */
  sano = -1;

    status = NFMget_storage_info(strg_name, &sano, nodename,
                               username, passwd, pathname, devicetype,
                               plattername, partition, nfs, compress,
                               machid, opsys, tcpip, xns, decnet, netware);

    if (status != NFM_S_SUCCESS) {
       PDMrollback_transaction(1200);
       _PDMdebug(fn, "NFMget_storage_info %s 0x%.8x\n", strg_name,
                          status);
       return (status);
       }

    sprintf(row_str,
"%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%s\1%s\1\1\1%d%s",
     sano,
     nodename, username, passwd, pathname, devicetype, plattername, partition,
     nfs, compress, machid, opsys, tcpip, xns, decnet, netware, filename, "pdm_temp_file", NFM_MOVE,"\1\1\1");

    _PDMdebug(fn, "MEMwrite %s\n", row_str);

    status = MEMwrite(file_list, row_str);
          if (status != MEM_S_SUCCESS) {
            _PDMdebug(fn, "MEMwrite 0x%.8x\n", status);
            MEMclose(&file_list);
            return (status);
            }

      status = MEMbuild_array(file_list);
        if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, " MEMbuild_array failed %d \n", status);
           MEMclose (&file_list);
           return (status);
        }


        if (PDMdebug_on) {
                MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);
        }

   /* check filename*/
      status = _NFMfs_recv_files (&file_list);
      if (status == NFM_S_SUCCESS) {
        _PDMdebug(fn, "_NFMfs_recv_files 0x%.8x\n", status);

        status = MEMbuild_array(file_list);
        if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, " MEMbuild_array failed %d \n", status);
           MEMclose (&file_list);
           return (status);
        }

        if (PDMdebug_on) {
                MEMprint_buffer("file_list", file_list, PDM_DEBUG_FILE);
        }

        data = (char **) file_list->data_ptr;
        _PDMdebug (fn, "filesize = %d\n", atol (data[22]));
/* Mychelle 4/20/93 - get the column by name, instead of number */

        status = PDUget_buffer_col(file_list, "n_filesize", &file_col);
        if (status != PDM_S_SUCCESS)
          return(status);

        if (atol(data[(file_list->columns * 1) + file_col]) > 0)
          {
          _PDMdebug(fn, "%s exists in %s\n", filename, strg_name);
          _NFMfs_undo_recv_files(&file_list);
          MEMclose(&file_list);
          return (PDM_E_FILE_ALREADY_EXISTS);
          }
       else {
          _PDMdebug(fn, "%s does not exist in %s\n", filename, strg_name);
           MEMclose(&file_list);
          _PDMdebug ("EXIT", "%s\n", fn);
          return (PDM_S_SUCCESS);
          }
    }
  _PDMdebug(fn, "_NFMfs_recv_files 0x%.8x\n", status);
 _PDMdebug(fn, "%s does not exist in %s\n", filename, strg_name);
  MEMclose(&file_list);
  _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}


  /* 
   This function was written to get the couserid 
   to validate activate checked out file. This userid is
   compared with the userid of user who is trying to activate
   a checked out file.
   MaC 120993 
   */



int PDMget_co_username (catalog, partnum, revision, CoUserId)
char *catalog;
char *partnum;
char *revision;
int *CoUserId;
{
        char            *fn = "PDMget_co_username";
	long		status;
        char            sql_str[512];
        MEMptr          bufr = NULL;
        char             **data;

      _PDMdebug(fn, "ENTER:\n");

      _PDMdebug (fn, "catalog[%s] partnum[%s] rev[%s]\n",
                                         catalog, partnum, revision);

      sprintf(sql_str, 
      "SELECT %s FROM %s t1 ,f_%s t2 WHERE %s '%s' %s '%s' %s ", 
      " t1.n_status, t1.n_itemno, t2.n_couser  ",
      catalog, catalog, 
      "t1.n_itemname = ", partnum, 
      " AND t1.n_itemrev = ", revision,
      " AND t1.n_itemno = t2.n_itemnum" );

      status = SQLquery(sql_str,&bufr,512); 
      if (status != SQL_S_SUCCESS) {
          if(status == SQL_I_NO_ROWS_FOUND)
               return(PDM_E_PART_NOT_FOUND);
          else
              _PDMdebug(fn,  
                   "%s %d\n", "PDMquery_part_status failed ", status);
             status = _PDMget_db_error (status);
             return (status);
          }

      status  = MEMbuild_array (bufr);
      if (status != MEM_S_SUCCESS) {
        MEMclose(&bufr);
        _PDMdebug(fn,  "%s %d\n", "MEMbuild_array failed ", status);
         return (status);
        }

      data = (char **) bufr->data_ptr; 

      if ((!strcmp(data[0],"I")) || (!strcmp(data[0], ""))) {
           MEMclose(&bufr);
           _PDMdebug("PART is", "CHECKED IN \n");
           return(PDM_E_PART_NOT_CHECKEDIN);
          }

      else if (!strcmp(data[0], "")) {
           MEMclose(&bufr);
           _PDMdebug("PART is", "NEVER CHECKED IN \n");
           return(PDM_I_NEVER_CHECKED_IN);
          }

      _PDMdebug (fn, "CoUserName = %s\n", data[2]);
      
      sprintf (sql_str, 
         "SELECT n_userno from nfmusers where n_username = '%s' ", data[2]);

       MEMclose (&bufr);

      status = SQLquery(sql_str,&bufr,512); 
      if (status != SQL_S_SUCCESS) {
          if(status == SQL_I_NO_ROWS_FOUND)
               return(PDM_E_NO_SUCH_USER);
          else
              _PDMdebug(fn,  
                   "%s %d\n", "PDMquery_part_status failed ", status);
             status = _PDMget_db_error (status);
             return (status);
          }

      status  = MEMbuild_array (bufr);
      if (status != MEM_S_SUCCESS) {
        MEMclose(&bufr);
        _PDMdebug(fn,  "%s %d\n", "MEMbuild_array failed ", status);
         return (status);
        }

      data = (char **) bufr->data_ptr; 

      *CoUserId = atol (data[0]);
      
      _PDMdebug (fn, "CoUserId = %d\n", *CoUserId);

    MEMclose (&bufr);

   _PDMdebug (fn, "Exit\n");
   return (PDM_S_SUCCESS);
}
