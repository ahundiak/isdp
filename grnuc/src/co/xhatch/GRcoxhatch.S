/* #######################    APOGEE COMPILED   ######################## */
class specification GRcoxhatch (1:1) of GRlistener,GRcmpowner,GRconnector;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "grxhatch.h"

instance GRcoxhatch
{
    IGRchar               xhatch_pattern_name[80];
    IGRshort              xhatch_color;       
    IGRdouble             xhatch_spacing;
    IGRdouble             xhatch_angle;
    IGRboolean            associative_flag;
    IGRpoint              origin;
    struct GRxhatchpat    pattern_def;
    struct GRid           window_grid;
    channel {(many_to_many, rel_ordered, initial=2, increment=2)} to_notify;
    channel {(one_to_many, rel_ordered, initial=2, increment=2)} to_context;
};

override GRnotifylis,GRdisplay,GRdisyourself;

message GRxhinit(IGRlong            *msg;
                 struct GRid        *wireframe_go;
                 struct GRid        *window_grid;
                 IGRboolean          xhatch_assoc_flag;
                 IGRshort            xhatch_color;
                 IGRdouble           xhatch_spacing;
                 IGRdouble           xhatch_angle;
                 IGRdouble          *origin;
                 struct GRxhatchpat *pattern_def);

message GRxhadd_bdry(IGRlong         *msg; 
                     struct GRid     *cob_id;
                     OM_S_CHANSELECT *p_co_chanselect);

message GRxhremove_bdry(IGRlong         *msg; 
                        struct GRid     *cob_id;
                        OM_S_CHANSELECT *p_co_chanselect);

message GRxhget_definition(IGRlong            *msg; 
                           IGRshort           *alt_color;
                           IGRdouble          *alt_angle;
                           IGRdouble          *alt_spacing;
                           IGRboolean         *associative_flag;
                           IGRdouble          *origin;
                           struct GRxhatchpat *pattern_def);

/* */
message GRxhput_definition(IGRlong            *msg; 
                           IGRshort           *alt_color;
                           IGRdouble          *alt_angle;
                           IGRdouble          *alt_spacing;
                           IGRboolean         *associative_flag;
                           IGRdouble          *origin;
                           struct GRxhatchpat *pattern_def);

message GRxhupdate_definition(IGRlong            *msg; 
                              struct GRxhatchpat *pattern_def);

message GRxhcompute(IGRlong          *msg;
                    struct GRmd_env  *module_info;                    
                    struct GRid      *xhatch_gg);

message GRxhget_gg(IGRlong           *msg;
                    struct GRid      *xhatch_gg);

message GRxhget_addl_info(IGRlong          *msg;
                          struct GRid      *window_id);

end specification GRcoxhatch;
