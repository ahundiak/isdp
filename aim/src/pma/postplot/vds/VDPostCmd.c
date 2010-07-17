/* $Id: VDPostCmd.c,v 1.1 2002/05/31 16:30:59 tlstalli Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdproot/PostCmd.c
 *
 * Description:
 *		Support routines for E4R for AIM connections.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDPostCmd.c,v $
 *	Revision 1.1  2002/05/31 16:30:59  tlstalli
 *	Backup of PMA process from EXTR
 *	
 *	Revision 1.2  2001/02/15 16:45:09  build
 *	Replaced v_dbgmacros.h file with vedbgmacros.h file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:25  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/11/15  15:29:06  pinnacle
 * initial revision
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/11/13  19:24:46  pinnacle
 * Created: vdproot/VDPostCmd.c by v250_int for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			tls		creation date
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#if defined(CLIX) || defined (X11)
#include <netinet/in.h>
#include <netdb.h>
#endif  /* CLIX */

#include "OMerrordef.h"
#include "OMminimum.h"

#include "vedbgmacros.h"


#define CLIX_CONNECT    -1
#define CLIX_DISCONNECT -2

#define SIZE	256


int VDP_connect_status(char *server_name, int connection, int *conn_status) 
{

  int status = 0;
  struct hostent *h = NULL;
  char *errmsg = NULL;
  int dstat = 0;

  SetProc( VDP_connect_status ); Begin

  /*****  change the server name to a net address *************/

    __DBGpr_str(" server_name ", server_name);
  
    h = gethostbyname(server_name);

    if(h)
    {
      __DBGpr_com("h has a value");
    }
    else
    {  
        __DBGpr_com( "Server not recognised");
        *conn_status = 1;
        return(1);
    }

    /* set the PROXY_CLIENT_ADDRESS */
/*
    sprintf(envstring,"PROXY_CLIENT_ADDRESS=%s",
			inet_ntoa(*((struct in_addr *)h->h_addr)));

    __DBGpr_str(" export ", envstring );

    if(putenv( envstring ) != NULL )
    {
       __DBGpr_com("Unable to set the environment variable");
       *conn_status = 1;
       return(1);
    }
*/


   if( connection == 0 )
   {
     __DBGpr_com("Before connecting to Postman.");
     dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT, (char *)inet_ntoa(*((struct in_addr *)h->h_addr)), NULL, NULL, NULL, &errmsg);

     __DBGpr_int("dstat ", dstat);

     if( (dstat != 0) || (*errmsg) )
     {
       *conn_status = 1;
       status = 1;
       __DBGpr_int("dstat ", dstat);
       if(errmsg)
         __DBGpr_str("errmsg ", errmsg);
     }
     __DBGpr_com("after Postman CONNECT");

   }

   if( connection == 1)
   {
       __DBGpr_com("Before Postman DISCONNECT if connected");
       dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT, NULL, NULL,
                                            NULL, NULL, &errmsg);
       if( (dstat != 0) || (errmsg) )
       {
         __DBGpr_int("dstat ", dstat);
         if(errmsg)
           __DBGpr_str("errmsg ", errmsg);
         *conn_status = 1;
         status = 1;
       }
   }

	End
	return status;

}

int VDP_send_verify_cmd(char *filename, char *wlname)
{
  int status = 0;
  int inlen=0, outlen=0, code=0, *p_code=NULL, dstat=0, mfail=0;
  char inbuf[512], *errmsg=NULL, *temp_str=NULL, *outbuf=NULL;
  char *temp = NULL, tmpfile[256];

  SetProc( VDP_send_verify_cmd ); Begin

  if(filename == NULL)
  {
     __DBGpr_com("filename is null.");
    return(1); 
  }
  else
  {
    /* take off the extension */
    sprintf(tmpfile,"%s", filename);
    temp = strtok(tmpfile, ".");
  } 
    /* send command to PME */
     
    inlen = 4;
    code = 1;
    p_code = &code;
    
    temp_str = (char *) malloc(SIZE);
    memcpy((void *) inbuf, (void *) p_code, sizeof(int));
    sprintf(temp_str, "%s*%s", temp, wlname );
    strcpy(inbuf + 4, temp_str);
    inlen = inlen + strlen(inbuf+4) +1 ;

    __DBGpr_str("temp_str : ", temp_str  );
    __DBGpr_int("inlen ", inlen);

    __DBGpr_com("Sending the verify command to AIM....................");

    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,&outbuf, &mfail, &errmsg);
    __DBGpr_int("dstat ", dstat);
    if(dstat != 0)
      status = 1; 

    if (mfail != 0 )
    {
      if(*errmsg)
      {
       __DBGpr_str("errmsg ", errmsg); 
      }
      status = mfail;
      return (status);
    }


    if(temp_str)
      free(temp_str);

  End
  return status;
}


