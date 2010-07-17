/* $Id: VRHvFrPl.sl,v 1.4 2001/02/20 01:12:23 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRHvFrPl.sl
 *
 * Description:
 *	Place HVAC Inline Component command file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRHvFrPl.sl,v $
 *	Revision 1.4  2001/02/20 01:12:23  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.3  2001/02/15 15:24:07  build
 *	Corrected debug related errors.
 *	
 *	Revision 1.2  2001/01/11 22:46:27  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/05/11  14:53:04  pinnacle
# Replaced: route/vrco/VRHvFrPl.sl for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/10  15:04:04  pinnacle
# initial revision
#
# Revision 1.2  1999/04/18  08:52:16  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.7  1998/04/01  18:44:28  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by lawaddel for route
#
# Revision 1.6  1998/01/14  20:09:36  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by lawaddel for route
#
# Revision 1.4  1997/12/05  20:58:22  pinnacle
# Replaced: vrco/VRHvFrPl.sl for: AXFAN crash in 02.04.03.04 by aharihar for route
#
# Revision 1.3  1997/12/02  21:52:28  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by lawaddel for route
#
# Revision 1.2  1997/09/10  16:09:48  pinnacle
# Replaced: vrco/VRHvFrPl.sl for: TR 179700927 by aharihar for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/08/20  09:10:06  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by ashankar for route
#
# Revision 1.13  1996/06/24  12:06:40  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by ashankar for route240
#
# Revision 1.12  1996/05/13  14:58:24  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by ashankar for route240
#
# Revision 1.11  1996/05/01  23:37:56  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by ashankar for route240
#
# Revision 1.10  1996/04/24  18:24:20  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by ashankar for route240
#
# Revision 1.9  1996/03/18  10:25:40  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by ashankar for route240
#
# Revision 1.8  1996/03/05  22:15:06  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by hverstee for route240
#
# Revision 1.7  1996/03/04  18:15:04  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by hverstee for route240
#
# Revision 1.6  1996/01/18  23:29:00  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by r240_int for route240
#
# Revision 1.5  1996/01/16  21:16:54  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by r240_int for route240
#
# Revision 1.4  1995/12/08  21:19:42  pinnacle
# Replaced: vrco/VRHvFrPl.sl for:  by r240_int for route240
#
 *
 * History:
 *	10/23/92	K.B.	creation
 *	10-28-94  	Lori	Update to add spec to HVAC
 *	10-31-95  	Sundar	Replaced Status with VStatus during Port.
 *      11-31-95  	yzhu	add VRset_messages method.
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	01/17/96	tlb	Use VDfld_set_list_text
 *	09/09/97	Anand	TR 179700927 (update collection in
 *				form_notification (for HSHAPE))
 *      11/25/97        law     CR179603118 Activate place raceway component,
 *                              also fixed "additional para" execute,accept.
 *	12/06/97	Anand	Modified VRCheckSelCrit - for getting catalog
 *				occurences list on the catalog-form properly
 *      01/13/98        Alwin   Overridden filter(). for TR179702522, etc
 *                              Made slight corrections to set SHAPE CODE
 *                              Correctly, when we Get Information from the
 *                              existing component using Replace Params icon.
 *
 *      01/13/98        law     CR179700399 - Link equiv diameter-width/depth
 *      04/01/98        law     NoTR-modified codelist for fixed length buffer
 *      04/18/99        Alwin   Modified the VRLoadForm and form_notification
 *				methods to implement the Raceway Multi Tier
 *				enhancements.
 *	May 9 2k	Anand	Removed FIg_erase calls to Corner Radius related
 *				fields for all Raceway forms - TR 179901473
 *************************************************************************/

command_string		VRC_M_HvFreePl, 0 , VRHvFrPl
synonym			VRC_M_PpFreePl, 1 , VRPpFrPl
synonym			VRC_M_RwFreePl, 2 , VRRwFrPl
class			VRHvFrPl
super_class		VRCmpMgr
/* product_name		"$SPXR" */
product_name		"$ROUTE"
command_table		"route.cmd"
start_state		start

status_display "VRConnectCmp","-1","-1"
form "VRUserParam", 0, 0,"-1", "-1"
form "VRCatSelect", 1, 0,"-1", "-1"
form "VRSearchParams", 2, 0,"-1", "-1"
specification

#include "FI.h"
#include "VRRwDimen.h" //added by alwin Rway Enhancement

instance

{
	Form			FormPtr;
	Form			FormUser;
	Form			FormCatalog;
	Form			FormSearch;
	struct 	GRid		SearchId;
	struct  VRRwCptDetails  RwCptData[10];
}

implementation

#include <stdio.h>
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VRDbParamDef.h"
#include "vrparameters.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRchgattrdef.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRMcForm.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "vrdbgmacros.h"
#include "VRPid.h"
#include "acrepdef.h"
#include "VRdbcodlst.h"
#include "VRmsg.h"
#include "VDmacdef.h"
#include "vdsmacros.h"

#include "vrpdu_pto.h"
#include "vrtools_pto.h"
#include "vrco_pto.h"
#include "vrinit_pto.h"

#include "VRRwDimen.h" //added by alwin Rway Enhancement

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define AS_DEBUG
*/
#define VR_OPTCODE_LIST_NUM 400
#define	MAIN			1
#define	DYNCOMP			10

extern GRclassid      OPP_VRPComp_class_id, OPP_VRPCComp_class_id,
                      OPP_VRHComp_class_id, OPP_VRHCComp_class_id,
                      OPP_VRRComp_class_id, OPP_VRRCComp_class_id;


from	GRgraphics	import	GRdelete,
				GRdisplay;
from 	GRgencs		import	GRgetmatrix;
from	ACrg_collect	import	ACget_named_attribute,
				AClist_attribute;
from	ACncpx		import	ACgive_structure;
from    VRGeneric	import	VRGetInstance,
				VRGetParams;			
from    NDnode		import	NDcopy;
from 	ACdiowner	import	ACrem_attribute;

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "VRsketchdef.h"
#include "VRDbStruct.h"

#define	DYNCOMP			10

state *
on  EX_DATA.GRst_PERPEND_FROM                        state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        state HaveError
on  EX_DATA.GRst_PERPEND_TO                          state HaveError
on  EX_DATA.GRst_ANGLE_TO                            state HaveError

/* ======================================================================== */

state start

	on ELSE	do VRInitInstance(&me->ret)
		do VRDefaultPocketMenu (&me->ret)	
		do VRLoadForm(&me->ret)			state GET_ATTR

/* ======================================================================== */

state GET_REF

	prompt_key		VR_P_IdentRefOrPoint
        execute 		VRset_messages
/*        message_key		VR_M_HvFreePl */
	dynamics		off
	locate_eligible		"+GRgencs"
/* Extra `+' added to enable locating base coordinate system - Anand */
	locate_owner         	"LC_RIGID_OWNER | LC_FLEX_COMP"
   	filter                  locate


   on EX_DATA		do VRGetRef(&me->ret)
			do VRRotateComponent (&me->ret)		state start

   on EX_RJT_MOVEON						state GET_POINT

   on EX_BACK_UP						state -

   on EX_STRING or EX_CHAR					state . 

   on EX_RESTART						state . 

   on EX_FORM_FINISHED						state .

/* ======================================================================== */

state GET_POINT

	prompt_key		VR_P_EnterInsertPoint
        execute 		VRset_messages
/*        message_key		VR_M_HvFreePl */
	dynamics		DYNCOMP
   	filter                  get_event


   on EX_DATA		do VRGetPoint(&me->ret)		
			do VRRotateComponent(&me->ret)		state start

   on EX_RJT_MOVEON						state .

   on EX_BACK_UP						state -

   on EX_STRING or EX_CHAR					state . 

   on EX_FORM_FINISHED						state .

   on EX_RESTART						state . 

/* ======================================================================== */

state GET_ATTR

        execute 		VRset_messages
/*        message_key		VR_M_HvFreePl */
	prompt_key 		VR_P_ChgPar
	filter			wfi

	on EX_FORM_FINISHED
			do VREvaluateComp (&me->ret)	
		on RETURN_CODE = VR_NOT_VALID		
			do VRResetForm(&me->ret)	state start
		on RETURN_CODE = VR_ADDED_PARAM		
			do VRUpdateForm (&me->ret)	state .			
			do VRResetForm(	&me->ret)	state GET_REF

	on EX_RESTART	do VRResetForm(	&me->ret)	state LOC_CMP


	on  EX_STRING or EX_CHAR 
			do VRGetAABBCCCode (&me->ret)	
		on RETURN_CODE = MSFAIL
			do status_key  VR_S_InvalidAABBCCcode	state .
			do VRLoadForm(&me->ret)			state .
				
	on EX_RESET	state .

/* ======================================================================== */

state LOC_CMP

