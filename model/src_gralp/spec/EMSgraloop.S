/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class specification EMSgraloop (2:0) of EMScreator, EMShelper, EMSassoc, EMSloop;
/*
Abstract

    This class represents graphics loops, or sets of graphics-only
    edges. These loops (and their edges) are of no topological or
    geometric significance.

Notes

    This class replaces EMSfeaturelp.

    EMSgraloop stores the clipping information, rather than making use
    of part-edges. The number of clips and the transition values are
    stored for each edge. The edge is assumed to begin in an area,
    unless the first transition is on span_inx=0, param=0.0.

    As an optimization, the data structure for this class can be
    optimized by:

        a) storing all EMSedgebound.param's (double) in sequence,
           followed by all EMSedgebound.span_inx (short), and

        b) storing all instance data in a single VLA.

History

    AIC/Jack/SCW   08-MAR-91   Genesis
    Jack           13-June-91  Added override of EMget_the_edges 
                               message. 
    WBC            20-June-91  Added override of EMgetsurface_info
                               message.
    DLB            07/10/91    Disable tagging.
    AIC            08/06/91    Added EMmatch_graphics_loops.
    Jack           09/14/91    Added parent class EMSassoc.  Related
                               to making horizon edges work with 
                               reference planes. 
    Jack           11/18/91    Added parent class EMScreator.  No added
                               instance data, and only one message which
                               is rejected at EMScreator.  Will override
                               it at EMShorizon.
    Jack           09/25/92    Added override EMchangeSurface.
*/

not_taggable;

from EMShelper inherit EMset_props;

override        GRgraphics; /* Reject instance data. All GRgraphics
                               messages have been rejected by
                               EMSboundary. */
override        EMSassoc;   /* reject the instance data for these classes */
override        NDnodein;  

override        EMcreator_undoing,   /* Overridden from EMShelper */
                EMdisplay,
                EMhelperCopy,
                EMkeypoint,
                EMlocate,
                EMreset,
                EMget_the_edges,
                EMgetsurface_info,
       EMSassoc.EMput_info, /* as result of rejecting EMSassoc instance data */
       EMSassoc.EMget_info, /* as result of rejecting EMSassoc instance data */
       NDnodein.NDget_state, /* as result of rejecting NDnodein instance data */
       NDnodein.NDchg_state, /* as result of rejecting NDnodein instance data */
                EMchangeSurface;

override        EMShelper.EMexecuteCurveFunction;  


/***************************************************************/
/* Begin block 03/19/92                                        */
/* These are messages that were rejected by this class but are */
/* now being overridden to make a smoother transition from 1.4 */
/* to 2.0.  #Jack                                              */
/***************************************************************/
override        EMget_loops,
                EMmakeFRT,
                EMlinintgrl,
                EMptnesting,
                EMlpcleanup,
                EMtplydelete,
                EMtoggle_type,
                EMlppytrimint,
                EMlpbstrimint,
                EMvalidate,
/*                EMdelete_nat_gradata, */
/*                EMget_class_info, */
                EMchangeClass,
                EMget_edges,
                EMnesting;

message EMmatch_graphics_loops(IGRlong *msg; struct GRmd_env *md_env;
                               GRobjid new_surfid; GRspacenum new_surfos);
/*
Abstract

    Match these graphics loops onto the new surface. (Used in
    recomutation of surfaces and solids.

Arguments

    msg         - output    return status
    md_env      - input     environment of the new surface
    new_surfid  - input     id of the new surface
    new_surfos  - input     osnum of the new surface
*/
                               

message EMglpinit(long                    *msg;
                  unsigned short           props;
                  struct EMSpartolbasis   *partolbasis; 
                  GRobjid                  surf_id);

/*
Abstract

    Initialize a graphics loop.

Arguments

    msg         - output    return status 
    props       - input     loop property settings
    partolbasis - input     part basis tolerance
    surf_id     - input     surface id

*/



message EMupdate_feature(IGRlong   *EMmsg;
                         IGRshort  *matrix_type;
                         IGRmatrix  matrix );
/*
Abstract

    Reclip the edges. (All existing clip values will be discarded.)
*/



   




reject
/*
    The following messages do not make sense or are not supported by
    existing algorithms for open, disjoint sets of edges.
*/
/*        EMtreemod, */
/*        EMnesting, */
/*        EMget_loops, */
/*        EMptnesting, */
/*        EMmakeFRT,  */
/*        EMlinintgrl, */
/*        EMlpcleanup, */
/*        EMtplydelete, */
/*        EMget_edges,  */
/*        EMtoggle_type, */
/*        EMlppytrimint, */
/*        EMlpbstrimint, */
/*        EMvalidate,    */
        EMtrimyourself, 
        EMextractyourself, 
        EMpt_location,          
        EMlpinit, 
        EMcloseyourself, 
        EMmake_natural_loop, 
        EMmkface_collapse_copy, 
        EMgroup_loops,
        EMmake_lb_loop, 
        EMmergeloop, 
        EMptinside, 
        EMgetAdjacentLoops;
        
end specification EMSgraloop;
