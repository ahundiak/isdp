/* $Id: vsoptdef.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/include/vsoptdef.h 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsoptdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/12/18  13:36:54  pinnacle
 * Replaced: include/vsoptdef.h for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  12:34:22  pinnacle
 * Replaced: include/vsoptdef.h for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
	Options for behaviors of I/STRUCT methods
*/

#ifndef vsoptdef_include
#	define vsoptdef_include

#define VS_m_All	0x7fffffff

#define VS_m_NdState	256


/*
Abstract
	The following masks define the attributes which one wants to put to
	or get from a part using the GRputattr or GRgetattr methods.
*/

#define	VS_m_MatGrade	0x0001
#define	VS_m_MatType	0x0002
#define VS_m_Notes	0x0004
#define VS_m_PartFam	0x0008
#define VS_m_PartNum	0x0010
#define VS_m_MtoSrc	0x0020
#define VS_m_MtoStk	0x0040
#define VS_m_UsrAttr	0x0080
#define VS_m_MbrClass	0x0100
#define VS_m_MbrType	0x0200
#define VS_m_AppStat	0x0400
#define VS_m_CstStat	0x0800
#define VS_m_FpThck	0x1000
#define VS_m_ChgNum	0x2000

/*
Abstract
	The following masks define the attributes which one wants to put to
	or get from a beam (in additions to the ones above) using the
	GRputattr or GRgetattr methods.
*/
#define VS_m_xOffset		0x010000
#define VS_m_yOffset		0x020000
#define VS_m_RotAngle		0x040000
#define VS_m_cardPnt		0x080000
#define VS_m_Symmetry		0x100000

/*
Abstract
	The following masks define the attributes which one wants to put to
	or get from a plate (in additions to the ones above) using the
	GRputattr or GRgetattr methods.
*/
#define VS_m_Thickness		0x010000
#define VS_m_CutOff		0x020000
#define VS_m_Offset		0x040000
#define VS_m_Orientation	0x080000

/*
Abstract
	The following masks define the attributes which one wants to put to
	or get from a joint (those above are not valid for joints) using the
	GRputattr or GRgetattr methods.
*/
#define VS_m_WeldAttr		0x010000
#define VS_m_Allowance		0x020000
#define VS_m_GrooveAngle	0x040000
#define VS_m_Pitch		0x080000
#define VS_m_IncrLength		0x100000
#define VS_m_UsrSymbol		0x200000
#define VS_m_Size               0x400000
#define VS_m_Shrinkage          0x800000
#define VS_m_AddWeldAttr	0x001000

/*
	The following mask checks for the use of of detail profile cardinal
	option
*/
#define VS_m_detCard	0x400000

#endif
