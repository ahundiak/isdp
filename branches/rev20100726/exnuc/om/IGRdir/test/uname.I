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

#define NB_CASE 5

from OMFiledOS import write;


void tst_save_os ( osnum )
                   DIspacenum osnum;
/*
   This entry point saves and reads back an object space.  It tests if the
   directories are not modified.
*/
/*.tst_save_os */
{
  DIint   status, om_status, i, count0, count;
  DIobjid objid, osid;
  DIgrid  *grids0, *grids;
  DIchar  **lines0, **lines, dirname [PATH_MAX], name [PATH_MAX];
  DIchar  file_name [PATH_MAX];

  /*| do not save transient ! */
  if (osnum == 1)
    return;

  strcpy ( file_name, "master_file" );

  status = di$find ( start_dir = ":", 
                     lines = &lines0, grids = &grids0,
                     ptr = &count0, options = 0 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "find from Root", sts = status );

  /*|find a path name to the object space */
  status = di$give_pathname ( osnum = osnum, pathname = dirname );
  /*"save the OS : '%s'\n", dirname */

/*debug_on(); debug_class("*"); debug_method ("*");*/
  
  status = di$umount ( dirname = dirname, sleep = 1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "umount for master", sts = status );
  else
  {
    om_status = om$send ( msg      = message OMFiledOS.write ( file_name ),
                          senderid = NULL_OBJID,
                          targetid = 0,
                          targetos = osnum );

      om_status = om$send ( msg      = message OMFiledOS.delete ( 1 ),
                            senderid = NULL_OBJID,
                            targetid = 0,
                            targetos = osnum );

  }

#if 0
{
  DIchar **lines0;
  DIgrid *grids;
  DIint  count0, i;

  status = di$dump ( regexp = ":*", 
                     lines = &lines0, grids = &grids0,
                     ptr = &count0, options = OPT_ALL );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "Dump in Root", sts = status );
  else
    for (i = 0; i < count0; i++)
      printf ( "lines [%d] : '%s' - (%d, %d)\n",
               i, lines0 [i], grids0 [i].osnum, grids0 [i].objid );
}
#endif


  /*|re-load the master object space */
  status = DIload ( file_name, &osnum, &osid, dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "DImount", sts = status );

  /* debug_method ("tst_*"); */

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

        /*"lines [%d] : %d\n", i, lines [i] */
        if (lines [i])
        {
          if (strcmp ( lines [i], lines0 [i] ))
            printf ( "find problem : '%s' - '%s'\n", lines0 [i], lines [i] );

          /*"untranslate (%d, %d)\n", osnum, objid */
          status = di$untranslate ( objname    = name,
                                    osnum      = grids [i].osnum,
                                    objid      = grids [i].objid,
                                    ptr        = &nb_links );
          if ((status != DIR_S_SUCCESS) && (status != DIR_W_NO_NAME))
            di$report_error ( comment = "untranslate", sts = status );

          if (status != DIR_W_NO_NAME)
          {
            /*"translate the name : '%s'\n", lines [i] */
            status = di$translate ( regexp    = lines [i],
                                    p_osnum    = &osnum,
                                    p_objid    = &objid );
            if (status != DIR_S_SUCCESS)
              di$report_error ( comment = "translate ( lines [i] )", sts = status );

            /*|compare objids */
            if ((objid != grids [i].objid) || (osnum != grids [i].osnum))
              printf ( "problem in translate (%s) : (%d, %d) and (%d, %d)\n",
                       lines [i], grids [i].osnum, grids [i].objid, osnum, objid );
          }

          for (k = 0; k < nb_links; k++)
          {
            DIobjid    objid1;
            DIspacenum osnum1;

            status = di$untranslate ( objname    = name,
                                      osnum      = grids [i].osnum,
                                      objid      = grids [i].objid,
                                      index      = k );
            if ((status != DIR_S_SUCCESS) && (status != DIR_W_NO_NAME))
              di$report_error ( comment = "untranslate ( name )", sts = status );

            if (status == DIR_S_SUCCESS)
            {
              status = di$translate ( regexp    = name,
                                      p_osnum    = &osnum1,
                                      p_objid    = &objid1 );
              if (status != DIR_S_SUCCESS)
                di$report_error ( comment = "translate ( name )", sts = status );
              else
                if ((grids [i].osnum != osnum1) || (grids [i].objid != objid1))
                  printf ( "untranslate problem : '%s' - '%s', (%d, %d) - (%d, %d)\n",
                           lines [i], name, grids [i].osnum, grids [i].objid, osnum1, objid1 );
            }
            else
              if (status == DIR_W_NO_NAME)
              {
                DIint index;

                status = di$untranslate ( objname    = name,
                                          osnum      = grids [i].osnum,
                                          objid      = grids [i].objid,
                                          index      = k,
                                          p_index    = &index );
                status = di$index ( dirname = name, index = index,
                                    p_osnum = &osnum1, p_objid = &objid1 );

                if (status != DIR_S_SUCCESS)
                  di$report_error ( comment = "index ()", sts = status );
                else
                  if ((grids [i].osnum != osnum1) || (grids [i].objid != objid1))
                    printf ( "index - untranslate problem : (%d, %d) - (%d, %d)\n",
                             grids [i].osnum, grids [i].objid, osnum1, objid1 );
              }
          }
        }
        else
          if (lines0 [i])
            printf ( "lines - lines0 incompatibility : %d\n", i );
      }
        
      di$free ( lines = lines, count = count );
      DIfree ( grids );
      di$free ( lines = lines0, count = count0 );
      DIfree ( grids0 );
    }


}


