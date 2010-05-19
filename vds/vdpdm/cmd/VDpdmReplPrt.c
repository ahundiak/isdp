 /* $Id: VDpdmReplPrt.c,v 1.9 2002/05/08 14:47:01 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmReplPrt.c
 *
 * Description: Replace Part GUI
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/18/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmReplPrt.c");

typedef struct {
    IGRchar   app_cfg[4];
    IGRchar   catalog[80];
    IGRchar   part   [80];
    IGRchar   rev_old[80];
    IGRchar   descr  [240];
    IGRchar   rev_new[80];
    IGRchar   view   [80];
    IGRchar   uid_old[80];
    IGRint    itno_old;
    IGRchar   uid_new[80];
    IGRint    itno_new;
    TGRid     part_id;
    IGRchar   action[80];
    IGRint    filekey;
}  refData;

typedef struct {
    TVDpdmInfo   info;
    VDpdmHullApp actShips;
    IGRchar      descr[240];
    IGRint       catno;
    IGRint       itemno;
    Form         form;
    IGRstat      loop;
}  actData;

static refData     ref;
static actData     act;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* ----------------------------------------------
 * Define the steps to replace a part for use in rollback
 * ***/
#define VDPDM_REPL_PART_RENAME_CS         1
#define VDPDM_REPL_PART_UPDATE_GRPART_UID 2
#define VDPDM_REPL_PART_UPDATE_GRPART_REV 3

/* ----------------------------------------------
 * Given a part_id and the row on the form, set the value on the form
 * ***/
static IGRstat setRowPartID(TGRid  *partID,
	                    IGRint row)
{
    VDASSERT_FN("setRowPartID");
    IGRstat retFlag = 0;
    IGRchar part_id[240];

    VDASSERTW(partID->objid != NULL_OBJID);
    VDASSERTW(act.form);
    
    // set the text
    sprintf(part_id,"%d,%d",partID->osnum,partID->objid);

    // put it on the form
    VDfrmSetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_PART_ID,part_id);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}

/* ----------------------------------------------
 * Given a row on the form, get the part_id
 * ***/
static IGRstat getRowPartID(TGRid  *partID,
	                    IGRint row)
{
    VDASSERT_FN("getRowPartID");
    IGRstat retFlag = 0;
    IGRchar part_id[240];
    IGRchar *p;
    IGRchar osnum[240];
    IGRchar objid[240];

    VDASSERTW(partID); partID->objid = NULL_OBJID;
    VDASSERTW(act.form);
    *part_id = 0;
    *osnum   = 0;
    *objid   = 0;
    
    // get it from the form
    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_PART_ID,part_id);
    VDASSERTW(*part_id != 0);

    // decipher the text
    p = strchr(part_id,',');
    if (p) {
	*p = 0;
	strcpy(osnum,part_id);
	strcpy(objid,p+1);
    }
    else goto wrapup;

    // set them
    partID->osnum = atoi(osnum);
    partID->objid = atoi(objid);

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}


/* ----------------------------------------------
 * rollback stuff that has already been done
 * **/
static void rollbackPart(IGRint step)
{
    VDASSERT_FN("rollbackPart");

    switch(step) {

      case VDPDM_REPL_PART_RENAME_CS:
	  // nothing to rollback if this failed
	  goto wrapup;

      case VDPDM_REPL_PART_UPDATE_GRPART_UID:
	  // rollback RENAME
	  VDpdmRenameRefFileCS(ref.uid_new,ref.uid_old);
	  goto wrapup;

      case VDPDM_REPL_PART_UPDATE_GRPART_REV:
	  // rollback uid
	  VDpdmUpdateGRpartUID(&ref.part_id,ref.uid_old);
	  // rollback RENAME
	  VDpdmRenameRefFileCS(ref.uid_new,ref.uid_old);
	  goto wrapup;

    } // end of switch

    // done
wrapup:
    return;
}

/* -----------------------------------------------
 * Fill the refData structure from the information on the form
 * **/
