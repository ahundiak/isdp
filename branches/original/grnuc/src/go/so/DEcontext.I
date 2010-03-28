class implementation DEso;

#include <stdio.h>
#include <memory.h>
#include <sys/types.h>
#include <tools.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "gr.h"
#include "godef.h"
#include "DEso.h"
#include "DEglob.h"


method GRdelete ( long *msg; struct GRmd_env *md_env )
/*
   Whenever a context is deleted, we need to clean up the soo.
*/
{
  int   status;
  short index;
  DEsoe *ptr, *last;
  
  *msg = MSSUCC;
  
  /* find the index of the guy on our channel */
  status = om$send ( msg = message DEso.DEget_view_index ( msg, 0, &index,
                                                           0, NULL_OBJID, 
                                                           sender_id ),
                     targetid = my_id );
  if (!(status & 1)) return status;
  if (*msg != MSSUCC) return OM_E_ABORT;
  
  /* traverse the table and delete each entry that point to the deleted context. */
  last = &me->soo [om$dimension_of ( varray = me->soo )];
  for (ptr = &me->soo [0]; ptr < last; ptr++)
    if (ptr->type != DE_DELETED && ptr->type != DE_EMPTY && 
        ptr->context == index)
    {
      ptr->type = DE_DELETED;
      me->used--;
    }
/*
   else if(ptr->context > index)
           ptr->context--;
*/
     
  return status;
}

end implementation DEso;
