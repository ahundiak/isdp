
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

class specification VEdpb (2:0) of global_class;

/*
DESCRIPTION
	Class that contains the global data for Visible Edges

HISTORY
	S.P. Rogers  04/22/91  Creation Date
*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"

#include "vedef.h"

instance VEdpb
	{
	IGRuint    flags;                            /* flags word                                 */
        IGRdouble  gapping_distance;                 /* gapping distance                           */
	IGRdouble  trace_tol;                        /* tracing tolerance                          */
        IGRshort   surf_threshold;                   /* surface reduction threshold                */
        IGRshort   curve_threshold;                  /* curve reduction threshold                  */
	IGRchar    server[SERVER_SIZE];              /* last server used for a background job      */
	IGRchar    user_name[USER_NAME_SIZE];        /* last user name used for a background job   */
	IGRchar    password[PASSWORD_SIZE];          /* last password used for a background job    */
	IGRchar    results_file[RESULTS_FNAME_SIZE]; /* last results file used in a background job */
	IGRchar    start_time[START_TIME_SIZE];      /* last start time used in a background job   */
	};


override super_construct, debug;

message copy_instance_to_other_VEdpb( OM_S_OBJID objid; OMuword osnum );

message get_flags( IGRuint *flags );
message set_flags( IGRuint flags );

message get_gapping_distance( IGRdouble *gapping_distance );
message set_gapping_distance( IGRdouble gapping_distance );

message get_trace_tol( IGRdouble *trace_tol );
message set_trace_tol( IGRdouble trace_tol );

message get_reduction_thresholds( IGRshort *surf_threshold; IGRshort *curve_threshold );
message set_reduction_thresholds( IGRshort surf_threshold; IGRshort curve_threshold );

message get_last_bg_info( IGRchar *last_server; IGRchar *last_user_name;
	                  IGRchar *last_password; IGRchar *last_results_file; IGRchar *last_start_time );
message set_last_bg_info( IGRchar *last_server; IGRchar *last_user_name;
	                  IGRchar *last_password; IGRchar *last_results_file; IGRchar *last_start_time );

end specification VEdpb;

