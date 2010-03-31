
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"

#include "igr.h"
#include "gr.h"

#include "vedef.h"
#include "ve.h"
#include "vemem.h"
#include "ve_timing.h"


/* Global Variables Used By Visible Edges */

struct VEtolerance_info   VEtolerances               = { 0 };
struct VEexecution_parms  VEexec_parms               = { 0 };
struct VEexecution_status VEexec_status              = { 0 };
struct VEwindow_info      VEwin_info                 = { 0 };
struct VEresults_info     VEoutput_data              = { 0 };
struct GRmd_env           VEmaster_env               = { 0 };
struct VEsort_record      **VEbuckets                = NULL;
struct VEenv_info         *VEenv_list                = NULL;
struct VEid_list          *VEcommon_id_list          = NULL;
IGRchar                   VEactivated_string[20]     = { 0 };
IGRchar                   VEcompleted_string[20]     = { 0 };
IGRboolean                VEreport_errors            = FALSE;
IGRboolean                VEuse_classification_alg   = FALSE;
IGRboolean                VEcolor_classification     = FALSE;
IGRboolean                VEstroke_all_ints          = FALSE;
IGRdouble                 VEstroke_cht               = 0.0;

/* global data for saved intersection management */
struct VEint_manager VEsaved_ints                    = { 0 };

/* global data for timing */
#if TIMING
IGRint                   VEnum_proj_points           = 0;
struct tms               VEs_time                    = { 0 };
struct tms               VEe_time                    = { 0 };
IGRdouble                VEtime_part                 = 0.0;
IGRdouble                VEtime_cvcv                 = 0.0;
IGRdouble                VEtime_cvslf                = 0.0;
IGRdouble                VEtime_ptproj               = 0.0;
IGRdouble                VEtime_ptloc                = 0.0;
IGRdouble                VEtime_trim                 = 0.0;
IGRdouble                VEtime_datred               = 0.0;
IGRdouble                VEtime_water                = 0.0;
IGRdouble                VEtime_cvred                = 0.0;
IGRdouble                VEtime_multrim              = 0.0;
IGRdouble                VEtime_2sfpart              = 0.0;
IGRdouble                VEtime_shprtcl              = 0.0;
IGRdouble                VEtime_csprtcl              = 0.0;
IGRdouble                VEtime_partcsp              = 0.0;
IGRdouble                VEtime_smprtcl              = 0.0;
IGRint                   VEcount_part                = 0;
IGRint                   VEcount_cvcv                = 0;
IGRint                   VEcount_cvslf               = 0;
IGRint                   VEcount_ptproj              = 0;
IGRint                   VEcount_ptloc               = 0;
IGRint                   VEcount_trim                = 0;
IGRint                   VEcount_datred              = 0;
IGRint                   VEcount_water               = 0;
IGRint                   VEcount_cvred               = 0;
IGRint                   VEcount_multrim             = 0;
IGRint                   VEcount_2sfpart             = 0;
IGRint                   VEcount_shprtcl             = 0;
IGRint                   VEcount_csprtcl             = 0;
IGRint                   VEcount_partcsp             = 0;
IGRint                   VEcount_smprtcl             = 0;
#endif
