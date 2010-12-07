/* $Id: AIMcmAddPart.C,v 1.6.2.2 2004/02/27 15:01:29 ahundiak Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: aim/src/cm/AIMcmAddPart.c
 *
 * Description:  The entry point into this file is AIMcmAddPart().
 * 	This function is called from PDU in vds/emsfixes/pdu/PDUadd_part.c
 * 	In this file, all of the stuff required by AIM CM will be accomplished
 * 	when a new part is added to PDM.
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: AIMcmAddPart.C,v $
 *       Revision 1.6.2.2  2004/02/27 15:01:29  ahundiak
 *       ah
 *
 *       Revision 1.6.2.1  2004/02/11 19:49:37  ahundiak
 *       ah
 *
 *       Revision 1.6  2002/05/13 18:14:49  tlstalli
 *       added error message for revisioning
 *
 *       Revision 1.5  2002/04/08 18:34:36  tlstalli
 *       Fixed TR 6128
 *
 *       Revision 1.4  2002/03/04 16:15:51  tlstalli
 *       Set the p_incpartrpt to what ever the existing file was
 *
 *       Revision 1.3  2002/02/08 20:00:07  tlstalli
 *	 TLS - Added code to set the p_incpartrpt value to N for new parts
 *
 *       Revision 1.2  2001/12/06 21:41:39  jdsauby
 *       Fixes the Fix-Rejected CR 5228
 *
 *       Revision 1.1  2001/10/29 17:22:11  jdsauby
 *       JTS MP TR 5552 - jds
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/19/01  js	     Creation for TR5552
 * 02/11/04  ah      Added some trace statments for debugging
 * -------------------------------------------------------------------------*/

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDaimCM.h"
#include "VDpdm.h"
#include "VDrisc.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "VDfrmc.h"
#include "vadbgmacros.h"
#include "VDPdef.h"

VDASSERT_FFN("aim/src/cm/AIMcmAddPart.c");

/* static variables set in entry function AIMcmAddPart() */
typedef struct
{
    IGRchar old_cat [80];
    IGRchar old_part[80];
    IGRchar old_rev [80];
    IGRchar new_cat [80];
    IGRchar new_part[80];
    IGRchar new_rev [80];
    IGRchar new_desc[200];
} AIMpartData;

static AIMpartData s_data;
static IGRint force_aim_login;

/* ------------------------------------------------------------
 * Set the PDM attributes used by AIM CM
 * **/