tst_uname ( dirname, objname, bad )
            DIchar *dirname, *objname;
            DIint  bad;
/*.tst_uname */
{
  DIint   status, i, j, count1, count2, om_status, index;
  DIobjid objid, objids [NB_CASE + 10], dirid;
  DIgrid  *grids1, *grids2;
  DIchar  name [PATH_MAX], **lines1, **lines2;
  DIspacenum osnum;

/*- */
  status = di$give_osnum ( p_osnum = &osnum, pathname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  status = di$mkdir ( dirname = dirname, p_dirid = &dirid );
  if (status != DIR_S_SUCCESS)
  {
    printf ( "directory name : '%s'\n", dirname );
    di$report_error ( comment = "mkdir ( indexing )", sts = status );
  }

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
  {
    di$report_error ( comment = "cd ( dirname )", sts = status );
    debug_on(); debug_method("*"); debug_class("*");
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "cd ( dirname )", sts = status );
  }

  /*|construct NB_CASE objects */
  for (i = 0; i < NB_CASE + 1; i++)
  {
    om_status = om$construct( classname = "GRoup",
                              osnum     = osnum,
                              p_objid   = &(objids [i]) );
    if (om_status != OM_S_SUCCESS)
      om$report_error ( sts = om_status );
  }
    
  /*|add NB_CASE entries */
  for (i = 0; i < NB_CASE; i++)
  {
    /*"add_index ( '%s', %d )\n", dirname, objids [i] */
    status = di$add_index ( dirname = dirname, objid = objids [i] );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "add_index ( ... )", sts = status );

    /*|untranslate it */
    status = di$untranslate ( objid = objids [i], objname = name,
                              osnum = osnum, p_index = &index );
    if (status != DIR_W_NO_NAME)
    {
      printf ( "untranslate is wrong for %d, index is %d\n", objids [i], index );
      di$report_error ( sts = status );
    }

    sprintf ( name, "%s_%d", objname, ++i );
    /*"add_name ( '%s', %d )\n", name, objids [i] */
    status = di$add_name ( objname = name, objid = objids [i] );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "add_name ( ... )", sts = status );
    status = di$translate ( regexp = name, p_objid = &objid );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "name : '%s'\n", name );
      di$report_error ( comment = "translate after add_name", sts = status );
    }
    /*|untranslate it */
    status = di$untranslate ( objid = objids [i], objname = name,
                              osnum = osnum, p_index = &index );
  }

  /*|index NB_CASE + 1 ... */
  for (i = 0; i < NB_CASE + 2; i++)
  {
    objid = -1;
    /*"index ( '%s', %d )\n", dirname, i */
    status = di$index ( dirname = dirname, index = i, 
                        p_objid = &objid, name = name );
    if (i != (NB_CASE + 1))
      if ((status != DIR_S_SUCCESS) && (status != DIR_W_NO_NAME))
      {
        printf ( "i : %d\n", i );
        di$report_error ( comment = "index ( ... )", sts = status );
      }
      else
      {
        /*|untranslate it */
        status = di$untranslate ( objid = objid, objname = name,
                                  osnum = osnum, p_index = &index );
        if ((status == DIR_W_NO_NAME) || (status == DIR_S_SUCCESS))
        {
          if (index != i)
            printf ( "tst_uname : index incompatibility problem : %d - %d\n",
                     i, index );
          if (status == DIR_W_NO_NAME)
          {
            if (strcmp ( dirname, name ))
              printf ( "tst_uname : not directory name : '%s' - '%s'\n",
                       dirname, name );
          }
          else
          {
            status = di$translate ( regexp = name, p_objid = &objid );
            if (status != DIR_S_SUCCESS)
              di$report_error ( sts = status,
                                comment = "tst_uname : untrans -trans problem\n" );
            else
              if (objid != objids [i])
                printf ( "tst_uname : objid incompatibility problem : %d, %d\n",
                          objid, objids [i] );
          }
        }
      }
    else
      if (status == DIR_S_SUCCESS)
      {
        printf ( "tst_uname : indexing [%d] is successful!!!\n", i );
        printf ( "indexing [%d] : %d (%s)\n", i, objid, name );
      }
  }

  /*|translate all of them */
  for (i = 0; i < NB_CASE; i++)
  {
    objid = -1;
    sprintf ( name, "%s_%d", objname, i );
    status = di$translate ( regexp = name, p_objid = &objid );
    if (i / 2 * 2 != i)
    {
      if (status != DIR_S_SUCCESS)
      {
        printf ( "tst_uname : name : '%s'\n", name );
        di$report_error ( comment = "translate ( ... )", sts = status );
      }
    }
    else
      if (status == DIR_S_SUCCESS)
        printf ( "tst_uname : translate is successful !!!\n" );
  }

  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids1, lines = &lines1, ptr = &count1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids2, lines = &lines2, ptr = &count2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );
  else
  {
    if (count1 != count2)
      printf ( "tst_uname : count problem : %d - %d\n", count1, count2 );
    else
      for (i = 0; i < count1; i++)
      {
        if (lines1 [i])
          if (lines2 [i])
          {
            if (strcmp ( lines1 [i], lines2 [i] ))
              printf ( "tst_uname : '%s' & '%s' are different\n",
                       lines1 [i], lines2 [i] );
          }
          else
            printf ( "tst_uname : 1 is 0 and 2 is not (%d)\n", i );
        if ((grids1 [i].osnum != grids2 [i].osnum) ||
            (grids1 [i].objid != grids2 [i].objid))
           printf ( "tst_uname : compatibility problem (%d, %d) - (%d, %d)\n",
                    grids1 [i].osnum, grids1 [i].objid,
                    grids2 [i].osnum, grids2 [i].objid );
      }
  }

  /*|untranslate everybody */
  for (i = 0; i < NB_CASE; i++ )
  {
    DIchar tmp [PATH_MAX];

    /*|untranslate it */
    status = di$untranslate ( objid = objids [i], objname = tmp,
                              osnum = osnum, p_index = &index );
    if ((status != DIR_W_NO_NAME) && (status != DIR_S_SUCCESS))
      printf ( "tst_uname : untranslate problem\n" );
  }

  tst_save_os ( osnum );

  /*|remove some entries (0, 2, 4, ... ) */
  for (i = 0; i < NB_CASE / 4; i++)
  {
    status = di$rm_index ( dirname = dirname, index = i );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "rm_index ( ... )", sts = status );
  }

  tst_save_os ( osnum );

