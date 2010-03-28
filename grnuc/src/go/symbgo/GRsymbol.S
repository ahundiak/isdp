/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This abstract class provides the instance data needed to define
   a symbol.

History
   Gray Winn      10/29/87    Design and Coding Date.
\*/

class specification GRsymbol (1:0) of Root;

#include "igrtypedef.h"
#include "var.h"

instance GRsymbol
{
   IGRlong           time_stamp;    /* Time stamp in GMT.  This is   */
                                    /* the time in seconds since     */
                                    /* 00:00:00 GMT, January 1, 1970 */
   variable IGRchar  symbol_name[]; /* Symbol name in library        */
   variable IGRchar  symbol_desc[]; /* Symbol description in library */
};

/*\
Name
   GRset_inq_symbol

Description
   This method is used to inquire or set information pertaining to the
   symbol.

   *msg           IGRlong              return code 
   set_inq        IGRint               if 0 inqure the instance data
                                       if 1 set the instance data
   *var_list      struct GRvar_list    Varaible list

Notes
   The following items may be inquired.
      GR_TIME_STAMP
      GR_SYMBOL_NAME
      GR_SYMBOL_DESC

Return Values
   MSSUCC   -  if successful.
   MSFAIL   -  if failure.
\*/
message GRset_inq_symbol (IGRlong *msg; IGRint set_inq; 
                          struct GRvar_list *var_list);

end specification GRsymbol;
