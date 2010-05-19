class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "griodef.h"
#include "UOMdef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "UOMmacros.h"
#include "nddef.h"

#include "VDPdef.h"
#include "VDPzone.h"

#include "vdsollocdef.h"

extern GRclassid 	OPP_VDPZoneObj_class_id;

from NDnode import ASreturn_go,NDget_objects;

IGRint	VDSelectElementsinVolume (
	IGRlong			*msg,
	struct GRid		ObjectId,
	IGRint			VolumeType,
	IGRdouble		offset,
	struct GRid		*WindowId,
	GRobjid			CmdId,
	OM_S_CHANSELECT		*locate_chansel,
	struct GRmd_env		ModInfo,
	IGRint			*nbLocObjs,
	struct GRobj_env	**LocObjs )
{
    IGRlong		status = OM_S_SUCCESS;
    struct GRid		solbool,VolumeId;
    struct GRmd_env	solbool_env, tmp_env;
    struct GRobj_env	offset_solid;
    GRclassid		ClassId;
    IGRint		count=0;


    SetProc( VDSelectElementsinVolume ); Begin

    *msg = MSSUCC;
    
    if ( ObjectId.objid == NULL_OBJID )
    {
	status = OM_E_INVARG;
	goto wrapup;
    }

    om$get_classid ( objid = ObjectId.objid,
		     osnum = ObjectId.osnum,
		     p_classid = &ClassId );
    if (om$is_ancestry_valid
			( subclassid = ClassId,
			  superclassid = OPP_VDPZoneObj_class_id )
		== OM_S_SUCCESS )
    {
	VolumeId.objid = NULL_OBJID;
	status =
	_VD_SEND_OBJN( ObjectId, NDnode.NDget_objects(  ND_ROOT,
					&VolumeId,
					1,
					NULL,
					0,
					OM_K_MAXINT,
					&count ) );
	__CheckRC( status, 1, "message NDnode.NDget_objects", wrapup );

	__DBGpr_obj ( "Graphic Object", VolumeId );

	switch ( VolumeType )
	{
	case VDP_MDLVW_ZONE :
	    status = _VD_SEND_OBJN ( VolumeId, NDnode.ASreturn_go (
					&solbool,
					&(solbool_env.md_env.matrix_type),
					solbool_env.md_env.matrix )) ;
	    __CheckRC ( status, *msg, "NDnode.ASreturn_go", wrapup );


	    break;
	default :
	    break;
	}
    }
    else
	VolumeId = ObjectId;

    solbool_env = ModInfo;

    if ( offset > 0.0001 && offset < -0.0001 ) 
    /* Just an arbitrary offset */
    {
	IGRchar			type[UOM_K_MAX_TYPE], name[20];
	IGRshort		flag = 0, num_defaults;
	GRIOalias_name  	default_units[3];
	IGRdouble		db_offset, chtol;
	IGRint			sizbuf=0, RetSize;
	struct GRvg_construct   cst;
	struct IGRdisplay       disp;
	GRobjid			off_solid;


	/* get default units */
	strcpy ( type, GRIO_DISTANCE );
	status = 
	co$get_default_units (  msg 		= msg,
				table_name	= type,
				osnum		= ModInfo.md_id.osnum,
				flag		= &flag,
				num_defaults	= &num_defaults,
				default_units	= default_units );
	CheckRC ( status, *msg );

	strcpy( name, default_units[0] );


	/* convert to database units */
	status = 
	uom$cvt_value_to_value( msg			= msg,
				unit_type		= type,
				osnum            	= ModInfo.md_id.osnum,
				alias_to_cvt_from  	= name,
				alias_to_cvt_to		= NULL,
				num_vals 		= 1,
				values_in 		= &offset,
				values_out		= &db_offset);

	/* construct an offset solid outside range tree */
	sizbuf = sizeof ( IGRshort );
	gr$get_active_layer (   msg	= msg,
				sizbuf	= &sizbuf,
				buffer	= &(cst.level),
				nret	= &RetSize );

	sizbuf = sizeof ( struct IGRdisplay );
	gr$get_active_display ( msg    = msg,
				sizbuf = &sizbuf,
				buffer = &disp,
				nret   = &RetSize );

	tmp_env = ModInfo;
	tmp_env.md_id.objid = NULL_OBJID;

	cst.msg		= msg;
	cst.env_info	= &tmp_env;
	cst.display	= &disp;
	cst.geometry	= NULL;
	cst.newflag	= FALSE;
	cst.properties	= GRIS_DISPLAYABLE | GRIS_LOCATABLE;
	cst.class_attr	= NULL;
	cst.name	= NULL;

     /*
      * construct a solid outside range tree which is an offset solid by
      * given offset.
      */
	status = VDoffsetSolid( msg, &solbool, &solbool_env, &cst, db_offset,
				&off_solid );
	__CheckRC( status, *msg, "VDoffsetSolid", wrapup );

	if ( status & *msg & 1 )
	{
	    offset_solid.obj_id.objid  = off_solid;
	    offset_solid.obj_id.osnum  = tmp_env.md_id.osnum;
	    offset_solid.mod_env       = tmp_env;
	}
	else
	{
	    printf("WARNING : offsetting solid failed; using original solid\n");
	    offset_solid.obj_id  = solbool;
	    offset_solid.mod_env = solbool_env;
	}
    }
    else
    {
	offset_solid.obj_id = VolumeId;
	offset_solid.mod_env = ModInfo;
    }

    /* Locate elements in the solid */
    status = VDlocateWithSolid2( msg,
				1,
				&offset_solid.obj_id,
				&offset_solid.mod_env,
				0,
				NULL,
				VD_EL_INSIDE_OVERLAP,
				VD_LIST_OF_OBJS,
				WindowId,
				"Processing",
				locate_chansel,
				CmdId,
				nbLocObjs,
				LocObjs );
    __CheckRC( status, *msg, "VDlocateWithSolid2", wrapup );

    __DBGpr_int ( "Number of Objects ", *nbLocObjs );

wrapup:
    End
    return status;

}

end implementation Root;
