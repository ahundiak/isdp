/* $Id: VSctoutsCmdi.I,v 1.1.1.1 2001/01/04 21:10:22 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSctoutsCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSctoutsCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:22  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/29  08:29:00  pinnacle
# Replaced: vscmd/VSctoutsCmdi.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification for Simualtion process
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSctoutsCmd ;

#include <stdio.h>
#include <stdlib.h>
#include <FI.h>
#include "OMmacros.h"
#include "exdef.h"
#include "madef.h"
#include "exmacros.h"
#include "COBmacros.h"
#include "dpmacros.h"
#include "vsdef.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes
 */
/* VX_FIproto.h uses OPP keywords ... */
#include "maidmx.h"

#define message		__message__
#define increment	__increment__
#	include "VX_FIproto.h"
#undef message
#undef increment
#include "vsformproto.h"
#include "vsstrngproto.h"

extern long VSsimulateCutOuts() ;
/*
 * Sub form for test results
 */
#define VS_K_TEST_PROC	"VStestProc.fm"
#define VS_K_MacField	14
#define VS_K_WriteFile	16
#define VS_K_FileName	15

/*
 * Gadget label in form.
 */
#define MCF		12
#define ERROR		16
#define LOCATE_PART	15
#define NUMBER_OF_PART	18
#define NUMBER_GRP	19
#define TEST_PROCESS	21

