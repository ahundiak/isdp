class implementation Q;

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"

method dim_vla (int size)
{
   int sts;

   sts = om$vla_set_dimension ( varray = ME.Q->qq,
                                size   = size );
   if (!(1&sts)) {
      printf ("In Q.qq set_dimension for %d bytes failed\n",size);
      om$report_error(sts=sts);
      return (sts);
   }
   return (OM_S_SUCCESS);
}

method delme()
{
   int sts;

   sts = om$send (msg = message Root.delete(0),
                  targetid = my_id);
   if (!(1&sts)) {
      printf ("In Q.delme Root.delete failed\n");
      om$report_error(sts=sts);
      return (sts);
   }
   return (OM_S_SUCCESS);
}

end implementation Q;
