/*d-----------------------------------------------------------------------------


	Class Name:	VLplMarkCmd

	Abstract:	Formally Place Marking Line Command, now more
			appropriately "Mark Plate/Surface".

			Dec. '92 convert from JLL's PPL
			Straight convert of the PPL code no change in the
			command's structure, though all global variables were
			eliminated.

			March '93: Change locate flag to allow CurStiffs in
			reference files to be located, then add code to find
			the resulting object in the reference file.
			March '93: Added stiffeners to locate mechanism, so
			that the axis can be used to define the mark on a
			plate. ( No thanks to Eric l'infantile ).

			August '93:	Complete revision.  Now places
			the object VLmrkLine, which is associative and can
			take account of a stiffener's offset.

			Dec.   '94	Add the logic to process interupts from
					the Stop button, include information
					about the names of objects making and
					being marked.
					
------------------------------------------------------------------------------*/

command_string	VLC_M_MARKING_CURVE, 0, VLPlMaCu
synonym		VLC_M_MARKING_GEOM,  1, VLPlMaGm
command_table	"vl.cmd"
class		VLplMarkCmd
super_class	VLlocateCmd 
product_name	"$LOFT"

specification		/** Specification of object's structure ****/

instance {

/*c	Same as superclass + **/

        struct GRobj_env        PlateObj ;      /* Plate selected to Mark     */
        struct GRobj_env        SideObj ;       /* Side of 1st plate for Mark */
        struct GRobj_env        StiffObj ;      /* Stiff/Plate defining Mark  */
        struct GRobj_env        IntsObj ;       /* Side of 2nd plate / Stiffener
						   used to define Mark.   */
        int                 TypeSide ;		/* Line on bottom or top side */
                                                /* of plate.                  */
        int                 IntsTypeSide ;      /* Intersect with bottom side */
                                                /* or top side of 2nd plate.  */
	struct GRid		ptIds[2];	/* endpts of CurStiff on xSn  */
	IGRdouble		pts[6];		/* endpts of CurStiff on xSn  */

	IGRvector		ptVec;		/* vector between these pts   */
	IGRint			nbCrvs;
	struct GRobj_env CurveObj[50];       /* Selected Curve object */
}

implementation		/* Implementation details start here	****/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include "bserr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "coparamac.h"
#include "asmacros.h"
#include "vsglobalmsg.h"
#include "vsbmaxisdef.h"
#include "vssectiondef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsstfnrdef.h"
#include "vsbeam.h"
#include "vsattr.h"
#include "vsoptdef.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vluserkey.h"
#include "vlmark.h"

#define MY_ERROR        530
#define IMMEDIATE       0

#define		PlateDef	0
#define		StiffDef	1

/*********************************** DEBUG flags	***********************

#ifndef MARKERDEBUG

#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1

#endif

*********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vldbgmacros.h"

/*c	External Functions ****/

#include "bsnorvec.h"

extern	IGRboolean	IGEstop() ;

extern 			ASmake_source_from_env( struct GRid *,
						struct GRmd_env *,
						struct GRid *,
						int ),
			GRdisplay_object();

extern	void		EFdraw_vector_on_screen( OM_S_OBJID,
						 struct          IGRdisplay *,
						 struct          GRmd_env *,
						 enum            GRdpmode,
						 IGRboolean,
						 IGRpoint,
						 IGRvector,
						 GRrange,
						 IGRlong         * );


/*c  External Methods ****/

from  GRgraphics import	GRaltconstruct;
from  GR3dpoint import	GRdelete;
from  EMSsubbs	import	EMss4poles ;
from  NDmacro	import	ACreturn_foot,
			ACgive_structure;
from  GRvg	import  GRgetrang ;
from  VSstfBeam	import	VSgetPlateSide;
from  VSfeature import	VSforwardToOriginal,
			VSgetResultType ;

from  VLmrkLine	import	VLplace_mark;

/*c	Extern variables ***/

extern	GRclassid	OPP_GR3dpoint_class_id,
			OPP_VSplate_class_id,		/* plate obj classid**/
			OPP_VSbeam_class_id;	  /* stiffener+ obj classid **/


/*c	Define the state transitions... *****/

state_table

#include	"OMerrordef.h"
#include	"vlmsg.h"
#include	"vltemplate.h"
#include 	"VSmsg.h"
					// defines 
#define		VSplate_type	99
#define		VSstiff_type	101
#define		PlateDef	0
#define		StiffDef	1

