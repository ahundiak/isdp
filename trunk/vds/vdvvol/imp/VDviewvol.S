class specification VDviewvol (0:1) of ASnode;

/*
 Doc :  This is the view volume class. It is a child of solid.
	It's children are usually model views.

 History:
 Nov 5 1994    Raju
*/

instance VDviewvol
{

variable char   name[1];
variable char   desc[1];

};


override GRvg;

override NDcompute_node,  NDplace, NDparent_deleted;

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

message VDvv_give_name_desc(
 long		*msg;		/* o - Return status            */
 char		*vol_name;      /* i - name for view vol
			 	       = NULL if not needed     */
 char		*vol_desc;      /* i - description of view vol
			 	       = NULL if not needed     */
);

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
message VDvv_set_name_desc(
 long            *msg;		/* o - Return status            */
 char            *vol_name;	/* i - name for view vol
				       = NULL if need not set   */
 char            *vol_desc;     /* i - description of view vol
				       = NULL if need not set   */
);


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
message VDvv_give_solid (
 long		  *msg;
 struct GRid	  *solid_id;
 struct GRmd_env  *solid_env;
);

/*+mi
Method   VDvv_display_solid

Abstract
  This method displays solid of the view volume. If the parent solid
  is deleted then *msg = VD_VOL_SOLID_DELETED.

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
message VDvv_display_solid (
 long		  *msg;
 enum GRdpmode	  *dpmode;
);


end specification VDviewvol;

