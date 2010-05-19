/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdpdefault/cmd/VDPCmdPMDefi.I
 *
 * Description:
 *      Implementation of the following methods for VDPCmdPMDef :
 *
 * Dependencies:
 *
 * History:
 *
 *      09/26/95        MSM        Creation
 *	09/18/96	msm	   Command not executed if PME is not enabled
 *	10/03/96	msm	   Fixed TR#179603259
 *
 *	Feb 16 '98	SSR	Fixed TR # 179800483
 *  	Aug 07 1998 	SSR    	New Functions for SIR sir_form_notification
 *				VDPqueryModCxId, VDPgetCntxts, VDPgetHulls,
 *				VDPgetCfgItms 
 *	Aug 13  '98	SSR     Replaced gadets nos with #defined constants
 *	Aug 20  98  	SSR     Changed form 
 *	Aug 21  98  	SSR    	Corrrected the sequence of
 *				enabled/disabled gadgets.
 *	Sep 03  98  	SSR     Corrected sequence of gadgets
 * 	Oct 26 98	SSR	Added new case for Showing/Querying subsystem.
 * 	Nov 24 98	SSR	Added new case for Arrangemetn file type 
 * 				CR #179801371
 * 	Dec 07 98	SSR	Initialised a form field showing 
 * 				cfg items in DAD to NULL This avoids core
 * 				dump.
 * 	Dec 28 98	SSR	Changed SIR to AIM in UI_status. TR #
 * 				179802462
 *  	Jan 18 99	SSR	CR#1798002232 To sort the DAD form
 *   				Alphanumerically, added AIMqsort() and swap().
 * 	Apr 29 99	SSR	TR # MP 90 Added FI_get_form_by_name().
 * 	Aug 27 99	SSR	Modifications for Prefix based query for
 * 				contests. form and form notification modified.
 */

class implementation VDPCmdPMDef;
/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDCmdDef.h"
#include "FI.h"

#ifdef ENV5
%safe
#include "FIproto_pub.h"
%endsafe
#endif

#include "FEI.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "PDUstr.h"

#include "VDPDatFrmDf.h"
#include "VDPdef.h"

from ACrg_collect import ACset_list_attribute, ACget_named_attribute;

extern struct PDUrefresh	*refresh;
extern long VDPgetCfgItms ();
extern int VDgetSrError( );
%safe
static char   CfgNameGbl[30];
static struct SRReqDat SRDefDat;
static int    VDnbCfgGbl = 0;
static struct VDPCfgItms *CfgItmGlbl=NULL;
static struct VDPhulls   *HullGlbl = NULL;
static int    nbHull  = 0;
static int    nbCntxt = 0;
static struct VDPCntxt   *CntxtGlbl = NULL;
static char   ModCxId[30];
%endsafe

int		sir_form_notification( );
int VDPsortESWBSnos( struct VDPEswbs *elm1, struct VDPEswbs *elm2 )
{
     return( strcmp( elm1->ESWBS, elm2->ESWBS ));
}

int VDPsortESWBS( struct VDPEswbs *elm1, struct VDPEswbs *elm2 )
{
     return( strcmp( elm1->ESWBS_Desc, elm2->ESWBS_Desc ));
}


/*+me
 ---------------------------------------------------------------------------
  Public Message VDPInitForm

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method VDPInitForm ( long *sts )
{
   IGRlong		status = OM_S_SUCCESS;
   IGRlong		msg;
   OMuword		curOs;
   IGRchar		DirName[DI_PATH_MAX];
   IGRint		diagCtl = 4;
   int			i, nbCfgItm = 0;
   Form			VD_FP1, old_form;

   SetProc( VDCmdPMDef.VDPInitForm ); Begin
   *sts = VD_SUCCESS;
   old_form = NULL;

   if( IsPmeEnabled() == FALSE )
   {
	UI_status("AIM server connection required");
	*sts = VD_ERROR;
	me->state = _terminate;
	return status;
   } 

   if( WhichAim()  == PME ){
   /* Initialise all user input fields to NULL */

   //FIfld_set_text( VD_FP, G_ESWBS_E, 0, 0, "", FALSE );
   FIfld_set_text( VD_FP, G_BWTCTX_E, 0, 0, "", FALSE );
   FIfld_set_text( VD_FP, G_CTX_TYPE_E, 0, 0, "", FALSE );
   FIfld_set_text( VD_FP, G_CTX_SUBTYPE_E, 0, 0, "", FALSE );
   FIfld_set_text( VD_FP, G_CTX_NAME_E, 0, 0, "", FALSE );
   FIg_delete( VD_FP, G_ESWBS_E ); // FOR TR # 179800483
   FIg_delete( VD_FP, G_ESWBS_R );
   FIg_delete( VD_FP, G_ESWBS_DESC_E);
   FIg_delete( VD_FP, G_ESWBS_DESC_R);
   FIg_delete( VD_FP, 26);
   FIg_delete( VD_FP, 29);

   /* Check if the RG_Collector is already created */
   ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */

   status = di$give_pathname(  osnum           = curOs,
                               pathname        = DirName );
   __CheckRC( status, 1,"di$give_pathname", wrapup );
   __DBGpr_str( "Path name", DirName );

   sprintf( me->CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );
   __DBGpr_str( "Collector name", me->CollName );

   me->CollId.objid = NULL_OBJID;

   /* Get the collector Id if it is already created */

   status = VDgetVdCollId ( &msg, me->CollName, TRUE, FALSE, &me->CollId ); 
   CheckRC( status, msg );

   if (!(status & msg & 1) || me->CollId.objid == NULL_OBJID )
   {
        /* Collector does not exist */

	FIg_erase( VD_FP, G_REV_GROUP_LBL );
	FIg_display( VD_FP, G_EDIT_GROUP_LBL );

	/* Query the database for required PME data and fill the form */

	UI_status( "Querying PME database ..." );
	status = _VD_SEND_MY( VDPCmdPMDef.VDPqueryPMData( &msg ) );
	CheckRC( status, msg );

	if( !(status & msg & 1) )
	{
	    UI_status( "Error querying PME database" );
	    me->state = _terminate;
	}
   }
   else
   {
	/* Read the collector and update the form */

	status = _VD_SEND_MY ( VDPCmdPMDef.VDPGetDefaults ( &msg ) );
	CheckRC( status, msg );

	FIg_erase( VD_FP, G_EDIT_GROUP_LBL );
	FIg_display( VD_FP, G_REV_GROUP_LBL );
	FIg_disable(VD_FP, FI_ACCEPT );
   }
} // end if for pme



