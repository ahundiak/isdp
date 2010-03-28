class implementation Root;

#include <stdio.h>
#include <time.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG
#define GOOD       (   0 )
#define BAD        (   1 )

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "GRtypedef.h"
#include "GRdef.h"
#include "GRprims.h"

from OMFiledOS import write;

rm_minus_r ( dirname )
             char *dirname;
{
  DIint  status, i, count;
  DIgrid *grids;
  DIchar **lines;

  /*|go to sys */
  status = gr$cg ( groupname = "sys", passwd = "kozzy" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "cleaning : go to sys" );

  /*"find from '%s'\n", dirname */
  status = di$find ( start_dir = dirname, regexp = "*", ptr = &count,
                     options = OPT_ALL, lines = &lines, grids = &grids );
  if (status == DIR_S_SUCCESS)
  {
    for (i = count - 1; i >= 0; i--)
    {
      if(DIancestry_valid ( grids [i].osnum, grids [i].objid,
                            DIR_G_IGRdir_clid ))
      {
	 /*"di$rmdir %d - '%s'\n", i, lines[i] */
         status = di$rmdir ( dirname = lines [i] );
         if (status != DIR_S_SUCCESS)
           di$report_error ( sts = status, comment = "rmdir for clean" );
      }
      else
      {
	 /*"di$rename %d - '%s'\n", i, lines[i] */
         status = di$rename ( oldname = lines [i] );
         if (status != DIR_S_SUCCESS)
           di$report_error ( sts = status, comment = "rename for clean" );
      }
    }

    di$free ( count = count, lines = lines );
    DIfree ( grids );
  }
  else
  {
    if (status != DIR_W_NAME_NOT_FOUND)
      di$report_error ( sts = status, comment = "find for clean" );
  }

  /*|go to where we were */
  status = gr$cg ( groupname = "-" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "cleaning : go back" );

  return DIR_S_SUCCESS;
}


main ()
{
  entry ();

  unlink ( "master_file" );
  unlink ( "master" );
  unlink ( "ref.dgn" );

  return 1;
}

FILE *log_fet;
DIchar dir_class_name [DI_PATH_MAX];

