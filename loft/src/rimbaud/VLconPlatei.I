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
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbmaxisdef.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlplatejig.h"
#include "vlmark.h"
#include "vlglobals.h"
#include "vsdrwapi.h"
#include "vsdrwmacros.h"
#include "vlstructure.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"



/************************** internal definitions************************/

#include "vlalma.h"
#define		FINDMARKS	0
#define		FINDPLATE	1
#define		FINDTEMPS	2

/************************** internal definitions************************/

/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/


#include "vldbgmacros.h"

//c     External Functions ****/
//c defined in include files */

//c *************** External Methods ***********************/

from  NDmacro           import  ACreturn_foot,
				ACgive_structure;
from  GRgraphics        import  GRdelete;
from  EMSloopset	import	EMget_loops;
from  EMSboundary	import	EMgetxyzobj ,
				EMget_edges;
from  EMSedge		import	EMget_bcxyz_geom ;

//c     Extern variables ***/

	extern GRclassid	OPP_ACpretend_class_id ;

//c     Define the methods... *****/



method ProcessPlate (
	struct GRid *	plate;	// Incoming plate
	IGRint 		index 	// incoming index into list of located objs
)
{

#include "EMSopt.h"                             // Ems option defines

  struct GRobj_env 	locObj,	     // ptr to the located obj, for environ info
			PlateObjEnv ;

  struct GRid		surfGrid,	//underlying surf used to get the data
			currentloop;   // current loop in loop set of surface

  IGRlong               msg = MSFAIL;           // return codes
  int			topmarks = 0,		// num of marks top of plate
			botmarks = 0,		// num of marks on its bottom
  			status = OM_E_INVARG ;

  char			LogMessage[50] ;	// message to put in log file

  struct mise_a_plat	FlatSurf;		//flat struct for orientation

  SetProc( ProcessPlate );	Begin

    if ( !plate ) goto wrapup;

   if (me->LogFileId)				// log file enabled, set message
	strcpy( LogMessage, "Problem converting the plate" ) ;

    msg   = VLinitDev(&FlatSurf);		//init flattened plate struct
    __CheckRC( 1, msg  , "VLinitDev", wrapup ) ;

    me->planar_plate = FALSE;
    locObj = me->Lst1[index];
    PlateObjEnv = me->Lst1[index];
    surfGrid = locObj.obj_id;
    status = ASmake_source_from_env( &locObj.obj_id,
                                        &me->ModuleInfo, &locObj.obj_id );

    __CheckRC( status, 1, "make_source", wrapup );
    locObj.mod_env = me->ModuleInfo;

                         // Get bottom side of plate.
    status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        VS_K_plBotSfPath,
                                        &surfGrid,
					&(me->RefMatType) ,
                                        me->RefMatrix ),
		senderid = NULL_OBJID,
		targetid = plate->objid,
		targetos = plate->osnum ) ;

    __CopyLogMessage( status, msg, "could not find plate's surface" ) ;
    __CheckRC( status, msg, "ACreturn_foot BotSf", wrapup );
    
    	// see if the surface is planar */

    me->planar_plate = vs$is_surface_planar(     msg    = &msg,
                                                surfId = &surfGrid,
                                                surfEnv= &locObj.mod_env );
    CheckRC( 1, msg );
    __DBGpr_int( "is plate planar", me->planar_plate ) ;
    locObj.obj_id = surfGrid ;
					// if flat and process flat plates

    if ( me->planar_plate == TRUE && (me->TransTypes&FlatPlates) ) { 

	VLsdlContext * CtxCast = &(((VLsdlContext*)(me->SdlContexts))[0]) ;

	// get thickness, material etc of plate

	 status = om$send( msg = message VLcoToAlCmd.GetPlateAttribs( plate,
							     index ),
		    targetid = my_id);

	 __CopyLogMessage( status, 1, "could not find plate's attributes" ) ;
         __CheckRC( status, 1, "plate att:GetPlateAttribs", wrapup );

	// find which side the most marks are attached to

	 status = om$send( msg = message VLcoToAlCmd.FindSuccessors( plate,
								FINDMARKS,
								&topmarks,
								&botmarks ),
		    targetid = my_id);

	 __CopyLogMessage( status, 1, "could not find plate's successors" ) ;
         __CheckRC( status, 1, "plate FindSuccessors", wrapup );
	 __DBGpr_int( "plate has this many top marks ", topmarks );
	 __DBGpr_int( "plate has this many bottom marks ", botmarks );

	 if ( topmarks > botmarks ) {
 		me->whichSide = VS_K_baOnTopOfPlate ;
    		status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        VS_K_plTopSfPath,
                                        &surfGrid,
					&(me->RefMatType) ,
                                        me->RefMatrix ),
			senderid = NULL_OBJID,
			targetid = plate->objid,
			targetos = plate->osnum ) ;

	 	__CopyLogMessage( status, msg, "could not find plate's top" ) ;
		__CheckRC( status, msg, "ACreturn_foot TopSf", wrapup );
    
	 }
	 else 
		__DBGpr_com( "Staying with bottom of plate" );

         status = om$send(msg = message VLcoToAlCmd.RangeToxyPlane( &surfGrid ),
		 	targetid   = my_id);

	 __CopyLogMessage( status, 1, "could not find plate's range" ) ;
	 __CheckRC( status, 1, "PP: rangetoxy ", wrapup );


	if ( me->master_fileid ) {

	   status = om$send(msg = message VLcoToAlCmd.writeToMaster( me->name ),
		 targetid   = my_id);

	   __CopyLogMessage( status, 1, "could not find masterfile" ) ;
	   __CheckRC( status, 1, "PP: writeToMaster", wrapup );
	}
	else {
		__DBGpr_com( " Process Plate NO MASTER FILE ID " );
	}

	if (me->init_fileid) {
		fprintf((FILE*)me->init_fileid,"%s\n",me->name);
	}
	__DBGpr_com( "BEFORE ecrit_fi in pp" );

	currentloop.objid = NULL_OBJID;

	if ( CtxCast->systTxt.out ) {		// if using strudel file

	   VSdrwOutputData *outPutInit = NULL ;

	   struct IGRplane	Plane ;
	   struct IGRlbsys	LBSys ;
	   IGRvector	Vector ;

	   status =  vs$drwExecConfig (      msg             = &msg ,
                                elmId           = plate ,
                                elmEnv          = &me->Lst1[index].mod_env ,
                                drwPlane        = &Plane ,
                                viewPlane       = &Plane ,
                                viewVector      = Vector,
                                drwEnv          = &me->Current ,
                                drwLbsys        = &LBSys ,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = "AlmaIni" ,
                                appData         = CtxCast ,
                                output          =  &outPutInit );
	   CheckRC( status , msg ) ;

	}		// if strudel active

	else {		// write to ini file myself

	   status = om$send( msg = message VLcoToAlCmd.EcritDansFichierINI(
								me->name,
								currentloop 
							    		    ),
		targetid   = my_id);
	   CheckRC( status, 1 ) ;
	}


    }		// if correct plate selected or not

    else {		// plates or templates should not have been selected

	if ( me->LogFileId ) {
		fprintf( (FILE*)me->LogFileId, "Plate not flat\n" );
	}

	status = OM_E_INVARG ;
			// this should never really be needed as locate should
			// not pass 3D plates

 	strcpy( me->status , "Incorrect plate/template selected" ) ;
 	__CopyLogMessage( status, 1, me->status  ) ;
	om$send( msg = message VLcoToAlCmd.status( me->status ),
			targetid   = my_id);

	goto wrapup ;		// GOTO wrapup and don't process

    }	// else wrong type of plate



   {		// code to expand the plate if required

	#define MAX_LINES 100
	double		XExpn = 0.0 ,		// don't expand the plate
			YExpn = 0.0 ;
	int		TypeOfExpn = 0 ;	// don't expand the plate
	IGRmatrix	ScaleMatrix ;
	struct	GRsymbology	symb ;

	IGRlong		l_sts = MSFAIL ;

	symb.display_attr= *(me->cst.display ) ;
	symb.level	 = (me->cst.level) ;

	msg = MSFAIL;

	/* to be compatible with the unwrap functions, the method that finds
	   the orientation and scales the plate, requires the mise_a_plat 
	   structure as an argument **/

	FlatSurf.surf_id.obj_id = surfGrid;
	FlatSurf.surf_id.mod_env= locObj.mod_env ;
	FlatSurf.res_id = FlatSurf.surf_id.obj_id;

	l_sts  = VLgetGeometry(&FlatSurf.surf_id, (IGRboolean) TRUE, NULL_OBJID,
                       (IGRchar ** )&FlatSurf.surface, &msg );

	__CopyLogMessage( l_sts, msg, "could not find plate's geometry" ) ;
	__CheckRC( l_sts, msg, "VLgetGeometry", wrapup ) ;

	if ( FlatSurf.surface ){

	IGRshort opt = 0;
	IGRdouble MeshTol = 0. ;

	FlatSurf.type = 4 ;

	msg = VLgetPtsNorms( &FlatSurf, opt, MeshTol );

	__CopyLogMessage( 1, msg, "could not find plate's normals" ) ;
	__CheckRC( 1, msg  , "VLgetPtsNorms", wrapup );

 	 msg = VLmaplatNDevel (&FlatSurf);
	__CheckRC( 1, msg  , "VLmaplatNDevel", wrapup );

	}
	else {
		__DBGpr_int( "no surface geom!!", FlatSurf.surface ) ;
		status = OM_E_INVARG ;
		goto wrapup ;
	}

		// get loft globals for values of any expansion in x & y of 
		// the plate and the type of expansion required (see unwrap)

	status = om$send(msg = message VLcoToAlCmd.VLgetGlobals
						    (&msg ,NAM_G_X_EXP,&XExpn ),
                                targetid = my_id);
	CheckRC( status, msg ) ;
	__DBGpr_dbl( "expansion in X", XExpn );

	status = om$send(msg = message VLcoToAlCmd.VLgetGlobals
						    (&msg ,NAM_G_Y_EXP,&YExpn ),
                                targetid = my_id);
	CheckRC( status, msg ) ;
	__DBGpr_dbl( "expansion in Y", YExpn );

	{  IGRdouble TmpEx = 0. ;
	  status = om$send(msg = message VLcoToAlCmd.VLgetGlobals
						    (&msg ,NAM_G_T_EXP,&TmpEx ),
                                targetid = my_id);
	  CheckRC( status, msg ) ;
	  __DBGpr_dbl( "expansion type ", TmpEx );
	  TypeOfExpn = TmpEx ;
        }

	status = om$send( msg = message VLcoToAlCmd.VLOrientScaleFlatPlate(
								&PlateObjEnv ,
								&FlatSurf,
								ScaleMatrix ,
								TypeOfExpn ,
								XExpn ,
								YExpn ,
								&me->Current ,
								&me->cst ),
		    	targetid = my_id);


	__CopyLogMessage( status, 1, "could not place orientation macro" ) ;
	__CheckRC( status, 1, "plate OrientScale ", wrapup );

    }	// end expand plate code

   status = OM_S_SUCCESS;

   if (me->LogFileId) {
	strcpy( LogMessage, "Plate and dependents converted" );
   }


