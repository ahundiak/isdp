class implementation VLabstract;

#include	<stdio.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"
#include	"grmacros.h"

#define	WORK_DIRNAME	"LOFTwork"

/* ========================================================================== */
IGRlong	VLgetWorkDirectory
(
struct	GRmd_env	*cenv,	/*I	Current environment		*/
	IGRchar		path[],	/*O     Working directory path		*/
struct	GRid		*work	/*O	Working directory object 	*/
)
{
	IGRlong		ret;

	/* Retrieve current osnum absolute path */
        ret = di$give_pathname ( osnum    = cenv->md_id.osnum,
                                 pathname = path );
        if (ret != DIR_S_SUCCESS) {
                di$report_error ( sts     = ret,
                                  comment = "\tdi$give_pathname()");
                goto wrapup;
        }

	/* Build absolute path for working directory */
	sprintf ( path, "%s:IGENOD:%s", path, WORK_DIRNAME);

	/* Search existing working directory */
	work->objid = NULL_OBJID;
	ret = di$translate ( objname = path,
			     p_objid = &work->objid,
			     p_osnum = &work->osnum );
        if ( (work->objid == NULL_OBJID) || (ret != DIR_S_SUCCESS) ) {
		ret = di$mkdir ( dirname = path,
				 osnum   = cenv->md_id.osnum );
	        if (ret != DIR_S_SUCCESS) {
	                di$report_error ( sts     = ret,
	                                  comment = "\tdi$mkdir()");
	                goto wrapup;
	        }
		else {	ret = di$translate ( objname = path,
					     p_objid = &work->objid,
					     p_osnum = &work->osnum );
		        if (ret != DIR_S_SUCCESS) {
		                di$report_error ( sts     = ret,
		                                  comment = "\tdi$translate()");
		                goto wrapup;
		        }
		}
	}

wrapup:
	return (ret);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLchangeTemporaryName
(
struct	GRmd_env	*cenv,	/*I	Current environment	*/
struct	GRid		*obj,	/*I	Object ID		*/
	IGRchar		nam[],	/*I	Name to store		*/
	IGRlong		*msg	/*O	Completion code		*/
)
{
	IGRint		ret;
	IGRchar		wrk[DI_PATH_MAX];
struct	GRid		dir;

	/* Initialize */
	*msg = MSSUCC;

	/* Clean working directory */
	ret = VLgetWorkDirectory ( cenv, wrk, &dir);
	if (ret != DIR_S_SUCCESS) {
		di$report_error ( sts     = ret,
				  comment = "\tVLcleanWorkDirectory()");
		if (ret == DIR_S_SUCCESS)	ret = OM_S_SUCCESS;
		else				ret = MSFAIL;
		goto wrapup;
	}

	/* Change name in working directory */
	sprintf ( wrk, "%s:%s", wrk, nam);
	ret = om$send ( msg = message GRgraphics.GRchgname ( msg, cenv, wrk),
			senderid = NULL_OBJID,
			targetid = obj->objid,
			targetos = obj->osnum );
	as$status ( sts    = ret,
                    msg    = "GRgraphics.GRchgname",
                    test   = (!(ret & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (ret);
}
/* ========================================================================== */

/* ************************************************************************** 
Func :  VLsetSymb_Name_Disp

Desc : 
	This function sets the correct symbology as per the user_defined path,
	and put target object in the directory subsystem as per the userkey.
	Also displays the object, if needed.
		( Respects TransTable and user_path )

History :
	Rama Rao  -  12-09-1995 - Creation
******************************************************************************/
IGRlong	VLsetSymb_Name_Disp (
 IGRlong		*msg,		/*  O - return message 		   */
 IGRchar		*name,		/*  I - name of tar_geom 	   */
 IGRchar		*matchKey,	/*  I - match key of tar_geom.
					        see vluserkey.h	*/
 struct	GRid		*matchId,	/*  I - grid of match obj for 
						tar_geom 		   */
 struct	GRid		*tar_geom,	/*  I - object for which symb, 
						name to be set		   */
 enum	GRdpmode	*dpmode,	/*  I - dpmode if tar_geom to be
					  	displayed. = NULL,if not
					 	needed.			   */
 struct  GRmd_env	*md_env		/*  I - mod env of tar_geom. 
						Needed if dpmode != NULL   */
)
{
IGRint			sts=OM_S_SUCCESS;
struct	GRsymbology	loc_symb;
IGRchar			loc_path[DI_PATH_MAX];


	if ( !msg || !name || !matchKey || !matchId || !tar_geom )
	{
	   *msg = MSINARG;
	   sts =  OM_E_INVARG;
	   goto wrapup;
	}

	*msg = MSSUCC;

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
	sts = om$send ( msg = message GRvg.GRputname
				( msg, loc_path),
			senderid = NULL_OBJID,
			targetid = tar_geom->objid,
			targetos = tar_geom->osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence full name not changed\n");

	/* Change symbology of target object */
	sts = om$send ( msg = message GRvg.GRputsymb ( msg, &loc_symb),
			senderid = NULL_OBJID,
			targetid = tar_geom->objid,
			targetos = tar_geom->osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence symbology not changed\n");

	/* Redisplay target object (if wanted) */
	if (dpmode && md_env )	
		gr$display_object ( object_id = tar_geom,
				    md_env    = md_env,
				    mode      = *dpmode );

wrapup:
	return (sts);
}
/* ************************************************************************** */

end implementation VLabstract;