/*	message_key		VR_M_CPDParamComp */
        message                 "Copy Design Parameters from Component"
	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
        locate_eligible         "VRPComp, VRPCComp, VRHComp, VRHCComp, VRRComp, VRRCComp"
	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
	dynamics		off
	filter			locate

	on EX_BACK_UP 						state -

	on EX_DATA	do VRCopyComponentAttr (&me->ret)	
			do VRLoadForm(&me->ret)			state -

	on EX_FORM_FINISHED					state .

	on  EX_RJT_MOVEON or EX_RESET				state -	

   	on EX_RESTART						state . 

/* ======================================================================== */

state HaveError
   
	status_key		VR_S_InvDataType

	on ELSE							state -

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method init ( 26-03-1992 )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action init
{
  IGRlong	retmsg;
  IGRchar	*FormName;
  IGRint	i, j;
  IGRshort	listsize, *code_num;
  IGRchar 	*speclist, *codelist;
  IGRdouble	*npdlist;
  IGRchar 	Cnpdlist[VR_MAX_NPDLIST_SIZE][10];
  /* Below added for CR179700399 - link diameter/width/radius */
  IGRchar	szText[20]; 

  extern int    	COB_FI_form_notification();
  extern int    	COB_FI_initial_form_notification();

  /*| call VDB_LOCATE.init with respect to message */
  status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VDB_LOCATE.init( type, str_ptr ),
			targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated) return (status);

  /*| call VRinit_products to load the macro object spaces */
  status = VRinit_products();
  as$status( action = RET_STATUS );

  switch( type )
  {
	case 0:	me->Product = VR_HVAC;
		FormName = "VRHVCmDsPara";
	break;

    	case 1:	me->Product = VR_PIPING;
		FormName = "VRPpCmDsPara";
    	break;

	case 2:	me->Product = VR_RWAY;
		FormName = "VRRwCmDsPara";
	break;

	default: return OM_E_ABORT;
  }

  FIf_new ( 0, FormName, COB_FI_form_notification,&me->FormPtr);
  FIf_set_cmd_oid_os( me->FormPtr, my_id, OM_Gw_current_OS );

  FIf_set_initial_notification_routine ( me->FormPtr, 
					    COB_FI_initial_form_notification);

  /*| Init form pointers */
  me->FormUser     = me->forms[0].form_ptr;
  me->FormCatalog  = me->forms[1].form_ptr;
  me->FormSearch   = me->forms[2].form_ptr;

  if( me->Product != VR_PIPING )	
  {
        /* Below added for CR179700399 - link diameter/width/radius */
        FIg_get_text ( me->FormPtr, HSHAPE, szText);

	if( me->Product != VR_HVAC && !strncmp(szText,"Corner R",8) )
        {
          /* Below added for CR179700399 - link diameter/width/radius */
	  FIg_display(me->FormPtr, RCORNRAD);
	  FIg_display(me->FormPtr, RCORNRAD_LBL);
	  return OM_S_SUCCESS;
        }
        if(!strncmp(szText,"Corner R",8))
        {
          FIg_display(me->FormPtr, HCORNER_RAD);
          FIg_display(me->FormPtr, HCORNER_RAD_LBL);
        }
        else
        {
          FIg_erase(me->FormPtr, HCORNER_RAD);
          FIg_erase(me->FormPtr, HCORNER_RAD_LBL);
        }
  	
	status = VRget_spec_list (&retmsg, VR_HVAC, &listsize , &speclist , NULL); 
  	if( status & 1 )
  	{
  		FIfld_set_list_num_rows( me->FormPtr, HVMC, 0, listsize );
  		for(i=0,j=0;j<listsize;j++)
  		{
       			if (speclist [i])
       			{
         			VDfld_set_list_text( me->FormPtr, HVMC, j, 0, &speclist[i], FALSE);
         			i += VR_MAX_SPEC_NAME_LEN;
       			}
  		}	
  	}
	return OM_S_SUCCESS;
  }
  /*| -- Get Spec Name List and initialize form -- */
  status = VRget_spec_list (&retmsg, VR_PIPING, &listsize , &speclist , NULL); 
  if( status & 1 )
  {
  	FIfld_set_list_num_rows( me->FormPtr, PPMC, 0, listsize );
  	for(i=0,j=0;;i++)
  	{
  		if (j == listsize )	break;
       		if (speclist [i])
       		{
         		VDfld_set_list_text( me->FormPtr, PPMC, j, 0, &speclist[i], FALSE);
         		i += strlen (&speclist[i]) - 1;
         		j++;
       		}
  	}
  }
  status = 
  VRget_npd_list (&retmsg, VR_PIPING, "NOZZLE",  &listsize , &npdlist, NULL);
  if ( status & 1 )
  {
        for( i = 0; i<listsize; i++)    sprintf(Cnpdlist[i], "%g", npdlist[i]);

 	FIfld_set_list_num_rows( me->FormPtr, PDIA_NOM, 0,listsize );
  	FIfld_set_list_num_rows( me->FormPtr, PDIA_RED, 0,listsize );
	for(i=0; i<listsize; i++)
  	{        	
		VDfld_set_list_text( me->FormPtr, PDIA_NOM, i, 0, Cnpdlist[i], FALSE);
		VDfld_set_list_text( me->FormPtr, PDIA_RED, i, 0, Cnpdlist[i], FALSE);
  	}
  }
  /*| -- Get Tracing Type List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, VR_PIPING, VR_P_TRACE_TYPE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
/******** law-modified fixed length buffer **********/
  if( status & 1 )
  {
        FIfld_set_list_num_rows( me->FormPtr, PHEAT_TRAC, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
                        VDfld_set_list_text( me->FormPtr, PHEAT_TRAC, j, 0,
                                             &codelist[i], FALSE);
                        j++ ;
                }
        }
  }
  
  /*| -- Get Constarined Status List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, VR_PIPING, VR_P_CONST_STS_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
  if( status & 1 )
  {
/******** law-modified fixed length buffer **********/
        FIfld_set_list_num_rows( me->FormPtr, PCONST_STS, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (codelist [i])
                {
                        VDfld_set_list_text( me->FormPtr, PCONST_STS, j, 0,
                                             &codelist[i], FALSE);
                        j++ ;
                }
        }

  }
  return OM_S_SUCCESS;


}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method status_disp

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action status_disp
{
  /*| call status_disp method with respect to message */

	status =
	om$send (mode     = OM_e_wrt_message,
		 msg      = message super_cmd.status_disp(),
		 targetid = my_id);
	as$status( action = RET_STATUS );

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

}/* end status_disp */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method VRCheckSelCrit

	This method verifies that the component is selectable in the
	database.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
   