wrapup:		///////////////////////////////////////////

   if ( me->LogFileId ) {
	fprintf( (FILE*)me->LogFileId, "%s\n\n", LogMessage );
   }

#ifndef vsDEBUG
//              CS used to map geometry to its xy plane was created in Orient
//		method and now need to be cleared up 

 if ( me->planar_plate )
{
	IGRint sts ; 
        sts = om$send( msg = message GRgraphics.GRdelete( &msg,
                                                                &me->Current ),
                                senderid = NULL_OBJID ,
                                targetid = me->Coord.objid,
                                targetos = me->Coord.osnum ) ;
        CheckRC( sts, msg ) ;
	me->Coord.objid = NULL_OBJID ;
}
#endif

	msg    = VLfreeDev ( &FlatSurf );
	CheckRC( 1, msg   ) ;

	End

	return status;

}	// end process plate

// *************************************************************************++

method GetPlateAttribs (
	struct GRid *	plate;	// incoming plate
	IGRint 		indx 	// incoming index into list of located objs
)
{
  int		  status = OM_S_SUCCESS;

     IGRlong		msg	= OM_E_INVARG;
     IGRint		index	= 0 ,
			suc	= OM_E_INVARG;
     IGRchar	*	unknown="unknown";
struct ret_struct       ret_struct;	// struct to hold returned attribute
     
     __DBGpr_obj( "into get plate attrib",*plate );

	status = om$send( msg    = message NDmacro.ACgive_structure(
                                        &suc,
                                        &index,
                                        VS_K_plThcknsAttr,
                                        &ret_struct,
                                        &me->Lst1[indx].mod_env),
                  senderid = NULL_OBJID,
                  targetid = plate->objid,
                  targetos = plate->osnum ) ;

	CheckRC( status, suc );
        if( !( status   & 1 & suc ) ){
                me->epaisseur = 1. ;	// will be read as .1 of mm by geoform
        }
        else
                me->epaisseur = ret_struct.var.root_pm_st.value * 10. ;


	status   = om$send( msg    = message NDmacro.ACgive_structure(
                                        &suc,
                                        &index,
                                        VS_K_prMatTypAttr,
                                        &ret_struct,
                                        &me->Lst1[indx].mod_env),
                  senderid = NULL_OBJID,
                  targetid = plate->objid,
                  targetos = plate->osnum ) ;

	CheckRC( status, suc );
        if( !( status   & 1 & suc ) ){
                strcpy( me->material, unknown );
        }
        else {  /* copy no of chars, as define by Alma **/
          strncpy(      me->material,
                        ret_struct.var.text_st.text_string,
                        (size_t)(MATL_SIZE-1) );
          me->material[MATL_SIZE-1] = '\0';
        }

	status   = om$send( msg    = message NDmacro.ACgive_structure(
                                        &suc,
                                        &index,
                                        VS_K_prMatGrdAttr,
                                        &ret_struct,
                                        &me->Lst1[indx].mod_env),
                  senderid = NULL_OBJID,
                  targetid = plate->objid,
                  targetos = plate->osnum ) ;

	CheckRC( status, suc );
        if( !( status   & 1 & suc ) ){
                strcpy( me->grade, unknown );
        }
        else {
          strncpy(      me->grade,
                        ret_struct.var.text_st.text_string,
                        (size_t)(GRADE_SIZE-1) );
          me->grade[GRADE_SIZE-1] = '\0';
        }

	status   = om$send( msg    = message NDmacro.ACgive_structure(
                                        &suc,
                                        &index,
                                        VS_K_prConstrAttr,
                                        &ret_struct,
                                        &me->Lst1[indx].mod_env),
                  senderid = NULL_OBJID,
                  targetid = plate->objid,
                  targetos = plate->osnum ) ;

	CheckRC( status, suc );
        if( !( status   & 1 & suc ) ){
		__DBGpr_com( " couldn't find status" );
		me->aStatus = ADD;
	}
	else {
		me->aStatus = ADD;
	   __DBGpr_str( "construc status", ret_struct.var.text_st.text_string );
	}

	if ( me->autofile ) {
         sprintf( me->fileprefix, "%.4s_%dmm", me->grade,(int)me->epaisseur/10);
	}

	status = om$send( msg = message VLcoToAlCmd.SaveFilename( &msg ),
                        targetid   = my_id);

	__CheckRC( status, msg, "getplateattrib: SaveFilename", wrapup );

	status = OM_S_SUCCESS;
wrapup:
	return status;

} // end get plate attributes

