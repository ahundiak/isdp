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

main11 ()
{
  /* dummy test routine for this on */
  system ( "cp output/masterout output/newout" );
  
  return 1;
}


tst_ls ( dirname, bad )
         DIchar *dirname;
	 DIint bad                                           /* IN  */;
/*
   This routine is supposed to test the ls directory feature.
*/
{
  DIint      i, status, count;
  DIobjid    dirid;
  DIspacenum osnum;
  DIchar     **lines;
  DIgrid     *grids;
  extern FILE *log_fet;

  if (bad == 0)      /*   Good input from ls.in   */

  {
    status = di$cd ( dirname = ":transient" );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_ls : di$cd is wrong", sts = status );

    for ( i=0; i<5; ++i )
    {
      DIchar tmp [DI_PATH_MAX];

      sprintf ( tmp, "fool" );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$mkdir is wrong", sts = status );

      sprintf ( tmp, "fool:first" );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$mkdir is wrong", sts = status );

      sprintf ( tmp, "fool:second" );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$mkdir is wrong", sts = status );

      sprintf ( tmp, "fool2" );
      status=di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$mkdir is wrong", sts = status );

      status=di$mkdir(dirname = dirname, p_dirid = &dirid, p_osnum = &osnum  );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$mkdir is wrong", sts = status );

      status = di$ls ( regexp = "*:*", lines = &lines, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_ls : ls is wrong", sts = status );
      else
      {
        if (count < 2)
        {
          DIint i;

          printf ( "problem with count : %d\n", count );
          for (i = 0; i < count; i++)
            printf ( "lines [%d] : '%s'\n", i, lines [i] );
        }

        di$free ( lines = lines, count = count );
      }

      sprintf ( tmp, "fool:first" );
      status=di$rmdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$rmdir is wrong", sts = status );

      sprintf ( tmp, "fool:second" );
      status=di$rmdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$rmdir is wrong", sts = status );

      sprintf ( tmp, "fool2" );
      status=di$rmdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$rmdir is wrong", sts = status );

      sprintf ( tmp, "fool" );
      status=di$rmdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_ls : di$rmdir is wrong", sts = status );

      status = di$ls ( lines = &lines, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_ls : ls is wrong", sts = status );
      else
        di$free ( lines = lines, count = count );

      status = di$dump ( lines = &lines, grids = &grids, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error(comment = "tst_dump : di$dump is wrong",sts=status);
      else
      {
        DIfree ( grids );
        di$free ( lines = lines, count = count );
      }

      status = di$cd ( dirname = "option1" );
      if (status != DIR_S_SUCCESS)
        di$report_error ( comment = "tst_ls : di$cd is wrong", sts = status );
    }

    status = di$find ( start_dir = ":", 
                       lines = &lines, grids = &grids,
                       ptr = &count, options = 0 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from Root", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }

    status = di$ls ( regexp = ":tran*:*", lines = &lines, ptr = &count );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_ls : ls is wrong", sts = status );
    else
      di$free ( lines = lines, count = count );

    status = di$ls(regexp=":tr[abc]*:*1:*1:*[135790]",lines=&lines,ptr=&count);
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_ls : ls is wrong", sts = status );
    else
      di$free ( lines = lines, count = count );

    status = di$find ( start_dir = ":transient:option1:option1:option1", 
                       lines = &lines, grids = &grids,
                       ptr = &count, options = 0 );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "find from nowhere", sts = status );
    else
    {
      di$free ( lines = lines, count = count );
      DIfree ( grids );
    }

    {
      DIchar **lines, tmp [DI_PATH_MAX];
      DIint  i, count;
      DIgrid *grids;

      sprintf ( tmp, "%s_test", dirname );
      status = di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "mkdir ( test )" );
      status = di$cd ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "cd ( test )" );

      sprintf ( tmp, ".hid1_%s", dirname );
      status = di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "mkdir ( .hid1 )" );
      sprintf ( tmp, ".hid2_%s", dirname );
      status = di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "mkdir ( .hid2 )" );

      status = di$dump ( grids = &grids, lines = &lines, ptr = &count,
                         options = OPT_ALL );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls for hid*" );
      else
      {
        if (count != 2)
          printf ( "tst_ls: count problem for .hid* : %d\n", count );
        for (i = 0; i < count; i++)
        {
          DIspacenum osnum;
          DIobjid    objid;

          status = di$translate ( regexp = lines [i], p_objid = &objid,
                                  p_osnum = &osnum );
          if (status != DIR_S_SUCCESS)
            di$report_error ( sts = status, comment = "tst_ls: trans for .hid" );
          else
            if ((objid != grids [i].objid) || (osnum != grids [i].osnum))
              printf ( "tst_ls: incompatibility for .hid* : (%d, %d), (%d, %d)\n",
                       osnum, objid, grids [i].osnum, grids [i].objid );
        }         
        di$free ( lines = lines, count = count );
        free ( grids );
      }
    }

    /* test if we can dump a directory with unnamed elements in it */
    {
      DIobjid    objid [10];
      DIspacenum osnum;
      DIchar     tmp [DI_PATH_MAX];

      strcat ( strcpy ( tmp, dirname ), "_unamed" );
      status = di$mkdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: mkdir for unnamed" );

      status = di$pwd ( p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: pwd for unnamed" );

      for (i = 0; i < 10; i++)
      {
        status = om$construct ( classname = "GRgraphics", osnum = osnum, p_objid = &objid [i] );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "ls.I: construct for unnamed" );
        status = di$add_index ( dirname = tmp, objid = objid [i] );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "ls.I: add_index for unnamed" );
      }
      status = di$cd ( dirname = tmp, p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: cd for unnamed" );
      status = di$dump ( grids = &grids, lines = &lines, ptr = &count );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: dump for unnamed" );
      if (count != 10)
        printf ( "ls.I: incompatible counts\n" );
      status = di$cd ( dirname = "-", p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: cd for unnamed (2)" );
      for (i = 0; i < 10; i++)
      {
        if (grids [i].objid != objid [i])
          printf ( "ls.I: incompatible ids for unnamed (1)\n" );
        status = di$index ( dirname = tmp, index = NULL, p_objid = &objid [i] );
        if (status != DIR_S_SUCCESS)
          di$report_error ( sts = status, comment = "ls.I: index for unnamed" );
        if (grids [i].objid != objid [i])
          printf ( "ls.I: incompatible ids for unnamed (2)\n" );
        om$send ( msg = message Root.delete ( 1 ), targetos = osnum, targetid = objid [i],
                  senderid = NULL_OBJID );
      }

      status = di$cd ( dirname = "-", p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: cd for unnamed (2)" );
      di$dump ( grids = &grids, lines = &lines, ptr = &count );
      status = di$cd ( dirname = "-", p_osnum = &osnum );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: cd for unnamed (2)" );
      if (count != 0)
        printf ( "ls.I: count should be 0\n" );
      status = di$rmdir ( dirname = tmp );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "ls.I: rmdir for unnamed" );
    }
  }

  else          /*  Bad input from ls_bad.in   */

  {

  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
   di$report_error ( comment = "tst_ls : di$mkdir is wrong", sts = status );

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_ls : di$cd is wrong", sts = status );

  status = di$ls ( lines = &lines, ptr = &count );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "bad tst_ls : ls is wrong", sts = status );

  status = di$dump ( lines = &lines, grids = &grids, ptr = &count );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "tst_dump : di$dump is wrong", sts = status );

  status = di$find ( start_dir = dirname, 
                     lines = &lines, grids = &grids,
                     ptr = &count, options = 0 );
  if (status == DIR_S_SUCCESS)
    di$report_error ( comment = "find from dirname", sts = status );

  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_ls : di$cd ':' is wrong", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "tst_ls : di$rmdir is wrong", sts = status );

  }

  return DIR_S_SUCCESS;
}

end implementation Root;
