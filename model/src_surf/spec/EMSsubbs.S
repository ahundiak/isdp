/*
  ABSTRACT

  This is an abstract class which represents surfaces that
  can be represented as a simple bspline surface. In order to
  be a subclass of this class the following requirements must be
  meet:

  1) The surface must be representable as a single bspline surface
  2) The u and v parameters of the surface must range from 0 to 1, i.e.
          surface->u_knots[surface->u_order] = 0.0
          surface->u_knots[surface->u_num_poles] = 1.0
          surface->v_knots[surface->v_order] = 0.0
          surface->v_knots[surface->v_num_poles] = 1.0
  3) The bspline representation must preserve the mapping from 
     parametric to model space.  For example, a sphere can be
     represented as a center and a radius.  If the sphere has
     parametric space boundaries and is rotated then it must be
     able to generate a bspline surface for which the parametric
     space boundaries are valid.

     This class also provides standard methods which will work on all
     simple bspline surfaces.


  NOTES

  The contigous instance data for this class begins on a quadword
  boundary (32 bytes of contiguous instance data are inherited),
  and uses 15 bytes.


  HISTORY

  25-Nov-93  ashokAdded "newid" argument to EMextend_by_dist message.
  01-May-93  ashokAdded EMextend_by_dist message.
  11-Jan-93  Jack Moved EMruled_surface and EMdrafted_surface from EMSgenbs
                  to here to aid in analytic surface creation.  Now, these
                  messages can be sent to an EMScylindr for example.
  18-Aug-92  NP	Parameter "node_pts" was declared as "IGRint **" instead of
  		"IGRdouble **" as it should be. 
  12-May-92  SM   Added override GRgetobjinfo
  26-Sep-91  Jack Removed the z_vector and md_env parms to 
                  EMget_graphics_edges.  Added num_parents and parents.
  20-Sep-91   AIC Changed matrix and type to GRmdenv_info structure in
                  EMget_ele_header message.
  02-Jul-91  Jack Added the md_env parm to the EMget_graphics_edges message. 
                  Also replaced a semicolon in the override list with a comma.
                  Also commented out an override to EMexeinst since the 
                  message is defined for this class.
  27 Jun 91   AIC Replaced EM[get/put]RenderingIndex with GR[get/chg]props.
  24 Jun 91   AIC Added EMputRenderingIndex and EMgetRenderingIndex messages.
  14-Jun-91  Jack Added EMget_graphics_edges method for 2.0.1 Horizon Loops.
  10 Jun 91   msm Override GRreport, GRreport_defaults, GRupdate_gadgets.
                  Removed override GRloadform and GRgetsfsize.
  08 Jun 91  PP   Added override of EMpostgeomod
  09-May-91  Jack Added EMinit_display method for 2.0.1 Horizon Loops.
  02 May 1991 AIC Added hidden_line (moved from GRvg).
  10 Oct 1989 BL  Added out_solid and surface two arguments to EMget_unit_norm.
  02 Oct 1989 SM  Added message EMcreateAngularPartingSurface.
  25 Aug 1989 RC  Changed EMwrite_to_envelope_file to
                  EMcreate_envelope_and_igds_files.
  01 Aug 1989 RC  Added EMwrite_to_envelope_file overrride.
  31 Jul 1989 BL  Added EMget_unit_norm() message.
  28 Jul 1989 PP  Added message related to placement of isophotes..
  18 Jul 1989 PP  Added messages related to move poles/nodes.
  11 Jul 1989 DLB Added EMupdateGradata message.
  19 Jun 1989 BL  Added EMget_tan_btn_surfs() message.
  06-Jun-89   SM  Override EMputLsIfNotThere.
  20 Dec 1988 jBk Added struct GRid *window_id argument to
                  EMprofile message.  The implementation and the
                  only apparent usage utilized this argument.
  19 Dec 1988 jBk Added EMgetLoops override.
  30 Nov 1988 RC  Added override for EMget_mdsfs_info.
  23 Nov 1988 rlw Reworked the extract iso curve method to support
                  trimming to the existing boundaries.  One argument
                  was added and one was change.  Due to these changes
                  I renamed the method.
  12 Oct 1988 AIC Added matrix and matrix_type arguments to
                  EMget_boundaries messages, and changed alt_symb
                  argument of EMSget_ele_header message from
                  IGRdisplay to IGRaltdisplay.
  09/28/88    DLB Added EMgetowner message.
  19 Aug 1988 SAM Added EMtoggle_polygon() message.
  
  27 Jul 1988 AIC Added declaration of EMprofile and EMpartingLines
                  messages.
  
  07 Jul 1988 SAM Added overrides of GRaddwrng, EMget_params, and added
                  message EMput_range_in_rtree to put minimum possible
                  range of the surface in the rtree at surface costruction,
                  geometric or topological modification. Further added a 
                  IGRuchar "ls_area_for_rtree" field to the instan-
                  ce data ( It came for free because of the kind of
                  dynamic memory allocator we have (ie:This area would be
                  allocated by the allocator even though not asked for,
                  but could not be used)).
  
  29 Jun 1988 AIC Added override of GRlnprocess, and removed declaration
                  of EMboreLineProject.
  
  10 Jun 1988 jBk Renamed EMoffset_surface message (overridden
                  here) to be EMgenerate_offset_surface.
  
  02 Jun 1988 AIC Added GRpoltprep override and removed
                  GRplotyourself override.
  
  19 May 1988 jBk Added override of EMisClosed.
  
  16 May 1988 dhm Overrode GRloadform and GRgetsfsize.
  
  05 Apr 1988 AIC Added declaration of GRlocate override. 
                  (Apparently the implementation was checked in,
                  but not the change to the specification.) 
  
  23 Mar 1988 SAM Added EMreduce_range, EMset_props and EMget_props
                  messages.
  
  10 Mar 1988 AIC Added EMmodifiedClass message.
      
  20 Jan 1988 SM  added 'eligible_edge_types' argument to
                  EMexecuteCurveFunction.
  
  05 Jan 1988 rlw Moved the message EMbstobz from EMSgenbs back to
                  this class.
  
      12/31/87        SAM     Added EMssdelfrt.



    12/30/87        rlw     Removed EMsfoffset method as the
                            EMoffset_surface method replaces it.
                            Removed the EMextsf method and placed a new
                            EMextend_surface method at class EMSgenbs.

    20/12/87        SAM     Added EMss4poles.

    12/03/87        RV      Added EMdisplay_edges, removed EMjoincs
                            override.

    11/14/87        RC      Added EMget_edges message.

    11/07/87        RC      Overrode EMintcopy, moved GRcopy override
                            to EMSsurface, deleted EMget_mod_edges_vertex
                            message.

    10/29/87        DLB     Added EMintplane override(moved from
                            EMSsurface)
                            Deleted EMcompress_top changed to override.
                              
    03-Nov-87       SM      Moved some messages from EMSsubbs to
                            EMSsurface.

    27 October 87   AIC     Conversion to EMS 1.1

                            Free form message declarations were removed
                            and redeclared at EMSgenbs. The instance
                            data was changed so that any method of
                            storage uses the instance data declared
                            in EMSsubbs.

    The following modifications occured before EMS 1.1

    AIC, RC 09/28/87    Added EMmake_frt message.

    rlw 09/23/87        Added ovveride for plotyourself method and
                        documented move cross section method
    SM  15-Sep-87       Added arguments window_loopset and
                        want_status_messages to EMpartsf, to reflect
                        windowing of boundaries.
    RV  01-Sep-87       Added overrides EMjoincs and EMgetedges.
    SM  31-Aug-87       Added the message EMunpack.
    dhm 08/17/87        changed arguments for EMruled_surface.
    AIC 01-Aug-87       Moved declaration of EMgetbsdef and override
                        of GRgeomprops from EMSbssubbs to here.
    AIC 15-Jul-87       Added EMget_ele_header and EMgetRuleLineTable
                        messages.
    RLW 06/10/87        Rewrote and documented the align surface method
                        Actually I started to rewrite but did not finish
                        due to other, more pressing, issues.
    SM  05/28/87        Added GRid argument to delete_boundaries message
    RLW 05/21/87        Moved project curve onto surface message from
                        class GRbspline to this class and rewrote it.
                        Added project curve onto surface along normals
                        method.
    gk  05/21/87        added EMfaceintgrl, EMsurfintgrl and EMareaprop
                        methods
    SM  05/20/87        Added arguments out_loops,num_output_loops and 
                        output_loops to EMssimpose_boundaries and
                        removed override for EMintplane.
    RLW 05/19/87        Moved merge surface method to class EMSbssubbs
    RLW 05/17/87        Removed swap solid hole message
    JBK 05/06/87        Added EMcompress_top message.
    JBK 05/06/87        Added EMmovesurfs override.
    RLW 03/25/87        Removed par_tol, changed dp_props to a
                        char, and combined u_rules and v_rules
                        into a short and removed slow rule line
                        spacing option
    AIC 03/10/87        Made this class abstract -- see EMSbssubbs
    RLW 02/12/87        Modified impose boundary arguments
    RLW 09/20/86        OM 4.0 conversion
    RLW 06/28/86        Created for demo system.
    gupta 05/12/88      Added several messages for Rounding
    Vadi  01/31/95      Overriding GRanalyze_element inherited from GRgraphics.
    GVK 09/23/95        Added message EMinitInstance for MINIEMS. Similar to
			Postabsg but just updates VLA nothing else.
*/