action VRCheckSelCrit
{
  IGRlong		retmsg, msg;
  IGRshort		nType, nTopo, NbOcc;
  IGRint		i, j, nShape, NbParam;
  IGRchar		szText[20], szSearch[20], szFamilyName[10], szSpecName[10];
  IGRchar		Error[300];
  IGRchar		Catalog[20];
  struct ACrg_coll 	attributes[VR_MAX_ATTR], Attribute;
  IGRchar		**OccLst;
/* OccLst is now a double pointer to char. Its address is passed to
   VRdbGetHvCatOccList so that the list is returned intact. - Anand */

  SetProc( VRCheckSelCrit ); Begin

  if( me->Product != VR_HVAC )	return OM_S_SUCCESS;

  /*" Code =<%s>\n",me->CmpAABBCCcode*/
  /*" Opti =<%d>\n",me->CmpOption*/ 
  /*" szNu =<%s>\n",me->CmpNumber*/
  /*" Note =<%s>\n",me->CmpNotes*/ 

  me->SearchId.objid = NULL_OBJID;
  me->SearchId.osnum = me->ModuleEnv.md_id.osnum;
 
  FIg_erase( me->FormPtr, 67 );
  FIg_erase( me->FormPtr, 68 );

  FIg_get_text ( me->FormPtr, HSHAPE, szText);
  VRGetShapeCode ( szText, &nShape );
  /*"Shape =<%d>\n",nShape*/

  szFamilyName[0] = '\0';
  Error[0]	= '\0';
  Catalog[0]	= '\0';
  OccLst	= NULL;
  NbOcc		= 0;


  strcpy( Attribute.name, VR_N_CLASS_AN );
  
  status = 
    om$send( msg = message ACrg_collect.ACget_named_attribute( &msg, 
							      &Attribute),
	    senderid = NULL_OBJID,
	    targetid = me->SysParamId.objid,
	    targetos = me->SysParamId.osnum );
  as$status( );
  if ( (msg&1) && (status&1) )
    strcpy( szSpecName, Attribute.desc.value.att_txt );
  else
    strcpy( szSpecName, "SERV1" );


  /*| --- Acces DB to get the needed parameters --- */ 
  status = VRaccess_hvac_db( &retmsg, szSpecName, me->CmpAABBCCcode, 
				nShape, szFamilyName, &nTopo, &nType,
				&me->SearchId, NULL, NULL, Error );

  if( !(status&1) || Error[0] != '\0')
  {
	status = ex$message( field   = ERROR_FIELD,
		    	     msgnumb = retmsg);
	me->ret = VRNOT_OK;
	strcpy( Error, "No such component in Data Base" );
	status = FIg_set_text( me->FormPtr, FI_MSG_FIELD, Error);

	return OM_S_SUCCESS;
  }
  else  if( me->SearchId.objid != NULL_OBJID )
  {
	/* --- Get Catalog Name and remove it from the collection --- */
  	strcpy( Attribute.name, VR_N_CATAL_NAME_AN );

  	status = 
  	om$send( msg = message ACrg_collect.ACget_named_attribute( &msg, 
								   &Attribute),
	   	 senderid = NULL_OBJID,
	   	 targetid = me->SearchId.objid,
	   	 targetos = me->SearchId.osnum );
  	as$status( );
	if ( msg&1 )
		strcpy( Catalog, Attribute.desc.value.att_txt );
	else
		return OM_S_SUCCESS;

	status =
	om$send( msg      = message ACdiowner.ACrem_attribute( &retmsg, 
							       Attribute.name),
		 senderid = me->SearchId.objid,
                 targetid = me->SearchId.objid,
                 targetos = me->SearchId.osnum);
	as$status( action = RET_STATUS ) ;

	status = VR$ModifyCollection( p_msg                   = &retmsg,
                                      Operation               = VR_MERGE_COLL,
				      p_InputCollectionId     = &me->SysParamId,
                                      p_OutputCollectionId    = &me->SearchId );
  }

  /*| --- Get catalog occurrences list --- */
  status = VRdbGetHvCatOccList ( &retmsg, Catalog, &OccLst, &NbOcc, Error );
 
  if( OccLst )
  {
        for( i=0 ; i < NbOcc ; ++i )
        {
                if( OccLst[i] )
		    { __DBGpr_str(" Contents", OccLst[i] ); }
                else
		    { __DBGpr_com(" Occ list not allocated "); }
        }
  }
  __DBGpr_int("NbOcc",NbOcc);
  __DBGpr_int("retmsg",retmsg);
  __DBGpr_str("Catalog",Catalog);
 
  if ( NbOcc )
  {
	FIg_reset( me->FormCatalog, 12 );
	FIg_display ( me->FormPtr, 67 );
	FIg_set_text ( me->FormCatalog, 15, Catalog );
        for(i=0;i<NbOcc;i++)
        {
                if ( OccLst[i][0] !='\0' )
                {
                  FIfld_set_text( me->FormCatalog, 12, i, 0, OccLst[i], FALSE);
                  __DBGpr_str(" Occlsst",OccLst[i]);
                }
        }
        VdsRisFreeBuffer( OccLst, NbOcc );
  }

  /*| --- See if macro name in collection --- */
  strcpy( Attribute.name, VR_N_MACRO_NAME_AN );

  status = 
  om$send( msg = message ACrg_collect.ACget_named_attribute( &msg, &Attribute),
	   senderid = NULL_OBJID,
	   targetid = me->SearchId.objid,
	   targetos = me->SearchId.osnum );
  as$status( );
	
  if( msg )	return OM_S_SUCCESS;

  /* --- We ghave a search criteria -- */
  if( retmsg&1 && me->SearchId.objid != NULL_OBJID )
  {
	FIg_display ( me->FormPtr, 68 );
	szSearch[0] = '/';
	szSearch[1] = '\0';

	status =
	om$send( msg      = message ACrg_collect.AClist_attribute( &retmsg,
					   VR_MAX_ATTR, attributes, &NbParam ),
		 senderid = me->SearchId.objid,
                 targetid = me->SearchId.objid,
                 targetos = me->SearchId.osnum) ;
  	as$status( action = RET_STATUS ) ;

	/*  ---- Build Search criteria string --- */
        /** ---- Presently restricting Search string displayed to 1 param 
                 because of problems with string overflow.  ----  ***/
/**   SHANKAR
	for( i=0; i<NbParam; i++ )
	{
**/
	if( NbParam )
		strcat( szSearch, attributes[0].name );
/**   SHANKAR
		strcat( szSearch,"/" );
	}
**/

	status = FIg_set_text( me->FormPtr, FI_MSG_FIELD, szSearch );
  }

  return OM_S_SUCCESS;

}/* end VRCheckSelCrit */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRGetRef
{
  IGRlong       msg;
  struct  GRid  RefId;

  /* ----- Get located referencial  ----- */
  RefId = me->event1.located_object[0].located_obj;

  status = dp$erase_hilite ( msg   = &msg,
                             osnum = me->ModuleEnv.md_id.osnum);

  /*| -- Take matrix from the located component that will be replaced -- */
  if( RefId.objid != NULL_OBJID )
  {
        status =
        om$send( msg      = message GRgencs.GRgetmatrix( &msg, me->CmpMatrix ),
                 targetid = RefId.objid,
                 targetos = RefId.osnum );
        if( ! ( status & 1 & msg ) )
        {
                me->ret = VRNOT_OK;
        }
  }

  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRGetPoint
{
  IGRchar	CsType[MAX_CS_TYPE];
  struct GRid	CsId;

  /* ----- Get located point ----- */
  VRskget_active_cs( NULL, &CsId, me->CmpMatrix, CsType );

  me->CmpMatrix[3]  = me->event1.event.button.x;
  me->CmpMatrix[7]  = me->event1.event.button.y;
  me->CmpMatrix[11] = me->event1.event.button.z;

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method form_notification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
   
action form_notification
{
IGRlong			msg;
IGRint			NbParamInList, sel_flag, r_pos;
IGRint			VStatus, Value;
IGRshort		ret_flag;
IGRchar			szText [30], err_msg[100];
IGRchar			CodeText[20];
IGRchar			szActivePocketMenuName[300];
struct	ACrg_coll	Collection;
struct ret_struct	ParamAttr;
IGRint 			FootIndex = -1, retstatus;
struct	EXFI_data_st	FormDataArray [2];
struct	GRid		ParamList;
  extern int FIg_set_state_off();
  extern int FIg_set_state_on();
extern int strncmp();

  SetProc( Md form_notification ); Begin

  if( !form_ptr )
  {
    __DBGpr_com( " Invalid form pointer " );
    End
    return OM_S_SUCCESS;
  }

  /*| -- If dynamic search message don't remove it --- */
  FIg_get_text( form_ptr, FI_MSG_FIELD, err_msg );
  if( err_msg[0] != '/' )	strcpy( err_msg, "" );

  FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
	
  szActivePocketMenuName[0] = 0;

  if( form_ptr == me->status_display_form_ptr )
  {
	/*| status display */

  	switch( gadget_label )
    	{

		case FI_CANCEL:
        		FIf_erase( form_ptr );
		 	return OM_S_SUCCESS;

		case P_REDUCER_BUTTON :
			strcpy( szActivePocketMenuName, PREDUCERPKTMNU );
			break;

		case VALVE_BUTTON :
			strcpy( szActivePocketMenuName, PVALVEPKTMNU );
		 	break;

		case ENDPIPE_BUTTON :
			strcpy( szActivePocketMenuName, PPIPEENDSPKTMNU );
		 	break;

		case P_ELBOW_BUTTON :
			strcpy( szActivePocketMenuName, PELBOWPKTMNU );
		 	break;

		case P_TEE_BUTTON :
			strcpy( szActivePocketMenuName, PTEEPKTMNU );
		 	break;

		case FLANGE_BUTTON :
			strcpy( szActivePocketMenuName, PFLANGEPKTMNU );
		 	break;

		case SPECIALITY:
			strcpy( szActivePocketMenuName, PSPECIALPKTMNU );
			break;

		case INSTRUMENT:
			strcpy( szActivePocketMenuName, PINSTRUPKTMNU);
			break;

		case CONNECTOR:
			strcpy( szActivePocketMenuName, PCONNECPKTMNU);
			break;

		case H_ELBOW_BUTTON :
		case R_ELBOW_BUTTON :
			strcpy( szActivePocketMenuName, HELBOWPKTMNU );
		 	break;

		case H_TEE_BUTTON :
		case R_TEE_BUTTON :
			strcpy( szActivePocketMenuName, HTEEPKTMNU );
		 	break;

		case H_OFFSET_BUTTON:
		case R_OFFSET_BUTTON:
			strcpy( szActivePocketMenuName, HOFFSETPKTMNU );
		 	break;

		case ENDDUCT_BUTTON:
			strcpy( szActivePocketMenuName, HDUCTENDSPKTMNU );
		 	break;

		case H_REDUCER_BUTTON:
		case R_REDUCER_BUTTON:
			strcpy( szActivePocketMenuName, HREDUCERPKTMNU );
		 	break;

		case DEVICE_BUTTON:
			strcpy( szActivePocketMenuName, HDEVICEPKTMNU );
		 	break;

		case TERMINATION:
			strcpy( szActivePocketMenuName, HTDEVICEPKTMNU );
		 	break;

		default : break;

      	}

  	FIbtn_set_auto_pop_up_off( form_ptr, gadget_label );

	if( szActivePocketMenuName )
	{
		VRChangePocketMenu (szActivePocketMenuName);
    		_put_response( resp = EX_POCKET);
	}

  }


  if (form_ptr == me->FormPtr)
  {
 	switch( gadget_label )
    	{
    		case HCODE :
			CodeText[0] = '\0';
			/* -- See if the code has already been defined -- */
			FIg_get_text ( form_ptr, gadget_label, 
					me->CmpAABBCCcode);

			if( me->CmpAABBCCcode[0] != '\0' )
			{
			    status = 
			    om$send ( msg = message VRHvFrPl.VRCheckSelCrit
							( &msg ),
  	    	  	  	  	  targetid = my_id);
			}

                        /* AAAA added by alwin for Raceway Enhancement */
                        if( ( me->Product == VR_RWAY ) &&
                            ( me->CmpAABBCCcode[0] != '\0' ) )
                        {
                           IGRint direct_index, i;
                           IGRchar spec_name[20];
                           struct ret_struct Attr;

                           FIg_get_text ( form_ptr, HSHAPE, szText);
                           VRGetShapeCode ( szText, &Value );

                           Attr.var.text_st.text_string[0] = '\0';
                           status =
                           om$send ( msg = message ACncpx.ACgive_structure
                                ( (int*) &msg, &direct_index, VR_N_CLASS_AN,
                                      &Attr, &me->ModuleInfo ),
                                targetid = me->SysParamId.objid,
                                targetos = me->SysParamId.osnum );
                           as$status();

                           __DBGpr_str( " Vendor name ",
                                        Attr.var.text_st.text_string );

                           strcpy( spec_name, Attr.var.text_st.text_string );

                           /* Get the number of the connect point for the
                           comp_code keyed in. */
                           __DBGpr_com( " Calling the fn VRGetComp_NbCpt ...");
                           status = VRGetComp_NbCpt( &msg, VR_RWAY, Value,
                                                spec_name, me->CmpAABBCCcode,
                                                &me->CmpNbCpts );

                           __DBGpr_int( " Nb. of Connect Pts.", me->CmpNbCpts );

                           if( Value != VR_RECT ) break;

                           FIg_set_text( form_ptr, ACTIVE_CPT_INDEX, "2" );

                           FIg_disable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
                           FIg_disable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );

                           if( me->CmpNbCpts  > 2 )
                           {
                             FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );

                             // assign the Cpt 0 information to all the other
                             // connect points. If the user wants let him
                             //modify as he wishes
                             for( i=2; i<me->CmpNbCpts; i++ )
                             {
                               IGRint j;

                               me->RwCptData[i].width = me->RwCptData[0].width;
                               me->RwCptData[i].depth = me->RwCptData[0].depth;
                               me->RwCptData[i].nb_tier =
                                                      me->RwCptData[0].nb_tier;

                               for( j=0; j<me->RwCptData[i].nb_tier; j++ )
                               {
                                 me->RwCptData[i].tier_sp[j] =
                                                  me->RwCptData[0].tier_sp[j];
                               }
                             }
                           }
                           else if( me->CmpNbCpts < 2 )
                           {
                             FIg_erase( form_ptr, FRM_NO_TIER_2 );
                             FIg_erase( form_ptr, FRM_TIER_SP_2 );
                           }
                           FIg_display( form_ptr, 29 );
                        }
                        /* AAAA added by alwin for Raceway Enhancement */
		break;

                case FRM_WIDTH_1 :
                case FRM_WIDTH_2 :
                case FRM_DEPTH_1 :
                case FRM_DEPTH_2 :
                case FRM_NO_TIER_1 :
                case FRM_NO_TIER_2 :
                case FRM_TIER_SP_1 :
                case FRM_TIER_SP_2 :
                case INCREASE_ACTIVE_CPT_INDEX :
                case DECREASE_ACTIVE_CPT_INDEX :
                {
                    IGRint proc_mode, active_cpt;

                    FIg_get_text ( form_ptr, HSHAPE, szText);
                    VRGetShapeCode ( szText, &Value );

                    __DBGpr_com( " Calling the Fn VRRw_dimen_fields ... " );
                    proc_mode = 1; //for Storing the information in the instance
                    active_cpt = 2;
                    __DBGpr_int( " Nb. of Connect points ", me->CmpNbCpts );
                    status =
                    VRRw_dimen_fields( form_ptr, gadget_label,
                                        NULL, &me->ModuleInfo, me->CmpNbCpts,
                                        &active_cpt, proc_mode, Value,
                                        me->RwCptData, &me->SysParamId );
                }
                break;

    		case HCONST_STS :	
			strcpy ( Collection.name , VR_N_CONSTR_STAT_AN ); 
			Collection.desc.type = AC_ATTRIB_TEXT;
			FIg_get_text ( form_ptr, gadget_label, Collection.desc.value.att_txt);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

		case HVMC :	
		/*| Updating collection material class*/
		strcpy ( Collection.name , VR_N_CLASS_AN ); 
		Collection.desc.type = AC_ATTRIB_TEXT;
		FIg_get_text ( form_ptr, gadget_label, Collection.desc.value.att_txt);
		status = check_spec( &msg, me->Product, 
					Collection.desc.value.att_txt, NULL );
		if( status != OM_S_SUCCESS )
		{
			FIfld_set_text( form_ptr, MESSAGE, 0, 0, 
				"Mat. Class not found in DB", sel_flag );
		}
/*			status = 
			VRUpdateParameterBox(
                                   &msg, &Collection, &me->SysParamId); */
		VR$ModifyCollection(p_msg = &msg,
				    Operation = VR_MERGE_COLL,
				    p_ParamsListToModify = &Collection,
				    NbParamsToModify = 1,
				    p_OutputCollectionId = &me->SysParamId);
		as$status (sts = msg);
		break;


    		case HCMP_NB :
			FIg_get_text ( form_ptr, gadget_label, me->CmpNumber);
		break;

    		case HNOTES :
			FIg_get_text ( form_ptr, gadget_label, me->CmpNotes);
		break;


    		case HMTOFLAG :
		break;

          /* Below modified for CR179700399 - link diameter/width/radius */
    		case RCORNRAD :
			strcpy ( Collection.name , VR_N_CORN_RAD_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
          /* Below modified for CR179700399 - link diameter/width/radius */
			FIg_get_value ( form_ptr, gadget_label,
                                              &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, 
                                                             &me->SysParamId);
			as$status ();
		break;

                /* Below added for CR179700399 - link diameter/width/radius */
                case PDIA_RED :
                        strcpy ( Collection.name , VR_N_RDIAMETER_DB );
                        Collection.desc.type = AC_ATTRIB_DOUBLE;
                        VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL,
                         PPMC, PDIA_NOM, PDIA_RED, 1 );
                        FIg_get_value ( form_ptr, gadget_label,
                                              &Collection.desc.value.att_exp);
                        status =
                        VRUpdateParameterBox( &msg, &Collection, 
                                                             &me->SysParamId);
                        as$status ();
                break;

    		case PDIA_NOM :
			strcpy ( Collection.name , VR_N_GDIAMETER_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL,
			 PPMC, PDIA_NOM, PDIA_RED, 1 );
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;


		case PPID :
			/*| -- Set Pid Scale Factor -- */
			FIg_get_value( form_ptr , PPID, &Collection.desc.value.att_exp);
			strcpy( Collection.name, VR_N_PID_SCALE_DB );
      			Collection.desc.type = AC_ATTRIB_DOUBLE;
			status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

    		case HWIDTH_G :
			strcpy ( Collection.name , VR_N_WIDTH1_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

    		case HDEPTH_G :
			strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

	    	case HWIDTH_R :
			/* KLUDGE: PPMC, HWIDTH_R share the same label */
			if( me->Product != VR_PIPING )
			{
				strcpy ( Collection.name , VR_N_WIDTH2_DB ); 
				Collection.desc.type = AC_ATTRIB_DOUBLE;
				FIg_get_value ( form_ptr, gadget_label, 
						&Collection.desc.value.att_exp);
				status = 
				VRUpdateParameterBox( &msg, &Collection, 
							&me->SysParamId);
				as$status ();
			}
			else
			{
				/*| Updating collection material class*/
				strcpy ( Collection.name , VR_N_CLASS_AN ); 
				Collection.desc.type = AC_ATTRIB_TEXT;
				FIg_get_text ( form_ptr, gadget_label, 
						Collection.desc.value.att_txt);
				status = check_spec( &msg, me->Product, 
					Collection.desc.value.att_txt, NULL );
				if( status != OM_S_SUCCESS )
				{
					FIfld_set_text( form_ptr, MESSAGE, 0, 0,
					"Spec. Name not found in DB", sel_flag );
				}
				VR$ModifyCollection(p_msg = &msg,
				    		Operation = VR_MERGE_COLL,
				    		p_ParamsListToModify = &Collection,
				    		NbParamsToModify = 1,
				    		p_OutputCollectionId = &me->SysParamId);
				as$status (sts = msg);
			}
		break;

    		case HDEPTH_R :
			strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

    		case HLOAD_FROM :
    			me->ret	= VRLOC_CMP;
			_put_response(resp = EX_RESTART);
			FIg_set_state_off (form_ptr, gadget_label);
		break;


		case CATALOG_FORM :
			FIg_set_state_off (form_ptr, gadget_label);
			FIf_display( me->FormCatalog );
		break;

		case SEARCH_FORM :
			FIg_set_state_off (form_ptr, gadget_label);
		  	status = VR$DispCollAttr( pForm	  = me->FormSearch,
					  	  Gadget  = USER_ATTR_FLD,
					  	  pCollId = &me->SearchId);
  			as$status( action = RET_STATUS );
			FIf_display( me->FormSearch );
		break;

    		case FI_RESET :
			FIg_set_state_off (form_ptr, gadget_label);
			status = 
			om$send ( msg      = message VRCmpMgr.VRInitInstance( 0 ),
				  targetid = my_id );
			status = 
			om$send ( msg      = message VRHvFrPl.VRLoadForm( 0 ),
				  targetid = my_id );
		break;

    		case FI_CANCEL :
			FIg_set_state_off (form_ptr, FI_CANCEL);
			FIf_erase( form_ptr );
			_put_response( resp = TERMINATE );
		break;

    		case FI_ACCEPT :
			FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
			FIg_get_text ( form_ptr, HCODE, err_msg );
			if( err_msg[0] == '\0' )
			{
		  		strcpy( err_msg, "ERROR : Component Code is not defined" );
		  		status = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		  		FIg_set_state_off (form_ptr, FI_ACCEPT);
		  		break;
			} 
			if( me->FormPtr )
			{
		 		/*| Erase the displayed form */   
				VStatus = 0;
		    		/* Check whether User Param Form is displayed */
		    		FIf_is_displayed (me->FormUser, &VStatus);
		    		if (VStatus)
				{
					if (me->FormUser) FIf_erase (me->FormUser);
					VStatus = 0;
		    		}
				FIf_is_displayed (me->FormSearch, &VStatus);
				if (VStatus)
				{
					FIg_set_state_off( me->FormPtr, 68 );
					VStatus = 0;
					status = VRBuildUserFromForm( form_ptr, 
								USER_ATTR_FLD, 
						      		&me->SearchId,
								&me->MissParamId );
					as$status();

					status = VRUpdOrAddAttr( &me->SearchId, 
								&me->SysParamId,
								&me->UsrParamId, 
								&me->MissParamId );
					as$status();

					_put_response(resp = EX_FORM_FINISHED);
					FIf_erase(me->FormSearch);
		    		}
				FIf_is_displayed (me->FormCatalog, &VStatus);
				if (VStatus)
				{
					struct	ACrg_coll Collection;
					IGRchar		  Occur[16];
					IGRint		  NbParam;
	
					FIg_set_state_off( me->FormPtr, 67 );

					NbParam = 1;
					FIg_get_text( me->FormCatalog, 12, Occur );
				
					Collection.desc.type = AC_ATTRIB_TEXT;
					strcpy( Collection.name, VR_N_CATAL_OCC_AN );
					strcpy( Collection.desc.value.att_txt, Occur );

					VR$ModifyCollection( 	p_msg		  = &msg,
       				     	     			Operation		  = VR_MERGE_COLL,
	 			     	     			p_ParamsListToModify = &Collection,
				     	     			NbParamsToModify	  = NbParam,
	 			     	     			p_OutputCollectionId = &me->MissParamId );
					_put_response(resp = EX_FORM_FINISHED);
					FIf_erase( me->FormCatalog );
		    		}		
			}
			strcpy ( Collection.name , VR_N_SHAPE_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_text ( me->FormPtr, HSHAPE, szText);
			VRGetShapeCode ( szText, &Value );
			Collection.desc.value.att_exp = (IGRdouble) Value;
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);

                        /* AAAA added by Alwin for Raceway enhancement */
                        if( me->Product == VR_RWAY )
                        {
                           IGRdouble dValue;

                           /* Call this function with the option proc_mode = 2
                           to transfer the information from the instance to
                           the Collector */
                           status = VRRw_dimen_fields( NULL, NULL, NULL,
                                        &me->ModuleInfo, me->CmpNbCpts,
                                        NULL, 2, Value, me->RwCptData,
                                        &me->SysParamId );
                        }
                        /* AAAA added by Alwin for Raceway enhancement */

			_put_response(resp = EX_FORM_FINISHED);
			FIg_set_state_off (form_ptr, FI_ACCEPT);
		break;

	    	case FI_EXECUTE :
			FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		 	FIg_get_text ( form_ptr, HCODE, err_msg );
			if( err_msg[0] == '\0')
			{
		  		strcpy( err_msg, "ERROR : Component Code is not defined" );
		  		status = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		 		FIg_set_state_off (form_ptr, FI_EXECUTE);
		  		break;
			} 
			strcpy ( Collection.name , VR_N_SHAPE_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_text ( me->FormPtr, HSHAPE, szText);
			VRGetShapeCode ( szText, &Value );
			Collection.desc.value.att_exp = (IGRdouble) Value;
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);

                        /* AAAA added by Alwin for Raceway enhancement */
                        if( me->Product == VR_RWAY )
                        {
                           IGRdouble dValue;

                           /* Call this function with the option proc_mode = 2
                           to transfer the information from the instance to
                           the Collector */
                           status = VRRw_dimen_fields( NULL, NULL, NULL,
                                        &me->ModuleInfo, me->CmpNbCpts,
                                        NULL, 2, Value, me->RwCptData,
                                        &me->SysParamId );
                        }
                        /* AAAA added by Alwin for Raceway enhancement */

			_put_response(resp = EX_FORM_FINISHED);
			FIg_set_state_off (form_ptr, FI_EXECUTE);
		break;

	    	case HAIR_FLOW :
		if( me->Product == VR_PIPING )
			FIg_get_text ( form_ptr, gadget_label, me->CmpNotes);
		else
		{
			/*| Updating collection VR_N_FLOW_RATE_DB */
			strcpy ( Collection.name , VR_N_FLOW_RATE_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		}
		break;

	    	case HTHROAT_RAD:
			strcpy ( Collection.name , VR_N_THROAT_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

	    	case HSHAPE:
			strcpy ( Collection.name , VR_N_SHAPE_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_text ( form_ptr, gadget_label, szText);
                        /* Added for CR179603118 */
                        if(!strncmp(szText,"Circular",8))
                        {
                            FIg_disable(form_ptr, HDEPTH_G);
                            FIg_disable(form_ptr, HDEPTH_R);

                            if( me->Product == VR_RWAY )
                            {
                                FIg_disable( form_ptr, FRM_DEPTH_1 );
                                FIg_disable( form_ptr, FRM_DEPTH_2 );
                            }
                        }
                        else
                        {
                            FIg_enable(form_ptr, HDEPTH_G);
                            FIg_enable(form_ptr, HDEPTH_R);

                            if( me->Product == VR_RWAY )
                            {
                                FIg_enable( form_ptr, FRM_DEPTH_1 );
                                FIg_enable( form_ptr, FRM_DEPTH_2 );
                            }
                        }
/* Below added for CR179700399 - Link diameter/width/depth */
                        if(!strncmp(szText,"Corner R",8))
                        {
                            FIg_display(form_ptr, RCORNRAD);
                            FIg_display(form_ptr, RCORNRAD_LBL);
                        }

			VRGetShapeCode ( szText, &Value );
			Collection.desc.value.att_exp = (IGRdouble) Value;
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();

                        /* AAAAA added by alwin for Raceway enhancement */
                        if( Value == VR_RECT )
                        {
                           //display the tier gadget group
                           FIg_display( form_ptr, ACTIVE_CPT_INDEX );
                           FIg_display( form_ptr, ACTIVE_CPT_INDEX_TEXT );
                           FIg_display( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
                           FIg_display( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
                           FIg_display( form_ptr, FRM_NO_TIER_1 );
                           FIg_display( form_ptr, FRM_NO_TIER_2 );
                           FIg_display( form_ptr, FRM_TIER_SP_1 );
                           FIg_display( form_ptr, FRM_TIER_SP_2 );
                           FIg_display( form_ptr, RN_TIER_CMTEXT );
                           FIg_display( form_ptr, RSP_TIER_CMTEXT );
                           FIg_disable( form_ptr, FRM_DEPTH_1 );
                           FIg_disable( form_ptr, FRM_DEPTH_2 );
                        }
                        else
                        {
                           //erase the tier gadget group
                           FIg_erase( form_ptr, ACTIVE_CPT_INDEX );
                           FIg_erase( form_ptr, ACTIVE_CPT_INDEX_TEXT );
                           FIg_erase( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
                           FIg_erase( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
                           FIg_erase( form_ptr, FRM_NO_TIER_1 );
                           FIg_erase( form_ptr, FRM_NO_TIER_2 );
                           FIg_erase( form_ptr, FRM_TIER_SP_1 );
                           FIg_erase( form_ptr, FRM_TIER_SP_2 );
                           FIg_erase( form_ptr, RN_TIER_CMTEXT );
                           FIg_erase( form_ptr, RSP_TIER_CMTEXT );
                        }
                        /* AAAAA added by alwin for Raceway enhancement */

			if (VRCircularTreatment (me->Product, &me->SysParamId, 
						 &me->ModuleEnv))
			{
	    			status = 
				om$send( msg      = message ACncpx.ACgive_structure
				       		 	( &retstatus, &FootIndex, VR_N_DEPTH1_DB,
					 	   	  &ParamAttr, &me->ModuleEnv),
			      		  targetid = me->SysParamId.objid,
			      		  targetos = me->SysParamId.osnum );
	    			as$status( action = RET_STATUS );
	    			FormDataArray [0].label	   = HDEPTH_G;
	    			FormDataArray [0].type	   = FI_DOUBLE;
	    			FormDataArray [0].value.dvalue = ParamAttr.var.root_pm_st.value;

	    			status = 
				om$send( msg      = message ACncpx.ACgive_structure
				       		 	( &retstatus, &FootIndex, VR_N_DEPTH2_DB,
					 	   	  &ParamAttr, &me->ModuleEnv),
			      		  targetid = me->SysParamId.objid,
			      		  targetos = me->SysParamId.osnum );
	    			as$status( action = RET_STATUS );
	    			FormDataArray [1].label	   = HDEPTH_R;
	    			FormDataArray [1].type	   = FI_DOUBLE;
	    			FormDataArray [1].value.dvalue = ParamAttr.var.root_pm_st.value;
		 	}
			CodeText[0] = '\0';
			/* -- See if the code has already been defined -- */
			FIg_get_text ( form_ptr, HCODE, CodeText );

			if( CodeText[0] != '\0' )
			{
				strcpy( me->CmpAABBCCcode, CodeText );
				status = 
  				om$send ( msg      = message VRHvFrPl.VRCheckSelCrit( &msg ),
  	    	  	  	  	  targetid = my_id);
			}
		break;

    		case HTRANS_L:
			strcpy ( Collection.name , VR_N_TRANS_L_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		break;

    		case HLOAD_USER :
			FIf_display( me->FormUser );
			ParamList = me->UsrParamId;
			NbParamInList = 1;
			VRUpgradeUserForm( me->FormUser, NbParamInList, 
					   &ParamList, USER_ATTR_FLD );
		break;

    		case PLOAD_USER :
			FIf_display( me->FormUser );
			ParamList = me->UsrParamId;
			NbParamInList = 1;
			VRUpgradeUserForm( me->FormUser, NbParamInList, 
					   &ParamList, USER_ATTR_FLD );
		break;

    		case POPTION :
		{
			IGRint l_code;
			IGRchar p_error[30];

			strcpy ( Collection.name , VR_N_OPTION_IN ); 
			FIfld_get_text( form_ptr, POPTION, 0, 0, 30,
					(unsigned char *) szText,
					&sel_flag, &r_pos );

			status = vd$get_alias( p_msg = &msg,
						product = PIPING,
						type = VR_OPTCODE_LIST_NUM,
						i_lname = szText,
						o_code = &l_code,
						p_error = p_error );
			if( status != OM_S_SUCCESS )
			{
				Collection.desc.type = AC_ATTRIB_DOUBLE;
			
				if( me->CmpAABBCCcode[0] == '\0' )
				VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, 
					NULL, PPMC, PDIA_NOM,
					 PDIA_RED, POPTION );
				else
				VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, 
					me->CmpAABBCCcode, PPMC, PDIA_NOM,
					 PDIA_RED, POPTION );

				FIg_get_value ( form_ptr, gadget_label, 
					&Collection.desc.value.att_exp);
			}
			else
			{
				Collection.desc.value.att_exp = l_code;
			}

			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		}
		break;


    		default :
		break;
    	}
  } 
  else if( form_ptr == me->FormUser )
  {
    	switch( gadget_label )
	{
    		case FI_CANCEL: 
			FIg_set_state_off( me->FormPtr, HLOAD_USER );
			FIg_set_state_off( me->FormPtr, PLOAD_USER );
			FIg_set_state_off( me->FormUser, FI_CANCEL );
			FIf_erase( form_ptr );
		break;

    		case FI_EXECUTE:
			status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, 
						      &me->UsrParamId, 
						      &me->MissParamId );
			as$status();
/* CR179603118 - execute part placement from main form */	
/*			_put_response(resp = EX_FORM_FINISHED); */
			FIg_set_state_off( me->FormUser, FI_EXECUTE );
		break;

    		case FI_RESET:
			FIg_set_state_off( me->FormUser, FI_RESET );
		break;

   		 case FI_ACCEPT: 
			status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, 
						      &me->UsrParamId, 
						      &me->MissParamId );
			as$status();
			/*| Erase the displayed form */
			status = FIf_erase( form_ptr );
			if ( status == FI_SUCCESS )
	    		{
	    			/*| Set button to off */
	    			FIg_set_state_off( me->FormPtr, HLOAD_USER );
	    			FIg_set_state_off( me->FormPtr, PLOAD_USER );
	    			FIg_set_state_off( me->FormUser, FI_ACCEPT );
			}
			else
	    		{
	    			/*| got bad return from erase_form */
	    			as$status( action = RET_STATUS );
	    		}
/* CR179603118 - accept part placement from main form */	
/*			_put_response(resp = EX_FORM_FINISHED); */

		break;
    	}

  }
  else if ( form_ptr == me->FormCatalog )
  {
    	switch( gadget_label )
	{
    		case FI_CANCEL: 
			FIf_erase( form_ptr );
			FIg_set_state_off( me->FormPtr, 67 );
			FIg_set_state_off( me->FormCatalog, FI_CANCEL);
		break;

		case  FI_ACCEPT:
		{
			struct	ACrg_coll Collection;
			IGRchar		  Occur[30];
			IGRint		  NbParam;

			NbParam = 1;
                        Occur[0] ='\0';

			FIg_get_text( me->FormCatalog, 12, Occur );
			FIg_set_state_off( me->FormCatalog, FI_ACCEPT);
			
			Collection.desc.type = AC_ATTRIB_TEXT;
			strcpy( Collection.name, VR_N_CATAL_OCC_AN );
			strcpy( Collection.desc.value.att_txt, Occur );

			VR$ModifyCollection( p_msg		  = &msg,
       				     	     Operation		  = VR_MERGE_COLL,
	 			     	     p_ParamsListToModify = &Collection,
				     	     NbParamsToModify	  = NbParam,
	 			     	     p_OutputCollectionId = &me->MissParamId );
			strcpy ( Collection.name , VR_N_SHAPE_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_text ( me->FormPtr, HSHAPE, szText);
			VRGetShapeCode ( szText, &Value );
			Collection.desc.value.att_exp = (IGRdouble) Value;
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			_put_response(resp = EX_FORM_FINISHED);
			FIf_erase( form_ptr );
		}
		break;
	}

  }
  else if( form_ptr == me->FormSearch )
  {
    	switch( gadget_label )
	{
    		case FI_CANCEL: 
			FIf_erase( form_ptr );
			FIg_set_state_off( me->FormPtr, 67 );
		break;

		case  FI_ACCEPT:
		{
			FIg_set_state_off( me->FormSearch, FI_ACCEPT);
			status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, 
						      &me->SearchId,&me->MissParamId );
			as$status();
			status = VRUpdOrAddAttr( &me->SearchId, 
						 &me->SysParamId,
						 &me->UsrParamId, 
						 &me->MissParamId );
			as$status();
			strcpy ( Collection.name , VR_N_SHAPE_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			FIg_get_text ( me->FormPtr, HSHAPE, szText);
			VRGetShapeCode ( szText, &Value );
			Collection.desc.value.att_exp = (IGRdouble) Value;
			status = 
			VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			_put_response(resp = EX_FORM_FINISHED);
			FIf_erase( form_ptr );
		}
		break;
	}
  }

  End
  return OM_S_SUCCESS;

}/* end form_notification */

/****************************************************************************/
action delete
{
  IGRlong	msg;

  if (!(me->VDB_terminated))
  {
    FIf_erase ( me->FormPtr );

    if(1&(om$is_objid_valid(objid = me->CmpId.objid,
		            osnum = me->CmpId.osnum)))
    {
	/*| Delete Component */
  	status = om$send (msg = message GRgraphics.GRdelete ( &msg, 
					    &me->ModuleEnv),
		     senderid = my_id,
		     targetid = me->CmpId.objid,
		     targetos = me->CmpId.osnum);
  	as$status ();
    }

    status = om$send ( msg    = message VRHvFrPl.VRDefaultPocketMenu ( &msg ),
		     targetid = my_id);
    as$status (); 
  }

  status = om$send ( mode     = OM_e_wrt_message,
		     msg      = message VDB_LOCATE.delete( f_defer_flag),
		     targetid = my_id);
  as$status();

  return OM_S_SUCCESS;
}

/***************************************************************************/
action VRLoadForm
{
  IGRlong			msg;
  IGRchar			szCode [15];
  IGRchar                       szText [20];
  IGRint 			FootIndex = -1, retstatus, Shape;
  struct 	ret_struct	ParamAttr;
  struct	GRid		SysParamId, UsrParamId;

  SetProc( Md VRLoadForm ); Begin

  __DBGpr_obj( " System Params Id ", me->SysParamId );
  __DBGpr_obj( " User Params Id ", me->UsrParamId );


  if ( me->SysParamId.objid == NULL_OBJID &&  me->UsrParamId.objid == NULL_OBJID )
  {
  	/*| Get active parameters */
  	SysParamId.osnum = me->ModuleEnv.md_id.osnum;
  	VR$active_params( operation 	   = VR_RETRIEVE,
			  mode	  	   = VR_SYSTEM_MODE,
			  VRproduct	   = me->Product,
			  act_param_id	   = &SysParamId,
			  status 	   = status);

  	UsrParamId.osnum = me->ModuleEnv.md_id.osnum;
  	VR$active_params( operation 	   = VR_RETRIEVE,
			  mode	  	   = VR_USER_MODE,
			  VRproduct	   = me->Product,
			  act_param_id	   = &UsrParamId,
			  status	   = status);

  	status = 
  	om$send( msg      = message NDnode.NDcopy( &msg ,0, &me->ModuleEnv,
						   &me->ModuleEnv,
						   &me->SysParamId),
           	senderid = NULL_OBJID,
           	targetid = SysParamId.objid,
           	targetos = SysParamId.osnum  );
  	as$status( );

  	status = 
  	om$send( msg      = message NDnode.NDcopy( &msg ,0, &me->ModuleEnv,
						   &me->ModuleEnv,
						   &me->UsrParamId),
           	senderid = NULL_OBJID,
           	targetid = UsrParamId.objid,
           	targetos = UsrParamId.osnum  );
  	as$status( );
  }

  /*| -- Initialize the component Symbology -- */
  me->Symb.display_attr = me->ActiveDisplay;
  me->Symb.level        = me->ActiveLevel;

  /*| Fill form with parameters */
  if( me->Product == VR_PIPING )
  {
	FIg_set_text( me->FormPtr, PCODE, me->CmpAABBCCcode );
	FIg_set_text( me->FormPtr, PCMP_NB, me->CmpNumber );
	FIg_set_text( me->FormPtr, PNOTES,  me->CmpNotes );
	FIg_set_state( me->FormPtr, PMTOFLAG, FALSE);

	VR$DispCollAttr(pForm 		= me->FormPtr,
			pCollId		= &me->SysParamId,
			Gadget		= PDIA_NOM,
			pAttrName 	= VR_N_GDIAMETER_DB);

	VR$DispCollAttr(pForm		= me->FormPtr,
		    	pCollId		= &me->SysParamId,
		    	Gadget		= PDIA_RED,
		    	pAttrName 	= VR_N_RDIAMETER_DB);

  	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
		    	Gadget		= PPMC,
		    	pAttrName 	= VR_N_CLASS_AN);

	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
			Gadget		= PHEAT_TRAC,
			pAttrName 	= VR_N_TRACING_CODE_AN);

	VR$DispCollAttr(pForm		= me->FormPtr,
		    	pCollId		= &me->SysParamId,
		    	Gadget		= PCONST_STS,
		    	pAttrName 	= VR_N_APPRV_STAT_AN);

  	if ( bVR_IS_PID( me->cRep ) )
  	{
  		VR$DispCollAttr(pForm		= me->FormPtr,
				pCollId		= &me->SysParamId,
		    	  	Gadget		= PPID,
		    	  	pAttrName 	= VR_N_PID_SCALE_DB );		

		FIg_display( me->FormPtr, PPID );
		FIg_display( me->FormPtr, PPID_TXT );
  	}
  	else
  	{
		FIg_erase( me->FormPtr, PPID );
		FIg_erase( me->FormPtr, PPID_TXT );
  	}
  }
  else
  {
	IGRint gadget_label;

	/* --- Erase the buttons that could be still displayed --- */
	FIg_erase( me->FormPtr, 67 );
	FIg_erase( me->FormPtr, 68 );

	strcpy( szCode, "" );
	FIg_set_text( me->FormPtr, HCODE, me->CmpAABBCCcode );
	FIg_set_text( me->FormPtr, HCMP_NB, me->CmpNumber );
	FIg_set_text( me->FormPtr, HNOTES,  me->CmpNotes );
	FIg_set_state( me->FormPtr, HMTOFLAG, FALSE);

  	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
		    	Gadget		= HVMC,
		    	pAttrName 	= VR_N_CLASS_AN);

        gadget_label = HWIDTH_G;
        if( me->Product == VR_RWAY )
            gadget_label = FRM_WIDTH_1;

  	status=
  	VR$DispCollAttr(pForm 	= me->FormPtr,
			pCollId	= &me->SysParamId,
			Gadget	= gadget_label,
			pAttrName 	= VR_N_WIDTH1_DB);

        gadget_label = HDEPTH_G;
        if( me->Product == VR_RWAY )
            gadget_label = FRM_DEPTH_1;

  	status=
  	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
			Gadget		= gadget_label,
			pAttrName 	= VR_N_DEPTH1_DB);

        gadget_label = HWIDTH_R;
        if( me->Product == VR_RWAY )
            gadget_label = FRM_WIDTH_2;

  	status=
  	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
			Gadget		= gadget_label,
			pAttrName 	= VR_N_WIDTH2_DB);

        gadget_label = HDEPTH_R;
        if( me->Product == VR_RWAY )
            gadget_label = FRM_DEPTH_2;

	status=
	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
			Gadget		= gadget_label,
			pAttrName 	= VR_N_DEPTH2_DB);

	status=
	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
		 	Gadget		= HCONST_STS,
			pAttrName 	= VR_N_CONSTR_STAT_AN);

	status=
	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
			Gadget		= HEQUI_DIA,
			pAttrName 	= VR_N_EQUIV_DIA_DB);

	status=
	VR$DispCollAttr(pForm		= me->FormPtr,
		    	pCollId		= &me->SysParamId,
			Gadget		= HTRANS_L,
			pAttrName 	= VR_N_TRANS_L_DB);

	status=
	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
		    	Gadget		= HAIR_FLOW,
		    	pAttrName 	= VR_N_FLOW_RATE_DB);

  	status=
  	VR$DispCollAttr(pForm		= me->FormPtr,
			pCollId		= &me->SysParamId,
		    	Gadget		= HTHROAT_RAD,
		    	pAttrName 	= VR_N_THROAT_DB);
  
 	status = 
  	om$send( msg = message ACncpx.ACgive_structure( &retstatus, &FootIndex,
			       VR_N_SHAPE_IN, &ParamAttr, &me->ModuleEnv ),
		 targetid = me->SysParamId.objid,
		 targetos = me->SysParamId.osnum );
  	Shape = (IGRint) ParamAttr.var.root_pm_st.value;
  	VRGetShapeString ( Shape, szCode );

        /* added by alwin for TR179702485 */
        FIg_set_text( me->FormPtr, HSHAPE, szCode );
        __DBGpr_int( " Shape Code Value from Component ", Shape );
        __DBGpr_str( " Shape Code String ", szCode );


        /* Added for CR179603118 - REMOVED BY ALWIN   */
        /* FIg_get_text(me->FormPtr, HSHAPE, szText); */
        /* if(!strcmp(szText,"Circular"))             */

        if( !strcmp(szCode, HCIRCLESTRING) )
        {
           FIg_disable(me->FormPtr, HDEPTH_G);
           FIg_disable(me->FormPtr, HDEPTH_R);

           if( me->Product == VR_RWAY )
           {
               FIg_disable(me->FormPtr, FRM_DEPTH_1);
               FIg_disable(me->FormPtr, FRM_DEPTH_2);
           }
        }
        else
        {
           FIg_enable(me->FormPtr, HDEPTH_G);
           FIg_enable(me->FormPtr, HDEPTH_R);

           if( me->Product == VR_RWAY )
           {
               FIg_enable(me->FormPtr, FRM_DEPTH_1);
               FIg_enable(me->FormPtr, FRM_DEPTH_2);
           }
        }

        /* AAAAA added by alwin for Raceway Enhacenment ... */

        if( me->Product == VR_RWAY )
        {
            IGRint proc_mode, active_cpt, NbCpts, i;

            /* Fill up the no_tier1 information in the gadget */
            __DBGpr_obj( " System Parameter Id ", me->SysParamId );

            if( me->CmpId.objid == NULL_OBJID )
               NbCpts = 2;
            else
               NbCpts = me->CmpNbCpts;

            if( NbCpts == 2 )
            {
               FIg_disable( me->FormPtr, INCREASE_ACTIVE_CPT_INDEX );
               FIg_disable( me->FormPtr, DECREASE_ACTIVE_CPT_INDEX );
            }
            else if( NbCpts > 2 )
            {
               FIg_enable( me->FormPtr, INCREASE_ACTIVE_CPT_INDEX );
               FIg_disable( me->FormPtr, DECREASE_ACTIVE_CPT_INDEX );
            }

            __DBGpr_com( " Calling the Fn VRRw_dimen_fields ... " );
            proc_mode = 0; // zero for Initialization
            status = VRRw_dimen_fields( NULL, NULL, NULL, &me->ModuleInfo,
                                        NbCpts, NULL, proc_mode, Shape,
                                        me->RwCptData, &me->SysParamId );

            __DBGpr_int( " Nb. of Tier 1 ", me->RwCptData[0].nb_tier );
            __DBGpr_int( " Nb. of Tier 2 ", me->RwCptData[1].nb_tier );
            __DBGpr_dbl( " Width 1 ", me->RwCptData[0].width );
            __DBGpr_dbl( " Width 2 ", me->RwCptData[1].width );
            __DBGpr_dbl( " Depth 1 ", me->RwCptData[0].depth );
            __DBGpr_dbl( " Depth 2 ", me->RwCptData[1].depth );

            proc_mode = 1; // one for Displaying the Instance data
            active_cpt = 2;
            status = VRRw_dimen_fields( me->FormPtr, NULL, NULL,
                                        &me->ModuleInfo,
                                        NbCpts, &active_cpt,
                                        proc_mode, Shape,
                                        me->RwCptData, &me->SysParamId );

            __DBGpr_com( " First Cpt Tier Spacings... " );
            for( i=0; i<me->RwCptData[0].nb_tier; i++ )
              __DBGpr_dbl( " Tier Spacing ", me->RwCptData[0].tier_sp[i] );

            __DBGpr_com( " Second Cpt Tier Spacings... " );
            for( i=0; i<me->RwCptData[0].nb_tier; i++ )
              __DBGpr_dbl( " Tier Spacing ", me->RwCptData[1].tier_sp[i] );

            if( Shape == RECTFLAG )
            {
               IGRint i;

               FIg_disable(me->FormPtr, FRM_DEPTH_1);
               FIg_disable(me->FormPtr, FRM_DEPTH_2);
               FIg_display( me->FormPtr, 29 );
            }
            else FIg_erase( me->FormPtr, 29 );
        }
        /* added by alwin for Raceway Enhacenment ... */
  }
  FIf_display( me->FormPtr );

  End
  return OM_S_SUCCESS;


}

