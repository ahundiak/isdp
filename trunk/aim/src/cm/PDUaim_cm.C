/*
#define vaimDEBUG
#define vaimerrDEBUG
*/

#include <stdio.h>
#include <FI.h>
#include <PDUforms.h>
#include <PDUerror.h>
#include <PDUintdef.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUcommand.h>
#include <PDUstr.h>
#include <MEMerrordef.h>
#include <MEMstruct.h>
#include <PDMmessage.h>
#include "PDUproto.h"
#include "PDUprompt.h"
#include "PDUint.h"
#include "vadbgmacros.h"

#include "VDPdef.h"

/* #include for PDM Utilities Form */
#include "part_gadgets.h"
#include "SQLerrordef.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "msmacros.h"
#include "msdef.h"
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "gr.h"

#include "vdbmacros.h" 

#include "time.h"

    

#define SEL_AIM_SERVER  16

/* #include "PDMproto.h" */
/* #include "helpifproto.h" */ /* solaris include, maybe */

/* CM forms */  /*??? this should eventually move somewhere like PDUform_def.h -ddd */

/* define statements */
#define CM_LIST_AR_FORM 
#define CM_MOVE_STATE_FORM 891

/* CM Gadgets */
#define ARNUM	14
#define AIRNUM	13
#define AIRREV	15
#define FMRNUM	16
#define FMRREV	17
#define TITLE	18
#define CREDATE	19
#define AROBID	12
#define ARTBL	11

#define GETARBTN 22

/* Change Promotion Fiorm */
#define CP_ARTBL	11
#define CP_C_ARNUM	0
#define CP_C_AIRNUM	1
#define CP_C_AIRREV	2
#define CP_C_FMRNUM	3
#define CP_C_FMRREV	4
#define CP_C_TIT	5
#define CP_C_DATE	6
#define CP_C_OBID	7

/* Postman Codes */
/*
#define VDP_MAKE_AR_CHECKING	133
#define VDP_BASELINE_MDC	122
#define VDP_GET_WORKING_ARS	130
#define VDP_MAKE_AR_CHECKING	133
#define VDP_MAKE_AR_RELEASED	134
#define VDP_MAKE_AR_IMPLEMENTS	135
#define VDP_MAKE_MDC_RELEASED	138
*/

/* nfm attributes used for CM */
#define CMENAB	"p_mrppart"
#define ARSEL	"p_mrpstruct"
#define DCCSEL	"p_explode"

/* CM states */
#define BASELINE	"Baseline"
#define RELEASE		"Release"
#define CHECKING	"Checking"
#define DEVELOPMENT	"Development"
#define AVD_CM_WFLOW	"CM WORKFLOWr9"

/* Gadgets from other forms */
#define ASSY_SELECT_GRP          64
#define PART_SEARCH_MCF          59

/* Gadgets from TOPDOWN form */
#define TD_CATALOG       34
#define TD_PARTID        35
#define TD_REVISION      36
#define TD_FILENAME      37
#define TD_DESC          12

/* Gadgets for PDM State Form */

#define CURRENT		20   /* workflow, ACL, state */
#define NEW 		22
#define PARTS_MCF  	11
#define SELECT  	24
#define DESELECT	25

#define LIST_MCF	11

#define MCF_LIST        12

/* Global Variables */
//static char *CMstate = VDAIM_CMstate = NULL;

/* Externs */
extern char * calloc();
extern char * realloc();
extern short PDU_state_form_created;
extern short PDU_state_form_displayed;
extern short PDU_state_perm_window;
extern short PDU_second_row;
extern int PDU_command;
extern int PDU_selected_rows;
extern int PDU_local_files_displayed;
extern struct PDUforms      forms;
extern struct PDUrefresh      *refresh;
extern int PDU_mcf_list;
extern int *PDU_parts_index;
extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_states_bufr;
extern struct PDUacl_node *PDU_acl_list;
extern struct PDUacl_node *PDU_acl_group_list;
extern struct PDUforms forms;

/* Externs for the PDM Utilities Form */
extern char   * PDU_cat_sort_string;
extern char   * PDU_part_sort_string;
extern char    *PDU_dyn_cat_search;
extern char    *PDU_dyn_part_search;
extern char *** PDU_update_struct;
extern char    *PDU_save_project;
extern char    *PDU_save_catalog;
extern char    *PDU_save_partid;
extern char    *PDU_save_revision;
extern char    *PDU_save_description;
extern char    *PDU_save_filename;
extern char    *PDU_save_parttype;
extern char    *ep_project;
extern char    *ep_catalog;
extern char    *en_itemname;
extern char    *ep_rev;
extern char    *ep_desc;
extern char    *PDU_search_format;
extern int  *   PDU_gadget_labels;
extern int      PDU_refresh_gadgets[7];
extern int  *   PDU_parts_index;
extern int      PDU_command;
extern int      PDU_selected_rows;
extern int      PDU_checkout_type;
extern int      PDU_gadget_label;
extern int      PDU_mcf_list;
extern int      PDU_list_files;
extern int      PDU_form_type;
extern int      PDU_search_type;
extern int      FIg_get_text_length();
extern int      FIg_get_text();
extern int      FImcf_get_active_col();
extern int      FIfld_get_text();
extern int      FIg_get_type();
extern int      PDU_local_files_created;
extern int      PDU_local_files_displayed;
extern int      PDU_single_list_displayed;
extern int      PDU_single_list_created;
extern int      PDU_mcf_list_displayed;
extern int      PDU_mcf_list_created;
extern int      PDU_file_list_created;
extern int      PDU_file_list_displayed;
extern int      PDU_cat_list_displayed;
extern int      PDU_cat_list_created;
extern int      PDU_check_filename;
extern int      project_flag;
extern int      catalog_flag;
extern int      PDU_act_row;
extern int      PDU_login;
extern int      PDU_active_button;
extern int      bufr_flag;
extern int      PDMdebug_on;
extern int      PDU_list_cat;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_cat_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_move_to_state_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_active_list;
extern short    PDU_files_deleted;
extern short    PDU_list_filenames;
extern short    PDU_check_file_refresh;
extern short    PDU_select_area;
extern short    PDU_second_row;
extern short    PDU_structure_list;
extern short    PDU_load_file_buffer;
extern short    PDU_local_perm_window;
extern short    PDU_perm_window;
extern short    PDU_assy_perm_window;
extern short    PDU_where_used_perm_window;
extern short    PDU_activate_copy;
extern short    PDU_param_cat;
extern short    PDU_main_form_cat;
extern short    PDU_chkout_single;
extern short    PDU_edit_display;
extern short    PDU_extadmin;
extern short    PDU_flag_form_created;
extern short    PDU_flag_form_displayed;
extern short    PDU_flag_perm_window;
extern Form     PDU_form_id;
extern Form     PDU_calling_form;
extern Form     place_part_f;
extern Form     ModifyPartForm;
extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_storage_area;
extern MEMptr   PDU_parts_list_bufr;
extern MEMptr   PDU_login_data;
extern MEMptr   PDU_login_attrs;
extern MEMptr   PDU_wf_buffer;
extern MEMptr   PDU_assy_parts_bufr;
extern MEMptr   PDU_part_file_buffer;
extern MEMptr   PDU_delete_buffer;
extern MEMptr   PDUsearch_part_list;
extern struct   PDUrefresh   *refresh;
extern struct   PDUuser      *user;
extern struct   PDUforms     forms;

extern IGRchar *PDU_save;
extern IGRchar *PDU_delete_checkin;
extern MEMptr PDU_attach_buffer;
extern short PDU_active_part;
extern MEMptr PDU_detach_buffer;
extern MEMptr PDU_detach_macro_lib;
extern struct PDUattach_mac_node *PDU_attach_macro_lib;
extern short PDU_design_form_display;
extern struct PDUpart_node      *PDU_parts_id_list;
extern int POSTMAN_REQUEST_ON_CLIX();
extern int IsPmeEnabled();
extern int SrVDGetCMattrs();
extern int SrVDUpdCMattrs();
extern int SrVDGetCMState();
extern int CMar_form();
extern int EnablePME();
extern struct hostent *gethostbyname();
extern  inet_ntoa();
extern int IsRetOK();
extern int CMget_wflow_name();

extern VDPPutAimInfo();
extern VDPGetAimInfo();
extern int SrVDPGetAIMInfo();

static Form cm_move_state_form_id;  /*??? should eventually become part of structure in PDUforms.h -ddd*/

static Form cm_change_ar_form;  
static Form con_form_id;

/*??? eventually add to global form flags  in fmgr_global.c */
static short CM_state_form_created = FALSE;
static short CM_state_form_displayed = FALSE;
static short CM_state_perm_window = FALSE;
static int ChkOK = 0;
static int ForceConnect = 0;

//TLS 05-06-02 - Added for AMDC Phase II
static int gARProcess = 0;

struct  hostent {
       char    *h_name;        /* official name of host */
        char    **h_aliases;    /* alias list */
        int     h_addrtype;     /* host address type */
        int     h_length;       /* length of address */
        char    **h_addr_list;  /* list of addresses from name server */
#define h_addr  h_addr_list[0]  /* address, for backward compatiblity */
};


/*
 * Internet address (a structure for historical reasons)
 */
struct in_addr {
        unsigned long s_addr;
};


#define CLIX_CONNECT	-1
#define CLIX_DISCONNECT -2
#define PME     0
#define SIR     1

extern int AIMlogin();

/* -------------------------------------------------------
 * This function used to let regular PDM know that AIM is loaded.
 * **/
int VDaimIsAimLoaded()
{
    return 1;
}

int ForceConn()
{
  return ForceConnect;
}

int CheckAllowed()
{
  return ChkOK;
}

//TLS 05-06-02 - Added for AMDC Phase II
int getARProcess()
{
  return gARProcess;
}

