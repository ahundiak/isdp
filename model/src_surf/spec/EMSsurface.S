/*
  ABSTRACT

  This class contains message declarations which are common to all
  surfaces whether they are composites, or just simple surfaces.  It
  is meant to be an abstract class which provides a common target for
  message sends to surfaces.


  HISTORY

  01/20/93  sam   Added additional arguments to EMoffset .
  01/06/93  AIC   Moved EMvalidate to GRgraphics.
  07/30/91  mrm   Added natural_normal arg to EMintsurf_saveside
  07/25/91  pp    Moved EMtranslate_id_key message to EMScreator and
                  subclassing from the same
  06/26/91  Inasu Added new message EMlmnewround().
  06/03/91   mrm  Added state_object parameter to EMimpose_boundaries
  10-JUN-91  SCW  Added EMcreator_is_undoing message.
  11/22/89   RC   Added arguments to message EMtrim_a_surface.
  Nov 06 89  gupta added message EMcompute_density.
  17-Oct-89   SM  Added EManalyzeIntfAlongXsec message.
  09/18/89 gupta  Made changes to massprop method arguments
  08/25/89    RC  Changed EMwrite_to_envelope_file to
                  EMcreate_envelope_and_igds_files.
  08-10-89    PP  Modified arguments to EMgenerate_offset_surface to 
                  incorporate passing in of the module_environment instead
                  of just matrix and matrix type.
  08-01-89    RC  Added message EMtrim_a_surface.
  06-Jul-89   SM  Added bdry_options and sf_options arguments to EMintcopy.
   		bdry_options : passed on to EMSboundary.EMintcopy.
  		sf_options : Meant for EMSsurface.EMintcopy. Currently ignored.
  15-Jun-89   SM	Added message EMcompressed_copy. 
  06-Jun-89   SM  Added message EMputLsIfNotThere, so as not to have to
  		go through the following mundane sequence -
  		Check classid.
  		if subbs type, check if loopset exists.
  		if not put natural ls.
  		The EMSsurface implementaion simply returns EMS_I_InvalidSend.
  02-Jun-89   SM  Added message EManalyzeIntf.
  05/25/89    RC  Added message EMwrite_to_envelope_file
  03/03/89    DLB Added parameter to EMgetSurfsOfPrim to indicate which
                  of the surfaces are active in the tree.
  28-Feb-89   SM  Added curve_buffs argument to EMimpose_boundaries. This will
  		help applications which otherwise would have to construct
  		curve objects unnecessarily.
  19 Dec 1988 jBk Added messages EMgetContiguousAreas and
                  EMgetLoops.
  12/01/88    DLB Added EMgetCuttingPrims message.
  11/22/88    RC  Added EMget_mdsfs_info and EMcross_section2 messages
  11/20/88    DLB Added EMgetSurfsOfPrim message.
  11/18/88    DLB Added EMswapPrimitive message.
  11/14/88    RC  Removed EMlift message.
  10/28/88    DLB Added EMreplacePrimitive message.
  10/13/88    DLB Added EMgetattributeid message.
  09/26/88    DLB Added EMgetInfoAboutComponents message.
  08/12/88    DLB Added EMislm message.
  15 Jun 1988 SAM Added geometry field in EMget_params message.
  10 Jun 1988 jBk Added option argument to EMoffset_surface and
                  renamed message to EMgenerate_offset_surface.
  02 Jun 1988 AIC Added eligible_edge_type argument to
                  EMmake_wire_frame.
  23-May-88   SM  Added environment and md_id arguments to
                  EMdelete_boundary message.
  19 May 1988 jBk Added environment argument to EMisClosed message.
  04/03/88    RC  Added EM_lift and EMlift_face_w_draft messages.
  04/03/88    DLB Added parameter to EMgettreepath.
  14-Mar-1988 jBk Added EMisClosed message.  Added comments for
                  EMgetstatedesc message.
  14-Mar-1988 DLB Removed rejection of EMgetactiveid message.
  25-Mar-88   SM  Moved EMcross_section from EMSsolid to here so
                  that cross section of any surface can be taken as
                  long as the intersection is closed.
  03/21/88    RV  Added EMvalidate.
  12/03/87    RV  Removed EMjoincs, added EMdisplay_edges.
  12/01/87    GK  added mass properties related messages
                          1. EMmassprop
                          2. EMfaceintgrl
                          3. EMsurfintgrl
  
  26 January 88   Rootmsg replaced in the ancestry for FEM.
  
  11/07/87    RC  Moved EMmake_face and EMlift from EMScompsurf
                  to EMSsurface. Overrode GRcopy and moved EMintcopy to
                  EMSsubbs.
  10/29/87    DLB Deleted EMintplane (moved to EMSsubbs).  
                  Moved EMcompress_top from EMsubbs to here (stubbed).
                  Moved EMtree_traverse to EMScomposite.
  
  13 October 87   AIC     Conversion to EMS 1.1
  
                          Rootmsg was removed from the ancestry
                          and the channel EMSsurface->to_associations
                          was removed. (GRnotify->notification is used
                          in its place.)
  20-Jan-88       SM      added message 'EMmake_wire_frame'
  
    The following modifications occured before EMS 1.1
  
  30-Sep-1987 jBk Added EMputDescription, EMgetDescription, and
                  EMlenDescription messages.  For SM:  Readded
                  EMintplane override.
  01-Sep-1987 RV  Added EMjoincs and EMgetedges.
  18-Jun-1987 jBk Added EMresend message.
  20-May-1987 SM  Added message EMintplane_notrim and override for
                  EMintplane.
  06-May-1987 jBk Made changes for Gupta.
  25-Mar-1987 RLW Removed range from instance data
  16-Mar-1987 AIC Added associations channel
  20-Sep-1986 RLW OM 4.0 rewrite
  28-Jun-1986 RLW The beginning
*/

