/*
  ABSTRACT

  This class represents surface boundary and topology objects. It
  is the root class for all such classes.


  NOTES

  This is an abstract class. It kills instance data inherited from
  GRgraphics and rejects all messages.


  HISTORY

  SM      13-Oct-87       1.1 Genesis
  SM      30-Oct-89       Moved EMconn_my_assoc from EMSedge to here.
  DLB     3/4/91          Add EMstore.
  DLB     07/10/91        Added not_taggable.
  Jack    09/15/91        Added #include "nd.h"  This clears up strange
                          problem of multiply defined struct NDcp_list. 
  AIC	  01/11/93	  Moved EMvalidate to GRgraphics.
*/

class specification EMSboundary (1:1) of Rootmsg, GRnotify;

# include "EMSbnddef.h"
# include "EMSerrordef.h"
# include "EMSerrnumdef.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "emserr.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "lc.h"
# include "nd.h"
# include "EMSlc.h"
# ifndef EMcp_include
# include "EMcp.h"
# endif
# include "emsdef.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSboundary
{
  OM_S_OBJID    creator_id;
};

override
  GRgraphics;             

not_taggable;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetsurface_info
(
  IGRlong *EMmsg;
  GRobjid *srfid;
  struct EMSpartolbasis *partolbasis;
);

message EMget_objid
(
  IGRlong *EMmsg;
  GRobjid *my_objid;
);

reject
  GRgetprops,
  GRgethprops,
  GRgetrang,
  GRlevelcount,
  EMgetsurface_info;

#ifndef BASE_EMS

message EMcount_edges
(
  IGRlong *EMmsg;
  IGRlong option;
  IGRint *count;
);

message EMget_edges
(
  IGRlong *EMmsg;
  IGRint tree_depth;
  IGRlong option;
  struct GRid **edges;
  IGRint *array_size;
  IGRint *num_edges;
);

message EMtree_traverse
(
  IGRlong *rc;
  OM_p_MESSAGE messg;
  IGRint tree_depth;
  IGRint num_classes;
  GRclassid *classids;
  IGRushort options;
  IGRushort all_mask;
  IGRushort any_mask;
  IGRushort none_mask;
);

message EMbdrylocate
(
  IGRlong *msg;
  struct EMSsfinfo *sfinfo;
  struct EMSlcinput *lcin;
  struct GRlc_cvl *cvl;
  OM_p_KEY_DESC range_key;
  struct EMSlcoutput *lcout;
);

message EMchksliver
(
  IGRlong *msg;
  IGRushort options;
  IGRdouble uvtol;
  IGRint num_samplepts_edge;
  IGRint *num_slivers;
  GRobjid (**sliver_edges)[2];
);

message EMobint
(
  IGRlong *msg;
  struct EMSpartolbasis *mytol;
  GRobjid other_obj;
  struct EMSpartolbasis *othertol;
  IGRushort options;
  IGRint *num_inters;
  struct EMSsfintedpar **my_inters;
  struct EMSsfintedpar **other_inters;
);

message EMtpcopy
(
  IGRlong *msg;
  struct GRmd_env *mdenv;
  GRspacenum obj_osnum;
  GRspacenum new_osnum;
  IGRushort options;
  GRobjid *newobjid;
);

message EMintcopy
(
  IGRlong *EMmsg;
  struct GRmd_env *mdenv;
  GRspacenum obj_osnum;
  GRspacenum new_osnum;
  IGRushort options;
  GRobjid *newobjid;
  struct EMcp_info *copy_info;
);

message EMgetobjinfo
(
  IGRlong *EMmsg;
  struct GRobj_info *object_info;
  IGRshort es_attr;
);

message EMcompress_top
(
  IGRlong *EMmsg;
  struct EMSpartolbasis *partolbasis;
  GRobjid *newobjid;
);

message EMuv_transform
(
  IGRlong *EMmsg;
  IGRdouble matrix[16];
  struct EMSpartolbasis *partolbasis;
  IGRshort option;
  IGRchar *null_ptr1;
  IGRchar *null_ptr2;
);

message EMlinintgrl
(
  IGRlong *msg;
  struct IGRbsp_surface *surf_ptr;
  IGRchar *char_surf_info;
  IGRlong option;
  IGRlong *loop_counter;
  IGRdouble *density;
  IGRdouble *integrals;
);

message EMcheck_props
(
  IGRlong *EMmsg;
  IGRushort *ls_props;
  IGRushort *lp_props;
  IGRushort *ed_props;
);

