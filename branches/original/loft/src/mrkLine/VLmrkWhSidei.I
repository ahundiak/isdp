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
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "exmacros.h"
#include "vsmiscmacros.h"

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


extern int			VLseekFields ( struct ACrg_coll*, int, char* );
 

//********************c  External Methods

from	ACrg_collect	import	AClist_attribute,
				ACmod_list_attribute,
				ACadd_list_attribute;

// External variables


//+++++++++++++++++++++++++ see spec file ++++++++++++++++++++++++++++++++++++**

method WhichSide(	int * TypeSide ) { // say which side of plate
					   //	this mark is attached to

	IGRint	sts = OM_E_INVARG,
		suc = OM_E_INVARG,
		posn,			// position in collection
		num_att = 0;

	IGRlong msg = OM_E_INVARG;
 struct	GRid	boiteId;			// id of collection

 struct ACrg_coll	list_att[ VLMrkMinAtt]; // input from rg collection

  SetProc ( WhichSide ); Begin

  if ( ! TypeSide ) goto wrapup;


  sts = om$send( msg = message VLmrkLine.ACfind_temp_obj(	&suc,
							 VLMrkCollName,
							&boiteId
								),
                 targetid = my_id );
		
  __CheckRC( sts, suc, "Mark: ACfind_temp_obj", wrapup ) ;

  sts = om$send(msg = message ACrg_collect.AClist_attribute( &msg,
							      VLMrkMinAtt,
							     list_att,
							     &num_att ),
	    targetid = boiteId.objid,
	    targetos = boiteId.osnum);

  __CheckRC( sts, msg, "Mark: ACrg_collect.AClist_attribute", wrapup ) ;
  __DBGpr_int( "ACrg_collect gave attributes",  num_att );

  if ( (posn = VLseekFields( list_att, num_att,  VLTypeSide) ) != -1 ) 
	*TypeSide = (int)list_att[TypeSideIndex].desc.value.att_exp;
  else {  __DBGpr_str( "Couldn't find attribute ",  VLTypeSide); goto wrapup;}

wrapup:
  End 
  return ( sts );

} // WhichSide of plate

//----------------------------------------------------------------------------

end implementation VLmrkLine  ;

