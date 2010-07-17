/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "vsdefltvalue.h"

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
int VSreadDefaultValues( FILE *f, const int max, VSdefaultValues d[] ) {

	BUFFER		line ;
	int		eof ;
	int		i = -1 ;
	const int	nmln = VS_K_DEFVAL_NM_SZ - 1 ;
	const int	vlln = VS_K_DEFVAL_VL_SZ - 1 ;

	do {
		eof = ReadLine( f, line ) ;
		/* Remove leading & trailing blanks */
		VSstripString( line ) ;
		if( *line ) {
			/* Non-empty line */
			if( *line == '%' ) {
				/* Lines beginning with '%' flag attribute
				 * names. Store the name, truncating to
				 * 'VS_K_DEFVAL_NM_SZ' characters
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
				if( i >= 0 && d[i].count < VS_K_MX_NB_OF_VLS ) {
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

} /* VSreadDefaultValues */
/*----------------------------------------------------------------------------*/