static IGRstat fillRefDataStructure(IGRint row)
{
    VDASSERT_FN("fillRefDataStructure");
    IGRstat retFlag = 0;

    IGRint gadget = VDPDM_REPL_PART_F_REF;

    IGRchar catNo   [80];
    IGRchar itmNo   [80];
    IGRchar itmNoNew[80];
    IGRchar citNo   [80];

    VDASSERTW(act.form);

    // init
    memset(&ref,0,sizeof(refData));

    // fill it
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_CAT,       ref.catalog);
    if (*ref.catalog == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_PART,      ref.part);
    if (*ref.part == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_REV_OLD,   ref.rev_old);
    if (*ref.rev_old == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_DESCR,     ref.descr);
    if (*ref.descr == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_REV_NEW,   ref.rev_new);
    if (*ref.rev_new == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_UID_OLD,   ref.uid_old);
    if (*ref.uid_old == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_UID_NEW,   ref.uid_new);
    if (*ref.uid_new == 0) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_VIEW,      ref.view);
    if (*ref.view == 0) goto wrapup;
    
    getRowPartID(&ref.part_id,row);
    if (ref.part_id.objid == NULL_OBJID) goto wrapup;
    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_ACTION,      ref.action);
    if (*ref.action == 0) goto wrapup;
    
    // validate some of the data
    // rev_new should not eqaul 'NULL'
    if (!strcmp(ref.rev_new,"NULL")) goto wrapup;

    // rev_new should not eqal rev_old
    if (!strcmp(ref.rev_new,ref.rev_old)) goto wrapup;

    // done, have the data, and the data is good
    retFlag = 1;

wrapup:
    return retFlag;
}
    
/* -----------------------------------------------
 * The working function to replace the part
 * **/
static IGRstat replacePart(IGRint row)
{
    VDASSERT_FN("replacePart");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar msg[80];


    // fill the data refData structure from the information on the form
    if (traceFlag) printf("### fill data structure\n");
    sts = fillRefDataStructure(row);
    if (!(sts & 1)) {
	sprintf(msg,"<%s %s %s> Not Replaced",ref.catalog,ref.part,ref.rev_old);
	UI_status(msg);
	goto wrapup;
    }

    if (traceFlag) printf("### ID:(%d,%d) REV_NEW: %s, UID_NEW<OLD>: %s<%s>\n",
	                   ref.part_id.osnum,ref.part_id.objid,ref.rev_new,ref.uid_new,ref.uid_old);

    // Verify that the check out file names are the same
    if (traceFlag) printf("### verify COfile\n");
    sts = VDpdmIsCOFileNameEqual(ref.catalog,ref.part,ref.rev_old,ref.rev_new);
    if (!(sts & 1)) {
	strcpy(msg,"Check Out filenames are Not equal, part not replaced");
	UI_status(msg);
	goto wrapup;
    }

    if (!strcmp(ref.action,VDPDM_RE_PRT_ACTION_NONE)) {
	// do nothing
	goto wrapup;
    }

    if (!strcmp(ref.action,VDPDM_RE_PRT_ACTION_DEL)) {
	// delete the part
	//VDpdmDeletePdmPart(&ref.part_id);
    }

    if (!strcmp(ref.action,VDPDM_RE_PRT_ACTION_REV)) {
	
	// rename the CS
	sts = VDpdmRenameRefFileCS(ref.uid_old,ref.uid_new);
	if (!(sts & 1)) {
	    strcpy(msg,"Rename of CS failed, attempting rollback...");
	    rollbackPart(VDPDM_REPL_PART_RENAME_CS);
	    UI_status(msg);
	    goto wrapup;
	}

	// edit the usage_id attribute
	sts = VDpdmUpdateGRpartUID(&ref.part_id,ref.uid_new);
	if (!(sts & 1)) {
	    strcpy(msg,"Update of GRpartUID failed, attempting rollback...");
	    rollbackPart(VDPDM_REPL_PART_UPDATE_GRPART_UID);
	    UI_status(msg);
	    goto wrapup;
	}

	// rev the part
	sts = VDpdmUpdateGRpartRev(&ref.part_id,ref.rev_new);
	if (!(sts & 1)) {
	    strcpy(msg,"Update of GRpartRev failed, attempting rollback...");
	    rollbackPart(VDPDM_REPL_PART_UPDATE_GRPART_REV);
	    UI_status(msg);
	    goto wrapup;
	}
    }  // end of rev action

    if (!strcmp(ref.action,VDPDM_RE_PRT_ACTION_UID)) {

	// rename the CS
	sts = VDpdmRenameRefFileCS(ref.uid_old,ref.uid_new);
	if (!(sts & 1)) {
	    strcpy(msg,"Rename of CS failed, attempting rollback...");
	    rollbackPart(VDPDM_REPL_PART_RENAME_CS);
	    UI_status(msg);
	    goto wrapup;
	}

	// edit the usage_id attribute
	sts = VDpdmUpdateGRpartUID(&ref.part_id,ref.uid_new);
	if (!(sts & 1)) {
	    strcpy(msg,"Update of GRpartUID failed, attempting rollback...");
	    rollbackPart(VDPDM_REPL_PART_UPDATE_GRPART_UID);
	    UI_status(msg);
	    goto wrapup;
	}
    }
	
    // completed
    retFlag = 1;

wrapup:
    return retFlag;
}

