/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/pcard/VLpcMethCmd.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/25/00        Rama Rao        Header Creation.
 * -------------------------------------------------------------------*/

class implementation VLpcCmd;

#include "AS_status.h"
#include "FI.h"
#include "vlpcmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "vlglobals.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "macro.h"
#include "acdef.h"
#include "acmacros.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vlmsg.h"
#include "vlpcdef.h"
#include "vlsdldef.h"
#include "vlsdl.h"
#include "vlsdlmacros.h"

from	ASnode		import	ACconnect_pretend;
from	NDmacro		import	ACreturn_foot;
from	GRgencs		import	GRgetmatrix;
from	NDnode		import	NDchg_state;
from	ACrg_collect	import	ACget_named_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from    ACheader        import  ACfind_model;
from    GRowner         import  GRget_matrix;
from    VDlink          import  GRgetrang;

#define	VLPC_FI_BORDER_NAME	12
#define	VLPC_FI_GAP		30
#define VLPC_FI_MAX_COL		40
#define VLPC_FI_VERBOSE		42

#define	IDX_PC_BDR_NAME		0
#define IDX_PC_GAP		1
#define IDX_PC_MAX_COL		2
#define IDX_PC_VERBOSE		3

#define NAM_PC_VERBOSE		"Verbose"

extern  char 		pcBorderName[DI_PATH_MAX];

method form_notification( int form_label; int gadget_label; 
						double value; char *form_ptr )
{
long		sts, msgl;
int		msg;
char		macName[DI_PATH_MAX];
struct	GRid	defId;

	switch( form_label ){

	case STATUS_FORM :
		switch (gadget_label) {
    		case FI_CANCEL:
			sts = 
			om$send(msg	 = message CEO.erase_form_by_label
						( STATUS_FORM, 0, &msg ),
				targetid = my_id);

			me->ret = om$send(	msg	 = 
						message VLpcCmd.VLinitUserVar(),
						targetid = my_id );
			as$status(sts = me->ret);
			goto quit;

    		case FI_ACCEPT:
			sts = 
			om$send(msg	 = message CEO.erase_form_by_label	
						( STATUS_FORM, 0, &msg ),
				targetid = my_id);

			// set variable into globals
			sts = om$send(	msg	 = message ACrg_collect.ACmod_list_attribute
						( &msgl, 4, me->userVar ),
					targetid = me->Globals.objid,
					targetos = me->Globals.osnum );
			as$status( sts = sts );
			as$status( sts = msgl );
			goto quit;

		case VLPC_FI_BORDER_NAME :
			FIg_get_text( form_ptr, gadget_label, macName );
			// check if macro exist
		        defId.objid    = NULL_OBJID;
		        sts = ac$find_macro_defn(       
					action          = ACfind_load,
                                        macro_name      = macName,
                                        p_macro_defn_id = &defId );
		        if( ! (sts&1) || defId.objid == NULL_OBJID )
			        FIg_set_text(	me->status_display_form_ptr, VLPC_FI_BORDER_NAME,  
				me->userVar[IDX_PC_BDR_NAME].desc.value.att_txt );

			else strcpy( me->userVar[IDX_PC_BDR_NAME].desc.value.att_txt, macName );

			break;

		case VLPC_FI_GAP :
			FIg_get_value( form_ptr, gadget_label, 
				&me->userVar[IDX_PC_GAP].desc.value.att_exp );
			break;

		case VLPC_FI_MAX_COL :
			FIg_get_value( form_ptr, gadget_label, 
				&me->userVar[IDX_PC_MAX_COL].desc.value.att_exp );
			break;

		case VLPC_FI_VERBOSE :
			 FIg_get_value( form_ptr, gadget_label, 
				&me->userVar[IDX_PC_VERBOSE].desc.value.att_exp );
			break;

		default:
			goto quit;
		}

	default:
		goto quit;
	}

quit:

return OM_S_SUCCESS;
}

method wakeup( int pos )
{

	/* Execute method wakeup of VLlocateCmd*/
	me->StatusDisplay = TRUE;
	me->ret = om$send ( msg      = message VLpcCmd.wakeup( pos ),
			    mode     = OM_e_wrt_parent,
			    targetid = my_id );
	as$status(sts = me->ret);

	me->ret = om$send(	msg	 = message VLpcCmd.VLinitUserVar(),
				targetid = my_id );
	as$status(sts = me->ret);

return	OM_S_SUCCESS;
}

