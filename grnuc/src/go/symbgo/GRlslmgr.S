/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class will store all data needed for the symbol subsystem.

Notes
   All the methods defined for this class have a macro interface.
   See the grsymmacros.h include for a description of the user
   interface to these methods.

History
   HGW    08/30/86 : Design date.
\*/

class specification GRlslmgr (1:0) of global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h" 
#include "grsymdef.h"
#include "grsym.h"

override
   wake_up,          /* global_class   -  Init symbol system            */
   sleep,            /* global_class   -  Wake the symbol system up     */
   super_construct;  /* global_class   -  Close down the symbol system  */

instance GRlslmgr
{
   struct  GRsymbol_info  symbol_info;
                              /* This structure contains                */
                              /*    -  active symbol name               */
                              /*    -  active symbol attachment number  */
                              /*    -  active symbol time stamp         */
                              /*    -  array of symbol attachments.     */
};

/*\
Name
   GRget_active_symbol

Description
   This method is used to retreive the active symbol definition.

   *msg              IGRlong           return code 
   *act_symbol_def   struct GRactive_symbol_def
                                       The active symbol and its 
                                       environment
   index             IGRint            The type of active symbol.
                                       0  -  active cell
                                       1  -  active point
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRget_active_symbol (IGRlong *msg; 
                             struct GRactive_symbol_def *buffer;
                             IGRint index);

/*\
Name
   GRget_asl_env

Description
   This method is used to retrieve the active symbol library
   environment.

   *msg        IGRlong           return code 
   *asl_env    struct GRmd_env   The active symbol library env.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
   GR_I_SL_READ_ONLY    -- Cell library is read only.
\*/
message GRget_asl_env (IGRlong *msg; struct GRmd_env *buffer);


/*\
Name
   GRget_sl_OS_array

Description
   This method is used to retrieve an array of OS numbers of the attached
   symbol libraries.

   *msg           IGRlong           return code 
   *os_array      GRspacenum        The array of OS numbers.
   *num_os_array  IGRint            The number of OS numbers.
 
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRget_sl_OS_array (IGRlong *msg; GRspacenum *os_array;
                           IGRint *num_os_array);

/*\
Name
   GRget_sl_env_from_OS

Description
   This method is used to retrieve the symbol library environment
   of a given object space.

   *msg        IGRlong           return code 
   *sl_osnum   GRspacenum        The symbol library OS number.
   *sl_env     struct GRmd_env   The environment of that symbol library.
 
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRget_sl_env_from_OS (IGRlong *msg; GRspacenum *sl_osnum;
                              struct GRmd_env *sl_env);

/*\
Name
   GRput_active_symbol

Description
   This method is used to put the active symbol.

   *msg           IGRlong           return code 
   *symbol_name   IGRchar           The name of the symbol.
   *symbol_id     struct GRid       The symbol definition id
   *asl_env       struct GRmd_env   The active symbol library environment
   index          IGRint            The type of active symbol.
                                       0  -  active cell
                                       1  -  active point

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRput_active_symbol (IGRlong *msg; 
                             IGRchar *symbol_name; struct GRid *symbol_id;
                             struct GRmd_env *asl_env; IGRint index);

/*\
Name
   GRput_asl

Description
   This macro is used to put the active symbol library.

   *msg           IGRlong           return code 
   *file          struct GRsymbol_lib_file  
                                    The file information structure.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRput_asl (IGRlong *msg; struct GRsymbol_lib_file *file);

/*\
Name
   GRsave_asl

Description
   This macro is used to save the active symbol library.

   *msg           IGRlong           return code 

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRsave_asl (IGRlong *msg);

/*\
Name
   GRget_sl_type

Description
   This macro is used to retrieve the symbol library type.
   There are two types of libraries, MULTIPLE LIBRARY TYPE allows
   multiple copies of symbols with the same name, SINGLE LIBRARY
   TYPE allows only one copy of a symbol with a given name.

   *msg        IGRlong           return code 
   *sl_osnum   GRspacenum        The space number of symbol library
   *type       IGRint            The type of symbol library.
                                    TRUE  - SINGLE LIBRARY TYPE
                                    FALSE - MULTIPLE LIBRARY TYPE
 
Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
message GRget_sl_type (IGRlong *msg; GRspacenum *sl_osnum; IGRint *type);

/*\
Name
   GRget_asl_info

Description
   This method is used to retreive the active cell library information

   *msg              IGRlong                    return code 
   *file             struct GRsymbol_lib_file   file information

Return Values
   MSSUCC      -  successful completion
   GR_I_NOSL   -  No active cell library defined
\*/
message GRget_asl_info (IGRlong *msg; struct GRsymbol_lib_file *file);


end specification GRlslmgr;
