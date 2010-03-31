class specification VEedgescmds (1:0) of CEO_GSLOCATE;



#include "grdpbdef.h"
#include "grdpb.h"
#include "godef.h"

#include "vedef.h"
#include "ve.h"
#include "ve_inst.h"

#include "FI.h"


instance VEedgescmds
{
	/* instance data required by all VE commands */
	IGRdouble           cht;                              /* current CHT                    */
	struct GRid         gragad;                           /* GRid of selected window        */
	IGRchar             gragad_name[GRNAME_SIZE];         /* name of selected window        */
	IGRdouble           vvol[6];                          /* view volume of selected window */

	/* instance data gathered from the form */
	struct GRhesym      visible_symb;                     /* symbology for visible edges    */
	struct GRhesym      hidden_symb;                      /* symbology for hidden edges     */
	IGRushort           visible_level;                    /* level for visible output       */
	IGRushort           hidden_level;                     /* level for hidden output        */
	IGRushort           text_level;	                      /* level for copied text          */
	IGRuint             ve_vhl_flags;                     /* VEdpb flags word               */
	IGRuint             hs_vhl_flags;                     /* vhl flags word                 */
	IGRdouble           gapping_distance;                 /* gapping distance               */
	IGRdouble           trace_tol;                        /* tracing tolerance              */
	struct VEbatch_info batch_info;                       /* batch job info. for window     */
        IGRshort            surf_threshold;                   /* surface reduction threshold    */
        IGRshort            curve_threshold;                  /* curve reduction threshold      */
	IGRchar             results_name[RESULTS_FNAME_SIZE]; /* results file name              */
	IGRchar             server[SERVER_SIZE];              /* batch server name              */
	IGRchar             user_name[USER_NAME_SIZE];        /* batch user name                */
	IGRchar             password[PASSWORD_SIZE];          /* batch password                 */
	IGRchar             start_time[START_TIME_SIZE];      /* batch job start time           */
	IGRboolean          hidden_line_display;              /* hidden line display on/off     */
	};


message put_event_back_on_queue ( long * sts );

message spawn_elements_in_view ( long * sts );

message fix_cell_locate ( IGRint *sts; IGRint on0_off1 );

message cleanup ( long * sts );

message initialize_instance_data ( long * sts );

message get_window_by_object_id ( long * sts );

message get_selected_window ( long * sts );

message get_background_confirmation ( long * sts );

message read_or_set_dpb_data ( IGRint *sts; IGRint read0_set1; );

message process ( IGRint *sts; IGRint batch_mode );

end specification VEedgescmds;
