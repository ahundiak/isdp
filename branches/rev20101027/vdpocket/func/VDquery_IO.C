/* $Id: VDquery_IO.C,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/func / VDquery_IO.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDquery_IO.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/31  19:23:56  pinnacle
 * UnInit warnings
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.5  1996/05/23  20:10:34  pinnacle
 * Replaced: vdpocket/func/VDquery_IO.C for:  by yzhu for vds.240
 *
 * Revision 1.4  1995/09/26  22:19:08  pinnacle
 * Replaced: vdpocket/func/VDquery_IO.C for:  by sundar for vds.240
 *
 * Revision 1.3  1995/08/30  15:38:18  pinnacle
 * Replaced: vdpocket/func/VDquery_IO.C for:  by yzhu for vds.240
 *
 * Revision 1.2  1995/07/08  20:35:24  pinnacle
 * Replaced: vdpocket/func/VDquery_IO.C for:  by yzhu for vds.240
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
 *	10/31/97	ah		UnInit warnings
 *
 * -------------------------------------------------------------------*/

/*
 * I/VDS
 *

  ABSTRACT :
  --------

	This file contains the functions to manipulate the query
	support files.

	The following functions are defined to interact with the ASCII
	file.

		- VDqry_read_entry()
		- VDqry_write_entry()
		- VDqry_write_header()
		- VDqry_load_names()

  FILE LAYOUT :
  -----------

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


	<Query Name> short name of query	

	<Definition>
	select from .. where ..

	<Comment>
	specified information to support query.


   HISTORY :
   -------

	08/26/94	adz		Creation Date.
	09/08/94	yzhu            Modify.

 ***************************************************************************/


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

/*--------------------------------------------------------------------------

Function:
    
	VDqry_read_entry

Description:

	This function reads an entry by looking for the name of the
	query. It creates the query object if found.

Return Status

    status	= TRUE ;	 query created
    status	= FALSE;	 otherwise    
   
 */

