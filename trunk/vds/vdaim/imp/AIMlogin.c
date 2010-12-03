/* $Id: AIMlogin.c,v 1.3.2.1 2003/05/16 14:37:27 ahundiak Exp $  */
/***************************************************************************
 * I/AIM
 *
 * File:        vdpdm/cmd/AIMlogin.c
 *
 * Description: Controls the AIM login form, this is written to replace the PPL
 *              VDpostconn.u, and the same code with PDUaim_cm.C.  Both the PPL,
 *              and PDUaim_cm.C will call the entry function of this file.
 *              The entry function is AIMlogin();
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: AIMlogin.c,v $
 *      Revision 1.3.2.1  2003/05/16 14:37:27  ahundiak
 *      ah
 *
 *      Revision 1.3  2002/04/26 16:18:58  tlstalli
 *      Fixed TR 6089, print to screen connection error
 *
 *      Revision 1.2  2001/11/06 13:15:08  jdsauby
 *      fixed bugs related to AIMlogin - JDS 11/06/01
 *
 *      Revision 1.1  2001/11/05 16:39:12  jdsauby
 *      JTS CR MP 5228
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/01/01  js      Creation
 ***************************************************************************/
  
#include "VDtypedefc.h"
#include "VDdbgAssert.h"
#include "VDassert.h"
#include "VDrisc.h"
#include "VDfrmc.h"

#include "VDPaimPostMan.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>

VDASSERT_FFN("aim/src/sir/AIMlogin.c");

static Form    s_form;
static IGRstat s_loop;
static IGRstat s_returnAIMlogin;

extern Display *_FI_display;

/* ------------------------------------
 * AIMlogin form gadget labels
 * **/
#define AIM_LOGIN_F_NAME         "AIMlogin"
#define AIM_LOGIN_F_NUM            101
#define AIM_LOGIN_STATUS           10
#define AIM_LOGIN_L_AIM_SERVERS    16
#define AIM_LOGIN_G_AIM_ENV        17

#define SIR 1

/* --------------------------------------
 * FI_EXECUTE pressed
 * **/
//VDfrmSetgListText( form, gadget, i, ris->buf[i] );
static IGRstat notifyDoit()
{
    VDASSERT_FN("notifyDoit");

    IGRstat retFlag = 1;
    IGRstat sts;
    IGRchar server_name[80];
    IGRchar *errmsg = NULL;
  
    IGRint   sts1; 

    TVDPaimServerInfo serverInfo;

    // disconnect if already connected
    if( IsPmeEnabled() )
    {
        sts = VDPaimPostManDisConnect();

	if ( !sts) EnablePME(0);

	UI_status("Disconnected From AIM server");

	VDfrmSetgText(s_form,AIM_LOGIN_G_AIM_ENV,"");
    }

    // disable the FI_ACCEPT button
    FIg_disable(s_form,FI_ACCEPT);

    VDfrmGetgText(s_form, AIM_LOGIN_L_AIM_SERVERS, server_name);

    // tell the world we are connected to SIR
    ConnectAIM(SIR);

    // connect to SIR
    UI_status("Connecting to AIM server....");
    sts = VDPaimPostManConnect(server_name);
    if ( !sts)
    {
	EnablePME(1);
	UI_status(" Connected to AIM server");
	VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Connected to AIM Server");
    } 
    else
    {
        errmsg = VDPaimPostManGetErrorMsg();
	EnablePME(0);
	UI_status(errmsg);
	VDfrmSetgText(s_form,AIM_LOGIN_STATUS,errmsg);
	goto wrapup;
    } 

    // put the aim environment onto the form 
    VDPaimGetServerInfo(serverInfo.user,serverInfo.server,serverInfo.env);
    if (*serverInfo.env == 0) {
	UI_status("Not Connected to AIM Server");
	VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Not Connected to AIM Server");
	goto wrapup;
    }
    
    VDfrmSetgText(s_form,AIM_LOGIN_G_AIM_ENV,serverInfo.env);
    FIg_disable(s_form, FI_EXECUTE);
    FIg_enable (s_form, FI_ACCEPT);

    // done
    retFlag = 1;
    s_returnAIMlogin = 1;

wrapup:
    return retFlag;
}

