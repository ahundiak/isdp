/*
    ABSTRACT :
    --------

    This is the implementation file of the class IGRdir_mst.  
    This class provides the directory of directories capability.  The method
    ls is overriden to support regular expression searches of directories.
*/

class implementation DImaster;

#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "DIglob.h"
#include "GRtypedef.h"
#include "GRdef.h"
#include "GRglob.h"
#include "DIprims.h"
#include "GRprims.h"
#include "DIomac.h"


method IGRdir.init ( DIint *status )
{
  om_send_me_msg ( IGRdir.init ( status ) );
  om_send_me ( DIstorage.init ( status ) );

  return OM_S_SUCCESS;
}


method retrieve_info ( DIint *status; DIchar *key; DIint index; DIchar *info;
                       DIchar *name; DIint *p_index; )
{
  if (*key)
    if (strcmp ( DIR_G_cur_dir_name, key ))
      om_send_me_msg ( DIbstgr.retrieve_info ( status, key, index, info, name, p_index ) )
    else
      if (info)
      { ((DIgrid *)info)->objid = DIR_G_cur_dir_id;
        ((DIgrid *)info)->osnum = DIR_G_cur_dir_os;
        *status = DIR_S_SUCCESS; }
      else
        *status = DIR_E_INVARG;
  else
    if (info)
    { /* translating the root */
      ((DIgrid *)info)->objid = DIR_G_root_id;
      ((DIgrid *)info)->osnum = DIR_G_root_os;
      *status = DIR_S_SUCCESS; }
    else
      *status = DIR_E_INVARG;

  return OM_S_SUCCESS;
}

#argsused  
DImasterRetrieve ( status, key, index, info, name, p_index )
DIint *status; 
DIchar *key; 
DIint index; 
DIchar *info; 
DIchar *name; 
DIint *p_index;
{
  /*
   * Validation (permission) can be turned off since this entry point is only called
   * internally.
   */
  GRDisableValidate ();

  /*
   * Test if we are translating the root directory (root is empty string)
   */
  if (*key)
  {
    /*
     * If we are translating the current directory then it's fast and easy
     */
    if (strcmp ( DIR_G_cur_dir_name, key ))
    {
      DIgrid dir_grid;
      DIchar *ptr1, *ptr2, tmp_name [DI_PATH_MAX];
      
      /*
       * dir_grid is the directory we are looking at and tmp_name is the
       * path_name that remains to be translated.
       */
      /*
       * Check if we are translating a full or a relative pathname. In the later,
       * we must start at the current.
       */
      if (*key == DIR_G_car_dir)
      {
        /*
         * Test if the beginning of the path name is the current directory. In that
         * case we can start to translate from there (faster).
         */
        if (!strncmp ( key, DIR_G_cur_dir_name, strlen ( DIR_G_cur_dir_name ) ))
        {
          dir_grid.osnum = DIR_G_cur_dir_os;
          dir_grid.objid = DIR_G_cur_dir_id;
          DIstrcpy ( tmp_name, &key [strlen ( DIR_G_cur_dir_name )] );
        }
        else
        {
          dir_grid.osnum = DIR_G_root_os;
          dir_grid.objid = DIR_G_root_id;
          DIstrcpy ( tmp_name, key );
        }
      }
      else
      {
        dir_grid.osnum = DIR_G_cur_dir_os;
        dir_grid.objid = DIR_G_cur_dir_id;
        DIstrcpy ( tmp_name, key );
      }

      /*
       * ptr1 points to the beginning of the string (base name) we are translating
       * ptr2 points to the next delimiter (:) or is NULL when translating the last
       * base name.
       */      
      ptr1 = (tmp_name [0] == DIR_G_car_dir) ? &tmp_name [1] : &tmp_name [0];
      ptr2 = strchr ( ptr1, DIR_G_car_dir );
      for (;;)
      {
        if (ptr2)
          *ptr2 = '\0';

        om_send_for ( IGRdir.translate ( status, ptr1, 0, NULL, &dir_grid.objid ),
                 NULL_OBJID, dir_grid.objid, dir_grid.osnum );
        if (*status != DIR_S_SUCCESS)
          break;
          
        if (ptr2)
        {
          /*
           * Restore the : and extract the next base name.
           */
          *ptr2 = DIR_G_car_dir;
          ptr1 = ++ptr2;
          ptr2 = strchr ( ptr1, DIR_G_car_dir );

          /*
           * In the case of a DIlink, we have to get the real directory (in the other
           * object space).
           */
          if (DIancestry_valid ( dir_grid.osnum, dir_grid.objid, DIR_G_DIlink_clid ))
          {
            om$get_intercept ( osnum = dir_grid.osnum, objid = dir_grid.objid,
               p_target_osnum = &dir_grid.osnum, p_target_objid = &dir_grid.objid );
          }
        }
        else
          break;
      }
      
      if ((*status == DIR_S_SUCCESS) && info)
      {
        ((DIgrid *)info)->objid = dir_grid.objid;
        ((DIgrid *)info)->osnum = dir_grid.osnum;
      }
    }
    else
      if (info)
      { ((DIgrid *)info)->objid = DIR_G_cur_dir_id;
        ((DIgrid *)info)->osnum = DIR_G_cur_dir_os;
        *status = DIR_S_SUCCESS; }
      else
        *status = DIR_E_INVARG;
  }
  else
    if (info)
    { /* translating the root */
      ((DIgrid *)info)->objid = DIR_G_root_id;
      ((DIgrid *)info)->osnum = DIR_G_root_os;
      *status = DIR_S_SUCCESS; }
    else
      *status = DIR_E_INVARG;

  GREnableValidate ();

  return OM_S_SUCCESS;
}


