/***************************************************************************

  Description :

  Macros for Topology related functions in EMS.

  Creation :

  Vadiraj M.R.  - long ago.

***************************************************************************/
#ifndef EMStopo_func_macros
#define EMStopo_func_macros

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) () 
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
#ifndef igetypedef_include
#include "igetypedef.h"
# endif
#ifndef gr_include
#include "gr.h"
# endif
#ifndef go_include
#include "go.h"
# endif
#ifndef exdef_include
#include "exdef.h"
# endif
#ifndef ex_include
#include "ex.h"
# endif
#ifndef emsinterdef_include
#include "emsinterdef.h"
# endif
#ifndef emsinter_include
#include "emsinter.h"
# endif
# ifndef emssfintdef_include
#include "emssfintdef.h"
# endif
# ifndef emsdef_include
#include "emsdef.h"
# endif
#ifndef griodef_include
#include "griodef.h"
# endif
#ifndef grio_include
#include "grio.h"
# endif
#ifndef godef_include
#include "godef.h"
# endif
#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
# endif
# ifndef emserr_include
#include "emserr.h"
# endif
#ifndef dp_include
#include "dp.h"
# endif
#ifndef emsmapdef_include
#include "emsmapdef.h"
# endif
#ifndef OM_D_MINIMUM
#include "OMminimum.h"
# endif
# ifndef emsbool_include
#include "emsbool.h"
# endif
# ifndef emssfint_include
#include "emssfint.h"
# endif

extern IGRlong EFsspbtol_by_geom __((IGRlong *EMmsg,
                                     struct  IGRbsp_surface *surf,
                                     IGRdouble *partolbasis));

extern IGRlong EMboolean_surfaces_w_intersection __((IGRlong *msg,
                                              struct GRid *boolid,
                                              enum EMSbooltype boolop,
                                              struct GRmd_env *mdenv,
                                              GRobjid sf1,
                                              IGRint numsfs2,
                                              GRobjid *sfs2,
                                              struct EMSinters *sf1_inters,
                                              struct EMSinters *sfs2_inters,
                                          struct EMSsftracedata *sf1_tracedata,
                                          struct EMSsftracedata *sfs2_tracedata,
                                      struct EMSsfintloopsdata *sf1_loopdata,
                                      struct EMSsfintloopsdata *sfs2_loopdata,
                                          IGRushort options,
                                          IGRint *num_dispsfs,
                                          GRobjid **dispsfids,
                                          IGRchar *status_st));

extern IGRint EMcount_loops __((IGRlong *rc, GRobjid sender_edge,
                         IGRint *count, OM_S_OBJECT_LINKAGE **loops,
                         IGRushort all_mask, IGRushort any_mask,
                         IGRushort none_mask));

extern IGRint EMcount_partedges __((IGRlong *rc, GRobjid sender_edge,
                             IGRint *count, OM_S_OBJECT_LINKAGE **edges,
                             IGRushort all_mask, IGRushort any_mask,
                             IGRushort none_mask));

extern IGRlong EMdupinters __((IGRlong *EMmsg, struct EMSinters **inters1,
                        struct EMSinters **inters2, IGRboolean copyintobjs,
                        IGRboolean delorigobjs, struct GRid *surfid,
                        struct GRid *copyid, IGRboolean compressed_copy,
                        struct GRmd_env *fromenv, 
                        struct GRvg_construct *const_list,
                        struct GRid *inorig_surfs,
                        struct GRid *incopy_surfs,
                        IGRint innum_surfs,
                        struct GRid *inorig_edges,
                        struct GRid *incopy_edges,
                        IGRint innum_edges));


extern IGRint EMget_mapped_data __((IGRlong number_of_objects, 
                             struct IGRbsp_curve **input_curves,
                             struct GRlc_info *object_information,
                             struct GRvg_construct *const_list,
                             struct IGRbsp_surface *surface,
                             IGRdouble *par_tol_basis,
                             struct GRmd_env *env,
                             struct EMSgetlp_badcrvinfo *bad_curves,
                             struct IGRpolyline *bad_points,
                             struct EMSgetlp_output *out_loops,
                             struct EMSgetlp_output *out_curves,
                             struct GRid clip_ls,
                             IGRushort options,
                             struct EMSgetlp_planar_info *planar_info,
                             IGRlong *EMmsg));

extern void EMinters_data_free __((IGRlong *msg, struct EMSinters *inters_list,
                            IGRint num, void (*func_free_moreinfo)(),
                            void (*func_free_inters_moreinfo)()));

extern void EMinters_free __((struct EMSinters *inters, IGRint num));

extern struct EMSinters *EMinters_malloc __((IGRlong *msg, IGRint num));

extern struct EMSintobj *EMmakeintlist __((IGRlong *msg,
                               struct EMSinters **inters_a,
                               struct EMSinters **inters_b,
                               struct GRid *object_a,
                               struct GRid *object_b,
                               IGRchar *inters_moreinfo_a,
                               IGRchar *inters_moreinfo_b,
                               IGRulong inters_props_a,
                               IGRulong inters_props_b,
                               struct EMSdataselect *xyzintobject,
                               struct EMSdataselect *uvintobject_a,
                               struct EMSdataselect *uvintobject_b,
                               IGRboolean reversed_a,
                               IGRboolean reversed_b,
                               IGRchar *moreinfo_a,
                               IGRchar *moreinfo_b,
                               IGRulong props_a,
                               IGRulong props_b,
                               IGRchar *cvtype_a, 
                               IGRchar *cvtype_b, 
                               IGRboolean is_curve,
                               IGRboolean positioned)); 

extern void EMpypoint_free __((struct EMSpypoint *pypts, IGRint num_nodes));

extern IGRint EMsend_loops __((IGRlong *rc, OM_p_MESSAGE messg, 
                               GRobjid sender_edge,
                        IGRint frominx, IGRint toinx, IGRushort all_mask,
                        IGRushort any_mask, IGRushort none_mask));

extern IGRint EMsend_partedges __((IGRlong *rc, OM_p_MESSAGE messg, 
                            GRobjid sender_edge, IGRint frominx, IGRint toinx,
                            IGRushort all_mask, IGRushort any_mask,
                            IGRushort none_mask));

extern IGRlong EMsfint_topology_validate __((IGRlong *msg, 
                                      struct GRmdenv_info *mdenvinfo,
                                      struct EMSinters *sf1_inters,
                                      struct EMSinters *sf2_inters,
                                      struct EMSsftracedata *sf1_tracedata,
                                      struct EMSsftracedata *sf2_tracedata,
                                      IGRushort options,
                                      struct EMSsfintloopsdata *sf1_loopdata,
                                      struct EMSsfintloopsdata *sf2_loopdata));

extern struct EMSsfintedpar *EMsfintedpar_malloc __((IGRlong *msg, IGRint num));

extern void EMsfintloops_data_free __((IGRint num_grps, IGRint *num_subgrps_grp,
                                GRobjid **loop_sf, GRspacenum loop_os));

extern void EMsfintloops_free __((GRobjid **loop_sf, GRobjid **endedges, 
                           struct EMSsfintedpar ***intparms,
                           IGRdouble **sfpartolb));

extern void EMsfinttrace __((IGRlong *msg, IGRshort *mattyp, IGRmatrix mat,
                      struct EMSinters *inters, IGRdouble *altuvtol,
                      IGRdouble *altxyztol, IGRint *num_grps,
                      IGRint **num_subgrps_grp, IGRint ***num_elems_subgrp,
                      struct EMSintobj ****elems, IGRboolean ***subgrp_rev,
                      IGRboolean ****elem_rev, IGRboolean **grp_closed,
                      IGRboolean ***subgrp_closed));