if( WhichAim() == SIR )
{
  // TR # MP 90
  status = FI_get_form_by_name("VdSrDefDat", &old_form);
  if (status == FI_SUCCESS && old_form != NULL)
  {
    UI_status("Command Already Running");
    me->state = _terminate;
    return OM_S_SUCCESS;
  }

  status = FIf_new ( 1,"VdSrDefDat", sir_form_notification, &VD_FP1);
  VD_FP = VD_FP1;
  if (status == FI_NO_SUCH_FORM )
    printf("\n could not get the form"); 

  if( refresh->act_catalog[0] == '\0'
      || refresh->act_partid[0] == '\0' ||
      refresh->act_revision[0] == '\0' )
  {
    UI_status("File Catalog, Part & Rev not defined");
    FIfld_set_text( VD_FP1, FI_MSG_FIELD,
	0, 0, "File Catalog, Part & Rev not defined",FALSE);
    status = OM_E_ABORT;
    goto wrapup;
  }
  __DBGpr_str( " --->Catalog :", refresh->act_catalog );
  __DBGpr_str( " --->Partnum :", refresh->act_partid );
  __DBGpr_str( " --->Partrev :", refresh->act_revision ); 
  
  status = VDgetDiagCtlPar(&msg, &diagCtl );
  if( !(status&msg&1) ||diagCtl ==-1)
  {
    UI_status ("Design Setup Parameter Not Set ");
    __DBGpr_int(" diagCtl ", diagCtl);
    me->state = _terminate;
    FIf_erase( VD_FP1 );
    goto wrapup;
  }

   /* Check if the RG_Collector is already created */
  ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */

  status = di$give_pathname( osnum = curOs, pathname = DirName );
  __CheckRC( status, 1,"di$give_pathname", wrapup );
  __DBGpr_str( "Path name", DirName );

  sprintf( me->CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
  __DBGpr_str( "Collector name", me->CollName ); 
  
  me->CollId.objid = NULL_OBJID;

   /* Get the collector Id if it is already created */

  
  status = VDgetVdCollId ( &msg, me->CollName, TRUE, FALSE, &me->CollId );
  CheckRC( status, msg ); 
  
  if (!(status & msg & 1) || me->CollId.objid == NULL_OBJID )
  {
    FIg_disable( VD_FP1, G_VEW_CFG_DESC );
    FIg_disable( VD_FP1, G_VEW_HULL_DESC );
    FIg_disable( VD_FP1, G_VEW_CTX_DESC );

        /* Collector does not exist */

        /* Query the database for required PME data and fill the form */
    UI_status( "Querying AIM database ..." );
    status = VDPgetCfgItms( &msg, &nbCfgItm, &CfgItmGlbl );
    CheckRC( status, msg );
    
    if( !(status & msg & 1) )
    {
      UI_status( "Error querying AIM database" );
      me->state = _terminate;
    }
    __DBGpr_int( " no of cfg items ", nbCfgItm); // SSR dec2
   
    VDnbCfgGbl = nbCfgItm;
    if(nbCfgItm == 0)
    {
      UI_status( "No Configuration Items in AIM");
      me->state = _terminate;
    }

    FIf_display ( VD_FP1 );	// SSR 3 Dec
    
    /* TR no 984 DIsable is D S P = ON */
    if(diagCtl == 1)
      FIg_disable( VD_FP1, G_TG_FILE_TYP );

    // Dec 4 SSR added foll to avoid unstable form
    FIfld_set_text( VD_FP1, G_SEL_CFG_ITM, 0, 0, "", FALSE );
    
    FIg_erase(VD_FP1,G_VEW_GRP );
    UI_status ( "");
    FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0,
	"Select Configuration Item", FALSE );
    __DBGpr_com( " displayed and erased gadget sets ");
    FIg_display( VD_FP1, G_SEL_GRP );

    for ( i = 0; i < nbCfgItm; i++ )
      FIfld_set_list_text( VD_FP1, G_SEL_CFG_ITM, i, 0,
	  CfgItmGlbl[i].CfgName, FALSE );
    __DBGpr_com( " Set cfg names in form");
    FIg_disable( VD_FP1, G_SEL_HULL );
    FIg_disable( VD_FP1, G_SEL_CTX_TYP );
    FIg_disable( VD_FP1, G_SEL_CTX );
    FIg_erase( VD_FP1, G_TIT_SYS );
    FIg_erase( VD_FP1, G_TIT_ZONE );
    FIg_erase( VD_FP1, G_BTN_QRY_CTX );
    FIg_erase( VD_FP1, G_FLD_PREFX );

  }
  else
  { 
	/* Read the collector and update the form */

    status = _VD_SEND_MY ( VDPCmdPMDef.VDPGetDefaults ( &msg ) );
    CheckRC( status, msg ); 
    
    UI_status ( " Default Data already Set ");
    FIg_erase( VD_FP1, G_SEL_GRP );
    FIg_display( VD_FP1, G_VEW_GRP );
    FIg_disable(VD_FP1, 1 );
    FIg_disable(VD_FP1, G_TG_FILE_TYP); // CR # 17801371 SSR
  }
  
  goto wrapup;

} // ens sir
wrapup:

   End
   return OM_S_SUCCESS;

}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPCheckDM2Conn

  Abstract
        This method checks the VDS - DM2 Connection.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method VDPCheckDM2Conn ( long *sts )
{
   IGRlong	status = OM_S_SUCCESS;

   SetProc( VDPCmdPMDef.VDPCheckDM2Conn ); Begin

   *sts = VD_SUCCESS;

   /* Call Srirup's function for the DM2 server connection */
   if( IsPmeEnabled() == FALSE )
   {
	UI_status("PME server connection required");
	*sts = VD_ERROR;
	me->state = _terminate;
   }

   End

   return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPValidateInput

  Abstract
        This method validates the user inputs and checks to see if they are 
  not NULL.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method VDPValidateInput( long *msg )
{
   IGRlong	status = OM_S_SUCCESS;
   IGRint	len=1;

   SetProc( VDPCmdPMDef.VDPValidateInput ); Begin
   *msg = MSSUCC;

   /* Verify for any NULL inputs */

   //FIfld_get_text_length( VD_FP, G_ESWBS_E, 0, 0, &len );
   //if( len == 1) goto wrapup;

   FIfld_get_text_length( VD_FP, G_BWTCTX_E, 0, 0, &len );
   if( len == 1) goto wrapup;

   FIfld_get_text_length( VD_FP, G_CTX_TYPE_E, 0, 0, &len );
   if( len == 1) goto wrapup;

   FIfld_get_text_length( VD_FP, G_CTX_SUBTYPE_E, 0, 0, &len );
   if( len == 1) goto wrapup;

   FIfld_get_text_length( VD_FP, G_CTX_NAME_E, 0, 0, &len );
   if( len == 1) goto wrapup;

   if( refresh->act_catalog[0] == '\0' || refresh->act_partid[0] == '\0'
       || refresh->act_revision[0] == '\0' )
   {
	UI_status("File Catalog, Part & Rev not defined");
        FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "File Catalog, Part & Rev not defined",FALSE);
	status = OM_E_ABORT;
	goto wrapup;
   }
   __DBGpr_str( " --->Catalog :", refresh->act_catalog );
   __DBGpr_str( " --->Partnum :", refresh->act_partid );
   __DBGpr_str( " --->Partrev :", refresh->act_revision );

wrapup:
   if(len == 1) 
   {
      FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "All fields must be set",FALSE);
      status = OM_E_ABORT;
   }

   End
   return status;
}


method VDPSaveDefaults( long *msg )
{
   IGRlong		status = VD_SUCCESS;
   struct GRid		DirId;
   IGRchar		DirName[DI_PATH_MAX],
			CollName[DI_PATH_MAX];
   OMuword		curOs;
   struct ACrg_coll	coll[NB_REQ_DATA_VALUES];

   SetProc( VDPCmdPMDef.VDPSaveDefaults ); Begin

   ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */

   status = di$give_pathname(  osnum           = curOs,
                               pathname        = DirName );

   __CheckRC( status, 1, "di$give_pathname", wrapup );
   __DBGpr_str( "Path name", DirName );

   strcat( DirName, PME_GLOBAL_DIR );

   status =
   di$translate ( objname = DirName,
                  p_objid = &DirId.objid,
                  p_osnum = &DirId.osnum ) ;

   __DBGpr_obj( "Dir Id", DirId );

   /*A create PME_GLOBAL if it does not exist     */
   if ( status != DIR_S_SUCCESS )
   {
	DirId.objid = NULL_OBJID;

	status =
	di$mkdir( dirname = DirName,
		  p_dirid = &DirId.objid,
		  p_osnum = &DirId.osnum );

	__DBGpr_obj( "Dir Id", DirId );

	if( status != DIR_S_SUCCESS ) 
	{
		/*A Cannot create directory*/
		di$report_error( sts = status ) ;
		goto    wrapup;
	}
   }

   sprintf( CollName, "%s%s", DirName, PME_REQ_DATA );
   __DBGpr_str( "Collector name", CollName );

   status = VDgetVdCollId ( msg, CollName, TRUE, TRUE, &me->CollId ); 
   if( !(status & *msg & 1))
	UI_status("Error in creating Collector ");

   __CheckRC( status, *msg, "VDgetVdCollId", wrapup );

   __DBGpr_obj( "Collector Id", me->CollId );

   /* set up the coll values */

   strcpy( coll[0].name, VDP_ESWBS );
   coll[0].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[0].desc.value.att_txt, me->ReqDat.ESWBS );

   strcpy( coll[1].name, VDP_ESWBS_DESC );
   coll[1].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[1].desc.value.att_txt, me->ReqDat.ESWBS_Desc );
   
   strcpy( coll[2].name, VDP_BDGCTX_ID );
   coll[2].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[2].desc.value.att_txt, me->ReqDat.BdgWtCtx.CtxId );
   
   strcpy( coll[3].name, VDP_BDGCTX_TYPE );
   coll[3].desc.type = AC_ATTRIB_TEXT;
   coll[3].desc.value.att_txt[0] = me->ReqDat.BdgWtCtx.Type;
   coll[3].desc.value.att_txt[1] = '\0';
   
   strcpy( coll[4].name, VDP_BDGCTX_ST );
   coll[4].desc.type = AC_ATTRIB_DOUBLE;
   coll[4].desc.value.att_exp = me->ReqDat.BdgWtCtx.SubType;
   
   strcpy( coll[5].name, VDP_BDGCTX_ST_DESC );
   coll[5].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[5].desc.value.att_txt, me->ReqDat.BdgWtCtx.SubTypeDesc );
   
   strcpy( coll[6].name, VDP_BDGCTX_NAME );
   coll[6].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[6].desc.value.att_txt, me->ReqDat.BdgWtCtx.Name );
   
   strcpy( coll[7].name, VDP_BDGCTX_DESC );
   coll[7].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[7].desc.value.att_txt, me->ReqDat.BdgWtCtx.CtxDesc );
   
   strcpy( coll[8].name, VDP_PLCTX_ID );
   coll[8].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[8].desc.value.att_txt, me->ReqDat.PlacementCtx.CtxId );
   
   strcpy( coll[9].name, VDP_PLCTX_TYPE );
   coll[9].desc.type = AC_ATTRIB_TEXT;
   coll[9].desc.value.att_txt[0] = me->ReqDat.PlacementCtx.Type;
   coll[9].desc.value.att_txt[1] = '\0';
   
   strcpy( coll[10].name, VDP_PLCTX_ST );
   coll[10].desc.type = AC_ATTRIB_DOUBLE;
   coll[10].desc.value.att_exp = me->ReqDat.PlacementCtx.SubType;
   
   strcpy( coll[11].name, VDP_PLCTX_ST_DESC );
   coll[11].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[11].desc.value.att_txt, me->ReqDat.PlacementCtx.SubTypeDesc );
   
   strcpy( coll[12].name, VDP_PLCTX_NAME );
   coll[12].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[12].desc.value.att_txt, me->ReqDat.PlacementCtx.Name );
   
   strcpy( coll[13].name, VDP_PLCTX_DESC );
   coll[13].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[13].desc.value.att_txt, me->ReqDat.PlacementCtx.CtxDesc );

   __DBGpr_str( " --->Catalog :", refresh->act_catalog );
   __DBGpr_str( " --->Partnum :", refresh->act_partid );
   __DBGpr_str( " --->Partrev :", refresh->act_revision );

   status = VDPqueryFileId( msg, refresh->act_catalog, refresh->act_partid, refresh->act_revision, me->ReqDat.File );
   CheckRC ( status, *msg );
   __DBGpr_str( "File Id :", me->ReqDat.File );

