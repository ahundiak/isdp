/*
#define vaimDEBUG 1
#define vaimerrDEBUG 1
*/

/************* Includes ******************/
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
#include "PDUuser.h"
#include "vdbmacros.h" 
#include "vadbgmacros.h"
#include "DIdef.h"
#include "PDMmacros.h"
#include "SQLerrordef.h"



/* include for PDM Utilities Form */
#include "part_gadgets.h"
#include "SQLerrordef.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VDtypedef.h"

#include "VDPdef.h"

/****** Define statements *************/
#define CM_CHANGE_AR_FORM 892
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
#define CHGSTATE 20	
#define QUERYAR  22
#define GETARBTN 22
//TLS 04-22-02 CR 6194 - Add the ARs to a structure to be used
//                       for sorting.
#define ARSORT	 24

#define CA_TBL	11
#define CA_C_ARNUM	0
#define CA_C_AIRNUM	1
#define CA_C_AIRREV	2
#define CA_C_FMRNUM	3
#define CA_C_FMRREV	4
#define CA_C_TIT	5
#define CA_C_CHST	6
#define CA_C_DATE	7
//TLS Fix for TR5708
#define CA_C_COGORG	8
#define CA_C_OBID	9

/* nfm attributes for CM management */
#define CMENAB  "p_mrppart"
#define ARSEL   "p_mrpstruct"
#define DCCNOTSEL  "p_explode"
#define DCCHIST "dcc_history"
#define HISTCOLMN "dcc_time, pdu_catalog, pdu_part, pdu_revision, nfm_usr, wrk_usr, wrk_node, ssr_time"

/* Default data attributes */
#define SIR_MODCX_ID            "Model Context Id"
#define SIR_CNTX_ID             "Context Id"
#define CLIX_DISCONNECT -2


/***************** Externs ***************/
extern 	struct 	PDUacl_node *PDU_acl_list;
extern 	struct 	PDUacl_node *PDU_acl_group_list;
extern struct PDUrefresh        *refresh;
extern struct PDUuser	*user;


/***************** Globals ******************/
static Form cm_ar_form_id;  
static short CM_ar_form_created = FALSE;
static short CM_ar_form_displayed = FALSE;
static short CM_ar_perm_window = FALSE;
static char Gcat[30];
static char Gpart[30];
static char Grev[30];
static int RetOK = 0;

extern int POSTMAN_REQUEST_ON_CLIX();
extern int CMGetArs();
extern int SrVDUpdCMattrs();
extern int VDPGetCtxId();
extern int SrVDGetCMattrs();
extern int IsPmeEnabled();
extern int ForceConn();
extern int EnablePME();
extern int AIMlogin();
static int ForceConnect = 0;

//TLS 04-22-02 - Global veriables for AMDC Phase II
//SrARList *gARList = NULL;
//int	  gARListCnt = 0;

/**************************************************************************/

int IsRetOK()
{
  return RetOK;
}
int ForceConn1()
{
  return ForceConnect;
}

/************************************************************
* CMSort1 Routine
* This will sort the Changes Authorization Form by AR Number
************************************************************/
int CMSort1(const void *v1, const void *v2)
{
  SrARList *p_ARList1 = (SrARList*)v1;
  SrARList *p_ARList2 = (SrARList*)v2;

  //int arnum1, arnum2;

  //arnum1 = atoi(p_ARList1->ARNum);
  //arnum2 = atoi(p_ARList2->ARNum);
  //__DBGpr_int("arnum1", arnum1);
  //__DBGpr_int("arnum2", arnum2);

  //__DBGpr_int("arnum1 - arnum2", (arnum1 - arnum2));

  //return (arnum1 - arnum2);
  return strcmp(p_ARList1->ARNum, p_ARList2->ARNum);
}

/************************************************************
* CMSort2 Routine
* This will sort the Changes Authorization Form by AIR Number
************************************************************/
int CMSort2(const void *v1, const void *v2)
{
  SrARList *p_ARList1 = (SrARList*)v1;
  SrARList *p_ARList2 = (SrARList*)v2;

  //int airnum1, airnum2;

  //airnum1 = atoi(p_ARList1->AIRNum);
  //airnum2 = atoi(p_ARList2->AIRNum);
  //__DBGpr_int("airnum1", airnum1);
  //__DBGpr_int("airnum2", airnum2);

  //__DBGpr_int("airnum1 - airnum2", (airnum1 - airnum2));

  //return (airnum1 - airnum2);
  return strcmp(p_ARList1->AIRNum, p_ARList2->AIRNum);
}