class specification EMSsubbs (2:0) of EMSrequester, EMSsurface;

# include "bstypes.h"
# include "bsisfprtlns.h"   

/*------------------ INSTANCE DATA SECTION -------------------*/

channel loop_channel
{
  (one_to_one)
  EMSloopset.to_surface;
};

instance EMSsubbs
{
  channel loop_channel  to_loopset;     
  variable IGRchar      packed_data[];  
  IGRint                hidden_line;    
  IGRuchar      u_rules;        
  IGRuchar      v_rules;        
  IGRuchar      ss_props;       
  IGRuchar      ls_area_for_rtree;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetRuleLineTable
(
  IGRlong *EMmsg;
  IGRboolean nat_edges;
  IGRint *u_stripes;
  IGRint *v_stripes;
  struct IGRbsp_surface *in_surf;
  IGRint *mx_type;
  IGRmatrix mx;
  IGRchar *buffer;
  IGRint buffer_size;
  struct IGResqbs **rlt;
);

message EMget_props
(
  IGRlong *EMmsg;
  IGRuchar *props;
);

message EMgetbsdef
(
  IGRlong *msg;
  struct IGRbsp_surface *surface;
);

message EMpartolbasis
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRboolean *world;
  IGRboolean compute_new;
  IGRdouble *partolbasis;
);

