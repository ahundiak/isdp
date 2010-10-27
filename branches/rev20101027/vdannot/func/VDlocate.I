/* $Id: VDlocate.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:	vdannot/func/VDlocate.I
 *
 * Description:		VD_DMlocate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDlocate.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.3  1995/08/31  18:46:22  pinnacle
# Replaced: vdannot/func/VDlocate.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/08/30  13:39:54  pinnacle
# Replaced: vdannot/func/VD[AlpsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/08/29  21:13:36  pinnacle
# Created: vdannot/func/VDlocate.I by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *	08/26/95     HF		Creation
 *				Override of dimensioning function DMlocate()
 *
 * -------------------------------------------------------------------------
 */
class implementation DMroot;

#define AS_DEBUG 1

#include "griodef.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dimlocate.h"

#include "msdef.h"		/* MSSUCC, MSFAIL		*/
#include "maerr.h"		/* MANOMEMORY			*/
#include "grgs.h"		/* GRobj_env			*/
#include "grownerdef.h"		/* GR_LC_RIGID			*/
#include "grgsmacros.h"		/* gr$gsget_fence() macro	*/
#include "OMmacros.h"		/* OM_BLOCK_MOVE() macro	*/
#include "msmacros.h"
#include "DMmsg.h"

extern GRclassid	OPP_GRgraphics_class_id;

IGRint VD_DMlocate
(
  IGRlong		 *rc,		/* Return code from ls$locate	*/
  struct GRevent	 *event1,	/* Event for the locate point	*/
  struct GRevent	 *event2,	/* Event for the accept point	*/
  IGRlong		 *mask1,	/* Mask for the locate		*/
  IGRlong		 *mask2,	/* Mask for the input events	*/
  IGRlong		  display_flag,	/* Flag to define the display mode */
  IGRint		 *response,
  IGRchar		 *response_data,
  IGRchar		 *locate_prompt,
  IGRchar		 *acc_prompt,
  IGRchar		 *relocate_prompt,
  struct GRlc_locate	 *attributes,	/* Attributes to be found	*/
  struct DMact_info	 *act_parms,	/* Action handler parameters	*/
  struct GRlc_dynamics	 *hand_dyn,	/* Function & args for dynamics	*/
  OM_p_CLASSLIST	  Class_List	/* List of classes to locate; may be NULL */
)
{
	IGRlong		  status, msg;
	struct GRevent	  locevt;
	OM_S_CLASSLIST	  classlist;
	OM_p_CLASSLIST	  p_classlist;
	OMuword		  class[1];

	if ( Class_List )
	{
	  p_classlist = Class_List;	/* From Input arguments	*/
	}
	else
	{
	  /*
	   * If input arg (Class_List == NULL), then ALL graphics classes are to be
	   * located.
	   */
	  p_classlist = &classlist;	/* Locally defined	*/

	  classlist.w_count	= 1;
	  classlist.w_flags	= OM_CLST_subclass;
	  classlist.p_classes	= class;

	  class[0] = OPP_GRgraphics_class_id;
	}

	status =
	lc$locate(
		rc		=  rc,
		event1		=  event1,
		event2		=  event2,
		event3		= &locevt,
		mask1		=  mask1,
		mask2		=  mask2,
		display_flag	=  display_flag,
		hilight_mode	=  GRhd,
		unhilight_mode	=  GRhe,
		response	=  response,
		response_data	=  response_data,
		locate_prompt	=  locate_prompt,
		acc_prompt	=  acc_prompt,
		relocate_prompt	=  relocate_prompt,
		attributes	=  attributes,
		stack		= &act_parms->stack,
		dyn		=  (hand_dyn->GRlc_dyn) ? hand_dyn : NULL,
		act_handler	=  DMaction_handler,
		eligible_classes= p_classlist,
		act_args	=  act_parms);

	dm$status(action = RET_STATUS);

	if (!(display_flag & LC_ERASE_LOC_ELEMENT))
		dp$erase_hilite ( msg = &msg );

	/*^
		printf("status = %d, rc = %d\n", status, *rc);
		printf("response: %d\n", *response);

		printf("event1: grid=%d, %d, num_id=%d\n",
				event1->located_object[0].located_obj.objid,
				event1->located_object[0].located_obj.osnum,
				event1->num_id);

		printf("event2: grid=%d, %d, num_id=%d\n",
				event2->located_object[0].located_obj.objid,
				event2->located_object[0].located_obj.osnum,
				event2->num_id);

		printf("locevt: grid=%d, %d, num_id=%d\n",
				locevt.located_object[0].located_obj.objid,
				locevt.located_object[0].located_obj.osnum,
				locevt.num_id);
	*/

	if (*rc == LC_OBJ_LOCATED)
	{
		event1->num_id = locevt.num_id;
		event1->located_object[0] = locevt.located_object[0];
	}

	return(TRUE);
}

end implementation DMroot;