static IGRstat setSirPDMAttrs(IGRchar *mdc_rev)
{
    VDASSERT_FN("setSirPDMAttrs");
    IGRstat retFlag = 0;

    IGRstat sts;
    IGRchar ARsel[10],RevCM[10],DCCsel[10],Mdc[10],IsSuper[10];
    IGRchar CtxRev[20],CtxName[40],CtxType[40];

    // init
    *RevCM = 0;
    *CtxRev = 0;
    *CtxName = 0;
    *CtxType = 0;

    // arg check
    VDASSERTW(mdc_rev && *mdc_rev);

    
    // insert the new part into the SIR PDM table
    if (traceFlag) printf("### Insert New Part into SIR_PDM_TABLE\n");
    PDMInsertSirTable(s_data.new_cat,s_data.new_part,s_data.new_rev);

    if (traceFlag) printf("### Insert MDC REV into SIR_PDM_TABLE\n");
    SirVDUpdCMAttrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "mdc_rev",mdc_rev);


    // update some CM attributes for the new part
    if (traceFlag) printf("### Update part in Catalog with CM Attributes\n");
    SrVDUpdCMattrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "p_mrpstrcut","N");
    SrVDUpdCMattrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "p_explode","Y");
    SrVDUpdCMattrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "p_mrpfieldupd","N");

    // set the is superceded flag for the old part
    if (traceFlag) printf("### Tag the old part as superceded\n");
    SrVDUpdCMattrs(s_data.old_cat,s_data.old_part,s_data.old_rev,
	           "p_mrpfieldupd","Y");


    // get the rev cm from the old part
    if (traceFlag) printf("### Copy Rev CM from old part to new (p_mrppart)\n");
    SrVDGetCMattrs(s_data.old_cat,s_data.old_part,s_data.old_rev,
	           ARsel,RevCM,DCCsel,Mdc,IsSuper);
    if (*RevCM == 0) {
	printf("### Failed to get Rev CM from old part\n");
	goto wrapup;
    }

    // RevCM 
    SrVDUpdCMattrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "p_mrppart",RevCM);

    //TLS 02/26/02 - Set the p_incpartrpt to what ever the existing file was
    if (*Mdc == 0) 
    {
	printf("### Failed to get Mdc from old part\n");
	goto wrapup;
    }

    SrVDUpdCMattrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "p_incpartrpt",Mdc);
    //TLS

    // copy some PDM sir attributes from old part to new part
    if (traceFlag) printf("### Copy attrs from SIR_PDM_TABLE of old to new\n");
    PDMGetAttrsfromSirTable(s_data.old_cat,s_data.old_part,s_data.old_rev,
	                    CtxRev,CtxName,CtxType);
    if ( (*CtxRev == 0) || (*CtxName == 0) || (*CtxType == 0) ) {
	printf("### Failed to get SIR_PDM_TABLE attrs of old part\n");
	goto wrapup;
    }
    
    // old stuff to the new
    SirVDUpdCMAttrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "ctx_rev",CtxRev);
    SirVDUpdCMAttrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "ctx_name",CtxName);
    SirVDUpdCMAttrs(s_data.new_cat,s_data.new_part,s_data.new_rev,
	           "ctx_type",CtxType);

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -----------------------------------------------------------
 * Check the AIM connection.  If it is not connected, connect it.
 * if it is connected, and a forceconn has been done, disconnect it
 * **/
