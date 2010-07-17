/*d-----------------------------------------------------------------------------


        Class Name:     VLplRollCmd

        Abstract:       Place Roll Line Command

                        Feb. '93 PW convert from JLL's PPL
				 General structure of ppl command left intact.
				 Just remove redundant variables and comments 
				 added.

			Sep. '93 Change command object to place new roll line
				 object.  This involved moving most of the 
				 calculations out to the object, leaving the
				 command to only recover the user input.
				 Add prototyping wherever possible.
------------------------------------------------------------------------------*/

command_string  VLC_M_ROLL_LINE, 0, VLPlRoLi
command_table   "vl.cmd"
class           VLplRollCmd
super_class     VLplCntrCmd
product_name    "$LOFT"

start_state     start

specification

instance {
		/* need to restructure command object to remove globals
			left from ppl legacy */
IGRboolean	  direction;	/* current direction for roll line v=1,u=0*/
struct GRid 	  tmpId[2];	/* temporary lines to show direction */
struct GRobj_env  surfObj;	/** current surface to process **/
IGRdouble         ShipAxis[3];  
IGRint            NumbLines ;
IGRint            swap ;
IGRint		  ProcessType;
IGRint            nbCrvs;
struct GRobj_env  CurveObj[10];       /* Selected Curve object */
}


/***+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++***********/

implementation

#include  <stdio.h>
#include  <math.h>
#include "vlprototype.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "coparamac.h"
#include "asmacros.h"
#include "growner.h"
#include "graph.h"
#include "ndmacros.h"

#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vsmiscmacros.h"

#include "vlmsg.h"
#include "vlrolline.h"
#include "vluserkey.h"

#define MANUAL_ROLL     100
#define IMMEDIATE       0

/*+++++++++++++++++++++++++DEBUG FLAGS		*+++++++++++++++++++++++++++++*

#ifndef ROLLDEBUG

	#define	ROLLDEBUG
	#define vsDEBUG
	#define vserrDEBUG

#endif

*+++++++++++++++++++++++++ END DEBUG FLAGS	*+++++++++++++++++++++++++++++*/

#include "vldbgmacros.h"


/*+++++++++++++++++++++	external functions 	+++++++++++++++*/

#include "bssfevaln.h"
#include "bssfarrevmc.h"


extern 			ASmake_source_from_env( struct GRid *,
						struct GRmd_env *,
						struct GRid *,
						int	);

from	NDmacro		import	ACreturn_foot;
from	EMSsubbs	import	EMisoparcvs,
				GRgenabsg;
from	GRgraphics	import	GRptproject;
from	GRcurve		import	GRdelete;
from	VLrolLine	import	VLplaceRollLine;

/*++++++++++++++++++++++++     Extern variables ++++++++++++++++++++++++++*/

extern  GRclassid
		OPP_VSplate_class_id ,
		OPP_VSfeature_class_id ,
		OPP_VSimgFeature_class_id,
		OPP_ACpretend_class_id ;



/*++++++++++++++++     Define the state transitions... +++++++++++++++++++*/

state_table

#include	"OMerrordef.h"
#include        "vlmsg.h"
#include        "vltemplate.h"

#define MANUAL_ROLL     100

/*++++++ 1st state: get direction (x/y/z) of ship's axis +++++++++++++++++++*/

state start
        message_key             VL_S_ROLL_LINE
        prompt_key              VL_P_SHIP_AXIS
        filter                  get_event

        on EX_STRING    do VLstoreLocate( &me->ret )
                              do VLsetAxis( &me->ret )
                                 on RETURN_CODE = VL_S_SUCCESS
                                 do status_key VL_S_BLANK_STATUS state NumLines
                                 on RETURN_CODE = MSFAIL
                                 do status_key VL_E_BADAXIS state .
                        state .
	on EX_RJT_MOVEON	do VLsetAxis( &me->ret ) state NumLines

/*++++++ 2nd state: get number of roll lines required +++++++++++++++++++*/

