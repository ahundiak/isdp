#include "machine.h"
#include <process.h>
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <ctype.h>
#include <string.h>
#include <stdarg.h>
#include <io.h>
#include <mselems.h>
#include "CLIerrordef.h"
#include "CLIstruct.h"
#include "CLIextern.h"
#include "NFMerrordef.h"
#include "NFMfto_buf.h"
#include "pc.h"
#include "proto.h"
#include <memcheck.h>
#include "NETstruct.h"

short clnt_fd;
long clientid;
extern char *buffer;
extern char npath[51];
MSElement *element;
unsigned short buf[6144];/* Buffer to read elements into */

#define FEOF (feof(input_file))
#define EOD (buf[bufpos] == 0xffff)
#define FILE_HEADER ((element->buf[0] == 0x0908) || (element->buf[0] == 0x09c8))
#define REF_ATTACH ((element->buf[0] == 0x0509) || (element->buf[0] == 0x4205))
#define COLOR_TABLE (element->buf[0] == 0x0501)
#define WTF (element->buf[1])
#define TRUE 1
#define FALSE 0

long NFMpcfile_server () 
{
  char *fname = "NFMpcfile_server" ;
  long status, server_transfer;
  struct NETbuffer_info *struct_ptr ;
  long NFMpcfs_attached_files () ;
  long _NFMget_abort() ;
  char   tmp_str [100] ;

  _CLI_str ("ENTER %s", fname) ;
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  server_transfer = 1 ;
  while (server_transfer)
    {
      sprintf (tmp_str, "%ld", struct_ptr ->request) ;
      _CLI_str ("REQUEST %s", tmp_str) ;
      switch (struct_ptr -> request)
	{
	case FS_SEND_FILES :
	  status = _NFMpcfs_send_files () ;
	  break ;
	  
	case FS_RECV_FILES :
	  status = _NFMpcfs_recv_files () ;
	  break ;
	  
	case FS_UNDO_RECV_FILES :
	  status = NFMpcfs_undo_recv_files () ;
	  break ;
	  
	case FS_UNDO_SEND_FILES :
	  status = NFMpcfs_undo_send_files () ;
	  break ;
	  
	case RM_CO_FILES :
	  status = NFMpcrm_co_files () ;
	  break ;

/******* not implemented ********	  
	case FS_CHG_FILES :
	  status = NFMpcfs_chg_files () ;
	  break ;
	  
	case FS_UNDO_CHG_FILES :
	  status = NFMpcfs_undo_chg_files () ;
	  break ;
***********************************/
	  
	case FS_PURGE :
	  status = NFMpcfs_purge () ;
	  break ;


	case FS_LIST_ATTACHED_FILES :
	  status = NFMpcfs_attached_files () ;
	  break ;

	case ABORT_OPERATION :
	  status = _NFMget_abort() ;
	  break ;

        default :
	  server_transfer = 0 ;
          break ;
	}
    } /* while */
 
  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMcheck_status ()
{
  struct NETbuffer_info *struct_ptr  ;
  long   *src, size ;

  struct_ptr = (struct NETbuffer_info *) buffer ;

  if (struct_ptr->request == ABORT_OPERATION)
    {
      /*      send acknowledge    */
      struct_ptr = (struct NETbuffer_info *) buffer ;
      struct_ptr -> request = ABORT_OPERATION ;
      src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
      *src = 0 ; src ++ ;      
      *src = 1 ; 
      size = (long) ((long) (sizeof (struct NETbuffer_info)) +
		     (long) (2*sizeof(long)));
      struct_ptr -> size = size;
      
      _CLI_str ("size of buffer sent %d\n", size) ;
      NETbuffer_send ((char *) buffer, &size) ;
      _CLI_str ("abort operation") ;
      return (NFM_E_FAILURE) ;
    }
  _CLI_str ("acknowledge from server -> SUCCESSFUL") ;
  return (NFM_S_SUCCESS) ;
}


long _NFMget_abort () 
{
  struct NETbuffer_info *struct_ptr  ;
  long   *src, size, status ;
  char *fname = "_NFMget_abort" ;

  _CLI_str ("%s : ENTER", fname) ;

  struct_ptr = (struct NETbuffer_info *) buffer ;

  /*      send acknowledge    */
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request = ABORT_OPERATION ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  *src = 0 ; src ++ ;      
  *src = 1 ; 
  size = (long) ((long) (sizeof (struct NETbuffer_info)) +
		 (long) (2*sizeof(long)));
  struct_ptr -> size = size;
  
  _CLI_str ("size of buffer sent %d\n", size) ;
  NETbuffer_send ((char *) buffer, &size) ;

  _CLI_str ("abort operation acknowledged to server -> SUCCESSFUL") ;

  _CLI_str ("%s : get next command from pcserver..", fname) ;
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
      return (status) ;
    }  
  _CLI_str ("%s : Successful", fname) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpcfs_send_files ()
{
  char *fname = "_NFMpcfs_send_files" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512];
  long rows, columns, status, size, columns1 ;
  short	   i;
  char interaddr[31], n_username[15], n_passwd[51], n_pathname[51] ;
  char n_nfs[2], n_mountpoint[51];
  char n_fileold[128], n_cifilename[128], n_cofilename[128] ;
  char n_cifilesize[20], n_status[20];
  char drive[2];
  char doscommand[128];							
  char localpath[128], localname[256];
  struct stat filestatus;
  FILE *filechecksize;
  long lfilesize;
  long rfilesize;
  long size_of_path;
  char tempsendfilename[128];

  _CLI_str ("ENTER %s", fname) ;
  sprintf (tmp_str, "%ld", buffer) ;

  /* get rows and columns from header */
  struct_ptr = (struct NETbuffer_info *) buffer ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src ; src ++ ;  
  columns = *src ; src ++ ;

  /* send response for header */
  struct_ptr -> request =  NFM_S_SUCCESS ;
  size = (long) sizeof (struct NETbuffer_info) ;
  struct_ptr -> size = size;

  _CLI_str ("SENDING RESPONSE FOR FILE SERVER HEADER %s\n", "") ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }

  for (i=1; i<=((short)rows); i++)
    {
      _CLI_str ("RECEIVING ROW FROM SERVER %s\n", "") ;
      status = NETbuffer_receive ((char *) buffer, &size) ; 
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
	  return (status) ;
	}  
      status = _NFMcheck_status () ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("operation aborted : status = <%d>", status) ;
	  break ;
	}
      sprintf (tmp_str, "%d", i) ;
      _CLI_str( "file		 <%s>", tmp_str) ;
      src = (long *) buffer;
      size_of_block = (short *) buffer ;
      sizes_array = (short *) ((long)buffer + sizeof (short)) ;
      data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
      memcpy (interaddr, data, sizes_array[0]) ;
      _CLI_str( "internet address     <%s>", interaddr );
      data += (long) sizes_array[0] ;
      memcpy (n_username, data, sizes_array[1]) ;
      _CLI_str( "user name	    <%s>", n_username );
      data += (long) sizes_array[1] ;
      memcpy (n_passwd, data, sizes_array[2]) ;
