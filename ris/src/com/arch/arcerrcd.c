/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							arcerrcd.c
**	AUTHORS:						David Michal
**	CREATION DATE:					9/91
**	ABSTRACT:
**			Generic interface error codes.
**	
**	REVISION HISTORY:
*/

#include "risarch.h"

static struct
{
	char *code;
	char *msg;
} ARC_error_info[] =
{
{	/* Error code #0 */
	"ARC_SUCCESS",
	"Successful Architecture Conversion"
},
{	/* Error code #1 */
	"ARC_INTERNAL_ERROR",
	"Internal architecture error"
},
{	/* Error code #2 */
	"ARC_OVERFLOW",
	"Source float magnitude too large for dest float"
},
{	/* Error code #3 */
	"ARC_UNDERFLOW",
	"Source float magnitude too small for dest float"
},
{	/* Error code #4 */
	"ARC_NOT_A_NUMBER",
	"Source float is not a valid number"
},
{   /* Error code #5 */
    "ARC_NO_CONVERSION",
    "No conversion function is defined for this type"
},

{	/* Error code #6 */
	"ARC_IBM_UNDERFLOW_ERROR",
	"Underflow error: resulted during architecture conversion to IBM"
},

{	/* Error code # 7 */
	"ARC_IBM_OVERFLOW_ERROR",
	"Overflow error: resulted during architecture conversion to IBM"
},
{	/* Error code #8 */
	"ARC_IBM_INFINITY_ERROR",
	"Infinity error: resulted during architecture conversion to IBM"
},
{	/* Error code #9 */
	"ARC_IBM_NOT_NUMBER_ERROR",
	"Not-a-number: error resulted during architecture conversion to IBM"
},
{	/* Error code #10 */
	"ARC_IBM_UNDETERMINED_ERROR",
	"Undetermined error: resulted during architecture conversion to IBM"
},
{   /* Error code #11 */
    "ARC_LAST_ERROR_CODE",
    "Invalid architecture error code"
}
};

/*
**	FUNCTIONS
*/

/******************************************************************************/

/* return the error message for the given error code */

extern char *ARC_error_msg(
	int code)
{
	if (code < 0 || code > ARC_LAST_ERROR_CODE) 
	{
		ARC_DBG(("ARC_error_msg - CODE OUT OF RANGE - %d\n", code));
		code = ARC_LAST_ERROR_CODE;
	}
	return(ARC_error_info[code].msg);
}

/******************************************************************************/

extern char *ARC_error_code(
	int code)
{
	if (code < 0 || code > ARC_LAST_ERROR_CODE) code = ARC_LAST_ERROR_CODE;
	return(ARC_error_info[code].code);
}

/******************************************************************************/

/* Generic error handler */

extern void ARC_error(
	arc_s  * arc,
	int  code)
{

ARC_DBG(("ARC_error: arc = 0x%x code = %d\n",arc,code));

	arc->error_code = code;
	strcpy(arc->error_string, ARC_error_msg(code));

ARC_DBG(("error string = <%s>\n", arc->error_string));

}

/******************************************************************************/
