/***************************************************************************
 * I/AIM
 *
 * File:        sir/VDPaimUtil.c
 *
 * Description: Some utility functions for the aim server
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimUtil.c,v $
 *      Revision 1.1.2.2  2003/06/04 18:13:42  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/17/03  ah      Creation
 ***************************************************************************/

#include <assert.h>
#include <string.h>

#include "VDPaimPostMan.h"


/* ----------------------------------------------
 * Moved from sir/VDPutil.I because of lod order issues
 */
static char AIMUser[50];
static char AIMServer[25];
static char AIMEnv[15];

/* added code Pullabhotla */
void VDPPutAimInfo(char *aim_user, char *aim_server, char *aim_env)
{
  strcpy(AIMUser,   aim_user);
  strcpy(AIMServer, aim_server);
  strcpy(AIMEnv,    aim_env);
}
/* added code Pullabhotla */
void VDPGetAimInfo(char *aim_user, char *aim_server, char *aim_env)
{
  strcpy(aim_user,   AIMUser);
  strcpy(aim_server, AIMServer);
  strcpy(aim_env,    AIMEnv);
}
void VDPGetAimName(char *server_name )
{
  strcpy (server_name, AIMServer);
}
void VDPPutAimName(char *server_name)
{
 strcpy(server_name , server_name );
}
/* ----------------------------------------------
 * Get the aim server information
 * replacement for SrVDPGetAIMInfo
 */
int VDPaimGetServerInfo(char *user, char *server, char *env)
{
  int sts,cnt;
  TVDPaimBuf buf;

  /* Arg check */
  assert(user);   *user   = 0;
  assert(server); *server = 0;
  assert(env);    *env    = 0;

  /* Request */
  sts = VDPaimPostManRequest(&buf.len,&buf.data,"d",444);
  if (sts) goto wrapup; /* Disconnect? */

  /* Extract */
  buf.iter = 0;
  VDPaimPostManExtract(buf.len,buf.data,&buf.iter,
    "dsss",&cnt,
    user,server,env);

  if (cnt == 0) {

    /* How to handle the case where the query workd ok but the data
     * was not as expected.  Do we need a put error message
     * for the routines?  Or let the calling program do the checking.
     */
    sts = 99;
    goto wrapup;
  }

  /* Store it */
  VDPPutAimInfo(user, server, env);

wrapup:
  return sts;
}
#if 0
/* ----------------------------------------------
 * Simple file type number to string
 */
void VDPaimGetFileTypeDesc(int fileType, char *desc)
{
  switch(fileType)
  {
    case VDP_ASIR_FILE_TYPE_MODEL: 
      strcpy(desc,"M"); 
      break;
    case VDP_ASIR_FILE_TYPE_DIAGRAM: 
      strcpy(desc,"D"); 
      break;
    case VDP_ASIR_FILE_TYPE_ARR: 
      strcpy(desc,"A"); 
      break;
    case VDP_ASIR_FILE_TYPE_ASM: 
      strcpy(desc,"ASM"); 
      break;
    case VDP_ASIR_FILE_TYPE_DM: 
      strcpy(desc,"DM"); 
      break;
    default:
      *desc = 0;
  }
  return;
}

/* ----------------------------------------------
 * PDU Nonsense
 */
// #include "PDUstr.h"
// #include "PDUuser.h"

extern struct PDUrefresh *refresh;
extern struct PDUuser	 *user;

/* ----------------------------------------------
 * See if the current part is checked out under pdm 
 */
IGRstat VDPaimIsPartCheckedOut()
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRint  noco = 0;
  IGRchar *p;

  IGRchar err_msg      [80];
  IGRchar io_status    [10], 
          checkin_user [30], 
          checkout_user[30],
          checkout_node[62],
	  checkout_dir[162];

  /* Make sure it's managed */
  if(*refresh->act_catalog  == 0 ||
     *refresh->act_partid   == 0 ||
     *refresh->act_revision == 0) goto wrapup;

  /* Allow override */
  p = getenv("ISDP_SIR_NOCO");
  if (p)
  {
    if (*p == '1') noco = 1;
  }
  if (noco == 1)
  {
    retFlag = 1;
    goto wrapup;
  }

  /* verify that the part is checked out */
  *io_status     = 0;
  *checkout_user = 0;
  *checkout_dir  = 0;

  VdsRetrievePartAttributes(
    refresh->act_catalog,
    refresh->act_partid, 
    refresh->act_revision, 
    io_status, 
    checkin_user, 
    checkout_user, 
    checkout_node, 
    checkout_dir, 
    err_msg);

  if (strcmp(io_status,"O") && strcmp(io_status,"S"))
  {
    goto wrapup;
  }
  if (strcmp(checkout_node, user->wrkst_node)) goto wrapup;
  if (strcmp(checkout_dir,  user->wrkst_cwd))  goto wrapup;


  /* Done */
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif
