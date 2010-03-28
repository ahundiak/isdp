/* #######################    APOGEE COMPILED   ######################## */
class specification super_dir (0:0) of global_class;

/*

   H. BEQUET                                        super_dir.S

   This object is the super_object for the directory sub-system.

   HISTORY
   =======

   09/22/1986 : Creation Date
   06/18/1987 : Hash table saving
   01/20/1988 : Add new instance data for trailer support
   08/23/1988 : New IGRdir support
   09/09/1988 : Save home directory
*/

#include "DItypedef.h"
#include "DIdef.h"

  instance super_dir
  {
    variable DIchar current [DI_PATH_MAX]	/* current directory      */;
    variable DIchar home    [DI_PATH_MAX]	/* home directory         */;
  };

  override wake_up, super_construct, sleep;

end specification super_dir;
 

