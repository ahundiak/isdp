/* Do not alter this SPC information: $Revision: 1.7.3.1 $ */
/*
** NAME:       cliinit.c
** AUTHORS:   Terry McIntyre
** CREATION DATE: 8/91
** ABSTRACT:
** 
** REVISION HISTORY:
*/
 
/*
** INCLUDES
*/
#if defined(unix)
#include <pwd.h>
#include <dirent.h>
#endif

#include <errno.h>
#include "riscom.h"
#include "rismem.h"
#include "client.h"
#include "net.h"
#include "ris.h"/*win95*/
#if defined(WIN32)
#include "secure.h"
#include "stuff.h"
#endif

/*
** DEFINES
*/
#define CHECK_UNIX_FILENAME_LEN(name) \
   if (strlen(name) > 10) LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME);

#define CHECK_VMS_FILENAME_LEN(name, type) \
if (type) \
{ \
   if (strlen(type + 1) > 39) LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME); \
   *type = '\0'; \
   if (strlen(name) > 39) LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME); \
   *type = '.'; \
} \
else if (strlen(name) > 39) LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME); \


/*
** TYPES
*/

/*
** FUNCTION PROTOTYPES
*/
#define cliinit_c
#include "cliinit.prt"
#include "clivers.prt"
#include "comalloc.prt"
#include "comc2pw.prt"
#include "comdebug.prt"
#include "comwrap.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comprtcl.prt"
#include "filglob.prt"
#include "usrinit.prt"
#include "sys.prt"
#if defined(WIN32)
#include "complat.prt"/* win95 */
#endif

/*
** VARIABLES
*/

/*
** FUNCTIONS
*/

extern void RIScli_init(
   ris_schfile_parms_s	*schfile_parms,
   ris_client_parms_s	*client_parms,
   ris_parms_s	   *parms,
   ristimestamp        *timestamp_parms,
   unsigned int      debug,
   unsigned char     app_maj,
   unsigned char     app_min,
   unsigned char     app_rel)
{
#if defined(WIN32)
   char  dcpt_password[38];
#endif
   CLI_DBG(("RIScli_init(schfile_parms:0x%x client_parms:0x%x parms:0x%x "
      "debug:%d app_maj:%d app_min:%d app_rel:%d)\n", 
      schfile_parms, client_parms, parms, debug, app_maj, app_min, app_rel));

   /*
   ** Initialize the debug flags
   */
   if (RIScom_debug_mask_to_flags(debug, SET_ONLY))
   {
      LONGJMP(RIS_E_INTERNAL_ERROR);
   }

   /*
   ** check the version
   */
   RIScli_check_version(app_maj, app_min, app_rel);

   /*
   ** set the app version
   */
   RIS_app_cli_version = app_maj;

   /*
   ** If tcp, verify the username and password
   */
   if (client_parms->protocol == 'T')
   {
#if defined(unix) 
      check_username_password(client_parms->username,client_parms->password);
#endif
#if defined(WIN32)
   CLI_DBG(("validate logon (TCP/IP) need to add impersonate\n"));
      RIScom_depd(client_parms->password, dcpt_password);
   CLI_DBG(("decrypted password. \n"));
      check_username_password(client_parms->username,dcpt_password);
#endif
   }

   /*
   ** Copy the parms into the global variable
   */
   memcpy(&RIS_parms, parms, sizeof(ris_parms_s));

   /*
   **  Copy the net_parms into the global variable
   */
   memcpy(&RIS_timestamp, timestamp_parms, sizeof(ristimestamp));

   /*
   ** Allocate memory for RIS_stmts[RIS_max_stmts]
   */
   RIS_max_dict_stmts = RIS_MAX_DICT_STMTS;
   RIS_max_secondary_stmts = 
    RIS_parms.max_user_stmts * RIS_parms.max_secondary_schemas;

   RIS_max_stmts =  RIS_MAX_STMTS;

   /*
   ** RIS_max_dict_stmts + RIS_parms.max_user_stmts + RIS_max_secondary_stmts;
   */

   if(	   (RIS_max_dict_stmts + RIS_parms.max_user_stmts + RIS_max_secondary_stmts) > 
      RIS_max_stmts )
   {
      LONGJMP(RIS_E_INV_USER_OR_SECONDARY_PARMS); 
   }

   CLI_DBG(("RIScli_init: RIS_max_dict_stmts:%d RIS_parms.max_user_stmts:%d "
    "RIS_max_secondary_stmts:%d\n", 
    RIS_max_dict_stmts, RIS_parms.max_user_stmts, RIS_max_secondary_stmts));

   CLI_DBG(("RIScli_init: RIS_max_stmts:%d\n", RIS_max_stmts));

   /*
   ** Initialize the schema file globals
   */
   RISfil_begin_globals_transaction();
   if (SETJMP())
   {
      RESETJMP();
      RISfil_globals_rollback();
   }
   else
   {
      RISfil_update_globals(schfile_parms);
      RISfil_globals_commit();
      RESETJMP();
   }

    /* initialize global dummy sdp */
   RIS_sdp = ALLOCTP(rissql);
   RIS_sdp->input = ALLOCTP(internal_sqlda);
   RIS_sdp->output = ALLOCTP(internal_sqlda);

   /* initialize usr transactions */
   RISusr_init_transact((unsigned short)(RIS_parms.max_transactions));

   /* initialize local protocol functions */
   RIScom_init_protocols(
      RIS_local_xns_addr, sizeof(RIS_local_xns_addr),
      RIS_local_tcp_addr, sizeof(RIS_local_tcp_addr),
      RIS_local_lu62_addr, sizeof(RIS_local_lu62_addr),
      RIS_local_dnp_addr, sizeof(RIS_local_dnp_addr));

    /* initialize RIS_ssmem structure */
    RIScli_init_RIS_ssmem_struct();

   CLI_DBG(("RIScli_init: complete\n"));
}

