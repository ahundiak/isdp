/* $Id: VRflowdir.sl,v 1.4 2002/04/10 19:37:52 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflowco/VRflowdir.sl
 *
 * Description:
 *   This file contains the command object needed to change flow direction
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRflowdir.sl,v $
 *      Revision 1.4  2002/04/10 19:37:52  louis
 *      TR5649-standardize tolerances
 *
 *      Revision 1.3  2001/02/20 01:13:56  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/12 20:43:11  anand
 *      SP merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:52  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/07/28  16:36:12  pinnacle
# Created: route/vrflowco/VRflowdir.sl by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.7  1998/03/27  21:39:36  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.6  1998/03/27  17:22:24  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.5  1998/03/17  14:38:50  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.4  1998/03/08  23:38:04  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.3  1997/10/20  15:36:22  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.9  1997/10/01  20:36:34  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.8  1997/09/18  21:17:46  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by onayragu for route
#
# Revision 1.7  1997/07/02  18:36:36  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.6  1997/06/24  22:05:20  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.5  1997/04/22  22:42:46  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.4  1997/04/15  21:35:18  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.3  1997/03/02  17:14:46  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by r241_int for route
#
# Revision 1.2  1997/02/22  00:21:56  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/03/05  22:50:12  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by hverstee for route240
#
# Revision 1.4  1996/03/04  21:53:10  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  23:58:04  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:21:58  pinnacle
# Replaced: vrflowco/VRflowdir.sl for:  by r240_int for route240
#
 *
 * History:
 *	momo : 11-06-1991	design date
 *	bruno: 31-12-1992	Change display and fixe propagation.
 *
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/16/96	tlb	Add prototypes
 *      Feb 97          kdd     VRReverseFlowDir, EX_STRING in state Chg_Dir 
 *                              locate_owner in state start. New FlowDir alg.
 *	Mrs 97		adz	Add include files to compilation.
 *	Apr 97		kdd	Propagate from !VR_DANGLING && !VRNozzle 
 *	June 1997	kdd     Now we propagate from VRCorrection not
 *				VRComponent. See VRCorrection.VRPropagateFlow.
 *				Again the propgation is only along 2 con point
 *				elements (Corrections and Components). 
 *				The pattern is like:
 *
 *	VRComponent (father_0) <---> VRCorrection <---> (father_1) VRComponent
 *
 *				VRCorrection can own other VRComponents.
 *	3-98		KDD	locate_eligible
 *	07/28/2000	Alwin	Implemented selection of more than one element 
 *				to display the flow direction. CR179901347
 *      04/05/02        law     TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

command_string       VRC_M_ChgFlowDir,0,VRMdFlDr
class                VRflowdir
super_class          VDB_LOCATE
product_name         "$ROUTE"
command_table	     "route.cmd"

specification

instance
{
  IGRshort		CurCpt;
  IGRint		NbCpts;
  struct GRid		LocatedObject;
  int			NumPropagateCorr;
  struct GRid		PropagateCorr[2];
  IGRint		NbLocatedObjects;
  struct GRid		*LocObjects;
}


implementation

/*
#define vdsDEBUG 1
*/

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include "igewindow.h"
#include "dp.h"
#include "igrdef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "VRcompdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "VRcordef.h"
#include "VRutildef.h"

#include "vrinit_pto.h"
#include "vrflowco_pto.h"
#include "bslenvec.h"

#include "OMprimitives.h"
#include "vrdbgmacros.h"
#include "vrparameters.h"
#include "coparamac.h"
#include "VRdef.h"
#include "VRMath.h"
#include "VDmem.h"

#define	AS_DEBUG	 1
#define	FIN		 2
#define	MULTISELECT	 100

from	VRGeneric	import	VRGetFlow,
				VRGetCptGeom,
				VRGetCorrections,
				VRGetCorOnCpt,
				VRGetStatus,
				VRGetSysType,
				VRGetPrivateParams,
				VRGetNumberOfCpts;

from	VRCorrection	import	VRget_state,
                                GRgetattr,
                                GRputattr,
				VRSetFlow,
                                VRGetNumCptOfMyComps,
				VRPropagateFlow,
				VRGetCmpNeighbor,
				VRUpdateFlowArrow,
				VRDeleteFlowArrow;



