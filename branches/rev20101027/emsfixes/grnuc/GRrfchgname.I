/* $Id: GRrfchgname.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc / GRrfchgname.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRrfchgname.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


/*
     CHANGE HISTORY:
	
	HGB     12/16/92: Design date.
	rmn     06/18/94: Introduced tmp_name for old name

--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This module changes the name of a reference file attachment 
	(not the mount name!).

*/

class implementation GRreffile;

#include "grerr.h"
#include "msdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "gocmacros.h"

method GRchgname ( long *pStatus; struct GRmd_env *pModuleEnvironment; char *Name )
{
  long OMStatus, Status;
  char OldName [DI_PATH_MAX], NewName [DI_PATH_MAX];
  char tmp_name[DI_PATH_MAX];

  *pStatus = MSSUCC;
  OMStatus = OM_S_SUCCESS;

  Status = di$untranslate ( objname = OldName, objid = my_id );
  DIstmocpy ( NewName, "ref", "refnames", Name, NULL, OM_Gw_current_OS );

  if( Status == DIR_S_SUCCESS )
	strcpy( tmp_name, OldName );
  else
	strcpy( tmp_name, "");
/*
  Status = di$rename ( oldname = Status == DIR_S_SUCCESS ? OldName : NULL, 
      newname = NewName );
*/
  Status = di$rename ( oldname = tmp_name, newname = NewName );
  if (Status == DIR_E_NAME_DUP)
  {
    *pStatus = GR_E_INV_REQUEST;
    OMStatus = OM_E_ABORT;
  }
  else 
    if (Status != DIR_S_SUCCESS)
    {
      *pStatus =  MSFAIL;
      OMStatus = OM_E_ABORT;
    }

  GR_NOTIFY_LISTENERS ( pStatus, &OMStatus, GR_ATTR_MODIFIED );

  return OMStatus;
}

end implementation GRreffile;