/* ---------------------------------------
 * FI_CANCEL pressed
 * **/
static IGRstat notifyCancel()
{
    VDASSERT_FN("notifyCancel");

    IGRstat retFlag = 1;

    VDfrmDeleteForm( s_form, 0 );
    s_form = NULL;
    s_loop = 0;

    // done
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

    VDASSERTW(s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    switch(g_label) {

      case FI_CANCEL :

	  notifyCancel();
	  break;  

      case FI_EXECUTE: 

	  notifyDoit();
	  break; 

      case  FI_ACCEPT:

	  notifyCancel();
	  break;

    }

wrapup:
    return retFlag;
}

static FILE *AIMloginOpenServerListFile()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;

  // Look in local directory
  file = fopen("aim_servers.cfg","r");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i=i+1) {
    
    // Product specific loading
    *buf = 0;
    EX_getpath(i,buf,sizeof(buf),EX_CONFIG_PATH);
    if (*buf == 0) {
      file = NULL;
      return file;
    }
   
    strcat(buf,"config/sets/aim_servers.cfg");
    //printf("Directory for tm_access.tbl file is [%s]\n",buf);
    
    file = fopen(buf,"r");
    if (file != NULL) return file;
  }
}

/* --------------------------------------------
 * Initialize the AIMlogin form settings
 * **/
static void initAIMloginForm()
{
  VDASSERT_FN("initAIMloginForm");

  FILE *file = NULL;
  char  buf[1024];
  char *p;
  int   row;


  // Select a server
  VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Select an AIM Server");

  // Open the access control list
  file = AIMloginOpenServerListFile();
  if (file == NULL) {
    printf("*** aim_servers.cfg not found\n");
    goto wrapup;
  }
  VDfrmSetNumRows(s_form,AIM_LOGIN_L_AIM_SERVERS,0);

  // Cycle through
  row = 0;
  while(fgets(buf,sizeof(buf),file)) 
  {
    if (strncmp(buf,"#",1)) 
    {
      for(p = buf; *p > ' '; p=p+1); *p = 0;
      if (*buf) 
      {
        // display on the form
	VDfrmSetgListText(s_form, AIM_LOGIN_L_AIM_SERVERS, row, buf );
        if (row == 0)
        {
          /* CR 7585 Default Value */
          VDfrmSetgText(s_form, AIM_LOGIN_L_AIM_SERVERS, buf);
        }
        row = row + 1;
      }
    }
  }
  fclose(file);

wrapup:
    return;
}


/* ---------------------------------------------
 * Loop on events
 * **/
static IGRstat loopAIMloginForm()
{
  VDASSERT_FN("loopAIMloginForm");
    
  XEvent  event;

  /* Make sure have a form */
  VDASSERTW(s_form);

  /* loop until told to break out */
  s_loop = 1;
  while (s_loop) 
  {
    XNextEvent(_FI_display,&event);
    FI_process_event(&event, 0);
  }
  
wrapup:
  return 1;
}

/* ---------------------------------------------
 * Called by the PPL (VDpostconn.u), and function CMAimConnect, to wakeup the form
 * ***/
IGRstat AIMlogin()
{
    VDASSERT_FN("AIMlogin");

    IGRstat retFlag = 0;
    IGRstat sts;
    IGRint  disp_flag = 0;

    //traceFlag = traceFlagx = 0;

    s_returnAIMlogin = 0;

    // should not be called twice
    VDASSERTW(!s_form);
    
    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // wakeup the form
    sts = VDfrmNewForm (AIM_LOGIN_F_NUM,AIM_LOGIN_F_NAME,notifyForm,0,&s_form);
    if (!(sts & 1)) {
	fprintf(stderr,"ERR-FIf_new, sts = %d\n",sts);
	return sts;
    }

    sts = VDfrmDisplayForm( s_form, 1, &disp_flag );
    VDASSERTW(disp_flag);

    // init the form settings
    initAIMloginForm();

    // loop on events
    loopAIMloginForm();

wrapup:
    return s_returnAIMlogin;

}
