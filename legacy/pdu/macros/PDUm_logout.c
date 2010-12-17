#include "PDUerror.h"
#include "PDUuser.h"
#include "PDUintdef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDU_command;
extern char *PDU_save;
extern int PDU_login;
extern struct PDUuser *user;

void PDUppl_logout(status)
int    *status;
{

  _pdm_debug("in the macro PDUppl_logout", 0);

  *status = PDUverify_part ( 'a' );
  _pdm_status ("PDUverify_part (active)", *status);
  if ( 1&(*status) )
     {
       PDUfill_in_string(&PDU_save, "N");
       *status = PDUdeactivate ();
       _pdm_status("PDUdeactivate_part", *status);
       if ( 1&(*status) )
          *status = PDM_S_SUCCESS;
     }
  else
     if ( *status == PDM_E_NOT_ACTIVE )
          *status = PDM_S_SUCCESS;

  PDUmessage(PDC_M_LOGOUT, 'c');

  *status = PDUlogout ();
  _pdm_status("PDUext_logout", *status);

  /* reset global structure */
  user->username = NULL;
  PDUuser_init();
  refresh_init();
  PDUpart_init();

  PDU_login = FALSE;
}