/************************************************************
*
* cm_ar_notification_routine
* Change Authorisation Form
*
************************************************************/
int cm_ar_notification_routine ( f_label, g_label, value, fp )
 int f_label; /* The label of the form */
 int g_label; /* The label of the gadget */
 double value; /* The value of the gadget */
 Form fp; /* Pointer to the form */
{
  int   status = 0;
  int   select, pos, length;
  int   row = 0;
  int   mcf_select = FALSE;
  int   num_rows = 0, numARs;
  int dcc_found = 0, ar_found = 0;
  static char *arobid = NULL;
  char *msg = NULL;
  int inlen=0;
  int outlen=0;
  int code=0;
  int dstat=0;
  int mfail=0;
  int index=0, index1=0, i=0;
  char inbuf[512], CollName[DI_PATH_MAX], DirName[DI_PATH_MAX], srerrmsg[70];
  char  mdcobid[25], ctxobid[25], buffer[5];
  char *errmsg=NULL, *outbuf =NULL;
  OMuword                       curOs;
  struct GRid CollId;
  long qmsg;
  int resp;
  SrARList *ARList=NULL;
  int ARListCnt;
  int chkTgOpt;

  __DBGpr_com("VDGetARs.c.cm_ar_notification_routine BEGIN ");
  switch ( g_label )
  {
    case FI_CANCEL: /* Member of group FI_CTRL_GROUP */

    /* Erase the displayed form */

      PDUmessage(PDM_E_CMD_CANCELLED, 's');

      _pdm_debug("User selected the cancel button", 0);

      if (CM_ar_form_displayed == TRUE)
      	FIf_erase( fp );
      if (CM_ar_form_created == TRUE)
        FIf_delete( fp );

      CM_ar_form_displayed = FALSE;
      CM_ar_form_created = FALSE;
      resp = EX_FORM_FINISHED;
      if(IsPmeEnabled() == TRUE)
      {
        if(ForceConn1() == 1)
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
      }

      RetOK = 0;
      ex$putque( msg = &qmsg,
                 response = &resp,
                 buffer = buffer);
      break;

    case FI_EXECUTE: /* Member of group FI_CTRL_GROUP */
      _pdm_debug("User selected the execute button", 0);

      _pdm_debug("The file is in the Development state.", 0);

      _pdm_debug("getting the AR Obid", 0);
      FIfld_get_num_rows(fp, CA_TBL, &num_rows);
      __DBGpr_int("num_rows ", num_rows);

      for (row = 0; row < num_rows; ++row)
      {
        FIfld_get_select(fp, CA_TBL, row, 0, &mcf_select);
        if (mcf_select)
        {
          __DBGpr_int("selected row ", row);
          FIfld_get_text_length(fp, CA_TBL, row, CA_C_OBID, &length);
          arobid = (char *) malloc (sizeof (char) * length+1);
          memset(arobid, NULL, sizeof (char) * length + 1);

          FIfld_get_text(fp, CA_TBL, row, CA_C_OBID, length,
                      (unsigned char *)arobid, &select, &pos);

          if (strcmp(arobid, "") == 0)
          {
            if(row == 0)
              dcc_found = 1;
            continue;
          }
          __DBGpr_str("arobid ", arobid);

          /* inbuf code-arobid-cat-part-rev */
          code = 132; /*VDP_MAKE_AR_WORKING;  */

	  index = 0;
	  inlen = 0;
	  *inbuf = NULL;

          memcpy( &inbuf[index], &code, sizeof(int));
          inlen += sizeof(int);
          index = inlen;

          strcpy( &inbuf[index], arobid);
          inlen += strlen(arobid) +1;
          index = inlen;

          strcpy( &inbuf[index], Gcat);
          inlen += strlen(Gcat) +1;
          index = inlen;

          strcpy( &inbuf[index], Gpart);
          inlen += strlen(Gpart) +1;
          index = inlen;

          strcpy( &inbuf[index], Grev);
          inlen += strlen(Grev) +1;
          index = inlen;

          __DBGpr_com("trying to talk with AIM with VDP_MAKE_AR_WORKING");
          UI_status("Changing AR MDC relations in AIM");
          FIg_set_text( fp, FI_MSG_FIELD, "Changing AR MDC relations in AIM.");
          dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

          //printf("\n dstat %d, mfail %d", dstat, mfail );
          if(dstat != 0)
          {
 		if(dstat == 12345 )
        	{
         		UI_status("AIM connection reset by server.");
			printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        		strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        		ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        	}
            if(errmsg) __DBGpr_str("errmsg ", errmsg );
            status = 1;
            UI_status("Couldnot Change AR state.");
            FIg_set_text( fp, FI_MSG_FIELD, "Couldnot Change AR state.");
            RetOK = 0;
            break;
          }

          if (mfail != 0 )
          {
            if(errmsg)
            {
              __DBGpr_str("ERROR 2", errmsg );
            }
            status = mfail;
            UI_status("Couldnot Change AR state.");
            FIg_set_text( fp, FI_MSG_FIELD, "Couldnot Change AR state.");
            RetOK = 0;
            break;
          } /* if mfial */

        ar_found = 1;
        } /* if mcf_selected */
      } /* end for number of rows selected */

      if(dcc_found == 0 && ar_found == 0)
      {
        FIg_set_text( fp, FI_MSG_FIELD, "No ARs selected.");
        UI_status( "No ARs selected.");
	RetOK = 0;
        break;
      }

      if(dcc_found == 1)
      {
        status = CMWriteHistory();
        status = SrVDUpdCMattrs(Gcat, Gpart, Grev, DCCNOTSEL, "N" );
        if(status) return status;
      }
      if(ar_found == 1)
        status = SrVDUpdCMattrs(Gcat, Gpart, Grev, ARSEL, "Y" );
      if(status) return status;


      CM_ar_form_displayed = FALSE;
      CM_ar_form_created = FALSE;

      FIf_erase( fp );
      FIf_delete( fp );
      RetOK = 1;
      if(IsPmeEnabled() == TRUE)
      {
        if(ForceConn1() == 1)
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
      }
      resp = EX_FORM_FINISHED;
      ex$putque( msg = &qmsg,
                 response = &resp);
      break;

  case ARSORT:// sort the form
   	
  	//TLS 04-22-02 CR 6194 - Add the ARs to a structure to be used
  	//                       for sorting.

  	//make sure structure is null
  	if ( ARList != NULL )
    		free(ARList);

	//generate the AR list
	status = CMGenerateARList(fp, &ARList, &ARListCnt);

	FIg_get_state(fp, ARSORT, &chkTgOpt );
     	if( chkTgOpt ) //if the toggle is ON
	{
		//sort by AIR Number
          	__DBGpr_com("Sorting by AIR Number");
		qsort(ARList, (unsigned) ARListCnt, sizeof(SrARList), CMSort2);
	}
	else
	{
		//sort by AR Number
          	__DBGpr_com("Sorting by AR Number");
		qsort(ARList, (unsigned) ARListCnt, sizeof(SrARList), CMSort1);

    	}

	//clear the form
	numARs = ARListCnt;

	FIfld_delete_rows(fp, CA_TBL, 1, numARs);

	//put the new list on the form
        FIfld_set_num_rows( fp, CA_TBL, numARs );

	
	for ( i=0; i<numARs; i++)
    	{
     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_ARNUM, ARList[i].ARNum, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_AIRNUM,ARList[i].AIRNum, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_AIRREV,ARList[i].AIRRev, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_FMRNUM,ARList[i].FMRNum, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_FMRREV,ARList[i].FMRRev, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_TIT,ARList[i].Title, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_CHST, "Auth.", FALSE );
     
     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_DATE, ARList[i].CreDate, FALSE ); 

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_OBID, ARList[i].ARObid, FALSE );

     		FIfld_set_text( fp, CA_TBL, i+1, CA_C_COGORG, ARList[i].COGOrg, FALSE ); 

    	} 
    	
	FIg_set_text( fp, FI_MSG_FIELD, "Select AR.");

	break;

  case QUERYAR: /* Sequenced to  */

     /* Get the authorised ARs for the concerned MDC */
     /* inbuf cat-part-rev */
     code = 131; /*VDP_GET_AUTHORIZING_ARS;  */

    index =0;
    inlen =0;
    index1=0;
    numARs =0;
    memcpy( &inbuf[index], &code, sizeof(int));
    inlen += sizeof(int);
    index = inlen;

     /* SSR not sure if refresh atructure works, need to check */
    strcpy( &inbuf[index], Gcat);
    inlen += strlen(Gcat) +1;
    index = inlen;

    strcpy( &inbuf[index], Gpart);
    inlen += strlen(Gpart) +1;
    index = inlen;

    strcpy( &inbuf[index], Grev);
    inlen += strlen(Grev) +1;
    index = inlen;
    

    /*VDPGetCtxId( SIR_MODCX_ID, mdcobid);
    *printf("\n MDC %s", mdcobid);

    *VDPGetCtxId( SIR_CNTX_ID, ctxobid);
    *printf("\n CTX id %s", ctxobid);

    *strcpy( &inbuf[index], mdcobid);
    *inlen += strlen(mdcobid) +1;
    *index = inlen;

    *strcpy( &inbuf[index], ctxobid);
    *inlen += strlen(ctxobid) +1;
    *index = inlen;
   */ 
    __DBGpr_com("trying to talk with AIM to get auth ARs");
    UI_status("Getting Authorising ARs");
    FIg_set_text( fp, FI_MSG_FIELD, "Getting Authorising ARs.");
    dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   &outbuf, &mfail, &errmsg);

    if(dstat != 0)
    {
	if(dstat == 12345 )
        {
         	UI_status("AIM connection reset by server.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        }
       if(errmsg) __DBGpr_str("errmsg ", errmsg );
       UI_status("Failed to get Authorised ARs.");
       status = 1;
       return status;
    }

    if (mfail != 0 )
    {
       if(errmsg)
       {
        __DBGpr_str("ERROR 2", errmsg );
       }
       UI_status("Failed to get Authorised ARs.");
       status = mfail;
       return status;
    }
                /* outbuf nos-allcolumndetails */
    memcpy( &numARs, &outbuf[index1], sizeof(int));
    index1 = index1 + sizeof(int);
    __DBGpr_int("1. no of authorizing ars",  numARs);
 
    if( numARs == 0 )
    {
      UI_status("No Authorised ARs found.");
      break;
    }
                /* get the no of rows, increse the rows */
    FIfld_get_num_rows( fp, CA_TBL, &num_rows );
    FIfld_set_num_rows( fp, CA_TBL, num_rows+numARs );
    FIg_set_text( fp, FI_MSG_FIELD, "");
    UI_status("");

                /* add new data to form */
    for ( i=0; i<numARs; i++)
    {
     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_ARNUM,
                      &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_AIRNUM,
                     &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_AIRREV,
                     &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_FMRNUM,
                     &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_FMRREV,
                     &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_TIT,
                    &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_CHST,
                    "Auth.", FALSE );
     

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_DATE,
                    &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_OBID,
                     &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

     //TLS Fix for TR# 5708
     FIfld_set_text( fp, CA_TBL, num_rows+i, CA_C_COGORG,
                    &outbuf[index1], FALSE );
     index1 = index1 + strlen( &outbuf[index1] ) +1;

    } 
    //TLS 04-22-02 - CR 6194
    FIg_get_state(fp, ARSORT, &chkTgOpt );
    if( chkTgOpt ) //if the toggle is ON
  	FIg_set_state_on(fp, ARSORT);
    else
  	FIg_set_state_off(fp, ARSORT);

    FIg_set_text( fp, FI_MSG_FIELD, "Select AR.");
    break;

  } /* END switch ( g_label ) */

  //make sure structure is null
  if ( ARList != NULL )
  	free(ARList);

  __DBGpr_com("VDGetARs.c.cm_ar_notification_routine END ");
  return status;
} /* END notification_routine() */


