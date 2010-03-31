/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
# include "igrtypedef.h"
# include "OMlimits.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "ex.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"

/*
Abstarct
        This utility inserts a new entry in the
        locate stack. The distance (stored in proj_pnt[0]) is used
        as a sorting key.
*/

EMsort ( stack, new_entry )

struct GRlc_stack     *stack;
struct GRlc_info      *new_entry;

{
        struct GRlc_info     *temp;
        IGRint start, ii, m, end;

    /*
     *    if the stack is empty
     */

    if (!stack->num_entries)
    {
        stack->entry[0] = *new_entry;
        stack->num_entries++;
        return (1);
    }
    
    /*
     *    check (FULL_STACK && distance too big)
     */

    if (stack->num_entries == MAX_LCSTACK_LEN
                           &&
        stack->entry[0].proj_pnt[0] < new_entry->proj_pnt[0])
    {
        return (1);
    }
                     
    /*
     *    check redundant objid and osnum
     */

    temp = &stack->entry[0];
    for (ii=0; ii < stack->num_entries; ii++)
    {
        if (temp->located_obj.objid == new_entry->located_obj.objid
                                    &&
            temp->located_obj.osnum == new_entry->located_obj.osnum)
        {
            /*
             *   Since the entry is allready on the stack there is 
             *   no need in reinserting it.  The distance has to
             *   be the same and the context has to be the same
             *   if it is the same object in the same object 
             *   space.
             */

            return (1);
        }
        else
        {
            temp++;
        }
    }

    /*
     *    check top of stack for trivial insertion
     */

    if (stack->num_entries < MAX_LCSTACK_LEN 
                           &&
        stack->entry[stack->num_entries - 1].proj_pnt[0] >= new_entry->proj_pnt[0])
    {
        stack->entry[stack->num_entries++] = *new_entry;
        return (1);
    }

    /*
     *   Insert at top of stack
     */

    if (stack->num_entries < MAX_LCSTACK_LEN 
                           &&
        stack->entry[0].proj_pnt[0] <= new_entry->proj_pnt[0])
    {
        stack->num_entries++;
        for (ii=stack->num_entries - 1; ii > 0; ii--)
        {
            stack->entry[ii] = stack->entry[ii - 1];
        }
        stack->entry[0] = *new_entry;
        return (1);
    }
    /*
     *    find proper spot in stack to insert
     */
    start = 0;
    end = stack->num_entries;
    while (start <= end)
    {
        m = (start + end) / 2;
        if (new_entry->proj_pnt[0] > stack->entry[m].proj_pnt[0])
        {
            end = m - 1;
        }
        else
        {
            start = m + 1;
        }
    }

   /* 
    *    Increment the stack if necessary
    */

    if (stack->num_entries < MAX_LCSTACK_LEN)
    {
        for (ii = stack->num_entries; ii > start; ii--)
        {
            stack->entry[ii] = stack->entry[ii - 1];
        }
        stack->num_entries++;
    }
    else
    {
        if (start >= MAX_LCSTACK_LEN)
        {
            start = MAX_LCSTACK_LEN - 1;
        }
        else
        {
            start--;
        }
        for (ii = 0; ii < start; ii++)
        {
            stack->entry[ii] = stack->entry[ii + 1];
        }
    }
    stack->entry[start] = *new_entry;
    return (1);
}
