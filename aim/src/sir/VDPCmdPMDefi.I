 /* --------------------------------------------------------------------
 * I/AIMSIR
 *
 * File:        aim/src/sir/VDPCmdPMDefi.I
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
#define vaimDEBUG
#define vaimerrDEBUG
*/

#define VDP_ERROR       2
#define NB_ITEMS_IN_COLL 7

#define VDP_GET_REV  	121
#define VDP_UPDATE_HA  	128

#include <stdio.h>
#include "string.h"
#include "stdlib.h"

#include "griomacros.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"

#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"

#include "vdparmacros.h"
#include "vdbmacros.h"
#include "VDtypedef.h"

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
#include "VDSutil.h"

#include "vdbmacros.h"
#include "VDPtrTbl.h"
#include "SQLerrordef.h"
#include "PDMmacros.h"

#include "VDrisc.h"  // SAUBY, added for PDMInsertSirTable

#define FILE_PRINT	if (dm2_err) fprintf

from ACrg_collect import ACset_list_attribute, ACget_named_attribute, ACmod_list_attribute;
from VDSroot import ACgive_db_structure;
from VDPenabObj import VDPgetPMenabledList;
from VDPenabObj import VDPIsObjEnabled;
from VDPtrTbl           import VDPAddtoTrTable;
from VDPtrTbl           import VDPinit;
from VDPtrTbl		import VDPprintTransTable;

extern struct PDUrefresh	*refresh;
extern long VDPgetCfgItms ();
extern int VDgetSrError( );
extern int SirVDUpdCMAttrs();

extern int itoa();
extern int VDPGetRevFromOBID(); 
//extern fprintf();

extern VDPPutAimInfo();
extern VDPGetAimInfo();

#define CLIX_DISCONNECT -2
#define XX_LEN 256

%safe
static char   CfgNameGbl[XX_LEN];
static struct SRReqDat SRDefDat;
static int    VDnbCfgGbl = 0;
static struct VDPCfgItms *CfgItmGlbl=NULL;
static struct VDPhulls   *HullGlbl = NULL;
static int    nbHull  = 0;
static int    nbCntxt = 0;
static struct VDPCntxt   *CntxtGlbl = NULL;
/* static char   ModCxId[30]; */ /*  commented 06/07/2000 */

static char   ModCxId[XX_LEN]; 
static char   ModCxRev[XX_LEN];

static char lpdval[XX_LEN];   /* added code Pullabhotla 15/06/2000 */
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
    IGRint		diagCtl;
    int			i, nbCfgItm = 0;

    char LpdDesc[XX_LEN]; 
    static char LpdtempDesc[XX_LEN];
    static char LpdValue[XX_LEN];
    static char LpdValue_New[XX_LEN];
    static char *lpdvalue[XX_LEN];
    static char aim_user1[XX_LEN], aim_server1[XX_LEN], aim_env1[XX_LEN];
    int j = 0;
    int count1=0, count2=0;
    int number=0, dstat = 0;
    int next;
    int k;
    int row, pos, sel;
    char Lpdtempvar[XX_LEN];
    char *text1;
    
    Form			VD_FP1, old_form;

   
    SetProc( VDCmdPMDef.VDPInitForm ); Begin
    *sts = VD_SUCCESS;
    old_form = NULL;
    
    LpdDesc[0] = '\0'; 
    
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
/* added code Pullabhotla 21/06/2000 */
   
 VDPGetAimInfo(aim_user1, aim_server1, aim_env1);

  
  FIfld_set_text( VD_FP, G_SERV_NAME, 0, 0, aim_server1, TRUE);

  FIg_disable(VD_FP, G_SERV_NAME); 
  
  FIfld_set_text( VD_FP, G_AIM_ENVI, 0, 0, aim_env1, TRUE);

  FIg_disable(VD_FP, G_AIM_ENVI);
  status = PDMReadHullApp(refresh->act_catalog, refresh->act_partid, 
   	                 refresh->act_revision, lpdvalue);

  if(status == 1)
  {
   EX_error_box( FI_CURRENT_SCREEN,
       		   "Hull Applicability is not set properly", 
		   		   "Contact Administrator"); 
   me->state = _terminate;
   return OM_S_SUCCESS;
  }

  
  for(i=0;i<=11;i++)
  {
    LpdValue[0] = '\0';
    strncpy(LpdValue, lpdvalue[i], 1);

  if(!strcmp(LpdValue,""))
  {
     count2 = count2 + 1;
  }
         
  if(count2)
   {
      EX_error_box( FI_CURRENT_SCREEN, "Hull Applicability is not set properly", 	                               "Contact Administrator"); 
      me->state = _terminate;
      return OM_S_SUCCESS;
   }
    
    if(!strcmp(LpdValue,"Y"))
    {

     number  = number + 1;
      sprintf(LpdtempDesc,"%d",j+17);
      
      if(number>1)
      {
        strcat(LpdDesc, ",");
      }
      strcat(LpdDesc, LpdtempDesc);
      if(!strcmp(LpdtempDesc, "28"))
       strcat(LpdDesc, "AF");

    }

   if(!strcmp(LpdValue,"N"))
   {
    count1 = count1 + 1;
   }
  

   if(count1 == 12)
   {
        EX_error_box( FI_CURRENT_SCREEN,
	               "Hull Applicability is not set properly", 
		       "Contact Administrator"); 
        me->state = _terminate;
        return OM_S_SUCCESS;
   }

     j++;
 }
  

	FIfld_set_text( VD_FP, G_HULL_APP, 0, 0, LpdDesc, TRUE);

	FIg_disable( VD_FP, G_HULL_APP );
	
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

       if( diagCtl == 1)   // file type 2D
       {
	 FIfld_set_list_text(VD_FP,
	     G_SEL_CTX_TYP, 0,0,
	     SR_FSI, FALSE);
	 FIfld_set_list_text(VD_FP, 
	   G_SEL_CTX_TYP, 1,0,
	   SR_SUB_FSI, FALSE);
       }
       else if (diagCtl == 0 )
       {
	 FIfld_set_list_text( VD_FP,
	     G_SEL_CTX_TYP, 0,0, 
	     SR_ZNSYS, FALSE);
	 FIfld_set_list_text( VD_FP,
	     G_SEL_CTX_TYP, 1,0, 
	     SR_ZONE, FALSE);
	 FIfld_set_list_text( VD_FP,
	     G_SEL_CTX_TYP, 2,0, 
	     SR_UNIT, FALSE);
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
 /*   FIg_disable( VD_FP1, G_VEW_CFG_DESC );
    FIg_disable( VD_FP1, G_VEW_HULL_DESC ); */  /* pullabhotla 21/06/2000 */
 /*   FIg_disable( VD_FP1, G_VEW_CTX_DESC ); */

        /* Collector does not exist */


   /* pullabhotla 21/06/2000 commented */
    
        /* Query the database for required PME data and fill the form */
 /*   UI_status( "Querying AIM database ..." );
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
*/
    FIf_display ( VD_FP1 );	// SSR 3 Dec
  
    
    /* TR no 984 DIsable is D S P = ON */
    if(diagCtl == 1)
      FIg_disable( VD_FP1, G_TG_FILE_TYP );

    // Dec 4 SSR added foll to avoid unstable form
  /*  FIfld_set_text( VD_FP1, G_SEL_CFG_ITM, 0, 0, "", FALSE ); */ 
    /* pullabhotla 21/06/2000 */
    
    FIg_erase(VD_FP1,G_VEW_GRP );
    UI_status ( "");
    FIfld_set_text( VD_FP1, FI_MSG_FIELD, 0, 0,
	"Select Context", FALSE );
    __DBGpr_com( " displayed and erased gadget sets ");
    FIg_display( VD_FP1, G_SEL_GRP );

 /*   for ( i = 0; i < nbCfgItm; i++ )
      FIfld_set_list_text( VD_FP1, G_SEL_CFG_ITM, i, 0,
	  CfgItmGlbl[i].CfgName, FALSE );
    __DBGpr_com( " Set cfg names in form"); */
    
    //FIg_disable( VD_FP1, G_SEL_HULL );
    //FIg_disable( VD_FP1, G_SEL_CTX_TYP );
    //FIg_disable( VD_FP1, G_SEL_CTX );
    FIg_erase( VD_FP1, G_TIT_SYS );
    FIg_erase( VD_FP1, G_TIT_ZONE );
    FIg_erase( VD_FP1, G_TIT_UNIT );
    FIg_erase( VD_FP1, G_BTN_QRY_CTX );
    FIg_erase( VD_FP1, G_FLD_PREFX );


    FIg_erase( VD_FP1, G_FLD_MULTICOL );
    FIg_erase( VD_FP1, G_TEXT_HSC );
    FIg_erase( VD_FP1, G_TEXT_ZONE );
    FIg_erase( VD_FP1, G_TEXT_UNIT);

    FIg_erase( VD_FP1, G_TEXT_CONTEXTS );
    FIg_erase( VD_FP1, G_TEXT_CONTDESC );
    FIg_erase( VD_FP1, G_TEXT_REV);
    FIg_erase( VD_FP1, G_TEXT_CONTAPP );
    FIg_erase( VD_FP1, G_FLD_CONTAPP);
    FIg_erase( VD_FP1, G_TEXT_ZONESYS);

  }
  else
  { 
	/* Read the collector and update the form */

    status  = _VD_SEND_MY ( VDPCmdPMDef.VDPGetDefaults ( &msg ) );
    CheckRC( status, msg ); 
    
    UI_status ( " Default Data already Set ");
    FIg_erase( VD_FP1, G_SEL_GRP );
    FIg_display( VD_FP1, G_VEW_GRP );
    FIg_disable(VD_FP1, 1 );
    FIg_disable(VD_FP1, G_TG_FILE_TYP); // CR # 17801371 SSR

    FIg_disable(VD_FP1, G_TG_ASSEM_FILE); // TLS 01/23/02 - AMDC Enhancements 

    	FIg_erase( VD_FP, G_FLD_CONTAPP );
	FIg_erase( VD_FP, G_TEXT_CONTAPP );
	FIg_erase( VD_FP, G_TEXT_ZONE );
	FIg_erase( VD_FP, G_TEXT_UNIT );
	FIg_erase( VD_FP, G_TEXT_ZONESYS );
	FIg_erase( VD_FP, G_TIT_ZONE );
	FIg_erase( VD_FP, G_TIT_UNIT );
	FIg_erase( VD_FP, G_TIT_SYS );
	FIg_erase( VD_FP, G_BTN_QRY_CTX );
	FIg_erase( VD_FP, G_FLD_PREFX );
	FIg_erase( VD_FP, G_TEXT_HSC );

       text1 = (char *) malloc (sizeof (char) * 15 );
       memset(text1,NULL,sizeof (char) * 15);

    FIfld_get_text(VD_FP, G_VEW_CTX_TYP , 0, 0, 15, (unsigned char *)text1, 
                 &sel, &pos);

  	if( !strcmp(text1, SR_FSI) || !strcmp(text1, SR_SUB_FSI) )
	     FIg_display( VD_FP, G_TEXT_HSC );
	 
	if( !strcmp(text1, SR_ZONE) ) 
	          FIg_display( VD_FP, G_TEXT_ZONE );   
	
	if( !strcmp(text1, SR_ZNSYS) ) 
	          FIg_display( VD_FP, G_TEXT_ZONESYS );   
	
	if( !strcmp(text1, SR_UNIT) ) 
	          FIg_display( VD_FP, G_TEXT_UNIT ); 
	
	goto wrapup;

	} // ens sir
	wrapup:

	End
	return OM_S_SUCCESS;

}
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
   struct ACrg_coll	coll[NB_REQ_DATA_VALUES + 20];

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
   IGRchar		CtxTypeName[VDPNAME_LEN + 128];

   char searchst[XX_LEN], ctxrev[XX_LEN], ctxrev_value[XX_LEN];
   char **bufst;
   int num;
   int status1=0, sts=1;
   

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
 /*  strcpy( coll.name, SIR_CFG_NAME );
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
 */  

   strcpy( coll.name, SIR_CNTX_NAME );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Name ", coll.desc.value.att_txt );

 /* FIfld_set_text( VD_FP, G_VEW_CTX, 0, 0, coll.desc.value.att_txt, FALSE );
   */
 
  FIfld_set_text( VD_FP, G_FLD_MULTICOL, 0, 0, coll.desc.value.att_txt, FALSE );
  
