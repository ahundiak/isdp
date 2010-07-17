/* $Id: VRcabledef.h,v 1.1.1.1 2001/01/04 21:12:55 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude / VRcabledef.h
 *
 * Description:
	The cable include file contains constants for the 
	cable expression values. Here, the expression working directory 
	is specified inwhich the expression string are defined. The 
	values are set in the command object "Set/Review Cable Directory
	Paths" and used in the command object "Connect Cables" and
	"Create Cable Output File"

	In case the expressions and the expr. directory are not placed
	on the right location, the program allows to modify the string.
		
	The cable expression directory is placed after the path:

		:<file_name>:usr:"CABLE_EXP_DIR"

 * Dependences:
	The file VRcabledef.h is depended on the following files:

			- igrtypedef.h
			- igetypedef.h
			- igrdp.h
			- dpstruct.h
 * Revision History:
 *	$Log: VRcabledef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:55  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/13  00:00:06  pinnacle
 * Replaced: vrinclude/VRcabledef.h for:  by r240_int for route240
 *
 *
 * History:
	04/28/91	ADZ	Creation date.
	01/12/96	tlb	Add struct Cable
 *
 *************************************************************************/

#ifndef VRcabledef_include

#define VRcabledef_include

#include "GRtypedef.h"
/*
 * expressions names
 */
#define CABLE_EXP_DIR           "CABLE_EXP_DIR"		/* expression directory */
#define CABLE_EQUIP_TABLE       "Cable_Expression1"
#define CABLE_OUTPUT_FILE       "Cable_Expression2"
#define CABLE_WORKING_DIR       "Cable_Expression3"

/*
 * text limitation
 */
#define CABLE_MAX_TXT   80
#define CABLE_MAX_BUF   200

/*
 * parameters of cable gadgets
 */
#define VRCAB_UNDEF	0
#define	VRCAB_ACCEPT	1
#define	VRCAB_EXECUTE	2
#define VRCAB_CANCEL	4
#define	VRCAB_MCF1	12
#define	VRCAB_LOCATE	15
#define	VRCAB_TRACE	16
#define	VRCAB_DIGID	17
#define VRCAB_FORM_INFO	255	/* exist from form_notification */

#define	VRCAB_LINEDYN	100	/* dynamics constant */
#define	VRCAB_HIL_EQUIP	101	/* dynamics constant */

#define	VRCAB_RWAY_COMP	120	/* select point on VRRWay component */
#define	VRCAB_RWAY_PNT	121

/*
 * constants for memory allocation
 */
#define VRCAB_MAXBUF	500
#define VRCAB_INCRBUF	100

/*
 * cable flags
 */
#define	VRCAB_IN_LIST	0
#define	VRCAB_OUT_LIST	1

/*
 * dynamic structure
 */
struct	VRcable_params{

	GRobjid			ObjId;
	IGRdouble		*start_pnt;
	IGRdouble		*end_pnt;
	IGRdouble		*start_vec;
	IGRboolean		Dynamic_Point;
	IGRdouble		*Z_Window;
	
	IGRdouble		*Pnts;
	IGRdouble		num_pnts;
	struct	DPele_header	*header_line;
};

struct	VRcable_data{
	IGRchar		CableNameStr[CABLE_MAX_TXT];
	IGRchar		Equipment1Str[CABLE_MAX_TXT];
	IGRchar		Equipment2Str[CABLE_MAX_TXT];
	IGRchar		ConnectPnt1Str[CABLE_MAX_TXT];
	IGRchar		ConnectPnt2Str[CABLE_MAX_TXT];
	IGRchar		BendRadiusStr[CABLE_MAX_TXT];
	IGRchar		SectRadiusStr[CABLE_MAX_TXT];

	IGRdouble	BendRadius;
	IGRdouble	SectRadius;

	IGRboolean	not_displayed;
	IGRboolean	start_index;	/* Equip1(FALSE) Equip2(TRUE) */
};

struct	VRcable{

	GRobjid			ObjId;
	IGRdouble		*start_pnt;
	IGRdouble		*end_pnt;
	IGRdouble		*start_vec;
	IGRboolean		Dynamic_Point;
	IGRdouble		*Z_Window;
	
	struct VRcable_data	*Cable_Data;
	IGRdouble		*Pnts;
	IGRint			num_pnts;
	struct	DPele_header	*header_line;
};
#endif