/*
   strcpy(me->ReqDat.File, "0001" );
   __DBGpr_str( "File Id :", me->ReqDat.File );
*/
   
   strcpy( coll[14].name, VDP_FILEID );
   coll[14].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[14].desc.value.att_txt, me->ReqDat.File );
   
   strcpy( coll[15].name, VDP_SHIPID );
   coll[15].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[15].desc.value.att_txt, me->ReqDat.Ship.ShipId );

   strcpy( coll[16].name, VDP_SHIPNAME );
   coll[16].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[16].desc.value.att_txt, me->ReqDat.Ship.ShipName );

   strcpy( coll[17].name, VDP_SHIPDESC );
   coll[17].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[17].desc.value.att_txt, me->ReqDat.Ship.ShipDesc );

   /* store in collector */

   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACset_list_attribute( 
					msg, 
					NB_REQ_DATA_VALUES,
					coll ) );
   CheckRC( status, *msg );
   
wrapup:

   End
   return status;
}



method VDPGetDefaults( long *msg )
{
   IGRlong		status = VD_SUCCESS;
   struct ACrg_coll	coll;
   IGRchar		CtxTypeName[VDPNAME_LEN];

   SetProc( VDPCmdPMDef.VDPGetDefaults ); Begin
if( WhichAim( ) == PME){
   /* Get each attribute individually and fill the form */

   strcpy( coll.name, VDP_SHIPNAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_SHIPNAME", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_SHIPNAME_R, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, VDP_SHIPDESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_SHIPDESC", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP,G_SHIP_DESC_E, 0, 0, coll.desc.value.att_txt, FALSE );
/*    for TR # 179800483
   strcpy( coll.name, VDP_ESWBS );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_ESWBS", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_ESWBS_R, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, VDP_ESWBS_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_ESWBS_DESC", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP,G_ESWBS_DESC_R, 0, 0, coll.desc.value.att_txt, FALSE );
*/
   strcpy( coll.name, VDP_BDGCTX_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_BDGCTX_NAME", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_BWTCTX_R, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, VDP_BDGCTX_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_BDGCTX_DESC", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_BWTCTX_DESC, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, VDP_PLCTX_TYPE );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_PLCTX_TYPE", coll.desc.value.att_txt );

   /* Convert the Context Type Code to Context Type */
   VDPGetContextType( coll.desc.value.att_txt[0], CtxTypeName );

   FIfld_set_text( VD_FP, G_CTX_TYPE_R, 0, 0, CtxTypeName, FALSE );

   strcpy( coll.name, VDP_PLCTX_ST_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_PLCTX_ST_DESC", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_CTX_SUBTYPE_R, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, VDP_PLCTX_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_PLCTX_NAME", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_CTX_NAME_R, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, VDP_PLCTX_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "VDP_PLCTX_DESC", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_CTX_DESC, 0, 0, coll.desc.value.att_txt, FALSE );
}
if( WhichAim( ) == SIR)

{
   strcpy( coll.name, SIR_CFG_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Configuration Name", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_CFG_ITM, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, SIR_CFG_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Configuration Desc", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_CFG_DESC , 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, SIR_HULL_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Hull Name  ", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_HULL_NAM, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, SIR_HULL_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Hull Name Desc ", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_HULL_DESC, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, SIR_CNTX_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Name ", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_CTX, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, SIR_CNTX_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Desc. ", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_CTX_DESC, 0, 0, coll.desc.value.att_txt, FALSE );

   strcpy( coll.name, SIR_CNTX_TYP );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Type ", coll.desc.value.att_txt );

   FIfld_set_text( VD_FP, G_VEW_CTX_TYP, 0, 0, coll.desc.value.att_txt, FALSE );

   //get the filetype from collector and set the toggle accordingly.
   //disable the toggle  CR # 17801371 SSR
   strcpy( coll.name, SIR_FILE_TYP );
   coll.desc.value.att_exp = 2;
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __DBGpr_int( "FILE Type ", coll.desc.value.att_exp );

   if (!(*msg&1))
   {
     // old file version, set defa file type to Non arrangement 
     FIg_set_state_off( VD_FP, G_TG_FILE_TYP);
   }
   else
   {
     if ( coll.desc.value.att_exp == A_FILE )
       FIg_set_state_on( VD_FP, G_TG_FILE_TYP);
     else
       FIg_set_state_off( VD_FP, G_TG_FILE_TYP);
   }

}
wrapup:
   End
   return status;
}





method VDPqueryPMData( long *msg )
{
    IGRint			i;
    IGRlong			status = OM_S_SUCCESS;
    IGRint			nbTST=0,
				nbCtx=0,
				nbShips=0;
//				nbESWBS=0;  for TR # 179800483
    struct VDPPlCtxTST		*TypST=NULL;
    struct VDPNameDesc		*Contexts=NULL;
    //struct VDPEswbs		*ESWBSLst=NULL;
    struct VDPShipDesc		*Ships=NULL;

    SetProc( VDPCmdPMDef.VDPqueryPMData ); Begin

    *msg = MSSUCC;

    /* Query for ESWBS information */

    status = VDPgetShips( msg, &nbShips, &Ships );
    __CheckRC ( status, *msg, "VDPgetShips", wrapup );
    __DBGpr_int("Number of Ships :", nbShips );

    status = om$vla_set_dimension( varray = me->Ships,
				   size	  = nbShips );
    CheckRC( status, 1 );
    memcpy ( me->Ships, Ships, nbShips * sizeof (struct VDPShipDesc));

    for ( i = 0; i < nbShips; i++ )
	FIfld_set_list_text( VD_FP, G_SHIPNAME_E, i, 0,
				me->Ships[i].ShipName, FALSE );

    /* Query ESWBS numbers */

    /*status = VDPgetESWBS( msg, &nbESWBS, &ESWBSLst );  for TR # 179800483
    __CheckRC ( status, *msg, "VDPgetESWBS", wrapup );
    
    __DBGpr_int("Number of ESWBS Codes :", nbESWBS );*/

    /* Store the ESWBS List in the Instance */ 

    /*status = om$vla_set_dimension( varray = me->ESWBSList,
				   size	  = nbESWBS );
    CheckRC( status, 1 );

    status = om$vla_set_dimension( varray = me->sortedESWBSList,
				   size	  = nbESWBS );
    CheckRC( status, 1 );

    memcpy ( me->ESWBSList, ESWBSLst, nbESWBS * sizeof (struct VDPEswbs) );
    qsort( me->ESWBSList, nbESWBS, sizeof(struct VDPEswbs),
                      (int (*)())VDPsortESWBSnos );
    memcpy ( me->sortedESWBSList, ESWBSLst, nbESWBS * sizeof (struct VDPEswbs) );
    qsort( me->sortedESWBSList, nbESWBS, sizeof(struct VDPEswbs),
                      (int (*)())VDPsortESWBS ); */


    /* Update the form */
    /*for ( i = 0; i < nbESWBS; i++ )
    {
	FIfld_set_list_text( VD_FP, G_ESWBS_E, i, 0,
				me->ESWBSList[i].ESWBS, FALSE );
	FIfld_set_list_text( VD_FP, G_ESWBS_DESC_E, i, 0,
				me->sortedESWBSList[i].ESWBS_Desc, FALSE );
    } */

   /* Query for Placement context types and subtypes and Set them in the form*/

    FIfld_set_list_text( VD_FP, G_CTX_TYPE_E, 0, 0, VDPTSYSTEM, FALSE );
    FIfld_set_list_text( VD_FP, G_CTX_TYPE_E, 1, 0, VDPTCOMPARTMENT, FALSE );
    FIfld_set_list_text( VD_FP, G_CTX_TYPE_E, 2, 0, VDPTZONE, FALSE );
    FIfld_set_list_text( VD_FP, G_CTX_TYPE_E, 3, 0, VDPTUSERDEF, FALSE );

    status = VDPgetCtxTypeSubTypes( msg, &nbTST, &TypST );
    __DBGpr_int("Number of Type SubType :", nbTST );

    status = om$vla_set_dimension( varray = me->PLCtxTST,
				   size	  = nbTST );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    memcpy ( me->PLCtxTST, TypST, nbTST * sizeof (struct VDPPlCtxTST) );

    /* Query for Budget Wt Contexts, Names and description */

/* Make these changes later
    status = VDPGetClassNameGivenTST ( Type, SubType, me->PLCtxTST, nbTST, BwtClassName );
*/

    /* Now this has to be done in Form Notification as the BWT Contexts are
       ship dependant.

    status = VDPgetBWTContexts( msg, &nbCtx, &Contexts );
    __CheckRC ( status, *msg, "VDPgetBWTContexts", wrapup );

    __DBGpr_int("Number of Budget Wt contexts :", nbCtx );

    /* Store the Budget Wt Context in the Instance *

    status = om$vla_set_dimension( varray = me->BwcNameDesc,
				   size	  = nbCtx );
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    memcpy ( me->BwcNameDesc, Contexts, nbCtx * sizeof (struct VDPNameDesc) );

    for ( i = 0; i < nbCtx; i++ )
	FIfld_set_list_text( VD_FP, G_BWTCTX_E, i, 0,
				me->BwcNameDesc[i].CtxName, FALSE );

   */

wrapup :
    _FREE(Contexts);
    _FREE(TypST);
    //_FREE( ESWBSLst );
    End
    return status;
}


