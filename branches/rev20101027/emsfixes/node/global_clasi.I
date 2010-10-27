
class implementation global_class;

#define debug 0
#include <OMerrordef.h>
#include <OMlimits.h>
#include <exproto.h>

#ifdef SUNOS5
%undef sleep
#endif

method super_construct ()      

 {
  return (OM_S_SUCCESS);
 }

method wake_up ()                
 {
  return (OM_S_SUCCESS);
 }


method global_class.sleep (int type_sleep) 
 {
  return (OM_S_SUCCESS);
 }


method place ( OM_p_CHANSELECT chan ) /* pointer to the super channel */

 {
   int stat;
   OM_S_CHANSELECT   chandef;

/* mod is rhs of instance data of super_class*/
                  

    if(chan!=0)
    {

        chandef.type = OM_e_addr;
        chandef.u_sel.addr = &ME.global_class->mod;
                
        stat = om$send  (msg = message Root.connect(*chan, 0, 
                         my_id,OM_Gw_current_OS,  chandef, 0 ), 
                                   senderid = my_id, 
                                   targetid = sender_id);

        if (!(stat&1))
        {
/*            printf("OM_connect_me error\n");*/
            om$report_error(sts = stat);
            return(OM_W_ABORT);
        }
    }
    else 
     return(OM_W_ABORT);

  return (OM_S_SUCCESS);
 }

end implementation global_class;