int VDP_send_ctx_verify_cmd(char *contexid, int chkcode)
{
  int status = 0;
  int inlen=0, outlen=0, code=0, *p_code=NULL, dstat=0, mfail=0;
  char inbuf[512], *errmsg=NULL, *temp_str=NULL, *outbuf=NULL;
  char *temp = NULL, tmpfile[256];

  SetProc( VDP_send_verify_cmd ); Begin

  if(filename == NULL)
  {
     __DBGpr_com("filename is null.");
    return(1); 
  }
    /* send command to PME */
     
   /*
    * Send Cmd to AIM through Postman to:
    *      1.  register and attach the extracted files into AIM
    */
     code = chkcode;
     inlen = 0;
     index = 0;
     temp_str = (char *) malloc(INPUT_SIZE);
     if(temp_str == NULL)
     {
       printf("ERROR in memory allocation for temp_str.\n");
     }

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     strcpy( &inbuf[index], contexid );
     inlen += strlen(contexid) +1;
     index = inlen;

    __DBGpr_int("inlen ", inlen);

    __DBGpr_com("Sending the verify command to AIM....................");

     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     __DBGpr_int("dstat ", dstat);
     if(dstat != 0)
     {
       __DBGpr_int("dstat is bad. dstat ", dstat);
       status = 1;
     }

     if (mfail != 0 )
     {
       if(*errmsg)
       {
         __DBGpr_str("errmsg ", errmsg);
       }
       __DBGpr_int("mfail is bad.  mfail =  ", mfail);
       status = mfail;
       return (status);
     }


    if(temp_str)
      free(temp_str);

  End
  return status;

}

int VDP_send_post_cmd(char *filename, char *server, char *catalog,
			char *partno, char *revision, 
			int chkcode, char *ctxid)
{
  int    status=0, index=0 ;
  int    inlen=0, code=0, *p_code=NULL, dstat=0, mfail=0, outlen=0;
  char   inbuf[512], *errmsg=NULL, *temp_str=NULL, *outbuf=NULL;
  char   *temp = NULL, tmpfile[256];

  SetProc( VDP_send_post_cmd ); Begin

  if ( 	( filename == NULL ) || 
	( server == NULL ) || 
	( catalog == NULL ) || 
	( partno == NULL ) || 
	( revision == NULL ) || 
	( chkcode == 0 ) ||
	( ctxid == NULL )  )
  {
     __DBGpr_com("Invalid input argument for posting process.");
     return (1);
  }
  else
  {
    /* take off the extension on the filename */
    sprintf(tmpfile,"%s", filename);
    temp = strtok(tmpfile, ".");
  } 

   /*
    * Send Cmd to AIM through Postman to:
    *      1.  register and attach the extracted files into AIM
    */
     code = chkcode;
     inlen = 0;
     index = 0;
     temp_str = (char *) malloc(INPUT_SIZE);
     if(temp_str == NULL)
     {
       printf("ERROR in memory allocation for temp_str.\n");
     }

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     strcpy( &inbuf[index], temp );
     inlen += strlen(filename) +1;
     index = inlen;

     strcpy( &inbuf[index], server );
     inlen += strlen(server) +1;
     index = inlen;

     strcpy( &inbuf[index], catalog );
     inlen += strlen(catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], partno );
     inlen += strlen(partno) +1;
     index = inlen;

     strcpy( &inbuf[index], revision );
     inlen += strlen(revision) +1;
     index = inlen;

     strcpy( &inbuf[index], filetype );
     inlen += strlen(filetype) +1;
     index = inlen;

     strcpy( &inbuf[index], ctxid );
     inlen += strlen(ctxid) +1;
     index = inlen;


     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     __DBGpr_int("dstat ", dstat);
     if(dstat != 0)
     {
       __DBGpr_int("dstat is bad. dstat ", dstat);
       status = 1;
     }

     if (mfail != 0 )
     {
       if(*errmsg)
       {
         __DBGpr_str("errmsg ", errmsg);
       }
       __DBGpr_int("mfail is bad.  mfail =  ", mfail);
       status = mfail;
       return (status);
     }


    if(temp_str)
      free(temp_str);


  End
  return status;

}


int VDP_copy_cmd(char *localpath, char *exportDir, char *filename)
{
  
  int           x=0, status=0, ext_cnt=6, check=0;
  char          *ext[6] = {"tbl", "drv", "dgn", "dst", "log", "dri"};
  char          file[256], dgnfile[256], tmpfile[256], temp[256];
  char          *tmp = NULL, workdir[256];

  SetProc( VDP_copy_cmd ); Begin

  /* take off the extension */
  sprintf(tmpfile,"%s", filename);
  tmp = strtok(tmpfile, ".");
  sprintf(dgnfile,"%s", tmp);

  sprintf(workdir, "%s/", exportDir);

  if( (check = strcmp(localpath, workdir)) != 0)
  {
    	/* copy the file over to the work location */
  	for(x = 0; x < ext_cnt; x++)
  	{
    		sprintf(file, "%s%s.%s", localpath, dgnfile, ext[x]);

    		/* copy the file over to the work location */
    		sprintf(temp, "cp %s %s", file, exportDir);
    		status = system(temp);
    		if(status != 0)
    		{
      			status = OM_E_ERROR;
      			return status;
    		}
	}
  }

    temp[0] = '\0';

    sprintf(temp, "chmod a+rw %s/%s.*", exportDir,dgnfile);
    __DBGpr_str("temp ", temp); 
    status = system(temp);
    if(status != 0)
    {
      printf("Change permissions on files failed.\n");
      status = OM_E_ERROR;
      return status;
    }

  status = OM_S_SUCCESS;

  End
  return status;

}

int VDP_remove_cmd(char *exportDir, char *filename)
{

  int 		status=0;
  char          temp[256], *file = NULL, tmpfile[256];

  SetProc( VDP_remove_cmd ); Begin

  /* take off the extension */
  sprintf(tmpfile,"%s", filename);
  file = strtok(tmpfile, ".");
  
  sprintf(temp, "rm %s/%s.dri", exportDir, file);
  status = system(temp);

  temp[0] = '\0';
  sprintf(temp, "rm %s/%s.htm", exportDir, file);
  status = system(temp);

  status = OM_S_SUCCESS;

  End
  return status;

}