/* to query ctxrev from PDU --  07/07/2000 */
   

   strcpy( coll.name, SIR_CNTX_DESC );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Desc. ", coll.desc.value.att_txt );

 /*  FIfld_set_text( VD_FP, G_VEW_CTX_DESC, 0, 0, coll.desc.value.att_txt, FALSE ); */

  FIfld_set_text( VD_FP, G_FLD_MULTICOL, 0, 2, coll.desc.value.att_txt, FALSE );

    FIg_disable( VD_FP, G_FLD_MULTICOL );
   
   strcpy( coll.name, SIR_CNTX_TYP );
   status =
   _VD_SEND_OBJ( me->CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
   __CheckRC( status, *msg, "ACget_named_attribute", wrapup );
   __DBGpr_str( "Context Type ", coll.desc.value.att_txt );

/*   FIfld_set_text( VD_FP, G_VEW_CTX_TYP, 0, 0, coll.desc.value.att_txt, FALSE ); */

    FIfld_set_text( VD_FP, 21, 0, 0, coll.desc.value.att_txt, FALSE );

    

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
     /* TLS 01/23/02 - AMDC Enhancements */
     FIg_set_state_off( VD_FP, G_TG_ASSEM_FILE);
   }
   else
   {
     if ( coll.desc.value.att_exp == A_FILE )
     {
       FIg_set_state_on( VD_FP, G_TG_FILE_TYP);
       /* TLS 01/23/02 - AMDC Enhancements */
       FIg_set_state_off( VD_FP, G_TG_ASSEM_FILE);
     }
     else
     {
       FIg_set_state_off( VD_FP, G_TG_FILE_TYP);
       /* TLS 01/23/02 - AMDC Enhancements */
       if ( coll.desc.value.att_exp == ASM_FILE )
       	 FIg_set_state_on( VD_FP, G_TG_ASSEM_FILE);
       else
         FIg_set_state_off( VD_FP, G_TG_ASSEM_FILE);
     }
   }

	sprintf(searchst, "pdu_catalog = '%s' and pdu_part = '%s' and pdu_revision = '%s'", refresh->act_catalog, refresh->act_partid, refresh->act_revision); 

 __DBGpr_str("Searchst is", searchst);
 
     status1 =
          vdb$RisSelect(select="ctx_rev",
                        table_name = "SIR_PDM_TABLE", 
    		        where = searchst,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufst);
     
 if(status1 != 1 || num == 0)
                return 1;

    sts = vdb$RisExtractValue( nbrows = num,
                               nbcolumns = 1,
			       buffer = bufst,
			       row = 0,
			       column = 0,
			       value = ctxrev_value);


       vdb$RisFreeBuffer( buffer = bufst, size = 1 * num );     
         
          FIfld_set_text( VD_FP, G_FLD_MULTICOL, 0, 1, ctxrev_value, FALSE );
	   
    
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
        char        inbuf[20], srerrmsg[70];
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
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
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
  char		*outbuf, *errmsg = 0, srerrmsg[70];

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
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }

    if(mfail != 0)
    {
        if(!errmsg || (errmsg && !errmsg[0]))
            errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
        UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
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
  char 		inbuf[100], srerrmsg[70];
  int 		inlen = 0, index = 0, dstat, mfail, outlen = 0, i = 0;
  char          *outbuf, *errmsg = 0;
  IGRlong	status = OM_S_SUCCESS;

  char *lpdvalue[12];
  int j, k=0, number=0;
  char LpdDesc[50]; 
  static char LpdtempDesc[2];
  static char LpdValue[1];
  char Lpdtempvar[5];
  
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

  status = PDMReadHullApp(refresh->act_catalog, refresh->act_partid, 
        	                 refresh->act_revision, lpdvalue);
 
  for(j=0;j<=11;j++)
   {
      LpdValue[0] = '\0';
      strncpy(LpdValue, lpdvalue[j], 1);

      if(!strcmp(LpdValue,"Y"))
          {

	   number  = number + 1;
	    sprintf(LpdtempDesc,"%d",k+17); 

	   if(number>1)
	     {
	           strcat(LpdDesc, ",");
	     }
	           strcat(LpdDesc, LpdtempDesc);
		   if(!strcmp(LpdtempDesc, "28"))
		    strcat(LpdDesc, "AF");

	   }

	k++;
   }
    
  strcpy(&inbuf[index], LpdDesc );
  inlen = inlen + strlen( LpdDesc ) + 1 ;
  index = inlen;
  __DBGpr_str(" LpdDesc ", LpdDesc);

  dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                        inbuf,
                                        &outlen,
                                        &outbuf,
                                        &mfail,
                                        &errmsg );
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    if(mfail != 0)
    {
        if(!errmsg || (errmsg && !errmsg[0]))
            errmsg="No error msg but should be";
        if ( strlen(errmsg ) > 63 )
           errmsg[63] = '\0';
        UI_status( errmsg );
	printf("mfail = <%d>\n", mfail);
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

		(*Cntxts)[i].CntxtRev[0] = '\0';
		(*Cntxts)[i].CntxtApp[0] = '\0';
		
                
                strcpy((*Cntxts)[i].CntxtId, &outbuf[index1]);
                index1 = index1 + strlen((*Cntxts)[i].CntxtId) +1;
                __DBGpr_str ("CntxtId", (*Cntxts)[i].CntxtId );

                strcpy((*Cntxts)[i].CntxtName, &outbuf[index1]);
                index1 = index1 + strlen((*Cntxts)[i].CntxtName) +1;
                __DBGpr_str ("CntxtName", (*Cntxts)[i].CntxtName );

                strcpy((*Cntxts)[i].CntxtDesc, &outbuf[index1]);
                index1 = index1 + strlen((*Cntxts)[i].CntxtDesc) +1;
                __DBGpr_str ("CntxtDesc", (*Cntxts)[i].CntxtDesc );

	         strcpy((*Cntxts)[i].CntxtRev, &outbuf[index1]);
		 index1 = index1 + strlen((*Cntxts)[i].CntxtRev) +1;
		 __DBGpr_str ("CntxtRev", (*Cntxts)[i].CntxtRev );

		 strcpy((*Cntxts)[i].CntxtApp, &outbuf[index1]);
		  index1 = index1 + strlen((*Cntxts)[i].CntxtApp) +1;
		 __DBGpr_str ("CntxtApp", (*Cntxts)[i].CntxtApp );
		
    }

    AIMqsort(5, 0, *nbCntxt-1); // CR#179802232 Jan 19 SSR
wrapup:

return OM_S_SUCCESS;
}

