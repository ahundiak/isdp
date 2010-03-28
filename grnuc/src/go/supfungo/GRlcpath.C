/*\
Description
   This file contains the functions that are used to access the path
   stack.

History
   AC/HGW   11/16/87    Creation Date
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "igrdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "dpstruct.h"
#include "lc.h"
#include "OMprimitives.h"

# define PATH_SIZE 20

static IGRint            size = 0;
static struct GRlc_path  *path = NULL;

struct GRlc_path * GRlc_get_path()
{
   if(size == 0)
   {
      size = PATH_SIZE;
      path = (struct GRlc_path *)om$malloc
                  (size = size * sizeof(struct GRlc_path));
   }
   return(path);
}
   
IGRint GRlc_add_path (path_ptr, path_position, objid, osnum)
struct GRlc_path  *path_ptr;
IGRint            *path_position;
GRobjid           objid;
GRspacenum        osnum;
{
   IGRint status = 1;

   if (*path_position == (size - 1))
   {
      size += PATH_SIZE;
      path = (struct GRlc_path *)om$realloc(ptr = (char *)path,
                  size = size * sizeof(struct GRlc_path));
      if (path)
      {
         path_ptr = path;
      }else
      {
         status = 0;
      }
   }

   if (status)
   {
      (*path_position) ++;
      path_ptr[*path_position].call_action_handler = FALSE;
      path_ptr[*path_position].result = GR_LC_NORESULT;
      path_ptr[*path_position].name_entry = FALSE;
      path_ptr[*path_position].lc_info.located_obj.osnum = osnum;
      path_ptr[*path_position].lc_info.located_obj.objid = objid;
   }
   return(status);
}

#argsused
IGRint GRlc_remove_path (path, path_position)
struct GRlc_path  path[];
IGRint            *path_position;
{
   (*path_position) --;
   return(1);
}
