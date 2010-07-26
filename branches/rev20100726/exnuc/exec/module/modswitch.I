/*-----
%change history : 
     2/16/87   HT   change to use new help.
-----*/
/* GRmd_deactive GRmd_active are called after switch to clear menu, sleep
   cmdserver,  wakeup new cmdserver, create new menu             */
class implementation module;


from cmdserver import exec_cs, wakeup_cs, sleep_cs;
from IGEwsys import clear, activate;
from IGEwindow import deactivate,reactivate;

#include <execmsg.h>
#include <string.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>

extern struct module_params **module_data;
extern struct EX_visible_module *module_table;
extern char CS_path_name[];    
extern char EX_runname[];
extern int  MS_delete_visible_menus();
method GRmd_deactive( IGRint flag)
 /* flag = 1 do not deactivate menu */
{

    OM_S_CHANSELECT chandef1;
    int status;
    
   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "module.windows";

 if(module_data[OM_Gw_current_OS]->visible_flag > 0)
 {
        status = om$send(mode = OM_e_wrt_object,
                    msg = message IGEwindow.deactivate(),
                    senderid = my_id,
                    p_chanselect = &chandef1,
                    from = 0,
                    to = OM_K_MAXINT     );

        if( !flag  )
	{
             MS_delete_visible_menus();
        }
/*    
        chandef1.type = OM_e_name;
        chandef1.u_sel.name = "cmdsvr";
    
        status = om$send(mode = OM_e_wrt_object,
                         msg = message cmdserver.sleep_cs(msg),
                         senderid = my_id,
                         p_chanselect = &chandef1,
                         from = NULL,
                         to = NULL);
        if(!(1&status)) return(OM_W_ABORT);


        status = EX_clear_pocket_menu((char *)NULL);
        if(status == 0)
        {
           printf("In GRmd_deactive clear pocket menu error\n");
        }
*/
      return(status);
   }
   return(1);
 } /* method deactive */


method GRmd_active()
{
  int status;
  OM_S_CHANSELECT  chandef1;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "windows";

    status = om$send(mode = OM_e_wrt_object,
/*                     msg = message IGEwsys.activate(&msg,-1), */
                      msg = message IGEwindow.reactivate(),
                     senderid = my_id,
                     p_chanselect = &chandef1,
                     from = 0,
                     to = 0); 

    if(!(1&status)) return(OM_W_ABORT);
/*
   chandef1.type = OM_e_name;
   chandef1.u_sel.name = "cmdsvr";

    status = om$send(mode = OM_e_wrt_object,
                     msg = message cmdserver.wakeup_cs(),
                     senderid = my_id,
                     p_chanselect = &chandef1,
                     from = NULL,
                     to = NULL);
*/
    /*check_error_status(status,"cmdserver.wakeup_cs error");*/
/*
    if(!(1&status)) return(OM_W_ABORT);
*/


  return(OM_S_SUCCESS);

} /* method activate */
end implementation module;