extern void EMsfinttrace_free __((IGRlong *msg, IGRint num_grps, 
                           IGRint *num_subgrps_grp, 
                           IGRint **num_elems_subgrp,
                           IGRchar ***elems,
                           IGRboolean **subgrp_rev,
                           IGRboolean ***elem_rev,
                           IGRboolean *grp_closed,
                           IGRboolean **subgrp_closed));
#if defined(__cplusplus)
}
#endif

#undef __

/**********************************************************************

    Description :

    This macro uses the input intersection data between surface-object A
    and the set of surface-objects B, and performs the specified Boolean
    operation between them. The boundaries of the comprising surfaces are
    modified to reflect the Boolean operation. An object of class EMSsfboolean
    is passed in which becomes the result of this operation. This object
    will own the modified A and B on it's channel on successful completion.

    Since the intersections are being passed, a "Boolean" operation
    can be done just on object A. This would be equivalent to an impose
    boundary operation. For this, all data concerning the second operand
    B could be NULL.   

    ARGUMENTS

IGRlong *msg                       -  Output:
                                      Message return code.
                                      If the operation was successfully
                                      completed:

                                      - EMS_S_Success
                                        if succeeded  
                                      - EMS_I_Interrupt
                                        If the option to handle the
                                        STOP-interrupt was on and the
                                        procedure was interrupted.
                                      
                                      In all of the following errors
                                      a recovery operation succeeded
                                      and the two input solids are
                                      still intact and reusable.

                                      - EMS_E_IntersectTrim
                                      the end-point incidence data on
                                      the surface intersection curves
                                      was incorrect in some way or
                                      indicated bad topology.
                                      - EMS_E_InvalidArg
                                      if the input argument list was invalid,
                                      i.e., the objects input belong to
                                      different object spaces.
                                      - EMS_E_NoDynamicMemory
                                      if dynamic memory allocation was tried
                                      but failure occurred.
                                      - EMS_E_SurfaceError
                                      if a failure occurred when a call to a 
                                      surface method was made.
                                      - EMS_E_LoopsetError
                                      if a failure occurred when a call to a
                                      surface-loopset method was made.
                                      - EMS_E_LoopError
                                      if a failure occurred when a call to a
                                      surface-loop method was made.
                                      - EMS_E_EdgeError
                                      if a failure occurred when a call to a
                                      surface-edge method was made.
                                      - EMS_E_OMError
                                      if a failure occurred when a call to an
                                      OM-primitive was made or,
                                      a failure on invocation of a 
                                      method on some object.     
                                      - EMS_E_Fail
                                      Most probably a failure in a call to a
                                      math-function. In some cases the reason
                                      for failure was not understood in greater
                                      detail.

                                      A catastrophic failure has occurred. The
                                      objects' topology has gotten corrupted.
                                      
                                      - EMS_F_Fail
                                      If an error occurred and the recovery
                                      was not possible or failed, the solids
                                      have possibly been destroyed beyond 
                                      recovery.      
 
GRobjid surface1                   -  Input:
                                      Surface object A.

IGRint numsurfaces2                    
GRobjid *surfaces2                 -  Input:
                                      Surface objects that comprise the set B.
                                      numsurfaces2 == 0, surfaces2 == NULL,
                                      if B not specified.             

struct GRid *booleanid             -  Input:
                                      The object that will be the result of
                                      this operation. To this object A and B are
                                      connected as the operands (only A if B
                                      is not specified).         

struct GRmd_env *mdenv             -  Input: 
                                      Information about the module in which
                                      booleanid, A and B reside.

IGRushort opts                     -  Input:
                                      Options used to change the default
                                      characteristics of this function:
                                      EMSsfbool_opt_display,
                                      EMSsfbool_opt_noredraw,
                                      EMSsfbool_opt_OpenIntPossible,
                                      EMSsfbool_opt_SingleTopology,
                                      EMSsfbool_opt_HandleStop
                                      are currently the possible options.
                                      See emssfintdef.h

enum EMSbooltype booleanopts       -  Input:
                                      The Boolean operation required to be
                                      performed. If only data for A passed in,
                                      this is not looked at.

struct EMSinters *surface1_inters,
struct EMSinters *surfaces2_inters -  Input:
                                      The intersection lists for A and B.
                                      surfaces2_inters is NULL if B not 
                                      specified.

struct EMSsftracedata *surface1_tracedata
struct EMSsftracedata *surfaces2_tracedata
                                   -  Input:
                                      The trace information for A and B.
                                      surfaces2_tracedata == NULL, if B not
                                      specified.

struct EMSsfintloopsdata *sf1_loopdata
struct EMSsfintloopsdata *sfs2_loopdata
                                   -  Input:
                                      The intersection data converted into
                                      toplogical data along with incidence
                                      information, that can directly be used
                                      for splitting existing edges and closing
                                      loops, and so on. Either or both could be
                                      NULL (if so, this is generated inside
                                      this function).

IGRint *num_dispsfs,
GRobjid **dispsfids             - Input/Output:
                                  Information about display surfaces
                                  exchanged when the option to 'noredraw' is on.
                                  The surfaces that are modified are added to
                                  this list if not already in it and any erasure
                                  of surfaces is done only if the surface is not
                                  already in the list. 

IGRchar *status_st              - Input/Output:
                                  If non-NULL, the input string is
                                  displayed in the status-space with dots (".")
                                  appended onto it incrementally as the function
                                  proceeds. In this function a maximum of five
                                  dots may be added, hence that much space
                                  must be available in the string.
************************************************************************/    

#omdef ems$boolean_surfaces_w_intersection(
                  msg,
                  surface1,
                  numsurfaces2 = 0,
                  surfaces2 = NULL,
                  booleanid,
                  mdenv,
                  opts, 
                  booleanopts,
                  surface1_inters,
                  surfaces2_inters = NULL,
                  surface1_tracedata,
                  surfaces2_tracedata = NULL,
                  surface1_loopdata = NULL,
                  surfaces2_loopdata = NULL,
                  num_dispsfs,
                  dispsfids,
                  status_str = NULL)
EMboolean_surfaces_w_intersection ((msg), (booleanid), (booleanopts), (mdenv),
                                   (surface1), (numsurfaces2), (surfaces2),
                                   (surface1_inters), (surfaces2_inters),
                                   (surface1_tracedata), (surfaces2_tracedata),
                                   (surface1_loopdata), (surfaces2_loopdata),
                                   (opts), (num_dispsfs), (dispsfids),
                                   (status_str)) 
#endomdef

/**********************************************************************

    Description :

    This method returns the basis parmateric tolerance of the surface.
    
    NOTE : For the description of various tolerances, refer to the
           help available on I/EMS. 

    ARGUMENTS

    IGRlong *msg           -  Output:
                             Message return code.

                             If the operation was successfully
                             completed:

                           - EMS_S_Success   
 
    struct  IGRbsp_surface *surface
                           -  Input:
                              Pointer to surface geometry.

    IGRdouble *partolbasis -  Output:
                              Parametric basis tolerance of the surface. 
**********************************************************************/
#omdef ems$sspbtol_by_geom (msg,
                            surface,
                            partolbasis)
EFsspbtol_by_geom ((msg), (surface), (partolbasis))
#endomdef

