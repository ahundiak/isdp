/*
	I/VDS	Copy.
*/

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"

extern int	VDyydrwlineno ;
extern FILE	*VDyydrwin ;
extern char	*VDyydrwsptr ;
extern char	VDyydrwsbuf[] ;
/*----------------------------------------------------------------------------*/
void VD_setDrwConfigInput( file, lineno ) FILE *file ; int lineno ; {

	/*
	 * Tell lex where to read from.
	 */
	 VDyydrwin	= file ;
	 VDyydrwlineno	= lineno ;

} /* VD_setDrwConfigInput */
/*----------------------------------------------------------------------------*/
void VD_drwResynchLex __(( void )) {

	VDyydrwsptr	= VDyydrwsbuf ;

} /* VD_drwResynchLex */
/*----------------------------------------------------------------------------*/
int VDyydrwWrap( verbose, inputs )

int		verbose ;
VD_drwInputFiles	*inputs ; {

	int	stackNotEmpty ;
	int	stopScanning ;

	/*
	 * If we are at the end of an included file, then close it, and set
	 * Lex's input file pointer to the including file. If it is the
	 * topmost file then `stackNotEmpty' will be FALSE.
	 */
	stackNotEmpty = VD_drwPopInputFile( verbose, inputs ) ;

	if( stackNotEmpty ) {
		stopScanning = FALSE ;
	} else {
		stopScanning = TRUE ;
		/*
		 * Resync for next time.
		 */
		VD_drwResynchLex() ;
	}

	return stopScanning ;

} /* VDyydrwWrap */
/*----------------------------------------------------------------------------*/