class specification EMSsurface (3:0) of EMScreator, Rootmsg, GRvg;

# include "emserr.h"
# include "EMSerrordef.h"
# include "EMStypedef.h"
# include "emssfcvs.h"  
# include "emsdef.h"
# include "EMSadt.h"
# include "EMSopt.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "emssfint.h"
# include "EMSsfintsort.h"
# include "emsbool.h"
# include "DIdef.h"     
# include "EMSasnuc.h"  

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMrevorient
(
  IGRlong *EMmsg;
);

reject 
  EMrevorient;

#ifndef BASE_EMS

message EMchksliver
(
  IGRlong *msg;
  IGRushort options;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRdouble xyztol;
  IGRint num_samplepts_edge;
  IGRint *num_slivers;
  GRobjid (**sliver_edges)[2];
);

message EMoffset
(
  IGRlong *msg;
  IGRushort options;
  IGRshort *mattyp;
  IGRmatrix matrix;
  struct GRvg_construct *const_args;
  IGRboolean offset_inward;
  IGRdouble thickness;
  IGRint num_spec_thick;
  IGRdouble *val_spec_thick;
  struct GRobjid_set *spec_thick_sf_sets;
  IGRint num_nooffsetsfs;
  GRobjid *nooffsetsfs;
  IGRchar status_str[];
  GRobjid *offsetobj;
  struct EMSerror_help *errkey_list;
);

message EMmove
(
  IGRlong *EMmsg;
  IGRshort move_type;
  struct GRid move_obj_id;
  IGRpoint from_pt;
  IGRpoint to_pt;
  IGRshort option;
  struct GRmd_env *my_env;
  IGRshort *display_option;
);

message EMgetGRobjid
(
  IGRlong *EMmsg;
  GRobjid *objid;
);

message EMlmmove
(
  IGRlong *rc;
  OM_p_MESSAGE mess;
  struct GRid *sfmove_GRid;
);

message EMsfsfint
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct GRvg_construct *const_args;
  struct EMSdataselect *other_data;
  struct GRmdenv_info *other_datenv;
  IGRushort outworld_options;
  IGRushort outparam_option;
  IGRushort trim_options;
  IGRlong *num_inters;
  struct EMSinters **my_inters;
  struct EMSinters **other_inters;
);

message EMowner_sfsfint
(
  IGRlong *msg;
  struct GRmdenv_info *my_mdenv_info;
  struct GRid *other_obj;
  struct GRmdenv_info *other_mdenv_info;
  IGRushort inters_options;
  IGRushort outworld_options;
  IGRushort outparam_option;
  IGRushort trim_options;
  struct GRvg_construct *const_list;
  IGRint *num_inters;
  struct EMSinters **my_inters;
  struct EMSinters **other_inters;
  GRobjid *inters_outputobj;
  GRobjid *inters_endptsobj;
  IGRchar *status_str;
);