state start
  on CMD_TYPE = 0     do
                        message_key	VL_S_MARKING_CURVE
			state 		GETPLATE
  on CMD_TYPE = 1     do
                        message		"Manual Marking Lines"
			state           GETPLATE

/*	locate any subclass of a structural plate or EMS surface **/
state GETPLATE
	prompt_key		VL_P_PLATE
	accept_key		VL_M_PLATE
        execute			VLplateActionHandlerOn 

	locate_eligible		"+VSplate,VSimgFeature"
	locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | 
				 LC_FLEX_COMP  | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	filter			locate

        on CLEAR_STACK				state terminate
                        
        on EX_RJT_MOVEON or EX_BACKUP   	state .

	on EX_OBJID or EX_DATA		do VLstoreLocate( &me->ret )
					do VLstoreResponse( &me->ret )
					do VLstoreList( &me->ret, 1, 1)
					do CheckType( &me->ret, 1 )
						on RETURN_CODE = VSstiff_type
				      		do status "Not a plate "
						state .
					on CMD_TYPE = 0	 state CHOOSETYPE
					state LOCREFOBJ

/*	locate any subclass of a structural stiffener or GRCurStiff **/

state CHOOSETYPE
	message			"Choose type of stiffener"
	prompt			"Accept for beams, reject for plates"

	filter			get_event

        on EX_BACK_UP   	state GETPLATE

        on EX_DATA		do VLbeamActionHandlerOn
				do prompt( "Identify beam(s)" )
				   state GETSTIFF 

        on EX_RJT_MOVEON	do  VLplateActionHandlerOn
				do prompt( "Identify plate(s)" )
				state GETSTIFF

state LOCREFOBJ
	message                 "Manual Marking Lines"
	prompt			"Identify Reference Object/Move on"
	accept                  "Accept Object(s)/Move on"
	execute                 VLstructActionHandlerOff
	locate_eligible		"+VDSroot"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_OWNER | LC_FLEX_COMP |
                                 LC_REF_OBJECTS"
        filter                  locate

        on EX_BACK_UP           state GETPLATE

        on EX_RJT_MOVEON        state LOCATEGEOM

        on EX_OBJID or EX_DATA  do VLstoreLocate( &me->ret )
                                do VLstoreResponse( &me->ret )
                                do VLstoreList( &me->ret, 1, 2)
                                do VLloadCst( &me->ret )
				state LOCATEGEOM


/************* event to locate stiffener to use for the mark ******************/

state GETSTIFF
	accept_key		VL_M_STIFFPLATE
	message_key		VL_S_MARKING_CURVE

	locate_eligible		"+VSplate,VSimgFeature,VSbeam"
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER | 
				 LC_FLEX_OWNER | LC_FLEX_COMP |
				 LC_REF_OBJECTS"
	filter			locate

	on EX_BACK_UP		state CHOOSETYPE

        on EX_RJT_MOVEON	state .

	on EX_OBJID or EX_DATA	do VLstoreLocate( &me->ret )
				do VLstoreResponse( &me->ret )
				do VLstoreList( &me->ret, 1, 2)
				do VLloadCst( &me->ret )
				do CheckType( &me->ret, 2 )

				   on RETURN_CODE = VSplate_type
				   	do	SwapSide( PlateDef )
					state GETFIRSTPLATESIDE

				   on RETURN_CODE = VSstiff_type
				      	do status "Processing stiffener"
					do BuildEndPoints( &me->ret )
				   	   on RETURN_CODE = MSFAIL
					      state .
				      	state CHOOSESIDE

				   on RETURN_CODE = OM_S_SUCCESS
					do message "Incomplete locate"
					state .

	on ELSE 		 do message "locate failed"	state .
				 state .
			
state GETFIRSTPLATESIDE
       
	execute			HighliteSide( PlateDef )

	message			"Check side"
	prompt_key		VS_P_AccSwapSide

	filter			get_event

        on EX_BACK_UP   	state GETPLATE
        on EX_DATA		do UnhighliteSide( PlateDef )
				do SwapSide( StiffDef ) 
				   state GETSECONDPLATESIDE 
        on EX_RJT_MOVEON    do  SwapSide( PlateDef ) state .

