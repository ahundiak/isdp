/* ###################   APOGEE COMPILED   ################## */
class specification GRaxhatch (2:0) of EMSassoc, GRowner;

#include "grxhatch.h"

/* ************************************************************************
Description
 This class provides implementation for support of associative crosshatch
 objects.

History
 Creation : WBC : 11/01/91
   ************************************************************************ */


message GRxhadd_bdry(IGRlong                *msg; 
                     IGRint                  num_boundaries;
                     struct EMSobject_info  *boundaries);

message GRxhremove_bdry(IGRlong         *msg; 
                        IGRint           num_boundaries;
                        struct GRid     *boundaries);

message GRxhget_definition(IGRlong            *msg; 
                           IGRshort           *alt_color;
                           IGRdouble          *alt_angle;
                           IGRdouble          *alt_spacing;
                           IGRdouble          *origin;
                           struct GRxhatchpat *pattern_def;
                           struct GRid        *window_grid);

message GRxhput_definition(IGRlong            *msg;
                           IGRshort           *alt_color;
                           IGRdouble          *alt_angle;
                           IGRdouble          *alt_spacing;
                           IGRdouble          *origin;
                           struct GRxhatchpat *pattern_def;
                           struct GRid        *window_grid);

message GRxhcompute(IGRlong               *msg;
                    struct GRid           *elem_to_xhatch;
                    struct GRmd_env       *module_info;
                    IGRint                 num_boundaries;
                    struct GRid           *boundaries;
                    struct GRaxhatch_info *xhatch_info;
                    struct GRid           *xhatch_gg);

message GRxhget_gg(IGRlong           *msg;
                    struct GRid      *xhatch_gg);

override EMconstruct_associative,
         GRdisplay,
         GRlocate_owner,
         NDparent_deleted;

end specification GRaxhatch;