/**********************************************************************

    Description :

    This macro is usable by any object to count the number of specific
    type of loops owning a specified edge. The edge is specified by it's
    object-id and the loop-type is specified by a list of properties that
    must be satisfied. Thus, this macro serves as a means of breaking up the
    edge-loop channel into user-definable pieces, where it appears that
    only those loops are connected to the edge that are specified via
    the properties masks.

    ARGUMENTS:

    IGRlong *msg            - Output:
                              Message return code.

                              If the operation was successfully
                              completed:

                            - EMS_S_Success

                              If dynamic memory allocation was tried
                              but failure occurred.

                            - EMS_E_NoDynamicMemory

    GRobjid sender_edge     - Input:
                              The edge whose owner-loops are to be queried

    IGRint *count           - Output:
                              The returned count of the number of loops
    
    OM_S_OBJECT_LINKAGE **loops
                            - Output:
                              If loops (value) is not NULL the loops are
                              returned with the memory malloced in this 
                              function.      

    IGRushort all_mask      - Input:
                              Properties mask specifying properties
                              (specifiable by a bit turned ON) ALL
                              of which MUST be satisfied. If NULL,
                              then ignored.
    IGRushort any_mask      - Input:
                              Properties mask specifying properties
                              (specifiable by a bit turned ON) ANY of
                              which MUST be satisfied. If NULL,
                              then ignored.
    IGRushort none_mask     - Input:
                              Properties mask specifying properties
                              (specifiable by a bit turned ON) NONE
                               of which MUST be satisfied. If NULL,
                               then ignored.        
    NOTE :
         
    For loop properties, refer to the include file EMSprop.h

    EXAMPLE:

    For example, if the user would like to count the number of active
    loops (maximum there can be is one), all_mask would be (EMLP_ACTIVE),
    any_mask would be NULL and none_mask would be NULL.
    If a count of all loops was required,
    all_mask would be NULL, any_mask would be NULL and
    none_mask would be NULL. 
**********************************************************************/
#omdef ems$count_loops (msg,
                        sender_edge,
                        count,
                        loops = NULL,
                        all_mask = NULL,
                        any_mask = NULL,
                        none_mask = NULL)
EMcount_loops ((msg), (sender_edge), (count), (loops),
               (all_mask), (any_mask), (none_mask))
#endomdef

/**********************************************************************

    Description :

    This macro is usable by any object to count the number of specific
    type of partedges owning a specified edge. The edge is specified by its
    object-id and the partedge-type is specified by a list of properties that
    must be satisfied. Thus, this macro serves as a means of breaking up the
    edge-loop/partedge channel into user-definable pieces, where it appears
    that only those partedges are connected to the edge that are specified via
    the proerties masks.

    ARGUMENTS:

    IGRlong *msg            - Output:
                              Message return code.    

                              If the operation was successfully
                              completed:

                            - EMS_S_Success

                              If dynamic memory allocation was tried
                              but failure occurred.

                            - EMS_E_NoDynamicMemory

    GRobjid sender_edge     - Input:
                              The edge whose owner-partedges are to be queried.

    IGRint *count           - Output:
                              The returned count of the number of partedges.

    OM_S_OBJECT_LINKAGE **edges
                            - Output:
                              If 'edges' (value) is not NULL the partedges are
                              returned with memory malloced in this function.
                              Else, ignored.

    IGRushort all_mask      - Input:
                              Properties mask specifying properties
                              (specifiable by a bit turned ON) ALL of which
                              MUST be satisfied. If NULL, then ignored.

    IGRushort any_mask      - Input:
                              Properties mask specifying properties
                              (specifiable by a bit turned ON) ANY of which
                              MUST be satisfied. If NULL, then ignored.

    IGRushort none_mask     - Input:
                              Properties mask specifying properties
                              (specifiable by a bit turned ON) NONE of which
                              MUST be satisfied. If NULL, then ignored.  
    NOTE :

    For edge properties, refer to the include file EMSprop.h
    
    EXAMPLE:

    For example, if the user would like to count all the partedges,
    all_mask would be NULL, any_mask would be NULL and none_mask
    would be NULL.
**********************************************************************/
#omdef ems$count_partedges (msg,
                            sender_edge,
                            count,
                            edges = NULL,
                            all_mask = NULL,
                            any_mask = NULL,
                            none_mask = NULL)  
EMcount_partedges ((msg), (sender_edge), (count), (edges),
                   (all_mask), (any_mask), 
                   (none_mask))
#endomdef
/**********************************************************************

    Description :

    This macro accepts a surface and the intersection data on it and
copies the surface and the intersection data such that the copied data
is now valid for the copied surface. This includes the various objids found
in the data (surface ids, incedent edge ids etc.). The surface copy can
be made optionally as compressed (active entities only).

    ARGUMENTS :

IGRlong *msg          - Output:
                        Message return code.
                        
                        EMS_S_Success,
                        if everything goes well.

                        EMS_E_Fail,
                        in case of a severe failure.

                        EMS_E_NoDynamicMemory,
                        failure to allocate memory.

                        EMS_E_InvalidArg,
                        an object or input that makes no sense.
 
struct EMSinters **origsf_inters
                      - Input:
                        The intersection data on the original surf.

struct EMSinters **copysf_inters
                      - Output:
                        The intersection data for the copy surface.
                        If This argument is NULL, then the copied
                        data will overwrite the original data.

IGRboolean copyintobjs
                      - Input:
                        Flag indicating whether the intersection
                        edges in origsf_inters be copied and
                        transfered to the corresponding copy surfaces
                        or the original edges themselves should be
                        transferred. TRUE is valid only if the copy 
                        is being made into the same object space.

IGRboolean delorigintobjs 
                      - Input:
                        Flag indication whether the input (original)
                        intersection are deletable or not. e.g
                        When a copy is being made into a
                        different object space with same memory of
                        origsf_inters being overwritten, the original edges
                        need to be deleted (if appropriate) by the
                        function before they are lost due to
                        overwrite. This argument makes sense only
                        if copysf_inters is NULL.

struct GRid *origsfid
                      - Input:
                        The original surface.

struct GRid *copysfid
                      - Output:
                        Copied surface. If this argument is NULL, then
                        no surface is copied. If however copysf_inters
                        is non NULL the intersection data is copied
                        but it is now valid for the original
                        surface.

IGRboolean compressed_copy
                      - Input:
                        Only the active entities should be copied or
                        the whole shibang. Makes sense only if the
                        original surface is a DPR kinda guy.

struct GRmd_env *origsfenv
                      - Input:
                        env of origianl surface.

struct GRvg_construct *construction_args
                      - Input:
                        construct list for the object to be constructed.

struct GRid *orig_leafsfnodes
                      - Input:
                        List of leaf surface nodes in the original
                        object. If not known pass NULL.

struct GRid *copy_leafsfnodes
                      - Input:
                        List of leaf surface nodes in the copy (if
                        already made by the caller). If not known
                        pass NULL. 

IGRint numin_leafsfs  - Input:
                        Number of leaf surfaces being passed in.

struct GRid *origsf_edges
                      - Input:
                        Edges in the original object.

struct GRid *copysf_edges
                      - Input:
                        Edges in the copy (if already made by the
                        caller). 

IGRint numin_edges    - Input:
                        number of edges being passed in.
        NOTES :

        The surface lists being passed in should have a one to one
        correspondence, copy_lfsfnodes[i] must be a copy of
        orig_sfnodes[i]. If either list is not passed in, the function
        'gets components' from the corresponding owner (copy or original)
        and assumes one to one correspondence.
                In case of edges, the method EMSsurface.EMgetedges is used
        on each leaf surface in the list and a similar correspondence between
        original edge and its copy is assumed.
                If all the above lists are passed in as NULL, the function
        ensures integrity of the above assumption.

        Assumption :

        inters.more_info is a pointer to the surface geometry.
        intobj.more_info is a pointer to a pair of sfintedpars.

        Bugs :

        The function as of now copies only the uv data and that too only
        if it is in object form.

        Note that sfintedpar->info, and intobj->other_intobj_node
        remain NULL for the copy if origsf_inters is not being overwritten. 
*****************************************************************************/
#omdef ems$dupinters (msg,
                      origsf_inters = NULL,
                      copysf_inters = NULL,
                      copyintobjs = TRUE,
                      delorigintobjs = FALSE,
                      origsfid,
                      copysfid = NULL,
                      compressed_copy = TRUE,
                      origsfenv,
                      construction_args,
                      orig_leafsfnodes = NULL,
                      copy_leafsfnodes = NULL,
                      numin_leafsfs = 0,
                      origsf_edges = NULL,
                      copysf_edges = NULL,
                      numin_edges = 0)
