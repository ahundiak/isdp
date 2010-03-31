/*
  ABSTRACT

  DPR class for composite surface and surface make face.


  HISTORY

  Jack     07/27/93  Added override EMresetSSI. 
  RC      08/25/88  Added override EMget_mdsfs_info;
  RC      11/2/87   Modified for version 1.1.0 and added
                    num_edges_copied field to the instance data.
  DLB     10/15/87  1.1.0 class conversion
  RC      04/24/87  Creation Date
*/

class specification EMSsfmkface (1:0) of EMSsfregmod;

#include "OMmacros.h"
#include "EMSlm.h"
#include "EMSlmdef.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfmkface
{
   IGRshort     num_regions;           
   IGRshort     num_edges_out;         
   IGRshort     num_edges_copied;      
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMmake_face_execute
(
  IGRlong *EMmsg;
  struct GRid srf_GRid;
  struct GRmd_env *srf_env;
  IGRlong num_of_objects;
  struct GRlc_info object_info[];
  struct GRvg_construct *construct_list;
  IGRlong *num_of_bad_points;
  IGRpoint **bad_points;
  IGRboolean want_bad_curves;
  IGRlong *num_of_bad_curves;
  IGRlong bad_curve_indices[];
  IGRboolean want_status_message;
  IGRlong process_phase;
  IGRchar *grp_info;
  IGRushort dis_options;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRpoint track_pt;
);

message EMgraceful_exit
(
  IGRlong *EMmsg;
  struct EMSpartolbasis *partolbasis;
  struct GRmd_env *md_env;
  struct EMSsfintedpar **loops_trim_info;
  IGRint num_trim_info;
  struct EMSmkf_edcon_info *ed_con_info;
  IGRint num_edcon_entries;
  GRobjid gr1_ls_id;
  GRobjid gr2_ls_id;
  struct GRid sf_GRid;
  GRobjid sf_org_ls;
  GRobjid *sf_org_lps;
  IGRint num_sf_org_lps;
  GRobjid part_sf_id;
  IGRushort dis_options;
);

override
  EMgetInGeomIds,
  EMconstruct_associative,  
  EMgetInInfo,
  EMgetOutInfo,
  EMmatch,
  EMconnectTopology,
  EMgettreepath,
  EMcheckOverlap,
  EMgetsolidclass,
  EMsavestatedelete,
  EMintcopy,
  EMdeactivate,
  EMactivate,
  EMgetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMputSSI,
  EMget_mdsfs_info,
  NDattach_to_track_pt,
  NDdetach_from_track_pt,
  EMresetSSI;

#endif

end specification EMSsfmkface;