state GETSECONDPLATESIDE
       
	execute			HighliteSide( StiffDef )

	message_key		VL_S_MARKING_CURVE
	prompt_key		VS_P_AccSwapSide

	filter			get_event

        on EX_BACK_UP   	state GETPLATE
        on EX_DATA		do UnhighliteSide( StiffDef )
				   state PLACELINE
				   
        on EX_RJT_MOVEON    do  SwapSide( StiffDef ) state .

state CHOOSESIDE
       
	execute			HighLiteEndPoint

	message			"Check side of stiffener"
	prompt_key		VS_P_AccSwapSide

	filter			get_event

        on EX_BACK_UP   	state GETPLATE

        on EX_DATA		do UnHighliteEndPoint
				do StoreNoCurve(&me->ret)
				state PLACELINE

        on EX_RJT_MOVEON    do  SwapEndPoint	state .

state LOCATEGEOM
	message                 "Manual Marking Lines"
        prompt_key              VL_P_CHAR_LINE
        accept_key              VL_M_CHAR_LINE
	execute                 VLstructActionHandlerOff
	locate_eligible         "+GRcurve"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP           state LOCREFOBJ

        on EX_RJT_MOVEON        state .

        on EX_OBJID or EX_DATA          do StoreCurve( &me->ret ) 
					on MY_ERROR  state .
                                        state PLACELINE

state PLACELINE
	status 		"Marking plate(s)..."
	construct_class	"VLmrkLine"

        execute		 PlaceMark( &me->ret )

				on RETURN_CODE = OM_S_SUCCESS
					do	VLfreeList(&me->ret,2)
					on CMD_TYPE = 0
						state CHOOSETYPE

					state LOCREFOBJ

				on RETURN_CODE = MSFAIL
					do	VLfreeList(&me->ret,1)
					do	VLfreeList(&me->ret,2)
					state GETPLATE

				on ELSE do	status "ELSE!!"
					do	VLfreeList(&me->ret,1)
					do	VLfreeList(&me->ret,2)
					state GETPLATE


at delete do DeletePoints()
	  do status ""

/*c *********** That's all folks, END of STATE TABLE *******************/


