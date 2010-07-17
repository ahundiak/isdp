#ifndef applimits_defined
#define	applimits_defined

/* Doc: applimits.h

   Abstract:
	
   History:

	Date		Who		Why
	---------	------		----------------------------------
	04-17-90	kk		Creation
	04-24-91	msl		Added AP_MAX_NAME_LEN
	10-20-93	jc		Added AP_MAX_NAME_LEN2
*/
/* *****************************H H H H H******************************* */

/*
**  Table Manager #defines
*/
#define		FE_MAX_TBLNAME_SIZE	17	/* Size of names for load cases */
#define		AP_MAX_NAME_LEN		32	/* Size of names (table columns etc) */

/*
**  Size of names for some database entities such as Load Cases, etc.
**  NOTE: AP_MAX_NAME_LEN can also be used for entities such as material names, etc.
*/
#define		AP_MAX_NAME_LEN2	17	/* Size of names ( Load Cases, etc) */

/*
**  Coordinate System #defines
*/
#define 	AP_MAX_CS_NAME_LEN	17 	/* Includes null terminator 	*/
#define 	AP_MAX_CS_NAME_BUF 	128	/* Buffer for CS name		*/

#endif
