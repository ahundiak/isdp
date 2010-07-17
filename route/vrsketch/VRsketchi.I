/* $Id: VRsketchi.I,v 1.5 2002/05/30 20:00:48 louis Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrsketch/VRsketchi.I
 *
 * Description:
 *  This file contains the method-implementations for the commands : 
		Piping  sketch : VRSkPipeLine,0,VRSkPp
 *	        HVAC    sketch : VRSkDuctLine,1,VRSkDcLn
 *		Raceway sketch : VRSkRaceway,2,VRSkRw
 *
 *  Some of the methods implemented in this file are:
 *
 *                    ==> init 
				   : is overridden to initialize the 
 *				     instance data particulary the product 
 *				     and locate filter eligible class.
 *                    ==> wakeup
 *                                 : is overridden to update sketch form gadgets
 *                    ==> delete
 *                                 : is overridden to terminate correctly the 
 *					current network.
 *                    ==> sleep
			 	   : is overridden to erase sketch form 
				    and undisplay construct point way 
 *				    if neccessary
 *                    ==> dynamics
 *                                 : is overridden to call funtion of 
 *					product the right dynamic function.
 *                    ==> form_notification
 *                                 : is overridden to ( gerer ) the sketch form.
 *                                 (SEE vrsketch/VRskformnotify.I)
 *		      ==> VRSkSetRetCode
 *                                 : set my_ret instance data
 *			==> VRSkFormBottonOff
 *                                 : set to off all sketch form gadgets
 *			==> VRSkPopupLocate
 *                                 : set to off sketch form locate gadget
 *			==> VRSkPopupSkewed
 *                                 : set to off sketch form skewed gadget
 * Dependencies:
 *
 * Log History:
 *	$Log: VRsketchi.I,v $
 *	Revision 1.5  2002/05/30 20:00:48  louis
 *	Modified the livelookup switch to avoid a database query
 *	
 *	Revision 1.4  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:25  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:30  anand
 *	SP merge
 *	
# Revision 1.2  2000/11/28  22:02:34  pinnacle
# Replaced: route/vrsketch/VRsketchi.I for:  by lawaddel for Service Pack
#
# Revision 1.1  2000/05/10  14:51:06  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.1  2000/03/20  06:34:58  pinnacle
# Created: vrsketch/VRsketchi.I by aharihar for route
#
 *
 * History:
 *      10/31/90 	momo	Rewrite date
 *	08/19/94	MM	Modification done to form notification
 *					due to addition of RW_T_SHAPE.
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *				Fix FIfld_set_value call
 *      Feb/06/97       Alwin   Modified form_notification to add 
 *                              cases HV_THROAT_RADIUS and HV_TRAN_LENGTH
 *                              for CR#179603184
 *      May/23/97       Alwin   Modification done to form_notification.
 *                              For providing different option codes for
 *                              pipes. CR#179300978
 *      May/30/97       Alwin   Modified state N_C, for TR179700865.
 *      Oct/10/97       Onay    Update line seq number to 14 char long
 *      Nov/07/97       law     CR179308634 - Livelookup of parts from db.
 *      Dec/30/97       Anand   No T.R - VRPlvlkfrm pops up even when the
 *                              piping_spec_eq table does not exist. Replaced
 *                              vdb$RisSelect by VdsVerifyRisTable in
 *                              action status_disp
 *      Jan/12/98       law     CR179701945- throat radius field
 *      Jan/12/98       law     CR179309874- New raceway shapes
 *      Jan/21/97       Anand   No T.R - Redefined the criteria to kick off LLP.
 *                              piping_spec_eq table need not exist anymore.
 *      Mar/06/98       law     TR179600988-Prevent sketch from wrong nozzle end
 *      May/18/98       law     CR179801061-Add width/depth computation
 *      25-Jul-1998     LAW     Added tiers for raceway - CR179801144
 *      March/1999      Reddy   TR179900116 - npd list was not being populated
 *                              properly for diameter field.
 *      Apr/19/99       law     CR179900491 - Variable tier spacing
 *      May/20/99       Reddy   CR179900491 - Shape coordination of the gadgets 
 *				for diff. shapes is being done ...
 *      May/28/99       Alwin   CR179900491 - Modified to support Shape 
 *				transition components. Added two instance 
 *				variables.
 *      July/29/99       Alwin  TR179900758 - Deleted the Sketch form from 
 *				the memory
 *      Sep/Oct 99	Anand   For TR 179900778, CR 179900060 and CR 179900837
 *      09/19/99        LAW     TR17900780/781- rway cleanup
 *      10/2/99         law     TR17900780&tr179900932-more cleanup
 *	1/3/2000	LAW	Minor cleanup delivered with TR179900934
 *      1/04/00         law     TR179801414 - CONRED sizes incorrect
 *      01/25/00        law     tr179900976 - transition failures
 *      Feb 2000	Anand   Split VRsketch.sl into .t, .S and .I
 *      			Removed form_notification from VRsketchi.I and
 *      			created VRskformnotify.I
 *      			Added Live lookup functionality for Raceways
 *      			(vide CR 179801143)
 *      11/27/00        law     TR-MP4140  - prevent crash on bad option code
 *      04/08/02        law     TR5649-standardize tolerance with VRGetTol
 *      05/30/02        law     no-TR Reddesign of 'on' switch to avoid
 *                              database query.
 *
 ***********************************************************************/

class implementation VRsketch;


#include <stdio.h>
#include <math.h>
#include <string.h>
#include "OMlimits.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "exdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "VRdef.h"
#include "VRact_params.h"
#include "VRattr_index.h"
#include "VRparamdef.h"
#include "VRMath.h"
#include "dpdef.h"
#include "VRco.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "FI.h"
#include "nddef.h"
#include "VRsketchdef.h"
#include "VRchgattrdef.h"
#include "ACattrib.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "VRPid.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "VRDbStruct.h"
#include "VRMcForm.h"
#include "VDDfEntCode.h"
#include "VDSutil.h"
#include "AS_status.h"
#include "vrinit_pto.h"
#include "vrtools_pto.h"
#include "vrpdu_pto.h"
#include "vrsketch_pto.h"
#include "bsdotp.h"
#include "VRPDBmac.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"

/* The header files below included by Anand */
#include "VDDbDef.h"
#include "vrdbgmacros.h"
#include "VRPDBdef.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"
#include "VRlivlkup.h"
#include "VDmem.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define DYN		1
#define DYNTEE		2
#define AS_DEBUG	1
#define NOT_VALID       100
#define VR_OPTCODE_LIST_NUM  400
#define VR_MANAGE_TAG	2
#define PIPING_OPTION 50

#define	VR_LINE_NUM	0
#define	VR_TAG_NUM	1

/* Redefined Raceway Depth gadget label in order to
   maintain consistency with other forms - Reddy */

#define	RW_DEPTH		718  
#define	RW_WIDTH		720  
#define	SMALL_RW_DEPTH		719  
#define	SMALL_RW_WIDTH		721  
#define	SMALL_RW_DEPTH_TXT	35  
#define	SMALL_RW_WIDTH_TXT	34  


%safe
static X_SketchFormPosition 	= 0;
static Y_SketchFormPosition 	= 0;
static ScreenSketchFormNumber	= 0;
%endsafe

from	ACncpx	import	ACgive_structure;
/* from	VRRComp	import	ACgive_structure;  CR179801144 */
from    ACrg_collect import  ACget_named_attribute;
from	VRGeneric import VRGetMatrix;

