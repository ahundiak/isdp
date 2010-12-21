class specification VDCmdMngMV (1:0) of CEO_LOCATE;



#define  FP_MGR		me^^CEO.forms[0].form_ptr
#define  FP_MV		me^^CEO.forms[1].form_ptr

#include "growner.h"
#include "vdvvoldef.h"
#include "vdmdlvwdef.h"

#define  VD_INIT_DIM	10


instance VDCmdMngMV
{

 struct GRid		MdlvwMgr;

 int		      	num_mdlvw;
 variable struct GRid	mdlvw_ids[VD_INIT_DIM];
 variable struct GRmd_env  mdlvw_envs[VD_INIT_DIM];
 variable char		mdlvw_names[VD_INIT_DIM][VD_MAX_MV_NAME_LEN];
 variable char		mdlvw_desc[VD_INIT_DIM][VD_MAX_MV_DESC_LEN];
 variable char		mdlvw_used[VD_INIT_DIM];

 int			mod_mv_nb;
 char			mod_mv_name[VD_MAX_MV_NAME_LEN];
 int			hilited_mv_nb;

 int			nb_tot_root;
				/* o - no. of total roots for model view */
 int			nb_root_fnd;
				/* o - no. of roots found */
 int		 	num_vvol;
				/* o - no. of view vols in model view */
 variable struct GRid	vvol_ids[VD_INIT_DIM];
				/* o - view volume object ids.
				       = NULL, if not needed	      */
 variable struct GRmd_env vvol_envs[VD_INIT_DIM];
				/* o - view volume envs.
				       = NULL, if not needed	      */
 variable char		vvol_names[VD_INIT_DIM][VD_MAX_VOL_NAME_LEN];
				/* o - view volume names.
				       = NULL, if not needed	      */
 variable char		vvol_desc[VD_INIT_DIM][VD_MAX_VOL_DESC_LEN];
				/* o - view volume desc.
				       = NULL, if not needed	      */
 int			num_qry;
				/* o - no. of queries in model view */
 variable struct GRid	qry_ids[VD_INIT_DIM];
				/* o - query ids.
				       = NULL, if not needed	      */
 variable struct GRmd_env qry_envs[VD_INIT_DIM];
				/* o - query envs.
				       = NULL, if not needed	      */
 variable char		qry_names[VD_INIT_DIM][VD_MAX_QRY_NAME_LEN];
				/* o - query names.
				       = NULL, if not needed	      */
 variable char		qry_desc[VD_INIT_DIM][VD_MAX_QRY_DESC_LEN];
				/* o - query desc.
				       = NULL, if not needed	      */
 int			nbVVcreated;
				/* - No. of VVOLs created by locating solid */
 variable struct GRid	createdVVlist[0];

 int			last_sel_mdlv;   /* for display purposes only */
};


override form_notification;

message check_and_create_a_view_vol ( long * sts );

message get_mdlvw_list ( long * sts );

message set_manag_form ( long * sts );

message clean_up ( long * sts );

message set_form_pos ( long * sts );

message save_form_pos ( long * sts );

message create_mv_mgr_if_not_created ( long * sts );

message init_instance ( long * sts );

message set_instance_dimension ( int  nb_vvol;  int  nb_qry );

message copy_to_instance (
 int		 num_vvol;
 struct GRid	 *vvol_ids;
 struct GRmd_env *vvol_envs;
 char		 **vvol_names;
 char		 **vvol_desc;
 int		 num_qry;
 struct GRid	 *qry_ids;
 struct GRmd_env *qry_envs;
 char		 **qry_names;
 char		 **qry_desc;
);

message set_crt_mdf_list_fld ( long * sts );

message add_to_vv_qry_list (
 char		 vv_qry_flag;
 struct GRid	 *objid;
 struct GRmd_env *objenv;
 char		 *name;
 char		 *desc
);

message delete_from_vv_qry_list (
 char		 vv_qry_flag;
 int		 vv_qry_ind;
);

message enable_crt_gadgets ( long * sts );

message add_to_created_vvlist ( struct GRid new_vvol );

message delete_created_vvs ( long * sts );

end specification VDCmdMngMV;