/* The following Globals are transmitted to the DIls_driver */

extern OM_p_CLASSLIST DIR_G_classlist	/* classlist of elements to be listed	*/;
extern DIchar	       ***DIR_G_lines	/* buffer to malloc			*/;
extern DIgrid	       **DIR_G_grids	/* buffer to malloc			*/;
extern DIchar	       DIR_G_options	/* options to be considered		*/;
extern DIint          DIR_G_count	/* number of processed itmes		*/;
extern DIint          DIR_G_level	/* number of levels in the reg. exp.	*/;


DImasterDump ( DIint *status, DIchar *reg_exp, OM_p_CLASSLIST classlist,
   DIchar ***lines, DIgrid **grids, DIint *count, DIchar options )
{
  if (!count) 
  { 
    *status = DIR_E_INVARG; 
    return OM_W_ABORT; 
  }

  DIR_G_classlist = classlist;  
  DIR_G_lines     = lines;
  DIR_G_grids     = grids;      
  DIR_G_options   = options;
  DIR_G_count     = *count;     
  DIR_G_level     = DIget_level ( reg_exp );

  if (di$is_regexp ( regexp = (reg_exp) ? reg_exp : "*" ))
  {
    DIchar *ptr1, current_path [DI_PATH_MAX];
    DIgrid grid;
    
    if (*reg_exp == DIR_G_car_dir)
    {
      /*
       * I start to translate from the root
       */
      strcpy ( current_path, DIR_G_str_dir );
      ptr1 = &reg_exp [1];
      grid.osnum = DIR_G_root_os;
      grid.objid = DIR_G_root_id;
    }
    else
    {
      /*
       * I start to translate from the current
       */
      strcpy ( current_path, DIR_G_cur_dir_name );
      grid.osnum = DIR_G_cur_dir_os;
      grid.objid = DIR_G_cur_dir_id;
      ptr1 = reg_exp;
    }

    *count = 0;    
    DIInvestigatePath ( ptr1, grid, current_path, lines, grids, count );
    
    *status = *count ? DIR_S_SUCCESS : DIR_W_NAME_NOT_FOUND;
  }
  else
  { 
    DIint  type = DIR_D_STRING_GRID;
    DIgrid grid;

    /* not a regular expression -> translate */
    DImasterRetrieve ( status, reg_exp, 0, (char *)&grid,
       (char *)NULL, (int *)NULL );
    if (*status == DIR_S_SUCCESS)
    {
      DIls_driver ( (DIchar) type, (DIchar *) &grid, reg_exp ); 
      *count = DIR_G_count = 1;
    }
  }

  return OM_S_SUCCESS;
}


method debug ()
{
  om_send_msg ( DIbstgr.debug (), my_id, my_id );

  return OM_S_SUCCESS;
}


method give_pointer ( DIchar *key, **ptr )
{
  extern DIint *DIBlast;
  DIint  status;

  /* find the entry */
  om_send_me_msg ( DIbst.retrieve_info ( &status, key, 0, NULL, NULL, NULL ) );
  *ptr = ind_nm ( my_last );

  return OM_S_SUCCESS;
}