/***************************************************************************/
action VRResetForm
{
  FIg_set_text( me->FormPtr, FI_MSG_FIELD, "");
  FIg_set_text( me->FormPtr, HCODE , "");

  return OM_S_SUCCESS;

}

/**************************************************************************/
action VRUpdateForm
{
  if( me->MissParamId.objid == NULL_OBJID ) return OM_S_SUCCESS;


  status = VR$DispCollAttr(	pForm	= me->FormUser,
				Gadget	= USER_ATTR_FLD,
				pCollId	= &me->MissParamId );
  as$status( action = RET_STATUS );
 
  FIf_display( me->FormUser );

  return	OM_S_SUCCESS;

}

/* ====================================================================	*/

action VRCopyComponentAttr
{
  IGRlong			msg;
  struct	GRid		LocatedComp;
  struct 	GRmd_env	LocatedMdEnv;
  struct	VRGenInfo	Instance;

  status = FIg_set_text( me->FormPtr, FI_MSG_FIELD, "" );
  FIf_erase ( me->FormUser );

  LocatedComp  = me->event1.located_object[0].located_obj;
  LocatedMdEnv = me->event1.located_object[0].module_info;
  /*"LocatedComp = %d /%d\n",LocatedComp.objid,LocatedComp.osnum */

  /* --- Retrieve VRGenInfo and initialise instances --- */ 
  status = 
  om$send( msg      = message VRGeneric.VRGetInstance( &msg, &Instance ),
	   senderid = NULL_OBJID,
	   targetid = LocatedComp.objid,
	   targetos = LocatedComp.osnum );
  as$status();

  strcpy( me->CmpAABBCCcode, Instance.szAABBCC );
  strcpy( me->CmpNumber, Instance.szNumber );
  strcpy( me->CmpNotes, Instance.szNotes );

  me->CmpOption = Instance.nOption;

  status = FIg_set_text( me->FormPtr, HCODE, me->CmpAABBCCcode );
  status = FIg_set_text( me->FormPtr, HCMP_NB, me->CmpNumber );
  status = FIg_set_text( me->FormPtr, HNOTES, me->CmpNotes );

  status = 
  om$send ( msg 	   = message VRGeneric.VRGetParams ( &msg, 
							     &me->SysParamId, 
							     &me->UsrParamId, 
							     &me->MissParamId),
	    targetid = LocatedComp.objid,
	    targetos = LocatedComp.osnum,
	    senderid = my_id );
  as$status( );

  VRprint_user_attr( &me->SysParamId );

  status = dp$erase_hilite ( msg   = &msg,
			     osnum = me->ModuleEnv.md_id.osnum);

return	OM_S_SUCCESS;

}
/* ==================================================================== */