/*      _CLI_str( "password	     <%s>", n_passwd ); */
      data += (long) sizes_array[2] ;
      memcpy (n_pathname, data, sizes_array[3]) ;
      _CLI_str( "pathname	     <%s>", n_pathname );
      data += (long) sizes_array[3] ;
      memcpy (n_nfs, data, sizes_array[4]) ;
      _CLI_str( "NFS Available	<%s>", n_nfs );
      data += (long) sizes_array[4] ;
      memcpy (n_mountpoint, data, sizes_array[5]) ;
      _CLI_str( "mountpoint	   <%s>", n_mountpoint );
      data += (long) sizes_array[5] ;
      if (i != 1)
	{
	  memcpy (n_fileold, data, sizes_array[6]) ;
	  _CLI_str( "file old	     <%s>", n_fileold );
	  data += (long) sizes_array[6];
	  memcpy (n_cifilename, data, sizes_array[7]) ;
	  _CLI_str( "Check In File Name   <%s>", n_cifilename );
	  data += (long) sizes_array[7] ;
	  memcpy (n_cofilename, data, sizes_array[8]) ;
	  _CLI_str( "Check Out File Name  <%s>", n_cofilename );
	  data += (long) sizes_array[8] ;
	  memcpy (n_cifilesize, data, sizes_array[9]) ;
	  _CLI_str( "Check In File Size   <%s>", n_cifilesize );
	  data += (long) sizes_array[9] ;
	  memcpy (n_status, data, sizes_array[10]) ;
	  _CLI_str( "Status	       <%s>", n_status );
	  /* Get File Size */
	  size_of_path = strlen (localpath) -1;
          if (localpath [size_of_path] == '\\') localpath[size_of_path] = 0 ;
	  sprintf(localname, "%s\\%s", localpath, n_cofilename);
	  _CLI_str ("local name is %s\n", localname) ; 
	  if ( ( filechecksize = fopen(localname,"r") ) == NULL )
	    {
	      /* Unable to open the file for reading */
	      _CLI_str ("%s", "File Open Failed") ;
	      struct_ptr -> request = NFM_E_FOPEN_READ_CI_FILENAME;
	    }
	  else
	    {
	      /* File opened */
	      if ( ( lfilesize = filelength(fileno(filechecksize)) ) == -1L )
		{
		  /* Error getting file size */
		  _CLI_str ("%s", "File Size Read Failed") ;
		  struct_ptr -> request = NFM_E_STAT_CI_FILENAME;
		  if ( fclose(filechecksize) != 0 )
		    {
		      /* Error closing file */
		      _CLI_str ("%s", "File Close Failed") ;
/*		      struct_ptr -> request = NFM_E_FAILURE; */
		    }
		}
	      else
		{
		  if ( fclose(filechecksize) != 0 )
		    {
		      /* Error closing file */
		      _CLI_str ("%s", "File Close Failed") ;
		      struct_ptr -> request = NFM_E_FCLOSE_CI_FILENAME;
		    }
		  else
		    {
		      if (n_nfs != "Y")
			{
			  /* need to ftp file */
			  if ( ftpput(interaddr,n_username,n_passwd,n_pathname,n_cifilename,localpath,n_cofilename) != NFM_S_SUCCESS )
			    {
			      /* Unable to send the file */
			      _CLI_str ("%s", "FTP Failed") ;
			      struct_ptr -> request = NFM_E_FTP_SEND_CO_FILENAME;
			    }
			  else
			    {
			      /* Get file size of transferred file */
			      sprintf( tempsendfilename, "%s\\temp\\nfmsend.tmp", npath );
			      if (NFMcount_ftp_output(tempsendfilename,&rfilesize) != NFM_S_SUCCESS)
				{
				  /* Unable to obtain sent file size */
				  _CLI_str ("%s", "FTPCount Failed") ;
				  struct_ptr -> request = NFM_E_BAD_SIZE_CI_FILENAME ;
				}
			      else
				{
				  /* Compare File Size */
				  if ( lfilesize != rfilesize )
				    {
				      /* Error in file size */
				      _CLI_str ("%s", "File Size Mismatch") ;
				      struct_ptr -> request = NFM_E_BAD_SIZE_CI_FILENAME;
				    }
				  else
				    {
				      /* Successful file transfer */
				      _CLI_str ("%s", "File Received Successfully") ;
				      struct_ptr -> request = NFM_TRANSFERED;
				    }
				}
			    }
			}
		      else
			{
			  /* need to remote mount drive */
			  if ( finddisk(drive) != NFM_S_SUCCESS )
			    {
			      /* No local mount point available */
			      _CLI_str ("%s", "No Local Mount Points Available") ;
			      struct_ptr -> request = NFM_E_FAILURE;
			    }
			  else
			    {
			      /* mount drive */
			      if ( mountdisk(drive,interaddr,n_username,n_passwd,n_pathname) != NFM_S_SUCCESS )
				{
				  /* Unable to mount remote drive */
				  _CLI_str ("%s", "NFSMount Failed") ;
				  struct_ptr -> request = NFM_E_FAILURE;
				}
			      else
				{
				  /* copy file */
				  memset(doscommand,'\0',128);
                                  size_of_path = strlen (localpath) -1 ;
                                  if (localpath [size_of_path] == '\\')
				    localpath[size_of_path] = 0 ;
				  sprintf(doscommand, "copy %s\\%s %s\\%s", drive, n_cifilename, localpath, n_cofilename);
				  if ( system( doscommand ) == -1)
				    {
				      /* System call failed */
				      _CLI_str ("%s", "File Copy Failed") ;
				      struct_ptr -> request = NFM_E_FAILURE;
				    }
				  else
				    {
				      /* File copied - Check File Size */
				      sprintf(localname, "%s\\%s", drive, n_cifilename);
				      if ( ( filechecksize = fopen(localname,"r") ) == NULL )
					{
					  /* Unable to open the file for reading */
					  _CLI_str ("%s", "File Open Failed") ;
					  struct_ptr -> request = NFM_E_FREAD_CI_FILENAME;
					}
				      else
					{
					  /* File opened */
					  if ( ( rfilesize = filelength(fileno(filechecksize)) ) == -1L )
					    {
					      /* Error getting file size */
					      _CLI_str ("%s", "File Size Read Failed") ;
					      struct_ptr -> request = NFM_E_BAD_SIZE_CI_FILENAME;
					      if ( fclose(filechecksize) != 0 )
						{
						  /* Error closing file */
						  _CLI_str ("%s", "File Close Failed") ;
/*						  struct_ptr -> request = NFM_E_FAILURE; */
						}
					    }
					  else
					    {
					      if ( fclose(filechecksize) != 0 )
						{
						  /* Error closing file */
						  _CLI_str ("%s", "File Close Failed") ;
						  struct_ptr -> request = NFM_E_FAILURE;
						}
					      else
						{
						  /* Compare File Size */
						  if ( lfilesize != rfilesize )
						    {
						      /* Error in file size */
						      _CLI_str ("%s", "File Size Mismatch") ;
						      struct_ptr -> request = NFM_E_BAD_SIZE_CI_FILENAME ;
						    }
						  else
						    {
						      /* Successful file transfer */
						      _CLI_str ("%s", "File Received Successfully") ;
						      struct_ptr -> request  =NFM_TRANSFERED ;
						      /* Unmount remote drive */
						      if ( unmountdisk(drive) != NFM_S_SUCCESS )
							{
							  /* Unable to unmount remote drive */
							  _CLI_str ("%s", "NFSUnMount Failed") ;
							}
						    }
						}
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
      else
	{
	  if ( stat(n_pathname, &filestatus) !=0 )
	    {
	      /* No directory exists with name n_pathname */
	      struct_ptr -> request = NFM_E_FAILURE;
	    }
	  else
	    {
	      if (( filestatus.st_mode & S_IFDIR ) != S_IFDIR )
		{
		  /* n_pathname exists but not a directory */
		  struct_ptr -> request = NFM_E_FAILURE;
		}
	      else
		{
		  /* n_pathname exists and is a directory */
		  strcpy(localpath, n_pathname);
		  struct_ptr -> request = NFM_TRANSFERED ;
		}
	    }
	}
      if ((struct_ptr -> request == NFM_TRANSFERED) && (i != 1))
	{

	  _CLI_str ("SUCCESSFUL or i!= 1 %s\n", "") ;
	  sprintf (tmp_str, "%ld", rfilesize) ;
	  _CLI_str ("Building 1 row/1 column buffer with filesize %s\n", 
		    tmp_str) ;
	  struct_ptr = (struct NETbuffer_info *) buffer ;
	  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
	  *src = 1 ; src ++ ;      
	  columns1 = *src = 1 ; src ++ ;
	  size_of_block = (short *) src ;
	  sizes_array = (short *) ((long)src + sizeof (short)) ;
	  sizes_array [0] = strlen (tmp_str) + 1 ;
	  data = (char *) ((long) sizes_array + columns1 * sizeof (short)) ;
	  memcpy (data, (char *) tmp_str, strlen (tmp_str) +1) ;
	  data += strlen (tmp_str) + 1 ;
	  size = (long) (data - buffer) ; 
	  *size_of_block = (short) ((long)data - (long) size_of_block) ;
	  struct_ptr -> size = size ;

	}
      else
	{
	  struct_ptr = (struct NETbuffer_info *) buffer ;
	  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
	  *src = 0 ; src ++ ;      
	  *src = 1 ; 
	  size = (long) ((long) (sizeof (struct NETbuffer_info)) +
			 (long) (2*sizeof(long)));
	  struct_ptr -> size = size;
	}
      
      _CLI_str ("size of buffer sent %d\n", size) ;
      status = NETbuffer_send ((char *) buffer, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
	  return (status) ;
	}
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
      return (status) ;
    }  

  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
}

long NFMpcrm_co_files ()
{
  char *fname = "NFMpcrm_co_files" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [100] ;
  long rows, columns, status, size ;
  short	   i;
  char interaddr[31], n_username[15], n_passwd[51] ;
  char n_pathname[51], n_nfs[2], n_mountpoint[51];
  char n_fileold[128], n_cifilename[128], n_cofilename[128] ;
  char n_cifilesize[20], n_status[20];
  char doscommand[128];							
  char localpath[128], localname[256];
  struct stat filestatus;
  short statusn;
  long  size_of_path;

/*
  long lfilesize;
  char tempsendfilename[128];
*/
  _CLI_str ("ENTER %s", fname) ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src ; src ++ ;  
  columns = *src ; src ++ ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  NFM_S_SUCCESS ;
  size = (long) sizeof (struct NETbuffer_info) ;
  struct_ptr -> size = size;
  _CLI_str ("SENDING RESPONSE TO SERVER HEADER %s", "") ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  sprintf (tmp_str, "%ld", rows) ;
  _CLI_str ("number of rows %s", tmp_str) ;
  for (i=1; i<=((short)rows); i++)
    {
      sprintf (tmp_str, "%d", i) ;
      _CLI_str ("RECEVING ROW %s", tmp_str) ;
      status = NETbuffer_receive ((char *) buffer, &size) ; 
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
	  return (status) ;
	}  
      status = _NFMcheck_status () ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("operation aborted : status = <%d>", status) ;
	  break ;
	}
      _CLI_str( "file		 <%s>", tmp_str) ;
      src = (long *) buffer;
      size_of_block = (short *) buffer;
      sizes_array = (short *) ((long)src + sizeof (short)) ;
      data = (char *) ((long) sizes_array + columns * sizeof (short)) ;

      if (i == 1)
	{
	  memcpy (interaddr, data, sizes_array[0]) ;
	  _CLI_str( "internet address     <%s>", interaddr );
	  data += (long) sizes_array[0] ;
	  memcpy (n_username, data, sizes_array[1]) ;
	  _CLI_str( "user name	    <%s>", n_username );
	  data += (long) sizes_array[1] ;
	  memcpy (n_passwd, data, sizes_array[2]) ;
	  /*      _CLI_str( "password	     <%s>", n_passwd ); */
	  data += (long) sizes_array[2] ;
	  memcpy (localpath, data, sizes_array[3]) ;
	  _CLI_str( "local path           <%s>", localpath) ;
	  data += (long) sizes_array[3] ;
	  memcpy (n_nfs, data, sizes_array[4]) ;
	  _CLI_str( "NFS Available	<%s>", n_nfs );
	  data += (long) sizes_array[4] ;
	  memcpy (n_mountpoint, data, sizes_array[5]) ;
	  _CLI_str( "mountpoint	   <%s>", n_mountpoint );
	  data += (long) sizes_array[5] ;
	}

      if (i != 1)
	{
	  data += (long) sizes_array[0] + sizes_array [1] +
	    sizes_array [2] + sizes_array [3] + sizes_array [4] +
	    sizes_array [5] ;
	  memcpy (n_fileold, data, sizes_array[6]) ;
	  _CLI_str( "file old	     <%s>", n_fileold );
	  data += (long) sizes_array[6];
	  memcpy (n_cifilename, data, sizes_array[7]) ;
	  _CLI_str( "Check In File Name   <%s>", n_cifilename );
	  data += (long) sizes_array[7] ;
	  memcpy (n_cofilename, data, sizes_array[8]) ;
	  _CLI_str( "Check Out File Name  <%s>", n_cofilename );
	  data += (long) sizes_array[8] ;
	  memcpy (n_cifilesize, data, sizes_array[9]) ;
	  _CLI_str( "Check In File Size   <%s>", n_cifilesize );
	  data += (long) sizes_array[9] ;
	  memcpy (n_status, data, sizes_array[10]) ;
	  sscanf(n_status,"%d",&statusn);
	  _CLI_str( "Status	       <%s>", n_status );
	  _CLI_num ("Status <%d>", statusn) ;
	  if ((statusn==NFM_TRANSFERED) || (statusn==NFM_READ_ONLY) ||
	      (statusn==NFM_NFSED) || (statusn==NFM_DELETE_FILE) ||
	      (statusn==NFM_MOVE_MOVE_WARNING) || 
	      (statusn==NFM_MOVE_TRANSFERED))
	    {
	      /* Create File Name */
/*  CHECK IF LAST CHARACTER IN localpath is BACKSLASH */
	      size_of_path = strlen (localpath) -1 ;
	      if (localpath [size_of_path] == '\\') localpath[size_of_path]=0;
	      sprintf(localname, "%s\\%s", localpath, n_cofilename);
	       _CLI_str ("deleting %s", localname) ;
              /* Create System Call to Delete File */
	      memset(doscommand,'\0',128);
	      sprintf(doscommand,"erase %s",localname);
	      if (system(doscommand)==-1)
	        {
	          /* System call failed */
	          _CLI_str ("%s", "File Delete Failed") ;
	          struct_ptr -> request = NFM_E_FAILURE;
	        }
	      else
	        {
	          /* System call successful */
	          _CLI_str ("%s", "File Delete Successful") ;
		  if (statusn==NFM_NFSED)
		    {
	              struct_ptr -> request = NFM_NFS_UNDONE;
		    }
		  else if (statusn==NFM_READ_ONLY)
		    {
	              struct_ptr -> request = NFM_READ_DONE;
		    }
		  else
		    {
		      struct_ptr -> request = NFM_REMOVED;
                    }
	        }
	    }
	  else
	    {
	      struct_ptr -> request = (long) statusn ;
	    }
	}
      else
	{
/* i == 1 */
/*	  if ( stat(n_pathname, &filestatus) !=0 ) */
	  if ( stat(localpath, &filestatus) !=0 ) 
	    {
	      /* No directory exists with name n_pathname */
	      struct_ptr -> request = NFM_E_FAILURE;
	    }
	  else
	    {
	      if (( filestatus.st_mode & S_IFDIR ) != S_IFDIR )
		{
		  /* n_pathname exists but not a directory */
		  struct_ptr -> request = NFM_E_FAILURE;
		}
	      else
		{
		  /* n_pathname exists and is a directory */
/*		  strcpy(localpath, n_pathname); */
		  struct_ptr -> request = NFM_TRANSFERED ;
		}
	    }
	}
      struct_ptr = (struct NETbuffer_info *) buffer ;
      src = (long *) (buffer + sizeof (struct NETbuffer_info));
      size = (long) (sizeof (struct NETbuffer_info) +
		     (long) (2*sizeof (long)));
      *src = 0 ; src++;
      *src = 1 ;
      struct_ptr -> size = size;

      sprintf (tmp_str, "%d", i) ;
      _CLI_str ("SENDING RESPONSE FOR ROW %s", tmp_str) ;
      status = NETbuffer_send ((char *) buffer, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
	  return (status) ;
	}
    }
  _CLI_str ("RECEIVING RESPONSE FROM SERVER AFTER OPERATION %s", "");
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
      return (status) ;
    }  
  _CLI_str ("%s : SUCCESSFUL\n", fname) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpcfs_recv_files () 
{
  char *fname = "_NFMpcfs_recv_files";
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data ;
  long rows, columns, status, size ;
  short	   i;
  char interaddr[31], n_username[15], n_passwd[51], n_pathname[51], n_nfs[2], n_mountpoint[51];
  char n_fileold[128], n_cifilename[128], n_cofilename[128], n_cifilesize[20], n_status[20];
  char drive[2];
  char local_filename [NFM_COFILENAME+1] ;
  long move_file ;
  char doscommand[128];							
  char localpath[128], localname[256];
  struct stat filestatus;
  long size_of_path;

  _CLI_str ("ENTER %s", fname) ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src ; src ++ ;  
  columns = *src ; src ++ ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr -> request =  NFM_S_SUCCESS ;
  size = (long) sizeof (struct NETbuffer_info) ;
  struct_ptr -> size = size;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }
  for (i=1; i<=((short)rows); i++)
    {
      status = NETbuffer_receive ((char *) buffer, &size) ; 
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
	  return (status) ;
	}  
      status = _NFMcheck_status () ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("operation aborted : status = <%d>", status) ;
	  break ;
	}
      _CLI_str( "file		 <%d>", i );
      src = (long *) buffer;
      size_of_block = (short *) src ;
      sizes_array = (short *) ((long)src + sizeof (short)) ;
      data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
      memcpy (interaddr, data, sizes_array[0]) ;
      _CLI_str( "internet address     <%s>", interaddr );
      data += (long) sizes_array[0] ;
      memcpy (n_username, data, sizes_array[1]) ;
      _CLI_str( "user name	    <%s>", n_username );
      data += (long) sizes_array[1] ;
      memcpy (n_passwd, data, sizes_array[2]) ;
/*      _CLI_str( "password	     <%s>", n_passwd ); */
      data += (long) sizes_array[2] ;
      memcpy (n_pathname, data, sizes_array[3]) ;
      _CLI_str( "pathname	     <%s>", n_pathname );
      data += (long) sizes_array[3] ;
      memcpy (n_nfs, data, sizes_array[4]) ;
      _CLI_str( "NFS Available	<%s>", n_nfs );
      data += (long) sizes_array[4] ;
      memcpy (n_mountpoint, data, sizes_array[5]) ;
      _CLI_str( "mountpoint	   <%s>", n_mountpoint );
      data += (long) sizes_array[5] ;
      if (i != 1)
	{
	  memcpy (n_fileold, data, sizes_array[6]) ;
	  _CLI_str( "file old	     <%s>", n_fileold );
	  data += (long) sizes_array[6];
	  memcpy (n_cifilename, data, sizes_array[7]) ;
	  _CLI_str( "Check In File Name   <%s>", n_cifilename );
	  data += (long) sizes_array[7] ;
	  memcpy (n_cofilename, data, sizes_array[8]) ;
	  _CLI_str( "Check Out File Name  <%s>", n_cofilename );
	  data += (long) sizes_array[8] ;
	  memcpy (n_cifilesize, data, sizes_array[9]) ;
	  _CLI_str( "Check In File Size   <%s>", n_cifilesize );
	  data += (long) sizes_array[9] ;
	  memcpy (n_status, data, sizes_array[10]) ;
	  _CLI_str( "Status	       <%s>", n_status );
	  size_of_path = strlen (localpath) -1 ;
	  if (localpath [size_of_path] == '\\') localpath [size_of_path] = 0 ;
	  sprintf (local_filename, "%s\\%s", localpath, n_cofilename) ;
	  /* does file exist (n_cofilename) */
	  move_file = 1 ;
	  _CLI_str ("stat %s", local_filename);
	  if ( stat(local_filename, &filestatus) ==0 )
	    {
	      _CLI_str ("file %s exists - do not overwrite", local_filename);
	      /* yes -> is overwrite set */
	      if (!CLIoverwrite)
		{ 
		  /* no -> put failure condition */
		  struct_ptr -> request = NFM_E_LFM_NFS_EXISTS_LOCALLY ;
		  move_file = 0 ;
		} 
	    }

	  if (move_file)
	    {
	      if (n_nfs != "Y")
		{
		  /* need to ftp file */
		  if ( ftpget(interaddr,n_username,n_passwd,n_pathname,n_cifilename,localpath,n_cofilename) != NFM_S_SUCCESS )
		    {
		      /* Unable to recieve the file */
		      _CLI_str ("%s", "FTP Failed") ;
		      struct_ptr -> request = NFM_E_FAILURE;
		    }
		  else
		    {
		      /* Successful file transfer */ 
		      _CLI_str ("%s", "File Received Successfully") ;
		      struct_ptr -> request = NFM_TRANSFERED ;
		    }
		}
	      else
		{
		  /* need to remote mount drive */
		  if ( finddisk(drive) != NFM_S_SUCCESS )
		    {
		      /* No local mount point available */
		      _CLI_str ("%s", "No Local Mount Points Available") ;
		      struct_ptr -> request = NFM_E_FAILURE;
		    }
		  else
		    {
		      /* mount drive */
		      if ( mountdisk(drive,interaddr,n_username,n_passwd,n_pathname) != NFM_S_SUCCESS )
			{
			  /* Unable to mount remote drive */
			  _CLI_str ("%s", "NFSMount Failed") ;
			  struct_ptr -> request = NFM_E_FAILURE;
			}
		      else
			{
			  /* checkout_item file */
                          size_of_path = strlen(localpath) -1 ;
                          if (localpath [size_of_path] == '\\')
			    localpath[size_of_path] = 0 ;
	                  sprintf(doscommand, "copy %s\\%s %s\\%s", 
                               drive, n_cifilename, localpath, n_cofilename);
			  if ( system( doscommand ) == -1)
			    {
			      /* System call failed */
			      _CLI_str ("%s", "File Copy Failed") ;
			      struct_ptr -> request = NFM_E_FAILURE;
			    }
			  else
			    {
			      /* Successful file transfer */
			      _CLI_str ("%s", "File Received Successfully") ;
			      struct_ptr -> request = NFM_NFSED ;
			      /* Unmount remote drive */
			      if ( unmountdisk(drive) != NFM_S_SUCCESS )
				{
				  /* Unable to unmount remote drive */
				  _CLI_str ("%s", "NFSUnMount Failed") ;
				}
			    }
			}
		    }
		}
	    }
	}
      else
	{
	  if ( stat(n_pathname, &filestatus) !=0 )
	    {
	      /* No directory exists with name n_pathname */
	      struct_ptr -> request = NFM_E_FAILURE;
	    }
	  else
	    {
	      if (( filestatus.st_mode & S_IFDIR ) != S_IFDIR )
		{
		  /* n_pathname exists but not a directory */
		  struct_ptr -> request = NFM_E_FAILURE;
		}
	      else
		{
		  /* n_pathname exists and is a directory */
		  strcpy(localpath, n_pathname);
		  struct_ptr -> request = NFM_TRANSFERED ;
		}
	    }
	}
      struct_ptr = (struct NETbuffer_info *) buffer ;
      size = (long) sizeof (struct NETbuffer_info) ;
      struct_ptr -> size = size;
      _CLI_str ("size of buffer sent %d\n", size) ;
      status = NETbuffer_send ((char *) buffer, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
	  return (status) ;
	}
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
      return (status) ;
    }  

  _CLI_str ("%s : SUCCESSFUL", fname) ;
   return (NFM_S_SUCCESS) ;
}

long  NFMpcfs_undo_recv_files () 
{
  char *fname = "NFMpcfs_undo_recv_files" ;
  long status ;

  _CLI_str ("ENTER %s", fname) ;
  status = NFMpcrm_co_files () ;
  _CLI_str ("%s : EXITING", fname) ;
  return (status) ;
}

long NFMpcrm_ci_files () 
{
  char *fname = "NFMpcrm_ci_files" ;
  struct NETbuffer_info *struct_ptr ;
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, tmp_str [512];
  long rows, columns, status, size ;
  short	   i;
  char interaddr[31], n_username[15], n_passwd[51], n_pathname[51] ;
  char n_nfs[2], n_mountpoint[51];
  char n_fileold[128], n_cifilename[128], n_cofilename[128] ;
  char n_cifilesize[20], n_status[20];
  char drive[2];
  char doscommand[128];							
  char localpath[128];
  struct stat filestatus;
  short statusn;
  
  _CLI_str ("ENTER %s", fname) ;
  /* get rows and columns from header */
  struct_ptr = (struct NETbuffer_info *) buffer ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src ; src ++ ;  
  columns = *src ; src ++ ;

  /* send response for header */
  struct_ptr -> request =  NFM_S_SUCCESS ;
  size = (long) sizeof (struct NETbuffer_info) ;
  struct_ptr -> size = size;

  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
      return (status) ;
    }

  for (i=1; i<=((short)rows); i++)
    {
      status = NETbuffer_receive ((char *) buffer, &size) ; 
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
	  return (status) ;
	}  
      status = _NFMcheck_status () ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("operation aborted : status = <%d>", status) ;
	  break ;
	}
      sprintf (tmp_str, "%d", i) ;
      _CLI_str( "file		 <%s>", tmp_str) ;
      src = (long *) buffer;
      size_of_block = (short *) buffer ;
      sizes_array = (short *) ((long)buffer + sizeof (short)) ;
      data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
      memcpy (interaddr, data, sizes_array[0]) ;
      _CLI_str( "internet address     <%s>", interaddr );
      data += (long) sizes_array[0] ;
      memcpy (n_username, data, sizes_array[1]) ;
      _CLI_str( "user name	    <%s>", n_username );
      data += (long) sizes_array[1] ;
      memcpy (n_passwd, data, sizes_array[2]) ;
/*      _CLI_str( "password	     <%s>", n_passwd ); */
      data += (long) sizes_array[2] ;
      memcpy (n_pathname, data, sizes_array[3]) ;
      _CLI_str( "pathname	     <%s>", n_pathname );
      data += (long) sizes_array[3] ;
      memcpy (n_nfs, data, sizes_array[4]) ;
      _CLI_str( "NFS Available	<%s>", n_nfs );
      data += (long) sizes_array[4] ;
      memcpy (n_mountpoint, data, sizes_array[5]) ;
      _CLI_str( "mountpoint	   <%s>", n_mountpoint );
      data += (long) sizes_array[5] ;

      memcpy (n_fileold, data, sizes_array[6]) ;
      _CLI_str( "file old	     <%s>", n_fileold );
      data += (long) sizes_array[6];
      memcpy (n_cifilename, data, sizes_array[7]) ;
      _CLI_str( "Check In File Name   <%s>", n_cifilename );
      data += (long) sizes_array[7] ;
      memcpy (n_cofilename, data, sizes_array[8]) ;
      _CLI_str( "Check Out File Name  <%s>", n_cofilename );
      data += (long) sizes_array[8] ;
      memcpy (n_cifilesize, data, sizes_array[9]) ;
      _CLI_str( "Check In File Size   <%s>", n_cifilesize );
      data += (long) sizes_array[9] ;
      memcpy (n_status, data, sizes_array[10]) ;
      _CLI_str( "Status	       <%s>", n_status );
      sscanf(n_status,"%d",&statusn);

      if(statusn == NFM_DELETE_FILE || statusn == NFM_TRANSFERED ||
	 statusn == NFM_MOVE_MOVE_WARNING || 
	 statusn == NFM_MOVE_TRANSFERED  ||
	 statusn == NFM_PURGE_FILE )
	{
	  if (n_nfs != "Y")
	    {
	      /* need to delete ftp'ed file */
	      if ( ftpdel(interaddr,n_username,n_passwd,n_pathname,n_cifilename,n_pathname) != NFM_S_SUCCESS )
		{
		  /* Unable to delete the file */
		  _CLI_str ("%s", "NFMpcfs_undo_send_files : FTP Failed") ;
		  struct_ptr -> request = NFM_E_FTP_SEND_CO_FILENAME;
		}
	      else
		{
		  /* Successful file deletion */
		  _CLI_str ("%s", "NFMpcfs_undo_send_files : File Deleted Successfully") ;
		  if (statusn==NFM_MOVE_TRANSFERED)
		    {
		      struct_ptr -> request = NFM_MOVE_MOVE_UNDONE;
		    }
		  else if (statusn==NFM_PURGE_FILE)
		    {
		      struct_ptr -> request = NFM_PURGED ;
		    }
		  else 
		    {
		      struct_ptr -> request = NFM_UNDONE;
		    }
		}
	    }
	  else
	    {
	      /* need to remote mount drive */
	      if ( finddisk(drive) != NFM_S_SUCCESS )
		{
		  /* No local mount point available */
		  _CLI_str ("%s", "NFMpcfs_undo_send_files : No Local Mount Points Available") ;
		  struct_ptr -> request = NFM_E_FAILURE;
		}
	      else
		{
		  /* mount drive */
		  if ( mountdisk(drive,interaddr,n_username,n_passwd,n_pathname) != NFM_S_SUCCESS )
		    {
		      /* Unable to mount remote drive */
		      _CLI_str ("%s", "NFMpcfs_undo_send_files : NFSMount Failed") ;
		      struct_ptr -> request = NFM_E_FAILURE;
		    }	
		  else
		    {
		      /* delete file */
		      memset(doscommand,'\0',128);
		      sprintf(doscommand, "delete %s\\%s", drive, n_cifilename);
		      if ( system( doscommand ) == -1)
			{
			  /* System call failed */
			  _CLI_str ("%s", "NFMpcfs_undo_send_files : File Delete Failed") ;
			  struct_ptr -> request = NFM_E_FAILURE;
			}
		      else
			{
			  /* Successful file transfer */
			  _CLI_str ("%s", "NFMpcfs_undo_send_files : File Deleted Successfully") ;
			  if (statusn==NFM_MOVE_TRANSFERED)
			    {
			      struct_ptr -> request = NFM_MOVE_MOVE_UNDONE;
			    }
			  else if (statusn==NFM_PURGE_FILE)
			    {
			      struct_ptr -> request = NFM_PURGED ;
			    }
			  else
			    {
			      struct_ptr -> request = NFM_UNDONE;
			    }
			  /* Unmount remote drive */
			  if ( unmountdisk(drive) != NFM_S_SUCCESS )
			    {
			      /* Unable to unmount remote drive */
			      _CLI_str ("%s", "NFMpcfs_undo_send_files : NFSUnMount Failed") ;
			    }
			}
		    }
		}
	    }
	}
      else
	{
	  if ( stat(n_pathname, &filestatus) !=0 )
	    {
	      /* No directory exists with name n_pathname */
	      struct_ptr -> request = NFM_E_FAILURE;
	    }
	  else
	    {
	      if (( filestatus.st_mode & S_IFDIR ) != S_IFDIR )
		{
		  /* n_pathname exists but not a directory */
		  struct_ptr -> request = NFM_E_FAILURE;
		}
	      else
		{
		  /* n_pathname exists and is a directory */
		  strcpy(localpath, n_pathname);
		  struct_ptr -> request = NFM_TRANSFERED ;
		}
	    }
	}
      
      struct_ptr = (struct NETbuffer_info *) buffer ;
      src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
      *src = 0 ; src ++ ;      
      *src = 1 ; 
      size = (long) ((long) (sizeof (struct NETbuffer_info)) +
	       (long) (2*sizeof(long)));
      struct_ptr -> size = size;
      
      _CLI_str ("size of buffer sent %d\n", size) ;
      status = NETbuffer_send ((char *) buffer, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("NETbuffer_send failed : status = <%d>", status) ;
	  return (status) ;
	}
    }
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
      return (status) ;
    }  

  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
}