message EMinitInstance
 (
   IGRlong *msg;
   struct GRmd_env *md_env;
   struct GRpost_info *info;
   IGRchar *absptr;
   GRobjid *newobjid;
 );

override
  GRgeomprops,
  GRgetattr,
  GRgenabsg,
  GRgetsize,
  GRgetgeom,
  GRgetrang,
  GRgethprops,
  EMrevorient,
  GRdetplane;

#ifndef BASE_EMS

message EMgetowner
(
  IGRlong *EMmsg;
  GRobjid *owner_id;
  IGRboolean immediate_owner;
);

message EMprofile
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  IGRint num_vectors;
  IGRvector vectors[];
  IGRshort options;
  IGRint *num_crvs;
  struct GRid **crv_ids;
);

message EMpartingLines
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  IGRvector vector;
  IGRushort options;
  struct EMSpartolbasis *partolbasis;
  IGRint *numgrps;
  struct BSpartgrp **partgrps;
);

message EMmodifiedClass
(
  IGRlong *EMmsg;
  IGRint modif;
  GRobjid *newobjid;
);

message EMputGeom
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRpost_info *info;
  IGRchar *absptr;
  GRobjid *newobjid;
  IGRboolean validate_class;
);

message EMtangent_normal
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRdouble parms[];
  IGRdouble dis_fac;
  IGRvector *vec_TN;
);

message EMintersect_plane_fillet
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRboolean iso_edge;
  struct IGRbsp_curve *iso_geom;
  IGRdouble *param;
  struct EMedge_round_info *my_info;
  IGRboolean imp_on_plane;
  IGRpoint vtx_point;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  struct IGRplane *plane;
  struct IGRbsp_curve **lin_curve;
  GRobjid plane_id;
  GRobjid *edges;
  GRobjid *round_id;
);