method VLinitUserVar()
{
long			sts, msg;

	strcpy( me->userVar[IDX_PC_BDR_NAME].name, NAM_G_PC_BDR_NAME );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &me->userVar[IDX_PC_BDR_NAME] ),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	if( ! (sts&msg&1)){
		strcpy( me->userVar[IDX_PC_BDR_NAME].desc.value.att_txt, 
							VAL_G_PC_BDR_NAME );
		me->userVar[IDX_PC_BDR_NAME].desc.type = AC_ATTRIB_TEXT;
	}

	strcpy( me->userVar[IDX_PC_GAP].name, NAM_G_PC_GAP );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &me->userVar[IDX_PC_GAP] ),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	if( ! (sts&msg&1)){
		me->userVar[IDX_PC_GAP].desc.value.att_exp= VAL_G_PC_GAP ;
		me->userVar[IDX_PC_GAP].desc.type = AC_ATTRIB_DOUBLE;
	}

	strcpy( me->userVar[IDX_PC_MAX_COL].name, NAM_G_PC_MAX_COL );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &me->userVar[IDX_PC_MAX_COL] ),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	if( ! (sts&msg&1)){
		me->userVar[IDX_PC_MAX_COL].desc.value.att_exp=VAL_G_PC_MAX_COL;
		me->userVar[IDX_PC_MAX_COL].desc.type = AC_ATTRIB_DOUBLE;
	}


	strcpy( me->userVar[IDX_PC_VERBOSE].name, NAM_G_PC_VERBOSE );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( &msg, &me->userVar[IDX_PC_VERBOSE] ),
			targetid = me->Globals.objid,
			targetos = me->Globals.osnum );
	if( ! (sts&msg&1)){
		me->userVar[IDX_PC_VERBOSE].desc.value.att_exp=VAL_G_PC_VERBOSE;
		me->userVar[IDX_PC_MAX_COL].desc.type = AC_ATTRIB_DOUBLE;
	}

	// initialize option form
        FIg_set_text(	me->status_display_form_ptr, VLPC_FI_BORDER_NAME,  
			me->userVar[IDX_PC_BDR_NAME].desc.value.att_txt );
        FIg_set_value(	me->status_display_form_ptr, VLPC_FI_GAP, 
			me->userVar[IDX_PC_GAP].desc.value.att_exp );
        FIg_set_value(	me->status_display_form_ptr, VLPC_FI_MAX_COL, 
			me->userVar[IDX_PC_MAX_COL].desc.value.att_exp );
        FIg_set_value(	me->status_display_form_ptr, VLPC_FI_VERBOSE, 
			me->userVar[IDX_PC_VERBOSE].desc.value.att_exp );

return OM_S_SUCCESS;
}


/* ----------------------- FCT VLplacePcOnBorder ----------------------	*/
long	VLplacePcOnBorder( struct GRobj_env *drwBrOv, 
						struct GRobj_env *stiffOv )
{
long			sts, msg;
char			*usedView[10];
int			maxView;
char			ViewRgPt[DI_PATH_MAX];
struct	GRid		foot, pcViewId, pcTextId;
struct	GRobj_env	csView, rngPt;
int			suc;
int			k;

	// Initialization
	usedView[0]	= "side";
	usedView[1]	= "top";
	usedView[2]	= "bottom";
	usedView[3]	= "end_on";
	maxView		= 4;

	// scan profile card to get view
	for( k=0; k<maxView; k++ ){

		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
						&msg,
						usedView[k],
						&foot,
						NULL, NULL ),
				senderid = NULL_OBJID,
				targetid = drwBrOv->obj_id.objid,
				targetos = drwBrOv->obj_id.osnum );
		if( ! (sts&msg&1))	continue;

		// generate pretend on border for viewCs
		csView.obj_id.objid	= NULL_OBJID;
		sts = om$send(	msg	 = message ASnode.ACconnect_pretend
					( &suc, usedView[k], &csView.obj_id ),
				senderid = NULL_OBJID,
				targetid = drwBrOv->obj_id.objid,
				targetos = drwBrOv->obj_id.osnum );
		as$status( sts = sts );
		as$status( sts = suc );
		if( ! (suc&sts&1) || csView.obj_id.objid == NULL_OBJID ){
			printf(" Error in connect_pretend \n");
			continue;
		}
		csView.mod_env = drwBrOv->mod_env;

		sprintf( ViewRgPt, "maxrg%s", usedView[k] );
		// generate pretend on border for rngPt
		rngPt.obj_id.objid	= NULL_OBJID;
		sts = om$send(	msg	 = message ASnode.ACconnect_pretend
					( &suc, ViewRgPt, &rngPt.obj_id ),
				senderid = NULL_OBJID,
				targetid = drwBrOv->obj_id.objid,
				targetos = drwBrOv->obj_id.osnum );
		as$status( sts = sts );
		as$status( sts = suc );
		if( ! (suc&sts&1) || rngPt.obj_id.objid == NULL_OBJID ){
			printf(" Error in connect_pretend \n");
			continue;
		}
		rngPt.mod_env = drwBrOv->mod_env;

		sts = vl$plpcview(
				supportId	= stiffOv,
				csId		= &csView,
				viewType	= usedView[k],
				rngPtId		= &rngPt,
				asState		= ND_DONT_MVRT,
				env		= &drwBrOv->mod_env,
				pcViewId	= &pcViewId );
		as$status( sts = sts );
		VLprocMgrPulse();
	}

	sts = vl$plpctext(	drwBdr	= drwBrOv,
				support	= stiffOv,
				env	= &drwBrOv->mod_env,
				pcText	= &pcTextId );
	as$status( sts = sts );

