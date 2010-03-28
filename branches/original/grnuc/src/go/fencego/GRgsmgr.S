/*
Name
        GRgsmgr - graphic set manager

Description
        This class manages the active fence, active select set, and the
        current locate criteria. 

History
        Gray Winn   11/02/86    Design and Coding Date.
                    06/15/87    Add methods to manage the current locate
                                criteria.
                    09/18/87    Changes for 1.1, subclass of of GRcmpowner
                    10/05/88    Changes to become a message interceptor for
                                the active fence.
        mrm         11/07/89    removed GRplotobject
*/

class specification GRgsmgr (1:1) of IGEwinsup, global_class, GRgraphics,
                                     GRconnector, GRcmpowner;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "lcdef.h"
#include "griodef.h"
#include "dpdef.h"

override 
   unknown,             /* Root           - Pass message to fence       */
   pre_update,          /* IGEwinsup      - Receiving update from window*/
   post_update,         /* IGEwinsup      - Cleanup from update.        */
   pre_single_display,  /* IGEwinsup      - Receiving update from window*/
   post_single_display, /* IGEwinsup      - Cleanup from update.        */
   pre_delete,          /* IGEwinsup      - Window is being deleted.    */
   wake_up,             /* global_class   - Set up message interception */
   sleep,               /* global_class   - Empty the select set        */
   GRcopy,              /* GRgraphics     - Fence can not be copied.    */
   GRclip,              /* GRgraphics     - Override for efficiency.    */
   GRdisyourself,       /* GRgraphics     - Fence displays in one window*/
   GRplotyourself,      /* GRgraphics     - Fence should not plot.      */
   GRcptform,           /* GRgrapihcs     - Fence can not be copied.    */
   GRlocate,            /* GRgraphics     - Fence locates in one window.*/
   GRgetobjinfo,        /* GRgraphics     - Get object specific info    */
   GRconstruct,         /* GRgraphics     - Pass message to fence       */
   GRlocaldp,           /* GRgraphics     - Pass message to fence       */
   GRapprojpt,          /* GRgraphics     - Pass message to fence       */
   GRptproject,         /* GRgraphics     - Pass message to fence       */
   GRlnproject,         /* GRgraphics     - Pass message to fence       */
   GRlocate_processing, /* GRgraphics     - Pass message to fence       */
   GRdelete,            /* GRgraphics     - Pass message to fence       */
   GRdisplay,           /* GRgraphics     - Pass message to fence       */
   GRgetprops,          /* GRgraphics     - Pass message to fence       */
   GRgethprops,         /* GRgraphics     - Pass message to fence       */
   GRplotprep,          /* GRgraphics     - Pass message to fence       */
   GRgentform,          /* GRgraphics     - Pass message to fence       */
   GRcpforundo,         /* GRgraphics     - Pass message to fence       */
   GRundocp,            /* GRgraphics     - Pass message to fence       */
   GRrcopy,             /* GRgraphics     - Pass message to fence       */
   GRchgprops,          /* GRgraphics     - Pass message to fence       */
   GRfunction,          /* GRgraphics     - Pass message to fence       */
   GRxform,             /* GRgraphics     - Pass message to fence       */
   GRaltconstruct,      /* GRgraphics     - Pass message to fence       */
   GRformatele,         /* GRgraphics     - Pass message to fence       */
   GRaddwrng,           /* GRgraphics     - Pass message to fence       */
   GRremwrng,           /* GRgraphics     - Pass message to fence       */
   GRprismrel,          /* GRgraphics     - Pass message to fence       */
   GRidchanged,         /* GRgraphics     - Pass message to fence       */
   GRgetrang,           /* GRgraphics     - Pass message to fence       */
   GRlevelcount,        /* GRgraphics     - Pass message to fence       */
   GRreport,            /* GRgraphics     - Pass message to fence       */
   GRreport_defaults,   /* GRgraphics     - Pass message to fence       */
   GRupdate_gadgets,    /* GRgraphics     - Pass message to fence       */
   GRptprocess,         /* GRgraphics     - Pass message to fence       */
   GRlnprocess,         /* GRgraphics     - Pass message to fence       */
   GRflexconn,          /* GRconnector    - Can not belong to groups.   */
   GRrigidconn,         /* GRconnector    - Can not belong to groups.   */
   GRdisconn;           /* GRconnector    - Pass message to fence       */

override  GRanalyze_element;

instance GRgsmgr
{
   IGRshort fence_properties; /* Contains properties for display */

   /*
    * select_set - channel to the active select set.
    */

   channel {(many_to_many, rel_ordered, initial=2, increment=2)}select_set;
   
   /*
    *  The following information allows for posting of the locate criteria.
    */

   IGRint               posted_info_properties;          /* properties  */
   IGRint               levels[DP_NUM_OF_LEVELS/32 + 1]; /* levels      */
   struct GRmd_env      locate_env;          /* Locate environment      */
   struct GRlc_locate   attributes;          /* Attributes              */
   OM_S_CLASSLIST       rtree_classlist;     /* The rtree class list    */
   OM_S_CLASSLIST       eligible_classlist;  /* The eligible class list */
   variable OMuword     rtree_classes[];     /* Rtree class id's        */
   variable OMuword     eligible_classes[];  /* Eligible class id's     */
};

message GRget_prism_size (IGRlong *msg; struct GRmd_env *mod_env;
                          IGRint *type; IGRint *size;
                          IGRint *num_poles; IGRint *num_weights;
                          IGRint *num_knots; IGRint *num_boundaries);