//TLS 04-22-02 CR 6194 - Add the ARs to a structure to be used
//                       for sorting.
/*********************************************************
* CMGenerateARList
***********************************************************/
int CMGenerateARList(Form fp, SrARList **ARList, int *ARListCnt)
{
  int num_rows=0, i=0, length=0;
  int status=0;
  int select, pos;

  //get the number of rows from the form
  FIfld_get_num_rows(fp, CA_TBL, &num_rows);
  __DBGpr_int( "num_rows", num_rows );

  *ARListCnt = num_rows - 1;
  __DBGpr_int( "ARListCnt", *ARListCnt );

  //allocate memory for the arlist structure
  *ARList = malloc ( num_rows * sizeof( SrARList ) );
  if ( *ARList == NULL )
  {
        printf("Error in dynamic allocation of memory\n");
        return OM_E_NODYNMEM;
  }

  //clear the structure
  for( i = 0; i < num_rows; i++ )
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

  //get the ars from the form
  for (i = 1; i < num_rows; i++)
  {
	FIfld_get_text_length(fp, CA_TBL, i, CA_C_ARNUM, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_ARNUM, length,
                      (unsigned char *)(*ARList)[i-1].ARNum, &select, &pos);
        __DBGpr_str("ARList[i].ARNum ", (*ARList)[i-1].ARNum);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_AIRNUM, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_AIRNUM, length,
                      (unsigned char *)(*ARList)[i-1].AIRNum, &select, &pos);
        __DBGpr_str("ARList[i].AIRNum ", (*ARList)[i-1].AIRNum);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_AIRREV, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_AIRREV, length,
                      (unsigned char *)(*ARList)[i-1].AIRRev, &select, &pos);
        __DBGpr_str("ARList[i].AIRRev ", (*ARList)[i-1].AIRRev);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_FMRNUM, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_FMRNUM, length,
                      (unsigned char *)(*ARList)[i-1].FMRNum, &select, &pos);
        __DBGpr_str("ARList[i].FMRNum ", (*ARList)[i-1].FMRNum);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_FMRREV, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_FMRREV, length,
                      (unsigned char *)(*ARList)[i-1].FMRRev, &select, &pos);
        __DBGpr_str("ARList[i].FMRRev ", (*ARList)[i-1].FMRRev);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_TIT, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_TIT, length,
                      (unsigned char *)(*ARList)[i-1].Title, &select, &pos);
        __DBGpr_str("ARList[i].Title ", (*ARList)[i-1].Title);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_DATE, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_DATE, length,
                      (unsigned char *)(*ARList)[i-1].CreDate, &select, &pos);
        __DBGpr_str("ARList[i].CreDate ", (*ARList)[i-1].CreDate);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_OBID, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_OBID, length,
                      (unsigned char *)(*ARList)[i-1].ARObid, &select, &pos);
        __DBGpr_str("ARList[i].ARObid ", (*ARList)[i-1].ARObid);

	FIfld_get_text_length(fp, CA_TBL, i, CA_C_COGORG, &length);
        FIfld_get_text(fp, CA_TBL, i, CA_C_COGORG, length,
                      (unsigned char *)(*ARList)[i-1].COGOrg, &select, &pos);
        __DBGpr_str("ARList[i].COGOrg ", (*ARList)[i-1].COGOrg);
  }
 