DIInvestigatePath ( path, grid, current_path, lines, grids, count )
DIchar *path	     /* The path we are looking for			IN  */;
DIgrid grid	     /* The directory to start at			IN  */;
DIchar *current_path /* The full pathname of grid			IN  */;
DIchar ***lines      /* Where to return the names			OUT */;
DIgrid **grids	     /* Where to return the grids			OUT */;
DIint  *count        /* The number of entries found			OUT */;
/*
 * This routine looks for path starting from grid. The current_path
 * is maintained to return the full pathnames in lines.
 */
{
  DIchar *ptr1, *ptr2;
  DIint  status;
  
  /*
   * We split the path (isolate the first component)
   */
  ptr1 = path;
  ptr2 = strchr ( path, DIR_G_car_dir );
  if (ptr2)
    *ptr2 = '\0';
  if (di$is_regexp ( regexp = ptr1 ))
  {
    DIchar **local_lines = NULL;
    DIgrid *local_grids = NULL;
    DIint  i, local_count = 0;
    
    /*
     * We get the list of names that match the regular expression and their grid
     */
    om_send_for ( IGRdir.dump ( &status, ptr1, NULL, &local_lines, &local_grids, &local_count, 
             0 ), NULL_OBJID, grid.objid, grid.osnum );
    if (status == DIR_S_SUCCESS)
    {
      if (ptr2)
      {
        /*
         * For each name, we investigate if the path leads to anything
         */
        *ptr2 = DIR_G_car_dir;
        for (i = 0; i < local_count; i++)
        {
          DIchar local_current_path [DI_PATH_MAX];
        
          DIstrcat ( strcpy ( local_current_path, current_path ), local_lines [i] );
  
          /*
           * In the case of a DIlink, we have to get the real directory (in the other
           * object space).
           */
          if (DIancestry_valid ( local_grids [i].osnum, local_grids [i].objid, DIR_G_DIlink_clid ))
          {
            om$get_intercept ( osnum = local_grids [i].osnum, objid = local_grids [i].objid,
               p_target_osnum = &local_grids [i].osnum, p_target_objid = &local_grids [i].objid );
          }
          
          DIInvestigatePath ( ptr2 + 1, local_grids [i], local_current_path, lines, grids, count );
        }
      }
      else
      {
        for (i = 0; i < local_count; i++)
        {
          DIchar local_current_path [DI_PATH_MAX];
        
          /*
           * We want to return directories nothing but directories
           */
          if (DIancestry_valid ( local_grids [i].osnum, local_grids [i].objid, DIR_G_IGRdir_clid ))
          {
            DIstrcat ( strcpy ( local_current_path, current_path ), local_lines [i] );
            DIadd_grid_line ( lines, grids, local_current_path, local_grids [i], *count );
            (*count)++;
          }
        }
      }
      
      di$free ( lines = local_lines, count = local_count );
      free ( local_grids );
    }
  }
  else
  {
    om_send_for ( IGRdir.translate ( &status, ptr1, 0, NULL, &grid.objid ),
             NULL_OBJID, grid.objid, grid.osnum );
    if (status == DIR_S_SUCCESS)
    {
      DIchar local_current_path [DI_PATH_MAX];
      
      DIstrcat ( strcpy ( local_current_path, current_path ), ptr1 );
      if (ptr2)
      {
        /*
         * In the case of a DIlink, we have to get the real directory (in the other
         * object space).
         */
        if (DIancestry_valid ( grid.osnum, grid.objid, DIR_G_DIlink_clid ))
        {
          om$get_intercept ( osnum = grid.osnum, objid = grid.objid,
             p_target_osnum = &grid.osnum, p_target_objid = &grid.objid );
        }
  
        /*
         * Restore the : and build the current path (name of the grid)
         */
        *ptr2 = DIR_G_car_dir;
        DIInvestigatePath ( ptr2 + 1, grid, local_current_path, lines, grids, count );
      }
      else
      {
        /*
         * We want to return directories nothing but directories
         */
        if (DIancestry_valid ( grid.osnum, grid.objid, DIR_G_IGRdir_clid ))
        {
          DIadd_grid_line ( lines, grids, local_current_path, grid, *count );
          (*count)++;
        }
      }
    }
  }
  
  return DIR_S_SUCCESS;
}

end implementation DImaster;