message EMintersect_surface_fillet
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRpoint vtx_point;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  struct EMedge_round_info *my_info;
  IGRboolean pt_outside;
  GRobjid my_edge_id;
  GRobjid *round_id;
  IGRpoint beg_xyz;
  IGRpoint end_xyz;
);

message EMfillet_surface
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRint *edge_number;
  GRobjid *round_id;
  IGRpoint dirpt;
  struct GRvg_construct *construct_list;
  IGRushort operation_type;
  struct EMedge_round_info *my_info;
  IGRint *num_def_info;
  struct EMdef_con_info *def_info;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  IGRint num_round_edges;
  GRobjid *rnd_edge_ids;
  GRobjid *fillet_id;
);

message EMvariable_fillet_surface
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid *round_id;
  IGRboolean s1_nat_norm;
  IGRboolean s2_nat_norm;
  IGRpoint starting_point;
  IGRdouble starting_radius;
  IGRpoint ending_point;
  IGRdouble ending_radius;
  struct GRvg_construct *construct_list;
  struct EMedge_round_info *my_info;
  GRobjid *fillet_id;
);

message EMend_patches
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid *round_id;
  struct GRvg_construct *construct_list;
  struct EMSpartolbasis *s1_partol;
  struct EMSpartolbasis *s2_partol;
  struct IGRbsp_surface *s2;
  GRobjid fillet_id;
  IGRpoint *bpnt;
  IGRdouble *params;
  GRobjid *f_edges;
  struct IGRbsp_curve *first_arc;
  struct IGRbsp_curve *last_arc;
  struct EMedge_round_info *my_info;
  IGRint *num_def_info;
  struct EMdef_con_info *def_info;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  IGRint num_round_edges;
  GRobjid *rnd_edge_ids;
  struct GRid bnd_edge_ids[];
);

message EMmake_edge_loop
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct EMedge_round_info *my_info;
  struct IGRbsp_surface *fsurf;
  struct IGRbsp_surface *impbnd_surf;
  BSpair **par;
  IGRint cind;
  IGRint *numpnts;
  IGRdouble v0_or_v1;
  IGRshort bnd_type;
  GRobjid *round_id;
  GRobjid rnd_edge_id;
  struct EMSpartolbasis *surf_partol;
  IGRboolean auto_trim;
  IGRboolean special_fillet;
  IGRdouble *point_in_area;
  struct GRid *edge_id;
  IGRint *num_loops;
  GRobjid **loop_id;
);

message EMmake_bsedge_loop
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct IGRbsp_surface *impbnd_surf;
  struct IGRbsp_curve *xyz_curve;
  struct EMSpartolbasis *surf_partol;
  GRobjid rnd_edge_id;
  IGRshort bnd_type;
  IGRboolean pt_outside;
  IGRpoint vtx_point;
  struct GRid *edge_id;
  GRobjid *round_id;
);

message EMmake_linedge_loop
(
  IGRlong *EMmsg;
  IGRboolean iso_edge;
  struct IGRpolyline *poly;
  GRobjid *round_id;
  struct EMSpartolbasis *surf_partol;
  IGRshort bnd_type;
  GRobjid rnd_edge_id;
  GRobjid *edge_id;
  IGRdouble *point_in_area;
);

message EMextend_fillet
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRdouble radius;
  IGRdouble *param;
  struct IGRbsp_surface *my_geom;
  struct IGRbsp_surface **extended_surface;
);

message EMvalidateClass
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  GRobjid *new_objid;
  struct IGRbsp_surface *surf;
);

message EMexecuteCurveFunction
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *alt_geom;
  IGRshort *mx_type;
  IGRmatrix mx;
  IGRint (*f)();
  IGRchar *args;
  IGRushort eligible_edge_type;
);

message EMbstobz
(
  struct GRvg_construct *construct_list;
  GRobjid **pch_objid;
  IGRint *nondeg_pch;
  IGRlong *msg;
);

message EMmove_class
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid *newid;
);

message EMget_ele_header
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *srf_geom;
  struct GRmdenv_info *mdenv_info;
  struct IGRaltdisplay *alt_symb;
  struct DPele_header *ele_header;
  GRrange range_buffer;
  struct IGRdisplay *dis_att_buffer;
  union IGRele_attr ele_spec_buffer;
  OM_p_KEY_DESC key;
);

