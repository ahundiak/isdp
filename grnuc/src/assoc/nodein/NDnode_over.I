/* 
   Design jla 11 July 1988
*/

class implementation NDnodein;


#include "AS_status.h"
#include "nddef.h"
#define AS_DEBUG

/*
    get the state of the target element
*/
method NDget_state ( IGRchar *n_state )
{
 /*"get state of %d is %x\n",my_id,me->state */
 *n_state = me->state;
 return(OM_S_SUCCESS);
}

/*
    Change the state of the target element
*/
method NDchg_state ( IGRchar mask,n_state )
{
/*"obj %d mask %x n_state %x\n",my_id,mask,n_state */
 me->state = (me->state & ~mask) | (n_state&mask);
 return(OM_S_SUCCESS);
}
end implementation NDnodein;
