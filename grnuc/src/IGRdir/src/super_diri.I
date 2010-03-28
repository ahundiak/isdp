class implementation super_dir;

#include <stdio.h>

#include <OMerrordef.h>
#include <OMmacros.h>
#include <OMprimitives.h>

#include "igrtypedef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "DImacros.h"
#include "FI.h"

#include "exmacros.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int DIis_ref __((void));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



#define NB_CHOICE 7

#define COM 0
#define SEP 1
#define HOM 2
#define BCK 3
#define DIR 4
#define LOD 5
#define PWD 6
#define TRL 7
#define UND 99


from FIdirform import update;
from DIstorage import remove_info, store_info;
from DIbstgr   import retrieve_info;

method super_construct ()
{
  char home [DI_PATH_MAX];
  int  status;

  /* home and current : usr */
  status = DIstmocpy(home, "usr", 0, OM_Gw_current_OS);
  status = di$cd (dirname = home);
  if (status != DIR_S_SUCCESS)
    di$report_error ( sts     = status,
		      comment = "super_dir.supe_construct->di$cd" );
  DIstrcpy ( DIR_G_home_name, home );

  /* save the context in instance data */
  om_send ( super_dir.sleep ( 0 ), my_id, my_id );

  return OM_S_SUCCESS;
}

static DIgrid  *ref_grids, *cell_grids;
static char    **ref_names, **cell_names;
%safe
static int     ref_index = NULL, cell_index = NULL;
%endsafe


static DIis_ref ()
{
  OMuword mod_osnum;

  ex$get_cur_mod ( osnum = &mod_osnum );

  return OM_Gw_current_OS != mod_osnum;
}


method global_class.sleep ( int pos )
{
  if (DIis_ref ())
    return OM_S_SUCCESS;

  /* the current directory must be relative to the module */
  /* save the current directory */
  om$vla_set_dimension ( varray = me->current,
			 size   = strlen ( DIR_G_cur_dir_name ) + 1 );
  DIstrcpy ( me->current, DIR_G_cur_dir_name );

  /* save the home directory */
  om$vla_set_dimension ( varray = me->home,
			 size   = strlen ( DIR_G_home_name ) + 1 );
  DIstrcpy ( me->home, DIR_G_home_name );

  if (pos == EX_TEMP_SLEEP)
  {
    int     i, status;
    char    name [DI_PATH_MAX];
    DIobjid ref_dir_id, cell_dir_id;

    /* disconnect the GRlinks */
    DIstmocpy ( name, "ref", 0, OM_Gw_current_OS );
    status = di$translate ( objname = name, p_objid = &ref_dir_id );
    DIstmocpy ( name, "ref", "*", 0, OM_Gw_current_OS );
    status = di$dump ( regexp = name, lines = &ref_names, grids = &ref_grids,
                       ptr    = &ref_index, options = OPT_ALL );
    for (i = 0; i < ref_index ; i++)
      if (DIancestry_valid ( ref_grids [i].osnum, ref_grids [i].objid,
                             DIR_G_DIlink_clid ))
      {
        DIgrid root_grid;
	char   dir_name [DI_PATH_MAX];

        status = di$split ( pathname = ref_names [i], name = ref_names [i],
			    dirname = dir_name );
        om_send ( DIstorage.remove_info ( &status, ref_names [i], NULL ),
                  my_id, ref_dir_id );

        /* find the OS we are pseudo-unmounting */
        root_grid = ref_grids [i];
        DIcheck_link ( (root_grid.osnum), (root_grid.objid) )
	DIunall ( root_grid.osnum, root_grid.objid,
		  dir_name, ref_names [i], 1, NULL, NULL );
      }

    /* disconnect the GRlinks */
    DIstmocpy ( name, "cell", 0, OM_Gw_current_OS );
    status = di$translate ( objname = name, p_objid = &cell_dir_id );
    DIstmocpy ( name, "cell", "*", 0, OM_Gw_current_OS );
    status = di$dump ( regexp = name, lines = &cell_names, grids = &cell_grids,
                       ptr    = &cell_index, options = OPT_ALL );
    for (i = 0; i < cell_index ; i++)
      if (DIancestry_valid ( cell_grids [i].osnum, cell_grids [i].objid,
                             DIR_G_DIlink_clid ))
      {
        DIgrid root_grid;
	char   dir_name [DI_PATH_MAX];

        status = di$split ( pathname = cell_names [i], name = cell_names [i],
			    dirname = dir_name );
        om_send ( DIstorage.remove_info ( &status, cell_names [i], NULL ),
                  my_id, cell_dir_id );

        /* find the OS we are pseudo-unmounting */
        root_grid = cell_grids [i];
        DIcheck_link ( (root_grid.osnum), (root_grid.objid) )
	DIunall ( root_grid.osnum, root_grid.objid, dir_name,
		  cell_names [i], 1, NULL, NULL );
      }
  }
  else
  {
    int   i, j, status, count;
    char  name [DI_PATH_MAX], **lines;
    DIgrid  *grids;

    /* check that the cell libraries have been unmounted */
    DIstmocpy ( name, "cell", "*", 0, OM_Gw_current_OS );
    for (j = 0, grids = NULL; j < 2; j++ )
    {
      status = di$dump ( regexp = name, lines = &lines, grids = &grids,
                         ptr    = &count, options = OPT_ALL );
      for (i = 0; i < count; i++)
        if (DIancestry_valid ( grids [i].osnum, grids [i].objid, DIR_G_DIlink_clid ))
        {
          status = di$umount ( dirname = lines [i] );
          if (status != DIR_S_SUCCESS)
            di$report_error ( sts = status, comment = "cell - ref clean up" );
        }
      if (grids) DIfree ( grids );
      di$free ( lines = lines, count = count );

      /* check that the reference files have been unmounted */
      DIstmocpy ( name, "ref", "*", 0, OM_Gw_current_OS );
    }
  }

  /* we cd to a valid directory */
  di$cd ( dirname = ":transient" );

  DIlock_form ();
  DIupdate_form ();

  return OM_S_SUCCESS;
}