/**********************************************************/


#define _main 0
#define _init_start 1
#define _start 2
#define _N_P 3
#define _ADD_MISS_PARAM 4
#define _SWD_ANG 5
#define _SWD_LEN 6
#define _N_C 7
#define _LOC_CMP 8
#define _GET_PARAMS 9
#define _ADD_PARAM 10
#define _MX_ORI 11
#define _REVERSE_HV_CMP 12
#define _REVERSE_PP_CMP 13
#define _PP_ORI_CMP 14
#define _HV_ORI_CMP 15
#define _PL_CMP 16
#define _GET_DATA 17
#define _have_error 18

method VRskformon ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   FIf_display (me->form_ptr);
   goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRskformoff ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   FIf_erase (me->form_ptr);
   goto quit;
quit:
  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

  IGRlong 		msg;
  IGRint		fi_status;
      IGRchar optcode_text[20];
      IGRchar pathname[OM_K_MAXOSNAME_LEN];
      struct GRid ExpressionId;

  extern int    	COB_FI_form_notification();
  extern int    	COB_FI_initial_form_notification();

  extern GRclassid OPP_VRPComp_class_id;
  extern GRclassid OPP_VRPNozz_class_id;
  extern GRclassid OPP_VRPCComp_class_id;
  extern GRclassid OPP_VRHComp_class_id;
  extern GRclassid OPP_VRHNozz_class_id;
  extern GRclassid OPP_VRHCComp_class_id;
  extern GRclassid OPP_VRRComp_class_id;
  extern GRclassid OPP_VRRNozz_class_id;
  extern GRclassid OPP_VRRCComp_class_id;

  me->ret = MSSUCC;