state NumLines
        message_key             VL_S_ROLL_LINE
        status                  "Reset to take the default"
        prompt                  "Enter number of roll lines for each plate[1]"
        filter                  get_event

        on EX_STRING    do VLstoreLocate( &me->ret )
                              do VLsetNumb( &me->ret )
                                 on RETURN_CODE = VL_S_SUCCESS
				 state GETPROCESSTYPE
                                 on RETURN_CODE = MSFAIL
                                 do status "Please re-type the number" state .
                        state .
	on EX_RJT_MOVEON	state GETPROCESSTYPE

state GETPROCESSTYPE
	message_key             VL_S_ROLL_LINE
	status                  "0 - Manual,  1 - Algorithm 1, 2 - Algorithm 2"
	prompt                  "Enter Process Type ( 0/1/2 )/Move on(1)"
	filter                  get_event
	 on EX_STRING    	do VLstoreLocate( &me->ret )
				do VLsetProcessType( &me->ret )
				on RETURN_CODE = MANUAL_ROLL
				 do status_key VL_S_BLANK_STATUS 
				 state LOCATEGEOM
				on RETURN_CODE = VL_S_SUCCESS
                                 do status_key VL_S_BLANK_STATUS state GETPLATE
				on RETURN_CODE = MSFAIL
                                 do status "Please re-type the number" state .
				state .
        on EX_RJT_MOVEON        do status_key VL_S_BLANK_STATUS state GETPLATE

state LOCATEGEOM
        message                 "Manual Roll Lines"
        prompt_key              VL_P_CHAR_LINE
        accept_key              VL_M_CHAR_LINE
        execute                 VLstructActionHandlerOff
        locate_eligible         "+GRcurve"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP           state GETPROCESSTYPE

        on EX_RJT_MOVEON        state .

        on EX_OBJID or EX_DATA          do StoreCurve( &me->ret )
                                        on MY_ERROR  state .
					state GETPLATE

/*+++++++++ 3rd state: locate surface or plate for rolling    +++++++++++++*/

state GETPLATE
        prompt_key              VL_P_PLATE
        accept_key              VL_M_PLATE
        locate_eligible         "+VSplate,VSimgFeature"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        filter                  locate

        on EX_BACK_UP           do InitInstance()
				state start
				

        on EX_OBJID or EX_DATA  do VLstoreLocate( &me->ret )
                                do VLstoreResponse( &me->ret )
                                do VLstoreList( &me->ret, 1, 1)
                                do VLloadCst( &me->ret )
                                do VLcalcDirection( &me->ret, 0 )

                                	on RETURN_CODE = OM_S_SUCCESS
					state GETDIRECTION

					on RETURN_CODE = MSFAIL
                                        do       VLfreeList(&me->ret,1)
                                                 state GETPLATE

                                   state GETDIRECTION

/*+++++++++ 3rd state: given a surface find if they want the u or v direction+*/

state GETDIRECTION
        prompt_key              VL_P_DIRECTION
        filter                  get_event
	construct_class		"VLrolLine"

        on EX_RJT_MOVEON	do VLswapDirection()
				do VLremoveIsos()
				do VLplaceRest()
				do VLfreeList( &me->ret, 1)
				state GETPLATE

	on EX_DATA	do VLremoveIsos()
			do VLplaceRest() 
			state GETPLATE

at init		do	InitInstance()
at delete	do	VLremoveIsos()
		do	status ""

/*+++++++++++++ That's all folks; end of state table  ++++++++++++++++++++++++*/

/*++++++ Method calc_direction: given an object find out if it's a plate or
	surface. With plates find the underlying surface.  When the surface has
	been found, calculate the current direction (u or v) for the line and
	show this to the user.
++++++++++++++++++++++++++++++++++++*/

action InitInstance( )
{

	status = OM_S_SUCCESS ;
	me->ShipAxis[0] = 1.0;
	me->NumbLines = 1 ;
	me->ProcessType = 1;
	me->swap = 0 ;
	__CheckRC( status, 1 , "COB status", quit ) ;

}

