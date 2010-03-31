
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSinstance;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMminimum.h"
#include "OMmacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "msdef.h"
#include "dpdef.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmacdef.h"
#include "hswinmacros.h"
#include "hsurferrpriv.h"

#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"

%safe
#include "HSpr_gragad.h"
%endsafe


extern OMuword OPP_HSgragad_class_id;

/*--- HSget_default_instance ----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRlong HSget_default_instance( IGRlong *msg,
					IGRlong *which_error,
				struct var_list *var_list )
#else
	IGRlong HSget_default_instance( msg, which_error, var_list )

	IGRlong         *msg;
	IGRlong         *which_error;
	struct var_list *var_list;
#endif

/*
DESCRIPTION
	Inquire the default instance data for a shading window
*/

	{
	IGRboolean	               storage;
	struct HStotal_window_instance *users_struct;

	*msg = MSSUCC;

	storage = TRUE;
	while ( (storage) && (var_list->var != END_PARAM) )
	   {
	   /* Switch on attribute of the instance data that is being requested */
	   switch( var_list->var )
	      {
	      case HS_TOTAL_INSTANCE :

	         if ( storage = (var_list->num_bytes >= sizeof( struct HStotal_window_instance )) )
	            {
	            *(var_list->bytes_returned) = sizeof( struct HStotal_window_instance );
	            users_struct = (struct HStotal_window_instance *) var_list->var_ptr;

	            users_struct->disp_flags = 0;
	            users_struct->shading_style = HS_STYLE_SMOOTH;
	            }
	         break;

	      case HS_WIN_FLAGS :

	         if ( storage = (var_list->num_bytes >= sizeof( IGRuint )) )
	            {
	            *(var_list->bytes_returned) = sizeof( IGRuint );
	            *((IGRuint *)var_list->var_ptr) = 0;
	            }
	         break;

	      case HS_WIN_SHADING_STYLE :

	         if ( storage = (var_list->num_bytes >= sizeof( IGRuchar )) )
	            {
	            *(var_list->bytes_returned) = sizeof( IGRuchar );
	            *((IGRuchar *)var_list->var_ptr) = HS_STYLE_SMOOTH;
	            }
	         break;

	      default :

	         storage = FALSE;
	         break;

	   	}  /* end: switch */

	   /* If there was an error, then return the flag of the */
	   /* attribute that the error occured on                */
	   if (!storage)
	      {
	      *which_error = var_list->var;
	      *msg = MSFAIL;
	      }

	   var_list++;
	   }  /* end: while */

	return( (*msg == MSSUCC) ? 0 : 1 );

	}   /* HSget_default_instance */


/*--- HSget_window_instance_data -------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRlong HSget_window_instance_data( IGRlong *msg,
					 OM_S_OBJID win_id,
					    OMuword win_os,
					    IGRlong *which_error,
				    struct var_list *var_list )
#else
	IGRlong HSget_window_instance_data( msg, win_id, win_os, which_error, var_list )

	IGRlong         *msg;
	OM_S_OBJID      win_id;
	OMuword         win_os;
	IGRlong         *which_error;
	struct var_list *var_list;
#endif

	{
	IGRlong    sts;
	OMuword    classid;
	OM_S_OBJID hs_inst_id;

	*msg = MSSUCC;

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	if ( om$is_ancestry_valid( subclassid = classid, 
	                           superclassid = OPP_HSinstance_class_id ) == OM_S_SUCCESS )
	   {
	   /* object has HSinstance in its ancestry => get instance data from it */
	   sts = om$send( msg      = message HSinstance.HSinquire( msg, which_error, var_list ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );
	   }
	else
	   {
	   hs$get_saved_instance_id( msg = msg,
	                             win_id = win_id,
	                             win_os = win_os,
	                             instance_id = &hs_inst_id );

	   if ( hs_inst_id != NULL_OBJID )
	      {
	      /* window has a HSinstance object attached to it => get instance data from it */
	      sts = om$send( msg      = message HSinstance.HSinquire( msg, which_error, var_list ),
	                     targetid = hs_inst_id,
	                     targetos = win_os,
	                     senderid = NULL_OBJID );
	      }
	   else
	      {
	      /* return default instance data */
	      HSget_default_instance( msg, which_error, var_list );
	      }
	   }

	return( (*msg == MSSUCC) ? 0 : 1 );

	}  /* HSget_window_instance_data */


/*--- HSset_window_instance_data -------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRlong HSset_window_instance_data( IGRlong *msg,
					 OM_S_OBJID win_id,
					    OMuword win_os,
					    IGRlong *which_error,
				    struct var_list *var_list )
#else
	IGRlong HSset_window_instance_data( msg, win_id, win_os, which_error, var_list )

	IGRlong         *msg;
	OM_S_OBJID      win_id;
	OMuword         win_os;
	IGRlong         *which_error;
	struct var_list *var_list;
#endif

	{
	IGRlong    sts;
	OMuword    classid;
	OM_S_OBJID hs_inst_id;

	*msg = MSSUCC;

	hs$get_saved_instance_id( msg = msg,
	                          win_id = win_id,
	                          win_os = win_os,
	                          instance_id = &hs_inst_id );

	om$get_classid( objid = win_id, osnum = win_os, p_classid = &classid );

	if ( om$is_ancestry_valid( subclassid = classid, 
	                           superclassid = OPP_HSgragad_class_id ) == OM_S_SUCCESS )
	   {
	   /* object is a HS window => set its instance data */
	   sts = om$send( msg      = message HSinstance.HSset( msg, which_error, var_list ),
	                  targetid = win_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );
	   }
	else if ( hs_inst_id != NULL_OBJID )
	   {
	   /* window has a HSinstance object attached to it => set its instance data */
	   sts = om$send( msg      = message HSinstance.HSset( msg, which_error, var_list ),
	                  targetid = hs_inst_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );
	   }
	else
	   {
	   /* construct a HSinstance object, connect it to this window, and */
	   /* set the instance data in the HSinstance object                */
	   sts = om$construct( osnum = win_os,
	                       classid = OPP_HSinstance_class_id,
	                       p_objid = &hs_inst_id );

	      OM_ERRCHK( sts, "HSset_window_instance_data:  construct of HSinstance failed" );

	   HSconnect_instance_to_gragad( msg, hs_inst_id, win_id, win_os );

	   sts = om$send( msg      = message HSinstance.HSset( msg, which_error, var_list ),
	                  targetid = hs_inst_id,
	                  targetos = win_os,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "HSset_window_instance_data:  HSinstance.HSset send failed" );
	   }

	return( (*msg == MSSUCC) ? 0 : 1 );

	}  /* HSset_window_instance_data */


