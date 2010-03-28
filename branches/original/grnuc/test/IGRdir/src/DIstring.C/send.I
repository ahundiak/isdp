class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

main21 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_send( dirname, objname, bad )
          DIchar *dirname;
          DIchar *objname;
          DIint bad;
/*
   This routine is supposed to test the add name ( add_name ) feature.
   The input is a directory name (full path name or base name), the objid
   of the name to be added to the directory subsystem, and the bad code
   for input ( good = 0 ).
*/
/*.tst_send */
{
  DIint      count, status;
  DIobjid    dirid, dirid2, bidon1, bidon2, bidon3;
  DIspacenum osnum, osnum2;
  DIint      om_status;
  DIchar     name [DI_PATH_MAX], tmp [DI_PATH_MAX];

  /*"dirname : '%s', objname : '%s'\n", dirname, objname */

  if (bad == 0)      /*   Good input from add.in   */

  {

  /*|mkdir */
  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$mkdir is wrong", sts = status);

  /*|cd */
  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd is wrong", sts = status);

  /*|pwd */
  status = di$pwd ( p_osnum = &osnum );

  /*|construct */
  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon2 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &bidon3 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  /*|add_name */
  /*- */
  sprintf ( name, "first%s", objname );
  status = di$add_name ( objname = name, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$add_name (1) is wrong", sts = status);
  sprintf ( name, "second%s", objname );
  status = di$add_name ( objname = name, objid = bidon2, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$add_name (2) is wrong", sts = status);
  sprintf ( name, "third%s", objname );
  status = di$add_name ( objname = name, objid = bidon3, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$add_name (3) is wrong", sts = status);

  /*"send to %d, '%s'\n", osnum, name */
  sprintf ( name, "first%s", objname );
  status = di$send ( msg = message Root.delete ( 1 ),
                     senderid = NULL_OBJID, targetname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (9)" );
  sprintf ( name, "second%s", objname );
  status = di$send ( msg = message Root.delete ( 1 ),
                     senderid = NULL_OBJID, targetname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (9)" );
  sprintf ( name, "third%s", objname );
  status = di$send ( msg = message Root.delete ( 1 ),
                     senderid = NULL_OBJID, targetname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (9)" );
  status = di$cd ( dirname = ".." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "cd ( .. )" );
  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "rmdir" );
  }
  else /* bad == 1 */
  {
    /*|send the message to objects that don't exist */
    status = di$send ( msg = message Root.debug (),
                       targetname = dirname, senderid = NULL_OBJID );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts     = status,
                        comment = "tst_send: send should fail" );
  }

  return DIR_S_SUCCESS;
}


end implementation Root;