action VLcalcDirection( IGRlong *ret; IGRint current )
{

 IGRlong		msg = MSFAIL;	//   method return code
 OMuword		obj_cl;		// class id of current object

  *ret    = MSFAIL;
  me->surfObj.mod_env = me->ModuleInfo;

  status = as$make_source( go_grid = me->Lst1[current].obj_id	,
			mod_env = &(me->ModuleInfo)        	,
			as_os   = me->Module.md_id.osnum	,
			as_grid = &(me->surfObj.obj_id)        );

  __CheckRC( status, 1, "make source", wrapup ) ;

                // retrieve the support surface of the plate

  status = om$get_classid(	osnum           = me->surfObj._osnum  ,
				objid           = me->surfObj._objid  ,
				p_classid       = &obj_cl      ) ;

  __CheckRC( status, 1, "get classid of plate", wrapup ) ;


  if( 
      (om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id ,
                            subclassid    = obj_cl ) == OM_S_SUCCESS  ) ||
      (om$is_ancestry_valid( superclassid  = OPP_VSimgFeature_class_id ,
                            subclassid    = obj_cl ) == OM_S_SUCCESS  ) ||
      (	om$is_ancestry_valid(superclassid  = OPP_ACpretend_class_id ,
                            subclassid    = obj_cl ) == OM_S_SUCCESS ) ) {

	__DBGpr_com( "PlRol: calc_dir It's a plate!!\n" );

                         // Get bottom side of plate.

	status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        VS_K_plBotSfPath,
                                        &me->surfObj.obj_id,
                                        &me->surfObj._matrix_type,
                                        me->surfObj._matrix ),
                   senderid = NULL_OBJID,
                   targetid = me->surfObj._objid,
                   targetos = me->surfObj._osnum ) ;
	__CheckRC( status, msg, "PlRol: ACreturn_foot", wrapup );    
	__DBGpr_obj( "Pl: foot after return_foot", me->surfObj.obj_id );

  }
  else {
	__DBGpr_obj( "PlRol: calc_dirn unknown object ", me->surfObj.obj_id );
	goto wrapup;
  }

  status = om$send( msg  = message VLplRollCmd.findDirection( &me->surfObj ),
		targetid = my_id );
  CheckRC( status, 1 ) ;

  if ( ! current ) {
    status = om$send(msg = message VLplRollCmd.ShowDirection( ),
		targetid = my_id );
    CheckRC( status, 1 ) ;
  }

  *ret = status = OM_S_SUCCESS;

   __CheckRC( status, 1 , "COB status", quit ) ;

wrapup:				 /*          WRAPUP HERE */

  return status ;

} /* end calc direction*/


/**++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++**/

action VLswapDirection( )
{
		/** Change instance (global) ! 
			swap direction is probably a better name */

  if ( me->direction == TRUE )	me->direction = FALSE;  //  set to u
  else 				me->direction = TRUE;  //  set to v

  me->swap = 1;

  status = om$send( msg = message VLplRollCmd.status( "Direction changed"),
			targetid = my_id);
  __CheckRC( status, 1 , "COB status", quit ) ;

} /* swap dirn */

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*++ Method VLplaceRest:  Once the default direction established and line 
	have been place go through the rest of the list and place the lines.
+++++++++++++++++++++++++++++++++++++++++*/

