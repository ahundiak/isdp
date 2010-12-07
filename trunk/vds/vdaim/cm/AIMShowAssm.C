/* $Id: AIMShowAssm.C,v 1.1 2002/05/10 21:50:36 tlstalli Exp $ */
/***************************************************************************
**
** Program:     AIMShowAssem.C
**
** Version:     02.06.02.08
**
** Date:        05/10/02
**
** Description: This command will interact with AIM to  
**              retrieve a list of contained ARs.
**
** Author:      T. Stalling
**               
************************************************************************/

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

#include "VDPdef.h"
#include "VDpdmDef.h"
#include "DItypedef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"


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

/****** Define statements *************/
/* Defines for the Show AIM Assembly Form */
#define SHOW_AIM_ASSEM_AR_FORM 	1301

/* ASSEMBLY FORM GADGETS */
#define SHOW_ASM_AR_MSG_FLD 		10	

/* ASSEMBLY FORM TABLE GADGETS */
#define SHOW_ASM_AR_TBL			11
#define SHOW_ASM_AR_TBL_C_ARNUM		0
#define SHOW_ASM_AR_TBL_C_AIRNUM	1
#define SHOW_ASM_AR_TBL_C_ARSTATUS	2

/* Defines for Generic Attributes */
#define CLIX_DISCONNECT 	-2

/***************** Globals ******************/
/* Globals for the Assembly Form */
static 	Form show_assem_ar_form_id;  
static 	short show_assem_ar_form_created = FALSE;
static 	short show_assem_ar_form_displayed = FALSE;
static 	short show_assem_ar_perm_window = FALSE;

static int RetOK = 0;
static int force_aim_login = 0;

/**************** Externs *******************/
extern struct 	PDUrefresh        *refresh;

extern int POSTMAN_REQUEST_ON_CLIX();
extern int AIMlogin();

/************************************************************
* CMConARSort1 Routine
* This will sort the Changes Authorization Form by AR Number
************************************************************/
int CMConARSort1(const void *v1, const void *v2)
{
  SrConARList *p_ARList1 = (SrConARList*)v1;
  SrConARList *p_ARList2 = (SrConARList*)v2;

  return strcmp(p_ARList1->ARNum, p_ARList2->ARNum);
}


/**************************************************************************/
/*********************************************************
* Function: AIMshow_contained_ars_form
**********************************************************/
int AIMshow_contained_ars_form()
{
  int 	status = 0, resp;
  int 	i=0;
  long 	qmsg;
  int 	numARs = 0;
  int 	index1 = 0;
  char 	*outbuf = NULL;
  int 	code=0, response;
  OMuword curOs;
  long	msg;
  int	fileType = 0;

  __DBGpr_com("AIMshow_contained_ars_form START");

  UI_status("Processing...");

  /* Check for AIM conenction */
  if(IsPmeEnabled()==FALSE)
      force_aim_login = AIMlogin();

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

  /* 1. Make sure that this file is an AMDC file */
  
  /* Check if the RG_Collector is created */
  ex$get_cur_mod( osnum = &curOs );

  __DBGpr_com("VDPGetBinItemFromCollector - Get the file type from the collector.");
  status = VDPGetBinItemFromCollector( &msg, curOs, "File Type", &fileType );
  if ( (fileType != 3) || (fileType == 0) )
  {
	UI_status("This is not an Assembly File. Process Terminated!");
  	__DBGpr_com( "This is not an Assembly File. Process Terminated!" ); 
	status = OM_E_ABORT;
	goto wrapup;	
  }	

  __DBGpr_int("fileType = ", fileType );

  /* THIS MUST BE AN ASSEMBLY FILE */
  __DBGpr_com("This must be an assembly file.");

  /* 2.  put the ARs on the form */
  __DBGpr_com("Initialize the form");
  status = show_assem_ar_form();

  wrapup:
  	__DBGpr_com("AIMref_files_form END");

	if( status == 0 )
  		UI_status("");
    	else
  		UI_status("Process Terminated...");
	return status;
}