EMdupinters ((msg), (origsf_inters), (copysf_inters),
             (copyintobjs), (delorigintobjs),
             (origsfid), (copysfid), (compressed_copy),
             (origsfenv), (construction_args),
             (orig_leafsfnodes), (copy_leafsfnodes), 
             (numin_leafsfs), (origsf_edges),
             (copysf_edges), (numin_edges))
#endomdef

/*************************************************************************
       Description :

       This macro accepts a list of model-space curve-objects ^ curve buffers
     and maps them onto the given surface. The output is a corresponding list
     of parametric space loop objects or model space curves mapped onto the
     surface along the surface normals.
       This macro ensures, unless opted otherwise, that:

      1) No jump occurs in parametric space when there is not a corresponding
         jump in model space.
      2) The parametric linestrings do not intersect themselves.
      3) The parametric linestrings do not intersect with any other
         parametric linestrings in the same space.
      4) The parametric linestrings do not have edges which lie
         along the natural surface boundaries.  In doing this it
         also moves points which are very near natural edges to the
         natural edge.  

       ARGUMENTS :

       IGRlong *msg        - Output:
                             Message return code.

                             EMS_S_Success if sucess
                             EMS_E_DynamicMemoryAllocated if no memory
                             EMS_E_Fail if severe problems (best to
                             abort), note that this most likely
                             implies coding, algorithm, or math
                             problems  

       struct IGRbsp_surface *surface
                           - Input:
                             The surface for imposition.

       struct GRid clip_ls - Input:
                             Clipping loopset. If clip_ls.objid is
                             NULL_OBJID then a natural loopset will be used
                             for clipping. Relevant only if clipping
                             is not suppressed via the options.

       
       struct GRmd_env *surfaceenv                      
                           - Input:
                             mod env of the surface (can be
                             different from curves)

       IGRdouble *par_tol_basis
                           - Input:
                             par_tol for this surface. If NULL,
                             it is computed by the function.  

       struct IGRbsp_curve **input_curves
                           - Input:
                             curve buffers.

       struct GRlc_info *object_information
                           - Input:
                             Locate information per curve object.
                             The curve objects can be in any object space.
                             Required to get curve geometries if input
                             is curve objects instead of curve buffers. 

       IGRlong number_of_objects
                           - Input:
                             Number of curve objects you have.

       struct GRvg_construct construction_args
                           - Input:
                             construct list for model space curves. If
                             curves not desired, can be NULL.  

       struct EMSgetlp_planar_info *planar_info
                           - Input:
                             optional information for curves being mapped
                             onto planar surfaces. It consists of the
                             following 4 fields -

                             edge types- Ignored if comp curve is input.
                             All edges produced from a curve will have the
                             corresponding edge type set. If no edge
                             types, set the pointer value to NULL.

                             curve_info - is an input array of pointers
                             per curve. The pointer for a curve is returned
                             back as 'more_info' with edges produced
                             from that curve. Relevant only for planes.

                             out_edges - edges created are returned via
                             structure 'EMgetlp_edgeinfo'.
                             Each pointer in the array points to begining
                             of the array containing edges for a loop.

                             num_out_edges array of num edges in each loop.

IGRushort opts             - Input:
                             See file /ems/include/emsmapdef.h

struct EMSgetlp_output *out_loops
                           - Output:
                             The parametric loops resulting from the
                             input parametric curves. Can be NULL if
                             not interested. If out_loops.objs is non NULL
                             enough memory is assumed, else memory
                             is allocated by the function.

struct EMSgetlp_output *out_curves
                           - Output:
                             Curves mapped along surface normals. Rest as
                             above.     

struct IGRpolyline *bad_points
                           - Output:
                             Xyz points corresponding to ends of dangling
                             parametric data
                             not interested ? NULL : non NULL.
                             Memory for the 3D points is ALWAYS allocated
                             by the function.  

struct EMSgetlp_badcrvinfo *bad_curves
                           - Output:
                           Info about the bad curves encountered (curves
                           not within tol from the surface). The
                           structure is defined in include/emsmapdef.h
                           not interested ? NULL : non NULL. If
                           bad_curves.bad_indices is NULL, memory is
                           allocated by the function, else enough memory
                           is assumed. 

   NOTES :

   If the incoming surface is an order 2 plane with equal and parallel sides
   then the boundaries with order > 2 are mapped as bspline curves and
   bs edges are created instead of stroking the curve out and constructing
   linear edges.
   If the input curves contain a composite then each component of the
   composite is handled individually. Thus an edge will be formed for each
   component of the composite if loops are desired. If model space curves
   are desired, a composite will result after mapping.
*************************************************************************/
#omdef ems$get_mapped_data (msg,
                            surface,
                            clip_ls,
                            surfaceenv,
                            partolbasis = NULL, 
                            input_curves = NULL,
                            object_information,
                            number_of_objects,
                            construction_args = NULL,
                            planar_info = NULL,
                            opts,
                            out_loops = NULL,
                            out_curves = NULL,
                            bad_points = NULL,
                            bad_curves = NULL)
EMget_mapped_data ((number_of_objects), (input_curves),
                   (object_information),
                   (construction_args), (surface), (partolbasis),
                   (surfaceenv),
                   (bad_curves), (bad_points), (out_loops), (out_curves),
                   (clip_ls), (opts), (planar_info), (msg))
#endomdef                           

/****************************************************************************

      Description :
      
      This macro frees/deallocates/deletes the actual intersection data -
      the curve-objects, point-objects, curve-buffers, point-buffers, etc.
      The nodes in the linked-list are NOT deallocated. To deallocate these
      one would use EMinters_free. Also, only the intersection data directly
      with this list is freed. (The list contains references to intersection
      data belonging to another similar list, but that is left untouched.
      Example: the field "other_intobj_node").The actual number of nodes
      processed is dependent on the argument - "num_nodes". Only "num_nodes"
      number of nodes are processed in the linked list. If the list
      terminates before "num_nodes" nodes, processing terminates,  having
      processed all the nodes. Also, if "num_nodes" is NULL, it is assumed that
      the entire list is to be processed.

      Arguments :
   
      IGRlong *msg         - Output:
                             Message return code.

                             -EMS_S_Success, if all is well. 
                             -EMS_E_OMerror, in case of severe error.

      struct EMSinters *inters_list
                           - Input:
                             The intersection list to be freed of
                             actual intersection data.

      IGRint num_nodes     - Input:
                             The actual number of nodes processed 
                             in the linked list. If NULL, then the
                             entire list will be processed.  

      void (*userdfnd_func_to_free_inters_moreinfo)()
                           - Input:
                             User supplied function to deallocate the
                             memory assigned to the "more_info" field 
                             in the EMSinters structure(refer to the
                             structure EMSinters in modelsrc/include/
                             emsinter.h). The only input to this
                             function is the pointer to the "more_info"
                             field in the EMSinters structure.
                             Eg. : An invocation of this user
                             defined function can be
                           (*func_free_inters_moreinfo)(inters_list->more_info,
                                                        NULL).
                             If the pointer to the user supplied function is
                             NULL, om$dealloc is called on the "more_info"
                             field (if this field is non-NULL).

        void (*userdfnd_func_to_free_intobj_moreinfo)()
                            - Input:
                              User supplied function to deallocate the
                              memory assigned to the "more_info" field
                              in the EMSintobj structure(refer to the
                              structure EMSinters in modelsrc/include/
                              emsinter.h). The only input to this
                              function is the pointer to the "more_info"
                              field in the EMSintobj structure.
                              Eg. : An invocation of this user
                              defined function can be       
                            (*func_free_intobj_moreinfo)(intobj_list->more_info,
                                                        NULL).
                             If the pointer to the user supplied function is
                             NULL, om$dealloc is called on the "more_info"
                             field (if this field is non-NULL). 
****************************************************************************/
#omdef ems$inters_data_free (msg,
                             inters_list,
                             num_nodes = NULL,
                             userdfnd_func_to_free_inters_moreinfo = NULL,
                             userdfnd_func_to_free_intobj_moreinfo = NULL)
