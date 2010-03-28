/*
Name
        COlocelig.sl

Description
        This command drives the locate eligiblility form.

History
        mrm     10/23/90    creation
        scw     07/10/92    ansi conversion
*/

command_object      GRMLcElFm, 0, GRLcElFm
synonym             GRMRvESlCr, 0, GRRvESlCr
product_name        "$GRNUC"
class               "COlocelig"
super_class         "CEO"
form                "GRLocElig", LABEL, DISPLAYCODE, XCOORD, YCOORD
options             "SIcT"
start_state         wait_for_input

specification

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"

instance
{
    variable struct GRelclass_f elclass[];
}

implementation

#include <stdio.h>
#include "FI.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "grmessage.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"

#define CLASSFIELD      13
#define CLEAR_BUTTON    15
#define SET_BUTTON      16

state_table

#define LABEL       0
#define DISPLAYCODE 1
#define XCOORD      0
#define YCOORD      0
#define IFORM       1
#include "grcmd.h"

state wait_for_input
    message_key GRC_M_LcElFm
    filter wfi
        on EX_FORM_FINISHED
            state terminate

action init
{
    IGRchar buf[128], *c;
    IGRint i, j, sel, count;
    IGRlong sts;
    struct GRelclass_f *p;
    struct var_list vlist[2];

    /* send to parent to pick up necessary initialization */

    status = om$send (mode = OM_e_wrt_message,
                      msg = message CEO.init (type, str_ptr),
                      targetid = my_id);

    /* make sure the form was created before writing to it - this might happen
       if the command file is not created properly */
 
    if (me->forms == NULL || me->forms[0].form_ptr == NULL)
        return(OM_S_SUCCESS);

    /* get the number of classes stored in the dpb */

    vlist[0].var = DPB_NUMBER_CLASSES;
    vlist[0].var_ptr = (IGRchar *)&count;
    vlist[1].var = END_PARAM;

    gr$set_inq (msg = &sts, var_list = vlist);

    /* allocate memory for the data */

    om$vla_set_dimension (varray = me->elclass, size = count);

    /* retrieve the data from the dpb */

    vlist[0].var = DPB_GET_CLASSES;
    vlist[0].var_ptr = (IGRchar *)me->elclass;

    gr$set_inq (msg = &sts, var_list = vlist);

    /* put the data on the form, indenting to show ownership depth */

    for (i = 0; i < count; i++)
    {
        p = &me->elclass[i];
        buf[0] = NULL;
        for (j = 0; j < p->depth; j++) strcat (buf, "  ");
#ifndef BELIEVE_RETURN_CODE
        c = &buf[j * 2];
        *c = NULL;
#endif
        sts = ex$message (msgname = p->ascii_key, buff = &buf[j * 2]);
#ifndef BELIEVE_RETURN_CODE
        if (*c == NULL)
#else
        if (!(sts & 1))
#endif
            strcat (buf, p->ascii_key);
        sel = (int)p->properties & DPB_LOCATABLE;
        FIfld_set_text (me->forms[0].form_ptr, CLASSFIELD, i, 0, buf, sel);
    } 

    return (OM_S_SUCCESS);
}

action form_notification /* (int form_label;
                             int gadget_label;
                             double value; 
                             char *form_ptr); */
{
    IGRlong  msg, i;
    IGRint depth, row, ncategories, state;
    struct var_list vlist[2];
    struct GRelclass_f *e;

    status = OM_S_SUCCESS;

    switch (gadget_label)
    {
      case FI_ACCEPT:
    
        /* save the changes in the dpb */

        vlist[0].var = DPB_SET_PROPERTIES;
        vlist[0].var_ptr = (IGRchar *)me->elclass;
        vlist[1].var = END_PARAM;
        gr$set_inq (msg = &msg, var_list = vlist, set_inq = DPB_SET);

        /* no break */

      case FI_CANCEL:

        /* erase the form and terminate the command */

        FIf_erase (form_ptr);
        *me->response = EX_FORM_FINISHED;
        i = sizeof (struct EX_button);
        ex$putque (msg = &msg,
                   response = me->response,
                   byte = &i,
                   buffer = me->response_data);
        break;

      case CLEAR_BUTTON:
      case SET_BUTTON:

        row = 0;
        depth = -1;
        e = &me->elclass[row];
        if (gadget_label == SET_BUTTON)
            e->properties |= DPB_LOCATABLE;     /* set */
        else
            e->properties &= ~DPB_LOCATABLE;    /* clear */
        state = e->properties;
        ncategories = om$dimension_of (varray = me->elclass);
        while (row < ncategories && e->depth > depth)
        {
            (e++)->properties = state;
            FIfld_set_select (form_ptr, CLASSFIELD, row++, 0, state);
        }
        FIg_set_state_off (form_ptr, gadget_label);
        break;

      case CLASSFIELD:

        /* mark the entry as toggled */

        row = (int)value;
        e = &me->elclass[row];
        e->properties ^= DPB_LOCATABLE;
        depth = e->depth;
        state = e->properties;

        /* check for owners and turn them on also */

        if (e->depth && (state & DPB_LOCATABLE))
        {
            while (--row >= 0 && (--e)->depth >= 0)
            {
                if (e->depth < depth)
                {
                    e->properties = state;
                    FIfld_set_select (form_ptr, CLASSFIELD, row, 0, state);
                    depth--;
                }
            }
        }

        /* toggle any sub-categories to match the lead category */

        row = (int)value;
        e = &me->elclass[row];
        depth = e->depth;
        ncategories = om$dimension_of (varray = me->elclass);
        while (++row < ncategories && (++e)->depth > depth)
        {
            e->properties = state;
            FIfld_set_select (form_ptr, CLASSFIELD, row, 0, state);
        }
        break;
    }
    return (OM_S_SUCCESS);
}
