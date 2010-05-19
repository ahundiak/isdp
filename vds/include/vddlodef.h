/* $Id: vddlodef.h,v 1.2 2002/05/20 15:17:02 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/vddlodef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddlodef.h,v $
 *	Revision 1.2  2002/05/20 15:17:02  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/07  15:08:14  pinnacle
 * Replaced: include/vddlodef.h for:  by yzhu for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/05/04  16:22:10  pinnacle
 * Replace: include/vddlodef.h by tdumbach for OPE
 *
 * Revision 1.1  1995/03/16  21:45:38  pinnacle
 * Created: include/vddlodef.h by azuurhou r#
 * rno
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	05/20/02	ylong		TR6281
 * -------------------------------------------------------------------*/


#ifndef vddlodef_include
#define vddlodef_include

/*
 * 	This file depends on the following files :
 *	
 */

/*---------------------------------------------------------------------------*/

/*
 * Information data structure.
 */
#define		VD_drwLO_Type_char		1
#define		VD_drwLO_Type_double		2
#define		VD_drwLO_Type_short		3
#define		VD_drwLO_Type_int		4
#define		VD_drwLO_Type_string		5
#define		VD_drwLO_Type_point		6
#define		VD_drwLO_Type_vec		7

/*
 * Drawing Layout Data structture.
 */
struct  VD_s_drwLoInfo {
	IGRshort	type;

	union {
		IGRchar		cValue;
		IGRdouble	dValue;
		IGRshort	sValue;
		IGRint		iValue;
		IGRchar		sString[80];
		IGRpoint	point;
		IGRvector	vec;
	} val;
};
typedef	struct	VD_s_drwLoInfo VD_drwLoInfo ;


/*
 * 	VD_K_drwLO_*****	: The macro access constant for LO variables.
 *
 *	VD_S_drwLO_*****	: Corresponding string name in collector.
 *
 *	VD_F_drwLO_*****	: Correspsonding Gadgets in form.
 */

/*
 * Projection point for the drawing extraction process.
 */

#define		VD_K_drwLO_MaxAttr		16

#define		VD_K_drwLO_projPoint		1

#define		VD_F_drwLO_projPointX		23
#define		VD_F_drwLO_projPointY		24
#define		VD_F_drwLO_projPointZ		25

#define		VD_S_drwLO_projPoint		"projPoint"
#define		VD_S_drwLO_projPoint_X		"projPoint_X"
#define		VD_S_drwLO_projPoint_Y		"projPoint_Y"
#define		VD_S_drwLO_projPoint_Z		"projPoint_Z"

/*
 * Projection vector for the drawing extraction process.
 */

#define		VD_K_drwLO_projVector		2

#define		VD_F_drwLO_projVector_X		26
#define		VD_F_drwLO_projVector_Y		27
#define		VD_F_drwLO_projVector_Z		28
   
#define		VD_S_drwLO_projVector		"projVector"
#define		VD_S_drwLO_projVector_X		"projVector_X"
#define		VD_S_drwLO_projVector_Y		"projVector_Y"
#define		VD_S_drwLO_projVector_Z		"projVector_Z"

/*
 * The sheet can be placed later using the place Table command. A
 *  sheet is nothing more then a specific table, inwhich the center
 *  is totaly empty.
 */

#define		VD_K_drwLO_sheetColor		3
#define		VD_F_drwLO_sheetColor		0
#define		VD_S_drwLO_sheetColor		"sheetColor"

/*
 * The level on with we will display the tables.
 */
#define		VD_K_drwLO_tblLevel		4
#define		VD_F_drwLO_tblLevel		30
#define		VD_S_drwLO_tblLevel		"tblLevel"

/*
 * The default table color.
 */
#define		VD_K_drwLO_tblColor		5
#define		VD_F_drwLO_tblColor		39
#define		VD_S_drwLO_tblColor		"tblColor"

/*
 * Color for user defined Text in Table.
 */
#define		VD_K_drwLO_tblTextColor		6
#define		VD_F_drwLO_tblTextColor		41
#define		VD_S_drwLO_tblTextColor		"tblTextColor"

/*
 * Color for objects attribute information.
 */
#define		VD_K_drwLO_tblAttColor		7
#define		VD_F_drwLO_tblAttColor		42
#define		VD_S_drwLO_tblAttColor		"tblAttColor"

/*
 * Color for Overriden Attribute Data Fields.
 */
#define		VD_K_drwLO_tblModColor		8
#define		VD_F_drwLO_tblModColor		43
#define		VD_S_drwLO_tblModColor		"tblModColor"


/*
 * The level on with we will display the drawingviews.
 */
#define		VD_K_drwLO_drvLevel		9
#define		VD_F_drwLO_drvLevel		46
#define		VD_S_drwLO_drvLevel		"drvLevel"


/*
 * Object representation information.
 */

#define		VD_K_drwLO_objRep		10
#define		VD_F_drwLO_objRep		49
#define		VD_S_drwLO_objRep		"objRep_"


/*
 * The height for drawing frame.
 */
#define         VD_K_drwLO_frmHeight            11
#define         VD_F_drwLO_frmHeight            56
#define         VD_S_drwLO_frmHeight            "frmHeight"


/*
 * The color for drawing frame.
 */
#define         VD_K_drwLO_frmColor             12
#define         VD_F_drwLO_frmColor             62
#define         VD_S_drwLO_frmColor             "frmColor"

/*
 * The style for drawing frame.
 */
#define         VD_K_drwLO_frmStyle             13
#define         VD_F_drwLO_frmStyle             58
#define         VD_S_drwLO_frmStyle             "frmStyle"


/*
 * The weight for drawing frame.
 */
#define         VD_K_drwLO_frmWeight             14
#define         VD_F_drwLO_frmWeight             61
#define         VD_S_drwLO_frmWeight             "frmWeight"

/*
 * Flag for reserving position and item number for lined out row.
 */
#define		VD_K_drwLO_tblUsrValue		15
#define		VD_F_drwLO_tblUsrValue		71
#define		VD_S_drwLO_tblUsrValue		"tblUsrValue"

/*
 * Flag for reserving values keyed-in by user.
 */
#define		VD_K_drwLO_tblLinedOut		16
#define		VD_F_drwLO_tblLinedOut		72
#define		VD_S_drwLO_tblLinedOut		"tblLinedOut"


/*
 * Name of the collector
 */
#define		VD_DRWLO_DIR_NAME		"VDdrwInfo"


/*
 * Information internal matching structure.
 */
struct	VD_s_drwInfoInternal {

	char	*text ;		/* VD_S_drwLO_****	*/
	int	type ;		/* VD_K_drwLO_****	*/
	int	gadget ;	/* VD_F_drwLO_****	*/
	int	var ;		/* Output Structure 	*/
};

typedef	struct	VD_s_drwInfoInternal	VD_drwInfoInternal ;

/*
 * serial no. of the attributes 
 */
#define  PRJ_PT_X	0
#define  PRJ_PT_Y	1
#define  PRJ_PT_Z	2
#define  PRJ_VEC_X	3
#define  PRJ_VEC_Y	4
#define  PRJ_VEC_Z	5
#define  TBL_LO_CLR	6

#define  VD_UNDEFINED		-100
#define  VD_UNDEFINED_STR	"-100"


#endif	/* vddlodef_macros */