EMinters_data_free ((msg), (inters_list), (num_nodes), 
                    (userdfnd_func_to_free_inters_moreinfo), 
                    (userdfnd_func_to_free_intobj_moreinfo))
#endomdef 

/****************************************************************************

      Description :

      This macro frees the nodes in the linked-list containing the intersection
      data.  The number of nodes freed in the linked-list, starting from
      "inters_list" , is "num_nodes". To free the entire list specify either
      NULL or MAXINT or the exact number of elements in the list. 

      ARGUMENTS :
      
      struct EMSinters *inters_list  - Input:
                                       The linked-list containing the 
                                       intersection data to be freed 
                                       of memory.
 
      IGRint num_nodes               - Input:
                                       Number of nodes to be freed in 
                                       the linked-list.
                                       To free the entire list specify
                                       either NULL or MAXINT or the
                                       exact number of elements in the
                                       list.  
****************************************************************************/
#omdef ems$inters_free (inters_list,
                        num_nodes = NULL)
EMinters_free ((inters_list), (num_nodes))
#endomdef

/****************************************************************************

      Description :

      This macro allocates memory for a linked-list storing intersection
      data.  "num_nodes" is the number of nodes in the linked-list for
      which memory is to be allocated.  Returns a pointer to the
      linked-list created. 

      ARGUMENTS :
      
      IGRlong *msg    - Output:
                        Message return code.
                        -EMS_I_DynamicMemoryAllocated, if memory is allocated,
                         successfully.
                         If not
                        -EMS_E_DynamicMemoryAllocated.

      IGRint num_nodes - Input:
                         Number of nodes in the linked-list
                         for which memory is to be allocated.              
*****************************************************************************/
#omdef ems$inters_malloc (msg,
                          num_nodes)
EMinters_malloc ((msg), (num_nodes))
#endomdef

/******************************************************************************

       Description :

       This macro adds on new elements to an existing or a NULL linked_list
       of EMSinters structures. The element added is intialized with the input
       passed in.

                                          Any of the input arguments
       can be NULL (value). This provides the user with ability to use only
       a subset of the input. Wherever possible, output corresponding to a NULL
       argument is made more meaningful. For example: xyzintobject being NULL
       will cause a datatype of "EMSdata_null" to be output in the relevant
       field of the output. One restriction however applies. If an EMSinters
       pointer is non-NULL, it's corresponding "object" (a or b) should be
       meaningful. Else an invalid-argument error code is returned.
       One use of such a flexibility is that an intersection list for a single
       object (a or b) can be processed.    

       ARGUMENTS :

       IGRlong *msg   -  Output:
                         Message return code.
                         -EMS_S_Success,
                          if everything goes well.
                         -EMS_E_InvalidArg,
                          refer to the comments above.

       struct EMSinters **inters_a
                      -  Input:
                         The intersection linked_list for object_a
                         to be created or appended to.
                         If NULL, then the linked_list for object_b
                         is processed.
      
       struct EMSinters **inters_b
                      -  Input:
                         The intersection linked_list for object_b
                         to be created or appended to.   
                         If NULL, then the linked_list for object_a
                         is processed.

       IGRchar *inters_moreinfo_a
       IGRchar *inters_moreinfo_b
                      -  Input:
                         The "more_info" field of the EMSinters structure
                         is initialised with these values for object_a and
                         object_b.
                         Either of these can be NULL.

       IGRulong inters_props_a
       IGRulong inters_props_b
                      -  Input:
                         The "props" field of the EMSinters structure
                         is initialised with these values for object_a and
                         object_b.
                         Both of these can be NULL.

       struct GRid *object_a
       struct GRid *object_b
                      -  Input:
                         The "this_obj" field of the EMSinters structure
                         is initialised with these values for object_a and
                         object_b.             
                         Either of these can be NULL.

       struct EMSdataselect *xyzintobject
                      -  Input:
                         The "this_xyzintobj" field of the EMSintobj
                         structure, which is a field in the EMSinters 
                         structure, is initialised with this.
                         Can be NULL.
       struct EMSdataselect *uvintobject_a
       struct EMSdataselect *uvintobject_b
                      -  Input:
                         The "this_uvintobj" field of the EMSintobj
                         structure, which is a field in the EMSinters
                         structure, is initialised with these values,
                         for object_a and object_b.
                         Either of these can be NULL.

       IGRboolean reversed_a
       IGRboolean reversed_b
                      -  Input:
                         The "reversed" field of the EMSintobj
                         structure, which is a field in the EMSinters
                         structure, is initialised with these values,
                         for object_a and object_b.

       IGRchar *moreinfo_a
       IGRchar *moreinfo_b
                      -  Input:
                         The "more_info" field of the EMSintobj
                         structure, which is a field in the EMSinters
                         structure, is initialised with these values,
                         for object_a and object_b.
                         Either of these can be NULL.

       IGRulong props_a
       IGRulong props_b
                      -  Input:
                         The "props" 
                         The "more_info" field of the EMSintobj
                         structure, which is a field in the EMSinters
                         structure, is initialised with these values,
                         for object_a and object_b.
                         Either of these can be NULL.
       IGRuchar *cvtype_a
       IGRuchar *cvtype_b
                      -  Input:
                         The "curve_type" field of the EMSintobj struct.
                         Either of these can be NULL. If NULL, then the field
                         "curve_type" of the intobj is set to "EMpoint" (if 
                         the next argument "is_curve" is FALSE), else it is set
                         to "EMfreeform_curve".
                        

       IGRboolean is_curve  -  Input:
                               A flag to initialise the fields "cvs"
                               "pts" in the EMSinters structure.

       IGRboolean positioned 
                            -  Input:
                               If this is set to TRUE, it is being implied
                               that the list-pointer being input is set to
                               the node that simply requires initialization.
                               A NULL-list-pointer with this option is
                               therefore an invalid argument.
                               If this option is set to FALSE, this macro
                               picks out its EMSinters node, if it exists
                               (that node that has my object-id as "this_obj").
                               If such a node does not exist it allocates a new
                               node which might start of the list or be 
                               linked to the end (depends on whether the input
                               list ptr is NULL or not).   
                             
******************************************************************************/ 
#omdef ems$makeintlist(msg, 
                     inters_a = NULL,
                     inters_b = NULL,
                     object_a = NULL,
                     object_b = NULL, 
                     inters_moreinfo_a = NULL,
                     inters_moreinfo_b = NULL,
                     inters_props_a = NULL,
                     inters_props_b = NULL,
                     xyzintobject = NULL,
                     uvintobject_a = NULL,
                     uvintobject_b = NULL,
                     reversed_a = FALSE,
                     reversed_b = FALSE,
                     moreinfo_a = NULL,
                     moreinfo_b = NULL,
                     props_a = NULL,
                     props_b = NULL,
                     cvtype_a = NULL,
                     cvtype_b = NULL,
                     is_curve = TRUE,
                     positioned = FALSE)