method VDPqueryClass( long *msg; IGRchar *ClassName )
{
    IGRint			nbCtx=0;
    IGRlong			status = OM_S_SUCCESS;
    struct  VDPNameDesc		*Contexts=NULL;

    SetProc( VDPCmdPMDef.VDPqueryPMData ); Begin

    *msg = MSSUCC;
    __DBGpr_str( "Querying on Class name", ClassName );

    __DBGpr_str( "Ship Name ", me->ReqDat.Ship.ShipName );
    status = VDPgetContexts( msg, ClassName, me->ReqDat.Ship.ShipName, &nbCtx, &Contexts );
    __CheckRC ( status, *msg, "VDPgetContexts", wrapup );

    __DBGpr_int("Number of contexts :", nbCtx );

    status = om$vla_set_dimension( varray = me->PlcNameDesc,
				  size	  = nbCtx ); 
    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    memcpy ( me->PlcNameDesc, Contexts, nbCtx * sizeof (struct VDPNameDesc) );

wrapup :
    _FREE(Contexts);

    End
    return status;
}
long VDPgetCfgItms ( long        *msg,
                    int             *nbCfgItms,
                    struct  VDPCfgItms   **CfgItms )
{
        int     i = 0, inlen = 0, code = 0,
                index = 0, index1 = 0, outlen = 0,
                dstat = 0, mfail = 0;
        char        inbuf[20], srerrmsg[50];
        char    *outbuf, *errmsg=0;

    SetProc ( VDPgetCfgItms ); Begin
        *nbCfgItms = 0;
    *CfgItms = NULL;
    *msg = MSSUCC;
        for ( i=0; i<20; i++ )
                inbuf[i]='\0';

    /* Add the code to the beginning of the buffer */
 code = VDP_QUERY_CFGITEMS;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* Query SIR server */
    dstat = POSTMAN_REQUEST_ON_CLIX (   inlen, inbuf,
                &outlen,
                &outbuf,
                &mfail,
                &errmsg );

        if(dstat || mfail)
    {
                if(!errmsg || (errmsg && !errmsg[0]))
                        errmsg="No error msg but should be";
                if ( strlen(errmsg ) > 63 )
                        errmsg[63] = '\0';
                UI_status( errmsg );
      if(dstat == 12345 )
      {
        strcpy(srerrmsg, "AIM connection reset by server.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
      }
        return OM_E_ABORT;
}
    memcpy( nbCfgItms, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);
    __DBGpr_int( "nbCfgItms", *nbCfgItms );

    if( *nbCfgItms == 0) goto wrapup;
    if( *nbCfgItms )
    {
                *CfgItms = _MALLOC ( *nbCfgItms, struct VDPCfgItms );
                if ( *CfgItms == NULL )
                {
                        printf("Error in dynamic allocation of memory\n");
                        return OM_E_NODYNMEM;
                }
    }
for ( i = 0; i < *nbCfgItms; i++ )
 {
                (*CfgItms)[i].CfgId[0] = '\0';
                (*CfgItms)[i].CfgName[0] = '\0';
                (*CfgItms)[i].CfgDesc[0] = '\0';

                strcpy((*CfgItms)[i].CfgId, &outbuf[index1]);
                index1 = index1 + strlen((*CfgItms)[i].CfgId) +1;
                __DBGpr_str ("CfgItmId", (*CfgItms)[i].CfgId );

                strcpy((*CfgItms)[i].CfgName, &outbuf[index1]);
                index1 = index1 + strlen((*CfgItms)[i].CfgName) +1;
                __DBGpr_str ("cfg Name ", (*CfgItms)[i].CfgName );

                strcpy((*CfgItms)[i].CfgDesc, &outbuf[index1]);
                index1 = index1 + strlen((*CfgItms)[i].CfgDesc) +1;
                __DBGpr_str ("Cfg Desc ", (*CfgItms)[i].CfgDesc );
        }
	AIMqsort(1, 0, *nbCfgItms-1); // CR#179802232 Jan 19 SSR

wrapup:
End
        return OM_S_SUCCESS;
}

int     VDPgetHulls( long         *msg,
                           char         *CfgName,
                           int          *nbHull,
                           struct  VDPhulls  **Hulls )
{
  char		inbuf[100];
  int		inlen, outlen = 0, code, index = 0, dstat, mfail,i, index1 = 0;
  char		*outbuf, *errmsg = 0;

    *msg = MSSUCC;
  *nbHull = 0;

  for ( i = 0; i < 100; i++ )
    inbuf[i] = '\0';

  code = VDP_QUERY_HULLS;
  inlen = 0;
  memcpy( &inbuf[index], &code, sizeof(int) );
  inlen += sizeof(int);
  index = inlen;
   
  strcpy( &inbuf[index], CfgName );
  inlen = inlen + strlen( CfgName ) +1;
  index = inlen;

  dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                        inbuf,
                                        &outlen,
                                        &outbuf,
                                        &mfail,
                                        &errmsg );
    if(dstat || mfail)
    {
        if(!errmsg || (errmsg && !errmsg[0]))
            errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
        UI_status( errmsg );
        return 0;
    }

    memcpy( nbHull, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);
    if ( *nbHull == 0) goto wrapup;
    if( *nbHull )
    {
                *Hulls = _MALLOC ( *nbHull, struct VDPhulls );
                if ( *Hulls == NULL )
                {
                        printf("Error in dynamic allocation of memory\n");
                        return OM_E_NODYNMEM;
                }
    }

   __DBGpr_int( " outlen ", outlen );
    for ( i = 0; i < *nbHull; i++ )
       {
                (*Hulls)[i].HullId[0] = '\0';
                (*Hulls)[i].HullName[0] = '\0';
                (*Hulls)[i].HullDesc[0] = '\0';
                (*Hulls)[i].HullRev[0] = '\0';
                (*Hulls)[i].HullEffFrom[0] = '\0';
                (*Hulls)[i].HullEffTo[0] = '\0';

                strcpy((*Hulls)[i].HullName, &outbuf[index1]);
                index1 = index1 + strlen((*Hulls)[i].HullName) +1;
                __DBGpr_str ("HullName", (*Hulls)[i].HullName );

                strcpy((*Hulls)[i].HullRev, &outbuf[index1]);
                index1 = index1 + strlen((*Hulls)[i].HullRev) +1;
                __DBGpr_str ("Ship Rev ", (*Hulls)[i].HullRev );

                strcpy((*Hulls)[i].HullId, &outbuf[index1]);
                index1 = index1 + strlen((*Hulls)[i].HullId) +1;
                __DBGpr_str ("Ship Id ", (*Hulls)[i].HullId );

                strcpy((*Hulls)[i].HullEffFrom, &outbuf[index1]);
                index1 = index1 + strlen((*Hulls)[i].HullEffFrom) +1;
                __DBGpr_str ("Ship EffFrom ", (*Hulls)[i].HullEffFrom );

                strcpy((*Hulls)[i].HullEffTo, &outbuf[index1]);
                index1 = index1 + strlen((*Hulls)[i].HullEffTo) +1;
		__DBGpr_int( " index1 ", index1 );
                __DBGpr_str ("Ship EffTo ", (*Hulls)[i].HullEffTo ); 
        }
    AIMqsort(2, 0, *nbHull-1); // CR#179802232 Jan 19 SSR

wrapup:

return OM_S_SUCCESS;
}

