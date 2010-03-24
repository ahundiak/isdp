/*
  ABSTRACT :
  --------

   This file constains the routines related to the dump feature.

  HISTORY :
  -------

   06/15/1988 : HGB - Design Date
   06/04/1992 : EMS - change PATH_MAX to DI_PATH_MAX

*/

class implementation DIrectory;

#define DEBUG

#include <string.h>
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DIomac.h"
#include "DIprims.h"
#include "DIdef.h"

int DIstart_dump (DIchar ls, OM_p_CLASSLIST classes, DIchar *reg_exp, 
    DIint *count, DIchar options)
/*
   This entry point is used to initiate an ls/dump to the system.  Rather than
   being given to the user, the result of the execution is saved in a
   buffer to be retrieved, one at a time, using the function DIfetch_dump
*/
/*.DIstart_dump */
{
  DIint status;

  if (!count) return DIR_E_INVARG;
  if (DIR_G_dump_count)
  {
    di$free ( lines = DIR_G_dump_lines, count = DIR_G_dump_count );
    if (DIR_G_dump_grids) DIfree ( DIR_G_dump_grids )
  }

  if ((status = di$dump ( p_classes = classes, regexp = reg_exp, 
             lines = &DIR_G_dump_lines, grids = (ls) ? NULL : &DIR_G_dump_grids,
             ptr = &DIR_G_dump_count, options = options )) != DIR_S_SUCCESS)
    DIR_G_dump_count = 0;
  *count = DIR_G_dump_count;

  return status;
}



DIfetch_dump ( line, p_grid, index )
               DIchar line [DI_PATH_MAX]/* Line to put the result in	OUT */;
               DIgrid *p_grid		/* Grid of object 		OUT */;
               DIint  index		/* Index of entry		IN  */;
/*
   This entry point is used to get an entry from the result of a 
   DIstart_dump execution.
*/
/*.DIfetch_dump */
{
  DIint status = DIR_S_SUCCESS;

  if ((index >= 0) && (index < DIR_G_dump_count))
  {
    if (line)
      if (DIR_G_dump_lines [index])
        strcpy ( line, DIR_G_dump_lines [index] );
      else
        status = DIR_W_NO_NAME;
    if (p_grid) *p_grid = DIR_G_dump_grids [index];
  }
  else
    status = DIR_E_OVFLOW;

  return status;
}

int DIfind (DIchar *start_dir, DIchar *reg_exp, DIchar ***lines,
            DIgrid **grids, DIint *count, DIint max_level, DIint *deep,
            DIchar options)
/*
   This entry point is used to find down the names that match the given regular
   expression, starting from the current directory.  If lines is specified,
   not NULL, the result is filled in it, otherwise it is printed to stdout.
*/
/*.DIfind */ 
{
  DIint  i, status, level, buf_count, nbr, loc_deep;
  DIchar **expbuf, dir_name [DI_PATH_MAX], **my_lines;
  DIgrid *my_grids;

  *count = 0;  nbr = 0; loc_deep = 0;
  level  = 0;  expbuf = NULL;
  DImulti_parse ( reg_exp, &expbuf, &buf_count );
  
  /*|find the targets */
  DIexpanse ( start_dir, dir_name );
  DImasterDump ( &status, dir_name, NULL, &my_lines, &my_grids, &nbr,
     (DIchar) (options & ~OPT_TRAILER) );
  for (i = 0; (i < nbr) && (status == DIR_S_SUCCESS); i++)
    om_send_for ( IGRdir.i_find ( &status, my_lines [i], expbuf, buf_count, level,
                                  max_level, &loc_deep, lines, grids, count, options ),
                  NULL_OBJID, my_grids [i].objid, my_grids [i].osnum );

  if (deep) *deep = loc_deep;
  if (expbuf) di$free ( lines = expbuf, count = buf_count );
  if (nbr)
  {
    di$free ( lines = my_lines, count = nbr );
    DIfree ( my_grids );
  }

  return status;
}


int DIstart_find (DIchar *start, DIchar *reg, DIint *ptr, DIint max,
                DIint *deep, DIchar options)

