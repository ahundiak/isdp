/* $Id: VLunwObjgr.I,v 1.4 2001/02/20 01:07:29 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwObjgr.I
 *
 * Description: Overridden graphical methods for Unwrap Object
 *		like GRgetobjinfo, GRdisplay, GRdelete, GRxform,
 *		GRcopy, GRgetrang...
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwObjgr.I,v $
 *      Revision 1.4  2001/02/20 01:07:29  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.3  2001/02/14 20:42:06  ramarao
 *      Modification related to __DBGpr_obj() macro.
 *
 *      Revision 1.2  2001/01/16 20:01:18  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/10/16  22:47:08  pinnacle
# Created: loft/src/unwext/VLunwObjgr.I by rchennup for Service Pack
#
# Revision 1.2  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.3  1998/01/29  17:40:04  pinnacle
# Replaced: src/unwext/VLunwObjgr.I for:  by rchennup for loft
#
# Revision 1.2  1997/10/31  19:26:34  pinnacle
# Replaced: src/unwext/VLunwObjgr.I for:  by rchennup for loft
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 10/28/97  Rama Rao  File Creation
 * 04/09/99  ah        Rama Rao SP08 Fixes
 *************************************************************************/

class implementation VLunwObj;

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
#include "vlmsg.h"
#include "vddrwattr.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "vdsmacros.h"
#include "vldbgmacros.h"

