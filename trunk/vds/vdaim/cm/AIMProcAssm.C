/* $Id: AIMProcAssm.C,v 1.6 2002/05/30 22:12:32 tlstalli Exp $ */
/***************************************************************************
**
** Program:     AIMProcAssembly.C
**
** Version:     02.06.02.08
**
** Date:        01/24/02
**
** Description: This command will interact with AIM to  
**              retrieve a list of catalog, part number, and revisions
**              that are reference files for the active file.  It will 
**              compare the AIM list with an ISDP list of referenced files
**              retrieved from the active file to display an acurate list
**              of reference files that have been processed or not within
**              AIM.  It will also interface with AIM to process reference 
**              in AIM. 
**
** Author:      T. Stalling
**               
************************************************************************/
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
/* Defines for the Assembly Form */
#define AIM_ASSEM_FORM 	1300

/* ASSEMBLY FORM GADGETS */
#define ASM_MSG_FLD 		10	
#define ASM_PROC_BTN 		11	
#define ASM_SELECT_ALL_BTN	18

//TLS 05-28-02 Add Sort for AMDC Phase II
#define ASM_SORT		19

/* ASSEMBLY FORM TABLE GADGETS */
#define ASM_TBL			13
#define ASM_TBL_C_PART		0
#define ASM_TBL_C_REV		1
#define ASM_TBL_C_DESC		2
#define ASM_TBL_C_AIMSTATUS	3
#define ASM_TBL_C_CATALOG	4

/* Defines for Generic Attributes */
#define CLIX_DISCONNECT 	-2

/***************** Globals ******************/
/* Globals for the Assembly Form */
static 	Form assem_form_id;  
static 	short assem_form_created = FALSE;
static 	short assem_form_displayed = FALSE;
static 	short assem_perm_window = FALSE;

//static 	char gAmdcObid[25];

static int RetOK = 0;
static int force_aim_login = 0;

/**************** Externs *******************/
extern struct 	PDUrefresh        *refresh;
extern int    	SrVDUpdCMattrs();
extern int	AIMGetItemFromCollector();

extern int POSTMAN_REQUEST_ON_CLIX();
extern int VDPGetCtxId();
extern int SrVDGetCMattrs();
extern int AIMlogin();

/**************************************************************************/
/************************************************************
* ASMSort1 Routine
* This will sort the Process AIM Assembly Form by Description
************************************************************/
int ASMSort1(const void *v1, const void *v2)
{
   AIMpdmInfo *p_MDCList1 = (AIMpdmInfo*)v1;
   AIMpdmInfo *p_MDCList2 = (AIMpdmInfo*)v2;

   return strcmp(p_MDCList1->desc, p_MDCList2->desc);
}

/************************************************************
* ASMSort2 Routine
* This will sort the Process AIM Assembly Form by Part Number
************************************************************/
int ASMSort2(const void *v1, const void *v2)
{
  AIMpdmInfo *p_MDCList1 = (AIMpdmInfo*)v1;
  AIMpdmInfo *p_MDCList2 = (AIMpdmInfo*)v2;

  return strcmp(p_MDCList1->part, p_MDCList2->part);
}
/**************************************************************************/

