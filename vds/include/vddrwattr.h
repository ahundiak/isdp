/* $Id: vddrwattr.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include/vddrwattr.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrwattr.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1998/04/09  18:10:38  pinnacle
 * Replaced: include/vddrwattr.h for:  by yzhu for vds
 *
 * Revision 1.2  1998/01/02  16:44:32  pinnacle
 * Replaced: include/vddrwattr.h for:  by v250_int for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.7  1995/07/06  20:38:24  pinnacle
 * Replaced: include/vddrwattr.h for:  by azuurhou for vds.240
 *
 * Revision 1.6  1995/06/27  23:08:04  pinnacle
 * Replaced: include/vddrwattr.h for:  by azuurhou for vds.240
 *
 * Revision 1.5  1995/06/27  18:34:14  pinnacle
 * Replaced: include/vddrwattr.h for:  by azuurhou for vds.240
 *
 * Revision 1.4  1995/03/03  23:05:04  pinnacle
 * Replaced: include/vddrwattr.h by azuurhou r#
 *
 * Revision 1.3  1995/01/10  15:48:40  pinnacle
 * Replaced: include/vddrwattr.h by azuurhou r#
 *
 * Revision 1.1  1995/01/04  15:16:20  pinnacle
 * Created:  include/vddrwattr.h by rmanem r#
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/17/94	adz		creation
 *
 * -------------------------------------------------------------------*/

#ifndef vddrwattr_include
#define vddrwattr_include

#ifndef	godef_include
#	include "godef.h"
#endif

#ifndef	gr_include
#	include "gr.h"
#endif

#ifndef	igr_include
#	include "igr.h"
#endif

#ifndef	igrdp_include
#	include "igrdp.h"
#endif

#ifndef	go_include
#	include	"go.h"
#endif

#ifndef	growner_include
#	include	"growner.h"
#endif

/*
 ****************************************************************************
 *	Names of the macros
 */
#define	VDdrw_M_2d		"VDdrw2d"
#define	VDdrw_M_2dVw		"VDdrw2dVw"
#define	VDdrw_M_3d		"VDdrw3d"
#define	VDdrw_M_3dVw		"VDdrw3dVw"

/*
 ****************************************************************************
 *	Default visualization filename.
 */
#define VD_Ks_DEFAULT_NAME      "visual"
#define VD_Ks_DEFAULT_TRANS     "trans"

/*
 ****************************************************************************
 *	Clipping drawing Constants.
 */
#define	VDdrw_K_OUTSIDE         0
#define	VDdrw_K_INSIDE          1
#define	VDdrw_K_OVERLAP         2

/*
 ****************************************************************************
 *	Instance Information Types for VDdrw2dVw & VDdrw3dVw
 *	using the commands GRgetattr/GRputattr.
 */
#define	VD_I_drwInitialization	0
#define	VD_I_drwCompute		1
#define	VD_I_drwOffset		2
#define	VD_I_drwLevel		3
#define	VD_I_drwVisual		4
#define	VD_I_drwTrans		5
#define	VD_I_drwDetach		6

#define	VD_I_drwNoteName	10
#define	VD_I_drwNoteScale	11
#define	VD_I_drwNoteLocation	12
#define	VD_I_drwNoteDesciption	13
#define	VD_I_drwNoteReference	14
#define	VD_I_drwNoteOther1	15
#define	VD_I_drwNoteOther2	16

#define	VD_I_drwObjName		20
#define	VD_I_drwInternalName	21

#define	VD_I_drwProjPnt		30
#define	VD_I_drwProjVec		31
#define	VD_I_drwProjLbs		32
#define	VD_I_drwProjLevel	33

#define	VD_I_drwSelectMask	35
#define	VD_I_drwProjAllInfo	39

/*
 ****************************************************************************
 * Internal object names for the VDdrw2dVw & VDdrw3dVw object.
 */
#define	VD_S_drw2dVwName	"2dVw_"
#define	VD_S_drw3dVwName	"3dVw_"

/*
 ****************************************************************************
 * VDdrw2d/VDdrw3d getattr/putattr Types.
 */

/*
 * Object Interaction types.
 */
#define	VD_I_drwParentObj	1		/* Get the 2d/3d parent     */
#define	VD_I_drwGeometObj	2		/* VDdrwGm Object	    */
#define	VD_I_drwParentCtx	3		/* Parent Context object    */	
#define	VD_I_drwAttribObj	4		/* Get collector object     */

/*
 * Object Values types.
 */
#define	VD_I_drwMacroInfo	10		/* Object Macro Name        */
#define	VD_I_drwOccurInfo	11		/* Occurence Object Name    */
#define	VD_I_drwDesgnInfo	12		/* Parent Design File       */
#define	VD_I_drwAttrbInfo	13		/* Give objects attr        */
#define	VD_I_drwGrMacInfo	14		/* Graphical Macro object   */

#define	VD_I_drwAllObjInfo	19		/* Macro/Occ/Design Info    */

/*
 * Object State types.
 */
#define	VD_I_drwGetStsMask	20		/* Get bit mask of object   */
#define	VD_I_drwSetStsMask	21		/* Set bit mask of object   */
#define	VD_I_drwAddStsMask	22		/* operation mask |= mask   */
#define	VD_I_drwDelStsMask	23		/* operation mask &= mask   */
#define	VD_I_drwChkStsMask	24		/* Check of mask is valid   */

/*
 ****************************************************************************
 * Object Type to Process.
 */

#define	VD_O_drw2d		0x0001		/* 2d visualization group.  */
#define	VD_O_drw3d		0x0002		/* 3d visualization group.  */
#define	VD_O_drwVw		0x0004		/* View Groups		    */
#define	VD_O_drwObj		0x0008		/* Visualization object     */
#define	VD_O_drwPar		0x0010		/* Parent object	    */

