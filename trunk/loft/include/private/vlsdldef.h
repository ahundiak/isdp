/*
	vlsdldef.h : 
*/

#ifndef	vlsdldef_include
#define	vlsdldef_include

/* General definitions for reporting */
#define	VLSDL_MAX_IDX		200
#define VLSDL_CHECK_IDX		if (idx > VLSDL_MAX_IDX - 1) \
{ printf ("Error : index too large : %d\n", idx); sts = MSFAIL; goto wrapup; }

/* Name of System attributes */
#define	VLSDL_STATE		"CUR_STATE"
#define	VLSDL_FILE_PATH		"FILE_PATH"
#define VLSDL_VIEW		"CUR_VIEW"

#define VLSDL_SYST_COL		1
#define VLSDL_USER_COL		2

/* Keywords for attributes handling */
#define VLSDL_SET_ATTR		"vl-SetAttributeVal"
#define VLSDL_GET_ATTR		"vl-GetAttributeVal"

/* Keywords for <vl-xxxx> functions */
#define	VLSDL_F_FOPEN		"vl-OpenFile"
#define	VLSDL_F_PRINT		"vl-Print"
#define	VLSDL_F_SKIP		"vl-Skip"
#define	VLSDL_F_PATTERN		"vl-RepeatPattern"
#define	VLSDL_F_SPRINTF		"vl-Sprintf"

/* Keywords for Graphic Placement */
#define VLSDL_PLMACRO		"vl-PlaceMacro"

#endif
