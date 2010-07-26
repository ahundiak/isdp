/*----
%GP% CODE CLASSIFICATION
----
%HD%
     MODULE NAME:  CObrln

----
%CH%
     CHANGE HISTORY:    

              10/24/91 JSD : fixed bug introduced by reference planes
			     by not calling DPinrot.  (VW_ROT_NO_CON)

----
%PD%
----*/
/*EH*/


class implementation COroot;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "msdef.h"
#include "dp.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "codef.h"
#include <stdio.h>


from IGEgragad import DPinrot;

#argsused
IGRboolean CObrln (msg, obj_id, event, line) 
IGRlong                 *msg;
GRobjid                 *obj_id;            /* not used     KLUDGE  */
struct  GRevent         *event;             /* event containing pt  */
struct  IGRline         *line;              /* boreline             */

{

    IGRpoint                    pt1;
    IGRlong                     status;     /* return status        */
    IGRboolean                  b_status;   /* return status        */
    IGRmatrix                   vwmat;      /* rotation matrix      */

    IGRlong                      ret_size;
    IGRlong                     which_err;
    struct var_list             var_list[2];


    var_list[0].var            =  VW_ROT_NO_CON;
    var_list[0].var_ptr        =  (IGRchar *)vwmat;
    var_list[0].num_bytes      =  sizeof ( IGRmatrix );
    var_list[0].bytes_returned = &ret_size;
  
    var_list[1].var = END_PARAM;
  
    status = dp$inq_set_gragad(
                msg          =  msg,
                osnum        =  event->event.button.osnum,
                gragad_objid =  event->event.button.objid,
                which_error  = &which_err,
                var_list     =  var_list );

    if( COERROR(status) || COERROR(*msg))
      {
         b_status = FALSE;
         *msg = MSFAIL;
      }
    else    /* construct bore line */
      {
        pt1[0] = event->event.button.x;
        pt1[1] = event->event.button.y;
        pt1[2] = event->event.button.z;
        b_status = GRbrlnconstr(msg,pt1,vwmat,line);
      }

     return(b_status);
}
end implementation COroot;