#define	VD_O_drw2dVw		0x0005		/* Area View objects.       */
#define	VD_O_drw2dObj		0x0009		/* Visual objects of 2d     */
#define	VD_O_drw2dPar		0x0011		/* Parent objects of 2d vis */

#define	VD_O_drw3dVw		0x0006		/* Volume View objects.     */
#define	VD_O_drw3dObj		0x000A		/* Vol Area objects of 3d   */
#define	VD_O_drw3dPar		0x0012		/* Parent objects of 3d vis */
/*
 ****************************************************************************
 * The VDdrw2d/VDdrw3d mask-bits
 *
 *	Defaults Includes for 2d :	Object is in select set.
 *					Object has active parent object.
 *					Object has locatable graphics.
 *					Object is not based of implied mat.
 *					Object has associtive link with papa.
 */

#define	VD_B_drwDefaultMask		0x0001	
#define	VD_B_drwTransParent		0x0002
#define	VD_B_drwDetached		0x0004
#define	VD_B_drwNonLocatable		0x0008
#define	VD_B_drwImpliedMat		0x0010
#define	VD_B_drwNonAssociative		0x0020

/*
 *	Defaults Includes for 3d :	Object is processed against volume.
 *					Object has associative link with papa.
 */

#define	VD_B_drwCopy			0x0001
#define	VD_B_drwOverlapVolume		0x0002		

/*
 ****************************************************************************
 *  The VDdrw3d process mode to be used for ACconstruct_feet.
 */

#define	VD_P_drw_INTERACTIVE		0	/* unused cn_type mode = 0 */
#define	VD_P_drw_PREPROCESS		1	/* Copy/No process.	   */
#define	VD_P_drw_FEETPROCESS		2	/* Feet reprocess.	   */

/*
 ****************************************************************************
 * 
 */

/*
 ****************************************************************************
 * The data structure & constants.
 */
#define VD_K_FamilyLen		64      /* Part family                  */
#define VD_K_PrtNumLen		64      /* Part type inside family      */
#define VD_K_PrtRevLen		64      /* Part type inside family      */
#define VD_K_UsrNotLen		256     /* User notes about part        */


typedef char VDfamily[VD_K_FamilyLen] ;
typedef char VDprtNum[VD_K_PrtNumLen] ;
typedef char VDprtRev[VD_K_PrtRevLen] ;
typedef char VDusrNot[VD_K_UsrNotLen] ;

struct VD_s_partInfo {
        VDfamily        family ;        /* PDM/PDU family name          */
        VDprtNum        partNum ;       /* PDM/PDU part number          */
        VDprtRev        partRev ;       /* PDM/PDU part version         */
	VDusrNot	usrNot ;	/* User defined notes		*/
};

typedef struct VD_s_partInfo VDpartInfo ;

/*
	Attributes of a part as they may be obtaine with GRgetattr or
	set with GRputattr.

	If the attributes are obtained with GRgetattr, the needed memory for
	some of them may have been allocated in a cache buffer and must be
	returned to the system when no longer needed :

		VDpartAttr attr ;

		om$send( ... GRvg.GRgetattr( &msg, (char *) &attr ) ... ) ;

		...

	When this structure is filled to be input to GRputattr, this
	field is to be ignored.

	Not all attributes are wanted all the time, to avoid useless filling
	of the unwanted attributes which may be costly, the attributes wanted
	must be specified in the "Iwant" field. This being for GRgetattr or
	GRputattr.

	If one want to set or get all attributes, "attr.Iwant" may be set
	to "VD_m_DRAW_All".
*/

struct VD_s_partAttr {

	/*
	 * Attributes to be set or obtained (mask).
	 */
	unsigned long		Iwant ;

	/*
	 * Part information.
	 */
	VDpartInfo		info ;

	/*
	 * Id of the requested object.
	 */
	struct GRobj_env	obj;

	/*
	 * collector information of the object.
	 */
	IGRint			nbAttr ;
	struct ACrg_coll	*Attr ;
	IGRshort		*typAttr ;

	/*
	 * Attribute specific information.
	 */
	IGRshort		aType ;
	IGRdouble		aValue ;
	IGRint			aInt ;
	GRname			aString ;

	/*
	 * Pointer to part-specific attributes.
	 */
	void			*specific ;
};

typedef struct VD_s_partAttr VDpartAttr ;

/*
 ****************************************************************************
 *  Data structure to control the Context origin of the model objects.
 *  This is needed to estabish a set of object related to a drawing-view.
 */

#define	VD_I_drwIndexNotFound	-1 

struct	VD_s_drwMgrInfo {

	struct	GRid	VwId ;
	IGRchar		nameVw[40] ;
	IGRshort	mtxType ;
	IGRdouble	mtx[16] ;
} ;

typedef	struct	VD_s_drwMgrInfo	VDdrwMgrInfo ;

/*
 ****************************************************************************
 *  Data structure to get the information from the VDdrw2dVw object. 
 *  Instead of calling the object per item, get everything at ones.
 */

struct	VD_s_drw2dVwInfo {

	IGRchar		*intName ;
	IGRchar		*visFile ;
	IGRchar		*trsFile ;
	IGRdouble	*prjVec ;
	IGRdouble	*prjPnt ;
	IGRint		*objLev ;
	struct	IGRlbsys *drwLbsys ;
} ;

typedef	struct	VD_s_drw2dVwInfo	VDdrw2dVwInfo ;

struct	VD_s_drwObjInfo {

	IGRchar		*objMacro ;
	IGRchar		*objName ;
	IGRchar		*objDesign ;
};

typedef	struct	VD_s_drwObjInfo		VDdrwObjInfo ;

#endif	/* vddrwattr_include */