/* -----------------------------------------------
 * Form checked off, start replacing
 * **/
static IGRstat notifyDoit()
{
    VDASSERT_FN("notifyDoit");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  i, numrows;

    VDASSERTW(act.form);

    // get the number for rows
    VDfrmGetNumRows(act.form,VDPDM_REPL_PART_F_REF,&numrows,NULL,NULL);
    if (numrows < 1) goto wrapup;

    // run through the list and do it
    for (i = 0; i < numrows; i++) {
	sts = replacePart(i);
	if (sts) retFlag = 1;   /* only one has to be changed for a success  */
    }

    // let the user know that this part should be saved and checked in
    if (retFlag) {
	VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,"Parts Replaced");
	EX_error_box(FI_CURRENT_SCREEN,
		     "Save, Checkin, then Retrieve this Part",
		     "To see Replaced Part(s)" );
    }

    // done
wrapup:
    return retFlag;
}

/* -----------------------------------------------
 * Generates the new usage id based on the old uid and the new rev
 * **/
static IGRstat getNewUsageID(IGRint  row)
{
    VDASSERT_FN("getNewUsageID");

    IGRstat retFlag = 0;
    IGRchar *p;
    IGRchar buf[80];
    IGRint  gadget = VDPDM_REPL_PART_F_REF;

    VDASSERTW(act.form);
    
    // get the uid_old, and the new rev
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_UID_OLD,ref.uid_old);
    if (*ref.uid_old == 0) goto wrapup;
	    
    VDfrmGetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_REV_NEW,ref.rev_new);
    if (*ref.rev_new == 0) goto wrapup;
    
    //printf("UID_OLD: %s\n",ref.uid_old);
    // do it
    strcpy(buf,ref.uid_old);
    p = strchr(buf,' ');
    if (p) {
	*p = 0;
	strcpy(buf,p+1);
    }
    p = strchr(buf,' ');
    if (p) {
	*p = 0;
	strcpy(buf,p+1);
    }
    

    // set the uid_new = part rev_new buf
    sprintf(ref.uid_new,"%s %s %s",ref.part,ref.rev_new,buf);
    if (*ref.uid_new == 0) goto wrapup;

    VDfrmSetfText(act.form,gadget,row,VDPDM_REPL_PART_REF_COLI_UID_NEW,ref.uid_new);
    
    // done
    retFlag = 1;

wrapup:
    //printf("UID_NEW: %s\n",ref.uid_new);
    return retFlag;
}
	
#if 0
/* ------------------------------------------------
 * Check to see if the view of the current part is available for the new revision of the same part.
 * ***/
static IGRstat isViewAvailable(IGRchar *view)
{
    VDASSERT_FN("isViewAvailable");
    IGRstat retFlag = 0;

    TVDrisInfo  ris;

    // Init, arg check
    VDrisInitInfo( &ris );
    VDASSERTW(*view != 0);
    VDASSERTW(*ref.catalog != 0);
    VDASSERTW(ref.itno_new > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,view);

    // build the sql
    sprintf(ris.sql,
	    "Select * from v_%s where %s=%d and %s='%s';",
	    ref.catalog, "n_itemno", ref.itno_new, "p_viewname", view);

    if (traceFlag) printf("### SQL: <%s>\n",ris.sql);

    // query it
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;

    // done, found one
    retFlag = 1;

wrapup:
    VDrisFreeInfo( &ris );
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}
#endif