message EMalgnnrml
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRshort *pos_orient;
  IGRpoint point_in_solid;
  struct GRmd_env *surf_env;
);

message EMshow_normals
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  struct IGRdisplay *active_display;
  enum GRdpmode display_mode;
);

message EMintcopy
(
  IGRlong *msg;
  struct GRmd_env *obj_env;
  struct GRmd_env *new_mdenv;
  GRobjid *newobjid;
  struct EMcp_info *copy_info;
  IGRushort bdry_options;
  IGRushort sf_options;
);

message EMisactive
(
  IGRlong *EMmsg;
  IGRboolean *active_state;
  IGRboolean *active_path;
);

message EMgetactiveid
(
  IGRlong *EMmsg;
  struct GRid *active_id;
  struct GRid *top_lm_id;
);

message EMgetCuttingPrims
(
  IGRlong *EMmsg;
  GRobjid **cutting_prim_ids;
  IGRint *num_cutting_prim;
  IGRushort options;
);

message EMgetSurfsOfPrim
(
  IGRlong *EMmsg;
  GRobjid prim_id;
  GRobjid **surf_ids;
  IGRint *num_surf;
  IGRint *num_active;
);

message EMswapPrimitive
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid swap_id;
  IGRushort options;
);

message EMgetprimsfromtree
(
  IGRlong *EMmsg;
  IGRint *count;
  GRobjid **prims;
);

message EMislm
(
  IGRlong *EMmsg;
  IGRboolean *is_lm;
);

message EMmake_active_state
(
  IGRlong *EMmsg;
  IGRushort *option;
  struct GRmd_env *my_env;
  struct GRid **active_state;
  IGRint *num;
  IGRint *buff_size;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRint *involk_count;
);

message EMreplacePrimitive
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid new_id;
  IGRushort options;
);

message EMgetattributeid
(
  IGRlong *EMmsg;
  struct GRid *attribute_GRid;
);

message EMgetInfoAboutComponents
(
  IGRlong *EMmsg;
  IGRint *comp_info_count;
  struct EMScomponent_info **comp_info;
);

message EMmovesurfs
(
  IGRlong *EMmsg;
  struct GRid *prim_id;
  struct GRmd_env *env;
);

message EMintplane_notrim
(
  struct GRvg_construct *construct_list;
  struct IGRplane *plane;
  struct GRlc_info *located_object;
  int *number_of_intersections;
  struct GRid **ptr_to_resulting_intersections;
  int *msg;
);

message EMintsurf_saveside
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  struct EMSdataselect *surf;
  struct GRmd_env *my_env;
  double *saveside_point;
  IGRint natural_normal;
  IGRushort options;
  GRobjid *intobj;
  GRobjid *auxobj;
  IGRboolean want_status_messages;
  struct EMSobject_info *parent;
);

message EMlmsplit
(
  IGRlong *rc;
  OM_p_MESSAGE mess;
  struct GRid *split_GRid;
);

message EMsplit_surface
(
  IGRlong *rc;
  struct GRmd_env *my_env;
  struct GRvg_construct *construct_list;
  IGRint option;
  IGRlong in_numpars;
  IGRlong *out_numpars;
  IGRdouble *in_parms;
  IGRdouble **out_parms;
  struct GRid insrf_id;
  GRobjid **out_surf_ids;
  IGRboolean *uv_closed;
  IGRboolean delete_flag;
);

message EMlmround
(
  IGRlong *EMmsg;
  OM_p_MESSAGE mess;
  struct GRid *round_GRid;
);

message EMlmnewround
(
  IGRlong *EMmsg;
  OM_p_MESSAGE mess;
  struct GRid *round_GRid;
);

message EMresend
(
  OM_S_OBJID objid;
  OMuword osnum;
  OM_E_WRT_FLAG wrt_flag;
  OM_p_MESSAGE sd_message;
);

message EMcap_yourself
(
  IGRlong *EMmsg;
  IGRshort option;
  struct GRmd_env *env;
  struct GRvg_construct *construct_list;
  GRobjid *bottom_cap;
  GRobjid *top_cap;
  GRobjid *bottom_edgeids;
  GRobjid *top_edgeids;
);

