class implementation VLmrkLine;

//+*****************************************************************************
//
//	Implementation of object defining the mark of a Struct 
//		   stiffener or plate on a plate. The result is usually a
//		   curve defining the side of the marking object which touches
//		   the corresponding plate along with an offset (malconta) which
//		   indicates the width of the marking object.  The main curve
//		   may be trimmed across boundaries and the offset is usually a
//		   short curve of a 100 units, a third of the way along the
//		   length of the marking object.
//		   
//===========================================================================***

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "madef.h"
#include "ma.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vlstructure.h"
#include "vlmsg.h"

/********************************** DEBUG flags	***********************

#ifndef MARKERDEBUG

#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1

#endif

*********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vlmark.h"

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#define EPS 1e-5
#define MALCONTA 8

//   *********c	External Functions


//********************c  External Methods

from  GRcurve	import	GRendpts,
			GRmidpoint ;


// External variables

extern	GRclassid
			OPP_GR3dlinestr_class_id,
			OPP_GR3dlineseg_class_id;


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Function to place the first foot which as far as the user is concerned, does 
// not exist, it used for genLine compatibilty, especially for other objects 
// that need to know the complete extent of the main Mark

int	VLPlaceFullLine (
			 struct GRvg_construct	  * VgConst,
			 int			    NumLines ,
			 struct GRid		  * ListOfLines ,
			 struct GRid		  * TheFullLine 	) 
{

	struct IGRpolyline	FullLineGeom ;

	IGRpoint	* Points	= NULL ;

	IGRint	sts	=	OM_E_INVARG,
		pt	=	0 ,
		NumPts	=	NumLines*2 ,		// 2pts per line
		Line	=	0 ;

	IGRlong		msg  	= MSFAIL ;

 SetProc( VLFullLine ) ;   Begin

	if (	! VgConst ||
		! ListOfLines ||
		! TheFullLine )  goto wrapup ;

	Points = _MALLOC( NumPts , IGRpoint ) ;

	for ( Line = 0,pt=0 ; Line < NumLines ; ++Line,++pt ) {

		sts = om$send ( msg = message GRcurve.GRendpts ( &msg ,
					    &(VgConst->env_info->_MATRIX_TYPE) ,
						VgConst->env_info->_MATRIX ,
							Points[pt],
							Points[++pt] ),
				senderid = NULL_OBJID ,
				targetos = ListOfLines[Line].osnum ,
				targetid = ListOfLines[Line].objid ) ;
		__CheckRC( sts, msg , "Get endpts", wrapup ) ;

	}
	__DBGpr_int( "num pts is ", pt ) ;

	TheFullLine->osnum	=	VgConst->env_info->_MD_OS ;
        FullLineGeom.num_points	=       NumPts ;
        FullLineGeom.points	=       (IGRdouble*)Points;
        VgConst->geometry	= (char*)&FullLineGeom;

        sts = om$construct(     classid = OPP_GR3dlinestr_class_id,
        		       msg = message GRgraphics.GRaltconstruct(VgConst),
                                osnum   = TheFullLine->osnum,
                                p_objid = &TheFullLine->objid ) ;
        __CheckRC( sts,*VgConst->msg,"Mrk: FullLine GRaltconstruct",wrapup);

        __DBGpr_obj( "Placed full line", *TheFullLine );

	sts = OM_S_SUCCESS ;

wrapup:

        VgConst->geometry               = NULL ;
	_FREE( Points ) ;

	End
	return sts ;

} // place virtual line 

//----------------------------------------------------------------------------

end implementation VLmrkLine  ;