/******************************************************************************/

static void RIScli_init_RIS_ssmem_struct()
{
    int i;

    CLI_DBG(("RIScli_init_RIS_ssmem_struct()\n"));
    for( i = 0; i < RIS_MAX_OPEN_SUPERSCHEMAS; i++ )
    {
   RIS_ssmem[i] = 0;
    }
    CLI_DBG(("RIScli_init_RIS_ssmem_struct(): complete\n"));
}

/******************************************************************************/

#if defined(__clipper__) || defined(sco)
#define C2
#endif

#if defined(unix) 
static void check_username_password(
   char *username,
   char *password)
{
   char salt[3];
   char decrypt[RIS_MAX_PASSWD_SIZE];
   struct passwd *pw;
   char password_buf[81];
   int	  got_a_password = 0;

   CLI_DBG(("check_usr_passwd(username:<%s> password:<not printed>)\n",
      STRING(username)));

   if ((pw = RIScom_getpwnam(username)) == NULL)
   {
      CLI_DBG(("check_usr_passwd: RIScom_getpwnam returns null, errno %d\n",
    errno));
      LONGJMP(RIS_E_BAD_LOGIN);
   }
   /*
   ** The encrypted password may have to be obtained in different
   ** ways, so that has been isolated.
   */
   RIScom_get_password(pw, username, &got_a_password, password_buf);

   CLI_DBG(("got a password ? %s  %s\n", got_a_password ? "Yes: " : "no",
      got_a_password ? password_buf : ""));

   if (got_a_password)
   {
      if (password && *password)
      {
    RIScom_depd(password, decrypt);

    CLI_DBG(("decrypted (ris) password.<not printed> \n"));

    salt[0] = password_buf[0];
    salt[1] = password_buf[1];
    salt[2] = '\0';

    CLI_DBG(("when encrypted,  password: <%s>\n", crypt(decrypt,salt)));
    CLI_DBG(("system encrypted password: <%s>\n", password_buf));

    if (strcmp(crypt(decrypt, salt), password_buf))
    {
       LONGJMP(RIS_E_BAD_LOGIN);
    }
      }
      else
      {
    LONGJMP(RIS_E_BAD_LOGIN);
      }
   }
   else
   {
      if (password && *password)
      {
    LONGJMP(RIS_E_BAD_LOGIN);
      }
   }

   CLI_DBG(("check_usr_passwd:returning\n"));
}
#endif
#if defined(WIN32)
static void check_username_password(
   char *username,
   char *password)
{
/*   HANDLE hLogonToken; */
/*   LONG   ignore; */

/*   if (RIScom_get_platform() == IS_CHICAGO) */
      return;/*win95*/
/*
   CLI_DBG(("check_usr_passwd(username:<%s> password:<not printed>)\n",
      STRING(username) ));

   if (SecureInit() == FALSE)
	{
	   CLI_DBG(("check_usrer_password:SecureInit failed\n"));
	   LONGJMP(RIS_E_BAD_LOGIN);
	}
*/
/*   if ( ! (hLogonToken = GetLogonToken(username, "", password))) */
/*   { */
/*	   CLI_DBG(("check_usr_passwd: hLogonToken: %d\n", hLogonToken)); */
/*   	SecureClose(); */
/*	   LONGJMP(RIS_E_BAD_LOGIN); */
/*   }
   /*
   **  For now only verify Username/Password
   **  Need to Add Impersonate Remote Client User
    */
/*   else */
/*   { */
/*	   ignore = CloseHandle(hLogonToken); */
/*   } */
/*   SecureClose(); */

/*   CLI_DBG(("check_usr_passwd:returning\n")); */
}
#endif