action VLplaceRest( )
{
 struct GRid		rollLine;	// the resulting roll line
 struct GRsymbology	symbology;	// symbology for control lines
 IGRint			i, index, crv_ind,
 			current		= 0;	// current plate counter
 IGRlong		msg		= MSFAIL;	// method return code
 IGRchar		occ_name[50],		// name of current control line
 			tar_dir[DI_PATH_MAX],	 // dir of current control line
 			txt[80];		// text buffer for status field
 int			TypeSide	= 0; 	// side of plate to use

 enum    GRdpmode        dpmode=GRbd;    // mode for placed line



 __DBGpr_com( "place rest  " );

 symbology.display_attr.color		= me->ActiveDisplay.color;
 symbology.display_attr.weight		= me->ActiveDisplay.weight;
 symbology.display_attr.style		= 1;
 symbology.level			= me->cst.level;

  for ( current=0; current<me->Cnt1; current++ ){

	sprintf(txt,"processing plate %d/%d",current+1,me->Cnt1);
	om$send( msg = message VLplRollCmd.status(txt),
			targetid = my_id ); 
	if ( current ) {
 		   om$send( msg = message VLplRollCmd.VLcalcDirection( &msg,
									current
		   						      ),
			targetid = my_id );
	}

        if( me->nbCrvs )   {  index = me->nbCrvs ;  crv_ind = 1; }
        else               {  index = 1 ;           crv_ind = 0; }

        for( i=0; i<index; ++i )
        {
            rollLine.osnum = me->ModuleInfo.md_id.osnum;
            status = om$construct(
                                classname       = me->const_class,
                                osnum           = rollLine.osnum,
                                p_objid         = &rollLine.objid ) ;

            __CheckRC( status, 1, "PlRol: OMconstruct Roll", wrapup ) ;
            __DBGpr_obj( "PlRol: constructed Roll ", rollLine );

            TypeSide = VS_K_baOnBotOfPlate;
            status = om$send( msg = message VLrolLine.VLplaceRollLine(
                                                &msg           ,
                                                TypeSide       ,
                                                me->ProcessType  ,
                                                me->direction  ,
                                                me->ShipAxis   ,
                                                me->NumbLines  ,
                                                &me->Lst1[current],
                                                &me->ModuleInfo,
                                                &crv_ind,
                                                &me->CurveObj[i]
                                                ),
                targetid = rollLine.objid,
                targetos = rollLine.osnum );


            __CheckRC( status, msg, "PlRol: VLplaceRollLine ", next_plate );
            __DBGpr_obj( "Placed roll line ", rollLine );

            status = om$send ( msg = message VLplRollCmd.VLsymbNameDir (
                                                &msg ,
                                                ROLL_KEY,
                                                &(me->Lst1[current].obj_id),
                                                 VLMacroRolLn ,
                                                &symbology,
                                                tar_dir,
                                                occ_name,
                                                rollLine,
                                                &dpmode ),                           
			targetid = my_id );
        }

	CheckRC( status, msg );
	__DBGpr_str( "occurrence name ", occ_name );

next_plate:
	if ( !status&1&msg ) {
		sprintf(txt,"Could not place line on plate %d/%d",current+1,
								 me->Cnt1 );
		om$send( msg = message VLplRollCmd.status(txt),
				targetid = my_id ); 
	}

  } // end for on located objects

  me->swap = 0;

  status = OM_S_SUCCESS;
  __CheckRC( status, 1 , "COB status", quit ) ;

wrapup:

  return status;

} /* end of place_rest*/

/*=======================================================================*/

action ShowDirection( )
{
 IGRlong		msg,		//	return code
			numCurves = 0;	// number of possible curves on surf
 GRobjid		*curvesObjId = NULL;  // list of possible curves' ids
 IGRdouble		uv01[2];	// u/v coordinates

 me->cst.display->weight		= /*me->ActiveDisplay.weight+*/ 3;
 me->cst.geometry = NULL;
 me->cst.env_info = &me->ModuleInfo;

 uv01[0]	= 0.0;
 uv01[1]	= 1.0;

 if ( !me->direction ) {

	__DBGpr_com(  "courbure en u extract iso u");

	status = om$send (msg = message EMSsubbs.EMisoparcvs  (&msg,
					&me->surfObj._matrix_type,
					me->surfObj._matrix,
					&me->cst,
					FALSE,
					2,
					uv01,
					me->direction,	// in u
					&numCurves,
					&curvesObjId),
	targetid  = me->surfObj._objid,
	targetos  = me->surfObj._osnum );
 } 
 else {  // try the v direction

	__DBGpr_com(  "courbure en v extract iso v");

	status = om$send (msg = message EMSsubbs.EMisoparcvs  (&msg,
					&me->surfObj._matrix_type,
					me->surfObj._matrix,
					&me->cst,
					FALSE,
					2,
					uv01,
					me->direction,	// in v
					&numCurves,
					&curvesObjId),
	targetid  = me->surfObj._objid,
	targetos  = me->surfObj._osnum );

 }
 __CheckRC( status, msg, "PlRol: EMSsubbs.EMisoparcvs", wrapup );
 __DBGpr_int( "PlRol: found isos ", numCurves );

 if ( !curvesObjId ) goto wrapup;

 // display current direction via 2 lines

 me->tmpId[0].objid = curvesObjId[0];
 me->tmpId[0].osnum = me->ModuleInfo.md_id.osnum;
 __DBGpr_obj( "PlRol: iso0 ", me->tmpId[0] );

 status = gr$display_object( object_id = &me->tmpId[0], mode = GRbd); 
 CheckRC( status, 1 ) ;

 me->tmpId[1].objid = curvesObjId[1];
 me->tmpId[1].osnum = me->ModuleInfo.md_id.osnum;
 __DBGpr_obj( "PlRol: iso0 ", me->tmpId[1] );

 status = gr$display_object( object_id = &me->tmpId[1], mode = GRbd); 
 __CheckRC( status, 1 , "display status", quit ) ;


 status = OM_S_SUCCESS;

wrapup:

	me->cst.display->weight		= me->ActiveDisplay.weight ;
	return status;

} /* End ShowDirection */

