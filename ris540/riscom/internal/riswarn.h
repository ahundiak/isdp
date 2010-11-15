/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							riswarn.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/


/* Set Warning bits */
#define RESET_RIS_WARNING(mask)			mask &= 0
#define SET_RIS_WARNING(mask)			mask |= RIS_WARNING
#define SET_RIS_WARNING1(mask)			mask |= RIS_WARNING|RIS_WARNING1
#define SET_RIS_WARNING2(mask)			mask |= RIS_WARNING|RIS_WARNING2
#define SET_RIS_ILICENSE_WARNING(mask)	mask |= RIS_WARNING|RIS_ILICENSE_WARNING
#define SET_RIS_WARNING4(mask)			mask |= RIS_WARNING|RIS_WARNING4
#define SET_RIS_WARNING5(mask)			mask |= RIS_WARNING|RIS_WARNING5
#define SET_RIS_PRIM_SCH_WARNING(mask)	mask |= RIS_WARNING|RIS_PRIM_SCH_WARNING
#define SET_RIS_SEC_SCH_WARNING(mask) 	mask |= RIS_WARNING|RIS_SEC_SCH_WARNING

/*
**	TYPES
*/

/*
**	VARIABLES
*/