from	NDnode		import	NDdisplay,
				NDchange_node,
				NDget_objects;

from	GRvg		import	GRgetsymb;

from	ACrg_collect	import	ACmod_list_attribute;


/* KDD + externals */
extern	int	VRCorrection_VRFlArSym();
extern  int	VRStorage(); 

/* Macros */
#define sign(x)  ( ((x) < 0)? -1: 1) 


/**********************************************************/

state_table

#include "VRmsg.h"

#define	FIN		 2

state start

	message_key	VR_M_ChgFlowDir
	prompt_key	VR_P_IdComp
	status		""
	dynamics	off
	locate_eligible	"+VRComponent, +VRConcComp"
        locate_owner    "LC_RIGID_OWNER|LC_FLEX_COMP|LC_RIGID_COMP|LC_REF_OBJECTS"
	accept_key	VR_P_AccReject
	relocate_key	VR_S_CompNotFound
	filter		locate
 

   execute initialize

   on EX_BACK_UP	state .
   on EX_RJT_MOVEON 	state .

   on EX_DATA		do VRGetObject ( &me->ret, 0 )
			do VRGetNextCpt( &me->ret, 0 )
			state Chg_Dir

   on ELSE		state terminate

/*----------------------------------------------------------------------------*/

state Chg_Dir

   execute VRDispCptFlowDir( &me->ret, 1, 0 )

        prompt          "Accept Flow Direction/MoveOn to change (or B, R)"
	dynamics	off
	filter		get_event


   execute VRDispCptFlowDir( &me->ret, 0, 0 )


   on EX_STRING         do VRReverseFlowDir( me->event1.event.keyin)
                        state .

   on EX_DATA		do VRGetNextCpt	( &me->ret, 0 )
	      			on RETURN_CODE = FIN	state start
			state .

   on EX_RJT_MOVEON     do VRReverseFlowDir (0)
			state .

   on EX_BACK_UP	state start


   on ELSE		state terminate

/********************************************************************************************/

action init
{
  /*| call VDB_LOCATE.init method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.init( type, str_ptr ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated) return (status);

  VRInitPid();

  goto quit;

}/* end init */

/******************************************************************************/

action initialize
{
	/*---- KDD reset current flow arrow symbol and update flag ----*/

  int 		dummy = 0;

  status = VRStorage((char *) &dummy, VRFlowDirOldSymbol,  NULL, 1);
  status = VRCorrection_VRFlArSym(1, &dummy);
  status = VRCorrection_VRFlArSym(2, &dummy);


  /*----  Reset Propagate Correction(s).  ----*/

  me->NumPropagateCorr = 0;
  me->PropagateCorr[0].objid = NULL_OBJID;
  me->PropagateCorr[1].objid = NULL_OBJID;

  // added for CR179901347. Alwin
  me->NbLocatedObjects = 0;
  me->LocObjects = NULL;
}

/******************************************************************************/

action VRGetObject ( IGRlong *sts; IGRboolean bDisplayFlowDirCmd )

{
  IGRchar	ClassName[256];
  IGRlong	retcode;

  SetProc( Md VRGetObject ); Begin 

  me->LocatedObject       = me->event1.located_object[0].located_obj;

  status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
			       ( &retcode, &me->NbCpts, &me->ModuleInfo ),
                    targetid = me->LocatedObject.objid,
                    targetos = me->LocatedObject.osnum );

  /*"NbCpts = %d\n", me->NbCpts */

  me->CurCpt = -1;

  __DBGpr_obj( " Located Object Id", me->LocatedObject );

  if( bDisplayFlowDirCmd )
  {
    /* For the "Display Flow Direction" command, the input could be
     * Fence object or tip of a Network. From this object we need to extract
     * the Correction Object to which the Display is set.
     */
      IGRint            NumOfFenceObjs=0;
      struct GRobj_env  *FenceObjs=NULL;

      __DBGpr_com( " Start Fence " );
      as$start_fence(set= &me->event1.located_object[0].located_obj,
                    set_env = &me->event1.located_object[0].module_info,
                    nb_obj = &NumOfFenceObjs,
                    p_obj_env = &FenceObjs,
                    response = me->response,
                    response_data = me->response_data );

      if ( !NumOfFenceObjs )
      {
	      *sts = MSFAIL;
	      return  OM_S_SUCCESS;
      }

      if( NumOfFenceObjs )
      {
	 IGRint i;

	 for( i=0; i<NumOfFenceObjs; i++ )
	 {
	     extern GRclassid	OPP_VRComponent_class_id;
	     extern GRclassid	OPP_VRRComp_class_id;
	     GRclassid		ClassId;

	     om$get_classid(objid = FenceObjs[i].obj_id.objid,
			    osnum = FenceObjs[i].obj_id.osnum,
			    p_classid = &ClassId );

	     /*
	      * Grab all the components and check if its Correction Component or
	      * not. Filter out the Raceway Correction Components as they don't
	      * need flow direction. If its Correction Component get the owner 
	      * Correction Entity and store in an array for later use. 
	      * CR179901347 Alwin 
	      */
	     if( om$is_ancestry_valid (
				subclassid = ClassId,
				superclassid = OPP_VRComponent_class_id ) && 
		  ( ClassId != OPP_VRRComp_class_id ) )
	     {
		IGRshort	CmpStatus;

		status = om$send( msg = message VRGeneric.VRGetStatus(
					&retcode, &CmpStatus ),
			      targetid = FenceObjs[i].obj_id.objid,
			      targetos = FenceObjs[i].obj_id.osnum );

		if( CmpStatus & VR_CORRECTION )
		{
		   me->NbLocatedObjects++;

		   if( me->NbLocatedObjects == 1 )
			  me->LocObjects = _CALLOC( me->NbLocatedObjects, 
						    struct GRid);
		   else
			  me->LocObjects = _REALLOC( me->LocObjects,
					me->NbLocatedObjects, struct GRid);

		   __CheckPtr(me->LocObjects, "Memory Allocation Error", quit );

		   me->LocObjects[me->NbLocatedObjects-1] = FenceObjs[i].obj_id;

		   *sts = me->ret = MULTISELECT;
		}
	     }
	 } // for i=0, NumOfFenceObjs loop ends here
      } // if NumOfFenceObjs loop ends here

      __DBGpr_int( " No. of Fence Objects", NumOfFenceObjs );
      ASend_fence();
  }

  End
  goto quit;
}


