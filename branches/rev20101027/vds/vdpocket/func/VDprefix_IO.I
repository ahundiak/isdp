/* $Id: VDprefix_IO.I,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / VDprefix_IO.I
 *
 * Description:
 *    This file include function used for reading/writing prefix fileds
 *    in query in/to a ASCII file which includes same query
 *                   - VDpfx_read_entry()
 *                   - VDpfx_write_entry()
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDprefix_IO.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  19:23:56  pinnacle
# UnInit warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/26  22:19:16  pinnacle
# Replaced: vdpocket/func/VDprefix_IO.I for:  by sundar for vds.240
#
# Revision 1.2  1995/08/30  15:39:10  pinnacle
# Replaced: vdpocket/func/VDprefix_IO.I for:  by yzhu for vds.240
#
# Revision 1.1  1995/07/08  20:25:56  pinnacle
# Created: vdpocket/func/VDprefix_IO.I by yzhu for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      07/07/95        Yzhu            create
 *	10/31/97	ah		UnInit warnings
 * -------------------------------------------------------------------*/

/*
  ASCII FILE LAYOUT :
  ------------------

	The created ASCII files permits to load and save query setups 
	from one configuration into another and allows users to define
	new queries.


	#
	# Comment area.
	#
	# <time stamp when created>
	#

	<Query Name> short name of query	

	<Definition>
	select from .. where ..

	<Comment>
	specified information to support query.

        <Prefix>
         pfx_index
         pfx_name
         
	<Query Name> short name of query	

	<Definition>
	select from .. where ..

	<Comment>
	specified information to support query.

        <Prefix>
         pfx_index
         pfx_name

 Note: the file may/may not include <Prefix>.
       If it includes <Prefix>, it must include pfx_index and pfx_name together.
 ***************************************************************************/
class implementation Root;

#include <ctype.h>
#include <stdio.h>		/* FILE type */

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"      /* must be behind OMminimum.h */
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igrdef.h"
#include "igr.h"
#include "griodef.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "VDQYdef.h"
#include "VDmem.h"

/*
 include "VDquery.h"
*/

#include "vdsupmacros.h"

/* #define DEBUG	1 */

from VDquery import VDsetPfxInfo;
/*--------------------------------------------------------------------------

Function:
    
	VDqrypfx_read_entry

Description:

	This function reads an entry(query and prefix) by looking for the 
        name of the query. It creates the query object if found.
        Note: VDqry_read_entry only read query but prefix.

Return Status

    status	= TRUE ;	 query created
    status	= FALSE;	 otherwise    
   
 */

int VDqrypfx_read_entry( file, text)
FILE		*file;
IGRchar		*text;
{
IGRlong			msg = MSSUCC ;
IGRchar			*select,
			*comment;
IGRint			status = OM_S_SUCCESS ;
struct GRid		object;
long			flong, prepos;
IGRint                  pfxIndex;
IGRchar			pfxName[80];

#ifdef DEBUG
	printf(" name: %s\n", text );
#endif
	select = NULL;
	comment = NULL;

	if( ! file || ! text ){
		/*
		 * No file pointer available or no query name.
		 */
		return	MSFAIL ;
	}
	/* get position of fp */	
	flong = ftell(file); 
	fseek(file,flong,SEEK_SET); 

	/*
	 * check if the text(<Nmae> .....) is defined.
	 */
	if( ! VDqry_find_name( file, text, NULL )){
		msg = MSFAIL ;
		goto wrapup;
	}
	/* get position of fp */	
	flong = ftell(file); 
        prepos = flong;
	fseek(file,flong,SEEK_SET); 

	/*
	 * find the definition/comment within the name.
	 */

	if( ! VDqry_find_definition( file, &select, &comment ,&prepos) ){
                printf(" Input format is wrong \n");
		fseek(file,prepos,SEEK_SET); 
		msg = MSFAIL ;
		goto wrapup;
	}
		fseek(file,prepos,SEEK_SET); 

	/*
	 * create the query in collector.
	 */

	VDqry_create_object( &msg, &object, text, select, comment );

        /*
         * find the prefix with name.
         */
        if( ! VDpfx_find_prefix( file, &pfxIndex, &pfxName ,&prepos) ){
                printf(" Input format is wrong \n");
                fseek(file,prepos,SEEK_SET);
                msg = MSFAIL ;
                goto wrapup;
        }
                fseek(file,prepos,SEEK_SET);

        /*
         *  set prefix into collector 
         */

        status =
        om$send(msg = message VDquery.VDsetPfxInfo( &msg, 
                                                    &pfxIndex,
                                                    pfxName),
                        senderid = NULL_OBJID,
                        targetos = object.osnum ,
                        targetid = object.objid );
        if( ! (status&msg&1)){
                printf(" Cann't set prefix into query: %s\n", text);
                fseek(file,prepos,SEEK_SET);
                msg = MSFAIL ;
                goto wrapup;
        }
                fseek(file,prepos,SEEK_SET);


	_FREE(	select  );
	_FREE(  comment );

	return status ;

wrapup:
	
	return MSFAIL ;
} /*  VDqry_read_entry */

