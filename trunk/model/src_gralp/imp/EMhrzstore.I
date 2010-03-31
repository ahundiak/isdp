/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include "OMmacros.h"

method EMstore_horizon_info(int                     count;
                            struct EMShorizon_info  *horizon_info;
                            int                     append)
{
  IGRlong                   sts = OM_S_SUCCESS;
  int                       size, new_size;
  struct EMShorizon_info    *local_info;

  if(count < 1) goto wrapup;

  /*
   * Get the current size.
   */
  size = om$dimension_of(varray = me->horizon_info);

  /*
   * Get the new size.
   */
  if(append) new_size = size + count;
  else new_size = count;

  /*
   * Resize the VLA.
   */
  if(new_size != count) om$vla_set_dimension(varray = me->horizon_info,
                                             size = new_size);

  /*
   * Get the address at which the information is to be stored.
   */
  if(append) local_info = &me->horizon_info[count];
  else local_info = me->horizon_info;

  /*
   * Store the information.
   */
  OM_BLOCK_MOVE(horizon_info, local_info, count * sizeof(*local_info));

wrapup:
  return sts;
};

end implementation EMShorizon;
