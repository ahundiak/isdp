/*
 * Class :
 *
 *      EMasmmgr
 *
 * Abstract :
 *
 *      This class provides for wakeup and sleep management functionality
 *      for the assembly modeling system. It also serves as a clearinghouse
 *      for updates to the on-line bill-of-material.
 *
 * History :
 *
 *      Jay Wallingford     6/1/93  Creation date.
 *
 */
class specification EMasmmgr (1:0) of global_class;

#include <FI.h>
#include <DIdef.h>
#include <igetypedef.h>
#include <igrtypedef.h>
#include <gr.h>
#include "assemdef.h"
#include "assem.h"
#include "assemconstr.h"
#include "assemmacros.h"

instance EMasmmgr
{
    IGRchar item_number[40];   /* Last item number. */
};

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMget_item_number                                               |
 |                                                                           |
 | This message returns the next available item number.                      |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRchar *   item_number Item number IGRchar[40].                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_item_number (IGRlong *msg; IGRchar * item_number);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMset_item_number                                               |
 |                                                                           |
 | This message sets the last used item number, it will be sent during the   |
 | construction of a part. The last used item number is used to determine    |
 | the format of item number (1, 2, 3, etc. or aa, bb, cc, etc.). This       |
 | message will also insure that the item number is unique within the file   |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRchar *   item_number Item number.                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_item_number (IGRlong *msg; IGRchar * item_number);


override wake_up,
         sleep,
         super_construct;

end specification EMasmmgr;

