/* ************************************************************************** */
/*	File :		<VLpathMethod.I>				      */
/*									      */
/*	Authors :	Ludovic Lecorvec (COC shipbuilding)		      */
/*			Marc Fournier (COC shipbuilding)		      */
/*									      */
/*	History :	12-Jan-1993	creation of <VLlocMethod.I>	      */
/*			05-Apr-1995	group methods in <VLpathMethod.I>     */
/*									      */
/*	These <VLlocate> methods manage the VDS path and symbology retrieval  */
/*	and the automatic naming of macro occurences.			      */
/* ************************************************************************** */

class implementation VLlocateCmd;

#include	"vlprototype.h"
#include	"AS_status.h"
#include	"grmacros.h"

from	GRvg		import	GRchgname, GRputsymb;

/* ************************************************************************** */
method	VLgetSymbDirName (		IGRlong		*msg;
					IGRchar		*matchKey;
				struct	GRid		*matchId;
					IGRchar		*com_name;
				struct	GRsymbology	*tar_symb;
					IGRchar		*tar_path;
					IGRchar		*occ_name	)
{
	IGRint		sts=OM_S_SUCCESS;
struct	GRsymbology	loc_symb;
	IGRchar		loc_path[DI_PATH_MAX];

	/* Initialize */
	*msg = MSFAIL;
	if (tar_path)	tar_path[0] = '\0';
	if (occ_name)	occ_name[0] = '\0';

	/* Extract symbology and path from EMS directories */
	loc_path[0] = '\0';
	sts = VDSget_dir_and_symb ( msg, matchId, matchKey, NULL, loc_path,
				    &loc_symb.level, &loc_symb.display_attr );
	as$status ( sts    = sts,
                    msg    = "VDSget_dir_and_symb()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Generate an occurence name iv EMS directories */
	if ( (com_name) && (occ_name) ) {
		sts = om$send ( msg = message VLlocateCmd.VLnameOccurence
					( msg, loc_path, com_name, occ_name),
				targetid = my_id );
		as$status ( sts    = sts,
	                    msg    = "VLlocateCmd.VLnameOccurence",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	if (tar_symb)	*tar_symb   = loc_symb;
	if (tar_path)	strcpy ( tar_path, loc_path);
	if (!((*msg) & 0x00000001)) { *msg = MSFAIL; sts  = OM_W_ABORT; }
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
method	VLsetSymbNameDisp (		IGRlong		*msg;
					IGRchar		*name;
					IGRchar		*matchKey;
				struct	GRid		*matchId;
				struct	GRid		tar_geom;
				enum	GRdpmode	*dpmode	)
{
	IGRint		sts=OM_S_SUCCESS;
struct	GRsymbology	loc_symb;
	IGRchar		loc_path[DI_PATH_MAX];

	/* Extract symbology and path from EMS directories */
	loc_path[0] = '\0';
	sts = VDSget_dir_and_symb ( msg, matchId, matchKey, NULL, loc_path,
				    &loc_symb.level, &loc_symb.display_attr );
	as$status ( sts    = sts,
                    msg    = "VDSget_dir_and_symb()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Change name of target object */
	sprintf ( loc_path, "%s:%s", loc_path, name);
	sts = om$send ( msg = message GRvg.GRchgname
				( msg, &me->Current, loc_path),
			targetid = tar_geom.objid,
			targetos = tar_geom.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence full name not changed\n");

	/* Change symbology of target object */
	sts = om$send ( msg = message GRvg.GRputsymb ( msg, &loc_symb),
			targetid = tar_geom.objid,
			targetos = tar_geom.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence symbology not changed\n");

	/* Redisplay target object (if wanted) */
	if (dpmode)	gr$display_object ( object_id = &tar_geom,
					    md_env    = &me->Current,
					    mode      = *dpmode );

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
method	VLnameOccurence (	IGRlong	*msg;
				IGRchar	*tar_path, *com_name, *occ_name	)
{
//        VLoccNaming ( tar_path, com_name, occ_name, msg);

         VLoccNaming1 ( tar_path, com_name, occ_name, msg);

return  OM_S_SUCCESS;
}
/* ************************************************************************** */

/* ************************************************************************** */
method	VLsymbNameDir (		IGRlong		*msg;
				IGRchar		*matchKey;
			struct	GRid		*matchId;
				IGRchar		*com_name;
			struct	GRsymbology	*tar_symb;
				IGRchar		*tar_path;
				IGRchar		*occ_name;
			struct	GRid		tar_geom;
			enum	GRdpmode	*dpmode	)
{
	IGRint		sts=OM_S_SUCCESS;
struct	GRsymbology	loc_symb;
	IGRchar		loc_path[DI_PATH_MAX];

	/* Extract symbology and path from EMS directories */
	loc_path[0] = '\0';
	sts = VDSget_dir_and_symb ( msg, matchId, matchKey, NULL, loc_path,
				    &loc_symb.level, &loc_symb.display_attr );
	as$status ( sts    = sts,
                    msg    = "VDSget_dir_and_symb()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Generate an occurence name iv EMS directories */
	if ( (com_name) && (occ_name) ) {
		sts = om$send ( msg = message VLlocateCmd.VLnameOccurence
					( msg, loc_path, com_name, occ_name),
				targetid = my_id );
		as$status ( sts    = sts,
	                    msg    = "VLlocateCmd.VLnameOccurence",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Change name of target object */
	sprintf ( loc_path, "%s:%s", loc_path, occ_name);
	sts = om$send ( msg = message GRvg.GRchgname
				( msg, &me->Current, loc_path),
			targetid = tar_geom.objid,
			targetos = tar_geom.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence full name not changed\n");

	/* Change symbology of target object */
	sts = om$send ( msg = message GRvg.GRputsymb ( msg, &loc_symb),
			targetid = tar_geom.objid,
			targetos = tar_geom.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence symbology not changed\n");

	/* Redisplay target object (if wanted) */
	if (dpmode)	gr$display_object ( object_id = &tar_geom,
					    md_env    = &me->Current,
					    mode      = *dpmode );

wrapup:
	if (tar_symb)	*tar_symb   = loc_symb;
	if (tar_path)	strcpy ( tar_path, loc_path);
	if (!((*msg) & 0x00000001)) { *msg = MSFAIL; sts  = OM_W_ABORT; }
	return (sts);
}
/* ************************************************************************** */

end implementation VLlocateCmd;
