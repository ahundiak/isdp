class           COpal
product_name    "$SOURCE"
super_class     COtools
super_class     CEO_LOCATE
start_state     terminate
spec_path       "$GRNUC/co/spec"
path            "."
options         "SItc"

specification

#ifdef SUNOS 
#include "sunlimits.h"
#endif

#include <coimport.h>
#include <FI.h>
#include <limits.h>
#include "palgo.h"
#include "palco.h"

instance
{
    int     label;
    int     rows;
    int     cols;
    int     num_cmds;
    char    name[DI_PATH_MAX];
    char    cmd[PAL_MAX_CMD_LENGTH];
    int     cmd_type;
    char    symbol_file[DI_PATH_MAX];
    int     symbol;
    struct palette *p;
}

implementation

#include <coimport.h>

from GRpalmgr import wake_up_palettes;

extern int EX_batch_mode;

action arg_name_to_value
{
    *ret_type = _COB_UNKNOWN_ARG;
    *is_const = 0;

    if ( class_name[0] ) 
    {
        if ( !strcmp ( arg, "rows" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->rows);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->rows;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "cols" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->cols);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->cols;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_cmds" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_cmds);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_cmds;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "name" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->name;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "cmd" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->cmd;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "symbol_file" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->symbol_file;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "symbol" ) ) 
        {
            if ( addr_mode == _COB_address )
            {
                data->p = (char *)(&me->symbol);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->c = (char)me->symbol;
                *ret_type = _COB_arg_c;
            }
        }
        else if ( !strcmp ( arg, "p" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->p;
                *ret_type = _COB_arg_p;
            }
        }
    }

    if ( *ret_type == _COB_UNKNOWN_ARG ) 
    {
        om$send ( targetid = my_id,
                  mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.arg_name_to_value ( addr_mode,
                                                               class_name,
                                                               arg,
                                                               data,
                                                               ret_type,
                                                               is_const ) );
    }

    return OM_S_SUCCESS;
}

action COpal_startup 
{

#if 0

    /*
        This code has been disabled.  The palette initialization now takes
        place in the GRpalmgr.wake_up method.  See notes there for more
        details.
    */

    OM_S_OBJID super_objid;
    OMuword    super_osnum;
    char *     form;
    int        GRmenu_button_intercept_routine();

    super_objid = NULL_OBJID;
    ex$get_super ( mod_id = me->ModuleInfo.md_id.objid,
                   mod_osnum = me->ModuleInfo.md_id.osnum,
                   super_name = "palmgr",
                   create = FALSE,
                   super_class = "GRpalmgr",
                   super_id = &super_objid,
                   super_osnum = &super_osnum );

    if ( super_objid != NULL_OBJID )
    {
        *sts = om$send ( msg = message GRpalmgr.wake_up_palettes (),
                         targetid = super_objid,
                         targetos = super_osnum );
    }

#endif

    if (!EX_batch_mode)
    {
        /*
            Make adjustments to the menus (popup intercepts, menu icons, adp
            gadgets, etc).  This call was moved here from GRdpb.wakeup to make
            sure that the menus have been displayed before attempting to
            customize them.  Some journaling settings (OMJNLON=0) can change
            the order in which menus are displayed and supers awakened
            (believe it or not!).  TR119323033.
        */

        GRcustomize_menus();
    }

    return(OM_S_SUCCESS);
}

action status_disp
{
    om$send(msg = message COpal.set_gadgets(),
            targetid = my_id);

    om$send(msg = message CEO.status_disp(),
            mode = OM_e_wrt_message,
            targetid = my_id);
}

action COpal_func (int func) extern

action form_notification extern

action set_gadgets() extern