#define vdsDEBUG      1
#define vdserrDEBUG   1

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
	SetProc( VLunwObj_GRgetobjinfo ); Begin

	sprintf( info->type, "Unwrap Extraction -%s ", me->name );

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
	/* If any VLunwFeat objects are connected to this object, delete them */

	IGRint			sts = OM_S_SUCCESS ;
	OM_S_CHANSELECT		to_feat ;
	enum GRdpmode   	mode=GRbehe;

	SetProc( VLunwObj_GRdelete ); Begin

	*rc = MSSUCC ;

	/*
	 * Find the channel name.
	 */
        to_feat.type       = OM_e_name;
        to_feat.u_sel.name = "VLunwObj.to_feat";

        sts =
        _VD_SEND_CHAN(  to_feat, GRgraphics.GRdisplay( rc,
			&md_env->md_env.matrix_type, md_env->md_env.matrix,
			&mode, &md_env->md_id ) );
        __CheckRC( sts, *rc, "GRgraphics.GRdisplay", wrapup ) ;

	sts =
	_VD_SEND_CHAN(	to_feat, GRgraphics.GRdelete(	rc, md_env ));
	__CheckRC( sts, *rc, "GRgraphics.GRdelete", wrapup ) ;

	wrapup :
		sts =
		_VD_SEND_MY(	VLunwObj.VDdeleteIfEmpty( rc, md_env ));
		__CheckRC( sts, *rc, "VLunwObj.VDdeleteIfEmpty", wrapup );

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
	OM_S_CHANSELECT		to_feat ;

	SetProc( VLunwObj_GRdisplay ); Begin

	*msg	= MSSUCC ;

	/*
	 * Find the channel name.
	 */
        to_feat.type       = OM_e_name;
        to_feat.u_sel.name = "VLunwObj.to_feat";

	sts =
	_VD_SEND_CHAN(	to_feat,
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
	IGRint		sts = OM_S_SUCCESS, i, four=4;
	IGRboolean	isRotation=FALSE;
	IGRdouble	toMat[16], tmp_matrix[16];
	VDpartAttr      attr ;
        struct GRid   	obj ;

	SetProc( VLunwObj_GRxform ); Begin

	*msg	= MSSUCC ;


	for( i=0; i<11; ++i )
	{
	  if( i != 3 && i != 7 && i != 11 )
	  {
	   if( i%5 == 0 )
	   {
		if( matrix[i] != 1 ) break;
	   }
	   else
	   {
		if( matrix[i] != 0 ) break;
	   }
	 }
	}

	if( i != 11 ) isRotation = TRUE;

        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) toMat ;
        sts = _VD_SEND_MY( GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	if( isRotation )
	{
	  matrix[3] = 0;
	  matrix[7] = 0;
	  matrix[11] = 0;
	  MAmulmx ( msg, &four, &four, &four, toMat, matrix, tmp_matrix);
	}
	else
	{
	  for( i=0; i<15; ++i )
	  {
	    if( i%4 == 3 ) tmp_matrix[i] = toMat[i]+matrix[i];
	    else tmp_matrix[i] = toMat[i];
	  }
	  tmp_matrix[15] = 1.0;
	}

        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) tmp_matrix ;
        sts = _VD_SEND_MY( GRvg.GRputattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

        sts = om$send ( msg = message ACncpx.GRxform( msg, obj_dsenv, 
					  matrix_type, matrix, newobjid ),
                          mode = OM_e_wrt_message,
                          targetid = my_id );
        __CheckRC( sts, *msg, "GRvg.GRxform", wrapup ) ;

        obj.objid = my_id;
        obj.osnum = OM_Gw_current_OS;

        nd$wait_batch(type     = GR_GEOM_POSTED,
                      nb_obj   = 1,
                      l_object = &obj );
        nd$exec_batch();

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
	IGRint			i, drwCnt, cpCnt;
	struct GRid		ownerId, *cpIds, cpObj, myGRid ;
	struct GRobj_env	*drwObjs ;
	struct GRmd_env		loc_mod_env;
	struct GRmd_env		loc_target_env;

	SetProc( VLunwObj_GRcopy ); Begin

	*msg 		= MSSUCC;
	drwObjs		= NULL ;
	drwCnt		= 0 ;
	cpIds		= NULL ;
	cpCnt		= 0 ;
	loc_mod_env	= *mod_env;
	loc_target_env	= *target_env ;
	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	ownerId.osnum	= target_env->_MD_OS ;

	sts = om$send( msg = message ACcpx.GRcopy( msg, mod_env, 
						   target_env,
						   &ownerId.objid ),
		targetid = my_id,
		mode	 = OM_e_wrt_message );

	if( sts & *msg & 1 ){
	    sts = VLunw_GetChannelObjects( msg, &myGRid, mod_env, 
					   &drwCnt, NULL, &drwObjs );
	    __CheckRC( sts, *msg, "VLunw_GetChannelObjects", wrapup );

	    if( !drwCnt ) goto wrapup;

            /* Copy the objects and connect to owner */
	    if( IF_NULL_OBJID( loc_target_env.md_id.objid ))
                   loc_target_env._MD_ID = loc_mod_env._MD_ID ;

	    if( !(cpIds = _MALLOC( drwCnt, struct GRid )))
		vd_$mem_fail();
		
	    for( i=0 ; i<drwCnt ; i++ ){
                /*  Copy the component  */
		sts = vd_$grCopy( msg	= msg,
				  frEnv	= &drwObjs[i].mod_env,
				  frObj	= &drwObjs[i]._grid,
				  toEnv	= &loc_target_env,
				  toObj	= &cpObj );
		if (sts & *msg & 1)   cpIds[cpCnt++] = cpObj ;
	    }

	    /* Connect the copy of the component to the new owner */
	    sts = VLunwMgr_ConnectObjectsToVw( msg, &loc_target_env,
					       &ownerId, cpCnt, cpIds );
	    __CheckRC( sts, *msg, "VLunwMgr_ConnectObjectsToVw", wrapup );
        }

wrapup:
	if (!( sts & *msg & 1)){
		/* Delete the owner and all components */
		vd_$bulk_delete(count	= cpCnt,
				theEnv	= &loc_target_env,
				grids	= cpIds );

		sts = _VD_SEND_OBJ(   ownerId,
				GRgraphics.GRdelete( msg, target_env));
		ownerId.objid = NULL_OBJID ;
		*msg = MSFAIL ;
	}

	_FREE( cpIds );
	_FREE( drwObjs );
          
	*new_objid = ownerId.objid;
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
	OM_S_CHANSELECT   	chansel;

	SetProc( VLunwObj_GRgetrang ); Begin

        sts = GRget_to_comp_info( &chansel,
                                  OM_Gw_current_OS,
                                  my_id,
                                  &count );
        if(!(sts&1)) return sts;

        sts = om$send(msg     = message GRgraphics.GRgetrang(
                                                msg, matrix_type, matrix,
                                                world, range ),
                       p_chanselect = &chansel,
                       from = 0,
                       to = 0      );
	return( sts );

#if 0
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

	sts = VLunw_GetChannelObjects(	msg,
					&myGRid,
					NULL,
					&count,
					&grids,
					NULL );
	__CheckRC( sts, *msg, "VLunw_GetChannelObjects", wrapup );
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
#endif
}

method   VLgetInst_devSrf(  struct IGRbsp_surface       **dev_srf )
{
	  IGRlong rc, sts=OM_S_SUCCESS;

          /* Malloc the dev->devsrf structure and copy me->dev.devsrf */
          BSallocsf (     (IGRshort)me->dev.devsrf->u_order,
                          (IGRshort)me->dev.devsrf->v_order,
                          (IGRlong)me->dev.devsrf->u_num_poles,
                          (IGRlong)me->dev.devsrf->v_num_poles,
                          (IGRboolean ) me->dev.devsrf->rational,
                          (IGRshort)me->dev.devsrf->num_boundaries,
                          dev_srf, &rc);
          if (rc != BSSUCC) {
             printf("Error in VLgetInst_devSrf()\n");
             printf("BSallocsf on <struct IGRbsp_surface *> returns %d\n", rc);
	     sts = OM_E_ABORT;
             goto wrapup;
          }

          BSsf_copy( &rc, me->dev.devsrf, *dev_srf );
          if (rc != BSSUCC) {
             printf("Error in VLgetInst_devSrf()\n");
	     sts = OM_E_ABORT;
             goto wrapup;
          }
	  sts = OM_S_SUCCESS;
wrapup:
	return sts;
}

end implementation VLunwObj;
 
