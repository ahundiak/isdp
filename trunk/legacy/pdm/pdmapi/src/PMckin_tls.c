#include	<string.h>
#include	<ctype.h>
#include	<time.h>
#include	<unistd.h>
#include	<PDUintdef.h>
#include	<PDUstorage.h>
#include        <MEMerrordef.h>
#include        <FI.h>
#include        <PDUforms.h>
#include        <PDUfile_def.h>
#include        <PDUuser.h>
#include        <PDUproto.h>
#include        <PDMproto.h>
#include        <sys/types.h>
#include        <sys/param.h>
#include        <sys/stat.h>

int pdmoObjectSpaceInfoForCheckin(filename)

char *filename;
  {
  char            path[MAXPATHLEN];
  char            new_name[MAXPATHLEN];
  char            command[MAXPATHLEN];
  char            *c = NULL;
  char            *ingrhome = NULL;
  FILE            *fp;
  extern          MEMptr PDU_file_bufr;

  _pdm_debug("In pdmoObjectSpaceInfoForCheckin", 0);
  if (filename == NULL)
    {
    _pdm_debug("exiting:  filename is blank", 0);
    return(PDM_E_FILENAME_BLANK);
    }
  else if (strcmp(filename, "") == 0)
    {
    _pdm_debug("exiting:  filename is blank", 0);
    return(PDM_E_FILENAME_BLANK);
    }

  _pdm_debug("filename = <%s>", filename);
  path[0] = NULL;
  command[0] = NULL;
  _pdm_debug("creating path", 0);
  ingrhome = (char *)getenv("INGRHOME");
  strcpy(path, "");
  sprintf(path, "%s/ems/bin/ems", ingrhome);
  _pdm_debug("calling function access", 0);
  if (access(path, X_OK) != 0)
    {
    _pdm_debug("access failed", 0);
    return(PDM_E_FAILURE);
    }
  _pdm_debug("generating c", 0);
  c = (c = (char *)getenv("TMPDIR")) ? c : "/usr/tmp";
  _pdm_debug("generating new_name", 0);
  sprintf(new_name, "%s/chkinprtXXXXXX", c);
  _pdm_debug("making new_name", 0);
  _pdm_debug("new_name = %s", new_name);
  mktemp(new_name);
  _pdm_debug("generating command", 0);
  sprintf(command, "%s -f %s -b -C \"\\\"ci=api_ckin\\\"\"",path, filename);
  _pdm_debug("command = <%s>", command);
  if ((fp = (FILE *)popen(command, "r")) == NULL)
    {
    _pdm_debug("p_open failed", 0);
    return(PDM_E_FAILURE);
    }
  else
    {
    path[0] = NULL;
    c = new_name;
    while (fgets(c, sizeof(new_name), fp))
      {
      if ((strlen(c) + strlen(path)) < MAXPATHLEN)
        {
        strcat(path, c);
        }
      }
    /*if (pclose(fp) != 0)
      {
      _pdm_debug("pclose failed", 0);
      return(PDM_E_FAILURE);
      }*/
    }

  return(PDM_S_SUCCESS);
  }

int pdmoObjectSpaceInfoForCheckout()

  {
  char            path[MAXPATHLEN];
  char            new_name[MAXPATHLEN];
  char            command[MAXPATHLEN];
  char            *c = NULL;
  char            *ingrhome = NULL;
  FILE            *fp;
  extern          MEMptr PDU_file_bufr;

  _pdm_debug("In pdmoObjectSpaceInfoForCheckout", 0);

  path[0] = NULL;
  command[0] = NULL;
  _pdm_debug("creating path", 0);
  ingrhome = (char *)getenv("INGRHOME");
  strcpy(path, "");
  sprintf(path, "%s/ems/bin/ems", ingrhome);
  _pdm_debug("calling function access", 0);
  if (access(path, X_OK) != 0)
    {
    _pdm_debug("access failed", 0);
    return(PDM_E_FAILURE);
    }
  _pdm_debug("generating c", 0);
  c = (c = (char *)getenv("TMPDIR")) ? c : "/usr/tmp";
  _pdm_debug("generating new_name", 0);
  sprintf(new_name, "%s/chkoutprtXXXXXX", c);
  _pdm_debug("making new_name", 0);
  _pdm_debug("new_name = %s", new_name);
  mktemp(new_name);
  _pdm_debug("generating command", 0);
  sprintf(command, "%s -f %s -b -C \"\\\"ci=api_ckout\\\"\"",path, "PDUdummy");
  _pdm_debug("command = <%s>", command);
  if ((fp = (FILE *)popen(command, "r")) == NULL)
    {
    _pdm_debug("p_open failed", 0);
    return(PDM_E_FAILURE);
    }
  else
    {
    path[0] = NULL;
    c = new_name;
    while (fgets(c, sizeof(new_name), fp))
      {
      if ((strlen(c) + strlen(path)) < MAXPATHLEN)
        {
        strcat(path, c);
        }
      }
    /*if (pclose(fp) != 0)
      {
      _pdm_debug("pclose failed", 0);
      return(PDM_E_FAILURE);
      }*/
    }

  return(PDM_S_SUCCESS);
  }
  
int pdmoObjectSpaceInfoForCancelPartCheckout()

  {
  char            path[MAXPATHLEN];
  char            new_name[MAXPATHLEN];
  char            command[MAXPATHLEN];
  char            *c = NULL;
  char            *ingrhome = NULL;
  FILE            *fp;
  extern          MEMptr PDU_file_bufr;

  _pdm_debug("In pdmoObjectSpaceInfoForCancelPartCheckout", 0);

  path[0] = NULL;
  command[0] = NULL;
  _pdm_debug("creating path", 0);
  ingrhome = (char *)getenv("INGRHOME");
  strcpy(path, "");
  sprintf(path, "%s/ems/bin/ems", ingrhome);
  _pdm_debug("calling function access", 0);
  if (access(path, X_OK) != 0)
    {
    _pdm_debug("access failed", 0);
    return(PDM_E_FAILURE);
    }
  _pdm_debug("generating c", 0);
  c = (c = (char *)getenv("TMPDIR")) ? c : "/usr/tmp";
  _pdm_debug("generating new_name", 0);
  sprintf(new_name, "%s/chkoutprtXXXXXX", c);
  _pdm_debug("making new_name", 0);
  _pdm_debug("new_name = %s", new_name);
  mktemp(new_name);
  _pdm_debug("generating command", 0);
  sprintf(command, "%s -f %s -b -C \"\\\"ci=api_canckout\\\"\"",path, "PDUdummy");
  _pdm_debug("command = <%s>", command);
  if ((fp = (FILE *)popen(command, "r")) == NULL)
    {
    _pdm_debug("p_open failed", 0);
    return(PDM_E_FAILURE);
    }
  else
    {
    path[0] = NULL;
    c = new_name;
    while (fgets(c, sizeof(new_name), fp))
      {
      if ((strlen(c) + strlen(path)) < MAXPATHLEN)
        {
        strcat(path, c);
        }
      }
    /*if (pclose(fp) != 0)
      {
      _pdm_debug("pclose failed", 0);
      return(PDM_E_FAILURE);
      }*/
    }

  return(PDM_S_SUCCESS);
  }