int VDqry_read_entry( file, text)
FILE		*file;
IGRchar		*text;
{
IGRlong			msg = MSSUCC ;
IGRchar			*select,
			*comment;
IGRint			status = OM_S_SUCCESS ;
struct GRid		object;
long			flong, prepos;

#ifdef DEBUG
	printf(" name: %s\n", text );
#endif
	select = NULL;
	comment = NULL;

	if( ! file || ! text ){
		/*
		 * No file pointer available or no query name.
		 */
		return	FALSE ;
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
	 * create the query.
	 */

	VDqry_create_object( &msg, &object, text, select, comment );

	_FREE(select  );
	_FREE(comment );

	return status ;

wrapup:
	
	return MSFAIL ;
} /*  VDqry_read_entry */

/*-------------------------------------------------------------------------*/

VDqry_clr_display( form_ptr, gadget )
IGRchar			*form_ptr;
IGRint			gadget;
{
IGRint	    	i,
		row = 0 ;
	/*
	 * reset the list if not done yet.
	 */

	FIfld_get_num_rows(	form_ptr, gadget, &row );

	for( i=0 ; i<row ; i++ )
		FIfld_set_text(	form_ptr, gadget, i, 0, "", FALSE );

	row = 0;
	FIfld_set_num_rows(	form_ptr, gadget, row );

	return TRUE ;

} /* VDqry_clr_display */
/*------------------------------------------------------------------------*/	
VDqry_load_names( form_ptr, gadget, file )
IGRchar			*form_ptr;              /* in   */
IGRint			gadget;			/* in   */
FILE			*file;			/* in   */
{
IGRint			status = OM_S_SUCCESS,
			row = 0 ;
GRname			name, my_msg;


	if( ! VDqry_clr_display( form_ptr, gadget ) ){
		/*
		 * error in form.
		 */
		return FALSE;
	}

	/*
	 * read information from ASCII file and display
	 * the result in the form.
	 */

	while( VDqry_find_name(	file, NULL, name )){

		FIfld_set_text(	form_ptr,
				gadget,
				row++,
				0,
				name,
				FALSE );
	}
 	if( row == 0 ) {
                                sprintf(my_msg,
                                " It is not query_criteria file");
                                UI_status(my_msg );
                                FIg_set_text(form_ptr, 10, 
                                   "Not query_criteria file!");
                        }
	FIfld_set_num_rows(	form_ptr, gadget, row );

	return status ;
} /* VDqry_load_names */
/*------------------------------------------------------------------------*/

VDqry_write_header( file )
FILE			*file;
{

	/*
	 * Some default information will be written on each file.
	 */
	if( ! file ){
		/*
		 * no file defined
		 */
		return FALSE ;
	}

	fprintf( file, "%s\n", VD_QRY_FILE_COMMENT );
	fprintf( file, "%s\n", VD_QRY_FILE_COMMENT );

	fprintf( file, "%s\t%s - %s\n", VD_QRY_FILE_COMMENT, 
                                        VD_QRY_ASCII_COMMENT, 
                                        VD_QRY_ASCII_HEADER );

	fprintf( file, "%s\n", VD_QRY_FILE_COMMENT );
	fprintf( file, "%s\n", VD_QRY_FILE_COMMENT );

	fprintf( file, "%s\t%s", VD_QRY_FILE_COMMENT, vd$get_time() );

	fprintf( file, "%s\n", VD_QRY_FILE_COMMENT );
	fprintf( file, "%s\n", VD_QRY_FILE_COMMENT );

	return TRUE ;
} /* VDqry_write_header */
/*--------------------------------------------------------------------------*/
VDqry_write_entry( file, text, select, where, comment )
FILE			*file;
IGRchar			*text;
IGRchar			*select;
IGRchar			*where;
IGRchar			*comment;
{


	if( ! text || ! select ){
		/*
		 * we do not allow to write queries without any name
		 */
		return FALSE ;
	}

	fprintf( file, "\n\n" );
	fprintf( file, "%s\t%s\n\n", VD_QRY_ASCII_NAME, text  );

	/*
	 * set the definition title.
	 */
	fprintf( file, "%s\n", VD_QRY_ASCII_DEFINITION );
	fprintf( file, "\t%s\n", select );

	if( where )
		fprintf( file,"\t%s\n\n", where );

	if( comment ){
		fprintf( file, "%s\n", VD_QRY_ASCII_COMMENT );
		fprintf( file, "\t%s\n", comment );
	} 

	return	TRUE ;

} /*VDqry_write_entry */
/*-------------------------------------------------------------------------*/	
VDqry_find_name( file, text, name )
FILE			*file;			/* in    */
IGRchar			*text;			/* in  or NULL  */
IGRchar			*name;			/* out or NULL  */
{
IGRint			sts;
GRname			buffer;
IGRint			size = DI_PATH_MAX ;
IGRchar			*pText;

	sts = TRUE ;
	/*
	 * find the query name and look for the starting location
	 * of definition part. if name != NULL, function finds name.
         * if name == NULL, function tests name see if it equals selected
         * name.
	 */

	if( ! text && ! name ){
		/*
		 * error in setup
		 */
		return FALSE;
	}

	while( TRUE ){

		/*
		 * read a line of the file and check the name.
		 */

		if( ! VDio_read_line(	file,
					buffer,
					size ) ){
			/*
			 * end of file
			 */
			sts = FALSE ;
			break ;
		}

		/*
		 * scann the information.
		 */
		if( strncmp(buffer, VD_QRY_FILE_COMMENT, 1) == 0){
			/*
			 * skip command lines.
			 */
			continue;  /* back to while */
		}
		/*
		 * scann the blank lines.
		 */
		if( buffer[0] == '\0'){
			continue;  /* back to while */
		}
		/*
		 * if <Name> is find, check string after it to 
                 * see if it equals the input text.
                 */ 
		if( strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ){

			pText = &( buffer[VD_QRY_ASCII_szNAME+1] );

			/*
			 * skip space characters befroe name.
			 */
			while( pText[0] != '\0' &&
				( pText[0] == ' '  ||
				  pText[0] == '\t' ||
				  pText[0] == '\n' )	)	pText ++;

			if( pText[0] == '\0' && name  ) {
				/*
				 * No name defined. (name = " ")
				 */
				continue;        /* back to while (TRUE) */
			}

			if( name ){

				/*
				 * copy info  into name array 
				 */
				strcpy( name, pText );
				sts = TRUE ;
				break ;
			}
			/* check if input name =  content of <Name> */
			if( strcmp( text, pText ) != 0 ){
				continue;
			}
 
			/*
			 * get the definition.
			 */
			sts = TRUE ;
			break ;
		} /* if */
	} /* while */

	return	sts ;

} /* VDqry_find_name */
/*------------------------------------------------------------------------*/
VDqry_find_definition( file, select, comment ,prepos)
FILE			*file;			/* in  */
IGRchar			**select;               /* out */
IGRchar			**comment;		/* out */
long			*prepos;		/* in/out */
{
IGRint			msg = TRUE ;
GRname			buffer;
IGRint			size = DI_PATH_MAX ;
IGRint			len;
IGRint			nameflag = 1;
IGRint			defflag =  2;
IGRint			commflag = 3;
IGRint			flag  = 0;
long			flong;

  flong = 0;  // UnInit warning

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
			msg = FALSE;
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
                 *   <Comment> ....
                 *   return FALSE
                 */
                                  
		if( (strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) ||
		    ( strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 )){
			msg = FALSE ;
			break ;
		}

                /* 
                 * if line is not 
                 * <Definition>
                 * goto read next line, this format ignores the garbages
                 * before the <Definition>
                 */

		if( strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF ) != 0 ){
			/*
			 * looking for next line.
			 */
                        *prepos = flong;
			continue;
		}

		msg = TRUE ;
		break;
	} /* while */

	/*
	 * start reading the definition line(s).
	 */
		
	while( msg ){
                        
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
			msg = FALSE;
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
                 * skip the blank line below the <Definition>
                 */
		if( (len = strlen( buffer )) == 0 && *select == NULL){
                        *prepos = flong;
		        continue;	
                }
		/*
                 *  not allow <Name>, <Definition>, <Comment>
                 *  occur before reading contents of definition. 
		 */

		if(( (strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) && !*select) ||
		   ( (strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF  ) == 0 ) && !*select) ||
		   ( (strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 ) && !*select)){
			/*
			 * did not found the definition.
			 */
			msg = FALSE ;
			break;
                        /* goto wrapup ; */
		}
		/*
                 *  the occurence of  <Name>, <Definition>, <Comment>
                 *  means finish of definiton after reading contents of
		 *  definition, then return true.		 
		*/
		if( (strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) && *select){ 
			msg = TRUE ;
                        flag = nameflag ;
               		break;
 		}     
		if( (strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF  ) == 0 ) && *select){
			msg = TRUE ;
                        flag  = defflag;
               		break;
 		}     
		if( (strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 ) && *select){
			msg = TRUE ;
                        flag = commflag;
               		break;
		}
		/*
		/* 
                 * the content of definition can put in several lines, but 
                 * no blank lnes allowed between the content lines. When 
                 * blank line is met, it means the difinition part ends
                 * 
                 */
                /*
		if( (len = strlen( buffer )) == 0 && *select[0] != NULL){
                        msg = TRUE;
			break;
		}
                */
		if( ! *select ){
			*select = _MALLOC(len+2, char);
			*select[0] = '\0';
		}
		else{
			len += strlen( *select );
			*select = _REALLOC(	*select, len+2, char );
		}

		strcat( *select, buffer );
		strcat( *select, " " );

	} /* while(msg) */
	if( *select )	msg = TRUE ;

        /* read comments: if no comment we return blank line  */	
	if( ! *comment ){
			*comment = _MALLOC(2, char );
			*comment[0] = '\0';
	}
	if(flag ==  commflag){
		VDqry_find_comment( file, comment, prepos );       
        }   
        
	return msg ;

} /* VDqry_find_definition */
/*------------------------------------------------------------------------*/
VDqry_find_comment( file, comment ,prepos)
FILE			*file;			/* in     */
IGRchar			**comment;		/* out    */
long			*prepos;		/* in/out */
{
IGRint			msg = TRUE ;
GRname			buffer;
IGRint			size = DI_PATH_MAX ;
IGRint			len = 0;
long 			flong;

  flong = 0;  // UnInit warning

	/*
	 * start reading the comment line(s).
         * this is option but we must keep the line <Comment> there.
	 */
	while( msg ){
	
		/*
		 * read a line of the file 
		 */
		if( ! VDio_read_line(	file,
					buffer,
					size ) ){
			/*
			 * end of file, even not find <comment> line, it still
                         * ok
			 */
			msg = TRUE ;
			goto wrapup;
		}
		flong = ftell(file); 

		/*
		 * scan the information.
		 */
		if( strncmp ( buffer, VD_QRY_FILE_COMMENT, 1 ) == 0){
			/*
			 * get next line of text.
			 */
                        *prepos = flong;
			continue;
		}

                /* skip blank lines */
                if( buffer[0]== '\0' ){
                        /*
                         * get next line of text.
                         */
                        *prepos = flong;
                        continue;
                }

                /*
                 *   if next line is following format
                 *      	<Name> ......
                 *   or		<definition> 
		 *		....
                 *   or		<Comment> 
		 *		....
                 *   or         <Prefix>
                 *              ....
                 *   it means the comment finish and return TRUE
                 */

		if(( strncmp(	buffer,
				VD_QRY_ASCII_NAME,
				VD_QRY_ASCII_szNAME ) == 0 ) ||

		   ( strncmp(	buffer,
				VD_QRY_ASCII_COMMENT,
				VD_QRY_ASCII_szCOMMENT ) == 0 ) ||
                   ( strncmp(   buffer,
                                VD_QRY_ASCII_PREFIX,
                                VD_QRY_ASCII_szPREFIX) == 0 ) ||

		   ( strncmp(	buffer,
				VD_QRY_ASCII_DEFINITION,
				VD_QRY_ASCII_szDEF ) == 0 )){
			msg = TRUE ;
			goto wrapup;
		}

		len = strlen( buffer );

		if(  *comment ){
			len += strlen( *comment );
			*comment = _REALLOC(	*comment, len+2 , char);
		}

		strcat( *comment, buffer );

		/*
		 * add a new line in comment field.
		 */
		strcat( *comment, "\n" );
	} /* while */

wrapup:
	return msg ;
}

/**************************************************************************/
VDio_read_line( fp, buffer, size )
FILE			*fp;			/* in  */
IGRchar			*buffer;		/* out */
IGRint			size;			/* in  */
{
IGRint			i,
		        ii,
			len;

	if( ! buffer )	return FALSE ;

	buffer[0] = '\0';

	if( fgets( buffer, size, fp ) == NULL ){
		/*
		 * end_of_file
		 */
		return FALSE;
	}

	/*
	 * remove space characters at end of buffer
	 */
	len = strlen( buffer );
	while(--len){
		if( buffer[len] == '\n' || buffer[len] == ' ' ){
			buffer[len] = '\0';
			continue;
		}
		break;
	}

	/*
	 * remove space characters at begin of buffer
	 */
	len = strlen( buffer );
	i = 0;
	while(	i < len &&
		( buffer[i] == ' ' || buffer[i] == '\t' || buffer[i] == '\n' ))
			i++;

	ii = 0;
	while( i < len ) buffer[ii++] = buffer[i++]; 
	buffer[ii] = '\0';          /* set last character '\0' */


#ifdef	DEBUG
	printf(" buffer: %s\n", buffer );
#endif

	return( TRUE );
} /* VDio_read_line */
/*--------------------------------------------------------------------------*/

