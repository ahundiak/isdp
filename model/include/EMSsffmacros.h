/****************************************************************************

	Description :

	            Macros for surfaces' intersection functions in EMS.

	Creation :
                    Vadiraj M.R. - long ago.
****************************************************************************/
#ifndef EMSsf_func_macros
#define EMSsf_func_macros

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
#ifndef igetypedef_include
#include "igetypedef.h"
# endif
#ifndef gr_include
#include "gr.h"
# endif
#ifndef exdef_include
#include "exdef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
#ifndef go_include
#include "go.h"
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
#ifndef EMSbnddef_include
#include "EMSbnddef.h"
# endif   
#ifndef EMSbnd_h
#include "EMSbnd.h"
# endif
# ifndef emssfint_include
#include "emssfint.h"
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

extern IGRlong EMintersect_surfaces __((IGRlong *msg, struct GRid *sf1,
                                 struct GRmdenv_info *sf1env,
                                 IGRint numsfs2,
                                 struct EMSdataselect *sfs2,
                                 struct GRmdenv_info *sfs2env,
                                 IGRushort inters_opts,
                                 IGRushort world_opts,
                                 IGRushort param_opts,
                                 IGRushort trim_opts,
                                 struct GRvg_construct *const_args,
                                 IGRint *num_inters,
                                 struct EMSinters **sf1_inters,
                                 struct EMSinters **sfs2_inters,
                                 struct EMSsftracedata *sf1_tracedata,
                                 struct EMSsftracedata *sfs2_tracedata,
                                 GRobjid *inters_outputobj,
                                 GRobjid *inters_endptsobj,
                                 IGRchar *status_str));

extern IGRlong EMintersect_two_element __((struct GRlc_info *object_1,
                                   struct GRlc_info *object_2,
                                   IGRushort trimming_options,
                                   struct GRvg_construct *construct_list,
                                   IGRlong *num_inters,
                                   struct GRid **inters,
                                   IGRlong *msg));
#if defined(__cplusplus)
}
#endif

#undef __