int VDPqueryModCxId(long	*msg,
			char	*ModCxId1, char *ModCxRev1 )
{
  int		i, inlen = 0, code, index = 0, outlen, dstat,mfail,j;
  char		inbuf[200];
  char		*outbuf =  NULL, *errmsg = NULL;
  char		FileName[257], FileTyp[4], srerrmsg[200];
  int		diagCtl;
  IGRlong	status = OM_S_SUCCESS;
  char 		searchst[128], partdesc_value[130];
  char 		**bufst;
  int 		num;
  int 		status1=0, sts=1;
  int           nbItems=0;

  SetProc( VDPqueryModCxId ); Begin

  *msg = MSSUCC;

  for( i = 0; i<100; i++) inbuf[i] = '\n';

  /* TLS 01/23/02 - AMDC Enhancements */
  //Moved this code up so that the command code to reflect the correct Design Context to 
  //create in AIM.  Which Design Context to create is based on the file type.

  FileTyp[0] = '\0';
  if(SRDefDat.FileTyp == 0)
    strcpy(FileTyp, "M");
  else if(SRDefDat.FileTyp == 1)
    strcpy(FileTyp, "D");
  else if(SRDefDat.FileTyp == 2)
    strcpy(FileTyp, "A");
  else if(SRDefDat.FileTyp == 3)
    strcpy(FileTyp, "ASM");

  if(SRDefDat.FileTyp == 3)
  	code = VDP_CREATE_AMDC;
  else
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


   /* Add Hull obid foe new DAD*/
/*   strcpy(&inbuf[index], SRDefDat.Hull.HullId);
   inlen += strlen( SRDefDat.Hull.HullId) + 1;
   index = inlen;
  __DBGpr_str(" HullId ", SRDefDat.Hull.HullId);
  */ 
  strcpy( &inbuf[index], FileTyp );
  inlen += strlen(FileTyp) +1;
  index = inlen;
  __DBGpr_str(" filetyp ", FileTyp);

    strcpy( &inbuf[index], refresh->act_catalog );
    __DBGpr_str("Catalog", refresh->act_catalog );
    inlen += strlen(refresh->act_catalog) + 1;
    index = inlen;

    strcpy( &inbuf[index], refresh->act_partid );
    __DBGpr_str("Part ID", refresh->act_partid );
    inlen += strlen(refresh->act_partid) + 1;
    index = inlen;

    strcpy( &inbuf[index], refresh->act_revision );
    __DBGpr_str("Part Revision ", refresh->act_revision );
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

    strcpy( &inbuf[index], SRDefDat.Cntxt.CntxtApp );
    __DBGpr_str(" VDPCntxt.CntxtApp", SRDefDat.Cntxt.CntxtApp );
    inlen += strlen(SRDefDat.Cntxt.CntxtApp) + 1;
    index = inlen;
    
    //CR 1793
    /*
    strcpy( &inbuf[index], refresh->act_description);
   __DBGpr_str("Part Description", refresh->act_description );
    inlen += strlen(refresh->act_description) + 1;
    index = inlen;
    */

    //TLS 05-29-02 Fix TR 5971 for Part Description
    searchst[0] = '\0';
    sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'", refresh->act_partid, refresh->act_revision); 

     __DBGpr_str("Searchst is", searchst);
 
     status1 =
          vdb$RisSelect(select="n_itemdesc",
                        table_name = refresh->act_catalog, 
    		        where = searchst,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufst);
     if(status1 != 1 || num == 0 )
     {
	strcpy( &inbuf[index], refresh->act_description);
   	__DBGpr_str("Part Description", refresh->act_description );
    	inlen += strlen(refresh->act_description) + 1;
    	index = inlen;	
     }
     else
     {
	sts = vdb$RisExtractValue( nbrows = num,
                               nbcolumns = 1,
			       buffer = bufst,
			       row = 0,
			       column = 0,
			       value = partdesc_value);


     	vdb$RisFreeBuffer( buffer = bufst, size = 1 * num );

	strcpy( &inbuf[index],partdesc_value );
   	__DBGpr_str("Correct Part Description", partdesc_value);
    	inlen += strlen(partdesc_value) + 1;
    	index = inlen;
     }
    
 /*   strcpy( &inbuf[index], SRDefDat.CfgItm.CfgId );
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

    if ( mfail != 0 )
    {
      status = VDgetSrError( mfail, srerrmsg );
      UI_status ( srerrmsg );
      ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
      printf("mfail = <%d>\n", mfail);
      return OM_E_ABORT;
    }
    if(dstat == 12345 )
    {
	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        return 0;
    }
    
   __DBGpr_int("dstat:", dstat );
   __DBGpr_int("mfail:", mfail );
   __DBGpr_str("errmsg:", errmsg );

    /* The number of File Id's is returned */
  /*  index = sizeof(int);
    strcpy( ModCxId, &outbuf[index] );
    index = strlen(ModCxId) + 1; */


   index = 0;
   
   memcpy( &nbItems, &outbuf[index], sizeof(int) ); 
   index = index + sizeof(int);   

			        
	                 
   if(outbuf[0]!='\0')
     {
      	 for(i=0; i< outlen; i = i + 1)
       __DBGpr_com("Allocating memory for the Attributes");

       __DBGpr_int("length", strlen(&outbuf[index])); 

  /* *ModCxId1 = _MALLOC(strlen(&outbuf[index]), char);  */
	        
    if(ModCxId1) strcpy(ModCxId1, &outbuf[index] );
      index = index + strlen(ModCxId1) + 1;
   

  /*  *ModCxRev1 = _MALLOC(strlen(&outbuf[index]), char);  */
    	        
    if(ModCxRev1) strcpy(ModCxRev1, &outbuf[index] );
    index = index + strlen(ModCxRev1) + 1;
	         
   
     }

    End
    return OM_S_SUCCESS;
}


