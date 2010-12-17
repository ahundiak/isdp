#include "PDUuser.h"
#include "PDUintdef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDU_command;
extern struct PDUuser *user;

void PDUppl_login(status, environment, username, passwd)
int    *status;
char   *environment;
char   *username;
char   *passwd;
{

  _pdm_debug("in the macro PDUppl_login", 0);

  PDUmessage(PDC_M_LOGIN_USER, 'c');

  /* populate user structure */
  PDUfill_in_string(&user->environment, environment);
  PDUfill_in_string(&user->username, username);
  PDUfill_in_string(&user->passwd, passwd);

  /* call function to set up workstation information */
  *status = PDUprocess_wrkst_info();
  _pdm_status("PDUprocess_wrkst_info", *status);

  /* call function to set up global storage structure and log in to PDM */
  *status = PDUprocess_login();
  _pdm_status("PDUprocess_login", *status);

}