/* *********************************************************************

    Description :

    This macro is the standard way of performing intersection between
    a surface object - A and a set of surface definitions - B. By
    surface definition is meant any data that implies a surface or a composite
    surface (EMSsurface objid, IGRbsp_surface structures, infinite plane
    definition). Various options are provided so that the intersection
    output data's characteristics are the one's desired. These are explained
    in some detail in the arguments section.

    It is also possible to input an existing intersection-list and have
    it processed for tracing and/or refining. This macro can thus be
    called in a reentrant fashion.

IGRlong *msg             - Output: Message return code.

struct GRid *surface1    - Input: Surface object A.

struct GRmdenv_info *surface1env  
                         - Input: Local-to-world transformation for A.
                           If NULL, identity matrix is assumed.

IGRint numsurfaces2,      
struct EMSdataselect *surfaces2 
                         - Input: Surface elements comprising the set B.

struct GRmdenv_info *surfaces2env 
                         - Input: Local-to-world transformation for
                           the elements in set B. If NULL, identity
                           matrix is assumed.

IGRushort inters_opts    - Input: General options for the processing:
                           The following options define additional
                           criteria that must be fulfilled by the intersection
                           for acceptability -
                           EMS_SFINT_MUSTINTERSECT - Every element in the
                            set B must have an intersection with A. Else,
                            stop processing and return EMS_E_NoIntersection.
                           EMS_SFINT_MUSTCLOSE - The intersections
                            when traced out must form closed groups in
                            model-space. If not, stop processing and return
                            EMS_E_IntersectClosure or
                            EMS_E_IntersClosureOrient.
                           EMS_SFINT_MUSTORIENT - The intersections
                            when traced out must indicate consistency in
                            their orientation in a uv-space of a surface. If
                            not, stop processing and return
                            EMS_E_IntersectOrient. This should be used in
                            conjunction with the orientation options in
                            'world_opts' or 'param_opts'.
                           EMS_SFINT_MUSTNOAMBIGUOUS - The intersections when
                            traced out should not follow more than one possible
                            trace path.

                           The following options direct the type of processing
                           to be done:
                           EMS_SFINT_SKIPSFINT - Processing should skip
                            computation of the raw intersection data.
                            Intersection list is taken as input to perform
                            the rest of the steps in this macro - trace,
                            refinement, output_object, etc. just as if
                            the intersection-list had been internally
                            generated.
                            EMS_SFINT_NOREFINE - Processing will skip the
                            refining stage.
                           EMS_SFINT_DOUBLECHECK - At every step of the
                            function go through possibly alternate algorithms
                            which double-checks the results.
                           EMS_SFINT_PROCDUPLICATE - An unconditional search
                            is made through the intersection curves, looking
                            for duplicate intersections that might occur
                            along edges. This option is automatically implied
                            if the double-check option is specified.
                           EMS_SFINT_AUTODOUBLECHECK - On error (except
                            NoIntersection), this macro will automatically
                            call itself with the double-check option set, in
                            the hope that the error will thus get rectified.
                            If the double-check option is already on, this
                            option does not cause the recursion.
                           EMS_SFINT_REVERSESECONDINT - The orientation of
                            second operand is unconditionally reversed.
                            This helps in being able to get the intersection
                            oriented say, "left" for the first operand and
                            "right" for the second, as in a difference
                            operation.
                           EMS_SFINT_HANDLESTOP - If this option is set, then
                            the user interrupt is handled, else it is ignored.
                           EMS_SFINT_PUSHBADCOINC - If "bad" coincident
                            intersection edges are found they are pushed onto
                            the common edge with the idea to remove the
                            "badness". By "bad" is meant that when these
                            intersection edges are used, they will produce
                            degeneracies in the output loop.
                           EMS_SFINT_MARKEDDELINFO - If the caller needs to be
                            informed about a deletion of an intersection that
                            had been marked for deletion.

IGRushort world_opts     - Input: 
                           The options used to specify the kind of
                           model-space output desired from surface-surface
                           intersection.

                           EMSINT_OUTPUT_WORLD - Model-space output
                           wanted or not
                           EMSINT_WORLD_OBJECT - Output to be database objects
                           (line-strings) or memory buffers.
                           EMSINT_WORLD_NOTYPEDCV - To output raw intersection
                           data in a very general form. Otherwise, when
                           possible, intelligent curve typing is done - eg:
                           a circle-intersection when detected is output as
                           a cirle.
                           EMSINT_ORIENT_OUTPUT - Output to be oriented with
                           respect to the other intersection surface. The 
                           orientation is done wrt to the oriented normal
                           (pointing into volume) of the surface.
                           EMSINT_ORIENT_RIGHT - If output to be oriented
                           - should the other surface be to the right or
                           the left of a natural traversal.  
IGRushort param_opts     - Input:
                           The options used to specify the kind of
                           parametric-space output desired from surface-surface
                           intersection. 

                           EMSINT_OUTPUT_PARAM - Parametric-space output 
                           wanted or not
                           EMSINT_PARAM_OBJECT - Output to be database objects
                           (surface edges) or memory buffers.
                           EMSINT_ORIENT_OUTPUT - Output to be oriented with
                           respect to the other intersection surface.
                           The orientation is done wrt to the natural normal
                           of the surface (direction of the cross-product
                           U X V).
                           EMSINT_ORIENT_RIGHT - If output to be oriented
                           - should the other surface be to the right or
                           the left of a natural traversal.
IGRushort trim_opts      - Input: 
                           The options for trimming the intersections :

                           EMSINT_TRIM_OUTPUT - Output to be trimmed with 
                           respect to the existing surface boundaries.
                           EMSINT_TRIM_COPLANAR - Processing of intersections
                           produced due to coincident planes.
                           EMSINT_TRIM_BDRYISAREA - The trimming to take place
                           w.r.t boundaries being treated as part of area.
                           EMSINT_TRIM_MOREPRECISE - The trimming is to be done
                           using an alternate more careful (therefore more
                           time-consuming algorithm.)
                           EMSINT_TRIM_PROCOVERLAP - Overlapping cases with the
                           boundaries should be output as separate
                           intersections. This option is relevant only
                           when boundary is area.
                           EMSINT_TRIM_ONLYCUTTING - Option to return
                           intersections only if it is "cutting"
                           EMSINT_TRIM_OPSWITCHED - Option to flag that the 
                           operands to surface-surface intersection have been
                           switched around. 
                           EMSINT_TRIM_HANDLESTOP - The STOP-interrupt to be 
                           handled.
struct GRvg_construct *construction_args  
                         - Input: 
                           If any object has to be constructed, it
                           is done using the information herein. The
                           object-space for the construction is taken
                           from here. Could be NULL, if no objects are
                           to be constructed.

IGRint *num_inters         - Output: The total number of intersections (each
                           curve is one intersection) generated on A during
                           this macro call is added to the existing
                           value of (*num_inters). This is done to enable
                           reentrant behaviour. Thus, this argument must be
                           zeroed before the call, if this is the first
                           call. This can be set to NULL.

struct EMSinters **surface1_inters,
struct EMSinters **surfaces2_inters  
                           - Output: 
                           The intersection lists for A and B,
                           respectively. Either or both could be NULL
                           by value; if so the corresponding output is ignored.
                           If non-NULL then (*sf1_inters) and (*sfs2_inters)
                           must be set to NULL, else a previous list is
                           expected and the current output is appended into
                           these lists. This is done to enable reentrant
                           behaviour. To free these lists use
                           EMSinters_data_free and EMSinters_free. If non-NULL
                           these lists are NOT freed even on error. The
                           responsibility for freeing them is the callers.

struct EMSsftracedata *surface1_tracedata,
struct EMSsftracedata *surfaces2_tracedata      
                         - Output: The trace data for the intersections
                           on A and B, respectively. Either or both could be
                           NULL by value; if so the corresponding output is
                           ignored. If non-NULL, space for the structure
                           EMSsftracedata is assumed to be allocated by the
                           caller. The memory for the individual fields in the
                           EMSsftracedata structure will always be allocated
                           by this macro. No reenttrant behaviour
                           on this output. To free this allocated memory
                           use the function EMsfinttrace_free.

GRobjid *inters_outputobj - Output: If this argument is non-NULL, the
                           intersection(s) are output as a graphic-group,
                           composite-curve or a single curve depending
                           on the output.

GRobjid *inters_endptsobj - Output: If this argument is non-NULL, the
                           end-points of any open string of intersection
                           curves are output as a graphic-group. The color
                           of these point objects is obtained by incrementing
                           the color given in the construct-list. If no
                           open string is present, the objid is set to
                           NULL_OBJID.

IGRchar *status_str       - Input/Output: If non-NULL, the input string is
                           displayed in the status-space with dots (".")
                           appended onto it incrementally as the function
                           proceeds. In this function a maximum of three dots
                           may be added, hence that much space must be
                           available in the string.

  RETURN VALUE

    Note that this macro per se does not print any error message.
    The macro's return value is either OM_S_SUCCESS or an informational
    OM-code (OM_I_STOP_SENDING, etc) or an OM error-code.

    The message return code ('msg') will be one of the following:

      Information codes:
      - EMS_I_Interrupt
          If the processing of the intersections was user-interrupted.
          The output generated may be incomplete. The OM-status is
          OM_S_SUCCESS. This return code is possible only when the option
          to handle interrupt is on.

      Information/Success codes:
      One of the following codes are returned when some output was desired
      (atleast one of the output arguements was non-NULL) and no error
      has occurred in the processing.
      - EMS_S_Success
          if the output desired is being successfully returned. In case a
          special option, viz, EMS_SFINT_MARKEDDELINFO is set and an
          intersection was deleted because of it being so marked, this success
          code is changed to EMS_I_Clipped.
      - EMS_I_NotFound
          if the output desired turns out to be the NULL set due to non
          intersection of the surfaces.

      Information codes:
      These codes are returned only if all the output arguments are set to
      NULL (no output is desired) and no other errors occurred.
      - EMS_I_Intersect
          if atleast one intersection was found

      - EMS_I_NoIntersection
          if no intersections were found
      - EMS_I_IntersectOrient
          if some intersections were found but were all disregarded
          as they were non-orientable due to occurence along a tangency.

      Error codes:
      The following error codes occur because some criteria specified by
      the 'inters_opts' is not satisfied. These error codes will not cause
      printing of an error message.
      - EMS_E_NoIntersection
          If the option is set so that every element in B intersects A
          and there is atleast one such element that does not intersect A.
      - EMS_E_IntersectClosure
          If the option is set to only output closed intersections and
          the intersection curves do not close in model-space.
      - EMS_E_IntersClosureOrient
          If the option is set to only output closed intersections and
          the intersection curves do not close in model-space and this could
          possibly be due to rejection of intersections at tangencies.
      - EMS_E_IntersectOrient
          If the option is set to only output oriented intersections and
          the intersection curves are not oriented correctly.
      - EMS_E_Ambiguous
          If the option is set to not accept an intersection set that presents
          ambiguity during tracing and there is such ambiguity.

      The following error codes occur because of some internal error in
      computing the intersections. These error codes will print a
      corresponding message on stderr.
      - EMS_E_IntersectTrim
          the trimming of the surface intersection curves was incorrect.
      - EMS_E_Intersect
          if the failure occurred due to bad intersection result, but
          the error cannot be pinpointed.

      - EMS_E_InvalidArg
          if the input surface data is neither a surface-object, surface buffer
          or an infinite plane.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_Fail
          Call to some EMS/BS-math function returned an error.
      - EMS_E_SurfaceError
          Invocation of a surface method failed.
      - EMS_E_OMerror
          Call to an OM-primitive failed.                         
*********************************************************************** */    
     