message EMmove_face
(
  IGRlong *rc;
  struct GRmd_env *my_env;
);

message EMisoparcvs
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct GRvg_construct *const_args;
  IGRboolean trim_to_boundaries;
  IGRint numparms;
  IGRdouble parms[];
  IGRboolean in_udir;
  IGRlong *number_of_curves;
  GRobjid **curves;
);

message EMsftanorm
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct GRvg_construct *const_args;
  IGRlong unumpars;
  IGRdouble upars[];
  IGRlong vnumpars;
  IGRdouble vpars[];
  IGRdouble displen;
  IGRdouble *dirpt;
  IGRboolean comp_tangent;
  IGRboolean comp_normal;
  IGRdouble *outpoly;
  GRobjid *outobj;
);

message EMpartsf
(
  IGRlong *rc;
  struct GRvg_construct *arglist;
  IGRdouble *parm1;
  IGRdouble *parm2;
  IGRdouble *parm3;
  IGRint split_ind;
  GRobjid *par_surf_objid;
  struct IGRbsp_surface **par_surf;
  IGRboolean window_loopset;
  IGRboolean want_status_messages;
);

message EMpjptsf
(
  IGRlong *msg;
  struct GRmd_env *env;
  IGRpoint v_pnt1;
  IGRpoint v_pnt2;
  IGRpoint pnt_to_prjct;
  IGRlong *num_pnts;
  IGRdouble **proj_pnts;
  IGRdouble **u_pars;
  IGRdouble **v_pars;
);

message EMsfradcrv
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct GRvg_construct *const_args;
  IGRuint prop_type;
  IGRlong unumpars;
  IGRdouble upars[];
  IGRlong vnumpars;
  IGRdouble vpars[];
  IGRdouble cutoff_value;
  IGRdouble *prop_val;
  IGRdouble *prop_poly;
  GRobjid *prop_obj;
);

message EMpratmpt
(
  IGRlong *EMmsg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRint numpts;
  IGRdouble *xyzpts;
  IGRdouble *uvpts;
  IGRdouble *dists;
  IGRdouble *mindistpts;
);

message EMfulltrim
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct EMSdataselect *my_uvdata;
  struct EMSdataselect *my_xyzdata;
  struct IGRbsp_surface *my_srf;
  struct EMSpartolbasis *mytolbasis;
  struct EMSdataselect *ot_data;
  struct GRmdenv_info *ot_envinfo;
  struct EMSdataselect *ot_uvdata;
  struct EMSdataselect *ot_xyzdata;
  struct IGRbsp_surface *ot_srf;
  struct EMSpartolbasis *ottolbasis;
  IGRdouble *correl_params;
  IGRushort options;
  IGRint *num_bdrys;
  struct EMSpypoint **my_bdrys;
  struct EMSsfintedpar **my_bdryparms;
  struct EMSpypoint **ot_bdrys;
  struct EMSsfintedpar **ot_bdryparms;
);

message EMparttrim
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct EMSdataselect *my_uvdata;
  IGRushort options;
  IGRint *num_bdrys;
  struct EMSpypoint **bdrys;
  struct EMSsfintedpar **bdry_parms;
);

message EMpassloop
(
  IGRlong *send_rc;
  OM_p_MESSAGE messg;
);

message EMdrop
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
);

message EMproject_curve_onto_surface
(
  struct GRlc_info *located_curve;
  struct GRlc_info *located_surface;
  struct GRvg_construct *construct_list;
  IGRvector projection_vector;
  IGRboolean want_status_messages;
  IGRboolean trimming_required;
  IGRlong *number_of_objects;
  OM_S_OBJID **objects;
  IGRlong *msg;
);

message EMproject_curve_along_surface_normals
(
  struct GRlc_info *located_curve;
  struct GRlc_info *located_surface;
  struct GRvg_construct *construct_list;
  IGRboolean want_status_messages;
  IGRboolean trimming_required;
  IGRlong *number_of_objects;
  OM_S_OBJID **objects;
  IGRlong *msg;
);

message EMunpack
(
  IGRlong *EMmsg;
  struct GRvg_construct *const_list;
);

