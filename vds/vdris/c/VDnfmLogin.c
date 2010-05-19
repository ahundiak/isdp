/* $Id: VDnfmLogin.c,v 1.2 2001/02/11 17:59:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdris/c/VDnfmLogin.c
 *
 * Description: Form driven nfm login
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDnfmLogin.c,v $
 * Revision 1.2  2001/02/11 17:59:46  ahundiak
 * Renamed VDris2 to VDrisc
 *
 * Revision 1.1  2001/02/01 21:58:19  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/01/01  ah      Creation
 *
 ***************************************************************************/

/* ----------------------------------------------- 
 * Some of this stuff was based on the GRnotify
 * routine and included just to see what happens.
 * 
 * Really need a stub event handler so this works
 * properly under both isdp and stand alone
 */

#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDnfmc.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
#endif

#include "ris.h"

extern int FI_current_screen_height;
extern int FI_current_screen_width;

#ifdef X11
extern Display *_FI_display;
#endif

#define VDNFM_FORM_LOGIN_G_USER 11
#define VDNFM_FORM_LOGIN_G_PASS 12
#define VDNFM_FORM_LOGIN_G_ENV  13

static Form s_form;
static Form s_formStatus;

/* -----------------------------------------------
 * Just to let other routines see if login is
 * in progress
 */
Form VDnfmGetLoginForm()
{
  return s_form;
}

/* -----------------------------------------------
 * Callback routine for updating status
 */
static void showStatus(IGRchar *buf)
{
  Form form;
  
  form = s_formStatus;
  if (form == NULL) form = s_form;
  if (form == NULL) return;
  
  VDfrmSetgFmt(form,10,buf);
}

/* -----------------------------------------------
 * Execute the form
 * Allow calling with an external form
 * Should pass the gadgets as arguments
 */
IGRstat VDnfmNotifyExecute(Form form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDnfmEnvInfo info;
  
  IGRchar envName[32];
  IGRchar buf[128];
  
  // Save it for the status calls
  s_formStatus = form;
  
  // Get some stuff from the form
  VDfrmGetgText(form,VDNFM_FORM_LOGIN_G_ENV,envName);
  if (*envName == 0) {
    showStatus("Pick Enviroment First");
    goto wrapup;
  }

  // Need the schema name
  sts = VDnfmGetEnvInfoForPdmEnv(envName,&info,showStatus);
  if (!(sts & 1)) goto wrapup;

  // Check to see if schema is already opened

  // Make sure have a user and password
  VDfrmGetgText(form,VDNFM_FORM_LOGIN_G_USER,info.pdmName);
  VDfrmGetgText(form,VDNFM_FORM_LOGIN_G_PASS,info.pdmPass);
  
  if (*info.pdmName == 0) {
    showStatus("Enter User Name");
    goto wrapup;
  }
  
  // Locate schema file
  sts = VDnfmLocateSchemaFile(&info,showStatus);
  if (!(sts & 1)) goto wrapup;
  
  // Open it
  sts = VDnfmOpenSchema(&info,showStatus);
  if (!(sts & 1)) goto wrapup;

  // Validate user
  sts = VDnfmValidateUser(&info,showStatus);
  if (!(sts & 1)) {
    goto wrapup;
  }

  // Done
  retFlag =1;
  
 wrapup:

  // Reset status form
  s_formStatus = NULL;
  
  return retFlag;
}

/* -----------------------------------------------
 * Fills in the list of available enviroments
 * using NFMenv.dat
 */
IGRstat VDnfmFillEnvListGadget(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;
  
  IGRchar fileName[128];
  FILE   *file = NULL;

  IGRchar *p;
  IGRchar buf[256];
  IGRint  row = 0;

  TVDnfmEnvInfo info;
    
  // Open the file
  VDnfmGetEnvInfoFileName(fileName);
  file = fopen(fileName,"rt");
  if (file == NULL) goto wrapup;
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    VDnfmDecodeEnvInfoLine(buf,&info);
    strcpy(buf,info.envName);
    if (*buf) {
      p = strchr(buf,'_');
      if (p) strcpy(buf,p+1);
      VDfrmSetlText(form,gadget,row,buf);
      row++;
    }
  }
  fclose(file);
    
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Form notification routine
 */
static IGRint notify(IGRint    f_label,
		     IGRint    g_label,
		     IGRdouble value,
		     Form      formx)
{

  IGRstat retFlag = 1;
  IGRstat sts;
  
  // do it
  switch(g_label) {

    case FI_CANCEL:
      VDfrmDeleteForm(s_form,0);
      s_form = NULL;
      break;
      
    case FI_RESET:
      VDfrmResetForm(s_form);
      break;
                  
    case FI_EXECUTE:
      VDnfmNotifyExecute(s_form);
      
  }  // end of switch
  
  // done
 wrapup:
  return retFlag;
}


static IGRstat init_form()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar txt[128];
  
  // Create it
  sts = VDfrmNewForm(555,VDNFM_FORM_LOGIN_NAME,notify,0,&s_form);
  if (!(sts & 1)) goto wrapup;
  
  // Display it
  VDfrmShowForm(s_form);

  VDnfmFillEnvListGadget(s_form,VDNFM_FORM_LOGIN_G_ENV);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Modal function for logging into nfm/pdm
 *
 * Just grabbing the events does not prevent the user
 * from clicking on another form
 *
 * We can teach the notifys to ignore but that's a pain
 */
IGRstat VDnfmFormLogin()
{
  IGRstat retFlag = 0;
  IGRstat sts;

#ifdef X11
  XEvent event;
  XSetWindowAttributes winatt;
  Window win;
#endif

  // Just to prevent multiple copies
  if (s_form) goto wrapup;
  
  // Start it up
  sts = init_form();
  if (!(sts & 1)) goto wrapup;
  
#ifdef X11
#if 1
    /* make the form save-under */
    winatt.save_under = TRUE;
    if (FIf_get_window(s_form, &win) == FI_SUCCESS)
        XChangeWindowAttributes(_FI_display, win, CWSaveUnder, &winatt);
#endif
#endif
  
  // Now here is the tricky part
  while(s_form) {
    
#ifdef X11
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
#endif
  }
  

 wrapup:
  return retFlag;
}