/******************************************************************************
* 
* Note: Display Flow Direction command calls this method with Single = 1.
*       Modify Flow Direction command calls it with Single = 0.
******************************************************************************/

action VRDispCptFlowDir( IGRint *sts, DisplayFlag, Single )

{
	IGRint			i,State,NbCor, NumComp3Cpt;
	IGRlong			retcode;
	struct	GRid		CorId[2]; /* maximum 2 correction to display */
	struct GRsymbology	Symb;
static	IGRboolean		bDisplayed[2]={FALSE,FALSE};
				/* to remember whether the arrow was already
						 displayed or not */
SetProc( VRflowdir.VRDispCptFlowDir );Begin

	dp$erase_hilite(msg	= &retcode);

	UI_status("");

	if ( !Single && me->NbCpts <= 2 )
	{
		status =
		om$send( msg      = message VRGeneric.VRGetCorrections
				( &retcode, 2, CorId, &NbCor),
			targetid = me->LocatedObject.objid,
			targetos = me->LocatedObject.osnum );

	}/* end not inline component managment */
	else
	{
		NbCor = 1;
		status =
		om$send( msg     = message VRGeneric.VRGetCorOnCpt( &retcode, 
					me->CurCpt, &CorId[0], &me->ModuleInfo),
			targetid = me->LocatedObject.objid,
			targetos = me->LocatedObject.osnum );
	}/* end not inline component managment */

	as$status ( action = RET_STATUS );

for (i=0; i<NbCor; i++) {

  if (DisplayFlag)
  {
	status =
	om$send( msg      = message VRCorrection.VRget_state (&State),
		targetid = CorId[i].objid,
		targetos = CorId[i].osnum );

	if ( !(bDisplayed[i] = (State & VR_DISP_FLOW)) )
	{
/* KDD June 97
*  To display the flow direction of a correction, the correction must own only
*  components with 1 or 2 connect points.
*  Post warning if display Flow Direction Command is invoked. 
*/
  		status = om$send(msg = message VRCorrection.VRGetNumCptOfMyComps
                                           (&retcode, NULL, NULL, &NumComp3Cpt,
                                            NULL, NULL, NULL, &me->ModuleInfo),
                            targetid = CorId[i].objid,
                            targetos = CorId[i].osnum );

  		if ( NumComp3Cpt != 0 ) {
	           if (Single) UI_status("Component with 3+ connect points.");
           	   continue;
  		}

		/* -- Force the flow display -- */

		/* get symbology from the located object */
		status =
		om$send( msg      = message GRvg.GRgetsymb
					( &retcode, &Symb ),
			targetid = me->LocatedObject.objid,
			targetos = me->LocatedObject.osnum );

		status =
		om$send( msg     = message VRCorrection.VRUpdateFlowArrow
				    (&retcode, 0, NULL, &Symb, &me->ModuleInfo),
			targetid = CorId[i].objid,
			targetos = CorId[i].osnum );
	}

	status =
	om$send( msg     = message NDnode.NDdisplay
				( 0, GRbdhd , &me->ModuleInfo ),
		targetid = CorId[i].objid,
		targetos = CorId[i].osnum );
	as$status();

	/*----  Set Propagate Correction(s)  ----*/

	if ( me->NumPropagateCorr >= 2 ) me->NumPropagateCorr = 0; 
	me->PropagateCorr[ me->NumPropagateCorr++ ] = CorId[i]; 

  }
  else	if (Single || !bDisplayed[i])
  {
	status =
	om$send( msg      = message NDnode.NDdisplay
				( 0, GRbehe , &me->ModuleInfo ),
		targetid = CorId[i].objid,
		targetos = CorId[i].osnum );
	as$status();

	status =
	om$send( msg      = message VRCorrection.VRDeleteFlowArrow
				(&retcode, &me->ModuleInfo),
		targetid = CorId[i].objid,
		targetos = CorId[i].osnum );
	nd$exec_batch (mode = 0 );

	status =
	om$send( msg      = message NDnode.NDdisplay
				( 0, GRbd , &me->ModuleInfo ),
		targetid = CorId[i].objid,
		targetos = CorId[i].osnum );
	as$status();

	/*----  Set Propagate Correction(s)  ----*/

	if ( me->NumPropagateCorr >= 2 ) me->NumPropagateCorr = 0; 
	me->PropagateCorr[ me->NumPropagateCorr++ ] = CorId[i]; 
  }

	as$status ( action = RET_STATUS );


 }/* end loop on corrections */

End
  goto quit;
}/* end VRDispCptFlowDir */