message EMdebug_display
(
  IGRlong *msg;
  struct GRmd_env *mdenv;
  struct IGRdisplay *display_attr;
  enum GRdpmode display_mode;
);

message EMgetxyzobj
(
  IGRlong *msg;
  IGRushort options;
  struct GRmdenv_info *xyzinfo;
  struct IGRbsp_curve *xyzcv;
  IGRuchar *cvtype;
  struct GRsymbology *xyzsymb;
  struct IGResbc *xyzattr;
  GRspacenum xyzos;
  GRobjid *xyzobj;
);

message EMmk_act_cm_eds_connectable
(
  IGRlong *EMmsg;
  IGRint tree_depth;
  struct GRmd_env *md_env;
  IGRint *num_act_cm_eds;
  IGRint *act_cm_eds_buf_size;
  GRobjid **act_cm_eds;
  IGRint *num_new_cm_eds;
  IGRint *new_cm_eds_buf_size;
  GRobjid **new_cm_eds;
);

message EMarea
(
  IGRlong *msg;
  IGRdouble *area;
);

message EMchkbindings
(
  IGRlong *msg;
  IGRushort options;
  GRobjid *components;
);

message EMpostdelete
(
  IGRlong *msg;
  IGRushort options;
  struct GRmd_env *model_env;
);

message EMpostxform_xyz
(
  IGRlong *msg;
  IGRushort options;
  struct GRmd_env *model_env;
  IGRshort *xmattyp;
  IGRmatrix *xmat;
);

message EMremmsc
(
  IGRlong *msg;
  IGRushort options;
);

message EMputmsc
(
  IGRlong *msg;
  IGRushort options;
  GRobjid mscobj;
);

message EMpostrtree
(
  IGRlong *msg;
  IGRboolean add;
  IGRushort options;
  struct GRmd_env *model_env;
);

message EMcoincedges
(
  IGRlong *msg;
  GRobjid ref_edge;
  struct EMSpartedinfo *ref_partinfo;
  IGRdouble *ref_range;
  struct IGRbsp_curve *ref_geom;
  struct EMSpartolbasis *partolbasis;
  IGRint *num_coinc;
  struct EMSpypoint **pts_on_ref;
  struct EMSsfintedpar **pts_on_coinc;
);

message EMreturn_my_id
(
  IGRlong *msg;
  IGRint *numobjs;
  GRobjid **objlist;
);

message EMsendtomsc
(
  IGRlong *msg;
  OM_p_MESSAGE messg;
  IGRushort options;
);

message EMconn_to_myassoc
(
  IGRlong *msg;
  IGRint num_conobjs;
  GRobjid *conobjs;
);

message EMget_put_creator_id
(
  IGRlong *EMmsg;
  GRobjid *creator_id;
  IGRboolean put_it;
);

message EMmatch_topology
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

message EMget_dependents
(
  IGRlong *EMmsg;
  int options;
  struct GRid *context_GRid;
  IGRint *dependent_count;
  struct GRid **dep_GRid;
);

reject
  GRprismrel,
  GRgetobjinfo,
  GRapprojpt,
  GRptproject,
  GRlnproject,
  GRlocate,
  GRlocate_processing,
  EMchksliver,
  GRlocaldp,
  GRdisyourself,
  GRcopy,
  GRclip,
  GRcptform,
  GRdelete,
  GRdisplay,
  GRchgprops,
  GRgentform,
  GRxform,
  GRconstruct,
  GRaltconstruct,
  GRformatele,
  GRplotyourself,
  GRaddwrng ,
  GRremwrng ,
  GRcpforundo,
  GRundocp,
  GRfunction,
  GRidchanged,
  EMgetxyzobj,
  EMgetobjinfo, 
  EMlinintgrl,
  EMobint,
  EMintcopy,
  EMcompress_top,
  EMuv_transform,
  EMlinintgrl,
  EMcheck_props, 
  EMdebug_display, 
  EMmk_act_cm_eds_connectable,
  EMarea,
  EMcount_edges, 
  EMget_edges, 
  EMtree_traverse,
  EMchkbindings,
  EMpostdelete,
  EMpostxform_xyz,
  EMremmsc,
  EMputmsc,
  EMpostrtree,
  EMcoincedges,
  EMsendtomsc,
  EMbdrylocate,
  EMmatch_topology;
                 
override 
  GRmksource,
  GRprint,
  GRread;

#endif

end specification EMSboundary;
