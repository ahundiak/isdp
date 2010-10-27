/* $Id: VDaimStubs.c,v 1.3 2002/05/28 20:16:41 tlstalli Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/VDaimStubs.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: VDaimStubs.c,v $
 *       Revision 1.3  2002/05/28 20:16:41  tlstalli
 *       Added CMCheckFile stub
 *
 *       Revision 1.2  2001/10/29 17:16:29  jdsauby
 *       JTS CR 5552 - jds
 *
 *       Revision 1.1  2001/09/07 18:31:09  jdsauby
 *       Final Checkin for AIM / PDU integration  - jds
 *
 *
 *
 *
 * Revision 1.3  2000/10/24  21:50:08  pinnacle
 * (No comment)
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       08/15/01	 js		 AIM integration
 * -------------------------------------------------------------------------*/


/*******************************************************
 * Function to determine if AIM is loaded.  This function is 
 * overwritten in the AIM code to return 1.
 * **/
int VDaimIsAimLoaded()
{
    return 0;
}
   
int CMstate_form()
{
    return 0;
}

/* To Query Context Rev, Name and Type from SIR_PDM_TABLE */
int PDMGetAttrsfromSirTable(char *Catalog, char *Partid, char *Revision,
                            char *CntxtRev, char *CntxtName, char *CntxtType)
{
    return 0;
}

//                  Mainly searchst was to small but I went ahead and made the other
//					variables larger as well.
int PDMInfoOnCommandbar(char *catalog, char *partid, char *revision)
{
    return 0;
}

int CheckAllowed()
{
    return 0;
}

/************************************************************
* Function CMReject
* IF a state is back to development, change the ARs selcted to WORKING
***************************************************/
int CMReject()
{
    return 0;
}

/********************************************
* Function CMRelease
* this is to Release the part.
* in SIR it changes the relaitonship to implemented
*****************************************************/
int CMRelease()
{
    return 0;
}

/*********************************************************
* Function: CMar_form
*
*
*
***********************************************************/
int CMar_form( char *catalog, char *partno, char *rev )
{
    return 0;
}

/**********************************************************
* Function CMBaseline
* if file is CMEnabled, 1. baseline MDC, 2. Change the relation
* If not ; Just baseline the MDC
**********************************************************/

int CMBaseline()
{
    return 0;
}

/************************************************************
* Function CMCheckFile
* Check the file to make sure that DCC or an AR is selected 
* before doing any CM processing on the file.
***************************************************/
int CMCheckFile()
{
    return 0;
}

int IsRetOK()
{
    return 0;
}

/*******************************************************************
* SrCMCopySim()
* Function to take care about copy similar of a part.
* Nothing to worry about if it is a new part.
* If it is a revision, if old file is under CM control, MDC is baselined
* Revisioning is allowed only in Baseline and Release states.
*******************************************************************/
int SrCMCopySim(char *CMMdcRev, char *t_LpdDesc)
{
    return 0;
}

/* added code Pullabhotla -  Function to Insert Attributes into SIR_PDM_TABLE
 */
int PDMInsertSirTable(char *Refcat, char *Refpart, char *Refrev)
{
    return 0;
}

int SrValidateforRet( char *cat, char *part, char *rev )
{
    return 0;
}

/***************************************************************
 * Added by Anjani
 * SirVDUpdCMAttrs updates the values in the SirPdmtable attributes 
 * which are written for CM management purpose
 * **************************************************************/
int SirVDUpdCMAttrs( char *catalog, 
                     char *partid, 
		     char *revision, 
		     char *Attr,
                     char *Value )
{
    return 0;
}

long AIMcmAddPart(int  new_mode,
	          int  sim_mode,
		  char *old_catalog,
		  char *old_partid,
		  char *old_revision,
		  char *new_catalog,
		  char *new_partid,
		  char *new_revision)
{

    return 0;
}



