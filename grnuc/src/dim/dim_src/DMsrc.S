class specification DMsrc(2:0) of dim_src, DMproot;

#include "OMmacros.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dimplan.h"
#include "dimsrc.h"
#include "dimerror.h"
#include "dimacc.h"
#include "dimext.h"
#include "dimmacros.h"
#include "dimdload.h"
#include "dm_status.h"

override GRvg;

instance DMsrc
{
	char type;
	variable char data[0];
};

override NDmove_to_root;
override NDplace, NDgive_structure;
override NDcompute_node;
override DMgive_structure, DMmodify;
override DMgive_tangent;
override NDmake_source;
override GRxform;

message DMkeypt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMkeyseg_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMaxis_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DM2ptseg_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMradcen_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message compute_radcen(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list;
	struct DMradcen_str *dm_radcen);

message DMtanpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMmidpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMptdist_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMarc_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMintpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMcenpt_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message edge_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list;
	struct DMedgeseg_str *dm_edgeseg);

message DMedgept_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message DMedgeseg_compute(
	IGRint *msg;
	struct GRmd_env *md_env;
	IGRint count;
	struct GRid *list);

message find_keypoint(
	IGRint *msg;
	struct GRid as_grid;
	double u_par;
	short *matrix_type;
	IGRmatrix matrix;
	struct GRid *go_grid;
	struct IGRbsp_curve **bsp_curve;
	IGRpoint point;
	IGRpoint keypoint);

message DMgive_src_info(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct dim_src_info *src_info);

message DMdisplay_source(
	IGRint *msg;
	IGRdouble *tolerance;
	struct IGRline *boreline;
	IGRint *display;
	struct GRmd_env *md_env);

message get_dimension_plane(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct GRid *plan;
	struct DMplan_info *plan_info);

end specification DMsrc;
