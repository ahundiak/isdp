/* $Id: VDTransYS.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/imp / VDTransYS.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDTransYS.I,v $
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

class implementation GRgraphics ;

#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcdef.h"
#include "lc.h"

extern int	LCcselect(),
		LCevaction() ;

long VDStranslateYourself( msg, name, target, translatedId )

long		*msg ;		/* OUT: Completion code			*/
char		*name ;		/* IN : name of `target'		*/
struct GRid	*target,	/* IN : di$translated object from `name'*/
		*translatedId ; /* OUT: object pointed to by `target'	*/

{

	/*
	 * Sample call:
	 * struct GRid	pointer,
	 *		object ;
	 * GRname	name ;
	 * long		msg ;
	 *
	 * msg = di$translate(	objname	= name,
	 *			p_objid	= &pointer.objid,
	 *			p_osnum	= &pointer.osnum ) ;
	 * if( !( msg & 1 ) ) etc.
	 * VDStranslateYourself( &msg, name, &pointer, &object ) ;
	 */
	long			sts ;
	struct GRmd_env		mod ;
	int			nbytes ;
	struct GRlc_cvl		cvl ;
	int			levels[32],
				i ;
	OM_S_CLASSLIST		eligible_classes ;
	struct GRlc_locate	attributes ;
	struct LC_action_args	locate_args ;
	struct GRlc_stack	stack ;
	struct LC_select_args	select_info ;

	IGRboolean		is_bore	= FALSE ;
	int			obj_hilighted,
				size = sizeof( struct GRevent )
					- ( 2 * sizeof( int ) ),
				response ;
	struct GRevent		event2,
				event3 ;
	double			response_data[128] ;

	/*
	 * The following 12 441 lines are just to fill the cvl structure.
	 */

	/* Active module */
	nbytes = sizeof cvl.module ;
        gr$get_module_env(	msg	= msg,
        			sizbuf	= &nbytes,
				buffer	= &cvl.module,
				nret	= &nbytes ) ;

	/* Accept all levels 32 * 32 = 1024 */
	for( i = 0 ; i < 32 ; i++ ) {
		levels[i] = 0xffffffff ;
	}
	cvl.levels = levels ;

	/* Accept all classes */
	eligible_classes.w_count	= 0 ;
	eligible_classes.w_flags	= 0 ;
	eligible_classes.p_classes	= NULL ;
	cvl.classes			= &eligible_classes ;

	/* No rtree classes */
	cvl.r_classes			= NULL ;

	/* Name locate */
	cvl.attributes.type		= GR_nam_loc ;

	/*
	 * If translate done during a locate, retrieve locate criteria.
	 */

	{
		struct GRlc_locate	*attr ;
		OM_S_CLASSLIST		rtree, eligible ;
		int			regex, hilite, unhilite ;
		long			dpflag ;

		attr = &cvl.attributes.obj_attr ;

		dpflag		= attr->properties	= rtree.w_count
				= eligible.w_count	= regex
				= hilite		= unhilite = 0 ;

		LCmark_node( LC_PASS_CRITERIA ) ;
		LCget_prev_criteria(	&dpflag,
					attr,
					&rtree,
					&eligible,
					&regex,
					&hilite,
					&unhilite ) ;
	
#ifdef DEBUG
	printf( "-- properties %d\n", attr->properties ) ;
#endif
		if(    !dpflag && !attr->properties && !rtree.w_count
		    && !eligible.w_count && !regex && !hilite && !unhilite ) {
			/*
			 * We may assume there is no previous locate going on.
			 */
			attr->properties	= LC_LC_ONLY | LC_DP_ONLY ;
			attr->owner_action	=   LC_RIGID_OWNER
						  | LC_FLEX_COMP ;
			attr->classes[0]	= '\0' ;
#ifdef DEBUG
	printf( "-- No previous locate criteria\n" ) ;
#endif
		}
	}

	/* Any range */
	cvl.attributes.acc_tolerance	= 100000 ;
	cvl.action_handler		= LCevaction ;
	cvl.act_parms			= NULL ;

	select_info.response_data	= (char *) response_data ;
	select_info.obj_hilighted	= (char *) &obj_hilighted;
	select_info.acc_prompt		= "" ;
	select_info.relocate_prompt	= "" ;
	select_info.is_bore		= &is_bore ;
	select_info.eventsize		= &size ;
	select_info.response		= &response ;
	select_info.eventmask		= GRm_DATA ;
	select_info.display_flag	= 0 ;
	select_info.stack		= &stack;
	select_info.dyn			= NULL ;
	select_info.accept_event	= &event2 ;
	select_info.acc_event1		= &event3 ;
	select_info.relocate_key	= MS_NO_MSG ;
	select_info.acc_key		= MS_NO_MSG ;
	select_info.nbytes		= &nbytes ;
	select_info.value_type		= NULL ;
	select_info.scale_flag		= GRIO_X_SCALE ;
	select_info.mode		= GRhd ;
	select_info.hilight_mode	= GRhd ;

	stack.number_located		= stack.num_entries = 0 ;
	locate_args.stack		= &stack ;
	locate_args.rc			= msg ;
	locate_args.type		= GR_nam_loc ;
	locate_args.located		= 0 ;
	locate_args.is_regex		= FALSE ;
	locate_args.max_entries		= 0 ;
	locate_args.select		= LCcselect ;
	locate_args.select_args		= (char *) &select_info ;
	locate_args.loc_select_args	= &select_info ;

	cvl.locate_args = &locate_args ;

	/*
	 * NOW WE GET TO THE ACTION! THANK YOU GRNUC.
	 */
	sts = om$send(	msg	= message GRgraphics.GRlocate( &cvl, NULL ),
			senderid= target->objid,
			targetid= target->objid,
			targetos= target->osnum ) ;

	*msg = MSSUCC ;
	if( !( sts & 1 & cvl.msg ) ) {
#ifdef DEBUG
	printf( "GRgraphics.GRlocate FAILED\n" ) ;
#endif
		/*
		 * Target object probably not a GRgraphic, eg. an expression.
		 */
		*translatedId = *target ;
	} else {

		*translatedId = stack.entry[0].located_obj ;
	}

	return sts ;
}

end implementation GRgraphics ;

