/***************************************************************************
 *
 * File:	Post_DM2.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: Post_DM2.c,v $
 *	Revision 1.1  2002/05/31 16:29:11  tlstalli
 *	Backup of PMA process from EXTR
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:23  cvs
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
 * Revision 1.2  1997/06/09  19:43:34  pinnacle
 * (No comment)
 *
 * Revision 1.1  1996/11/07  01:04:06  pinnacle
 * initial revision
 *
 * Revision 1.2  1996/10/18  15:50:26  pinnacle
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
* argv[1] = node name						 *
* argv[2] = login						 *
* argv[3] = pswd						 *
* argv[4] = location of files					 *
* argv[5] = dummy file name					 *
* argv[6] = context id						 *
* argv[7] = server						 *
*****************************************************************/
main(int argc, char *argv[])
{
  int   inlen=0, outlen = 0, dstat = 0, mfail = 0, code = 0;
  int   y = 0, look = 0, check = 0;
  char  inbuf[512], *errmsg = NULL, line[80], *outbuf = NULL;
  int   *p_code = NULL, size = 0;
  long	fpos;
  char  *temp_str = NULL, *temp = NULL, *desc = NULL;
  char  *cmdfile = "/usr/tmp/pma/pma_cmd.txt";
  FILE  *file_ptr = NULL;
  FILE  *ptr = NULL;
  char	server_name[25], envstring[50];
  struct hostent *h = NULL;
  char  log[80];


  printf( "Inside Post_DM2.exe\n" );	/* Rishad */

  if(argc == 8)
  {
   /* create the log file to print out user information */
   sprintf(log, "/usr/tmp/ps%s.log", argv[5]);
    
    ptr = fopen( log, "w+"); 
    if(ptr == NULL)
    {
      printf("Can not create log file for posting extracted files\n");
    }
    printf("argv[1] = <%s>\n", argv[1]);

    /******* Set the PROXY_CLIENT_ADDRESS ***********/
    sprintf(server_name, "%s", argv[7]);
    printf("argv[7] = <%s>, server_name = <%s>\n", argv[7], server_name);

    h = gethostbyname(server_name);
    if(h == NULL)
    {  
       	fprintf(ptr,"Server not recognised\n");
    }
/*
    sprintf(envstring,"PROXY_CLIENT_ADDRESS=%s",inet_ntoa(*((struct in_addr *)h->h_addr)));

    printf("envstring  = <%s>\n", envstring );

    if(putenv( envstring ) != NULL )
    {
       fprintf(ptr, "Unable to set the environment variable");
    }
*/
    /********** Read the Description from the command file *********/
     file_ptr = fopen(cmdfile, "r");
     if(file_ptr == NULL)
     {
    	 fprintf(ptr, "Could not open command file for reading");
     }
     else
     {
        printf("inside else statement.\n");
        printf("check = <%d>\n", check);
    	while(check != 1)
    	{
        	printf("inside while loop.\n");
      		fpos= ftell(file_ptr);
                line[0] = '\0';
      		if( fgets( line, 80, file_ptr) == NULL)
                {
        		check = 1;
			printf("line is NULL, setting check to 1.\n");
                }
      		if(check != 1)
      		{
			printf("check is not 1 so get data from file.\n");
        		y = strlen(line);

        		if(*line)
        		{
    	        		printf("line = <%s>\n", line);
          			if((look = strncmp( line, "DESC:", 5 )) == 0)
          			{
            				strtok(line, " ");
            				temp = strtok(NULL, "\n");
                                        size = strlen(temp);
					desc = (char *) malloc(size);
					if(desc)
					{
					  sprintf(desc, "%s", temp);
    	        			  printf("desc = <%s>\n", desc);
					}
          			} 

        		} 

      		}

      		fseek(file_ptr, fpos+y, SEEK_SET);

    	}

     }

     if(file_ptr)
       fclose(file_ptr);
     file_ptr = NULL;



	/*
	 * Connect to DM2 through Postman
         */
    	   fprintf(ptr, "Connecting to DM2.................\n");
	   fflush(ptr);
           dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT, (char *)inet_ntoa(*((struct in_addr *)h->h_addr)), NULL, NULL, NULL, &errmsg);

    	   fprintf(ptr, "Connected...........................\n");
	   fflush(ptr);
           if((dstat != 0) || (*errmsg))
            fprintf(ptr, "error in connecting.\n");
	/*
         * Send Cmd to DM2 through Postman to:
         * 	1.  ftp extracted files from CLIX to DM2 server
	 *	2.  register and attach the extracted files into DM2
         */
    	   inlen = 4;
           code = 60;
  	   p_code = &code;
           temp_str = (char *) malloc(SIZE); 
	   if(temp_str == NULL)
	   {
	     fprintf(ptr, "ERROR in memory allocation for temp_str.\n");
	     fflush(ptr);
          }
           memcpy((void *) inbuf, (void *) p_code, sizeof(int));
           if( (*desc) && (desc != NULL) )
	   {
    	     printf("*desc has a value.\n");
    	     printf("desc = <%s>\n", desc);
             sprintf(temp_str, "%s*%s*%s*%s*%s*%s*%s", 
                                argv[1], argv[2], argv[3], 
                                argv[4], argv[5], argv[6], desc);
    	     printf("temp_str = <%s>\n", temp_str);
           }
           else
           {
    	     printf("desc is null.\n");
             sprintf(temp_str, "%s*%s*%s*%s*%s*%s*%s", 
                                argv[1], argv[2], argv[3], 
                                argv[4], argv[5], argv[6], 
                                "No description provided.");
    	     printf("temp_str = <%s>\n", temp_str);
           }
             
           strcpy(inbuf + 4, temp_str);
           inlen = inlen + strlen(inbuf+4) +1 ;

    	   fprintf(ptr, "Sending command to DM2....................\n");
	   fflush(ptr);
	   dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen, 
				       	     &outbuf, &mfail, &errmsg);

           if( (dstat != 0) || (*errmsg) )
	   {
             fprintf(ptr, "Error in sending command to DM2. dstat = %d\n", dstat);
            fprintf(ptr, "Error in sending command to DM2.  errmsg = %s\n", errmsg);
	   }
	   else
 	   {
    	     fprintf(ptr, "Posting was Successful.....................\n");
	     fflush(ptr);
           }
	/*
	 * Disconnect from DM2 through Postman
	 */
    	   fprintf(ptr, "Disconnecting from DM2........................\n");
	   fflush(ptr);
           dstat = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT, NULL, NULL, 
					    NULL, NULL, &errmsg);

           if( (dstat != 0) || (*errmsg) ) 
	   {
             fprintf(ptr, "Error in disconnecting.  dstat = %d\n", dstat);
             fprintf(ptr, "Error in disconnecting. errmsg = %s\n", errmsg);
	   }
	   else
	   {
    	     fprintf(ptr, "Disconnected........................\n");
	     fflush(ptr);
	   }


           if(temp_str)
    		free(temp_str);
           if(desc)
    		free(desc);
           if(ptr)
           {
              fclose(ptr);
 	      ptr = NULL;
           }
  }
  else
  {
    printf("All arguments are not given............\n");
    printf("argc = %d\n", argc);
  }

  

}

