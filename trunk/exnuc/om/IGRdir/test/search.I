class implementation Root;

#include <stdio.h>
#include <time.h>
#include "OMmacros.h"

#define BIG        ( 500 )
#define TEST1      ( 0x01 )
#define TEST2      ( 0x02 )
#define TEST3      ( 0x04 )

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "OMminimum.h"

extern FILE *log_fet;

/* ---------------------------   test macros   ---------------------------- */

void mkpath_dir ( FullPath )
  DIchar       FullPath[PATH_MAX];
{
  DIint        Status = DIR_S_SUCCESS;
  DIobjid      Objid;
  DIspacenum   Osnum;

  Osnum = OM_Gw_TransOSnum_0;

  /*
   *  construct objects that will be named in the directory
   */
  om$construct( osnum = Osnum, classname = "dummy", p_objid = &Objid );

  Status = di$mkpath( objid = Objid, pathname = FullPath, p_osnum = &Osnum );

  if (Status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkpath_dir : di$mkpath", sts = Status );
}

void mkdir_dir ( dirname )
  DIchar dirname[PATH_MAX];
{
  DIint  Status = DIR_S_SUCCESS;

  Status = di$mkdir( dirname = dirname );

  if (Status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir_dir : di$mkdir", sts = Status );
}

addname ( name, objid )
  DIchar  name[PATH_MAX];
  DIobjid objid;
{
  DIint      sts = DIR_S_SUCCESS;
  DIspacenum osnum;

  sts = di$add_name ( objname = name, objid = objid );

  if (sts != DIR_S_SUCCESS)
    di$report_error ( comment = "addname : di$add_name", sts = sts );
}

search_pwd ( dirname )
  DIchar dirname[PATH_MAX];
{
  DIint  Status = DIR_S_SUCCESS;

  Status = di$cd ( dirname = dirname );

  if (Status != DIR_S_SUCCESS)
    di$report_error ( comment = "search_pwd : di$cd", sts = Status );

  return Status;
}

search_mask ()
{
  FILE   *fet;
  DIchar  line1 [BIG];
  DIint  TestMask;

  /* get the mask for search path testing */
  /* opens search_mask.in */
  if ( fet = fopen ("in/search_mask.in","r") )
  {
     read_line ( fet, line1 );
     sscanf ( line1, "%x", &TestMask );
     fclose ( fet );
  }

  return ( TestMask );
}

/* --------------------   end of test macros   ---------------------------- */

tst_search ( mask, bad )
   DIint   mask,        /* low order 3 bits represent tests 1, 2, and 3 */
           bad;         /* determines if good or bad data is used       */
/*
   This routine is supposed to test the di$macros that use the search path 
   parameter.  These macros include

   Macros to be tested:  di$translate()
                         di$rename()
                         di$rmdir()
                         di$cd() - which passes path to di$translate

   Specific features of search path to be tested:

    o linear search path with full path prefix ( e.g. [ :master:foo:test:@ ] )
    o linear search path with relative path prefix ( e.g. [ .:@ ] )
    o search path with multiple path specifiers ( e.g. 
         [ :master:foo:test  :transient:test:@ :master:usr:tmp ] )

   INPUT:
      mask - search_mask retrieves the mask setting from in/search_mask.in

	     0x0 - no test is performed
	     0x1 - tests search path using di$rename
	     0x2 - tests search path using di$rmdir
	     0x4 - tests search path using di$cd
*/

{
   FILE       *fet;
   DIint       Status;
   DIspacenum  osnum;
   DIchar      line1 [BIG],
               line2 [BIG],
               line3 [BIG];

  if ( mask & TEST1 )
  {
    Status = di$cd ( dirname = ":" );
    if (Status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_search : di$cd", sts = Status );

    rm_minus_r ( ":transient" );

    /* testing search path using di$rename */
    /* build directory structure using mkpath_dir */
    if ( fet = fopen ("in/srename.dir.in","r") )
    {
      fprintf ( log_fet, "search : srename.dir.in ( )\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line1 ))
          mkpath_dir ( line1 );

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/srename.dir.in\n" );

    /* set pwd for testing search path using di$rename */
    if ( fet = fopen ("in/search_pwd.in","r") )
    {
      fprintf ( log_fet, "search : search_pwd.in ( )\n" );
      fflush ( log_fet );

       read_line ( fet, line1 );
       search_pwd ( line1 );
       fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/search_pwd.in\n" );

    /* now testing search path using di$rename */
    if ( fet = bad ? fopen ("in/srename.bad.in","r")
                   : fopen ("in/srename.in","r") )
    {
      fprintf ( log_fet, "search : srename.[bad].in ( )\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line1 ))
      {
        read_line ( fet, line2 );
        read_line ( fet, line3 );
        tst_search1 ( bad, line1, line2, line3 );
      }

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/srename.in\n" );
  }

  if ( mask & TEST2 )
  {
    Status = di$cd ( dirname = ":" );
    if (Status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_search : di$cd", sts = Status );

    rm_minus_r ( ":transient" );

    /* testing search path using di$rmdir */
    /* build directory structure using mkdir_dir */
    if ( fet = fopen ("in/srmdir.dir.in","r") )
    {
      fprintf ( log_fet, "search : srmdir.dir.in ( )\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line1 ))
          mkdir_dir ( line1 );

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/srmdir.dir.in\n" );

    /* set pwd for testing search path using rmdir */
    if ( fet = fopen ("in/search_pwd.in","r") )
    {
      fprintf ( log_fet, "search : search_pwd.in ( )\n" );
      fflush ( log_fet );

       read_line ( fet, line1 );
       search_pwd ( line1 );
       fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/search_pwd.in\n" );

    /* now testing search path using di$rmdir */
    if ( fet = bad ? fopen ("in/srmdir.bad.in","r")
                   : fopen ("in/srmdir.in","r") )
    {
      fprintf ( log_fet, "search : srmdir.[bad].in ( )\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line1 ))
      {
        read_line ( fet, line2 );
        tst_search2( bad, line1, line2 );
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/srmdir.in\n" );
  }

  if ( mask & TEST3 )
  {
    Status = di$cd ( dirname = ":" );
    if (Status != DIR_S_SUCCESS)
      di$report_error ( comment = "tst_search : di$cd", sts = Status );

    rm_minus_r ( ":transient" );

    /* testing search path using di$cd */
    /* build directory structure using mkdir_dir */
    if ( fet = fopen ("in/scd.dir.in","r") )
    {
      fprintf ( log_fet, "search : scd.dir.in ( )\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line1 ))
          mkdir_dir ( line1 );

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/scd.dir.in\n" );

    /* set pwd for testing search path using di$cd */
    if ( fet = fopen ("in/search_pwd.in","r") )
    {
      fprintf ( log_fet, "search : search_pwd.in ( )\n" );
      fflush ( log_fet );

       read_line ( fet, line1 );
       search_pwd ( line1 );
       fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/search_pwd.in\n" );

    /* now testing search path using di$cd */
    if ( fet = bad ? fopen ("in/scd.bad.in","r")
                   : fopen ("in/scd.in","r") )
    {
      fprintf ( log_fet, "search : scd.[bad].in ( )\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line1 ))
      {
        read_line ( fet, line2 );
        tst_search3 ( bad, line1, line2 );
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/scd.in\n" );
  }

  return DIR_S_SUCCESS;
}

end implementation Root;
