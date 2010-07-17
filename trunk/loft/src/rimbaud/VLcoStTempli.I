class implementation VLcoToAlCmd;



#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "maerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlstifftpl.h"
#include "vsmiscmacros.h"


//c************************ internal definitions************************

#include "vlalma.h"


/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"


//c     External Variables ****


//c     NO External Functions ****

//c *************** External Methods ***********************

from	NDmacro		import	ACreturn_foot;

//c     Define the methods... *****




method ProcessStiffTemplate ( struct GRobj_env * template ) // the template
{
   IGRlong		msg	 = MSFAIL ;
   IGRint		ii	= 0 ,
			status	= OM_E_INVARG ;

   IGRboolean		TempTooling = me->tooling,//temp storage for the globals
			TempApprox  = me->circleapprox ;    // ditto

   IGRchar		attribTemp = me->edgeAt.type[0],
		*	footName[5] , 		// the feet to convert
			VarFootName[12] ,	// the name of variable foot
			LogMessage[50] ;        // message to put in log file


   struct GRobj_env footObj ;			// the current foot to convert

   if (me->LogFileId)                           // log file enabled, set message
	   strcpy( LogMessage, "Problem converting the stiffener template" ) ;

   if ( ! template ) goto wrapup ;

    strcpy( me->material, "Mix" );
    strcpy( me->grade,    "StTe" );
    me->epaisseur = 100.0;		// units are .1 of a mm
    footObj._objid = NULL_OBJID ;

    status = om$send( msg = message VLcoToAlCmd.ProcessName( "stiffTemp",
							    &template->obj_id ),
			targetid =   my_id );
    CheckRC( status, 1 );

    __DBGpr_str( "template name", me->name ) ;

    if ( me->autofile ) {
	sprintf( me->fileprefix, "%.4s_%dmm", me->grade,(int)me->epaisseur );
    }

    status=om$send( msg = message VLcoToAlCmd.SaveFilename( &msg ),
                 targetid   = my_id );

    __CheckRC( status, msg, "ptemp:SaveFilename", wrapup );

    status = om$send( msg = message VLcoToAlCmd.EcritDansFichierINI( me->name,
							     template->obj_id ),
		targetid   = my_id);

    __CheckRC( status, 1, "process_temp:EcritDansFichierINI ", wrapup );

	footName[0] = NAM_SF_CONT;		// the contour ?  to cut
						// the rest are marks 
	footName[1] = NAM_SF_SLIN ;		// the start line
	footName[2] = NAM_SF_ELIN ;		// the end   line ?
	footName[3] = NAM_SF_NMRK ;		// the directional letter ?
	footName[4] = NAM_SF_NLIN ;		// the directional arrow

	// go thru the list of constant feet

   for ( ii=0 ; ii < 5; ++ ii ) {

	__DBGpr_str( "looking for foot", footName[ii] ) ;

	status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        footName[ii] ,	// see vltemplate.h
                                        &footObj.obj_id ,
					&(me->RefMatType),
					me->RefMatrix ),
		senderid = NULL_OBJID,
		targetid = template->_objid,
		targetos = template->_osnum ) ;

	__CheckRC( status, msg, "return templates foot", next_foot );

	if ( ! ii ) {  // only need this for the contour
	   status = om$send( msg = message VLcoToAlCmd.RangeToxyPlane(
							      &footObj.obj_id ),
			  targetid   = my_id);

	   __CheckRC( status, 1, "PT: rangetoxy ", wrapup );
	}

	if ( ii == 3 )	me->circleapprox = 0;    //letter&arrow are linear
		

	status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert( 
								&footObj.obj_id,
								FALSE ),
				targetid = my_id );

	__CopyLogMessage( status, 1, "possible problem with orientation macro");
	__CheckRC( status, 1, "PT:findThen..", wrapup );

next_foot:
	me->edgeAt.type[0] = 'M';
	me->tooling = 1;  // mark on jig


   }  // for the constant graphic feet of the stiffener template


   me->circleapprox = TempApprox  ;    //set global back to original value 
   VarFootName[4] = VarFootName[5] = VarFootName[6] = 0 ; //safety valve

	// now through the list of variable feet

   for ( ii=0 ; ii < 100; ++ ii ) {
	sprintf( VarFootName, "mark%d", ii ) ;

	__DBGpr_str( "looking for foot", VarFootName ) ;

	status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        VarFootName ,
                                        &footObj.obj_id ,
					&(me->RefMatType),
					me->RefMatrix ),
		senderid = NULL_OBJID,
		targetid = template->_objid,
		targetos = template->_osnum ) ;

	__CheckRC( status, msg, "return templates foot", FinishedFeet );

	status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert( 
								&footObj.obj_id,
								FALSE ),
				targetid = my_id );

	__CopyLogMessage( status, 1, "possible problem with jig marks");
	__CheckRC( status, 1, "PT:findThen..", wrapup );


   }	// for list of variable feet

FinishedFeet:


    if (me->LogFileId) {
	if ( !ii)	fprintf( (FILE*)me->LogFileId, "No marks found\n" );
        strcpy( LogMessage, "stiffener template converted\n\n" ) ;
    }

wrapup:

	if ( me->LogFileId )
			fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );

	me->tooling = TempTooling;/* after override return these globals back to
					their original values */
	me->edgeAt.type[0] = attribTemp ; 
	me->circleapprox   = TempApprox ;    //set global back to original value 

	return status ;

}	// end process stiffener template

end implementation VLcoToAlCmd;