/************************************************************************/
/* FORM CODE PROCESSING */
/*********************************************************
* Function: assem_notification_routine
***********************************************************/
int show_assem_ar_notification_routine ( f_label, g_label, value, fp )
 int f_label;  
 int g_label; 
 IGRdouble value;
 Form fp; 
{
  int   status = 0;
  int   select, pos, length;
  int   row = 0;
  int   mcf_select = FALSE;
  int   num_rows = 0, numRef;
  int   assem_found = 0, resp;
  long	qmsg;
  char  buffer[5];
  char  *errmsg;

  __DBGpr_com("show_assem_ar_notification_routine - BEGIN ");

  switch ( g_label )
  {
    	case FI_CANCEL: /* Member of group FI_CTRL_GROUP */

    		/* Erase the displayed form */

      		PDUmessage(PDM_E_CMD_CANCELLED, 's');

      		__DBGpr_com("User selected the cancel button");
		
      		if (show_assem_ar_form_displayed == TRUE)
      			FIf_erase( fp );
      		if (show_assem_ar_form_created == TRUE)
        		FIf_delete( fp );

      		show_assem_ar_form_displayed = FALSE;
      		show_assem_ar_form_created = FALSE;
      		resp = EX_FORM_FINISHED;
      		ex$putque(	msg = &qmsg,
                 		response = &resp,
                 		buffer = buffer);
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
			force_aim_login = 0;
  		}
      		break;

      } /* END switch ( g_label ) */

  wrapup:
  	__DBGpr_com("show_assem_ar_notification_routine - END ");
  	return status;
}

