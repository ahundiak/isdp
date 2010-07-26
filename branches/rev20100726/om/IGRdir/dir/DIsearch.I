/*
  ABSTRACT :
  --------

   This file constains the main procedure for IGRdir calls that involve a
name and/or a regular expression.  It also takes care of the search path stuff.

  HISTORY :
  -------

   07/12/1988 : HGB - Creation Date
   08/01/1988 : SRH - Search Path
   08/01/1988 : HGB - Scan all directories when there is a regular expression
   08/08/1988 : HGB - Add targetos in DImain
   08/25/1988 : SRH - Added synpath arg to all functions that have a search
                      path argument (path)
   06/09/1989 : SRH - Working on search path efficiencies
   09/25/1989 : JSD - Rewrote search path code using "the" algorithm
   06/04/1992 : EMS - change PATH_MAX to DI_PATH_MAX

*/

class implementation DIrectory;

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIdef.h"
#include "DIglob.h"

#define DEBUG
#include "DIdebug.h"
#include "DIomac.h"


DIboolean _is_absolute_name( name )
   DIchar *name;
{
  /* 
   *  If the name is absolute, do not append the path. In this case we
   *  define an absolute *  name as one that begins with ":", "~:", ".:",
   *  or "..:" )
   */

  DIchar dotdot[3],   /* ".."  */
         dotdotc[4],   /* "..:" */
	 dot[2],      /* "."   */
	 dotc[3],      /* ".:"  */
	 tilda[2],    /* "~"   */
	 tildac[3];    /* "~:"  */

  tilda[0] = tildac[0] = '~';

  dot[0] = dotc[0] = dotdot[0] = dotdot[1] = dotdotc[0] = dotdotc[1]   =   '.'; 
  dotc[1] = dotdotc[2] = tildac[1]    =   DIR_G_car_dir; 
  dot[1] = dotc[2] = tilda[1] = tildac[2]  = dotdot[2] = dotdotc[3]   =   '\0';
  
  return (   ( name[0] == DIR_G_car_dir ) 
          || ! ( (strncmp ( dot,    name, 1 ))
          &&     (strncmp ( dotdot, name, 2 ))
          &&     (strncmp ( tilda,  name, 1 ))
          &&     (strncmp ( dotc,   name, 2 ))
          &&     (strncmp ( dotdotc,name, 3 ))
          &&     (strncmp ( tildac, name, 2 )) ) ) ? TRUE : FALSE;


} /* end _is_absolute_name */



DIadd_os_path ( to_name, from_name, os )
                DIchar     *to_name     /* result (name + path name)    OUT */;
                DIchar     *from_name   /* source name                  IN  */;
                DIspacenum os           /* OS to deal with              IN  */;
/*
   This procedure adds a path name to the os (if any) at the beginning
   of from_name.  The result is put in to_name.  If from_name is a full 
   path name, from_name is copied into to_name.
*/
{
  DIint  status = DIR_S_SUCCESS;
  DIchar tmp [DI_PATH_MAX];

  if (from_name)
    if (os)
    {
      if (*from_name != DIR_G_car_dir)
      {
        status = di$give_pathname ( osnum = os, pathname = tmp );
        if (status == DIR_S_SUCCESS)
        {
          status = DIstrcat ( tmp, from_name );
          if (status == DIR_S_SUCCESS)
            status = DIstrcpy ( to_name, tmp );
        }
      }
      else
        status = DIstrcpy ( to_name, from_name );
    }
    else
      status = DIstrcpy ( to_name, from_name );

  return status;
}

#argsused

DImain ( DIchar * path, DIint synpath, OM_p_CLASSLIST classes,
         DIint (*basic)(), DIint number, DIchar * name, DIspacenum osnum,
         DIobjid objid, DIchar *new_name,
         DIobjid * p_objid, DIspacenum * p_osnum, DIchar *** lines,
         DIgrid ** grids, DIint * ptr, DIchar options, DIchar translate,
         DIspacenum targetos )

