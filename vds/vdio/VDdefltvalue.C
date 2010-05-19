
/***************************************************************************
 * I/VDS
 *
 * File:        vdio/VDdefltvalue.C
 *
 * Purpose:
 *              Functions used to read the attribute names and values from
 *              an ascii file.
 * Description:
 *              The file format must be %attribute name followed by a list 
 *              of possible values for the attribute. %name and values is
 *              repeated for each attribute.
 *
 * History:
 *   MM/DD/YY   AUTHOR  DESCRIPTION
 *   06/10/97   EJM     CR#179527294  Add "Read from File" capability
 *
 *                      This file adapted from Struct file of same name
 *                      in struct/vsio. Default refers to ascii file
 *                      input data, namely, attribute names and their values.
 *
 ***************************************************************************/

#include <stdio.h>
#include <string.h>
#include "vddefltvalue.h"

#define TRUE  1
#define FALSE 0


/*
 * To read a line of the files of default values.
 */
#define BUFFERSIZE	256
typedef char BUFFER[BUFFERSIZE] ;
/*----------------------------------------------------------------------------*/
static int ReadLine( FILE* f, BUFFER b ) {

	int		readChar	= 0 ;
	int		i		= 0 ;
	int		eof		= FALSE ;
	int		eol		= FALSE ;
	const int	max		= BUFFERSIZE - 1 ;

	/*
	 * '#' in 1st column indicate comments: skip until the end-of-line
	 * Otherwise lines are truncated to 'BUFFERSIZE - 1'
	 */

	do {
		switch( readChar = fgetc( f ) ) {
			case '#'  : if( i == 0 ) { b[0] = '\0' ; i = max ; }
				    break ;
			case EOF  : eof = TRUE ; readChar = '\0' ; break ;
			case '\n' :
			case '\r' : eol = TRUE ; readChar = '\0' ; break ;
		}
		if( i < max ) {
			b[i++] = readChar ;
			if( eol ) { b[i] = '\0' ; return FALSE ; }
		} else	b[max] = '\0' ;
	
	} while ( !( eol || eof ) ) ;

	return eof ;

} /* ReadLine */
/*----------------------------------------------------------------------------*/
int VDreadDefaultValues( FILE *f, const int max, VDdefaultValues d[] ) {

	BUFFER		line ;
	int		eof ;
	int		i = -1 ;
	const int	nmln = VD_K_DEFVAL_NM_SZ - 1 ;
	const int	vlln = VD_K_DEFVAL_VL_SZ - 1 ;

	do {
		eof = ReadLine( f, line ) ;
		/* Remove leading & trailing blanks */
		VD_stripString( line ) ;
		if( *line ) {
			/* Non-empty line */
			if( *line == '%' ) {
				/* Lines beginning with '%' flag attribute
				 * names. Store the name, truncating to
				 * 'VD_K_DEFVAL_NM_SZ' characters
				 */
				i++ ;
				strncpy( d[i].attrName,
					 line + 1,
					 nmln )[nmln] = '\0' ;
				d[i].count = 0 ;
				d[i].curVal= -1 ;
			} else {
				/*
				 * Lines not beginning with '%' are the values
				 * for the preceeding name found.
				 */
				if( i >= 0 && d[i].count < VD_K_MX_NB_OF_VLS ) {
					strncpy( d[i].attrValues[d[i].count++],
						 line,
						 vlln )[vlln] = '\0' ;
				} /* Else : skip it */
			}
		}
	} while( !eof && i < max ) ;

	/*
	 * Return the number of attributes read.
	 */
	return i + 1 ;

} /* VDreadDefaultValues */
/*----------------------------------------------------------------------------*/