/*********************************************************
* Function: show_assem_ar_form
***********************************************************/
int show_assem_ar_form()
{
  int 	status = 0, i = 0, resp;
  long	qmsg;
  int   numARs=0;
  int	index1=0;
  char 	*outbuf = NULL;
  SrConARList *ARList=NULL;

  show_assem_ar_form_created = FALSE;
  show_assem_ar_form_displayed = FALSE;
  show_assem_ar_perm_window = FALSE;

  __DBGpr_com("show_assem_ar_form - START");
  __DBGpr_com("loading contained ARs into form");

  __DBGpr_com( "before initializing the show_assem_ar_form_id to NULL" );
  show_assem_ar_form_id = NULL;

  __DBGpr_com( "before creating the AIMShowAssemAR form" );
  status = FIf_new(SHOW_AIM_ASSEM_AR_FORM, "AIMShowAssemAR", show_assem_ar_notification_routine, &show_assem_ar_form_id);

  __DBGpr_com( "before checking to see if show_assem_ar_form_id is NULL" );
  if(show_assem_ar_form_id == NULL)
  {
  	__DBGpr_com( "show_assem_ar_form_id is NULL...could not created form...EXITING" );
  	printf("\nCould not create form <AIMShowAssemAR>...EXITING");
  	status = 1;
	goto wrapup;
  }

  __DBGpr_com( "setting show_assem_ar_form_created to TRUE" );
  show_assem_ar_form_created = TRUE;

  status = SrGetContainedARs(	refresh->act_catalog, 
				refresh->act_partid, 
				refresh->act_revision, 
				&outbuf);

  memcpy( &numARs, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);
  __DBGpr_int( "number of ARs to display", numARs);

  /* Set the no of rows in the table on the form */
  FIfld_set_num_rows( show_assem_ar_form_id, SHOW_ASM_AR_TBL, numARs );

  //allocate memory for the arlist structure
   ARList = malloc ( numARs * sizeof( SrConARList ) );
   if ( ARList == NULL )
   {
        printf("Error in dynamic allocation of memory\n");
        return OM_E_NODYNMEM;
   }

   for( i = 0; i < numARs; i++ )
   {
    	ARList[i].ARNum[0] = '\0';
    	ARList[i].AIRNum[0] = '\0';
    	ARList[i].ARStatus[0] = '\0';
   }
   
   for(i = 0; i < numARs; i++ )
   {
	__DBGpr_str("AR Number", &outbuf[index1]);
        strcpy(ARList[i].ARNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Number", &outbuf[index1]);
        strcpy(ARList[i].AIRNum, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Status", &outbuf[index1]);
        strcpy(ARList[i].ARStatus, &outbuf[index1]);
    	index1 = index1 + strlen( &outbuf[index1] ) +1;

    }

   __DBGpr_com("Sorting by AR Number");
   qsort(ARList, (unsigned) numARs, sizeof(SrConARList), CMConARSort1);

  __DBGpr_com( "before for loop to loop through ARs" );
  for ( i = 0; i < numARs; i++ )
  {
   	/* store the ref File on the form */
	__DBGpr_str("AR Number", ARList[i].ARNum);
   	FIfld_set_text(	show_assem_ar_form_id, 
			SHOW_ASM_AR_TBL,
               		i, 
			SHOW_ASM_AR_TBL_C_ARNUM, 
			ARList[i].ARNum,
			FALSE);

    	__DBGpr_str("AIR Number", ARList[i].AIRNum);
    	FIfld_set_text(	show_assem_ar_form_id, 
			SHOW_ASM_AR_TBL,
               		i, 
			SHOW_ASM_AR_TBL_C_AIRNUM, 
			ARList[i].AIRNum,
			FALSE);
    		
    	__DBGpr_str("AR Status", ARList[i].ARStatus);
    	FIfld_set_text(	show_assem_ar_form_id, 
			SHOW_ASM_AR_TBL,
               		i, 
			SHOW_ASM_AR_TBL_C_ARSTATUS, 
			ARList[i].ARStatus, 
			FALSE);
	
/*
   	__DBGpr_str("AR Number", &outbuf[index1]);
   	FIfld_set_text(	show_assem_ar_form_id, 
			SHOW_ASM_AR_TBL,
               		i, 
			SHOW_ASM_AR_TBL_C_ARNUM, 
			&outbuf[index1],
			FALSE);
	index1 = index1 + strlen( &outbuf[index1] ) +1;

    	__DBGpr_str("AIR Number", &outbuf[index1]);
    	FIfld_set_text(	show_assem_ar_form_id, 
			SHOW_ASM_AR_TBL,
               		i, 
			SHOW_ASM_AR_TBL_C_AIRNUM, 
			&outbuf[index1], 
			FALSE);
  	index1 = index1 + strlen( &outbuf[index1] ) +1;
    		
    	__DBGpr_str("AR Status", &outbuf[index1]);
    	FIfld_set_text(	show_assem_ar_form_id, 
			SHOW_ASM_AR_TBL,
               		i, 
			SHOW_ASM_AR_TBL_C_ARSTATUS, 
			&outbuf[index1], 
			FALSE);
	index1 = index1 + strlen( &outbuf[index1] ) +1;
*/

	
  }

  __DBGpr_com("displaying the form");
  status = FIf_display(show_assem_ar_form_id);
  __DBGpr_com("form displayed");
  show_assem_ar_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  
wrapup:
  	__DBGpr_com("show_assem_ar_form - END");
  	return status;
}

 

/************************************************************************/
/**********************************************************
* ISDP Interface Function calls
**********************************************************/
/*********************************************************
* Function: 
*
* This function gets a list of contained ARs from AIM.
*
***********************************************************/
int SrGetContainedARs(char *catalog, char *part, char *rev, char **outbuf) 
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

  __DBGpr_com("SrGetContainedARs - START");

  /*
     Send Cmd to AIM through Postman to:
     1. fill the in buffer with the code ( =  )
     2. fill the in buffer with the catalog, partno and rev

   */

  if( IsPmeEnabled() == FALSE )
  {
	force_aim_login = AIMlogin();
  }

  if( IsPmeEnabled() == FALSE )
  {
    status = 1;
    return status;
  }

  code = VDP_GET_CONTAINED_ARS; //146

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;

  strcpy( &inbuf[index], catalog );
  inlen += strlen(catalog) +1;
  index = inlen;

  strcpy( &inbuf[index], part );
  inlen += strlen(part) +1;
  index = inlen;

  strcpy( &inbuf[index], rev );
  inlen += strlen(rev) +1;
  index = inlen;
  
  UI_status( "Querying AIM database for Contained ARs..." );
  __DBGpr_com("Sending the VDP_GET_CONTAINED_ARS command to AIM.");


  dstat = POSTMAN_REQUEST_ON_CLIX ( inlen, inbuf, &outlen,
                                   outbuf, &mfail, &errmsg);

  if(dstat != 0)
  {
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
	goto wrapup;
  }

  if (mfail != 0 )
  {
       	if(errmsg)
       	{
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
	goto wrapup;
  }

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

  	__DBGpr_com("SrGetContainedARs - END");
	return status;
}
