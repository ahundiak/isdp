/* $Id: VDXserver.C,v 1.2 2001/02/15 01:07:48 ramarao Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdextr/func/VDXserver.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDXserver.C,v $
 *      Revision 1.2  2001/02/15 01:07:48  ramarao
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
#include <netdb.h>
#include <netinet/in.h>
#endif /* CLIX */

#include "OMerrordef.h"
#include "OMminimum.h"

int VDXget_servername(char *server_name)
{

  int status = 0;
  FILE *file_ptr = NULL;
  char *temp = NULL;
  char line[80];
  long fpos;
  int y = 0, look = 0, check = 0;  
  char *cmdfile = "/usr/tmp/e4rcmd.txt";

  if( ! server_name ){ return 0 ; }

  *server_name = '\0';
  file_ptr = fopen(cmdfile, "r");
  if(file_ptr == NULL)
  {
    return 1;
  }
  else
  {
    while(check != 1)
    {
      fpos = ftell(file_ptr);
      if( fgets(line, 80, file_ptr) == NULL)
        check = 1;	
      if(check != 1)
      {
        y = strlen(line);
  	    
        if(*line)
        {
          if((look = strncmp( line, "SERVER:", 7 )) == 0)
	  {
	    strtok(line, " ");
    
	    temp = strtok(NULL, "\n");
            if(temp)
            {
              strcpy(server_name, temp); 
              status = 0;
	    }
	    else
            {
	      status = 1;
              check = 1;
            }
	  } //end if for look

	} //end if for line

      }//end if for check

      fseek(file_ptr, fpos+y, SEEK_SET);

    }//end while  

  }//end if for else

  if(file_ptr)
  {
    fclose(file_ptr);
    file_ptr = NULL;
  }

	return status;

}
