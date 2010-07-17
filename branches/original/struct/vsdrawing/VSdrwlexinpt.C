/*
	I/STRUCT
*/

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"

extern int	VSyydrwlineno ;
extern FILE	*VSyydrwin ;
extern char	*VSyydrwsptr ;
extern char	VSyydrwsbuf[] ;
/*----------------------------------------------------------------------------*/
void VSsetDrwConfigInput( file, lineno ) FILE *file ; int lineno ; {

	/*
	 * Tell lex where to read from.
	 */
	 VSyydrwin	= file ;
	 VSyydrwlineno	= lineno ;

} /* VSsetDrwConfigInput */
/*----------------------------------------------------------------------------*/
void VSdrwResynchLex __(( void )) {

	VSyydrwsptr	= VSyydrwsbuf ;

} /* VSdrwResynchLex */
/*----------------------------------------------------------------------------*/
int VSyydrwWrap( verbose, inputs )

int		verbose ;
VSdrwInputFiles	*inputs ; {

	int	stackNotEmpty ;
	int	stopScanning ;

	/*
	 * If we are at the end of an included file, then close it, and set
	 * Lex's input file pointer to the including file. If it is the
	 * topmost file then `stackNotEmpty' will be FALSE.
	 */
	stackNotEmpty = VSdrwPopInputFile( verbose, inputs ) ;

	if( stackNotEmpty ) {
		stopScanning = FALSE ;
	} else {
		stopScanning = TRUE ;
		/*
		 * Resync for next time.
		 */
		VSdrwResynchLex() ;
	}

	return stopScanning ;

} /* VSyydrwWrap */
/*----------------------------------------------------------------------------*/