/*******************************************************************************
*  KDD
*       code is a pointer to the new direction code symbol.
*-------------------------------------------------------------------------------
*  NOTE:
*	If you need to add new symbols. Change the logic here and in 
*	vrcorrection/VRCorrecti.I (macro name choice "pidflow")
*-------------------------------------------------------------------------------
*  PARAMETERS
*  
*  flag	= flag to point to flow_direction for the correction (Generic.VRGetFlow)
*	  0 along the correction vector
*	  1 opposite. 
*
*-------------------------------------------------------------------------------
*  PROMPT INPUT:
*
*  code = NULL . Change the flow direction according to:
*	  NULL --> Xsymbol --> reverse --> bi_direct --> Xsymbol --> reverse
*
*       =  'B' or 'b'  bidirectional flow arrow
*          'R' or 'r' reverse direction. R --> L, L --> R, B --> R.
*
*-------------------------------------------------------------------------------
* Note 10-97:
*	Flow DIrection is defined as vector = (Correction_cpt_1 - cpt_0).
*
*-------------------------------------------------------------------------------
*  FLOW DIRECTION ALGORITHM: Feb-97 KDD
*
*  if ( abs(VRFlowDirOldSymbol) == abs(current_symbol) ) then
*       change symbol.
*  else
*       reverse sign
*  endif
*******************************************************************************/

