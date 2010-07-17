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
#include "EMSssprops.h"
#include "cotxmacros.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlplatejig.h"
#include "vlmark.h"
#include "vsmiscmacros.h"


//************************* internal definitions************************

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

	extern OMuword OPP_VLtplObj_class_id,
			OPP_VL2Dtempl_class_id ;

//c     NO External Functions ****

//c *************** External Methods ***********************

from	NDmacro		import	ACreturn_foot;
from	GR3dtext	import	GRgettxattr;


//c     Define the methods... *****



method ProcessJig (
	struct GRid *	jig ;	// incoming plate jig
	IGRint 		index 	// incoming index into list of located objs
		  )
{
  int		  status = OM_S_SUCCESS;		// method return code

  struct GRobj_env 	locObj;		//ptr to located obj, for environ info
  struct GRid		FootGrid;	// contour and line ie output from jig
  IGRlong               msg = MSFAIL;		// method argument return code
  IGRboolean		temp;			// temp var for tool variable
  IGRchar		pathName[DI_PATH_MAX],	// directory name of jig
			attribTemp,	//tmp var hold current attribute setting
			LogMessage[50] ;        // message to put in log file



   if (me->LogFileId)                           // log file enabled, set message
	     strcpy( LogMessage, "Problem converting the jig" ) ;

    pathName[0] = '\0';			// terminate character string
    locObj = me->Lst1[index];
    FootGrid = locObj.obj_id;
    status = ASmake_source_from_env( &locObj.obj_id,
                                        &me->ModuleInfo, &locObj.obj_id );
    CheckRC( status, 1 ) ;

    if ( (status&1 ) )
          locObj.mod_env = me->ModuleInfo;
    else
          locObj.obj_id  = FootGrid;

				// first find its name
    status = om$send( msg = message VLcoToAlCmd.ProcessName( "jig", jig ),
              targetid =   my_id );
    CheckRC( status, 1 );

				// then convert all graphic feet
    status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        NAM_P_CONT, /* see vlplatejig.h */
                                        &FootGrid,
                                        &(me->RefMatType),
                                        me->RefMatrix ),
		senderid = NULL_OBJID,
		targetid =   jig->objid,
		targetos =   jig->osnum ) ;

    __CopyLogMessage( status, msg, "could not find foot NAM_P_CONT " ) ;
    __CheckRC( status, msg, "pjig:ACreturn_foot", wrapup );

				// hard code attributes !!
    strcpy( me->material, "Mix" );
    strcpy( me->grade,    "Jg" );
    me->epaisseur = 100.0;	  // default to ten millimetres

					// map to the XY plane
    status = om$send( msg = message VLcoToAlCmd.RangeToxyPlane( &FootGrid ),
		 targetid   = my_id);

    __CheckRC( status, 1, "pjigs:RangeToxyPlane", wrapup );

    if ( me->autofile ) {
	sprintf( me->fileprefix, "%.4s_%dmm", me->grade,(int)me->epaisseur/10 );
    }

    status=om$send( msg = message VLcoToAlCmd.SaveFilename( &msg ),
                 targetid   = my_id );

    __CheckRC( status, msg, "pjigs:SaveFilename", wrapup );

					// output what we have
    status = om$send( msg = message VLcoToAlCmd.EcritDansFichierINI( me->name,
								  FootGrid ),
		targetid   = my_id);

    __CheckRC( status, 1, "ProcessJig:EcritDansFichierINI ", wrapup );

    status = om$send( msg = message NDmacro.ACreturn_foot(	&msg,
								NAM_P_LINE,
								&FootGrid,
							&(me->RefMatType),
							me->RefMatrix ),
                            senderid = NULL_OBJID,
                            targetid =   jig->objid,
                            targetos =   jig->osnum ) ;

    __CopyLogMessage( status, msg, "could not find foot NAM_P_LINE ") ;
    __CheckRC( status, msg, "pjigs:ACreturn_foot", wrapup );

			// override globals when converting marks
    temp = me->tooling;
    attribTemp = me->edgeAt.type[0];
    me->edgeAt.type[0] = 'M';
    me->tooling = 1;  // mark on jig

    status = om$send( msg = message VLcoToAlCmd.TranslateBSCurve(
						&FootGrid,
						(struct IGRbsp_curve *) NULL ),
		    targetid = my_id );

    CheckRC( status, 1 ) ;

    me->tooling = temp;		/* after override return these globals back to
					their original values */
    me->edgeAt.type[0] = attribTemp ; 

    status = OM_S_SUCCESS;	// even if mark failed

    if (me->LogFileId)
        strcpy( LogMessage, "jig converted" );