action VRDefaultPocketMenu
{

  /*| Calling VRAddToPocketMenu () */
  /* 
    VRChangePocketMenu (DEFAULTPKTMNU);
    VRAddToPocketMenu ();
   */
  vd$pkt_menu();

return OM_S_SUCCESS;

} /* end action VRDefaultPocketMenu */
/* ==================================================================== */

action dynamics
{
  if ( dynamics == DYNCOMP )
  	VRFollowCursor( &me->CmpId, &me->ActiveDisplay, &me->ModuleInfo);

  return OM_S_SUCCESS;

} /* end method dynamics */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              METHOD: VRset_messages                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*-------------------------------------------------------------------------+mi
 * Private Message set_prompt
 *
 * Abstract
 *     It is called at execute keyword and used to change the message info
 *     according different conditions.
 *
 * Algorithm
 *
 * Status/Return Code
 *     status == OM_S_SUCCESS   if success;
 *
 *------------------------------------------------------------------------mi*/
action VRset_messages
{
  IGRchar       buffer[DI_PATH_MAX];

          if(  me->Product == VR_HVAC){
                /* for HVAC */
                ex$message( msgnumb = VR_M_HvFreePl,
                            buff    = buffer );
          } 
          else if ( me->Product == VR_PIPING) {
                /* for Piping */
                ex$message( msgnumb = VR_M_PpFreePl,
                            buff    = buffer );
          } 
          else  {
                /* for Raceway */
                ex$message( msgnumb = VR_M_RwFreePl,
                            buff    = buffer );
          } 

          status =
          om$send(msg      = message CEO.msg( buffer ),
                  targetid = my_id );
          as$status( action = RET_STATUS );

          *sts = OM_S_SUCCESS;
          goto quit;

} /* end VRset_prompt */