%safe
static char	**VSmacList	= NULL ;
static int	VSmacCount	= 0 ;
%endsafe
/*----------------------------------------------------------------------------*/
method init( int type; char *string ){

	me->testForm = NULL ;

	om$send( msg    = message VSlocateCmd.init( type, string ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
 
        return OM_S_SUCCESS ;

}/* method init */
/*----------------------------------------------------------------------------*/
method sleep( int pos ){

	if( me->testForm ) FIf_erase ( me->testForm );

	om$send( msg    = message VSlocateCmd.sleep( pos ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
 
        return OM_S_SUCCESS ;

}/* method sleep */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ){

	if ( me->testForm ) {
		int disp_sts ;

		FIf_is_displayed( me->testForm, &disp_sts ) ;
 
		if(!( disp_sts ) )	 FIf_display( me->testForm );
	}

	om$send( msg    = message VSlocateCmd.wakeup( pos ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
 
        return OM_S_SUCCESS ;

}/* method wakeup */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ){

        if ( me->testForm ) FIf_delete( me->testForm ) ;

	om$send( msg    = message VSlocateCmd.delete( f_defer_flag ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
 
        return OM_S_SUCCESS ;

}/* method delete */
/*----------------------------------------------------------------------------*/
method store_part( int *sts ) {

	long			sts ;
	char			*form = me->forms[0].form_ptr ;
	struct GRlc_info	*toStore = me->event1.located_object ;

	sts = om$send(	msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
			targetid= my_id ) ;

	me->number_of_parts = 0 ;

	sts = om$send(	msg	= message VSlocateCmd.addLocObj(
							  &toStore->located_obj,
							  &toStore->module_info,
							  me->number_of_parts ),
			targetid= my_id ) ;

	if( sts & 1 ) {
		me->number_of_parts = 1 ;

		FIg_set_value( form, NUMBER_OF_PART,
			       (double) me->number_of_parts ) ;
		FIg_display( form, NUMBER_GRP ) ;
	}

	me->ret = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	return OM_S_SUCCESS ;

} /* method store_part */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	long			sts,
				msg ;
	int			i,
				nbParts ;
	struct GRobj_env	fence,
				*parts = NULL ;
	char			*form = me->forms[0].form_ptr ;

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	sts = vs$process_fence( msg		= &msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				p_count 	= &nbParts,
				p_content	= &parts,
				response	= me->response,
				response_data	= me->response_data ) ;
	__CheckRC( sts, msg, "VSlocateCmd.addLocObj", wrapup ) ;

	if( *me->response != EX_DATA || !nbParts ) {
		me->ret = VS_K_NO_FENCE ; return OM_S_SUCCESS ;
	}

	sts = om$send(	msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
			targetid= my_id ) ;

	me->number_of_parts = 0 ;

	for( i=0; i<nbParts; i++ ) {
		sts = om$send( msg	= message VSlocateCmd.addLocObj(
							      &parts[i]._grid,
							      &parts[i].mod_env,
							      i ),
			       targetid = my_id ) ;
		__CheckRC( sts, 1, "VSlocateCmd.addLocObj", wrapup ) ;
	}

	me->number_of_parts = nbParts ;

	FIg_set_value( form, NUMBER_OF_PART, (double) me->number_of_parts ) ;
	FIg_display( form, NUMBER_GRP ) ;

	wrapup :
		_FREE( parts ) ;
		me->ret = sts & 1 & msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method setDefaults() {

	char	*form = me->forms[0].form_ptr ;

	me->number_of_parts = 0 ;
	me->suppressHilite  = TRUE ;

	FIg_erase( form, NUMBER_GRP ) ;

	if( VSmacCount && VSmacList ) {
		VSmcf_set_list_text( form, MCF, 0, VSmacCount, VSmacList ) ;
	}

	return OM_S_SUCCESS ;

} /* method setDefaults */
/*----------------------------------------------------------------------------*/
method saveDefaults() {

	int	rc ;
	char	*form = me->forms[0].form_ptr ;

	if( VSmacCount && VSmacList ) {
		VSfreeList( VSmacCount, VSmacList ) ;
	}

	rc = FIfld_get_num_rows( form, MCF, &VSmacCount ) ;

	if( rc == FI_SUCCESS ) {
		if( VSmacCount ) {
			VSmacList = VSmcf_get_list_text( form, MCF, 0 ) ;
			if( !VSmacList ) VSmacCount = 0 ;
		} else {
			VSmacList = NULL ;
		}
	} else {
		VSmacCount	= 0 ;
		VSmacList	= NULL ;
	}

	return OM_S_SUCCESS ;

} /* method saveDefaults */
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
				response,
				*found			= NULL,
				*success		= NULL ;
	char			**list			= NULL,
				*badOperatorInMacDef	= NULL,
                                **macsFailed            = NULL,
				**fObject		= NULL ;

	char			buf[100] ;
	struct GRobj_env	*parts			= NULL ;
	int			fCount ,
				objCount ;

	if( form_label == TEST_PROCESS ) {
                om$send( msg = message VSctoutsCmd.sub_form_notification(
                                                        me->testForm,
                                                        gadget_label ),
                        targetid = my_id );
        } else {

	switch( gadget_label ) {

	case FI_ACCEPT	:
		 FIg_erase( form_ptr, ERROR ) ;

		 VSfld_blank_out_rows( form_ptr, MCF, 1 ) ;
		 FIfld_get_num_rows( form_ptr, MCF, &size ) ;

		 if( size ) {
			list = VSmcf_get_list_text( form_ptr, MCF, 0 ) ;

			if( !( (found	= _MALLOC( size, int )) &&
			       (success = _MALLOC( size, int )) ) ||
			       (me->number_of_parts &&
				!(parts = _MALLOC( me->number_of_parts,
						   struct GRobj_env ))) ) {
				VSfreeList( size, list ) ;

				ex$message( msgnumb = VS_gE_NoDynMem ) ;

				response = EX_FORM_FINISHED ;
				ex$putque( msg = &msg, response = &response ) ;
				break ;
			}

			om$send( msg	  =
					  message VSlocateCmd.getLocObjs(
							    &msg,
							    me->number_of_parts,
							    parts ),
				 targetid = my_id ) ;

			sts = VSfindCutOuts( &msg,
					     me->number_of_parts,
					     parts,
					     size,
					     list,
					     found,
					     success,
					     &badOperatorInMacDef ) ;
			if( !( sts & 1 & msg ) ) {
#if 0
				printf( "VSfindCutOuts FAILED\n" ) ;
#endif
			} else {
				for( i = 0 ; i < size ; i++ ) {
					sprintf( buf, "%3d/%3d",
						 found[i], success[i] ) ;
					FIfld_set_text( form_ptr, MCF, i,
							1, buf, FALSE ) ;
				}
				if( badOperatorInMacDef ) {
					FIg_display( form_ptr, ERROR ) ;

					ex$message( msgnumb = VS_gI_InvalidOperator,
						    type    = "%s",
						    var     = `badOperatorInMacDef`,
						    buff    = buf ) ;
					FIfld_set_text( form_ptr, ERROR, 0, 0,
							buf, FALSE ) ;

				}
			 }
			VSfreeList( size, list ) ;
			_FREE( found ) ; _FREE( success ) ;
			_FREE( badOperatorInMacDef ) ;
			_FREE( parts ) ;
		}
		FIg_set_state_off( form_ptr, gadget_label ) ;
		break ;

	case FI_CANCEL	: response = EX_FORM_FINISHED ;
			  ex$putque( msg = &msg, response = &response ) ;
			  break ;

	case MCF	: VSfld_del_empty_rows( form_ptr, gadget_label, 0 ) ;
			  VSfld_blank_out_rows( form_ptr, gadget_label, 1 ) ;
			  break ;

	case LOCATE_PART: response = VS_K_GADGET_LOCATED ;
			  ex$putque( msg = &msg, response = &response ) ;
			  break ;
	
	case TEST_PROCESS:
		 FIg_erase( form_ptr, ERROR ) ;

		 VSfld_blank_out_rows( form_ptr, MCF, 1 ) ;
		 FIfld_get_num_rows( form_ptr, MCF, &size ) ;

		 if( size ) {
			list = VSmcf_get_list_text( form_ptr, MCF, 0 ) ;

			if( !( (found	= _MALLOC( size, int )) &&
			       (success = _MALLOC( size, int )) ) ||
			       (me->number_of_parts &&
				!(parts = _MALLOC( me->number_of_parts,
						   struct GRobj_env ))) ) {
				VSfreeList( size, list ) ;

				ex$message( msgnumb = VS_gE_NoDynMem ) ;

				response = EX_FORM_FINISHED ;
				ex$putque( msg = &msg, response = &response ) ;
				break ;
			}

			om$send( msg	  =
					  message VSlocateCmd.getLocObjs(
							    &msg,
							    me->number_of_parts,
							    parts ),
				 targetid = my_id ) ;

			fCount = 0;
			objCount = 0;

			sts = VSsimulateCutOuts(&msg,
					     	me->number_of_parts,
					     	parts,
					     	size,
					     	list,
					     	found,
					     	success,
					     	&badOperatorInMacDef,
						&fCount, 
						&macsFailed,
						&objCount,
						&fObject ) ;
			if( !( sts & 1 & msg ) ) {
#if 0
				printf( "VSSimulateCutouts  FAILED\n" ) ;
#endif
			} else {
				for( i = 0 ; i < size ; i++ ) {
					sprintf( buf, "%3d/%3d",
						 found[i], success[i] ) ;
					FIfld_set_text( form_ptr, MCF, i,
							1, buf, FALSE ) ;
				}
				if( badOperatorInMacDef ) {
					FIg_display( form_ptr, ERROR ) ;

					ex$message( msgnumb = VS_gI_InvalidOperator,
						    type    = "%s",
						    var     = `badOperatorInMacDef`,
						    buff    = buf ) ;
					FIfld_set_text( form_ptr, ERROR, 0, 0,
							buf, FALSE ) ;

				}
			 }
			if( fCount ) {
				if ( me->testForm ) {
                       			int disp_sts ;

					FIf_is_displayed( me->testForm, 
							  &disp_sts ) ;
 
                        		if(!( disp_sts ) )
						FIf_display( me->testForm );
                		} else {
					int x_pos , y_pos ;
                       			VSf_sub_form(   form_ptr,
                               		   		gadget_label,
                                        		VS_K_TEST_PROC,
                                        		&me->testForm ) ;
 
                        		FIf_get_location( 	form_ptr, 
								&x_pos, 
								&y_pos ) ;
                        		FIf_set_location( me->testForm,
                                          		x_pos+200,
                                          		y_pos+100 ) ;
 
                        		FIf_display( me->testForm) ;
                		}
				for( i = 0; i < fCount ; i++ ) {
					FIfld_set_text( me->testForm, 
							VS_K_MacField, 
							i, 
							0, 
							macsFailed[i], 
							FALSE );
					FIfld_set_text( me->testForm, 
							VS_K_MacField, 
							i, 
							1, 
							fObject[i], 
							FALSE );
				}
			}

			VSfreeList( size, list ) ;
			_FREE( found ) ; _FREE( success ) ;
			_FREE( badOperatorInMacDef ) ;
			for( i = 0; i < fCount ; i++ ) {
				_FREE( macsFailed[i] );
				_FREE( fObject[i] );
			} 
			_FREE( macsFailed );
			_FREE( fObject );
			_FREE( parts ) ;
		}
		FIg_set_state_off( form_ptr, gadget_label ) ;
		break ;
	}
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/method sub_form_notification( char *form_ptr ; int gadget_label ) {
 
        long            	sts,
                        	msg ;
	char            	*fileName ;
        FILE            	*usrFile ;
	int			row , pos;
	struct GRid		obj ;
	struct GRmd_env         actEnv ;
			
	row = pos = 0;
 
        switch (gadget_label ) {
 
                case FI_CANCEL            :
			/*
			 * Not deleteing the form purposefully
			 */
                        FIf_erase( form_ptr ) ;
                        break ;
 
		case VS_K_MacField :
 			/*
            		 * Highlight selected macro object.
            		 */
           		FIfld_get_active_row( 	form_ptr,
						gadget_label,
						&row,
						&pos );

           		dp$erase_hilite( msg = &msg ) ;
			{
			char	*text ;
                	text = VSmcf_get_text( 	form_ptr, 
						VS_K_MacField,
						row,
						1 ) ;
			sscanf( text, "%d %d", &obj.objid, &obj.osnum );	
			_FREE( text );
			}

			ex$get_cur_mod( osnum = &actEnv._MD_OS, 
					id = &actEnv._MD_ID ) ;
        		MAidmx( &msg, actEnv._MATRIX ) ; 
			actEnv._MATRIX_TYPE = MAIDMX ;

			vs$bulk_display(	count	= 1,
						dpmode	= GRhd,
						grids	= &obj, 
						theEnv	= &actEnv );
			break;
                case VS_K_WriteFile :
 
			/*
			 * Get the text in the file field
			 */ 
			fileName = VSfld_get_text( form_ptr, VS_K_FileName ) ;

			/*
			 * Open the file in write mode
			 */
                	if( usrFile = (FILE *) fopen( fileName, "w" ) ) {
				int	i, nbRows = 0;
				char	*macText = NULL,
					*objText = NULL ;
				/*
			 	 * Get the text from the macro name column and 
				 * object id column and write to the file 
				 * the user specified 
				 */
				FIfld_get_num_rows( 	form_ptr, 
							VS_K_MacField,
							 &nbRows ) ;
				for( i = 0 ; i < nbRows ; i++ ) {
                			macText = VSmcf_get_text( form_ptr, 
								  VS_K_MacField,
								  i,
								  0 ) ;
                			objText = VSmcf_get_text( form_ptr, 
								  VS_K_MacField,
								  i,
								  1 ) ;
                			fprintf( usrFile, "%-20s %s \n", 
							macText, objText ) ;
                			_FREE( macText ) ;
                			_FREE( objText ) ;
        			}

                        	fclose( usrFile ) ;
                	} else {
                       		char error[MS_MAX_MSG_LENGTH] ;
                        	ex$message(     msgnumb = VS_gE_OpenFileW,
						type	= "%s",
						var	= "",
                               		        buff    = error ) ;
                        	FIfld_set_text( form_ptr, FI_MSG_FIELD, 
						0, 0, error, FALSE ) ;
                	}
                	_FREE( fileName ) ;

                	FIg_set_state_off( form_ptr, gadget_label ) ;

			break ;
	}

	return OM_S_SUCCESS ;

}/* method sub_form_notification */
/*----------------------------------------------------------------------------*/
end implementation VSctoutsCmd ;