EMmakeintlist((msg), (inters_a), (inters_b), (object_a),
              (object_b), (inters_moreinfo_a), 
              (inters_moreinfo_b), (inters_props_a),
              (inters_props_b), (xyzintobject),
              (uvintobject_a), (uvintobject_b),
              (reversed_a), (reversed_b), (moreinfo_a),
              (moreinfo_b), (props_a), (props_b),
              (cvtype_a), (cvtype_b), (is_curve), 
              (positioned))
#endomdef 

/****************************************************************************

           Description :

           This macro should be used to free memory allocated
          to the linked list - "pypts" of type struct EMSpypoint. The 
          linked list is expected to be NULL-terminated.
          The actual number of nodes processed is dependent on the argument -
          "num_nodes ". Only "num_nodes" number of nodes are processed
          in the linked list.
          If the list terminates before "num_nodes", processing terminates,
          having processed all the nodes. Also, if "num_nodes" is NULL, it is
          assumed that the entire list is to be processed.

          NOTES :
        
          The linked list "pypts" of EMSpypoint structures is a temporary
          one in Boolean operations.  The elements of "pypts" taken in pairs,
          constitute the boundaries on the polyline.

          ARGUMENTS :

          struct EMSpypoint *pypts  -  Input:
                                       The input linked list to be freed 
                                       for memory.

          IGRint num_nodes          -  Input:
                                       See the comments above.
****************************************************************************/
#omdef ems$pypoint_free (pypts,
                         num_nodes = NULL)
EMpypoint_free ((pypts), (num_nodes))
#endomdef

/****************************************************************************

      Description :

          This macro is usable by any object to send a message to specific
      loop(s) owning a specified edge. The edge is specified by it's object
      id and the loop is specified by a list of properties that must be
      satisfied. Thus, this macro serves as a means of breaking up the
      edge-loop channel into user-definable pieces, where it appears that
      only those loops are connected to the edge that are specified via
      the proerties masks.      

      ARGUMENTS :

      IGRlong  *msg         -  Output:
                               Message return code.

                               -EMS_S_Success, if everything goes well.
                               -EMS_E_InvalidArg,
                                if 'frominx' greater than
                                'toinx' or if frominx greater
                                than the number of valid loops 
                               -EMS_E_NoDynamicMemory,
                                failure to allocate memory.

      OM_p_MESSAGE message  - Input:
                              Message to be sent to the valid loop(s).

      GRobjid sender_edge   - Input:
                              The edge whose loops are the targets for the
                              message send. 

      IGRint frominx        - Input:
                              The starting relative index on the edge-loop
                              channel if there were only valid loops on it.

      IGRint toinx          - Input:
                              The ending relative index on the edge-loop
                              channel if there were only valid loops on it.

      IGRushort all_mask    - Input:
                            - Properties mask specifying properties
                              (specifiable by a bit turned ON) ALL of which
                              MUST be satisfied. If NULL, then this condition
                              is ignored. 

     IGRushort any_mask    - Input:
                           - Properties mask specifying properties
                             (specifiable by a bit turned ON) ANY of which
                             MUST be satisfied. If NULL, then this condition
                             is ignored.

    IGRushort none_mask    - Input:
                           - Properties mask specifying properties
                             (specifiable by a bit turned ON) NONE of which
                             MUST be satisfied. If NULL, then this condition
                             is ignored.

    NOTES :

    For example, if the user would like to send to the active loop(s),
    frominx would be 0, toinx could be any number greater than 0,
    all_mask would be (EMLP_ACTIVE), any_mask would be NULL and
    none_mask would be NULL.
    If a send to all loops was required,
    frominx would be 0, toinx could be MAXINT,
    all_mask would be NULL, any_mask would be NULL and
    none_mask would be NULL. 

      An important characteristic to be noted is that the "sends" take place
    in the reverse order of channel connections if the conditions specified
    indicate that one of the properties required to be satisfied is that the
    loop be active. Every other condition causes the "sends" to take place
    in the natural order. This is done in the hope that if an active loop
    is being sought, it is found mostly at the (n-1)th index and that there
    is only one active loop. If the frominx and toinx are 0 and 0,
    respectively, the target active loop is found and no more processing
    needs to be done. But if toinx is larger then the search continues
    for other loops on the channel that might satisfy these conditions.
****************************************************************************/
#omdef ems$send_loops (msg,
                       message,
                       sender_edge,
                       frominx = 0,
                       toinx = 0,
                       all_mask = NULL,
                       any_mask = NULL,
                       none_mask = NULL)
EMsend_loops ((msg), (message), (sender_edge),
              (frominx), (toinx), (all_mask), (any_mask),
              (none_mask))
#endomdef

/***************************************************************************

       Description :

       This macro is usable by any object to send a message to specific
      partedge(s) owning a specified edge. The edge is specified by its object
      id and the partedge is specified by a list of properties that must be
      satisfied. Thus, this macro serves as a means of breaking up the
      EMSedge-EMSpartedge channel into user-definable pieces, where it 
      appears that only those partedges are connected to the edge that are
      specified via the proerties masks.

      ARGUMENTS :

      IGRlong  *msg         -  Output:
                               Message return code.

                               -EMS_S_Success, if everything goes well.
                               -EMS_E_InvalidArg,
                                if 'frominx' greater than
                                'toinx' or if frominx greater
                                than the number of valid loops

      OM_p_MESSAGE message  - Input:
                              Message to be sent to the valid partedge(s).

      GRobjid sender_edge   - Input:
                              The edge whose partedges are the targets for the
                              message send.

      IGRint frominx        - Input:
                              The starting relative index on the edge-partedge
                              channel if there were only valid partedges on it.

      IGRint toinx          - Input:
                              The ending relative index on the edge-partedge
                              channel if there were only valid partedge on it.

      IGRushort all_mask    - Input:
                            - Properties mask specifying properties
                              (specifiable by a bit turned ON) ALL of which
                              MUST be satisfied. If NULL, then this condition
                              is ignored.

     IGRushort any_mask    - Input:
                           - Properties mask specifying properties
                             (specifiable by a bit turned ON) ANY of which
                             MUST be satisfied. If NULL, then this condition
                             is ignored.

    IGRushort none_mask    - Input:
                           - Properties mask specifying properties
                             (specifiable by a bit turned ON) NONE of which
                             MUST be satisfied. If NULL, then this condition
                             is ignored.

    NOTE :

    For edge properties, refer to the include file EMSprop.h

    EXAMPLE:
    
    If a send to all partedges was required,
    frominx would be 0, toinx could be MAXINT,
    all_mask would be NULL, any_mask would be NULL and
    none_mask would be NULL.  
***************************************************************************/
#omdef ems$send_partedges (msg,
                           message,
                           sender_edge,
                           frominx = 0,
                           toinx = 0,
                           all_mask = NULL,
                           any_mask = NULL,
                           none_mask = NULL)   
EMsend_partedges ((msg), (message), (sender_edge), (frominx),
                  (toinx), (all_mask),
                  (any_mask), (none_mask))
#endomdef  

