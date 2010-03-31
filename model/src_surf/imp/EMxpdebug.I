/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
# include <stdio.h>
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSobjmgrdef.h"
# include "EMSobjmgr.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSxsection.h"

/*
 
 HISTORY     

        RC     12/09/88      Creation Date

*/

method debug()
{
  IGRlong  OM_stat;
  IGRint   i;

  switch (me->alignment_info_fmt)
  {
    case EMS_FMT_TRANS_VEC_ROT_ANGLE:

      fprintf (stderr, 
                "Aligment_info_fmt = EMS_FMT_TRANS_VEC_ROT_ANGLE\n");
      fprintf (stderr, "Trans Vector \n");
      for (i = 0; i < 3; i++)
        fprintf (stderr, "\t Trans_vec[%d] = %f \n", i, 
                 me->alignment_info[i]);

      fprintf (stderr, "Rotation Angle = %f \n", me->alignment_info[3]);
      break;

   case EMS_FMT_MATRIX:

     fprintf (stderr, "Alignment_info_fmt = EMS_FMT_MATRIX\n");
     fprintf (stderr, "Alignment Matrix :\n");

     for (i = 0; i < 16; i++)
      fprintf (stderr, "\t Algn_mat[%d] = %f \n", i, 
      me->alignment_info[i]);
     break;

   default:
    break;    
 }
  OM_stat = om$send (mode = OM_e_wrt_parent,
                     msg = message EMSxsplane.debug(),
                     targetid = my_id);
  
   return (OM_S_SUCCESS);
}



end implementation EMSxsplane;