message EMget_params
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf_geom;
  struct GRmd_env *env;
  IGRushort *type;
  struct EMsurface_params *params;
);

message EMgetedges
(
  IGRlong *EMmsg;
  IGRlong option;
  struct GRid **edges;
  IGRint *buf_size;
  IGRint *num_edges;
  GRobjid **surf_list;
  IGRint **numed_list;
  IGRint *list_size;
  IGRint *num_in_list;
);

message EMputDescription
(
  EMSrc *rc;
  char description[];
);

message EMgetDescription
(
  EMSrc *rc;
  char description[];
  int len;
);

message EMlenDescription
(
  EMSrc *rc;
  int *len;
);

message EMimpose_boundaries
(
  IGRlong *EMmsg;
  IGRlong number_of_curves;
  struct IGRbsp_curve curve_buffs[];
  struct GRlc_info info[];
  IGRdouble in_uv[2];
  IGRboolean uv_in_area;
  struct GRmd_env *my_env;
  IGRlong *number_of_bad_points;
  IGRpoint **bad_points;
  IGRlong *number_of_bad_curves;
  IGRlong bad_curve_indices[];
  IGRint *num_sfloops;
  struct EMSownercomp **sfloops;
  IGRint *num_output_loops;
  GRobjid **output_loops;
  IGRushort map_options;
  IGRushort imp_options;
  OM_S_OBJID *state_object;
);

message EMdelete_boundary
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  struct GRid *md_id;
  struct GRid *surfid;
);

message EMmassprop
(
  IGRlong *msg;
  IGRint num_surfaces;
  IGRdouble sld_range;
  struct GRmd_env *my_env;
  IGRdouble scaling_factor;
  IGRvector trans_vector;
  IGRdouble *density;
  IGRdouble *mass_int;
);

message EMareaprop
(
  IGRlong *msg;
  IGRboolean want_status;
  IGRint num_surfaces;
  struct GRmd_env *my_env;
  IGRdouble scaling_factor;
  IGRvector trans_vector;
  IGRdouble *out_int;
);

message EMfaceintgrl
(
  IGRlong *msg;
  IGRboolean want_status;
  IGRboolean new_tiler;
  IGRint *surf_inx;
  IGRint num_surfaces;
  struct GRmd_env *my_env;
  struct IGRbsp_surface *surf_in;
  IGRdouble scaling_factor;
  IGRvector trans_vector;
  IGRdouble *tran_mat;
  IGRlong option;
  IGRdouble *density;
  IGRdouble *out_int;
);

message EMsurfintgrl
(
  IGRlong *msg;
  struct GRmd_env *my_env;
  IGRboolean new_tiler;
  IGRvector trans_vector;
  struct IGRbsp_surface *surf;
  IGRchar *char_surf_info;
  IGRlong option;
  IGRdouble *density;
  IGRdouble *out_int;
);

message EMmk_nat_bdry
(
  IGRlong *EMmsg;
  struct GRmdenv_info *md_env;
  GRobjid *edge_ids;
);

message EMis_surf_modif
(
  IGRlong *rc;
  IGRshort option;
  IGRboolean *modifiable;
);
       
message EMcompress_top
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
);

message EMmake_face
(
  IGRlong *EMmsg;
  OM_p_MESSAGE pass_message;
  struct GRid *lm_object;
);

message EMdisplay_edges
(
  IGRlong *EMmsg;
  struct GRmd_env *mod_info;
  IGRlong option;
  enum GRdpmode display_mode;
  IGRint *num_edges;
);

message EMget_point_on_surface
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  IGRuint attempt_no;
  IGRint number_of_points;
  IGRdouble *points;
  struct EMparms *params;
);

message EMcrvsrfint
(
  IGRlong *msg;
  struct GRvg_construct *cnst_list;
  struct GRmdenv_info *my_objenv;
  struct IGRbsp_curve *curve_in;
  struct GRid *curve_obj;
  struct GRmdenv_info *curve_objenv;
  IGRboolean hole_inter_valid;
  IGRlong *pnt_slots;
  IGRlong *grand_num_pnt;
  struct GRid **pnt_ids;
  struct GRparms **my_pnt_inters;
  struct GRparms **curve_pnt_inters;
  IGRdouble **inter_pnts_xyz;
  IGRulong **inter_props;
);

