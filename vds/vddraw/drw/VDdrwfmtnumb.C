/*
	I/VDS	Copy.
*/
#include <string.h>
#include <stdlib.h>

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_strngproto.h"
/*----------------------------------------------------------------------------*/
int VD_formatNumber( format, d, output, size, errFile )

const char	*format ;	/* IN : Format for number		*/
char		output[] ;	/* OUT: Buffer for formatted number	*/
IGRdouble		d ;		/* IN : Number to format		*/
int		size ;		/* IN : Size of output buffer		*/
FILE		*errFile ; {	/* IN : error file pointer (may be NULL)*/

	/*
	 * Format a print of a double given the integer part and the decimal
	 * part, and a delimiter between them ( we think here of a '.' in
	 * the Anglo-Saxon world, and a ',' in the rest of the world ) :
	 *
	 *	<integer part><delimiter><decimal part>
	 * Examples: "12.7", "9,2"
	 */
#define	MAX	20
	char		*endstr,
			delimiter	= '\0',
			*p,
			tmp[MAX+1+MAX+1] ;
	const char	*endfmt 	= format + strlen( format ) ;
	int		integerpart ;

	*tmp = '\0' ;

	integerpart = strtol( format, &endstr, 10 ) ;
	if( integerpart > MAX ) integerpart = MAX ;

	if( endstr == endfmt ) {
		sprintf( tmp, "%*.0lf", integerpart, d ) ;
	} else if( endstr != format ) {
		int	decimalpart ;

		delimiter	= *endstr,
		p		= endstr + 1 ;
		decimalpart	= strtol( p, &endstr, 10 ) ;

		if( endstr == endfmt ) {
			if( endstr == p ) decimalpart = 0 ;
			else if( decimalpart > MAX ) decimalpart = MAX ;

			sprintf( tmp, "%*.*lf", integerpart, decimalpart, d ) ;

		} else if( errFile ) {
			fprintf( errFile, "\n" ) ;
			VD_drwPrintf( "!!! Bad decimal part for number : '%s'\n",
					format ) ;
		}
	} else if( errFile ) {
		fprintf( errFile, "\n" ) ;
		VD_drwPrintf( "!!! Bad format for number : '%s'\n", format ) ;
	}
	if( *tmp ) {
		int	truncated ;

		for( p = tmp ; ' ' == *p ; p++ ) ;
		VD_strncpy( output, p, size, &truncated ) ;
		if(    delimiter
		    && ( p = strchr( output, '.' ) ) ) *p = delimiter ;
	} else *output = '\0' ;

	return *output != '\0' ;

} /* VD_formatNumber */
/*----------------------------------------------------------------------------*/

