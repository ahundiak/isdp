#include        <stdio.h>
#include        <PDUerror.h>
#include        <string.h>
#include        <PDUproto.h>
#include        <sys/stat.h>
 

int PDUget_sun_nodename(node)
char  **node;
{
  FILE   *hostfile;
  char   *path = NULL;
  char   *nodename = NULL;
  int    status = PDM_S_SUCCESS;
  struct stat file_status;

  _pdm_debug("In the function PDUget_sun_nodename", 0);

/*
 * 20/Mar/95 - raj.
 * /etc/hostname.xxx extension is different on INTEL Solaris.
 */
#if defined (i386) && defined (__Sol2__)
  PDUfill_in_string(&path, "/etc/hostname.pcn0");
#else
  PDUfill_in_string(&path, "/etc/hostname.le0");
#endif

#if defined (i386)
  status = stat(path, &file_status);
  if (status != 0)
    {
    _pdm_debug("file <%s> was not found; check for hostname.pnt0", 0);
    PDUfill_in_string(&path, "/etc/hostname.pnt0");
    }
  status = stat(path, &file_status);
  if (status != 0)
    {
    _pdm_debug("file <%s> was not found; check for hostname.pcn0", 0);
    PDUfill_in_string(&path, "/etc/hostname.pcn0");
    }
#endif

  _pdm_debug("Path = <%s>", path);

/*
 * 20/Mar/95 - raj. Use var. 'path' instead of hardcoded string.
 */
  hostfile = fopen (path, "r");
  if (!hostfile)
    {
      /*
       * 20/Mar/95 - raj. Use var. 'path' instead of hardcoded string.
       */
    _pdm_debug("Error opening %s file", path);
    status = PDM_E_OPEN_FILE;
    return(status);
    }

  status = PDUread_refresh_file(&nodename, path, hostfile);
  if (status != PDM_S_SUCCESS)
    {
    fclose(hostfile);
    return(status);
    } 

  _pdm_debug("node name = <%s>", nodename);
  if ((nodename) && (strlen(nodename)))
    {
    PDUfill_in_string(node, nodename);
    _pdm_debug("node name (after PDUfill_in_string) = <%s>", *node);
    }
  else
    {
    status = PDM_E_WRKST_NODE;
    return(status);
    }

  return(status);
}
