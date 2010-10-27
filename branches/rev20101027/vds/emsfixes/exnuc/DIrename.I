/* $Id: DIrename.I,v 1.2 2001/01/13 00:41:56 hans Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:        emsfixes/exnuc/DIrename.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: DIrename.I,v $
 *	Revision 1.2  2001/01/13 00:41:56  hans
 *	SP16 modifications
 *	
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/12/00   adz          File Creation
 *************************************************************************/
/*
  ABSTRACT :
  --------

   This file contains the programmer DIinterface.
   The correction in DIrename()  is introduced for I/VDS  against the
   TR#179600963  -Ravi 03/21/96



*/

class implementation DIrectory;

#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIprims.h"
#include "DIdef.h"
#include "DIomac.h"

extern	GRclassid	OPP_ACcpx_class_id ;


#argsused

DIrename ( full_name, target_name, target_grid, base_name, base_objid,
           new_name, p_objid, p_osnum )
           DIchar     *full_name	/* Full path name		IN  */;
           DIchar     *target_name	/* Directory name		IN  */;
           DIgrid     target_grid	/* Directory grid		IN  */;
           DIchar     *base_name	/* Base name to be translated	IN  */;
           DIobjid    base_objid	/* Objid object			IN  */;
           DIchar     *new_name		/* New object name		IN  */;
           DIobjid    *p_objid		/* Pointer to object objid	OUT */;
           DIspacenum *p_osnum		/* Pointer to object osnum	OUT */;
/*
   This function is used to rename an named object.  Note that a directory
   CANNOT be renamed.
*/
{
  DIint status;

  if (base_objid == NULL_OBJID)
    return DIR_W_NAME_NOT_FOUND;

  if (DIancestry_valid ( target_grid.osnum, base_objid, DIR_G_IGRdir_clid ))
  {
    if (new_name)
      if (*new_name)
      { if ((status = di$link ( objname  = full_name,
                                newname  = new_name )) == DIR_S_SUCCESS)
          status = di$rmdir ( dirname = full_name ); }
      else
        status = DIR_E_INVARG;
    else{
      OMuword	subclassid ;
      if( ( 1 & om$get_classid( objid           = base_objid,
                                osnum           = target_grid.osnum,
                                p_classid       = &subclassid ) )
        &&      om$is_ancestry_valid(
                                superclassid    = OPP_ACcpx_class_id,
                                subclassid      = subclassid
)==OM_S_SUCCESS){
        om_send_for ( IGRdir.remove ( &status, base_name, 0 ),
                        NULL_OBJID, target_grid.objid, target_grid.osnum );
        status = DIR_S_SUCCESS;
      }
      else
        status = DIR_E_INVARG;
    }
  }
  else
  {
    /* make sure that name is in there */
    om_send_for ( IGRdir.translate ( &status, base_name, 0, NULL, NULL ),
                  NULL_OBJID, target_grid.objid, target_grid.osnum );
    if (status == DIR_S_SUCCESS)
    {
      /* make sure we have the right to modify that directory */
      om_send_for ( GRoups.validate ( &status, DIR_R_WRITE ),
                    NULL_OBJID, target_grid.objid, target_grid.osnum );
      if (status == DIR_S_SUCCESS)
      {
        if (new_name)
        {
          DIchar full_name [DI_PATH_MAX];

          if ((status = DIexpanse ( new_name, full_name )) == DIR_S_SUCCESS)
            status = di$add_name ( objname = full_name, objid = base_objid
);
        }
        if (status == OM_S_SUCCESS)
          om_send_for ( IGRdir.remove ( &status, base_name, 0 ),
                        NULL_OBJID, target_grid.objid, target_grid.osnum );
      }
    }
  }

  return status;
}

end implementation DIrectory;