int sir_form_notification( int             form_label,
			int             gadget_label,
			double          value,
			char            *form_ptr)
{
int		sel, i, pos, len, FilTypOpt, FileType = 0;
/* TLS 01/23/02 - AMDC Enhancements */
int		FilTypOpt1, chkTgOpt, ISDPFileType = 0;
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

char            tablename[20], column[10], value1[5], string1[30];
int             row, col;
char            *text1;

SetProc( sir_form_notification ); Begin

  __DBGpr_int( " gadget_label ", gadget_label); 
  __DBGpr_int( " form_label ", form_label);

  /* added Pullabhotla 05/06/200 */

  value = 0.0;
  form_label = 0;

  /* for(i =0; i< 80; i++) CfgName[i] = '\0';
  for(i =0; i< 80; i++) HullName[i] = '\0';
  for(i =0; i< 119; i++) HullDesc[i] = '\0';  */
  
/*  switch(gadget_label)
  { */
  /* case G_SEL_CFG_ITM : // select config item gdget

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
       
       break;  */  // case 17

/*   case FI_CANCEL : 
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
       break;   */
   
/*   case G_SEL_HULL : // select hulll
   
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
       }  */
       
    /*   FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );  */
       
      
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

////START HERE

       status = VDgetDiagCtlPar(&msg, &diagCtl ); 

       FIg_get_state((Form)form_ptr, G_TG_FILE_TYP, &FilTypOpt );

       /* TLS 01/23/02 - AMDC Enhancements */
       FIg_get_state((Form)form_ptr, G_TG_ASSEM_FILE, &FilTypOpt1 );

       if( FilTypOpt )
	 FileType = A_FILE;
       else
       {
         /* TLS 01/23/02 - AMDC Enhancements */
         if( FilTypOpt1 )
	 {
	   FileType = ASM_FILE;
           ISDPFileType = diagCtl;
         }
	 else
	   FileType = diagCtl;
       }

       SRDefDat.FileTyp = FileType;

       switch ( FileType )
       {
        /* TLS 01/23/02 - AMDC Enhancements */
	case ASM_FILE:
	    if( ISDPFileType == D_FILE ) 
	    {
	    	FIfld_set_list_text((Form)form_ptr,
			G_SEL_CTX_TYP, 0,0,
			SR_SUB_FSI, FALSE);
	    	FIfld_set_list_text((Form)form_ptr,
			G_SEL_CTX_TYP, 1,0,
			SR_FSI, FALSE);
	    }
	    
	    if( ISDPFileType == M_FILE ) 
	    {
	    	FIfld_set_list_text( (Form)form_ptr,
			G_SEL_CTX_TYP, 0,0, 
			SR_UNIT, FALSE);
	    	FIfld_set_list_text( (Form)form_ptr,
			G_SEL_CTX_TYP, 1,0, 
			SR_ZONE, FALSE);
	    }
	    break;
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
       
  /*   FIg_disable( (Form)form_ptr, G_SEL_CTX);
       FIfld_set_text( (Form)form_ptr,
       FI_MSG_FIELD, 0, 0, "Select Context Type", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE ); */

/////GADGET SELECTION STARTS HERE

  switch(gadget_label)
  {
   
   case G_SEL_CTX_TYP : // select context type

    /* FIg_enable( (Form)form_ptr, G_SEL_CTX_TYP); 
       FIg_disable( (Form)form_ptr, G_SEL_CTX );  
       FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC ); */

       FIg_erase( (Form)form_ptr, G_TIT_SYS );
       FIg_erase( (Form)form_ptr, G_TIT_ZONE );
       FIg_erase( (Form)form_ptr, G_TIT_UNIT );
       FIg_erase( (Form)form_ptr, G_BTN_QRY_CTX );
       FIg_erase( (Form)form_ptr, G_FLD_PREFX );
 

       FIg_erase( (Form)form_ptr, G_FLD_MULTICOL);
       FIg_erase( (Form)form_ptr, G_TEXT_HSC);
       FIg_erase( (Form)form_ptr, G_TEXT_ZONE);
       FIg_erase( (Form)form_ptr, G_TEXT_UNIT);
       
       FIg_erase( (Form)form_ptr, G_TEXT_CONTEXTS);
       FIg_erase( (Form)form_ptr, G_TEXT_CONTDESC);
       FIg_erase( (Form)form_ptr, G_TEXT_REV);
       FIg_erase( (Form)form_ptr, G_TEXT_CONTAPP);
       FIg_erase( (Form)form_ptr, G_FLD_CONTAPP);
       FIg_erase( (Form)form_ptr, G_TEXT_ZONESYS); 
       

    /*   FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE ); */

       
       FIfld_get_text((Form)form_ptr,
	   G_SEL_CTX_TYP, 0, 0, 
	   VDPDESC_LEN, (unsigned char *)CntxType, 
	   &sel, &pos );
       strcpy(SRDefDat.CntxTyp, CntxType);
       
       if(!strcmp(SRDefDat.CntxTyp, SR_FSI) ||
          !strcmp(SRDefDat.CntxTyp, SR_SUB_FSI))
           FIg_display( (Form)form_ptr, G_TIT_SYS );
       
       if(!strcmp(SRDefDat.CntxTyp, SR_ZONE) ||
          !strcmp(SRDefDat.CntxTyp, SR_ZNSYS))
        FIg_display( (Form)form_ptr, G_TIT_ZONE );

       if( !strcmp(SRDefDat.CntxTyp, SR_UNIT) )
	FIg_display( (Form)form_ptr, G_TIT_UNIT );

       FIg_display( (Form)form_ptr, G_BTN_QRY_CTX );
       
       FIg_display( (Form)form_ptr, G_FLD_PREFX );
       FIfld_set_text( (Form)form_ptr, G_FLD_PREFX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr,
           FI_MSG_FIELD, 0, 0, "Enter prefix and/or Query Contexts.", FALSE );

    break;

  case FI_CANCEL : 
       
  /*    if( CfgItmGlbl )
      _FREE( CfgItmGlbl );
       if( HullGlbl )
       _FREE( HullGlbl );
	if( CntxtGlbl )
	_FREE( CntxtGlbl ); €
			       //if( SRDefDat )
			       //   // _FREE( SRDefDat );
			       */

        resp = VD_FORM_CANCEL;			                        	   
	ex$putque( msg  = &msg,response = &resp );
	  
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

        strcpy(SRDefDat.CntxTyp, CntxType); 

	status = VDPgetCntxts( &msg, CntxType, CntxPrFx, &nbCntxt, &CntxtGlbl );


	if(nbCntxt)
	{
        if( !strcmp(SRDefDat.CntxTyp, SR_FSI) ||
	            !strcmp(SRDefDat.CntxTyp, SR_SUB_FSI) )
	            FIg_display( (Form)form_ptr, G_TEXT_HSC );
	       
	if( !strcmp(SRDefDat.CntxTyp, SR_ZONE) ) 
	           FIg_display( (Form)form_ptr, G_TEXT_ZONE );    
	 
	 if(!strcmp(SRDefDat.CntxTyp, SR_ZNSYS))
	            FIg_display( (Form)form_ptr, G_TEXT_ZONESYS ); 

	if( !strcmp(SRDefDat.CntxTyp, SR_UNIT) )
	       	   FIg_display( (Form)form_ptr, G_TEXT_UNIT );

	}
	
/* in order to refresh the rows in CONTEXTS table */
	
       FIfld_get_list_num_rows( (Form)form_ptr, G_FLD_MULTICOL, 2, &row );
	
	if(row)
	{
	     FIfld_delete_rows( (Form)form_ptr, G_FLD_MULTICOL , 0, row );
	     FIfld_set_text( (Form)form_ptr, G_FLD_CONTAPP, 0, 0, "", FALSE );
	}
	
       FIfld_set_text( (Form)form_ptr,
           FI_MSG_FIELD, 0, 0,
           "Wait.... Querying SIR for Contexts", FALSE );

       __DBGpr_str("Cntxtype", CntxType);
       __DBGpr_str("CntxPrFx", CntxPrFx);

    /*   FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_CTX, 0, 0);
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE ); 
     status = VDPgetCntxts( &msg, CntxType, CntxPrFx, &nbCntxt, &CntxtGlbl ); 
     */ 
       
       FIg_set_state_off( (Form)form_ptr, G_BTN_QRY_CTX );
       if(nbCntxt == 0)
       {
         FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0,
             " No Contexts found ",0);
         UI_status( "" );

	 FIg_erase( (Form)form_ptr, G_FLD_MULTICOL );
	 FIg_erase( (Form)form_ptr, G_TEXT_CONTEXTS );
	 FIg_erase( (Form)form_ptr, G_TEXT_HSC );
	 FIg_erase( (Form)form_ptr, G_TEXT_ZONE );
	 FIg_erase( (Form)form_ptr, G_TEXT_UNIT );
	 FIg_erase( (Form)form_ptr, G_TEXT_REV );
	 FIg_erase( (Form)form_ptr, G_TEXT_CONTAPP );
	 FIg_erase( (Form)form_ptr, G_TEXT_CONTDESC );
	 FIg_erase( (Form)form_ptr, G_FLD_CONTAPP );
	 FIg_erase( (Form)form_ptr, G_TEXT_ZONESYS ); 
	   
         break;
         //goto wrapup;
       }

       __DBGpr_int( " number  of contexts is ", nbCntxt);
   
   /*    FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_CTX, 0, 0);
       for ( i = 0; i < nbCntxt; i++ )
         FIfld_set_list_text((Form)form_ptr,
             G_SEL_CTX, i, 0,
             CntxtGlbl[i].CntxtName, FALSE );
       __DBGpr_int( " nbctx ", nbCntxt );   
   */    

       
         for ( i = 0; i < nbCntxt; i++ )
	 { 
	  FIfld_set_text((Form)form_ptr, G_FLD_MULTICOL , i, 0,
				               CntxtGlbl[i].CntxtName, FALSE );
	        __DBGpr_int( " nbctx ", nbCntxt );   
      
	  FIfld_set_text((Form)form_ptr, G_FLD_MULTICOL, i, 1, 
	                                       CntxtGlbl[i].CntxtRev, FALSE);
	    
	 FIfld_set_text((Form)form_ptr, G_FLD_MULTICOL, i, 2, 
	     	                                CntxtGlbl[i].CntxtDesc, FALSE);
	 } 
       
     /*  FIg_enable(  (Form)form_ptr, G_SEL_CTX ); */

      FIg_display( (Form)form_ptr, G_TEXT_CONTEXTS );
      FIg_display( (Form)form_ptr, G_TEXT_CONTDESC );
      FIg_display( (Form)form_ptr, G_TEXT_REV );
      FIg_display( (Form)form_ptr, G_TEXT_CONTAPP );
      FIg_display( (Form)form_ptr, G_FLD_CONTAPP );
      FIg_display( (Form)form_ptr, G_FLD_MULTICOL );	
      
       
      FIg_enable( (Form)form_ptr, G_FLD_MULTICOL );	 
      FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, " Select Context",0);
       
       break;

       
    case  G_FLD_MULTICOL:
       
   FIfld_get_active_row( (Form)form_ptr, G_FLD_MULTICOL, &row, &pos);

   FIfld_set_text( (Form)form_ptr, G_FLD_CONTAPP, 0, 0, 
                    CntxtGlbl[row].CntxtApp, FALSE );

   FIg_disable( (Form)form_ptr, G_FLD_CONTAPP );

   strcpy(SRDefDat.Cntxt.CntxtName, CntxtGlbl[row].CntxtName);

   strcpy(SRDefDat.Cntxt.CntxtId, CntxtGlbl[row].CntxtId);
   strcpy(SRDefDat.Cntxt.CntxtRev, CntxtGlbl[row].CntxtRev);
   strcpy(SRDefDat.Cntxt.CntxtDesc, CntxtGlbl[row].CntxtDesc);

   
   FIfld_get_text_length( (Form)form_ptr, 17, 0, 0, &len ); 
   
   text1 = (char *) malloc (sizeof (char) * len );
   memset(text1,NULL,sizeof (char) * len);

   FIfld_get_text( (Form)form_ptr, 17, 0, 0, 40, (unsigned char *)text1, 
                    &sel, &pos);

   
   strcpy(SRDefDat.Cntxt.CntxtApp, text1);


       break;

   case FI_ACCEPT :

    /*   FIfld_get_text_length( (Form)form_ptr, G_SEL_CFG_ITM, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;

       FIfld_get_text_length( (Form)form_ptr, G_SEL_HULL, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean; */

       FIfld_get_text_length( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;

     /*  FIfld_get_text_length( (Form)form_ptr, G_SEL_CTX, 0, 0, &len );
       if((len == 0 ) || ( len == 1 )) goto clean;   */
 
        FIfld_get_text_length( (Form)form_ptr, G_FLD_MULTICOL, 0, 0, &len );
	        if((len == 0 ) || ( len == 1 )) goto clean;   
       
       UI_status( "Processing...." );
       /* Get the OBID of the associated Model Cntxt object */
       status = VDPqueryModCxId ( &msg,
			      ModCxId, ModCxRev ); 
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

       __DBGpr_str(" ModCxRev ", ModCxRev );

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
       /*create SIR_GLOBAL if it does not exist     */
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
     /*  strcpy( coll[0].name, SIR_CFG_NAME );
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
       strcpy( coll[8].desc.value.att_txt, SRDefDat.Hull.HullEffTo );  */

       strcpy( coll[0].name, SIR_CNTX_TYP );
       coll[0].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[0].desc.value.att_txt, SRDefDat.CntxTyp);

       strcpy( coll[1].name, SIR_CNTX_NAME );
       coll[1].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[1].desc.value.att_txt, SRDefDat.Cntxt.CntxtName );

       strcpy( coll[2].name, SIR_CNTX_ID );
       coll[2].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[2].desc.value.att_txt, SRDefDat.Cntxt.CntxtId );

       strcpy( coll[3].name, SIR_CNTX_DESC );
       coll[3].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[3].desc.value.att_txt, SRDefDat.Cntxt.CntxtDesc );

       strcpy( coll[4].name, SIR_MODCX_ID );
       coll[4].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[4].desc.value.att_txt, ModCxId);

       /* for CR #  179801371 */
       strcpy( coll[5].name, SIR_FILE_TYP );
       coll[5].desc.type = AC_ATTRIB_DOUBLE;
       coll[5].desc.value.att_exp = SRDefDat.FileTyp;

       
       /*to generate UID, sequence no is needeed, store it in collector*/
       strcpy( coll[6].name, SIR_SEQ_NO );
       coll[6].desc.type = AC_ATTRIB_TEXT;
       strcpy( coll[6].desc.value.att_txt, "1");
       
       status = _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
				    &msg,
				    7,
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
 
    /*   status = SrVDUpdCMattrs( refresh->act_catalog, refresh->act_partid,
                                refresh->act_revision, "ctxtype", 
	     		        SRDefDat.CntxTyp);


       status = SrVDUpdCMattrs( refresh->act_catalog, refresh->act_partid,
                                refresh->act_revision, "ctxnumber", 
  			        SRDefDat.Cntxt.CntxtName);

 
       status = SrVDUpdCMattrs( refresh->act_catalog, refresh->act_partid,
                                refresh->act_revision, "ctxrev", 
  			        SRDefDat.Cntxt.CntxtRev);


       status = SrVDUpdCMattrs( refresh->act_catalog, refresh->act_partid,
	                        refresh->act_revision, "mdcrev", 
				ModCxRev);
	*/			
       //Added by Anjani, 23Aug2000

       /* SAUBY, Insert attributes in SIR_PDM_TABLE here instead of at new
	* part creation. */

       PDMInsertSirTable(refresh->act_catalog,
	                 refresh->act_partid,
			 refresh->act_revision);
       
       status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
	  	                 refresh->act_revision, "mdc_rev", 
				 ModCxRev);
        status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
	  	                 refresh->act_revision, "ctx_rev", 
				 SRDefDat.Cntxt.CntxtRev);
	 status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
	  	                 refresh->act_revision, "ctx_name", 
				 SRDefDat.Cntxt.CntxtName);
	  status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
	  	                 refresh->act_revision, "ctx_type", 
				 SRDefDat.CntxTyp);
        
       if(status)
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
       //
     /*  FIg_disable( (Form)form_ptr, G_VEW_CFG_DESC ); 
       FIg_disable( (Form)form_ptr, G_VEW_HULL_DESC );  */
       
       //FIg_disable( (Form)form_ptr, G_VEW_CTX_DESC );
       //FIg_disable( (Form)form_ptr, G_SEL_HULL);
       //FIg_disable( (Form)form_ptr, G_SEL_CTX_TYP );
       //FIg_disable( (Form)form_ptr, G_SEL_CTX);
       
         FIg_erase( (Form)form_ptr, G_BTN_QRY_CTX);
	 FIg_erase( (Form)form_ptr, G_TEXT_HSC);
	 FIg_erase( (Form)form_ptr, G_TEXT_ZONE);
	 FIg_erase( (Form)form_ptr, G_TEXT_UNIT);
	 FIg_erase( (Form)form_ptr, G_TEXT_CONTEXTS);
	 FIg_erase( (Form)form_ptr, G_TEXT_CONTDESC);
	 FIg_erase( (Form)form_ptr, G_TEXT_REV);
	 FIg_erase( (Form)form_ptr, G_TEXT_CONTAPP);
	 FIg_erase( (Form)form_ptr, G_FLD_CONTAPP);
         FIg_erase( (Form)form_ptr, G_FLD_MULTICOL ); 
	 FIg_erase( (Form)form_ptr, G_TIT_ZONE );
	 FIg_erase( (Form)form_ptr, G_TIT_UNIT );
	 FIg_erase( (Form)form_ptr, G_FLD_PREFX );
	 FIg_erase( (Form)form_ptr, G_TEXT_ZONESYS ); 
    
       FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, "", FALSE );
       
    /* FIfld_set_text( (Form)form_ptr, G_SEL_CFG_ITM, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_CFG_DESC, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_SEL_HULL, 0, 0, "", FALSE );
       FIfld_set_text( (Form)form_ptr, G_VEW_HULL_DESC, 0, 0, "", FALSE ); 
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX, 0, 0, "", FALSE ); */

       FIfld_set_text( (Form)form_ptr, G_FLD_MULTICOL , 0, 0, "", FALSE ); 
       FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );
       
   /*  FIfld_set_text( (Form)form_ptr, G_VEW_CTX_DESC, 0, 0, "", FALSE ); */
       
       UI_status( ""); 
       FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, 
	               "Select Context", FALSE );

       //set context `list to zero cr # 179801371
    /*   FIfld_set_list_num_rows( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0); */
       
      status = VDgetDiagCtlPar(&msg, &diagCtl );
      
      if( !(status&msg&1) ||diagCtl ==-1)
      {
      	UI_status ("Design Setup Parameter Not Set ");
      	 __DBGpr_int(" diagCtl ", diagCtl);
     	/*  me->state = _terminate;  */
       	FIf_erase( (Form)form_ptr );
       	goto wrapup;
      }

      	/* TLS 01/23/02 - AMDC Enhancements */
      	//Make sure the Assemble Toggle is set to No if Arrangement toggle is set to Yes	
 	FIg_get_state((Form)form_ptr, G_TG_FILE_TYP, &chkTgOpt );

	if( chkTgOpt )
	{
	  FIg_set_state_off((Form)form_ptr, G_TG_ASSEM_FILE);

      	  if( diagCtl == 1)   // file type 2D
      	  {
		FIfld_set_list_text( (Form)form_ptr ,G_SEL_CTX_TYP, 0, 0, 
	                       SR_FSI, FALSE);
	 	FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 1, 0, 
	                       SR_SUB_FSI, FALSE);
      	  }
      	  else if (diagCtl == 0 )
      	  {
	 	FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, 
	                       SR_ZNSYS, FALSE);
	 	FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 1, 0, 
	                       SR_ZONE, FALSE);
	 	FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 2, 0,  
	                       SR_UNIT, FALSE);
      	  } 
        }
	
       break;

