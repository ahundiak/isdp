/* $Id: VDdrw2dVwgr.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw2dVwi.I
 *
 * Description:
 *
 *      This file implements the methods for the View Area control object,
 *	which concatenates all 2d visualization objects.
 *
 * Dependencies:
 *      VDdrw2dVw.S
 *
 * History:
 *      06/06/94        adz		Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrw2dVw;

/*
%safe
#include <math.h>
%endsafe
*/

#include <math.h>
#include <values.h>
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "refdef.h"
#include "madef.h"
#include "msdef.h"
#include "gocmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "asbox.h"
#include "dp.h"
#include "AS_debug.h"
#include "grerr.h"
#include "grgsdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"
#include "EMSmsgdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "AS_status.h"

#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"
#include "vdsmacros.h"

extern	GRclassid	OPP_Gexp_class_id,
			OPP_Gtext_exp_class_id;

from	expression	import	modify;
from	VDmdlview	import	VDmv_give_name_desc;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the main surface when it
	is located (status field).

  Arguments

      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	/*
	 * layout:	Occurence Name - Design File.
	 */
	SetProc( VDdrw2dVw_GRgetobjinfo ); Begin

	sprintf( info->type, "3d View-Note -%s ", me->name );

	*msg = MSSUCC;
	End ;
	return(OM_S_SUCCESS);
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRdelete from GRgraphics

  Abstract

	Delete the model set object and all the linked section objects.
	This will automatically delete all the volume cut members.

  Arguments

      IGRlong		*msg             O   	completion code
      struct GRmd_env	*md_env          I	structure for environment

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails



 -------------------------------------------------------------------------
-mo*/