/* This Method will allow the user to locate (only) the object based on the
product selected (Piping/HVAC/Rway). Previously there was no filter, as a
result, from the Place Piping Component Command (Replace Params) we were able
to select HVAC components. This method just sets the proper locate filter.
Added by alwin for TRs 179702522, 179702482 & 179702489 */

action filter
{
   SetProc( Md Filter ) ; Begin

   /* The following check  is made to skip the changing of filter, otherwise
   we won't be able to select the Co-ordinate system */


   if( me->CmpId.objid == NULL_OBJID )
   {
     if ( filter == 3 )   /* it's a locate filter */
     {
        __DBGpr_com( " It's locate filter " );

        if( me->locate_eligible_thing.w_count ) /* Classids have been defined */
        {
          IGRchar       ClassName[30];
          IGRint        i=0, sts=0;

          /* Number of Classids in the classlist */
          OMuword       *pcount = &me->locate_eligible_thing.w_count;

          /* Override the Predefined values */

          me->locate_eligible_thing.w_count = 0;

          if( me->Product == VR_PIPING )
          {
                me->locate_eligible_thing.p_classes[*pcount] =
                                                         OPP_VRPComp_class_id;
                ++me->locate_eligible_thing.w_count;

                me->locate_eligible_thing.p_classes[*pcount] =
                                                         OPP_VRPCComp_class_id;
                ++me->locate_eligible_thing.w_count;
          }
          else if( me->Product == VR_HVAC )
          {
                me->locate_eligible_thing.p_classes[*pcount] =
                                                        OPP_VRHComp_class_id;
                ++me->locate_eligible_thing.w_count;

                me->locate_eligible_thing.p_classes[*pcount] =
                                                        OPP_VRHCComp_class_id;
                ++me->locate_eligible_thing.w_count;
          }
          else
          {
                me->locate_eligible_thing.p_classes[*pcount] =
                                                        OPP_VRRComp_class_id;
                ++me->locate_eligible_thing.w_count;

                me->locate_eligible_thing.p_classes[*pcount] =
                                                        OPP_VRRCComp_class_id;
                ++me->locate_eligible_thing.w_count;
          }
        }
     }
   }

   __DBGpr_com( "Out of local filter" );
   status = om$send( msg = message CEO_LOCATE.filter( filter,
                                               response, response_data),
                       mode = OM_e_wrt_message,
                       targetid = my_id );
   __CheckRC( status, 1, "CEO filter failed", quit ) ;

   End
   return status;
}