/* TLS 01/23/02 - AMDC Enhancements */
   case G_TG_ASSEM_FILE: // for assemble toggle
        FIg_erase( (Form)form_ptr, G_BTN_QRY_CTX);
	FIg_erase( (Form)form_ptr, G_TEXT_HSC);
	FIg_erase( (Form)form_ptr, G_TEXT_ZONE);
	FIg_erase( (Form)form_ptr, G_TEXT_UNIT);
	FIg_erase( (Form)form_ptr, G_TEXT_CONTEXTS);
	FIg_erase( (Form)form_ptr, G_TEXT_CONTDESC);
	FIg_erase( (Form)form_ptr, G_TEXT_REV);
	FIg_erase( (Form)form_ptr, G_TEXT_CONTAPP);
	FIg_erase( (Form)form_ptr, G_FLD_CONTAPP);
        FIg_erase( (Form)form_ptr, G_FLD_MULTICOL ); 
	FIg_erase( (Form)form_ptr, G_TIT_ZONE );
	FIg_erase( (Form)form_ptr, G_TIT_UNIT );
	FIg_erase( (Form)form_ptr, G_FLD_PREFX );
	FIg_erase( (Form)form_ptr, G_TEXT_ZONESYS ); 
    
        FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, "", FALSE );
       
        FIfld_set_text( (Form)form_ptr, G_FLD_MULTICOL , 0, 0, "", FALSE ); 
        FIfld_set_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, "", FALSE );
       
        UI_status( ""); 
        FIfld_set_text( (Form)form_ptr, FI_MSG_FIELD, 0, 0, 
	               "Select Context", FALSE );

        status = VDgetDiagCtlPar(&msg, &diagCtl );

        if( !(status&msg&1) ||diagCtl ==-1)
        {
        	UI_status ("Design Setup Parameter Not Set ");
       		__DBGpr_int(" diagCtl ", diagCtl);
       		FIf_erase( (Form)form_ptr );
       		goto wrapup;
	}

	//Make sure the Arrangement Toggle is set to No if Assembly toggle is set to Yes	
	//and vice versa except if the toggle is set back to no then reset the form.
 	FIg_get_state((Form)form_ptr, G_TG_ASSEM_FILE, &chkTgOpt );

	if( chkTgOpt )
	{
	  FIg_set_state_off((Form)form_ptr, G_TG_FILE_TYP);
      
      	  if( diagCtl == 1)   // file type 2D
      	  {
		 FIfld_set_list_text( (Form)form_ptr ,G_SEL_CTX_TYP, 0, 0, 
	                       SR_FSI, FALSE);
		 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 1, 0, 
	                       SR_SUB_FSI, FALSE);
      	  }
      	  else if (diagCtl == 0 )
      	  {
		 //clear the list first
		 FIg_reset ( (Form)form_ptr, G_SEL_CTX_TYP );

 		 //reset the number of rows in the list
		 FIfld_set_list_num_rows((Form)form_ptr, G_SEL_CTX_TYP, 0, 0); 

		 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0, 
	                       SR_ZONE, FALSE);
		 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 1, 0,  
	                       SR_UNIT, FALSE);
      	  } 
	}
	else
	{
	  FIg_set_state_off((Form)form_ptr, G_TG_FILE_TYP);
      
      	  if( diagCtl == 1)   // file type 2D
      	  {
		 FIfld_set_list_text( (Form)form_ptr ,G_SEL_CTX_TYP, 0, 0, 
	                       SR_FSI, FALSE);
		 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 1, 0, 
	                       SR_SUB_FSI, FALSE);
      	  }
 
      	  else if (diagCtl == 0 )
      	  {
	 	 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 0, 0,
	     			SR_ZNSYS, FALSE);
		 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 1, 0, 
	                       	SR_ZONE, FALSE);
		 FIfld_set_list_text( (Form)form_ptr, G_SEL_CTX_TYP, 2, 0,  
	                       	SR_UNIT, FALSE);
      	  }

	}

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

/* 
 * TLS: -- Function to set the new HA in AIM on a given object 
 * 03/28/01
 */
int SrUpdateHAOnOBID(char *classname, char *obid, char *newHA)
{
     int status=0, index=0, inlen=0, dstat=0, mfail, outlen, code;
     char *outbuf=NULL, *errmsg = 0;
     char inbuf[100], err[180];
     char srerrmsg[70];

     __DBGpr_com("START SrUpdateHAOnOBID");

     code = VDP_UPDATE_HA;

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     __DBGpr_str("classname", classname);
     strcpy( &inbuf[index], classname );
     inlen += strlen(classname) +1;
     index = inlen;

     __DBGpr_str("obid", obid);
     strcpy( &inbuf[index], obid );
     inlen += strlen(obid) +1;
     index = inlen;

     __DBGpr_str("newHA", newHA);
     strcpy( &inbuf[index], newHA );
     inlen += strlen(newHA) +1;
     index = inlen;

     __DBGpr_int("trying to talk with AIM for VDP_UPDATE_HA code", code)
;
     UI_status("Updating HA in AIM.");
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     if(dstat != 0)
     {
      if(dstat == 12345)
      {
  	UI_status("AIM connection was reset by server.");
	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
       }
       __DBGpr_int("dstat ", dstat);
       if(errmsg) __DBGpr_str("errmsg ", errmsg );
       UI_status("Could not Update HA in AIM.");
       status = 1;
       goto wrapup;
     }

     if (mfail != 0 )
     {
       if(errmsg)
       {
        __DBGpr_str("ERROR 2", errmsg );
       }
       __DBGpr_int("mfail ", mfail);
       status = mfail;
	printf("mfail = <%d>\n", mfail);
       UI_status("Could not Update HA in AIM.");
       status = 1;
       goto wrapup;
     }


wrapup:
     __DBGpr_com("END SrUpdateHAOnOBID");
     return status;
}

/* added code Pullabhotla -- Function to query Hull Applicability from PDU */

int PDMReadHullApp(char *catalog, char *partid, char *revision, 
                   char *lpdvalue1[12])
{
 char searchst[70];
 char **bufst;
 int num;
 int status=0, sts=1;
 int i;

  static char lpdnum[100] = { "lpd17,lpd18,lpd19,lpd20,lpd21,lpd22,lpd23,lpd24,lpd25,lpd26,lpd27,lpd28" }; 
 
 
 SetProc(PDMReadHullApp); Begin

  sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'",
    		     partid, revision);

  __DBGpr_str("Searchst is", searchst); 

status =
   vdb$RisSelect(select=lpdnum,
            	 table_name = catalog, 
		 where = searchst,
		 numselect = 12,
		 p_numrows = &num,
		 p_buffer = &bufst);


  if(status != 1 || num == 0)
          return 1;
 

  for(i=0;i<=11;i++)
  { 
   

   sts = vdb$RisExtractValue( nbrows = num,
                              nbcolumns = 12,
			      buffer = bufst,
			      row = 0,
			      column = i,
			      value = &lpdval[i]);
  
lpdvalue1[i] = &lpdval[i];



   
  } 

  vdb$RisFreeBuffer( buffer = bufst, size = 1 * num );     
 End

 return 0; 
 
}

