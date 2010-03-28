/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRadd_components

Description
   This method is used to add a list of elements to an owner.

   *msg           long              completion code 
   *mod_env       struct GRmd_env      The current module environment
   *num_objects   int               The number of objects
   objects[]      struct GRobj_env     The list of elements to be added.
   own_index[]    int               An array of indexes for the owner's
                                       channel when connecting.
   go_index[]     int               An array of indexes for the graphics
                                       object's channel when connecting. 

Notes
   The own_index and go_index arrays may be NULL.  If either is NULL
   then OM_K_MAXINT will be used.

   The components must be in the same environment as the header and 
   they must be transformed to the correct coordinate system.

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.

History
   Gray Winn    09/15/87    Creation date.
   scw          07/22/92    ansi conversion
\*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"

extern int      GRaccumulate_range();

method GRadd_components (long *msg; struct GRmd_env *mod_env;
                         int *num_objects; struct GRobj_env objects[];
                         int own_index[]; int go_index[])
{
  long        om_msg;
  int         i;
  IGRlong     local_own_index;
  IGRboolean  world;
  GRrange     go_range;
  GRrange     range;
  struct GRid my_GRid;
  short       mx_type;
  double      matrix [16];

  om_msg = OM_S_SUCCESS;
  *msg = MSSUCC;
  world = FALSE;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  for (i=0; i < 3; ++i)
  {
    range[i] = me->diag_pt1[i];
    range[i+3] = me->diag_pt2[i];
  }


  mx_type = MAIDMX;
  MAidmx ( msg, matrix );
  for (i=0; i < *num_objects; ++i)
  {
    /*
     *  Get the range of the object in the symbol definition coordinate
     *  system.  Note that the object is currently in the symbol 
     *  definition coordinate system.
     */

    om_msg = om$send(
        msg = message GRvg.GRgetrang ( msg, &mx_type, matrix, &world, 
        go_range),
        targetid = objects[i].obj_id.objid,
        targetos = objects[i].obj_id.osnum);

    if (om_msg & *msg & 1)
    {
      /*
       *  Connect to the components to my self.
       */

      if ( (objects[i].mod_env.md_id.osnum == mod_env->md_id.osnum)  &&
          (objects[i].mod_env.md_id.objid == mod_env->md_id.objid))
      {
        /*
         *  Accumulate the range of all the components.
         */

        if (GRaccumulate_range (msg, go_range, range))
        {
          if (own_index)
            local_own_index = own_index[i];
          else
            local_own_index = OM_K_MAXINT;

          om_msg = om$send(
              msg = message GRconnector.GRrigidconn (msg, 
              &my_GRid, &local_own_index),
              targetid = objects[i].obj_id.objid,
              targetos = objects[i].obj_id.osnum);

        }
      }
    }
  }

  if (om_msg & *msg & 1)
  {
    for (i=0; i < 3; ++i)
    {
      me->diag_pt1[i] = range[i];
      me->diag_pt2[i] = range[i+3];
    }
  } 
  else
    *msg = MSFAIL;

  return om_msg;
}


end implementation GRsmdfhdr;
