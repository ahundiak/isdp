/***************************************************************************
 *
 * File:	AIMpost.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: AIMpost.c,v $
 *	Revision 1.1  2002/05/31 16:28:07  tlstalli
 *	Backup of PMA process from EXTR
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:22  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:43:50  pinnacle
 * EXTR 2.5.1
 *
 * Revision 1.1  1997/11/04  18:53:50  pinnacle
 * e4r 2.5
 *
 * Revision 1.1  1997/10/17  15:16:44  pinnacle
 * Extract For Review 2.5
 *
 * Revision 1.1  1997/04/15  21:55:34  pinnacle
 * New Extract for Review 02.04.02.00
 *
 * Revision 1.2  1996/4/07  15:50:26  pinnacle
 * (No comment)
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/
#include <stdio.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <string.h>
#include <stdlib.h>

#define CLIX_CONNECT	-1
#define CLIX_DISCONNECT -2 
#define SIZE		4096

/*****************************************************************
* This is the main program                                       *
* argv[1] = extraction file name					 *
* argv[2] = server name						 *
*****************************************************************/
main(int argc, char *argv[])
{
  int   inlen=0, outlen = 0, dstat = 0, mfail = 0, code = 0;
  char  inbuf[512], *errmsg = NULL, *outbuf = NULL;
  int   *p_code = NULL, status = 0;
  char  *temp_str = NULL, *temp = NULL, tmpfile[80];
  FILE  *ptr = NULL, *file_ptr = NULL;
  char	server_name[25], extract_name[25];
  struct hostent *h = NULL;
  char  log[80], rmtmp[80], wlname[128], tmp[128];

  /* make sure that we have the right number os arguments */
  if(argc == 4)
  {
    /* make sure that the extraction set is located */
    file_ptr = fopen(argv[1], "r");
    if(file_ptr == NULL)
    {
      printf("\n");
      printf("The extraction set can not be found\n");
      printf("ERROR occurred.  Process has been terminated.\n");
      printf("\n");
      exit(0);
    }

    /* create the log file to print out user information */
    strcpy(log, "./AIMpost.log");
    
    ptr = fopen( log, "w+"); 
    if(ptr == NULL)
      printf("Can not create log file for posting extracted files\n");


    /* take off the extension  on the extraction name ( if any )*/
    sprintf(tmpfile,"%s", argv[1]);
    temp = strtok(tmpfile, ".");

    sprintf(extract_name, "%s", temp);
    sprintf(server_name, "%s", argv[2]);
    sprintf(wlname, "%s", argv[3]);
    fprintf(ptr,"Extraction Set Name :  %s\n", extract_name);
    fprintf(ptr,"Server Name :  %s\n", server_name);
    fprintf(ptr,"Work Location Name :  %s\n", wlname);

    /* change the permissions on the extraction set */
    sprintf(tmp, "chmod a+rw %s.*", extract_name);
    status = system(tmp);
    if(status != 0)
    {
      printf("FAILED ON ACCESSING EXTRACTION SET.  PERMISSION DENIED...\n");
      printf("Check the file permissions on the extraction set.\n");
      printf("The extraction set should have read and write permissions.\n");
      fprintf(ptr,"FAILED ON ACCESSING EXTRACTION SET.  PERMISSION DENIED...\n");
      fprintf(ptr,"Check the file permissions on the extraction set.\n");
      fprintf(ptr,"The extraction set should have read and write permissions.\n");
      if(ptr)
        fclose(ptr);
      exit(0);
    }
    /* get the servers ip address */
    h = gethostbyname(server_name);
    if(h == NULL)
    {
      fprintf(ptr,"Server not recognised\n");
      printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
      if(ptr)
        fclose(ptr);
      exit(0);
    }
   
    /* Connect to the Server through the postman */
    fprintf(ptr, "Connecting to DM2.................\n");
    fflush(ptr);
 
    dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT, (char *)inet_ntoa(*((struct in_addr *)h->h_addr)), NULL, NULL, NULL, &errmsg);

    if(dstat != 0) 
    {
      fprintf(ptr, "Error in connecting to server.\n");
      fprintf(ptr, "DM2 Return Status : %d\n", dstat);
      fprintf(ptr, "DM2 Error Message : %s\n", errmsg);
      printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
      if(ptr)
        fclose(ptr);
      exit(0);
    }

    fprintf(ptr, "Connected...........................\n");
    fflush(ptr);

/*
 * Send Cmd to DM2 through Postman to:
 *	1. Verify the extraction filename 
 *	2. Verify the work location, vault and vault location 
 */

     inlen = 4;
     code = 1;
     p_code = &code;

     temp_str = (char *) malloc(SIZE); 
     if(temp_str == NULL)
     {
       fprintf(ptr, "ERROR in memory allocation.\n");
       fflush(ptr);
       printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
       goto disconnect;
     }
     memcpy((void *) inbuf, (void *) p_code, sizeof(int));
     sprintf(temp_str, "%s*%s", extract_name, wlname);
#ifdef DEBUG
     fprintf(ptr,"temp_str = <%s>\n", temp_str);
#endif

     strcpy(inbuf + 4, temp_str);
     inlen = inlen + strlen(inbuf+4) +1 ;

     fprintf(ptr, "Sending command to DM2 To Verify the Extractin Filename.\n");
     fflush(ptr);
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen, &outbuf, &mfail, &errmsg);

     if( (dstat != 0) || (mfail != 0) )
     {
       fprintf(ptr, "\n");
       fprintf(ptr, "Error in sending verify command to DM2.\n");
       fprintf(ptr, "DM2 Return Status   : %d\n", dstat);
       fprintf(ptr, "DM2 Error Message   : %s\n", errmsg);
       fprintf(ptr, "DM2 Failure Status  : %d\n", mfail);
       fprintf(ptr, "\n");
       fprintf(ptr, "THE ERROR IS:\n\n");
       if(mfail == 20)
         fprintf(ptr, "The extraction name is already being used within DM2.\n");

       if(mfail == 30)
         fprintf(ptr, "The PMR work location could not be found in DM2.  Verify that the work locatin exist.  If it does, contact your administrator.\n");

       if(mfail == 34)
         fprintf(ptr, "The PMR vault could not be found in DM2.  Verify that the vault exist.  If it does, contact your administractor.\n");

       if(mfail == 35)
         fprintf(ptr, "The PMR vault location could not be found in DM2.  Verify that the vault location exist.  If it does, contact your administractor.\n");
       else
       {
	 fprintf(ptr, "ERROR occured in DM2.  PProcess has been terminated...\n");
       }
       printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
       fprintf(ptr, "\n");
       goto disconnect;
     }
     else
     {
       fprintf(ptr, "Verification of filename was Successful..........\n");
       fflush(ptr);
     }