/*debug_on(); debug_class ("*"); debug_method ("*");*/

  /*|untranslate on deleted unnamed */
  for (i = 0; i < NB_CASE / 4; i += 2 )
  {
    DIchar tmp [PATH_MAX];

    /*|untranslate it */
    status = di$untranslate ( objid = objids [i], objname = tmp,
                              osnum = osnum, p_index = &index );
    if ((status == DIR_W_NO_NAME) || (status == DIR_S_SUCCESS))
      printf ( "tst_uname : untranslate should not find %d\n", objids [i] );
  }

  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids1, lines = &lines1, ptr = &count1 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids2, lines = &lines2, ptr = &count2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );
  else
  {
    if (count1 != count2)
      printf ( "tst_uname : count problem : %d - %d\n", count1, count2 );
    else
      for (i = 0; i < count1; i++)
      {
        if (lines1 [i])
          if (lines2 [i])
          {
            if (strcmp ( lines1 [i], lines2 [i] ))
              printf ( "tst_uname : '%s' & '%s' are different\n",
                       lines1 [i], lines2 [i] );
          }
          else
            printf ( "tst_uname : 1 is 0 and 2 is not (%d)\n", i );
        if ((grids1 [i].osnum != grids2 [i].osnum) ||
            (grids1 [i].objid != grids2 [i].objid))
           printf ( "tst_uname : compatibility problem (%d, %d) - (%d, %d)\n",
                    grids1 [i].osnum, grids1 [i].objid,
                    grids2 [i].osnum, grids2 [i].objid );
      }
  }


  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( dirname )", sts = status );

  /*|translate the odd ones */
  for (i = 1; i < NB_CASE; i += 2)
  {
    objid = -1;
    sprintf ( name, "%s_%d", objname, i );
    status = di$translate ( regexp = name, p_objid = &objid );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "name : '%s'\n", name );
      di$report_error ( comment = "translate ( ... )", sts = status );
    }
  }

  /*|index them */
  for (i = 1, j = 0; j < NB_CASE / 4; i += 2, j++)
  {
    objid = -1;
    status = di$index ( dirname = dirname, index = j, p_objid = &objid,
                        name = name );
    if ((status != DIR_S_SUCCESS) && (status != DIR_W_NO_NAME))
      di$report_error ( comment = "index ( ... )", sts = status );
    else
    {
      DIchar  tmp [PATH_MAX];
      DIobjid objid2;

      /*|check result */
      sprintf ( tmp, "%s_%d", objname, i );
      if (strcmp ( name, tmp ))
        printf ( "tst_uname : index - translate incompatibility : '%s' - '%s'\n",
                 name, tmp );
      status = di$translate ( regexp = tmp, p_objid = &objid2 );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status,
                          comment = "tst_uname : index.translate" );  
      else
        if (objid != objid2)
          printf ( "tst_uname : index - translate incompatibility : %d - %d\n",
                   objid, objid2 );
    }
  }

  /*|remove all the entries */
  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids2, lines = &lines2, ptr = &count2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