long NFMpcfs_chg_files () 
{
  char *fname = "NFMpcfs_chg_files" ;
  long status ;

  _CLI_str ("ENTER %s", fname) ;
   status=NFM_S_SUCCESS;
  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

long  NFMpcfs_undo_chg_files () 
{
  char *fname = "NFMpcfs_undo_chg_files" ;
  long status ;

  _CLI_str ("ENTER %s", fname) ;
  status=NFM_S_SUCCESS;
 _CLI_str ("%s : SUCCESSFUL", fname) ;
   return (status) ;
}

long NFMpcfs_purge () 
{
  char *fname = "NFMpcfs_purge" ;
  long status ;

  _CLI_str ("ENTER %s", fname) ;
  status = NFMpcrm_ci_files () ;
  _CLI_str ("%s : EXITING", fname) ;
  return (status) ;
}

long NFMpcfs_undo_send_files ()
{
  char *fname = "NFMpcfs_undo_send_files" ;
  long status ;

  _CLI_str ("ENTER %s", fname) ;
  status = NFMpcrm_ci_files () ;
  _CLI_str ("%s : EXITING", fname) ;
  return (status) ;
}

long  NFMpcfs_attached_files ()
{
  char *fname = "NFMpcfs_attached_files" ;
  char *list = NULL ;
  long size, status, *src ;
  /*char str [100] ;*/
  char tmp_str [50], delimiter ;
  char filename [NFM_FILENAME+1] ;
  char path [NFM_FILENAME+1], *data ;
  long rows, columns ;
  short *size_array_ptr ;
  struct NETbuffer_info *struct_ptr ;
  long  _NFMsend_buf_pc_fs_by_row () ;

  FILE 	*input_file,           /* Input design file  	            */
	*fopen();               /* I/O routine                 	    */

  char 	/* *ptr,	 place holder				    */
 /*	cellib[15],	 attached cell library		    */
	refFile[66],	/* reference file name			    */
/*	colorTable[33],  attached color table file		    */
	dgnfile[255];    /* design file name                         */

  short	words;	/* words read by fread				    */
 /*	length;	length of ascii string returned from rd2asc	    */

  unsigned long startbuf = 0,	/* file position of start of buffer */
		endbuf = 0,	/* file position of end of buffer   */
		bufpos = 0,	/* words offset within the buffer   */
		curpos = 0;	/* current file position in bytes   */

/** mms - added 5/15/92 ** problem with boundaries **/
  long skip ;

  _CLI_str ("%s : ENTER", fname) ;
  status = NFM_S_SUCCESS ;


  /* get rows and columns from header */
  struct_ptr = (struct NETbuffer_info *) buffer ;
  sprintf (tmp_str, "address of buffer is %d", buffer) ;

  _CLI_str ("%s", tmp_str) ;
  src = (long *) ((char *) buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src ; src ++ ;
  columns = *src ; src ++ ;
  sprintf (tmp_str, "address of src is %d", src) ;
  _CLI_str ("%s", tmp_str) ;
  sprintf (tmp_str, "%ld", rows) ;
  _CLI_str ("rows are %s", tmp_str) ;
  sprintf (tmp_str, "%ld", columns) ;
  _CLI_str ("columns are %s", tmp_str) ;

  size_array_ptr = (short *) ((char *)src + sizeof (short));
  sprintf (tmp_str, "address of size_array_ptr is %d", size_array_ptr) ;
  _CLI_str ("%s", tmp_str) ;
  data = (char *) size_array_ptr + (columns*sizeof(short)) ;
  sprintf (tmp_str, "address of data is %d", data) ;
  _CLI_str ("%s", tmp_str) ;
  strncpy (path, data, *size_array_ptr) ;
  data += *size_array_ptr ;
  ++size_array_ptr ;
  strncpy (filename, data, *size_array_ptr) ;
 
  _CLI_str ("path is %s\n", path) ;
  _CLI_str ("filename is %s\n", filename) ;

/******** what happen if path end in \ **************/
  delimiter = '\\' ;
  sprintf (dgnfile, "%s%c%s", path, delimiter, filename) ;

   status = _NFMpc_build_buffer (&list,  1);
  if (status != NFM_S_SUCCESS)
    {
      return (NFM_E_MESSAGE) ;
    }
  
  input_file=fopen(dgnfile,"rb");

  if (!input_file)
    {
      if (list) free (list) ;
      printf ("\ncan't open file, %s\n", dgnfile) ;
      return (NFM_E_FAILURE) ;
    }

  skip = 0 ;
  while (!FEOF && !EOD)
    {
      fseek (input_file, curpos, 0);
      words = fread(&buf,2,6144,input_file);  
      startbuf = curpos;
      endbuf = startbuf + (words * 2);
      bufpos = 0;
      element = (MSElement *)&buf[bufpos];
      if ((buf[bufpos] & 0x8000) == 0x8000)
	{
	  _CLI_str ("This element has been deleted%s", "") ;
	}
      else if (WTF > 766)
	{
	  fclose (input_file);
	  _CLI_str ("MS element greater than 768 words : Not a design file") ;
	  status = NFM_E_NO_END_OF_DESIGN ;
	  return (status) ;
	}
      while ((curpos + (WTF + 2) * 2) < endbuf && !EOD)
   	{
/* AMIT - We are not concerned with cell libraries
	  if (FILE_HEADER)
	    {
	      ptr = &cellib[0];
              memset(ptr, ' ', 15);
	      length = 9;
	      r50asc(length, &element->buf[632], ptr);
	      ptr = strchr(cellib, ' ');
	      if (ptr != &cellib[0])
		{
		  if (ptr) *ptr = '.';
		  length = 3;
		  ptr++;
		  r50asc(length, &element->buf[635], ptr);
		  ptr = strchr(cellib, ' ');
		}
	      if (ptr) *ptr = '\0';
	      NFMstrlwr(cellib);
	      if (!strlen(cellib))
		printf ("\nNo cell library attached");
	      else
		printf("\ncell library = %s", cellib);
	    }
************/

	  if ((!skip) && (REF_ATTACH))
	    {
	      memset(&refFile[0], ' ', 65);
	      memcpy (&refFile[0], &element->buf[19], element->buf[18]);
	      refFile[element->buf[18]] = '\0';
/*	      printf ("    Reference file name = %s\n", refFile); */
	      _CLI_str ("Reference file name = %s", refFile) ;
	      sprintf (tmp_str, "%s\001", refFile) ;
  	      status = _NFMpc_write_row (&list, tmp_str) ;
              if (status != NFM_S_SUCCESS)
              {
                return (status) ;
              }      
	    }
/* AMIT - We are not concerned with color tables
	  if (COLOR_TABLE)
	    {
	      memset(&colorTable[0], ' ', 33);
	      memcpy(&colorTable[0], &element->buf[404], element->buf[403]);
	      colorTable[element->buf[403]] = '\0';
	      printf("\ncolor table file name = %s\n", colorTable);
	    }
***********************************/
	  skip = 0 ;
	  /* mms - According to Nancy McCall WTF (Word to found) is always the second word (16 bits) of the element */
	  if ((curpos + (WTF + 2) * 2 + 6) >= endbuf)
	    {
/***
	      _NFMdebug ((fname, "curpos <%d> : WTF <%d> : endbuf <%d>\n",
			  curpos, WTF, endbuf)) ;
***/
	      skip = 1 ;
	      break ;
	    }

    	  bufpos += WTF + 2;
	  curpos += (WTF + 2)*2;
	  element = (MSElement *)&buf[bufpos];
	  if (buf[bufpos] == 0xffff)
	    {
	      _CLI_str ("Encountered END OF FILE%s", "") ;
	    }
	  else if ((buf[bufpos] & 0x8000) == 0x8000)
	    {
	      _CLI_str ("This element has been deleted%s","") ;
	    }
	  else if (WTF > 766)
	    {
	      fclose (input_file);
	      _CLI_str ("MS element greater than 768 words : Not a design file") ;
	      status = NFM_E_NO_END_OF_DESIGN ;
	      return (status) ;
	    }
	}
    }

/* AMIT - Whether or not EOD exists is not relevant
  if (!EOD)
    printf("\nError -- Design file has no end-of-design marker.\n");
*/
/*DT removed 3/22/92
  printf ("closing %s\n", input_file) ;
*/
  fclose(input_file);

  /* send files one by one */
  status = _NFMsend_buf_pc_fs_by_row (list) ;
  if (status != NFM_S_SUCCESS)
    {
      free (list) ;
      _CLI_str ("NFMsend buf pc fs by row failed\n") ;
      return (status) ;
    }
  
  free (list) ;
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("NETbuffer_receive failed : status = <%d>", status) ;
      return (status) ;
    }  

  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (status) ;
}

/*----------------------------------------------------------------------+
|                                                                       |
| name          r50asc - convers radix 50 input to ascii string output  |
|                                                                       |
| author        BJB                                     2/86            |
|                                                                       |
+----------------------------------------------------------------------*/
void r50asc (length, input, output)
int	length;         /* => maximum length of output string
                            (excluding terminator). Should be multiple of 3 */
short	*input;         /* => radix 50 to be converted */
char	*output;        /* <= output string */

{
	int		i, j;
	unsigned short	temp1, temp2;
	char		*out;

	for (i=0; i<(length+2)/3; i++)
        {
		temp1 = *input++;

		for (j=0, out=output+2; j<3; j++)
		{
			temp2 = temp1 % 40;
			temp1 /= 40;

			if (temp2 == 0) *out-- = ' ';
			else if (temp2 <= 26) *out-- = 'A' - 1 + temp2;
			else if (temp2 == 27) *out-- = '$';
			else if (temp2 == 28) *out-- = '.';
			else if (temp2 == 29) *out-- = '_';
			else *out-- = temp2 + '0' - 30;
		}
		output += 3;
	}
	*output = '\0';
}

long  _NFMsend_buf_pc_fs_by_row (list)
     char *list ;
{
  char *fname = "_NFMsend_buf_pc_fs_by_row" ;
  long status, size, size_to_send, size_rcd ;
  short *block_size_ptr ;
  char *new_ptr ;
  struct NETbuffer_info *struct_ptr ;
  long row_no ;
  char tmp_str [512];

  _CLI_str ("%s : ENTER", fname) ;

  if (!list)
    {
      _CLI_str ("%s : buffer is empty", fname) ;
      return (NFM_S_SUCCESS) ;
    }

  size = (long) (sizeof (struct NETbuffer_info) + (2*sizeof (long))) ;

  struct_ptr = (struct NETbuffer_info *) list ;
  size_to_send = struct_ptr -> size - size ;
  new_ptr = (char *) list + size ;
  _CLI_str ("%s : SENDING HEADER OF BUFFER", fname) ;
  status = NETbuffer_send ((char *) list, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      return (status) ;
    }
  _CLI_str ("%s : RECEVING RESPONSE OF BUFFER", fname) ;
  status = NETbuffer_receive ((char *) buffer, &size) ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("failed receiving buffer %s", "") ;
      return (status) ;
    }  
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      _CLI_str ("error with response of client %s", "") ;
      return (NFM_E_FAILURE) ;
    }

  /* send all rows one row at a time */
  row_no = 1 ;
  while (size_to_send != 0)
    {
      sprintf (tmp_str, "%d", row_no) ;
      _CLI_str ("SENDING ROW %s", tmp_str) ;
      block_size_ptr = (short *) new_ptr ;
      size = (long) *block_size_ptr ;
      size_to_send = size_to_send - size ;

      status = NETbuffer_send ((char *) new_ptr, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  return(status) ;
	}
      
      _CLI_str ("Waiting for client response...%s", "") ;
      status = NETbuffer_receive ((char *) buffer, &size_rcd) ; 
      if (status != NFM_S_SUCCESS)
	{
	  return (status) ;
	}  
      
      struct_ptr = (struct NETbuffer_info *) buffer ;
      status = struct_ptr -> request ; 

      new_ptr = (char *) (new_ptr + size) ;
      ++row_no ;
    }
  
  _CLI_str ("%s : SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMpc_display_items ()
{
  char *fname = "_NFMpc_display_items" ;
  long status, size, i ;
  short *size_array_ptr ;
  char *data, *str ;
  struct NETbuffer_info *struct_ptr ;
  long rows, cols, *long_ptr, y ;
  FILE *fd ;

  _CLI_str ("%s : ENTER", fname) ;

  /* open file for append */
  fd = fopen (CLIdisplay_file, "a") ;
  if (fd == NULL)
  {
     return (status) ;
  }

/****** get rows and columns *******/
  struct_ptr  = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ;
  long_ptr = (long *) (buffer+ sizeof (struct NETbuffer_info)) ;
  rows = *long_ptr ; ++long_ptr ;
  cols = *long_ptr ;
  _CLI_num ("rows sent by client  %d", rows) ;
  _CLI_num ("cols sent by client %d", cols) ;
  
/******* send response *************/
  size = sizeof (struct NETbuffer_info) ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr->size = size ;
  struct_ptr -> request = NFM_S_SUCCESS ;

  _CLI_num ("send response (0x%.8x) from header...", NFM_S_SUCCESS) ;
  status = NETbuffer_send ((char *) buffer, &size) ;
  if (status != NFM_S_SUCCESS)
    {
      _CLI_num ("buffer send failed : status = <0x%.8x>\n",
		  status) ;
      return (status) ;
    }

  str = (char *) malloc (cols * 100) ;
  if (str == NULL)
    {
      _CLI_str ("%s : malloc failed", fname) ;
      return (NFM_E_MALLOC) ;
    }

/* check for aborts */

  fprintf (stderr, "Please wait ... retrieving %d items\n",
	   rows) ;

  /* receive all rows one row at a time */
  for (i=0; i<rows; i++)
    {
      _CLI_num ("RECEIVING ROW %d. Waiting for client ...", 
		  i+1) ;
      status = NETbuffer_receive ((char *) buffer, &size);
      if (status != NFM_S_SUCCESS) 
	{
	  free (str) ;
	  _CLI_num ("buffer receive failed : status = <0x%.8x>\n",
		      status) ;
	  return (status) ;
	} 

      status = _NFMcheck_status () ;
      if (status != NFM_S_SUCCESS)
	{
	  _CLI_str ("operation aborted : status = <%d>", status) ;
	  break ;
	}

      size_array_ptr = (short *) (buffer+sizeof(short)) ;
      data = ((char *) size_array_ptr +  (cols * sizeof (short))) ;
      str [0] = 0 ;
      for (y=0; y<cols; y++)
	{
	  strcat (str, data) ;
	  strcat (str, " : ") ;
	  data += *size_array_ptr ;
	  ++size_array_ptr ;
	}
      /**** write row to file *******/
      fprintf (fd, "%s\n", str) ;
      
      struct_ptr = (struct NETbuffer_info *) buffer ;
      struct_ptr -> request  = NFM_S_SUCCESS ;
      size = struct_ptr -> size = sizeof (struct NETbuffer_info *) ;
      _CLI_str ("Sending RESPONSE to client..") ;
      status = NETbuffer_send ((char *) buffer, &size) ;
      if (status != NFM_S_SUCCESS)
	{
	  free (str) ;
	  _CLI_num ("buffer send failed : status = <0x%.8x>",
		      status) ;
	  return (status) ;
	}
    }  /* for */

  free (str) ;
  fclose (fd) ;

  _CLI_str ("RECEIVING COMMAND. Waiting for client ...");
  status = NETbuffer_receive ((char *) buffer, &size);
  if (status != NFM_S_SUCCESS) 
  {
    _CLI_num ("buffer receive failed : status = <0x%.8x>\n",
	      status) ;
    return (status) ;
  } 

  _CLI_str ("%s  :SUCCESSFUL", fname) ;
  return (NFM_S_SUCCESS) ;
}




