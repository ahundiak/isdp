/* $Id: GRowputsymb.I,v 1.1 2001/07/28 17:40:28 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/emsfixes/GRggrigidcon.I
 *
 * Description: Tweak to support using graphic groups in VDbufMacros
 *              Do not pass symbology changes downward
 * Dependencies: 
 *
 * Revision History:
 *      $Log: GRowputsymb.I,v $
 *      Revision 1.1  2001/07/28 17:40:28  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/24/01  ah      Created
 ***************************************************************************/
/* #######################    APOGEE COMPILED   ######################## */

/*\
Description
    The following messages are passed to the unknown message handler 
    which will pass them to the components.

History
    Gray Winn       10/15/87    Design and Coding date.
    jay wallingford 04/27/89    Optimized the making of the chanselect
    scott walters   06/23/92    Added static ANSI C prototypes
\*/
   
class implementation GRowner;

#include "OMmacros.h"
#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"

extern int   GRget_to_comp_chansel();

extern GRclassid OPP_GRgrgrp_class_id;

/* -----------------------------------------------
 * During a recompute of a macro it appears that all
 * owner objects get told to rest their symbology
 *
 * Don't know why, maybe it has something to do
 * with the fact that and owner object get's it's
 * symbology from it's first component
 *
 * In any event this causes all the components to change their symbology
 * Need to prevent this by seeing if the owner object is attached to
 * a VDbufMacro
 *
 * For now, try suppressing this for all GRaphic groups and see what happens
 */

method GRputsymb(long *msg; struct GRsymbology *symb)
{
    long         om_msg;
    OM_S_CHANSELECT chansel;

    IGRint flag = 0;
    struct GRid  myID;
#if 0    
    fprintf(stderr,">>> GRowner.GRputsymb %d L%d C%d\n",
	   my_id,symb->level,symb->display_attr.color);
#endif
    // Ignore for graphic group
    myID.objid = my_id;
    myID.osnum = OM_Gw_current_OS;    
    if (flag == 0) flag = VDobjIsAncestryValid(NULL,&myID,OPP_GRgrgrp_class_id,NULL);
    if (flag) {
      *msg = MSSUCC;
      om_msg = OM_S_SUCCESS;
      return om_msg;
    }
    
    if ( GRget_to_comp_chansel( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRvg.GRputsymb (msg, symb),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

    return (om_msg);
}


end implementation GRowner;