action VRReverseFlowDir ( IGRchar       *code)
{
	IGRlong		retcode;
	IGRshort	nFlowDir,nOppFlowDir;
	int		dummy, i, index;
	int		flag=0;
	IGRshort	Comp_status;
	int		SetUpdateFlag = 2, UpdateFlag;
	IGRshort	old_symbol;


SetProc( VRflowdir.VRReverseFlowDir );Begin

        UI_status("");

/*-----------------
# KDD June 97. Now the flow direction gets propagated by the correction, not
* the component. That is natural, since it is the correction that holds
* flow direction arrow.
-----------------*/
{
	IGRshort		FlowDir, NewFlowDir, ConnectPoint;

	IGRint			NumCor, NumComp3Cpt;

	struct  GRid		CorId, SysParId,
				Correction[2];

        struct ACrg_coll   	Attr;

   struct VRCorrection_common 	attr;

        UpdateFlag = 0; 
        status = VRCorrection_VRFlArSym( SetUpdateFlag, &UpdateFlag);
	status = VRStorage((char *) &dummy, VRFlowDirOldSymbol,  NULL, 0);
	old_symbol = (IGRshort) dummy;


__DBGpr_obj("me->LocatedObject", me->LocatedObject);

/* 
#1. Can not propagate from components with more than 2 connect points. 
	if ( me->NbCpts > 2 )  { goto quit1; }
*/
	
/*
#2. Get a correction to propagate from.
*   For components owned by correction, VRGetCorrections will return the owner,
*   otherwise will return the children corrections.  Either way works for us. 
        status = om$send( msg = message VRGeneric.VRGetCorrections
                                        (&retcode, 2, Correction, &NumCor),
                     targetid = me->LocatedObject.objid,
                     targetos = me->LocatedObject.osnum );
	if ( !(status&1) ) goto quit1; 
*/

/*----------------
#  Get Propagate Correction(s). Determined and highlighted in VRDispCptFlowDir.
----------------*/
	NumCor = me->NumPropagateCorr;
	Correction[0] = me->PropagateCorr[0];
	Correction[1] = me->PropagateCorr[1];

	if((Correction[0].objid==NULL_OBJID)&&(Correction[1].objid==NULL_OBJID))
	{ 
	     printf("Undefined Propagate Correction \n"); 
	     goto quit1;
	}
	

/*
#2.1. The propagate correction must own only 1 or 2 connect point components.
*/
	index = -1; 

	for (i = 0; i < NumCor; i++ ) {
__DBGpr_obj("Correction       ", Correction[i]);

  	    status = om$send( msg  = message VRCorrection.VRGetNumCptOfMyComps
					(&retcode, NULL, NULL, &NumComp3Cpt, 
					 NULL, NULL, NULL, &me->ModuleInfo),
                          targetid = Correction[i].objid,
                          targetos = Correction[i].osnum );

  	    if ( NumComp3Cpt == 0 ) { index = i; break; }
	}
	if ( index == -1) goto quit1; 

	CorId.objid = Correction[index].objid;
	CorId.osnum = Correction[index].osnum;

__DBGpr_obj("Propag Correction", CorId); 

/*
#3. Get the flow direction from correction CorId 
*/
    	attr.Iwant = VRCorrection_FlowDirection;

    	status = om$send ( msg = message VRCorrection.GRgetattr
                                   (&retcode, (IGRchar *) &attr),
	              targetid = CorId.objid,
	              targetos = CorId.osnum );

	FlowDir= attr.FlowDirection; 

__DBGpr_int("Old FlowDirection", (int) FlowDir); 
__DBGpr_int("Old Symbol       ", (int) old_symbol); 

/*
#4. Change the flow direction according to the algorithm 
*/ 
   if ( code == NULL ) {

        switch (FlowDir) {
           case VR_FLOW_IN:
           case VR_FLOW_OUT:
                if ( abs(old_symbol) == abs(FlowDir) ) 
                   NewFlowDir = VR_FLOW_BIDIRECTION * sign(FlowDir);
                else 
                   NewFlowDir = - FlowDir;

                break;

           case   VR_FLOW_BIDIRECTION:
           case - VR_FLOW_BIDIRECTION:
		NewFlowDir = - VR_FLOW_OUT * sign(old_symbol); 
                break;

           default:
                UI_status("Unknown Current Flow Direction.");
		NewFlowDir = VR_FLOW_OUT;
                break;
        }
   }
   else {
        switch ( toupper(code[0]) ) {

           case 'B':
                NewFlowDir =  VR_FLOW_BIDIRECTION * sign(FlowDir);
                break;

           case 'R':
                NewFlowDir = - FlowDir;
                break;

           default:
                UI_status("Unknown flow direction code.");
                goto quit1;
        }
   }

/*
#4.1. If needed allow flow arrow symbol update.
*/
	if ( abs(NewFlowDir) != abs(FlowDir) )  {
           UpdateFlag = 1; 
           status = VRCorrection_VRFlArSym( SetUpdateFlag, &UpdateFlag);
	}

   	old_symbol = FlowDir; 
	dummy = (int) old_symbol; 
	status = VRStorage((char *) &dummy, VRFlowDirOldSymbol, NULL, 1);



/*-----------------------------
#5. Set flow direction in CorId. (Always in cp #0 of the correction).
-----------------------------*/
__DBGpr_int("New FlowDirection", (int) NewFlowDir);

    	attr.Iwant = VRCorrection_FlowDirection;
	attr.FlowDirection = NewFlowDir; 

    	status = om$send ( msg = message VRCorrection.GRputattr
                                            ( &retcode, (IGRchar *) &attr),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );

/*-----------------------------
# 3-98 KDD.  
# DIRTY update of the dependent components.
*----------------------------*/

    	status = om$send ( msg = message VRCorrection.VRSetFlow ( &retcode,
					NULL, NULL, &me->ModuleInfo),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );


/*-----------------------------
#5.1 Update the sys collection of me->LocatedObject, with new flow direction.
*----------------------------*/
        status = om$send( msg      = message VRGeneric.VRGetPrivateParams
					     (&retcode, &SysParId, NULL, NULL),
                          targetid = me->LocatedObject.objid,
			  targetos = me->LocatedObject.osnum );
 
        strcpy (Attr.name, VR_N_FLOW_DIR_IN),
        Attr.desc.type = AC_ATTRIB_DOUBLE;
        Attr.desc.value.att_exp = (double) NewFlowDir;
 
        status = om$send( msg     = message ACrg_collect.ACmod_list_attribute
                                           ( &retcode, 1, &Attr ),
                         targetid = SysParId.objid,
                         targetos = SysParId.osnum);


/*-----------------------------
#6. Propagate the new flow direction from CorId (both cp 0 & 1)  
*----------------------------*/
	ConnectPoint = (IGRshort) 0; 
	status = om$send ( msg = message VRCorrection.VRPropagateFlow
			 	(&retcode, &CorId, &NewFlowDir, NULL, 
				 &ConnectPoint, NULL, &me->ModuleInfo),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );

	ConnectPoint = (IGRshort) 1; 
	status = om$send ( msg = message VRCorrection.VRPropagateFlow
			 	(&retcode, &CorId, &NewFlowDir, NULL, 
				 &ConnectPoint, NULL, &me->ModuleInfo),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );

        nd$exec_batch (mode = 0);

/*-----------------------------
#6.1. Reset the UpdateFlag so that we don't recreate FlowArrowSymbol constantly.
*----------------------------*/
        UpdateFlag = 0; 
        status = VRCorrection_VRFlArSym( SetUpdateFlag, &UpdateFlag);

/*
#7. return
*/
	if ( 1) goto quit1; 
}


quit1:

End
  goto quit;
}/* end VRReverseFlowDir */

