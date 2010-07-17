/* $Id: VSedgetobjdf.I,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsedge/VSedgetobjdf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSedgetobjdf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/26  18:22:50  pinnacle
# CR179700200
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/26/97        ah		CR179700200 Variable Bevel Parents
 ***************************************************************************/

class implementation VSedge3Datt ;

#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsedgeattr.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbInputs 	8
#define nbOutputs	6

	long		sts ;	/* OM return code		*/

	static char	*iNames [nbInputs] = {	SURF,
						EDGE_3D,
						ATT_BOX,
						"ref0",
						"ref1",
						"ref2",
						"ref3",
						"ref4"   } ;

	static int	iTypes  [nbInputs] = {	other_generic,
						other_generic   | line_generic
                                  		| curve_generic | conic_generic,
						macro_generic	| text_type,
						macro_generic,
						macro_generic,
						macro_generic,
						macro_generic,
						macro_generic  } ;

	static char	*oNames [nbOutputs]= {	EDGE_3D,
						SMALL_EDGE,
						ATT_BOX,
						ALLOW_IND,
						"var_base",
						"var_offset"   } ;

        myDef->info                     = VS_gI_EdgeAttr ;
        myDef->type                     = 0 ;
	myDef->minInput			= 3 ;
	myDef->input.count		= nbInputs ;
	myDef->input.names		= iNames ;
	myDef->input.type.types		= iTypes ;

	myDef->output.count		= nbOutputs ;
	myDef->output.names		= oNames ;
        myDef->output.type.classids     = NULL ;

        /*
         * Virtual outputs.
         */
        myDef->virtual.count            = 0;
        myDef->virtual.names            = NULL;
        myDef->virtual.type.types       = NULL; 

	/*
	 * IOs.
	 */
	myDef->i2o.count		= 0 ;
	myDef->i2o.type.types		= NULL ;
	myDef->i2o.names		= NULL ;

	/*
	 * When I consume my parent, I can have 2D only.
	 */
	myDef->parentRep		= AC_NO_REP;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSedge3Datt ;

