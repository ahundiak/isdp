/* $Id: VSmigrstCmdi.I,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSmigrstCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmigrstCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/12/09  20:38:12  pinnacle
# Replaced: vscmd/VSmigrstCmdi.I for:  by impd for struct
#
# Revision 1.1  1997/10/06  11:16:54  pinnacle
# Created: vscmd/VSmigrstCmdi.I by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          creation
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSmigrstCmd ;

#include <stdio.h>
#include <stdlib.h>
#include <FI.h>
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "COBmacros.h"
#include "vsdef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes
 */
/* VX_FIproto.h uses OPP keywords ... */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsstrngproto.h"

/*
 * Gadget label in form.
 */
#define STIFF_NAMES	12
#define NB_OF_STIFF	16
#define LOCATE_STIFF	11
#define NUMBER_GRP	19

%safe
static char	**VSstfList	= NULL ;
static int	VSstfCount	= 0 ;
%endsafe

extern OMuword OPP_VSstfBeam_class_id ;

from GRgraphics import GRgetname ;

extern long VDobjInActiveSpace( long *msg, int *count, struct GRid **loc_obj, OMuword  class);

/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	long 	sts ;
	SetProc( init_cmd ); Begin

	sts = om$send(	msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
			targetid= my_id ) ;

	me->num_of_stfns = 0 ;
	me->nb_stiff_fr_name = 0;
	me->nb_stiff_located = 0;


	me->ret = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	End
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method store_stiffener( int *sts ) {

	long			sts ;
	char			*form = me->forms[0].form_ptr ;
	struct GRlc_info	*toStore = me->event1.located_object ;

	SetProc( store_stiffener ); Begin

	sts = om$send(	msg	= message VSlocateCmd.addLocObj(
							  &toStore->located_obj,
							  &toStore->module_info,
							  me->num_of_stfns),
			targetid= my_id ) ;
	if( sts & 1 ) {
		me->nb_stiff_located++ ;
		me->num_of_stfns = me->nb_stiff_located + me->nb_stiff_fr_name ;
		FIg_set_value( form, NB_OF_STIFF,
			       (double) me->num_of_stfns ) ;		
	}

	me->ret = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	End
	return OM_S_SUCCESS ;

} /* method store_stiffeners */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	long			sts,
				msg ;
	int			i,
				nbStiff ;
	struct GRobj_env	fence,
				*stiffeners = NULL ;
	char			*form = me->forms[0].form_ptr ;

	SetProc( process_fence ); Begin

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	sts = vs$process_fence( msg		= &msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				p_count 	= &nbStiff,
				p_content	= &stiffeners,
				response	= me->response,
				response_data	= me->response_data ) ;
	__CheckRC( sts, msg, "VSlocateCmd.addLocObj", wrapup ) ;

	if( *me->response != EX_DATA || !nbStiff ) {
		me->ret = VS_K_NO_FENCE ; return OM_S_SUCCESS ;
	}

	sts = om$send(	msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
			targetid= my_id ) ;

	for( i=0; i<nbStiff; i++ ) {
		sts = om$send( msg = message VSlocateCmd.addLocObj(
					    &stiffeners[i]._grid,
					    &stiffeners[i].mod_env,
					    i + me->num_of_stfns ),
			       targetid = my_id ) ;
		__CheckRC( sts, 1, "VSlocateCmd.addLocObj", wrapup ) ;
	}

	me->nb_stiff_located = nbStiff + me->nb_stiff_located ;

	me->num_of_stfns = me->num_of_stfns + nbStiff ;

	FIg_set_value( form, NB_OF_STIFF, (double) me->num_of_stfns ) ;

	wrapup :
		_FREE( stiffeners ) ;
		me->ret = sts & 1 & msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		End
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method setFormSettings() {

	char	*form = me->forms[0].form_ptr ;

	SetProc( setFormSettings ); Begin

	me->num_of_stfns = 0 ;
	me->suppressHilite  = TRUE ;

	FIg_erase( form, NUMBER_GRP ) ;

	if( VSstfCount && VSstfList ) {
		VSmcf_set_list_text( form, STIFF_NAMES, 0, VSstfCount, VSstfList ) ;
	}

	End
	return OM_S_SUCCESS ;

} /* method setFormSettings */
/*----------------------------------------------------------------------------*/
method saveFormSettings() {

	int	rc ;
	char	*form = me->forms[0].form_ptr ;

	SetProc( saveFormSettings ); Begin

	if( VSstfCount && VSstfList ) {
		VSfreeList( VSstfCount, VSstfList ) ;
	}

	rc = FIfld_get_num_rows( form, STIFF_NAMES, &VSstfCount ) ;

	if( rc == FI_SUCCESS ) {
		if( VSstfCount ) {
			VSstfList = VSmcf_get_list_text( form, STIFF_NAMES, 0 ) ;
			if( !VSstfList ) VSstfCount = 0 ;
		} else {
			VSstfList = NULL ;
		}
	} else {
		VSstfCount	= 0 ;
		VSstfList	= NULL ;
	}

	End
	return OM_S_SUCCESS ;

} /* method saveFormSettings */
/*----------------------------------------------------------------------------*/
/* ARGSUSED */
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long			msg,
				sts ;
	int			size,
				i,
				response;
	char			**list = NULL;
	struct GRobj_env	*stiffeners = NULL ;
	int			nbStif = 0 ,
		    		index = 0, cnt = 0;
	struct GRid		*stifList = NULL ;
	GRname			stfPath ;
	char			stfName[80] ;

	SetProc( form_notification ); Begin

	switch( gadget_label ) {

	case FI_ACCEPT	:

		if( ! (me->num_of_stfns &&
		      (stiffeners = _MALLOC( me->num_of_stfns,
					   struct GRobj_env ))) ) {

			ex$message( msgnumb = VS_gE_NoDynMem ) ;

			response = EX_FORM_FINISHED ;
			ex$putque( msg = &msg, response = &response ) ;
			break ;
		}

		sts = om$send( msg	  = message VSlocateCmd.getLocObjs(
						    &msg,
						    me->num_of_stfns,
						    stiffeners ),
				 targetid = my_id ) ;
		/*
		 * Migrate the selected stiffeners
		 */
		sts = VSmigrateStiffeners( 	&msg, 
						me->num_of_stfns, 
						stiffeners );
		_FREE( stiffeners ) ;


	case FI_CANCEL	: response = EX_FORM_FINISHED ;
			  ex$putque( msg = &msg, response = &response ) ;
			  break ;

	case STIFF_NAMES	: 

		VSfld_del_empty_rows( form_ptr, gadget_label, 0 ) ;
		/*
		 * Get the strings in this field, row by row, 
		 * and evaluate the number of stiffeners that 
		 * can be migrated with the matching names and display
		 * them in the number of stiffeners field.
		 */
		FIfld_get_num_rows( form_ptr, STIFF_NAMES, &size ) ;

		me->nb_stiff_fr_name = 0 ;

		if( size ) {
			list = VSmcf_get_list_text( form_ptr, STIFF_NAMES, 0 ) ;
		}
		/*
		 * Write a function which gets all the stiffeners and
		 * taking this list checks if the stiffener name 
		 * is within the list of the stiffener names entered by
		 * the user.
		 * The validated stiffener list must be added to the locate
		 * instance, and update the number of stiffeners to reflect 
		 * the appropriate count
		sts = VDobjInActiveSpace( 	&msg, 
						&nbStif,  
						&stifList, 
						OPP_VSstfBeam_class_id ) ;
		__CheckRC( sts, msg, "VDobjInActiveSpace", wrapup ) ;
		 */
		 sts = VDobjInActiveSpace(  &msg,  &nbStif,  &stifList,  OPP_VSstfBeam_class_id ) ;
		if ( nbStif ) {
		    int 	found ;
		    for( i=0; i<nbStif; i++ ) {
			sts = om$send( msg = message GRgraphics.GRgetname(
							&msg,
							stfPath ),
					targetid = stifList[i].objid ,
					targetos = stifList[i].osnum ) ;
			__CheckRC( sts, msg, "GRgraphics.GRgetname", wrapup ) ;

			di$split(	pathname = stfPath,
					name	 = stfName );

			found = VSgetMacDefIndex( stfName, size, list ) ;
			if( -1 == found ) {
				/*
			  	 * Not in wanted list.
				 */
				continue ;
                	}

                	sts = om$send( msg = message VSlocateCmd.addLocObj(
                       					&stifList[i],
							NULL ,
							index+me->num_of_stfns ),
					targetid = my_id ) ;
			cnt++ ;
			if( (sts == VS_K_OBJONCHEXIST ) ) {
				continue ;	
			} 
			index++ ;
        	    }

		    me->nb_stiff_fr_name = cnt ;
		    me->num_of_stfns = me->nb_stiff_fr_name + me->nb_stiff_located ;
		}
		/*
		 * Fill the gadget number of stiffeners
		 */

		FIg_set_value( 	form_ptr, 
				NB_OF_STIFF, 
				(double) me->num_of_stfns ) ;

		VSfreeList( size, list ) ;
		if( stifList ) _FREE( stifList ) ;

		break ;

	case LOCATE_STIFF: response = VS_K_GADGET_LOCATED ;
			  ex$putque( msg = &msg, response = &response ) ;
			  break ;
	}
                End
wrapup :
		End
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/

end implementation VSmigrstCmd ;