action PlaceMark( IGRlong * ret )
{

 	IGRint 		i, CurPlate,		//current plate in locate list
			CurStiff,		//current stiffener "       "
			sts = OM_E_INVARG;	// status for message sends

 	IGRchar		err_txt[128];		// status buffer for errors

 	IGRlong		l_msg = MSFAIL;		// long return codes

	IGRboolean	stiff;

 struct GRsymbology	symbology;		// symbology for final Mark

 	IGRchar		PlateName[40],		// current name for plate
			StiffName[40],		// current name for stiffener
			MarkName [50] ,		// name of the mark placed
			tar_dir[DI_PATH_MAX];	// current dir  for Marks

 struct  GRvg_construct tcst;			//I construction list
						// current module's pointers
 struct GRobj_env	templates[12];		// graphic input for the Mark
 struct GRid		mark;


 enum    GRdpmode        dpmode=GRbd;	// mode for placed mark


 strcpy( err_txt, "Problem initialising the command" );

 if ( ret )	*ret =	MSFAIL;
 else		goto	wrapup;

 err_txt[38] = err_txt[39] = err_txt[127]  = 0 ;
 MarkName[0] = MarkName[30]= MarkName[49]  = 0 ;

			// these two ifs should never happen
 if ( ! me->Cnt1 ) {			// if there are no plates 
		strcpy( err_txt, "No plates found to mark" );
		goto wrapup;
 }

/*
 if ( ! me->Cnt2 ) {			// if there are no stiffeners
		strcpy( err_txt, "No plates/stiffeners found" );
		goto wrapup;
 }
*/

 symbology.display_attr.color           = me->ActiveDisplay.color;
 symbology.display_attr.weight          = me->ActiveDisplay.weight;
 symbology.display_attr.style           = 1;
 symbology.level                        = me->cst.level;

 if( !me->Cnt2 )
 {
        me->Lst2  = (struct GRobj_env *) om$malloc (
                                        size = sizeof(struct GRobj_env) );
        me->Lst2[0].mod_env = me->Current;
        me->Lst2[0].obj_id.osnum = me->Current.md_id.osnum;
        /* Create expression for Reference Object */
        status = exp$create ( exp_syntax = "ref_obj",
                              p_exp_id   = &me->Lst2[0].obj_id.objid,
                              osnum      = me->Current.md_id.osnum,
                              p_osnum    = &me->Lst2[0].obj_id.osnum,
                              type_rq    = EXP_TEXT );
        me->Cnt2 = 1;
 }
 // through list of plates, taking into account the stop button

 for ( CurPlate=0; (CurPlate<me->Cnt1) && (!IGEstop()); ++CurPlate ){ 

    __DBGpr_obj( "PlMrk Plate object id ", me->Lst1[CurPlate].obj_id );

    PlateName[0] = '\0';
    sts = VLGetShortName( &(me->Lst1[CurPlate]) ,
			  & me->Current ,
 			    PlateName ) ;
    CheckRC( sts, 1 ) ;
    PlateName[39] = '\0';		// safety valve

    if ( !PlateName[0] ) strcpy( PlateName, "no name" ) ;

	    //and through list of stiffeners,taking into account the stop button

    for ( CurStiff=0; (CurStiff<me->Cnt2)&&(!IGEstop()); ++CurStiff ){
				
		__DBGpr_obj("PlMrk Stiffener object id",me->Lst2[CurStiff].obj_id );

		stiff = FALSE;

	  	//if ( me->Lst2[CurStiff]._objid == NULL_OBJID ) continue;

		if ( me->Lst1[CurPlate]._objid == me->Lst2[CurStiff]._objid )
								continue;
  		if ( DMancestry_valid ( me->Lst2[CurStiff].obj_id, 
						OPP_VSbeam_class_id ) & 1 )
  		{	stiff = TRUE;	}

		StiffName[0] = '\0';
		sts = VLGetShortName( &(me->Lst2[CurStiff]) ,
				      & me->Current ,
					StiffName ) ;
		CheckRC( sts, 1 ) ;
		StiffName[39] = '\0';		// safety valve

		if ( !StiffName[0] ) strcpy( StiffName, "no name" ) ;

		tcst  = me->cst;

		templates[0] = me->Lst1[CurPlate];
		templates[1] = me->Lst2[CurStiff];
		for( i=0; i<me->nbCrvs; ++i )
		{
		   templates[2+i] = me->CurveObj[i]; 
		}

		mark.osnum = me->Current.md_id.osnum;

		if(stiff)
		sprintf( err_txt, "Stiffener %s failed on Plate %s",
					StiffName  , PlateName  );
		else
                sprintf( err_txt, "Plate %s failed on Plate %s",
                                        StiffName  , PlateName  );

 		*ret =	MSFAIL;

        	sts = om$construct(
				classname       = me->const_class,
				osnum           = mark.osnum,
				p_objid         = &mark.objid ,

				msg = message VLmrkLine.VLplace_mark( &l_msg ,
								me->TypeSide ,
							    me->IntsTypeSide ,
								2+me->nbCrvs ,
								templates    ,
								&me->Current ));

		__CheckRC( sts, l_msg, "Construct&VLplace_mark", next_stiff ) ;
		__DBGpr_obj( "PlMrk constructed mark ", mark );


		sprintf( MarkName , "%s / %s",
					StiffName  , PlateName  );

		status = om$send ( msg = message VLplMarkCmd.VLsymbNameDir (
                                                &l_msg ,
                                                MARK_KEY,
                                                &(templates[0].obj_id),
                                                 VLMarkName ,
                                                &symbology,
                                                tar_dir,
                                                MarkName,
                                                mark  ,
                                                &dpmode ),
                           targetid = my_id );
		CheckRC( status, l_msg );
		__DBGpr_str( "occurrence name ", MarkName );


		*ret	    =  OM_S_SUCCESS;

next_stiff:		// * jump to here if mark fails for current stiffener

	if ( (*ret)&1 ) {  // mark says it was placed
		if(stiff)
		sprintf( err_txt, "Plate %s marked with Stiffener %s",
					PlateName , StiffName  );
		else
                sprintf( err_txt, "Plate %s marked with Plate %s",
                                        PlateName , StiffName  );
	}

	status = om$send( msg = message VLplMarkCmd.status( err_txt ),
   			targetid = my_id );
	__CheckRC( status, 1, "status message", quit );


    } 			// end of for all located stiffeners
	

 } //c end for located surfaces/plates

 
wrapup:

	om$send( msg = message VLplMarkCmd.status( err_txt ),
   			targetid = my_id );
	
					// set these globals to their default
 	me->IntsTypeSide	= VS_K_baOnBotOfPlate ; 
 	me->TypeSide		= VS_K_stOnBotOfPlate ; 

	return  OM_S_SUCCESS;

} /*c end action place_mark **/

/***********************+++++++++++++++++++++++++++**************************/

action HighliteSide( int index ) {

        long    		msg  ;
	struct GRobj_env *	side ;
	IGRuchar		TempStyle = me->ActiveDisplay.style ;
	int			type;

	switch (index ) {

	default:

	case PlateDef :
		type = me->TypeSide;
		side = &me->SideObj;	break;

	case StiffDef :
		type = me->IntsTypeSide;
		side = &me->IntsObj;	break;

	} // case

			// offset surface, so dotted arrow
        if( type == VS_K_baOnTopOfPlate ) {
		om$send( msg = message VLplMarkCmd.status( "Offset" ),
   			targetid = my_id );
		me->ActiveDisplay.style	=	1 ;
	}
	else{
		om$send( msg = message VLplMarkCmd.status( "Base " ),
   			targetid = my_id );
		me->ActiveDisplay.style	=	0 ;
	}

        // Unhighlight old side and normal.

        dp$erase_hilite( msg = &msg ) ;


        // Hilight side selected.

        vs$bulk_display( count  = 1,
                         dpmode = GRhdo,
                         objenvs= side ) ;


        // Display normal.

        VSdisplaySurfaceNormal( &msg,
                                side,
                                TRUE,
                                &me->ActiveDisplay,
                                GRhd ) ;

	me->ActiveDisplay.style = TempStyle ;	// reset style before check rc
	__CheckRC( 1, msg, "side:display Normal", quit ); 

        return status;

}

/*----------------------------------------------------------------------------*/

action UnhighliteSide( int index ) {

        long    		msg  ;
	struct GRobj_env *	side ;

	switch (index) {

	default:

	case PlateDef :
		side = &me->SideObj;	break;

	case StiffDef :
		side = &me->IntsObj;	break;
	} // case

        status = vs$bulk_display(	count  = 1,
					dpmode = GRheo,
					objenvs= side  ) ;

        VSdisplaySurfaceNormal( &msg,
                                side,
                                TRUE,
                                &me->ActiveDisplay,
                                GRhe ) ;
	__CheckRC( 1, msg, "unhighl side display Normal", quit ); 

        return status ;

}

/*----------------------------------------------------------------------------*/

action SwapSide( int index ) {

        long                    msg;
        char                    *sidename ,
				StatusMessage[40] ; // For informing of problems
	int			*type;
	struct GRobj_env *	side ;
	struct GRobj_env *	plate;

	switch (index) {

	default:

	case PlateDef :
		type = &me->TypeSide;
		side = &me->SideObj;
		plate= &me->PlateObj;	break;

	case StiffDef :
		type = &me->IntsTypeSide;
		side = &me->IntsObj;
		plate= &me->StiffObj;	break;
	} // case

        // Get the opposite side.

        if( *type == VS_K_baOnTopOfPlate ) {
                *type		= VS_K_baOnBotOfPlate ;
                sidename        = VS_K_plBotSfPath ;
        } else  {
                *type		= VS_K_baOnTopOfPlate ;
                sidename        = VS_K_plTopSfPath ;
        }

        __DBGpr_str( "PlMrk Type of side wanted", sidename ) ;
	strcpy( StatusMessage, "Could not examine plate's geometry" );


        status = om$send( msg      = message NDmacro.ACreturn_foot(
                                                &msg,
                                                sidename,
                                                &side->obj_id,
                                                &side->_matrix_type,
                                                side->_matrix ),
                       targetid = plate->_objid,
                       targetos = plate->_osnum ) ;

        __CheckRC( status, msg, "NDmacro.ACreturn_foot", wrapup ) ;

        __DBGpr_obj( "PlMrk Side found", side->obj_id ) ;


        VSmulmx( side->_matrix, plate->_matrix,
                 side->_matrix, &side->_matrix_type ) ;

        side->mod_env.md_id = plate->mod_env.md_id ;

        __DBGpr_mat( "PlMrk Env of side", side->_matrix ) ;

	strcpy( StatusMessage, "" ) ;

wrapup :
        me->ret = ( status & msg & 1 ) ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

   	status = om$send( msg = message VLplMarkCmd.status( StatusMessage ),
   			  targetid = my_id );
	__CheckRC( status, 1, "status message", quit );


        return OM_S_SUCCESS ;

} /* method SwapSide */

action StoreNoCurve(long *sts)
{
  me->nbCrvs = 0; 
}