/*===========================================================================*/

action findDirection(struct GRobj_env *cur_obj)
{
 struct IGRbsp_surface	*bspSf;		// pointer to Bspline surface
 struct GRparms		param;		// projection parameters
 IGRpoint		ptI,ptTmp ;	// projection & calculation points
 BSrc			bsrc;		// Maths return code
 IGRint 		numNormals;	// number of normals to surface
 IGRvector		normalI[1],	// unit normal
 			direct1,
			direct2;	// possible directions
 IGRdouble		curvature1,	// principal curvature in u
			curvature2,	// principal curvature in v
			uI,vI;		// u and v parameters normally 0.5

 IGRlong		msg	=	OM_E_INVARG;	// method return code


 if ( !cur_obj ) goto wrapup;

 status=om$send ( msg = message EMSsubbs.GRgenabsg(&msg, 
					&cur_obj->_matrix_type, 
					cur_obj->_matrix,
					(IGRchar **) &bspSf ),
	 targetid = cur_obj->_objid,
	 targetos = cur_obj->_osnum);

  __CheckRC( status, msg, "PlRol findD: EMSsubbs.GRgenabsg", wrapup );


  // get the unit normal


 BSsfevaln(	bspSf,
		0.5,
		0.5,
		1,
		&numNormals,
		ptI,
		normalI,
		&bsrc);

  if (bsrc!=BSSUCC) {	
 	printf("BSsfevaln : FAIL \n");
	goto wrapup;
  }

  __DBGpr_vec( "PlRol: find_dirn ptI", ptI );


  // get the curvatures

 uI 	= 0.5;
 vI 	= 0.5;
 BSsfarrevmc(	bspSf,
		1,
		&uI,
		1,
		&vI,
		FALSE,
		FALSE,
		TRUE,
		FALSE,
		TRUE,
		FALSE,
		ptI,
		NULL,
		NULL,
		&curvature1,
		&curvature2,
		NULL,
		direct1,
		direct2,
		NULL,
		&bsrc);
 if (bsrc!=BSSUCC) {	
 	printf("BSsfarrevmc : FAIL \n");
	goto wrapup;
 }

	__DBGpr_vec( "ptI", ptI );
	__DBGpr_dbl( "curv 1", curvature1 );
	__DBGpr_vec( "dir 1", direct1 ) ;
	__DBGpr_dbl( "curv 2", curvature2 );
	__DBGpr_vec( "dir 2", direct2 ) ;

 if (	fabs(curvature1)<fabs(curvature2)	)
	{v_add(ptI,direct2,ptTmp);}
  else
	{v_add(ptI,direct1,ptTmp);}


	__DBGpr_vec( "ptTmp", ptTmp ) ;

  status = om$send (msg = message GRgraphics.GRptproject (&msg,
				&cur_obj->mod_env.md_env.matrix_type,
				cur_obj->mod_env.md_env.matrix,
				ptTmp,
				ptI,
				&param),
	targetid  = cur_obj->obj_id.objid,
	targetos  = cur_obj->obj_id.osnum);	

  __CheckRC( status, msg, "PlRol findD: GRgraphics.GRptproje", wrapup );

 __DBGpr_dbl( "u param", param.u ) ;
 __DBGpr_dbl( "v param", param.v ) ;

		//  Change global !

 if (fabs(param.u-uI)>=fabs(param.v-vI)) me->direction=FALSE;
 else	me->direction=TRUE;

 __DBGpr_int( "PlRol: direction is now ", me->direction );

 if (me->swap)
   status = om$send( msg  = message VLplRollCmd.VLswapDirection(),
		targetid = my_id );
 CheckRC( status, 1 ) ;

 status = OM_S_SUCCESS;
 __CheckRC( status, 1 , "COB status", quit ) ;

wrapup:
	return status;

} /* end find direction */