/*.DIstart_find */
{
  DIint status;

  if (DIR_G_find_count)
  {
    di$free ( lines = DIR_G_find_lines, count = DIR_G_find_count );
    DIfree ( DIR_G_find_grids )
  }

  status = di$find ( start_dir = start, regexp = reg, ptr = ptr, 
                     max_level = max, deep = deep, options = options,
                     lines = &DIR_G_find_lines, grids = &DIR_G_find_grids );
  DIR_G_find_count = *ptr;

  return status;
}



DIfetch_find ( line, grid, index )
               DIchar *line	/* Line to put the result in		OUT */;
               DIgrid *grid	/* Grid of object			OUT */;
               DIint  index	/* Index of line			IN  */;
/*.DIfetch_find */
{
  DIint status = DIR_S_SUCCESS;

  if ((index >= 0) && (index < DIR_G_find_count))
  {
    if (line)
    {
      DIint l = strlen ( DIR_G_find_lines [index] );

      if ((DIR_G_find_lines [index] [l - 1] == DIR_G_car_dir) &&
          (DIR_G_find_lines [index] [l - 2] == DIR_G_car_dir))
      {
        /*|this object has no name */
        status = DIR_W_NO_NAME;
        DIR_G_find_lines [index] [l - 2] = '\0';
      }
      DIstrcpy ( line, DIR_G_find_lines [index] );
    }
    if (grid) *grid = DIR_G_find_grids [index];
  }
  else
    status = DIR_E_OVFLOW;

  return status;
}



DInew_trailer ( line )
                DIchar *line;
/*.DInew_trailer */
{
  DIchar    class_name [OM_K_MAXCLASS_LEN];
  DIint     i, length;
  DIclassid classid;

  if (DIR_G_trailer_index < TRAILER_MAX)
  {  
    /*"new trailer, line : '%s'\n", line */
    strncpy ( class_name, &(line [4]), 
              OM_K_MAXCLASS_LEN ) [OM_K_MAXCLASS_LEN - 1] = '\0';
    for (i = 0, length = strlen ( class_name ); (i < length) && (class_name [i] != ','); i++);
    class_name [i] = '\0';
    DImalloc ( DIR_G_trailers [DIR_G_trailer_index], 
               DIchar *, strlen ( &(class_name [i + 1]) ) + 1 );
    strcpy ( DIR_G_trailers [DIR_G_trailer_index], &(class_name [i + 1]) );

    om$get_classid ( classname = class_name,
                     p_classid = &classid );
    DIR_G_trailer_ids [DIR_G_trailer_index++] = classid;
  }
  else
    fprintf ( stderr, "IGRdir WARNING, maximum number of trailers exceeded\n" );

  return DIR_S_SUCCESS;
}


DIget_trailer ( obj_name, trailer )
                DIchar *obj_name, *trailer;
/*.DIget_trailer */
{
  DIspacenum osnum;
  DIobjid    objid;
  
  di$translate ( objname = obj_name, p_objid = &objid, p_osnum = &osnum );
  DIget_trailer_with_id ( osnum, objid, trailer );
  return OM_S_SUCCESS;
}



DIget_trailer_with_id ( DIspacenum osnum, DIobjid objid, DIchar *trailer )
/*.DIget_trailer_with_id */
{
  OMuword class_id;
  DIint   i;
  
  om$get_classid ( objid = objid, osnum = osnum, p_classid = &class_id );
  
  for (i = 0; i < DIR_G_trailer_index; i++)
  {
    /*"examining : %d - %d\n", class_id, DIR_G_trailer_ids [i]*/
    if ((om$is_ancestry_valid ( subclassid = class_id,
               superclassid = (OMuword)DIR_G_trailer_ids [i] ) == DIR_S_SUCCESS) || 
        (class_id == (OMuword) DIR_G_trailer_ids [i]))
       break;
  }
  if (i < DIR_G_trailer_index)
     strncpy ( trailer, DIR_G_trailers [i], DI_PATH_MAX ) [DI_PATH_MAX - 1];
  else
     trailer [0] = '\0';
  return(1);
}


end implementation DIrectory;

