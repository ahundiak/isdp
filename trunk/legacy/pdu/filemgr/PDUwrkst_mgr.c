#include        <pwd.h>
#include        <stdio.h>
#include        <PDUuser.h>
#include        <PDUerror.h>
#include        <PDUintdef.h>
#include        <PDUfile_def.h>
#include        <MEMstruct.h>
#include        <MEMerrordef.h>
#include 	<sys/types.h>
#include 	<sys/stat.h>
#include 	<sys/utsname.h>
#include 	<errno.h>
#include        "PDUproto.h"
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
#include        "NFMerrordef.h"
#include        "DEBUG.h"
#endif

extern int PDMdebug_on;

int PDUprocess_wrkst_info()
{
    char                        *cwd;
    char                        node[512];
    char                        *PDUgetcwd();
    extern struct PDUuser       *user;
    char                        *remote_path;
    char                        *remote_node;
    char                        *get_remote_path();
    int                         status = PDM_S_SUCCESS;
    struct passwd               *user_info;
    unsigned short              getuid();
    auto    struct  utsname name;
#if defined (sparc) || defined (__sgi) || defined (__Sol2__)
    char                        *nodename = NULL;
#endif

  _pdm_debug("In the function PDUprocess_wrkst_info", 0);

  user_info = (struct passwd *) malloc ( sizeof(struct passwd));

  user_info = getpwuid(getuid());

  user->wrkst_username = user_info->pw_name;
  PDUfill_in_string(&user->wrkst_passwd, "");

/* 12/1/95 MJG - Use getenv instead 
  cwd = PDUgetcwd((char *)NULL, 64);
*/
  cwd = ((char *)getenv ("PWD"));

  _pdm_debug("getenv $PWD returns <%d>", (char *)cwd);
  _pdm_debug("cwd = <%s>", cwd);

  if ((!cwd) || (strcmp(cwd,"") ==0))
    return(PDM_E_WRKST_CWD);

  remote_path = get_remote_path(cwd, &remote_node);

  _pdm_debug("nodename = <%s>", remote_node);
  if (isdigit(remote_node[0]))
    return(PDM_E_DIGIT_IN_NODENAME);

  if ((remote_path) && (strlen(remote_path) > 0) && (remote_path != 0))
    {
     _pdm_debug("remote_path = <%s>", remote_path);
     _pdm_debug("remote_node = <%s>", remote_node);

     PDUfill_in_string(&user->wrkst_cwd, remote_path);
     _pdm_debug("user->wrkst_cwd = <%s>", user->wrkst_cwd);
     PDUfill_in_string(&user->wrkst_node, remote_node);
     return(PDM_S_SUCCESS);
    }

/* Vasu 21.2.92 - Alternative mechanism to get the local node name */

/* 20/Mar/95 - raj. changed sparc to __Sol2__	*/
/* #if defined (sparc) */
#if defined (__Sol2__)

  status = PDUget_sun_nodename ( &nodename );
  _pdm_status("PDUget_sun_nodename", status);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(PDM_E_WRKST_NODE);
    }

  _pdm_debug("Nodename = <%s>", nodename);
  _pdm_debug("cwd = <%s>", cwd);
 
  PDUfill_in_string(&user->wrkst_cwd, cwd);
  _pdm_debug("user->wrkst_cwd = <%s>", user->wrkst_cwd);
  PDUfill_in_string(&user->wrkst_node, nodename);

#else

/* Vasu 21.02.92 - End addition */

  /* change this call to prevent multiple nodenames 
  status = clh_vbyop("template", "Nodename", node, 512);

  _pdm_debug("clh_vbyop returns status = <%d>", status); */

  /*  Get the name of the client (this machine)  */

  if ((status = uname (&name)) < 0)
    {
      _pdm_debug ("uname = <%d>\n", (char *)status);
      _pdm_debug ("errno = <%d>\n", (char *)errno);
      _pdm_debug ("error retrieving workstation nodename", 0);
      return (PDM_E_WRKST_NODE);
    }

  strcpy (node, name.nodename);
  _pdm_debug("Nodename = <%s>", node);

  if (status)
    {
      _pdm_debug("clh_vbyop returns status = <%d>", (char *)status);
      return(PDM_E_WRKST_NODE);
    }
  else
    {
      _pdm_debug("cwd = <%s>", cwd);
      _pdm_debug("node = <%s>", node);

      PDUfill_in_string(&user->wrkst_cwd, cwd);
      _pdm_debug("user->wrkst_cwd = <%s>", user->wrkst_cwd);
      PDUfill_in_string(&user->wrkst_node, node);
    }
#endif

  return(PDM_S_SUCCESS);
}