__DBGpr_com("*****************Came thru init*********************");

  /*| call VDB_LOCATE.init method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.init( type, str_ptr ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated) return (status);

  /*| call VRinit_products to load the macro object spaces */
  status = VRinit_products();
  as$status( action = RET_STATUS );

  me->locate_eligible_thing.w_count = 3;
  me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  om$vla_set_dimension( varray = me->eligible_classids,
                        size   = me->locate_eligible_thing.w_count );


  fi_status = FI_SUCCESS;

  me->form_ptr = NULL;
  /* Added for CR179308634 - Livelookup of parts in db */
  me->first_entry = TRUE; /* needed for status display livelookup */
  me->new_live = TRUE; /* Bring up the livelookup form */
  me->proc_livelook = FALSE;

  switch( type )
  {
    case 0 : me->Product = VR_PIPING;
	     me->form_name = "VRPipSkParams";
             me->eligible_classids[0] = OPP_VRPComp_class_id;
             me->eligible_classids[1] = OPP_VRPNozz_class_id;
             me->eligible_classids[2] = OPP_VRPCComp_class_id;
             /* Added for CR179308634 - Livelookup of parts from database */
             /* Intended to reset the opt-code to 1 for start of sketch mode */
             strcpy(optcode_text,"1"); 
             /* Get the Current Working Directory */
             status = di$pwd( dirname = pathname );
 
             /* Change to the HOME directory */
             status = di$cd( dirname = DIR_G_home_name );
 
             /* Get the ExpressionId if it is already created
                              in the Directory Subsystem */
             status = di$translate(objname = "piping_option_code",
                                   p_objid = &ExpressionId.objid,
                                   p_osnum = &ExpressionId.osnum );
 
             if( status != DIR_S_SUCCESS )
             {
                ExpressionId.osnum = me->ModuleEnv.md_id.osnum;
                status = exp$create (exp_name   = "piping_option_code",
                                     exp_syntax = optcode_text,
                                     osnum      = ExpressionId.osnum,
                                     p_exp_id   = &ExpressionId.objid,
                                     p_osnum    = &ExpressionId.osnum,
                                     type_rq    = EXP_TEXT );
             }
             else
             {

             status = exp$modify ( exp_id = ExpressionId.objid,
                                   osnum  = ExpressionId.osnum,
                                   exp_syntax = optcode_text );
             }
 
             /* Re-Setting it to the PWD directory  */
             status = di$cd( dirname = pathname );
             UI_status( "Processing ..." );
 
             break;
    case 1 : me->Product = VR_HVAC;
	     me->form_name = "VRHVSkParams";
             me->eligible_classids[0] = OPP_VRHComp_class_id;
             me->eligible_classids[1] = OPP_VRHNozz_class_id;
             me->eligible_classids[2] = OPP_VRHCComp_class_id;
             /* Below added for CR179309874 - new RW shapes */  
             me->depth_sav = -1.; /* CR179801061 */
             me->width_sav = -1.; /* CR179801061 */
             me->shape_gadget = HV_R_SHAPE;
             break;
    case 2 : me->Product = VR_RWAY;
	     me->form_name = "VRRwaySkParams";
             me->eligible_classids[0] = OPP_VRRComp_class_id;
             me->eligible_classids[1] = OPP_VRRNozz_class_id;
             me->eligible_classids[2] = OPP_VRRCComp_class_id;
             /* Below added for CR179309874 - new RW shapes */  
             me->shape_gadget = RW_R_SHAPE;
             break;
    default: return OM_E_ABORT;
  }

  /*" me->form_name = %s \n", me->form_name */

  FIf_new ( MAIN, me->form_name, COB_FI_form_notification,&me->form_ptr);
  FIf_set_cmd_oid_os( me->form_ptr, my_id, OM_Gw_current_OS );

  /*| Set Form Configuration */
  
  /*"X_SketchFormPosition = %d\n", X_SketchFormPosition */
  /*"Y_SketchFormPosition = %d\n", Y_SketchFormPosition */

  if( X_SketchFormPosition && Y_SketchFormPosition )
  	FIf_set_location( me->form_ptr, X_SketchFormPosition, Y_SketchFormPosition );
  if( ScreenSketchFormNumber ) FIf_set_screen( me->form_ptr, ScreenSketchFormNumber );

  /*| Update eligible class for locate */
  me->locate_eligible_thing.p_classes = me->eligible_classids;
  me->locate_eligible = &me->locate_eligible_thing;

  FIf_set_initial_notification_routine ( me->form_ptr, 
					     COB_FI_initial_form_notification);
 
  /*| call VRskinit method */
  status = om$send( msg      = message VRsketch.VRskinit( &msg ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );
  FIg_erase  ( me->form_ptr, MAINTAIN_SKEW );
  goto quit;

quit:
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int		  status = OM_S_SUCCESS;

  IGRboolean 		pt_type;    /* TRUE if last segment is the first and  */
  IGRint		i;
  IGRlong		msg;
  IGRdouble		cmp_pt[6];  /* termination points of last segment     */
  IGRshort		listsize;
  IGRdouble		*npdlist;
  IGRchar		*err_ptr;
  IGRchar 		Cnpdlist[VR_MAX_NPDLIST_SIZE][10];

  /*"pos           = %d\n", pos */
  /*"EX_suspend    = %d\n", EX_suspend */
  /*"EX_nonsuspend = %d\n", EX_nonsuspend */


  me->ret = MSSUCC;
  pt_type = FALSE;
  err_ptr = NULL;

  /*| call VDB_LOCATE.wakeup method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.wakeup( pos ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  __DBGpr_com("******************Came thru wakeup ************************");
  if (me->VDB_terminated) goto quit;

  /* Bruno : 1-Dec-92 , Init Pid environment */

  if ( bVR_IS_PID_ACTIVE ) VRInitPid();

  status = VRSkSetFormMode( me->Product, FI_REVIEW );
  as$status();

  if( pos & EX_suspend )
  {
	if(  me->SketchMode == VR_AUTOMATIQUE || me->ListIds[0].objid != NULL_OBJID )
	{
  		status = om$send( msg      = message VRsketch.VRSwapSketchForm
						( me->SketchMode ),
            	  	  	  targetid = my_id );
		as$status();
	}
        FIf_display( me->form_ptr );
  }

  /*| -- Get Nominal Size List and initialize form -- */
  if( me->Product == VR_PIPING ){

	struct ret_struct	ParamAttr;
	IGRint 			FootIndex = -1, retstatus;

  	status = 
  	om$send( msg      = message ACncpx.ACgive_structure( &retstatus, 
							     &FootIndex, 
						       	     VR_N_CLASS_AN,
			     			       	     &ParamAttr, 
							     &me->ModuleInfo),
		 targetid = me->ActParamId.objid,
		 targetos = me->ActParamId.osnum );
  	as$status( action = RET_STATUS );

  	status = VRget_npd_list( &msg, me->Product,
				 ParamAttr.var.text_st.text_string,
				 &listsize , &npdlist, err_ptr);

//        for( i = 0; i<listsize; i++) __DBGpr_dbl( " 2npdList[i]",npdlist[i]);
        /* TR179900116 - sprintf(Cnpdlist[i], "%f", npdlist[i]) was changed
           to sprintf(Cnpdlist[i], "%.3lf", npdlist[i]) */

 	if( status & 1 ){
		for( i = 0; i<listsize; i++)
			sprintf(Cnpdlist[i], "%.3lf", npdlist[i]);
  		FIfld_set_list_num_rows( me->form_ptr, PP_DIAM, 0,listsize );
  		FIfld_set_list_num_rows( me->form_ptr, SMALL_DIAMETER, 0,listsize );
  		for(i=0; i<listsize; i++)
  		{
			FIfld_set_list_text( me->form_ptr, PP_DIAM, i, 0, (unsigned char *) Cnpdlist[i], FALSE);
			FIfld_set_list_text( me->form_ptr, SMALL_DIAMETER, i, 0, (unsigned char *) Cnpdlist[i], FALSE);
  		}
  	}
  }
  else if( me->Product == VR_RWAY ){ /* Added for CR179801144 */
	struct ret_struct	ParamAttr;
	IGRint 			FootIndex = -1, retstatus;
        IGRint		row = 0, col = 0;
        IGRdouble		sp_tier, no_tier;
        if(me->shape_gadget == RW_R_SHAPE)
        {
           FIfld_set_mode(me->form_ptr, RW_DEPTH, 0, FI_REVIEW);
           FIg_display( me->form_ptr, RW_DEPTH );
           /*** Modified for CR179900491 ***/
           FIg_display(me->form_ptr,FRM_TIER_SP_1);
/*           FIg_display(me->form_ptr,FRM_TIER_SP_2);     */
           FIg_display(me->form_ptr,FRM_NO_TIER_1);
/*           FIg_display(me->form_ptr,FRM_NO_TIER_2);     */

           FIg_display (me->form_ptr,N_TIER_SK1_TEXT);
/*           FIg_display (me->form_ptr,N_TIER_SK2_TEXT);  */
           FIg_display (me->form_ptr,SP_TIER_SK1_TEXT);
/*           FIg_display (me->form_ptr,SP_TIER_SK2_TEXT); */
        }
        else
        {
           __DBGpr_com("erasing tiers");
           FIg_erase(me->form_ptr,FRM_TIER_SP_1);
           FIg_erase(me->form_ptr,FRM_TIER_SP_2);
           FIg_erase(me->form_ptr,FRM_NO_TIER_1);
           FIg_erase(me->form_ptr,FRM_NO_TIER_2);

           FIg_erase (me->form_ptr,N_TIER_SK1_TEXT);
           FIg_erase (me->form_ptr,N_TIER_SK2_TEXT);
           FIg_erase (me->form_ptr,SP_TIER_SK1_TEXT);
           FIg_erase (me->form_ptr,SP_TIER_SK2_TEXT);

           FIg_display( me->form_ptr, RW_DEPTH );// Reddy - Shape coordination
           FIg_display( me->form_ptr , RW_D_TXT );

	   if(me->shape_gadget == RW_C_SHAPE)
           {
                // Reddy - Shape coordination of gadgets
                /*  FIfld_set_mode(me->form_ptr, RW_DEPTH, 0, FI_INSERT); */
                FIg_erase( me->form_ptr , RW_DEPTH ) ;
                FIg_erase( me->form_ptr , RW_D_TXT ) ;
           }
           else if( me->shape_gadget == RW_RS_SHAPE) /* tr179900932 cleanup */
           {
                FIfld_set_mode(me->form_ptr, RW_DEPTH, 0, FI_INSERT);
           }
           else
           {
             FIfld_set_mode(me->form_ptr, RW_DEPTH, 0, FI_REVIEW);
           }
           FIg_display( me->form_ptr, RW_DEPTH );
       }
  }
  /* Update component construction */
  me->cmp_const_list.env_info = &me->ModuleInfo;
  me->cmp_const_list.display  = &me->ActiveDisplay;
  me->cmp_const_list.level    = me->ActiveLevel;

  /*"ActLevel = %d\n", me->ActiveLevel */

  /* if we interrupt the sketch command by the move command, we must update  */
  /* prev_pt and first_pt if we are created any segment. we must be carreful */
  /* if we begin the sketch from a dangling and we interrupt imediately this */
  /* command, end points of  last segment (parents of dangling in this case) */
  /* depend of dangling  type ( BEGIN OR END of segment )                    */
  /* me->CmpPosition is 0 if located component is not a dangling             */

  if( me->num_of_seg )
  {
    if( me->CmpFirstType == IS_DANGLING && me->num_of_seg == 1 && me->CmpPosition == BEGIN_OF_SEG )
    {
      pt_type = TRUE;
    }

    if( me->prev_seg_id.objid != NULL_OBJID )
    {
    	status = VRskgetendpt(&msg,pt_type,cmp_pt,&me->prev_seg_id,&me->ModuleInfo);
    	as$status( action = RET_STATUS );
    	as$status( sts = msg, action = RET_STATUS );

    	for( i=0; i< 3; i++ )
    	{
      		me->prev_pt[i]  = cmp_pt[i];
      		me->first_pt[i] = cmp_pt[i+3];
    	}
    }
  }

  if( me->cst_buffer.dis_att )
  {
	dp$display ( 	msg 	= &msg,
			osnum 	= me->ModuleInfo.md_id.osnum,
			mode	= GRhd,
			num_elem = 1,
			buffer	= &me->cst_buffer );
  }

  if( me->way_cst_buffer.dis_att )
  {
	dp$display ( 	msg 	= &msg,
			osnum 	= me->ModuleInfo.md_id.osnum,
			mode	= GRhd,
			num_elem = 1,
			buffer	= &me->way_cst_buffer );
  }

  /* active the current pocket menu if manual mode */
  if( me->ChangePocket ) VRChangePocketMenu( me->PocketMenuName );
  goto quit;
quit:
  return OM_S_SUCCESS;
}

