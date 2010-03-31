/* ###################   APOGEE COMPILED   ################## */
class specification ECsfedloc (1:0) of COconst;


# include "igr.h"
# include "OMminimum.h"
# include "dp.h"
# include "godef.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "FI.h"
# include "EMSaction.h"
# include "emsdattyp.h"
# include "EMSasnuc.h"
# include "EMSrnd.h"

/*

HISTORY

07/15/96        Prashant Added variable subform_displayed to instance data

05/05/93	Vidya   Added locate_vertex_obj to instance
			Added num_bkp_entries ,num_bkp_list for
			backups
04/01/03        SCW     Added locate_ref_obj flag to instance data

11/25/92 	Tapadia Support for new rounding interface (phoenix). Overrode
			status_disp. Added new methods locate_rnd_edge(), 
			locate_surf_edge(), locate_chain_edge(), 
			locate_concave_convex_edge();
			Added some new instance data.
04/24/91        DLB     Changed edgeval to edgeval_event; 
                        added uniformval_event.
April, 1991     AMD     Creation 

*/

struct pseudo_vertex
{
 GRobjid       vertexid;
 IGRint        vertex_numed;
};

struct rnd_surfloop_selhndlr {
	struct GRid my_inst;
	IGRint edge_type;
};

struct rnd_surf_loc_acthndlr {
	struct rnd_surf_loc_acthndlr *next;
	IGRlong option;
	IGRlong num_objects;
	OMuword *classids;
	IGRchar *acc_prompt;
	struct GRid my_inst;
};
   

struct rnd_cacx_loc_acthndlr {
	struct rnd_cacx_loc_acthndlr *next;
	IGRlong option;
	struct GRid sol_id;
	struct GRid my_inst;
};

struct chain_edge_data {
	GRobjid *edge_id;
	struct GRevent chain_var_start;
	struct GRevent chain_var_end;
	IGRint numedges;
};
	
struct group_edge_data
{
	GRobjid edge_id;
	IGRint  group_id;
};
   
instance ECsfedloc
{
  struct         GRevent       loc_event; /* used for locate purpose */
  struct         GRevent       event;     /* get events */
  struct         GRlc_info     locate_info;
  struct         GRlc_stack    locate_stack;
  variable 	 struct chain_edge_data var_chain_edges[10];
  variable       GRobjid       located_obj[10];
  variable       GRobjid       tmp_located_obj[10];	/* Number of edges in
							temporary list */
  variable       struct GRevent edgeval_event[10];     	/* Start radius value */
  variable       struct GRevent end_edgeval_event[10]; 	/* End radius values */
  variable       IGRboolean    rt_vertex[10];
  struct GRid    active_GRid;     	/* active solid id of the round op. */
  struct GRid    rnd_construct_id;    	/* active id after the round op. */
  struct GRid    act_surf_id;           /* active id of the surface selected */
  IGRint        numed;		/* Final edge count */
  IGRint  	num_vertex; 
  IGRint 	process_state; 
  IGRint 	numtmped;	/* Temporary edge count */
  IGRint 	numtmp_chain_links;	/* Temporary chain count */
  IGRdouble      uniformval;
  struct GRevent uniformval_event;
  variable       struct pseudo_vertex  vertex[10] ;
  IGRdouble 	neutral_edge_angle;	/* user defined neutral edge definition
					*/
  IGRboolean 	selection; 	/* Selection or de-selection option */
  IGRboolean	fillet_out;	/* Do you want to process round or give the
				fillet ids */
  IGRushort 	form_displayed, subform_displayed; 
  IGRint 	fillet_type, edge_type, sel_type;
  IGRdouble 	active_rad;		/* the current radius value */
  Form 		form, sub_form;  
  variable	struct EMSrnd_boundary_input edge_info[10];
  variable 	IGRint 	fill_typ[10];	/* Information about the round fillet - 
					variable or constant radius */
  variable IGRushort 	bound_code[10];	/* Previous boundary code */
  IGRboolean    option_change; /* set to TRUE, if option is changed in form*/
  IGRboolean    radius_changed; /* toggled whenever radius is changed */
  IGRboolean    inner_loop;
  IGRboolean    locate_ref_obj;
  IGRboolean    valid_inputdata; /* if user-input is valid,set to TRUE */
  IGRboolean    locate_vertex_obj; /* set to TRUE,if vertex is found &
				      used only in Single edge/vertex option */
  IGRint	num_bkp_entries; /* number of backup entries */
  variable      IGRint	num_bkp_list[5];	/* count of edges for 
					   each backup entry */
IGRint numround[10];      /* number of edges in each group */ 
IGRint numgroup;          /* number of groups */
IGRint group_id[10];      /* group id of each edge */
struct group_edge_data group_edge_info[10];
 };

/* 
	This method locates edges using the chamfer edge option
	File: EMedgeloc.I
*/

message locate_edge( IGRlong *msg; IGRint *response; IGRchar *response_data;
                     	IGRchar *prompt_string; char (*funcptr) () );

/* 
	This method locates vertixes using the chamfer vertex option
	File: EMvtxloc.I
*/

message locate_vertex(IGRlong *msg; IGRint *response; IGRchar *response_data;
                      	IGRchar *prompt_string; char (*funcptr) () );

/* 
	This method locates edges using the single edge/vertex option.
	File: EMrndedloc.I 
*/

message locate_rnd_edge(IGRlong *msg; IGRint *response; IGRchar *response_data;
                     	IGRchar *prompt_string; char (*funcptr) ());

/* 
	This method locates edges using the surface loop option 
	File: EMrndsurfloc.I 
*/

message locate_surf_edge(IGRlong *msg; IGRint *response; IGRchar *response_data;
                     	IGRchar *prompt_string; char (*funcptr) ());

/* 
	This method locates edges using the chain edge option 
	File: EMrndchailoc.I 
*/

message locate_chain_edge(IGRlong *msg; IGRint *response; 
			IGRchar *response_data; IGRchar *prompt_string; 
			char (*funcptr) ());

/* 
	This method locates edges using the fillet (concave)/all radii (convex) 
	option 
	File: EMrndcacxloc.I 
*/

message locate_concave_convex_edge(IGRlong *msg; IGRint *response; 
			IGRchar *response_data; IGRchar *prompt_string; 
			char (*funcptr) ());

/* 
	This method sets up the instance data needed by the form_input method
	File: EMrndform.I
*/

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

/* Action handler used for finding out if a surface has inner loops */

message rnd_surf_action_handler(struct rnd_surf_loc_acthndlr *rnd_surf_act;
	struct GRlc_info *new_entry;
	struct LC_action_args *loc_args;
	enum GRlocate_action *action);

message EMdisplay_surfloop_elig_edges(IGRint edge_type;IGRshort *mattyp; 
	IGRdouble *mat;
	enum GRdpmode d_mode;
	GRobjid lp_id;GRspacenum lp_osnum);


override 
	status_disp,
	init, 
	sleep, 
	wakeup, 
	execute;

end specification ECsfedloc;