/****************************************************************************

       Description :

       This macro accepts the traced and oriented intersection data between
       two surfaces. The intersections must contain uv-edge objects for
       uv-data. It does the following -
       1) Validates the data based on following criteria -
        o Endpoints of subgroups must end on some valid existing edges
          (incedent edges). If a subgroup end is dangling, an attempt is made
          to fix it, provided it is within 2*chord_height_tol from the nearest
          boundary in model space.
        o The subgroup continuity must be consistent with the corresponding
          incedent edges being common edges.
        o The incedence location on a pair of common edges must be similar
          (middle-middle or end-end).
        o If the incedence location is end-end, the corresponding ends of the
          common edges must form a vertex.
      2) Returns appropriate error if the data is found to be invalid.
      3) Optionally creates topology objects (loops and edges) and
         outputs the following pieces of information -
        o surface-loop pairs
        o end information for each loop created
        o parametric tolerance for each surface 
      
      Arguments :
   
      IGRlong *msg        -  Output:
                             Message return code.

                             On successful completion
                           - EMS_S_Success
                             On error, one of the following
                           - EMS_E_IntersectTrim, the intersection data 
                             has failed the topological test in some way.
                           - EMS_E_Fail, unspecific failure. 

     struct GRmdenv_info *mdenv
                          -  Input:
                             Information about the module matrix in which
                             the surfaces reside.

    IGRushort opts        -  Input:
                             Options used to change the default
                             characteristics of this function:
                             EMSsfbool_opt_SingleTopology
                             EMSsfbool_opt_ValidateAllData
                             EMSsfbool_opt_ConnectToComEdge
                             are currently the possible options.
                             See emssfintdef.h 

    struct EMSinters *surface1_inters
                          -  Input:
                             The intersection list for the surface1.

    struct EMSinters *surface2_inters
                          -  Input:
                             The intersection list for the surface2.
                             surface2_inters could be NULL.

    struct EMSsftracedata *surface1_tracedata
                          -  Input:
                             The trace information for the surface1.

    struct EMSsftracedata *surface2_tracedata
                          -  Input:
                             The trace information for the surface2.
                             surface2_tracedata could be NULL.

    struct EMSsfintloopsdata *surface1_loopdata
    struct EMSsfintloopsdata *surface2_loopdata 
                          -  Output:
                             Either or both could be NULL. This argument
                             if non-NULL must point to an EMSsfintloopsdata
                             structure. The output arrays are returned here.
****************************************************************************/
#omdef ems$sfint_topology_validate (msg,
                                    mdenv,
                                    opts,
                                    surface1_inters,
                                    surface2_inters = NULL,
                                    surface1_tracedata,
                                    surface2_tracedata = NULL,
                                    surface1_loopdata,
                                    surface2_loopdata = NULL)
EMsfint_topology_validate ((msg), (mdenv), (surface1_inters),
                           (surface2_inters),
                           (surface1_tracedata), (surface2_tracedata), 
                           (opts), (surface1_loopdata), (surface2_loopdata))
#endomdef 

/***************************************************************************

          Description :

          This macro is the one that should be used when allocating memory
          for elements of the linked list made up of EMSsfintedpar(s), for
          e.g., the 'more_info' field in the EMSinters structure for 
          surface-surface intersection holds the additional information
          generated during the trimming of surface-intersections against the
          the surface's boundary elements. The EMSsfintedpar structure is
          associated with an end-point of the intersection curve. If this
          end-point was due to a trim against an edge, then this structure 
          yields information about, which edge caused the trimming, and
          where on the edge this trim actually take place. If the end-point
          is not due to a trim, the edge-id returned will be a NULL_OBJID.
          
          Refer to the file modelsrc/include/emssfint.h for more details
          on the structure EMSsfintedpar.

          ARGUMENTS :

          IGRlong *msg    -  Output:
                             Message return code.

                             -EMS_S_DynamicMemoryAllocated,
                              if memory is allocated successfully.
                             -EMS_E_DynamicMemoryAllocated,
                              in case of failure to allocate memory.  
          
          IGRint num_nodes
                          -  Input:
                             Number of nodes in the linked-list for
                             which memory is to be allocated. 
***************************************************************************/
#omdef ems$sfintedpar_malloc (msg,
                              num_nodes)
EMsfintedpar_malloc ((msg), (num_nodes))
#endomdef

/***************************************************************************

          Description :

          This macro is used to free the memory allocated for the boundary
          elements, surface edges and the loops, that might get constructed
          after the surface-intersection and tracing operations are done.
          This macro, infact, is used to free the actual data related to
          the object ids of the loops that are constructed.

          ARGUMENTS :

          IGRint num_grps     -  Input:
                                 The total number of groups.

          IGRint *num_subgrps_grp
                              -  Input:
                                 The number of sub-groups in
                                 a particular group.

          GRobjid **loop_sf   -  Input:
                                 The array holding the loop-surfaceid
                                 pairs.
                                 Eg. : loop_sf[i][j*2] - gives the loopid 
                                 corresponding to the jth subgroup of the
                                 ith group.
                                 loop_sf[i][j*2+1] - gives the surfaceid
                                 on which this loop is created.
                                 (NOTE: This macro deletes only the ids
                                  corresponding to the loops. The related
                                  surface ids are not touched.)

          GRspacenum loop_os  -  Input:
                                 The object space in which these loops
                                 reside.     
***************************************************************************/
#omdef ems$sfintloops_data_free (num_grps,
                                 num_subgrps_grp,
                                 loop_sf,
                                 loop_os)
EMsfintloops_data_free ((num_grps), (num_subgrps_grp), (loop_sf), (loop_os))
#endomdef 

/***************************************************************************

          Description : 

          This macro actually frees the memory allocated for the array
          holding the loop-surfaceid pairs.  

          See the comments for the above macro.

          ARGUMENTS :

          GRobjid **loop_sf  - Input:
                               The array holding the loop-surfaceid
                               pairs. 
     
          GRobjid **endedges - Input:
                               The edges at the ends of the loop, above.
                               Eg. : endedges[i][j*2] is the start-edge and
                               and the endedges[i][j*2+1]is the stop-edge. 
                               Can be NULL.
          struct EMSsfintedpar ***intparms
                             - Input:
                               Give the pointers to the pair of EMSsfintedpar
                               structures that relate to the endpoints of a
                               particular subgroup in a group.
                               Eg. : intparms[i][j*2] and intparms[i][j*2+1]
                          gives the pointers to the pair of EMSsfintedpar that
                         relate to the endpoints (begin, end in that order) of
                         the jth subgroup of the ith group. Consequently,
                         relate to the start of the start-edge and the stop
                         of the stop-edge.
                               Can be NULL. 

          IGRdouble **sfpartolb 
                             - Input:
                               The array holding the tolerances for each of
                               the surface involved. 
                               Can be NULL.
***************************************************************************/
#omdef ems$sfintloops_free (loop_sf, 
                            endedges = NULL, 
                            intparms = NULL, 
                            partolbasis = NULL)
EMsfintloops_free ((loop_sf), (endedges), (intparms), (partolbasis))
#endomdef

