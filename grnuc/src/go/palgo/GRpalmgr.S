/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Class:

    GRpalmgr
   
Description:

    This class provides a storage for palettes saved in an object space.
    
Abstract class:

    No
    
Messages

    wake_up_palettes
    add_string

History:

    jay wallingford     04/10/89    creation date
    
Bugs:

    There are no known bugs.
    
Notes:

******************************************************************************/

class specification GRpalmgr (1:0) of global_class;

#include <OMerrordef.h>
#include <OMmacros.h>
#include <ODE.h>
#include <igrtypedef.h>
#include <igr.h>
#include <igrdef.h>
#include <igrdp.h>
#include <FIdyn.h>
#include <FI.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <msdef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include "palgo.h"

instance GRpalmgr
{
    IGRint                          version;
    variable IGRchar                strings[0];
    variable struct os_palette_cmd  commands[0];
    variable struct os_palette      palettes[0];
};

message wake_up_palettes ();

message add_string ( IGRchar * string; IGRint * index );

override wake_up;

override global_class.sleep;

end specification GRpalmgr;