action StoreCurve( long *sts ) {
int			i, nb_obj=0;
struct GRobj_env        *LocatedObjects=NULL;

  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0 || nb_obj>50)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc,time=IMMEDIATE,seconds=IMMEDIATE);
    goto quit;
  }

  me->nbCrvs = nb_obj;
  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   = me->ModuleInfo.md_id.osnum ,
                    as_grid = &me->CurveObj[i].obj_id);
    me->CurveObj[i].mod_env = me->ModuleInfo;
  }

wrapup:
  _FREE( LocatedObjects );
  return OM_S_SUCCESS;
}

/*--------------------------------------------------------------------------*/

action CheckType( long * ret; int ListNum ) {

#define		VSplate_type 99 
#define		VSstiff_type 101

 OMuword		TEMP_cl ;		// temporary    obj classid
 long			msg	= MSFAIL;
 int			sts	= OM_E_INVARG,
			type	= OM_S_SUCCESS ;
 char			StatusMessage [40] ;	// For informing of problems

 struct GRobj_env *	ObjPtr	= NULL ;

 if ( ListNum == 1 ) {
	if ( ! me->Lst1 || ! me->Cnt1 )  goto wrapup ;
	ObjPtr = &me->Lst1[0] ;
	__DBGpr_obj( "1st check_type got plate id",  me->Lst1[0].obj_id );
  	me->StiffObj = me->Lst1[0] ;
 }
 else if ( ListNum == 2 ) {
	if ( ! me->Lst2 || ! me->Cnt2 )  goto wrapup ;
	ObjPtr = &me->Lst2[0] ;
	__DBGpr_obj( "2nd check_type got stiff id",  me->Lst2[0].obj_id );
  	me->StiffObj = me->Lst2[0] ;
 }
 else 	goto wrapup ;

  sts = as$make_source(	go_grid	= ObjPtr->obj_id		, 
			mod_env = &(ObjPtr->mod_env)	,
			as_os   = me->ModuleInfo.md_id.osnum	,
			as_grid = &(me->StiffObj.obj_id)	);

  __CheckRC( sts, 1, "PlMrk.check_type problem with make source", wrapup);

  status = VLGetObjAndClass(	&msg,
				&me->StiffObj ,
				&me->Current ,
				&TEMP_cl ) ;
  __CheckRC( status, msg, "PlMrk.CheckType problem with getclass ", wrapup );

                //c  retrieve the support surface of the plate

  if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
                            subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

	__DBGpr_com( "PlMrk obj = plate!!" );

	me->PlateObj = me->Lst1[0];       // Side of Plate for Mark
	me->SideObj  = me->Lst1[0];       // Side of Plate for Mark
	me->SideObj._objid = NULL_OBJID;
	me->IntsObj  = me->StiffObj ;      // Side of Plate defining Mark
	me->IntsObj._objid = NULL_OBJID;
	me->ret		= VSplate_type;
	type		= VSplate_type;

	me->TypeSide = VS_K_baOnTopOfPlate ;  //Swap will set these to bottom
 	me->IntsTypeSide	= VS_K_baOnTopOfPlate ; 

  }
  else if( om$is_ancestry_valid( superclassid  = OPP_VSbeam_class_id,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ){

	__DBGpr_obj( "PlMrk obj = stiffener!!",me->StiffObj.obj_id );

	me->ret			= VSstiff_type;
	type			= VSstiff_type;

		// so tell the mark to default to the base surf 

	me->TypeSide = VS_K_baOnBotOfPlate ;

  }
  else {
		__DBGpr_obj( "PlMrk Don't know obj", me->StiffObj.obj_id );
	strcpy( StatusMessage, "Could not examine object identified" );

	me->ret =	MSFAIL;
	type	=	MSFAIL;

 }

	strcpy( StatusMessage, "" ) ;

wrapup:
   	status = om$send( msg = message VLplMarkCmd.status( StatusMessage ),
   			  targetid = my_id );
	__CheckRC( status, 1, "status message", quit );

	return type;

} /* end check type */

/*--------------------------------------------------------------------------*/


