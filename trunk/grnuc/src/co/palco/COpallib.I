/*
Name
        COpallib.I

Methods
        COpal_func
    
Functions
        COpal_palette_locate_func

History
        jay wallingford     4/10/89     Creation date.
        mrm                 12/17/91    Change default button on color to white
        jjm                 03/06/92    Changed to handle swapping menu bars
        mrm                 04/10/93    Changed check for menu swap to reflect
                                        2.2 task button key naming convention
*/

class implementation COpal;

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <exdef.h>

extern int EX_get_cmd_info();
extern struct palette * GRpal_create();
extern struct palette * GRpal_recreate();
extern int GRpal_get_cmd_icon();
extern int GRpal_add_cmd();
extern int GRpal_del_cmd();
extern struct palette_cmd GRpal_cur_cmd;
extern int COtool_strip_quotes();
extern int (* GRpal_btn_locate_func)();

int COpal_palette_locate_func()
{
    long msg;
    int  response = PALETTE_LOCATED;

    ex$putque(msg = &msg, response = &response);
    return (OM_S_SUCCESS);
}

method COpal_func (IGRint func)
{
    char *task_prefix;
    IGRint *sts, symb;
    struct EX_cmd cmd;
    int row, col;
    struct palette *p;

    sts = (IGRint *)&me->ret;
    switch (func)
    {
      case CO_store_cmd:
        *sts = MSSUCC;
        symb = 0;
	
        /*
         * If either a button was pushed or a command typed in.
         */
        if ((me->event1.response == EX_CMD_KEY) ||
            (me->event1.response == CMD_STRING) ||
            (me->event1.response == EX_STRING))
        {
            /*
             * If it was a string without an equal sign.
             */
            if ((me->event1.response == EX_STRING) &&
                (strchr(me->event1.event.keyin, '=') == NULL))
            {
                /*
                 * Check for an existing command key.
                 */
                if (EX_get_cmd_info(me->event1.event.keyin,
                                    EX_STRING,
                                    &cmd))
                {
                    strcpy(me->event1.event.keyin, cmd.command_key);
                    me->event1.response = EX_CMD_KEY;
                }
            }

            if (me->event1.response == EX_CMD_KEY)
            {
                /* Check if the button pressed will try to swap menu bars */

                /*
                    Assumption: the command key looks like ..bar, where .. is
                    an application prefix to the command key for their swap
                    bar menu command (eg EMbar or MDbar).  The keys are not
                    hard coded because GRNUC can't track all the application
                    commands.  This (mostly) closes a hole in which
                    applications couldn't descend into their menu to select
                    commands.  It still leaves a hole for commands which
                    coincidentally have "bar" in the command key, but that is
                    a much smaller problem than hiding an entire menu of
                    commands.

                    For 2.2, the naming convention for the commands that swap
                    menus/tasks has changed.  All the keys must begin with
                    "IMTk".  The old check is left in place for applications
                    which may not yet conform to the new standard.
                */

                task_prefix = "IMTk";
                if ((strcmp(&me->event1.event.keyin[2], "bar") == NULL) || 
                    (strncmp(me->event1.event.keyin, task_prefix,
                            strlen(task_prefix)) == NULL))
		{
                    /* put command back on queue so menu bar can be swapped */
                    long msg = OM_S_SUCCESS;
                    ex$putque(msg = &msg,
                              pos = FRONT,
                              response = &me->event1.response,
                              byte = (IGRlong *)&me->event1.nbytes,
                              buffer = me->event1.event.keyin);

                    /* signal the command that this key was ignored */
		    *sts = MSINARG;
		}
		else
		{
		    me->cmd_type = FI_CMD_KEY;
		    strncpy(me->cmd, me->event1.event.keyin,
                            PAL_MAX_CMD_LENGTH);
		    me->cmd[PAL_MAX_CMD_LENGTH - 1] = NULL;

		    /*
		     * If an icon does not exist for the command
		     * set the symbol file to null.
		     */ 
		    if (! GRpal_get_cmd_icon(me->cmd,
					     me->symbol_file, 
					     &me->symbol)) 
		    {   
			/*
			 * This command does not have a symbol
			 * defined for it.
			 */
			*sts = MSFAIL;
		    }
		}
            }
            else                /* EX_STRING or CMD_STRING */
            { 
                strncpy(me->cmd, me->event1.event.keyin, PAL_MAX_CMD_LENGTH);
                me->cmd[PAL_MAX_CMD_LENGTH - 1] = NULL;
                COtool_strip_quotes (me->cmd);
                me->cmd_type = FI_CMD_STRING;
                *sts = MSFAIL;
            }
        } 
        break;

      case CO_create_pal:
        /* 
         * Construct the palette.
         */
        me->p = GRpal_create (sts, 
                              FALSE,
                              me->rows, me->cols, 
                              FI_MED_GREY, 
                              3, 133, 
                              -1, -1,
                              90, 60, 
                              FI_WHITE, FI_BLACK);

        if (!(*sts & 1)) *sts = MSFAIL;
        break;

      case CO_init_pal:
        /* 
         * Construct the palette in transient object space.
         */
        me->p = GRpal_recreate (sts, 
                                me->name);

        if (!(*sts & 1)) *sts = MSFAIL;
        else *sts = MSSUCC;

        break;
    
      case CO_add_cmd:
        if (me->mytype == PALCRE)
        {
            row = me->num_cmds / me->p->cols;
            col = me->num_cmds % me->p->cols;
            p = me->p;
        }
        else                    /* Adding a button individually. */
        {
            row = GRpal_cur_cmd.row;
            col = GRpal_cur_cmd.col;
            p = GRpal_cur_cmd.p;
        }

        *sts = GRpal_add_cmd(p,
                             row, col,
                             me->cmd_type,
                             me->cmd,
                             me->symbol_file,
                             me->symbol);
 

        if (*sts & 1)
        {
            if (me->num_cmds == ((me->rows * me->cols)-1))
            {
                *sts = MSFAIL;
            }
            else 
            {
                *sts = MSSUCC;
                ++(me->num_cmds);
            }
        }
        else 
        { 
            if (*sts != PAL_E_ABORT) *sts = MSFAIL;
        }
        break;

      case CO_rem_cmd:
        *sts = GRpal_del_cmd (GRpal_cur_cmd.p,
                              GRpal_cur_cmd.row,
                              GRpal_cur_cmd.col);
        break;

      case CO_sav_pal:

        *sts = GRpal_save_file (GRpal_cur_cmd.p, me->name, PAL_ASK_BEFORE_SAVE);
        break;

      case CO_del_pal:
        *sts = GRpal_delete (GRpal_cur_cmd.p);
        break;

      case CO_palette_locate_on:
      case CO_palette_locate_off:
        GRpal_btn_locate_func = (func == CO_palette_locate_on) ? 
            COpal_palette_locate_func : NULL;
    
        break;

      case CO_pop_cmd:
        if (me->num_cmds) --me->num_cmds;
        
        break;

    }                           /* end case */

    return (OM_S_SUCCESS);
}

end implementation COpal;
