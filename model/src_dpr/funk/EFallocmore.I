/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emserr.h"

void EFrealloc_if_needed(EMmsg, 
                         array,
                         count,
                         element_increment,
                         element_byte_size) 

IGRlong         *EMmsg;
IGRchar         **array;
IGRint          count;
IGRint          element_increment;
IGRint          element_byte_size;

/*
Description
    This function will allocate an array of size element_increment if the
    array is unallocated or will realloc the array with size plus increment
    size if the array is full.


Return Values
    EMmsg - EMS_S_Success if all is well.
    array - allocated, reallocated or untouched array.

Notes 
    'count' must be set to zero if array is not yet allocated.

History
     DLB  03/09/88 creation.
*/
{
 *EMmsg = EMS_S_Success;

 if (! (count % element_increment) )
 {
   if (! count)
     *array = (IGRchar *) om$malloc(size = element_increment * 
                                           element_byte_size);
   else
     *array = (IGRchar *) om$realloc(ptr = *array, 
                                     size = (count + element_increment) *
                                             element_byte_size); 

   if (! *array) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
 }
    
 wrapup:
  return;
}
end implementation EMSdpr;
