/* $Id: VRIsoBatch.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */
/**************************************************************************
*
* I/ROUTE
*
* File:        $ROUTE/vriso/VRIsoBatch.I
*
* Description:
*	VRiso_batch routine searches UNIX directory system for Isogen Drawing 
*	files. It will be used after Isogen NQS batch jobs. 
*
* Dependencies:
*
* Revision History:
*      $Log: VRIsoBatch.I,v $
*      Revision 1.1.1.1  2001/01/04 21:12:57  cvs
*      Initial import to CVS
*
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/01/21  16:12:56  pinnacle
# Replaced: vriso/VRIsoBatch.I for:  by kddinov for route
#
*
* History:
*
* 10/31/96  KDD	creation (VRiso_batch, ISO_is_drawing_file) 
**************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vdmiscmacros.h"

/*	Global routines */

extern int      system();
extern char     *strstr();
extern void 	UI_message(char *symstr);
extern void 	UI_status(char *symstr);
extern void 	UI_prompt(char *symstr);

/*	Local routines */

extern int      ISO_is_drawing_file();

/*******************************************************************************
* NAME: VRiso_batch()
*
*  1. Search for Isogen Drawing file <filename>.dat.
*  2. Move <filename>.dat to DATAFILE ("isogen.dat").
*  3. Create DGNFILE ("isogen.file") with a single line "<filename>.iso".
*
* PARAMETERS
*
* I	char	*DATAFILE	-after you select <filename> move it to DATAFILE
* I  	char	*DGNFILE	- create DGNFILE to specify the ISDP output file
*
* NOTES:
* 	The routine ISO_is_drawing_file filters out non drawing format files, 
*
* RETURN:
*	forwards the status from vd$get_file (1 OK; 0 otherwise). 
*	1	- OK
*	0	- failure 
*******************************************************************************/
int VRiso_batch( char	*DATAFILE,
		 char	*DGNFILE)
{
  int           status;
  char          *p1;
  char          filename[80],
                s1[132];

  FILE          *outfile;

  status = vd$get_file( title		= "Draw Isometrics", 
			directory       = ".",
                        out_file        = filename,
                        file_test       = ISO_is_drawing_file,
                        file_filter     = "*.dat");

  if ( strlen(filename) == 0 ) { 
	status = 0; 
	UI_status( "No file selected"); 
	goto wrapup; 
  } 

  sprintf(s1, "mv %s %s", filename, DATAFILE);
  if ( system(s1) ) {
        strcat(s1, " FAILED. Exiting.. ");
        UI_status(s1);
        status = 0; 
	goto wrapup; 
  }

  if ( (p1 = strstr(filename, ".dat")) )  {
          strcpy(p1, ".iso");
  }
  else {
          strcat(filename, ".iso");
  }

  outfile = ( FILE * ) fopen( DGNFILE, "w" );
  if ( outfile == NULL ) {
          sprintf(s1,"can not open %s for writing. Exiting...", DGNFILE);
          UI_status (s1);
  }
  else {
          fprintf(outfile, "%s\n", filename);
          fclose( outfile );
  }

wrapup:

return (status) ;
}

/*******************************************************************************
*  This routine determines if the input filename is of Isogen Drawing file
*  format. It checks if the first line contains pattern "ICIOPN".
*
*  RETURN:
*       1 - if Isogen Drawing file
*       0 - otherwise
*******************************************************************************/
int ISO_is_drawing_file( name)
char *name;
{
        int     status;
        char    text[80];
        FILE    *fp;

        status = 1;

        fp = fopen( name, "r");
        if ( fp == NULL) { status = 0; goto wrapup; }

        fgets(text, 80, fp);

        if ( strstr(text,"ICIOPN") == NULL ) status = 0;

        fclose(fp);

wrapup:

return (status);
}

end implementation Root;