int     VDPgetCntxts( long         *msg,
			   char		*CntxType,
                           char         *CntxPrFx,
                           int          *nbCntxt,
                           struct  VDPCntxt  **Cntxts )

{
  int 		code = 0, index1 = 0, ctxcode = 0,u=0;
  char 		inbuf[100];
  int 		inlen = 0, index = 0, dstat, mfail, outlen = 0, i = 0;
  char          *outbuf, *errmsg = 0;
  IGRlong	status = OM_S_SUCCESS;

  SetProc( VDPgetCntxts ); Begin

  *msg = MSSUCC;
  *nbCntxt = 0;
  __DBGpr_str( " CntxType ", CntxType);
  for ( i = 0; i < 100; i++ )
    inbuf[i] = '\0';
  code = VDP_QUERY_CTXS;
  __DBGpr_int(" code ", code);
  memcpy( &inbuf[index], &code, sizeof(int) );
  inlen += sizeof(int);
  index = inlen;

  if( !( strcmp(CntxType, SR_FSI)))
  {
    ctxcode = SR_FSI_TYPE;
    memcpy( &inbuf[index], &ctxcode, sizeof(int) );
    inlen += sizeof(int);
    index = inlen;
  }

  else if (!( strcmp(CntxType, SR_ZNSYS)))
  {
    ctxcode = SR_ZNSYS_TYPE;
    memcpy( &inbuf[index], &ctxcode, sizeof(int) );
    inlen += sizeof(int);
    index = inlen;
  }

  else if (!( strcmp(CntxType, SR_ZONE)))
  {
    ctxcode = SR_ZONE_TYPE;
    memcpy( &inbuf[index], &ctxcode, sizeof(int) );
    inlen += sizeof(int);
    index = inlen;
  }


  else if (!( strcmp(CntxType, SR_UNIT)))
  {
    ctxcode = SR_UNIT_TYPE;
    memcpy( &inbuf[index], &ctxcode, sizeof(int) );
    inlen += sizeof(int);
    index = inlen;
  }

  else if (!( strcmp(CntxType, SR_SUB_FSI)))
  {
    ctxcode = SR_SUB_FSI_TYPE;
    memcpy( &inbuf[index], &ctxcode, sizeof(int) );
    inlen += sizeof(int);
    index = inlen;
  }

  strcpy( &inbuf[index], CntxPrFx);
  inlen = inlen + strlen( CntxPrFx ) +1;
  index = inlen;
  __DBGpr_str(" CtxPrFx ", CntxPrFx );

  strcpy( &inbuf[index], SRDefDat.CfgItm.CfgName );
  inlen = inlen + strlen( SRDefDat.CfgItm.CfgName ) +1;
  index = inlen;
  __DBGpr_str(" cfgName ", SRDefDat.CfgItm.CfgName );

  strcpy( &inbuf[index], SRDefDat.Hull.HullEffFrom );
  inlen = inlen + strlen( SRDefDat.Hull.HullEffFrom ) +1;
  index = inlen;
  __DBGpr_str(" hull eff from ", SRDefDat.Hull.HullEffFrom );

  strcpy( &inbuf[index], SRDefDat.Hull.HullEffTo );
  inlen = inlen + strlen( SRDefDat.Hull.HullEffTo ) +1;
  index = inlen;
  __DBGpr_str(" hull eff to ", SRDefDat.Hull.HullEffTo );

  strcpy( &inbuf[index], SRDefDat.Hull.HullId );
  inlen = inlen + strlen( SRDefDat.Hull.HullId ) +1;
  index = inlen;
  __DBGpr_str(" hullid ", SRDefDat.Hull.HullId );

  /*for(u = 0; u< inlen; u++)
    printf(" %c", inbuf[u]);*/
  dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                        inbuf,
                                        &outlen,
                                        &outbuf,
                                        &mfail,
                                        &errmsg );
    if(dstat || mfail)
        /* outbuf[outlen-1] = '\0'; Outbuf len may be 0 */
    {
        if(!errmsg || (errmsg && !errmsg[0]))
            errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
        UI_status( errmsg );
        return 0;
    }
    memcpy( nbCntxt, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);

    if( *nbCntxt == 0 )  goto wrapup;
    if( *nbCntxt )
    {
                *Cntxts= _MALLOC ( *nbCntxt, struct VDPCntxt );
                if ( *Cntxts == NULL )
                {
                        printf("Error in dynamic allocation of memory\n");
                        return OM_E_NODYNMEM;
                }
    }

    for ( i = 0; i < *nbCntxt; i++ )
    {
                (*Cntxts)[i].CntxtId[0] = '\0';
                (*Cntxts)[i].CntxtName[0] = '\0';
                (*Cntxts)[i].CntxtDesc[0] = '\0';

                strcpy((*Cntxts)[i].CntxtId, &outbuf[index1]);
                index1 = index1 + strlen((*Cntxts)[i].CntxtId) +1;
                __DBGpr_str ("CntxtId", (*Cntxts)[i].CntxtId );

                strcpy((*Cntxts)[i].CntxtName, &outbuf[index1]);
                index1 = index1 + strlen((*Cntxts)[i].CntxtName) +1;
                __DBGpr_str ("CntxtName", (*Cntxts)[i].CntxtName );

                strcpy((*Cntxts)[i].CntxtDesc, &outbuf[index1]);
                index1 = index1 + strlen((*Cntxts)[i].CntxtDesc) +1;
                __DBGpr_str ("CntxtDesc", (*Cntxts)[i].CntxtDesc );
    }
    AIMqsort(3, 0, *nbCntxt-1); // CR#179802232 Jan 19 SSR
wrapup:

return OM_S_SUCCESS;
}

int VDPqueryModCxId(long	*msg,
			char	*ModCxId )
{
  int		i, inlen = 0, code, index = 0, outlen, dstat,mfail,j;
  char		inbuf[200];
  char		*outbuf, *errmsg = 0;
  char		FileName[257], FileTyp[2], srerrmsg[200];
  int		diagCtl;
  IGRlong	status = OM_S_SUCCESS;

  SetProc( VDPqueryModCxId ); Begin

  *msg = MSSUCC;

  for( i = 0; i<100; i++) inbuf[i] = '\n';
  code = VDP_QUERY_MODCX;
  __DBGpr_int("code ", code);
  inlen = 0;
  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;

  /* for CR # 179801371
  status = VDgetDiagCtlPar(&msg, &diagCtl );
  FileTyp[0] = '\0';
  if(diagCtl == 1)
    strcpy(FileTyp, "D");
  else
    strcpy(FileTyp, "M");
    */

  FileTyp[0] = '\0';
  if(SRDefDat.FileTyp == 0)
    strcpy(FileTyp, "M");
  else if(SRDefDat.FileTyp == 1)
    strcpy(FileTyp, "D");
  else if(SRDefDat.FileTyp ==2)
    strcpy(FileTyp, "A");

   /* Add Hull obid foe new DAD*/
   strcpy(&inbuf[index], SRDefDat.Hull.HullId);
   inlen += strlen( SRDefDat.Hull.HullId) + 1;
   index = inlen;
  __DBGpr_str(" HullId ", SRDefDat.Hull.HullId);
   
  strcpy( &inbuf[index], FileTyp );
  inlen += strlen(FileTyp) +1;
  index = inlen;
  __DBGpr_str(" filetyp ", FileTyp);

    strcpy( &inbuf[index], refresh->act_catalog );
    inlen += strlen(refresh->act_catalog) + 1;
    index = inlen;

    strcpy( &inbuf[index], refresh->act_partid );
    inlen += strlen(refresh->act_partid) + 1;
    index = inlen;

    strcpy( &inbuf[index], refresh->act_revision );
    inlen += strlen(refresh->act_revision) + 1;
    index = inlen;

    FileName[0] = '\0';
    if( !get_local_fname(refresh->act_catalog, refresh->act_partid, refresh->act_revision, FileName) )
    {
      UI_status( "Unable to get local( CheckOut ) file name from RDB" );
      return 0;
    }
  __DBGpr_str(" name ", FileName);
    strcpy( &inbuf[index], FileName );
    inlen += strlen(FileName) + 1;
    index = inlen;

    strcpy( &inbuf[index], SRDefDat.Cntxt.CntxtId );
    __DBGpr_str( " SRDefDat.Cntxt.CntxtId ", SRDefDat.Cntxt.CntxtId);
    inlen += strlen(SRDefDat.Cntxt.CntxtId) + 1;
    index = inlen;

    strcpy( &inbuf[index], SRDefDat.CfgItm.CfgId );
    __DBGpr_str( " SRDefDat.CfgItm.CfgId ", SRDefDat.CfgItm.CfgId);
    inlen += strlen(SRDefDat.CfgItm.CfgId) + 1;
    index = inlen;

    strcpy( &inbuf[index], SRDefDat.Hull.HullEffFrom );
    __DBGpr_str( " SRDefDat.Hull.HullEffFrom ", SRDefDat.Hull.HullEffFrom);
    inlen += strlen(SRDefDat.Hull.HullEffFrom) + 1;
    index = inlen;

    strcpy( &inbuf[index], SRDefDat.Hull.HullEffTo );
    __DBGpr_str( " SRDefDat.Hull.HullEffTo ", SRDefDat.Hull.HullEffTo);
    inlen += strlen(SRDefDat.Hull.HullEffTo) + 1;
    index = inlen;

    /*for(j=0; j < inlen; j++)
     * printf(" %c", inbuf[j]);
     */
    dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                        inbuf,
                                        &outlen,
                                        &outbuf,
                                        &mfail,
                                        &errmsg );

   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    if ( mfail )
    {
      status = VDgetSrError( mfail, srerrmsg );
      UI_status ( srerrmsg );
      ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
      return OM_E_ABORT;
    }

    if(dstat )
    {
        if(!errmsg || (errmsg && !errmsg[0]))
            errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
   UI_status( errmsg );
        return 0;
    }
   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    /* The number of File Id's is returned */
    index = sizeof(int);
    strcpy( ModCxId, &outbuf[index] );
    index = strlen(ModCxId) + 1;

    End
    return OM_S_SUCCESS;
}


