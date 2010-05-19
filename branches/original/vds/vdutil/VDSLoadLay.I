/* $Id: VDSLoadLay.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSLoadLay.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSLoadLay.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/08  00:41:12  pinnacle
# Replaced: vdutil/VDSLoadLay.I for:  by mdong for vds
#
# Revision 1.2  1998/01/20  15:57:20  pinnacle
# Replaced: vdutil/VDSLoadLay.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/07/98        Ming            TR179702060. 
 *                                      Create function VDSOpenFileAndPath().
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 30 Dec 91	  creation date.
/*
/*  Temporary thing allowing to load layer definitions from an ascii file
/* */

class implementation Root;


from  DPlvldir import add_name_to_lvldir;

#include	<stdio.h>
#include	<string.h>

#include        "OMerrordef.h"
#include        "OMminimum.h"
#include        "OMmacros.h"
#include        "OMparameters.h"
#include        "igrtypedef.h"
#include        "igetypedef.h"
#include        "igr.h"
#include        "igrdp.h"
#include        "gr.h"
#include	"go.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
	
#include 	"vdsmacros.h"

#define TRUE	1

extern int VD_isASCIIFile();
extern int get_modtype_data();

int VDSOpenFileAndPath(char *, char *, char *, int, char *, FILE **);

VDSLoadLay(file_name)
char *file_name;
{
 FILE   	*fp;
 IGRint 	msg;
 char    	buffer[160], *ptr=NULL, /* *next_ptr,*/ *line;
 char		*temp_ptr = NULL;
 int     	i, status, line_count;
 char 	 	/*lv_name[21], lv_def[81],*/ ems_file[120];
 char    	sep;
 struct GRid	dplvldir;
 char           path_name[256];

 sep = ',';  /* It is the separator */
 line_count = 0;
 line = NULL;


 /* try to open the ascii file */
 if( VDSOpenFileAndPath(file_name,
			 "Vds",
			 "config",
			 TRUE,
                         path_name,
			 &fp) == 0 )
 {
   /* no ascii file found */
   return 1;
 }

 if( !VD_isASCIIFile(path_name) )
 {
   printf("File %s is not a ASCII file\n", path_name);
   return 3;
 }
 
 /* Get the level manager object id */
 VDSget_filename(ems_file);
 strcat(ems_file,":IGENOD:DPLVLDIR");

 status = di$translate(objname = ems_file,
                     p_objid = &dplvldir.objid,
                     p_osnum = &dplvldir.osnum);
 if(!(status&1)) 
  {
   printf("Error in di$translate\n");
   return 2;
  }


 while(fgets(buffer,160-2, fp) != NULL)
  {
   short blank_line;

   buffer[160-1] = '\0';
   line = &buffer[0];

   ++line_count;
   temp_ptr = strchr( buffer, '=' );
   if( temp_ptr == NULL )
   {
     printf("Line %d has Syntax errors: %s\n", line_count, line);
     line = NULL;
     continue;
   }

   /*"buffer line: <%s>, length: %d\n", buffer , strlen(buffer) */
   /*| Take out the blank line */
   if(strlen(buffer) < 1) continue;
   buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */

   blank_line = 1;
   for(i=0;i<strlen(buffer);i++)
     if(buffer[i] != ' ' && buffer[i] != '\t') { blank_line = 0; break; }
   if(blank_line) continue;


   /*| take out the first blanc charracters */
   for(i=0;i<strlen(buffer);i++)
    {
     if(buffer[i] != ' ' && buffer[i] != '\t') { ptr = &buffer[i]; break; }
    }

   /*| Take out the comment line (starting by #) */
   if(ptr[0] == '#') continue;

   /* Store the layer */
   status = om$send(msg = message DPlvldir.add_name_to_lvldir(&msg, buffer),
                       	     senderid = NULL_OBJID,
                       	     targetid = dplvldir.objid,
                       	     targetos = dplvldir.osnum);
   if (!status || ! ( 1 & msg ))
    {
     printf("Error line: %s\n", line);
     continue;    
    }
  }

 /* Close the file */
 fclose(fp);
 return 0;
}

/*----------------------------------------------------------------------
 *                                                                      *
 * VDSOpenFileAndPath:                                                  *
 *                                                                      *
 * Given a file name, opens it and return the whole path name.          *
 * product is the product name. If not used put NULL.                   *
 * If the product name is used, a ralative path (sub_dir) to it can be  *
 * defined (NULL if not used).                                          *
 *                                                                      *
 * If product name is defined "cur_dir" indicates if the funtion tries  *
 * first to open it in the current dir or not                           *
 *									*
 * pathname is output of whole pathname.				*
 *                                                                      *
 * Return FALSE if false.                                               *
 *                                                                      *
 * Sample call:								* 
 * VDSOpenFileAndPath("file_name", "Vds", "config", FASLE, "path", &fp);*
 *----------------------------------------------------------------------*/

int VDSOpenFileAndPath(file, product, sub_dir, cur_dir, pathname, fp)
char *file;     /* file name                             (I) */
char *product;  /* Product name                          (I) */
char *sub_dir;  /* relative dir under the product        (I) */
int  cur_dir;   /* TRUE => look first in the current dir (I) */
char *pathname; /* file path name                        (O) */
FILE **fp;      /* pointeur to the file                  (O) */
{
 char product_path[256];

 *fp = NULL;
 if( file == NULL ) return 0;

 if( product == NULL || cur_dir == TRUE )
 {
   *fp = fopen( file,"r" );
   if( *fp!=NULL )
   {
     /*
     ** The file is opened
     */
     if( pathname != NULL ) strcpy( pathname, file );
     return 1;
   }
 }

 if( product != NULL )
 {
   /*
   ** Try the product path
   */
   if( get_modtype_data(product,NULL,NULL,NULL,NULL,product_path) == 0 )
   {
     /*
     ** Something wrong like the product name ...
     */
     return 0;
   }

   if( *sub_dir != NULL )
   {
     /*
     ** add the sub path
     */
     strcat( product_path, sub_dir );
     strcat( product_path, "/" );
   }
   strcat( product_path, file );
   *fp = fopen( product_path, "r" );

   if( *fp != NULL )
   {
     if( pathname != NULL ) strcpy( pathname, product_path );
     return 1;
   }
 }

 return 0;
}

end implementation Root;