action BuildEndPoints( long *ret )
{

struct GRobj_env	
			beamLocated ,
			stiffFaceObj;

struct  GRvg_construct  cnst;
struct  IGRpolyline     lstr_geom;

	IGRpoint	fourCorners[4];		// of surface

	IGRdouble *	nearest		= NULL,
		  *	furthest	= NULL;

	char		facename[40],
			StatusMessage [40] ;	// For informing of problems

	IGRlong		msg		= MSFAIL;

	IGRint		sts		= OM_E_INVARG;

	int		ii	= 0,
			xx	= 0;

	if ( ret )	*ret	= MSFAIL;
	else		goto wrapup;

	me->ptIds[0].objid = me->ptIds[1].objid = NULL_OBJID;

	strcpy( StatusMessage, "Could not examine stiffener's geometry" );
	sts = om$send( msg = message NDmacro.ACreturn_foot(
						&msg,
						"",
						&beamLocated.obj_id,
						&beamLocated._matrix_type,
						beamLocated._matrix ),
				senderid = NULL_OBJID,
				targetid = me->StiffObj._objid,
				targetos = me->StiffObj._osnum );

	__CheckRC( sts, msg, "BPts return foot on locate", wrapup ) ;
	__DBGpr_obj( "located beam", beamLocated._grid ) ;

        beamLocated.mod_env = me->StiffObj.mod_env;

		// should transform ? 

           strcpy( facename, "beam:body:" );
           strcat( facename, VS_K_nmFlgInfE );
           ii  = 10 + strlen( VS_K_nmFlgInfE );
           facename[ii ] = 0;
           __DBGpr_str( "looking for", facename );

           sts = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg    ,
                                        facename,
                                        &stiffFaceObj.obj_id,
                                        &stiffFaceObj._matrix_type,
                                        stiffFaceObj._matrix ),
                         senderid = NULL_OBJID,
                         targetid = beamLocated._objid,
                         targetos = beamLocated._osnum ) ;

           __CheckRC( sts, msg, "PlMark: surface of lower face", wrapup ) ;
           __DBGpr_obj( "stiff says face id", stiffFaceObj.obj_id );

           stiffFaceObj.mod_env = beamLocated.mod_env ;

           sts = om$send( msg = message EMSsubbs.EMss4poles (
                                        &msg    ,
                                        fourCorners,
                                        &stiffFaceObj.mod_env.md_env ),
                         senderid = NULL_OBJID,
                         targetid = stiffFaceObj._objid,
                         targetos = stiffFaceObj._osnum ) ;

           __CheckRC( sts, msg, "PlMark: get 4 corners ", wrapup ) ;
           __DBGpr_vec( "surface says 1st corner", fourCorners[3] );

	   nearest  = &fourCorners[3][0];		// u=0,v=0 
	   furthest = &fourCorners[2][0];		// u=1,v=0 

		for ( xx=0; xx<2; ++xx ) {

			cnst	= me->cst;
			cnst.display->color = 7-xx;
			cnst.display->weight = 4;
			me->ptIds[xx].objid	= NULL_OBJID;
			me->ptIds[xx].osnum	= me->Current.md_id.osnum;

			sts = om$construct( classid = OPP_GR3dpoint_class_id,
					    osnum   = me->ptIds[xx].osnum,
					    p_objid = &me->ptIds[xx].objid );

			__CheckRC( sts, 1, "omConstruct point", wrapup );

			lstr_geom.num_points    = 1;

			if (xx) lstr_geom.points     = furthest;
			else lstr_geom.points        = nearest;

			cnst.geometry   = (IGRchar *) &lstr_geom;

			sts = om$send( msg = message GRgraphics.GRaltconstruct
								      ( &cnst ),
                                senderid = NULL_OBJID,
                                targetid = me->ptIds[xx].objid,
                                targetos = me->ptIds[xx].osnum );
			CheckRC( sts, *cnst.msg ) ;

		}  /* for the 2 end points */

	if ( nearest && furthest ) {
		BSrc		bsrc		= BSFAIL;

		for ( ii=0; ii<3; ++ii ){
			me->pts[ii]	= nearest[ii];
			me->pts[ii+3]	= furthest[ii];
			me->ptVec[ii] = nearest[ii] - furthest[ii];
		}
		BSnorvec( &bsrc, me->ptVec );
		__CheckBSRC( bsrc , "PlMrk:BSnorvec", wrapup ) ;
	}

	*ret = OM_S_SUCCESS;
	sts  = OM_S_SUCCESS;
	strcpy( StatusMessage, "" ) ;

wrapup:
   	status = om$send( msg = message VLplMarkCmd.status( StatusMessage ),
   			  targetid = my_id );
	__CheckRC( status, 1, "status message", quit );

	return sts;

}  /**  BuildEndPoints **/