method GRdelete(IGRlong *rc ; struct GRmd_env *md_env)
{
	/*
	 * If any VDdrw2d objects are connected to this
	 * object, delete them.
	 */
	IGRint			sts = OM_S_SUCCESS ;
	OM_S_CHANSELECT		*to_drw ;

	SetProc( VDdrw2dVw_GRdelete ); Begin

	*rc = MSSUCC ;

	/*
	 * Find the channel name.
	 */
        sts = VDdrw_GetToDrwChannel( VD_O_drw2d, &to_drw );
	__CheckRC( sts, 1, "VDdrw_GetToDrwChannel", wrapup );

	sts =
	_VD_SEND_CHAN(	*to_drw, GRgraphics.GRdelete(	rc, md_env ));
	__CheckRC( sts, *rc, "GRgraphics.GRdelete", wrapup ) ;

	wrapup :
		sts =
		_VD_SEND_MY(	VDdrw2dVw.VDdeleteIfEmpty( rc, md_env ));
		__CheckRC( sts, *rc, "VDdrw2dVw.VDdeleteIfEmpty", wrapup );

		End ;
		return	sts ;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRdisplay from GRgraphics

  Abstract

	Display the model set objects.

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

method GRdisplay(	IGRlong		*msg;
			IGRshort	*type;
			IGRmatrix	matrix;
			enum GRdpmode	*mode;
			struct GRid	*display_info )
{
	IGRint			sts = OM_S_SUCCESS ;
	OM_S_CHANSELECT		*to_drw ;

	SetProc( VDdrw2dVw_GRdisplay ); Begin

	*msg	= MSSUCC ;

	/*
	 * Find the channel name.
	 */
        sts = VDdrw_GetToDrwChannel( VD_O_drw2d, &to_drw );
	__CheckRC( sts, 1, "VDdrw_GetToDrwChannel", wrapup );

	sts =
	_VD_SEND_CHAN(	*to_drw,
			GRgraphics.GRdisplay(	msg, type, matrix,
						mode, display_info ));
	__CheckRC( sts, *msg, "GRgraphics.GRdisplay", wrapup ) ;

	wrapup :

		sts =
		om$send(msg	= message ASnode.GRdisplay(
						msg, type, matrix,
						mode, display_info ),
			targetid = my_id,
			mode 	= OM_e_wrt_message );

		End ;
		return	sts ;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        GRxform from GRvg

  Abstract
        This method moves the connect objects.
 -------------------------------------------------------------------------
-mo*/


method GRxform(	IGRlong			*msg;
		struct GRmd_env		*obj_dsenv; 
		IGRshort		*matrix_type;
		IGRmatrix		matrix;
		GRobjid			*newobjid )
{
	IGRint		sts = OM_S_SUCCESS;
	OM_S_CHANSELECT	*to_drw ;

	SetProc( VDdrw2dVw_GRxform ); Begin

	/*
	 *  xform on to to_2d channel
	 */
	*msg	= MSSUCC ;

	sts = VDdrw_GetToDrwChannel( VD_O_drw2d, &to_drw );

	sts =
	_VD_SEND_CHAN(	*to_drw,
			GRvg.GRxform(	msg, obj_dsenv, matrix_type,
						matrix, newobjid ));
	__CheckRC( sts, *msg, "GRvg.GRxform", wrapup ) ;

	__DBGpr_com(" Call NDnode.NDchange_node "); 

	sts =
	_VD_SEND_MY( NDnode.NDchange_node( obj_dsenv ));
	__CheckRC( sts, 1, "GRvg.GRxform", wrapup ) ;

wrapup:
	End
	return OM_S_SUCCESS;
}


/*
Name
    GRcopy

Description
    This method will  send a message to each of its components to copy
    and then connect themselves to the new owner.  The new owner id will
    be returned in newobjid.

    *msg         long          Completion code
    *mod_env     struct GRmd_env  Module environment structure 
    *target_env  struct GRmd_env  The target environment structure 
    *newobjid    GRobjid          Objid of the transformed object

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
 */

method GRcopy(	IGRlong			*msg; 
		struct GRmd_env		*mod_env;
		struct GRmd_env		*target_env; 
		GRobjid			*new_objid )
{
	IGRint			sts = OM_S_SUCCESS ;
	IGRint			i,
				drwCnt,
				cpCnt;
	struct GRid		ownerId,
				*cpIds,
				cpObj,
				myGRid ;
	struct GRobj_env	*drwObjs ;
	struct GRmd_env		loc_mod_env;
	struct GRmd_env		loc_target_env;

	SetProc( VDdrw2dVw_GRcopy ); Begin

	*msg = MSSUCC;

	drwObjs	= NULL ;
	drwCnt	= 0 ;

	cpIds	= NULL ;
	cpCnt	= 0 ;

	loc_mod_env	= *mod_env;
	loc_target_env	= *target_env ;

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	ownerId.osnum	= target_env->_MD_OS ;
	sts =
	om$send(msg	= message ACcpx.GRcopy( msg, mod_env, 
						target_env,
						&ownerId.objid ),
		targetid = my_id,
		mode	= OM_e_wrt_message );

	if( sts & *msg & 1 ){

	    sts =
	    VDdrw_GetChannelObjects( msg, &myGRid, mod_env, VD_O_drw2dObj,
					&drwCnt, NULL, &drwObjs );
	    __CheckRC( sts, *msg, "VDdrw_GetChannelObjects", wrapup );

            /*
             *  Get the local context of the elements.  It is neccessary
             *  to get the context of the new owner first so that when
             *  the old owner gets it context it will clear the abstract
             *  cache.
             */
/******
            sts =
	    _VD_SEND_OBJ(	ownerId,
				GRowner.GRget_context(msg,
                                                     target_env, 
                                                     &local_target_env ));
          
            sts =
	    _VD_SEND_MY(	GRowner.GRget_context(msg, mod_env, 
                                                     &local_mod_env ));
 
 *******/
            /*
             * Copy the objects and connect to owner. 
             */
	    if( IF_NULL_OBJID( loc_target_env.md_id.objid ))
                   loc_target_env._MD_ID = loc_mod_env._MD_ID ;

	    if( !(cpIds = _MALLOC( drwCnt, struct GRid )))
		vd_$mem_fail();
		
	    for( i=0 ; i<drwCnt ; i++ ){

               /*
                *  Copy the component
                */
		sts =
		vd_$grCopy(	msg	= msg,
				frEnv	= &drwObjs[i].mod_env,
				frObj	= &drwObjs[i]._grid,
				toEnv	= &loc_target_env,
				toObj	= &cpObj );

		if (sts & *msg & 1){

		    cpIds[cpCnt++] = cpObj ;
		}
	    }

	    /*
             *  Connect the copy of the component to the new owner.
             */
	    sts =
	    VDdrwMgr_ConnectObjectsToVw( msg, &loc_target_env, VD_O_drw2d,
					 &ownerId, cpCnt, cpIds );
	    __CheckRC( sts, *msg, "VDdrwMgr_ConnectObjectsToVw", wrapup );
        }

	wrapup:

		if (!( sts & *msg & 1)){

			/*
			 *  Delete the owner and all components.
			 */
			vd_$bulk_delete(count	= cpCnt,
					theEnv	= &loc_target_env,
					grids	= cpIds );

			sts =
			_VD_SEND_OBJ(	ownerId,
					GRgraphics.GRdelete( msg, target_env));
			ownerId.objid = NULL_OBJID ;
			*msg = MSFAIL ;
		}

		_FREE( cpIds );
		_FREE( drwObjs );
          
		*new_objid = ownerId.objid;

/**
		GR_NOTIFY_LISTENERS(msg, &om_msg, GR_COPIED);
 **/

		return( sts );
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetrang from GRgraphics

  Abstract

	Getrange of all objects in View.

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

method GRgetrang(	IGRlong		*msg; 
			IGRshort	*matrix_type;
			IGRmatrix	matrix; 
			IGRboolean	*world; 
			GRrange		range ){

	IGRlong			sts = OM_S_SUCCESS ;
	IGRint			i, j;
	IGRint			count;
	IGRshort		local_mx_type,world_mx_type;
	IGRdouble		*world_mx;
	IGRmatrix		local_matrix,world_mx_buffer;
	GRrange			go_range;
	struct	GRid		myGRid ,
				*grids ;
	int			range_found ;

	SetProc( VDdrw2dVw_GRgetrang ); Begin

	*msg	= MSSUCC ;
	count	= 0 ;
	grids	= NULL ;

	range_found = 0;

	/*
	 * initialize matrix_type and matrix if not in the arguments 
	 */

	if( *world ){
		world_mx = matrix;
		world_mx_type = *matrix_type;
	}
	else{

		MAidmx(msg, world_mx_buffer);
		world_mx = world_mx_buffer;
		world_mx_type = MAIDMX;
	}

	/* 
	 *  Get the number of objects on my channel.
	 */
	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	sts = VDdrw_GetChannelObjects(	msg,
					&myGRid,
					NULL,
					VD_O_drw2d,
					&count,
					&grids,
					NULL );
	__CheckRC( sts, *msg, "VDdrw_GetChannelObjects", wrapup );
	if( ! count || ! grids ) goto wrapup ;
						
	/*
	 *  Get the component matrix.
	 */
	sts =
	_VD_SEND_MY( GRowner.GRget_matrix(	msg, 
                                               &world_mx_type,
                                                world_mx, 
                                               &local_mx_type, 
                                                local_matrix ));
	__CheckRC( sts, *msg, "GRowner.GRget_matrix", wrapup );

	/* 
	 * Cummulate component ranges
	 */
	for( i=0 ; i<count; ++i ){

		/*
	 	 *  Get the range of the object.
		 */
		sts =
		_VD_SEND_OBJ(	grids[i],
				GRvg.GRgetrang(msg, &local_mx_type,
                                                     local_matrix, 
                                                     world, 
                                                     go_range));

		if ((sts & *msg & 1) && (sts != OM_I_CHAN_EMPTY) ){
		  if( range_found ) 
		    GRaccumulate_range( msg, go_range, range );
		  else{
		    range_found = 1;
		    for( j=0; j<6; j++ ) range[j] = go_range[j];
		  }
		} 
	}

        __DBGpr_vec( "Min of range #0", range    ) ;
        __DBGpr_vec( "Max of range #0", range +3 ) ;

	wrapup :

		*msg	= MSSUCC;
		if( ! range_found ){
			*msg = MSFAIL;
			for (i=0;i<6;i++) range[i] = 0.0;
		}
		_FREE( grids );
		End ;
		return( OM_S_SUCCESS );
}

/*
  -------------------------------------------------------------------------
 */

end implementation VDdrw2dVw;
 