wrapup:
  return status;
}

/*********************************************************
* Function: CMar_form
*
*
*
***********************************************************/
int CMar_form( char *catalog, char *partno, char *rev )
{
  int i=0;
  int status = 0, resp;
  long qmsg;
  int numARs = 0;
  int index1 = 0;
  char *outbuf = NULL;
  int aimcode=0, response;
  char ARsel[2], CMmng[2], DCCsel[2], Mdc[5], response_data[50], IsSuper[20];
  SrARList *ARList=NULL;
  long msg;
  char *errmsg=0;
  int DCType=0;

  CM_ar_form_created = FALSE;
  CM_ar_form_displayed = FALSE;
  CM_ar_perm_window = FALSE;

  __DBGpr_str ("catalog ", catalog);

  __DBGpr_com("CMar_form START");
  /*if (PDU_acl_group_list)
    {*/
    _pdm_debug("loading ARs into CM form", 0);
     /*sts = CMload_ar_form( catalog, partno, rev );*/
  /* Check if the File is CM enabled if not neabled don't do anything */

  status = SrVDGetCMattrs(catalog, partno, rev, 
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  if(status) return status;

  if(strcmp(CMmng, "Y"))
  {
    UI_status("File is not CM managed; can not query ARs.");
    __DBGpr_com("File is not under CM control");
    return 0;
  }

  /* Check for AIM conenction */
  if(IsPmeEnabled()==FALSE)
  {
      AIMlogin();
      ForceConnect = 1;
#if 0
   status = CMAimConnect();
   do
   {
     ex$wait_for_input( response = &response,
                        buffer = response_data,
                        mode = EX_ALL_ASCII_MODE,
                        byte = &status );
   } while ( response != EX_FORM_FINISHED );
#endif                  
  }

  if(IsPmeEnabled() == FALSE)
  {
    UI_status("Not connected to AIM server.");
    __DBGpr_com( " Not connected to AIM server.");
    RetOK = 0;
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &qmsg,
               response = &resp);
    return 0;
  }

  //TLS 05-06-02 - Modified for AMDC Phase Ii
  //first determine design context type
  status = CMGetDCType(catalog, partno, rev, &DCType); 

  if( status )
  {
	resp = EX_FORM_FINISHED;
        ex$putque( msg = &msg, response = &resp);
    	RetOK = 0;
	return 1; 
  }

  __DBGpr_int("Design Context Type", DCType );

  if (DCType == AMDCTYPE)
  {
	UI_status("AMDC...Skipping Authorization");
  	__DBGpr_com("This is an AMDC file, no need to Authorize.");
	
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
	resp = EX_FORM_FINISHED;
        ex$putque( msg = &msg, response = &resp);
    	RetOK = 1;
        //status = SrVDUpdCMattrs(catalog, partno, rev, DCCNOTSEL, "N" );
        status = SrVDUpdCMattrs(catalog, partno, rev, ARSEL, "Y" );
	return 1; 
  }

  aimcode = VDP_GET_WORKING_ARS;

  /* call the function to query AIM */
  strcpy(Gcat, catalog);
  strcpy(Gpart, partno);
  strcpy(Grev, rev);
  __DBGpr_com("getting CMGetArs ");
  //TLS 04-29-02 - Changed for AMDC Phase II
  //status = CMGetArs(catalog, partno, rev, aimcode, &outbuf);
  status = CMGetArs(catalog, partno, rev, AR_WORKING, &outbuf);
  if(status)
  {
    resp = EX_FORM_FINISHED;
    ex$putque( msg = &qmsg,
               response = &resp);
    return status;
  }

  /* parse the buffer for the number of ARs being displayed */

  index1 =0;
  memcpy( &numARs, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);
  __DBGpr_int( "number of Working ARs found is", numARs );

  //TLS
  __DBGpr_com( "before initializing the cm_ar_form_id to NULL" );
  cm_ar_form_id = NULL;

  __DBGpr_com( "before creating the CMChgAR.frm" );
  status = FIf_new(CM_CHANGE_AR_FORM, "CMChgAR.frm", cm_ar_notification_routine, &cm_ar_form_id);

  __DBGpr_com( "before checking to see if cm_ar_form_id is NULL" );
  if(cm_ar_form_id == NULL)
  {
    __DBGpr_com( "cm_ar_form_id is NULL...could not created form...exiting." );
    printf("\nCould not create form<CMChgAR.frm>.");
    status = 1;
    return status;
  }

  __DBGpr_com( "setting CM_ar_form_created to TRUE" );
  CM_ar_form_created = TRUE;

  __DBGpr_com( "before check to see if numARs > 0" );
  if(numARs>0)
  {
    __DBGpr_com( "numARs is > 0" );
    /* Set the no of rows in form  an extra row for the default DCC*/
    FIfld_set_num_rows( cm_ar_form_id, CA_TBL, numARs+1 );

    __DBGpr_com( "before for loop to loop through ARs" );
    /* parse the buffer for the list of ARs and add to form */

   //TLS 04-22-02 - CR 6194 - Sort the list

   //allocate memory for the arlist structure
   ARList = malloc ( numARs * sizeof( SrARList ) );
   if ( ARList == NULL )
   {
        printf("Error in dynamic allocation of memory\n");
        return OM_E_NODYNMEM;
   }
   for( i = 0; i < numARs; i++ )
   {
    	ARList[i].ARNum[0] = '\0';
    	ARList[i].AIRNum[0] = '\0';
    	ARList[i].AIRRev[0] = '\0';
    	ARList[i].FMRNum[0] = '\0';
    	ARList[i].FMRRev[0] = '\0';
    	ARList[i].Title[0] = '\0';
    	ARList[i].CreDate[0] = '\0';
    	ARList[i].ARObid[0] = '\0';
    	ARList[i].COGOrg[0] = '\0';
   }
   
   for(i = 0; i < numARs; i++ )
   {
	__DBGpr_str("AR Number", &outbuf[index1]);
        strcpy(ARList[i].ARNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Number", &outbuf[index1]);
        strcpy(ARList[i].AIRNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Rev", &outbuf[index1]);
        strcpy(ARList[i].AIRRev, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("FMR Number", &outbuf[index1]);
        strcpy(ARList[i].FMRNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("FMR Rev", &outbuf[index1]);
        strcpy(ARList[i].FMRRev, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("Title", &outbuf[index1]);
        strcpy(ARList[i].Title, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("Creation Date", &outbuf[index1]);
        strcpy(ARList[i].CreDate, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("OBID", &outbuf[index1]);
        strcpy(ARList[i].ARObid, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("COG ORG", &outbuf[index1]);
        strcpy(ARList[i].COGOrg, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;
   }
   __DBGpr_com("Sorting by AR Number");
   qsort(ARList, (unsigned) numARs, sizeof(SrARList), CMSort1);

   //now store the sorted list on the form
   for ( i = 0; i < numARs; i++ )
   {
    	__DBGpr_str("AR Number", ARList[i].ARNum);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_ARNUM, ARList[i].ARNum, FALSE);

    	__DBGpr_str("AIR Number", ARList[i].AIRNum);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_AIRNUM, ARList[i].AIRNum, FALSE);

    	__DBGpr_str("AIR Revision",ARList[i].AIRRev );
   	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_AIRREV, ARList[i].AIRRev, FALSE);

    	__DBGpr_str("FMR Number", ARList[i].FMRNum);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_FMRNUM, ARList[i].FMRNum, FALSE);

   	__DBGpr_str("FMR Revision",ARList[i].FMRRev);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_FMRREV, ARList[i].FMRRev, FALSE);

    	__DBGpr_str("Title", ARList[i].Title);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_TIT, ARList[i].Title, FALSE);

    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_CHST, "work.", FALSE);

    	__DBGpr_str("Creation Date", ARList[i].CreDate);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_DATE, ARList[i].CreDate, FALSE);

    	__DBGpr_str("OBID", ARList[i].ARObid);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_OBID, ARList[i].ARObid, FALSE);

    	__DBGpr_str("COG ORG", ARList[i].COGOrg);
    	FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_COGORG, ARList[i].COGOrg, FALSE);
   }
   
/*
   for ( i = 0; i < numARs; i++ )
   {
    __DBGpr_str("AR Number", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_ARNUM, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("AIR Number", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_AIRNUM, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("AIR Revision", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_AIRREV, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("FMR Number", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_FMRNUM, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("FMR Revision", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_FMRREV, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("Title", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_TIT, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_CHST, "work.", FALSE);

    __DBGpr_str("Creation Date", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL,
                  i+1, CA_C_DATE, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("OBID", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL, 
                  i+1, CA_C_OBID, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    __DBGpr_str("COG ORG", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CA_TBL, 
                  i+1, CA_C_COGORG, &outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;
   }
*/

 }

