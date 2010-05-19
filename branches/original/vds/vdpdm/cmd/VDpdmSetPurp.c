 /* $Id: VDpdmSetPurp.c,v 1.5 2002/05/10 19:33:50 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmSetPurp.c
 *
 * Description: Main form director for all VDS PDM utilities
 *
 * Dependencies:
 *
 * Revision History:

 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/23/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDpdmCmd.h"
#include "VDpdmForms.h"

VDASSERT_FFN("vdpdm/cmd/VDpdmSetPurp.c");

static VDosnum           s_os;
static TVDpdmPurposeInfo *s_info;
static IGRstat           loop;
static IGRstat           set;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* ---------------------------------------
 * Do it, set the purpose Info, and send it back
 * **/
static IGRstat notifyDoit(Form form)
{
    VDASSERT_FN("notifyDoit");
    IGRstat retFlag = 0;
    IGRstat sts;
    IGRchar msg[80];

    VDASSERTW(form);

    // get the purpose info from the form
    VDfrmGetgText( form, VDPDM_SET_PURP_L_PURP, s_info->purpose );
    if (*s_info->purpose == 0) {
	VDfrmSetgText( form, VDPDM_SET_PURP_STATUS, "Need a Purpose");
	goto wrapup;
    }

    VDfrmGetgText( form, VDPDM_SET_PURP_G_ZONE, s_info->zone );
    VDfrmGetgText( form, VDPDM_SET_PURP_G_UNIT, s_info->unit );
    VDfrmGetgText( form, VDPDM_SET_PURP_G_SYSTEM, s_info->system );

    // Check that values match purpose
    sts = VDrrvCheckPurposeValues( s_info, msg );
    if (!(sts & 1)) {
	VDfrmSetgText(form, VDPDM_SET_PURP_STATUS, msg );
	goto wrapup;
    }

    // update 
    VDpdmSetPurposeInfo(s_os,s_info );

    // done
    retFlag = 1;
    set     = 1;


wrapup:
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
	  loop = 0;
	  VDfrmDeleteForm( form, 0 );
	  break;

      case FI_EXECUTE:
	  notifyDoit( form );
	  break;

      case FI_ACCEPT:
	  sts = notifyDoit( form );
	  if (sts) {
	      VDfrmDeleteForm( form, 0 );
	      loop = 0;
	  }
	  break;

      case FI_RESET:
	  VDpdmFillPurposeListGadget(form, VDPDM_SET_PURP_L_PURP);
	  break;

    }

wrapup:
    return retFlag;
}

/* -----------------------------------------------
 * Loop on events
 */
static void VDpdmCmdLoopSetPurp(Form form)
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
 * Called to set Purpose Info from anyone
 * ***/
IGRstat VDpdmCmdSetPurposeInfo(VDosnum           osnum,
                               TVDpdmPurposeInfo *info)
{
    VDASSERT_FN("VDpdmCmdSetPurposeInfo");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    Form    form;

    //traceFlag = traceFlagx = 0;

    // set the statics
    s_os = osnum;
    s_info = info;
    loop   = 1;
    set    = 0;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm(VDPDM_SET_PURP_F_NUM,
                       VDPDM_SET_PURP_F_NAME,
		       notifyForm, 0, &form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // fill the purpose Info list
    VDpdmFillPurposeListGadget(form, VDPDM_SET_PURP_L_PURP);

    VDpdmCmdLoopSetPurp( form );

wrapup:
    if (set) return 1;
    else     return 0;

}


