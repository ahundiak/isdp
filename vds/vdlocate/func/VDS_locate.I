/* $Id: VDS_locate.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / VDS_locate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDS_locate.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
Name
        VDSlocate

Description
        This is the function that is called as lc$locate.
Notes
	This routine has be taken from the LClocate, to override the
	filter for I/VDS.

History
	adz	12/10/92	Creation Date.
 */

class implementation Root;

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "msdef.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "exmacros.h"
#include "OMerrordef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "execmsg.h"

from GRgraphics import GRlocate;

IGRint VDSlocate(rc, event1, event2, event3, eventmask1, eventmask2,
                 eventsize, display_flag, response, response_data,
                 locate_prompt, acc_prompt, relocate_prompt, attributes,
                 stack, dyn, type, act_handler, act_args, rtree_classes,
                 eligible_classes, select, select_args, max_entries, regex,
                 locate_key, acc_key, relocate_key, hilite_mode,
                 unhilite_mode, nbytes1, nbytes2, range_handler,
                 range_args, value_type1, value_type2, scale_flag)

IGRlong *rc;                        /* return code */ 
struct GRevent *event1;             /* return from GRgetevent */
struct GRevent *event2;             /* return from GRgetevent */
struct GRevent *event3;             /* return from GRgetevent */
IGRlong eventmask1;                 /* mask to GRgetevent */
IGRlong eventmask2;                 /* mask to GRgetevent */
IGRint *eventsize;                  /* size of struct GRevent */
IGRlong display_flag;               /* see lcdef.h */
IGRint *response;                   /* response from GRgetevent */
IGRchar *response_data;             /* response data from GRgetevent */
IGRchar *locate_prompt;             /* locate prompt */
IGRchar *acc_prompt;                /* accept/reject prompt */
IGRchar *relocate_prompt;           /* when an object is not located */
struct GRlc_locate *attributes;     /* contains class & level info */
struct GRlc_stack *stack;           /* pointer to "stack" */
struct GRlc_dynamics *dyn;          /* dynamics info */
IGRint type;
IGRint (*act_handler)();
IGRchar *act_args;
OM_p_CLASSLIST rtree_classes;
OM_p_CLASSLIST eligible_classes;
IGRint (*select)();
IGRchar *select_args;
IGRint max_entries;
IGRint regex;
IGRlong locate_key, acc_key;
IGRlong relocate_key;
IGRint hilite_mode;
IGRint unhilite_mode;
IGRint *nbytes1, *nbytes2;
IGRint (*range_handler);
IGRchar *range_args;
IGRchar *value_type1;
IGRchar *value_type2;
IGRint scale_flag;
{
    IGRint              ret_code;
    IGRint              i_regex, i_hilite_mode, i_unhilite_mode;
    IGRlong             i_display_flag, control;
    struct GRlc_locate  i_attributes;
    OM_S_CLASSLIST      i_rtree_classes, i_eligible_classes;

    /*
     *	Fill in temporary fields that can be replaced by the stored
     *	attributes.
     */

    i_display_flag = display_flag;
    i_attributes = *attributes;

    if (rtree_classes)
    {
        i_rtree_classes = *rtree_classes;
    }
    else
    {
        i_rtree_classes.w_count = 0;
        i_rtree_classes.w_flags = 0;
        i_rtree_classes.p_classes = NULL;
    }

    if (eligible_classes)
    {
        i_eligible_classes = *eligible_classes;
    }
    else
    {
        i_eligible_classes.w_count = 0;
        i_eligible_classes.w_flags = 0;
        i_eligible_classes.p_classes = NULL;
    }

    i_regex = regex;
    i_hilite_mode = hilite_mode;
    i_unhilite_mode = unhilite_mode;

    if (display_flag & LC_Retrieve_Criteria)
    {
        LCmark_node (LC_PASS_CRITERIA);
        LCput_criteria_class (eligible_classes);
        LCget_prev_criteria (&i_display_flag, &i_attributes, &i_rtree_classes,
                             &i_eligible_classes, &i_regex, &i_hilite_mode,
                             &i_unhilite_mode);

        /*
         *  There are certain flags that are not to be inhertited.  These
         *  need to be masked out.
         */

        control = ELEM_HILIGHT | NO_ACC_REJ_CYCLE | DO_NOT_RELOCATE |
                  LC_ACCEPT_CURSOR | LC_ACC_ONE_ELEMENT | LC_Retrieve_Criteria;

        i_display_flag = (control & display_flag) | i_display_flag;
    }
    else
    {
        LCadd_criteria (display_flag, attributes, rtree_classes,
                        eligible_classes, regex, hilite_mode, unhilite_mode,
                        act_handler, act_args, select, select_args);
    }

    ret_code = VDSlocate_processing(rc, event1, event2, event3, eventmask1, 
                                    eventmask2, eventsize, i_display_flag,
                                    response, response_data, locate_prompt,
                                    acc_prompt, relocate_prompt,
                                    &i_attributes, stack, dyn, type,
                                    act_handler, act_args, &i_rtree_classes,
                                    &i_eligible_classes, select, select_args,
                                    max_entries, i_regex, locate_key, acc_key,
                                    relocate_key, i_hilite_mode,
                                    i_unhilite_mode, nbytes1, nbytes2,
                                    range_handler, range_args, value_type1,
                                    value_type2, scale_flag);

    LCfree_class_criteria();

    return (ret_code);
}
end implementation Root;
