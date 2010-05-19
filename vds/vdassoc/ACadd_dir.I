/* $Id: ACadd_dir.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/ACadd_dir.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ACadd_dir.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/29  22:47:46  pinnacle
# TR179701965 Macro Naming
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 *      10/29/97  ah      TR179701965 Macros not getting named properly
 *         when placed in directory other than current directory
 *         problem with di$translate, need to cd first
 *
 ***************************************************************************/

/*
  ACncpxi.I
  robert patience
  1 sept 1989
*/
class implementation ACncpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();


#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 
#include "DIomac.h" /*DIcheck_link DIfree*/
#include "exdef.h"
#include "exmacros.h"
#include "grownerdef.h"
#include "grownmacros.h"

extern GRclassid OPP_ASsource_class_id;

from ACcpx_defn import 	 ACgive_feet_desc;

IGRlong DIadd_dir ( osnum, objid, name, add )
            DIspacenum osnum	/* Object osnum				IN  */;
            DIobjid    objid	/* Object id				IN  */;
            DIchar     *name	/* Name of the link			IN  */;
            DIint      add	/* To add or not to add the name	IN  */;
/* This procedure is used to add a directory tree to the hieararchy. */
{
  IGRlong    retFlag = 0;

  DIint      status,msg;
  DIspacenum loc_osnum;

  DIchar  path_name [DI_PATH_MAX], 
          base_name [DI_PATH_MAX], 
          dir_name  [DI_PATH_MAX];
  DIgrid  target_grid;

  /* check OS */
  status = di$give_osnum ( pathname = name, p_osnum = &loc_osnum );

  if (status != DIR_S_SUCCESS) goto wrapup;
  if (osnum  != loc_osnum)     goto wrapup;

  /* Split names */
  DIexpanse( name, path_name );
  di$split ( pathname = path_name, dirname = dir_name, name = base_name );
 
  // TR179701965
  // Don't know what the problem is but skip it
  // status = DImasterRetrieve ( &msg, dir_name, NULL, (DIchar *)&target_grid, NULL, NULL );
  //
  target_grid.objid = NULL_OBJID;
  di$translate(
    objname = dir_name,
    p_osnum = &target_grid.osnum,
    p_objid = &target_grid.objid
  );
  if (target_grid.objid == NULL_OBJID) {
    printf("Could not find directory: '%s'\n",dir_name);
    goto wrapup;
  }

  /* add it to the directory */
  if (add) {
        
    /* add in dir AND untree */
    status = om$send(
      msg = message IGRdir.add(&msg, base_name, objid, NULL),
      senderid = NULL_OBJID,
      targetid = target_grid.objid,
      targetos = target_grid.osnum
    );

  }
  retFlag = 1;

wrapup:

  return retFlag;
}

end implementation ACncpx;
