/* $Id: vdmeamacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/vdmeamacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdmeamacros.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/11/08  21:55:14  pinnacle
 * Created: include/vdmeamacros.h by v241_int for vds.241
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date
 ***************************************************************************/

#ifndef	vdmeamacros_include
#define	vdmeamacros_include

#include	"vdmeasure.h"

extern	IGRlong
VDmeasureDistance	__((	long			*msg,
				struct	GRobj_env	*Obj1,
				struct	GRobj_env	*Obj2,
				struct	GRobj_env	*Obj3,
				struct	GRobj_env	*Obj4,
				double			*Pnt1,
				double			*Pnt2,
				double			*Dist,
				double			*Spnt,
				double			*Epnt	));

#omdef	vd$measure_distance (	msg,
				Object1,
				Point1,
				Object2,
				Point2,
				Plane		= NULL,
				Support		= NULL,
				Distance	= NULL,
				StartPnt	= NULL,
				EndPnt		= NULL	)

	VDmeasureDistance (	(msg),
				(Object1),
				(Object2),
				(Plane),
				(Support),
				(Point1),
				(Point2),
				(Distance),
				(StartPnt),
				(EndPnt)	);
#endomdef
#endif	vdmeamacros_include