/* ------------------------------------------------
 * Set some actions for related parts.  Related parts are those with the same catalog, part, and
 * revision as the one selected.  The possible actions are defined in VDpdmDef.h, and listed below.
 * This action will tell us what to do when the form is checked off.
 * #define VDPDM_RE_PRT_ACTION_NONE               "0"
 * #define VDPDM_RE_PRT_ACTION_REV                "1"
 * #define VDPDM_RE_PRT_ACTION_UID                "2"
 * #define VDPDM_RE_PRT_ACTION_DEL                "3"
 * **/
static void setUpdateActionsForRelatedParts(IGRint row)
{
    VDASSERT_FN("setUpdateActionsForRelatedParts");

    IGRint  i, numrows;
    IGRint  at_least_one = 0;
    IGRchar cat[80], prt[80], rev[80], view[80];
    IGRchar buf[80];
    IGRint  gadget = VDPDM_REPL_PART_F_REF;

    VDASSERTW(act.form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // get the number of rows
    VDfrmGetNumRows(act.form,gadget,&numrows,NULL,NULL);
    if (numrows < 1) goto wrapup;
    if (traceFlag) printf("### NUMROWS: %d\n",numrows);

    // loop through to find related parts
    for (i = 0; i < numrows; i++) {

	// get the data
	VDfrmGetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_CAT,    cat);
	VDfrmGetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_PART,   prt);
	VDfrmGetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_REV_OLD,rev);
	VDfrmGetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_VIEW,   view);

	if (traceFlag) printf("### CAT: %s, PRT: %s, REV: %s\n",cat,prt,rev);
	// Do some checks to set the correct action
	
	// if cat, prt, rev = the one selected, then something will change
	if ( (!strcmp(ref.catalog,cat)) &&
	     (!strcmp(ref.part   ,prt)) &&
	     (!strcmp(ref.rev_old,rev)) ) {

	    if (traceFlag) printf("### Similar Part\n");

	    // The part is related, is the view available in the new rev
	    if (traceFlag) printf("### View (%s) is available\n",view);

	    // view is available, now decide to revise the part, or just
	    // change the uid attribute and CS name, must have at least one to change.
	    if ( at_least_one ) strcpy(ref.action,VDPDM_RE_PRT_ACTION_UID);
	    else {
		strcpy(ref.action,VDPDM_RE_PRT_ACTION_REV);
		at_least_one = 1;
	    }

	    // set the information on the form for all related parts
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_REV_NEW,ref.rev_new);

	    // set the new usage id
	    getNewUsageID(i);
	    sprintf(buf,"%d",ref.itno_new);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_ITNO_NEW,buf);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_ACTION,  ref.action);
	    if (traceFlag) printf("### ACTION: %s\n",ref.action);

	}   // end of related parts

    }  // end of for loop

    // done
    
wrapup:
    return;
}
	
/* ------------------------------------------------
 * pop up subform to get new revision
 * **/
