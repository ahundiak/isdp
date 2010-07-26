/*
Name
        LCpost

Description
        These functions manage the locate criteria which is passed
        between commands.  This criteria is maintained in a linked
        list, with one node for each command in the command stack.

History
        rc      01/01/89    creation
        mrm     12/11/89    added comments which I hope reflect what is
                            going on in these functions.
        hgb     09/09/91    test pointers for NULL before de-ref
*/

#include "grimport.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "exmacros.h"
#include "lc.h"

#ifdef DEBUG_PRINT
#include "OMprimitives.h"
#endif

/*
    The static variable LClocate_point is used to keep up with where in
    the locate stage the user is at a given time.  This variable is
    maintained with the LCmark_locate function.  A value of
    LC_Locate_Point (1) implies that the user is at the "locate" stage
    (waiting for an event which will identify an element); a value of
    LC_Other_Point (0) implies that the user is at some later stage in
    the locate, usually the accept/reject stage (waiting for an event
    indicating whether the identified object is desired).  This
    knowledge is necessary to determine whether to retrieve a previous
    command's locate criteria.  If the user is at a locate stage, the
    previous criteria should be used to prevent unwanted objects from
    being located.  At the accept stage, this is not necessary (except
    in the case of chain locate, which is not currently handled). 
*/

static int LClocate_point;

/*
    The static variable LCfirst_time is used to determine whether to
    tell the command server to call LCcommand_function each time
    the command stack is manipulated.  It is only necessary to do
    so once.
*/
                                
static int LCfirst_time = 1;

/*
    The structure LC_sd_criteria is used to store the locate criteria
    values which may be passed between commands.
*/

struct LC_sd_criteria
{
    IGRlong display_flag;
    IGRint regex;
    IGRint hilite_mode;
    IGRint unhilite_mode;
    struct GRlc_locate attributes;
    OM_S_CLASSLIST rtree_classes;
    OM_S_CLASSLIST eligible_classes;
};

/*
    The structure LC_sd_node is used to define a doubly linked list of
    LC_sd_criteria structures.  The use_node field is used to determine
    whether a list entry should be used as criteria for locate.  Possible
    values are LC_NO_CRITERIA (don't use), LC_CRITERIA (use), and
    LC_PASS_CRITERIA (don't use), defined in lcdef.h
*/

struct LC_sd_node
{
    IGRint use_node;
    struct LC_sd_criteria *data;
    struct LC_sd_node *next;
    struct LC_sd_node *prev;
};

static struct LC_sd_node *LCnode = NULL;


/*
Name
        LCpost_function

Description
        This function will tell the command server to call LCcommand_function
        whenever a command is created, deleted, swapped, or the stack is
        cleared.

        Notice that since this is called only when the locate functionality
        is invoked there is no action taken for startup commands.  There is
        special case handling for the first command since it has already
        been constructed when this routine is called.
*/

int LCpost_function()
{
    IGRint LCcommand_function();

#ifdef DEBUG_PRINT
    printf ("LCpost_function: LCfirst_time = %d\n", LCfirst_time);
#endif

    if (LCfirst_time)
    {
        LCfirst_time = 0;
/*
        ex$add_cmdserver_fun (fun = LCcommand_function);
*/
        EX_add_cmdserver_function (LCcommand_function);
/*
        LCcommand_function (EX_CMD_NEW);
*/
    }
    return(1);
}


/*
Name
        LCcommand_function

Dsecription
        This function will be called from the command server.  It will
        manage the LCnode structure so that there is one LC_sd_node per
        command on the stack.
*/