/*
 * Send Cmd to DM2 through Postman to:
 * 	1.  register and attach the extracted files in DM2
 */

     inlen = 4;
     code = 2;
     p_code = &code;

     temp_str = (char *) malloc(SIZE); 
     if(temp_str == NULL)
     {
       fprintf(ptr, "ERROR in memory allocation.\n");
       fflush(ptr);
       printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
       goto disconnect;
     }
     memcpy((void *) inbuf, (void *) p_code, sizeof(int));
     sprintf(temp_str, "%s*%s", extract_name, wlname);
#ifdef DEBUG
     fprintf(ptr,"temp_str = <%s>\n", temp_str);
#endif

     strcpy(inbuf + 4, temp_str);
     inlen = inlen + strlen(inbuf+4) +1 ;

     fprintf(ptr, "Sending command to DM2 To Post the Extracted Files.\n");
     fflush(ptr);
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen, &outbuf, &mfail, &errmsg);

     if( (dstat != 0) || ( mfail != 0 ) )
     {
       fprintf(ptr, "\n");
       fprintf(ptr, "Error in sending post command to DM2.\n");
       fprintf(ptr, "DM2 Return Status   : %d\n", dstat);
       fprintf(ptr, "DM2 Error Message   : %s\n", errmsg);
       fprintf(ptr, "DM2 Failure Status  : %d\n", mfail);
       fprintf(ptr, "\n");
       fprintf(ptr, "THE ERROR IS:\n\n");
       if(mfail == 30)
         fprintf(ptr,"The PMR work location could not be found in DM2.  Verify that the work location exist.  If it does, conatact your administrator.\n");

       if(mfail == 31)
         fprintf(ptr,"Error in retrieving the server host name in DM2.  Contact Administrator.\n");

       if(mfail == 32)
         fprintf(ptr,"An Error has occured in DM2.  Contact the Administrator.\n");

       if(mfail == 33)
         fprintf(ptr,"The extracted files are not in the work locations.\n");
       else
       {
	 fprintf(ptr, "ERROR occured in DM2.  PProcess has been terminated...\n");
       }

       printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
       fprintf(ptr, "\n");
       goto disconnect;
     }
     else
     {
       fprintf(ptr, "Posting was Successful.....................\n");
       fflush(ptr);
       /* remove the .dri file from the exported work location */
       sprintf(rmtmp, "rm %s.dri", extract_name);
       status = system(rmtmp);
     }

disconnect:
/*
 * Disconnect from DM2 through Postman
 */
     fprintf(ptr, "Disconnecting from DM2........................\n");
     fflush(ptr);
     dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT, NULL, NULL, NULL, NULL, &errmsg);

     if(dstat != 0)  
     {
       fprintf(ptr, "Error in disconnecting from DM2.\n");
       fprintf(ptr, "DM2 Return Status : %d\n", dstat);
       fprintf(ptr, "DM2 Error Message : %s\n", errmsg);
       printf("ERROR occurred.  Process has been terminated.  Check the log file for status.\n");
      if(ptr)
        fclose(ptr);
      if(temp_str)
        free(temp_str);
       exit(0);
     }
     else
     {
       fprintf(ptr, "Disconnected........................\n");
       fflush(ptr);
       fprintf(ptr, "Process is complete........................\n");
       printf("Process is complete........................\n");
     }

/* free up memory */
     if(temp_str)
       free(temp_str);
     if(ptr)
     {
       fclose(ptr);
       ptr = NULL;
     }
  }
  else
  {
    printf("\nAll of the necessary arguments are not given..............\n");
    printf("Please specify a extraction filename, a server name, and a work location name...\n\n");
    printf("Example:\n\n");
    printf("AIMpost.exe file.dri server1 PMRWL\n\n");
    printf("\n");
    printf("OR\n");
    printf("\n");
    printf("AIMpost.exe file.dri server1 'PMR WL'\n\n");
    printf("Process Terminated........................................\n\n");
  }
/* end of progrram........ */
}

