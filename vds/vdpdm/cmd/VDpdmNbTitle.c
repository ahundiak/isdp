 /* $Id: VDpdmNbTitle.c,v 1.1 2001/10/03 13:52:14 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/cmd/VDpdmNbTitle.c
 *
 * Description: Sub Form to get a new title for notebook
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDpdmNbTitle.c,v $
 * Revision 1.1  2001/10/03 13:52:14  jdsauby
 * JTS MP CR5448, Database Notebooks
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

VDASSERT_FFN("vdpdm/cmd/VDpdmNbTitle.c");

/* Statics */
static IGRchar      *s_title;
static IGRstat      loop;
static Form         s_form;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

/* -------------------------------------------------
 * get either the selected revision or the approved revision
 * **/
static void getTitle()
{
    VDASSERT_FN("getTitle");

    VDASSERTW(s_form);

    // get the title one
    VDfrmGetgText(s_form,VDPDM_NB_TITLE_G_TITLE,s_title);
    if (*s_title == 0) goto wrapup;

wrapup:
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
	  getTitle();
	  if (*s_title == 0) goto wrapup;
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
static void loopNbTitleForm()
{
  VDASSERT_FN("loopNbTitleForm");
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
IGRstat VDpdmDbNbAddTitle(IGRchar  *title)
{
    VDASSERT_FN("VDpdmDbNbAddTitle");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;


    //traceFlag = traceFlagx = 0;

    // should not be called again
    VDASSERTW(!s_form);

    // set the static
    s_title = title;
    loop  = 1;

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm(VDPDM_NB_TITLE_F_NUM, VDPDM_NB_TITLE_F_NAME, notifyForm, 0, &s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // loop
    loopNbTitleForm();
    
    // done
    strcpy(title,s_title);
    

wrapup:
    if (s_form) {
	VDfrmDeleteForm(s_form,1);
	s_form = NULL;
    }
    return 0;

}