// *************************************************************************++

method FindPlate ( struct GRid * surf    /* incoming object surf,plate... */ )
{
  int		  status = OM_S_SUCCESS;

   struct GRid	GObj;		// GraphicObject returned
   OMuword	surf_cl;	// class of surface,plate or pretend
   IGRlong	l_msg  ;	// long return code for messages
 
   if ( !surf ) goto wrapup;

	status =  om$get_classid( osnum         = surf->osnum,
                        objid           = surf->objid,
                        p_classid       = &surf_cl      ) ;

	if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id ,
                                      subclassid =surf_cl ) == OM_S_SUCCESS) {

		__DBGpr_obj( "findp before return_foot", *surf );

		status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        "", 	// get the macro
                                        &GObj,
					&(me->RefMatType) ,
                                        me->RefMatrix ),
                       senderid = NULL_OBJID,
                       targetid = surf->objid,
                       targetos = surf->osnum );

		__CheckRC( status, l_msg, "FindPlate:ACreturn_foot", wrapup );
		__DBGpr_obj( "find_p return go is now ", GObj );

                *surf =  GObj;

	} /* if a pretend */

wrapup:
	return (status);

} // end find plate

// *************************************************************************++

method ProcessMarks (
  struct GRid * lmarks;		/* list of marks to find geometry */
	 int	number		/* number of marks in the list    */
	)
{
  int		  status = OM_S_SUCCESS;


 IGRlong	l_msg	= MSFAIL;		/* long return code/status    */
 IGRint		ind	= 0,
		foot	= 0;
 IGRchar *	feet_names[VLMrkNumFeet];
 struct GRid		FootGrid;		/* the macro's graphic foot */

  if ( ! lmarks ) goto wrapup;

  feet_names[0] = VLFirstMrkName	;/* see vlmark.h */
  feet_names[1] = VLSecondMrkName	;
  feet_names[2] = VLThirdMrkName	;
  feet_names[3] = VLFourthMrkName	;
  feet_names[4] = VLFifthMrkName	;
  feet_names[5] = VLSixthMrkName	;
  feet_names[6] = VLSeventhMrkName	;
  feet_names[7] = VLEighthMrkName	;
  feet_names[8] = VLNinethMrkName	;
  feet_names[9] = VLTenthMrkName	;
 
  for ( ind=0; ind<number  ; ++ind ) {

    for ( foot=0; foot< VLMrkNumFeet ; ++foot ) {
	status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        feet_names[foot], 
                                        &FootGrid,
					&(me->RefMatType) ,
                                        me->RefMatrix ),
		senderid = NULL_OBJID,
		targetid =   lmarks[ind].objid,
		targetos =   lmarks[ind].osnum );

		__CheckRC( status, l_msg, "pmarks: ACreturn_foot", next_mark );
		__DBGpr_obj( "pmarks:FootGrid", FootGrid );

	status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
								&FootGrid,
			     					FALSE ),
		 	targetid   = my_id);
	__CheckRC( status, 1, "pmarks: findType..", next_mark );

     }	/* for feet of mark macro */

