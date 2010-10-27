/* $Id: VDHandler.C,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDHandler.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDHandler.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
   ABSTRACT :
   --------

   This file contains functions to track the handler characters.

   HISTORY :
   -------

   06/15/1988 : HGB - Creation Date
*/

#include <string.h> 
#include <stdio.h> 

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "exdef.h"
#include "exmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIomac.h"

#define MAX_BUF 1024




VDcleanWord(text, was_bad)
char	*text; 		/* (I/O) the text to clean */
int	*was_bad;	/* (O) 1 if there was a handler char */
{
int	i, k;
char	*cleantext;

 cleantext = NULL;
 if(was_bad) *was_bad = 0;

 cleantext = (char *)malloc( (strlen(text)+1) * sizeof(char));
 if (cleantext == NULL) goto wrapup;

 k = 0;
 for(i=0;i< strlen(text);i++) {
		if(text[i] == '\202') {
			if(was_bad) *was_bad = 1;
			continue;
		}
		else cleantext[k++] = text[i]; 
 }
 
 cleantext[k] = '\0';
 strcpy(text, cleantext);

 if(cleantext){free(cleantext);cleantext = NULL;}

return 1;

wrapup:
 if(cleantext){free(cleantext);cleantext = NULL;}
return 0;
}



VDStestDir(dir)
char	*dir;		/* (I) directory or expression to verify */

{
int		i, sts, bad, nb_lines;
char		**lines, regexp[DI_PATH_MAX];
OM_S_OBJID	mod_id;
OMuword		mod_osnum;


lines = NULL;

if(dir == NULL || dir[0] =='\0'){
	ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum);
	di$give_pathname( osnum = mod_osnum,
			  pathname = regexp);
	strcat(regexp,":usr:*");
}
else if(dir[0] == '.')
	di$pwd(dirname = regexp);
else strcpy(regexp, dir);

if(regexp[strlen(regexp)-1] != '*'){
	if(regexp[strlen(regexp)-1] != ':') strcat (regexp,":");
	strcat(regexp,"*");
}
printf("ls of %s\n", regexp);

sts = di$ls(	regexp = regexp,
		lines  = &lines,
		ptr    = &nb_lines);

di$report_error(sts=sts);
if(sts == DIR_S_SUCCESS && nb_lines > 0){
	for(i=0;i< nb_lines;i++){
		VDcleanWord(lines[i], &bad);
		if(bad ) {
			printf("Invisible characters in the line %s\n",lines[i]);
		}
	}
		
}

if(lines != NULL){ di$free(lines = lines, count = nb_lines); lines = NULL;}
return 1;

}