method delete ( int f_defer_flag )
{
  int		  status = OM_S_SUCCESS;


  IGRlong  msg=MSSUCC;

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.delete( f_defer_flag ),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  if (me->VDB_terminated) goto quit;

  status = om$send( msg      = message VRsketch.VRskendline( &msg ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );

  /*| get sketch form configuration */
  FIf_get_location( me->form_ptr, &X_SketchFormPosition, &Y_SketchFormPosition );
  FIf_get_screen( me->form_ptr, &ScreenSketchFormNumber );
  
  /*"X_SketchFormPosition = %d\n", X_SketchFormPosition */
  /*"Y_SketchFormPosition = %d\n", Y_SketchFormPosition */

	/* This line just removes the form display, and it does exists in the memory.
	So the continues usage of this command brings up new form and remains in the
	memory and fills up the form stack. Hence leading to undesirable results like
	blanking out all the forms. Alwin */

  FIf_erase( me->form_ptr );

	/* added this line for TR179900758. Alwin */
	if( me->form_ptr ) FIf_delete( me->form_ptr );

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method sleep ( int pos )
{
  int		  status = OM_S_SUCCESS;


  IGRlong msg=MSSUCC;
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.sleep( pos ),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  if (me->VDB_terminated) goto quit;

  status = VRSkSetFormMode( me->Product, FI_INSERT );
  as$status();

  dp$erase_hilite ( msg   = &msg, osnum = me->ModuleEnv.md_id.osnum);

  if( !me->SketchMode )
  {
	dp$erase_hilite( msg   = &msg,
                         osnum = me->ModuleInfo.md_id.osnum );

  	if( me->ChangePocket )
  	{
		status = om$send( msg      = message VRsketch.VRSkActiveEmsPocket( &msg ),
			  	  targetid = my_id );
  	}
  }

  /*"pos           = %d\n", pos */
  /*"EX_suspend    = %d\n", EX_suspend */
  /*"EX_nonsuspend = %d\n", EX_nonsuspend */

  if( pos & EX_suspend ) FIf_erase( me->form_ptr );
  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSkFormBottonOff ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status = OM_S_SUCCESS;

  switch( me->Product )
  {
    case VR_PIPING  : FIg_set_state_off( me->form_ptr, PP_SKEWED );
		      FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
		      FIg_erase( me->form_ptr, MAINTAIN_SKEW );
                      FIg_set_state_off( me->form_ptr, PP_LOCATE );
                      FIg_set_state_off( me->form_ptr, PP_FITOFIT);
                      break;

    case VR_HVAC    :
    case VR_RWAY : FIg_set_state_off( me->form_ptr, HV_SKEWED );
		      FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
		      FIg_erase( me->form_ptr, MAINTAIN_SKEW );
                      FIg_set_state_off( me->form_ptr, HV_LOCATE );
                      FIg_set_state_off( me->form_ptr, HV_TWIST  );
                      FIg_set_state_off( me->form_ptr, HV_FITOFIT);
                      break;
  }

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSkPopupLocate ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status = OM_S_SUCCESS;

  switch( me->Product )
  {
    case VR_PIPING  : FIg_set_state_off( me->form_ptr, PP_LOCATE );
                      break;

    case VR_HVAC    :
    case VR_RWAY : FIg_set_state_off( me->form_ptr, HV_LOCATE );
                      break;
  }
  me->LocateMode = FALSE;

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSkPopupSkewed ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status = OM_S_SUCCESS;

  switch( me->Product )
  {
    case VR_PIPING  : FIg_set_state_off( me->form_ptr, PP_SKEWED );
		      FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
		      FIg_erase( me->form_ptr, MAINTAIN_SKEW );
                      break;

    case VR_HVAC    :
    case VR_RWAY : FIg_set_state_off( me->form_ptr, HV_SKEWED );
		      FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
		      FIg_erase( me->form_ptr, MAINTAIN_SKEW );
                      break;
  }
  me->orthogonal_sketch = TRUE;
  me->AngleFlag = FALSE;

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRint	action, i;
  IGRlong	retcode;
  IGRdouble 	Origin[3], XAxis[3];
  IGRdouble	ref_matrix[16];
  IGRdouble	*dummy;

  if( me->ChangePocket )
  {
	status = om$send( msg      = message VRsketch.VRSkActiveEmsPocket( &retcode ),
		  	  targetid = my_id );
  }

  if( dynamics == DYNTEE )
  {
	/* -- case we don't have any previous segment. Not finished implemented -- */
   	if ( me->prev_seg_id.objid == NULL_OBJID )
	{
		/*| Begin with placement of a component */
		for( i=0; i<3; i++ )
		{
			me->PrevSegAxis[i] = me->CmpMatrix[i*4];
			me->Cmp_Yaxis[i]   = me->CmpMatrix[(i*4)+1];
		}
	}

	/* -- update the origin of the axis for the dynamic display -- */
        Origin[0] =  me->CmpMatrix[3];
	Origin[1] =  me->CmpMatrix[7];
	Origin[2] =  me->CmpMatrix[11];

	XAxis[0] = me->PrevSegAxis[0] * me->CmpOrientation[0];
	XAxis[1] = me->PrevSegAxis[1] * me->CmpOrientation[0];
	XAxis[2] = me->PrevSegAxis[2] * me->CmpOrientation[0];

    	VRorient ( me->Product, Origin, XAxis, me->Cmp_Yaxis, 
	       	   &me->ActiveDisplay, &me->ModuleInfo
             	 );
  }
  else if( dynamics == DYN )
  {
    	me->ret       = MSSUCC;

	if( me->SketchMode == VR_MANUAL )
  	{
		status = om$send( msg      = message VRsketch.VRSkPartialInitInst( &retcode ),
			          targetid = my_id );
		as$status();
	}

    	me->ZwindowFlag = TRUE;
	if( me->FirstType == IS_NOZZLE )
        {
        status = om$send( msg      = message VRGeneric.VRGetMatrix
          ( &retcode,0,NULL,ref_matrix,&me->FirstLocatedElemMdEnv ),
                  targetid = me->FirstLocatedElemId.objid,
                  targetos = me->FirstLocatedElemId.osnum );
        as$status( action = RET_STATUS );
/*
dummy = &ref_matrix[0];
printf("sketch ref matrix\n");
printf("%f	%f	%f	%f\n",
ref_matrix[0],ref_matrix[1],ref_matrix[2],ref_matrix[3]);
printf("%f	%f	%f	%f\n",
ref_matrix[4],ref_matrix[5],ref_matrix[6],ref_matrix[7]);
printf("%f	%f	%f	%f\n",
ref_matrix[8],ref_matrix[9],ref_matrix[10],ref_matrix[11]);
printf("%f	%f	%f	%f\n",
ref_matrix[12],ref_matrix[13],ref_matrix[14],ref_matrix[15]);
printf("matrix address = %x",dummy);
*/
        }

	if( me->FirstType == IS_PIPE ) 	action = 0;
	else			       	action = 1;
    	switch( me->Product )
    	{
      		case VR_PIPING :  
                /* TR179600988 - prevent dynamics from wrong end of nozzle. */
			VRrblinear
                        ( action, me->prev_pt, me->first_pt, me->Z_Window, me->NbOfImpDirection,
			  me->ImpDirForDyn, me->orthogonal_sketch, &me->ActiveDisplay, 
			  me->Angle, me->AngleFlag,
                          ((me->FirstType==IS_COMP_TO_CONNECT ||
			    me->FirstType==IS_NOZZLE ||
			    me->FirstType==IS_CONC_COMP) ? TRUE : FALSE),
                            me->FirstType,
			    (IGRdouble *) &ref_matrix[0]
		        );
                  	break;

      		case VR_HVAC    :
      		case VR_RWAY : /*| HVAC dynamic */
                /* TR179600988- prevent dynamics from wrong end of nozzle. */
		    VRhvlinear
                    ( action, me->prev_pt, me->first_pt, me->Z_Window, me->NbOfImpDirection,
                    me->ImpDirForDyn, me->section_matrix, me->twist_orient,
                    me->orthogonal_sketch, &me->ActiveDisplay, me->Angle, me->AngleFlag,
                    ((me->FirstType==IS_COMP_TO_CONNECT ||
                      me->FirstType==IS_NOZZLE || 
		      me->FirstType==IS_CONC_COMP) ? TRUE : FALSE),
                      me->FirstType,
	              (IGRdouble *) &ref_matrix[0]);
                        break;

      		default : return OM_E_ABORT;
    	}
  }
  else me->ZwindowFlag = FALSE;

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSkSetRetCode ( IGRshort type )
{
    SetProc( VRSkSetRetCode ); Begin

    switch ( type )
    {
      case 0:
	  me->ret = me->my_ret;
	  break;

      case 1:
	  me->ret = me->Product;
	  break;
    }

    __DBGpr_int("me->ret",me->ret);

    End
    return OM_S_SUCCESS;
}

method status_disp ( )
{
    int		  status = OM_S_SUCCESS;

    /*| call status_disp method with respect to message */

    /* Added for CR179308634 - Livelookup of parts in db */
#define LLP_FLG 299
    IGRlong		msg=MSSUCC;
    int			rows;
    char		**results;
    IGRlong		retcode;
    extern int    	COB_FI_form_notification();
    IGRint		gadget_label;

    SetProc( status_disp ); Begin

    __DBGpr_int("proc_livelook",me->proc_livelook);
    __DBGpr_int("first entry",me->first_entry);
    __DBGpr_int("new live",me->new_live);

    if(me->proc_livelook)
	goto quit;

    if( me->prev_seg_id.objid == NULL_OBJID &&
	me->SketchMode == VR_AUTOMATIQUE )
    {
	me->my_ret = LLP_FLG;
	_put_response( resp = EX_FORM_FINISHED );
	goto quit;
    }
    /*** 05/30/02 - law - redesign of ON switch to avoid Db query ***/
    if(me->Product == VR_PIPING && !bVR_IS_PID_ACTIVE)
    {
IGRint notlvlkup;
IGRshort spec_nbr,row_no,NumComp;
struct ACrg_coll    Attr;
struct VRPDB_comps    *CompPtr=NULL;
        /***** Get the active spec_no *****/
        strcpy(Attr.name, VR_N_CLASS_AN);
        status = om$send(msg = message ACrg_collect.ACget_named_attribute
                                                               ( &msg, &Attr ),
                        senderid = NULL_OBJID,
                        targetid = me->ActParamId.objid,
                        targetos = me->ActParamId.osnum );
        as$status( action = RET_STATUS );
        __DBGpr_str(" Spec nam",Attr.desc.value.att_txt);

        status = VR$PDB_SNUM( p_nam = Attr.desc.value.att_txt,
                                  p_num = &spec_nbr );
        as$status( action = RET_STATUS );
        __DBGpr_int("spec_num from spec_name ",spec_nbr);

        /***** Set the cache for spec no and get the piping comps ****/
        VR$PDB_SET ( p_msg = &msg ,
                                 spec  = spec_nbr);
        status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);

	me->proc_livelook = FALSE;

        /**** Loop through comps to find non-zero fam-code ****/
        notlvlkup = 1;
        for( row_no=0 ; row_no<NumComp && notlvlkup ; row_no++ )
        {
           if(CompPtr[row_no].data.famcode)
           {
             notlvlkup = 0;
           }
        }
        if(!notlvlkup)
	{
	    me->proc_livelook = TRUE;
	    __DBGpr_com(" piping_comps populated, me->proc_livelook is TRUE");

	    if(me->new_live)
	    {
		FIf_new ( 999, "VRPlvlkfrm", COB_FI_form_notification,
			&me->status_display_form_ptr);
		FIf_set_cmd_oid_os( 
			me->status_display_form_ptr, my_id, OM_Gw_current_OS );
		me->new_live = FALSE;
	    }
	    if(me->first_entry)
	    {
		status = VRPlvlkup(me->first_entry,&gadget_label,
			me->status_display_form_ptr,&(me->OB.piping));
		me->first_entry = FALSE;

	    }

	    FIf_display( me->status_display_form_ptr );
	}
    }

    if( me->Product == VR_RWAY )
    {
	VRRacewayLiveLookUp( &msg, me->status_display_form_ptr, 0,
			     &(me->OB.rway), &(me->proc_livelook),
			     &(me->new_live), NULL );

	if( me->proc_livelook )
	{
	    struct ACrg_coll	Attr;

	    FIf_new ( 999, "VRRlvlkfrm", COB_FI_form_notification,
					      &(me->status_display_form_ptr) );
	    FIf_set_cmd_oid_os( me->status_display_form_ptr, my_id,
						OM_Gw_current_OS );
	    me->new_live = FALSE;

	    /* Get the spec num and fill me->OB.rway.VendorNo */

	    strcpy(Attr.name, VR_N_CLASS_AN); 
	    status = om$send(msg = message ACrg_collect.ACget_named_attribute
							       ( &msg, &Attr ),
			senderid = NULL_OBJID,  
			targetid = me->ActParamId.objid,
			targetos = me->ActParamId.osnum );
	    as$status( action = RET_STATUS );
	    __DBGpr_str(" Spec nam",Attr.desc.value.att_txt);

	    status = VR$RDB_SNUM( p_nam = Attr.desc.value.att_txt,
				  p_num = &(me->OB.rway.VendorNo) );
	    as$status( action = RET_STATUS );
	    __DBGpr_int("spec_num from spec_name ",me->OB.rway.VendorNo);

	    FIf_display( me->status_display_form_ptr );
			            
	    VRRacewayLiveLookUp( &msg, me->status_display_form_ptr, 3,
				 &(me->OB.rway), &(me->proc_livelook),
				 &(me->new_live), NULL );
	    				// 3 is gadget id for FI_RESET
			            
	    VRRacewayLiveLookUp( &msg, me->status_display_form_ptr, 12,
				 &(me->OB.rway), &(me->proc_livelook),
				 &(me->new_live), NULL );
	    				// 12 is gadget id for Vendor name
	}
    }

    status = om$send (mode     = OM_e_wrt_message,
	    msg      = message super_cmd.status_disp(),
	    targetid = my_id);
    as$status( action = RET_STATUS );
    /* Added for CR179308634 - Livelookup of parts in db */
    if(me->proc_livelook)
    {
	/* Force the change of state to GET_PARAMS */
	me->my_ret = LLP_FLG;
	FIf_erase(me->form_ptr);

	/* Goto next state */
	_put_response( resp = EX_FORM_FINISHED );
	goto quit;
    }
    else    /*if(!me->proc_livelook)*/
    {
	switch( me->Product )
	{
	  case VR_PIPING:
	      FIg_erase  ( me->status_display_form_ptr, 19 );
	      FIg_erase  ( me->status_display_form_ptr, 28 );
	      FIg_display( me->status_display_form_ptr, 24 );
	      break;

	  case VR_HVAC:
	      FIg_erase  ( me->status_display_form_ptr, 24 );
	      FIg_erase  ( me->status_display_form_ptr, 28 );
	      FIg_display( me->status_display_form_ptr, 19 );
	      break;

	  case VR_RWAY:
	      FIg_erase  ( me->status_display_form_ptr, 19 );
	      FIg_erase  ( me->status_display_form_ptr, 24 );
	      FIg_display( me->status_display_form_ptr, 28 );
	      break;
	}
	FIf_display( me->status_display_form_ptr );
    }

    __DBGpr_int(" my_ret",me->my_ret);
    __DBGpr_int(" proc_livelook",me->proc_livelook);
    __DBGpr_int(" first entry",me->first_entry);
    __DBGpr_int(" new live",me->new_live);

quit:
    End
    return OM_S_SUCCESS;
}

method VRskupdate_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;


  if( me->MissParamId.objid == NULL_OBJID ) return OM_S_SUCCESS;

  status = VR$DispCollAttr(	pForm	= me->forms[0].form_ptr,
				Gadget	= USER_ATTR_FLD,
				pCollId	= &me->MissParamId );
  as$status( action = RET_STATUS );

  FIg_erase( me->forms[0].form_ptr, 16 );
  FIg_display( me->forms[0].form_ptr, 15 );
  FIf_display( me->forms[0].form_ptr );

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSkEraseMissingForm ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status =
  FIf_erase( me->forms[0].form_ptr );

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSwapSketchForm ( IGRshort Mode )
{
  int		  status = OM_S_SUCCESS;

  struct	GRid	*ParamId;
  IGRint		row = 0, col = 0, sel_flag = 0;
  IGRint		i;
  IGRlong		msg;
  IGRshort		listsize;
  IGRdouble		*npdlist;
  IGRchar 		Cnpdlist[VR_MAX_NPDLIST_SIZE][10];
  extern IGRint		VRRwayTraySelector(Form, IGRint, IGRint, struct GRid *);

  SetProc( VRSwapSketchForm ); Begin

  if ( me->Product == VR_PIPING )
  {	/* -- Display scale if Representation active is PID -- */

	if (bVR_IS_PID_ACTIVE)
	{
		FIg_display( me->form_ptr, SK_PID_SCALE );
		FIg_display( me->form_ptr, SK_PID_SCALE_LABEL );
	}
	else
	{
		FIg_erase( me->form_ptr, SK_PID_SCALE );
		FIg_erase( me->form_ptr, SK_PID_SCALE_LABEL );
	}

  }/* end of scale factor */

  if ( me->Product == VR_HVAC )
  {	/* -- Display scale if Representation active is PID -- */

	if (bVR_IS_PID_ACTIVE)
	{
		FIg_display( me->form_ptr, HV_SYMB_SCALE );
		FIg_display( me->form_ptr, HV_SYMB_SCALE_LABEL );
	}
	else
	{
		FIg_erase( me->form_ptr, HV_SYMB_SCALE );
		FIg_erase( me->form_ptr, HV_SYMB_SCALE_LABEL );
	}

  }/* end of scale factor */


  if( Mode == VR_MANUAL )
  {
	/*| Mode is MANUAL */
	ParamId = &me->ListIds[0];
	FIg_erase  ( me->form_ptr, AUTOMATIQUE_GRP );
	FIg_display( me->form_ptr, MANUAL_GRP );
  	switch( me->Product )
  	{
		case VR_PIPING:
			/* -- get the text corresponding to the option code of the comp -- */
                        /*** TR-MP4140 - Expand option-code to 80 chars ***/
			{
			  IGRchar	o_lname[81], p_error[30];
                          /*** TR-MP4140 - o_lname initialized for no-match ***/
                          o_lname[0] = '\0';

  		          status = vd$get_alias (    p_msg	= &msg,
		    			 product	= PIPING,
		    			 type		= VR_OPTCODE_LIST_NUM,
		    			 i_code		= me->CmpOption,
		    			 o_lname	= o_lname,
		    			 p_error	= p_error	);
			  if ( !strlen(o_lname) ) 
			    sprintf(o_lname, "%d", me->CmpOption );
    			  FIfld_set_text( me->form_ptr, OPTION, row, col, o_lname, sel_flag );
			}
		
		case VR_HVAC:
			/*A access the database for comp number */
			if ( bVR_IS_PID_ACTIVE )
			{
			  struct ret_struct	ParamAttr;
			  IGRint 		FootIndex = -1, retstatus;
			  IGRint		IdList[VDS_LIST_OF_IDS];
			  IGRint		gadget_label;

			  /*A get the comp category */
			  retstatus =
			  VRdbGetCompCat( &msg, (IGRshort)VR_PIPING, 
					me->CmpAABBCCcode, &me->CmpCat, 
					&me->CmpBehavior,NULL );
			  as$status();

			  if ( me->CmpBehavior == (int)VR_MANAGE_TAG )
			  {
			  /*C Get system name */
			  status = 
			  om$send( msg      = message ACncpx.ACgive_structure
						   ( &retstatus, 
						     &FootIndex, 
					       	     VR_N_SYST_NAME_AN,
		     			       	     &ParamAttr, 
						     &me->ModuleInfo),
				targetid = me->ActParamId.objid,
				targetos = me->ActParamId.osnum );
			  as$status();

			  /*C get the list of available line Ids */
			  status = 
			  VDGetListOfIDs( ParamAttr.var.text_st.text_string,
				me->CmpCat, IdList );
			  
			  for ( i=0; i<VDS_LIST_OF_IDS; i++ ) {			
			    /*C lock this Id*/
			    status = VDLockSelectedID ( 
				ParamAttr.var.text_st.text_string,
				me->CmpCat, IdList[i] );
			    if ( status&1 ) {
			      /*C place the first one in the list as default*/
			      sprintf(me->CmpNumber, "%05d", IdList[i] );
			      me->PrevTagNum = IdList[i];
			      me->bTagNumUsed = FALSE;
			      break;
			    }
			  }
			  }
			  
			  if ( me->Product == VR_PIPING )
				gadget_label = PP_CMP_NB;
			  else gadget_label = HV_CMP_NB;

    			  FIfld_set_text( me->form_ptr, gadget_label,
					   row, col, me->CmpNumber, sel_flag );
			}/* end PID */
			break;

		case VR_RWAY: /* CR179801144 */

		    /* Below line added for CR 179900991 by Anand */
			VRRwayTraySelector(me->form_ptr, 0, VR_MANUAL, NULL);
		    /* Above line added for CR 179900991 by Anand */

                        me->bIsShapeTransition = FALSE;
                        me->nShapeCode = -1;

                        __DBGpr_str("Calling Fn VRGetShapeFrmCompCode for",
							    me->CmpAABBCCcode);
                        /*** TR179900780-add check for null compcode ***/
                        if( me->CmpAABBCCcode )
                        {
                          /* tr179900985-added product to arguments */
                          IGRint locproduct;
                          locproduct = VR_RWAY;

                        /* function implemented in VRskfunk.I file. This fn
                        returns the given comp_code is a shape_transition comp.
                        or not. If it so, then returns the shape_code value
                        back in the instance variable me->nShapeCode. Alwin */

                          status = VRGetShapeFrmCompCode( me->CmpAABBCCcode,
                                &me->bIsShapeTransition, &me->nShapeCode,
                                locproduct );
                        }
                        if( me->bIsShapeTransition )
                        {
                           __DBGpr_com( " Its a SHAPE TRANSITION COMPONENT " );
                           FIg_erase(me->form_ptr,ACTIVE_CPT_INDEX);
                           FIg_erase(me->form_ptr,ACTIVE_CPT_INDEX_TEXT);
                           FIg_erase(me->form_ptr,DECREASE_ACTIVE_CPT_INDEX);
                           FIg_erase(me->form_ptr,INCREASE_ACTIVE_CPT_INDEX);

                           FIg_erase(me->form_ptr,FRM_TIER_SP_2);
                           FIg_erase(me->form_ptr,FRM_NO_TIER_2);
                           FIg_erase (me->form_ptr,N_TIER_SK2_TEXT);
                           FIg_erase (me->form_ptr,SP_TIER_SK2_TEXT);

                           me->shape_gadget = me->nShapeCode;
                        }
                        else if(me->shape_gadget == RW_R_SHAPE)
	                 /* restore tier data */
                        {
			   FIfld_set_mode(me->form_ptr, SMALL_RW_DEPTH, 0,
                                        FI_REVIEW);
                       __DBGpr_com("VRSwapSketchForm- restore tier data display here");
                        /* Modified for CR179900491 */
                        }
			else
                        {
                           FIfld_set_mode(me->form_ptr, SMALL_RW_DEPTH, 0,
                                        FI_INSERT);
                           FIg_erase(me->form_ptr,FRM_TIER_SP_1);
                           FIg_erase(me->form_ptr,FRM_TIER_SP_2);
                           FIg_erase(me->form_ptr,FRM_NO_TIER_1);
                           FIg_erase(me->form_ptr,FRM_NO_TIER_2);

                           FIg_erase (me->form_ptr,N_TIER_SK1_TEXT);
                           FIg_erase (me->form_ptr,N_TIER_SK2_TEXT);
                           FIg_erase (me->form_ptr,SP_TIER_SK1_TEXT);
                           FIg_erase (me->form_ptr,SP_TIER_SK2_TEXT);

                        }
                        if( me->SketchMode == VR_MANUAL )
	                	FIg_display (me->form_ptr, SMALL_RW_DEPTH);

    		FIfld_set_text( me->form_ptr, RW_CMP_NB, row, col, me->CmpNumber, sel_flag );
		break;
	}
  }
  else
  {
	/* erasing and redisplaying form corrects left-over images */
	/*| Mode is AUTOMATIQUE */
        FIf_erase(me->form_ptr);
	FIg_erase  ( me->form_ptr, MANUAL_GRP );
	FIg_display( me->form_ptr, AUTOMATIQUE_GRP );
        FIf_display(me->form_ptr);
        __DBGpr_com("display AUTOMATIQUE_GRP group");

        /*** Modified for tr179900780 ***/
	ParamId = &(me->ActParamId);

	/* Below lines added by Anand for CR 179900060 and CR 179900837 */
	if( me->Product == VR_HVAC || me->Product == VR_RWAY )
	{
	    struct ACrg_coll	Attr;

	    /* Find shape code */
	    strcpy(Attr.name, VR_N_SHAPE_IN); 
	    status = om$send(msg = message ACrg_collect.ACget_named_attribute
							       ( &msg, &Attr ),
			senderid = NULL_OBJID,  
			targetid = ParamId->objid,
			targetos = ParamId->osnum );
	    as$status( action = RET_STATUS );
	    __DBGpr_int(" Shape code",Attr.desc.value.att_exp);

	    if( Attr.desc.value.att_exp == VR_CORNER )
	    {
		struct ret_struct	ParamAttr;
		IGRint			FootIndex = -1;

		status =
		om$send( msg = message ACncpx.ACgive_structure( ((int *) &msg),
								    &FootIndex,
							      VR_N_CORN_RAD_DB,
								    &ParamAttr,
							      &me->ModuleInfo),
			targetid = me->ActParamId.objid,
			targetos = me->ActParamId.osnum );
		as$status( action = RET_STATUS );

		__DBGpr_dbl("corner radius",ParamAttr.var.root_pm_st.value);
		FIg_set_value( me->form_ptr, CORN_RAD,
					      ParamAttr.var.root_pm_st.value );

		FIg_display( me->form_ptr, CORN_RAD );
		FIg_display( me->form_ptr, CORN_RAD_TXT );
	    }

	    /* Below lines added for CR 179900991 by Anand */
	    if( me->Product == VR_RWAY )
		VRRwayTraySelector(me->form_ptr, 0, VR_AUTOMATIQUE, ParamId);
	    /* Above lines added for CR 179900991 by Anand */
	}
	/* Above lines added by Anand for CR 179900060 and CR 179900837 */

  	/* -- Replace Active parameters -- */
  	me->ActParamId.osnum = me->ModuleInfo.md_id.osnum;
  	status = VR$active_params(	operation    = VR_RETRIEVE,
					VRproduct    = me->Product,
                    	  		act_param_id = &me->ActParamId,
                    	  		status       = status );
  	as$status( action = RET_STATUS );
  }
 
  /*| -- Get Nominal Size List and initialize form -- */
  if( me->Product == VR_PIPING ){
    status =
    VRget_npd_list ( &msg, VR_PIPING, "NOZZLE", &listsize , &npdlist , NULL);
    if( status & 1 )
    {
        __DBGpr_int( " Listsize is " , listsize );
        __DBGpr_com( " After VRget_npd_list");
//        for( i = 0; i<listsize; i++) __DBGpr_dbl("npdlist[i]", npdlist[i]);

        /* TR179900116 - sprintf(Cnpdlist[i], "%f", npdlist[i]) was changed 
            to sprintf(Cnpdlist[i], "%.3lf", npdlist[i]) */

	for( i = 0; i<listsize; i++)	sprintf(Cnpdlist[i], "%.3lf", npdlist[i]);

  	FIfld_set_list_num_rows( me->form_ptr, PP_DIAM, 0,listsize );
  	FIfld_set_list_num_rows( me->form_ptr, SMALL_DIAMETER, 0,listsize );
  	for(i=0; i<listsize; i++)
  	{
		FIfld_set_list_text( me->form_ptr, PP_DIAM, i, 0, (unsigned char *) Cnpdlist[i], FALSE);
		FIfld_set_list_text( me->form_ptr, SMALL_DIAMETER, i, 0, (unsigned char *) Cnpdlist[i], FALSE);
  	}
    } 
  } /* Product == VR_PIPING */
  __DBGpr_com("Call4 for VRSkUpdateForm");
  __DBGpr_str("CmpAABBCCcode",me->CmpAABBCCcode);
  status = VRSkUpdateForm( me->Product, me->form_ptr, &me-> shape_gadget,
			   ParamId, me->CmpAABBCCcode, &me->active_cpt,
			   me->RWcptdata, &me->ModuleInfo, Mode );
  as$status();
  __DBGpr_com("Back from  VRSkUpdateForm");

/*  Reddy - Shape coordination of the gadgets   */
    if(me->Product == VR_RWAY)
    {
        if(me->shape_gadget != RW_R_SHAPE ) {
            FIg_erase( me->form_ptr, ACTIVE_CPT_INDEX_TEXT );
            FIg_erase( me->form_ptr, DECREASE_ACTIVE_CPT_INDEX );
            FIg_erase( me->form_ptr, ACTIVE_CPT_INDEX );
            FIg_erase( me->form_ptr, INCREASE_ACTIVE_CPT_INDEX );
          }
    }

quit:
  End
  return OM_S_SUCCESS;
}

method initial_form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;


#ifdef	MANAGE_IDS

  int		i;

	if( form_ptr == me->form_ptr && bVR_IS_PID_ACTIVE )
        { 
__DBGpr_com("pid is active");
	  if ( gadget_label == LINE_SEQ_NUM )
	  {
		struct ret_struct	ParamAttr;
		IGRint 			FootIndex = -1, retstatus;
		IGRint			IdList[VDS_LIST_OF_IDS];
		IGRchar			LineIdStr[20];
			
		/*C Get system name */
		status = 
		om$send( msg      = message ACncpx.ACgive_structure
					   ( &retstatus, 
					     &FootIndex, 
				       	     VR_N_SYST_NAME_AN,
	     			       	     &ParamAttr, 
					     &me->ModuleInfo),
		targetid = me->ActParamId.objid,
		targetos = me->ActParamId.osnum );

		/*printf( " system name = %s \n", 
			ParamAttr.var.text_st.text_string ); */

		/*C unlock the previous unused id */
		if ( !me->bLineNumUsed && me->PrevLineNum != -1 )
		{
			status =
			VDUnLockID ( ParamAttr.var.text_st.text_string,
				(int)VD_C_PIPES, me->PrevLineNum );
		}/* end of unlock */

		/*C get the list of available line Ids */
		status = 
		VDGetListOfIDs( ParamAttr.var.text_st.text_string,
			(int)VD_C_PIPES, IdList );

		/*C set the associated list */
		for( i=0; i<VDS_LIST_OF_IDS; i++ )
		{
			sprintf( LineIdStr, "%05d", IdList[i] );
			FIfld_set_list_text( form_ptr, gadget_label, 
				i, 0, (unsigned char *) LineIdStr, FALSE);
		}
	  } 
	  else if ( ( (me->Product == VR_HVAC && gadget_label == HV_CMP_NB ) ||
		(me->Product == VR_PIPING && gadget_label == PP_CMP_NB ) )
			  && me->CmpBehavior == (int) VR_MANAGE_TAG )
	  {
		struct ret_struct	ParamAttr;
		IGRint 			FootIndex = -1, retstatus;
		IGRint			IdList[VDS_LIST_OF_IDS];
		IGRchar			LineIdStr[20];
			
		/*C Get system name */
		status = 
		om$send( msg      = message ACncpx.ACgive_structure
					   ( &retstatus, 
					     &FootIndex, 
				       	     VR_N_SYST_NAME_AN,
	     			       	     &ParamAttr, 
					     &me->ModuleInfo),
		targetid = me->ActParamId.objid,
		targetos = me->ActParamId.osnum );
		as$status();

		/*C unlock the previous unused id */
		if ( !me->bTagNumUsed && me->PrevTagNum != -1 )
		{
			status =
			VDUnLockID ( ParamAttr.var.text_st.text_string,
				me->CmpCat, me->PrevTagNum );
		}/* end of unlock */

		/*C get the list of available line Ids */
		status = 
		VDGetListOfIDs( ParamAttr.var.text_st.text_string,
			me->CmpCat, IdList );

		/*C set the associated list */
		for( i=0; i<VDS_LIST_OF_IDS; i++ )
		{
			sprintf( LineIdStr, "%05d", IdList[i] );
			FIfld_set_list_text( form_ptr, gadget_label, 
				i, 0, (unsigned char *) LineIdStr, FALSE);
		}
	  } 
	  else
	  if ( (me->Product == VR_HVAC && gadget_label == HV_CMP_NB ) ||
		(me->Product == VR_PIPING && gadget_label == PP_CMP_NB ) )
	  {
		/*A reset the associated list */
		FIfld_set_list_num_rows( form_ptr, gadget_label, 
				0, 0 );
	  }
          /* May need more work for CR179900491 */
          else if (me->Product == VR_RWAY)
          {
             /* Not supposed to be RWAY PID but may need init anyway */
             __DBGpr_com("Not supposed to be RWAY PID");
          }
          else return OM_S_SUCCESS;
       }
#else
  status = OM_S_SUCCESS;
#endif

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRSkUnLockId ( IGRshort	Mode )
{
  int		  status = OM_S_SUCCESS;


#ifdef	MANAGE_IDS

	struct ret_struct	ParamAttr;
	IGRint 			FootIndex = -1, retstatus;

	if ( ( me->Product == VR_PIPING || me->Product == VR_HVAC ) &&
				bVR_IS_PID_ACTIVE )
	{
		/*C Get system name */
		status = 
		om$send( msg      = message ACncpx.ACgive_structure
				   ( &retstatus, 
				     &FootIndex, 
			       	     VR_N_SYST_NAME_AN,
			       	     &ParamAttr, 
				     &me->ModuleInfo ),
			targetid = me->ActParamId.objid,
			targetos = me->ActParamId.osnum );
		as$status();

		/*C unlock the previous unused id */
		if ( Mode == VR_TAG_NUM && me->PrevTagNum != -1 )
		{
			status =
			VDUnLockID ( ParamAttr.var.text_st.text_string,
				me->CmpCat, me->PrevTagNum );
			as$status();
		} else if ( Mode == VR_LINE_NUM && me->PrevLineNum != -1 )
		{
			status =
			VDUnLockID ( ParamAttr.var.text_st.text_string,
				(int)VD_C_PIPES, me->PrevLineNum );
			as$status();
		}/* end of unlock */
	}
#else
  status = OM_S_SUCCESS;
#endif

  goto quit;
quit:
  return OM_S_SUCCESS;
}

method VRIsPrevSegSkewed ( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

       IGRdouble  tmp_vec[3], plane[3];
       BSrc	  bsretcode;

       BSmkvec(  &bsretcode, tmp_vec, me->prev_pt, me->first_pt );

       BSnorvec( &bsretcode, tmp_vec );

       plane[0] = 1.0;
       plane[1] = 0.0;
       plane[2] = 0.0;

       if( 1 - fabs( BSdotp(&bsretcode,tmp_vec,plane)) <
                                                    VRGetTol(VR_DOTPROD_TOL) )
       {
	   me->ret = VRALL_OK;
	   UI_status( "Prev Segment is already orthogonal !!!!" );
	   return OM_S_SUCCESS;
       }

       plane[0] = 0.0;
       plane[1] = 1.0;
       plane[2] = 0.0;

       if( 1 - fabs( BSdotp(&bsretcode,tmp_vec,plane)) <
                                                   VRGetTol(VR_DOTPROD_TOL) )
       {
	   me->ret = VRALL_OK;
	   UI_status( "Prev Segment is already orthogonal !!!!" );
	   return OM_S_SUCCESS;
       }

       plane[0] = 0.0;
       plane[1] = 0.0;
       plane[2] = 1.0;

       if( 1 - fabs( BSdotp(&bsretcode,tmp_vec,plane)) < VRGetTol(VR_DOTPROD_TOL) )
       {
	   me->ret = VRALL_OK;
	   UI_status( "Prev Segment is already orthogonal !!!!" );
	   return OM_S_SUCCESS;
       }
       
       me->ret  = VRNOT_OK;
       return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

end implementation VRsketch;