/*********************************************************
* Function: cm_state_notification_routine
* Form notif for move state form
*
*
*
*
***********************************************************/
int cm_state_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int   status = PDM_S_SUCCESS, sts;
  int   select, pos, length, resp;
  int   row = 0;
  int   mcf_select = FALSE;
  int   num_rows = 0;
  short obid_found = FALSE;
  static char *arobid = NULL;
  /*char *msg = NULL; SSR 21 JAN */
  char *errmsg;
  long mesg;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  /*FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING); */

  __DBGpr_com("in cm_state_notification_routine ");
  fp = cm_move_state_form_id; /*??? will become like forms.cm_move_state_form_id */

  switch ( g_label )
  {   

    case FI_CANCEL:     
      PDUmessage(PDM_E_CMD_CANCELLED, 's');

      _pdm_debug("User selected the cancel button", 0);
                               
      if (CM_state_form_displayed == TRUE)
        FIf_erase( fp );
      if (CM_state_form_created == TRUE)
        FIf_delete( fp );

      CM_state_form_displayed = FALSE;
      CM_state_form_created = FALSE;

      if(PDU_state_form_created == TRUE)
      {
      FIf_display(forms.move_state_form_id);
      FIg_disable( forms.move_state_form_id, FI_EXECUTE );
      PDU_state_form_created = TRUE;
      }
      if(PDU_mcf_list_displayed == TRUE)
      {
        FIg_disable(forms.mcf_list_form_id, FI_ACCEPT );
      }
      

      if(IsPmeEnabled() == TRUE && ForceConn()==1)
      {
           status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
          if ( !status)
          {
            EnablePME(0);
            UI_status("Disconnected From AIM server");
          }
      }
      ChkOK = 0;
      resp = EX_FORM_FINISHED;
      ex$putque( msg = &mesg,
                 response = &resp);

      break; 


    case FI_EXECUTE:

      ChkOK = 0;  // Do not allow move to checking
      _pdm_debug("User selected the execute button", 0);

      _pdm_debug("User selected the Checking state.", 0);

      _pdm_debug("getting the AR Obid", 0);
      FIfld_get_num_rows(fp, CP_ARTBL, &num_rows);
      _pdm_debug("num_rows = %d", (char *)num_rows);
      /*FImcf_set_active_col(fp, AROBID, 0, 0);*/
      if(PDU_state_form_created == TRUE)
        FIg_disable( forms.move_state_form_id, FI_EXECUTE );
      if(PDU_mcf_list_displayed == TRUE)
        FIg_disable(forms.mcf_list_form_id, FI_ACCEPT );
 
      for (row = 0; row < num_rows; ++row)
      {
        FIfld_get_select(fp, CP_ARTBL, row, 0, &mcf_select);
        if (mcf_select)
        {
           FIfld_get_text_length(fp,CP_ARTBL,row, CP_C_OBID, &length);
           arobid = (char *) malloc (sizeof (char) * length + 1);
           memset(arobid, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp, CP_ARTBL, row, CP_C_OBID, length, 
				(unsigned char *)arobid, &select, &pos);

           if (strcmp(arobid, "") == 0)
           {
             /* if FIRST row is selected, 
              * Update the DCC variable to TRUE */
             _pdm_debug("no state selected", 0);
	     /* SSR 21 JAN
             PDUmessage(PDM_E_SELECT_STATE, 's');
             msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE); */
             /*FIg_set_text(fp, FI_MSG_FIELD, msg);*/
             break;
           }
           _pdm_debug("arobid = <%s>", arobid);
           /* Go to Aim for every row and update relns. */
           if(PDU_state_form_created == TRUE)
             FIg_enable( forms.move_state_form_id, FI_EXECUTE );
           if(PDU_mcf_list_displayed == TRUE)
             FIg_enable(forms.mcf_list_form_id, FI_ACCEPT );
           __DBGpr_str("AROBID", arobid );

   	   //TLS 05-06-02 - Changed for AMDC Phase II
           if(getARProcess() == AR_REJECT)
	   {
  		__DBGpr_com("Setting arstate parameter to AR_REJECT");
		status = CMChangeARState( arobid, AR_REJECT);
	   }
	   else
	   {
  		__DBGpr_com("Setting arstate parameter to AR_CHECKING");
	   	status = CMChangeARState( arobid, AR_CHECKING);
	   }

           /* If not success; disable the execute button from move state form,
            * show status in msg field. */
           if(status)
           {
             if(PDU_state_form_created == TRUE)
             {
               FIg_disable( forms.move_state_form_id, FI_EXECUTE );
               FIg_set_text(forms.move_state_form_id, FI_MSG_FIELD, 
                            "Could not change AR status in AIM" );
             }
             if(PDU_mcf_list_displayed == TRUE)
             {
               FIg_disable( forms.mcf_list_form_id, FI_ACCEPT );
               FIg_set_text(forms.mcf_list_form_id, FI_MSG_FIELD, 
                            "Could not change AR status in AIM" );
             }
           }
	   ChkOK = 1; // Ahanged AR state; allowe move state

	 }
       }
       
       gARProcess = 0;

       FIf_erase( fp );
       /* if (CM_state_form_created == TRUE) */
       FIf_delete( fp );

       CM_state_form_displayed = FALSE;
       CM_state_form_created = FALSE;

       FIf_display(forms.move_state_form_id);
       PDU_state_form_created = TRUE;
       /* PDU_local_files_displayed = TRUE; */

       if(IsPmeEnabled() == TRUE)
       {
         if(ForceConn() ==1)
         {
           status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
           if ( !status)
           {
             EnablePME(0);
             UI_status("Disconnected From AIM server");
           }
         }
       }
      //ChkOK = 1;
      resp = EX_FORM_FINISHED;
      ex$putque( msg = &mesg,
                 response = &resp);
       break; 
  } /* END switch ( g_label ) */

  return status;

} /* END cm_notification_routine() */


/*********************************************************
* Function: CMChangeARState
*
* Send a command to AIM to change the state of the AR.
*
***********************************************************/
int CMChangeARState( arobid, arstate )
	char *arobid;
	//char *arstate;
	int arstate;
{
  int status = 0;
  int inlen=0; 
  int index=0;
  int outlen=0; 
  int code=0; 
  int dstat=0; 
  int mfail=0, i, response;
  char inbuf[512], response_data[50], srerrmsg[70]; 
  char *errmsg=NULL;
  char *outbuf=NULL;
  int  force_aim_login = 0;
  int  resp;
  long msg;
  int  DCType=0;

  /* Now fill the postman buffer with the 
   	1. code
   	2. catalog
  	3. part number
	4. revision 
	5. AR Obid
   */

/*
  if( IsPmeEnabled() == FALSE )
  {
      force_aim_login = AIMlogin();
  }
*/

  if( IsPmeEnabled() == FALSE )
  {
    status =1;
    return status;
  }

  //TLS 05-06-02 - Changes for AMDC Phase II

  if(arstate == AR_REJECT)
  {
  	__DBGpr_com("We are Rejecting an AR");
 	UI_status("Rejecting AR...");
  	__DBGpr_com("Setting commande code to VDP_REJECT_AR");
	code = VDP_REJECT_AR; //137
  	__DBGpr_int("code", code );
  }

  if(arstate == AR_CHECKING)
  {
  	//Determine the Design Context Type
  	//code = 133; /* VDP_MAKE_AR_CHECKING;  133 */
  	status = CMGetDCType(refresh->rev_catalog, refresh->rev_partid, 
                     refresh->rev_revision, &DCType);

  	if( status )
  	{
  		resp = EX_FORM_FINISHED;
        	ex$putque( msg = &msg,
               	   response = &resp);
	      	status = 1;
      		//return status;
        	goto wrapup;
  	}

  	__DBGpr_int("Design Context Type", DCType );

  	if (DCType == MDCTYPE)
  	{
		UI_status("Moving AR to Checking");
  		__DBGpr_com("Setting commande code to VDP_MAKE_AR_CHECKING");
		code = VDP_MAKE_AR_CHECKING;
  		__DBGpr_int("code", code );
 	 }
  
  	if (DCType == AMDCTYPE)
  	{
		UI_status("Moving AR to Checking");
  		__DBGpr_com("Setting commande code to VDP_MAKE_AMDC_AR_CHECKING");
		code = VDP_MAKE_AMDC_AR_CHECKING;
  		__DBGpr_int("code", code );
  	}
  }

  inlen = 0;
  index = 0;
/* inbuf is arobid-cat-part-rev */
  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;

  strcpy( &inbuf[index], arobid );
  inlen += strlen(arobid) +1;
  index = inlen;
  
  strcpy( &inbuf[index], refresh->rev_catalog );
  inlen += strlen(refresh->rev_catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_partid );
  inlen += strlen(refresh->rev_partid) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_revision );
  inlen += strlen(refresh->rev_revision) +1;
  index = inlen;

  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

  if(dstat != 0)
  {
    	if(dstat == 12345)
    	{
      		UI_status("AIM connection was reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
		strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
    		return status;
	}
    	if(errmsg) __DBGpr_str("errmsg", errmsg );
       	status = 1;
    	//return status;
        goto wrapup;
  }

  if (mfail != 0 )
  {
  	if(*errmsg)
  	{
              __DBGpr_str("ERROR 1 ", errmsg );
        }
        status = mfail;
        goto wrapup;
  }

wrapup:

/*
  if((IsPmeEnabled() == TRUE) && force_aim_login)
  {
    
        UI_status("Disconnecting From AIM server");
  	__DBGpr_com("Disconnecting from AIM server...");
    status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                                NULL,
                                                NULL,
                                                NULL,
                                                NULL,
                                                &errmsg);
    if ( !status)
      EnablePME(0);
    UI_status("Disconnected From AIM server");
  	__DBGpr_com("Disconnected from AIM server...");
  }
*/

  return status;

}

#if 0

/*********************************************************
* Function: CMmake_transition
*
*
*
***********************************************************/
int CMmake_transition()
{
  int  sts = 0;

  /* TLS 
    1. Check the CMEnabled Flag to see if we 
       can Configuration Manage the file. 
    2. Also check the state   SSR
    3. Must to check AIM connection.
   */
  /* if( CMenable == TRUE ) this attribute name may change 
   * It is better to see if the MDC exists for the file if yes proceed 
   * else return success.*/
 
    if(!strcmp(CMstate, CHECKING ))
      sts = CMstate_form(); 
    printf("\n sts after baseline %d", sts);

    if(!strcmp(CMstate, RELEASE))
      sts = CMRelease();
    printf("\n sts after release %d",sts);

  return sts;

}
#endif

/*********************************************************
* Function: CMGetArs
*
*
*
***********************************************************/
int CMGetArs( catalog, partno, rev, aimstate, outbuf )
  char *catalog;
  char *partno;
  char *rev;
  int  aimstate;
  char **outbuf;
{
  int status = 0, sts=0;
  int inlen=0;
  int outlen=0;
  int code=0;
  int dstat=0;
  int mfail=0;
  int index=0, index1=0, numARs=0, response=0;
  int i = 0;
  char inbuf[512], response_data[50];
  char *errmsg=0,srerrmsg[70];
  int force_aim_login = 0;


   /*
     Send Cmd to AIM through Postman to:
     1. fill the in buffer with the code ( =  )
     2. fill the in buffer with the catalog, partno and rev

    */

   __DBGpr_com("CMGetArs START");
    if( IsPmeEnabled() == FALSE )
    {
	force_aim_login = AIMlogin();
	/*
      status = CMAimConnect();
      do
      {
        ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
      } while( response != EX_FORM_FINISHED );
      */
    }
    if( IsPmeEnabled() == FALSE )
    {
      status = 1;
      return status;
    }

     //TLS 04-29-02 - AMDC Phase II
     //determine the command code
     if (aimstate == AR_WORKING)
	code = VDP_GET_WORKING_ARS;
     
     if (aimstate == AR_WORKING_ONLY)
	code = VDP_GET_DC_ARS;

     if (aimstate == AR_CHECKING)
	code = VDP_GET_DC_ARS;
     
     //TLS 04-29-02 - AMDC Phase II
     //code = aimcode;

    //printf("\n I am in here with code %d, cAT %s, part %s",code,catalog,partno);

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     strcpy( &inbuf[index], catalog );
     inlen += strlen(catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], partno );
     inlen += strlen(partno) +1;
     index = inlen;

     strcpy( &inbuf[index], rev );
     inlen += strlen(rev) +1;
     index = inlen;
  
     if(aimstate == AR_CHECKING)
     {
	strcpy( &inbuf[index], CMCHECKING);
     	inlen += strlen(CMCHECKING) +1;
     	index = inlen;
     }

     if(aimstate == AR_WORKING_ONLY)
     {
	strcpy( &inbuf[index], CMWORKING);
     	inlen += strlen(CMWORKING) +1;
     	index = inlen;
     }

    /*__DBGpr_int("inlen ", inlen);*/
    /* printf("inlen %d", inlen);*/

    UI_status( "Querying AIM database for ARs..." );
    __DBGpr_com("Sending the GET ARs command to AIM.");

    /*for ( i=0;i<inlen;i++)
     printf(" %c", inbuf[i]);*/

     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   outbuf, &mfail, &errmsg);

     /*__DBGpr_int("dstat ", dstat); */
     if(dstat != 0)
     {
       /*__DBGpr_int("dstat is bad. dstat ", dstat);*/
       //if(dstat == 12345)
       //  UI_status("AIM connection reset by server.");
       if(dstat == 12345 )
       {
       	 UI_status("AIM connection reset by server.");
         UI_status( "Couldnot Query AIM database for ARs." );
 	 printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
         strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
         __DBGpr_str("srerrmsg", srerrmsg );
         ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         status = 1;
         return status;
       }
       __DBGpr_int("dstat is bad. dstat", dstat);
       __DBGpr_str("errmsg", errmsg );
       UI_status( "Could Not Query AIM database for ARs." );
       status = 1;
       //return status;
	goto wrapup;
     }

     if (mfail != 0 )
     {
       	if(errmsg)
       	{
        	/*__DBGpr_str("errmsg ", errmsg);*/
         	__DBGpr_str("errmsg", errmsg);
       	}
       	
	__DBGpr_int("mfail is bad.  mfail ", mfail);
	
	if( mfail == 47 )
	{
       		__DBGpr_com("Could not find the Design Context.");
       		UI_status( "Could Not Locate the Design Context." );
	}

       	UI_status( "Could Not Query AIM database for ARs." );
		
       	status = 1;
       	//return status;
	goto wrapup;
     }
    UI_status( "" );

  memcpy( &numARs, outbuf[0], sizeof(int));
  __DBGpr_int( "number of ARs found are ", numARs );

