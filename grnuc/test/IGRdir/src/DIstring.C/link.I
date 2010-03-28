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


main9 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_link ( dirname, objname, bad )
           DIchar *dirname;
           DIchar *objname;
           DIint bad;
/*
   This routine is supposed to test the link feature.
   The input is a directory name (full path name or base name), the objid
   of the name to be added to the directory subsystem, and the bad code
   for input ( good = 0 ).
*/
/*.tst_link */
{
  DIint      status, count, i;
  DIobjid    dirid, dirid2, bidon1, res_objid;
  DIspacenum osnum, osnum2, res_osnum;
  DIint      om_status;
  DIchar     objname1 [DI_PATH_MAX], objname2 [DI_PATH_MAX], objname3 [DI_PATH_MAX];
  DIchar     pathname [DI_PATH_MAX], save_name [DI_PATH_MAX], dirname4 [DI_PATH_MAX];
  DIchar     dirname1 [DI_PATH_MAX], dirname2 [DI_PATH_MAX], dirname3 [DI_PATH_MAX];

  if (bad == 0)      /*   Good input from link.in   */
  {
    /*|make link using add_name */
    /*"dirname : '%s', objname : '%s'\n", dirname, objname */
    strcpy ( save_name, objname );
    /*|mkdir */
    status = di$mkdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|cd into it */
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd is wrong", sts = status);

    status = di$pwd ( p_osnum = &osnum );

    om_status = om$construct( osnum     = osnum,
                              classname = "GRgraphics",
                              p_objid   = &bidon1 ); 
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );

    /*|add names */
    status = di$add_name ( objname = objname, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (0) is wrong",
                        sts = status );

    sprintf ( objname1, "%s_first", objname );
    status = di$add_name ( objname = objname1, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (1) is wrong",
                        sts = status);

    sprintf ( objname2, "%s_second", objname );
    status = di$add_name ( objname = objname2, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (2) is wrong",
                        sts = status);

    sprintf ( objname3, "%s_third", objname );
    status = di$add_name ( objname = objname3, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (3) is wrong",
                        sts = status);

    /*|translates */
    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (0) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (0) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname1,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (1) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (1) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname2,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (2) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (2) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname3,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (3) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (3) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    /*|untranslate */
    status = di$untranslate ( objname = objname,
                              osnum   = osnum,
                              objid   = bidon1,
                              ptr     = &count );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate : is wrong",
                        sts = status);

    for (i = 0; i < count; i++)
    {
      status = di$untranslate ( objname  = pathname,
                                osnum = osnum,
                                objid = bidon1,
                                index = i );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$untranslate (i) : is wrong",
                          sts = status);
      }

      status = di$translate ( regexp = pathname,
                              p_objid = &res_objid, p_osnum = &res_osnum );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$translate (i) is wrong",
                          sts = status);
      }
      else
        if ((res_objid != bidon1) || (res_osnum != osnum))
          printf ( "tst_link : add_name - translate (3) problem : (%d, %d) - (%d, %d)\n",
                   osnum, bidon1, res_osnum, res_objid );
    }

    /*|cd ( :transient ) */
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd : is wrong", sts = status);

    /*|rmdir ( ... ) */
    status = di$rmdir ( dirname = dirname );
    if (status == DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);

    /*|cd ( ... ) */
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd is wrong", sts = status);

    /*|rm_objid */
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rm_objid is wrong", sts = status);

    /*|translate */
    status = di$translate ( regexp = objname,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (0) is no good",
                        sts = status);

    /*|untranslate */
    status = di$untranslate ( objname = objname,
                              osnum = osnum, objid = bidon1, ptr = &count );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate : is no good",
                        sts = status);

    /*|cd ( transient ) */
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd : is wrong", sts = status);

    /*|rmdir */
    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    /*|make links accross directories */
    strcpy ( objname, save_name );
    /*"dirname : '%s', objname : '%s'\n", dirname, objname */
    sprintf ( dirname1, "%s_first", dirname );
    /*"mkdir ( %s )\n", dirname1 */
    status = di$mkdir ( dirname = dirname1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);
    sprintf ( dirname2, "%s_second", dirname );
    /*"mkdir ( %s )\n", dirname2 */
    status = di$mkdir ( dirname = dirname2 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);
    sprintf ( dirname3, "%s_third", dirname );
    /*"mkdir ( %s )\n", dirname3 */
    status = di$mkdir ( dirname = dirname3 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|add name in these directories */
    sprintf ( objname1, "%s_first%c%s", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname1, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "name : '%s'\n", objname1 );
      di$report_error ( comment = "tst_link : di$add_name (dir : 1) is wrong",
                        sts = status);
    }
    sprintf ( objname2, "%s_second%c%s", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname2, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (dir : 2) is wrong",
                        sts = status);
    sprintf ( objname3, "%s_third%c%s", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname3, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (dir : 3) is wrong",
                        sts = status);

    /*|translates */
    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname1,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 1) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (dir : 1) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname2,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 2) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (dir : 2) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname3,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 3) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (dir : 3) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    /*|untranslate */
    status = di$untranslate ( objname = pathname,
                              osnum   = osnum,
                              objid   = bidon1,
                              ptr     = &count );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate  dir : is wrong",
                        sts = status);

    for (i = 0; i < count; i++)
    {
      status = di$untranslate ( objname  = pathname,
                                osnum = osnum,
                                objid = bidon1,
                                index = i );
    status = di$untranslate ( objname = pathname,
                              osnum   = osnum,
                              objid   = bidon1,
                              ptr     = &count );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$untranslate (dir : i) : is wrong",
                          sts = status);
      }

      status = di$translate ( regexp = pathname,
                              p_objid = &res_objid, p_osnum = &res_osnum );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$translate (dir : i) is wrong",
                          sts = status);
      }
      else
        if ((res_objid != bidon1) || (res_osnum != osnum))
          printf ( "tst_link : add_name - translate ( dirs ) problem : (%d, %d) - (%d, %d)\n",
                   osnum, bidon1, res_osnum, res_objid );
    }

    /*|rm_objid */
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rm_objid is wrong", sts = status);

    /*|translate */
    status = di$translate ( regexp = objname1,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 1) is no good",
                        sts = status);
    /*|translate */
    status = di$translate ( regexp = objname2,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 2) is no good",
                        sts = status);
    /*|translate */
    status = di$translate ( regexp = objname3,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 3) is no good",
                        sts = status);

    /*|untranslate */
    status = di$untranslate ( objname = objname,
                              osnum = osnum, objid = bidon1, ptr = &count );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate : is no good",
                        sts = status);

    /*|rmdir */
    status = di$rmdir ( dirname = dirname1 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }
    /*|rmdir */
    status = di$rmdir ( dirname = dirname2 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }
    /*|rmdir */
    status = di$rmdir ( dirname = dirname3 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }


    /*|make link using di$link */
    /*"dirname : '%s', objname : '%s'\n", dirname, objname */
    strcpy ( save_name, objname );
    /*|mkdir */
    status = di$mkdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|cd into it */
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd is wrong", sts = status);

    status = di$pwd ( p_osnum = &osnum );

    om_status = om$construct( osnum     = osnum,
                              classname = "GRgraphics",
                              p_objid   = &bidon1 ); 
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );

    /*|add names & link */
    status = di$add_name ( objname = objname, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (0) is wrong",
                        sts = status );

    sprintf ( objname1, "%s_first", objname );
    status = di$link ( objname = objname, newname = objname1 ); 
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$link (1) is wrong",
                        sts = status);

    sprintf ( objname2, "%s_second", objname );
    status = di$link ( newname = objname2, 
                       osnum = osnum,objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$link (2) is wrong",
                        sts = status);

    sprintf ( objname3, "%s_third", objname );
    status = di$link ( newname = objname3, objname = objname2 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$link (3) is wrong",
                        sts = status);

    /*|translates */
    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (0) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (0) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname1,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (1) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (1) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname2,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (2) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (2) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname3,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (3) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (3) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    /*|untranslate */
    status = di$untranslate ( objname = objname,
                              osnum   = osnum,
                              objid   = bidon1,
                              ptr     = &count );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate : is wrong",
                        sts = status);

    for (i = 0; i < count; i++)
    {
      status = di$untranslate ( objname  = pathname,
                                osnum = osnum,
                                objid = bidon1,
                                index = i );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$untranslate (i) : is wrong",
                          sts = status);
      }

      status = di$translate ( regexp = pathname,
                              p_objid = &res_objid, p_osnum = &res_osnum );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$translate (i) is wrong",
                          sts = status);
      }
      else
        if ((res_objid != bidon1) || (res_osnum != osnum))
          printf ( "tst_link : add_name - translate (3) problem : (%d, %d) - (%d, %d)\n",
                   osnum, bidon1, res_osnum, res_objid );
    }

    /*|cd ( :transient ) */
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd : is wrong", sts = status);

    /*|rmdir ( ... ) */
    status = di$rmdir ( dirname = dirname );
    if (status == DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);

    /*|cd ( ... ) */
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd is wrong", sts = status);

    /*|rm_objid */
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rm_objid is wrong", sts = status);

    /*|translate */
    status = di$translate ( regexp = objname,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (0) is no good",
                        sts = status);

    /*|untranslate */
    status = di$untranslate ( objname = objname,
                              osnum = osnum, objid = bidon1, ptr = &count );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate : is no good",
                        sts = status);

    /*|cd ( transient ) */
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd : is wrong", sts = status);

    /*|rmdir */
    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    /*|make links accross directories */
    strcpy ( objname, save_name );
    /*"dirname : '%s', objname : '%s'\n", dirname, objname */
    sprintf ( dirname1, "%s_first", dirname );
    /*"mkdir ( %s )\n", dirname1 */
    status = di$mkdir ( dirname = dirname1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);
    sprintf ( dirname2, "%s_second", dirname );
    /*"mkdir ( %s )\n", dirname2 */
    status = di$mkdir ( dirname = dirname2 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);
    sprintf ( dirname3, "%s_third", dirname );
    /*"mkdir ( %s )\n", dirname3 */
    status = di$mkdir ( dirname = dirname3 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|add name in these directories */
    sprintf ( objname1, "%s_first%c%s", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname1, objid = bidon1,
                           p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "name : '%s'\n", objname1 );
      di$report_error ( comment = "tst_link : di$add_name (dir : 1) is wrong",
                        sts = status);
    }

    sprintf ( objname2, "%s_second%c%s", dirname, DIR_G_car_dir, objname );
    status = di$link ( newname = objname2,
                       objid = bidon1, osnum = osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$link (dir : 2) is wrong",
                        sts = status);
    sprintf ( objname3, "%s_third%c%s", dirname, DIR_G_car_dir, objname );
    status = di$link ( objname = objname1, newname = objname3, 
                       objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$link (dir : 3) is wrong",
                        sts = status);

    /*|translates */
    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname1,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 1) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (dir : 1) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname2,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 2) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (dir : 2) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    res_objid = -1;
    res_osnum = 0;
    status = di$translate ( regexp = objname3,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 3) is wrong",
                        sts = status);
    else
      if ((res_objid != bidon1) || (res_osnum != osnum))
        printf ( "tst_link : add_name - translate (dir : 3) problem : (%d, %d) - (%d, %d)\n",
                 osnum, bidon1, res_osnum, res_objid );

    /*|untranslate */
    status = di$untranslate ( objname = pathname,
                              osnum   = osnum,
                              objid   = bidon1,
                              ptr     = &count );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate  dir : is wrong",
                        sts = status);

    for (i = 0; i < count; i++)
    {
      status = di$untranslate ( objname  = pathname,
                                osnum = osnum,
                                objid = bidon1,
                                index = i );
    status = di$untranslate ( objname = pathname,
                              osnum   = osnum,
                              objid   = bidon1,
                              ptr     = &count );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$untranslate (dir : i) : is wrong",
                          sts = status);
      }

      status = di$translate ( regexp = pathname,
                              p_objid = &res_objid, p_osnum = &res_osnum );
      if (status != DIR_S_SUCCESS)
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "tst_link : di$translate (dir : i) is wrong",
                          sts = status);
      }
      else
        if ((res_objid != bidon1) || (res_osnum != osnum))
          printf ( "tst_link : add_name - translate ( dirs ) problem : (%d, %d) - (%d, %d)\n",
                   osnum, bidon1, res_osnum, res_objid );
    }

    /*|rm_objid */
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rm_objid is wrong", sts = status);

    /*|translate */
    status = di$translate ( regexp = objname1,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 1) is no good",
                        sts = status);
    /*|translate */
    status = di$translate ( regexp = objname2,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 2) is no good",
                        sts = status);
    /*|translate */
    status = di$translate ( regexp = objname3,
                            p_objid = &res_objid, p_osnum = &res_osnum );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$translate (dir : 3) is no good",
                        sts = status);

    /*|untranslate */
    status = di$untranslate ( objname = objname,
                              osnum = osnum, objid = bidon1, ptr = &count );
    if (status == DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$untranslate : is no good",
                        sts = status);

    /*|rmdir */
    status = di$rmdir ( dirname = dirname1 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }
    /*|rmdir */
    status = di$rmdir ( dirname = dirname2 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }
    /*|rmdir */
    status = di$rmdir ( dirname = dirname3 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    /*|link directories */
    /*|mkdir */
    status = di$mkdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|make first link */
    sprintf ( dirname1, "%s_first", dirname );
    status = di$link ( objname = dirname, newname = dirname1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|make second link */
    sprintf ( dirname2, "%s_second", dirname );
    status = di$link ( objname = dirname, newname = dirname2 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|make third link */
    sprintf ( dirname3, "%s_third", dirname );
    status = di$link ( objname = dirname, newname = dirname3 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|make fourth link */
    sprintf ( dirname4, "%s_fourth", dirname );
    status = di$link ( objname = dirname, newname = dirname4 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    DIstrcpy ( objname1, dirname );
    DIstrcat ( objname1, objname );
    /*|add name in the basic directory */
    status = di$add_name ( objname = objname1, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (0) is wrong",
                        sts = status );

    /*|add name in the first directory */
    sprintf ( objname1, "%s_first%c%s_first", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname1, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (1) is wrong",
                        sts = status );

    /*|add name in the second directory */
    sprintf ( objname1, "%s_second%c%s_second", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname1, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (2) is wrong",
                        sts = status );

    /*|add name in the third directory */
    sprintf ( objname1, "%s_third%c%s_third", dirname, DIR_G_car_dir, objname );
    status = di$add_name ( objname = objname1, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (3) is wrong",
                        sts = status );

    /*|rmdir ( ..._fourth ) */
    status = di$rmdir ( dirname = dirname4 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    /*|try to cd into it */
    status = di$cd ( dirname = dirname4 );
    if (status == DIR_S_SUCCESS)
      printf ( "cd ( dirname4 ) should fail ...\n" );

    /*|dump the 4 directories and compare the results */
    {
      DIchar **lines0, **lines1, **lines2, **lines3;
      DIgrid *grids0, *grids1, *grids2, *grids3;
      DIint  count0, count1, count2, count3;

      sprintf ( dirname1, "%s%c*", dirname, DIR_G_car_dir );
      status = di$dump ( regexp = dirname1, lines = &lines0,
                         grids = &grids0, ptr = &count0 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "dump0" );

      sprintf ( dirname1, "%s_first%c*", dirname, DIR_G_car_dir );
      status = di$dump ( regexp = dirname1, lines = &lines1,
                         grids = &grids1, ptr = &count1 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "dump1" );

      sprintf ( dirname2, "%s_second%c*", dirname, DIR_G_car_dir );
      status = di$dump ( regexp = dirname2, lines = &lines2,
                         grids = &grids2, ptr = &count2 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "dump2" );

      sprintf ( dirname3, "%s_third%c*", dirname, DIR_G_car_dir );
      status = di$dump ( regexp = dirname3, lines = &lines3,
                         grids = &grids3, ptr = &count3 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "dump3" );

      if ((count0 != 4) || (count0 != count1) || (count0 != count2) ||
          (count0 != count3))
        printf ( "count problem : %d, %d, %d, %d\n", count0, count1,
                 count2, count3 );
      else
      {
        DIint i;

        /*|compare the entries */
        for (i = 0; i < count0; i++)
          if ((grids0 [i].osnum != grids1 [i].osnum) ||
              (grids0 [i].osnum != grids2 [i].osnum) ||
              (grids0 [i].osnum != grids3 [i].osnum) ||
              (grids0 [i].objid != grids1 [i].objid) ||
              (grids0 [i].objid != grids2 [i].objid) ||
              (grids0 [i].objid != grids3 [i].objid))
            printf ( "grid problem : (%d, %d), (%d, %d), (%d, %d), (%d, %d)\n",
                     grids0 [i].osnum, grids0 [i].objid,
                     grids1 [i].osnum, grids1 [i].objid,
                     grids2 [i].osnum, grids2 [i].objid,
                     grids3 [i].osnum, grids3 [i].objid );
      }
    }

    /*|rm_objid */
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$rm_objid is wrong", sts = status);

    /*|rmdir */
    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    status = di$cd ( dirname = dirname );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (0)\n" );

    sprintf ( dirname1, "%s_first", dirname );
    status = di$cd ( dirname = dirname1 );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "dirname1 : '%s'\n", dirname1 );
      di$report_error ( sts = status, comment = "cd ( dirname1 )" );
    }

    status = di$cd ( dirname = "-" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "cd ( - )" );

    /*|rmdir */
    status = di$rmdir ( dirname = dirname1 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    status = di$cd ( dirname = dirname1 );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (0)\n" );

    sprintf ( dirname2, "%s_second", dirname );
    status = di$cd ( dirname = dirname2 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "cd ( dirname1 )" );
    status = di$cd ( dirname = "-" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "cd ( - )" );

    /*|rmdir */
    status = di$rmdir ( dirname = dirname2 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    status = di$cd ( dirname = dirname2 );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (0)\n" );

    sprintf ( dirname3, "%s_third", dirname );
    status = di$cd ( dirname = dirname3 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "cd ( dirname3 )" );
    status = di$cd ( dirname = "-" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "cd ( - )" );

    /*|rmdir */
    status = di$rmdir ( dirname = dirname3 );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }

    status = di$cd ( dirname = dirname );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (0)\n" );
    status = di$cd ( dirname = dirname1 );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (1)\n" );
    status = di$cd ( dirname = dirname2 );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (2)\n" );
    status = di$cd ( dirname = dirname3 );
    if (status == DIR_S_SUCCESS)
      printf ( "problem : can cd to a deleted directory (3)\n" );

  }
  else          /*  Bad input from link_bad.in   */
  {
    /*|make link using add_name */
    /*"dirname : '%s', objname : '%s'\n", dirname, objname */
    strcpy ( save_name, objname );
    /*|mkdir */
    status = di$mkdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$mkdir is wrong", sts = status);

    /*|cd into it */
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd is wrong", sts = status);

    status = di$pwd ( p_osnum = &osnum );

    om_status = om$construct( osnum     = osnum,
                              classname = "GRgraphics",
                              p_objid   = &bidon1 ); 
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );

    /*|add names */
    status = di$add_name ( objname = objname, 
                           objid = bidon1, p_osnum = &osnum );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_link : di$add_name (0) is wrong",
                        sts = status );

    status = di$add_name ( objname = objname, 
                           objid = bidon1, p_osnum = &osnum );
    if (status == DIR_S_SUCCESS)
      printf ( "add_name ( objname ) should fail\n" );

    status = di$link ( newname = objname, objid = bidon1,
                       osnum = osnum + 10 );
    if (status == DIR_S_SUCCESS)
      printf ( "link ( objname, ... ) should fail (1)\n" );

    status = di$link ( newname = objname, objid = bidon1,
                       osnum = osnum );
    if (status == DIR_S_SUCCESS)
      printf ( "link ( objname, ... ) should fail (2)\n" );

    status = di$link ( objname = objname, newname = objname );
    if (status == DIR_S_SUCCESS)
      printf ( "link ( objname, ... ) should fail (3)\n" );

    /*|clean our stuff */
    status = di$rm_objid ( osnum = osnum, objid = bidon1 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "rm_objid ( ... )" );

    /*|cd into it */
    status = di$cd ( dirname = "-" );
    if (status != DIR_S_SUCCESS)
      di$report_error (comment = "tst_link : di$cd is wrong", sts = status);

    /*|rmdir */
    status = di$rmdir ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
    {
      DIchar **lines;
      DIgrid *grids;
      DIint  count, i;

      di$report_error (comment = "tst_link : di$rmdir is wrong", sts = status);
      status = di$find ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "find", sts = status );

      printf ( "find :\n" );
      for (i = 0; i < count; i++)
        printf ( "'%s' - (%d, %d)\n",
                 lines [i], grids [i].osnum, grids [i].objid );
    }
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
