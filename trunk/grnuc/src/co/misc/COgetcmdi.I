/*
Name
        COgetcmd.execute

Description
        This command object displays a form with a list of commands which
        matches a user-supplied pattern.  The user may then pick a command to
        invoke from the list.  A separate form will display the menu path to
        the selected command.
 
History
        dhm     10/23/91    creation date.
        msm     04/16/93    Added checks to find duplicate commands and ignore
                            them. Also made getting command process one pass
                            instead of two pass.
        mrm     08/16/93    Added the menu path display, created
                            COpick_command from code buried in execute.
	Satish  07/26/95    Check for command name length before processing it.
			    TR#119423944.
*/

class implementation COgetcmd;

#include <stdio.h>
#include <FI.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "ex.h"
#include "expriv.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grmessage.h"
#include "msdef.h"
#include "msmacros.h"

#define	CO_CMD_LEN	64
#define	CO_MAX_STR_LEN	128

#define KEYIN_SEARCH_STRING 0
#define WAIT_FOR_FORM_STATE 1

extern struct EX_cmd_cntrl *EX_cmdlist_ptr;

static int COsort_list(char **l1, char **l2)
{
    return(strcmp(l1[0], l2[0]));
}

int COpick_command(char *form_title, char *search_string, Form *form)
{
    char **list = NULL;
    char cmd_name[64];
    int i, j, num_cmds = 0;
    int sts, match, found;
    struct EX_cmd_cntrl *cmd_cntrl;

    /* get a pointer into the EXNUC list of commands */
    cmd_cntrl = EX_cmdlist_ptr;

    /* allocate a chunk of memory for the command list */
    list = (char **)malloc(20 * sizeof(char *));
    if (!list)
    {   /* No dynamic memory available */
        ex$message(msgnumb = GR_I_NoMemory);
        return(FALSE);
    }

    for (i = 0; i < cmd_cntrl->no_of_cmd; i++)
    {
        if (cmd_cntrl->cmd[i].invis_cmd)
            continue;

        strncpy(cmd_name, " ", 64);

	/** check for cmd name length **/

	if (cmd_cntrl->cmd[i].command_nbytes > 64)
	{
        	strncpy(cmd_name, cmd_cntrl->cmd[i].command_name_ptr,
                	64);
	}
	else
	{		
        	strncpy(cmd_name, cmd_cntrl->cmd[i].command_name_ptr,
                	cmd_cntrl->cmd[i].command_nbytes);
	}
        
        match = GRis_substr(search_string, cmd_name);
        
        if (match)
        {
            /* check whether the command is already in the list */
            for (j = 0, found = 0; j < num_cmds && !found; j++)
                if (!strcmp(list[j], cmd_name))
                    found = 1;

            if (!found)
            {
                /* add the command to the list */
                list[num_cmds] = (char *)calloc(1, CO_CMD_LEN * sizeof(char));
                if (!list[num_cmds])
                {
                    ex$message(msgnumb = GR_I_NoMemory);
                    goto punt;
                }

		/* Use strncpy instead of strcpy - When the cmd length is 
		   greater 64, it is truncated and therefore will not have
		   an end terminator */

                strncpy(list[num_cmds], cmd_name, CO_CMD_LEN);

                /* grow the list as necessary */
                if ((++num_cmds > 1) && ((num_cmds % 20) == 0))
                {
                    list = (char **)realloc(list,
                                            (num_cmds + 20) * sizeof(char *));
                    if (!list)
                    {
                        ex$message(msgnumb = GR_I_NoMemory);
                        goto punt;
                    }
                }
            }
        }
    }
    if (num_cmds == 0)
    {
        ex$message (msgnumb = GR_I_NoCmdsFound);
        return(FALSE);
    }            
    
    /* sort the command list */
    qsort(list, num_cmds, sizeof(int *), COsort_list);

    /* display form with list of commands */
    sts = COpick_command_from_list(form_title, list, num_cmds,
                                   NULL, NULL, TRUE, form);
    
  punt:

    /* free memory */
    if (list)
    {
        for (i = 0; i < num_cmds; i++)
            if (list[i]) free(list[i]);
        free(list);
    }

    return(TRUE);
}

// Handle form display/erase/delete for suspending & killing the command.
// Note that FIf_is_valid is used, since the form can delete itself in its
// callback function when it is accepted or dismissed.

method wakeup(int pos)
{
    if (me->form && (FIf_is_valid(me->form) == FI_SUCCESS))
        FIf_display(me->form);
    return(OM_S_SUCCESS);
}

method sleep(int pos)
{
    if (me->form && (FIf_is_valid(me->form) == FI_SUCCESS))
        FIf_erase(me->form);
    return(OM_S_SUCCESS);
}

method delete(int unused)
{
    if (me->form && (FIf_is_valid(me->form) == FI_SUCCESS))
        FIf_delete(me->form);

    om$send(mode = OM_e_wrt_message,
            msg = message Root.delete(NULL),
            targetid = my_id);

    return(OM_S_SUCCESS);
}

method execute (int *response; char *response_data; int pos)
{
    char title[128];
    long msg, sts;
    struct GRevent event;
    
    sts = OM_S_SUCCESS;
    msg = MSSUCC;
    
    ex$message(msgnumb = GRC_M_GetCmd);
    ex$message(msgnumb = GRC_M_GetCmd, buff = title);
    
    do
    {
        switch (me->state)
        {
          case KEYIN_SEARCH_STRING:
            
            sts = co$getevent(msg = &msg,
                              event_mask = GRm_TEXT_VALUE,
                              msgnum = GR_P_KeyinSrchStr,
                              response = response,
                              response_data = response_data,
                              event = &event);

            if (!(sts & msg & 1))
            {
                sts = OM_S_SUCCESS;
                *response = TERMINATE;
                goto quit;
            }
            
            if (event.response == EX_STRING)
            {
                if (COpick_command(title, event.event.keyin, &me->form))
                    me->state = WAIT_FOR_FORM_STATE;
            }
            else
                goto quit;
            break;
            
          case WAIT_FOR_FORM_STATE:
            
            sts = co$getevent(msg = &msg,
                              event_mask = GRm_FORM_FINISHED | GRm_STRING,
                              response = response,
                              response_data = response_data,
                              event = &event);

            if (!(sts & msg & 1))
            {
                sts = OM_S_SUCCESS;
                *response = TERMINATE;
                goto quit;
            }
            
            if (*response == EX_FORM_FINISHED)
                me->state = KEYIN_SEARCH_STRING;
            
            if ((*response == EX_FORM_FINISHED) ||
                (*response == TERMINATE) ||
                (*response == CLEAR_STACK) ||
                (*response == TOGGLE_COMMAND) ||
                (*response == EX_CMD_KEY) ||
                (*response == CMD_STRING) ||
                (*response == STRING))
                goto quit;
            
            break;          
            
          default:
            *response = TERMINATE;
            goto quit;
        }
    } while (TRUE);
    
  quit:
    return(sts);
}

end implementation COgetcmd;
