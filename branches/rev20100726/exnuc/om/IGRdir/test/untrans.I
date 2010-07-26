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

#define MAX 5

tst_untrans ( dirname, bad )
              DIchar *dirname					  /* IN  */;
              DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the untranslate feature.
   The input is a directory name (full path name or base name), and the code
   type to specify the input type ( good = 0 ).
*/
/*.tst_untrans*/
{
  DIint      i, status, om_status;
  DIobjid    dirid, dirid2, bidon1, objids [MAX];
  DIspacenum osnum;
  DIchar     objname [PATH_MAX];
  DIchar     path [11];

  /*"dirname : '%s'\n", dirname */
  if (bad == 0)      /*   Good input from trans.in   */

  {
    /*|make the directory */
    status = di$mkdir ( dirname = dirname, p_dirid = &dirid2, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$mkdir is wrong", sts = status );

    /*|cd into it */
    status = di$cd ( dirname = dirname, p_dirid = &dirid2, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$cd is wrong", sts = status );

    /*|construct a dummy */
    om_status = om$construct( osnum     = osnum,
                              classname = "dummy",
                              p_objid   = &bidon1 ); 
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );

    /*|let's give names */
    strcpy ( objname, "first" );
    status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment="tst_untrans : di$add_name is wrong", sts = status);
    strcpy ( objname, "second" );
    status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment="tst_untrans : di$add_name is wrong", sts = status);
    strcpy ( objname, "third" );
    status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment="tst_untrans : di$add_name is wrong", sts = status);

    /*|untranslate - translate - rm name */
    /*- */
    for (i = 0; i < 3; i++)
    {
      DIspacenum loc_os;
      DIobjid    loc_id;

      status = di$untranslate( objname = objname, objid = bidon1,
                               index = 0, osnum = osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_untrans : di$untranslate is wrong",
                          sts = status );

      status = di$translate( regexp = objname, p_objid = &loc_id,
                             p_osnum = &loc_os );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_untrans : di$translate is wrong",
                          sts = status );
      else
        if ((loc_os != osnum) || (loc_id != bidon1))
          printf ( "trans-untrans compatibility problem\n" );

      status = di$rm_name ( regexp = objname );
      if (status != DIR_S_SUCCESS)
        di$report_error (comment = "tst_untrans : di$rm_name is wrong", sts = status);
    }

    /*|untranslate bidon */
    status = di$untranslate( objname = objname, objid = bidon1,
                             osnum = osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$untranslate shoul be wrong",
                        sts = status );

    /*|bad untranslate (1) */
    status = di$untranslate( objname = objname, objid = bidon1,
                             osnum = 329472 );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$untranslate shoul be wrong",
                        sts = status );

    /*|bad untranslate (2) */
    status = di$untranslate( objname = objname, objid = bidon1,
                             osnum = -4 );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$untranslate shoul be wrong",
                        sts = status );

    /*|construct some dummy */
    for (i = 0; i < MAX; i++)
    {
      om_status = om$construct( osnum     = osnum,
                                classname = "dummy",
                                p_objid   = &objids [i] ); 
      if (om_status != OM_S_SUCCESS)
        om$report_error ( sts = om_status );

      sprintf ( objname, "first_%d", i );
      status = di$add_name ( objname = objname, 
                             objid = objids [i], p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error (comment="tst_untrans : di$add_name is wrong", sts = status);
    }

    for (i = 0; i < MAX; i++)
    {
      DIspacenum loc_os;
      DIobjid    loc_id;

      status = di$untranslate( objname = objname, objid = objids [i],
                               index = 0, osnum = osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_untrans : di$untranslate is wrong",
                          sts = status );

      status = di$translate( regexp = objname, p_objid = &loc_id,
                             p_osnum = &loc_os );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_untrans : di$translate is wrong",
                          sts = status );
      else
        if ((loc_os != osnum) || (loc_id != objids [i]))
          printf ( "trans-untrans compatibility problem\n" );

      om_send_for ( Root.delete ( 1 ), NULL_OBJID, objids [i], osnum );

      status = di$untranslate( objname = objname, objid = objids [i],
                               index = i, osnum = osnum );
      if (status == DIR_S_SUCCESS)
        di$report_error ( comment = "tst_untrans : di$untranslate shoul be wrong",
                          sts = status );
    }

    /*|clean ... */
    /*|cd into it */
    status = di$cd ( dirname = ".." );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$cd ( .. ) is wrong",
                        sts = status );

    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$rmdir is wrong",
                        sts = status );

    status = di$mkdir ( dirname = ":transient:literal", p_dirid = &dirid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$mkdir wrong", sts=status );

    strcpy ( path, ":transient" );
    status = di$untranslate ( objname =  objname,
			      objid   =  dirid,
			      path    =  path );
    if (status != DIR_S_SUCCESS)
       di$report_error ( comment = "tst_untrans", sts = status );
    if ( strcmp ( path, ":transient" ) )
       printf ( "tst_untrans, corrupted path\n" );

    status = di$rmdir ( dirname = ":transient:literal" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_untrans : di$rmdir wrong", sts=status );

  }
  else          /*  Bad input from trans_bad.in   */
  {
    DIint  status, i;
    DIchar objname [PATH_MAX];

    for (i = 100; i < 200; i++)
    {
      status = di$untranslate ( objid = 1, osnum = i, objname = NULL );
      if (status == DIR_S_SUCCESS)
        di$report_error ( sts = status,
                          comment = "tst_untrans: untranslate should fail\n" );
    }

    /*|check that the good still works */
    tst_untrans ( dirname, 0 );

    for (i = 1000; i < 1100; i++)
    {
      status = di$untranslate ( objid = i, osnum = 1, objname = NULL );
      if (status == DIR_S_SUCCESS)
        di$report_error ( sts = status,
                          comment = "tst_untrans: untranslate should fail\n" );
    }

    /*|check that the good still works */
    tst_untrans ( dirname, 0 );

    /* try bad start + fetch untranslate */
    status = di$start_untrans ( objid = -1, osnum = 1 );
    if (status != DIR_W_NAME_NOT_FOUND)
      printf ( "start untranslate: bad error status\n" );
    status = di$fetch_untrans ( index = 0, objname = objname );
    if (status != DIR_W_NAME_NOT_FOUND)
      printf ( "untranslate: bad error status\n" );
  }

    return DIR_S_SUCCESS;
}

end implementation Root;