entry ()
{
  FILE *fet;
  char line  [500];
  char line2 [500];
  char line3 [500], time_str [100];
  int i, status, om_status;
  DIspacenum osnum;
  DIobjid    osid;
  long clocker;

  strcpy ( dir_class_name, "DIrectory" );

  time (&clocker);
  strcpy ( time_str, &ctime ( &clocker ) [11] );
  time_str [2] = ';';
  time_str [5] = ';';
  time_str [13] = '\0';
  
  /*|opens the log file */
  log_fet = fopen ( "output/masterout", "r" );
  fclose ( log_fet );
  if (log_fet)
    log_fet = fopen ( "output/newout", "w" );
  else
    log_fet = fopen ( "output/masterout", "w" );
  if (!log_fet)
    fprintf ( stderr, "CANNOT open log file\n" );

  /*|test the uname stuff */
  fprintf ( log_fet, "tst_uname ( transient )\n" ); fflush ( log_fet );
  tst_uname ( ":transient:first_index", "obj_to_be_indexed", 0 );
  tst_uname ( ":transient:second_index", "obj_to_be_indexed", 0 );
  tst_uname ( ":transient:third_index", "obj_to_be_indexed", 0 );
  tst_uname ( ":transient:fourth_index", "obj_to_be_indexed", 0 );

  fprintf ( log_fet, "tst_uname ( master_file )\n" ); fflush ( log_fet );
  DIload ( "master_file", &osnum, &osid, ":uname_master_uname" );
  tst_uname ( ":uname_master_uname:first_uname", "obj_to_be_unnamed", 0 );

  fprintf ( log_fet, "tst_uname : delete ( master_file )\n" ); fflush ( log_fet );

  om_status = om$send ( msg      = message OMFiledOS.delete ( 1 ),
                        senderid = NULL_OBJID,
                        targetid = osid,
                        targetos = osnum );

  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "entry: cd ( :transient )" );

  /*|tst_mount () ...	*/
  if ( fet = fopen ( "input/mount.in", "r" ))
  {
    fprintf ( log_fet, "tst_mount ()\n" );
    fflush ( log_fet );

    while ( read_line ( fet, line ))
    {
      tst_mount ( line, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/mount.in\n" );

  /*|bad tst_mount () ...	*/
  if ( fet = fopen ( "input/mount_bad.in", "r" ))
  {
    fprintf ( log_fet, "tst_mount ()\n" );
    fflush ( log_fet );

    while ( read_line ( fet, line ))
    {
      tst_mount ( line, 1 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/mount_bad.in\n" );


  /*|load some files */
  /* opens load.in */
  if ( fet = fopen ( "input/load.in", "r" ))
  {
    fprintf ( log_fet, "tst_load ( )\n" );
    fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      tst_load ( line, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/load.in\n" );


  /*|testing gr$add_group ... create.I */
  /* opens create.in */
  if ( fet = fopen ( "input/create.in", "r" ))
  {
    fprintf ( log_fet, "tst_create ( )\n" );
    fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      int type;

      read_line ( fet, line2);
      read_line ( fet, line3);
      type = atoi ( line2 );
      strcat ( line, time_str );
      /*"tst_create ( '%s', ...\n", line */
      tst_create ( line, type, line3, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/create.in\n" );


  if ( fet = fopen ( "input/create_bad.in", "r" ))
  {
      fprintf ( log_fet, "bad tst_create ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      int type;

      read_line ( fet, line2);
      read_line ( fet, line3);
      type = atoi ( line2 );
      strcat ( line, time_str );
      tst_create ( line, type, line3, 1 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/create_bad.in\n" );



  /*|testing gr$cg and gr$pwg ... cg.I and pwg.I */
  /* opens cg.in */
  if ( fet = fopen ( "input/cg.in", "r" ))
  {
      fprintf ( log_fet, "tst_cg ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      read_line ( fet, line2);
      strcat ( line, time_str );
      tst_cg ( line, line2, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/cg.in\n" );


  if ( fet = fopen ( "input/cg_bad.in", "r" ))
  {
      fprintf ( log_fet, "bad tst_cg ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      read_line ( fet, line2);
      strcat ( line, time_str );
      tst_cg ( line, line2, 1 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/cg_bad.in\n" );



  /*|testing gr$validate ... valid.I */
  /* opens valid.in */
  if ( fet = fopen ( "input/valid.in", "r" ))
  {
      fprintf ( log_fet, "tst_valid ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      int  type;

      read_line ( fet, line2 );
      type = atoi ( line2 );
      strcat ( line, time_str );
      tst_valid ( line, type, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/valid.in\n" );


  if ( fet = fopen ( "input/valid_bad.in", "r" ))
  {
      fprintf ( log_fet, "bad tst_valid ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      int  type;

      read_line ( fet, line2 );
      type = atoi ( line2 );
      strcat ( line, time_str );
      tst_valid ( line, type, 1 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/valid_bad.in\n" );



  /*|testing gr$change_passwd ... cp.I */
  /* opens cp.in */
  if ( fet = fopen ( "input/cp.in", "r" ))
  {
      fprintf ( log_fet, "tst_cp (  )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      read_line ( fet, line2 );
      read_line ( fet, line3 );
      strcat ( line, time_str );
      tst_cp ( line, line2, line3, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/cp.in\n" );


  if ( fet = fopen ( "input/cp_bad.in", "r" ))
  {
      fprintf ( log_fet, "bad tst_cp ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      read_line ( fet, line2 );
      read_line ( fet, line3 );
      strcat ( line, time_str );
      tst_cp ( line, line2,line3, 1 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/cp_bad.in\n" );

  /*|create groups one and two */
  status = gr$cg ( groupname = "sys", passwd = "kozzy", flag = 1 );
  status = gr$add_group ( groupname = "one",
	                  type      = 2,
			  passwd    = "uno" );
  status = gr$add_group ( groupname = "two",
	                  type      = 2,
			  passwd    = "dos" );
  status = gr$cg ( groupname = "-", passwd = "kozzy", flag = 1 );

  /*|testing gr$change_group ... change_group.I */
  /* opens change_group.in */
  if ( fet = fopen ( "input/change_group.in", "r" ))
  {
      fprintf ( log_fet, "tst_change_group ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      DIint type;

      type = atoi ( line );
      tst_change_group ( type, 0 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/change_group.in\n" );

  if ( fet = fopen ( "input/change_group_bad.in", "r" ))
  {
      fprintf ( log_fet, "bad tst_change_group ( )\n" );
      fflush ( log_fet );
    while ( read_line ( fet, line ))
    {
      DIint type;

      type = atoi ( line );
      tst_change_group ( type, 1 );
    }

    fclose ( fet );
  }
  else
    fprintf ( stderr, "CANNOT open input/change_group_bad.in\n" );


  /*|let's clean the garbage */
  fprintf ( log_fet, "cleaning...\n" );
  fflush ( log_fet );
  rm_minus_r ( ":transient" );

  /*|go to usr */
  fprintf ( log_fet, "rm ( transient )\n" );
  fflush ( log_fet );
  status = gr$cg ( groupname = "usr" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status, comment = "cleaning : go to usr" );

  /*|try to delete transient */
  status = di$cd ( dirname = ".." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "cd ( .. )" );
  {
    DIchar tmp [DI_PATH_MAX];

    status = di$pwd ( dirname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "pwd" );
    else 
      if (strcmp ( tmp, ":" ))
        fprintf ( stderr, "current directory should be root : '%s'\n", tmp );
  }
  status = di$cd ( dirname = "transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "cd ( .. )" );

  status = di$rmdir ( dirname = ":transient" );
  if (status == DIR_S_SUCCESS)
    fprintf ( stderr, "CAN delete transient ...\n" );
  status = di$mkdir ( dirname = ":transient:coucou", classname = dir_class_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "mkdir ( :transient:coucou )" );
  status = di$rmdir ( dirname = ":transient:coucou" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "rmdir ( :transient:coucou )" );

  fprintf ( log_fet, "stm stuff\n" );
  fflush ( log_fet );
  tst_stm ();

  fprintf ( log_fet, "tst_search\n" );
  fflush ( log_fet );
  tst_search ( search_mask(), GOOD );
  tst_search ( search_mask(), BAD  );

  fprintf ( log_fet, "suntran\n" );
  fflush ( log_fet );
  suntran();

  fprintf ( log_fet, "mv_names\n" );
  fflush ( log_fet );
  mv_names();

  fprintf ( log_fet, "fast_trans\n" );
  fflush ( log_fet );
  fast_trans();
  
  return 1;
}  


tst_stm ()
{
  DIchar buf [DI_PATH_MAX];
  DIint  i, status;

  status = DIstmcpy ( buf, "first", 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "DIstmcpy ( first )" );
  else
    if (strcmp ( buf, "first" ))
      printf ( "tst_stm: buf and first should be the same\n" );

  status = DIstmcpy ( buf, "first", "second", "third", "fourth", 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "DIstmcpy ( first, ... )" );
  else
    if (strcmp ( buf, "first:second:third:fourth" ))
      printf ( "tst_stm: buf and first should be the same\n" );

  status = DIstmcat ( buf, "first", 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "DIstmcat ( first )" );
  else
    if (strcmp ( buf, "first:second:third:fourth:first" ))
      printf ( "tst_stm: buf and first should be the same\n" );

  status = DIstmcat ( buf, "first", "second", "third", "fourth", 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "DIstmcpy ( first, ... )" );
  else
    if (strcmp ( buf, "first:second:third:fourth:first:first:second:third:fourth" ))
      printf ( "tst_stm: buf and first should be the same\n" );

  for (i = 0; i < 100; i++)
    status = DIstmcat ( buf, "first", "second", "third", "fourth", 0 );
  if (status == DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "DIstmcat should fail" );
  else
    if (status != DIR_E_OVFLOW)
      printf ( "tst_stm: bad error code\n" );

  status = DIstmocpy ( buf, "first", "second", "third", 0, 1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "tst_stm: DIstmocpy" );
  else
    if (strcmp ( buf, ":transient:first:second:third"))
      printf ( "tst_stm: bad DIstmocpy (%s)\n", buf );
    
  return 1;
}


test_find ( start_dir, reg_exp )
           DIchar *start_dir, *reg_exp;
{
  DIint status, count;

  status = di$start_find ( regexp = reg_exp, ptr = &count, 
                           start_dir = start_dir );
  if (status == OM_S_SUCCESS)
  {
    DIint  i;
    DIchar line [DI_PATH_MAX];
    DIgrid grid;

    for (i = 0; i < count; i++)
    {
      di$fetch_find ( line = line, p_grid = &grid, index = i );
      printf ( "lines [%d] : '%s' - (%d, %d)\n",
               i, line, grid.osnum, grid.objid );
    }
  }

  return OM_S_SUCCESS;
}           


find_them ( reg_exp )
            DIchar *reg_exp;
{
  DIint  status, i, count, deep;
  DIchar line [DI_PATH_MAX];

  status = di$start_find ( regexp = reg_exp, ptr = &count,
                           options = OPT_ALL, deep = &deep );
  printf ( "deepness : %d\n", deep );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );
  else
    for (i = 0; i < count; i++)
    {
      status = di$fetch_find ( line = line, index = i );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "di$fetch_find" );
      else
        printf ( "line [%2d] : '%s'\n", i, line );
    }

  return 1;
}

fast_trans ()
{
   FILE       *fet;
   DIint       sts;
   DIobjid     p_objid;
   DIspacenum  p_osnum;
   DIchar      line  [DI_PATH_MAX],
               line2 [DI_PATH_MAX];

    sts = di$cd ( dirname = ":" );
    if (sts != DIR_S_SUCCESS)
      di$report_error ( comment = "mv_names : di$cd", sts = sts );

    rm_minus_r ( ":transient" );



    if ( fet = fopen ("input/ftrans.dir.in","r") )
    {
      fprintf ( log_fet, "fast_trans : ftrans.dir.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line ))
      {
          mkpath_dir ( line );
      }

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open input/ftrans.dir.in\n" );


    if ( fet = fopen ("input/ftrans.pwd.in","r") )
    {
       fprintf ( log_fet, "fast_trans : ftrans.pwd.in ()\n" );
       fflush ( log_fet );

       read_line ( fet, line );
       search_pwd ( line );
       fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open input/ftrans.pwd.in\n" );


    if ( fet = fopen ("input/ftrans.objpath.in","r") )
    {
      fprintf ( log_fet, "fast_trans : ftrans.objpath.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        sts = di$translate ( objname =  line,
		             p_osnum = &p_osnum,
                             p_objid = &p_objid,
		             path    =  line2 );
        if ( sts != DIR_S_SUCCESS )
        {
          di$report_error ( sts = sts,
                            comment = "translate with objname and path" );
          printf ( "'%s' and '%s'\n", line, line2 );
        }
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open input/ftrans.objpath.in\n" );


    if ( fet = fopen ("input/ftrans.regpath.in","r") )
    {
      fprintf ( log_fet, "fast_trans : ftrans.regpath.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        sts = di$translate ( regexp  =  line,
		             p_osnum = &p_osnum,
                             p_objid = &p_objid,
		             path    =  line2 );
        if ( sts != DIR_S_SUCCESS )
        {
          di$report_error ( sts = sts,
                            comment = "translate with regexp and path" );
          printf ( "'%s' and '%s'\n", line, line2 );
        }
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open input/ftrans.regpath.in\n" );


    if ( fet = fopen ("input/ftrans.reg.in","r") )
    {
      fprintf ( log_fet, "fast_trans : ftrans.reg.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line ))
      {
        sts = di$translate ( regexp =  line,
		             p_osnum = &p_osnum,
                             p_objid = &p_objid );
        if ( sts != DIR_S_SUCCESS )
        {
          di$report_error ( sts = sts, comment = "translate with regexp" );
          printf ( "'%s'\n", line );
        }
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open input/ftrans.reg.in\n" );


    if ( fet = fopen ("input/ftrans.in","r") )
    {
      fprintf ( log_fet, "fast_trans : ftrans.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet, line ))
      {
	sts = di$translate ( objname =  line,
			     p_osnum = &p_osnum,
                             p_objid = &p_objid );
	if ( sts != DIR_S_SUCCESS )
	{
	  di$report_error ( sts = sts, comment = "translate with objname" );
	  printf ( "'%s'\n", line );
	}
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open input/ftrans.in\n" );

    sts = di$cd ( dirname = ":" );
    if (sts != DIR_S_SUCCESS)
      di$report_error ( comment = "mv_names : di$cd", sts = sts );

    rm_minus_r ( ":transient" );

  return DIR_S_SUCCESS;
}

mv_names ()
{
   FILE       *fet1;
   FILE       *fet2;
   DIint       sts,
	       count = 0,
	       total = 0;
   DIobjid     objid1, objid2;
   DIchar      line1 [DI_PATH_MAX],
               tmp   [DI_PATH_MAX],
               name1 [DI_PATH_MAX],
               name2 [DI_PATH_MAX];
   DIspacenum  osnum = OM_Gw_TransOSnum_0;

    sts = di$cd ( dirname = ":" );
    if (sts != DIR_S_SUCCESS)
      di$report_error ( comment = "mv_names : di$cd", sts = sts );

    rm_minus_r ( ":transient" );



    if ( fet1 = fopen ("input/mv_name.dir.in","r") )
    {
      fprintf ( log_fet, "mv_names : mv_name.dir.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet1, line1 ))
      {
          mkdir_dir ( line1 );
      }

      fclose ( fet1 );
    }
    else
      fprintf ( stderr, "CANNOT open input/mv_name.dir.in\n" );



    if ( fet2 = fopen ("input/mv_name.pwd.in","r") )
    {
       fprintf ( log_fet, "mv_names : mv_name.pwd.in ()\n" );
       fflush ( log_fet );

       read_line ( fet2, line1 );
       search_pwd ( line1 );
       strcpy ( name1, line1 );
    }
    else
      fprintf ( stderr, "CANNOT open input/mv_name.pwd.in\n" );



    sts = om$construct( osnum = osnum, classname = "GRgraphics", p_objid = &objid1 );
    if ( sts != OM_S_SUCCESS )
      om$report_error ( sts = sts );


    if ( fet1 = fopen ("input/mv_name.add1.in","r") )
    {
      fprintf ( log_fet, "mv_names : mv_name.add1.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet1, line1 ))
      {
          addname ( line1, objid1 );
	  strcpy ( tmp, line1 );
      }
      DIstrcat ( name1, tmp );

      fclose ( fet1 );
    }
    else
      fprintf ( stderr, "CANNOT open input/mv_name.add.in\n" );



    read_line ( fet2, line1 );
    search_pwd ( line1 );
    strcpy ( name2, line1 );
    fclose ( fet2 );



    om$construct( osnum = osnum, classname = "GRgraphics", p_objid = &objid2 );
    if ( sts != OM_S_SUCCESS )
      om$report_error ( sts = sts );

    if ( fet1 = fopen ("input/mv_name.add2.in","r") )
    {
      fprintf ( log_fet, "mv_names : mv_name.add2.in ()\n" );
      fflush ( log_fet );

      while ( read_line ( fet1, line1 ))
      {
          addname ( line1, objid2 );
	  strcpy ( tmp, line1 );
      }
      DIstrcat ( name2, tmp );

      fclose ( fet1 );
    }
    else
      fprintf ( stderr, "CANNOT open input/mv_name.add.in\n" );


  di$untranslate ( objid = objid1, ptr = &total );
  di$untranslate ( objid = objid2, ptr = &count );

  total += count;

  di$move_names  ( old_name  = name1,  new_name  = name2 );
  di$untranslate ( objid = objid2, ptr = &count );
  if ( ! ( total = count ) ) printf ( "Problem with di$move_names 1\n");

  di$move_names  ( old_objid = objid2, new_objid = objid1 );
  di$untranslate ( objid = objid1, ptr = &count );
  if ( ! ( total = count ) ) printf ( "Problem with di$move_names 2\n");

  di$move_names  ( old_objid = objid1, new_objid = objid2 );
  di$untranslate ( objid = objid2, ptr = &count );
  if ( ! ( total = count ) ) printf ( "Problem with di$move_names 3\n");

  di$move_names  ( old_name  = name2,  new_objid = objid1 );
  di$untranslate ( objid = objid1, ptr = &count );
  if ( ! ( total = count ) ) printf ( "Problem with di$move_names 4\n");

  di$move_names  ( old_objid = objid1, new_objid = objid2 );
  di$untranslate ( objid = objid2, ptr = &count );
  if ( ! ( total = count ) ) printf ( "Problem with di$move_names 5\n");

  return DIR_S_SUCCESS;
}

end implementation Root;