/*********************************************************
* Function: AIMref_files_form
**********************************************************/
int AIMref_files_form()
{
  int 		status = 0, resp;
  char 		ARsel[2], CMmng[2], DCCsel[2], Mdc[5], IsSuper[20];
  int		fileType = 0;
  //struct 	SIRRefPDMInfo *ISDPRefList = NULL;
  //struct 	SIRRefPDMInfo *AIMRefList = NULL;
  TVDpdmRefList ISDPRefList;
  //TVDpdmInfo 	*AIMRefList = NULL;
  AIMpdmInfo 	*AIMRefList = NULL;
  AIMpdmInfo 	*CompareRefList = NULL;
  int		nAIMRefList = 0, nCompareRefList = 0;
  int		lastItem=0, *nLastItemPtr;
  OMuword	curOs;
  long		msg;
  int		filestate=0;

  int 	i=0;
  char	response_data[50];
  long 	qmsg;
  int 	numARs = 0;
  int 	index1 = 0;
  char 	*outbuf = NULL;
  int 	aimcode=0, response;

  *ARsel = 0;
  *CMmng = 0;
  *DCCsel = 0;
  *Mdc = 0;
  *IsSuper = 0;
  //*gAmdcObid = 0;

  //assem_form_created = FALSE;
  //assem_form_displayed = FALSE;
  //assem_perm_window = FALSE;

  __DBGpr_com("AIMref_files_form START");

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

  /* 1. get the aim attributes from the database */
  __DBGpr_com("SrVDGetCMattrs - Get the CM Attributes from the database.");
  status = SrVDGetCMattrs(refresh->act_catalog, refresh->act_partid, refresh->act_revision, 
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  /* only allow this process to work for files that have DAD set */
  if( !(strcmp(Mdc, "N"))  )
  {
	UI_status("Default AIM Data not set; can not process ref files.");
    	__DBGpr_com("Default AIM Data not set; can not process ref files.");
	status = OM_E_ABORT;
	goto wrapup;	
  }
  __DBGpr_str("Mdc = ", Mdc );

  /* 2. make sure that this is an AMDC file */

  /* Check if the RG_Collector is created */
  ex$get_cur_mod( osnum = &curOs );

  __DBGpr_com("AIMGetBinItemFromCollector - Get the file type from the collector.");
  status = VDPGetBinItemFromCollector( &msg, curOs, "File Type", &fileType );
  //if ( (status) || (strcmp(fileType, "3")) || (fileType == 0) )
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

 /* 3. Now, get the AMDC OBID from the collector */
/*************
  __DBGpr_com("AIMGetAsciiItemFromCollector - Get the AMDC OBID from the collector.");
  status = VDPGetAsciiItemFromCollector( &msg, curOs, "Model Context Id", &gAmdcObid );
  if ( (gAmdcObid == 0) )
  {
	UI_status("This is not an Assembly File. Process Terminated!");
  	__DBGpr_com( "This is not an Assembly File. Process Terminated!" ); 
	status = OM_E_ABORT;
	goto wrapup;	
  }	
  __DBGpr_str("gAmdcObid = ", gAmdcObid );
**********************/

//////////////////////////////////////

  /* 4. Get a list of reference files from ISDP for the active ISDP file */
  __DBGpr_com("AIMGetISDPReferenceFiles - Get the list of reference files from ISDP.");
  status = AIMGetISDPReferenceFiles(&ISDPRefList); 
  if (ISDPRefList.cnt < 1)
  {
	UI_status("No Reference Files in ISDP");
  	__DBGpr_com( "There Are No Reference Files in ISDP." ); 
  }

  __DBGpr_int( "no of ref ISDP files:", ISDPRefList.cnt); 

  /* 5. Get a list of reference files from AIM for the active ISDP file */
  __DBGpr_com("AIMGetAMDCtoMDCReln - Get the list of reference files from AIM.");
  //status = AIMGetAMDCtoMDCReln(gAmdcObid, &nAIMRefList, AIMRefList); 
  //status = AIMGetAMDCtoMDCReln(gAmdcObid, &nAIMRefList, &AIMRefList); 
  status = AIMGetAMDCtoMDCReln(refresh->act_catalog, refresh->act_partid, refresh->act_revision,
				&nAIMRefList, &AIMRefList); 
  if (status)
  {
	UI_status("ERROR getting AIM Reference List.");
  	__DBGpr_com( "ERROR getting AIM Reference List." ); 
  }	

  if (nAIMRefList < 1)
  {
	UI_status("No Reference Files in AIM");
  	__DBGpr_com( "There Are No Reference Files in AIM." ); 
  }
  __DBGpr_int( "no of ref files:", nAIMRefList); 
   
/////////////////////////////////////////////////////////

  /* 6. make sure we have some reference files before comparing them or showing them */
  __DBGpr_com("Comparing ref list counts");
  if( (nAIMRefList == 0) && (ISDPRefList.cnt < 1) )
  {
	UI_status("No Reference Files To Display");
  	__DBGpr_com("No Reference Files To Display");
	status = OM_E_ABORT;
	goto wrapup;
  }

  /* 7. initialize the Compare list structure count */
  __DBGpr_com("setting the compare list size");
  __DBGpr_int( "no of ref ISDP files:", ISDPRefList.cnt); 
  __DBGpr_int( "no of ref files:", nAIMRefList); 
/*
  if( nAIMRefList > ISDPRefList.cnt )
	nCompareRefList = nAIMRefList + 10; 	
  else
	nCompareRefList = ISDPRefList.cnt + 10;
*/

  nCompareRefList = nAIMRefList + ISDPRefList.cnt;
  __DBGpr_int("nCompareRefList:", nCompareRefList);

  /* 8. fill in the compare list structure with the ISDP Ref List*/
  __DBGpr_com("filling in the compare list");
  status = AIMFillCompareRefList(	ISDPRefList,
				  	nCompareRefList,
					&CompareRefList);		
  
  /* 9. Compare the compare list with the aim list and update the compare list */
  __DBGpr_com("checking to see if we need to call AIMCompareAIMReftoISDP");
  lastItem = ISDPRefList.cnt;
  __DBGpr_int( "last item :", lastItem); 
  nLastItemPtr = &lastItem;
  __DBGpr_int( "last item ptr:", *nLastItemPtr); 

  __DBGpr_int( "no of AIM ref files:", nAIMRefList); 
  for ( i = 0; i < nAIMRefList; i++ )
  {
  	__DBGpr_com("calling AIMCompareAIMReftoISDP");
  	__DBGpr_str ("AIM Catalog", AIMRefList[i].catalog );
 	status = AIMCompareAIMReftoISDP( 	AIMRefList[i],
						nLastItemPtr, 
						&CompareRefList);   
  }

  /* make sure we have something to display or quit */
  if(nLastItemPtr == 0 )
  {
	UI_status("No Reference Files To Display");
  	__DBGpr_com("No Reference Files To Display");
	status = OM_E_ABORT;
	goto wrapup;
  }
  __DBGpr_int( "NEW number for last item ptr:", *nLastItemPtr); 
  __DBGpr_str( "last item status:", CompareRefList[*nLastItemPtr - 1].status); 

  /* 8. Display form */
  __DBGpr_com("Display the form");

  status = assem_form(refresh->act_catalog, refresh->act_partid, refresh->act_revision,
				lastItem, CompareRefList);

  
  __DBGpr_com("AIMref_files_form END");

  wrapup:
	if(AIMRefList)
		free (AIMRefList);
	if(CompareRefList)
		free (CompareRefList);
	
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
int assem_notification_routine ( f_label, g_label, value, fp )
 int f_label;  
 int g_label; 
 IGRdouble value;
 Form fp; 
{
  int   status = 0;
  int   select, pos, length;
  int   row = 0;
  int   col = 0;
  int   mcf_select = FALSE;
  int   num_rows = 0, numRef;
  int   assem_found = 0, resp;
  long	qmsg;
  char  buffer[5];
  char  *errmsg;
  AIMpdmInfo *MDCList=NULL;
  int MDCListCnt;
  int chkTgOpt;
  int	numMDCs=0, i=0;

  __DBGpr_com("assem_notification_routine - BEGIN ");

  switch ( g_label )
  {
    	case FI_CANCEL: /* Member of group FI_CTRL_GROUP */

    		/* Erase the displayed form */

      		PDUmessage(PDM_E_CMD_CANCELLED, 's');

      		__DBGpr_com("User selected the cancel button");
		
      		if (assem_form_displayed == TRUE)
      			FIf_erase( fp );
      		if (assem_form_created == TRUE)
        		FIf_delete( fp );

      		assem_form_displayed = FALSE;
      		assem_form_created = FALSE;
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

    	case ASM_PROC_BTN: /* Member of group FI_CTRL_GROUP */
      		__DBGpr_com("User selected the process button");

         	UI_status("Processing request, please wait...");

		FIfld_set_text (fp, 
				ASM_MSG_FLD, 
				0, 
				0, 
				"Processing request,  please wait...", 
				FALSE);

		/* calling AIMProcRefFileRequest */
		status = AIMProcRefFileRequest( fp );
		
		/**  Reset the form gadgets **/
		FIfld_set_text (fp, 
				ASM_MSG_FLD, 
				0, 
				0, 
				"Process Complete...", 
				FALSE);
         	UI_status("Processing Complete...");

		break;

	case ASM_SELECT_ALL_BTN:
		__DBGpr_com ("Select All Button");
			
		num_rows = 0;
		row = 0;
		col = 0;

		FIfld_get_num_rows ( 	fp,
					ASM_TBL, 
					&num_rows);

		for (row = 0; row < num_rows; row = row + 1)
		{
				
			for (col = 0; col < 5; col = col + 1)
			{
				FIfld_set_select(	fp, 
							ASM_TBL, 
							row, 
							col, 
							TRUE);
			}
		}
				
		break;

	case ASM_SORT:
		__DBGpr_com ("Sort Toggle");

		//TLS 05-28-02 Add sort toggle for AMDC Phase II

  		//make sure structure is null
  		if ( MDCList != NULL )
    			free(MDCList);

		//generate the MDC list
		status = CMGenerateMDCList(fp, &MDCList, &MDCListCnt);

		FIg_get_state(fp, ASM_SORT, &chkTgOpt );
     		if( chkTgOpt ) //if the toggle is ON
		{
			//sort by Description Number
          		__DBGpr_com("Sorting by Description");
			qsort(MDCList, (unsigned) MDCListCnt, sizeof(AIMpdmInfo), ASMSort1);	
		}
		else
		{
			//sort by Part Number
          		__DBGpr_com("Sorting by Part Number");
			qsort(MDCList, (unsigned) MDCListCnt, sizeof(AIMpdmInfo), ASMSort2);
    		}

		//clear the form
		numMDCs = MDCListCnt;

		FIfld_delete_rows(fp, ASM_TBL, 1, numMDCs);

		//put the new list on the form
        	FIfld_set_num_rows( fp, ASM_TBL, numMDCs);

		for ( i=0; i<numMDCs; i++)
    		{
     			FIfld_set_text( fp, ASM_TBL, i, ASM_TBL_C_PART, MDCList[i].part, FALSE );

     			FIfld_set_text( fp, ASM_TBL, i, ASM_TBL_C_REV, MDCList[i].rev, FALSE );

     			FIfld_set_text( fp, ASM_TBL, i, ASM_TBL_C_DESC, MDCList[i].desc, FALSE );

     			FIfld_set_text( fp, ASM_TBL, i, ASM_TBL_C_AIMSTATUS, MDCList[i].status, FALSE );

     			FIfld_set_text( fp, ASM_TBL, i, ASM_TBL_C_CATALOG, MDCList[i].catalog, FALSE );
    		} 
    	
		break;

  } /* END switch ( g_label ) */

  wrapup:
  	__DBGpr_com("assem_notification_routine - END ");
  	return status;
}

/*********************************************************
* Function: assem_form
***********************************************************/
int assem_form( char *catalog, char *partno, char *rev, int nRefList, AIMpdmInfo *RefList )
{
  int 	status = 0, i = 0, resp;
  char 	ARsel[2], CMmng[2], DCCsel[2], Mdc[5], response_data[50], IsSuper[20];
  long	qmsg;

  assem_form_created = FALSE;
  assem_form_displayed = FALSE;
  assem_perm_window = FALSE;

  __DBGpr_com("assem_form - START");
  __DBGpr_com("loading Ref Files into form");

  status = SrVDGetCMattrs(catalog, partno, rev, 
                          ARsel, CMmng, DCCsel, Mdc, IsSuper);
  if(!(strcmp(Mdc, "N")) )
  {
	UI_status("Default AIM Data not set; can not process ref files.");
    	__DBGpr_com("Default AIM Data not set; can not process ref files.");
	status = OM_E_ABORT;
	goto wrapup;	
  }

  /* Check for AIM conenction */
  if(IsPmeEnabled()==FALSE)
  	AIMlogin();

  if(IsPmeEnabled() == FALSE)
  {
  	UI_status("Not connected to AIM server.");
  	__DBGpr_com("Not connected to AIM server.");
  	RetOK = 0;
  	resp = EX_FORM_FINISHED;
  	ex$putque( msg = &qmsg,
               response = &resp);
  	return 0;
  }

  __DBGpr_com( "before initializing the assem_form_id to NULL" );
  assem_form_id = NULL;

  __DBGpr_com( "before creating the AIMProcAssem form" );
  status = FIf_new(AIM_ASSEM_FORM, "AIMProcAssem", assem_notification_routine, &assem_form_id);

  __DBGpr_com( "before checking to see if assem_form_id is NULL" );
  if(assem_form_id == NULL)
  {
  	__DBGpr_com( "assem_form_id is NULL...could not created form...EXITING" );
  	printf("\nCould not create form <AIMProcAssem>...EXITING");
  	status = 1;
	goto wrapup;
  }

  __DBGpr_com( "setting assem_form_created to TRUE" );
  assem_form_created = TRUE;

  __DBGpr_int( "number of Ref Files to display", nRefList );
  __DBGpr_com( "before check to see if nRefList > 0" );
  if(nRefList > 0)
  {
  	__DBGpr_com( "nRefList is > 0" );
  	__DBGpr_int( "number of Ref Files to display", nRefList );

        //TLS 05-28-02 - sort the list by part number -- default
        __DBGpr_com("Sorting by Part Number");
	qsort(RefList, (unsigned) nRefList, sizeof(AIMpdmInfo), ASMSort2);

  	/* Set the no of rows in the table on the form */
  	FIfld_set_num_rows( assem_form_id, ASM_TBL, nRefList );

  	__DBGpr_com( "before for loop to loop through Ref List" );
  	for ( i = 0; i < nRefList; i++ )
  	{
    		/* store the ref File on the form */

    		__DBGpr_str("Ref Part", (RefList)[i].part);
    		FIfld_set_text(	assem_form_id, 
				ASM_TBL,
                  		i, 
				ASM_TBL_C_PART, 
				(RefList)[i].part, 
				FALSE);

    		__DBGpr_str("Ref Rev", (RefList)[i].rev);
    		FIfld_set_text(	assem_form_id, 
				ASM_TBL,
                  		i, 
				ASM_TBL_C_REV, 
				(RefList)[i].rev, 
				FALSE);
    		
    		__DBGpr_str("Ref Desc", (RefList)[i].desc);
    		FIfld_set_text(	assem_form_id, 
				ASM_TBL,
                  		i, 
				ASM_TBL_C_DESC, 
				(RefList)[i].desc, 
				FALSE);

    		__DBGpr_str("Ref Status", (RefList)[i].status);
    		FIfld_set_text(	assem_form_id, 
				ASM_TBL,
                  		i, 
				ASM_TBL_C_AIMSTATUS, 
				(RefList)[i].status, 
				FALSE);

    		__DBGpr_str("Ref Catalog", (RefList)[i].catalog);
    		FIfld_set_text(	assem_form_id, 
				ASM_TBL,
                  		i, 
				ASM_TBL_C_CATALOG, 
				(RefList)[i].catalog, 
				FALSE);
  	}
  }

  __DBGpr_com("displaying the form");
  status = FIf_display(assem_form_id);
  __DBGpr_com("form displayed");
  assem_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  
  wrapup:
  	__DBGpr_com("assem_form - END");
  	return status;
}

 

/************************************************************************/
/**********************************************************
* ISDP Interface Function calls
**********************************************************/
/*********************************************************
* Function: AIMGetISDPReferenceFiles
*
* This function gets a list of reference file from ISDP for the active file.
*
***********************************************************/
int AIMGetISDPReferenceFiles(TVDpdmRefList *RefList ) 
{
  int 		status = 0;
  VDosnum    	cur_os;

  __DBGpr_com("AIMGetISDPReferenceFiles - START");

  // init
  __DBGpr_com("calling VDpdmInitRefList");
  VDpdmInitRefList( RefList );

  /* get the reference files from the active ISDP file */
  // get the current os
  __DBGpr_com("calling ex$get_cur_mod");
  ex$get_cur_mod(osnum = &cur_os);
 

  // get list of reference files and count
  __DBGpr_com("calling VDpdmGetRefList ");
  status = VDpdmGetRefList( cur_os, RefList );
  if ( (status) || (RefList->cnt < 1) ) 
	goto wrapup;

  wrapup:
  	__DBGpr_com("AIMGetISDPReferenceFiles - END");
	return status;
}

/*********************************************************
* Function: AIMFillCompareRefList
*
* This function fills in the Compare Ref List.
*
***********************************************************/
int AIMFillCompareRefList( 	TVDpdmRefList ISDPRefList,
				int nCompareRefCnt,
				AIMpdmInfo **CompareRefList  ) 
{

  int 	status = 0, i=0;
  char 	searchst[128], partdesc_value[130];
  char 	**bufst;
  int 	num;
  int 	status1=0, sts=1;

  __DBGpr_com("AIMFillCompareRefList - START");

   __DBGpr_int("nCompareRefCnt:", nCompareRefCnt);

  if( nCompareRefCnt > 0 )
  {
  	__DBGpr_com("initializing the CompareRefList");
  	__DBGpr_int("nCompareRefCnt:", nCompareRefCnt);
	*CompareRefList = malloc ( nCompareRefCnt * sizeof( AIMpdmInfo ) );
        if ( *CompareRefList == NULL )
        {
        	printf("Error in dynamic allocation of memory\n");
                return OM_E_NODYNMEM;
        }
  }

  /* clear out the structure */
  for( i = 0; i < nCompareRefCnt; i++ )
  {
	(*CompareRefList)[i].catalog[0] = '\0';
       	(*CompareRefList)[i].part[0] = '\0';
       	(*CompareRefList)[i].rev[0] = '\0';
       	(*CompareRefList)[i].filename[0] = '\0';
       	(*CompareRefList)[i].desc[0] = '\0';
       	(*CompareRefList)[i].status[0] = '\0';
       	(*CompareRefList)[i].obid[0] = '\0';
  } 

  /* store the isdp list in the compare list ( if there are some isdp ref file ) */
  __DBGpr_com("store the isdp list in the compare structure");
  __DBGpr_int ("ISDP Ref Count = ", ISDPRefList.cnt );
  for ( i = 0; i < ISDPRefList.cnt; i++ )
  {
       	__DBGpr_str ("ISDP Ref Catalog", ISDPRefList.infos[i].catalog );
       	strcpy( (*CompareRefList)[i].catalog, ISDPRefList.infos[i].catalog);
       	__DBGpr_str ("Compare Ref Catalog", (*CompareRefList)[i].catalog );

       	__DBGpr_str ("ISDP Ref Part", ISDPRefList.infos[i].part );
       	strcpy( (*CompareRefList)[i].part, ISDPRefList.infos[i].part);
   	__DBGpr_str ("Compare Ref Part", (*CompareRefList)[i].part );

       	__DBGpr_str ("ISDP Ref Rev", ISDPRefList.infos[i].rev );
       	strcpy( (*CompareRefList)[i].rev, ISDPRefList.infos[i].rev);
       	__DBGpr_str ("Compare Ref Rev", (*CompareRefList)[i].rev );

       	__DBGpr_str ("ISDP Ref Filename", ISDPRefList.infos[i].filename );
       	strcpy( (*CompareRefList)[i].filename, ISDPRefList.infos[i].filename);
       	__DBGpr_str ("Compare Ref Filename", (*CompareRefList)[i].filename );

       	//__DBGpr_int ("ISDP Ref Filekey", ISDPRefList.infos[i].filekey );
       	//memcpy( (*CompareRefList)[i].filekey, ISDPRefList.infos[i].filekey, sizeof(int) );
       	//__DBGpr_int ("Compare Ref Filekey", (*CompareRefList)[i].filekey );

	//TLS 05-30-02 Get the part description from the database
	searchst[0] = '\0';
    	sprintf(searchst, "n_itemname = '%s' and n_itemrev = '%s'", 
			   ISDPRefList.infos[i].part, ISDPRefList.infos[i].rev); 

     	__DBGpr_str("Searchst is", searchst);
 
    	status1 =
          vdb$RisSelect(select="n_itemdesc",
                        table_name = ISDPRefList.infos[i].catalog, 
    		        where = searchst,
			numselect = 1,
			p_numrows = &num,
			p_buffer = &bufst);

     	if(status1 != 1 || num == 0 )
     	{
		strcpy( (*CompareRefList)[i].desc, "");
       		__DBGpr_str ("Compare Ref Desc", (*CompareRefList)[i].desc );
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

       		__DBGpr_str ("partdesc_value", partdesc_value );
		strcpy( (*CompareRefList)[i].desc, partdesc_value);
       		__DBGpr_str ("Compare Ref Desc", (*CompareRefList)[i].desc );
     	}

       	//strcpy( (*CompareRefList)[i].desc, "");
       	//__DBGpr_str ("Compare Ref Desc", (*CompareRefList)[i].desc );

       	strcpy( (*CompareRefList)[i].status, "NOT PROCESSED");
       	__DBGpr_str ("Compare Ref Status", (*CompareRefList)[i].status );

       	strcpy( (*CompareRefList)[i].obid, "");
       	__DBGpr_str ("Compare Ref OBID", (*CompareRefList)[i].obid );

  }

  wrapup:
	return status;
}


/*********************************************************
* Function: AIMCompareAIMRefToActive
*
* This function gets a list of reference file from ISDP for the active file.
*
***********************************************************/
int AIMCompareAIMReftoISDP( 	AIMpdmInfo AIMRefList,
				int *nLastItemPtr,
				AIMpdmInfo **CompareRefList  ) 
{
  int 	status = 0;
  int	compCnt = 0;
  int	i = 0, y=0, found = 0;

  __DBGpr_com("AIMCompareAIMReftoISDP - BEGIN ");

  __DBGpr_int("*nLastItemPtr:", *nLastItemPtr);
  __DBGpr_str ("AIM Catalog", AIMRefList.catalog );

  /* we need to aim ref files to the compare ref list */  
  for ( i = 0; i < *nLastItemPtr; i++ )
  {
	if( !(strcmp( (*CompareRefList)[i].catalog, AIMRefList.catalog)) &&
		!(strcmp( (*CompareRefList)[i].part, AIMRefList.part)) &&
		!(strcmp( (*CompareRefList)[i].rev, AIMRefList.rev)) )
	{

        	strcpy((*CompareRefList)[i].status, "PROCESSED");
        	__DBGpr_str ("Ref Status", (*CompareRefList)[i].status );

		found = 1;
		break;

	}

  }//for loop

  if( found == 0 )
  {
	/* aim only ref files */
  	__DBGpr_com("found is 0");

  	__DBGpr_int("*nLastItemPtr: ", *nLastItemPtr);
	*nLastItemPtr = *nLastItemPtr + 1;
  	__DBGpr_int("*nLastItemPtr: ", *nLastItemPtr);

	y = *nLastItemPtr - 1; /* zero indexed to subtract 1 */
  	__DBGpr_int("y: ", y);
/*
       	(*CompareRefList)[y].catalog[0] = '\0';
       	(*CompareRefList)[y].part[0] = '\0';
       	(*CompareRefList)[y].rev[0] = '\0';
       	(*CompareRefList)[y].filename[0] = '\0';
       	(*CompareRefList)[y].desc[0] = '\0';
       	(*CompareRefList)[y].status[0] = '\0';
       	(*CompareRefList)[y].obid[0] = '\0';
*/
        __DBGpr_str ("AIM Ref Catalog", AIMRefList.catalog);
       	strcpy((*CompareRefList)[y].catalog, AIMRefList.catalog);
        __DBGpr_str ("Compare Ref Catalog", (*CompareRefList)[y].catalog );

        __DBGpr_str ("AIM Ref Part", AIMRefList.part);
       	strcpy((*CompareRefList)[y].part, AIMRefList.part);
       	__DBGpr_str ("Compare Ref Part", (*CompareRefList)[y].part );

        __DBGpr_str ("AIM Ref Revision", AIMRefList.rev);
       	strcpy((*CompareRefList)[y].rev, AIMRefList.rev);
       	__DBGpr_str ("Compare Ref Revision", (*CompareRefList)[y].rev );

        //__DBGpr_str ("AIM Ref Filename", AIMRefList.filename);
       	//strcpy((*CompareRefList)[y].filename, AIMRefList.filename);
       	strcpy((*CompareRefList)[y].filename, "");
       	__DBGpr_str ("Compare Ref Filename", (*CompareRefList)[y].filename );

        //__DBGpr_str ("AIM Ref Filekey", AIMRefList.filekey);
       	//strcpy((*CompareRefList)[i].filekey, AIMRefList.filekey);
       	//__DBGpr_str ("Compare Ref Filekey", (*CompareRefList)[y].filekey );

        __DBGpr_str ("AIM Ref Desc", AIMRefList.desc);
       	strcpy((*CompareRefList)[y].desc, AIMRefList.desc);
       	//strcpy((*CompareRefList)[y].desc, "");
       	__DBGpr_str ("Compare Ref Desc", (*CompareRefList)[y].desc );

       	strcpy((*CompareRefList)[y].status, "OBSOLETE");
       	__DBGpr_str ("Compare Ref Status", (*CompareRefList)[y].status );

       	strcpy((*CompareRefList)[y].obid, "");
       	__DBGpr_str ("Compare Ref OBID", (*CompareRefList)[y].obid );

  }
	
  wrapup:
	return status;
}


/*********************************************************
* Function: AIMProcRefFileRequest  
*
* This function processes the selected reference files.
*
***********************************************************/
int AIMProcRefFileRequest( fp ) 
Form fp;
{
  int 	status = 0;
  int	select, pos, length;
  int   row = 0;
  int   mcf_select = FALSE;
  int 	code = 0;
  int   num_rows = 0, numRef;
  int   assem_found = 0, resp;
  char	*catalog=NULL, *part=NULL, *rev=NULL;

  static char *aimstatus = NULL;

  __DBGpr_com("getting the number of rows on the form");
  FIfld_get_num_rows(fp, ASM_TBL, &num_rows);
  __DBGpr_int("num_rows ", num_rows);

  __DBGpr_com("loop through each row");
  for (row = 0; row < num_rows; ++row)
  {
	__DBGpr_int("row: ", row);
	/* get the aim status */
       	FIfld_get_text_length(	fp, 
				ASM_TBL, 
				row, 
				ASM_TBL_C_AIMSTATUS, 
				&length);
       	aimstatus = (char *) malloc (sizeof (char) * length+1);
       	memset(aimstatus, NULL, sizeof (char) * length + 1);

       	FIfld_get_text(	fp, 
			ASM_TBL, 
			row, 
			ASM_TBL_C_AIMSTATUS, 
			length,
       			(unsigned char *)aimstatus, 
			&select, 
			&pos);

       	__DBGpr_str("aimstatus ", aimstatus);
	
	/* delete the contains relationship in aim regardless of if row is selected for 
	 * obsolete reference files.
         */
	if ( strcmp(aimstatus, "OBSOLETE") == 0 ) 
	{
		/* get the data from the form */
		__DBGpr_int("row: ", row);
       		FIfld_get_text_length(	fp, 
					ASM_TBL, 
					row, 
					ASM_TBL_C_CATALOG, 
					&length);
       		catalog = (char *) malloc (sizeof (char) * length+1);
       		memset(catalog, NULL, sizeof (char) * length + 1);

       		FIfld_get_text(	fp, 
				ASM_TBL, 
				row, 
				ASM_TBL_C_CATALOG, 
				length,
       				(unsigned char *)catalog, 
				&select, 
				&pos);

       		__DBGpr_str("catalog ", catalog);
		
       		FIfld_get_text_length(	fp, 
					ASM_TBL, 
					row, 
					ASM_TBL_C_PART, 
					&length);
       		part = (char *) malloc (sizeof (char) * length+1);
       		memset(part, NULL, sizeof (char) * length + 1);

       		FIfld_get_text(	fp, 
				ASM_TBL, 
				row, 
				ASM_TBL_C_PART, 
				length,
       				(unsigned char *)part, 
				&select, 
				&pos);

       		__DBGpr_str("part ", part);

       		FIfld_get_text_length(	fp, 
					ASM_TBL, 
					row, 
					ASM_TBL_C_REV, 
					&length);
       		rev = (char *) malloc (sizeof (char) * length+1);
       		memset(rev, NULL, sizeof (char) * length + 1);

       		FIfld_get_text(	fp, 
				ASM_TBL, 
				row, 
				ASM_TBL_C_REV, 
				length,
       				(unsigned char *)rev, 
				&select, 
				&pos);

       		__DBGpr_str("rev ", rev);


		/* delete relationship in aim */
		code = VDP_DELETE_AMDC_MDC_RELN;
		//status = AIMProcessAMDCtoMDCReln (code, gAmdcObid, catalog, part, rev );
		status = AIMProcessAMDCtoMDCReln (	code, 
							refresh->act_catalog,
							refresh->act_partid,
							refresh->act_revision,
							catalog, 
							part, 
							rev );
		if (status == 0 )
		{
			/* update the form to show it's been processed */
    			FIfld_set_text(	fp, 
					ASM_TBL,
                  			row, 
					ASM_TBL_C_AIMSTATUS, 
					"REMOVED", 
					FALSE);
		}
		
	}
	
	/* check to see if the row is selected */
       	FIfld_get_select(fp, ASM_TBL, row, 0, &mcf_select);

	/* if the row is a selected row then create the contains relationship in aim */
       	if (mcf_select)
       	{
		if ( (strcmp(aimstatus, "NOT PROCESSED") == 0) ) 
		{
			/* get the data from the form */
			__DBGpr_int("selected row: ", row);
       			FIfld_get_text_length(	fp, 
						ASM_TBL, 
						row, 
						ASM_TBL_C_CATALOG, 
						&length);
       			catalog = (char *) malloc (sizeof (char) * length+1);
       			memset(catalog, NULL, sizeof (char) * length + 1);

       			FIfld_get_text(	fp, 
					ASM_TBL, 
					row, 
					ASM_TBL_C_CATALOG, 
					length,
       					(unsigned char *)catalog, 
					&select, 
					&pos);

       			__DBGpr_str("catalog ", catalog);
		
       			FIfld_get_text_length(	fp, 
						ASM_TBL, 
						row, 
						ASM_TBL_C_PART, 
						&length);
       			part = (char *) malloc (sizeof (char) * length+1);
       			memset(part, NULL, sizeof (char) * length + 1);

       			FIfld_get_text(	fp, 
					ASM_TBL, 
					row, 
					ASM_TBL_C_PART, 
					length,
       					(unsigned char *)part, 
					&select, 
					&pos);

       			__DBGpr_str("part ", part);

       			FIfld_get_text_length(	fp, 
						ASM_TBL, 
						row, 
						ASM_TBL_C_REV, 
						&length);
       			rev = (char *) malloc (sizeof (char) * length+1);
       			memset(rev, NULL, sizeof (char) * length + 1);

       			FIfld_get_text(	fp, 
					ASM_TBL, 
					row, 
					ASM_TBL_C_REV, 
					length,
       					(unsigned char *)rev, 
					&select, 
					&pos);

       			__DBGpr_str("rev ", rev);


			/* create the contains relationship in aim */
			code = VDP_CREATE_AMDC_MDC_RELN;
			//status = AIMProcessAMDCtoMDCReln (code, gAmdcObid, catalog, part, rev );
			status = AIMProcessAMDCtoMDCReln (	code, 
								refresh->act_catalog,
								refresh->act_partid,
								refresh->act_revision, 
								catalog, 
								part, 
								rev );

			if (status == 0 )
			{
				/* update the form to show it's been processed */
    				FIfld_set_text(	fp, 
						ASM_TBL,
                  				row, 
						ASM_TBL_C_AIMSTATUS, 
						"PROCESSED", 
						FALSE);

			}

		}
      	} /* if mcf_selected */
  } /* end for number of rows selected */

  wrapup:
	return status;
}





/************************************************************************/

/**********************************************************
* AIM Function calls
**********************************************************/
/*********************************************************
* Function: AIMGetAMDCtoMDCReln
*
* This function gets a list of reference file from AIM.
*
***********************************************************/
//int AIMGetAMDCtoMDCReln(char *amdcObid, 
int AIMGetAMDCtoMDCReln(char *amdc_catalog, char *amdc_partno, char *amdc_rev, 
			int *nRefList,
			 AIMpdmInfo **RefList ) 
{

  int   status = 0;
  int   i = 0, inlen = 0, code = 0;
  int	index = 0, index1 = 0, outlen = 0;
  int   dstat = 0, mfail = 0;
  char  inbuf[50], srerrmsg[70];
  char  *outbuf, *errmsg=0;

  *nRefList = 0;
  *RefList = NULL;

  __DBGpr_com( "AIMGetAMDCtoMDCReln - START");

  for ( i=0; i<50; i++ )
  	inbuf[i]='\0';

  code = VDP_SEARCH_AMDC_MDC_RELN; //112

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  
  //strcpy( &inbuf[index], amdcObid );
  //inlen += strlen(amdcObid) + 1;
  //index = inlen;

  strcpy( &inbuf[index], amdc_catalog );
  inlen += strlen(amdc_catalog) + 1;
  index = inlen;

  strcpy( &inbuf[index], amdc_partno );
  inlen += strlen(amdc_partno) + 1;
  index = inlen;

  strcpy( &inbuf[index], amdc_rev );
  inlen += strlen(amdc_rev) + 1;
  index = inlen;

  dstat = POSTMAN_REQUEST_ON_CLIX (   inlen, inbuf,
                &outlen,
                &outbuf,
                &mfail,
                &errmsg );

  if(dstat != 0)
  {
 	if(dstat == 12345 )
        {
         	UI_status("AIM connection reset by server.");
         	UI_status("Failed to get reference files from AIM.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
        	strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
         	status = 1;
         	goto wrapup;
        }
	else
        {
         	UI_status("Failed to get reference files from AIM.");
         	status = 1;
         	goto wrapup;
        }
  }
  if(mfail != 0)
  {
	if(mfail == AMDC_DOES_NOT_EXIST )
       	{
       	 	UI_status("AMDC DOES NOT EXIST IN AIM.");
         	__DBGpr_com("AMDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	return status;
       	}
	if(mfail == AMDC_MDC_RELN_DOES_NOT_EXIST )
       	{
       	 	UI_status("AMDC TO MDC RELATIONSHIP DOES NOT EXIST IN AIM.");
         	__DBGpr_com("AMDC TO MDC RELATIONSHIP DOES NOT EXIST IN AIM.");
         	//status = mfail;
		status = 0; //this is ok, there is nothing to process from AIM
         	return status;
       	}
	if( (mfail == USC_VALIDATION_ERROR) || (mfail == VDP_AIM_ERROR ) )
       	{
       	 	UI_status("An Internal AIM Error Occurred. Contact AIM Administrator.");
       	 	__DBGpr_com("An Internal AIM Error Occurred. Contact AIM Administrator.");
         	status = mfail;
         	return status;
       	}

       	UI_status("An AIM Error Occurred. Contact AIM Administrator.");
       	__DBGpr_com("An AIM Error Occurred. Contact AIM Administrator.");
        status = mfail;
        return status;
  }

  memcpy( nRefList, &outbuf[index1], sizeof(int));
  index1 = index1 + sizeof(int);
  __DBGpr_int( "nRefList", *nRefList );

  if( *nRefList == 0) 
	goto wrapup;

  if( *nRefList )
  {
	//*RefList = malloc ( *nRefList * sizeof(TVDpdmInfo) );
	*RefList = malloc ( *nRefList * sizeof(AIMpdmInfo) );
        if ( *RefList == NULL )
        {
        	printf("Error in dynamic allocation of memory\n");
        	return OM_E_NODYNMEM;
        }

   	/*memset(*RefList, *nRefList, sizeof(TVDpdmInfo));
        if ( *RefList == NULL )
        {
        	printf("Error in dynamic allocation of memory\n");
                return OM_E_NODYNMEM;
        }*/
  }
  for ( i = 0; i < *nRefList; i++ )
  {
        (*RefList)[i].catalog[0] = '\0';
        (*RefList)[i].part[0] = '\0';
        (*RefList)[i].rev[0] = '\0';
        (*RefList)[i].filename[0] = '\0';
        (*RefList)[i].desc[0] = '\0';
        (*RefList)[i].status[0] = '\0';
        (*RefList)[i].obid[0] = '\0';

        strcpy((*RefList)[i].catalog, &outbuf[index1]);
        index1 = index1 + strlen((*RefList)[i].catalog) +1;
         __DBGpr_str ("Ref Catalog", (*RefList)[i].catalog );

        strcpy((*RefList)[i].part, &outbuf[index1]);
        index1 = index1 + strlen((*RefList)[i].part) +1;
        __DBGpr_str ("Ref Part No", (*RefList)[i].part );

        strcpy((*RefList)[i].rev, &outbuf[index1]);
        index1 = index1 + strlen((*RefList)[i].rev) +1;
        __DBGpr_str ("Ref Revision", (*RefList)[i].rev );

	strcpy((*RefList)[i].desc, &outbuf[index1]);
        index1 = index1 + strlen((*RefList)[i].desc) +1;
        __DBGpr_str ("Ref Description", (*RefList)[i].desc );
	
  }
  //AIMqsort(1, 0, *nRefList-1); 

  wrapup:
	return status;
}

/*********************************************************
* Function: AIMProcessAMDCtoMDCReln
*
* This function processes the reference file in aim.
*
***********************************************************/
/*
int AIMProcessAMDCtoMDCReln(	int code, 
				char *amdcObid, 
				char *catalog,
				char *part,
				char *rev) 
*/
int AIMProcessAMDCtoMDCReln(	int code, 
				char *amdc_catalog,
				char *amdc_part,
				char *amdc_rev, 
				char *catalog,
				char *part,
				char *rev) 
{
  int   status = 0;
  int   i = 0, inlen = 0;
  int	index = 0, index1 = 0, outlen = 0;
  int   dstat = 0, mfail = 0;
  char  inbuf[50], srerrmsg[70];
  char  *outbuf, *errmsg=0;

  //__DBGpr_str("amdcObid ", amdcObid);
  __DBGpr_str("amdc_catalog ", amdc_catalog);
  __DBGpr_str("amdc_part ", amdc_part);
  __DBGpr_str("amdc_rev ", amdc_rev);
  __DBGpr_str("catalog ", catalog);
  __DBGpr_str("part ", part);
  __DBGpr_str("rev ", rev);

  for ( i=0; i<50; i++ )
  	inbuf[i]='\0';

  memcpy( &inbuf[index], &code, sizeof(int));
  inlen += sizeof(int);
  index = inlen;
  
  //strcpy( &inbuf[index], amdcObid );
  //inlen += strlen(amdcObid) + 1;
  //index = inlen;

  strcpy( &inbuf[index], amdc_catalog );
  inlen += strlen(amdc_catalog) + 1;
  index = inlen;

  strcpy( &inbuf[index], amdc_part );
  inlen += strlen(amdc_part) + 1;
  index = inlen;

  strcpy( &inbuf[index], amdc_rev );
  inlen += strlen(amdc_rev) + 1;
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
       	if(mfail == MDC_DOES_NOT_EXIST )
       	{
       	 	UI_status("REF FILE (or MDC) DOES NOT EXIST IN AIM.");
         	__DBGpr_com("MDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	return status;
       	}

       	if(mfail == AMDC_DOES_NOT_EXIST )
       	{
       	 	UI_status("AMDC DOES NOT EXIST IN AIM.");
         	__DBGpr_com("AMDC DOES NOT EXIST IN AIM.");
         	status = mfail;
         	return status;
       	}

       	if(mfail == MDC_MR_DOES_NOT_EXIST )
       	{
       	 	UI_status("MDC MASTER DOES NOT EXIST IN AIM.");
         	__DBGpr_com("MDC MASTER DOES NOT EXIST IN AIM.");
         	status = mfail;
         	return status;
       	}

       	if(mfail == AMDC_MDC_RELN_DOES_NOT_EXIST )
       	{
       	 	UI_status("AMDC RELATIONSHIP DOES NOT EXIST IN AIM.");
         	__DBGpr_com("AMDC RELATIONSHIP DOES NOT EXIST IN AIM.");
         	status = mfail;
         	return status;
       	}
	if( (mfail == USC_VALIDATION_ERROR) || (mfail == VDP_AIM_ERROR ) )
       	{
       	 	UI_status("An Internal AIM Error Occurred. Contact AIM Administrator.");
       	 	__DBGpr_com("An Internal AIM Error Occurred. Contact AIM Administrator.");
         	status = mfail;
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

//TLS 05-28-02 - Add the MDCs to a structure to be used
//                       for sorting.
/*********************************************************
* CMGenerateMDCList
***********************************************************/
int CMGenerateMDCList(Form fp, AIMpdmInfo **MDCList, int *MDCListCnt)
{
  int num_rows=0, i=0, length=0;
  int status=0;
  int select, pos;

  //get the number of rows from the form
  FIfld_get_num_rows(fp, ASM_TBL, &num_rows);
  __DBGpr_int( "num_rows", num_rows );

  *MDCListCnt = num_rows;
  __DBGpr_int( "MDCListCnt", *MDCListCnt );

  //allocate memory for the arlist structure
  *MDCList = malloc ( num_rows * sizeof( AIMpdmInfo ) );
  if ( *MDCList == NULL )
  {
        printf("Error in dynamic allocation of memory\n");
        return OM_E_NODYNMEM;
  }

  //clear the structure
  for( i = 0; i < num_rows; i++ )
  {
    (*MDCList)[i].catalog[0] = '\0';
    (*MDCList)[i].part[0] = '\0';
    (*MDCList)[i].rev[0] = '\0';
    (*MDCList)[i].filename[0] = '\0';
    (*MDCList)[i].desc[0] = '\0';
    (*MDCList)[i].status[0] = '\0';
    (*MDCList)[i].obid[0] = '\0';
  }

  //get the MDCs from the form
  for (i = 0; i < num_rows; i++)
  {
	FIfld_get_text_length(fp, ASM_TBL, i, ASM_TBL_C_PART, &length);
        FIfld_get_text(fp, ASM_TBL, i, ASM_TBL_C_PART, length,
                      (unsigned char *)(*MDCList)[i].part, &select, &pos);
        __DBGpr_str("MDCList[i].part ", (*MDCList)[i].part);

	FIfld_get_text_length(fp, ASM_TBL, i, ASM_TBL_C_REV, &length);
        FIfld_get_text(fp, ASM_TBL, i, ASM_TBL_C_REV, length,
                      (unsigned char *)(*MDCList)[i].rev, &select, &pos);
        __DBGpr_str("MDCList[i].rev ", (*MDCList)[i].rev);

	FIfld_get_text_length(fp, ASM_TBL, i, ASM_TBL_C_DESC, &length);
        FIfld_get_text(fp, ASM_TBL, i, ASM_TBL_C_DESC, length,
                      (unsigned char *)(*MDCList)[i].desc, &select, &pos);
        __DBGpr_str("MDCList[i].desc ", (*MDCList)[i].desc);

	FIfld_get_text_length(fp, ASM_TBL, i, ASM_TBL_C_AIMSTATUS, &length);
        FIfld_get_text(fp, ASM_TBL, i, ASM_TBL_C_AIMSTATUS, length,
                      (unsigned char *)(*MDCList)[i].status, &select, &pos);
        __DBGpr_str("MDCList[i].status ", (*MDCList)[i].status);

	FIfld_get_text_length(fp, ASM_TBL, i, ASM_TBL_C_CATALOG, &length);
        FIfld_get_text(fp, ASM_TBL, i, ASM_TBL_C_CATALOG, length,
                      (unsigned char *)(*MDCList)[i].catalog, &select, &pos);
        __DBGpr_str("MDCList[i].catalpg ", (*MDCList)[i].catalog);
  }
 

wrapup:
  return status;
}

