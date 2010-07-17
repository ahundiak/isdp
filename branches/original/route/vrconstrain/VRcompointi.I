class implementation VRcompoint;

#include "nddef.h"
#include "AS_status.h"


#define AS_DEBUG 


method VRget_nb_constrain(int *nb_cons)
{
 *nb_cons = 1;
 return OM_S_SUCCESS;
}

/*************************************************************************/
/* Return the ith constrain defined by the control segment */

method VRget_constrain(IGRlong *suc; int i; int *cons_type;
              struct GRid *cons_obj; int *nb_obj; int size_obj;
              double *cons_val; int *nb_val; int size_val)
{
 int status;
 int count;


 switch (i)
  {
   case 0 :

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,
						     cons_obj,size_obj,NULL,
                                                     0,OM_K_MAXINT,&count),
                    targetid = my_id);
    as$status(action = RET_STATUS);
    *cons_type = VR_CNS_PT;
    *nb_obj = count;
    *nb_val = 0;
    break;

   default : 
    status = OM_W_ABORT;
    break;
  }

 return(status);
}

end implementation VRcompoint;
