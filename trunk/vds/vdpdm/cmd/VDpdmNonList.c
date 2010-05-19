 /* $Id: VDpdmNonList.c,v 1.6 2001/10/03 14:03:58 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmNonList.c
 *
 * Description: Called from vdpdm/func/VDpdmStartup.c.  Form controller for
 *              Displaying list of non-compliant reference files.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmNonList.c,v $
 *      Revision 1.6  2001/10/03 14:03:58  jdsauby
 *      JTS MP CR 5527
 *
 *      Revision 1.5  2001/07/16 13:52:57  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.4  2001/04/12 20:41:34  jdsauby
 *      sp 11
 *
 *      Revision 1.3  2001/03/08 14:39:31  jdsauby
 *      Re - organization of VDpdm.h
 *
 *      Revision 1.2  2001/02/21 21:57:49  jdsauby
 *      Just keeping the server up to date
 *
 *      Revision 1.1  2001/02/21 12:59:52  jdsauby
 *      CR4088
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmNonList.c");

/* -------------------------------------------
 * Static variables for sharing information within
 * this file.
 * ***/
static TVDpdmInfo    s_actInfo;   /* pdmInfo of active part         */
static VDpdmHullApp  s_actShips;  /* approved hulls for active part */
static TVDpdmRefList s_nonList;   /* non compliant reflist          */
static IGRstat       loop;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;


/* ------------------------------------------
 * Write file containing information shown on form
 * ***/
static IGRstat notifyWriteFile( Form form )
{
    VDASSERT_FN("notifyWriteFile");

    IGRstat retFlag = 0;
    IGRstat sts;

    IGRchar writefile[128];
    IGRint  i;

    FILE *file = NULL;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // init
    writefile[0] = '\0';

    // get the filename
    VDfrmGetgText( form, VDPDM_NON_LIST_G_WRITE_FILE, writefile );
    if (writefile[0] == '\0') goto wrapup;

    // open the file
    file = fopen(writefile,"wt");
    if (file == NULL) file = stdout;


    // Write file header
    fprintf(file,"Active Part Information:\n"
	         "     Catalog : %s\n"
		 "     Part    : %s\n"
		 "     Revision: %s\n"
		 "     Filename: %s\n"
		 "     Filekey : %d\n",
		 s_actInfo.catalog,s_actInfo.part,s_actInfo.rev,
		 s_actInfo.filename,s_actInfo.filekey );
    
    // Write the active file approved hulls
    fprintf(file,
	    "Active file <%s> is Approved for the following hulls:\n",
	    s_actInfo.filename );
    for (i = 0; i < s_actShips.cnt; i++) {
	fprintf(file,"     %s\n",s_actShips.hulls[i]);
    }

    // Write the list of non compliant reference files
    fprintf(file,
	    "The following reference files do not match the approved\n"
	    "hull configuration of the active file <%s>\n",s_actInfo.filename );
    fprintf(file,
	    "%-20s %-20s %-4s %-24s %-12s %-12s\n",
	    "Catalog","Part","Rev","Filename","Hull Cfg","Hull App");

    // better just get this off the form
    for (i = 0; i < s_nonList.cnt; i++) {
	fprintf(file,
		"%-20s %-20s %-4s %-24s %d\n",
		s_nonList.infos[i].catalog, s_nonList.infos[i].part,
		s_nonList.infos[i].rev, s_nonList.infos[i].filename,
		s_nonList.infos[i].filekey);
    }
    

    // done
    retFlag = 1;

wrapup:
    if ((file) && (file != stdout)) fclose(file);
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* ----------------------------------------
 * Set the test in all of the form gadgets
 * ***/
static IGRstat initNonListFormValues( Form form )
{
    VDASSERT_FN("initNonListFormValues");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar fkey[80];
    IGRchar writefile[80];
    IGRint  i;

    VDASSERTW(form);
    //VDASSERTW(*actInfo->catalog != 0);
    //VDASSERTW(actShips->cnt > 0);
    //VDASSERTW(nonList->cnt > 0);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // Set the active file info stuff
    // Active Catalog
    VDfrmSetgText(form, VDPDM_NON_LIST_G_ACT_CATALOG, s_actInfo.catalog);

    // Active Part
    VDfrmSetgText(form, VDPDM_NON_LIST_G_ACT_PART, s_actInfo.part);

    // Active Rev
    VDfrmSetgText(form, VDPDM_NON_LIST_G_ACT_REV, s_actInfo.rev);

    // Active Filename
    VDfrmSetgText(form, VDPDM_NON_LIST_G_ACT_FILENAME, s_actInfo.filename);

    // Active Filekey
    sprintf(fkey,"%d",s_actInfo.filekey);
    VDfrmSetgText(form, VDPDM_NON_LIST_G_ACT_FILEKEY, fkey);

    // Write File
    sprintf(writefile,"%s.ref",s_actInfo.part);
    VDfrmSetgText(form, VDPDM_NON_LIST_G_WRITE_FILE, writefile);

    // Approved Hulls
    for (i = 0; i < s_actShips.cnt; i++) {
	VDfrmSetfText(form, VDPDM_NON_LIST_G_ACT_APPR_HULLS, i, 0, s_actShips.hulls[i]);
    }

    // Set the non compliant ref list stuff
    for (i = 0; i < s_nonList.cnt; i++) {
	// catalog
	VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		      VDPDM_NON_LIST_C_NON_LIST_CATALOG, s_nonList.infos[i].catalog);
	
	// part
	VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		      VDPDM_NON_LIST_C_NON_LIST_PART, s_nonList.infos[i].part);
	
	// rev
	VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		      VDPDM_NON_LIST_C_NON_LIST_REV, s_nonList.infos[i].rev);
	
	// filename
	VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		      VDPDM_NON_LIST_C_NON_LIST_FILENAME, s_nonList.infos[i].filename);
	
	// set the hcfg and hap
	sprintf(fkey,"%d",s_nonList.infos[i].filekey);

	if (VDpdmIsShipApplicabilityValid(&s_actInfo.filekey,&s_nonList.infos[i].filekey))
	{
	    VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		      VDPDM_NON_LIST_C_NON_LIST_HAP, "YES");
	}
	
	else 
	{
	    VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		      VDPDM_NON_LIST_C_NON_LIST_HAP, "NO");
	}
	
	if (!VDpdmCompareCfgRefToActive(&s_actShips,
		                        &s_nonList.infos[i].filekey,
					s_nonList.infos[i].rev))
	{

	    VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		    VDPDM_NON_LIST_C_NON_LIST_HCFG, "NO");
	}
	else 
	{
	    VDfrmSetfText(form, VDPDM_NON_LIST_G_NON_LIST, i,
		    VDPDM_NON_LIST_C_NON_LIST_HCFG, "YES");
	}
    }

    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
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

    switch(g_label) {

      case FI_CANCEL:
	  VDfrmDeleteForm( form, 0 );
	  VDpdmFreeRefList( &s_nonList );
	  loop = 0;
	  break;

      case VDPDM_NON_LIST_G_WRITE:
	  notifyWriteFile( form );
	  break;

    }

