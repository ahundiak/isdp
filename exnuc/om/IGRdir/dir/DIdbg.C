/*
   ABSTRACT :
   --------

   This file contains some debuging functions for IGRdir. They are linked with
   the image in order to be able to display the state of the system on site.

   HISTORY :
   -------

   07/29/1988 : HGB - Creation Date
   05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX
*/

/* include UNIX stuff	*/
#include "string.h"
#include "stdio.h"
#include "memory.h"

/* include OM stuff	*/
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

/* include IGRdir stuff */
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

/* include Group stuff	*/
#include "GRtypedef.h"
#include "GRdef.h"
#include "GRprims.h"

DIdbg_glob ()
{
  DIint i;

  printf ( "DIR_G_init 		: %d\n", DIR_G_init );

  if (DIR_G_init)
  {
    printf ( "DIR_G_car_dir 		: '%c'\n", DIR_G_car_dir );
    printf ( "DIR_G_str_dir 		: '%s'\n", DIR_G_str_dir );

    printf ( "DIR_G_cur_dir_name	: '%s'\n", DIR_G_cur_dir_name );
    printf ( "DIR_G_cur_dir_os		: %d\n", DIR_G_cur_dir_os );
    printf ( "DIR_G_cur_dir_id		: %d\n", DIR_G_cur_dir_id );

    printf ( "DIR_G_prev_cur_name	: '%s'\n", DIR_G_prev_cur_name );
    printf ( "DIR_G_prev_cur_os		: %d\n", DIR_G_prev_cur_os );
    printf ( "DIR_G_prev_cur_id		: %d\n", DIR_G_prev_cur_id );

    printf ( "DIR_G_home_name		: '%s'\n", DIR_G_home_name );

    printf ( "DIR_G_master_os		: %d\n", DIR_G_master_os );
    printf ( "DIR_G_master_id		: %d\n", DIR_G_master_id );

    for (i = 0; i < 5; i++)
      DIundebug ( (DIspacenum) i );

    printf ( "DIR_G_dump_count		: %d\n", DIR_G_dump_count );
    for (i = 0; i < DIR_G_dump_count; i++)
    {
      printf ( "DIR_G_dump_lines [%d]	: '%s'\n", i, DIR_G_dump_lines [i] );
      printf ( "DIR_G_dump_grids [%d]	: (%d, %d)\n",
               i, DIR_G_dump_grids [i].osnum, DIR_G_dump_grids [i].objid );
    }
 
    printf ( "DIR_G_find_count		: %d\n", DIR_G_find_count );
    for (i = 0; i < DIR_G_find_count; i++)
    {
      printf ( "DIR_G_find_lines [%d]	: '%s'\n", i, DIR_G_find_lines [i] );
      printf ( "DIR_G_find_grids [%d]	: (%d, %d)\n",
               i, DIR_G_find_grids [i].osnum, DIR_G_find_grids [i].objid );
    }

    printf ( "DIR_G_trailer_index	: %d\n", DIR_G_trailer_index );
    for (i = 0; i < DIR_G_trailer_index; i++)
    {
      printf ( "DIR_G_trailer_ids [%d]	: %d\n", i, DIR_G_trailer_ids [i] );
      printf ( "DIR_G_trailers [%d]	: '%s'\n", i, DIR_G_trailers [i] );
    }

    printf ( "DIR_G_IGRdir_clid	        : %d\n", DIR_G_IGRdir_clid );
    printf ( "DIR_G_DIrectory_clid      : %d\n", DIR_G_DIrectory_clid );
    printf ( "DIR_G_DIlink_clid	        : %d\n", DIR_G_DIlink_clid );
    printf ( "DIR_G_DImaster_clid       : %d\n", DIR_G_DImaster_clid );
    printf ( "DIR_G_DIroot_clid         : %d\n", DIR_G_DIroot_clid );
  }

  return 1;
}


DIdbg_cd ( dirname )		/* change the current directory */
     char *dirname;
{
  int status;
  
  status = di$cd ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "cd" );
  else
    DIdbg_pwd();

  return 1;
}
   
  
DIdbg_pwd ( )			/* print the current directory */
{
  int  status;
  char tmp [DI_PATH_MAX];
  
  status = di$pwd ( dirname = tmp );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "pwd" );
  else
    printf ( "current directory : '%s'\n", tmp );

  return 1;
}

 
DIdbg_mkdir ( dirname )	/* make a new directory */
        char *dirname;
{
  int status;
  
  status = di$mkdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "mkdir" );

  return 1;
}

 
DIdbg_rmdir ( dirname )	/* delete an existing directory */
        char *dirname;
{
  int status;
  
  status = di$rmdir ( dirname = dirname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "mkdir" );

  return 1;
}

 
DIdbg_ls ( reg_exp )			/* list the existing entries	*/
     char *reg_exp;
{
  int status, i, count;
  char **lines;
  
  status = di$ls ( regexp = reg_exp, lines = &lines, ptr = &count );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "ls" );
  else
  {
    for (i = 0; i < count; i++)
      printf ( "lines [%2d] : '%s'\n", i, lines [i] );

    di$free ( lines = lines, count = count );
  }

  return 1;
}