#omdef ems$intersect_surfaces(
                    msg,
                    surface1,
                    surface1env = NULL,
                    numsurfaces2,
                    surfaces2,
                    surfaces2env = NULL,
                    inters_opts,
                    world_opts,
                    param_opts,
                    trim_opts,
                    construction_args = NULL,
                    num_inters = NULL,
                    surface1_inters = NULL,
                    surfaces2_inters = NULL,
                    surface1_tracedata = NULL,
                    surfaces2_tracedata = NULL,
                    inters_outputobj = NULL,
                    inters_endptsobj = NULL,
                    status_str = NULL)
EMintersect_surfaces((msg), (surface1), (surface1env),
                     (numsurfaces2), (surfaces2),
                     (surfaces2env), (inters_opts), (world_opts), (param_opts),
                     (trim_opts), (construction_args), (num_inters),
                     (surface1_inters), (surfaces2_inters), 
                     (surface1_tracedata),
                     (surfaces2_tracedata), (inters_outputobj),
                     (inters_endptsobj), 
                     (status_str))
#endomdef


/**************************************************************************
   
     Description :

     This macro intersects two graphics elements and returns the intersections
     in the form of objects constructed in the OS specified in the construct
     list.
     The valid combinations are -

            object_1                              object_2
            --------                              --------
         curve/comp curve                           --    (Self intersection)
         curve/comp curve                      curve/comp curve
         curve/comp curve                      surf/comp surf
         surf/comp surf                        surf/comp surf  

      Arguments
IGRlong  *msg                -    Output:
                                  Message return code.
                                  EMS_S_Success,
                                  all is well.
                                  EMS_E_InvalidArg,
                                  in case the input
                                  arguments don't make
                                  any sense.
                                  EMS_E_Fail,
                                  in case of a severe 
                                  failure.
                                  EMS_I_NoIntersection,
                                  no intersections between
                                  the two objects.
                                  EMS_E_NoDynamicMemory,
                                  failure to allocate 
                                  dynamic memory.
                                  EMS_I_Interrupt,
                                  in case the process is
                                  interrupted by the user.
                                        
struct GRlc_info * object1   -    input:
                                  info for object 1.

struct GRlc_info * object2   -    input:
                                  info for object 2 (This arguments should
                                  be NULL or same as object_1 for self
                                  intersection in case of curves)

IGRushort trim_opts          -    input:
                                  Pls. refer to the options described for the
                                  same variable under the above macro. 
 
struct GRvg_construct *construction_args  
                             -    input:
                                  For intersection objects to be
                                  constructed.

IGRlong * num_inters         -    output: 
                                  Number of intersection objects being 
                                  returned.

struct GRid **inters         -    output:
                                  GRids of intersection objects.
**************************************************************************/

#omdef ems$intersect_two_element(
                    msg,
                    object1,
                    object2,
                    trim_opts,
                    construction_args,
                    num_inters,
                    inters)
EMintersect_two_element((object1), (object2), (trim_opts), (construction_args),
                        (num_inters), (inters), (msg))
#endomdef
                    
#endif                                             