int LCcommand_function (mode)
int mode;
{
    struct LC_sd_node *t, *t1;

#ifdef DEBUG_PRINT
    printf ("LCcommand_function: ");
#endif

    switch (mode)
    {
        case EX_CMD_DISCONNECT: 
        case EX_CMD_POP:

            /*
             *  These cases occur on a command disconnecting itself from the
             *  command stack or a command is popped (deleted) from the
             *  command stack.
             */

#ifdef DEBUG_PRINT
            printf ("case EX_CMD_DISCONNECT or EX_CMD_POP\n");
#endif
            if (LCnode)
            {
                t = LCnode;
                if (LCnode->next) 
		{
                    LCnode = LCnode->next;
                    LCnode->prev = NULL;
                }
                else 
		{
                    LCnode = NULL;
                }
                LCfree_criteria (t, 1);
            }
            break;

        case EX_CMD_DROP:

            /*
             *  This case occurs when a command is dropped from the command
             *  stack.  The current limit of the stack is 10.
             */

#ifdef DEBUG_PRINT
            printf ("case EX_CMD_DROP\n");
#endif
            if (LCnode)
            {
                t = LCnode;
                t1 = LCnode->next;
                while (t1->next)
                {
                    t = t1;
                    t1 = t1->next;
                }
                t->next = NULL;
                LCfree_criteria (t1, 1);
            }
            break;

        case EX_CMD_NEW:

            /*
             *  This case allocates a node for the command.  Note that it
             *  does not fill in the criteria of the node.  It only
             *  allocates the node.
             */

#ifdef DEBUG_PRINT
            printf ("case EX_CMD_NEW\n");
#endif
            t = (struct LC_sd_node *) malloc (sizeof (struct LC_sd_node));
            t->data = NULL;
            t->next = LCnode;
            t->prev = NULL;
            t->use_node = 0;
            if (LCnode)
            {
                LCnode->prev = t;
            }
            LCnode = t;
            break;

        case EX_CMD_CLEAR_STACK:

            /*
             *  This case handles the clearing of the stack.
             *  All nodes are freed.
             */

#ifdef DEBUG_PRINT
            printf ("case EX_CMD_CLEAR_STACK\n");
#endif
            while (LCnode)
            {
                t = LCnode;
                LCnode = LCnode->next;
                LCfree_criteria(t, 1);
            }
            break;

        case EX_CMD_SWAP:

            /*
             *  This case handles the swapping of two commands.  No data
             *  is copied.  Only pointers are rearranged.
             */

#ifdef DEBUG_PRINT
            printf ("case EX_CMD_SWAP\n");
#endif
            t = LCnode;
            t1 = LCnode->next;
            LCnode = t1;
            t->next = t1->next;
            t1->next = t;
            t->prev = t1;
            t1->prev = NULL;
            t1->next->prev = t;
            break;

      case EX_CMD_SLEEP:

            // Turn off the Options Form button on the bar menu.  This has
            // nothing to do with locate, but since the notification mechanism
            // is already in place, this is a handy & efficient place to stick
            // this so that commands don't have to worry about turning the
            // button off themselves.  --Mike

            GRstatus_display_button(0);
            break;
    }
#ifdef DEBUG_PRINT
    print_criteria_list ();
#endif
    return(1);
}


/*
Name
        LCadd_criteria

Description
        This routine will fill in the criteria structure in the node that is
        at the top of the list.
*/

int LCadd_criteria (display_flag, attributes, rtree_classes, eligible_classes,
                    regex, hilite_mode, unhilite_mode)