return	MSSUCC;
}

method VLcheckInput( long *rc )
{
long	sts;
struct	GRid	defId;
GRname		macName;


	*rc	= VL_S_SUCCESS;

	// check drawing border definition
	defId.objid    = NULL_OBJID;
	strcpy( macName, me->userVar[IDX_PC_BDR_NAME].desc.value.att_txt );
	sts = ac$find_macro_defn(	action          = ACfind_load,
					macro_name      = macName,
					p_macro_defn_id = &defId );
	if( ! (sts&1) || defId.objid == NULL_OBJID ){ *rc = MSFAIL; }

return	OM_S_SUCCESS;
}

method VLpcPlace( long *sts )
{
long			sts, msg;
int			i;
IGRshort                world=FALSE;
GRrange                 range;
struct  GRmd_env        model_env;
struct	GRobj_env	csOv, drwBrOv, stiffOv;
char			drwBrName[DI_PATH_MAX];
double			L, W, gap;
int			maxCol;
IGRboolean		pcTerm;
double			csMat[16], nextMat[16];
double			basePt[3];
char			gText[DI_PATH_MAX];
VLsdlContext            sdlC;
struct GRid		contextCollId, model;
double                  viewPl[6];
double                  vector[3];
struct  IGRplane        view, plane;
struct  IGRlbsys        drwLbsys;
VSdrwOutputData         *outPutInit=NULL;
VSdrwOutputData         *outPutCur=NULL;

	// Initialization

	strcpy( drwBrName, me->userVar[IDX_PC_BDR_NAME].desc.value.att_txt );
	drwBrOv.mod_env	= me->Current;

	// get start Matrix
	csOv =  me->Lst2[0];
	sts = om$send(	msg	 = message GRgencs.GRgetmatrix
					( &msg, csMat ),
			targetid = csOv.obj_id.objid,
			targetos = csOv.obj_id.osnum );
	as$status( sts = sts );
	as$status( sts = msg );

	for( i=0; i<16; i++ )	nextMat[i] = csMat[i];

	basePt[0]	= csMat[3];
	basePt[1]	= csMat[7];
	basePt[2]	= csMat[11];

	// get range of border
	L 	= 295.;
	W 	= 210.;
	gap	= me->userVar[IDX_PC_GAP].desc.value.att_exp;
	maxCol	= (int)me->userVar[IDX_PC_MAX_COL].desc.value.att_exp;

        view.point      = &viewPl[0];   // plane associate to the web_left
        view.normal     = &viewPl[3];   // side of the stiffner
        plane.point     = &viewPl[0];   // Projection orthogonal
        plane.normal    = &viewPl[3];   //

        // drwLbsys == range of support
        MAidmx( &msg, drwLbsys.matrix );
        for( i=0; i<3; i++ )    drwLbsys.diag_pt1[i] = 0;
        for( i=0; i<3; i++ )    drwLbsys.diag_pt2[i] = 0;

	vl$sdlInit( ctx = &sdlC );

	for( i=0; i<me->Cnt1; i++ ){

                // set cur_state with startBorder
                vl$sdlSetState( ctx = &sdlC, state = VLPC_BORDER );
                vl$sdlGetCol(   ctx     = &sdlC,
                                colType = VLSDL_SYST_COL,
                                colId   = &contextCollId );

		// Init process manager
		VLprocMgrInit();
		if( ! ((int)me->userVar[IDX_PC_VERBOSE].desc.value.att_exp ))
			VLprocMgrClose();
		sprintf( gText, "%d/%d", i+1, me->Cnt1 );
		VLprocSetFText( gText );
		VLprocSetSText( VL_E_PROC_PC, gText );
		VLprocMgrPulse();

		pcBorderName[0] = '\0';
		VLvl_pc_LoadKeyWords();

		VLpcSetGlobPcTerminate( FALSE ) ;

        	vs$drwExecConfig(       
				msg             = &msg,
                                elmId           = &contextCollId,
                                elmEnv          = &drwBrOv.mod_env,
                                drwPlane        = &plane,
                                viewPlane       = &view,
                                viewVector      = vector,
                                drwEnv          = &drwBrOv.mod_env,
                                drwLbsys        = &drwLbsys,
                                selCount        = 1,
                                selList         = &me->Lst1[i].obj_id,
                                filename        = VLPC_GR_FILE,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCur->next
                                                        : &outPutInit );

		VLpcGetGlobPcTerminate( &pcTerm );
		if( pcTerm == TRUE ) 
		{
		   VSdrwRmFunctions();

		   VLprocMgrClose();

                   VSdrwFreeOutputData( &outPutInit );
                   outPutInit = NULL;

		   continue;
		}

        	if( pcBorderName[0] != '\0' )
        	{
          	    strcpy( drwBrName, pcBorderName );
        	}

	        // remove pcard functions
        	VSdrwRmFunctions();

		if( i != 0 ){

			sts = om$send ( msg = message ACheader.ACfind_model
                                                ( &msg, &model),
                                senderid = NULL_OBJID,
                                targetid = drwBrOv.obj_id.objid,
                                targetos = drwBrOv.obj_id.osnum );

			sts = om$send ( msg = message GRowner.GRget_matrix(
                                &msg,&drwBrOv.mod_env.md_env.matrix_type,
                                drwBrOv.mod_env.md_env.matrix,
                                &model_env.md_env.matrix_type,
                                model_env.md_env.matrix ),
                                senderid = NULL_OBJID,
                                targetid = drwBrOv.obj_id.objid,
                                targetos = drwBrOv.obj_id.osnum );

                        sts = om$send ( msg = message VDlink.GRgetrang(
                                        &msg, &model_env.md_env.matrix_type,
                                        model_env.md_env.matrix,
                                        &world, range ),
                                senderid = NULL_OBJID,
                                targetid = model.objid,
                                targetos = model.osnum  );

			L = range[3] - range[0] ;
			W = range[4] - range[1] ;

			// create next Cs
			csOv.mod_env = me->Current;
			if( (i % maxCol) != 0 ){
			    // next column
			    nextMat[3]  += nextMat[0] * (L + gap);
			    nextMat[7]  += nextMat[4] * (L + gap);
			    nextMat[11] += nextMat[8] * (L + gap);
			} else {
			    // next line
			    nextMat[3]  = basePt[0] -= (nextMat[1] * (W +gap));
			    nextMat[7]  = basePt[1] -= (nextMat[5] * (W +gap));
			    nextMat[11] = basePt[2] -= (nextMat[9] * (W +gap));
			  }

			sts = vl$plcs( 	mat	= nextMat,
					env	= &csOv.mod_env,
					csId	= &csOv.obj_id );
			as$status( sts = sts );

			// make source on Cs
			sts = as$make_source(	go_grid	= csOv.obj_id,
						as_grid	= &csOv.obj_id,
						mod_env	= &csOv.mod_env,
						as_os	= &csOv.mod_env.md_id.osnum );
			as$status( sts = sts );

			// set assoc state
			sts = om$send(	msg	 = message NDnode.NDchg_state
						( ND_DEL_NO_CH, ND_DEL_NO_CH ),
				senderid = NULL_OBJID,
				targetid = csOv.obj_id.objid,
				targetos = csOv.obj_id.osnum );
			as$status( sts = sts );
		} // end create Cs

		// place next Drw Border
		sts = vl$pldrwborder(	csId	= &csOv,
					name	= drwBrName,
					env	= &drwBrOv.mod_env,
					border	= &drwBrOv.obj_id );
		as$status( sts = sts );

		VLprocMgrPulse();

		// place next PC
		stiffOv =  me->Lst1[i];
		sts = VLplacePcOnBorder( &drwBrOv, &stiffOv );
		as$status( sts = sts );

		VLprocMgrClose();

        	VSdrwFreeOutputData( &outPutInit );
        	outPutInit = NULL;
	}

        // Free context
        vl$sdlFree( ctx = &sdlC );

return	OM_S_SUCCESS;
}


end implementation VLpcCmd;
