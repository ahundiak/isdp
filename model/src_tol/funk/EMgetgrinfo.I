class implementation Root;


#include <string.h>
#include <stdio.h>
#include "OMerrordef.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "ndmacros.h"
#include "nddef.h"

/* #include "ems_m_inc.h"
*/
#include "EMSmsgdef.h"
#include "emserr.h"

extern OMuword OPP_GRbcsubbc_class_id, OPP_EMSgenbs_class_id,
               OPP_GRcurve_class_id, OPP_EMSsubbs_class_id;

void EMgetgrinfo( EMmsg,
                  object,
                  num_of_classids,
                  class_id,
                  num_of_roots,
                  roots)

  IGRlong  *EMmsg;
  struct   GRid *object;    /*the object*/ 
  struct   GRid *(*roots);
  OMuword  *class_id;
  IGRint   *num_of_roots;
  IGRint   *num_of_classids;

{
 IGRint        *msg;
 IGRint       sts = OM_S_SUCCESS;
 int          k,flag;
 OMuword      classid;
 struct       GRid root_grid;
 int          classid_count,i;
 
  *msg = 1;

    sts = nd$get_graph(nb_tip=1,
                         p_tip= object);

    sts = nd$get_list_in_graph(  acc_type=ND_EXTERN ,
                                 rej_type = ND_TIP | ND_BODY ,
                                 p_count = num_of_roots,
                                 buf_addr = roots);


    if(sts==1) *EMmsg= EMS_S_Success;

    classid_count =0;
    for(i=0;i< *num_of_roots; i++)
      {
       
       root_grid = *(*roots+i);
      
       om$get_classid(osnum=root_grid.osnum,objid=root_grid.objid,
                          p_classid= &classid);
       flag = 0;
       for(k=0; k< classid_count ; k++)
          {
          if(class_id[k] ==  classid)  
            {
            flag=1;
            break;
            }
          }
       if(flag != 1 )
        {
        class_id[classid_count] = classid;
        classid_count++;
        }
      }
       *num_of_classids = classid_count;
 }

end implementation Root;
