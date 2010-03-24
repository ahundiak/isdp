/*
  ABSTRACT :
  --------

   This file constains the programmer interface for untranslate.

  HISTORY :
  -------

   06/09/1988 : HGB - Design Date
   05/14/1992 : EMS - Change PATH_MAX to DI_PATH_MAX

*/

class implementation DIrectory;

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"

#include "DIdef.h"
#include "DIprims.h"
#include "DIomac.h"

extern DIboolean _is_absolute_name();
extern OMuword OM_Gw_maxOS;

static DIspacenum DIR_G_untr_osnum;
static DIobjid    DIR_G_untr_objid;

DIuntranslate ( DIchar *objname, DIint *p_index, DIint index,
                DIint *count, DIobjid objid, DIspacenum osnum, DIchar *path )
{
  DIint   status;
  DIchar  **loc_names,
          base [DI_PATH_MAX];
  DIunode node;
                            
  if ( path )
  {
     /* build system base path */
     status = di$give_pathname ( osnum = osnum, pathname = base );
     if (status != DIR_S_SUCCESS ) 
       di$report_error ( comment = "di$give_pathname", sts = status );
  }

  if (DIR_G_untr_count)
  {
    di$free ( count = DIR_G_untr_count, lines = DIR_G_untr_dirnames );
    di$free ( count = DIR_G_untr_count, lines = DIR_G_untr_objnames );
    DIR_G_untr_count = 0;
  }

  if (osnum > OM_Gw_maxOS)
    return DIR_E_INVARG;
  if (count) *count = 0;

  if ((status = DIunall ( osnum, objid, NULL, NULL, 0, &node, NULL ))== DIR_S_SUCCESS)
  {
      DIint  i, counter = 0;
      DIchar **local_dir, **local_obj;

      DIR_G_untr_count = node.count;
      DImalloc ( local_dir, DIchar **, 
                 DIR_G_untr_count * sizeof ( DIchar * ) )
      DImalloc ( local_obj, DIchar **,
                 DIR_G_untr_count * sizeof ( DIchar * ) )
      loc_names = node.names;

      for ( i=0; i<DIR_G_untr_count; i++ )
      {
        local_dir[i] = loc_names[2 * i];
        local_obj[i] = loc_names[2 * i + 1];
      }

      if ( path )
      {
        DIchar my_path [DI_PATH_MAX],
  	       **reg_buffer;
        DIint reg_count, j;
        
        strcpy ( my_path, path );

        if (!_is_absolute_name ( my_path ))
          DIfrtcat ( my_path, base );

        /* Compile the regular expression */
        DImulti_parse ( my_path, &reg_buffer, &reg_count );

        for (i = 0, j = 0; i < DIR_G_untr_count; i++ )
        {
          local_dir [j] = loc_names [(j + counter) * 2];
          local_obj [j] = loc_names [(j + counter) * 2 + 1];
          DImulti_step ( local_dir [j], reg_buffer, reg_count ) ? j++ : counter++;
        }

        /* free buffer space */
        for (i = 0; i < reg_count; i++)
          DIfree ( reg_buffer [i] );
        DIfree ( reg_buffer );
      }

      DIR_G_untr_count = DIR_G_untr_count - counter;

      if ( DIR_G_untr_count )
      {
        /* save results */
        DIR_G_untr_objid = objid;
        DIR_G_untr_osnum = osnum;
        DImalloc ( DIR_G_untr_dirnames, DIchar **, 
                   DIR_G_untr_count * sizeof ( DIchar * ) )
        DImalloc ( DIR_G_untr_objnames, DIchar **,
                   DIR_G_untr_count * sizeof ( DIchar * ) )
      }

      for (i = 0; i < DIR_G_untr_count; i++)
      {
        DIchar dirname [DI_PATH_MAX], *objname = NULL, buf [DI_PATH_MAX];

        strcpy ( dirname, local_dir [i] );
        if (*local_obj [i])
        {
          objname = buf;
          strcpy ( objname, local_obj [i] );
        }

        DImalloc ( DIR_G_untr_dirnames [i], DIchar *,
                   strlen ( dirname ) + 1 )
        strcpy ( DIR_G_untr_dirnames [i], dirname );

        if (objname)
        {
          /* this object has a name */
          DImalloc ( DIR_G_untr_objnames [i], DIchar *,
                     strlen ( objname ) + 1 )
          strcpy ( DIR_G_untr_objnames [i], objname );
        }
        else
        {
          /* this object is unamed */
          DIR_G_untr_objnames [i] = NULL;
        }
      }

      /* set count */  
      if (count) *count = DIR_G_untr_count;

      if ((index >= 0) && (index < DIR_G_untr_count))
      {
        if (p_index)
        {
          status = di$unindex ( dirname = DIR_G_untr_dirnames [index], 
                                p_index = p_index, objid = objid );
        }
        if (objname && (status == DIR_S_SUCCESS))
        {
          DIstrcpy ( objname, DIR_G_untr_dirnames [index] );
          if (DIR_G_untr_objnames [index])
            DIstrcat ( objname, DIR_G_untr_objnames [index] );
          else
            status = DIR_W_NO_NAME;
        }
      }
      else
        status = DIR_E_OVFLOW;

      DIfree ( local_dir );
      DIfree ( local_obj );
    }
    else
      DIR_G_untr_count = 0;

  return status;
}


DIfetch_untrans ( objname, p_index, index )
                  DIchar objname [DI_PATH_MAX] /* Name of the object	OUT */;
                  DIint  *p_index	    /* Index of object in dir	OUT */,
                         index		    /* Index of entry		IN  */;
/*
   This entry point is used to get an entry from the result of a 
   DIstart_untrans (DIuntranslate) execution.
*/
{
  DIint status = DIR_S_SUCCESS;

  if ((index >= 0) && (index < DIR_G_untr_count))
  {
    /* good index */
    if (p_index)
    {
      status = di$unindex ( dirname = DIR_G_untr_dirnames [index], 
                            objid = DIR_G_untr_objid, p_index = p_index );
    }

    if (objname && (status == DIR_S_SUCCESS))
    {
      DIstrcpy ( objname, DIR_G_untr_dirnames [index] );
      if (DIR_G_untr_objnames [index])
        DIstrcat ( objname, DIR_G_untr_objnames [index] );
      else
        status = DIR_W_NO_NAME;
    }
  }
  else
    status = DIR_G_untr_count ? DIR_E_OVFLOW : DIR_W_NAME_NOT_FOUND;

  return status;
}


end implementation DIrectory;