/******************************************************************************/

action VRGetNextCpt( IGRint *sts, Single )
{
  IGRlong	retcode;
  BSrc		bsretcode;

  dp$erase_hilite(msg	= &retcode);

	/*----  Reset Propagate Correction(s).  ----*/

  me->NumPropagateCorr = 0;
  me->PropagateCorr[0].objid = NULL_OBJID;
  me->PropagateCorr[1].objid = NULL_OBJID;


  if( !Single && me->NbCpts == 2 && me->CurCpt >= 0 )
  {
    me->ret = FIN;
    return OM_S_SUCCESS;
  }

  while(TRUE)
  {
	IGRdouble	dConDir[3];
	struct GRid	CorId;

	if( ++me->CurCpt >= me->NbCpts )
	{
		me->ret = FIN;
		return OM_S_SUCCESS;
	}

	status =
	om$send( msg      = message VRGeneric.VRGetCptGeom
			 	( &retcode, me->CurCpt, NULL,
				dConDir, NULL, &me->ModuleInfo ),
		targetid = me->LocatedObject.objid,
		targetos = me->LocatedObject.osnum );

	status =
	om$send( msg      = message VRGeneric.VRGetCorOnCpt
				(&retcode, me->CurCpt, &CorId, &me->ModuleInfo),
		targetid = me->LocatedObject.objid,
		targetos = me->LocatedObject.osnum );

	if( 	BSlenvec( &bsretcode, dConDir ) > VRGetTol(VR_DIST_TOL) &&
		CorId.objid != NULL_OBJID ) break;
  }

  /*"CurCpt = %d\n", me->CurCpt */

  goto quit;
}/* end VRGetNextCpt */