static IGRstat getNewRevision()
{
    VDASSERT_FN("getNewRevision");

    IGRint row, sel;
    IGRstat sts;

    TVDpdmInfo   info;
    IGRchar      buf[80];
    IGRchar      app_rev[80];
    IGRchar      fKey[80];
    IGRchar      msg [128];
    IGRchar      itno_old[80];

    VDASSERTW(act.form);

    *app_rev = 0;
    *fKey    = 0;
    
    // get the selected record
    VDfrmGetActiveRow(act.form,VDPDM_REPL_PART_F_REF,&row,NULL);

    // is it selected
    VDfrmGetSelect(act.form,VDPDM_REPL_PART_F_REF,row,0,&sel);
    if (!sel) goto wrapup;

    // get the catalog, part, and uid_old
    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_CAT,ref.catalog);
    if (*ref.catalog == 0) goto wrapup;

    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_PART,ref.part);
    if (*ref.part == 0) goto wrapup;

    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_REV_OLD,ref.rev_old);
    if (*ref.rev_old == 0) goto wrapup;
    
    //filekey
    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_FILEKEY,fKey);
    if (*fKey == 0) goto wrapup;
    ref.filekey = atoi(fKey);
    
    // get the app_cfg flag
    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,VDPDM_REPL_PART_REF_COLI_APPR,ref.app_cfg);
    if (!strcmp(ref.app_cfg,"*")) {
	// find the recommended approved rev
	VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		      "Determining Approved Configuration Revision ...");
	sts = VDpdmGetApprCfgRevision(&act.actShips,&ref.filekey,app_rev);
	if (!(sts & 1)) strcpy(app_rev,"NULL");
	if (traceFlag) printf("app rev <%s>\n",app_rev);
    }
    else strcpy(app_rev,"NULL");

    // pop up the new rev sub-form to get the new revision
    VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		      "Select New Revision, or Accept Approved revision");

    VDpdmCmdGetNewRev(act.info.filekey,ref.catalog,ref.part,ref.rev_old,
	                                            app_rev,ref.rev_new);
    if (*ref.rev_new == 0) goto wrapup;
    
    // get the new item number
    strcpy(info.catalog,ref.catalog);
    strcpy(info.part,   ref.part);
    strcpy(info.rev,    ref.rev_new);
    VDpdmGetItemNo(&info, &ref.itno_new);
    if (ref.itno_new < 1) goto wrapup;

    // compare the views of old vs new, if they are equal, then set actions for related
    // otherwise, set this action back to none, and/or set rev back to NULL.
    // set the actions

    // need ref.itno_old from form
    *itno_old = 0;
    VDfrmGetfText(act.form,VDPDM_REPL_PART_F_REF,row,
	                   VDPDM_REPL_PART_REF_COLI_ITNO_OLD,itno_old);
    if (*itno_old == 0) goto wrapup;
    ref.itno_old = atoi(itno_old);
    if (ref.itno_old < 1) goto wrapup;
    
    if ( !VDpdmIsViewsAvailable(ref.catalog, &ref.itno_old, &ref.itno_new) ) {
	//put up a message that says so, and set the ref.action to NONE.
	strcpy(ref.action,VDPDM_RE_PRT_ACTION_NONE);
	sprintf(msg,"PDUviews of %s %s\nDO NOT MATCH\nPDUviews of %s %s",
		ref.part,ref.rev_old,ref.part,ref.rev_new);
	printf("## msg:\n%s\n",msg);
	strcpy(ref.rev_new,"NULL");
	VDfrmSetfText(act.form,VDPDM_REPL_PART_F_REF,row,
		               VDPDM_REPL_PART_REF_COLI_REV_NEW,ref.rev_new);
	EX_error_box(FI_CURRENT_SCREEN,msg,"PART WILL NOT BE REPLACED");
	
    }
    else setUpdateActionsForRelatedParts(row);

    VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		      "Select Part to replace or Accept form");

    // done
wrapup:
    return 1;
}

/* ------------------------------------------
 * Get the reference data given a part id
 * ***/
