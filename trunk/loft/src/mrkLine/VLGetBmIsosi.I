
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
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "asmacros.h"
#include "emssfintdef.h"
#include "graph.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsglobalmsg.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsbmaxisdef.h"
#include "vssectiondef.h"
#include "vsstfnrdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsattr.h"
#include "vsbeam.h"
#include "EMSssprops.h"
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

//   *********c	External Functions	:	none


//   *****************c  External Methods


from  EMSsubbs	import
			EMisoparcvs;

from  VSfeature	import	VSforwardToSource ;

// External variables	:	none


//
//		fnct  VLGetBeamIsos
// 
//	Function to give the two furthest isometric curves of the surface of
//	a beam VS_K_nmFlgInfE, which is closest to the plate it is stiffening
//

VLGetBeamIsos(
		struct GRobj_env  *	stiffObj ,	//I: stiff to find isos
                struct GRmd_env   *	md_env,		//I: active mod env
 		struct GRvg_construct *	vg_cnst,        //I:isos constrn list
		int			IntsTypeSide,	//I:Which side of stiff
		struct GRid	  *	Isocs ,		//O: the list of isos
		IGRint		  *	NumIsocs  	//0: numb of iso curves
	     )

{
	struct GRobj_env	stiffFaceObj;	// the lower surf of stiff

	IGRchar			facename[40];   // name of stiff's lower face

	IGRlong			NumCurves = 0,  // num of iso curves
				msg	  = MSFAIL ,
				lsts	  = OM_E_ABORT ;

	IGRint			ii= 0,
				jj=0,
				First=0,
				Last=0,
				sts	=	OM_E_INVARG ,
				NumCurvOnOneSide = 0, // only isos of one side
				OffIndex = 0;	// index in isos of Offset  
			
	IGRdouble		uParams[2];     // params in U of iso curves


	GRobjid *		isos	= NULL;		// isometric curves

	IGRshort		action  = 0 ;	 // what to do to the properties

	unsigned short		PropMask = 0 ;	  // which properties to set for
						  // the virtual line


  SetProc ( VLGetBeamIsos ); Begin

  if ( !stiffObj 	|| 
          !md_env	|| 
 	!vg_cnst	|| 
	! Isocs  ) goto wrapup ;

		// 1st get the stiffener face in contact with the plate

	   strcpy( facename, "beam:body:" );
	   strcat( facename, VS_K_nmFlgInfE );
	   ii  = 10 + strlen( VS_K_nmFlgInfE );
	   facename[ii ] = 0;
	   __DBGpr_str( "looking for", facename );

		// send to original beam as don't want any cutouts

	 sts = om$send( msg = message VSfeature.VSforwardToSource (
						&lsts,
						OM_e_wrt_object,
	 					message NDmacro.ACreturn_foot(
							&msg	,
							facename,
							&stiffFaceObj.obj_id,
						     &stiffFaceObj._matrix_type,
						stiffFaceObj._matrix ) ),
			 senderid = NULL_OBJID,
		       	 targetid = stiffObj->_objid,
		       	 targetos = stiffObj->_osnum ) ;

	 __CheckRC( sts, msg, "Mark: surface of lower face", wrapup ) ;
	 __CheckRC( lsts, 1, "Mark: ACreturn message", wrapup ) ;
	   __DBGpr_obj( "stiff says face id", stiffFaceObj.obj_id );

	stiffFaceObj.mod_env = stiffObj->mod_env;

		// now get the isometric curves at u = 0 and 1 

	uParams[0] = 0.;	uParams[1] = 1.;

	sts = om$send( msg = message EMSsubbs.EMisoparcvs(
					&msg	,
					&stiffFaceObj._matrix_type,
					stiffFaceObj._matrix  ,
					 vg_cnst, 
					TRUE,
					2,
					uParams,
					TRUE,
					&NumCurves,
					&isos ),
			 senderid = NULL_OBJID,
		       	 targetid = stiffFaceObj._objid,
		       	 targetos = stiffFaceObj._osnum ) ;

	 __CheckRC( sts, msg, "Mark: extract iso curve", wrapup ) ;
	 __DBGpr_int( "EMisoparcvs returned curves ", NumCurves ) ;

	 NumCurvOnOneSide = (int) NumCurves/2;

	 __DBGpr_int( "num on One side ", NumCurvOnOneSide ) ;

	 if ( NumCurvOnOneSide >  VLMrkNumFeet ) 
					NumCurvOnOneSide =  VLMrkNumFeet ;

	// use first set of isos to define the mark,
	//			the first of the others for the offset

	if ( IntsTypeSide == VS_K_baOnTopOfPlate ){

		OffIndex = NumCurves-1 ;  // furthest curve
		First = 0;  Last = NumCurvOnOneSide ;
	}	
	else  {
		OffIndex = 0;				// nearest curve 
		First = NumCurvOnOneSide;  Last = NumCurves ;
	}


	 for ( ii = First, jj=0 ; ii < Last ; ++ii, ++jj ) {
	 	Isocs[jj].objid = isos[ii];   
	   	__DBGpr_obj( "stiff says face  iso", Isocs[jj] );
	}

			// use next iso for the offset object

	  Isocs[NumCurvOnOneSide].objid = isos[OffIndex];
	   __DBGpr_obj( "iso offset", Isocs[NumCurvOnOneSide] );

		// end closure for vector from full to offset mark

	if ( Isocs[NumCurvOnOneSide].objid != NULL_OBJID )
					*NumIsocs  = NumCurvOnOneSide+1;



wrapup:
			// remove unused isos

	for ( ii=OffIndex+1 ; ii<OffIndex+1+NumCurvOnOneSide-2 ; ++ii ) {

	    if (   isos [ii] != NULL_OBJID ) {
		int stat ;
		__DBGpr_int( "deleting iso", isos [ii] ) ;
		stat= om$send(msg  = message GRgraphics.GRdelete( &msg,
								md_env ),
				senderid = NULL_OBJID,
				targetid =   isos [ii] ,
				targetos =   md_env->md_id.osnum );
		CheckRC( stat, msg );
	    }
	}		// for unused isos

	_FREE( isos );			

	End

	return sts ;

}	// end VLGetBeamIsos


end implementation VLmrkLine  ;