wrapup:
    if((IsPmeEnabled() == TRUE) && force_aim_login)
    {
      //if(ForceConn() == 1)
      //{
        UI_status("Disconnecting From AIM server");
  	__DBGpr_com("Disconnecting from AIM server...");
        sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
        if ( !sts)
          EnablePME(0);
        UI_status("Disconnected From AIM server");
  	__DBGpr_com("Disconnected from AIM server...");
      //}
    }

  __DBGpr_com("CMGetArs END");
return status;


}


/*********************************************************
* Function: CMstate_form
*
* This function loads/creates, initializes, and displays 
* the form displays the list of working ARs when a user tries to select a state
*
*
***********************************************************/
int CMstate_form()
{
  int  sts = 0, resp;
  char *outbuf = NULL;
  int  numARs = 0, index1=0, i=0, response;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[5], response_data[50], IsSuper[20];
  long msg;
  int  force_aim_login = 0;
  char *errmsg=NULL;
  int  DCType=0;
  int stsFailed=0;

  CM_state_form_created = FALSE;
  CM_state_form_displayed = FALSE;
  CM_state_perm_window = FALSE;

  __DBGpr_com("START CMstate_form");
  /*printf("\n CAT %s, PART %s, REV %s", refresh->rev_catalog, 
         refresh->rev_partid, refresh->rev_revision);*/

  sts = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                       refresh->rev_revision, ARsel, CMmng,
		       DCCsel, Mdc, IsSuper);
  if(sts)
  {
    __DBGpr_com("couldnot get CM attrs.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    sts = 1;
    goto wrapup;
  }

  //printf("\n ar %s, cm %s, dcc %s", ARsel, CMmng, DCCsel );
    /* If File is not CM managed, don'n go to aim and get ARs */
  if(strcmp(CMmng, "Y"))
  {
    __DBGpr_com("File is not CM managed.");
    if(PDU_state_form_created == TRUE)
      FIg_enable( forms.move_state_form_id, FI_EXECUTE );
    if(PDU_mcf_list_displayed == TRUE)
        FIg_enable(forms.mcf_list_form_id, FI_ACCEPT );
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 1;
    //return 0;
    sts = 0;
    goto wrapup;
  }

  //if(CMstate) __DBGpr_str("STATE", CMstate );

  /* If these revisions are correct, 
   * send them to SIR and get list of Working ARs, 
   * function GetARs() with proper code  Get list from SIr and populate form
   */

  if(strcmp(Mdc, "Y"))
  {
    UI_status("DAD information incorrect; Post the file.");
    __DBGpr_com("M D C doesn't exist.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    //return 1;
    sts = 1;
    goto wrapup;
  }
  if(strcmp(ARsel, "Y") && strcmp(DCCsel, "N") )
  {
    UI_status("No ARs selected; Cannot change state.");
    __DBGpr_com("No ARs selected; Cannot change state.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
              response = &resp);
    ChkOK = 0;
    //return 1;
    sts = 1;
    goto wrapup;
  }
    /* Check for AIM conenction */
  if(IsPmeEnabled()==FALSE)
  {
      force_aim_login = AIMlogin();
      if(force_aim_login == 1)
	ForceConnect = 1;
  }

  if(IsPmeEnabled() == FALSE)
  {
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    //return 0;
    sts = 1;
    goto wrapup;
  }

  sts = FIf_new(CM_MOVE_STATE_FORM, "CMMvSt.frm", 
                cm_state_notification_routine, &cm_move_state_form_id);
  if(cm_move_state_form_id == NULL)
  {
    printf("\nCould not Create form <CMMvSt.frm>.");
    stsFailed=1;
    sts = 1;
    goto wrapup;
  }


    //TLS 05-03-02 - Changes for AMDC Phase II
    //		     Determine the Design Context Type
    sts = CMGetDCType(refresh->rev_catalog, refresh->rev_partid, 
                     refresh->rev_revision, &DCType);

    if( sts )
    {
  	resp = EX_FORM_FINISHED;
        ex$putque( msg = &msg,
               	   response = &resp);
    	stsFailed=1;
      	sts = 1;
      	goto wrapup;
    }

    __DBGpr_int("Design Context Type", DCType );

    if (DCType == MDCTYPE)
    {
	
    	UI_status("Getting ARs from AIM for MDC...");
    	//TLS 04-29-02 - Changes for AMDC Phase II
    	//sts = CMGetArs ( refresh->rev_catalog, refresh->rev_partid, 
    	//                 refresh->rev_revision , VDP_GET_WORKING_ARS, &outbuf);
    	sts = CMGetArs ( refresh->rev_catalog, refresh->rev_partid, 
                     	refresh->rev_revision , AR_WORKING_ONLY, &outbuf);
    	if( sts )
    	{
        	resp = EX_FORM_FINISHED;
         	ex$putque( msg = &msg,
                    	   response = &resp);
      		//return sts;
    		stsFailed=1;
      		sts = 1;
      		goto wrapup;
    	}
    }

    if (DCType == AMDCTYPE)
    {
    	UI_status("Getting ARs from AIM for AMDC...");
	sts = CMGetContainedARs(refresh->rev_catalog, refresh->rev_partid, 
                     	  	refresh->rev_revision , &outbuf);

	if( sts )
    	{
        	resp = EX_FORM_FINISHED;
         	ex$putque( msg = &msg,
                    	   response = &resp);
      		//return sts;
    		stsFailed=1;
      		sts = 1;
      		goto wrapup;
    	}
    }

    /* extract outbuf */
    memcpy( &numARs, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);
    __DBGpr_int("1. no of ars ", numARs );

    if(numARs)
    {
      /* Set the nos of rows = numARs extra for the default entry */
      FIfld_set_num_rows( cm_move_state_form_id, CP_ARTBL, numARs );

      for ( i=0; i<numARs; i++)
      {
        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_ARNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_AIRNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_AIRREV, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                  i, CP_C_FMRNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_FMRREV, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_TIT, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_DATE, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_OBID, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

	//TLS 04-12-02 Fix TR 6272
	// 		Due to TR fix, COG Eng is being sent back
	//		in the buffer so we need to increase the
	//		buffer to skip over the string.
        //FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
        //            i, CP_C_OBID, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

      }
      FIfld_set_text( cm_move_state_form_id, 9, 0, 0, 
                    "Select ARs to move the state.", FALSE );
    }

  _pdm_debug("Creating CM state form", 0);
  CM_state_form_created = TRUE;
  /*
  * if (PDU_acl_group_list)
  *  {
  *  _pdm_debug("loading ARs into CM form", 0);
  *   sts = CMload_move_state_form();
  *  _pdm_status("CMload_move_state_form", sts);
  *  if (sts != PDM_S_SUCCESS)
  *    {
  *    FIf_delete(cm_move_state_form_id);
  *    CM_state_form_created = FALSE;
  *    CM_state_form_displayed = FALSE;
  *    CM_state_perm_window = FALSE;
  *    return(sts);
  *    }
  *  }
  **/
  /*FIf_erase(forms.local_files_form_id);
   * PDU_local_files_displayed = FALSE;
   **/

  /* Display the state form and set the displayed state to TRUE. */
  _pdm_debug("Displaying the CM state form", 0);

  sts = FIf_display(cm_move_state_form_id);
  CM_state_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

wrapup:
  if(outbuf) free(&outbuf);

  if (stsFailed == 1)
  {
  	if((IsPmeEnabled() == TRUE) && force_aim_login)
  	{
    		sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                	                        NULL,
                        	                NULL,
                                	        NULL,
                                        	NULL,
                                       		&errmsg);
    		if ( !sts)
      		{
      			EnablePME(0);
    			UI_status("Disconnected From AIM server");
     		}
  	}
  }

  return(sts);
}

