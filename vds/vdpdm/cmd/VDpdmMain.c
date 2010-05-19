 /* $Id: VDpdmMain.c,v 1.9 2001/07/16 13:52:54 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmMain.c
 *
 * Description: Main form director for all VDS PDM utilities
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpdmMain.c,v $
 *      Revision 1.9  2001/07/16 13:52:54  jdsauby
 *      VDassert working with Z D F
 *
 *      Revision 1.8  2001/06/04 13:07:47  jdsauby
 *      CR3403, new replace part
 *
 *      Revision 1.7  2001/04/24 20:41:05  jdsauby
 *      Post Macros, CR 5083
 *
 *      Revision 1.6  2001/04/12 20:41:32  jdsauby
 *      sp 11
 *
 *      Revision 1.5  2001/03/08 14:39:29  jdsauby
 *      Re - organization of VDpdm.h
 *
 *      Revision 1.4  2001/02/23 16:10:15  jdsauby
 *      Just some more changes, nearing completion
 *
 *      Revision 1.3  2001/02/21 13:00:31  jdsauby
 *      CR4088
 *
 *      Revision 1.2  2001/02/11 17:54:47  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/02/05 16:38:03  jdsauby
 *      JTS MP CR4088
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmMain.c");

static Form    s_form;
static IGRstat loop;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;


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

    VDASSERTW(s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    switch(g_label) {
      case FI_CANCEL:
	  VDpdmKillMainForm();
	  break;

      case VDPDM_MAIN_G_PART_HULL:
	  sts = VDpdmInitPtHull();
	  break;

      case VDPDM_MAIN_G_HULL_PART:
	  sts = VDpdmInitHullPt();
	  break;

      case VDPDM_MAIN_G_NOTEBOOK:
	  sts = VDpdmInitNoteBk();
	  break;

      case VDPDM_MAIN_G_MACROS:
	  sts = VDpdmInitMacro();
	  break;
#if 0  
	  //Don't want this on the VDpdm form, it should go to the Main PDM form
      case VDPDM_MAIN_G_REPL_PART:
	  sts = VDpdmInitReplPart();
	  break;
#endif
      default:
	  EX_error_box(FI_CURRENT_SCREEN,
		       "Reserved for future use.",
		       "Function not yet implemented" );
	  break;

    }

wrapup:
    return retFlag;
}

/* ---------------------------------------------
 * Called by the PPL, to wakeup Main form
 * ***/
IGRstat VDpdmUtilInitMain()
{
    VDASSERT_FN("VDpdmUtilInitMain");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    //traceFlag = traceFlagx = 0;

    // should not be called twice
    VDASSERTW(!s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm (555, VDPDM_MAIN_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // loop on events
    VDpdmLoopMainForm();

wrapup:
    return 0;

}

/* ---------------------------------------------
 * Loop on events
 * **/
IGRstat VDpdmLoopMainForm()
{
    VDASSERT_FN("VDpdmLoopMainForm");
    
    XEvent  event;

    // make sure it is not called twice
    VDASSERTW(s_form);

    // loop until told to break out
    loop = 1;
    while (loop) {
	XNextEvent(_FI_display, &event);
	FI_process_event(&event, 0);
  }
  
 wrapup:
  return 1;
}

/* ----------------------------------------------
 * Form killer
 * **/
IGRstat VDpdmKillMainForm()
{
    VDASSERT_FN("VDpdmKillMainForm");

    // better have a form
    VDASSERTW(s_form);
    
    // Kill this form
    VDfrmDeleteForm( s_form, 0 );

    // break the loop
    loop = 0;
    s_form = NULL;

    // Kill the other forms
    VDpdmKillPtHullForm();
    VDpdmKillHullPtForm();
    VDpdmKillNoteBkForm();
    VDpdmKillMacroForm();

    // done
wrapup:
    return 1;
}

