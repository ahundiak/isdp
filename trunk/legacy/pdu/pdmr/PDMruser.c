#include <stdio.h>

#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDMcommand.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDMmessage.h"
#include "PDUintdef.h"
#include "PDUstr.h"
#include "NFMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern PDUsts_ptr PDUsts;
extern int PDMdebug_on;
extern char PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;
extern struct PDUrefresh *refresh;
int PDMsock;
static char s[1024];

int PDMrlogin (username, password, environment, login_flag, user_id)
  char          *username;
  char          *password;
  char          *environment;
  short         login_flag;   /* determines whether user is logging in or
                                 reconnecting */
  long		*user_id;           /*  o - 0 if function fails  */

  {
        int     status = PDM_S_SUCCESS;

	if (PDMdebug_on)
		PDUprint_storage_area();
        _pdm_debug("username = <%s>", username);
        _pdm_debug("environment = <%s>", environment);

	/*  Initialize user_id  */

	*user_id = 0;

        if (login_flag == 1)
          {
          /* Display message */
          PDUmessage(PDS_M_USER_LOGIN, 's');
          }
        else
          PDUmessage(PDS_M_RECONNECT, 's');

        /* call function to load PDMexec structure */
	PDUload_exec_structure("",username, password, environment,
                               "","","",0,0);

	/* call PDM function */
	_pdm_debug("calling PDMlogin", 0);
        status = PDMlogin(user_id);
        _pdm_status("PDMlogin", status);

        if (status != PDM_S_SUCCESS)
          return(status);

        if (PDMdebug_on)
	   PDUprint_storage_area();
        _pdm_debug("user_id = %d", (char *)*user_id);
	PDMexec->user_id = *user_id;

        /* Display Message */
        PDUmessage(status, 's');

	_pdm_debug("PDMlogin: returning SUCCESS", 0);
	return (status);
  }


int PDMrterminate()
{
        int     status = PDM_S_SUCCESS;
        extern int PDU_connection;

        _pdm_debug("ENTER:PDMrterminate", 0);

        PDU_connection = FALSE;
        refresh->command = PDC_M_LOGOUT;

        /* Display message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        /* Load exec structure */
        PDUload_exec_structure("", "", "", "", "LOGOUT","","", 0, 0);

        /* Terminate PDM. */
        status = PDMterminate();
        _pdm_status("PDMterminate", status);

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDMterminate failed", 0);
            return(status);
           }

        _pdm_debug("EXIT:PDMrterminate", 0);
        return(PDM_S_SUCCESS);
}


int PDMrverify_init (prod_name,prod_version)
char    *prod_name;
char    *prod_version;
  {
        int   status = PDM_S_SUCCESS;

        _pdm_debug("PDMrverify_init ...", 0);

        sprintf(s,"Product Name -> %s\n",prod_name);
        _pdm_debug(s, 0);
        sprintf(s,"Product Revision -> %s\n",prod_version);
        _pdm_debug(s, 0);

        /* Display message */
        PDUmessage(PDS_M_VERIFY_INIT, 's');

        /* call function to load exec structure */
        PDUload_exec_structure("","",prod_name, prod_version,"","","",0,0);

        PDMupdate_dots();

        /* call PDM function */
        _pdm_debug("calling PDMverify_init", 0);
        status = PDMverify_init();
        _pdm_status("PDMverify_init", 0);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

        _pdm_debug("PDMrverify_init: returning SUCCESS", 0);
        return (status);
  }

