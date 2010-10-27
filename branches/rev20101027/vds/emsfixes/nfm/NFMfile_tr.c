 /* $Id: NFMfile_tr.c,v 1.5 2001/11/08 20:21:30 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/nfm/NFMfile_tr.c
 *
 * Description: VDS Zip functions for files in/out of NFM
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: NFMfile_tr.c,v $
 * Revision 1.5  2001/11/08 20:21:30  jdsauby
 * JTS CR MP 4079 - jds
 *
 * Revision 1.4  2001/09/14 16:41:38  jdsauby
 * Made it so that if one file fails to unzip, then it all fails -jds
 *
 * Revision 1.3  2001/09/10 20:49:13  jdsauby
 * When file fails to transfer on checkin, needed to uncompress file back to original state, error found in cert.  -jds 09/10/01
 *
 * Revision 1.2  2001/08/14 19:41:52  jdsauby
 * Added logging file, plus env variable to turn zip off  - jds
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/13/01  js      Added for SP, CR5453
 ***************************************************************************/
#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"
#include "time.h"

extern long VDnfmUnzipBufr();
extern long VDnfmZipBufr  ();
extern FILE *VDnfmOpenXferLogFile();
extern long VDnfmCheckForLocalFiles();

/************************************************************************
*									*
*			_NFMfs_recv_files				*
*									*
*	This function is used by check out in which case the destination*
*	for all the files is the same storage location			*
************************************************************************/

long _NFMfs_recv_files (buffer_ptr)

MEMptr  *buffer_ptr;
{
  char *fname="_NFMfs_recv_files";
  long     status,protocol;
  char     **data;
  time_t   begTime;
  time_t   endTime;
  struct tm *tm;
  char     timestamp[256];
  char     msg[128];
  FILE     *logFile = NULL;

  _NFMdebug((fname,"Entry > MEMptr: *buffer_ptr = <%x>\n",*buffer_ptr));



/* MEM build the buffer_ptr to access the data */

  status = MEMbuild_array (*buffer_ptr);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status); 
    _NFMdebug((fname,"MEM operation failed: Operation <%s> for <%s> status <0x%.8x>\n","MEMbuild_array","*buffer_ptr",status));
/* Return NFM_E_FAILURE to indicate General failure: Do not look in buffer */
    return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
  }
/* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
	status = NFMget_server_sa_info();
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to set server information in local\
buffer. status : <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_I_LOAD_SERVER_NODE_INFO,"%x",status);
	}
  }


  data   = (char **) (*buffer_ptr) -> data_ptr;

/* set the value of protocol 
   for Server to Fileserver Connection */

  if (! strcmp (data [FTO_TCPIP], "Y") &&
      ! strcmp (filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y")) protocol = NET_TCP;
  else if (! strcmp (data [FTO_XNS], "Y") &&
           ! strcmp ( filexfer_loc_sa.LOCAL_SA[FTO_XNS], "Y")) protocol = NET_XNS;
  else      
  {
                         protocol = NULL;
     _NFMdebug((fname,"<WARNING> No match found for protocol between Server and\
file_server proceeding with NULL\n"));
  }

  /* CR 4079, Should not allow files which are already local to be overwritten. jds
   * */
  status = VDnfmCheckForLocalFiles(buffer_ptr);
  if (!(status & 1)) return (NFM_E_SEVERE_ERROR);


  time(&begTime);
  tm = localtime(&begTime);
  sprintf(timestamp,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);


  logFile = VDnfmOpenXferLogFile();
  if (logFile) {
      fprintf(logFile,
	      "\n###### %s ######\n",timestamp);
      fprintf(logFile,
	      "Files Transferred from Server\n");
      fclose(logFile);
  }

  //printf("CO Begin Transfer: %d\n",begTime);

/* check if the destination location is a CLIX m/c */

  if ((! strcmp (data [FTO_OPSYS], "CLIX"))||(! strcmp (data [FTO_OPSYS], "UNIX")))
  {
    status = NFMs_dest_recv_clix(data [FTO_NODENAME], 
                                 data [FTO_USERNAME], 
				 data [FTO_PASSWD],
			         protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server destination receive clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  }
  else
  {
/* Call function to receive files at a temporary location on server node 
   and transfer them to the destination node */
    status = NFMs_dest_recv_nonclix(data [FTO_NODENAME], 
                                   data [FTO_USERNAME], 
				   data [FTO_PASSWD],
			           protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server destination receive non clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }

  }

  /* -----------------------------------
   * Now that the files are on the local storage area, uncompress them
   * **/
  status = VDnfmUnzipBufr(buffer_ptr,1);

  time(&endTime);
  //printf("CO End Transfer: %d\n",endTime);
  //printf("CO Elapsed Time: %d seconds\n",endTime - begTime);
  
  sprintf(msg,"Transfer Time: %d seconds",endTime - begTime);
  UI_status(msg);
  
  logFile = VDnfmOpenXferLogFile();
  if (logFile) {
      fprintf(logFile,
	      "%s\n\n",msg);
      fclose(logFile);
  }

  if (!(status & 1)) return (NFM_E_SEVERE_ERROR);
  
  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}

/************************************************************************
*									*
*			_NFMfs_send_files				*
*									*
*	This function is used by "check in" in which case the source    *
*	for all the files is the same storage location			*
************************************************************************/

long _NFMfs_send_files (buffer_ptr, NETid,close_flag)

MEMptr  *buffer_ptr;
long *NETid,close_flag;
{
  char *fname="_NFMfs_send_files";
  long     status,protocol;
  char     **data;
  time_t   begTime;
  time_t   endTime;
  struct tm *tm;
  char     timestamp[256];
  char     msg[128];
  int      zip_off = 0;
  FILE     *logFile = NULL;

  _NFMdebug((fname,"Entry > MEMptr: buffer = <%x>\n",*buffer_ptr));

/* Set NETid to -1 */

   *NETid = -1;

/* MEM build the buffer_ptr to access the data */

  status = MEMbuild_array (*buffer_ptr);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status); 
    _NFMdebug((fname,"MEM operation failed: Operation <%s> for <%s> status <0x%.8x>\n","MEMbuild_array","*buffer_ptr",status));
    return (NFM_E_SEVERE_ERROR);        
  }
/* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
	status = NFMget_server_sa_info();
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to set server information in local\
buffer. status : <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_I_LOAD_SERVER_NODE_INFO,"%x",status);
	}
  }


  data   = (char **) (*buffer_ptr) -> data_ptr;

/* set the value of protocol for check out destination location  */

  if (! strcmp (data [FTO_TCPIP], "Y") &&
      ! strcmp (filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y")) protocol = NET_TCP;
  else if (! strcmp (data [FTO_XNS], "Y") &&
           ! strcmp ( filexfer_loc_sa.LOCAL_SA[FTO_XNS], "Y")) protocol = NET_XNS;
  else      
  {
                         protocol = NULL;
     _NFMdebug((fname,"<WARNING> No match found for protocol between Server and\
file_server proceeding with NULL\n"));
  }

  /* ---------------------------------
   * compress the files before sending them to server
   * **/

  // log what is happening
  time(&begTime);
  tm = localtime(&begTime);
  sprintf(timestamp,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);


  logFile = VDnfmOpenXferLogFile();
  if (logFile) {
      fprintf(logFile,
	      "\n###### %s ######\n",timestamp);
      fprintf(logFile,
	      "Files Transferred to Server\n");
      fclose(logFile);
  }

  /* -----------------------------------------------
   * The env variable VDS_ZIP_FILES_OFF = 1 will turn off the compression
   * **/
  if (getenv("VDS_ZIP_FILES_OFF")) zip_off = atoi(getenv("VDS_ZIP_FILES_OFF"));
  
  if (zip_off == 0) {
      VDnfmZipBufr(buffer_ptr);
  }

  
/* check if the destination location is a CLIX m/c */

  if ((! strcmp (data [FTO_OPSYS], "CLIX"))||(! strcmp (data [FTO_OPSYS], "UNIX")))
  {
    status = NFMs_src_send_clix(data [FTO_NODENAME], 
                                 data [FTO_USERNAME], 
				   data [FTO_PASSWD],
			         protocol, buffer_ptr,NETid,close_flag);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server source send clix : status = <0x%.8x>\n",
      status));
      if (zip_off == 0) VDnfmUnzipBufr(buffer_ptr,0);
      return (status);             
    }
  }
  else
  {
/* Call function to receive files at a temporary location on server node 
   and transfer them to the destination node */
    status = NFMs_src_send_nonclix(data [FTO_NODENAME], 
                                   data [FTO_USERNAME], 
				   data [FTO_PASSWD],
			           protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server source send non clix : status = <0x%.8x>\n",
      status));
      if (zip_off == 0) VDnfmUnzipBufr(buffer_ptr,0);
      return (status);             
    }

  }

  /* ---------------------------------
   * Uncompress files so they can be cleaned up, and so PDM
   * can finish its thing before deleting the locally.
   * **/
  status = VDnfmUnzipBufr(buffer_ptr,0);
  if (!(status & 1)) return (NFM_E_SEVERE_ERROR);

  time(&endTime);
  //printf("CI End Transfer: %d\n",endTime);
  //printf("CI Elapsed Time: %d seconds\n",endTime - begTime);
  sprintf(msg,"Transfer Time: %d seconds",endTime - begTime);
  UI_status(msg);

  logFile = VDnfmOpenXferLogFile();
  if (logFile) {
      fprintf(logFile,
	      "%s\n\n",msg);
      fclose(logFile);
  }

  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     

}