IGRlong display_flag;
struct GRlc_locate *attributes;
OM_p_CLASSLIST rtree_classes, eligible_classes;
IGRint regex;
IGRint hilite_mode, unhilite_mode;
{
    IGRint ii;

#ifdef DEBUG_PRINT
    printf ("LCadd_criteria\n");
#endif

    /*
     *  If the data has not been already inserted.  This can happen due to
     *  command stacking.
     */

    if (LCnode && !LCnode->data)
    {
        LCnode->use_node = 1;
        LCnode->data = (struct LC_sd_criteria *) 
                           malloc (sizeof (struct LC_sd_criteria));
        LCnode->data->display_flag = display_flag;
        LCnode->data->regex = regex;
        LCnode->data->hilite_mode = hilite_mode;
        LCnode->data->unhilite_mode = unhilite_mode;
        LCnode->data->attributes = *attributes;

        if (rtree_classes && rtree_classes->w_count)
	{

            LCnode->data->rtree_classes.w_count = rtree_classes->w_count;
            LCnode->data->rtree_classes.w_flags = rtree_classes->w_flags;
            LCnode->data->rtree_classes.p_classes = (OMuword *) malloc 
                          (sizeof (OMuword) * rtree_classes->w_count);
            for (ii = 0; ii < (IGRint)rtree_classes->w_count; ii++)
	    {
                LCnode->data->rtree_classes.p_classes[ii] = 
                             rtree_classes->p_classes[ii];
            }
        }
        else
	{
            LCnode->data->rtree_classes.w_count = 0;
            LCnode->data->rtree_classes.w_flags = 0;
            LCnode->data->rtree_classes.p_classes = 0;
        }

        if (eligible_classes && eligible_classes->w_count)
	{

            LCnode->data->eligible_classes.w_count = eligible_classes->w_count;
            LCnode->data->eligible_classes.w_flags = eligible_classes->w_flags;
            LCnode->data->eligible_classes.p_classes = (OMuword *) malloc 
                          (sizeof (OMuword) * eligible_classes->w_count);
            for (ii = 0; ii < (IGRint)eligible_classes->w_count; ii++)
	    {
                LCnode->data->eligible_classes.p_classes[ii] = 
                               eligible_classes->p_classes[ii];
            }
        }
        else
	{
            LCnode->data->eligible_classes.w_count = 0;
            LCnode->data->eligible_classes.w_flags = 0;
            LCnode->data->eligible_classes.p_classes = 0;
        }
    }
#ifdef DEBUG_PRINT
    print_criteria_list();
#endif
    return(1);
}


/*
Name
        LCfree_criteria

Description
        This function frees all memory allocated for an LC_sd_node structure.
*/

int LCfree_criteria (t, all)
struct LC_sd_node *t;
IGRint all;
{

#ifdef DEBUG_PRINT
    printf ("LCfree_criteria\n");
#endif

    if (t)
    {
        if (t->data)
	{
            if (t->data->rtree_classes.w_count)
	    {
                free (t->data->rtree_classes.p_classes);
            }
            if (t->data->eligible_classes.w_count)
	    {
                free (t->data->eligible_classes.p_classes);
            }
            free(t->data);
            t->data = NULL;
        }
        if (all)
	{
           free (t);
           t = NULL;
        }
    }
    return(1);
}


/*
Name
        LCdel_criteria

Desciption
        This function frees the base node of the list.
*/

int LCdel_criteria()
{
#ifdef DEBUG_PRINT
    printf ("LCdel_criteria\n");
#endif

    LCfree_criteria (LCnode, 0);
    return(1);
}


/*
Name
        LCget_prev_criteria

Description
        This function returns the locate criteria of the last command
        which declared its own criteria.
*/

int LCget_prev_criteria (display_flag, attributes, rtree_classes,
                         eligible_classes, regex, hilite_mode, unhilite_mode)
IGRlong            *display_flag;
struct GRlc_locate *attributes;
OM_p_CLASSLIST     rtree_classes, eligible_classes;
IGRint             *regex;
IGRint             *hilite_mode, *unhilite_mode;
{
    struct LC_sd_criteria *temp;
    struct LC_sd_node     *temp_node;

#ifdef DEBUG_PRINT
    printf ("LCget_prev_criteria: LClocate_point = %d\n", LClocate_point);
#endif

    /*
     *	Since the list is always added to at the head, the previous
     *	criteria is the one pointed to by the field next.
     */

    temp_node = LCnode;

    if (LClocate_point)
    {
        while (temp_node && temp_node->next && temp_node->use_node == 2)
	{
            temp_node = temp_node->next;
        }
 
        if (temp_node && temp_node->data && temp_node->use_node == 1)
	{
            temp = temp_node->data;
            if (display_flag)
              *display_flag = temp->display_flag;
            if (regex)
              *regex = temp->regex;
            if (hilite_mode)
              *hilite_mode = temp->hilite_mode;
            if (unhilite_mode)
              *unhilite_mode = temp->unhilite_mode;
            if (attributes)
              *attributes = temp->attributes;
            if (rtree_classes)  
              *rtree_classes = temp->rtree_classes;
            if (eligible_classes)  
              *eligible_classes = temp->eligible_classes;
#ifdef DEBUG_PRINT
            printf ("\t returning the following criteria\n");
            print_criteria_node (temp_node);
#endif
        }
    }
    return(1);
}


