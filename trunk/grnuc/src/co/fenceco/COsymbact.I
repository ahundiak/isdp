/*
Name
        COsymbology_action

Description
        This function is the action handler used to add an object to
        the current graphic set if it passes the specified symbology
        criteria.  The normal graphic set action handler is invoked
        to actually add the object to the set.

History
        mrm     05/08/91    creation
        jjm     02/19/92    added logic code to intersect color, style,
                            and weight options
*/

class implementation COgenset;

#include "grgs.h"
#include "grpgen.h"

from GRvg import GRgetsymb;

IGRint COsymbology_action(symbact, new_entry, locate_args, action)
struct COsymbact *symbact;
struct GRlc_info *new_entry;
IGRchar *locate_args;
enum GRlocate_action *action;
{
    IGRint sts = OM_S_SUCCESS, call_default = TRUE;

    switch (*action)
    {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
        call_default = FALSE;

        if (symbact->symb_set & (COLOR_DEFINED | STYLE_DEFINED | WEIGHT_DEFINED))
        {
            IGRlong msg;
            struct GRsymbology symbology;

            /*
                get the located object's symbology and compare it to
                the specified symbology; if it passes, add the object
                to the active graphic set
            */

            sts = om$send (msg = message GRvg.GRgetsymb(&msg, &symbology),
                           senderid = NULL_OBJID,
                           targetid = new_entry->located_obj.objid,
                           targetos = new_entry->located_obj.osnum);

            if (sts & msg & 1)
            {
                if (symbact->symb_set & COLOR_DEFINED)
                {
                    if ((1 << (symbology.display_attr.color % 8)) & symbact->color[symbology.display_attr.color / 8])
                    {
                        call_default = TRUE;
                    }
                }
                else call_default = TRUE;

                if ((symbact->symb_set & STYLE_DEFINED)&&(call_default==TRUE))
                {
                    if ((1 << (symbology.display_attr.style % 8)) & symbact->style[symbology.display_attr.style / 8])
                    {
                        call_default = TRUE;
                    }
		    else call_default = FALSE;
                }
		else call_default &= TRUE;

                if ((symbact->symb_set & WEIGHT_DEFINED)&&(call_default==TRUE))
                {
                    if ((1 << (symbology.display_attr.weight % 8)) & symbact->weight[symbology.display_attr.weight / 8])
                    {
                        call_default = TRUE;
                    }
		    else call_default = FALSE;
                }
            }
        }
        else  /* no symbology was specified; add object to graphic set */
        {
            call_default = TRUE;
        }

        break;

      case start_transition:
      case end_transition:
      case post_object:
      case check_object:
      case add_nopost:
      default:
        break;
    }

    if (call_default)
    {
        /* call the normal graphic set action handler */

        struct GRrp_action_args args;

        args.rp_relation = symbact->rp_relation;
        args.clip_flag = symbact->clip_flag;
        args.gs_id = symbact->gs_id;
        args.sv_id = symbact->sv_id;
        sts = GRgs_rp_action(&args, new_entry, locate_args, action);
    }

    return (sts);
}

end implementation COgenset;