/* added code Pullabhotla -- Function to query AIM Info. from AIM side */

  int SrVDPGetAIMInfo(int *code, char **aim_user, char **aim_server,
                      char **aim_env) 
                      
{
  int 	index, inlen, dstat, mfail, outlen, i, nbItems ;
  char inbuf[XX_LEN], srerrmsg[XX_LEN];
  char	*outbuf, *errmsg;

  int status, stat_flag;
  
  char aim_user1[XX_LEN], aim_server1[XX_LEN], aim_env1[XX_LEN];

  index = 0;
  inlen = 0;
  nbItems = 0;
  errmsg = NULL;
  outbuf = NULL;


   memcpy( &inbuf[index], code, sizeof(int)); 
   inlen = inlen + sizeof(int);
   index = inlen;
	        
   dstat = POSTMAN_REQUEST_ON_CLIX( inlen, 
           	                    inbuf, 
				    &outlen, 
				    &outbuf, 
				    &mfail, 
	                            &errmsg );
	

  if(dstat || mfail)
     {
        //printf("\n dstat %d, mfail %d", dstat, mfail);
	             
        if(!errmsg || (errmsg && !errmsg[0]))
        errmsg="No error msg but should be";
    
        if ( strlen(errmsg ) > 63 )
        errmsg[63] = '\0';
	
        UI_status( errmsg );

        if(dstat == 12345 )
	{
		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
	    	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
	}
	// EX_error_box( FI_CURRENT_SCREEN, "Unable to Connect", 
	//   		                      "Contact AIM Administrator");
	
	 stat_flag = IsPmeEnabled();

	 if(stat_flag == 1)
	 {
	  
          status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
	     	    	                     NULL,
					     NULL,
					     NULL,
					     NULL,
					     &errmsg);
          if ( !status)
		 EnablePME(0);
     	         UI_status("Disconnected From AIM server");
         }

	 

        return OM_E_ABORT; 
    
     }  
   
   index = 0;
	      	
   memcpy( &nbItems, &outbuf[index], sizeof(int) ); 
   index = index + sizeof(int);   

   if(outbuf[0]!='\0')
    {

   if( strlen(&outbuf[index]) > 0 )
   {
     *aim_user = _MALLOC(strlen(&outbuf[index]) + 1, char); 
	        
     if(*aim_user) strcpy(*aim_user, &outbuf[index] );
     index = index + strlen(*aim_user) + 1;
   }
   else 
   {
     EX_error_box( FI_CURRENT_SCREEN, "Check config.cfg on AIM side", 
		                      "Contact AIM Administrator"); 
     return OM_S_SUCCESS;
   } 
	 
   if( strlen(&outbuf[index]) > 0 )
   {
     *aim_server = _MALLOC(strlen(&outbuf[index]) + 1, char); 
       
     if(*aim_server) strcpy(*aim_server, &outbuf[index] );
     index = index + strlen(*aim_server) + 1;
   }	
   else
   {
     EX_error_box( FI_CURRENT_SCREEN, "Check config.cfg on AIM side", 
		   		      "Contact AIM Administrator"); 
   return OM_S_SUCCESS;
   }
   
  if( strlen(&outbuf[index]) > 0 )
   {
    *aim_env =    _MALLOC(strlen(&outbuf[index]) + 1, char); 
				  	
    if(*aim_env) strcpy(*aim_env, &outbuf[index] );
    index = index + strlen(*aim_env) + 1;
   }
   else
   {
     EX_error_box( FI_CURRENT_SCREEN, "Check config.cfg on AIM side", 
		   		      "Contact AIM Administraotr"); 
   return OM_S_SUCCESS;
   }
  
 strcpy(aim_user1, *aim_user);
 strcpy(aim_server1, *aim_server);
 strcpy(aim_env1, *aim_env);
 
 VDPPutAimInfo(aim_user1, aim_server1, aim_env1);

 }  

 return 0 ;
 }
 
/*************************************************************************
 Added by Anjani
 The function is written to reconnect the MDC information from AIM,
 in case the DAD is corrupted in ISDP. This function sends part 
 info as inbuf and gets the Mdc info as outbuf.
 	Inbuf : catalog, part, revision
	outbuf: mdcobid, ctxtype, ctxname, ctxrev, ctxdesc, ctxobid, ftype 
	
************************************************************************/

IGRint VDPReconnectDAD()
{
    int code = 0, index = 0, index1 = 0, inlen = 0, outlen = 0, i = 0;
    int dstat = 0, mfail = 0, status = 0;
    long msg;

    char inbuf[100];
    char FileName[250], TmpFileName[260];
    char *outbuf;
    char *token;
    char *errmsg = NULL;
    FILE *dm2_err = NULL;
    time_t  ltime;
    char aim_user[50], aim_server[15], aim_env[15];

    SetProc(VDPCmdPMDefi.DADReconnect); Begin

    FileName[0]='\0';
    TmpFileName[0]='\0';
    aim_user[0]='\0';
    aim_server[0]='\0';
    aim_env[0]='\0';
    
	for ( i=0; i<100; i++ )
             inbuf[i]='\0';
    
	VDPGetAimInfo(aim_user, aim_server, aim_env);
	
    	get_local_fname(refresh->act_catalog,
             refresh->act_partid,
             refresh->act_revision,
             FileName );
	token = strtok(FileName, ".");
	sprintf( TmpFileName, "%s", token );
        strcat( TmpFileName, "_recon.log" );	
	time( &ltime );
	dm2_err = (FILE *)fopen(TmpFileName,"a");
       if( dm2_err == NULL )
	 printf( "Cannot open file %s\n", TmpFileName);
       FILE_PRINT(dm2_err, "\n\t-------------------------------------------------------------------\n");
       FILE_PRINT( dm2_err, "\n\tReconnect Process Started %s\n", ctime(& ltime));
       FILE_PRINT(dm2_err, "\n\tUser Name is %s\n", aim_user);
       FILE_PRINT(dm2_err, "\n\tSever Name is %s\n", aim_server);
	FILE_PRINT(dm2_err, "\n\tEnvironment Name is %s\n", aim_env);	 

    	code = VDP_MDC_RECONNECT;
	__DBGpr_int(" code ", code);
	 memcpy( &inbuf[index], &code, sizeof(int) );
	inlen += sizeof(int);
	  index = inlen;
	strcpy( &inbuf[index],refresh->act_catalog);
	inlen = inlen + strlen(refresh->act_catalog ) +1;
	  index = inlen;
	strcpy( &inbuf[index],refresh->act_partid); 
	inlen = inlen + strlen(refresh->act_partid)+1;
	  index = inlen;
	strcpy(&inbuf[index], refresh->act_revision);
	inlen = inlen + strlen(refresh->act_revision) + 1;
	index = inlen;

	dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
					    inbuf,
					    &outlen,
				            &outbuf,
				             &mfail,
				             &errmsg );
	if(dstat || mfail)
	{
		if(dstat == 12345 )
    		{
			printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        		//strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        		//ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    		}
	 	FILE_PRINT(dm2_err, "\n\tIn Reconnect Process\n");
      	 	FILE_PRINT( dm2_err, "\n\t%s\n", errmsg);
       		FILE_PRINT( dm2_err, "\n\tdstat is %d\n",dstat);
		FILE_PRINT( dm2_err, "\n\tmfail is %d\n",mfail);
	}	
	if(outlen != 0)
	        status = VDPSaveReconDefaults(dm2_err, TmpFileName, outbuf, &msg );		
	else
		printf("<S-Home>Failed to query AIM Infor\n");
	fclose(dm2_err);	
wrapup :
 //if(dm2-err)
  //fclose(dm2_err);
   
End
     return OM_S_SUCCESS;
}

/**************************************************************************
 * Added by Anjani, 
 * This function is written to restore all the placements from AIM after 
 * DAD is reconnected. This function sends the Mdcobid and hullapp as inbuf
 * and gets all the placements related to Mdc as outbuf. 
 * After restoring and posting the parts
 * 1. The primary relations with Mdc will be modified
 * 2. The existing 3D relations are deleted and new relations will be created
 * 3. The hull applicability for Mdc is updated in AIM
 * **********************************************************************/