/*===========================================================================*/

action VLsetAxis (IGRlong	*ret)
{
	*ret = VL_S_SUCCESS;
	switch (me->event1.event.keyin[0]) {

                case 'y':
                case 'Y':
                        me->ShipAxis[1] = 1.0;
                        break;

                case 'z':
                case 'Z':
                        me->ShipAxis[2] = 1.0;
                        break;

                default:        // X
                        me->ShipAxis[0] = 1.0;
        }

   status = OM_S_SUCCESS ;
   __CheckRC( status, 1 , "COB status", quit ) ;

   return status ;

} /* set the ship's axis */

/*===========================================================================*/

action VLsetNumb (IGRlong       *ret)
{
   *ret = VL_S_SUCCESS;

   me->NumbLines = atoi( me->event1.event.keyin ) ;

   if ( me->NumbLines > VLRolNumFeet/2 ) me->NumbLines = VLRolNumFeet/2 ;

   else if ( me->NumbLines <= 0 ) me->NumbLines = 1 ;

   __DBGpr_int( "PlRol: number of lines is now ", me->NumbLines );

   status = OM_S_SUCCESS ;
   __CheckRC( status, 1 , "COB status", quit ) ;

   return status ;
}

action VLsetProcessType (IGRlong       *ret)
{
   *ret = VL_S_SUCCESS;

   me->ProcessType = atoi( me->event1.event.keyin ) ;

   if( me->ProcessType < 0 || me->ProcessType > 2 )
	me->ProcessType = 1;

   if(  me->ProcessType == 0 )  *ret = MANUAL_ROLL ;
   status = OM_S_SUCCESS ;

   return status ;
}

action StoreCurve( long *sts ) {
int                     i, nb_obj=0;
struct GRobj_env        *LocatedObjects=NULL;

  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0 || nb_obj>10)
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
/*===========================================================================*/

action VLremoveIsos ()
{
  IGRlong	msg	=	MSFAIL;

		 // Unhighlight anything

  dp$erase_hilite( msg = &msg ) ;
  CheckRC( 1, msg ) ;

 // delete the iso curves displayed on the surface

  msg = vs$bulk_display(dpmode	= GRbe,
			count	= 2,
			grids	= me->tmpId,
			theEnv	= &me->ModuleInfo	);
  __CheckRC( 1, msg, "PlRol: bulk erase of isos", wrapup );

  msg = vs$bulk_delete(	count	= 2,
			grids	= me->tmpId,
			theEnv	= &me->ModuleInfo	);
  __CheckRC( 1, msg, "PlRol: bulk delete of isos", wrapup );

 		// deleting the isos will obscure the corresponding edges
  msg = vs$bulk_display( objenvs = &me->surfObj ,
			 dpmode = GRbd ); 
  __CheckRC( 1, msg, "PlRol: bulk display of plate", wrapup );
  
  status = OM_S_SUCCESS;
   __CheckRC( status, 1 , "COB status", quit ) ;

wrapup:
	return status;

}  /* end remove isos */

/* *++++++++++++++++++++++ end of slic file	*+++++++++++++++++++++++++++++*/