int sir_form_notification( int             form_label,
			int             gadget_label,
			double          value,
			char            *form_ptr)
{
int		sel, i, pos, len, FilTypOpt, FileType = 0;
char		CfgName[81];
char		CfgDesc[120], filename[80];
char		CntxtDesc[120];
int		resp, diagCtl, prlen = 0;
long		msg, status = OM_S_SUCCESS;
char		HullName[81];
char		CntxType[81], CntxPrFx[50];
char		CntxtName[81];
char		HullDesc[120];
struct GRid	CollId, DirId;
OMuword		curOs;
char		DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
struct ACrg_coll coll[16];

SetProc( sir_form_notification ); Begin

  __DBGpr_int( " gadget_label ", gadget_label); 
  __DBGpr_int( " form_label ", form_label);

  value = 0.0;
  form_label = 0;

  for(i =0; i< 80; i++) CfgName[i] = '\0';
  for(i =0; i< 80; i++) HullName[i] = '\0';
  for(i =0; i< 119; i++) HullDesc[i] = '\0'; 
  
  switch(gadget_label)
  {
   case G_SEL_CFG_ITM : // select config item gdget

       FIg_disable( (Form)form_ptr, G_VEW_CFG_DESC );
       FIg_disable( (Form)form_ptr, G_VEW_HULL_DESC );
       FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC );
       FIg_erase( (Form)form_ptr, G_TIT_SYS );
       FIg_erase( (Form)form_ptr, G_TIT_ZONE );
       FIg_erase( (Form)form_ptr, G_BTN_QRY_CTX );
       FIg_erase( (Form)form_ptr, G_FLD_PREFX );


       FIfld_get_text( (Form)form_ptr,
	   G_SEL_CFG_ITM, 0, 0,
	   VDPDESC_LEN, 
	   (unsigned char *)CfgName, 
	   &sel, &pos);
       __DBGpr_str( " CfgName :", CfgName);
       __DBGpr_int (" Number of cfg items ", VDnbCfgGbl ); 
       
       for (i=0; i < VDnbCfgGbl; i++ )
       {
	 if(!strcmp(CfgName,CfgItmGlbl[i].CfgName))
	 {
	   CfgDesc[0] = '\0';
	   strcpy(CfgDesc, CfgItmGlbl[i].CfgDesc);
	   FIfld_set_text( (Form)form_ptr,
	       G_VEW_CFG_DESC , 0, 0,
	       CfgDesc, FALSE );
	   FIg_enable( (Form)form_ptr, G_VEW_CFG_DESC );
	   __DBGpr_str( " CfgDesc", CfgDesc);
	   strcpy(SRDefDat.CfgItm.CfgDesc, CfgDesc);
	   __DBGpr_str( " SRDefDat.CfgItm.CfgDesc", SRDefDat.CfgItm.CfgDesc);
	   strcpy(SRDefDat.CfgItm.CfgId, CfgItmGlbl[i].CfgId);
	   __DBGpr_str( " SRDefDat.CfgItm.CfgId", SRDefDat.CfgItm.CfgId);
	   break;
	 }
       } // end for

       strcpy(CfgNameGbl, CfgName);
       strcpy(SRDefDat.CfgItm.CfgName, CfgName);
       
       __DBGpr_str(" cfg name in defadata ", SRDefDat.CfgItm.CfgName); 
       
       FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_HULL, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_HULL_DESC, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE );
       UI_status( ""); 
       FIfld_set_text( (Form)form_ptr,
	   FI_MSG_FIELD, 0, 0, 
	   "Wait.... Querying SIR for Hulls", FALSE );
       status = VDPgetHulls( &msg, CfgNameGbl, &nbHull, &HullGlbl );
       if(nbHull == 0)
       {
	 FIfld_set_text( (Form)form_ptr,
	     FI_MSG_FIELD, 0, 0, 
	     " No Hulls in S I R ",0);
	 FIfld_set_text( (Form)form_ptr, G_SEL_HULL, 0, 0, "", FALSE );
	 FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_HULL, 0, 0);
	 FIg_disable( (Form)form_ptr, G_SEL_HULL );
	 FIg_disable( (Form)form_ptr, G_SEL_CTX_TYP );
	 FIg_disable( (Form)form_ptr, G_SEL_CTX );
	 break;
         //goto wrapup;
       } 
       
       FIg_enable( (Form)form_ptr, G_SEL_HULL );
       FIg_disable( (Form)form_ptr, G_SEL_CTX_TYP );
       FIg_disable( (Form)form_ptr, G_SEL_CTX );
       FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_HULL, 0, 0); 
       
       for ( i = 0; i < nbHull; i++ )
	 FIfld_set_list_text((Form)form_ptr,
	     G_SEL_HULL, i, 0, 
	     HullGlbl[i].HullName, FALSE );
      
       FIfld_set_text( (Form)form_ptr,
	   FI_MSG_FIELD, 0, 0,
	   "Select Hull", FALSE ); 
       
       break;   // case 17

   case FI_CANCEL : 
       if( CfgItmGlbl )
	 _FREE( CfgItmGlbl );
       if( HullGlbl )
	 _FREE( HullGlbl );
       if( CntxtGlbl )
	 _FREE( CntxtGlbl );
   //if( SRDefDat )
   // _FREE( SRDefDat );

       resp = VD_FORM_CANCEL;
       ex$putque( msg  = &msg,
		response = &resp );
       break; 
   
   case G_SEL_HULL : // select hulll
   
       FIg_disable( (Form)form_ptr, G_VEW_HULL_DESC );
       FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC ); 
       FIg_erase( (Form)form_ptr, G_TIT_SYS );
       FIg_erase( (Form)form_ptr, G_TIT_ZONE );
       FIg_erase( (Form)form_ptr, G_BTN_QRY_CTX );
       FIg_erase( (Form)form_ptr, G_FLD_PREFX );

       FIfld_get_text((Form)form_ptr,
	   G_SEL_HULL, 0, 0,
	   VDPDESC_LEN, (unsigned char *)HullName,
	   &sel, &pos );
       strcpy(SRDefDat.Hull.HullName, HullName);
       __DBGpr_str(" hullname ", HullName);
       __DBGpr_int(" nbhull ",  nbHull); 
       
       for (i=0; i < nbHull; i++ )
       {
	 if(!strcmp(HullName,HullGlbl[i].HullName))
	 {
	   strcat( HullDesc, HullName);
	   strcat( HullDesc, ":");
	   strcat( HullDesc, HullGlbl[i].HullRev);
	   strcat( HullDesc, ":");
	   strcat( HullDesc, SRDefDat.CfgItm.CfgName);
	   strcat( HullDesc, ":");
	   strcat( HullDesc, HullGlbl[i].HullEffFrom);
	   strcat( HullDesc, ":");
	   if ( HullGlbl[i].HullEffTo[0] != '~' )
	     strcat( HullDesc, HullGlbl[i].HullEffTo);
	   else
	     strcat( HullDesc, " ");
	   __DBGpr_str(" HullDesc ", HullDesc);
	   FIfld_set_text( (Form)form_ptr,
	       G_VEW_HULL_DESC, 0, 0, 
	       HullDesc, FALSE );
	   FIg_enable( (Form)form_ptr, G_VEW_HULL_DESC );
	   strcpy(SRDefDat.Hull.HullEffFrom, HullGlbl[i].HullEffFrom);
	   strcpy(SRDefDat.Hull.HullId, HullGlbl[i].HullId);
	   strcpy(SRDefDat.Hull.HullDesc, HullDesc);
	   strcpy(SRDefDat.Hull.HullEffTo, HullGlbl[i].HullEffTo);
	   strcpy(SRDefDat.Hull.HullRev, HullGlbl[i].HullRev);
	   break;
	 }
       } 
       
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE ); 
       
       status = VDgetDiagCtlPar(&msg, &diagCtl );
       // Get the toggle state and est filetype CR # 179801371
       // set the pop up list depending on file type
       //if( diagCtl == 1)   // file type 2D
       /*{
	 FIfld_set_list_text((Form)form_ptr,
	     G_SEL_CTX_TYP, 0,0,
	     SR_FSI, FALSE);
	 FIfld_set_list_text((Form)form_ptr,
	     G_SEL_CTX_TYP, 1,0,
	     SR_SUB_FSI, FALSE);
       }
       else if (diagCtl == 0 )
       {
	 FIfld_set_list_text( (Form)form_ptr,
	     G_SEL_CTX_TYP, 0,0, 
	     SR_ZNSYS, FALSE);
	 FIfld_set_list_text( (Form)form_ptr,
	     G_SEL_CTX_TYP, 1,0, 
	     SR_ZONE, FALSE);
	 FIfld_set_list_text( (Form)form_ptr,
	     G_SEL_CTX_TYP, 2,0, 
	     SR_UNIT, FALSE);
       }*/ 
       
       FIg_get_state((Form)form_ptr, G_TG_FILE_TYP, &FilTypOpt );
       if( FilTypOpt )
	 FileType = A_FILE;
       else
	 FileType = diagCtl;
       //printf("\n file = %d", FileType);

       SRDefDat.FileTyp = FileType;

       switch ( FileType )
       {
	case D_FILE:
	    FIfld_set_list_text((Form)form_ptr,
		G_SEL_CTX_TYP, 0,0,
		SR_SUB_FSI, FALSE);
	    FIfld_set_list_text((Form)form_ptr,
		G_SEL_CTX_TYP, 1,0,
		SR_FSI, FALSE);
	    break;
	case M_FILE:
	case A_FILE:
	    FIfld_set_list_text( (Form)form_ptr,
		G_SEL_CTX_TYP, 0,0, 
		SR_UNIT, FALSE);
	    FIfld_set_list_text( (Form)form_ptr,
		G_SEL_CTX_TYP, 1,0, 
		SR_ZONE, FALSE);
	    FIfld_set_list_text( (Form)form_ptr,
		G_SEL_CTX_TYP, 2,0, 
		SR_ZNSYS, FALSE);
	    break;
       }

       FIg_enable( (Form)form_ptr, G_SEL_CTX_TYP);
       FIg_disable( (Form)form_ptr, G_SEL_CTX);
       FIfld_set_text( (Form)form_ptr,
	   FI_MSG_FIELD, 0, 0, "Select Context Type", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE );

       break; 
   case G_SEL_CTX_TYP : // select context type

       FIg_disable( (Form)form_ptr, G_SEL_CTX );
       FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC );
       FIg_erase( (Form)form_ptr, G_TIT_SYS );
       FIg_erase( (Form)form_ptr, G_TIT_ZONE );
       FIg_erase( (Form)form_ptr, G_BTN_QRY_CTX );
       FIg_erase( (Form)form_ptr, G_FLD_PREFX );


       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_get_text((Form)form_ptr,
	   G_SEL_CTX_TYP, 0, 0, 
	   VDPDESC_LEN, (unsigned char *)CntxType, 
	   &sel, &pos );
       strcpy(SRDefDat.CntxTyp, CntxType);
       
       if(!strcmp(SRDefDat.CntxTyp, SR_FSI) ||
          !strcmp(SRDefDat.CntxTyp, SR_SUB_FSI))
           FIg_display( (Form)form_ptr, G_TIT_SYS );

       if(!strcmp(SRDefDat.CntxTyp, SR_ZONE) ||
          !strcmp(SRDefDat.CntxTyp, SR_UNIT) ||
          !strcmp(SRDefDat.CntxTyp, SR_ZNSYS))
             FIg_display( (Form)form_ptr, G_TIT_ZONE );
       FIg_display( (Form)form_ptr, G_BTN_QRY_CTX );
       FIg_display( (Form)form_ptr, G_FLD_PREFX );
       FIfld_set_text( (Form)form_ptr, G_FLD_PREFX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr,
           FI_MSG_FIELD, 0, 0, "Enter prefix and/or Query Contexts.", FALSE );

       break;

    case G_BTN_QRY_CTX:
       FIfld_get_text_length( (Form)form_ptr, G_FLD_PREFX, 0, 0, &prlen);
       if( prlen == 0 )
       {
         strcpy(CntxPrFx, "*");
       }
       else
       {
         FIfld_get_text((Form)form_ptr, G_FLD_PREFX, 0, 0,
                        VDPDESC_LEN, (unsigned char *)CntxPrFx, &sel, &pos );
       }
       FIfld_get_text((Form)form_ptr,
           G_SEL_CTX_TYP, 0, 0,
           VDPDESC_LEN, (unsigned char *)CntxType,
           &sel, &pos );

       FIfld_set_text( (Form)form_ptr,
           FI_MSG_FIELD, 0, 0,
           "Wait.... Querying SIR for Contexts", FALSE );

       __DBGpr_str("Cntxtype", CntxType);
       __DBGpr_str("CntxPrFx", CntxPrFx);
       FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_CTX, 0, 0);
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE );
       status = VDPgetCntxts( &msg, CntxType, CntxPrFx, &nbCntxt, &CntxtGlbl );
       FIg_set_state_off( (Form)form_ptr, G_BTN_QRY_CTX );
       if(nbCntxt == 0)
       {
         FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0,
             " No Contexts found ",0);
         UI_status( "" );
         break;
         //goto wrapup;
       }

       __DBGpr_int( " nu of contestx", nbCntxt);
       FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_CTX, 0, 0);
       for ( i = 0; i < nbCntxt; i++ )
         FIfld_set_list_text((Form)form_ptr,
             G_SEL_CTX, i, 0,
             CntxtGlbl[i].CntxtName, FALSE );
       __DBGpr_int( " nbctx ", nbCntxt );
       FIg_enable(  (Form)form_ptr, G_SEL_CTX );
       FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, " Select Context",0);

       break;


   case G_SEL_CTX :   // select context
       FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC );
       FIfld_get_text((Form)form_ptr,
	   G_SEL_CTX, 0, 0, 
	   VDPDESC_LEN, (unsigned char *)CntxtName,
	   &sel, &pos );
       strcpy(SRDefDat.Cntxt.CntxtName, CntxtName);

       for (i=0; i < nbCntxt; i++ )
       {
	 if(!strcmp(CntxtName,CntxtGlbl[i].CntxtName))
	 {
	   strcpy(CntxtDesc, CntxtGlbl[i].CntxtDesc);
	   FIfld_set_text( (Form)form_ptr,
	       G_VEW_CTX_DESC, 0, 0, 
	       CntxtDesc, FALSE );
	   FIg_enable( (Form)form_ptr, G_VEW_CTX_DESC );
	   strcpy(SRDefDat.Cntxt.CntxtId, CntxtGlbl[i].CntxtId);
	   strcpy(SRDefDat.Cntxt.CntxtDesc, CntxtDesc);
	   break;
	 }
       }
       FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, " ",0);
       UI_status( "" );

       break;

   case FI_ACCEPT :

       FIfld_get_text_length( (Form)form_ptr, G_SEL_CFG_ITM, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;

       FIfld_get_text_length( (Form)form_ptr, G_SEL_HULL, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;

       FIfld_get_text_length( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;

       FIfld_get_text_length( (Form)form_ptr, G_SEL_CTX, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;

       UI_status( "Processing...." );
       /* Get the OBID of the associated Model Cntxt object */
       status = VDPqueryModCxId ( &msg,
			      ModCxId );
       CheckRC( status, msg );
       if( !(status & msg & 1) )
       {
	 //UI_status("ModelCx Already Exists In SIR\n" );
	 
	 //resp = VD_FORM_CANCEL;
	 //ex$putque( msg  = &msg,
	//	response = &resp );
	 //goto wrapup;
         FIg_set_state_off((Form)form_ptr, FI_ACCEPT);
         break;
       }
       __DBGpr_str(" ModCxId ",ModCxId );
       ex$get_cur_mod( osnum = &curOs );
       /* get directory path name */
       status = di$give_pathname(  osnum           = curOs,
  				 pathname        = DirName );
       __CheckRC( status, 1, "di$give_pathname", wrapup );
       __DBGpr_str( "Path name", DirName );
       strcpy(filename, (char *)(strrchr(DirName, ':') + sizeof(char)) );
       strcat( DirName, SIR_GLOBAL_DIR );
       status = di$translate ( objname = DirName,
	   p_objid = &DirId.objid,
	   p_osnum = &DirId.osnum ) ; 
       
       __DBGpr_obj( "Dir Id", DirId );
       /*A create SIT_GLOBAL if it does not exist     */
       if ( status != DIR_S_SUCCESS )
       {
	 DirId.objid = NULL_OBJID;
	 status = di$mkdir( dirname = DirName,
	     p_dirid = &DirId.objid,
	     p_osnum = &DirId.osnum );
	 __DBGpr_obj( "Dir Id", DirId );
	 if( status != DIR_S_SUCCESS )

	 {/*A Cannot create directory*/
	   di$report_error( sts = status ) ;
	   goto    wrapup;
	 }
       }
       sprintf( CollName, "%s%s", DirName, SIR_REQ_DATA );
       __DBGpr_str( "Collector name", CollName );

       status = VDgetVdCollId ( &msg, CollName, TRUE, TRUE, &CollId );
       __DBGpr_obj( " Collector Id ", CollId );

       /* set up the coll values */
       strcpy( coll[0].name, SIR_CFG_NAME );
       coll[0].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[0].desc.value.att_txt, SRDefDat.CfgItm.CfgName );

       strcpy( coll[1].name, SIR_CFG_DESC );
       coll[1].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[1].desc.value.att_txt, SRDefDat.CfgItm.CfgDesc );

       strcpy( coll[2].name, SIR_CFG_ID );
       coll[2].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[2].desc.value.att_txt, SRDefDat.CfgItm.CfgId );

       strcpy( coll[3].name, SIR_HULL_NAME );
       coll[3].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[3].desc.value.att_txt, SRDefDat.Hull.HullName );

       strcpy( coll[4].name, SIR_HULL_DESC );
       coll[4].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[4].desc.value.att_txt, SRDefDat.Hull.HullDesc );
  
       strcpy( coll[5].name, SIR_HULL_ID );
       coll[5].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[5].desc.value.att_txt, SRDefDat.Hull.HullId );

       strcpy( coll[6].name, SIR_HULL_REV );
       coll[6].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[6].desc.value.att_txt, SRDefDat.Hull.HullRev );

       strcpy( coll[7].name, SIR_HULL_EFFFROM );
       coll[7].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[7].desc.value.att_txt, SRDefDat.Hull.HullEffFrom );

       strcpy( coll[8].name, SIR_HULL_EFFTO );
       coll[8].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[8].desc.value.att_txt, SRDefDat.Hull.HullEffTo );

       strcpy( coll[9].name, SIR_CNTX_TYP );
       coll[9].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[9].desc.value.att_txt, SRDefDat.CntxTyp);

       strcpy( coll[10].name, SIR_CNTX_NAME );
       coll[10].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[10].desc.value.att_txt, SRDefDat.Cntxt.CntxtName );

       strcpy( coll[11].name, SIR_CNTX_ID );
       coll[11].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[11].desc.value.att_txt, SRDefDat.Cntxt.CntxtId );

       strcpy( coll[12].name, SIR_CNTX_DESC );
       coll[12].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[12].desc.value.att_txt, SRDefDat.Cntxt.CntxtDesc );

       strcpy( coll[13].name, SIR_MODCX_ID );
       coll[13].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[13].desc.value.att_txt, ModCxId);

       /* for CR #  179801371 */
       strcpy( coll[14].name, SIR_FILE_TYP );
       coll[14].desc.type = AC_ATTRIB_DOUBLE;
       coll[14].desc.value.att_exp = SRDefDat.FileTyp;

       
       /*to generate UID, sequence no is needeed, store it in collector*/
       strcpy( coll[15].name, SIR_SEQ_NO );
       coll[15].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[15].desc.value.att_txt, "1");
       
       status = _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
				    &msg,
				    16,
				    coll ) );
       __DBGpr_com("added sequence no to default dir");
       CheckRC( status, msg );
       if( CfgItmGlbl )
	 _FREE( CfgItmGlbl );
       if( HullGlbl )
	 _FREE( HullGlbl );
       if( CntxtGlbl )
	 _FREE( CntxtGlbl ); 
       
       __DBGpr_str("Saving file", filename);
       status = ex$save_module( ftype = EX_visible, filename = filename );
       if (status != 1)
       {
         UI_status("WARNING!! Design file not saved ");
       }
       resp = VD_FORM_ACCEPT;
       ex$putque( msg  = &msg, response = &resp );
       FIf_erase((Form)form_ptr);
       UI_status( " " );

       /* Add the call to update the NFM attributes */
       status = SrVDUpdCMattrs( refresh->act_catalog, refresh->act_partid,
                                refresh->act_revision, "p_incpartrpt", "Y");
       if(status)
         printf("\n problem with SrVDUpdCMattrs");
       __DBGpr_com("Breaking");
       break;
       clean :
         __DBGpr_com("Cleaning");
         if((len == 0 ) || ( len == 1 ))
         {
           FIfld_set_text( (Form)form_ptr,
               FI_MSG_FIELD, 0, 0, "All fields must be set",FALSE);
           FIg_reset( (Form)form_ptr, FI_ACCEPT);
           status = OM_E_ABORT;
         }
       break;


   case G_TG_FILE_TYP: // for arrangement toggle
       //Clear all selected gadgets cr # 179801371
       FIg_disable( (Form)form_ptr, G_VEW_CFG_DESC );
       FIg_disable( (Form)form_ptr, G_VEW_HULL_DESC );
       FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC );
       FIg_disable( (Form)form_ptr, G_SEL_HULL);
       FIg_disable( (Form)form_ptr, G_SEL_CTX_TYP );
       FIg_disable( (Form)form_ptr, G_SEL_CTX);
       FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CFG_ITM, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CFG_DESC, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_HULL, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_HULL_DESC, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE );
       UI_status( ""); 
       FIfld_set_text( (Form)form_ptr,
	   FI_MSG_FIELD, 0, 0, 
	   "Select Configuration Item.", FALSE );
       //set context `list to zero cr # 179801371
       FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0);
       break;

   default:
       break;
  } // end switch(gadget_label)