IGRint VDPRestorePlacmts(FILE *dm2_err, char *FileName, long *msg, char *MdcObid, char *ftype)
{
	int index = 0, outlen = 0, inlen = 0, status = 0, code = 0, dstat = 0;
	int index1 = 0, nbplacmts = 0, MaxUid=0, mfail = 0, i = 0, seqnum = 0;
	char *outbuf;
	char inbuf[1000];
	char *errmsg = NULL;
	char *lpdvalue[12];
  	int j, k=0, number=0;
  	char LpdDesc[50];
  	static char LpdtempDesc[2];
  	static char LpdValue[1];
  	char Lpdtempvar[5];
	char FSIClass[15];
	struct GRid *list, EnabListId, trTblId;
  	Tret_struct rs;
	OMuword     curOs;
	IGRlong     stat = OM_S_SUCCESS;

	int objcount = 0, size = 0, objctr = 0, nbObjs = 0, nobjs_unposted = 0;
	int ret_size, siruidsize = 0, notUsed, ret_msg;
	int  FSI = -1;
	extern GRclassid    OPP_VDSroot_class_id;
	char class_name[80], exp[20];
        IGRchar *sirobid=NULL, siruid[30];
	struct SIRPlacmtsInfo *SrPlacmts = NULL;
	struct SIRuidinfo *SIR_uid = NULL;
	struct VDPtrObjList   *GlTrTbl = NULL;
	struct      ACrg_coll       Coll;
	struct      GRmd_env        MdEnv;
	struct GRobj_env    *listObjs = NULL;
	struct VDPtrObjList  TrRow;
	IGRboolean        flag=TRUE;
	 time_t  	ltime;

	SetProc( VDPCmdPMDefi.RestorePlacmts); Begin

	for(i = 0; i<1000; i++)
		inbuf[i]='\0';
	LpdDesc[0] = '\0';

	//dm2_err = (FILE *)fopen(FileName, "a");

	status = PDMReadHullApp(refresh->act_catalog, refresh->act_partid, 
				 	refresh->act_revision, lpdvalue);
	for(j=0;j<=11;j++)
   	{
      		LpdValue[0] = '\0';
      		strncpy(LpdValue, lpdvalue[j], 1);

       	  if(!strcmp(LpdValue,"Y"))
          {

           number  = number + 1;
            sprintf(LpdtempDesc,"%d",k+17);

			 if(number>1)
             {
                   strcat(LpdDesc, ",");
             }
                   strcat(LpdDesc, LpdtempDesc);
                   if(!strcmp(LpdtempDesc, "28"))
                    strcat(LpdDesc, "AF");

		  }

          k++;
    }

	
	code = VDP_PLACMT_RECONNECT;
	memcpy(&inbuf[index], &code, sizeof(int));
	inlen = inlen + sizeof(int);	 
	index = inlen;
	strcpy(&inbuf[index], MdcObid);
	inlen = inlen + strlen(MdcObid) + 1;
	index = inlen;
	strcpy(&inbuf[index], LpdDesc);
	inlen = inlen + strlen(LpdDesc) + 1;
	index = inlen;

	dstat = POSTMAN_REQUEST_ON_CLIX(inlen,
					inbuf,
					&outlen,
					&outbuf,
					&mfail,
					&errmsg);

	if(dstat || mfail)
   	{
	  if(dstat == 12345 )
    	  {
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	//strcpy(srerrmsg, "AIM connection reset by server. Disconnect and Re-Connect.");
        	//ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
    	  }	
    	 FILE_PRINT( dm2_err, "\n\tIn Restore Placements Process\n");
	 FILE_PRINT(dm2_err, "\n\t%s\n", errmsg);
    	 FILE_PRINT( dm2_err, "\n\tdstat is %d\n", dstat);
    	 FILE_PRINT( dm2_err, "\n\tmfail is %d\n", mfail);
   	} 	
	
	memcpy(&nbplacmts, &outbuf[index1], sizeof(int));
	index1 = index1 + sizeof(int);

   	if(nbplacmts != 0)
	{
	   SrPlacmts = _MALLOC(nbplacmts, struct SIRPlacmtsInfo);

		if(SrPlacmts == NULL)
		{
			UI_status("No Dynamic Memory.");
			return OM_E_NODYNMEM;
		}
	}
	
    for(i = 0; i<nbplacmts; i++)
	{
             strcpy(SrPlacmts[i].uid, &outbuf[index1]);
		     index1 = index1 + strlen(&outbuf[index1]) + 1; 
		     SrPlacmts[i].obid =  atoi(&outbuf[index1]);
		     index1 = index1 + strlen(&outbuf[index1]) + 1;
			 strcpy(SrPlacmts[i].class, &outbuf[index1]);
			 index1 = index1 + strlen(&outbuf[index1]) + 1;
			 strcpy(SrPlacmts[i].reltype, &outbuf[index1]);
			 index1 = index1 + strlen(&outbuf[index1]) + 1;
	}
    //printf("FileName in Restoreis %s\n", FileName);
    if(nbplacmts == 0)
      FILE_PRINT(dm2_err, "\n\tNo Placements found to Restore\n");
    else
    {
     //	printf("I am in else\n");
    	FILE_PRINT( dm2_err, "\n\t%d Placements Restored Successfully\n", nbplacmts);
    }

	memcpy(&MaxUid, &outbuf[index1], sizeof(int)); 

	if(nbplacmts == 0)
		MaxUid = 0;	
	status = VDPUpdSeqNoforUid(MaxUid);


         //get the Transaction list id
         VDPGetTrTblId ( msg, &trTblId );      
		//get the initial size of transaction list  	 
         size = VDgetTrSize();
        if(size > 0)
		{
            _VD_SEND_OBJN ( trTblId, Root.delete (1));
        }
        VDPGetTrTblId ( msg, &trTblId );
        //To initialize transaction table
       _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPinit(msg));

	//Remove the initial enabledlist
	ex$get_cur_mod(osnum = &curOs);

                status = VDPGetEnabledListId ( msg, curOs, &EnabListId );

                if(EnabListId.objid == NULL_OBJID )
                {
                   printf("\n failed to get EnabListId.\n");
                   goto wrapup;
                }
                /* Get all the PME Enabled OBJID's */

           status =
            om$send ( msg = message VDPenabObj.VDPgetPMenabledList (
                                                msg,
                                                &nbObjs,
                                                &listObjs ),
                     senderid = NULL_OBJID,
                     targetid = EnabListId.objid,
                     targetos = EnabListId.osnum );
	if (nbObjs == 0 )
                {
                __DBGpr_com("No objects found in Enabled List\n");
               // goto wrapup;
                }

	 for( objctr  = 0; objctr < nbObjs; objctr = objctr+1)        
			status = VDPDisableObject(msg, listObjs[objctr].obj_id);
             
	list = _MALLOC(1, struct GRid);
	
	for(i = 0; i<nbplacmts; i++)
	{
            class_name[0]='\0';
		    TrRow.VDSobjid = SrPlacmts[i].obid;
		    TrRow.oldVDSobjid = SrPlacmts[i].obid;
		    TrRow.PMEobid[0] = '\0';

		    //Get Object Class Name
   		    status = om$get_classname( objid = SrPlacmts[i].obid,
               			                osnum = 2,
                               			classname = class_name );

			FSIClass[0] = '\0';
			
		if(!strcmp(class_name, "VDequipment") || !strcmp(class_name, "VREquipment"))
			strcpy(FSIClass, "SrEquip");
		else if(!strcmp(class_name, "VRPComp"))
			strcpy(FSIClass, "SrPiping");
		else if(!strcmp(class_name, "VRRComp"))
			strcpy(FSIClass, "SrRway");
		else if(!strcmp(class_name, "VRHComp"))
			strcpy(FSIClass, "SrHvac");

		if(!strcmp(FSIClass, SrPlacmts[i].class) && !strcmp("P", SrPlacmts[i].reltype))

		{		
			if(!strcmp(ftype, "A"))
			  continue;
		     
                    size = sizeof( struct GRmd_env );
			
		    gr$get_module_env( msg = msg,
                                       sizbuf = &size,
                                       buffer = &MdEnv,
                                       nret = &ret_size );
	       

			list[0].objid = SrPlacmts[i].obid;
			list[0].osnum = 2;

			
                   //Get the Uid attribute of the object
                    strcpy( Coll.name, "sirid" );
                    Coll.desc.type = AC_ATTRIB_TEXT;
                    strcpy ( Coll.desc.value.att_txt, "" );
		    status = vd$review_params ( pMsg = msg,
                                               pComponent = &list[0],
                                               pMdEnv = &MdEnv,
                                               pList = &Coll,
                                               NbParams = 1 );

                    CheckRC (status, *msg);
        __DBGpr_str("The UID value is %s", Coll.desc.value.att_txt);

		    if(strlen( Coll.desc.value.att_txt)==0)
	        {
            	 	__DBGpr_com("UID is NULL");

            	   	// Set UID value for the Placment object 
		         strcpy( Coll.desc.value.att_txt, SrPlacmts[i].uid );
            		strcpy( Coll.name, "sirid" );
            		Coll.desc.type = AC_ATTRIB_TEXT;
				
            		status = VDmodUsrAttrs(msg,list[0],&MdEnv,1,&Coll);
			
          	}//UID is set
          	__DBGpr_str("Object UID =", Coll.desc.value.att_txt);


	      status = VDPEnableObject( msg, list[0] );
                CheckRC ( status, *msg );

                /* Get all the PME Enabled OBJID's */

           status =
            om$send ( msg = message VDPenabObj.VDPgetPMenabledList (
                                                msg,
                                                &nbObjs,
                                                &listObjs ),
                     senderid = NULL_OBJID,
                     targetid = EnabListId.objid,
                     targetos = EnabListId.osnum );
		if (nbObjs == 0 )
                {
                __DBGpr_com("No objects found in Enabled List\n");
               // goto wrapup;
                }

		//To initialize TrRow
		
		TrRow.ActionCode = VDP_MODIFY;

	   //Add to Transaction table

	  status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPAddtoTrTable(msg, TrRow));
                   // CheckRC( status, *msg );
	  status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPprintTransTable (msg));
          GlTrTbl = (struct VDPtrObjList *)VDgetTrTable();
                size = VDgetTrSize();

	setPostingStatus(&GlTrTbl[size-1].ActionCode, VDP_MODIFY);
	FILE_PRINT(dm2_err, "\nF S I  : [%d/%d]", list[0].osnum, list[0].objid);
	FILE_PRINT(dm2_err, "\t%s", SrPlacmts[i].uid);
	FILE_PRINT(dm2_err, "\t %s", class_name);
	FILE_PRINT(dm2_err, "\t Reconnect[MODIFY]\n");
	//FILE_PRINT(dm2_err, "\n\tThe Placement with UID value %s is Posted with MODIFY status\n", SrPlacmts[i].uid);

		}//end of class_name check
		else
		{
			//to init TrRow

                        TrRow.ActionCode = VDP_DELETE;

			//Delete from Transaction table

                      status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPAddtoTrTable(msg, TrRow));
                   // CheckRC( status, *msg );
                     status = _VD_SEND_OBJN(trTblId, VDPtrTbl.VDPprintTransTable (msg));
                      GlTrTbl = (struct VDPtrObjList *)VDgetTrTable();
                      size = VDgetTrSize();
		     FILE_PRINT(dm2_err, "\nF S I  : [%d/%d]", list[0].osnum, list[0].objid);
	FILE_PRINT(dm2_err, "\t%s", SrPlacmts[i].uid);
	FILE_PRINT(dm2_err, "\t %s", class_name);	
	FILE_PRINT(dm2_err, "\t Reconnect[DELETE]\n"); 
		      //FILE_PRINT(dm2_err, "\n\tThe Placement with UID value %s is Posted with DELETE status\n", SrPlacmts[i].uid );
		}
		
    }//Placment For loop
	
	if(nbplacmts == 0)
	 FILE_PRINT( dm2_err, "\n\tNo Placements found to post\n");
	else
	{
	 //printf("I am in else2\n");
	 FILE_PRINT( dm2_err, "\n\t%d Placements Posted Successfully\n", nbplacmts );
	}
	//printf("End of Restore Placements\n");

	//fclose(dm2_err);

	UI_status("Placements are restored successfully");