/*--- HSinquire -----------------------------------------------------------*/

method HSinquire( IGRlong *msg;
	          IGRlong *which_error;
	          struct var_list *list )

/*
DESCRIPTION
	Inquire method of the window.  Will look at the arguments in
	list and returned the requested information from the
	hidden line instance data
*/

	{
	IGRboolean	        storage;
	struct HStotal_window_instance *users_struct;

	*msg = MSSUCC;
	storage = TRUE;

	while ( (storage) && (list->var != END_PARAM) )
	   {
	   /* Switch on attribute of the instance data that is being requested */
	   switch( list->var )
	      {
	      case HS_TOTAL_INSTANCE :

	         if ( storage = (list->num_bytes >= sizeof( struct HStotal_window_instance )) )
	            {
	            *(list->bytes_returned) = sizeof( struct HStotal_window_instance );
	            users_struct = (struct HStotal_window_instance *) list->var_ptr;

	            users_struct->disp_flags = me->disp_flags;
	            users_struct->shading_style = me->shading_style;
	            }
	         break;

	      case HS_WIN_FLAGS :

	         if ( storage = (list->num_bytes >= sizeof( IGRuint )) )
	            {
	            *(list->bytes_returned) = sizeof( IGRuint );
	            *((IGRuint *)list->var_ptr) = me->disp_flags;
	            }
	         break;

	      case HS_WIN_SHADING_STYLE :

	         if ( storage = (list->num_bytes >= sizeof( IGRuchar )) )
	            {
	            *(list->bytes_returned) = sizeof( IGRuchar );
	            *((IGRuchar *)list->var_ptr) = me->shading_style;
	            }
	         break;

	      default :

	         storage = FALSE;
	         break;

	      }  /* end: switch */

	   /* If there was an error, then return the flag of the */
	   /* attribute that the error occured on                */
	   if (! storage)
	      {
	      *which_error = list->var;
	      *msg = MSFAIL;
	      }

	   list++;
	   }  /* end: while */

	return( OM_S_SUCCESS );

	}   /* HSinquire */


/*--- HSset -----------------------------------------------------------*/

method HSset( IGRlong *msg;
	      IGRlong *which_error;
	      struct var_list *list )

/*
DESCRIPTION
	Set method of the window.  Will look at the arguments in
	list and returned the requested information from the
	hidden line instance data
*/

	{
	IGRboolean	        storage;
	struct HStotal_window_instance *users_struct;

	*msg = MSSUCC;
	storage = TRUE;

	while ( (storage) && (list->var != END_PARAM) )
	   {
	   /* Switch on attribute of the instance data that is being requested */
	   switch( list->var )
	      {
	      case HS_TOTAL_INSTANCE :

	         if ( storage = (list->num_bytes >= sizeof( struct HStotal_window_instance )) )
	            {
	            *(list->bytes_returned) = sizeof( struct HStotal_window_instance );
	            users_struct = (struct HStotal_window_instance *) list->var_ptr;

	            me->disp_flags = users_struct->disp_flags;
	            me->shading_style = users_struct->shading_style;
	            }
	         break;

	      case HS_WIN_FLAGS :

	         if ( storage = (list->num_bytes >= sizeof( IGRuint )) )
	            {
	            *(list->bytes_returned) = sizeof( IGRuint );
	            me->disp_flags = *((IGRuint *)list->var_ptr);
	            }
	         break;

	      case HS_WIN_SHADING_STYLE :

	         if ( storage = (list->num_bytes >= sizeof( IGRuchar )) )
	            {
	            *(list->bytes_returned) = sizeof( IGRuchar );
	            me->shading_style = *((IGRuchar *)list->var_ptr);
	            }
	         break;

	      default :

	         storage = FALSE;
	         break;

	      }  /* end: switch */

	   /* If there was an error, then return the flag of the */
	   /* attribute that the error occured on                */
	   if (!storage)
	      {
	      *which_error = list->var;
	      *msg = MSFAIL;
	      }

	   list++;
	   }  /* end: while */

	return( OM_S_SUCCESS );

	}   /* HSset */

method debug()

/*
DESCRIPTION
	Print out the instance data
*/

	{

	fprintf( stderr, "HSinstance/HSgragad INSTANCE DATA\n" );
	fprintf( stderr, "   WIN-FLAGS: 0x%X\n", me->disp_flags );
	fprintf( stderr, "   SHADING-STYLE: %d\n", me->shading_style );

	return( OM_S_SUCCESS );
	}

end implementation HSinstance;
