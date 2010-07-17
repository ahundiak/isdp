
class implementation VLcoToAlCmd;



#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "madef.h"
#include "msdef.h"
#include "exmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "graph.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vsmiscmacros.h"
#include "vlstructure.h"
#include "vlunfold.h"
#include "vljunction.h"
#include "vlmsg.h"


// ************************* internal definitions************************

#include "vlalma.h"


/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"

//c     External Functions
//c defined in include files

#include	"matypemx.h"
#include	"maidmx.h"

//c *************** External Methods ***********************

from  NDmacro           import  ACreturn_foot;
from  NDnode            import  ASreturn_go;
from  ACrg_collect	import	ACget_named_attribute ;

//c     Extern variables 

	extern	GRclassid	OPP_ACpretend_class_id ,
				OPP_ACrg_collect_class_id ;

//c  ***********   no global external func.. ***


method GetEdges (	struct	GRid	UnWrap_id;
			struct	GRid	**edge_ids;
			IGRint		*numObjects )
{
  int		  status = OM_E_INVARG ,
		  shift  = 0 ;

IGRlong		l_msg = OM_S_SUCCESS;
IGRint		i		= 0 ,
		CurrentByte	= 0 ,	// active byte in char array
		CurrentBit 	= UNFOLD_IDX_EDGE , // active bit in active byte
						    // start at first edge foot
		NumEdgAts 	= 0 ;	// number of edge attributes on an edge

IGRchar		FootName[20],		// name of graphic foot of unwrap
	  *	FeetNames[4] ,		// list of ptrs to names of ortn macro
		LogMessage[50] ;        // message to put in log file

IGRboolean	TempTooling	= me->tooling ,    // to override default value
		TempApprox 	= me->circleapprox ,	// ditto
		NotCut		= TRUE ;	   // to confirm edge is to mark

struct	GRid		MacroFoot ,	// object given by return foot to Macro
	     		GObj;		// "	"	"	"	"pretend

struct ACrg_coll	ParamColl ;	// Collection foot of unwrap macro


 SetProc ( GetEdges );	Begin

 if (me->LogFileId)   {                        // log file enabled, set message
	   strcpy( LogMessage, "Problem converting the flattened plate" ) ;
 }

 if ( !numObjects || !edge_ids || *edge_ids )	goto wrapup;

 
 FootName[17] = FootName[18] = FootName[19] = 0 ;
 *numObjects = 0;
 MacroFoot.objid	=	NULL_OBJID ;

 if ( UnWrap_id.objid == NULL_OBJID ) { status = OM_S_SUCCESS;	goto wrapup;}

  MacroFoot.objid = NULL_OBJID ;
  status   = om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        "Box",
                                        &MacroFoot ,
 					&(me->RefMatType),
 					me->RefMatrix ),
                senderid     = NULL_OBJID,
                targetid     = UnWrap_id.objid,
                targetos     = UnWrap_id.osnum);

  __CopyLogMessage( status, l_msg, "could not find foot Box" ) ;
  __CheckRC( status, l_msg, "could not find foot Box", wrapup  ) ;

  strcpy( ParamColl.name , N_ATT_TYPE ) ;


  status   = om$send( msg = message ACrg_collect.ACget_named_attribute(
								&l_msg,
								&ParamColl ),
                senderid     = NULL_OBJID,
                targetid     = MacroFoot.objid,
                targetos     = MacroFoot.osnum);

  __CopyLogMessage( status, l_msg, "could not find N_ATT_TYPE in collection" );
  __CheckRC( status, l_msg, "could not find attribute in collection", wrapup ) ;
  __DBGpr_obj( "collection", MacroFoot ) ;


 for ( i=0; i<200 ; ++i, ++CurrentBit ) {

	shift =   CurrentBit % 8 ;	// check if mod 8 or not */
	__DBGpr_int( "shift", shift ) ;

	if ( ! shift ) ++CurrentByte ;	// if mod 8  jump to next byte
	__DBGpr_int( "CurrentByte", CurrentByte) ;

//	printf( "current %o\n", ParamColl.desc.value.att_txt[CurrentByte]);
//	printf( "PC&Sh%d\n", ( ParamColl.desc.value.att_txt[CurrentByte] & 
//				(IGRchar)1 << shift ) ) ;
	__DBGpr_int( "NotCut", NotCut ) ;

	if ( ( ParamColl.desc.value.att_txt[CurrentByte] & 
				(IGRchar)1 << shift ) && NotCut ){

		__DBGpr_int( "edge is a mark", i ) ;
		me->tooling = 1 ;		// override global values
		me->edgeAt.type[0] = 'M' ;
		me->edgeAt.type[1] = 0 ;
		FootName[5] = FootName[6] = FootName[7] = 0 ;
		sprintf( FootName, "edge%d:%s",i,NAM_JU_GRA );
	}
	else {
		NotCut = FALSE ;
		me->tooling = 0 ;		// override global value
		FootName[5] = FootName[6] = FootName[7] = 0 ;
		sprintf( FootName, "edge%d",i);	 // true edges are cut
	}
 		__DBGpr_str( "foot name", FootName ) ;
		MacroFoot.objid = NULL_OBJID;
	status   = om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        FootName,
                                        &MacroFoot ,
 					&(me->RefMatType),
 					me->RefMatrix ),
                senderid     = NULL_OBJID,
                targetid     = UnWrap_id.objid,
                targetos     = UnWrap_id.osnum);

	if( !( status   & 1 & l_msg ) || MacroFoot.objid == NULL_OBJID ) {
	  CheckRC( status, l_msg );
	  *numObjects = i-1;
	  break;
	}
	else {
		//Assigning the foot id to Global value for use later in strudel
			me->edgeAt.macOcId      = UnWrap_id ;
        }

	 // used to have get real edge here 

		// if mark, just the geometry otherwise the attribs as well.

	status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
                                                                    &MacroFoot ,
                                                                    !NotCut ),
			targetid   = my_id);

	CheckRC( status, 1 );

	NumEdgAts = 0 ;		// reset for next pass in loop

  } //  end for graphic edges

  __DBGpr_obj( "MacroFoot", MacroFoot ) ;


  me->tooling = 1 ;		// override global values
  me->edgeAt.type[0] = 'M' ;
  me->edgeAt.type[1] = 0 ;
  MacroFoot.objid = NULL_OBJID ;

  TempApprox	   = me->circleapprox ;
  me->circleapprox = FALSE ;

  FeetNames[0] = "Orientation:arrow1" ;	FeetNames[1] = "Orientation:letter1" ;
  FeetNames[2] = "Orientation:arrow2" ;	FeetNames[3] = "Orientation:letter2" ;

  for ( i=0 ; i<4 ; ++ i ) {

	GObj.objid = NULL_OBJID ;
	status   = om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        FeetNames[i] ,
                                        &GObj ,
 					&(me->RefMatType),
 					me->RefMatrix ),
                senderid     = NULL_OBJID,
                targetid     = UnWrap_id.objid,
                targetos     = UnWrap_id.osnum);

	CheckRC( status, l_msg );

	if ( GObj.objid != NULL_OBJID ) {
		// transfer the graphic part to rimbaud file

		if ( me->RefMatType != MAIDMX ) {
		__DBGpr_mat( "foot matrix", me->RefMatrix ) ;
		}

        	status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
                                                                &GObj ,
                                                                FALSE ),
				targetid   = my_id);

        	CheckRC( status, 1 );

	}
	else  break ;	// as no more feet of this name

  } // for orientation feet

  MacroFoot.objid = NULL_OBJID ;
  GObj.objid = NULL_OBJID ;

  status   = om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        "Type:letter",
                                        &GObj,
 					&(me->RefMatType),
 					me->RefMatrix ),
                senderid     = NULL_OBJID,
                targetid     = UnWrap_id.objid,
                targetos     = UnWrap_id.osnum);

  __CopyLogMessage( status, l_msg, "could not find orientation foot letter" );
  __CheckRC( status, l_msg, "could not find foot Type:letter", wrapup  ) ;


  if ( me->RefMatType != MAIDMX ) 
  __DBGpr_mat( "letter matrix", me->RefMatrix ) ;

		// transfer the graphic part to rimbaud file
  status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
                                                                &GObj ,
                                                                FALSE ),
			targetid   = my_id);
  __CopyLogMessage( status, l_msg, "could not convert foot letter" );
  __CheckRC( status, 1, "convert letter of Type", wrapup  ) ;

  if ( me->RefMatType != MAIDMX ) {
			MAidmx( &l_msg, me->RefMatrix ) ;
			me->RefMatType = MAIDMX  ;
  }

		// all's well that ends well...
   if (me->LogFileId) {
	   strcpy( LogMessage, "Flattened plate converted" );
   }

   status = OM_S_SUCCESS;

wrapup:

	if ( me->LogFileId ) {
			fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );
	}
	me->circleapprox =  TempApprox ;
	me->tooling = TempTooling ;

	End
	return (status);

} // end GetEdges

end implementation VLcoToAlCmd;