static IGRstat getRefDataForPartID(TGRid *part_id)
{
    VDASSERT_FN("getRefDataForPartID");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar *p;

    TVDpdmInfo  info;

    // arg check
    VDASSERTW(part_id->objid != NULL_OBJID);

    // clear the static refData structure
    memset(&ref,0,sizeof(refData));

    // CATALOG
    sts = VDpdmGetAttrForPartID(part_id,"CATALOG",ref.catalog);
    if (!(sts & 1)) goto wrapup;
    strcpy(info.catalog,ref.catalog);

    // PART
    sts = VDpdmGetAttrForPartID(part_id,"NUMBER",ref.part);
    if (!(sts & 1)) goto wrapup;
    strcpy(info.part,ref.part);

    // REVISION
    sts = VDpdmGetAttrForPartID(part_id,"REVISION",ref.rev_old);
    if (!(sts & 1)) goto wrapup;
    strcpy(info.rev,ref.rev_old);

    // usage_id
    sts = VDpdmGetAttrForPartID(part_id,"usage_id",ref.uid_old);
    if (!(sts & 1)) goto wrapup;

    	// clean out any " from usage id
	p = 0;
	while (p = strchr(ref.uid_old,'"'))
	    strcpy(p,p+1);
	
    // view_name
    sts = VDpdmGetAttrForPartID(part_id,"view_name",ref.view);
    if (!(sts & 1)) goto wrapup;
    
    	// clean out any " from view name
	p = 0;
	while (p = strchr(ref.view,'"'))
	    strcpy(p,p+1);

    // old item number
    VDpdmGetItemNo(&info, &ref.itno_old);
    if (ref.itno_old < 1) goto wrapup;

    // description
    VDpdmGetPartDescription(ref.catalog,ref.itno_old,ref.descr);
    if (*ref.descr == 0) goto wrapup;

    // action
    strcpy(ref.action,VDPDM_RE_PRT_ACTION_NONE);

    // filekey
    VDpdmGetFileKeyForCPR(ref.catalog,ref.part,ref.rev_old,&ref.filekey);
    VDASSERTW(ref.filekey > 0);

    // does the reference file match approved config
    if (!(VDpdmCompareCfgRefToActive( &act.actShips, 
		                      &ref.filekey,
				       ref.rev_old) )) {
	strcpy(ref.app_cfg,"*");
    }
    else strcpy(ref.app_cfg," ");
    
    // done
    retFlag = 1;

wrapup:
    return retFlag;
}
    
/* ------------------------------------------
 * Fill the reference Part fields
 * **/
static void fillRefPartFields()
{
    VDASSERT_FN("fillRefPartFields");
    IGRstat  sts;

    IGRchar     itno[80];
    IGRchar     filekey[80];

    TGRid       part_ids[20000];
    IGRint      part_cnt = 0;

    IGRint      i, j;
    IGRint      gadget = VDPDM_REPL_PART_F_REF;

    VDASSERTW(act.form);

    // call the new get parts function here
    VDpdmGetPDMPartIDs(part_ids,&part_cnt);
    if (part_cnt < 1) goto wrapup;

    // status on form
    VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		  "All reference files match approved configuration");
    // fill the form
    for (i = 0; i < part_cnt; i++) {
        sts = getRefDataForPartID(&part_ids[i]);

	if (sts & 1) {
	    setRowPartID(&part_ids[i],i);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_APPR,    ref.app_cfg);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_CAT,     ref.catalog);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_PART,    ref.part);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_REV_OLD, ref.rev_old);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_DESCR,   ref.descr);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_REV_NEW, "NULL");
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_UID_OLD, ref.uid_old);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_UID_NEW, "NULL");
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_VIEW,    ref.view);
	    sprintf(itno,"%d",ref.itno_old);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_ITNO_OLD,itno);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_ITNO_NEW,"NULL");
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_ACTION,  ref.action);
	    sprintf(filekey,"%d",ref.filekey);
	    VDfrmSetfText(act.form,gadget,i,VDPDM_REPL_PART_REF_COLI_FILEKEY, filekey);

	    // status on form
	    if (!strcmp(ref.app_cfg,"*")) 
		VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
			      "* Denotes Reference files that do not match approved configuration");
	}
    }

    // done
wrapup:
    return;
}

/* -------------------------------------------
 * Fill the Active Part fields
 * **/
static void fillActPartFields()
{
    VDASSERT_FN("fillActPartFields");

    VDASSERTW(act.form);

    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // catalog
    VDfrmSetfText(act.form,VDPDM_REPL_PART_F_ACT,0,
	          VDPDM_REPL_PART_ACT_COLI_CAT,act.info.catalog);

    // part
    VDfrmSetfText(act.form,VDPDM_REPL_PART_F_ACT,0,
	          VDPDM_REPL_PART_ACT_COLI_PART,act.info.part);

    // revision
    VDfrmSetfText(act.form,VDPDM_REPL_PART_F_ACT,0,
	          VDPDM_REPL_PART_ACT_COLI_REV,act.info.rev);

    // desrciption
    VDpdmGetPartDescription(act.info.catalog,act.itemno,act.descr);
    VDASSERTW(*act.descr != 0);
    
    VDfrmSetfText(act.form,VDPDM_REPL_PART_F_ACT,0,
	          VDPDM_REPL_PART_ACT_COLI_DESCR,act.descr);

    // done
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}

