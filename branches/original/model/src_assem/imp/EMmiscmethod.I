class implementation EMconstr;

#include <stdio.h>


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMmark_visited                                                  |
 |                                                                           |
 | This message marks a constraint as visited during mating graph traversal. | 
 |                                                                           |
 | Input:   IGRboolean do_mark    TRUE to mark constr                        |
 |                                FALSE to unmark constr                     |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
                      

method EMmark_visited (IGRlong *msg; IGRboolean do_mark)
{
  *msg = EMS_S_Success;

  me->is_visited = do_mark;

  return (OM_S_SUCCESS);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMis_constr_visited                                            |
 |                                                                           |
 | This message determines if a constraint has been visited during mating    |
 | graph traversal.                                                          | 
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRboolean *ptr_is_visited  TRUE if constr has been visited      |
 |                                                                           |
 +---------------------------------------------------------------------------*/

method EMis_constr_visited (IGRlong *msg; IGRboolean *ptr_is_visited)
{
 *msg = EMS_S_Success;
 
 *ptr_is_visited =  me->is_visited;
 
 return (OM_S_SUCCESS);
}

end implementation EMconstr;
