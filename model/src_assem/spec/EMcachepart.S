/*
 * Class :
 *
 *      EMcachepart
 *
 * Abstract :
 *
 *      This class defines a type of parts which cache part 
 *      definitions that are defined elsewhere. These will include
 *      reference parts which are cached file parts and other application
 *      part types.
 *
 * History :
 *
 *      Jay Wallingford     3/25/93  Creation date.
 *
 */
class specification EMcachepart (1:1) of EMpart;

#include "assemdef.h"
#include "assem.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMget_definition                                                |
 |                                                                           |
 | This message will return the part definition. For reference parts this    |
 | be the file part in the attached file otherwise the part itself will be   |
 | returned.                                                                 |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code.                         |
 |          struct GRid * definition_id Definition.                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_definition (IGRlong *msg; struct GRid * definition_id);

/*
 * Directory Overrides
 */
override remove;

/*
 * Describe Overrides
 */
override EMconstruct,
         EMnum_attrs,
         EMget_attr,
         EMadd_attr,
         EMmod_attr,
         EMrem_attr,
         EMlegal_memb_op,
         EMlegal_attr_op,
         EMupdate;

reject   EMget_active,
         EMset_active,
         EMadd_notify,
         EMget_notify,
         EMrem_notify;

end specification EMcachepart;



