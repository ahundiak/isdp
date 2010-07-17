/* $Id: vsbmsuppdef.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	include/vsbmsuppdef.h
 *
 * Description: 
 *
 * Dependencies: nmacro.h
 *
 * Revision History:
 *	$Log: vsbmsuppdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/20  20:26:32  pinnacle
 * CR179800676
 *
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 ***************************************************************************/

#ifndef vsbmsuppdef_include
#	define vsbmsuppdef_include

#ifndef _STANDARDS_H_
#       include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#       include "OMminimum.h"
#endif
#ifndef igetypedef_include
#       include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#       include "igrtypedef.h"
#endif
#ifndef gr_include
#       include "gr.h"
#endif
#ifndef growner_include
#       include "growner.h"
#endif

/*
 * Name of input graphics to generate a beam support.
 */
#	define VS_K_bsBmAxis		"BeamAxis"
#	define VS_K_bsTwAng		"TwistAngles"
#	define VS_K_bsPosition		"Position"
#	define VS_K_bsIntAngle		"Angle"
#	define VS_K_bsIntRefType	"RefType"

/*
 * Name of output graphic.
 */
#define VS_K_bsBmSupp            "BeamSupp"

struct VStws_info {
        struct GRobj_env	position ;
        double 			angle ;
        char			refType ;
};

/* CR179800676
 * I copied these from vsbmaxisdef.h and renamed them
 * Just to decouple these objects
 */
#define VS_K_bsOnBotOfPlate	0
#define VS_K_bsOnTopOfPlate	1
#define VS_K_bsExtendAxis      10

#endif /* vsbmsuppdef_include */





