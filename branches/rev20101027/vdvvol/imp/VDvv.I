class implementation VDviewvol;

#include "exmacros.h"
#include "OMmacros.h"
#include "nddef.h"
#include "vderrmacros.h"
#include "vdvvoldef.h"

/*+mi
Method   VDvv_give_name_desc

Abstract
  This method gives name and description of a view volume.

Arguments
  IGRlong       *msg		O    return status
  char		*vol_name;	i - name for view vol
			 	    = NULL if not needed
  char		*vol_desc;      i - description of view vol
			 	    = NULL if not needed
Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/

method VDvv_give_name_desc(
 long		*msg;		/* o - Return status            */
 char		*vol_name;      /* i - name for view vol
			 	       = NULL if not needed     */
 char		*vol_desc;      /* i - description of view vol
			 	       = NULL if not needed     */
)
{

   *msg = MSSUCC;

   if ( vol_name )   strcpy ( vol_name, me^^VDviewvol.name );
   if ( vol_desc )   strcpy ( vol_desc, me^^VDviewvol.desc );

   return OM_S_SUCCESS;

}

/*+mi
Method   VDvv_set_name_desc

Abstract
  This method gives name and description of a view volume.

Arguments
  IGRlong       *msg		O    return status
  char		*vol_name;	i - name for view vol
			 	    = NULL if need not set
  char		*vol_desc;      i - description of view vol
			 	    = NULL if need npt set

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
method VDvv_set_name_desc(
 long            *msg;		/* o - Return status            */
 char            *vol_name;	/* i - name for view vol
				       = NULL if need not set   */
 char            *vol_desc;     /* i - description of view vol
				       = NULL if need not set   */
)
{
long sts;
int  len;
char loc_str[256];

   *msg = MSSUCC;

   if ( vol_name )
   {
	strcpy( loc_str, vol_name );
	len = strlen ( loc_str ) + 1;
	if ( len > VD_MAX_VOL_NAME_LEN )
	{
	   len = VD_MAX_VOL_NAME_LEN;
	   loc_str[len-1] = '\0';
	}
	sts = om$vla_set_dimension ( varray = me^^VDviewvol.name,
				     size   = len );
	strcpy ( me^^VDviewvol.name, loc_str );
   }


   if ( vol_desc )
   {
	strcpy( loc_str, vol_desc );
	len = strlen ( loc_str ) + 1;
	if ( len > VD_MAX_VOL_DESC_LEN )
	{
	   len = VD_MAX_VOL_DESC_LEN;
	   loc_str[len-1] = '\0';
	}
	sts = om$vla_set_dimension ( varray = me^^VDviewvol.desc,
				     size   = len );
	strcpy ( me^^VDviewvol.desc, loc_str );
   }

   return OM_S_SUCCESS;

}


/*+mi
Method   VDvv_give_solid

Abstract
  This method gives solid of the view volume

Arguments
  IGRlong		*msg		O    return status
  struct GRid		*solid_id	I -  objid of solid
  struct GRmd_env	*solid_env      I -  mod env of the solid

Return status
  same as OM return status

Return message
  *msg = VD_VVOL_SOLID_DELETED if the parent solid is deleted
  MSSUCC - success
  MSFAIL - failure

-mi*/
method VDvv_give_solid (
 long		  *msg;
 struct GRid	  *solid_id;
 struct GRmd_env  *solid_env;
)
{
long		sts1;
struct GRid	*buffer;
int		count;

	*msg = MSSUCC;

	sts1 = om$send ( msg = message NDnode.NDget_objects (
						ND_ROOT | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&count ),
			 targetid = my_id );
	VDS_ERR_HNDLR("NDnode.NDget_objects", sts1, 1, VD_VERBOSE, wrapup );

	if ( count == 0 )
	{
	   *msg = VD_VVOL_SOLID_DELETED;
	   goto wrapup;
	}

	sts1 = om$send ( msg = message NDnode.ASreturn_go (
					solid_id,
					&(solid_env->md_env.matrix_type),
					solid_env->md_env.matrix ),
			 targetid = buffer[0].objid,
			 targetos = buffer[0].osnum  );
	if ( !(sts1&1) ) goto wrapup;
	VDS_ERR_HNDLR("NDnode.ASreturn_go", sts1, 1, VD_VERBOSE, wrapup );

	__DBGpr_obj ( "solid connected to vvol", *solid_id );

	solid_env->md_id.osnum = solid_id->osnum;
	ex$get_modid ( mod_osnum = solid_id->osnum,
		       mod_id    = &solid_env->md_id.objid );


wrapup:
   return sts1;
}

/*+mi
Method   VDvv_display_solid

Abstract
  This method displays solid of the view volume. If the parent solid
  is deleted then *msg = BD_VOL_SOLID_DELETED.

Arguments
  IGRlong		*msg		O    return status
  enum GRdpmode		*dpmode		I    display mode ( GRhd, GRbdhe )

Return status
  same as OM return status

Return message
  *msg = VD_VVOL_SOLID_DELETED if the parent solid is deleted
  MSSUCC - success
  MSFAIL - failure

-mi*/
method VDvv_display_solid (
 long		  *msg;
 enum GRdpmode	  *dpmode;
)
{

long			sts1;
struct GRid		solid_id,
			mod_id;
struct GRmd_env		solid_env;


	*msg = MSSUCC;
	sts1 = om$send( msg = message VDviewvol.VDvv_give_solid (
					    msg, &solid_id, &solid_env ),
			      targetid = my_id );
	if ( *msg == VD_VVOL_SOLID_DELETED )  goto wrapup;
	VDS_ERR_RPT ( "VDviewvol.VDvv_give_solid", sts1, *msg, VD_VERBOSE );

	ex$get_cur_mod ( id = &mod_id.objid, osnum = &mod_id.osnum );
	sts1 = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&solid_env.md_env.matrix_type,
						solid_env.md_env.matrix,
						dpmode,
						&mod_id ),
			 targetid = solid_id.objid,
			 targetos = solid_id.osnum );
wrapup:
  return sts1;
}

end implementation VDviewvol;

