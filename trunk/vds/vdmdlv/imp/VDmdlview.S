class specification VDmdlview (0:1) of ASnode;

/*
 Doc :  This is the model volume class. It has view volumes and
	and queries as its parents.
	It's children are usually drawing views.

 History:
 Nov 7 1994    Raju
*/

instance VDmdlview
{

variable char   name[1];
variable char   desc[1];

};


override GRvg;

override NDplace,
	 NDcompute_node;

/*+mi
Method   VDmv_give_name_desc

Abstract
  This method gives name and description of a model view.

Arguments
  IGRlong       *msg		O   return status
  char		*mv_name;	i - name of model view
				    = NULL if not needed
  char		*mv_desc;       i - description of model view
				    = NULL if not needed
Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/

message VDmv_give_name_desc(
 long		*msg;		/* o - Return status            */
 char		*mv_name;      /* i - name of model view
				       = NULL if not needed     */
 char		*mv_desc;      /* i - description of model view
				       = NULL if not needed     */
);

/*+mi
Method   VDmv_set_name_desc

Abstract
  This method gives name and description of a model view.

Arguments
  IGRlong       *msg		O   return status
  char		*mv_name;	i - name of model view
			 	    = NULL if need not set
  char		*mv_desc;       i - description of model view
			 	    = NULL if need not set

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
message VDmv_set_name_desc(
 long            *msg;		/* o - Return status            */
 char            *mv_name;	/* i - name of model view
				       = NULL if need not set   */
 char            *mv_desc;      /* i - description of model view
				       = NULL if need not set   */
);


/*+mi
Method   VDmv_give_vv_qry

Abstract
  This method gives roots of model view ( view volumes and queries)

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
message VDmv_give_vv_qry(
 long		 *msg;		/* o - Return status            */
 int		 *nb_tot_root;	/* o - no. of total roots for model view */
 int		 *nb_root_fnd;	/* o - no. of roots found */
 int		 *num_vvol;	/* o - no. of view vols in model view */
 struct GRid	 **vvol_ids;	/* o - view volume object ids.
				       = NULL, if not needed	      */
 struct GRmd_env **vvol_envs;	/* o - view volume envs.
				       = NULL, if not needed	      */
 char		 ***vvol_names;	/* o - view volume names.
				       = NULL, if not needed	      */
 char		 ***vvol_desc;	/* o - view volume desc.
				       = NULL, if not needed	      */
 int		 *num_qry;	/* o - no. of queries in model view */
 struct GRid	 **qry_ids;	/* o - query ids.
				       = NULL, if not needed	      */
 struct GRmd_env **qry_envs;	/* o - query envs.
				       = NULL, if not needed	      */
 char		 ***qry_names;	/* o - query names.
				       = NULL, if not needed	      */
 char		 ***qry_desc;	/* o - query desc.
				       = NULL, if not needed	      */
);

/*+mi
Method   VDmv_give_objects

Abstract
  This method gives objects having specified relation with model view
solids and which satisfy any of the queries of mv.

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failue
-mi*/
message VDmv_give_objects(
 long			*msg;		/* o - return status	*/
 char			rln_needed;	/* I - relation with model view
					       see vdsollocdef.h	*/
 int			*num_obj;	/* I - no. of output objects */
 struct GRobj_env	**obj_list;	/* I - output object list of ids.
					       = NULL, if not needed	*/
);

/*+mi
Method   VDmv_modify

Abstract
  This method modifies a model view with the given name, desc, view vols and
queries.

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure
-mi*/
message VDmv_modify(
 long		 *msg;		/* o - Return status            */
 char		 *mv_name;	/* i - model view name
				       = NULL, to keep old name */
 char		 *mv_desc;	/* i - model view desc
				       = NULL, to keep old desc */
 int		 num_vvol;	/* i - no. of view vols in model view (new) */
 struct GRid	 *vvol_ids;	/* i - view volume object ids.  */
 struct GRmd_env *vvol_envs;	/* i - view volume envs.
				       = NULL, if active mod_env      */
 int		 num_qry;	/* i - no. of queries in model view (new) */
 struct GRid	 *qry_ids;	/* i - query ids. */
 struct GRmd_env *qry_envs;	/* i - qry envs.
				       = NULL, if active mod_env      */
);

/*+mi
Method   VDmv_display_solid

Abstract
  This method displays boolean solid of the model view.

Arguments
  IGRlong		*msg		O    return status
  enum GRdpmode		*dpmode		I    display mode ( GRhd, GRbdhe )

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

-mi*/
message VDmv_display_solid (
 long		  *msg;
 enum GRdpmode	  *dpmode;
);

end specification VDmdlview;
