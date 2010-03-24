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



tst_add ( dirname, objname, bad )
          DIchar *dirname;
          DIchar *objname;
          DIint bad;
/*
   This routine is supposed to test the add name ( add_name ) feature.
   The input is a directory name (full path name or base name), the objid
   of the name to be added to the directory subsystem, and the bad code
   for input ( good = 0 ).
*/
/*.tst_add */
{
  DIint      status;
  DIobjid    dirid, dirid2, bidon1;
  DIspacenum osnum, osnum2;
  DIint      om_status;

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
                            classname = "tst_dir",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  {
    DIchar  name [PATH_MAX];
    DIint   i;
    DIobjid objid;
    /*|add some names and remove them */
    
    for (i = 0; i < 10; i++)
    {
      /*|construct */
      om_status = om$construct( osnum     = osnum,
                                classname = "tst_dir",
                                p_objid   = &objid ); 
      if (om_status != OM_S_SUCCESS)
        om$report_error ( sts = om_status );

      sprintf ( name, "%s%d", objname, i );
      status = di$add_name ( objname = name, objid = objid );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status,
                          comment = "tst_add: add_name for rm_name" );
    }

    sprintf ( name, "%s*", objname );
    status = di$rm_name ( regexp = name, number = -1 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_add: rm_name ( ...* )" );

    status = di$translate ( regexp = name, p_objid = &objid );
    if (status == DIR_S_SUCCESS)
    {
      printf ( "tst_add: problem with rm_name\n" );
      /*-*/
    }
  }

  /*|add_name */
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_add : di$add_name (1) is wrong",
                      sts     = status);

  status = di$rm_name ( regexp = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_add : di$rm_name is wrong", sts = status);

  status = di$add_name ( objname = objname, path = dirname,
                         objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_add : di$add_name (1.1) is wrong",
                      sts     = status);

  status = di$rm_name ( regexp = objname, path = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_add : di$rm_name is wrong", sts = status);

  {
    DIchar tmp [PATH_MAX], name [PATH_MAX];

    status = di$split ( pathname = dirname, name = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, 
                        comment = "tst_add: di$split" );

    DIstrcpy ( name, tmp );
    DIstrcat ( name, objname );
    status = di$add_name ( objname = name, osnum = osnum, objid = bidon1, 
                           p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_add : di$add_name (2) is wrong",
                        sts     = status);
  }

  /*- after add_name */
  /*|cd */
  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd : is wrong", sts = status);

  /*|rmdir */
  status = di$rmdir ( dirname = dirname );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rmdir is wrong", sts = status);

  /*|cd */
  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd is wrong", sts = status);

  /*|rm_objid */
  status = di$rm_objid ( osnum = osnum, objid = bidon1 );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rm_objid is wrong", sts = status);

#if 0
  status = di$rm_name ( regexp = objname );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rm_name is wrong", sts = status);
#endif

  /*|cd */
  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd : is wrong", sts = status);

  /*|rmdir */
  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rmdir is wrong", sts = status);


  }

  else          /*  Bad input from add_bad.in   */

  {
  /*|mkdir */
  status = di$mkdir ( dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
  if (status != DIR_S_SUCCESS)
   di$report_error (comment = "tst_add : di$mkdir_1 is wrong",sts=status);

  /*|cd */
  status = di$cd ( dirname = dirname, p_dirid = &dirid2, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd is wrong", sts = status);

  /*|pwd */
  status = di$pwd ( p_dirid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_add : di$pwd is wrong", sts = status );

  /*|construct */
  om_status = om$construct( osnum     = osnum,
                            classname = "tst_dir",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  /*|add_name */
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$add_name is wrong", sts = status);

  /*|add_name */
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$add_name is wrong", sts = status);

  /*|add_name */
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$add_name is wrong", sts = status);

  /*|rm_objid */
  status = di$rm_objid ( osnum = osnum, objid = bidon1 );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rm_objid is wrong", sts = status);

  /*|rm_objid */
  status = di$rm_objid ( osnum = osnum, objid = dirid );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rm_objid is wrong", sts = status);

  /*|cd */
  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd : is wrong", sts = status);

  /*|pwd */
  status = di$pwd ( p_dirid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_add : di$pwd is wrong", sts = status );

  /*|rm_objid */
  status = di$rm_objid ( osnum = osnum, objid = dirid );
  if (status == DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rm_objid is wrong", sts = status);

  /*|cd */
  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$cd : is wrong", sts = status);

  /*|rmdir */
  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_add : di$rmdir is wrong", sts = status);

  /*|remove a name that does not exist */
  status = di$rm_name ( regexp = "this name doesn't exist in any directory" );
  if (status == DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "bad rm_name" );
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