/*
Name
        LCmark_node

Description
*/

int LCmark_node (mode)
int mode;
{
#ifdef DEBUG_PRINT
    printf ("LCmark_node: mode = LCnode->use_node = %d\n", mode);
#endif

    if (LCnode)
        LCnode->use_node = mode;
    return(1);
}


/*
Name
        LCmark_locate

Description
*/

int LCmark_locate (mode) 
int mode;
{
#ifdef DEBUG_PRINT
    printf ("LCmark_locate: mode = LClocate_point = %d\n", mode);
#endif

    LClocate_point = mode;
    return(1);
}

#ifdef DEBUG_PRINT
int print_criteria_list ()
{
    int i = 0;
    static char use_modes[3][32] =
                {{"LC_NO_CRITERIA"}, {"LC_CRITERIA"}, {"LC_PASS_CRITERIA"}};
    struct LC_sd_node *node;

    printf ("print_criteria_list\n");
    node = LCnode;
    while (node)
    {
        printf ("node #%d\n", i++);
        printf ("node->use_node = %d\t%s\n", node->use_node, use_modes[node->use_node]);
        if (node->use_node && node->data)
            print_criteria_node (node);
        node = node->next;
    }
    return (1);
}

int print_criteria_node (node)
struct LC_sd_node *node;
{
    int i;
    char classname[64];
    struct LC_sd_criteria *criteria;

    criteria = node->data;

    printf ("criteria->display_flag = %#x\n", criteria->display_flag);
    printf ("criteria->regex = %d\n", criteria->regex);
    printf ("criteria->hilite_mode = %d\n", criteria->hilite_mode);
    printf ("criteria->unhilite_mode = %d\n", criteria->unhilite_mode);
    printf ("criteria->attributes.classes = %s\n", criteria->attributes.classes);
    printf ("criteria->attributes.properties = %#x\n", criteria->attributes.properties);
    printf ("criteria->attributes.owner_action = %#x\n", criteria->attributes.owner_action);
    printf ("criteria->rtree_classes.w_count = %d\n", criteria->rtree_classes.w_count);
    printf ("criteria->rtree_classes.w_flags = %#x\n", criteria->rtree_classes.w_flags);
    for (i = 0; i < criteria->rtree_classes.w_count; i++)
    {
        classname[0] = NULL;
        om$get_classname (classid = criteria->rtree_classes.p_classes[i],
                          classname = classname);
        printf ("criteria->rtree_classes.p_classes[%d] = %d\t%s\n",
                i, criteria->rtree_classes.p_classes[i], classname);
    }
    printf ("criteria->eligible_classes.w_count = %d\n", criteria->eligible_classes.w_count);
    printf ("criteria->eligible_classes.w_flags = %#x\n", criteria->eligible_classes.w_flags);
    for (i = 0; i < criteria->eligible_classes.w_count; i++)
    {
        classname[0] = NULL;
        om$get_classname (classid = criteria->eligible_classes.p_classes[i],
                          classname = classname);
        printf ("criteria->eligible_classes.p_classes[%d] = %d\t%s\n",
                i, criteria->eligible_classes.p_classes[i], classname);
    }
    return (1);
}
#endif