static IGRstat checkAIMConnection(IGRint connect)
{
    VDASSERT_FN("checkAIMConnection");
    IGRstat retFlag = 0;

    IGRstat sts;
    IGRchar response_data[80];
    IGRint  response,status;
    IGRchar *errmsg = NULL;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    if (connect)
    {

	if(IsPmeEnabled() == FALSE)
	{
	    force_aim_login = AIMlogin();
#if 0
	    sts = CMAimConnect();
	    do
	    {
		ex$wait_for_input( response = &response,
			buffer = response_data,
			mode = EX_ALL_ASCII_MODE,
			byte = &status );
	    } while( response != EX_FORM_FINISHED );
#endif
	}
	if(IsPmeEnabled() == FALSE)
	{
	    UI_status("Not conencted to AIM.");
	    goto wrapup;
	}
	retFlag = 1;
	goto wrapup;
    }

    else
    {
	if(IsPmeEnabled() == TRUE)
	{
	    if(force_aim_login & 1)
	    {
		sts = POSTMAN_REQUEST_ON_CLIX( -2,  //CLIX_DISCONNECT
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

    }

    // done
    retFlag = 1;

wrapup:
    if (errmsg) free(&errmsg); errmsg = NULL;
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* -----------------------------------------------------------
 * Get the hull applicability string for the new part
 * Obsolete, use better routine for generating
 * hull app string 
 * **/
#if 0
static IGRstat getHullApplicabilityString(IGRchar *app_str)
{
    VDASSERT_FN("getHullApplicabilityString");
    IGRstat retFlag = 0;

    IGRstat sts;
    IGRint  file_key = 0;
    IGRchar *p;
    IGRchar buf[80];
    IGRchar bufa[80];
    IGRchar a_str[80];
    IGRint  i;

    VDpdmHullApp hulls;


    // arg check
    VDASSERTW(app_str); *app_str = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the file_key
    VDpdmGetFileKeyForCPR(s_data.new_cat,s_data.new_part,s_data.new_rev,&file_key);
    if (file_key < 1) goto wrapup;

    // get the list of applicable hulls for the part
    sts = VDpdmGetHullAppforFilekey(&file_key,&hulls);
    if (!(sts & 1)) goto wrapup;

    // set the app_str
    strcpy(a_str,"");
    for (i = 0; i < hulls.cnt; i++)
    {
	strcpy(bufa,hulls.hulls[i]);
	p = bufa;
	if (i == 0) sprintf(buf,"%s",p+3);
	else        sprintf(buf,",%s",p+3);
	strcat(a_str,buf);

	if (!strcmp(p+3,"28")) strcat(a_str,"AF");
    }

    if (*a_str == 0) goto wrapup;

    // set it
    strcpy(app_str,a_str);
    if (traceFlag) printf("### app_str <<%s>>\n",app_str);
	
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
#endif
/* ------------------------------------------------------------
 * Set the inbuf string for the postman request
 * **/
static IGRstat setInbufForRevMDC(char *inbuf,
				 int  *inlen)
{
    VDASSERT_FN("setInbufForRevMDC");
    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar hullAppStr[80];
    int  index,length;
    int  code;
    IGRchar buf[512];

    // arg check
    VDASSERTW(inbuf); *inbuf = 0;
    VDASSERTW(inlen); *inlen = 0;

    // get the hull applicability string
    VDPaimGetHullApp(s_data.new_cat,
                     s_data.new_part,
                     s_data.new_rev,
                     hullAppStr);
    if (*hullAppStr == 0) goto wrapup;

    // do it
    code = 136; /*VDP_CM_REVISE_MDC*/
    if (traceFlag) printf("VDP_CM_REVISE_MDC Code %d\n",code);

    index = 0;
    length = 0;
    memcpy( &inbuf[index], &code, sizeof(int));
    length += sizeof(int);
    index = length;

    /* inbuf cat-part-rev  */
    if (traceFlag) printf("Catalog '%s'\n",s_data.old_cat);
    strcpy( &inbuf[index], s_data.old_cat );
    length += strlen(s_data.old_cat) +1;
    index = length;

    if (traceFlag) printf("Part '%s'\n",s_data.old_part);
    strcpy( &inbuf[index], s_data.old_part );
    length += strlen(s_data.old_part) +1;
    index = length;

    if (traceFlag) printf("Old Rev '%s'\n",s_data.old_rev);
    strcpy( &inbuf[index], s_data.old_rev );
    length += strlen(s_data.old_rev) +1;
    index = length;

    /* DCC flag is needed for AIM to revise MDC with Minor design changes
     * when no ARs are selected.Send always "Y" to abe AIM able to revise */
    strcpy( &inbuf[index], "N" );
    length += strlen("N") +1;
    index = length;

    if (traceFlag) printf("New Rev '%s'\n",s_data.new_rev);
    strcpy( &inbuf[index], s_data.new_rev );
    length += strlen(s_data.new_rev) +1;
    index = length;

    //added for the CR#1793
    if (traceFlag) printf("New Desc '%s'\n",s_data.new_desc);
    strcpy( &inbuf[index], s_data.new_desc );
    length += strlen(s_data.new_desc) +1;
    index = length;

    //TLS added for the TR#4976
    if (traceFlag) printf("Hull App '%s'\n",hullAppStr);
    strcpy( &inbuf[index], hullAppStr );
    length += strlen(hullAppStr) +1;
    index = length;

    //if (*buf == 0) goto wrapup;
    if (length < 1) goto wrapup;

    // set it
    //strcpy(inbuf,buf);
    *inlen = length;

    // doRne
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n<<%d>>\n",
	                       ffn(),fn,retFlag,*inlen);
    return retFlag;
}

/* ------------------------------------------------------------
 * Revise the MDC in AIM
 * **/
static IGRstat reviseMDCinAIM(IGRchar *MDCrev)
{
    VDASSERT_FN("reviseMDCinAIM");
    IGRstat retFlag = 0;

    IGRstat sts;
    IGRchar hullAppStr[80];
    int  inlen, outlen, mfail;
    char inbuf[512], srerrmsg[70];
    char *outbuf = NULL;
    char *errmsg = 0;
    IGRint  nbItems, index;

    // arg check
    VDASSERTW(MDCrev);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // setup the inbuf string
    inlen = 0;
    sts = setInbufForRevMDC(inbuf,&inlen);
    if (!(sts & 1)) goto wrapup;

    // are we connected to AIM
    sts = checkAIMConnection(1);
    if (!(sts & 1)) goto wrapup;

    // make the postman request
    sts = POSTMAN_REQUEST_ON_CLIX(inlen,inbuf,&outlen,&outbuf,&mfail,&errmsg);
    if (sts != 0)
    {
	if(sts == 12345)
	{
	    	UI_status("AIM connection reset by server.");
  	 	printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
		strcpy(srerrmsg, "AIM connection reset by server. Please Disconnect and Re-Connect.");
        	ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
		UI_status("MDC WAS NOT REVISED.");
		printf("AIM connection reset by server. Please Disconnect and Re-Connect.\n");
		printf("MDC WAS NOT REVISED\n");
         	goto wrapup;
        }

	if(errmsg) printf("errmsg: %s\n ", errmsg );	

	printf("*** Could not revise MDC ***\n");
	
	UI_status("Could not Revise M D C.");
	goto wrapup;
    }

    if (mfail != 0 )
    {
	UI_status("An AIM Error Occurred. Contact AIM Administrator.");
       	printf("mfail = <%d>\n", mfail);
        if (errmsg == NULL) printf("No SIR Error Message\n");
        else                printf("SIR ERROR '%s'\n",errmsg);
	printf("*** Could not revise MDC ***\n");
	UI_status("Could not Revise M D C.");
	goto wrapup;
    }

    // set the mdcrev
    index = 0;
    memcpy( &nbItems, &outbuf[index], sizeof(IGRint) ); 
    index = index + sizeof(IGRint);   

    if(outbuf[0]!='\0')
    {
	strcpy(MDCrev, &outbuf[index] );
	index = index + strlen(MDCrev) + 1;
    }

    if (*MDCrev == 0) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    if (outbuf) {
	free(&outbuf);
	outbuf = NULL;
    }
    if (errmsg) {
	free(&errmsg);
	errmsg = NULL;
    }
    checkAIMConnection(0);
    return retFlag;
}   
    
/* -------------------------------------------------------------
 * Validate a part to see if the MDC in AIM should be revised.
 * **/
static IGRstat validatePartForRevMDC()
{
    VDASSERT_FN("validatePartForRevMDC");
    IGRstat retFlag = 0;

    IGRstat sts;
    IGRchar w_flow[20];
    IGRchar ARsel[10],CMmng[10],DCCsel[10],Mdc[10],IsSuper[10];

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // is the old part in the correct workflow
    if (traceFlag) printf("### CHECK: to see if old part is in correct w_flow\n");
    *w_flow = 0;
    CMget_wflow_name(s_data.old_cat,s_data.old_part,s_data.old_rev,w_flow);
    if (*w_flow == 0) goto wrapup;
    if(strcasecmp(w_flow, "Y")) goto wrapup; //part is not in correct workflow
    if (traceFlag) printf("### PASS: old part is in correct w_flow\n");

    // does the old part and new part have the same name
    if (traceFlag) printf("### CHECK: does old part name equal new\n");
    if (strcmp(s_data.old_part,s_data.new_part)) goto wrapup;
    if (traceFlag) printf("### PASS: old part = new part name\n");

    // check to see if the old part is cm managed, if it has an mdc, and
    // make sure it is not already superceded.
    sts = SrVDGetCMattrs(s_data.old_cat,s_data.old_part,s_data.old_rev,
	                 ARsel,CMmng,DCCsel,Mdc,IsSuper);
    if (sts) goto wrapup;


    // does it have an mdc
    if (traceFlag) printf("### CHECK: does old part have MDC\n");
    if (strcmp(Mdc, "Y")) goto wrapup;
    if (traceFlag) printf("### PASS: old part has MDC\n");

    // is it cm managed
    if (traceFlag) printf("### CHECK: Is old part CM managed\n");
    if (strcmp(CMmng, "Y")) goto wrapup;
    if (traceFlag) printf("### PASS: old part is CM managed\n");

    // is it superceded
    if (traceFlag) printf("### CHECK: Is old part already superceded\n");
    if(!strcasecmp(IsSuper, "Y"))
    {  
	printf("ERROR: Revising a Superceded file.\n");
	UI_status (" ERROR: Revising a Superceded file.");
	goto wrapup;
    }
    if (traceFlag) printf("### PASS: old part is not superceded\n");

    // done, file is OK for revise MDC
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

    

/* --------------------------------------------------------------
 * New PDM part is being added with the copy similar option
 * Need to revise the MDC in AIM if applicable.
 * **/
IGRstat AIMcmAddSimPart()
{
    VDASSERT_FN("AIMcmAddSimPart");
    IGRstat retFlag = 0;

    IGRstat sts;
    IGRchar MDCrev[20];

    __DBGpr_com("in AIMcmAddSimPart");
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // validate the part for MDC revision
    UI_status("Revising MDC in AIM");
    sts = validatePartForRevMDC();
    if (!(sts & 1)) goto wrapup;

    // make the postman request to revise MDC
    *MDCrev = 0;
    sts = reviseMDCinAIM(MDCrev);
    if (!(sts & 1)) 
    {
	if(sts == VDP_CAN_NOT_REVISE_CI)
	{
		UI_status("MDC not revised");
		printf("*** PDM part was created, MDC Failed to Revise ***\n");
		printf("*** Related AR's May Not Be in a Valid State ***\n");
		printf("*** Contact AIM Administrator ***\n");
		EX_error_box(FI_CURRENT_SCREEN,
		     "PDM Part Created, MDC Failed to Revise. Related AR's May Not Be In A Valid State. Contact AIM Administrator.",
		     "MDC REVISION FAILURE");
		goto wrapup;
	}
	else
	{
		UI_status("MDC not revised");
		printf("*** PDM part was created, MDC Failed to Revise ***\n");
		EX_error_box(FI_CURRENT_SCREEN,
		     "PDM Part Created, MDC Failed to Revise",
		     "MDC REVISION FAILURE");
		goto wrapup;
	}
    }

    // Add/Set attributes in PDM database
    sts = setSirPDMAttrs(MDCrev);
    if (!(sts & 1)) {
	UI_status("Update of SIR PDM attributes Failed");
	printf("*** PDM Part Created, MDC Revised ***\n");
	printf("*** Update of SIR PDM Attrs FAILED ***\n");
	EX_error_box(FI_CURRENT_SCREEN,
		     "PDM Part Created, MDC Revised, Update of Attrs FAILED",
		     "MDC REVISION FAILURE");
	goto wrapup;
    }
    
    // done
    retFlag = 1;
    UI_status("MDC Revised in AIM");

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
    
/* ---------------------------------------------------------------
 * New PDM part is being added without the copy similar option.
 * Need only to add some attributes to the sir PDM table.
 * **/
IGRstat AIMcmAddNewPart()
{
    VDASSERT_FN("AIMcmAddNewPart");
    IGRstat retFlag = 0;

    IGRchar w_flow[20];
    IGRstat sts;

    __DBGpr_com("in AIMcmAddNewPart");
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the workflow info of the old
    CMget_wflow_name(s_data.new_cat,s_data.new_part,s_data.new_rev,w_flow);

    // if Y, insert the data
    if(!strcasecmp(w_flow, "Y"))
    {
	sts = PDMInsertSirTable(s_data.new_cat,s_data.new_part,s_data.new_rev);
	if (sts) {
	    retFlag = 0;
	    goto wrapup;
	}
    }

    /* TLS 01/22/02 - Add the call to update the NFM attributes */ 
    sts = SrVDUpdCMattrs(s_data.new_cat, s_data.new_part,
                                s_data.new_rev, "p_incpartrpt", "N");
    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

// get the part description
static IGRstat getPartDescription()
{
    VDASSERT_FN("getPartDescription");
    IGRstat retFlag = 0;
    
    TVDrisInfo ris;
    
    // init
    VDrisInitInfo( &ris );

    // arg check
    VDASSERTW(*s_data.new_cat);
    VDASSERTW(*s_data.new_part);
    VDASSERTW(*s_data.new_rev);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // query
    sprintf(ris.sql,
	    "Select n_itemdesc from %s where %s='%s' and %s='%s';",
	    s_data.new_cat,
	    "n_itemname",s_data.new_part,
	    "n_itemrev" ,s_data.new_rev );

    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // set it
    strcpy(s_data.new_desc,ris.buf[0]);

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    VDrisFreeInfo( &ris );
    return retFlag;
}

/* -----------------------------------------------
 * Entry point function, called from PDUadd_part.c
 * Depending on the two modes, call AIMcmAddNewPart() or AIMcmAddSimPart()
 * ***/
IGRstat AIMcmAddPart(IGRint  new_mode,
	             IGRint  sim_mode,
		     IGRchar *old_catalog,
		     IGRchar *old_partid,
		     IGRchar *old_revision,
		     IGRchar *new_catalog,
		     IGRchar *new_partid,
		     IGRchar *new_revision)
{
    VDASSERT_FN("AIMcmAddPart");
    IGRstat retFlag = 0;
    IGRstat sts;
    
    __DBGpr_com("in AIMcmAddPart");
    memset(&s_data,0,sizeof(AIMpartData));
    // arg check
    VDASSERTW(new_catalog  && *new_catalog);
    VDASSERTW(new_partid   && *new_partid);
    VDASSERTW(new_revision && *new_revision);
    if (sim_mode)
    {
	VDASSERTW(old_catalog  && *old_catalog);
	VDASSERTW(old_partid   && *old_partid);
	VDASSERTW(old_revision && *old_revision);
    }

    // check for some possible bad data
    if (sim_mode)
    {
	if (strlen(old_catalog) > 80) {
	    printf("## Bad Old Catalog\n");
	    goto wrapup;
	}
    }

    // set the statics
    traceFlag = traceFlagx = VDdbgGetTraceFlag(AIM_CM_TRACE_ADD_PART);
    //traceFlag = traceFlagx = 1;

    strcpy(s_data.old_cat ,old_catalog);
    strcpy(s_data.old_part,old_partid);
    strcpy(s_data.old_rev ,old_revision);
    strcpy(s_data.new_cat ,new_catalog);
    strcpy(s_data.new_part,new_partid);
    strcpy(s_data.new_rev ,new_revision);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get new description, as an added bonus, if this doesn't work, then
    // the part is not yet created at this point.
    sts = getPartDescription();
    if (!(sts & 1)) goto wrapup;

    if (traceFlag) 
    {
	if (sim_mode) printf("### old CPR: %s %s %s\n",
		             s_data.old_cat,s_data.old_part,s_data.old_rev);
	printf("### new CPR: %s %s %s\n",
		s_data.new_cat,s_data.new_part,s_data.new_rev);
    }

    // what to do
    __DBGpr_com("determine what to do");
    if (new_mode) retFlag = AIMcmAddNewPart();
    if (sim_mode) retFlag = AIMcmAddSimPart();

    // nothing else to do
wrapup:
    // clear the struct
    memset(&s_data,0,sizeof(AIMpartData));
    return retFlag;
}