/*\
Name
   GRget_prism_size

Description
   This method returns the size of the buffer needed to contain the
   prism geometry.

Arguments
   *msg              IGRlong          o   completion code
   *mod_env          struct GRmd_env  i   The module environment. 
   *prism_type       IGRint           o   The type of the prism
                                             -  GR_RIGHT_PRISM
                                             -  GR_CURVE_PRISM
   *size             IGRint           o   Total size of the prism geometry.
   *num_poles        IGRint           o   The number of poles or points;
   *num_weights      IGRint           o   The number of weights
   *num_knots        IGRint           o   The number of knots
   *num_boundaries   IGRint           o   The nubmer of boundaries;
 
Return Values
   MSSUCC  -- successful completion
\*/

message GRget_prism (IGRlong *msg; struct GRmd_env *mod_env;
                     IGRint formatted; IGRchar *prism;
                     struct GRid *window_id);
/*\
Name
   GRget_prism

Description
   This method returns a prism which represents the fence object.

Arguments
   *msg           IGRlong          o   completion code
   *mod_env       struct GRmd_env  i   The module environment. 
   formatted      IGRint           i   Flag signifing if prism is formated.
                                          if 0 - prism is unformated buffer
                                          if 1 - prism is formated
   *prism         IGRchar          i/o Pointer to the prism
   *window_id     struct GRid      o   object id of the window.

Notes
   The prism or the window_id may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRget_prism_extents (IGRlong *msg; struct GRmd_env *mod_env;
                             GRrange range);
/*\
Name
   GRget_prism_extents

Description
   This method returns the range of the prism.

Arguments
   *msg        IGRlong             o   completion code
   *mod_env    struct GRmd_env     i   The module environment. 
   range       GRrange             o   Prism range

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRpre_clip (long *msg; IGRshort *mode);
/*\
Name
   GRpre_clip

Description
   This method is a pre clip message sent to the fence so that it will
   know whether to be inside or outside.

Arguments
   *msg         IGRlong      o   completion code
   *mode        IGRshort     i   flag  -  GRFN_CLIP_INSIDE
                                       -  GRFN_CLIP_OUTSIDE

Return Values
   MSSUCC  -- successful completion
\*/

message GRget_fence (IGRlong *msg; struct GRid *fence_id);
/*\
Name
   GRget_fence

Description
   This method returns the active fence.

Arguments
   *msg         IGRlong      o   completion code
   *fence_id    struct GRid  o   object id of the active fence.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRput_fence (IGRlong *msg; struct GRmd_env *mod_env;
                     struct GRid *fence_id; struct GRid *window_id);
/*\
Name
   GRput_fence

Description
   This method defines the given fence as the active fence.

Arguments
   *msg         IGRlong         o   completion code
   *mod_env     struct GRmd_env i   The active module environment.
   *fence_id    struct GRid     i   object id of the active fence.
   *window_id   struct GRid     i   object id of the window.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRget_select_set (IGRlong *msg; struct GRid *select_set_id);
/*\
Name
   GRget_select_set

Description
   This method returns the active select set.

Arguments
   *msg           IGRlong       o   completion code
   *select_set_id struct GRid   o   object id of the active select set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRput_select_set (IGRlong *msg; struct GRmd_env *mod_env;
                         struct GRid *select_set_id);
/*\
Name
   GRput_select_set

Description
   This method defines the given graphics set as the active select set.

Arguments
   *msg         IGRlong         o   completion code
   *mod_env     struct GRmd_env i   The active module environment.
   *select_set_id struct GRid   i   object id of the active select set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRput_locate_criteria (IGRlong *msg; struct GRmd_env *locate_env;
                               struct GRlc_locate *attributes;
                               OM_p_CLASSLIST rtree_classes;
                               OM_p_CLASSLIST eligible_classes;
                               IGRint  *levels);
/*\
Name
   GRput_locate_criteria

Description
   This method will put the locate criteria.

Arguments
   *msg              IGRlong             o   Return code
   *locate_env       struct GRmd_env     i   The environment for a locate
   *attributes       struct GRlc_locate  i   The attributes describing the
                                             criteria that the object must
                                             pass.
   rtree_classes     OM_p_CLASSLIST      i   The rtree classes
   eligible_classes  OM_p_CLASSLIST      i   The eligible classes
   *levels           IGRint              i   The levels to search.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRget_number_rtree_classes (IGRlong *msg; IGRint *count);
/*\
Name
   GRget_number_rtree_classes

Description
   This method will get the number of rtree classes in the posted
   locate criteria.

Arguments
   *msg              IGRlong          o   Return code.
   *count            IGRint           o   The number of rtree classes

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRget_number_eligible_classes (IGRlong *msg; IGRint *count);
/*\
Name
   GRget_number_eligible_classes

Description
   This method will get the number of eligible classes in the
   posted locate criteria.

Arguments
   *msg              IGRlong          o   Return code.
   *count            IGRint           o   The number of eligible classes

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/

message GRget_locate_criteria (IGRlong *msg; IGRint *criteria_flag;
                               struct GRmd_env *locate_env;
                               struct GRlc_locate *attributes;
                               OM_p_CLASSLIST rtree_classes;
                               OM_p_CLASSLIST eligible_classes;
                               IGRint  *levels);
/*\
Name
   GRget_locate_criteria

Description
   This method will get the locate criteria.

Arguments
   *msg              IGRlong             o   Return code.
   *criteria_flag    IGRint              o   A flag which has a bit set
                                             for each item returned.
   *locate_env       struct GRmd_env     o   The environment for a locate
   *attributes       struct GRlc_locate  o   The attributes describing the
                                             criteria that the object must
                                             pass.
   rtree_classes     OM_p_CLASSLIST      o   The rtree classes
   eligible_classes  OM_p_CLASSLIST      o   The eligible classes
   *levels           IGRint              o   The levels to search.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure
\*/
end specification GRgsmgr;