message EMbdryint
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct GRvg_construct *const_args;
  struct GRid *other_obj;
  struct GRmdenv_info *other_datenv;
  IGRushort outworld_options;
  IGRushort outparam_options;
  IGRushort trim_options;
  IGRlong *num_inters;
  struct EMSinters **my_inters;
  struct EMSinters **other_inters;
);

message EMleavecs
(
  IGRlong *EMmsg;
  struct GRmd_env *mod_info;
);

message EMcomp_traverse
(
  IGRlong *EMmsg;
  GRobjid **surfs;
  IGRint *num_surfs;
  IGRint *buf_size;
);

message EMmake_frt
(
  IGRlong *EMmsg;
  GRobjid loop_id;
);

message EMget_boundaries
(
  IGRlong *EMmsg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRboolean *on_off;
  IGRshort *num_bdrys;
  struct IGRbsp_bdry_pts **bdrys;
);

message EMget_split_areas
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRlong num_of_objects;
  struct GRlc_info object_info[];
  IGRlong *num_of_bad_points;
  IGRpoint **bad_points;
  IGRboolean want_bad_curves;
  IGRlong *num_of_bad_curves;
  IGRlong bad_curve_indices[];
  IGRint *num_imp_loops;
  GRobjid **imp_loop_ids;
  struct EMSsfintedpar ***loops_trim_info;
  IGRint *num_trim_info;
  struct EMSownercomp **sf_loops_removed;
  IGRint *num_new_loops_created;
  GRobjid **new_loops_created;
  IGRboolean want_status_message;
);

message EMexeinst
(
  IGRlong *rc;
  IGRvector vector;
  struct GRmd_env *my_env;
  IGRint inst_no;
  GRobjid *newid;
  struct EMinstruction_table_info *raw_instructions;
);

message EMget_natedge_info
(
  IGRlong *EMmsg;
  struct GRmdenv_info *md_env;
  IGRuchar *curve_type;
  IGRushort *edge_props;
);

message EM3o4pts
(
  IGRlong *EMmsg;
  IGRpoint vtx1;
  IGRpoint vtx2;
  IGRpoint vtx3;
  IGRpoint vtx4;
  IGRpoint point_in_solid;
  struct GRvg_construct *construct_list;
);

message EMget_edges
(
  IGRlong *EMmsg;
  IGRint tree_depth;
  IGRlong option;
  struct GRmd_env *md_env;
  struct GRid **edges;
  IGRint *array_size;
  IGRint *num_edges;
);

message EMaltparams
(
  IGRlong *msg;
  IGRdouble *uvpt;
  IGRdouble partol;
  IGRint *numaltpts;
  IGRdouble *altuvpts;
);

message EMreduce_range
(
  IGRlong *EMmsg;
  struct GRmd_env *grmd_env;
  GRobjid *new_objectid;
  IGRdouble water_mark;
);

message EMset_props
(
  IGRlong *EMmsg;
  IGRuchar props;
  IGRchar option;
);

message EMput_range_in_rtree
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *new_geom;
  GRrange old_range;
  GRrange new_range;
  IGRuchar surf_change;
  struct GRid *md_grid;
);

message EMtoggle_polygon
(
  IGRlong *EMmsg;
  struct GRid *md_grid;
  IGRchar *attr;
);

message EMss4poles
(
  IGRlong *EMmsg;
  IGRpoint *poles_buff;
  struct GRmdenv_info *grmdenv_info;
);

message EMssdelfrt
(
  IGRlong *EMmsg;
);

message EMclassify_ray
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  struct IGRline *ray;
  IGRboolean reverse;
  IGRdouble *uvpt;
  IGRpoint int_point;
  IGRboolean *classification;
);

message EMget_int_data
(
  IGRlong *EMmsg;
  IGRushort options;
  struct EMSdataselect *other_data;
  struct IGRbsp_surface *my_geom;
  struct IGRbsp_surface *other_geom;
  IGRdouble *my_uvrange;
  IGRdouble *other_uvrange;
  struct EMSpartolbasis *my_partol;
  struct EMSpartolbasis *other_partol;
  IGRint *num_pieces;
  struct EMSdataselect **my_xyz_data;
  struct EMSdataselect **other_xyz_data;
  struct EMSdataselect **my_uv_data;
  struct EMSdataselect **other_uv_data;
  IGRdouble ***correl_params;
  IGRchar *curve_type;
  IGRushort *intinfo;
);

