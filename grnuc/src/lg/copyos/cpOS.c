/*
   interface between looking glass and copyOS
    -- main(), SCfree(), product_path()

   Date : July 3, 1990

*/
#include <stdio.h>
#include <sys/types.h>
#include <errno.h>
#include <sys/stat.h>
#include <string.h>

#include "pblk.h"
#include "aci_defs.h"
#include "libapl.h"
#include "lgft.h"

#define MAX_PATH 256
#define MAX_CMD 512
#define PRODUCT_DATA "/usr/ip32/product_data"

main()
{
 int sts;

 int ret;

 int socket;

 parm_blk request;

 char *cpPath;

 char sourceDir[MAX_PATH];

 char destDir[MAX_PATH];

 char command[MAX_CMD];

 char *data;

 char *product_path();

 /* ACI_SOCKFD is the standard "Looking Glass to client" socket */
 socket = ACI_SOCKFD;

 /* Wait for request from Looking Glass */

 while ((sts=apl_next_request(&request, socket)) == SUCCESS)
  {
   /* process the request */
     
   data=NULL;
   data=(char *)request.p_data;

   switch (request.p_opcode) 
    {
    case APL_SETSOURCE :
          strcpy(sourceDir, data);
          SCFree(data, request.p_flags);
   
          apl_done("",socket);                /* finished */
          break;
    case APL_SETDESTINATION :
          strcpy(destDir, data);
          SCFree(data, request.p_flags);
   
          apl_done("",socket);                /* finished */
          break;
    case APL_COPY :
          cpPath=product_path("Exnuc");
          strcpy (command, cpPath);
          strcat (command, "/bin/copyOS ");
          strcat (command, sourceDir);
          strcat (command, "/");
          strcat (command, data);
          strcat (command, " ");
          strcat (command, destDir);
          ret=system (command);
          if (ret != 0)
           {
            apl_error("Error creating target file");
            exit(-1);
           }
          apl_used(data,socket);
          apl_done("",socket);
          break;
    }
        
  }
  exit(0);
}

SCFree(data, flags) 
char *data;
u_short flags;
{
  if (flags & P_SEPMALLOC)
     free(data);
}


char * product_path( product )
char *product;
{

/* get path of product from product_data */

  FILE *fp;
  char line[1026];
  char *prod_path = 0;
  char *lproduct;
  char error[10];
  
  fp = fopen( PRODUCT_DATA, "r");
  if ( !fp )
  {
    printf("Could not open product_data file\n");
    exit(0);
  }

  lproduct = (char *) malloc( strlen(product) + 3 );
  sprintf( lproduct, "\"%s\"", product ) ;

  while ( fgets( line, 1025, fp ) )
  {
    line[strlen(line) - 1] = 0;
    if ( !strncmp(line, lproduct, strlen (lproduct) ) )
    {
       prod_path = ( char *) (strrchr( line, ' ') + 1);
       fclose( fp );
       return prod_path;
    }
  }
  strcpy( error, "not found");
  return error;
}
