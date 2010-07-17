 /* $Id: AIMlogin.c,v 1.3 2002/04/26 16:18:58 tlstalli Exp $  */
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

VDASSERT_FFN("aim/src/sir/AIMlogin.c");

static Form    s_form;
static IGRstat loop;
static IGRstat returnAIMlogin;

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

extern struct hostent *gethostbyname();


/* ------------------------------------
 * AIMlogin form gadget labels
 * **/
#define AIM_LOGIN_F_NAME         "AIMlogin"
#define AIM_LOGIN_F_NUM            101
#define AIM_LOGIN_STATUS           10
#define AIM_LOGIN_L_AIM_SERVERS    16
#define AIM_LOGIN_G_AIM_ENV        17

// connect / disconnect
#define CLIX_CONNECT	-1
#define CLIX_DISCONNECT -2

#define SIR 1

struct  hostent {
       char    *h_name;        /* official name of host */
        char    **h_aliases;    /* alias list */
        int     h_addrtype;     /* host address type */
        int     h_length;       /* length of address */
        char    **h_addr_list;  /* list of addresses from name server */
#define h_addr  h_addr_list[0]  /* address, for backward compatiblity */
};

/*
 * Internet address (a structure for historical reasons)
 */
struct in_addr
{
  unsigned long s_addr;
};



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
    IGRchar srerrmsg[80];
    struct hostent	*h = NULL;

    IGRint   code1;
  
    IGRint   sts1; 
    IGRchar *aim_user2, *aim_server2, *aim_env2;

    IGRchar  aim_user3[50], aim_server3[25], aim_env3[15];


    // disconnect if already connected
    if( IsPmeEnabled() )
    {

	sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
		NULL,
		NULL,
		NULL,
		NULL,
		&errmsg);

	if ( !sts) EnablePME(0);

	UI_status("Disconnected From AIM server");

	VDfrmSetgText(s_form,AIM_LOGIN_G_AIM_ENV,"");
    }

    // disable the FI_ACCEPT button
    FIg_disable(s_form,FI_ACCEPT);

    VDfrmGetgText(s_form, AIM_LOGIN_L_AIM_SERVERS, server_name);

    h = gethostbyname(server_name);
    if (h == NULL) {
	UI_status("Could not find AIM Server");
	goto wrapup;
    }

    // tell the world we are connected to SIR
    ConnectAIM(SIR);

    // connect to SIR
    UI_status("Connecting to AIM server....");
    sts = POSTMAN_REQUEST_ON_CLIX( CLIX_CONNECT,
	    (char *)inet_ntoa(*((struct in_addr *)h->h_addr)),
	    NULL, 
	    NULL, 
	    NULL, 
	    &errmsg);

    if ( !sts)
    {
	EnablePME(1);
	UI_status(" Connected to AIM server");
	VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Connected to AIM Server");
    } 
    else
    {
	printf("Connection status: %d\n", sts);
        UI_status("Connection ERROR...");

	if(sts == 12345)
        {
           UI_status("AIM connection reset by server.");
	   printf("AIM connection reset by server\n");
           //ex$message ( msgnumb = EX_F_Var1, type = "%s", var = srerrmsg );
        }
        if(errmsg) 
    	{
	   printf("Connection ERROR: \n", errmsg);
	}

	EnablePME(0);
	UI_status( " Failed to Connect to AIM server" );
	VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Failed to Connect to AIM Server");
	goto wrapup;
    } 

    // put the aim environment onto the form 
    code1 = 444;
    SrVDPGetAIMInfo(&code1, &aim_user2, &aim_server2, &aim_env2);

    *aim_env3 = 0;
    VDPGetAimInfo(aim_user3, aim_server3, aim_env3);
    if (*aim_env3 == 0) {
	UI_status("Not Connected to AIM Server");
	VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Not Connected to AIM Server");
	goto wrapup;
    }
    
    VDfrmSetgText(s_form,AIM_LOGIN_G_AIM_ENV,aim_env3);
    FIg_disable(s_form, FI_EXECUTE);
    FIg_enable (s_form, FI_ACCEPT);

    // done
    retFlag = 1;
    returnAIMlogin = 1;

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
    IGRstat sts;
    IGRchar *errmsg = NULL;
/*
    if ( IsPmeEnabled() )
    {
	sts = POSTMAN_REQUEST_ON_CLIX( CLIX_DISCONNECT,
		NULL,
		NULL,
		NULL,
		NULL,
		&errmsg);
	if ( !sts ) EnablePME(0);

	UI_status("Disconnected From AIM server");
    }
*/
    VDfrmDeleteForm( s_form, 0 );
    s_form = NULL;
    loop = 0;

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

FILE *AIMloginOpenServerListFile()
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

    FILE  *file;
    char  buf[1024];
    char  *p;
    int   row;


    // Select a server
    VDfrmSetgText(s_form,AIM_LOGIN_STATUS,"Select an AIM Server");

    // Open the access control list
    file = NULL;
    file = AIMloginOpenServerListFile();
    if (file == NULL) {
	printf("*** aim_servers.cfg not found\n");
	goto wrapup;
    }

    // Cycle through
    row = 0;
    while(fgets(buf,sizeof(buf),file)) {

	if (strncmp(buf,"#",1)) {

	    for(p = buf; *p > ' '; p=p+1); *p = 0;
	    if (*buf) {

		// display on the form
		VDfrmSetgListText(s_form, AIM_LOGIN_L_AIM_SERVERS, row, buf );
		row = row + 1;

	    } // end of if (*buf)

	} // end of if (strncmp(buf,"#",1))

    } // end of while 

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

    returnAIMlogin = 0;

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
    return returnAIMlogin;

}