wrapup:
    return retFlag;
}

/* -----------------------------------------------
 * Loop on events
 */
static void VDpdmCmdLoopNonList(Form form)
{
  VDASSERT_FN("VDpdmCmdLoopSetPurp");
  IGRstat sts;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(form);
  
  // Loop until form told to break out
  loop = 1;
  while(loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
 wrapup:
  return;
}

/* ---------------------------------------------
 * Called from VDpdmStartup.c, main form function.
 * ***/
/* -
 * Try storing all of this data into some static pointer variables so the 
 * data can be used throughout.  These are pointers.  See vdct1 cmdInfo stuff 
 * for an example.
 * **/
IGRstat VDpdmDisplayNonCompliantRefList(TVDpdmInfo    *actInfo,
	                                VDpdmHullApp  *actShips,
					TVDpdmRefList *nonList )
{
    VDASSERT_FN("VDpdmDisplayNonCompliantRefList");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    Form    form;

    traceFlag = traceFlagx = VDdbgGetTraceFlag(VDPDM_TRACE_APP_CFG);

    VDASSERTW(*actInfo->catalog != 0);
    VDASSERTW(actShips->cnt > 0);
    VDASSERTW(nonList->cnt > 0);

    // set the statics
    s_actInfo  = *actInfo;
    s_actShips = *actShips;
    s_nonList  = *nonList;
    loop       = 1;
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm (777, VDPDM_NON_LIST_F_NAME, notifyForm, 0, &form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    sts = initNonListFormValues( form );
    if (!(sts & 1)) goto wrapup;

    // start the loop
    VDpdmCmdLoopNonList(form);

wrapup:
    return 0;
}