/*----------------------------------------------------------------------------*/

action HighLiteEndPoint {

        long    		msg  = FALSE ;
	struct GRobj_env 	point ;
	GRrange			range ; // range used to draw arrowhead
	IGRdouble *		ppnt = NULL;  // ptr to start pt of arrow

	IGRboolean		reverse = FALSE,  // reverse arrowhead
				worldRef= FALSE;  // world coords

	point.mod_env = me->ModuleInfo;

	switch (me->IntsTypeSide) {

	default:

	case VS_K_baOnBotOfPlate :	// nearest point
		point.obj_id = me->ptIds[0];
		ppnt = me->pts;
		reverse = FALSE;	break;

	case VS_K_baOnTopOfPlate :	// furthest point
		point.obj_id = me->ptIds[1];
		ppnt = &me->pts[3];
		reverse = TRUE;		break;

	} // case

	worldRef = FALSE ;
        status = om$send(  msg     = message GRvg.GRgetrang(
                                                        &msg,
                                                    &me->StiffObj._matrix_type,
                                                        me->StiffObj._matrix,
                                                        &worldRef,
                                                        range ),
                        targetid= me->StiffObj._objid,
                        targetos= me->StiffObj._osnum ) ;
        __CheckRC( status, msg, "GRvg.GRgetrang", wrapup ) ;

        
        // Unhilight old side and normal.
       
        dp$erase_hilite( msg = &msg ) ;


        // Hilight side selected.

        vs$bulk_display( count  = 1,
                         dpmode = GRhdo,
                         objenvs= &point ) ;

	__DBGpr_vec( "vector", me->ptVec );
	__DBGpr_vec( "st pt", ppnt );
	EFdraw_vector_on_screen(point._objid, &me->ActiveDisplay,&point.mod_env,
				GRhdo, reverse, ppnt, me->ptVec, range, &msg);
        __CheckRC( 1, msg, "EFdraw_vector", quit ) ;

	status = OM_S_SUCCESS;
wrapup:	
        return status ;

}

/*----------------------------------------------------------------------------*/

action SwapEndPoint {



        // Get the opposite side of stiffener beam.


        if( me->IntsTypeSide == VS_K_baOnTopOfPlate )
                me->IntsTypeSide= VS_K_baOnBotOfPlate ;
        else 
                me->IntsTypeSide= VS_K_baOnTopOfPlate ;

        __DBGpr_int( "PlMrk beam point wanted", me->IntsTypeSide ) ;
	__CheckRC( status , 1, "redundand COB status", quit ) ;

        return status;

} /* method SwapEnd  */

/*----------------------------------------------------------------------------*/

action UnHighliteEndPoint {

        long    		msg  ;
	struct GRobj_env 	point ;

	point.mod_env	= me->ModuleInfo;

	switch (me->IntsTypeSide) {

	default:

	case VS_K_baOnBotOfPlate :
		point.obj_id = me->ptIds[0];	break;

	case VS_K_baOnTopOfPlate :
		point.obj_id = me->ptIds[1];	break;

	} // case



        // Unhilight old end point

        dp$erase_hilite( msg = &msg ) ;


        // erase point selected.

        vs$bulk_display( count  = 1,
                         dpmode = GRheo,
                         objenvs= &point ) ;

	// points no longer required, so remove

   status = om$send( msg = message VLplMarkCmd.DeletePoints(),
   			  targetid = my_id );
   __CheckRC( status, 1, "delete points", quit );

        return OM_S_SUCCESS ;

} /* unhighlight endpoint */

/*----------------------------------------------------------------------------*/


action DeletePoints( ) {

 IGRlong	msg = MSFAIL;

    status = om$send(msg  = message GR3dpoint.GRdelete( &msg, &me->ModuleInfo ),
              targetid =   me->ptIds[0].objid,
              targetos =   me->ptIds[0].osnum  );
    CheckRC( status, msg );

    me->ptIds[0].objid = NULL_OBJID;

    status = om$send(msg  = message GR3dpoint.GRdelete( &msg, &me->ModuleInfo ),
              targetid =   me->ptIds[1].objid,
              targetos =   me->ptIds[1].osnum  );
    __CheckRC( status, msg, "delete of second point", quit );

    me->ptIds[1].objid = NULL_OBJID;

   return status;

} /* DeletePoints */

/*******++++++++++++++++++  END of COB definition file +++++++++***************/