next_mark:
		status = OM_S_SUCCESS;
	} /* for list of marks */

wrapup:
	if ( lmarks ) lmarks[0].objid = NULL_OBJID;

 return ( status );

} // end process marks

// *************************************************************************++

method ProcessSurf( struct GRid * surfGrid ;    //I: the surface to convert
  			GRobjid  * LoopIds ;    //I: ptr to list of loop ids
		     int	   NumLoops	/*I: no of loops to process */ )
	
{
  OM_S_OBJECT_LINKAGE   listLOOPSET;             // loopset of surface
  IGRlong               option,                  // EMSloop options
			msg = MSFAIL;           // return codes
  IGRushort             options;                  // EMSboundary options
  IGRint		status = OM_E_INVARG,
			i	= 0;
  GRobjid		objid;                   // objid of external loop
  struct GRid		currentloop;	// current loop in loop set of surface

  if ( !surfGrid || !LoopIds ) goto wrapup ;

    option  = EMS_OPT_ALL;
    options  = EMS_OPT_ALL;
    objid = NULL_OBJID;

    __DBGpr_int( "number of loops", NumLoops );

    for ( i=0; i<NumLoops; ++i ) {
	msg = MSFAIL;
	status  = om$send ( msg = message EMSboundary.EMgetxyzobj (
							&msg,
							options,
							&me->ModuleInfo.md_env,
							NULL,
							NULL,
							NULL,
							NULL,
							listLOOPSET.osnum, 
							&objid ),
               senderid = NULL_OBJID,
               targetid = LoopIds[i],
               targetos = surfGrid->osnum );    // was listLOOPSET.osnum

	if ( !( (msg)&status&1) ) {  // so just get geometry from each edge

		IGRint      tree_depth = OM_K_MAXINT;
		struct GRid *edges	= NULL;
		IGRint      array_size = 0;
		IGRint      num_edges  = 0;
		IGRint		ix = 0;
	 struct IGRbsp_curve curve;

	  if ( objid != NULL_OBJID ) {  /* delete xyz obj after use */

	      om$send( msg = message GRgraphics.GRdelete ( &msg, &me->Current ),
         	  senderid = NULL_OBJID,
		  targetid = objid,
               targetos = surfGrid->osnum ) ;	// was listLOOPSET.osnum
	  }
	  objid = NULL_OBJID;	// sometime value set, but message failed

	__DBGpr_com( "BEFORe get edges" );

	  status  = om$send ( msg = message EMSboundary.EMget_edges( &msg,
								  tree_depth,
								  option,
								  &edges,
								  &array_size,
								  &num_edges ),
              	 senderid = NULL_OBJID,
              	 targetid = LoopIds[i],
               targetos = surfGrid->osnum ) ; // was listLOOPSET.osnum


	   __CheckRC( status, msg, "EMSboundary.EMget_edges", next_loop );
	   __DBGpr_int( "after get edges",num_edges );

	  for ( ix=0; ix<num_edges; ++ix ) {

		__DBGpr_obj( "current edge ", edges[ix] );
		__DBGpr_int( "edge no", ix );

	        curve.poles = curve.knots = curve.weights = NULL;
		status  = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                                                &msg,
                                                &me->Loc_env.mod_env.md_env,
                                                surfGrid,
                                                 NULL,
                                                 0, OM_K_MAXINT,
                                                FALSE,
                                                 NULL,
                                                 &curve),
			   senderid = NULL_OBJID,
			   targetid = edges[ix].objid,
			   targetos = edges[ix].osnum  );

		__CheckRC( status, msg, "EMSedge.EMget_bcxyz_geom", next_edge );

		  currentloop.objid = NULL_OBJID;
      		  om$send( msg = message VLcoToAlCmd.TranslateBSCurve( NULL,
							           &curve
							         ),
		    targetid   = my_id);
next_edge:
		
		if ( curve.poles ) om$dealloc( ptr = curve.poles );
		if ( curve.knots ) om$dealloc( ptr = curve.knots );
		if ( curve.weights ) om$dealloc( ptr = curve.weights );

	   } // for edges

     } // if didn't get objid
     else {
		currentloop.objid = objid;
		currentloop.osnum = surfGrid->osnum ; // was listLOOPSET.osnum

		__DBGpr_obj( "USING loop",currentloop );

		status = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
							    &currentloop,
							    FALSE ),
			targetid = my_id );
		__CheckRC( status, 1, "PP:findThen..", next_loop );
     }

     if ( objid != NULL_OBJID ) {  // delete xyz obj after use

	om$send( msg = message GRgraphics.GRdelete ( &msg, &me->Current ),
                senderid = NULL_OBJID,
		targetid = objid,
               targetos = surfGrid->osnum /*listLOOPSET.osnum*/  ); 

        objid = NULL_OBJID;
     }

