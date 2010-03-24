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


from dummy import test_pass;


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
  DIchar     name [PATH_MAX], tmp [PATH_MAX];

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
                            classname = "dummy",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct( osnum     = osnum,
                            classname = "dummy",
                            p_objid   = &bidon2 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct( osnum     = osnum,
                            classname = "dummy",
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

  /*|send the message test_pass */
  /*- */
  count = 0;
  sprintf ( name, "first%s", objname );
  status = di$send ( msg = message dummy.test_pass ( &count ),
                     senderid = NULL_OBJID, targetname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (1)" );
  sprintf ( name, "second%s", objname );
  status = di$send ( msg = message dummy.test_pass ( &count ),
                     senderid = NULL_OBJID, targetname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (2)" );
  sprintf ( name, "third%s", objname );
  status = di$send ( msg = message dummy.test_pass ( &count ),
                     senderid = NULL_OBJID, targetname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (3)" );
  if (count != 3)
    fprintf ( stderr, "tst_send: count should be 3\n" );

  status = di$cd ( dirname = DIR_G_str_dir );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "cd ( : )" );

  /*"try with targetos (%d)\n", osnum */
  /*- */
  count = 0;
  status = di$split ( pathname = dirname, name = tmp );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: split" );

  sprintf ( name, "%s:first%s", tmp, objname );
  /*"send to %d, '%s'\n", osnum, name */
  status = di$send ( msg = message dummy.test_pass ( &count ),
                     senderid = NULL_OBJID, targetname = name, targetos = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (4)" );
  sprintf ( name, "%s:second%s", tmp, objname );
  /*"send to %d, '%s'\n", osnum, name */
  status = di$send ( msg = message dummy.test_pass ( &count ),
                     senderid = NULL_OBJID, targetname = name, targetos = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (5)" );
  sprintf ( name, "%s:third%s", tmp, objname );
  /*"send to %d, '%s'\n", osnum, name */
  status = di$send ( msg = message dummy.test_pass ( &count ),
                     senderid = NULL_OBJID, targetname = name, targetos = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (6)" );
  if (count != 3)
    fprintf ( stderr, "tst_send: count should be 3\n" );

  sprintf ( name, "%s:first%s", tmp, objname );
  /*"send to %d, '%s'\n", osnum, name */
  status = di$send ( msg = message dummy.delete ( 1 ),
                     senderid = NULL_OBJID, targetname = name, targetos = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (7)" );
  sprintf ( name, "%s:second%s", tmp, objname );
  /*"send to %d, '%s'\n", osnum, name */
  status = di$send ( msg = message dummy.delete ( 1 ),
                     senderid = NULL_OBJID, targetname = name, targetos = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (8)" );
  sprintf ( name, "%s:third%s", tmp, objname );
  /*"send to %d, '%s'\n", osnum, name */
  status = di$send ( msg = message dummy.delete ( 1 ),
                     senderid = NULL_OBJID, targetname = name, targetos = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_send: di$send (9)" );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "cd ( - )" );
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
    status = di$send ( msg = message dummy.test_pass ( &count ),
                       targetname = dirname, senderid = NULL_OBJID );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts     = status,
                        comment = "tst_send: send should fail" );
  }

  return DIR_S_SUCCESS;
}


end implementation Root;