wrapup :
//if(dm2_err)
 //fclose(dm2_err);
if(SrPlacmts)
_FREE(SrPlacmts);

  if(GlTrTbl != NULL)
    _FREE( GlTrTbl );

End
 return OM_S_SUCCESS;

}

/************************************************************************
  Added by Anjani
  The method to store the context information in collector in DAD
  reconnect process
 ***********************************************************************/

IGRint VDPSaveReconDefaults(FILE *dm2_err, char *FileName, char *outbuf, long *msg )
{
   IGRlong		status = VD_SUCCESS;
   struct GRid		DirId, CollId;
   IGRchar		DirName[DI_PATH_MAX],
			CollName[DI_PATH_MAX];
   OMuword		curOs;
   struct ACrg_coll	*coll;
   int		index = 0, dstat = 0, code = 0;
   char		SrCtxRev[5], mdcobid[30], ftype[5], MdcRev[15]; 
   IGRboolean	IsDADExists=FALSE;
    time_t  	ltime;

   SetProc( VDPCmdPMDef.VDPSaveReconDefaults ); Begin

   SrCtxRev[0]='\0';
   mdcobid[0]='\0';
   ftype[0]='\0';

   ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */

   status = di$give_pathname(  osnum           = curOs,
                               pathname        = DirName );

   __CheckRC( status, 1, "di$give_pathname", wrapup );
   __DBGpr_str( "Path name", DirName );

   strcat( DirName, SIR_GLOBAL_DIR );

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

   sprintf( CollName, "%s%s", DirName, SIR_REQ_DATA );
   __DBGpr_str( "Collector name", CollName );

   status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId ); 
   /*if( !(status & *msg & 1))
	UI_status("Error in creating Collector ");*/
   if(CollId.objid == NULL_OBJID)
   {
	//printf("Collector is not found. Creating...\n");
   status = VDgetVdCollId ( msg, CollName, TRUE, TRUE, &CollId ); 
   IsDADExists=TRUE;
   }


   __CheckRC( status, *msg, "VDgetVdCollId", wrapup );

   __DBGpr_obj( "Collector Id", CollId );

   /* Intialize the Collector */
   coll = _MALLOC ( 7, struct ACrg_coll );

   /* set up the coll values */

   strcpy( coll[0].name, SIR_CNTX_ID );
   coll[0].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[0].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[0].desc.value.att_txt) + 1;

   strcpy( coll[1].name, SIR_CNTX_NAME );
   coll[1].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[1].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[1].desc.value.att_txt) + 1;
   
   strcpy( coll[2].name, SIR_CNTX_DESC );
   coll[2].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[2].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[2].desc.value.att_txt) + 1;
   
   strcpy( coll[3].name, SIR_CNTX_TYP );
   coll[3].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[3].desc.value.att_txt, &outbuf[index] );
   index = index + strlen(coll[3].desc.value.att_txt) + 1;
   
   /*strcpy( coll[4].name, CTX_REVISION );*/
   /*coll[4].desc.type = AC_ATTRIB_TEXT;*/
   strcpy( SrCtxRev, &outbuf[index] );
   index = index + strlen(SrCtxRev) + 1;

   strcpy( coll[4].name, SIR_MODCX_ID );
   coll[4].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[4].desc.value.att_txt, &outbuf[index] );
   strcpy( mdcobid, &outbuf[index]);
   index = index + strlen(coll[4].desc.value.att_txt) + 1;

   strcpy( coll[5].name, SIR_FILE_TYP );
   coll[5].desc.type = AC_ATTRIB_DOUBLE;
   //coll[4].desc.value.att_exp = atoi(&outbuf[index]);
   strcpy( ftype, &outbuf[index]);
   index = index + strlen(ftype) + 1;

   if(!strcmp(ftype, "M"))
      coll[5].desc.value.att_exp = 0;
   if(!strcmp(ftype, "D"))
      coll[5].desc.value.att_exp = 1;
   if(!strcmp(ftype, "A"))
      coll[5].desc.value.att_exp = 2; 

   
   strcpy( coll[6].name, SIR_SEQ_NO );
   coll[6].desc.type = AC_ATTRIB_TEXT;
   strcpy( coll[6].desc.value.att_txt, "1");

   /* store in collector */
   if(IsDADExists==TRUE)
   {
    status =
   _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute( 
					msg, 
					7,
					coll ) );
    }
    else
    {
   status =
   _VD_SEND_OBJN( CollId, ACrg_collect.ACmod_list_attribute( 
					msg, 
					7,
					coll ) );
    }

    //dm2_err = (FILE *)fopen(FileName, "a");
    //printf("File Name in SaveRecon is %s\n", FileName);
    FILE_PRINT( dm2_err, "\n\tPart is Successfully Reconnected to Mdcobid %s\n", mdcobid);

    //Added by Anjani on 26Aug2000
    //Updating the Context revision in Sirpdmtable after reconnecting the DAD 
    MdcRev[0]='\0';
    // TLS - 03/26/01 - Changed to to reflect correct function in aim
    code = VDP_GET_REV;
    status = VDPGetRevFromOBID(code, mdcobid, &MdcRev);
    __DBGpr_str( "MdcRev in Reconnect is", MdcRev );
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "mdc_rev",MdcRev);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "ctx_type",coll[3].desc.value.att_txt);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "ctx_name",coll[1].desc.value.att_txt);
    status = SirVDUpdCMAttrs( refresh->act_catalog, refresh->act_partid,
      	  	        refresh->act_revision, "ctx_rev",SrCtxRev); 

   dstat = VDPRestorePlacmts(dm2_err, FileName, msg, mdcobid, ftype);
   
   //fclose(dm2_err);

wrapup:
   //if(dm2_err)
    //fclose(dm2_err);
if(coll)
_FREE(coll);
  End
 return OM_S_SUCCESS;
}


/* VDPUpdSeqNoforUid()
 * Seq no is updated in default data collector.  In DAD Reconnect process,
 * Maximum Uid value is retreived from AIM and stored in the DAD
 * collector.
 *
 * */
IGRint  VDPUpdSeqNoforUid(IGRint SrMaxUid )
{
  IGRlong               status = OM_S_SUCCESS;
  IGRchar               DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
  struct GRid           SrSeqCollId;
  struct ACrg_coll      *SrSeqcoll=NULL;
  OMuword               curOs;
  long                  msg;
 
  SetProc(VDPCmdPMDefi.I.VDPUpdSeqNoforUid); Begin
  ex$get_cur_mod( osnum = &curOs );
  /* Get default data collector id */
  status = di$give_pathname(  osnum           = curOs,
                        pathname        = DirName );
  __DBGpr_str( "Path name", DirName );

  sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
  __DBGpr_str( "Collector name", CollName );

  status = VDgetVdCollId ( &msg, CollName, TRUE, FALSE, &SrSeqCollId );
  CheckRC( status, msg );

  if (SrSeqCollId.objid == NULL_OBJID )
  {
    UI_status("SIR Required Data not set");
    status = OM_E_ABORT;
    goto wrapup;
  }
  __DBGpr_obj ( "Collector Id ", SrSeqCollId );

  /* Get Sequence Number from the DAD Collector */
  SrSeqcoll = _MALLOC(2, struct ACrg_coll);
  strcpy( SrSeqcoll[0].name, SIR_FILE_TYP );
  SrSeqcoll[0].desc.type= AC_ATTRIB_DOUBLE;

  status = _VD_SEND_OBJN( SrSeqCollId,
                ACrg_collect.ACget_named_attribute( &msg, SrSeqcoll ));
  __DBGpr_int( "FILE TYPE", SrSeqcoll[0].desc.value.att_exp );

  /* Sequence number is not updated for 3D files. UID is not generated for 3D */
  if(SrSeqcoll[0].desc.value.att_exp != 0)
  {
	/* The file type is D or A */
	 
  strcpy( SrSeqcoll[0].name, SIR_SEQ_NO );
  SrSeqcoll[0].desc.type= AC_ATTRIB_TEXT;
  /* Increment the seq no and write back to collector */
  sprintf(SrSeqcoll[0].desc.value.att_txt,"%d", SrMaxUid+1);
  status = _VD_SEND_OBJN( SrSeqCollId,
      ACrg_collect.ACmod_list_attribute( &msg, 1, SrSeqcoll ));
  __CheckRC(status, msg, "ACmod_list_attribute", wrapup );
  }
  else
	printf("UID is remained as 1 for 3D files\n");
wrapup:
  if(SrSeqcoll) _FREE(SrSeqcoll);
  End
  return status;
}

/* added code Pullabhotla -  Function to Insert Attributes into SIR_PDM_TABLE
 */
int PDMInsertSirTable(char *Refcat, char *Refpart, char *Refrev)
{
  
  int             i, status, ris_err_code;
  char            value[1024];
  char            MdcRev[10], CntxtRev[10], CntxtName[10], CntxtType[30];

  TVDrisInfo  ris;

  // first, check to see if it is already inserted
  VDrisInitInfo( &ris );

  // the sql
  sprintf(value,
	  "Select * from SIR_PDM_TABLE where %s='%s' and %s='%s' and %s='%s';",
	  "pdu_catalog",Refcat,"pdu_part",Refpart,"pdu_revision",Refrev);

  // the check
  VDrisQuery( &ris, value );
  if (ris.rows > 0) goto wrapup;

  // it does not exist, so insert it
  strcpy(MdcRev, "");
  strcpy(CntxtRev,"");
  strcpy(CntxtName,"");
  strcpy(CntxtType,"");

  value[0]= '\0';
 __DBGpr_com("PDMInsertSirTable() Begin");
  sprintf(value, "INSERT INTO SIR_PDM_TABLE values('%s','%s','%s','%s','%s','%s', '%s')",
          Refcat, Refpart, Refrev, MdcRev, CntxtRev, CntxtName, CntxtType );
  __DBGpr_str("Stmt", value);
  pdm$ris_stmt(status = &status,
  		statement = value,
		ris_err_code = &ris_err_code);

   if(status != SQL_S_SUCCESS)
   {
      __DBGpr_com("Couldnot insert into SIR_PDM_TABLE");
      goto wrapup;
   }
  

wrapup:
  __DBGpr_com("\nPDMInsertSirTable End");
  VDrisFreeInfo( &ris );
  return 0;
}
end implementation  VDPCmdPMDef;