wrapup:

   if ( me->LogFileId )
	   fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );

   return ( status );

}	// end process template jig

/******************************************************************************
	Given a template manager, find and translate all the templates that
	it manages..
******************************************************************************/

method ProcessTemplMgr ( struct GRid * templateMgr ) // the template mgr
{
   struct GRobj_env	templObj ;	// the current template to convert

   IGRchar		footName[40],
			LogMessage[50] ;        // message to put in log file

   IGRlong		msg	= MSFAIL ;
   IGRint		status	= OM_E_INVARG ,
			ii	= 0;
   OMuword		spine_cl ;	// class of spine object

   if (me->LogFileId)                           // log file enabled, set message
	     strcpy( LogMessage, "Problem processing the template manager" ) ;

   if ( ! templateMgr ) goto wrapup ;

    templObj._objid = NULL_OBJID ;
    status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        NAM_TM_TSPI ,// see vltemplate.h
                                        &templObj.obj_id ,
                                        &templObj._matrix_type ,
                                        templObj._matrix ),
		senderid = NULL_OBJID,
		targetid =   templateMgr->objid,
		targetos =   templateMgr->osnum ) ;

    CheckRC( status, msg );
    __DBGpr_obj("spine id", templObj.obj_id );


    status =  om$get_classid(	osnum		= templObj._osnum,
				objid           = templObj._objid,
				p_classid       = &spine_cl      ) ;
    CheckRC( status, 1 );

    if( om$is_ancestry_valid(	superclassid = OPP_VLtplObj_class_id,
				subclassid =spine_cl ) == OM_S_SUCCESS ) {

	status = om$send(msg = message VLcoToAlCmd.ProcessTemplate( &templObj ),
				targetid = my_id );
	CheckRC( status, 1 );
    }

    for ( ii=0; ii<MACRO_TM_VFEET ; ++ii ) {

	templObj._objid = NULL_OBJID ;
	sprintf( footName, "%s%d", NAM_TM_VARF, ii+1 );
	status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        footName ,  /* see VLtemplate.h */
                                        &templObj.obj_id ,
                                        &templObj._matrix_type ,
                                        templObj._matrix ),
		senderid = NULL_OBJID,
		targetid = templateMgr->objid,
		targetos = templateMgr->osnum ) ;

	__DBGpr_str("looked for template's foot", footName );
	__DBGpr_obj("template's foot", templObj.obj_id );
	__CheckRC( status, msg, "ACreturn template", cleanup );

	if ( templObj._objid != NULL_OBJID ) {
		status = om$send( msg = message VLcoToAlCmd.ProcessTemplate( 
								    &templObj ),
				targetid = my_id );
		CheckRC( status, msg );
	}

    }  // for templates connected to the template manager

cleanup:
   if (me->LogFileId && ii>0)            // log file enabled, set message
	     strcpy( LogMessage, "Template manager processed" ) ;

wrapup:

   if ( me->LogFileId )
	   fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );

   return OM_S_SUCCESS;			// alway return good 

}	// end process templates connected to template manager


//*** ++++++++++++++ translate template geom to neutral file format  *****

