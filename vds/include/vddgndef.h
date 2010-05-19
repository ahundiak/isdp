/* $Id: vddgndef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/vddgndef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddgndef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/07/08  17:24:44  pinnacle
 * Created: include/vddgndef.h by yzhu for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/01/97	yzhu		create 
 * -------------------------------------------------------------------*/


#ifndef vddgndef_include
#define vddgndef_include

/*
 * 	This file depends on the following files :
 */

/*---------------------------------------------------------------------------*/

/*
 * Information data structure.
 */
#define		VD_dgnSt_Type_char		1
#define		VD_dgnSt_Type_double		2
#define		VD_dgnSt_Type_short		3
#define		VD_dgnSt_Type_int		4
#define		VD_dgnSt_Type_string		5
#define		VD_dgnSt_Type_point		6
#define		VD_dgnSt_Type_vec		7

/*
 * Desing Setup Data structture.
 */
struct  VD_s_dgnStInfo {
	IGRshort	type;

	union {
		IGRchar		cValue;
		IGRdouble	dValue;
		IGRshort	sValue;
		IGRint		iValue;
		IGRchar		sString[80];
                IGRpoint        point;
                IGRvector       vec;
	} val;
};
typedef	struct	VD_s_dgnStInfo VD_dgnStInfo ;


/*
 * 	VD_K_dgnSt_*****	: The macro access constant for dgn variable.
 *	VD_S_dgnSt_*****	: Corresponding string name in collector.
 *	VD_F_dgnSt_*****	: Correspsonding Gadgets in form.
 */

/*
 *   total attributes in the form 
 */

#define		VD_K_dgnSt_MaxAttr		3

/*
 *   for symbology part
 */
#define		VD_K_dgnSt_symbDrFile		1
#define		VD_F_dgnSt_symbDrFile	        17	
#define		VD_S_dgnSt_symbDrFile		"symbDrFile"


#define		VD_K_dgnSt_symbDrStatus		2
#define		VD_F_dgnSt_symbDrStatus	        15	
#define		VD_S_dgnSt_symbDrStatus		"symbDrStatus"


/*
 *   for symbology part
 */
#define		VD_K_dgnSt_pidDrStatus		3
#define		VD_F_dgnSt_pidDrStatus	        13	
#define		VD_S_dgnSt_pidDrStatus		"pidDrStatus"


/*
 * Name of the collector
 */
#define		VD_DGNST_DIR_NAME		"VDDgnSetupInfo"


/*
 * Information for internal matching structure.
 */
struct	VD_s_dgnInfoInternal {
	char	*text ;		/* VD_S_dgnSt_****	*/
	int	index ;		/* VD_K_dgnSt_****	*/
	int	gadget ;	/* VD_F_dgnSt_****	*/
	int	type ;		/* Output type 	*/
};

typedef	struct	VD_s_dgnInfoInternal	VD_dgnInfoInternal ;

/*
 * Information for default setup structure.
 */
struct  VD_s_dgnInfoDefault {
        char    *ntext ;        /* VD_S_dgnSt_****      */
        int     index ;         /* VD_K_dgnSt_****      */
        char    *vtext ;        /* default value        */
};

typedef struct  VD_s_dgnInfoDefault    VD_dgnInfoDefault ;


#define  VD_UNDEFINED		-100
#define  VD_UNDEFINED_STR	"-100"

/* used for VD_dgnPushFile */ 
#define VD_K_DGN_CONFIG_RELPATH      "config/attribute"


#endif	/* vddgndef_macros */