/*debug_on(); debug_class ("*"); debug_method ("*");*/

  tst_save_os ( osnum );

  for (i = 0; i < count2; i++)
  {
    /*"remove (%d, %d)\n", grids2 [i].osnum, grids2 [i].objid */
    status = di$rm_objid ( osnum = grids2 [i].osnum,
                           objid = grids2 [i].objid );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "rm_objid ( ... )", sts = status );
  }

  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids1, lines = &lines1, ptr = &count1 );
  if (status == DIR_S_SUCCESS)
  {
    printf ( "tst_uname : it not clean!!!\n" );
    printf ( "count : %d\n", count1 );
    for (i = 0; i < count1; i++)
      if (lines1 [i])
        printf ( "lines [%d] : '%s' - (%d, %d)\n",
                 i, lines1 [i], grids1 [i].osnum, grids1 [i].objid );
      else
        printf ( "lines [%d] : NULL - (%d, %d)\n",
                 i, grids1 [i].osnum, grids1 [i].objid );
  }

  tst_save_os ( osnum );

  /*"cd to '%s'\n", dirname */
  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
  {
    di$report_error ( comment = "cd ( dirname )", sts = status );
    /*- */
    status = di$cd ( dirname = dirname );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "cd ( dirname )", sts = status );
  }

  /*|add NB_CASE entries -> synonyms */
  for (i = 0; i < NB_CASE; i++)
  {
    DIint count;

    /*"add_index ( %d )\n", objids [i] */
    status = di$add_index ( dirname = dirname, objid = objids [i] );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "add_index ( ... )", sts = status );