/* 
 * Method to display/erase the flow direction on the Corrections. 
 * When the nDisplayFlowDir is TRUE, then display the flow direcitons in all
 * the Corrections stored in the array. If its FALSE, erase the flow directions
 * on the Correction list. CR179901347 Alwin
 */

action VRDisplayFlowDirection( IGRlong *sts; IGRboolean bDisplayFlowDir )
{
  IGRint	i;
  IGRlong	retcode;

  SetProc( Md VRDisplayFlowDirection ); Begin 

  for( i=0; i<me->NbLocatedObjects; i++ )
  {
      struct GRid	CompId, CorId;

      CompId = me->LocObjects[i];

      status = ASget_as_owner( &CompId, &CorId );
      __DBGpr_obj( " Correction Owner Id ", CorId );

      if( bDisplayFlowDir )
      {
	    IGRint	State;

	    status =
	    om$send( msg      = message VRCorrection.VRget_state (&State),
		    targetid = CorId.objid,
		    targetos = CorId.osnum );

	    if ( !(State & VR_DISP_FLOW) )
	    {
		// 
		// I don't know when this case woudl arise...for time being
		// 'm commenting this. Alwin
		//status=om$send(msg = message VRCorrection.VRGetNumCptOfMyComps
		//		   (&retcode, NULL, NULL, &NumComp3Cpt,
		//		    NULL, NULL, NULL, &me->ModuleInfo),
		//		targetid = CorId.objid,
		//		targetos = CorId.osnum );
		//
		//   if ( NumComp3Cpt != 0 ) 
		//   {
		//     if(Single)UI_status("Component with 3+ connect points.");
		//      continue;
		//   }
		//
 		///

		 struct GRsymbology      Symb;

		 ///-- Force the flow display -- //
		 ///get symbology from the located object //
		 status =
		 om$send( msg = message GRvg.GRgetsymb ( &retcode, &Symb ),
			   targetid = CompId.objid,
			   targetos = CompId.osnum );

		 status =
		 om$send( msg     = message VRCorrection.VRUpdateFlowArrow
				 (&retcode, 0, NULL, &Symb, &me->ModuleInfo),
			   targetid = CorId.objid,
			   targetos = CorId.osnum );
	    }

	    status =
	    om$send( msg     = message NDnode.NDdisplay
				    ( 0, GRbdhd , &me->ModuleInfo ),
		    targetid = CorId.objid,
		    targetos = CorId.osnum );
	    as$status();

	    continue;
      }
      else
      {
	    status =
	    om$send( msg      = message NDnode.NDdisplay
				    ( 0, GRbehe , &me->ModuleInfo ),
		    targetid = CorId.objid,
		    targetos = CorId.osnum );
	    as$status();

	    status =
	    om$send( msg      = message VRCorrection.VRDeleteFlowArrow
				    (&retcode, &me->ModuleInfo),
		    targetid = CorId.objid,
		    targetos = CorId.osnum );
	    nd$exec_batch (mode = 0 );
      }
  }

  End
  goto quit;
}

action VRCleanUp( IGRlong *sts )
{
  IGRint	i;
  IGRlong 	retcode;

  SetProc( Md VRCleanUp ); Begin 

  dp$erase_hilite(msg     = &retcode);

  for( i=0; i<me->NbLocatedObjects; i++ )
  {
      struct GRid       CompId, CorId;

      CompId = me->LocObjects[i];

      status = ASget_as_owner( &CompId, &CorId );
      __DBGpr_obj( " Correction Owner Id ", CorId );

      status =
      om$send( msg      = message NDnode.NDdisplay
			      ( 0, GRbd , &me->ModuleInfo ),
	      targetid = CorId.objid,
	      targetos = CorId.osnum );
      as$status();
  }

  me->NbLocatedObjects = 0;
  _FREE( me->LocObjects );

  End
  goto quit;
}