next_loop:
	__DBGpr_int( "\nNEXT LOOP",i );

  } // end for of all loops in loopset


wrapup:

	return status ;

} // end process surf

// *************************************************************************++

method GetSurfLoops( struct GRid * surfGrid 	/*I: the surface to convert*/ ;
  			GRobjid	**  LoopIds	/* ptr to list of loop ids */ ;
		     int	*   NumLoops    /* no of loops returned    */ )
{

  OM_S_CHANSELECT       chanloopset;            /* chan for surf'sloopset  */
  IGRuint               NumLoopsets;              /* no of connected loops   */
  OM_S_OBJECT_LINKAGE   listLOOPSET;             /* loopset of surface      */
  IGRlong               option,                  /* EMSloop options         */
			msg = MSFAIL;           /* return codes            */
  IGRint                depth,                   /* depth of tree to search */
  			status = OM_E_INVARG,
			buf_size;                /* size of buffer used     */
  IGRushort		*props;                  /* type of loop search     */

  if ( !surfGrid || !LoopIds || ! NumLoops ) goto wrapup ;


  /*c We look for the EMSloopset , first check if have one */

    chanloopset.type                = OM_e_num;
    status = om$get_channel_number ( channame  = "EMSsubbs.to_loopset",
                                p_channum = &chanloopset.u_sel.number );

    __CheckRC( status, 1, "Error get_channel_number loopset", wrapup );

  /*c retrieve the loopset id */

    listLOOPSET.S_objid = NULL_OBJID;

    status = om$get_channel_objects(	osnum           = surfGrid->osnum,
					objid           = surfGrid->objid,
					p_chanselect    = &chanloopset,
					size            = 1,
					count           = &NumLoopsets,
					list            = &listLOOPSET );

    __CheckRC( status, 1, "Error get_channel_objects loopset", wrapup );

    __DBGpr_int("NumLoopsets=",NumLoopsets);

  /*c retrieve the number of loops */

    option	= EMS_OPT_ALL;
    *LoopIds	= NULL;
    *NumLoops	= 0 ;
    props  	= NULL;
    depth  	= OM_K_MAXINT;
    buf_size	= 0;

    status = om$send ( msg = message EMSloopset.EMget_loops(  &msg,
                                                         option,
                                                         &depth,
                                                         LoopIds,
                                                         &props,
                                                         &buf_size,
                                                         NumLoops ),
           senderid = NULL_OBJID,
           targetid = listLOOPSET.S_objid,
           targetos = listLOOPSET.osnum );

    __CheckRC( status, msg, "EMSloopset.EMget_loops", wrapup );
    __DBGpr_int("NumLoops=", *NumLoops );

wrapup:

	return status ;

}   // end getsurfloops

