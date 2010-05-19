/* $Id: vdmeasure.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/vdmeasure.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdmeasure.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/11/08  21:55:02  pinnacle
 * Created: include/vdmeasure.h by v241_int for vds.241
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date
 ***************************************************************************/


#ifndef	vdmeasure_include
#define	vdmeasure_include

#define	VD_MEAS_3D_MINDIST	0	/* Minimum distance		 */
#define	VD_MEAS_2D_MINDIST	1	/* Minimum distance in a plane	 */
#define	VD_MEAS_3D_SUPPORT	2	/* Distance along surface	 */
#define	VD_MEAS_2D_SUPPORT	3	/* Planar distance along surface */

#define	VD_MEAS_PLAN	0x0001
#define	VD_MEAS_SUPP	0x0002
#define	VD_MEAS_DIST	0x0010
#define	VD_MEAS_SPNT	0x0020
#define	VD_MEAS_EPNT	0x0040
#define	VD_MEAS_CURV	0x0080

#include	"codynmeas.h"

struct	VDdynInfo
{
	struct	disp_val_info	disp_info;
	struct	IGRbsp_curve	*bspcurve;
};

struct	VDmeasure
{
		IGRushort	prop;
	struct	GRobj_env	Iobj[4];
		IGRdouble	Ipnt[6];
	struct	GRid		Iwin[2];
		IGRdouble	Odst;
		IGRdouble	Opnt[6];
	struct	GRobj_env	Ocrv;
};

#endif	vdmeasure_include
