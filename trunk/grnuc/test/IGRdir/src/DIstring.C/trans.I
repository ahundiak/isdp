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

main26 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}



tst_trans ( dirname, bad )
            DIchar *dirname;
            DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the translate name ( translate ) feature.
   The input is a directory name (full path name or base name), and the code
   type to specify the input type ( good = 0 ).
*/
/*.tst_trans*/
{
  DIint      status, om_status;
  DIobjid    dirid, dirid2, objid, bidon1;
  DIspacenum osnum, osnum2;
  DIchar     objname [DI_PATH_MAX];

  /*"dirname : '%s'\n", dirname */
  if (bad == 0)      /*   Good input from trans.in   */

  {
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: cd (1)" );
    status = di$mkdir ( dirname = "dir1" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (1)" );
    status = di$mkdir ( dirname = "dir2" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (2)" );
    status = di$mkdir ( dirname = "dir3" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (3)" );
    status = di$mkdir ( dirname = "dir1:p1" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (4)" );
    status = di$mkdir ( dirname = "dir1:p2" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (5)" );
    status = di$mkdir ( dirname = "dir2:r1" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (6)" );
    status = di$mkdir ( dirname = "dir3:p3" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: mkdir (7)" );

    {
      char   **lines;
      DIgrid *grids;
      int    count;
      
      status = di$dump ( regexp = "dir*:r1",
                         lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_trans : di$dump is wrong (1)",sts=status);
      else
      {
        DIfree ( grids );
        di$free ( lines = lines, count = count );
      }

      status = di$dump ( regexp = "dir*:r*",
                         lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_trans : di$dump is wrong (2)",sts=status);
      else
      {
        DIfree ( grids );
        di$free ( lines = lines, count = count );
      }
      status = di$dump ( regexp = "dir[1-3]:r*",
                         lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_trans : di$dump is wrong (3)",sts=status);
      else
      {
        DIfree ( grids );
        di$free ( lines = lines, count = count );
      }
    }

    status = di$rmdir ( dirname = "dir1:p1" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (4)" );
    status = di$rmdir ( dirname = "dir1:p2" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (5)" );
    status = di$rmdir ( dirname = "dir2:r1" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (6)" );
    status = di$rmdir ( dirname = "dir3:p3" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (7)" );
    status = di$rmdir ( dirname = "dir1" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (1)" );
    status = di$rmdir ( dirname = "dir2" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (2)" );
    status = di$rmdir ( dirname = "dir3" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: rmdir (3)" );

    status = di$cd ( dirname = "-" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: cd (1)" );
    
    /* let's translate some well-known stuff */
    status = di$translate ( objname = DIR_G_str_dir, p_objid = &objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: translate ( : )" );

    DIstrcpy ( objname, DIR_G_str_dir );
    DIstrcat ( objname, "transient" );
    status = di$translate ( objname = objname, p_objid = &objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: translate ( :transient )" );

  /*|make three directories */
  sprintf ( objname, "%s_first", dirname );
  status = di$translate ( regexp = objname, p_objid = &objid );
  if (status != DIR_W_NAME_NOT_FOUND)
    di$report_error ( comment = "tst_trans : translate should return name not found (1)",
                      sts     = status );
  status = di$mkdir ( dirname = objname, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir (1) is wrong",
                      sts     = status );
  sprintf ( objname, "%s_second", dirname );
  status = di$translate ( regexp = objname, p_objid = &objid );
  if (status != DIR_W_NAME_NOT_FOUND)
    di$report_error ( comment = "tst_trans : translate should return name not found (1)",
                      sts     = status );
  status = di$mkdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir (2) is wrong",
                      sts     = status );
  sprintf ( objname, "%s_third", dirname );
  status = di$translate ( regexp = objname, p_objid = &objid );
  if (status != DIR_W_NAME_NOT_FOUND)
    di$report_error ( comment = "tst_trans : translate should return name not found (1)",
                      sts     = status );
  status = di$mkdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir (3) is wrong",
                      sts     = status );

  /*|add one name in the last one */
  om_status = om$construct( osnum     = osnum2,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 );
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  sprintf ( objname, "%s_third:quick", dirname );
  status = di$translate ( regexp = objname, p_objid = &objid );
  if (status != DIR_W_NAME_NOT_FOUND)
    di$report_error ( comment = "tst_trans : translate should return name not found (1)",
                      sts     = status );
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment="tst_trans : di$add_name (1) is wrong", sts = status);

  /*|make a directory in the last one */
  sprintf ( objname, "%s_third:Root", dirname );
  status = di$mkdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir (1) is wrong",
                      sts     = status );

  /*|do a translate using regular expression */
  sprintf ( objname, "%s*:Root", dirname );
  status = di$translate ( regexp = objname,
                          p_objid = &objid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : translate with reg exp",
                      sts     = status );

  {
    DIchar tmp [DI_PATH_MAX], name [DI_PATH_MAX];

    status = di$split ( pathname = dirname, name = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_trans: split" );

    sprintf ( name, "%s*:Root", tmp );
    status = di$translate ( regexp = name, osnum = osnum,
                            p_objid = &objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_trans : translate reg exp, targetos",
                        sts     = status );

    /*-*/
    sprintf ( name, "%s_third", tmp );
    /*"objname : Root, path : '%s', osnum : %d\n", name, osnum */
    status = di$translate ( objname = "Root", path = name, osnum = osnum,
                            p_objid = &objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_trans : translate path + osnum",
                        sts     = status );
 
    /*-*/
    sprintf ( objname, "%s_third", dirname );
    /*"path : '%s'\n", objname */
    if (!di$is_regexp ( regexp = objname ))
    {
      status = di$translate ( objname = "Root", path = objname,
                              p_objid = &objid );
      if (status != DIR_S_SUCCESS)
      {
        di$report_error ( comment = "tst_trans : translate reg exp, path",
                          sts     = status );
        printf ( "path: '%s', objname: 'Root'\n", objname );
        OM_PMS();
      }
    }

    status = di$translate ( objname = "Root_is_not_there", path = objname,
                            p_objid = &objid );
    if (status == DIR_S_SUCCESS)
    {
      di$report_error ( comment = "tst_trans : bad translate reg exp, path",
                        sts     = status );
      printf ( "path: '%s', objname: 'Root_is_not_there'\n", objname );
      OM_PMS();
    }
  }

  sprintf ( objname, "%s*:quick", dirname );
  status = di$translate ( regexp = objname,
                          p_objid = &objid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : translate dir with reg exp",
                      sts     = status );

  /*|clean the third directory */
  sprintf ( objname, "%s_third:Root", dirname );
  status = di$rmdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir (1) is wrong",
                      sts     = status );

  status = om$send ( msg      = message Root.delete ( 1 ),
                     senderid = NULL_OBJID,
                     targetid = objid,
                     targetos = osnum );
  if (status != 1)
  {
    fprintf ( stderr, "tst_trans : Root.delete (%d, %d)\n", osnum, objid );
    om$report_error ( sts = status );
  }

  /*|remove the directories */
  sprintf ( objname, "%s_first", dirname );
  status = di$rmdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$rmdir (1) is wrong",
                      sts     = status );
  sprintf ( objname, "%s_second", dirname );
  status = di$rmdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$rmdir (2) is wrong",
                      sts     = status );
  sprintf ( objname, "%s_third", dirname );
  status = di$rmdir ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$rmdir (3) is wrong",
                      sts     = status );


  status = di$mkdir ( dirname = dirname, p_dirid = &dirid2, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir is wrong", sts = status );

  status = di$translate(regexp = dirname,p_objid = &dirid,p_osnum = &osnum);
  if (status != DIR_S_SUCCESS)
   di$report_error (comment = "tst_trans : di$translate is wrong",sts = status);
  if ((dirid != dirid2) || (osnum != osnum2))
   fprintf (stderr, "tst_trans : incompatibility between mkdir & translate\n" );

  status = di$cd ( dirname = dirname, p_dirid = &dirid2, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$cd is wrong", sts = status );
  if ((dirid != dirid2) || (osnum != osnum2))
    fprintf ( stderr, "tst_trans : incompatibility between translate & cd\n" );

  status = di$pwd ( p_dirid = &dirid2, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$pwd is wrong", sts = status );
  if ((dirid != dirid2) || (osnum != osnum2))
    fprintf ( stderr, "tst_trans : incompatibility between translate & pwd\n" );

  om_status = om$construct( osnum     = osnum2,
                            classname = "GRgraphics",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

  strcpy ( objname, "first" );
  status = di$add_name ( objname = objname, objid = bidon1, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment="tst_trans : di$add_name is wrong", sts = status);

  status = di$translate(regexp = objname,p_objid = &dirid,p_osnum = &osnum);
  if (status != DIR_S_SUCCESS)
   di$report_error (comment = "tst_trans : di$translate is wrong",sts = status);
  if ((dirid != bidon1) || (osnum != osnum2))
   fprintf(stderr,"tst_trans : incompatibility between add_name & translate\n");

  status = di$rm_name ( regexp = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_trans : di$rm_name is wrong", sts = status);

  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_trans : di$cd : is wrong",sts=status);

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$rmdir is wrong", sts = status );

  status = di$pwd ( p_dirid = &dirid2, p_osnum = &osnum2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$pwd is wrong", sts = status );

  status=di$translate ( objname = ":", p_objid = &dirid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
   di$report_error (comment = "tst_trans : di$translate is wrong",sts = status);
  if ((dirid != dirid2) || (osnum != osnum2))
   fprintf(stderr,"tst_trans : incompatibility between ':' & translate\n");

  /* these were added for the new search path code */
  strcpy ( objname, ":transient:newtest" );

  status = di$mkdir ( dirname = objname, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$mkdir error", sts = status );

  status = di$cd ( dirname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$cd error", sts = status );

  om_status = om$construct( osnum     = osnum,
                            classname = "GRgraphics",
                            p_objid   = &objid );
  if (om_status != OM_S_SUCCESS) om$report_error ( sts = om_status );

  strcat ( objname, ":test1" );

  status = di$add_name ( objname = objname, objid = objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$add_name error", sts = status );

  status = di$add_name ( objname = ":transient:newtest:case2", objid = objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$add_name error", sts = status );

  status = di$add_name ( objname = ":transient:newtest:essai3", objid = objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$add_name error", sts = status );

  status = di$translate ( objname = objname, p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 1 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 2 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = ":transient:newtest" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 3 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = "newtest", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 4 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = "hello newtest wait", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 5 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
           path = ":transient:hello :transient:newtest :transient:wait" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 6 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = "hello newtest wait", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 7 di$translate", sts = status );

  status = di$translate ( regexp = ":transient:new*:test1", p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 8 di$translate", sts = status );

  status = di$translate ( objname = ":transient:new*:test1", p_objid = &objid,
                          osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 9 di$translate", sts = status );

  status = di$translate ( objname = ":*:new*:test1", p_objid = &objid,
                          osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 10 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = ":transient:new*" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 11 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = "new*", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 12 di$translate", sts = status );

  status = di$translate ( objname = "test1", p_objid = &objid,
                          path = ":*:new*" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 13 di$translate", sts = status );

  status = di$translate ( objname = "te*", p_objid = &objid,
                          path = ":*:new*" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 14 di$translate", sts = status );

  status = di$translate ( objname = "te*", p_objid = &objid,
                          path = "new*", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 15 di$translate", sts = status );

  status = di$translate ( objname = ":transient:new*:test1", p_objid = &objid,
                          path = "newtest" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 16 di$translate", sts = status );

  status = di$translate ( objname = ":transient:new*:test1", p_objid = &objid,
                          path = "hello test wait", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 17 di$translate", sts = status );

  status = di$translate ( objname = ":transient:new*:test1", p_objid = &objid,
                          osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 18 di$translate", sts = status );

  status = di$translate ( objname = ":transient:new*:test1", p_objid = &objid,
                          path = "", osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 19 di$translate", sts = status );

  status = di$translate ( objname = ":transient:new*:test1", p_objid = &objid,
                          path = objname, osnum = osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : 20 di$translate", sts = status );

  status = di$rm_name ( regexp = ":transient:newtest:test1" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_trans : di$rm_name is wrong", sts = status);

  status = di$rm_name ( regexp = ":transient:newtest:case2" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_trans : di$rm_name is wrong", sts = status);

  status = di$rm_name ( regexp = ":transient:newtest:essai3" );
  if (status != DIR_S_SUCCESS)
    di$report_error (comment = "tst_trans : di$rm_name is wrong", sts = status);

  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
   di$report_error(comment = "tst_trans : di$cd : error",sts=status);

  status = di$rmdir ( dirname = ":transient:newtest" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_trans : di$rmdir error", sts = status );
  }

  else          /*  Bad input from trans_bad.in   */

  {
  status = di$translate (regexp = dirname, p_objid = &dirid, p_osnum = &osnum);
  if (status == DIR_S_SUCCESS)
   di$report_error (comment = "tst_trans : di$translate is wrong",sts = status);

    /* check if we cannot find a missing name */
    dirid = 0;
    status = di$translate ( regexp = "not in this directory",
                            p_objid = &dirid );
    if (status == DIR_S_SUCCESS)
      printf ( "bad translate: error in ret code (1)\n" );
    if (dirid != NULL_OBJID)
      printf ( "bad translate: error in OBJID (1)\n" );

    dirid = 0;
    status = di$translate ( objname = "not in this directory",
                            p_objid = &dirid );
    if (status == DIR_S_SUCCESS)
      printf ( "bad translate: error in ret code (2)\n" );
    if (dirid != NULL_OBJID)
      printf ( "bad translate: error in OBJID (2)\n" );
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