message EMmake_wire_frame
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  struct EMScurveinfo *curve_info;
  IGRushort eligible_edge_type;
);

message EMcross_section
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  struct IGRplane *plane;
  struct GRmd_env *my_env;
  GRobjid *plane_id;
  IGRushort impoptions;
);

message EMisClassInTree
(
  IGRlong *EMmsg;
  OMuword *classid;
  IGRushort num_classid;
  IGRboolean *flag;
  IGRboolean search_up;
);

message EMgettreepath
(
  IGRlong *EMmsg;
  GRobjid **pathlist;
  IGRint *pathlist_count;
  IGRboolean unused;
);

message EMgetstatedesc
(
  IGRlong *EMmsg;
  IGRchar description[];
);

message EMtree_display
(
  IGRlong *EMmsg;
  IGRshort *type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct GRid *display_info;
  GRobjid *stop_ids;
  IGRint stop_count;
);

message EMisClosed
(
  IGRlong EMmsg[1];
  struct GRmd_env env[1];
  IGRboolean isClosed[1];
);

message EM_lift
(
  IGRlong *EMmsg;
  OM_p_MESSAGE pass_message;
  struct GRid *lm_object;
);

message EMlift_face_w_draft
(
  IGRlong *EMmsg;
  OM_p_MESSAGE pass_message;
  struct GRid *lm_object;
);

message EMpostgeomod
(
  IGRlong *msg;
  IGRushort options;
  struct GRmd_env *model_env;
  OM_p_MESSAGE messg;
  IGRchar *classinfo;
);

message EMpostsymmod
(
  IGRlong *msg;
  IGRushort options;
  IGRushort symtype;
  struct GRsymbology *symb;
  OM_p_MESSAGE messg;
  IGRchar *classinfo;
);

message EMpostxform
(
  IGRlong *msg;
  IGRushort options;
  struct GRmd_env *model_env;
  IGRshort *xmattyp;
  IGRmatrix xmat;
  OM_p_MESSAGE messg;
  IGRchar *classinfo;
);

message EMpostdelete
(
  IGRlong *msg;
  IGRushort options;
  struct GRmd_env *model_env;
  OM_p_MESSAGE messg;
  IGRchar *classinfo;
);

message EMpostrtree
(
  IGRlong *msg;
  IGRushort options;
  IGRboolean add;
  struct GRmd_env *model_env;
  OM_p_MESSAGE messg;
  IGRchar *classinfo;
);

message EMget_mdsfs_info
(
  IGRlong *EMmsg;
  struct GRid st_nd_GRid;
  struct GRid end_nd_GRid;
  struct EMSsfs_md_info *md_info;
  struct GRmd_env *md_env;
  IGRshort options;
);

message EMcross_section2
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  struct GRlc_info *xs_pf_info;
  IGRvector win_zvec;
  struct GRmd_env *mdl_env;
  struct GRid *cs_GRid;
  struct GRid *vd_wn_GRid;
  IGRboolean want_status_messages;
);

message EMgetContiguousAreas
(
  EMSrc *rc;
  struct EMStreeHeap **pp_areas;
);

message EMgetLoops
(
  EMSrc *rc;
  IGRlong option;
  int *p_count;
  struct EMStreeHeap **pp_ploops;
);

message EMputLsIfNotThere
(
  IGRlong *EMmsg;
  struct GRmdenv_info *env;
  GRobjid *edge_ids;
  GRobjid *lsid;
  IGRushort options;
  IGRboolean *ls_created;
);

message EMcompressed_copy
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct GRmd_env *cp_env;
  GRobjid *new_id;
  IGRushort options;
);

message EMunevaluate
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmd_env *env;
  GRobjid **display_ids;
  IGRint *display_count;
  GRobjid *active_id;
  GRobjid nodes_owner_id;
  GRobjid *batch_id;
);

message EMevaluate
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRint num_to_eval;
  GRobjid *eval_ids;
  struct GRmd_env *env;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRint num_path_ids;
  GRobjid *path_ids;
);

message EMreplace
(
  IGRlong *EMmsg;
  GRobjid replacing_id;
  struct GRmd_env *env;
  IGRushort options;
  GRobjid **display_ids;
  IGRint *display_count;
  GRobjid *active_id;
);

