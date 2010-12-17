/*
 * File			: PDUmlibutil.C
 * Author		: Raj Shekar Pathivada
 * Creation Date	: 02/Dec/94
 * 
 */

#include "OMminimum.h"
#include "OMparameters.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "ex.h"
#include "exdef.h"
#include "exmacros.h"

#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "acdef.h"
#include "acmacros.h"

#include "string.h"

/*
 * This function checks if a given macro library is attached and writable.
 */

PDUis_maclib_writable(char *mlibname)
{
  IGRint	ac_sts;
  struct GRid	ac_dir;
  char		lpath[512], *ptr;
  int		lpath_len;

  _pdm_debug("Enter PDUis_maclib_writable()", 0);
  
  ac_dir.objid = NULL_OBJID;

  /*
   * Check if macro library is already attached.
   */
  ac_sts = ac$construct_path ( mode = AC_INQ,
  				path = lpath,
  				path_size = 1024,
  				path_len = &lpath_len);
  _pdm_status("ac$construct_path", ac_sts);

  strcat(lpath, ",");
  ptr = strtok(lpath, ",");

  ac_sts = 1;

  while (ptr != NULL)
  {
    _pdm_debug("ptr: >%s<", ptr);
  
    if (strcmp(mlibname, ptr) == 0)
    {
      /* macro library is already attached. */

      ac_sts = ac$lib_dir(name = mlibname, dir = &ac_dir);
      _pdm_status("ac$lib_dir", ac_sts);

      if (!(ac_sts & 1)) return(ac_sts);

      /* Fails if macro library is attached as READ-ONLY. */
      ac_sts = ac$construct_wd ( mode = AC_SET,
                        name = mlibname,
                        dir  = &ac_dir);
      _pdm_status("ac$construct_wd", ac_sts);
      
      break;
    }
 
    ptr = strtok(NULL, ",");
  }
  
  _pdm_debug("Exit PDUis_maclib_writable()", 0);

  return(ac_sts);
}