/*    _pdm_status("CMload_ar_form", sts);
    if (sts != PDM_S_SUCCESS)
      {
      FIf_delete(cm_ar_form_id);
      CM_ar_form_created = FALSE;
      CM_ar_form_displayed = FALSE;
      CM_ar_perm_window = FALSE;
      return(sts);
      }
*/
  /*_pdm_debug("Displaying the CM AR form", 0);*/
  status = FIf_display(cm_ar_form_id);
  __DBGpr_com("displaying the form");
  CM_ar_form_displayed = TRUE;


  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  

  __DBGpr_com("CMar_form END");
  return(0);
/*}*/
}


/************************************************************************/

/**********************************************************
*
* AIM Function calls
*
**********************************************************/


/*********************************************************
* Function: CMload_ar_form
*
* This function loads the form with a list of ARs from AIM.
*
***********************************************************/
int CMload_ar_form( char *catalog, char *partno, char *rev )
{

  int i=0;
  int status = 0;
  int numARs = 0;
  int index1 = 0;
  char *outbuf = NULL;
  int aimcode=0;


  /* TLS
     1. Query AIM for the list of ARs Working to show on this form.
     	Use the catalog, partno and revision to get the MDC object,
	then use the MDC object to find the related ARs.

     2. When the AIM Outbuffer returns, parse the buffer to get
	the list of ARs and display the list on the form.
   */


  aimcode = VDP_GET_WORKING_ARS;

  /* call the function to query AIM */
  //TLS 04-29-02 - Changed for AMDC Phase II
  //status = CMGetArs(catalog, partno, rev, aimcode, &outbuf);
  status = CMGetArs(catalog, partno, rev, AR_WORKING, &outbuf);

  /* check the status */

  /* parse the buffer for the number of ARs being displayed */
  memcpy( &numARs, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);
  __DBGpr_int( "number of Wroking ARs found is", numARs );

  /* parse the buffer for the list of ARs and add to form */
  for ( i = 0; i < numARs; i++ )
  {

    /* store the results on the form */
    _pdm_debug("writing to Change Promotion", 0);

    _pdm_debug("AR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, ARNUM, i, 0,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("AIR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, AIRNUM, i, 1,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("AIR Revision = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, AIRREV, i, 2,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("FMR Number = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, FMRNUM, i, 3,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("FMR Revision = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, FMRREV, i, 4,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("Title = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, TITLE, i, 5,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("Creation Date = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, CREDATE, i, 6,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;

    _pdm_debug("OBID = <%s>", &outbuf[index1]);
    FIfld_set_text(cm_ar_form_id, AROBID, i, 7,&outbuf[index1], FALSE);
    index1 = index1 + strlen( &outbuf[index1] ) +1;
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
         __DBGpr_int("AR Number ", (*ARItm)[i].ARNo );

        strcpy((*ARItm)[i].AIRNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].AIRNo) +1;
        __DBGpr_str ("AIR Number", (*ARItm)[i].AIRNo );

        strcpy((*ARItm)[i].AIRRev, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].AIRRev) +1;
        __DBGpr_str ("AIR Revision", (*ARItm)[i].AIRRev );

        strcpy((*ARItm)[i].FMRNo, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].FMRNo) +1;
        __DBGpr_str ("FMR Number", (*ARItm)[i].FMRNo );

        strcpy((*ARItm)[i].FMRRev, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].FMRRev) +1;
        __DBGpr_str ("FMR Revision", (*ARItm)[i].FMRRev );

        strcpy((*ARItm)[i].Title, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].Title) +1;
        __DBGpr_str ("Title", (*ARItm)[i].Title );

        strcpy((*ARItm)[i].ChgState, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].ChgState) +1;
        __DBGpr_str ("Change State", (*ARItm)[i].ChgState );


        strcpy((*ARItm)[i].CreDate, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].CreDate) +1;
        __DBGpr_str ("Creation Date", (*ARItm)[i].CreDate );


        strcpy((*ARItm)[i].Obid, &outbuf[index1]);
        index1 = index1 + strlen((*ARItm)[i].Obid) +1;
        __DBGpr_str ("OBID", (*ARItm)[i].Obid );

  }