/* ----------------------------------------
 * Initialize the form settings
 * **/
static void initReplPartFormSettings()
{
    VDASSERT_FN("initReplPartFormSettings");

    IGRstat sts;
    VDosnum cur_os = OM_K_NOT_AN_OS;

    VDASSERTW(act.form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    VIg_enable(act.form,FI_ACCEPT);
      
    // status on form
    VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		 "Validating Approved Configuration for reference files...");
    
    // get the current OS, and pdmInfo
    VDosGetCurrentOS(&cur_os);
    if (cur_os == OM_K_NOT_AN_OS) goto wrapup;

    // get pdmInfo for active part
    sts = VDpdmGetPdmInfo(cur_os,&act.info);
    if (!(sts & 1)) goto wrapup;

    // get the catalog no
    VDpdmGetCatalogNo(act.info.catalog, &act.catno);
    VDASSERTW(act.catno > 0);

    // get the item no from the catalog
    VDpdmGetItemNo(&act.info, &act.itemno);
    VDASSERTW(act.itemno > 0);

    // get the list of approved config ships for the active part
    if (traceFlag) printf("### Getting filekey\n");
    VDpdmGetApprCfgforFilekey(&act.info.filekey,&act.actShips);
    if (traceFlag) printf("### Got filekey\n");

    // Fill the active part fields
    fillActPartFields();

    // Fill the reference part fields
    fillRefPartFields();
    
    // check if part is checked out
    sts = VDpdmIsPartCheckedOut(&act.info, act.catno, act.itemno);
    if (!(sts & 1)) {
	VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		      "Part is not checked out, Cannot Replace Parts");
	VIg_disable(act.form,FI_ACCEPT);
    }

    // done
wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return;
}
    

/* ----------------------------------------
 * form notification routine
 * ***/
static IGRint notifyForm(IGRint      f_label,
	                 IGRint      g_label,
			 IGRdouble   value,
			 Form        form)
{
    VDASSERT_FN("notifyForm");

    IGRstat retFlag = 1;
    IGRstat sts;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    VDASSERTW(act.form);

    // switch on gadget
    switch(g_label) {

      case FI_RESET:
	  initReplPartFormSettings();
	  break;
      
      case FI_CANCEL:
	  VDfrmDeleteForm( act.form, 1);
	  act.form = NULL;
	  act.loop = 0;
	  break;

      case VDPDM_REPL_PART_F_REF:
	  sts = getNewRevision();
	  break;
      
      case FI_ACCEPT:
	  sts = notifyDoit();
	  if (!(sts & 1)) {
	      VDfrmSetgText(act.form,VDPDM_REPL_PART_STATUS,
		      "Replace Failed For All Parts");
	      goto wrapup;
	  }

	  VDfrmDeleteForm( act.form, 1 );
	  act.form = NULL;
	  act.loop = 0;

	  // force a retrieve and save = y
	  break;

    }

wrapup:
    return retFlag;
}

/* -----------------------------------------------
 * Loop on events
 */
static void loopReplPartForm()
{
  VDASSERT_FN("loopReplPartForm");
  IGRstat sts;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(act.form);
  
  // Loop until form told to break out
  act.loop = 1;
  while(act.loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
 wrapup:
  return;
}

/* ---------------------------------------------
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmInitReplPart()
{
    VDASSERT_FN("VDpdmInitReplPart");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_REPL_PART);

    // should not be called again
    VDASSERTW(!act.form);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // statics
    memset(&ref,0,sizeof(refData));
    memset(&act,0,sizeof(actData));
    act.loop = 1;

    // wakeup the form
    sts = VDfrmNewForm(VDPDM_REPL_PART_F_NUM,VDPDM_REPL_PART_F_NAME,
	               notifyForm,0,&act.form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( act.form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // Initialize the form settings.
    initReplPartFormSettings();
    
    // loop on events
    loopReplPartForm();



wrapup:
    return 0;

}