method wake_up()
{
  int     status;
  char    current [DI_PATH_MAX];
  static  int config = 0;
  DIobjid home_id;
  OMuword osnum, mod_osnum;

  if (DIis_ref ())
    return OM_S_SUCCESS;

  if (ref_index)
  {
    int     i;
    DIobjid ref_dir_id;
    DIgrid  grid;
    char    name [DI_PATH_MAX];

    /* re-mount the os */
    DIstmocpy ( name, "ref", 0, OM_Gw_current_OS );
    DImasterRetrieve ( &status, name, NULL, (DIchar *)&grid, NULL, NULL );
    ref_dir_id = grid.objid;
    for (i = 0; i < ref_index; i++)
      if (DIancestry_valid ( ref_grids [i].osnum, ref_grids [i].objid,
                             DIR_G_DIlink_clid ))
      {
        DIgrid root_grid;

        om_send ( DIstorage.store_info ( &status, ref_names [i], (DIchar *)&ref_grids [i].objid, NULL ),
                  my_id, ref_dir_id );

        /* find the OS we are pseudo-mounting */
        root_grid = ref_grids [i];
        DIcheck_link ( (root_grid.osnum), (root_grid.objid) )
	DIunall ( root_grid.osnum, root_grid.objid, name, ref_names [i],
		  NULL, NULL, NULL );
      }
    
    DIfree ( ref_grids );
    di$free ( lines = ref_names, count = ref_index );
    ref_index = NULL;
  }

  if (cell_index)
  {
    int     i;
    DIobjid cell_dir_id;
    DIgrid  grid;
    char    name [DI_PATH_MAX];

    /* re-mount the os */
    DIstmocpy ( name, "cell", 0, OM_Gw_current_OS );
    DImasterRetrieve ( &status, name, NULL, (DIchar *)&grid, NULL, NULL );
    cell_dir_id = grid.objid;
    for (i = 0; i < cell_index; i++)
      if (DIancestry_valid ( cell_grids [i].osnum, cell_grids [i].objid,
                             DIR_G_DIlink_clid ))
      {
        DIgrid root_grid;

        om_send ( DIstorage.store_info ( &status, cell_names [i], (DIchar *)&cell_grids [i].objid, NULL ),
                  my_id, cell_dir_id );

        /* find the OS we are pseudo-mounting */
        root_grid = cell_grids [i];
        DIcheck_link ( (root_grid.osnum), (root_grid.objid) )
	DIunall ( root_grid.osnum, root_grid.objid, name, cell_names [i],
		  NULL, NULL, NULL );
      }
    
    DIfree ( cell_grids );
    di$free ( lines = cell_names, count = cell_index );
    cell_index = NULL;
  }

  /* restore the current directory */
  *current = '\0';
  di$cvt_name_from_input ( u_path = me->current, s_path = current );
  status = di$cd ( dirname = current, p_osnum = &osnum );
  ex$get_cur_mod ( osnum = &mod_osnum );
  if (status != DIR_S_SUCCESS || (osnum != mod_osnum))
  {
    /* problem (could not cd or not in the design file) -> go to usr directory */
    DIstmocpy ( current, "usr", 0, OM_Gw_current_OS );
    status = di$cd ( dirname = current );
    if (status != DIR_S_SUCCESS)
    {
      DIstmocpy ( current, "", 0, OM_Gw_current_OS );
      status = di$cd ( dirname = current );
      if (status != DIR_S_SUCCESS)
        di$report_error ( sts = status, comment = "super_dir.wakeup->cd" );
    }
  }

  /* check if home directory is OK */
  if (di$translate ( objname = me->home, p_objid = &home_id ) != DIR_S_SUCCESS)
    DIstrcpy ( DIR_G_home_name, current );
  else
    DIstrcpy ( DIR_G_home_name, me->home );

  DIunlock_form ();

  /* read the config file (some commands only) */
  if (!config)
  {
    char filename [80];
    int  j, status;
    FILE *fet;

    config = 1;
    for (status = 1, j = 0; status; j++)
      if (status = ex$get_path ( index = j, 
                                 path  = filename,
                                 len   = 80 ))
      {
        strcat ( filename, "config/IGRdir.cfg" );
        fet = fopen ( filename, "r" );
        if (fet)
        {
          char line [DI_PATH_MAX];

          while (DIread_line ( fet, line ))
          {
            DIclean ( line );

            switch (DIget_choice ( line ))
            {
              case TRL : DInew_trailer ( line );
                         break;
            }
          }

          fclose ( fet );
        }
      }
  }

  DIupdate_form ();

  return OM_S_SUCCESS;
}


DIlock_form ()
{
  /* DIform should be locked */
  return DIR_S_SUCCESS;
}


DIunlock_form ()
{
  /* DIform should be unlocked */
  return DIR_S_SUCCESS;
}


int DIupdate_form ()
{
  int         status;
  DIobjid     form_id;
  OMuword     form_os;
  Form        form1;
  extern void DIget_dir_form();

  DIget_dir_form ( &form1 );

  if (form1)
  {
    status = FIf_get_cmd_oid_os ( form1, &form_id, &form_os );
    if (!status)
      status = om$send ( msg      = message FIdirform.update (),
                         senderid = NULL_OBJID,
                         targetid = form_id,
                         targetos = form_os );
  }

  return DIR_S_SUCCESS;
}


end implementation super_dir;