*/





return 1;
}

int CMWriteHistory()
{
  time_t ltime;
  int i, status, ris_err_code;
  char value[160];


 //SetProc(VDGetARs.C CMWriteHistory); Begin
  value[0]= '\0';
 __DBGpr_com("VDGetARs.C CMWriteHistory Begin");
  sprintf(value, "INSERT INTO dcc_history values(current_timestamp,'%s','%s','%s','%s','%s', '%s')",Gcat, Gpart, Grev, user->username, user->wrkst_username, user->wrkst_node);
  __DBGpr_str("Stmt", value);
  pdm$ris_stmt(status = &status,
  		statement = value,
		ris_err_code = &ris_err_code);

   if(status != SQL_S_SUCCESS)
   {
      __DBGpr_com("Couldnot insert into history");
      goto wrapup;
   }
  //time ( &ltime );
/* Code to write into a NFM table
  */
  /*strcpy(value,"'");
  strcat(value, ctime(& ltime));
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, Gcat);
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, Gpart);
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, Grev);
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, user->username);
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, user->wrkst_username);
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, user->wrkst_node);
  strcat(value,"'");
  strcat(value,",");
  strcat(value,"'");
  strcat(value, "current_timestamp");
  strcat(value,"'");
  __DBGpr_str("value", value);
  status = vdb$RisInsert(table_name = DCCHIST,
                         columns = HISTCOLMN,
                         values = value);
  if(status == 0)
  {
    printf("\n Could not Insert in to table.");
  }*/
  

wrapup:
  __DBGpr_com("\nVDGetARs.C CMwriteHistory End");
  return 0;
}