/*
   This procedure is used to process the regular expression.  It calls the
   dump primitive and the basic entry point.  The basic entry point is
   called for each name.  The number of calls to basic is limited by number
   (if number >= 0).  This entry point is also used by the di$dump macro
   (in this case, basic is NULL).
*/
{
  DIint   status = DIR_S_SUCCESS, counter = 0;
  DIchar  *tmp, tmp_name[DI_PATH_MAX], local_name[DI_PATH_MAX];
  DIobjid s_objid = objid;

  do
  {
    status = DIR_S_SUCCESS;
    strcpy ( local_name, name );

    if ( ! _is_absolute_name (local_name) )
    {
      if ( path )
      {
        tmp = strchr ( path, ' ' );
        if ( tmp ) *tmp = '\0';
        if ( ! _is_absolute_name (path) )
        {
          if ( targetos )
	  {
            DIadd_os_path ( tmp_name, path, targetos );
            DIfrtcat ( local_name, tmp_name );
	  }
          else
          {
	    DIfrtcat ( local_name, path );
            DIfrtcat ( local_name, DIR_G_cur_dir_name );
          }
        }
	else
          DIfrtcat ( local_name, path );
      }
      else
      {
        tmp = NULL;

        if ( targetos )
        {
          DIadd_os_path ( tmp_name, local_name, targetos );
          strcpy ( local_name, tmp_name );
        }
        else
          DIfrtcat ( local_name, DIR_G_cur_dir_name );
      }
    }
    else
      tmp = NULL;

    if (ptr) *ptr = 0;
    if (name)
    {
      DIint  limit;
      DIchar target_name [DI_PATH_MAX], loc_name [DI_PATH_MAX], 
             base_name [DI_PATH_MAX];

      if ((status = DIexpanse ( local_name, loc_name )) == DIR_S_SUCCESS)
      {
        DIint   i, mcount = 0;
        DIchar  **mlines;
        DIgrid  *targets  = NULL /* the grid of the target directories */;

        di$split ( pathname = loc_name, dirname = target_name, name = base_name );
	if ( ! strcmp ( loc_name, "" ) ) target_name[0] = '\0';
#define PATIENCE
#ifdef PATIENCE
        for (mcount = 0; !mcount; )
        {
#endif
          DImasterDump ( &status, target_name, NULL, &mlines, &targets,
              &mcount, (DIchar) (options & ~OPT_TRAILER) );
#ifdef PATIENCE
          if (strcmp ( target_name, DIR_G_str_dir ) && !mcount)
          /* recursive dump: kludge for ACmacros	*/
          {
            char dir [DI_PATH_MAX], base [DI_PATH_MAX];

            di$split ( pathname = target_name, dirname = dir, name = base );
            DIstrcpy ( target_name, dir );
            DIfrtcat ( base_name, base );
          }
          else
            break;
        }
#endif

        limit = (number == -1) ? mcount : (number < mcount) ? number : mcount;
        for (i = 0; (i < mcount) && (counter < limit) && ((status == DIR_S_SUCCESS) || 
             (status == DIR_W_NAME_NOT_FOUND) || (status == DIR_W_DIR_NOT_FOUND)); i++, objid = s_objid )
        {
          DIcheck_link ( (targets [i].osnum), (targets [i].objid) )
          if (di$is_regexp ( regexp = base_name ))
          {
            DIint   j, dir_count = 0;
            DIchar  **dir_lines;
            DIgrid  *dir_grids;

            om_send_for ( IGRdir.dump ( &status, base_name, classes, &dir_lines,
                                        &dir_grids, &dir_count, options ),
                          NULL_OBJID, targets [i].objid, targets [i].osnum );
            if (status == DIR_S_SUCCESS)
            {
              limit += (number == -1) ? dir_count
                 : (limit + dir_count <= number) ? dir_count: (number - limit);

              for (j = 0; (counter < limit) && (j < dir_count) && ((status == DIR_S_SUCCESS) ||
                   (status == DIR_W_NAME_NOT_FOUND) || (status == DIR_W_DIR_NOT_FOUND)); j++, objid = s_objid )
              {
                DIchar  *full_path, buffer [DI_PATH_MAX];

                if (dir_lines [j])
                {
                  full_path = buffer;
                  DIstrcpy ( full_path, mlines [i] );
                  DIstrcat ( full_path, dir_lines [j] );
                }
                else
                  full_path = NULL;

                if (basic)
                  status = basic ( (full_path) ? full_path : "",
                                   (mlines [i]) ? mlines [i] : "",
                                   targets [i],
                                   (dir_lines [j]) ? dir_lines [j] : "",
                                   (objid == NULL_OBJID) ? dir_grids[j].objid : objid,
                                   new_name, p_objid, p_osnum );
                DIadd_grid_line ( lines, grids, full_path, dir_grids [j], counter );
                if (status == DIR_S_SUCCESS) counter++;
              }

              di$free ( lines = dir_lines, count = dir_count );
              if (dir_grids) DIfree ( dir_grids )
            }
            else
              /* if no call to basic, the search may proceed */
              if (!basic && status == DIR_I_DIR_EMPTY)
                status = DIR_S_SUCCESS;
          }
          else
          {
            DIchar  full_path [DI_PATH_MAX];
            DIgrid  grid;

            DIstrcpy ( full_path, mlines [i] );
            DIstrcat ( full_path, base_name );
            if ((objid == NULL_OBJID) && translate)
            {
              om_send_for ( IGRdir.translate ( &status, base_name, 0, NULL, &objid ),
                            NULL_OBJID, targets [i].objid, targets [i].osnum );
              if (DIcheck_class ( classes, targets [i].osnum, objid )
                        != DIR_S_SUCCESS)
                break;
            }
            if (basic)
              status = basic ( full_path, mlines [i], targets [i], base_name,
                               objid, new_name, p_objid, p_osnum );
            grid.objid = objid; grid.osnum = targets [i].osnum,
            DIadd_grid_line ( lines, grids, full_path, grid, counter );
            if (status == DIR_S_SUCCESS) counter++;
          }
        }
        
        if ((status == DIR_W_DIR_NOT_FOUND || status == DIR_W_NAME_NOT_FOUND) &&
            counter != 0)
          /* last directory didn't find it but another one did */
          status = DIR_S_SUCCESS;

        /* free the tables */
        di$free ( lines = mlines, count = mcount );
        DIfree ( targets )
      }
    }
    else
      status = DIR_E_INVARG;

    if (status == DIR_S_SUCCESS)
    {
      if (ptr) *ptr = counter;
      if (!basic && !counter) status = DIR_I_DIR_EMPTY;
      path = NULL;
    }

    if ( tmp )
    {
      *tmp = ' ';
      path = tmp+1;
    }
    else
      path = NULL;
  }
  while ( path && (status != DIR_S_SUCCESS) );

  return status;
}

end implementation DIrectory;