// *************************************************************************++

VLGetSurfLoops( SurfGrid , ListLoopSets , NumLoopSets, LoopIdsPtr , NumLoopIds )

	struct GRid * SurfGrid	;	//I: the surface to find its loopsets
OM_S_OBJECT_LINKAGE * ListLoopSets ;	// O: link of loopsets on the surface
	IGRuint	*   NumLoopSets    ;	// O: no of loopsets returned 
  	GRobjid		**  LoopIdsPtr;	// O: ptr to list of loop ids
	IGRint		*  NumLoopIds;  // O: no of loops returned
{

  OM_S_CHANSELECT       chanloopset;            // chan for surf'sloopset

  IGRlong               option,                  // EMSloop options
			msg = MSFAIL;           // return codes
  IGRint                depth,                   // depth of tree to search
  			status = OM_E_INVARG,
			buf_size;                // size of buffer used
  IGRushort		*props;                  // type of loop search

  if ( !SurfGrid || !ListLoopSets || ! NumLoopSets ) goto wrapup ;


  /*c We look for the EMSloopset , first check if have one */

    chanloopset.type                = OM_e_num;
    status = om$get_channel_number ( channame  = "EMSsubbs.to_loopset",
                                p_channum = &chanloopset.u_sel.number );

    __CheckRC( status, 1, "Error get_channel_number loopset", wrapup );

  /*c retrieve the loopset id */

    ListLoopSets->S_objid = NULL_OBJID;
    *NumLoopSets = 0 ;

    status = om$get_channel_objects(	osnum           = SurfGrid->osnum,
					objid           = SurfGrid->objid,
					p_chanselect    = &chanloopset,
					size            = 1,
					count           = NumLoopSets,
					list            = ListLoopSets );

    __CheckRC( status, 1, "Error get_channel_objects loopset", wrapup );

    __DBGpr_int("NumLoopsets=", *NumLoopSets );

  //********* retrieve the number of loops

    option	= EMS_OPT_ALL;
    props  	= NULL;
    depth  	= OM_K_MAXINT;
    buf_size	= 0;

    status = om$send ( msg = message EMSloopset.EMget_loops(  &msg,
                                                         option,
                                                         &depth,
                                                         LoopIdsPtr,
                                                         &props,
                                                         &buf_size,
                                                         NumLoopIds ),
           senderid = NULL_OBJID,
           targetid = ListLoopSets->S_objid,
           targetos = ListLoopSets->osnum );

    __CheckRC( status, msg, "EMSloopset.EMget_loops", wrapup );
    __DBGpr_int("NumLoopsIds=", *NumLoopIds );


wrapup:

	if ( props ) om$dealloc( ptr = props ) ;

	return status ;

}   // end getsurfloops

// *************************************************************************++

end implementation VLcoToAlCmd;
