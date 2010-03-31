/*
  ABSTRACT

  This class represents a composite surface as a collection
  of surfaces whose common edges are connected. 
  The definition of a composite surface DOES NOT ensure that all edges
  will have a common edge.


  HISTORY

  SCW 08/23/93    Added EMchksliver to override list
  ashok 05/01/93    Added EMshell message.
  AMD 02/22/93    Removed NDmove_to_root override
  SB	01/20/93    Overriding EMoffset - Sampath.
  PP  06/08/92    Inheriting GRmksource from EMAsurface.
  TGM 07/30/91    Un-Rejected GRkeypoint.
  DLB 03/19/91    Subclass from EMAsurface.
  RC  08/25/89    Changed EMwrite_to_envelope_file to
                  EMcreate_envelope_and_igds_files.
  RC  05/25/89    Added EMwrite_to_envelope_file overrride.
  29 Sep 1988 jBk Added EMgetLoops override.
  RC  11/22/88    Added override EMget_mdsfs_info;
  DLB 11/20/88    Override EMgetSurfsOfPrim.
  AIC 15-Jun-88   Remove rejection of GRlocate.
  dhm 05/16/88    Overrode GRgetsfsize and GRloadform
  AIC 23-Feb-88   Reject GRkeypoint for efficiency of tentative
                  keypoint snap.
  dhm 02/10/88    Removed the reject of the method GRlocaldp.
  SM  20-Jan-88   override EMmake_wire_frame.
  RV  12/03/87    Added EMdisplay_edges, removed EMjoincs override.    
  RC  11/17/87    Inherit GRcopy from EMSsurface
  RC  11/07/87    Removed EMlm_make_face and EMlm_lift messages
  SM  05-Nov-87   Removed override for EMintplane_saveside.
  DLB 10/29/87    Changed EMcompress_top from decl to override (from surf)
                  Removed GRgetatt from override list (moved to composite)
  DLB/AIC 9/22/87 Class conversion for 1.1.0
  RV  01-Spt-1987 Added make composite,
                  added EMjoincs, EMgetedges overrides.
  rlw 12-May-1987 Added curve/surface intersection message
  NG  06-May-1987 Remove EMlmmove and EMlmsplit overrides.
  DLB 06-May-1987 Added EMcompress_top message.
  AIC 03/09/87    Creation Date
  Vadi  01/31/95      Overriding GRanalyze_element inherited from GRgraphics.
*/

class specification EMScompsurf (2:0) of EMAsurface, EMScomposite;

# include "EMS.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include <stdio.h>

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

reject
  GRgenabsg,
  GRgetsize, 
  GRgetgeom;

from EMSsurface inherit 
  GRclip;

override
  GRgeomprops,
  EMrevorient;


#ifndef BASE_EMS

message EMtree_traverse
(
  IGRlong *EMmsg;
  OM_p_MESSAGE messg;
  IGRint num_classes;
  GRclassid *classids;
  IGRboolean down;
);

message EMget_free_edge
(
  IGRlong *EMmsg;
  struct GRlc_info *comp_sf;
);

message EMcap_comp
(
  IGRlong *EMmsg;
  struct GRmd_env *grmd_env;
  struct GRvg_construct *construct_list;
  IGRboolean care_coincidency;
);

message EMreset_density
(
  IGRlong *EMmsg;
  IGRdouble *density;
);

message ECtrmcmpsfs
(
  struct GRlc_info **crvs_info;
  IGRint num_crvs;
  struct GRlc_info *compsf_info;
  IGRushort imp_options;
  IGRint num_lrgst_crvs;
  IGRint *crv_index;
  IGRlong crv_reversed;
  GRobjid *lrgst_cmpid;
  IGRboolean is_associative;
  IGRint *num_bad_pts;
  IGRdouble **bad_pts;
  struct GRid *dprid;
  IGRlong *EMmsg;
);

message EMshell
(
  IGRlong *msg;
  IGRushort option;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct GRvg_construct *construct_list;
  IGRboolean offset_inward;
  IGRboolean offset_symmetric;
  IGRdouble distance;
  IGRint num_spec_thick;
  IGRdouble *val_spec_thick;
  struct GRobjid_set *spec_thick_sf_sets;
  IGRint num_nooffsetsfs;
  GRobjid *nooffsetsfs;
  IGRchar *status_str;
  OM_S_OBJID *constructed_object;
  struct EMSerror_help *errkey_list;
);


reject 
  GRcpforundo,
  GRundocp,
  GRidchanged, 
  GRmodify,
  GRpostabsg,
  GRdynmod,
  GRfragment,
  EMpratpt, 
  EMptatpr,
  EMgetpoles,
  GRputattr,
  GRgetexgeom,
  GRgetexsize;

from EMSsurface inherit 
  GRcopy, EMintplane, GRmksource,
  GRprint, GRread;

override
  GRget_number_components,
  GRget_components,
  GRptproject,
  GRgetobjinfo,
  GRlocate_owner,
  GRaddwrng,
  GRremwrng,
  GRdelete,
  GRxform,
  EMmatch_geometry,
  EMupdate_all_xsec, 
  EMcreate_envelope_and_igds_files,
  EMgetSurfsOfPrim,
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  GRremove_components,
  EMtree_display,
  EMisClassInTree,
  GRdrop,
  GRconstruct,
  EMcompress_top,
  EMsfsfint,
  EMmovesurfs,
  EMintcopy,
  EMalgnnrml,
  EMshow_normals,
  EMgetedges,
  EMmassprop,
  EMfaceintgrl,
  EMcrvsrfint,
  EMget_point_on_surface,
  EMdisplay_edges, 
  EMvalidate,
  EMmake_wire_frame, 
  EMdelete_boundary,
  EMget_mdsfs_info, 
  GRdisyourself,      
  EMoffset,
  EMchksliver,
  GRanalyze_element,
  EMgetLoops;

#endif

end specification EMScompsurf;