message EMrtreerange
(
  IGRlong *EMmsg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRboolean *world;
  GRrange range;
);

message EMgetabsgeom
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRchar **srf;
);

message EMset_inactive
(
  IGRlong *EMmsg;
  IGRboolean *did_set_inactive;
);

message EMget_tan_btn_surfs
(
  IGRlong *EMmsg;
  struct GRmdenv_info *md_env;
  struct GRid *surf1;
  GRobjid *edge1_objid;
  struct IGRbsp_curve *cur;
  IGRint num_pts;
  IGRdouble *len;
  IGRpoint dirpt;
  IGRdouble *polylines;
  IGRdouble *angles;
);

message EMget_unit_norm
(
  IGRlong *EMmsg;
  IGRboolean out_solid;
  struct IGRbsp_surface *surface;
  struct GRmdenv_info *mdenv;
  IGRdouble *pt;
  IGRdouble *unit_norm;
);

message EMupdateGradata
(
  IGRlong *EMmsg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
);

message EMcreate_isophotes
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  IGRushort options;
  IGRvector vector;
  IGRdouble start_angle;
  IGRdouble stop_angle;
  IGRint num_insert;
  IGRint *num_crvs;
  struct GRid **crv_ids;
);

message EMgenerate_node_pt_surf
(
  IGRlong *msg;
  struct GRmd_env *env;
  IGRint u_insert;
  IGRint v_insert;
  IGRushort options;
  struct GRvg_construct *construct_list;
  OM_S_OBJID *newobjid;
  IGRint *unum;
  IGRdouble **u_vals;
  IGRint *vnum;
  IGRdouble **v_vals;
  IGRint *num_pts;
  IGRdouble **weights;
  IGRdouble **node_pts;
);

message EMdynmod
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRushort options;
  IGRlong num_poles;
  IGRint *indices;
  IGRdouble *poles;
  IGRpoint from_point;
  IGRchar *buff;
);

message EMmove_poles
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRint option;
  IGRint num_poles;
  IGRint *indices;
  IGRdouble *from_point;
  IGRdouble *to_point;
  IGRchar *buff;
  GRobjid *newobjid;
);

message EMgetfillet
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRboolean is_my_natural_normal;
  struct GRlc_info *other_surface;
  IGRboolean is_other_natural_normal;
  IGRpoint starting_point;
  IGRdouble starting_radius;
  IGRpoint ending_point;
  IGRdouble ending_radius;
  IGRdouble *dirpt;
  struct IGRbsp_curve *lawcv;
  IGRdouble rho;
  struct GRvg_construct *construct_list;
  IGRushort options;
  IGRint *num_fillets;
  GRobjid **fillets;
  IGRint ext_ind;
  IGRint cnv_ind;
  IGRint cnc_ind;
);

message EMcreateAngularPartingSurface
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct IGRbsp_surface *my_geom;
  struct GRvg_construct *c_list;
  IGRushort options;
  IGRint num_pairs;
  struct IGRpolyline *nprtl;
  struct IGRpolyline *angprtl;
  struct GRlc_info *nprtlobj;
  struct GRlc_info *angprtlobj;
  struct IGRpolyline *nprtluv;
  struct IGRpolyline *angprtluv;
  IGRdouble *sidept;
  struct GRid *outid;
  struct IGRbsp_surface **psurfs;
);

message EMgetuvrange
(
  IGRlong *msg;
  IGRdouble *uvrange;
);

message EMsfcvoffset
(
  IGRlong *EMmsg;
  IGRshort *mattype;
  IGRmatrix matrix;
  struct GRvg_construct *const_list;
  struct GRid *cur_info;
  IGRboolean right_side;
  IGRdouble dist1;
  IGRdouble dist2;
  IGRboolean linear;
  IGRboolean uniform;
  struct IGRbsp_curve *law_curve;
  struct GRid *off_crv_id;
);

message EMssgetbdry
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRushort options;
  IGRint *numbdrys;
  struct IGRpolyline **xyzbdrys;
  struct IGRpolyline **uvbdrys;
  IGRdouble **lpranges;
  IGRushort **lpprops;
  GRobjid **lpids;
);

