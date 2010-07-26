class implementation Root;

#include <stdio.h>
#include <time.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#define DEBUG

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

from OMFiledOS	import write;
from DIbstgr	import retrieve_info;
from dummy      import test_pass;

#define NBR 1

tst_load ( file_name, bad )
           DIchar *file_name	/* File to be loaded			IN  */;
           DIint  bad		/* 1 if bad input			IN  */;
/*.tst_load */
{
  DIint          i, status, count, count0;
  DIchar         os_name [PATH_MAX], name [PATH_MAX], **lines, **lines0;
  DIchar         dir_name [PATH_MAX], attach [PATH_MAX], obj_name [PATH_MAX];
  DIgrid         grid, *grids, *grids0, root_grid;
  OM_S_CLASSLIST list;
  OMuword        classids [10];
  DIobjid        objid, bidon1, bidon2, bidon3, bidon4, bidon5;
  long           clock;
  extern DIchar  read_line ();

  DIint          om_status;
  DIobjid        osid;
  DIspacenum     osnum, osmaster, osref;

  extern FILE *log_fet;
  FILE * fet;
  char line  [500];
  char line2 [500];



  time ( &clock );
  strncpy ( dir_name, &(ctime ( &clock ) [11]), 8 ) [8] = '\0';
  dir_name [2] = '_';
  dir_name [5] = '_';

  /*|translate : */
  status = di$translate ( objname = ":", p_objid = &objid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "translate ( : )", sts = status );

  /*|cd into root */
  status = di$cd ( dirname = ":" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( : )", sts = status );

  /*|cd into transient */
  status = di$cd ( dirname = ":t*t" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( transient )", sts = status );

  /*|cd - */
  status = di$cd ( dirname = "-" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( - )", sts = status );
  status = di$pwd ( dirname = name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "pwd", sts = status );
  else
    if (strcmp ( name, ":" ))
      printf ( "problem in cd ( - ) and/or pwd : '%s'\n", name );

  /*|load a new object space */
  strcpy ( attach, ":master" );
  status = DIload ( file_name, &osmaster, &osid, attach );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "DImount", sts = status );

  {
    DIchar tmp [PATH_MAX];

    status = di$give_pathname ( osnum = osmaster, pathname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_load: give_pathname" );
    else
      if (strcmp ( tmp, attach ))
        printf ( "tst_load: incompatibility in give_pathname : '%s' - '%s'\n",
                 attach, tmp );

    status = di$give_pathname ( osnum = osmaster + 10, pathname = tmp );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_load: bad give_pathname" );
  }

  /*|cd into it */
  status = di$cd ( dirname = attach, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( :master )", sts = status );

  /*|construct some dummy objects */
  om_status = om$construct(osnum     = osnum,
                            classname = "dummy",
                            p_objid   = &bidon1 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct(osnum     = osnum,
                            classname = "dummy",
                            p_objid   = &bidon2 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct(osnum     = osnum,
                            classname = "dummy",
                            p_objid   = &bidon3 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct(osnum     = osnum,
                            classname = "dummy",
                            p_objid   = &bidon4 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );
  om_status = om$construct(osnum     = osnum,
                            classname = "dummy",
                            p_objid   = &bidon5 ); 
  if (om_status != OM_S_SUCCESS)
    om$report_error ( sts = om_status );

/*debug_on(); debug_method("*"); debug_class("*");*/

  /*|add several names */
  sprintf ( obj_name, "%s%s", dir_name, "coucou1" );
  status = di$add_name ( objname = obj_name, objid = bidon1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "coucou1", sts = status );

  status = di$rm_name ( regexp = obj_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "rm_name ( coucou1 )", sts = status );

  status = di$add_name ( objname = obj_name, objid = bidon1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "add_name ( coucou1 )", sts = status );

  sprintf ( obj_name, "%s%s", dir_name, "coucou2" );
  status = di$add_name ( objname = obj_name, objid = bidon2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "coucou2", sts = status );

  sprintf ( obj_name, "%s%s", dir_name, "cou1" );
  status = di$add_name ( objname = obj_name, objid = bidon3 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cou1", sts = status );

  sprintf ( obj_name, "%s%s", dir_name, "cou2" );
  status = di$add_name ( objname = obj_name, objid = bidon4 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cou2", sts = status );

  sprintf ( obj_name, "%s%s", dir_name, "c??2" );
  status = di$rm_name ( regexp = obj_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "rm_name ( c??2 )", sts = status );

  sprintf ( obj_name, "%s%s", dir_name, "cou2" );
  status = di$add_name ( objname = obj_name, objid = bidon4 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "add_name ( cou2 )", sts = status );

  /*|perform some translation */
  sprintf ( obj_name, "%s%s", dir_name, "cou2" );
  status = di$translate ( regexp = obj_name, p_osnum = &osnum, p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "translate ( cou3 )", sts = status );

  sprintf ( obj_name, "%s%s", dir_name, "cou*2" );
  status = di$translate ( regexp = obj_name, p_osnum = &osnum, p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "translate ( cou*2 )", sts = status );

  sprintf ( obj_name, "%s%s%s", ":m*:", dir_name, "cou*2" );
  status = di$translate ( regexp = obj_name, p_osnum = &osnum, p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "translate ( :m*:cou2 )", sts = status );

  status = di$translate ( regexp = ":m*:*cou*2", p_osnum = &osnum, p_objid = &objid );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "translate ( :m*:*cou*2 )", sts = status );

  /*|make some directories */
  status = di$mkdir ( dirname = dir_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir", sts = status );

  strcat ( dir_name, "_second" );
  status = di$mkdir ( dirname = dir_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir", sts = status );

  strcat ( dir_name, "_third" );
  status = di$mkdir ( dirname = dir_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir", sts = status );

  /*|load a new object space */
  strcpy ( attach, ":master:ref.dgn" );
  status = DIload ( "ref.dgn", &osref, &osid, attach );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "DImount", sts = status );

  {
    DIchar tmp [PATH_MAX];

    status = di$give_pathname ( osnum = osref, pathname = tmp );
    if (status != DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_load: give_pathname" );
    else
      if (strcmp ( tmp, attach ))
        printf ( "tst_load: incompatibility in give_pathname : '%s' - '%s'\n",
                 attach, tmp );

    status = di$give_pathname ( osnum = osref + 10, pathname = tmp );
    if (status == DIR_S_SUCCESS)
      di$report_error ( sts = status, comment = "tst_load: bad give_pathname" );
  }

  /*|cd into it */
  status = di$cd ( dirname = ":master:ref.dgn" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  /*|make some directories */
  dir_name [8] = '\0';
  strcat ( dir_name, "_ref_first" );
  status = di$mkdir ( dirname = dir_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir", sts = status );

  strcat ( dir_name, "_ref_second" );
  status = di$mkdir ( dirname = dir_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir", sts = status );

  strcat ( dir_name, "_ref_third" );
  status = di$mkdir ( dirname = dir_name );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "mkdir", sts = status );

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


  fprintf ( log_fet, "tst_link ( )\n" );
  fflush ( log_fet );

  /*|link some names to directories */
  /* opens link.in */
    if ( fet = fopen ( "in/link.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for ( i=0; i<NBR; ++i )
	{
          tst_link ( line, line2, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/link.in\n" );

  fprintf ( log_fet, "bad tst_link ( )\n" );
  fflush ( log_fet );

    if ( fet = fopen ( "in/link_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for ( i=0; i<1; ++i )
	{
          tst_link ( line, line2, 1 );
	}
      }
    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/link_bad.in\n" );



  fprintf ( log_fet, "tst_cd ( )\n" );
  fflush ( log_fet );
  /*|cd to some directories */
  /* opens cd.in */
    if ( fet = fopen ( "in/cd.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for (i=0; i<NBR; ++i)
	{
          tst_cd ( line, line2, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/cd.in\n" );


  fprintf ( log_fet, "bad tst_cd ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/cd_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for (i=0; i<NBR; ++i)
	{
          tst_cd ( line, line2, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/cd_bad.in\n" );


  fprintf ( log_fet, "tst_mkdir ( )\n" );
  fflush ( log_fet );
  /*|make some directories */
  /* opens mkdir.in */
    if ( fet = fopen ( "in/mkdir.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_mkdir ( line, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/mkdir.in\n" );


  fprintf ( log_fet, "bad tst_mkdir ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/mkdir_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_mkdir ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/mkdir_bad.in\n" );


  fprintf ( log_fet, "tst_rmdir ( )\n" );
  fflush ( log_fet );
  /*|remove some directories */
  /* opens rmdir.in */
    if ( fet = fopen ( "in/rmdir.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_rmdir ( line, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/rmdir.in\n" );


  fprintf ( log_fet, "bad tst_rmdir ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/rmdir_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_rmdir ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/rmdir_bad.in\n" );

  fprintf ( log_fet, "tst_add ( )\n" );
  fflush ( log_fet );
  /*|add some names to directories */
  /* opens add.in */
    if ( fet = fopen ( "in/add.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for ( i=0; i<NBR; ++i )
	{
          tst_add ( line, line2, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/add.in\n" );

  fprintf ( log_fet, "bad tst_add ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/add_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for ( i=0; i<1; ++i )
	{
          tst_add ( line, line2, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/add_bad.in\n" );

  fprintf ( log_fet, "tst_send ( )\n" );
  fflush ( log_fet );
  /*|add some names to directories */
  /* opens send.in */
    if ( fet = fopen ( "in/send.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for ( i=0; i<NBR; ++i )
	{
          tst_send ( line, line2, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/send.in\n" );


  fprintf ( log_fet, "bad tst_send ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/send_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for ( i=0; i<1; ++i )
	{
          tst_send ( line, line2, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/send_bad.in\n" );


  fprintf ( log_fet, "tst_translate ( )\n" );
  fflush ( log_fet );
  /*|translate some directories */
  /* opens trans.in */
    if ( fet = fopen ( "in/trans.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_trans ( line, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/trans.in\n" );


  fprintf ( log_fet, "bad tst_translate ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/trans_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_trans ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/trans_bad.in\n" );


  fprintf ( log_fet, "tst_untranslate ( )\n" );
  fflush ( log_fet );
  /*|untranslate some directories */
  /* opens untrans.in */
    if ( fet = fopen ( "in/untrans.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_untrans ( line, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/untrans.in\n" );

  fprintf ( log_fet, "bad tst_untranslate ( )\n" );
  fflush ( log_fet );
  /*|untranslate some directories */
  /* opens bad_untrans.in */
    if ( fet = fopen ( "in/bad_untrans.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_untrans ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/bad_untrans.in\n" );

  fprintf ( log_fet, "tst_ls ( )\n" );
  fflush ( log_fet );
  /*|list (ls) some directories */
  /* opens ls.in */
    if ( fet = fopen ( "in/ls.in", "r" ))
    {
      while ( read_line ( fet, line ))
	{
        for (i=0; i<1; ++i)
            tst_ls ( line, 0 );
	}

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/ls.in\n" );


  fprintf ( log_fet, "bad tst_ls ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/ls_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_ls ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/ls_bad.in\n" );


  fprintf ( log_fet, "tst_find ( )\n" );
  fflush ( log_fet );
  /*|find some directories */
  /* opens find.in */
    if ( fet = fopen ( "in/find.in", "r" ))
    {
      while ( read_line ( fet, line ))
	{
        for (i=0; i<1; ++i)
            tst_find ( line, 0 );
	}

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/find.in\n" );


  fprintf ( log_fet, "bad tst_find ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/find_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_find ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/find_bad.in\n" );


  /*|get some indexes */
  /* opens index.in */
  fprintf ( log_fet, "tst_index ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/index.in", "r" ))
    {
      while ( read_line ( fet, line ))
	{
        for (i=0; i<1; ++i)
            tst_index ( line, 0 );
	}

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/index.in\n" );


  /*|pass some messages to directories */
  /* opens pass.in */
  fprintf ( log_fet, "tst_pass ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/pass.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for (i=0; i<1; ++i)
	{
          tst_pass ( line, line2, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/pass.in\n" );


  fprintf ( log_fet, "bad tst_pass ( )\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/pass_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
	read_line ( fet, line2 );
        for (i=0; i<NBR; ++i)
	{
          tst_pass ( line, line2, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/pass_bad.in\n" );


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

  fprintf ( log_fet, "save OS\n" );
  fflush ( log_fet );
  /*|save the OS */
  DIstrcpy ( dir_name, ":master:ref.dgn" );
  status = di$umount ( dirname = dir_name, sleep = 1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "umount for ref.dgn", sts = status );
  else
  {
    om_status = om$send ( msg      = message OMFiledOS.write ( "ref.dgn" ),
                          senderid = NULL_OBJID,
                          targetid = osid,
                          targetos = osref );

    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );
    else
      om_status = om$send ( msg      = message OMFiledOS.delete ( 1 ),
                            senderid = NULL_OBJID,
                            targetid = osid,
                            targetos = osref );
  }

  status = di$find ( start_dir = ":", 
                     lines = &lines0, grids = &grids0,
                     ptr = &count0, options = 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "find from Root", sts = status );

  fprintf ( log_fet, "save OS\n" );
  fflush ( log_fet );

  /*|save the OS */
  DIstrcpy ( dir_name, ":master");
  status = di$umount ( dirname = dir_name, sleep = 1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "umount for master", sts = status );
  else
  {
    om_status = om$send ( msg      = message OMFiledOS.write ( "master" ),
                          senderid = NULL_OBJID,
                          targetid = osid,
                          targetos = osmaster );

    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );
    else
      om_status = om$send ( msg      = message OMFiledOS.delete ( 1 ),
                            senderid = NULL_OBJID,
                            targetid = osid,
                            targetos = osmaster );

  }

  fprintf ( log_fet, "re-load master OS\n" );
  fflush ( log_fet );
  /*|re-load the master object space */
  strcpy ( attach, ":master" );
  status = DIload ( file_name, &osmaster, &osid, attach );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "DImount", sts = status );

  status = di$find ( start_dir = ":", 
                     lines = &lines, grids = &grids,
                     ptr = &count, options = 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "find from Root", sts = status );
  else
    if (count != count0)
      printf ( "problem : count2 are different : %d, %d\n", count0, count );
    else
    {
      for (i = 0; i < count; i++)
      {
        DIobjid    objid;
        DIspacenum osnum;
        DIchar     name [PATH_MAX];
        DIint      nb_links, k;

        if (strcmp ( lines [i], lines0 [i] ))
          printf ( "find problem : '%s' - '%s'\n", lines0 [i], lines [i] );

        /*|translate the name */
        status = di$translate ( regexp    = lines [i],
                                p_osnum    = &osnum,
                                p_objid    = &objid );
        if (status != DIR_S_SUCCESS)
          di$report_error ( comment = "translate ( lines [i] )", sts = status );

        if ((objid != grids [i].objid) || (osnum != grids [i].osnum))
          printf ( "problem in translate : (%d, %d) and (%d, %d)\n",
                   grids [i].osnum, grids [i].objid, osnum, objid );

        /*|untranslate the name */
        status = di$untranslate ( objname    = name,
                                  osnum      = osnum,
                                  objid      = objid,
                                  ptr        = &nb_links );
        if (status != DIR_S_SUCCESS)
          di$report_error ( comment = "untranslate", sts = status );

        for (k = 0; k < nb_links; k++)
        {
          DIobjid    objid1;
          DIspacenum osnum1;

          status = di$untranslate ( objname    = name,
                                    osnum      = osnum,
                                    objid      = objid,
                                    index      = k );
          if (status != DIR_S_SUCCESS)
            di$report_error ( comment = "untranslate ( name )", sts = status );

          status = di$translate ( regexp    = name,
                                  p_osnum    = &osnum1,
                                  p_objid    = &objid1 );
          if (status != DIR_S_SUCCESS)
            di$report_error ( comment = "translate ( name )", sts = status );
          else
            if ((osnum != osnum1) || (objid != objid1))
              printf ( "untranslate problem : '%s' - '%s', (%d, %d) - (%d, %d)\n",
                       lines [i], name, osnum, objid, osnum1, objid1 );
        }
      }
        
      di$free ( lines = lines, count = count );
      DIfree ( grids );
      di$free ( lines = lines0, count = count0 );
      DIfree ( grids0 );
    }


  fprintf ( log_fet, "mkpath\n" );
  fflush ( log_fet );
  /*|make paths to some directories in transient ... */
  /*|cd into transient */
  status = di$cd ( dirname = ":transient" );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( transient )", sts = status );
  /* opens mkpath.in */
    if ( fet = fopen ( "in/mkpath.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<1; ++i)
	{
          tst_mkpath ( line, 0 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/mkpath.in\n" );

  fprintf ( log_fet, "bad mkpath\n" );
  fflush ( log_fet );
    if ( fet = fopen ( "in/mkpath_bad.in", "r" ))
    {
      while ( read_line ( fet, line ))
      {
        for (i=0; i<NBR; ++i)
	{
          tst_mkpath ( line, 1 );
	}
      }

    fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/mkpath_bad.in\n" );

  fprintf ( log_fet, "delete the OS\n" );
  fflush ( log_fet );
  /*|delete the OS */
  DIstrcpy ( dir_name, ":master");
  status = di$umount ( dirname = dir_name, sleep = 1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "umount for master", sts = status );
  else
    om_status = om$send ( msg      = message OMFiledOS.delete ( 1 ),
                          senderid = NULL_OBJID,
                          targetid = osid,
                          targetos = osmaster );

  return 1;
}

end implementation Root;