/*********************************************************
* Function: CMload_move_state_form
*
* This function loads/creates, initializes, and displays 
* the login form. 
*
*
***********************************************************/
void CMload_move_state_form()
{

  int i=0;
  int status = 0;
  int numARs = 0;
  int index1 = 0;
  char *outbuf = NULL;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0;
  char inbuf[512]; 
  char *errmsg=NULL;
  char srerrmsg[70];


  /* TLS
     1. Query AIM for the list of ARs Working to show on this form.
     	Use the catalog, partno and revision to get the MDC object,
	then use the MDC object to find the related ARs.

     2. When the AIM Outbuffer returns, parse the buffer to get
	the list of ARs and display the list on the form.
   */


   __DBGpr_com("in CMload_move_state_form");
  /* call the function to query AIM */
  status = CMGetArs(&outbuf);

  /* check the status */

  /* parse the buffer for the number of ARs being displayed */
  memcpy( &numARs, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);

  /* parse the buffer for the list of ARs and add to form */
  for ( i = 0; i < numARs; i++ )
  {

    /* store the results on the form */
    _pdm_debug("writing to Change Promotion", 0);

    _pdm_debug("AR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, ARNUM, i, 0,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("AIR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, AIRNUM, i, 1,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("AIR Revision = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, AIRREV, i, 2,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("FMR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, FMRNUM, i, 3,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("FMR Revision = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, FMRREV, i, 4,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("Title = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, TITLE, i, 5,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("Creation Date = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, CREDATE, i, 6,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("OBID = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_move_state_form_id, AROBID, i, 7,
                            &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

  }

/* Change the AR relaiton ship to checking */
  code = 133; /*VDP_MAKE_AR_CHECKING;  122*/

     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_catalog );
     inlen += strlen(refresh->rev_catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_partid );
     inlen += strlen(refresh->rev_partid) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_revision );
     inlen += strlen(refresh->rev_revision) +1;
     index = inlen;



     __DBGpr_com("trying to talk with AIM");
     UI_status("Changing AR MDC relations in AIM");
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     if(dstat != 0)
     {
       	if(dstat == 12345)
  	{
         	UI_status("AIM connection reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
		strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        }
       status = 1;
     }

     if (mfail != 0 )
     {
       if(errmsg)
       {
        __DBGpr_str("ERROR 2 %s", errmsg );
       }
       status = mfail;
     }
/*
  for ( i = 0; i < *numARs; i++ )
  {
  	(*ARItm)[i].ARNo[0] = '\0';
        (*ARItm)[i].AIRNo[0] = '\0';
        (*ARItm)[i].AIRRev[0] = '\0';
        (*ARItm)[i].FMRNo[0] = '\0';
        (*ARItm)[i].FMRRev[0] = '\0';
        (*ARItm)[i].Title[0] = '\0';
        (*ARItm)[i].ChgState[0] = '\0';
        (*ARItm)[i].CreDate[0] = '\0';
        (*ARItm)[i].Obid[0] = '\0';

        strcpy((*ARItm)[i].ARNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].ARNo) +1;

        strcpy((*ARItm)[i].AIRNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].AIRNo) +1;

        strcpy((*ARItm)[i].AIRRev, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].AIRRev) +1;

        strcpy((*ARItm)[i].FMRNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].FMRNo) +1;

        strcpy((*ARItm)[i].FMRRev, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].FMRRev) +1;

        strcpy((*ARItm)[i].Title, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].Title) +1;

        strcpy((*ARItm)[i].ChgState, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].ChgState) +1;


        strcpy((*ARItm)[i].CreDate, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].CreDate) +1;


        strcpy((*ARItm)[i].Obid, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].Obid) +1;

  }
*/

}
/************************************************************
* Function CMReject
* IF a state is back to development, change the ARs selcted to WORKING
***************************************************/
int CMReject()
{
  int status = 0, sts=0;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0, response=0;
  char inbuf[512],srerrmsg[70]; 
  char *errmsg=NULL, *outbuf =NULL;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[2], response_data[50], IsSuper[20];
  int  force_aim_login = 0;
  int  resp;
  long msg;
  int  numARs=0;
  int  index1=0, i=0;
  int stsFailed=0;
  MEMptr ret_bufr = NULL;
  char   *string = NULL;
  char   **data_row;

  __DBGpr_com("BEGIN CMReject");

  //TLS 05-06-02 - Entire method modified for AMDC Phase II

  CM_state_form_created = FALSE;
  CM_state_form_displayed = FALSE;
  CM_state_perm_window = FALSE;

  status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                          refresh->rev_revision,
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  if(status)
  {
    __DBGpr_com("Could Not Get CM attrs.");
    UI_status("Could Not Get CM attrs.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    status = 1;
    goto wrapup;
  }

  if(strcmp(CMmng, "Y"))
  {
    UI_status("File Not CM Managed.");
    __DBGpr_com("File Not CM Managed.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 1;
    status = 0;
    goto wrapup;
  }

  if(strcmp(Mdc, "Y"))
  {
    UI_status("DAD Not Set.");
    __DBGpr_com("DAD Not Set.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    status = 1;
    goto wrapup;
  }

  //if DCC was selected then skip process
  if(strcmp(ARsel, "Y") && strcmp(DCCsel, "Y") )
  {
    UI_status("DCC was selected.");
    __DBGpr_com("DCC was selected.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 1;
    status =0;
    goto wrapup;
  }  

  //get the current state
  status = PDMget_state(refresh->rev_catalog, refresh->rev_partid,
                        refresh->rev_revision, &ret_bufr);
  __DBGpr_int(" PDMget_state", status);

  if (ret_bufr != NULL)
  {
    MEMbuild_array(ret_bufr);
    PDUsetup_buffer(ret_bufr, ROW, &data_row);
    PDUfill_in_string(&string, data_row[(ret_bufr->columns * 0) + 0]);
    __DBGpr_str("state", string);
  }

  //see if the state is Checking, if so no need to continue
  if(!strcmp(string, CHECKING_STATE) )
  {
    __DBGpr_com("In Checking State - no need to get AR's.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 1;
    status =0;
    goto wrapup;
  }

  if(strcmp(ARsel, "Y") && strcmp(DCCsel, "N") )
  {
    UI_status("No ARs selected; Cannot change state.");
    __DBGpr_com("No ARs selected; Cannot change state.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    status =0;
    goto wrapup;
  }

  /*Establish AIM connection */
  if( IsPmeEnabled() == FALSE )
  {
      force_aim_login = AIMlogin();
      if(force_aim_login == 1)
	ForceConnect = 1;	
  }
  if(IsPmeEnabled() == FALSE)
  {
   resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    status = 1;
    UI_status("Not Connected to AIM.");
    goto wrapup;
  }

  //ALL NEW
  
  status = FIf_new(CM_MOVE_STATE_FORM, "CMMvSt.frm", 
                cm_state_notification_routine, &cm_move_state_form_id);
  if(cm_move_state_form_id == NULL)
  {
    printf("\nCould not Create form <CMMvSt.frm>.");
    stsFailed=1;
    status = 1;
    goto wrapup;
  }

  status = CMGetArs ( refresh->rev_catalog, refresh->rev_partid, 
            	refresh->rev_revision , AR_CHECKING, &outbuf);
  if( status )
  {
    	resp = EX_FORM_FINISHED;
       	ex$putque( msg = &msg,
               	   response = &resp);
    	stsFailed=1;
      	status = 1;
      	goto wrapup;
  }
    
  // extract outbuf
  memcpy( &numARs, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);
  __DBGpr_int("1. no of ars ", numARs );

  if(numARs)
  {
      // Set the nos of rows = numARs extra for the default entry
      FIfld_set_num_rows( cm_move_state_form_id, CP_ARTBL, numARs );

      for ( i=0; i<numARs; i++)
      {
        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_ARNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_AIRNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                   i, CP_C_AIRREV, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                  i, CP_C_FMRNUM, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_FMRREV, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_TIT, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_DATE, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

        FIfld_set_text( cm_move_state_form_id, CP_ARTBL,
                    i, CP_C_OBID, &outbuf[index1], FALSE );
        index1 = index1 + strlen( &outbuf[index1] ) +1;

	index1 = index1 + strlen( &outbuf[index1] ) +1;

      }
      FIfld_set_text( cm_move_state_form_id, 9, 0, 0, 
                    "Select ARs to move the state.", FALSE );
  }

  //set the global variable to Reject
  gARProcess = AR_REJECT; 

  _pdm_debug("Creating CM state form", 0);
  CM_state_form_created = TRUE;
  
  // Display the state form and set the displayed state to TRUE. 
  _pdm_debug("Displaying the CM state form", 0);

  status = FIf_display(cm_move_state_form_id);
  CM_state_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

/************************************************
  code = 137; 

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  // inbuf cat-part-rev
  strcpy( &inbuf[index], refresh->rev_catalog );
  inlen += strlen(refresh->rev_catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_partid );
  inlen += strlen(refresh->rev_partid) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_revision );
  inlen += strlen(refresh->rev_revision) +1;
  index = inlen;

  __DBGpr_com("trying to talk with AIM ");
  UI_status("Changing AR relationships in AIM.");
  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

  //printf("\n dstat %d, mfail %d", dstat, mfail);
  if(dstat != 0)
  {
    	if(dstat == 12345)
	{
      		UI_status("AIM connection reset by server.");
    		UI_status("Could not change AR relationships in AIM.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
		strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }

    if(errmsg) __DBGpr_str("errmsg ", errmsg );
    UI_status("Could not change AR relationships in AIM.");
    status = 1;
    goto wrapup;
  }

  if (mfail != 0 )
  {
    if(errmsg) __DBGpr_str("ERROR %s", errmsg );
    UI_status("Could not change AR relationships in AIM.");
    status = 1;
    goto wrapup;
  }

***********************************/

wrapup:
  if(outbuf) free(&outbuf);

  if (stsFailed == 1)
  {
  	if((IsPmeEnabled() == TRUE) && force_aim_login)
  	{
    		sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                	                        NULL,
                        	                NULL,
                                	        NULL,
                                       		NULL,
                                       		&errmsg);
    		if ( !sts)
     	 	{
      			EnablePME(0);
    			UI_status("Disconnected From AIM server");
      		}
  	}
  }

  __DBGpr_com("END CMReject.");
  //SSR 21 JAN
  if(errmsg) free(&errmsg);
  if(outbuf) free(&outbuf);
  return status;
}

/**********************************************************
* Function CMBaseline
* if file is CMEnabled, 1. baseline MDC, 2. Change the relation
* If not ; Just baseline the MDC
**********************************************************/

int CMBaseline()
{
  int status = 0, sts=0;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0, response=0;
  char inbuf[512],srerrmsg[70]; 
  char *errmsg=NULL, *outbuf =NULL;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[2], response_data[50], IsSuper[20];
  int force_aim_login = 0;

  __DBGpr_com("PDUaim_cm.c.CMBaseline START ");
  /* Check for MDC existance */

  status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                          refresh->rev_revision,
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  /* No movement to Baseline if PART is Superseeded */
  if(!strcasecmp(IsSuper, "Y"))
  {
    UI_status("Part is superseded; Cannot change state of the part.");
    status = 1;
    goto wrapup;
  }
  if(strcmp(Mdc, "Y"))
  {
    status =0;
    goto wrapup;
  }
  if( IsPmeEnabled() == FALSE )
  {
      force_aim_login = AIMlogin();
      /*
    status = CMAimConnect();
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
    } while( response != EX_FORM_FINISHED );
    */
  }
  if(IsPmeEnabled() == FALSE)
  {
    status = 1;
    goto wrapup;
  }

  code = VDP_BASELINE_MDC; // 122

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  /* inbuf cat-part-rev  */
  strcpy( &inbuf[index], refresh->rev_catalog );
  inlen += strlen(refresh->rev_catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_partid );
  inlen += strlen(refresh->rev_partid) +1;
  index = inlen;

  strcpy( &inbuf[index], refresh->rev_revision );
  inlen += strlen(refresh->rev_revision) +1;
  index = inlen;

  __DBGpr_com("trying to talk with AIM for VDP_BASELINE_MDC");
  UI_status("Baselining M D C in AIM.");
  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

  if(dstat != 0)
  {
    	if(dstat == 12345)
	{
      		UI_status("AIM connection reset by server.");
    		UI_status("Could not baseline MDC.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }

    if(errmsg) __DBGpr_str("errmsg ", errmsg );
    UI_status("Could not baseline M D C.");
    status = 1;
    goto wrapup;
  }

  if (mfail != 0 )
  {
    if(errmsg)
    {
      __DBGpr_str("ERROR 2 ", errmsg );
    }
    status = mfail;
    UI_status("Could not baseline M D C.");
    status = 1;
    goto wrapup;
  }
  /* Create buffer for updating relations  do this only if file is CMEnabled*/

  /* If the file is CM managed, change the AR MDC relation in AIM to 
   * RELEASED */

  if( strcmp( CMmng, "Y" ))
  {
    status =  0;
    goto wrapup;
  }

  if(!strcmp(ARsel, "Y"))
  {
    inlen = 0;
    index = 0;
    *inbuf = NULL;
    code = VDP_MAKE_AR_RELEASED; /* 134 */

    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* inbuf arobid-cat-part-rev */
    strcpy( &inbuf[index], refresh->rev_catalog );
    inlen += strlen(refresh->rev_catalog) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_partid );
    inlen += strlen(refresh->rev_partid) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_revision );
    inlen += strlen(refresh->rev_revision) +1;
    index = inlen;

    UI_status("Changing AR MDC relations in AIM");
    __DBGpr_com("trying to talk with AIM for VDP_MAKE_AR_RELEASED");
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

    if(dstat != 0)
    {
      	if(dstat == 12345)
	{
        	UI_status("AIM connection reset by server.");
      		UI_status("Could not change MDC to AR relation.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }

      if(errmsg) __DBGpr_str("errmsg ", errmsg );
      status = 1;
      UI_status("Could not change M D C AR relation.");
      goto wrapup;
    }

    if (mfail != 0 )
    {
      if(errmsg)
      {
        __DBGpr_str("ERROR 2 ", errmsg );
      }
      status = 1;
      UI_status("Could not change M D C AR relation.");
      goto wrapup;
    }
  }


  wrapup:
    if((IsPmeEnabled() == TRUE) && force_aim_login)
    {
      //if(ForceConn() == 1)
      //{
        UI_status("Disconnecting From AIM server");
  	__DBGpr_com("Disconnecting from AIM server...");
        sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
        if ( !sts)
          EnablePME(0);
        UI_status("Disconnected From AIM server");
  	__DBGpr_com("Disconnected from AIM server...");
      //}
    }

    // 21 JAN SSR
    /*	TLS 10-22-01 
     *	Fixed for TR 5676
     */
   if(errmsg) free(&errmsg);
   if (outbuf) free(&outbuf);
    __DBGpr_com("PDUaim_cm.c.CMBaseline END ");
    return status;
}

/********************************************
* Function CMRelease
* this is to Release the part.
* in SIR it changes the relaitonship to implemented
*****************************************************/
int CMRelease()
{

  int status = 0, sts;
  int inlen=0;
  int outlen=0;
  int code=0; 
  int dstat=0; 
  int mfail=0;
  int index=0, response=0;
  char inbuf[512], response_data[50], srerrmsg[70];
  char *errmsg=NULL, *outbuf =NULL;
  char ARsel[2], CMmng[2], NDCCsel[2], Mdc[2], IsSuper[20];
  int  force_aim_login = 0;

  __DBGpr_com("PDUaim_cm.c.CMRelease START ");

  status = SrVDGetCMattrs( refresh->rev_catalog, refresh->rev_partid,
                           refresh->rev_revision, ARsel,
                           CMmng, NDCCsel, Mdc, IsSuper);
  /* Donot Release if PART is Superseede */
  if(!strcasecmp(IsSuper, "Y"))
  {
    UI_status("Part is superseded; Can not change state of part.");
    return 1;
  }
  
  if(strcmp(Mdc, "Y"))
  {
    UI_status("M D C doesnot exist; Can not change state of the part.");
    return 1;
  }

  if( !strcmp(ARsel, "Y"))
  {
    if( IsPmeEnabled() == FALSE )
    {
	force_aim_login = AIMlogin();
	/*
      status = CMAimConnect();
      do
      {
        ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
      } while( response != EX_FORM_FINISHED );
    */
      }
    if(IsPmeEnabled() == FALSE)
    {
      status = 1;
      goto wrapup;
    }
    __DBGpr_com("ARs selcted.");

    code = VDP_MAKE_AR_IMPLEMENTS;  /* 135 */

    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* inbuf arobid-cat-part-rev */

    strcpy( &inbuf[index], refresh->rev_catalog );
    inlen += strlen(refresh->rev_catalog) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_partid );
    inlen += strlen(refresh->rev_partid) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_revision );
    inlen += strlen(refresh->rev_revision) +1;
    index = inlen;



    __DBGpr_com("trying to talk with AIM to VDP_MAKE_AR_IMPLEMENTS");
    UI_status("Modifying AR MDC relations in AIM.");
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

    if(dstat != 0)
    {
      	if(dstat == 12345)
	{
        	UI_status("AIM connection reset by server.");
      		UI_status("Could not change MDC to AR relation.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }

      if(errmsg) __DBGpr_str("errmsg", errmsg );
      UI_status("Could not change M D C AR relation.");
      status = 1;
      goto wrapup;
    }

    if (mfail != 0 )
    {
      if(errmsg)
      {
        __DBGpr_str("ERROR 2", errmsg );
      }
      status = 1;
      UI_status("Could not change M D C AR relation.");
      goto wrapup;
    }
  }/* End if ARsel == Y */

  else
  {
	/* TLS 10/05/00:  Added for TR# 2169 */
    if( IsPmeEnabled() == FALSE )
    {
	force_aim_login = AIMlogin();
      /*
      status = CMAimConnect();
      do
      {
        ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
      } while( response != EX_FORM_FINISHED );
      */
    }
    if(IsPmeEnabled() == FALSE)
    {
      status = 1;
      goto wrapup;
    }
    __DBGpr_com("No ARs selcted.  Just set Released For CM Control Flag on MDC.");

    code = VDP_MAKE_MDC_RELEASED;  /* 138 */

    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

    /* inbuf cat-part-rev */

    strcpy( &inbuf[index], refresh->rev_catalog );
    inlen += strlen(refresh->rev_catalog) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_partid );
    inlen += strlen(refresh->rev_partid) +1;
    index = inlen;

    strcpy( &inbuf[index], refresh->rev_revision );
    inlen += strlen(refresh->rev_revision) +1;
    index = inlen;

    __DBGpr_com("trying to talk with AIM to VDP_MAKE_MDC_RELEASED");
    UI_status("Setting MDC to Released For CM Control in AIM.");
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

    if(dstat != 0)
    {
      	if(dstat == 12345)
	{
        	UI_status("AIM connection reset by server.");
      		UI_status("Could not change MDC to AR relation.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }

      if(errmsg) __DBGpr_str("errmsg", errmsg );
      UI_status("Could not change M D C AR relation.");
      status = 1;
      goto wrapup;
    }

    if (mfail != 0 )
    {
      if(errmsg)
      {
        __DBGpr_str("ERROR 2", errmsg );
      }
      status = 1;
      UI_status("Could not set MDC to Released For CM Control.");
      goto wrapup;
    }
 
  } /* Just set the MDC to Released for CM Control  in AIM */



  /* Update the CMemabled flag to CM managed */

  SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid, 
                      refresh->rev_revision, CMENAB, "Y" );


  wrapup:
    if((IsPmeEnabled() == TRUE) && force_aim_login)
    {
      //if(ForceConn() == 1)
      //{
        UI_status("Disconnecting From AIM server");
  	__DBGpr_com("Disconnecting from AIM server...");
        sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
        if ( !sts)
          EnablePME(0);
        UI_status("Disconnected From AIM server");
  	__DBGpr_com("Disconnected from AIM server...");
      //}
    }
  __DBGpr_com("PDUaim_cm.c.CMRelease END ");
  //SSR 21JAN
  if(errmsg) free(&errmsg);
  if(outbuf) free(&outbuf);
  return status;
}






int conct_notification( f_label, g_label, fp )
 int f_label; /* The label of the form */
 int g_label; /* The label of the gadget */
 Form fp;

{
  int			status, state;
  char			*errmsg;
  unsigned char			server_name[25];
  struct hostent	*h;
  long			msg;
  char			srerrmsg[80]; 
  int			sel, pos, resp;
  char			err_msg[100]; 

  int                   code1, sts1, stat_flag; 
  char                  aim_user2[50], aim_server2[25], aim_env2[15];
  char                  aim_user3[50], aim_server3[25], aim_env3[15];
  struct tm		*nowtime;
  time_t		long_time;
  int			last, now;




  __DBGpr_com("conct_notification START");

  
  	
	switch ( g_label )
	{ 
	 case FI_CANCEL :

	/*     FIf_erase ( con_form_id);
             FIf_delete ( con_form_id );
             resp = EX_FORM_FINISHED;
             ex$putque( msg = &msg,
                        response = &resp);
             status = 1;
	     break; 
	 */
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
	   FIf_erase ( con_form_id);
	   resp = EX_FORM_FINISHED;
           ex$putque( msg = &msg, response = &resp);
           status = 1;

	   break;  
	 
	 case FI_EXECUTE: 
/*	     FIfld_get_text ( con_form_id, 16, 0, 0, 30, server_name, &sel, &pos);
	     server_name[24] = '\0'; 
	     if ((h=gethostbyname(server_name)) == NULL) 
	     {  /* get the host info */
/*	       sprintf ( srerrmsg, "%s", "Server not recognised. Could not connect");
               UI_status ( srerrmsg );
               /*if (MS_init ( (&MS_msg), EX_F_Var1, NULL, NULL, 0, -1 ) )
               *{
               *  MS_fix_type( &MS_msg, "%s" );
               *  sprintf( (MS_msg.variables), (MS_msg.for_type), srerrmsg );
               *  MS_out_msg ( &MS_msg, NULL, 0,
               *         -1, MS_IMMEDIATE, MS_IMMEDIATE, 0);
               *}*/

/*	       FIf_erase ( con_form_id); 
	       FIf_delete ( con_form_id); 
               resp = EX_FORM_FINISHED;
               ex$putque( msg = &msg,
                        response = &resp);
	       return 1;
	     } 
	     
	     UI_status("Connecting to AIM server....");
	     status = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT,
		 	(char *)inet_ntoa(*((struct in_addr *)h->h_addr)),
		 	NULL,
			NULL,
			NULL,
			&errmsg);

		
	     
	     if ( !status)
	     {
	       EnablePME(1);
	       UI_status(" Connected to AIM server");

               VDPPutAimName(server_name);
               ForceConnect = 1;

	     }
		
		
	     
	     else
	     {
	       EnablePME(0);
	       UI_status( " Failed to Connect to AIM server" );
	     } 
	     
	     FIg_get_state (con_form_id, 12, &state);
	     
	     if(state == 1) ConnectAIM(PME) ;
	     if(state == 0) ConnectAIM(SIR);
	     
	     FIf_erase ( con_form_id );
	     FIf_delete ( con_form_id );
             resp = EX_FORM_FINISHED;
             ex$putque( msg = &msg,
                        response = &resp );
             status = 0;
	     break; 
*/


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
		 FIfld_set_text(con_form_id, 17, 0, 0, "", TRUE);
	  }
	   FIg_disable(con_form_id,1);
	   
	   FIfld_get_text (con_form_id, 16, 0, 0, 30, server_name, &sel, &pos);
	   server_name[24] = '\0'; 
	   
	   if ((h=gethostbyname(server_name)) == NULL) 
	   {  /* get the host info */
	     sprintf ( srerrmsg, "%s",
	              "Server not recognised. Could not connect" );
	 /*    if (MS_init ( (&MS_msg), EX_F_Var1, NULL, NULL, 0, -1 ) )
	     {
	       MS_fix_type( &MS_msg, "%s" );
	       sprintf( (MS_msg.variables), (MS_msg.for_type), srerrmsg );
	       MS_out_msg(&MS_msg, NULL, 0, -1, MS_IMMEDIATE, MS_IMMEDIATE, 0);
	     }
	  */   
	     FIf_erase ( con_form_id); 
	     resp = EX_FORM_FINISHED;
             ex$putque( msg = &msg, response = &resp );
             status = 0;
	     return(1);
	   }

           stat_flag = IsPmeEnabled();

	   FIg_get_state (con_form_id, 12, &state);

	   if(state == 1)
	     ConnectAIM(PME) ; 
	   
	   if(state == 0)
	   {
	     nowtime = localtime( &long_time );
	     now = nowtime->tm_year*10000 +
	    	(nowtime->tm_mon+1)*100 + 
	     	nowtime->tm_mday; 
	     if ( now > last )
	     {
	       UI_status ( "SIR beta expired" );
	       EX_error_box( FI_CURRENT_SCREEN,
		   "Beta SIR version has expired; Please contact INTERGRAPH", 
		   "Warning!"); 
	       return 0; 
	     } 
	   
	     ConnectAIM(SIR);
	   }
	   
	   status = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
	       NULL,
	       NULL, 
	       NULL,
	       NULL,
	       &errmsg);
	   
	   if ( !status)
	     EnablePME(0);  
	   
	   UI_status("Connecting to AIM server....");
	   status = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT,
	       (char *)inet_ntoa(*((struct in_addr *)h->h_addr)),
	       NULL, 
	       NULL, 
	       NULL, 
	       &errmsg);
	   
	   if ( !status)
	   {
	     EnablePME(1);
	     UI_status(" Connected to AIM server");
	     ForceConnect = 1;
	   } 
	   else
	   {
	     EnablePME(0);
	     UI_status( " Failed to Connect to AIM server" );
	   } 
	 
	      code1 = 444;
	      sts1 =  SrVDPGetAIMInfo(&code1, aim_user2, aim_server2, 
		    			  aim_env2);

  if(sts1)
  {
   UI_status("Not Connected to AIM Server");
   FIfld_set_text( con_form_id, 10, 0, 0, "Not Connected to AIM Server", TRUE );
   FIg_disable(con_form_id, FI_ACCEPT);
   FIfld_set_text(con_form_id, 17, 0, 0, "", TRUE);
   break;
  }

         VDPGetAimInfo(aim_user3, aim_server3, aim_env3);
        FIfld_set_text(con_form_id, 17, 0, 0, aim_env3, TRUE);
        FIfld_set_text(con_form_id, 10, 0, 0, "Connected to AIM Server", TRUE );
	FIg_disable(con_form_id, 2);
	FIg_enable(con_form_id, 1);

	   break; 

 case  FI_ACCEPT:

	   FIf_erase ( con_form_id );
	   resp = EX_FORM_FINISHED;
           ex$putque( msg = &msg, response = &resp );
           status = 1;  

	   break;

       case  SEL_AIM_SERVER:

	   FIg_enable(con_form_id, 2);
	   FIg_disable(con_form_id, 1);
   	   FIfld_set_text( con_form_id, 10, 0, 0, "Enter the Server Name", TRUE );
	   stat_flag = IsPmeEnabled();

         break;
	}   /* end switch*/
  __DBGpr_com("conct_notification END");

        return status;
}

int CMAimConnect ()
{
  int			status;

  int length, select, pos;
  static char *text;

  __DBGpr_com("in CMAimConnect" );
      status = FIf_new ( 101, "AIMlogin", conct_notification, &con_form_id);
      if(con_form_id == NULL)
      {
        __DBGpr_com("Not able to create form <AIMlogin>.");
        return 1;
      }
      status = FIf_display( con_form_id );
      FIfld_set_text( con_form_id, 9, 0, 0, "Enter the server name", FALSE );

      FIg_disable(con_form_id, 1);
      FIg_disable(con_form_id,17);

  __DBGpr_com("END CMAimConnect");

/* added code Pullabhotla 16/06/2000 */
 FIfld_get_text_length(con_form_id, 16, 0, 0, &length); 

 text = (char *) malloc (sizeof (char) * length + 1);
 memset(text, NULL, sizeof (char) * length + 1 );
 FIfld_get_text(con_form_id,16, 0, 0, length, 
		(unsigned char *)text, &select, &pos);


 
  if(status != FI_SUCCESS)
    status = FALSE;
  else
    status = TRUE;

  return status;
}
 
/*******************************************************************
* SrCMCopySim()
* Function to take care about copy similar of a part.
* Nothing to worry about if it is a new part.
* If it is a revision, if old file is under CM control, MDC is baselined
* Revisioning is allowed only in Baseline and Release states.
* SAUBY:  This function should not be used.  Instead, see AIMcmAddPart.
*******************************************************************/
int SrCMCopySim(char *CMMdcRev, char *t_LpdDesc)
{
  int status = 0, response, index=0, inlen=0, dstat, mfail, outlen, code;
  char  *outbuf=NULL, *errmsg = 0;
  char state[20], ARsel[2], CMmng[2], NDCCsel[2], Mdc[10], response_data[50];
  char inbuf[512], err[180], IsSuper[20], w_flow[20], cr_flag[2], srerrmsg[70];
  int sts, nbItems;

 __DBGpr_com("START SrCMCopySim ");

__DBGpr_str("File Applicability", t_LpdDesc);

if((!strcmp(refresh->new_catalog,""))|| refresh->new_catalog == NULL ||
   (!strcmp(refresh->new_partid,""))|| refresh->new_partid == NULL ||
   (!strcmp(refresh->new_revision,""))|| refresh->new_revision == NULL ||
   (!strcmp(refresh->rev_catalog,""))|| refresh->rev_catalog == NULL ||
   (!strcmp(refresh->rev_partid,""))|| refresh->rev_partid == NULL ||
   (!strcmp(refresh->rev_revision,""))|| refresh->rev_revision == NULL )
  goto wrapup;

//TR1364 nothing to do if old file is not from AVD_CM_W_FLOW
// SSR 7sep99
   status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
	   				refresh->rev_revision, w_flow);
   __DBGpr_str( " w_flow ", w_flow);
   //if(strcmp(w_flow, AVD_CM_WFLOW))
   if(strcasecmp(w_flow, "Y"))
   {
    __DBGpr_com(" Old part is not from CM workflow");
    status = 0;
    goto wrapup;
  }
/* Check if the process is new part creation */
  if (strcmp(refresh->new_partid, refresh->rev_partid))
  {
    __DBGpr_com(" New Part generation");
    status = 0;
    goto wrapup;
  }

  status = SrVDGetCMState( refresh->rev_catalog, refresh->rev_partid,
                           refresh->rev_revision, state); 

  __DBGpr_str("state", state );
  /*if(strcmp(state, BASELINE) || strcmp(state, RELEASE) )
  {
    sprintf(err, "File can not be revised in %s state", state);
    __DBGpr_str("er ",err);
    UI_status(err);
    status = 1;
    goto wrapup;
  }*/

  status = SrVDGetCMattrs( refresh->rev_catalog, refresh->rev_partid,
                           refresh->rev_revision, ARsel, CMmng, NDCCsel, Mdc, IsSuper);

  __DBGpr_str("Mdc ", Mdc);
  if(strcmp(Mdc, "Y"))
  {
    __DBGpr_com("M D C not exist ");
    // SSR 05 Jan TR # 1604
    // Add prompt to check for superseding.
    /*
    UI_prompt("Is Part being Superceded? Y/N");
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_CHAR_MODE,
                       byte = &status );
    }while(strcasecmp(response_data, "Y") &&
           strcasecmp(response_data, "N"));
    __DBGpr_str( " response data ", response_data);
    UI_prompt("");*/
    
    /*
    SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid,
                      refresh->rev_revision, "p_mrpfieldupd", "Y" ); 
    AS part of 1604 */
    status = 0;
    goto wrapup;
  }

  __DBGpr_str(" CMmng ", CMmng);
  if(strcmp(CMmng, "Y"))
  {
    __DBGpr_com("File is not CM managed.");
    /*
    UI_prompt("Is Part being Superceded? Y/N");
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_CHAR_MODE,
                       byte = &status );
    }while(strcasecmp(response_data, "Y") &&
           strcasecmp(response_data, "N"));
    __DBGpr_str( " response data ", response_data);
    UI_prompt("");
    */
    /*SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid,
                      refresh->rev_revision, "p_mrpfieldupd", response_data ); 
    As part of 1604 */
    status = 0;
    goto wrapup;
  }
  /* SSR 12 JAN 1604 check if old file is Superceded if yes ERROR */
  if(!strcasecmp(IsSuper, "Y"))
  {  
    status = 1;
    UI_status (" ERROR: Revising a Superceded file.");
    __DBGpr_com(" ERROR: Revising a Superceded file.");
    goto wrapup;
  }
  if(IsPmeEnabled() == FALSE)
  {
    status = CMAimConnect();
    do
    {
      ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
    } while( response != EX_FORM_FINISHED );

  }
  if(IsPmeEnabled() == FALSE)
  {
    UI_status("Not conencted to AIM.");
    status = 1;
    goto wrapup;
  }
 
  code = 136; /*VDP_CM_REVISE_MDC*/


     memcpy( &inbuf[index], &code, sizeof(int));
     inlen += sizeof(int);
     index = inlen;
/* inbuf cat-part-rev  */
     strcpy( &inbuf[index], refresh->rev_catalog );
     inlen += strlen(refresh->rev_catalog) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_partid );
     inlen += strlen(refresh->rev_partid) +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->rev_revision );
     inlen += strlen(refresh->rev_revision) +1;
     index = inlen;

     /* DCC flag is needed for AIM to revise MDC with Minor design changes
      * when no ARs are selected.Send always "Y" to abe AIM able to revise */
     strcpy( &inbuf[index], "N" );
     inlen += strlen("N") +1;
     index = inlen;

     strcpy( &inbuf[index], refresh->new_revision );
     inlen += strlen(refresh->new_revision) +1;
     index = inlen;

     //added for the CR#1793
     strcpy( &inbuf[index], refresh->new_description );
     inlen += strlen(refresh->new_description) +1;
     index = inlen;

     //TLS added for the TR#4976
     __DBGpr_str("File Applicability", t_LpdDesc);
     strcpy( &inbuf[index], t_LpdDesc );
     inlen += strlen(t_LpdDesc) +1;
     index = inlen;
     
     __DBGpr_int("trying to talk with AIM for VDP_CM_REVISE_MDCwith code", code);
     UI_status("Revising M D C in AIM.");
     dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

     if(dstat != 0)
     {
      	if(dstat == 12345)
	{
        	UI_status("AIM connection reset by server.");
       		UI_status("Could not Revise MDC.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }

       __DBGpr_int("dstat ", dstat);
       if(errmsg) __DBGpr_str("errmsg ", errmsg );
       UI_status("Could not Revise M D C.");
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
       UI_status("Could not Revise M D C.");
       UI_status("New Part not created.");
       status = 1;
       goto wrapup;
     }
     
     /* added code Pullabhotla 26/08/2000 */
  /* To Get MDC Rev from AIM Side */

   index = 0;
   memcpy( &nbItems, &outbuf[index], sizeof(int) ); 
   index = index + sizeof(int);   
	       
   if(outbuf[0]!='\0')
     {
      if(CMMdcRev) strcpy(CMMdcRev, &outbuf[index] );
      index = index + strlen(CMMdcRev) + 1;
      }

     /* Set the flag IsSuperseded */
     SrVDUpdCMattrs ( refresh->rev_catalog, refresh->rev_partid,
                      refresh->rev_revision, "p_mrpfieldupd", "Y" ); 

     
  wrapup:
     if(IsPmeEnabled() == TRUE)
     {
       if(ForceConn() == 1)
       {
         sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &errmsg);
          if ( !sts)
            EnablePME(0);
          UI_status("Disconnected From AIM server");
        }
      }
 __DBGpr_com("END SrCMCopySim ");
    return status;
}
int SrValidateforRet( char *cat, char *part, char *rev )
{
  int status =0;
  char state[20];

  __DBGpr_com("BEGIN SrValidateforRet.");
  status = SrVDGetCMState( cat, part, rev, state );
  if(strcmp(state, DEVELOPMENT))
  {
    __DBGpr_str("state ", state);
    UI_status("File can not be retrieved in this state.");
    status =1;
  }
wrapup:
  __DBGpr_com("END SrValidateforRet.");
  return status;

}


int PDMQueryforMdcExists(char *catalog, char *partid, char *revision)
{


 char searchst[70], p_incpartrptval[10], mdcrevval[10],
 ctxtypeval[10], ctxnumberval[10], p_mrppartval[10];
 char IsModlDCExists[5], errmsg[50], errmsg1[10], errmsg2[10],
 errmsg3[10],errmsg4[15];
 char **bufst;
 int  num, rows, ris_err_code;
 long status=0, sts=1;
 char *output_buffer;
 char wflow[25];


 SetProc(PDMQueryforMdcExists); Begin

 sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'",
		     partid, revision);

 __DBGpr_str("Searchst is", searchst);
 
 status =
 vdb$RisSelect(select="p_incpartrpt,mdcrev,ctxtype,ctxnumber,p_mrppart",
 			table_name = catalog, 
			where = searchst,
			numselect = 5,
			p_numrows = &num,
			p_buffer = &bufst);

 if(status != 1 || num == 0)
 return 1;

 sts = vdb$RisExtractValue( nbrows = num,
                            nbcolumns = 5,
			    buffer = bufst,
			    row = 0,
			    column = 0,
			    value = p_incpartrptval);
	

	strcpy(IsModlDCExists, p_incpartrptval);

   status = CMget_wflow_name(catalog, partid, revision, wflow);
   

   if(!strcmp(wflow, "Y"))
   { 

        if( !strcmp(IsModlDCExists, "N") )
	{
		UI_status("NO MDC EXISTS");

		status = 1;
	}

	else
	{
               
	sts = vdb$RisExtractValue( nbrows = num,
	                           nbcolumns = 5,
				   buffer = bufst,
				   row = 0,
				   column = 1,
				   value = mdcrevval );

	sts = vdb$RisExtractValue( nbrows = num,
				   nbcolumns = 5,
				   buffer = bufst,
				   row = 0,
				   column = 2,
				   value = ctxtypeval );

	
	sts = vdb$RisExtractValue( nbrows = num,
				   nbcolumns = 5,
				   buffer = bufst,
				   row = 0,
				   column = 3,
				   value = ctxnumberval );

	sts = vdb$RisExtractValue( nbrows = num,
	 			   nbcolumns = 5,
				   buffer = bufst,
				   row = 0,
				   column = 4,
				   value = p_mrppartval );
				   
    

	if(!strcmp(p_mrppartval, "Y"))
	{
	  strcpy(p_mrppartval, "CM Rel");
	}

	else
	{
	  strcpy(p_mrppartval, "Not CM Rel");
	}
          

       if(!strcasecmp(mdcrevval, "NULL") || !strcasecmp(ctxtypeval, "NULL") || 
             !strcasecmp(ctxnumberval, "NULL"))
	     UI_status("");
	     
       else
       {
	strcpy(errmsg, "MDC");
	strcpy(errmsg1, mdcrevval);
	strcpy(errmsg2, ctxtypeval);
	strcpy(errmsg3, ctxnumberval);
	strcpy(errmsg4, p_mrppartval);

	strcat(errmsg, " Rev ");
	strcat(errmsg, errmsg1);
	strcat(errmsg, ",");
	strcat(errmsg, errmsg2);
	strcat(errmsg, " ");
	strcat(errmsg, errmsg3);
	strcat(errmsg, ",");
	strcat(errmsg, errmsg4);

	UI_status(errmsg);

	}
	vdb$RisFreeBuffer( buffer = bufst, size = 5 * num );
	
	}
  } 
	End
	return 0;

}

//Added by Anjani, on 25Aug2000

//TLS - 09-11-2000: Changed the size of the variables being used.  They were to small.			    
//                  Mainly searchst was to small but I went ahead and made the other
//					variables larger as well.
int PDMInfoOnCommandbar(char *catalog, char *partid, char *revision)
{

 char      searchst[512], searchst1[512], mdcrevval[10], ctxtypeval[10], 
           ctxnumberval[10], ctxrevval[5];
 char      p_incpartrptval[10], p_mrppartval[10], IsModlDCExists[5];
 char      errmsg[60], errmsg1[60], errmsg2[60], errmsg3[60],
           errmsg4[60], errmsg5[60];
 char      **bufst, **bufst1;
 int       num, num1, rows, ris_err_code;
 long      status=0, sts=1;
 char      *output_buffer;
 char      wflow[60];

 SetProc(PDMInfoOnCommandbar); Begin

 searchst[0]='\0';
 searchst1[0] = '\0';
 mdcrevval[0]='\0';
 ctxtypeval[0]='\0';
 ctxnumberval[0]='\0';
 ctxrevval[0]='\0';

 sprintf(searchst1, "n_itemname = '%s' and n_itemrev = '%s'",
		     partid, revision);

 __DBGpr_str("Searchst1 is", searchst1);

 sprintf(searchst, "pdu_catalog = '%s' and pdu_part = '%s' and pdu_revision = '%s'", catalog, partid, revision); 

 __DBGpr_str("Searchst is", searchst);

 status =
 vdb$RisSelect(select="p_incpartrpt,p_mrppart",
 			table_name = catalog, 
			where = searchst1,
			numselect = 2,
			p_numrows = &num,
			p_buffer = &bufst);

	if(status != 1 || num == 0)
		return 1;

   sts = vdb$RisExtractValue( nbrows = num,
                            nbcolumns = 2,
			    buffer = bufst,
			    row = 0,
			    column = 0,
			    value = p_incpartrptval);

	sts = vdb$RisExtractValue( nbrows = num,
                            nbcolumns = 2,
			    buffer = bufst,
			    row = 0,
			    column = 1,
			    value = p_mrppartval);

	vdb$RisFreeBuffer( buffer = bufst, size = 2 * num );

	strcpy(IsModlDCExists, p_incpartrptval);

	status = CMget_wflow_name(catalog, partid, revision, wflow);

   if(!strcmp(wflow, "Y"))
   { 

        if( !strcmp(IsModlDCExists, "N") || !strcmp(IsModlDCExists,"") )
	{
		UI_status("NO MDC EXISTS");

		status = 1;
	}

	else
	{
	status =
	vdb$RisSelect(select="mdc_rev,ctx_rev,ctx_name,ctx_type",
 			table_name = "SIR_PDM_TABLE", 
			where = searchst,
			numselect = 4,
			p_numrows = &num1,
			p_buffer = &bufst1);
        
	if(status != 1 || num1 == 0)
	return 1;

	sts = vdb$RisExtractValue( nbrows = num1,
	                           nbcolumns = 4,
				   buffer = bufst1,
				   row = 0,
				   column = 0,
				   value = mdcrevval );

	sts = vdb$RisExtractValue( nbrows = num1,
				   nbcolumns = 4,
				   buffer = bufst1,
				   row = 0,
				   column = 1,
				   value = ctxrevval );

	
	sts = vdb$RisExtractValue( nbrows = num1,
				   nbcolumns = 4,
				   buffer = bufst1,
				   row = 0,
				   column = 2,
				   value = ctxnumberval );

	sts = vdb$RisExtractValue( nbrows = num1,
	 			   nbcolumns = 4,
				   buffer = bufst1,
				   row = 0,
				   column = 3,
				   value = ctxtypeval );

	if(!strcmp(p_mrppartval, "Y"))
	{
	  strcpy(p_mrppartval, "CM Rel");
	}

	else
	{
	  strcpy(p_mrppartval, "Not CM Rel");
	}
				   

       if(!strcasecmp(mdcrevval, "NULL") || !strcasecmp(ctxrevval, "NULL") || 
		   !strcasecmp(ctxtypeval, "NULL") || !strcasecmp(ctxnumberval, "NULL"))
	     UI_status("");
	     
       else
       {
	strcpy(errmsg, "MDC");
	strcpy(errmsg1, mdcrevval);
	strcpy(errmsg2, ctxtypeval);
	strcpy(errmsg3, ctxnumberval);
	strcpy(errmsg4, ctxrevval);	
	strcpy(errmsg5, p_mrppartval);

	strcat(errmsg, " Rev ");
	strcat(errmsg, errmsg1);
	strcat(errmsg, ",");
	strcat(errmsg, errmsg2);
	strcat(errmsg, " ");
	strcat(errmsg, errmsg3);
	strcat(errmsg, " ");
	strcat(errmsg, errmsg4);
	strcat(errmsg, ",");
	strcat(errmsg, errmsg5);

	UI_status(errmsg);

	}
	vdb$RisFreeBuffer( buffer = bufst1, size = 4 * num1 );
	
	}
  }

	End
	return 0;

}
/* added code Pullabhotla 26/08/2000 */
/* To Query Context Rev, Name and Type from SIR_PDM_TABLE */
int PDMGetAttrsfromSirTable(char *Catalog, char *Partid, char *Revision,
                            char *CntxtRev, char *CntxtName, char *CntxtType)
{

   char searchst[1024], ctx_revval[5], ctx_nameval[20], ctx_typeval[20];
   char **bufst;
   int num;
   int status=0, sts=1;
  
   ctx_revval[0] = '\0';
   ctx_nameval[0] = '\0';
   ctx_typeval[0] = '\0';
   
    sprintf(searchst,
	    "pdu_catalog = '%s' and  pdu_part = '%s' and pdu_revision = '%s'",
	    Catalog, Partid, Revision);

    __DBGpr_str("Searchst is", searchst); 

     status =
          vdb$RisSelect(select="ctx_rev, ctx_name, ctx_type",
                        table_name = "SIR_PDM_TABLE", 
    		        where = searchst,
			numselect = 3,
			p_numrows = &num,
			p_buffer = &bufst);
     
      if(status != 1 || num == 0)
            return 1;

      sts = vdb$RisExtractValue( nbrows = num,
                                 nbcolumns = 3,
			         buffer = bufst,
			         row = 0,
			         column = 0,
			         value = ctx_revval);

      strcpy(CntxtRev, ctx_revval);
      sts = vdb$RisExtractValue( nbrows = num,
	                         nbcolumns = 3,
	    		         buffer = bufst,
			         row = 0,
			         column = 1,
				 value = ctx_nameval);
      
      strcpy(CntxtName, ctx_nameval);
      sts = vdb$RisExtractValue( nbrows = num,
                                 nbcolumns = 3,
			         buffer = bufst,
			         row = 0,
			         column = 2,
			         value = ctx_typeval);

      strcpy(CntxtType, ctx_typeval);
       vdb$RisFreeBuffer( buffer = bufst, size = 3 * num );    

  return 0;
       
}

/*************************************************
* CMGetDCType - Get the file type for the current
*		file from AIM.
*************************************************/
int CMGetDCType(char *catalog, char *part, char *rev, int *type)
{
  int   status = 0;
  int   i = 0, inlen = 0;
  int	index = 0, index1 = 0, outlen = 0;
  int   dstat = 0, mfail = 0;
  char  inbuf[50], srerrmsg[70];
  char  *outbuf, *errmsg=0;
  int 	code=0;

  __DBGpr_str("catalog ", catalog);
  __DBGpr_str("part ", part);
  __DBGpr_str("rev ", rev);

  for ( i=0; i<50; i++ )
  	inbuf[i]='\0';

  code = VDP_GET_DC_TYPE; //143
  __DBGpr_int("code ", code);

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  
  strcpy( &inbuf[index], catalog );
  inlen += strlen(catalog) + 1;
  index = inlen;

  strcpy( &inbuf[index], part );
  inlen += strlen(part) + 1;
  index = inlen;

  strcpy( &inbuf[index], rev );
  inlen += strlen(rev) + 1;
  index = inlen;

  dstat = POSTMAN_REQUEST_ON_CLIX (	inlen, 
					inbuf,
					&outlen,
					&outbuf,
                			&mfail,
                			&errmsg );

  if(dstat != 0)
    {
       if(dstat == 12345)
       {
         UI_status("AIM connection reset by server.");
  	 printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
	 strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
         ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
	 status = 1;
         goto wrapup;
       }
       else
       {
         UI_status("Failed to process AIM Ref File.");
         status = 1;
         goto wrapup;
       }
    }

    if (mfail != 0 )
    {
       	if(mfail == MDC_DOES_NOT_EXIST)
       	{
       	 	UI_status("REF FILE (or MDC) DOES NOT EXIST IN AIM.");
         	__DBGpr_com("MDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_int("status:", status);
         	return status;
       	}

       	if(mfail == AMDC_DOES_NOT_EXIST)
       	{
       	 	UI_status("AMDC DOES NOT EXIST IN AIM.");
         	__DBGpr_com("AMDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_int("status:", status);
         	return status;
       	}

       	if(mfail == MDCTYPE )
       	{
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_com("This is a MDC Object.");
		*type = mfail;
         	__DBGpr_int("type:", *type);
		status = 0;
         	__DBGpr_int("status:", status);
         	return status;
       	}

       	if(mfail == AMDCTYPE )
       	{
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_com("This is a AMDC Object.");
		*type = mfail;
         	__DBGpr_int("type:", *type);
         	status = 0;
         	__DBGpr_int("status:", status);
         	return status;
       	}
	if( (mfail == USC_VALIDATION_ERROR) || (mfail == VDP_AIM_ERROR ) )
       	{
       	 	UI_status("An Internal AIM Error Occurred. Contact AIM Administrator.");
       	 	__DBGpr_com("An Internal AIM Error Occurred. Contact AIM Administrator.");
         	status = mfail;
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_int("status:", status);
         	return status;
       	}

       	UI_status("An AIM Error Occurred. Contact AIM Administrator.");
       	__DBGpr_com("An AIM Error Occurred. Contact AIM Administrator.");
        status = mfail;
        return status;
    }

wrapup:
  return status;

}


/*************************************************
* CMGetContainedARs - Get a list of contained ARs 
*		      from AIM for a given AMDC.	
*************************************************/
//int CMGetContainedARs(char *catalog, char *part, char *rev, SrARList **ARList, int *ARListCnt)
int CMGetContainedARs(char *catalog, char *part, char *rev, char **outbuf)
{
  int   status = 0;
  int   i = 0, inlen = 0;
  int	index = 0, index1 = 0, outlen = 0;
  int   dstat = 0, mfail = 0;
  char  inbuf[50], srerrmsg[70];
  //char  *outbuf;
  char  *errmsg=0;
  int 	code=0;
  int   numARs = 0;
 
  __DBGpr_str("catalog ", catalog);
  __DBGpr_str("part ", part);
  __DBGpr_str("rev ", rev);

  for ( i=0; i<50; i++ )
  	inbuf[i]='\0';

  code = VDP_GET_CONTAINED_CHK_ARS; //144
  __DBGpr_int("code ", code);

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  
  strcpy( &inbuf[index], catalog );
  inlen += strlen(catalog) + 1;
  index = inlen;

  strcpy( &inbuf[index], part );
  inlen += strlen(part) + 1;
  index = inlen;

  strcpy( &inbuf[index], rev );
  inlen += strlen(rev) + 1;
  index = inlen;

  dstat = POSTMAN_REQUEST_ON_CLIX (	inlen, 
					inbuf,
					&outlen,
					outbuf,
                			&mfail,
                			&errmsg );

  if(dstat != 0)
    {
       if(dstat == 12345)
       {
         UI_status("AIM connection reset by server.");
  	 printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
	 strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
         ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
	 status = 1;
         goto wrapup;
       }
       else
       {
         UI_status("Failed to process AIM Ref File.");
         status = 1;
         goto wrapup;
       }
    }

    if (mfail != 0 )
    {
       	if(mfail == MDC_DOES_NOT_EXIST)
       	{
       	 	UI_status("REF FILE (or MDC) DOES NOT EXIST IN AIM.");
         	__DBGpr_com("MDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_int("status:", status);
         	return status;
       	}

       	if(mfail == AMDC_DOES_NOT_EXIST)
       	{
       	 	UI_status("AMDC DOES NOT EXIST IN AIM.");
         	__DBGpr_com("AMDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_int("status:", status);
         	return status;
       	}

	if( (mfail == USC_VALIDATION_ERROR) || (mfail == VDP_AIM_ERROR ) )
       	{
       	 	UI_status("An Internal AIM Error Occurred. Contact AIM Administrator.");
       	 	__DBGpr_com("An Internal AIM Error Occurred. Contact AIM Administrator.");
         	status = mfail;
         	__DBGpr_int("mfail:", mfail);
         	__DBGpr_int("status:", status);
         	return status;
       	}

       	UI_status("An AIM Error Occurred. Contact AIM Administrator.");
       	__DBGpr_com("An AIM Error Occurred. Contact AIM Administrator.");
        status = mfail;
        return status;
    }

    memcpy( &numARs, outbuf[0], sizeof(int));
    __DBGpr_int( "number of ARs found are ", numARs );

/***********
    //get the list from the buffer
    // parse the buffer for the number of ARs being displayed 
    memcpy( &numARs, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);
    __DBGpr_int( "number of Contained ARs found are", numARs );

    *ARListCnt = numARs - 1;
    __DBGpr_int( "ARListCnt", *ARListCnt );

    //allocate memory for the arlist structure
    *ARList = malloc ( numARs * sizeof( SrARList ) );
    if ( *ARList == NULL )
    {
        printf("Error in dynamic allocation of memory\n");
  	status = 1;
        return status;
    }
    
    //clear the structure
    for( i = 0; i < numARs; i++ )
    {
    	(*ARList)[i].ARNum[0] = '\0';
	(*ARList)[i].AIRNum[0] = '\0';
    	(*ARList)[i].AIRRev[0] = '\0';
    	(*ARList)[i].FMRNum[0] = '\0';
    	(*ARList)[i].FMRRev[0] = '\0';
    	(*ARList)[i].Title[0] = '\0';
    	(*ARList)[i].CreDate[0] = '\0';
    	(*ARList)[i].ARObid[0] = '\0';
    	(*ARList)[i].COGOrg[0] = '\0';
    }

    for(i = 0; i < numARs; i++ )
    {
	__DBGpr_str("AR Number", &outbuf[index1]);
        strcpy((*ARList)[i].ARNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Number", &outbuf[index1]);
        strcpy((*ARList[i]).AIRNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Rev", &outbuf[index1]);
        strcpy((*ARList[i]).AIRRev, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("FMR Number", &outbuf[index1]);
        strcpy((*ARList[i]).FMRNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("FMR Rev", &outbuf[index1]);
        strcpy((*ARList[i]).FMRRev, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("Title", &outbuf[index1]);
        strcpy((*ARList)[i].Title, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("Creation Date", &outbuf[index1]);
        strcpy((*ARList[i]).CreDate, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("OBID", &outbuf[index1]);
        strcpy((*ARList[i]).ARObid, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("COG ORG", &outbuf[index1]);
        strcpy((*ARList[i]).COGOrg, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;
    }
**************************/

wrapup:
  return status;

}


/************************************************************
* Function CMCheckFile
* Check the file to make sure that DCC or an AR is selected 
* before doing any CM processing on the file.
***************************************************/
int CMCheckFile()
{
  int status = 0, sts=0;
  int response=0;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[2], response_data[50], IsSuper[20];
  int  resp;
  long msg;

  __DBGpr_com("BEGIN CMCheckFile");

  status = SrVDGetCMattrs(refresh->rev_catalog, refresh->rev_partid,
                          refresh->rev_revision,
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);

  __DBGpr_str("ARsel", ARsel);
  __DBGpr_str("CMmng",CMmng );
  __DBGpr_str("DCCsel",DCCsel );
  __DBGpr_str("Mdc", Mdc);
  __DBGpr_str("IsSuper", IsSuper);

  if(status)
  {
    __DBGpr_com("Could Not Get CM attrs.");
    UI_status("Could Not Get CM attrs.");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
               response = &resp);
    ChkOK = 0;
    status = 1;
    goto wrapup;
  }

  if(strcmp(CMmng, "Y"))
  {
    UI_status("File Not CM Managed.");
    __DBGpr_com("File Not CM Managed.");
    ChkOK = 1;
    status = 0;
    goto wrapup;
  }

  if(strcmp(Mdc, "Y"))
  {
    UI_status("DAD Not Set.");
    __DBGpr_com("DAD Not Set.");
    ChkOK = 0;
    status = 1;
    goto wrapup;
  }

  if(strcmp(ARsel, "Y") && strcmp(DCCsel, "N") )
  {
    UI_status("No ARs/DCC selected; Can not change state.");
    __DBGpr_com("No ARs/DCC selected; Can not change state.");
    EX_error_box(FI_CURRENT_SCREEN,
		 "No ARs/DCC selected.  Can not change state.",
		 "STATE CHANGE FAILURE");
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &msg,
              response = &resp);
    ChkOK = 0;
    status = 1;
    goto wrapup;
  }


wrapup:
  return status;

}