method ProcessTemplate ( struct GRobj_env * template ) // the template
{
   IGRlong		msg	 = MSFAIL ;
   IGRint		ii	= 0 ,
			status	= OM_E_INVARG ;

   IGRboolean		temp = me->tooling;	//temp storage for the globals
   IGRshort		TextLength = 0 ;	// length of template's name
   IGRchar		attribTemp = me->edgeAt.type[0],
		*	footName[5] , 		// the feet to convert
			LogMessage[40] ;        // message to put in log file

   IGRuchar	*	TextString = NULL ;	// the template's name 
   struct IGRestx	TextAttr ;		// the text's attributes
   struct GRobj_env footObj ;			// the current foot to convert

   if (me->LogFileId)                           // log file enabled, set message
	     strcpy( LogMessage, "Problem processing the plate template " ) ;

   if ( ! template ) goto wrapup ;

    strcpy( me->material, "Mix" );
    strcpy( me->grade,    "Te" );
    me->epaisseur = 100.0;		// default to 10 millimetres
    footObj._objid = NULL_OBJID ;

					// get the template's name
    status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        NAM_TO_NAME , // see VLtemplate.h
                                        &footObj.obj_id ,
					&(me->RefMatType),
					me->RefMatrix ),
		senderid = NULL_OBJID,
		targetid = template->_objid,
		targetos = template->_osnum ) ;

    CheckRC( status, msg );

    __DBGpr_obj( "template name obj", footObj.obj_id );

    status = om$send( msg = message GR3dtext.GRgettxattr( &msg,
							  &TextAttr ,
							  &TextLength,
							  &TextString ),
		senderid = NULL_OBJID,
		targetid = footObj._objid,
		targetos = footObj._osnum ) ;

    CheckRC( status, msg );

    if ( !TextString ) {
	status = om$send( msg = message VLcoToAlCmd.ProcessName( "template",
							    &template->obj_id ),
			targetid =   my_id );
	CheckRC( status, 1 );
    }
    else {
				// remove GRtext escape sequences
	  status = co$rm_esc_seqs(	msg		= &msg,
					font_num	= TextAttr.font ,
					font_flags	= TextAttr.flag ,
					text_string	= TextString ,
					text_length	= &TextLength ) ;
	  __CheckRC( status, msg, "remove escapes", wrapup );

	TextString[TextLength] = 0 ;			// terminate string
	strcpy( me->name, TextString ) ;

    } 

    __DBGpr_str( "template name", me->name ) ;

    if ( me->autofile ) {
	sprintf( me->fileprefix, "%.4s_%dmm", me->grade,(int)me->epaisseur/10 );
    }

    status=om$send( msg = message VLcoToAlCmd.SaveFilename( &msg ),
                 targetid   = my_id );

    __CheckRC( status, msg, "ptemp:SaveFilename", wrapup );

    status = om$send( msg = message VLcoToAlCmd.EcritDansFichierINI( me->name,
							     template->obj_id ),
		targetid   = my_id);

    __CheckRC( status, 1, "process_temp:EcritDansFichierINI ", wrapup );

	footName[0] = NAM_TO_CONT;		// the contour ?  to cut
						// the rest are marks 
	footName[1] = NAM_TO_LINE ;		// the lp_line
	footName[2] = NAM_TO_LINE1 ;		// the first weld line ?
	footName[3] = NAM_TO_LINE2 ;		// the second weld line ?
	footName[4] = NAM_TO_AMARK ;		// the Mark    ?

   for ( ii=0 ; ii < 5; ++ ii ) {

	__DBGpr_str( "Processing template's foot:", footName[ii] ) ;
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

	status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert( 
								&footObj.obj_id,
								FALSE ),
				targetid = my_id );
	__CheckRC( status, 1, "PT:findThen..", wrapup );

next_foot:
	me->edgeAt.type[0] = 'M';
	me->tooling = 1;  // mark on jig


   }  // for the graphic feet of the template

    if (me->LogFileId)
		strcpy( LogMessage, "template converted\n\n" ) ;

wrapup:

	if ( me->LogFileId )
			fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );

	me->tooling = temp;	/* after override return these globals back to
					their original values */
	me->edgeAt.type[0] = attribTemp ; 

	if ( TextString ) om$dealloc( ptr = TextString ) ;
	return status ;

}	// end process template

end implementation VLcoToAlCmd;
