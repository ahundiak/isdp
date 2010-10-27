 /* $Id: VDpdmNewRev.c,v 1.6 2002/04/25 21:50:10 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmNewRev.c
 *
 * Description: Used to cycle through classifications to find catalog
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDpdmNewRev.c,v $
 *	Revision 1.6  2002/04/25 21:50:10  jdsauby
 *	JTS TR6270
 *	
 *	Revision 1.5  2001/10/03 14:03:34  jdsauby
 *	JTS MP CR 5591
 *	
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/02/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"
#include "VDfrmc.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmNewRev.c");

/* Statics */
static IGRint       p_filekey;
static IGRchar      *s_new_rev;
static IGRchar      *s_catalog;
static IGRchar      *s_part;
static IGRchar      *s_old_rev;
static IGRchar      *s_app_rev;
static IGRstat      loop;
static Form         s_form;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* -------------------------------------------------
 * get either the selected revision or the approved revision
 * **/
static void getRevision()
{
    VDASSERT_FN("getRevision");

    IGRint  row, sel;
    
    VDASSERTW(s_form);

    // try to get one selected first
    VDfrmGetActiveRow(s_form,VDPDM_NEW_REV_L_REV,&row,NULL);

    // is it selected
    VDfrmGetSelect(s_form,VDPDM_NEW_REV_L_REV,row,0,&sel);
    if (!sel) {
	s_new_rev = s_app_rev;
	goto wrapup;
    }

    // get the selected one
    VDfrmGetfText(s_form,VDPDM_NEW_REV_L_REV,row,0,s_new_rev);
    if (*s_new_rev == 0) goto wrapup;

wrapup:
    return;
}

static IGRstat revisionMatchesHAP(IGRchar *rev)
{
    VDASSERT_FN("revisionMatchesHAP");
    IGRstat retFlag = 0;

    IGRint  filekey = 0;

    VDASSERTW(rev && *rev);
    VDASSERTW(p_filekey > 0);
    VDASSERTW(*s_catalog);
    VDASSERTW(*s_part);

    // get the filekey of the potential new rev
    VDpdmGetFileKeyForCPR(s_catalog, s_part, rev, &filekey);
    if (filekey < 1) goto wrapup;

    // compare the HAP
    retFlag = VDpdmIsShipApplicabilityValid(&p_filekey,&filekey);

    // done

wrapup:
    return retFlag;
}

/* --------------------------------------------------
 * Initialize settings on form.
 * Need to fill the new revisions gadget
 * ***/
static IGRstat initNewRevFormSettings()
{
    VDASSERT_FN("initNewRevFormSettings");
    
    IGRstat retFlag = 1;
    IGRstat sts;
    IGRint  i,row;
    TVDrisInfo  ris;
    
    // arg check / init
    VDrisInitInfo( &ris );
    VDASSERTW(s_form);
    VDASSERTW(*s_catalog);
    VDASSERTW(*s_part);

    // the sql
    sprintf(ris.sql,
	    "Select n_itemrev from %s where n_itemname='%s' order by n_itemrev;",
	    s_catalog,s_part);

    // the query
    VDrisQuery( &ris, NULL );
    if (ris.rows < 1) goto wrapup;


    // fill the gadget list
    UI_status("Getting Applicable Revisions");
    row = 0;
    for (i = 0; i < ris.rows; i++) {

	if (revisionMatchesHAP(ris.buf[i])) {
	    VDfrmSetfText( s_form, VDPDM_NEW_REV_L_REV, row, 0, ris.buf[i]);
	    row++;
	}
    }
    //VDpdmFillGadgetList( s_form, VDPDM_NEW_REV_L_REV, &ris );


    // Set the existing rev text
    VDfrmSetgText( s_form, VDPDM_NEW_REV_CUR_REV, s_old_rev );
    
    // set the approved rev
    VDfrmSetgText( s_form, VDPDM_NEW_REV_APPR_REV, s_app_rev );

    UI_status("Select Applicable Revision, or Accept Approved");
    
    // done
    retFlag = 1;


wrapup:
    VDrisFreeInfo( &ris );
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
    IGRchar msg[80];

    //// say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);


    // switch on gadget
    switch(g_label) {
      
      case FI_CANCEL:
	  loop = 0;
	  VDfrmDeleteForm( s_form, 1 );
	  s_form = NULL;
	  break;

      case FI_ACCEPT:
	  getRevision();
	  if (*s_new_rev == 0) goto wrapup;
	  loop = 0;
	  VDfrmDeleteForm( s_form, 1);
	  s_form = NULL;
	  break;

      case VDPDM_NEW_REV_B_DO_NOT_REPLACE:
	  strcpy(s_new_rev,"NULL");
	  loop = 0;
	  VDfrmDeleteForm( s_form, 1);
	  s_form = NULL;
	  break;

           
    }

wrapup:
    return retFlag;
}
/* -----------------------------------------------
 * Loop on events
 */
static void loopNewRevForm()
{
  VDASSERT_FN("loopNewRevForm");
  IGRstat sts;

  XEvent event;
  
  // Should not be called recursivily
  VDASSERTW(s_form);
  
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
 * Called by the Main form gadget.
 * ***/
IGRstat VDpdmCmdGetNewRev(IGRint   parent_filekey,
	                  IGRchar  *catalog,
                          IGRchar  *part,
                          IGRchar  *old_rev,
                          IGRchar  *app_rev,
			  IGRchar  *new_rev)
{
    VDASSERT_FN("VDpdmCmdGetNewRev");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;


    //traceFlag = traceFlagx = 0;

    // should not be called again
    VDASSERTW(!s_form);
    VDASSERTW(parent_filekey > 0);
    VDASSERTW(*catalog);
    VDASSERTW(*part);
    VDASSERTW(new_rev); *new_rev = 0; 

    // set the static
    p_filekey = parent_filekey;
    s_catalog = catalog;
    s_part    = part;
    s_old_rev = old_rev;
    s_app_rev = app_rev;
    s_new_rev = new_rev;
    loop  = 1;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm(VDPDM_NEW_REV_F_NUM, VDPDM_NEW_REV_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // Initialize form settings
    sts = initNewRevFormSettings( );
   

    // loop
    loopNewRevForm();
    
    // done
    strcpy(new_rev,s_new_rev);
    

wrapup:
    if (s_form) {
	VDfrmDeleteForm(s_form,1);
	s_form = NULL;
    }
    return 0;

}
