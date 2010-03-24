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

tst_cd ( dirname, objname, bad )
            DIchar *dirname;
            DIchar *objname;
	    DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the cd directory feature.
*/
{
  int        Count;
  DIint      i, status, om_status;
  DIobjid    dirid, dirid2, bidon1;
  DIspacenum osnum, osnum2;
  DIchar     **lines;
  DIchar     dirname2 [PATH_MAX];
  DIgrid     *grids;

  if (bad == 0)      /*   Good input from cd.in   */

  {

  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$mkdir is wrong", sts = status );

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$cd is wrong", sts = status );

  status = di$pwd ( dirname = dirname2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$pwd is wrong", sts = status );

  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_cd : cd ':transient' is wrong",sts = status);

  status = di$pwd ( dirname = dirname2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$pwd is wrong", sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_cd : di$cd '-' is wrong",sts = status);

  status = di$pwd ( dirname = dirname2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$pwd is wrong", sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_cd : di$cd '-' is wrong",sts = status);

  status = di$pwd ( dirname = dirname2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$pwd is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$rmdir is wrong", sts = status );

  status = di$cd ( dirname = "-" );
  if (status == DIR_S_SUCCESS)
   di$report_error(comment = "tst_cd : di$cd '-' is wrong",sts = status);

  /* added these after the new search path code */

  status = di$mkdir ( dirname = ":transient:testing" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$mkdir error", sts = status );

  status = di$cd ( dirname = ":transient:testing" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 1 di$cd error", sts = status );

  status = di$cd ( dirname = ".." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 1 di$cd error", sts = status );

  status = di$cd ( dirname = ".." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 2 di$cd error", sts = status );

  status = di$cd ( dirname = ":transient:testing" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 3 di$cd error", sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 4 di$cd error", sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 5 di$cd error", sts = status );

  status = di$cd ( dirname = "testing", path = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 6 di$cd error", sts = status );

  status = di$cd ( dirname = "*", path = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 7 di$cd error", sts = status );

  status = di$cd ( dirname = "testing", path = "hello :transient :wait" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 8 di$cd error", sts = status );

  status = di$cd ( dirname = "testing", path = "hello wait" );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 9 di$cd error", sts = status );

  status = di$cd ( dirname = "..:.." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 10 di$cd error", sts = status );

  status = di$cd ( dirname = ".." );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 11 di$cd error", sts = status );

  status = di$cd ( dirname = ":trans*" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 12 di$cd error", sts = status );

  status = di$cd ( dirname = "testing", path = "" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 13 di$cd error", sts = status );

  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 14 di$cd error", sts = status );

  status = di$cd ( dirname = "testing", path = "*" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 15 di$cd error", sts = status );

  status = di$cd ( dirname = "..:.." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : 16 di$cd error", sts = status );

  status = di$rmdir ( dirname = ":transient:testing" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_cd : di$rmdir error", sts = status );

  }
  else          /*  Bad input from cd_bad.in   */
  {
    DIchar     tmp [PATH_MAX], tmp1 [PATH_MAX];
    DIobjid    objid, objid1;
    DIspacenum osnum, osnum1;

    status = di$mkdir ( dirname = dirname, p_dirid = &objid, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad mkdir (1)" );

    status = di$cd ( dirname = dirname, path = "" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (1)" );
    else
    {
      status = di$pwd ( dirname = tmp, p_dirid = &objid1, p_osnum = &osnum1 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_cd: bad pwd (1)" );
      else
      {
        if ((osnum != osnum1) || (objid != objid1))
          printf ( "bad cd: osnum-objid problem in pwd (1)\n" );
        status = di$untranslate ( osnum = osnum, objid = objid, objname = tmp1 );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_cd: bad untranslate" );
        else
          if (strcmp ( tmp, tmp1 ))
            printf ( "bad cd: full path name problems (1)\n" );
      }
    }

    status = di$cd ( dirname = dirname, path = NULL );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (2)" );
    else
    {
      status = di$pwd ( dirname = tmp, p_dirid = &objid1, p_osnum = &osnum1 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "tst_cd: bad pwd (2)" );
      else
      {
        if ((osnum != osnum1) || (objid != objid1))
          printf ( "bad cd: osnum-objid problem in pwd (2)\n" );
        status = di$untranslate ( osnum = osnum, objid = objid, objname = tmp1 );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "tst_cd: bad untranslate" );
        else
          if (strcmp ( tmp, tmp1 ))
            printf ( "bad cd: full path name problems (2)\n" );
      }
    }

    status = di$cd ( dirname = "", path = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (3)" );
    status = di$cd ( dirname = "-", path = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (3.1)" );

    status = di$mkdir ( dirname = "one" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad mkdir (2)" );

    status = di$mkdir ( dirname = "two" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad mkdir (3)" );

    status = di$mkdir ( dirname = "three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad mkdir (3)" );

    status = di$cd ( dirname = "..", path = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (4)" );

    DIstmcpy ( tmp, dirname, "*", "1", NULL );
    status = di$mkdir ( dirname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad mkdir (3)" );

    status = di$cd ( dirname = "-", path = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (4.1)" );

    status = di$cd ( dirname = "1", path = "one two three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (5)" );
    status = di$cd ( dirname = "-", path = "one two three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (6)" );

    status = di$cd ( dirname = "1", path = "two three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (7)" );
    status = di$cd ( dirname = "-", path = "one two three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (8)" );

    status = di$cd ( dirname = "1", path = "three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (9)" );
    status = di$cd ( dirname = "-", path = "one two three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (10)" );

    status = di$cd ( dirname = "1", path = "*" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (11)" );

    status = di$cd ( dirname = "-", path = "one two three" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (4)" );

    status = di$cd ( dirname = DIR_G_str_dir, path = "" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (12)" );

    DIstmcpy ( tmp, dirname, "*", "1", NULL );
    status = di$rmdir ( dirname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad rmdir (1)" );

    DIstmcpy ( tmp, dirname, "*", NULL );
    status = di$rmdir ( dirname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad rmdir (2)" );

    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad rmdir (3)" );

    status = di$cd ( dirname = DIR_G_str_dir, path = "first second third *" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (13)" );
    status = di$cd ( dirname = DIR_G_str_dir, path = "" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (14)" );
    status = di$cd ( dirname = "transient", path = "" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (15)" );
    status = di$cd ( dirname = DIR_G_str_dir, path = "first second third *" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (16)" );
    status = di$cd ( dirname = "transient", path = "" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (17)" );
    status = di$cd ( dirname = ".", path = "" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (19)" );
    status = di$cd ( dirname = ".." );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (20)" );
    status = di$cd ( dirname = ".", path = "first second third *" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad cd (22)" );

    status = di$pwd ( dirname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_cd: bad pwd (4)" );
    else
    {
      DIterminator ( tmp );
      if (*tmp)
        printf ( "tst_cd: bad pwd (4), we were supposed to be at the root\n" );
    }
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