/*--------------------------------------------------------------------------*/
int VDpfx_write_entry( file, text,pfxIndex, pfxName)
FILE			*file;         /* I */
IGRchar			*text;         /* I */
IGRint			*pfxIndex;      /* I */
IGRchar			*pfxName;      /* I */
{


	if( ! text || ! pfxIndex || !pfxName ){
		/*
		 * we do not allow to write prefixe without any name
		 * we do not allow to write prefix without any one of prefix
                 *    field
		 */
		return FALSE ;
	}

	/*
	 * set the definition title.
	 */
	fprintf( file, "\n\n" );
	fprintf( file, "%s\n", VD_QRY_ASCII_PREFIX );
	fprintf( file, "\t%d\n", *pfxIndex );
	fprintf( file, "\t%s\n", pfxName );

	return	TRUE ;

} /*VDpfx_write_entry */
/*------------------------------------------------------------------------*/
/* return
   status == TRUE for success
   status == FALSE for unsuccess
--------------------------------------------------------------------------*/
VDpfx_find_prefix( file, pfxIndex, pfxName,prepos)
FILE			*file;			/* in  */
IGRint			*pfxIndex;              /* out */
IGRchar			*pfxName;		/* out */
long			*prepos;		/* in/out */
{
IGRint			status = TRUE ;
GRname			buffer;
IGRint			size = DI_PATH_MAX ;
IGRint			len;
long			flong;
IGRchar                 bufIndex[80];
IGRchar                 bufName[80];

        bufIndex[0] = '\0';
        bufName[0] = '\0';
	flong = 0;		// UnInit warning message
	while( TRUE ){

		/*
		 * read a line of the file.
		 */

		if( ! VDio_read_line(	file,
					buffer,
					size ) ){
			/*
			 * end of file
			 */
			status = FALSE;
			break;
		}
		flong = ftell(file); 

               
		/* skip comment lines */
		if( strncmp(buffer,VD_QRY_FILE_COMMENT,1) == 0 ){
			/*
			 * get next line of text.
		 	*/
                        *prepos = flong;
			continue;
		}

		/* skip empty lines */
		if( buffer[0]== '\0'){
			/*
			 * get next line of text.
			 */
                        *prepos = flong;
			continue;
		}
                /*  
                 *   if next line is following format
                 *   <Name> ......
                 *   <Definition> ......
                 *   <Comment> ....
                 *   return FALSE
                 */
                                  
		if( (strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) ||
		    ( strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF ) == 0 )  ||
		    ( strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 )){
			status = FALSE ;
			break ;
		}

                /* 
                 * if line is not 
                 * <Definition>
                 * goto read next line, this format ignores the garbages
                 * before the <Definition>
                 */

		if( strncmp(	buffer,
				VD_QRY_ASCII_PREFIX,
				VD_QRY_ASCII_szDEF ) != 0 ){
			/*
			 * looking for next line.
			 */
                        *prepos = flong;
			continue;
		}

		status = TRUE ;
		break;
	} /* while */

	/*
	 * start reading the definition line(s).
	 */
		
	while( status ){
                        
		*prepos = flong;

		/*
		 * read a line of the file 
		 */

		if( ! VDio_read_line(	file,
					buffer,
					size ) ){
			/*
			 * end of file
			 */
			status = FALSE;
			break ;
		}
		flong = ftell(file); 

		/*
		 * scann the information.
		 */
		if( strncmp(buffer,VD_QRY_FILE_COMMENT,1) == 0 ){
			/*
			 * get next line of text.
			 */
                        *prepos = flong;
			continue;
		}
                /*
                 * skip the blank line below the <Prefix>
                 */
		if( (len = strlen( buffer )) == 0 && bufName[0] == '\0'){
                        *prepos = flong;
		        continue;	
                }
		/*
                 *  not allow <Name>, <Definition>, <Comment>, <Prefix>
                 *  occur before reading contents of definition. 
		 */

		if(( (strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) && 
                                 bufName[0] == '\0') ||
		   ( (strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF  ) == 0 ) && 
                                 bufName[0] == '\0') ||
		   ( (strncmp(	buffer,
				VD_QRY_ASCII_PREFIX,
				VD_QRY_ASCII_szDEF  ) == 0 ) && 
                                 bufName[0] == '\0') ||
		   ( (strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 ) && 
                                 bufName[0] == '\0') ){
			/*
			 * did not found the prefix
			 */
			status = FALSE ;
			break;
                        /* goto wrapup ; */
		}
		/*
                 *  the occurence of  <Name>, <Definition>, <Comment>
                 *  means finish of prefix after reading contents of
		 *  prefix, then return true.		 
		*/
		if( (strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) && 
                                 bufName[0] != '\0' ){
			status = TRUE ;
               		break;
 		}     
		if( (strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF  ) == 0 ) && 
                                 bufName[0] != '\0' ){
			status = TRUE ;
               		break;
 		}     
		if( (strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 ) && 
                                 bufName[0] != '\0' ){
			status = TRUE ;
               		break;
		}
		/* 
                 * the index of prefix is on first line, 
                 * the name  of prefix is on second line 
                 */

		strcat( bufIndex,buffer );
                *pfxIndex = atoi(bufIndex);

                /*
                 * read a second line for prefix name
                 */

                if( ! VDio_read_line(   file,
                                        buffer,
                                        size ) ){
                        /*
                         * end of file
                         */
                        status = FALSE;
                        break ;
                }
                flong = ftell(file);
                *prepos = flong;
		strcat( bufName,buffer );
		strcat( pfxName,bufName );
	} /* while(status) */

	if( bufName[0] != '\0')	status = TRUE ;

	return status ;

} /* VDpfx_find_prefix */
/*------------------------------------------------------------------------*/
end implementation Root;
