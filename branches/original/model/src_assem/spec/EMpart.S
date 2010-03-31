/*
 * Class :
 *
 *      EMpart
 *
 * Abstract :
 *
 *      This abstract class defines a directory which describes a part.
 *      This class serves as a superclass to EMlocalpart and EMcachepart.
 *      It also sets up protection for certain attributes which are reserved
 *      by the assembly modeling system.
 *
 * History :
 *
 *      Jay Wallingford     6/19/93  Creation date.
 *
 */
class specification EMpart (1:1) of EMdescribe;

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMget_instancename                                              |
 |                                                                           |
 | This message returns a unique name for an instance object.                |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRchar *   dirname     Part's directory name. Optional.         |
 |          IGRchar *   name        Name for the instance.                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_instancename (IGRlong *msg; 
                             IGRchar *dirname;
                             IGRchar *name);

/*
 * Describe Overrides
 */
override EMdefault_memb_type,
         EMget_memb_type,
         EMlegal_memb_op,
         EMlegal_attr_op;

end specification EMpart;