message EMcreate_envelope_and_igds_files
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  IGRdouble *scale_factor;
  struct GUcvt_bufs *cvt_buffers;
  IGRlong *IGDS_filedesc;
  IGRdouble *max_abs_overflow;
  IGRint *cmpnt_tag;
  IGRboolean is_tag_good;
  IGRdouble *file_ige_range;
  IGRint *num_processed_ids;
  IGRint *processed_ids_arrsz;
  GRobjid **processed_ids;
);

message EMtrim_a_surface
(
  IGRlong *EMmsg;
  GRobjid op1_elem;
  struct GRmd_env *op1_elem_env;
  IGRint num_op2_elems;
  GRobjid *op2_elems;
  struct GRmd_env *op2_elems_env;
  struct GRvg_construct *const_list;
  IGRboolean extend_operand_1;
  struct EMSextend_info *extend_info;
  IGRboolean copy_operands_2;
  IGRint num_pts;
  struct EMSsortpt_info *sortpts_info;
  enum EMSbooltype bool_type;
  IGRboolean all_elements_solid;
  IGRint *num_bad_pts;
  struct EMSsortpt_info **bad_pts_info;
);

message EManalyzeIntfAlongXsec
(
  IGRlong *EMmsg;
  struct GRlc_info *SetInfo1;
  struct GRlc_info *Elems1;
  IGRint NumElems1;
  IGRint setnum1;
  struct GRlc_info *SetInfo2;
  struct GRlc_info *Elems2;
  IGRint NumElems2;
  IGRint setnum2;
  IGRushort options;
  IGRchar *ReportFileName;
  struct GRvg_construct *const_list;
  struct IGRplane *plane;
  struct EMSintf **result;
  IGRint *num_result;
);

message EMcompute_density
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRdouble *density;
);

message EMupdate_all_xsec
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRushort options;
);

message EMmatch_topology
(
);

message EMis_associative
(
  IGRlong *EMmsg;
  IGRboolean *is_associative;
);

message EMget_assoc_class
(
  IGRlong *EMmsg;
  IGRchar *assoc_class_name;
);

message EMtransform_to_associative
(
  IGRlong *EMmsg;
  OM_S_OBJID *new_objid;
);

message EMget_tree_top
(
  IGRlong *EMmsg;
  GRobjid *tree_top_id;
  GRobjid *comp_top_id;
  IGRushort options;
);

message EMmatch_geometry
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmd_env *md_env;
  GRobjid new_objid;
);

message EMfix_creator_id
(
  IGRlong *EMmsg;
  struct EMcp_info *cp_info;
  GRobjid new_creator_id;
  OMuword options;
);

message EMcreator_is_undoing
(
  IGRlong *EMmsg;
  GRobjid *creator_id;
);

message EMpattern_copy
(
  IGRlong *EMmsg;
  struct GRid *creator;
  struct GRid *p_new;
  struct GRid *p_par_list;
  IGRint *p_count;
  IGRint p_size;
  struct GRmd_env *md_env;
  struct GRid *ref_plane;
);

reject
  EMchksliver,
  EMcreate_envelope_and_igds_files,
  EMgetLoops,
  EMgetSurfsOfPrim,
  EMpostsymmod,
  EMpostxform,
  EMpostrtree,
  EMtree_display,
  EMisClassInTree,
  EMget_point_on_surface,
  EMintcopy,
  EMalgnnrml,
  EMsfsfint,
  EMmovesurfs,
  EMshow_normals,
  EMcap_yourself,
  EMget_params,
  EMgetedges, 
  EMdisplay_edges,
  EMimpose_boundaries, 
  EMdelete_boundary, 
  EMfaceintgrl, 
  EMsurfintgrl, 
  EMmk_nat_bdry, 
  EMis_surf_modif, 
  EMcrvsrfint, 
  EMcompress_top,
  EMmake_wire_frame, 
  EMmassprop,
  EMfaceintgrl,
  EMsurfintgrl,
  EMget_mdsfs_info,
  EMpattern_copy,
  EMmatch_topology,
  EMmatch_geometry;

override
  GRprint,
  GRread,
  GRgetobjinfo, 
  GRcopy,
  EMtranslate_id_key,
  GRmksource, 
  GRclip,
  EMintplane;

#endif

end specification EMSsurface;
