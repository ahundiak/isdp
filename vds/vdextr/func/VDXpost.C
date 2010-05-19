/* $Id: VDXpost.C,v 1.3 2001/02/15 01:12:07 ramarao Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdextr/func/VDXpost.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDXpost.C,v $
 *      Revision 1.3  2001/02/15 01:12:07  ramarao
 *      Removed v_dbgmacros.h file.
 *
 *      Revision 1.2  2001/02/15 01:10:30  ramarao
 *      Removed v_dbgmacros.h file.
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/16/99        ylong           created
 *
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

#define CLIX_CONNECT    -1
#define CLIX_DISCONNECT -2

#define PME_SIZE	256


int VDXconn_status(char *server_name, int connection, int *conn_status) 
{

  int status = 0;
  char envstring[50];
  struct hostent *h = NULL;
  char *errmsg = NULL;
  int dstat = 0;

  //SetProc( VDXconn_status ); Begin

  /*****  change the server name to a net address *************/

    //__DBGpr_str(" server_name ", server_name);
  
    h = gethostbyname(server_name);

    if(h)
    {
      //__DBGpr_com("h has a value");
    }
    else
    {  
        //__DBGpr_com( "Server not recognised");
        *conn_status = 1;
        return(1);
    }

    /* set the PROXY_CLIENT_ADDRESS */
/*
    sprintf(envstring,"PROXY_CLIENT_ADDRESS=%s",
			inet_ntoa(*((struct in_addr *)h->h_addr)));

    //__DBGpr_str(" export ", envstring );

    if(putenv( envstring ) != NULL )
    {
       //__DBGpr_com("Unable to set the environment variable");
       *conn_status = 1;
       return(1);
    }
*/


   if( connection == 0 )
   {
     //__DBGpr_com("Before Postman CONNECT");
     dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT, (char *)inet_ntoa(*((struct in_addr *)h->h_addr)), NULL, NULL, NULL, &errmsg);

     if( (dstat != 0) || (*errmsg) )
     {
       *conn_status = 1;
       status = 1;
       //__DBGpr_int("dstat ", dstat);
       if(errmsg);
         //__DBGpr_str("errmsg ", errmsg);
     }
     //__DBGpr_com("after Postman CONNECT");

   }

   if( connection == 1)
   {
       //__DBGpr_com("Before Postman DISCONNECT if connected");
       dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT, NULL, NULL,
                                            NULL, NULL, &errmsg);
       if( (dstat != 0) || (errmsg) )
       {
         //__DBGpr_int("dstat ", dstat);
         if(errmsg)
           //__DBGpr_str("errmsg ", errmsg);
         *conn_status = 1;
         status = 1;
       }
   }

	//End
	return status;

}

int VDXsend_cmd(char *server_name, char *vds_id, 
                char *file_id, char **outbuf, int *outlen)
{
  int status = 0;
  char envstring[50];
  struct hostent *h = NULL;
  int inlen=0, code=0, *p_code=0, dstat=0, mfail=0;
  char inbuf[512], *errmsg=NULL, *temp_str=NULL;

  //SetProc( VDXsend_cmd ); Begin

  *outbuf = NULL;

  if(file_id == NULL)
  {
     //__DBGpr_com("file_id is null.");
    return(1); 
  }

  /*****  change the server name to a net address *************/
/*
    h = gethostbyname(server_name);

    if(h)
    {
       //__DBGpr_com("h has a value");
    }
    else
    {
        //__DBGpr_com("Server not recognised"); 
	return(1);
    }


    sprintf(envstring,"PROXY_CLIENT_ADDRESS=%s",
                        inet_ntoa(*((struct in_addr *)h->h_addr)));

    //__DBGpr_str(" export ", envstring );

    if(putenv( envstring ) != NULL )
    {
       //__DBGpr_com("Unable to set the environment variable");
       return(1);
    }
*/
    /* send command to PME */
    
     
    inlen = 4;
    code = 70;
    p_code = &code;
    
    temp_str = (char *) malloc(PME_SIZE);
    memcpy((void *) inbuf, (void *) p_code, sizeof(int));
    sprintf(temp_str, "%s*%s", vds_id, file_id );
    strcpy(inbuf + 4, temp_str);
    inlen = inlen + strlen(inbuf+4) +1 ;

    //__DBGpr_str("temp_str : ", temp_str  );
    //__DBGpr_int("inlen ", inlen);
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, outlen,
                                       outbuf, &mfail, &errmsg);
    //__DBGpr_int("dstat ", dstat);
    if(dstat != 0)
      status = 1; 

    if(*errmsg)
    {
      //__DBGpr_str("errmsg ", errmsg); 
      status = 1;
    }

    if(outbuf)
    {
    	if(*outbuf)
    	{
      		//__DBGpr_str("outbuf ", *outbuf);
      		//__DBGpr_int("outbuf ", (int *) *outbuf);
      		//__DBGpr_int("outlen ", *outlen);
    	}      
    	else
    	{
      		status = 1;
    	}
    }
    else
    {
    	status = 1;
    }

    if(temp_str)
      free(temp_str);

  //End
  return status;
}


