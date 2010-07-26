#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "gr.h"

#include "DEso.h"

#include "DPdlist.h"

struct DPdlist_hash_table *DPhash_tables = NULL;

IGRdouble *DPdlist_fb_buffer = NULL;

IGRboolean DPdlist_use_display_list = TRUE;

IGRboolean DPdlist_feedback_in_progress = FALSE;
IGRdouble DPdlist_stroke_tolerance = 0.01;

int DPdlist_wf_fb_pipe_id;

struct GRid DPdlist_wf_fb_gragad;
struct GRid DPdlist_sh_fb_gragad; 

IGRboolean DPdlist_display_tangent_edges = TRUE;

IGRboolean DPdlist_performance_boost = FALSE;
