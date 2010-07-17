class implementation VRconsdist;

#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "AS_status.h"
#include "asbox.h"

#define AS_DEBUG 


method VRget_nb_constrain(int *nb_cons)
{
 *nb_cons = 1;
 return OM_S_SUCCESS;
}

method VRget_constrain( IGRlong *suc; IGRint i; IGRint *cons_type;
                        struct GRid *cons_obj; IGRint *nb_obj; IGRint size_obj;
                        IGRdouble *cons_val; IGRint *nb_val; IGRint size_val )

{
  IGRint 		count;
  IGRlong 		status;
  struct 	GRid 	my_root[2]; 

  if( size_val <= 0 ) return OM_E_INVARG;

  *suc   = MSSUCC;
  status = OM_S_SUCCESS;

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, my_root, 2, NULL, 0, OM_K_MAXINT, 
 			         &count 
                               ),
 		    targetid = my_id);
  as$status(action = RET_STATUS);

  if( count != 2 ) return OM_E_INVARG;
 
  switch( i ) 
  {
     case 0 :
       *nb_obj = 2;
       if(size_obj>0) cons_obj[0] = my_root[0];
       if(size_obj>1) cons_obj[1] = my_root[1];

       *nb_val = 1;
       *cons_type = VR_CNS_PARA | VR_CNS_VAL;
       cons_val[0] = 0.;
       break;
   
    default : status = OM_W_ABORT;
  }

  /*"cons_val = %f\n", cons_val[0] */

 return status;

}

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
                        struct GRmd_env *md_env)
{
  struct GRid     MyId;

  *msg = MSSUCC;

  /* -- Delete via batch -- */
  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  nd$wait_batch( type       = GR_DELETED,
                 l_object   = &MyId,
                 nb_obj     = 1 );

  return OM_S_SUCCESS;
}
end implementation VRconsdist;
