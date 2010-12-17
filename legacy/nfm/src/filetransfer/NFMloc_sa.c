#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"


/* Function that loads the local storage area information in this structure */

long NFMload_local_sa(buffer_ptr)
	MEMptr *buffer_ptr;
{
  	int y,status;
        char **data,**column;
        char *fname="NFMload_local_sa";
	
/* Initialize all the local variables */
        for(y=0; y < FTO_MAX_BUF ; y++)
		filexfer_loc_sa.LOCAL_SA[y][0] = '\0';
	status = MEMbuild_array(*buffer_ptr);

	if(status!= MEM_S_SUCCESS)
	{
		_NFMdebug((fname,"MEMbuild_array failed in NFMload_local_sa: Status <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_E_MEM_FAILURE,"%s","MEMbuild_array");
                return(status);
	}

	data = (char **) (*buffer_ptr)-> data_ptr;
	column = (char **) (*buffer_ptr)-> column_ptr;
/* PREVENT THE USE OF NFS WHEN USING TEMPORARY LOCATION */
      	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NFS],"N");

	for(y=0; y < (*buffer_ptr)->columns; y++)
        {
         if (! strcmp (column [y], "n_sano"))    
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_SANO],data[y]);
         else if (! strcmp (column [y], "n_nodename"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NODENAME],data[y]);
         else if (! strcmp (column [y], "n_username"))    
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_USERNAME],data[y]);
         else if (! strcmp (column [y], "n_passwd"))     
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PASSWD],data[y]);
         else if (! strcmp (column [y], "n_pathname"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PATHNAME],data[y]);
         else if (! strcmp (column [y], "n_devicetype"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_DEVICETYPE],data[y]);
         else if (! strcmp (column [y], "n_plattername"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PLATTERNAME],data[y]);
         else if (! strcmp (column [y], "n_partition"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PARTITION],data[y]);
/*
         else if (! strcmp (column [y], "n_nfs"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NFS],data[y]);
*/
         else if (! strcmp (column [y], "n_mountpoint"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_MOUNTPOINT],data[y]);
         else if (! strcmp (column [y], "n_compress"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_COMPRESS],data[y]);
         else if (! strcmp (column [y], "n_machid"))
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_MACHID],data[y]);
         else if (! strcmp (column [y], "n_opsys"))
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_OPSYS],data[y]);
         else if (! strcmp (column [y], "n_tcpip"))    
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],data[y]);
         else if (! strcmp (column [y], "n_xns"))     
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_XNS],data[y]);
         else if (! strcmp (column [y], "n_decnet")) 
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_DECNET],data[y]);
         else if (! strcmp (column [y], "n_netware")) 
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NETWARE],data[y]);
         else if (! strcmp (column [y], "n_fileold")) 
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_FILEOLD],data[y]);
         else if (! strcmp (column [y], "n_fileno")) 
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_FILENO],data[y]);
         else if (! strcmp (column [y], "n_cifilename"))
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_CIFILENAME],data[y]);
         else if (! strcmp (column [y], "n_cofilename"))
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_COFILENAME],data[y]);
         else if (! strcmp (column [y], "n_cifilesize")) 
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_CIFILESIZE],data[y]);
         else if (! strcmp (column [y], "n_filetype"))  
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_FILETYPE],data[y]);
         else if (! strcmp (column [y], "n_status1"))   
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_STATUS1],data[y]);
         else if (! strcmp (column [y], "n_status2"))   
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_STATUS2],data[y]);
         else if (! strcmp (column [y], "n_status3"))   
          	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_STATUS3],data[y]);

	}
	filexfer_loc_sa.local_sa_flag = NFM_S_SUCCESS ;
   _NFMdebug((fname,"SUCCESSFUL : status <0x%.8x>\n",status));
   return(NFM_S_SUCCESS);
}

NFMget_server_sa_info()
{
	char *fname="NFMget_server_sa_info";
	struct utsname	sys_name;
	char *c_status,ptcol[40];
        long status;

/* Get the nodename information for the server */
      _NFMdebug((fname,"Entry\n"));

      if((status=uname(&sys_name)) < 0)
       {
          _NFMdebug((fname,"Failed to get system name using uname: status <%d> errno <%d>\n",status,errno));
          ERRload_struct(NFM,NFM_E_UNAME,"%x%d",sys_name,errno);
          return(NFM_E_UNAME);
       }
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_SANO],"0");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NODENAME],sys_name.nodename);
/* Set the username to nfmadmin */
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_USERNAME],"nfmadmin");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PASSWD],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PATHNAME],"/usr/tmp");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_DEVICETYPE],"HD");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PLATTERNAME],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_PARTITION],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NFS],"N");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_MOUNTPOINT],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_COMPRESS],"");
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))
/* HP PORT-IGI- 10 Jun 1994 */
        /* Added for SUN by SSRS - 3/12/93 */
        strcpy(filexfer_loc_sa.LOCAL_SA[FTO_MACHID], "UNIX");
        strcpy(filexfer_loc_sa.LOCAL_SA[FTO_OPSYS], "UNIX");
#else
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_MACHID],"CLIX");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_OPSYS],"CLIX");
#endif	
       c_status = (char *) clh_vbyop (sys_name.nodename, "tcp_address", ptcol, 40);
	if(c_status == NULL)
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y");
	else
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"N");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_XNS],"Y");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_DECNET],"N");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_NETWARE],"N");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_FILENO],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_FILEOLD],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_CIFILENAME],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_COFILENAME],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_FILETYPE],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_CIFILESIZE],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_STATUS1],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_STATUS2],"");
	strcpy(filexfer_loc_sa.LOCAL_SA[FTO_STATUS3],"");

	filexfer_loc_sa.local_sa_flag = NFM_S_SUCCESS ;

	_NFMdebug((fname,"SUCCESSFUL: status : <0x%.8x>\n",NFM_S_SUCCESS));
	return(NFM_S_SUCCESS);
}