/*- */
    /*"add_index ( %d )\n", objids [i] */
    status = di$add_index ( dirname = dirname, objid = objids [i] );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "add_index ( ... )", sts = status );
/*- */
    /*|untranslate it */
    status = di$untranslate ( objid = objids [i], objname = name,
                              ptr   = &count,
                              osnum = osnum, p_index = &index );
/*- */
    if (status != DIR_W_NO_NAME)
    {
      printf ( "untranslate is wrong for %d, index is %d\n", objids [i], index );
      di$report_error ( sts = status );
    }
    else
      if (count != 2)
        printf ( "tst_uname : untranslate doesn't find synonyms (index) : %d\n",
                 count );

    sprintf ( name, "%s_%d", objname, i );
    /*"add_name ( %s, %d )\n", name, objids [i] */
    status = di$add_name ( objname = name, objid = objids [i] );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "add_name ( ... )", sts = status );
    status = di$translate ( regexp = name, p_objid = &objid );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "name : '%s'\n", name );
      di$report_error ( comment = "translate after add_name", sts = status );
    }
    sprintf ( name, "%s_%d_bis", objname, i );
    /*"add_name ( %s, %d )\n", name, objids [i] */
    status = di$add_name ( objname = name, objid = objids [i] );
    if (status != DIR_S_SUCCESS)
      di$report_error ( comment = "add_name ( ... )", sts = status );
    status = di$translate ( regexp = name, p_objid = &objid );
    if (status != DIR_S_SUCCESS)
    {
      printf ( "name : '%s'\n", name );
      di$report_error ( comment = "translate after add_name", sts = status );
    }
    /*|untranslate it */
    count = 0;
    status = di$untranslate ( objid = objids [i], objname = name,
                              ptr   = &count,
                              osnum = osnum, p_index = &index );
    if (count != 4)
      printf ( "tst_uname : untranslate doesn't find synonyms(name) : %d\n",
               count );
  }


  tst_save_os ( osnum );

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( dirname )", sts = status );

  /*|remove all the entries */
  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids2, lines = &lines2, ptr = &count2 );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

/*debug_on(); debug_class ("*"); debug_method ("*");*/

  tst_save_os ( osnum );

  {
    DIobjid last;

    for (last = NULL_OBJID, i = 0; i < count2; i++)
    {
      /*"remove (%d, %d)\n", grids2 [i].osnum, grids2 [i].objid */
      status = di$rm_objid ( osnum = grids2 [i].osnum,
                             objid = grids2 [i].objid );
      if ((status != DIR_S_SUCCESS) && (last != grids2 [i].objid))
        di$report_error ( comment = "rm_objid ( ... )", sts = status );
      last = grids2 [i].objid;
    }
  }

  /*|dump the contents of the directory */
  sprintf ( name, "%s:*", dirname );
  status = di$dump ( regexp = name,
                     grids  = &grids1, lines = &lines1, ptr = &count1 );
  if (status == DIR_S_SUCCESS)
  {
    printf ( "tst_uname : it not clean!!!\n" );
    printf ( "count : %d\n", count1 );
    for (i = 0; i < count1; i++)
      if (lines1 [i])
        printf ( "lines [%d] : '%s' - (%d, %d)\n",
                 i, lines1 [i], grids1 [i].osnum, grids1 [i].objid );
      else
        printf ( "lines [%d] : NULL - (%d, %d)\n",
                 i, grids1 [i].osnum, grids1 [i].objid );
  }

  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( dirname )", sts = status );

  status = di$cd ( dirname = ".." );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "cd ( .. )", sts = status );

  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( comment = "rmdir", sts = status );

  return 1;
}


end implementation Root;