/***************************************************************************

          Description :

          This macro is used to string together the pieces of surface-surface
    intersection, so as to output groups which have between their lowest
    elements, atleast positional continuity. Each of these groups consist of
    one or more subgroups. In general, subgroups in a group lie on different
    surfaces. Each of the subgroups consist of one or more elements.
    The elements of each subgroup necessarily lie on the same surface.

          A characteristic of the traced output is that no subgroup or group
    will cross over itself at an endpoint of it's component elements. But a
    self-intersection within an element cannot be prevented.

          If world-space curves are not input, groups will not be formed across
    surfaces. That is, every group will consist of only one subgroup.

          T/F information, whether any subgroup in any of the groups has to be
    reversed in direction for proper continuity to be maintained, is returned
    in the Boolean 2-dimensional array, "subgrp_rev". Similar information,
    whether any element has to be reversed in direction, is returned in the
    Boolean 3-dimensional array, "elem_rev". It makes no sense to have
    "grp_rev" flags.

          Whether each group is closed (considering world space of course) is
    returned in the Boolean array "grp_closed". Information about whether
    a subgroup is closed is returned in the Boolean array "subgrp_closed".
    It is possible that the group may be closed (based on the model-space
    or xyz data) but the subgroup (based on the parametric or uv data)
    remains open. Example: Intersection crossing the 'seam' of a  cylinder -
    this crossing is continuos in xyz but stops at the two bounds of the
    parametric space causing a break. This could lead to a closure in xyz
    but not in uv. Having an "elem_closed" flag is redundant, since that
    information is easily inferred from the fact that if an element is
    closed it will belong to a closed subgroup with a single element.

          Each of the subgroups is output as an EMSintobj linked-list.
    A sequence of these linked-list forms a group.

    If the continuity between any of the elements (or the definite lack of it)
    is known, either in uv-space and/or xyz-space, this can be made known via
    the "fwd" and "bwd" pointers of the EMSintobj structures. This information
    overrides any other continuity criteria that might be used (minimum
    distance, etc.). If the pointer indicates continuity to some node that
    doesn't exist or as it happens at the time of xyz-trace, points to some
    end of a node that is now not a free-end of a subgroup, such a pointer is
    ignored. In fact, it is cleared from the EMSintobj.

          The input - "inters" is essentially untouched except that it's
    sub-linked-lists of type EMSintobj may have been rearranged w.r.t. to
    their "next" field (to be as positionally continuous as possible). Also,
    the "fwd" and/or "bwd" pointers may have been reset to NULL and the
    corresponding continuity property destroyed if it was found that such
    continuity is unusable by the above criteria.

          The tracing is performed with respect to the existing model-space,
    zero-vector-length tolerance. A relevant parametric space tolerance is
    extracted by accessing the surface. But alternate tolerance(s) for
    parametric space (and model-space) can be specified. If these argument(s)
    are non-NULL it is assumed that the respective alternate tolerance has
    been provided and that this should be used for the trace.
    Caution: If the alternate parametric tolerance argument is NULL and the
    surface cannot be accessed (due to the relevant pointers not being
    available in the intersection list) a paramteric tolerance of 0.0 will
    be used.

       Arguments :
       
       IGRlong *msg    - Output:
                         Message return code.

                         Success codes:
                       - EMS_S_Success
                         if succeeded, with no ambiguities
                       - EMS_I_Ambiguous
                         if more than one paths were available 
                         to complete the trace but the "best" one was chosen.

                         Error codes:
                       - EMS_E_NoDynamicMemory
                         if dynamic memory allocation was tried but 
                         failure occurred.
                       - EMS_E_Fail
                         Call to a math function returned error.
                       - EMS_E_SurfaceError
                         Invocation of a surface method failed.
                       - EMS_E_EdgeError
                         Invocation of an edge method failed.
                       - EMS_E_OMerror
                         Call to an OM-primitive failed or,
                         Invocation of a method on some object failed.

      struct EMSinters *inters
                       - Input:
                         The input intersection list to be traced.
                         For more details, refer to the comments above.

      IGRshort *matrixtype
      IGRmatrix matrix  
                       -  Input:
                          Information about the module matrix in which
                          the intersection objects reside.  

      IGRdouble *altuvtol
      IGRdouble *altxyztol
                       -  Input:
                          Alternate tolerances for parametric space and
                          modelspace, respectively.  For more details
                          on tolerances, refer to the description
                          above.

      IGRint *num_grps - Output:
                         Gives the number of groups formed.

      IGRint **num_subgrps_grp
                       - Output:
                         A two dimensional array containing the number
                         of sub-grps in each of the groups formed.
                         Eg.: num_subgrps_grp[i] - gives the number
                         of subgroups in the ith group.

      IGRint ***num_elems_subgrp
                       - Output:
                         A three dimensional array containing the number
                         of elements in each of the sub-grps formed.
                         Eg.: num_elems_subgrp[i][j] gives the number of
                         elements in the jth subgroup of the ith group.

      struct EMSintobj ****elems
                       - Output:
                         Gives the EMSintobj linked-list for a particular
                         sub-grp in each of the sub-grps formed.
                         Eg.: elems[i][j] gives the EMSintobj linked-list for
                         jth subgroup in the ith group of curves.

      IGRboolean ***subgrp_rev
                       - Output:
                         Info. on the 'reversed' state of a sub-grp is
                         stored here.
                         Eg.: subgrp_rev[i][j] if TRUE, means that the
                         jth subgroup of the ith group needs to be reversed 
                         to maintain continuity.

      IGRboolean ****elem_rev
                       - Output:
                         Gives info. on the 'reversed' state of an element
                         in a subgroup.
                         Eg.: elem_rev[i][j][k] if TRUE, means that the
                         kth element in the jth subgroup of the ith group
                         needs to be reversed to maintain continuity.

      IGRboolean **grp_closed
                       - Output:
                         Gives info. on whether a group is closed or not.
                         Eg.: grp_closed[i] if TRUE, means that the
                         ith group is closed when considering the curve
                         in world space.

      IGRboolean ***subgrp_closed
                       - Output:
                         Contains info. on whether a particular subgroup
                         in a group is closed or not.
                         Eg.: subgrp_closed[i][j] if TRUE, means that the
                         jth subgroup in the ith group is closed.
                         (NOTE: A group in the model-space is always closed.
                          Whereas a group/subgroup in the parametric space
                          can either be closed or not closed.) 

     NOTES:
     
     The type of intersection elements are assumed to be curves. Any points
    are ignored. The model-space curves can be of type EMSdata_poly3d,
    EMSdata_curve3d or EMSdata_object (GRcurve). The paramteric-space curves
    can be of type EMSdata_poly2d, EMSdata_curve3d or EMSdata_object (EMSedge).

     The curves are first traced in parametric-space of each of the surfaces
    using the general-trace function. These form the subgroups. Treating
    these subgroups as units (storing their related information in a
    local-structure array) a second trace is performed in model-space.
    The second trace is performed only if model-space data exists. 
***************************************************************************/
#omdef ems$sfinttrace (msg,
                       inters,
                       matrixtype,
                       matrix,
                       altuvtol = NULL,
                       altxyztol,
                       num_grps,
                       num_subgrps_grp,
                       num_elems_subgrp,
                       elems,
                       subgrp_rev,
                       elem_rev,
                       grp_closed,
                       subgrp_closed)
EMsfinttrace ((msg), (matrixtype), (matrix), (inters),
              (altuvtol), (altxyztol), (num_grps),
              (num_subgrps_grp), (num_elems_subgrp), (elems),
              (subgrp_rev), (elem_rev), (grp_closed), (subgrp_closed))  
#endomdef 

/***************************************************************************

          Description :

          The following macro is to be used in conjunction with the
   above macro. All the output memory that has been malloced within
   the trace function should be deallocated using this macro.
   If this macro is not used for the deallocation, the user
   does so at his own risk.

          ARGUMENTS :
   IGRlong *msg            -  Output:
                              Message return code.
                              -EMS_S_Success,
                               if memory is deallocated successfully.

   IGRint num_grps         
   IGRint *num_subgrps_grp    
   IGRint **num_elems_subgrp  
                            -  Input:
                               Refer to the description of output arguments
                               for the above macro.

   IGRchar ***elems
   IGRboolean **subgrp_rev
   IGRboolean **subgrp_rev
   IGRboolean ***elem_rev
   IGRboolean *grp_closed
   IGRboolean **subgrp_closed
                            -  Input:
                               Refer to the description of output arguments
                               for the above macro. 

          
***************************************************************************/
#omdef ems$sfinttrace_free (msg,
                            num_grps,
                            num_subgrps_grp,
                            num_elems_subgrp,
                            elems,
                            subgrp_rev,
                            elem_rev,
                            grp_closed,
                            subgrp_closed)
EMsfinttrace_free ((msg), (num_grps), (num_subgrps_grp), (num_elems_subgrp),
                   (elems), (subgrp_rev), (elem_rev), 
                   (grp_closed), (subgrp_closed))
#endomdef   
                             
#endif 

                                                           