message EMnobdrydisp
(
  IGRlong *msg;
  IGRushort opts;
  IGRshort *mattyp;
  IGRmatrix mat;
  enum GRdpmode disp_mode;
  struct GRid *win_or_mod_id;
);

message EMinit_display
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
);

message EMget_graphics_edges
(
  IGRlong *EMmsg;
  IGRint *num_parents;
  struct EMSobject_info *parents;
  IGRshort options;
  IGRint *num_gralp_edges;
  IGRint *num_horiz_edges;
  IGRint *num_cusp_edges;
  struct GRid **gralp_edges;
  struct GRid **horiz_edges;
  struct GRid **cusp_edges;
);

message EMconvert_into_plane
(
  IGRlong *EMmsg;
  IGRushort options;
  GRobjid **origedges;
  GRobjid **newedges;
  GRobjid *oldls;
  IGRint *numedges;
  struct GRmd_env *env;
);

message EMruled_surface
(
  struct IGRbsp_curve *curve_1;
  struct GRlc_info *located_curve_1;
  struct IGRbsp_curve *curve_2;
  struct GRlc_info *located_curve_2;
  IGRint number_of_control_points;
  IGRpoint curve_1_points[];
  IGRpoint curve_2_points[];
  IGRpoint curve_end_points[2];
  IGRboolean nat_side;
  IGRboolean reverse_curve_1;
  IGRboolean reverse_curve_2;
  IGRshort option_flag;
  IGRboolean not_used_2;
  struct GRvg_construct *construct_list;
  IGRlong *msg;
);
                          
message EMdrafted_surface
(
  IGRlong *msg;
  struct IGRbsp_curve *curve;
  struct GRlc_info *located_curve;
  struct IGRbsp_curve *draft_cv;
  IGRvector draft_vec;
  IGRdouble draft_angle;
  IGRboolean right_side;
  IGRboolean fillet;
  IGRuchar curve_type;
  IGRboolean pos_orient_flag;
  GRobjid *new_obj;
  struct GRvg_construct *construct_list;
);

message EMextend_by_dist
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRdouble dist_in[4];
  IGRdouble dist_out[4];
  IGRint option;
  GRobjid *newid;
);

message EMextend_by_dist_from_orig_surf
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRdouble dist_in[4];
  IGRdouble dist_out[4];
  IGRint option;
  GRobjid orig_surf_id;
  GRobjid *newid;
);

override
  EMchksliver, 
  GRadd_to_display_list,
  GRchghprops,
  EMoffset,
  EMgetSurfsOfPrim,
  EMmatch_geometry,
  GRchgcolor,
  GRchglevel,
  GRchgstyle,
  GRchgweight,
  GRchgdp,
  GRputsymb,
  EMcreate_envelope_and_igds_files,
  GRstretch,
  EMputLsIfNotThere, 
  EMpostsymmod,
  EMpostgeomod,
  EMpostxform,
  EMpostdelete,
  EMpostrtree,
  GRaddwrng,
  EMget_params,
  GRplotprep,
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets,
  EMtree_display,
  EMisClassInTree,
  GRfragment,
  EMget_point_on_surface,
  EMintcopy,
  GRpostabsg,
  GRformatele,
  GRanalyze_element,
  GRptproject,
  GRlnproject,
  GRlnprocess,
  EMmovesurfs,
  GRdisyourself,
  GRkeypoint,
  GRxform,
  GRputattr,
  GRconstruct,
  EMptatpr,
  GRdynmod,
  GRmodify,
  EMpratpt,
  debug,
  EMsfsfint,
  EMalgnnrml,
  GRdelete,
  GRclipto,
  EMshow_normals,
  EMcap_yourself,
  EMdisplay_edges,
  EMgetedges,
  EMcrvsrfint,
  EMimpose_boundaries, 
  EMdelete_boundary, 
  EMmassprop,
  EMfaceintgrl, 
  EMsurfintgrl, 
  EMmk_nat_bdry, 
  EMis_surf_modif, 
  EMcompress_top, 
  EMvalidate,
  EMmake_wire_frame,          
  EMget_mdsfs_info, 
  GRgetobjinfo,
  EMisClosed,
  GRprismrel,
  GRlocate,
  GRlocate_processing,
  EMgetLoops;

#endif

end specification EMSsubbs;
