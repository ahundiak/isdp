/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"

# ifndef EMSerrordef_include
# include "EMSerrordef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

/*
   Transform the graphic data's RLT by incoming matrix.

   10/20/88     RC     Creation Date

*/

method EMuv_transform (IGRlong               *EMmsg;
                       IGRdouble             matrix[16];
                       struct EMSpartolbasis *partolbasis;
                       IGRshort              options)
{
  IGRdouble        *dbl_ptr, *rule_ptr;
  unsigned  short  *sh_ptr; 
  IGRint           i, j;

 *EMmsg = EMS_S_Success;

 dbl_ptr = ME.EMSgradata->double_data;
 for (i = 0; i < ME.EMSgradata->num_u_rules; i++, dbl_ptr++)
  (*dbl_ptr) = (*dbl_ptr) * matrix[0] + matrix[3];

 for (i = 0; i < ME.EMSgradata->num_v_rules; i++, dbl_ptr++)
  (*dbl_ptr) = (*dbl_ptr) * matrix[5] + matrix[7];

 sh_ptr = me->short_data;
 rule_ptr = me->double_data;
 for (i = 0; i < ME.EMSgradata->num_u_rules; i++, sh_ptr++, rule_ptr++)
  for (j = 0; j < 2 * (*sh_ptr); j++, dbl_ptr++)
   if ((*dbl_ptr) != 0. && (*dbl_ptr) != 1.0)
    (*dbl_ptr) = (*rule_ptr) * matrix[4] + (*dbl_ptr) * matrix[5] + 
                 matrix[7];
  

 for (i = 0; i < ME.EMSgradata->num_v_rules; i++, sh_ptr++, rule_ptr++)
  for (j = 0; j < 2 * (*sh_ptr); j++, dbl_ptr++)
   if ((*dbl_ptr) != 0. && (*dbl_ptr) != 1.0)
    (*dbl_ptr) = (*dbl_ptr) * matrix[0] + (*rule_ptr) * matrix[1] + 
                 matrix[3];

  return (OM_S_SUCCESS);

}
end implementation EMSgradata;