wrapup :
  End
  return 1;
}

/* Added to sort DAD form  CR#179802232  Shailesh*/
void swap(int st_2_sort, int i, int j)
{
  struct VDPCntxt ctx;
  struct VDPhulls hll;
  struct VDPCfgItms cfg; 
  
  switch(st_2_sort)
  {
   case 1:	// Cfg items
       cfg = CfgItmGlbl[i];
       CfgItmGlbl[i] = CfgItmGlbl[j];
       CfgItmGlbl[j] = cfg;
       break;
   
   case 2:	//Hulls
       hll = HullGlbl[i];
       HullGlbl[i] = HullGlbl[j];
       HullGlbl[j] = hll;
       break;
   
   case 3:	//contexts
       ctx = CntxtGlbl[i];
       CntxtGlbl[i] = CntxtGlbl[j];
       CntxtGlbl[j] = ctx;
       break;
   
   default:
       break;
  }
}

/* Added to sort the list shown in DAD form CR#179802232 Shailesh*/
int AIMqsort(int st_to_sort, int left, int right)
{
  int		i, last;

  if ( left >= right )
    return 1;
  
  swap ( st_to_sort, left, ( left + right)/2);
  last = left; 
  
  switch(st_to_sort)
  {
   case 1:	// Configuration items Sort by Congif Name
       for ( i = left+1; i<= right; i++ )
	 if (strcasecmp(CfgItmGlbl[i].CfgName, CfgItmGlbl[left].CfgName) < 0 )
	   swap(st_to_sort, ++last, i); 
       
       swap(st_to_sort, left, last);
       AIMqsort(st_to_sort, left, last-1);
       AIMqsort(st_to_sort, last+1, right);
       break;
   
   case 2:	//Hulls Sorted bu Hull Name
       for ( i = left+1; i<= right; i++ )
	 if (strcasecmp(HullGlbl[i].HullName, HullGlbl[left].HullName) < 0 )
	   swap(st_to_sort, ++last, i); 
       
       swap(st_to_sort, left, last);
       AIMqsort(st_to_sort, left, last-1);
       AIMqsort(st_to_sort, last+1, right);
       break;
   
   case 3:	//Contexts Sorted by Context Name
       for ( i = left+1; i<= right; i++ )
	 if (strcasecmp(CntxtGlbl[i].CntxtName, CntxtGlbl[left].CntxtName) < 0 )
	   swap(st_to_sort, ++last, i); 
       
       swap(st_to_sort, left, last);
       AIMqsort(st_to_sort, left, last-1);
       AIMqsort(st_to_sort, last+1, right);
       break;
   
   default:
       break;
  }
  return 1; 

}

end implementation VDPCmdPMDef;
