#include "machine.h"
#include "NFMnfmt_inc.h"
#include "NFMschema.h"
#include "NFMfto_buf.h"


#define MAX_ATTR_LEN	NFM_FILENAME

/* Build the buffer format to enter data for file transfers */

long _DMbuild_fto_buffer (list,size)
   MEMptr    *list;
   long size ;
   {
     char *fname="_DMbuild_fto_buffer ";
     char format[MAX_ATTR_LEN], attribute[MAX_ATTR_LEN];
     long      status,buf_size,i;

     _NFMdebug ((fname,"MEMptr *list = <%x> size <%d>\n", *list,size));

     if(size> 0) buf_size = size ;
     else buf_size = MEM_SIZE ;


/* close the previous buffer */
     MEMclose(list);
/* Open a new buffer */
     status = MEMopen (list, buf_size);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM_FAILURE;
        _NFMdebug ((fname,"MEM Open : status = <0x%.8x>\n", status));
	ERRload_struct(NFM,status,"%s","MEMopen");
        return (status);
      }

     for(i=0;i<DM_FTO_MAX_BUF ; i++)
     {
	switch(i)
	{
		case  FTO_SANO	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_sano");
			break;

		case  FTO_NODENAME	:
     			sprintf(format,"char(%d)",NFM_NODENAME);
     			strcpy(attribute,"n_nodename");
			break;
		case  FTO_USERNAME	:
     			sprintf(format,"char(%d)",NFM_USERNAME);
     			strcpy(attribute,"n_username");
			break;
		case  FTO_PASSWD	:
     			sprintf(format,"char(%d)",NFM_PASSWD);
     			strcpy(attribute,"n_passwd");
			break;
		case  FTO_PATHNAME	:
     			sprintf(format,"char(%d)",NFM_PATHNAME);
     			strcpy(attribute,"n_pathname");
			break;
		case  FTO_DEVICETYPE	:
     			sprintf(format,"char(%d)",NFM_DEVICETYPE);
     			strcpy(attribute,"n_devicetype");
			break;
		case  FTO_PLATTERNAME	:
     			sprintf(format,"char(%d)",NFM_PLATTERNAME);
     			strcpy(attribute,"n_plattername");
			break;
		case  FTO_PARTITION	:
     			sprintf(format,"char(%d)",NFM_PARTITION);
     			strcpy(attribute,"n_partition");
			break;
		case  FTO_NFS		:
     			sprintf(format,"char(%d)",NFM_NFS);
     			strcpy(attribute,"n_nfs");
			break;
		case  FTO_MOUNTPOINT	:
     			sprintf(format,"char(%d)",NFM_MOUNTPOINT);
     			strcpy(attribute,"n_mountpoint");
			break;
		case  FTO_COMPRESS	:
     			sprintf(format,"char(%d)",NFM_COMPRESS);
     			strcpy(attribute,"n_compress");
			break;
		case  FTO_MACHID	:
     			sprintf(format,"char(%d)",NFM_MACHID);
     			strcpy(attribute,"n_machid");
			break;
		case  FTO_OPSYS		:
     			sprintf(format,"char(%d)",NFM_OPSYS);
     			strcpy(attribute,"n_opsys");
			break;
		case  FTO_TCPIP		:
     			sprintf(format,"char(%d)",NFM_TCPIP);
     			strcpy(attribute,"n_tcpip");
			break;
		case  FTO_XNS		:
     			sprintf(format,"char(%d)",NFM_XNS);
     			strcpy(attribute,"n_xns");
			break;
		case  FTO_DECNET	:
     			sprintf(format,"char(%d)",NFM_DECNET);
     			strcpy(attribute,"n_decnet");
			break;
		case  FTO_NETWARE	:
     			sprintf(format,"char(%d)",NFM_NETWARE);
     			strcpy(attribute,"n_netware");
			break;
		case  FTO_FILENO	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_fileno");
			break;
		case  FTO_FILEOLD	:
/* FILEOLD represents OLD check in file */
     			sprintf(format,"char(%d)",NFM_CIFILENAME);
     			strcpy(attribute,"n_fileold");
			break;
		case  FTO_CIFILENAME	:
     			sprintf(format,"char(%d)",NFM_CIFILENAME);
     			strcpy(attribute,"n_cifilename");
			break;
		case  FTO_COFILENAME	:
     			sprintf(format,"char(%d)",NFM_COFILENAME);
     			strcpy(attribute,"n_cofilename");
			break;
		case  FTO_FILETYPE	:
     			sprintf(format,"char(%d)",NFM_FILETYPE);
     			strcpy(attribute,"n_filetype");
			break;
		case  FTO_CIFILESIZE	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_filesize");
			break;
		case  FTO_STATUS1	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_status1");
			break;
		case  FTO_STATUS2	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_status2");
			break;
		case  FTO_STATUS3	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_status3");
			break;
		case  FTO_CAT	:
     			sprintf(format,"char(%d)",NFM_CATALOGNAME);
     			strcpy(attribute,"n_catalogname");
			break;
		case  FTO_ITEMNO	:
     			strcpy(format,"integer");
     			strcpy(attribute,"n_itemno");
			break;
		case  FTO_REV 	:
     			sprintf(format,"char(%d)",NFM_ITEMREV);
     			strcpy(attribute,"n_itemrev");
			break;
		case  FTO_ITEMNAME	:
     			sprintf(format,"char(%d)",NFM_ITEMNAME);
     			strcpy(attribute,"n_itemname");
			break;
		case  FTO_ITEMDESC	:
     			sprintf(format,"char(%d)",NFM_ITEMDESC);
     			strcpy(attribute,"n_itemdesc");
			break;
		case  FTO_CATNO	:
     			sprintf(format,"char(%d)",NFM_CATALOGNO);
     			strcpy(attribute,"n_catalogno");
			break;
		default			:
			_NFMdebug((fname,"Buffer index <%d> is invalid . \n",i));
			MEMclose(list);
			ERRload_struct(NFM,NFM_E_FAILURE,"%s%d","Invalid FTO Buffer Index",i);
			return(NFM_E_FAILURE);
	}
	status = NFMwrite_format(list,attribute,format,fname);
	if(status!=NFM_S_SUCCESS) return(status);
    }
    _NFMdebug((fname,"SUCCESSFUL	status <0x%.8x>\n",status));
    return(NFM_S_SUCCESS);
}