DIdbg_dump ( reg_exp )		/* dump the existing entries	*/
       char *reg_exp;
{
  int status, i, count;
  char **lines;
  DIgrid *grids;
  
  status = di$dump ( regexp = reg_exp, lines = &lines, grids = &grids,
                     ptr = &count );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "dump" );
  else
  {
    for (i = 0; i < count; i++)
      printf ( "lines [%2d] : '%s' - (%d, %d)\n", 
               i, lines [i], grids [i].osnum, grids [i].objid );

    di$free ( lines = lines, count = count );
    DIfree ( grids )
  }

  return 1;
}

DIdbg_find ( reg_exp )	/* find the existing entries	*/
       char *reg_exp;
{
  DIint  status, i, count;
  DIchar **lines;
  DIgrid *grids;
  
  status = di$find ( regexp = reg_exp, options = OPT_LEVEL, 
                     grids = &grids, lines = &lines, ptr = &count );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status, comment = "find" );
  else
  {
    for (i = 0; i < count; i++)
      printf ( "lines [%2d] : '%s' - (%d, %d)\n",
               i, lines [i], grids [i].osnum, grids [i].objid );

    di$free ( lines = lines, count = count );
    DIfree ( grids )
  }

  return 1;
}


DIdbg_trans ( objname )		/* translate a name 	*/
            char *objname;
{
  int status;
  DIobjid objid;
  DIspacenum osnum;

  status = di$translate ( objname = objname,
                          p_objid = &objid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );
  else
    printf ( "\n'%s' : (%d, %d)\n", objname, osnum, objid );

  return 1;
}


DIdbg_rm ( objname )		/* remove an existing object	*/
     char *objname;
{
  int status;

  printf ( "rm : '%s'\n", objname );

  status = di$rename ( oldname = objname );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  return 1;
}


DIdbg_rename ( objname )		/* rename an existing object	*/
         char *objname;
{
  int  status;
  char *ptr;

  ptr = strchr ( objname, ',' );
  *ptr = 0;
  ptr++;

  status = di$rename ( oldname = objname, newname = ptr );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  return 1;
}


DIdbg_pwg ()
{
  int  osnum, id, index, status;
  char groupname [DI_PATH_MAX];

  status = gr$pwg ( p_groupid  = (GRobjid *) &id,
                    p_groupind = (GRint *) &index,
                    p_osnum    = (GRspacenum *) &osnum,
                    groupname  = (GRchar *) groupname );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status );
  else
    printf ( "\ncurrent group : name : '%s', index : %d, id : (%d, %d)\n",
             groupname, index, osnum, id );
  return(1);
}



DIdbg_cg ( groupname )
     char *groupname;
{
  int status;

  status = gr$cg ( groupname  = groupname );
  if (status != GR_S_SUCCESS)
    status = gr$cg ( groupname  = groupname, passwd = "kozzy" );

  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status );
  return(1);
}


DIdbg_mkgroup ( groupname )
          char *groupname;
{
  int  status;
  char *ptr;

  ptr = strchr ( groupname, ',' );
  *ptr = 0;
  ptr++;

  status = gr$add_group ( groupname = groupname, 
                          type      = (*ptr == 'r') ? DIR_D_READ :
                                      (*ptr == 'p') ? 
                                         (*++ptr == 'r') ? DIR_D_PRIVATE
                                                         : DIR_D_PUBLIC
                                                    : DIR_D_PUBLIC,
                          passwd    = "kozzy" );
  if (status != GR_S_SUCCESS)
    gr$report_error ( sts = status );
  return(status);
}


DIdbg_link ( objname )		/* link two existing objects	*/
       char *objname;
{
  int  status;
  char *ptr;

  ptr = strchr ( objname, ',' );
  *ptr = 0;
  ptr++;

  printf ( "link : '%s', '%s'\n", objname, ptr );

  status = di$link ( objname = objname, newname = ptr );
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts = status );

  return 1;
}
