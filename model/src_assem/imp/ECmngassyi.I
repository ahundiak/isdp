
/*

   Name
        ECmngassy  - Manage Assembly

   Decsription

        This command object drives the Manage Assembly.

   History

      Gang   09/24/93    Creation.

*/ 

class implementation ECmngassy;

#include "stdio.h"
#include "string.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"
#include "coparamac.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "FI.h"
#include "dpmacros.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "asdef.h"
#include "AS_status.h"
#include "grmsg.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"


/* define constants */

#define Null ((char *)NULL)

#ifdef TRACE
#define trace(x) x
#else
#define trace(x)
#endif

#define ASM_MGR    1
#define ASM_LOCATE 2

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                                init
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init(int type; char *string_ptr)
{
  int status;

  status = om$send(msg = message COpara.init(type,string_ptr),
                   targetid = my_id,
                   mode = OM_e_wrt_message);


  if(EMisbom_locate())
   {
     me->state = ASM_LOCATE;
   }
  else
   {
     me->state = ASM_MGR;
   }

  return(status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                                delete
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method delete(int n)
{
  int status;

   if(me->state == ASM_LOCATE)
     EMresetbom_locate();

 status = om$send(msg = message COpara.delete(n),
                  targetid = my_id,
                  mode = OM_e_wrt_message);
 return(status);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
                              execute
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
  IGRlong msg;
  IGRlong om_msg;
  IGRint done;
  IGRint n_obj;
  IGRlong mask1,mask2;
  IGRlong rc;
  struct GRid *objects;
  struct GRevent event1, event2,event3;
  char buf[DI_PATH_MAX];
  OMuword classid;
  OM_S_CLASSLIST classes;
  IGRlong display_flag;

  msg = MSSUCC;
  om_msg = OM_S_SUCCESS;

  n_obj = 0;
  buf[0] = NULL;
  done = FALSE;
  objects = NULL;

  ex$message(field = 1,msgnumb = EM_M_MngAssem);

  if(me->state == ASM_MGR)
   {
     om_msg = EMmanage_assembly(&msg);

     if(!(msg & om_msg & 1))
      {
#ifdef DEBUG
         printf("Could not create the form EMMngAssy\n");
#endif
      }
   }

  if(me->state == ASM_LOCATE)
   {
     me->attr.properties =   LC_RW | LC_LC_ONLY | LC_DP_ONLY;
     me->attr.owner_action = LC_READ |LC_REF_OBJECTS | LC_REF_HEADER;
     mask1 = mask2  = GRm_DATA | GRm_STRING |GRm_RESET | GRm_BACK_UP|
                      GRm_SPECIFIED_OBJ;

     om$get_classid(classname = "EMinstance",
                    p_classid = &classid);
     classes.p_classes = &classid;
     classes.w_count = 1;
     classes.w_flags = OM_CLST_subclass;

     display_flag = ALL_WINDOWS|ELEM_HILIGHT| LC_ERASE_LOC_ELEMENT |
                    NO_PROJ_ACCEPT_POINT;

     om_msg = lc$locate( rc = &rc,
                         event1 = &event1,
                         event2 = &event2,
                         event3 = &event3,
                         mask1 = mask1,
                         mask2 = mask2,
                         display_flag = display_flag,
                         response = response,
                         hilight_mode = GRhd,
                         unhilight_mode = GRhe,
                         locate_key = EMS_P_IdPart,
                         acc_key = GR_P_Acc,
                         relocate_key = EMS_I_PartNotFound,
                         attributes = &me->attr,
                         stack = &me->locate_stack,
                         eligible_classes = &classes);

    as$start_fence(set = &(event3.located_object[0].located_obj),
                   nb_obj = &n_obj,
                   p_obj = &objects);

    if(rc == LC_OBJ_LOCATED)
      {
         if(objects)
          {
            EMbom_locate_update(&msg, objects, n_obj);
            ASend_fence();
            *response = TERMINATE;
          }
      }
   }
  else
   {
     *response = TERMINATE;
   }

  return(OM_S_SUCCESS);
}

end implementation ECmngassy;
