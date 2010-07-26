/*
  ABSTRACT :
  --------

   This file constains the routines related to the linking feature.
*/

class implementation DIrectory;


#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIomac.h"
#include "DIprims.h"
#include "DIdef.h"

DIlink2 ( DIchar *obj_name1, DIchar *path, DIint synpath,
         DIspacenum osnum1, DIobjid objid1, DIchar *new_name )
/* This procedure is used to link two entries of the directory sub-system.
   Note that if a name (obj_name) is given, the osnum & objid are ignored. */
{
  DIint      status;
  DIobjid    objid = objid1;
  DIspacenum osnum = osnum1;
  DIchar     obj_name [DI_PATH_MAX];

  path = NULL;
  synpath = 0;
  if (obj_name1)
  { status = di$translate ( objname = obj_name1, p_objid = &objid, p_osnum = &osnum );
    DIstrcpy ( obj_name, obj_name1 ); }
  else
    status = di$untranslate ( objname = obj_name, objid = objid, osnum = osnum);

  /* linking linked directories is not allowed for now */
  { DIchar     new [DI_PATH_MAX], new_dir [DI_PATH_MAX],
               old [DI_PATH_MAX], old_dir [DI_PATH_MAX];
    DIint      syno = 0;
    DIobjid    objid;
    DIspacenum osnum;

    DIexpanse ( new_name, new );
    di$split ( pathname = new, dirname = new_dir );
    di$translate ( objname = new_dir, p_objid = &objid, p_osnum = &osnum );
    di$start_untrans ( objid = objid, osnum = osnum, ptr = &syno );
    if (syno > 1)
      status = DIR_E_INVARG;
    else
    { syno = 0;
      DIexpanse ( obj_name, old );
      di$split ( pathname = old, dirname = old_dir );
      di$translate ( objname = old_dir, p_objid = &objid, p_osnum = &osnum );
      di$start_untrans ( objid = objid, osnum = osnum, ptr = &syno );
      if (syno > 1) status = DIR_E_INVARG; }}
  

  if (status == DIR_S_SUCCESS)
    if (di$is_regexp ( regexp = obj_name ) || di$is_regexp ( regexp = new_name))
      status = DIR_E_INVARG;
    else
    { DIspacenum loc_osnum;
 
      /* check OS */
      status = di$give_osnum ( pathname = new_name, p_osnum = &loc_osnum );
      if ((status == DIR_S_SUCCESS) && (osnum == loc_osnum))
      { if (DIancestry_valid ( osnum, objid, DIR_G_IGRdir_clid ))
        {
          /* directories : check that no loop */
        }

        if (status == DIR_S_SUCCESS)
        { DIchar  path_name [DI_PATH_MAX], base_name [DI_PATH_MAX], 
                  dir_name [DI_PATH_MAX];
          DIgrid  target_grid;

          DIexpanse ( new_name, path_name );
          di$split ( pathname = path_name, dirname = dir_name,
                     name = base_name );
          DImasterRetrieve ( &status, dir_name, 0, (DIchar *) &target_grid, NULL, NULL );
          DIcheck_link ( target_grid.osnum, target_grid.objid )
          if ((status = DIadd_name ( path_name, 0, target_grid, base_name,
                                     objid, 0, 0, 0 )) == DIR_S_SUCCESS)
          { if (DIancestry_valid ( osnum, objid, DIR_G_DIlink_clid ))
            { DIspacenum root_os;
              DIobjid    root_id;

              /* the directory is a link : add the root of the OS */
              om$get_intercept ( osnum = osnum, objid = objid,
                                 p_target_osnum = &root_os, p_target_objid = &root_id );
              DIunall ( root_os, root_id, dir_name, base_name, 0, NULL, NULL );  
            }

            DIlink_down ( obj_name, osnum, objid, new_name, 0 ); }}
      else
        status = DIR_E_ILL_LINK;
    }
  }

  return status;
}


DIlink_down ( DIchar * old_name, DIspacenum osnum, DIobjid objid,
              DIchar * new_name, DIint add )
/* This procedure is used to link two entries of the directory sub-system. */
{
  DIchar  objname [DI_PATH_MAX], dirname [DI_PATH_MAX];
  DIint   status = DIR_S_SUCCESS;

  if (add)
  { di$split ( pathname = new_name, dirname = dirname, name = objname );
    if (status == DIR_S_SUCCESS)
    { /* add it to the untranslate tree */
      DIunall ( osnum, objid, dirname, objname, 0, NULL, NULL );  
      if (DIancestry_valid ( osnum, objid, DIR_G_DIlink_clid ))
      { DIspacenum root_os;
        DIobjid    root_id;

        /* the directory is a link : add the root of the OS */
        om$get_intercept ( osnum = osnum, objid = objid,
                           p_target_osnum = &root_os, p_target_objid = &root_id );
        DIunall ( root_os, root_id, dirname, objname, 0, NULL, NULL );  
      }}}

  if (status == DIR_S_SUCCESS)
    if (DIancestry_valid ( osnum, objid, DIR_G_IGRdir_clid ))
    { DIgrid *grids;
      DIchar full_name [DI_PATH_MAX], old [DI_PATH_MAX], new [DI_PATH_MAX], 
             reg_exp [DI_PATH_MAX], **lines;
      DIint  i, count;

      DIexpanse ( old_name, old );

      DIexpanse ( new_name, full_name );
      DIstrcpy ( new, full_name );

      /* find all the children and update the tables */
      DIstrcpy ( reg_exp, old );
      DIstrcat ( reg_exp, "*" );
      di$dump ( regexp = reg_exp, lines = &lines, grids = &grids,
                options = OPT_ALL, ptr = &count );
      for (i = 0; (i < count) && (status == DIR_S_SUCCESS); i++)
      { DIchar new_full [DI_PATH_MAX];

        DIstrcpy ( new_full, lines [i] );
        DIchstr ( new_full, old, new );
       
        /* This is a kludge. - explained below */
        
       if( check_IGRdir_ancestry (grids[i].osnum, grids[i].objid) )
          continue;
	/*  End Kludge   */

        status = DIlink_down ( lines [i], grids [i].osnum, grids [i].objid, new_full, 1 ); }

      if (count)
      { di$free ( lines = lines, count = count );
        DIfree ( grids ) }}

  return status;
}

/* In cases like a GRpart object containing another GRpart object in its    
 * to_components channel, the above code gets into an infinite loop. Hence, 
 * adding this kludge. - Srikanth.
 *
 * Note : The infinite loop occurs since di$dump returns the objid and
 * osnum of the attached GRpart object (example) but the directory path still 
 * contains that of the present object instead of its component object's. 
 * This, because of the 'regexp' to di$dump can't specify this. 
 * Also, if the any components of the incoming object has IGRdir class in its
 * ancestry, the components down won't be linked.
 */

int check_IGRdir_ancestry(osnum, objid)
DIspacenum osnum;
DIobjid    objid;
{
   if ( DIancestry_valid(osnum, objid, DIR_G_IGRdir_clid) )
      return(1);
   else
      return(0);

}

end implementation DIrectory;

