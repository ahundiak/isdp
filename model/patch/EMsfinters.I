/*
  DESCRIPTION

    This function is the standard way of performing intersection between
    a surface object - A and a set of surface definitions - B. By
    surface definition is meant any data that implies a surface or a composite
    surface (EMSsurface objid, IGRbsp_surface structures, infinite plane
    definition). Various options are provided so that the intersection
    output data's characteristics are the one's desired. These are explained
    in some detail in the arguments section.

    It is also possible to input an existing intersection-list and have
    it processed for tracing and/or refining. This function can thus be
    called in a reentrant fashion.

  ARGUMENTS

    msg			- Output: Message return code.
    sf1			- Input: Surface object A.
    sf1env		- Input: Local-to-world transformation for A.
			   If NULL, identity matrix is assumed.
    numsfs2, sfs2	- Input: Surface elements comprising the set B.
    sfs2env		- Input: Local-to-world transformation for
			   the elements in set B. If NULL, identity
                           matrix is assumed.
    inters_opts		- Input: General options for the processing:
                           The following options defines additional
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
                            the rest of the steps in this function - trace,
                            refinement, output_object, etc. just as if
                            the intersection-list had been internally 
                            generated.
			   EMS_SFINT_SKIPFIXING - Processing will skip the
                            "fixing" stage.
			   EMS_SFINT_NOREFINE - Processing will skip the
                            refining stage.
                           EMS_SFINT_DOUBLECHECK - At every step of the
			    function go through possibly alternate algorithms
			    which double-checks the results.
			   EMS_SFINT_AUTODOUBLECHECK - On error (except
                            NoIntersection), this function will automatically
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
			   EMS_SFINT_NOCURVECOPY - When intersection group is
                            requested (inters_outputobj) and inters list is
                            also requested, use the same objects as in the
                            inters list, rather than making their copies for 
                            inters_outputobj.
                           EMS_SFINT_CHTTRACETOL - Use chord-height instead
                            of basis-tolerance for tracing. Note that with
                            double-check on, cht trace tolerance is used
                            by default.
                           See emssfintdef.h
    world_opts		- Input: The options specified here are exactly
                           as specified in the corresponding argument
                           in the EMSsurface.EMsfsfint method.
                           See emssfintdef.h
    param_opts		- Input: The options specified here are exactly
                           as specified in the corresponding argument
                           in the EMSsurface.EMsfsfint method.
                           See emssfintdef.h
    trim_opts		- Input: The options specified here are exactly
                           as specified in the corresponding argument
                           in the EMSsurface.EMsfsfint method.
                           See emssfintdef.h
    const_args		- Input: If any object has to be constructed, it
                           is done using the information herein. The
			   object-space for the construction is taken
                           from here. Could be NULL, if no objects are
			   to be constructed.
    num_inters		- Output: The total number of intersections (each
                           curve is one intersection) generated on A during
                           this function call is added to the existing
                           value of (*num_inters). This is done to enable
                           reentrant behaviour. Thus, this argument must be
                           zeroed before the call, if this is the first
			   call. This can be set to NULL.
    sf1_inters,		- Output: The intersection lists for A and B, 
    sfs2_inters		   respectively. Either or both could be NULL 
	    		   by value; if so the corresponding output is ignored.
			   If non-NULL then (*sf1_inters) and (*sfs2_inters)
			   must be set to NULL, else a previous list is
			   expected and the current output is appended into 
			   these lists. This is done to enable reentrant
                           behaviour. To free these lists use
			   EMSinters_data_free and EMSinters_free. If non-NULL
			   these lists are NOT freed even on error. The
			   responsibility for freeing them is the callers.
    sf1_tracedata,	- Output: The trace data for the intersections
    sfs2_tracedata	   on A and B, respectively. Either or both could be
			   NULL by value; if so the corresponding output is
			   ignored. If non-NULL, space for the structure
			   EMSsftracedata is assumed to be allocated by the
			   caller. The memory for the individual fields in the 
			   EMSsftracedata structure will always be allocated
			   by this function. No reenttrant behaviour
                           on this output. To free this allocated memory
			   use the function EMsfinttrace_free.
    inters_outputobj	- Output: If this argument is non-NULL, the 
                           intersection(s) are output as a graphic-group,
                           composite-curve or a single curve depending
			   on the output.
    inters_endptsobj	- Output: If this argument is non-NULL, the 
                           end-points of any open string of intersection
                           curves are output as a graphic-group. The color
                           of these point objects is obtained by incrementing
			   the color given in the construct-list. If no
			   open string is present, the objid is set to
			   NULL_OBJID. 
    status_str		- Input/Output: If non-NULL, the input string is
			   displayed in the status-space with dots (".") 
			   appended onto it incrementally as the function
			   proceeds. In this function a maximum of three dots
			   may be added, hence that much space must be
			   available in the string.

  RETURN VALUE

    Note that this function per se does not print any error message.
    The functions return value is either OM_S_SUCCESS or an informational 
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

  EXAMPLE

    In the case where the true (trimmed) intersection curves are to be output
    in the form of object curves (GRcurves), the call sequence could be:

    status = EMintersect_surfaces (&msg, sf1objid, &sf1mdenv, 1, &sf2objid,
              &sf2mdenv, NULL, NULL, NULL, 
              EMS_TRIM_OUTPUT | EMS_TRIM_COPLANAR | EMS_TRIM_BDRYISAREA,
              &const_args, NULL, NULL, NULL, NULL, NULL, &intcvsobjid,
              NULL, NULL);
    EMerr_hndlr (EMSerror (status & msg), msg, EMS_E_SurfaceError, wrapup);

    No intersection list is output and neither is the trace data. Coincident
    planes are processed "appropriately", boundary is treated as belonging
    to area. The output is a single GRcurve or a graphic group object-id.
    If no intersection was detected, the return code is EMS_I_NoIntersection
    else on success it is EMS_S_Success.
 
    For another sample call see the call in EMsfbjbool.I in the source
    directory src_dpr/imp.

  NOTES
  
    Any or all of the output arguments can be NULL. The arguments starting
    from 'num_inters' and upto and including 'inters_endptsobj' are
    regarded as output arguments.

  HISTORY

    NP   : 10/11/93  :  Delete non-manifold intersections (oppositely oriented)
                        and tangential intersections (non-oriented) ONLY if the
                        EMSINT_TRIM_IGNOREVOLUME option is set. Also, set the
                        "EMSintobj_overlap" bit for coincident intobjs in the
                        "mark_for_dupinters" function.
    Jack : 06/01/93  :  Moved initialization of loc_world_opts to top of file
                        to fix Purify umr.  Also, commented out the labels
                        Generate_inters and Fit_inters since they were not 
                        referenced.
    SM/NP: 09/30/92  :  The curve fitting function "EMsfsfoutcv" is now called
			AFTER refinement, instead of before it. The reason is 
			as follows: 
                        During refinement, it is easy to extend a linestring
                        to an exact point. But, if the linestring has
			already been fitted with a curve, then we are forced to
			make a polynomial extension, which will not necessarily
			end at the exact point. This will mean end points of
			intersection could be more than bastol apart and create
			problems with downstream merging of curves etc. 
    NP  :  06/04/92  :  Always set the "EMSINT_TRIM_PROCOVERLAP" option (and 
			not only during double check only).  This is so that
			intersections partially overlapping with boundaries are
      			split while trimming so that slivers dont form later 
                        on.
    NP  :  05/19/92  :  Added "timer" functions to time intersections.
    NP  :  04/20/92  :  Added two new calls to EMfixsfintout during 
                        double-check to identify duplicate intersections that 
                        are oppositely oriented on the surface, mark them as
                        non-oriented and then delete them.
    SS  :  03/15/90  :  Added removal of topologically/geometrically
                        redundant intersections before and after "refinement".
    SS  :  09/17/89  :  Added the support for IGEstop() - interrruption
                        capability.
    SM  :  07/28/89  :  Added the call to EMfix_volumeint for the option
                        to output only 'cutting' intersections.
    SS  :  06/07/89  :  Creation. This is the first portion of the
		        old EMjoiningBoolean method. The second part of
                        the same method has gone into the file EMsfbool.I
    SS  :  05/25/88  :  Return more appropriate message-codes in the case
                        of tangencies.
    SM  :  29-Apr-88 :  Instead of calling EMfix_sfint_uvtrace call
                        EMfix_refine_intdata(). I need the traced
                        intersection on both the solids simultaneously,
                        for refinement. This warrants the change mentioned.
    SM  :  05-Apr-88 :  Call EMfix_sfint_uvtrace function. This function
                        will refine trim points by computing the exact
                        intersections and also merge subgroups on the
                        same surface. 
                        Also made some timer related changes. I am cheking
                        the file in with these timer changes knowningly and
                        will be responsible for their removal once their
                        use is over.
    jBk :  09-Mar-88 :  Changed two erroneous occurrences of
                        EMS_I_Intersection with EMS_I_NoIntersection.
                        Made change recommended by Siki to put num_inters
                        initialization into the loop in which it is used.
    SS  :  11/24/87  :  Added the functionality to process duplicates
                        that might be generated because of coincident,
                        coplanar surfaces.
    DLB :  11/03/87  :  Modified for version 1.1.0
    SS  :  03/01/87  :  Creation
*/

class implementation EMSsurface;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "timerdef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWmodel.h"
#include "PWapi/duplicate.h"
#include "PWapi/relstable.h"
#include "PWapi/delint.h"
#include "PWapi/degenint.h"
  
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

/*
 * Defined constants used herein. Their meaning should be
 * self-explanatory.
 */

#define NUM_GROUP_STATIC 5

#define NUM_INTERNAL_SAMPLES 3
#define NUM_FIXVOLUME_SAMPLES	1

#define MATCH 0

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_GRcompcurve_class_id;
extern IGRboolean _fit_sfsfint_xyz_data;
extern IGRboolean _use_timers;
extern IGRboolean _pathway_orient, _pathway_trim;

from GRcurve import GRrevparm;
from EMSsubbs import EMpassloop, EMpartolbasis;
from EMSboundary import EMgetsurface_info;
from EMSedge import EMinternalpt;
from EMSloopset import EMpt_location;

%safe
static void mark_for_dupinters();
static IGRboolean degelem();
%endsafe


IGRlong EMintersect_surfaces (msg, sf1, sf1env, numsfs2, sfs2, sfs2env,
                              inters_opts, world_opts, param_opts, trim_opts,
                              const_args, num_inters,
                              sf1_inters, sfs2_inters,
                              sf1_tracedata, sfs2_tracedata,
                              inters_outputobj, inters_endptsobj,
                              status_str)
IGRlong *msg;
struct GRid *sf1;
IGRint numsfs2;
struct EMSdataselect *sfs2;
struct GRmdenv_info *sf1env, *sfs2env;
IGRushort inters_opts, world_opts, param_opts, trim_opts;
struct GRvg_construct *const_args;
IGRint *num_inters;
struct EMSinters **sf1_inters, **sfs2_inters;
struct EMSsftracedata *sf1_tracedata, *sfs2_tracedata;
GRobjid *inters_outputobj, *inters_endptsobj;
IGRchar *status_str;
{
  IGRboolean int1req, int2req, reversed, endinx, start, outputobj;
  IGRboolean handle_stop;
  IGRboolean double_chk, tocopy, togroup, tocomposite;
  IGRboolean **subgrp_rev[2], ***elem_rev[2], *grp_closed[2];
  IGRboolean **subgrp_closed[2], sfinttrace_alloced[2],check,operate_first;
  /***** IGRchar loc_status_str[MS_MAX_MSG_LENGTH+1]; ******************/
  IGRchar dot[2];
  IGRushort loc_world_opts, loc_param_opts, loc_trim_opts, loc_inters_opts;
  IGRushort must_flags, props;
  IGRshort *mattyp;
  IGRint i, j, k, opinx, srfinx, crvinx, relinx, sgrpinx;
  IGRint count, perform_retrace, elemlim;
  IGRint num_grps[2], *num_subgrps_grp[2], **num_elems_subgrp[2];
  IGRint num_samplepts, numdel, nummarked, numchged, nummarkeddel;
  IGRint numnonorient, numdupother, loc_num_inters, loc_tot_num_inters;
  IGRint num_push_coinc_1, num_push_coinc_2, num_del_1, num_del_2;
  IGRlong msg_loc, stat_OM, savemsg;
  IGRdouble lentol, tracetol, *mat;
  IGRpoint dumpt, pt;
  GRobjid obj;
  GRspacenum constos;
  struct EMSinters *inters[2], *inters_loc, **inters_loc_ptr;
  struct EMSintobj ***elems[2], *intobj_loc;
  struct GRmdenv_info idenv, *sf1env_ptr, *sfs2env_ptr;
  struct EMSsftracedata *tracedata;
  struct GRid *outobjs, outobjsmem[NUM_GROUP_STATIC], compid;
  struct GRid *push_coinc_list_1[2], *push_coinc_list_2[2];
  struct GRid *delete_list_1[2], *delete_list_2[2];
  struct GRpost_info post_info;
  OM_S_CHANSELECT chan_to_comps, chan_to_owners;
  extern IGRboolean IGEstop();
  extern IGRint EMfixsfintout(), EMfix_volumeint(), EMpush_coinc_edges();
  extern IGRlong EMmake_chanselect(), EFbuild_graphic_group();
  extern void EMsfinttrace(), EMfix_and_refine_intdata();
  extern void EMsfinttrace_free(), EMsfintedpar_free(), EMidmatrix();

 
  if (_use_timers)
    start_timer (T_EMINTERSECT_SURFACES);

  /* 
   * If pathway orientation is set, 
   *   o set the option for PUSHBADCOINC
   *   o set the option SKIPFIXING
   */
  if (_pathway_orient)
  { 
    
    if (inters_opts & EMS_SFINT_PUSHBADCOINC)
      inters_opts = inters_opts & ~EMS_SFINT_PUSHBADCOINC;
    
    if (!(inters_opts & EMS_SFINT_SKIPFIXING))
      inters_opts = inters_opts | EMS_SFINT_SKIPFIXING;
  }
 
  *msg = EMS_S_Success;
  savemsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Initialize appropriate output arguments. 
   */

  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    tracedata = opinx == FIRST ? sf1_tracedata : sfs2_tracedata;
    if (tracedata)
      {
      tracedata->num_grps = 0;
      tracedata->num_subgrps_grp = NULL;
      tracedata->num_elems_subgrp = NULL;
      tracedata->elems = NULL;
      tracedata->subgrp_rev = NULL;
      tracedata->elem_rev = NULL;
      tracedata->grp_closed = NULL;
      tracedata->subgrp_closed = NULL;
      }
    }

  if (inters_outputobj)
    *inters_outputobj = NULL_OBJID;
  if (inters_endptsobj)
    *inters_endptsobj = NULL_OBJID;

  /*
   * Initialize internal, pointers, variables, etc. Check the consistency of
   * the arguments. If it is an inappropriate set, return an InvalidArg.
   */

  numnonorient = 0;
  nummarkeddel = 0;
  perform_retrace = FALSE;
  outobjs = NULL;
  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    inters[opinx] = NULL;
    num_grps[opinx] = 0;
    num_subgrps_grp[opinx] = NULL;
    num_elems_subgrp[opinx] = NULL;
    elems[opinx] = NULL;
    subgrp_rev[opinx] = NULL;
    elem_rev[opinx] = NULL;
    grp_closed[opinx] = NULL;
    subgrp_closed[opinx] = NULL;
    sfinttrace_alloced[opinx] = FALSE;
    }
  delete_list_1[0] = NULL;
  delete_list_1[1] = NULL;
  push_coinc_list_1[0] = NULL;
  push_coinc_list_1[1] = NULL;

  delete_list_2[0] = NULL;
  delete_list_2[1] = NULL;
  push_coinc_list_2[0] = NULL;
  push_coinc_list_2[1] = NULL;

  double_chk = inters_opts & EMS_SFINT_DOUBLECHECK;
  numdupother = 0;
  handle_stop = inters_opts & EMS_SFINT_HANDLESTOP;

  outputobj = inters_outputobj || inters_endptsobj;
  if (sf1_inters || sf1_tracedata || outputobj)
    {
    int1req = TRUE;
    if (sf1_inters)
      inters[FIRST] = *sf1_inters;
    }
  else
    int1req = FALSE;
  if ((!(inters_opts & EMS_SFINT_SKIPSFINT) &&
       sfs2 && sfs2->datatype != EMSdata_plane) ||
      sfs2_inters || 
      sfs2_tracedata || 
      (!(inters_opts & EMS_SFINT_SKIPSFINT) &&
       !(inters_opts & EMS_SFINT_NOREFINE)))
    {
    int2req = TRUE;
    if (sfs2_inters)
      inters[SECOND] = *sfs2_inters;
    }
  else
    int2req = FALSE;

  if (!sf1env || !sfs2env)
    EMidmatrix (&msg_loc, &idenv.matrix_type, idenv.matrix);
  if (!sf1env)
    sf1env_ptr = &idenv;
  else
    sf1env_ptr = sf1env;
  if (!sfs2env)
    sfs2env_ptr = &idenv;
  else
    sfs2env_ptr = sfs2env;

  loc_world_opts = world_opts;
  if(!_fit_sfsfint_xyz_data)
   loc_world_opts |= EMSINT_WORLD_NOFITTEDCV;

  if (outputobj)
    loc_world_opts |= EMSINT_OUTPUT_WORLD |
                       (inters_outputobj ? EMSINT_WORLD_OBJECT : NULL);

  loc_param_opts = param_opts;
  if ((int1req || int2req) && !(inters_opts & EMS_SFINT_NOREFINE))
    loc_param_opts |= EMSINT_OUTPUT_PARAM;

  loc_trim_opts = trim_opts | EMSINT_TRIM_PROCOVERLAP;
  if (double_chk)
    loc_trim_opts |= EMSINT_TRIM_MOREPRECISE; 
  if (handle_stop)
    loc_trim_opts |= EMSINT_TRIM_HANDLESTOP;

  EMerr_hndlr ((outputobj || (world_opts & EMSINT_WORLD_OBJECT)) && 
   !const_args, *msg, EMS_E_InvalidArg, ret_end);

  if (status_str)
    strcpy (dot, ".");

  /*
   * Check if the options indicate that the intersection list is being
   * input. If so then skip the production of this intersection list and
   * proceed to stage two. Check if the options selected and the I/O
   * arguments are consistent.
   */

  if (inters_opts & EMS_SFINT_AUTODOUBLECHECK)
    {
    EMerr_hndlr ((sf1_inters && *sf1_inters) || (sfs2_inters && *sfs2_inters),
     *msg, EMS_E_InvalidArg, ret_end);
    }

  if (inters_opts & EMS_SFINT_SKIPSFINT)
    {
    EMerr_hndlr (!sf1_inters && !sfs2_inters, *msg, EMS_E_InvalidArg, ret_end);
    goto Fixing_Inters;
    }
  
  /*
   * Obtain the intersection between the two operands using the options
   * passed in. If the option indicates that intersections must occur
   * with every member of set B, and if there is atleast one such 
   * non-occurence, exit this function.
   *
   * If the option to reverse the orientation on the second operand's
   * intersection-list has been set, then do so soon after it's generation.
   * Care needs to be taken to manage the direction-dependent property bits
   * of the affected EMSintobjs.
   *
   */

  if (status_str)
    {
    strcat (status_str, dot);
    UI_status (status_str);
    }

  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    goto ret_end;
    }

  if (_use_timers)
     start_timer(T1_SFSFINT);

  loc_tot_num_inters = 0;
  for (srfinx=0; srfinx<numsfs2; srfinx++)
    {
    loc_num_inters = 0;
    stat_OM = om$send (msg = message EMSsurface.EMsfsfint (&msg_loc,
               &sf1env_ptr->matrix_type, sf1env_ptr->matrix, const_args, 
               &sfs2[srfinx], sfs2env_ptr, 
               loc_world_opts, loc_param_opts, loc_trim_opts,
               (IGRlong *)(&loc_num_inters), int1req ? &inters[FIRST] : NULL,
               int2req ? &inters[SECOND] : NULL),
               targetid = sf1->objid, targetos = sf1->osnum,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (msg_loc == EMS_I_Interrupt)
      {
      *msg = msg_loc;
      stat_OM = OM_S_SUCCESS;
      goto ret_end;
      }

    if (inters_opts & EMS_SFINT_MUSTINTERSECT && !loc_num_inters)
      {
      if (double_chk && outputobj)
        {
        if (!EMSerror (savemsg))
          savemsg = EMS_E_NoIntersection;
        }
      else
        {
        *msg = EMS_I_NoIntersection;
        goto ret_end;
        }
      }

    if (num_inters)
      *num_inters += loc_num_inters;
    loc_tot_num_inters += loc_num_inters;
    }

  if( _pathway_orient )
  {
     /*
      * Pathway orientation
      */

     int    optype;
     double xyztol;
     struct PWrelstable  relstable;
     
     BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);

     if( loc_param_opts & EMSINT_ORIENT_OUTPUT &&
         loc_param_opts & EMSINT_ORIENT_RIGHT)
     {
        optype = 2; /* intersection */
     }
     else if ( inters_opts & EMS_SFINT_REVERSESECONDINT)
     {
        optype = 3; /* difference */
     }
     else
     {
        optype = 1; /* union */
     }
     relstable.table = NULL;
     pwGetBooleanRelsTable( optype, &relstable );
     if( relstable.num_entries )
     relstable.table = (unsigned int *)alloca( relstable.num_entries *
                                               sizeof(unsigned int ) );
     pwGetBooleanRelsTable( optype, &relstable );

     pwInitializeRelsTable( &relstable );

     inters_loc = inters[FIRST];
     while (inters_loc)
     {
        intobj_loc = inters_loc->cvs;
        while (intobj_loc)
        {
           pwValidateIntRels( intobj_loc );
           intobj_loc = intobj_loc->next;
        }
        inters_loc = inters_loc->next;
     }

     pwProcessDupInt (inters, xyztol);
     pwDeleteInt( inters );
     pwOrientDegenInt (&inters[0], xyztol);
     pwOrientDegenInt (&inters[1], xyztol); 
     
    
  } /* end of pathway orientation */
  

  if (_use_timers)
    stop_timer (T1_SFSFINT, FALSE, "");


  if (!(int1req || int2req))
    {
    *msg = loc_tot_num_inters ? EMS_I_Intersect : EMS_I_NoIntersection;
    goto ret_end;
    }
  else if (!loc_tot_num_inters || (!inters[FIRST] && !inters[SECOND]))
    {
    *msg = EMS_I_NoIntersection;
    goto ret_end;
    }

  if (inters_opts & EMS_SFINT_REVERSESECONDINT && !(_pathway_orient ) )
    {
    inters_loc = inters[SECOND];
    while (inters_loc)
      {
      intobj_loc = inters_loc->cvs;
      while (intobj_loc)
        {
        intobj_loc->reversed = !intobj_loc->reversed;

        intobj_loc->fwd = NULL;
        intobj_loc->bwd = NULL;
        props = intobj_loc->props;
        props &= ~(EMSintobj_exact_atstart | EMSintobj_exact_atstop |
                   EMSintobj_fwd_connectuv | EMSintobj_bwd_connectuv);
        if (props & EMSintobj_fwd_noconnectuv &&
            !(props & EMSintobj_bwd_noconnectuv))
          {
          props |= EMSintobj_bwd_noconnectuv;
          props &= ~EMSintobj_fwd_noconnectuv;
          }
        else if (props & EMSintobj_bwd_noconnectuv &&
                 !(props & EMSintobj_fwd_noconnectuv))
          {
          props |= EMSintobj_fwd_noconnectuv;
          props &= ~EMSintobj_bwd_noconnectuv;
          }
        intobj_loc->props = props;

        intobj_loc = intobj_loc->next;
        }
      inters_loc = inters_loc->next;
      }
    }

  /*
   * Check for topologically and geometrically redundant intersections.
   * For example: intersections that degenerate to points and are incident
   * at an existing vertex.
   *
   * Any intersection that was not orientable during the regular surface
   * intersection, is sent for orientation with a different algorithm.
   * This algorithm will delete the intersection if it is not a 'cutting
   * tangency' (for now all non-oriented intersections are summarily
   * dismissed).
   *
   * When contiguos intersections on a given surface are found such that their
   * common ends lie on the existing boundary of the surface, these are
   * specially marked so that they will not be picked up within the same
   * sub-group. This ensures that the existing boundary will get split in
   * a later processing in the Boolean code.
   * 
   * Due to surfaces incident along existing edges of the other solid, we
   * may obtain multiple intersections lying along this edge, since our
   * basic algorithm is one of surface vs. surface. A process is gone
   * through to find all such intersections (that lie along existing edges)
   * and mark them for further processing. A side-effect of this process
   * is also that such intersections are verified to contain their 
   * end-incidence information (EMSsfintedpar). If they did not possess it
   * before this point in the process, it is obtained for them by ....
   *
   * Now that new information about end-incidence is available we may find
   * more redundancies, since the redundancy check was based on topological
   * information at the ends of degenerate segments.
   *
   * Multiple intersections occurring within the surface and across from
   * surfaces are processed. The idea is to keep the "best" out of them.
   *
   * Intersections that run along existing edges may have to be pushed
   * across common-edges in order to not produce loops which have coincident
   * edges in them (slivers).
   *
   * If the option to output only 'cutting' intersections is on, then some
   * special processing is gone through.
   */

  Fixing_Inters:
  if (status_str)
    {
    strcat (status_str, dot);
    UI_status (status_str);
    }

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, lentol);
  lentol += lentol;
  if (double_chk || inters_opts & EMS_SFINT_CHTTRACETOL || _pathway_trim)
    tracetol = lentol;
  else
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tracetol);
  num_samplepts = NUM_INTERNAL_SAMPLES;

  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    goto ret_end;
    }

  if (_use_timers)
    start_timer (T1_FIXSFINTOUTS);
  
  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, 0, 
             NULL, NULL,
             NULL, NULL,
             chk_redundant, 
             NULL,
             &nummarked, &numdel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, num_samplepts, 
             NULL, NULL,
             NULL, NULL,
             chk_nonoriented,
             NULL, 
             &nummarked, &numnonorient);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_IntersectOrient, 
   ret_end);

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, num_samplepts, 
             NULL, NULL,
             NULL, NULL,
             chk_noconnect,
             NULL,
             &nummarked, &nummarkeddel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (inters_opts & EMS_SFINT_SKIPFIXING)
    goto Before_Pushing;

  if (int1req)
    mark_for_dupinters (&sf1env_ptr->matrix_type, sf1env_ptr->matrix,
     inters[FIRST]);
  if (int2req)
    mark_for_dupinters (&sfs2env_ptr->matrix_type, sfs2env_ptr->matrix,
     inters[SECOND]);

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, 0, 
             NULL, NULL,
             NULL, NULL,
             chk_redundant, 
             NULL,
             &nummarked, &numdel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);

  if (!(trim_opts & EMSINT_TRIM_IGNOREVOLUME))
    {
    stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
               sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
               &lentol, num_samplepts,
               EMSintobj_dupthissurf, EMSintobj_coincident,
               EMSintobj_dupthissurf, EMSintobj_coincident,
               chk_opporiented,
               NULL,
               &nummarked, &numdel);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
               sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
               &lentol, num_samplepts,
               NULL, NULL,
               NULL, NULL,
               chk_nonoriented,
               NULL,
               &nummarked, &numnonorient);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_IntersectOrient,
     ret_end);
    }

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, num_samplepts,
             EMSintobj_dupthissurf, NULL,
             EMSintobj_dupthissurf, EMSintobj_coincident,
             chk_dupsamesurf,
             EMSfixsfint_act_delunmarked,
             &nummarked, &numdel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, num_samplepts, 
             EMSintobj_dupothersurf, NULL,
             EMSintobj_dupothersurf, EMSintobj_coincident,
             chk_dupothersurf,
             EMSfixsfint_act_delunmarked,
             &nummarked, &numdel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, num_samplepts, 
             NULL, NULL,
             NULL, NULL,
             chk_deletable,
             NULL,
             &nummarked, &nummarkeddel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);

  if (_use_timers)
    stop_timer (T1_FIXSFINTOUTS, FALSE, "");

  Before_Pushing:
  if (inters_opts & EMS_SFINT_SKIPFIXING &&
      !(inters_opts & EMS_SFINT_PUSHBADCOINC))
    goto Trace_Inters;

 num_del_1 = 0;
 num_push_coinc_1 = 0;
 num_del_2 = 0;
 num_push_coinc_2 = 0;

 delete_list_1[0] = NULL;
 delete_list_1[1] = NULL;
 push_coinc_list_1[0] = NULL;
 push_coinc_list_1[1] = NULL;

 delete_list_2[0] = NULL;
 delete_list_2[1] = NULL;
 push_coinc_list_2[0] = NULL;
 push_coinc_list_2[1] = NULL;

 /***if (_pathway_orient)
 {
   double xyztol;
   BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
   for (opinx=FIRST; opinx<=SECOND; opinx++)
   {
     pwPushCoincEdges (&inters[opinx], xyztol);
   }
 } *******/
 if (!_pathway_orient)
 {
  check=TRUE;
  if (inters_opts & EMS_SFINT_PUSHBADCOINC)
    for (opinx=FIRST; opinx<=SECOND; opinx++)
      if (opinx == FIRST ? int1req : int2req)
        {
        stat_OM = EMpush_coinc_edges (&msg_loc, &inters[opinx],
                   opinx == FIRST ? sf1env_ptr : sfs2env_ptr, NULL,
                   num_samplepts, NULL, NULL, &nummarked, &numchged, &check,
                   &operate_first,
                   opinx == FIRST ? push_coinc_list_1 : push_coinc_list_2,
                   opinx == FIRST ? delete_list_1 : delete_list_2,
                   opinx == FIRST ? &num_push_coinc_1 : &num_push_coinc_2,
                   opinx == FIRST ? &num_del_1 : &num_del_2,
                   NULL, NULL, NULL, NULL);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }

  if (trim_opts & EMSINT_TRIM_ONLYCUTTING)
     operate_first =FALSE;
  else
     operate_first =TRUE;

  check=FALSE;

  if (inters_opts & EMS_SFINT_PUSHBADCOINC)
    for (opinx=FIRST; opinx<=SECOND; opinx++)
      if (opinx == FIRST ? int1req : int2req)
        {
        stat_OM = EMpush_coinc_edges (&msg_loc, &inters[opinx],
                   opinx == FIRST ? sf1env_ptr : sfs2env_ptr, NULL,
                   num_samplepts, NULL, NULL, &nummarked, &numchged, &check,
                   &operate_first,
                   opinx == FIRST ? push_coinc_list_2 : push_coinc_list_1,
                   opinx == FIRST ? delete_list_2 : delete_list_1,
                   opinx == FIRST ? &num_push_coinc_2 : &num_push_coinc_1,
                   opinx == FIRST ? &num_del_2 : &num_del_1,
                   opinx == FIRST ? push_coinc_list_1 : push_coinc_list_2,
                   opinx == FIRST ? delete_list_1 : delete_list_2,
                   opinx == FIRST ? &num_push_coinc_1 : &num_push_coinc_2,
                   opinx == FIRST ? &num_del_1 : &num_del_2);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        operate_first = (operate_first ?  FALSE :TRUE );

        }
  }

  stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
             sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
             &lentol, num_samplepts, 
             NULL, NULL,
             NULL, NULL,
             chk_deletable,
             NULL,
             &nummarked, &nummarkeddel);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);

  if (inters_opts & EMS_SFINT_SKIPFIXING &&
      inters_opts & EMS_SFINT_PUSHBADCOINC)
    goto Trace_Inters;

  if (trim_opts & EMSINT_TRIM_ONLYCUTTING && inters[FIRST] && inters[SECOND])
    {
    num_samplepts = NUM_FIXVOLUME_SAMPLES;
    stat_OM = EMfix_volumeint (&msg_loc, &inters[FIRST], sf1env_ptr, 
	       &inters[SECOND], sfs2env_ptr, &lentol, num_samplepts, NULL, 
	       NULL, NULL, NULL, &nummarked, &numdel, const_args, FALSE, TRUE);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection, ret_end);
    }

  if (double_chk)
    {
    stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
               sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
               &lentol, NULL, 
               NULL, NULL,
               NULL, NULL,
               chk_midptcoinc,
               EMSfixsfint_act_splitinters,
               &nummarked, &nummarkeddel);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Trace out the pieces of the intersection (intersection curves) on
   * a per surface basis in uv-space (if applicable) and then on a global
   * basis in xyz-space (if applicable), such that there is maximium
   * positional continuity between the intersection curve elements.
   * Peform refinement on the intersections unless this has been
   * inhibited. After refinement it may turn out that there are redundant
   * pieces of intersection data (geometrically as well as topologically
   * speaking). If found, delete them and perform a retrace.
   *
   * If the trace indicated that some ambiguity existed in that more than
   * one possible paths could be taken to complete the trace, and this
   * has been indicated as a no-no, then exit with the corresponding
   * return code.
   *
   * If closed intersection data was requested and atleast one of the groups
   * after tracing does not "close", return the appropriate error code.
   *
   * If oriented, uv-data is requested and if atleast one of the uv-elements
   * within a subgroup had to be reversed for the trace, or if subgroups 
   * within a group which lie on the same surface had to be reversed wrt
   * to each other, return correct error code. The rationale behind this
   * criteria is that if the intersections were oriented correctly, such
   * reversals would not have to take place.
   *
   * The condition of elements being degenerate is handled in that the flag
   * indicating any reversal is ignored and the flag indicating closure is
   * reconsidered in the light of a more global picture.
   *
   * If the requirement was no ambiguity in the trace and there is ambiguity,
   * an error condition has occurred. But the error is not severe enough
   * to abort the function. So continue with the rest of the processing
   * if this is in a double-check mode and outputobj is TRUE, remembering this
   * error condition.
   */

  Trace_Inters:
  if (status_str)
    {
    strcat (status_str, dot);
    UI_status (status_str);
    }
  
  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    goto ret_end;
    }

  must_flags = EMS_SFINT_MUSTCLOSE | EMS_SFINT_MUSTORIENT |
               EMS_SFINT_MUSTNOAMBIGUOUS;
  if ((inters_opts & EMS_SFINT_NOREFINE) && !(inters_opts & must_flags) &&
      !(sf1_tracedata || sfs2_tracedata) && !outputobj)
    goto Format_Output;

  if (_use_timers)
    start_timer (T1_TRACE);

  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    if (opinx == FIRST)
      {
      if (!int1req)
        continue;
      mattyp = &sf1env_ptr->matrix_type;
      mat = sf1env_ptr->matrix;
      }
    else
      {
      if (!int2req)
        continue;
      mattyp = &sfs2env_ptr->matrix_type;
      mat = sfs2env_ptr->matrix;
      }
    EMsfinttrace (&msg_loc, mattyp, mat, inters[opinx], NULL, &tracetol,
     &num_grps[opinx], &num_subgrps_grp[opinx], &num_elems_subgrp[opinx],
     &elems[opinx], &subgrp_rev[opinx], &elem_rev[opinx], 
     &grp_closed[opinx], &subgrp_closed[opinx]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    sfinttrace_alloced[opinx] = TRUE;

    if (inters_opts & EMS_SFINT_MUSTNOAMBIGUOUS && msg_loc == EMS_I_Ambiguous)
      {
      if (double_chk && outputobj)
        {
        if (!EMSerror (savemsg))
          savemsg = EMS_E_Ambiguous;
        }
      else
        {
        *msg = EMS_E_Ambiguous;
        goto ret_end;
        }
      }
    }

  if (_use_timers)
    stop_timer (T1_TRACE, FALSE, "");
 
  if (_use_timers)
    start_timer (T1_REFINE);

  if (! (inters_opts & EMS_SFINT_NOREFINE))
    {
    mattyp = int1req ? &sf1env_ptr->matrix_type : &sfs2env_ptr->matrix_type;
    mat = int1req ? sf1env_ptr->matrix : sfs2env_ptr->matrix;
    EMfix_and_refine_intdata(&msg_loc, mattyp, mat,
     &sfs2env_ptr->matrix_type, sfs2env_ptr->matrix, const_args,
     int1req ? inters[FIRST] : inters[SECOND], 
     int1req && int2req ? inters[SECOND] : NULL,
     NULL, &tracetol, NULL, 
     num_grps, num_subgrps_grp, num_elems_subgrp, elems, subgrp_rev, elem_rev,
     grp_closed, subgrp_closed, inters_opts, world_opts, param_opts,trim_opts);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (int2req && !int1req)
      {
      num_grps[SECOND] = num_grps[FIRST];
      num_subgrps_grp[SECOND] = num_subgrps_grp[FIRST];
      num_elems_subgrp[SECOND] = num_elems_subgrp[FIRST];
      elems[SECOND] = elems[FIRST];
      subgrp_rev[SECOND] = subgrp_rev[FIRST];
      elem_rev[SECOND] = elem_rev[FIRST];
      grp_closed[SECOND] = grp_closed[FIRST];
      subgrp_closed[SECOND] = subgrp_closed[FIRST];
      }

    if (!perform_retrace)
      {
      stat_OM = EMfixsfintout (&msg_loc, int1req ? &inters[FIRST] : NULL,
                 sf1env_ptr, int2req ? &inters[SECOND] : NULL, sfs2env_ptr,
                 &lentol, num_samplepts,
                 NULL, NULL,
                 NULL, NULL,
                 chk_redundant,
                 NULL,
                 &nummarked, &perform_retrace);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr (msg_loc == EMS_I_NoMore, *msg, EMS_I_NoIntersection,
       ret_end);

      if (perform_retrace)
        {
        for (opinx=FIRST; opinx<=SECOND; opinx++)
          if (sfinttrace_alloced[opinx])
            {
            EMsfinttrace_free (&msg_loc, num_grps[opinx],
             num_subgrps_grp[opinx], num_elems_subgrp[opinx], elems[opinx],
             subgrp_rev[opinx], elem_rev[opinx], grp_closed[opinx],
             subgrp_closed[opinx]);
            sfinttrace_alloced[opinx] = FALSE;
            }
        goto Trace_Inters;
        }
      }
    }

  if (_use_timers)
    stop_timer (T1_REFINE, FALSE, "");

  if (status_str)
    {
    strcat (status_str, dot);
    UI_status (status_str);
    }

  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    goto ret_end;
    }

  /* Optionally, fit the xyz stroked data with a cubic curve.
     SM 05/18/92.
     Do the above only if intersections are to be output as objects, so
     operations like booleans do not pay the price. I cannot do the fitting
     in the 'Format_Output' stage because uv and xyz data can become
     inconsistent during refinement.
  */

  if ((!(loc_world_opts & EMSINT_WORLD_NOFITTEDCV)) &&
      (inters[FIRST] || inters[SECOND]) && inters_outputobj)
    {
    stat_OM = EMsfsfoutcv (&msg_loc, 
               inters[FIRST] ? inters[FIRST] : inters[SECOND], loc_world_opts, 
               const_args);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_CurveError, 
     ret_end);
    }

  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    if (!(opinx == FIRST ? int1req : int2req))
      continue;

    for (i=0; i<num_grps[opinx]; i++)
      {
      /*
       * If group is not closed, and the options indicate that only
       * closed groups are required, then set the return code and exit.
       */
      if(!grp_closed[opinx][i] && inters_opts & EMS_SFINT_MUSTCLOSE) 
                                           grp_closed[opinx][i] = 1;
      if (!grp_closed[opinx][i] && inters_opts & EMS_SFINT_MUSTCLOSE)
        {
        if (double_chk && outputobj)
          {
          if (!EMSerror (savemsg))
            savemsg = numnonorient ? EMS_E_IntersClosureOrient : 
                                     EMS_E_IntersectClosure;
          }
        else
          {
          *msg = numnonorient ? EMS_E_IntersClosureOrient : 
                                EMS_E_IntersectClosure;
          goto ret_end;
          }
        }

      for (j=0; j<num_subgrps_grp[opinx][i]; j++)
        {
        /*
         * If this subgroup is degenerate the reversal flag
         * does not make any sense. Also if the group has more than one
         * subgroups, the closure flag for this subgroup does not make
         * any sense. So turn these flags off. 
         */

        if (num_elems_subgrp[opinx][i][j] == 1 && 
            degelem (elems[opinx][i][j], FIRST))
          {
          subgrp_rev[opinx][i][j] = FALSE;

          if (num_subgrps_grp[opinx][i] > 1)
            subgrp_closed[opinx][i][j] = FALSE;
          }

        /*
         * If the element had to be reversed and the options indicate that
         * only oriented intersections are required then set the return code
         * and exit. But if the element is degenerate, the elem_rev setting
         * does not make sense. So turn it off.
         */

        for (k=0; k<num_elems_subgrp[opinx][i][j]; k++)
          {
          if (elem_rev[opinx][i][j][k])
            {
            if (degelem (elems[opinx][i][j], k))
              elem_rev[opinx][i][j][k] = FALSE;
            else if (inters_opts & EMS_SFINT_MUSTORIENT)
              {
              if (double_chk && outputobj)
                {
                if (!EMSerror (savemsg))
                  savemsg = EMS_E_IntersectOrient;
                }
              else
                {
                *msg = EMS_E_IntersectOrient;
                goto ret_end;
                }
              }
            }
          }
        }
      }
    }

  /*
   * If the intersections are to be packaged into graphics group/composites
   * or curves and/or the end-points of groups are to be packaged,
   * perform the necessary manipulations for this.
   */

  Format_Output:
  if (inters_endptsobj)
    {
    count = 0;
    for (i=0; i<num_grps[FIRST]; i++)
      if (!grp_closed[FIRST][i])
        count++;

    if (count)
      {
      constos = const_args->env_info->md_id.osnum;
      mattyp = &const_args->env_info->md_env.matrix_type;
      mat = const_args->env_info->md_env.matrix;

      if (count * 2 > NUM_GROUP_STATIC)
        outobjs = (struct GRid *) om$malloc (size = count * 2 *
                   sizeof (struct GRid));
      else
        outobjs = outobjsmem;
      EMerr_hndlr (!outobjs, *msg, EMS_E_NoDynamicMemory, ret_end);

      count = 0;
      for (i=0; i<num_grps[FIRST]; i++)
        {
        if (grp_closed[FIRST][i])
          continue;

        for (endinx=FIRST; endinx<=SECOND; endinx++)
          {
          sgrpinx = endinx == FIRST ? 0 : num_subgrps_grp[FIRST][i]-1;
          intobj_loc = elems[FIRST][i][sgrpinx];
          reversed = subgrp_rev[FIRST][i][sgrpinx];
          if (endinx == FIRST && reversed || endinx == SECOND && !reversed)
            {
            elemlim = num_elems_subgrp[FIRST][i][sgrpinx]-1;
            for (k=0; k<elemlim; k++)
              intobj_loc = intobj_loc->next;
            reversed ^= elem_rev[FIRST][i][sgrpinx][elemlim];
            }
          else
            reversed ^= elem_rev[FIRST][i][sgrpinx][FIRST];
          reversed ^= intobj_loc->reversed;

          start = !(reversed ^ endinx);
          stat_OM = EMgetendpts_xyz (&msg_loc, mattyp, mat, 
                     &intobj_loc->this_xyzintobj, FALSE, 1,
                     start ? pt : dumpt, start ? dumpt : pt);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

          const_args->display->color++;
          EMoutput_point (&msg_loc, NULL_OBJID, const_args, 1, pt,
           &outobjs[count++]);
          const_args->display->color--;
          EMerr_hndlr (msg_loc == BSFAIL, *msg, EMS_E_Fail, ret_end);
          }
        }

      if (count)
        {
        stat_OM = EFbuild_graphic_group (count, NULL, outobjs,
                   const_args, inters_endptsobj, &msg_loc);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }

      if (outobjs != outobjsmem)
        om$dealloc (ptr = outobjs);
      outobjs = NULL;
      }
    }

  if (inters_outputobj)
    {
    stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    EMomerr_exit (stat_OM, ret_end);
 
    stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
    EMomerr_exit (stat_OM, ret_end);

    tocopy = ((sf1_inters || sfs2_inters) && 
              (!(inters_opts & EMS_SFINT_NOCURVECOPY))) ? TRUE : FALSE;

    togroup = num_grps[FIRST] > 1;

    if (num_grps[FIRST] > NUM_GROUP_STATIC)
      outobjs = (struct GRid *) om$malloc (size = num_grps[FIRST] *
                sizeof (struct GRid));
    else
      outobjs = outobjsmem;
    EMerr_hndlr (!outobjs, *msg, EMS_E_NoDynamicMemory, ret_end);

    constos = const_args->env_info->md_id.osnum;
    for (i=0; i<num_grps[FIRST]; i++)
      {
      tocomposite = num_subgrps_grp[FIRST][i] > 1 ||
                    num_elems_subgrp[FIRST][i][FIRST] > 1;
      if (tocomposite)
        {
        stat_OM = om$construct (classid = OPP_GRcompcurve_class_id,
                   osnum = constos, p_objid = &compid.objid, msg = message
                   GRgraphics.GRconstruct (const_args));
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (*const_args->msg), *msg, EMS_E_CurveError,
         ret_end);
        compid.osnum = constos;
        }

      crvinx = 0;
      relinx = 0;
      for (j=0; j<num_subgrps_grp[FIRST][i]; j++)
        {
        intobj_loc = elems[FIRST][i][j];
        relinx = crvinx;
        for (k=0; k<num_elems_subgrp[FIRST][i][j]; k++)
          {
          obj = intobj_loc->this_xyzintobj.data.object->objid;
          if (tocopy)
            {
	    stat_OM = om$send (msg = message GRgraphics.GRcopy
                       (&msg_loc, const_args->env_info, const_args->env_info, 
                       &obj), targetid = obj, targetos = constos, 
                       senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
            }
          else
            {
            /* 
             * Since we are reusing the same xyz curve objects, update the
	     * inters lists to reflect that no curves are present. This
             * is to prevent these curves from getting deleted when the
             * intersection data is freed.
	     */

            intobj_loc->this_xyzintobj.data.object->objid = NULL_OBJID;
            if (intobj_loc->other_intobj_node)
             intobj_loc->other_intobj_node->this_xyzintobj.data.object->objid =
               NULL_OBJID;
            }

          if (elem_rev[FIRST][i][j][k] ^
              intobj_loc->reversed ^
              subgrp_rev[FIRST][i][j])
            {
            stat_OM = om$send (msg = message GRcurve.GRrevparm (&msg_loc,
                       const_args->env_info), targetid = obj,
                       targetos = constos, senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
            }

          if (tocomposite)
            {
            stat_OM = om$send(msg = message GRconnector.GRrigidconn
                       (&msg_loc, &compid, (IGRlong *)&relinx), targetid = obj, 
	               targetos = constos, senderid = obj);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
            if (!subgrp_rev[FIRST][i][j])
              relinx++;
            }
          crvinx++;
          intobj_loc = intobj_loc->next;
          }
        }
      if (tocomposite)
        {
        post_info.construct_flag = TRUE;
        stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc, 
                   const_args->env_info, &post_info, NULL, &compid.objid),
                   targetid = compid.objid, targetos = constos,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

        outobjs[i].objid = compid.objid;
        }
      else
        outobjs[i].objid = obj;
      outobjs[i].osnum = constos;
      }

    if (togroup)
      {
      stat_OM = EFbuild_graphic_group (num_grps[FIRST], NULL, outobjs,
                 const_args, inters_outputobj, &msg_loc);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    else
      *inters_outputobj = outobjs[FIRST].objid;

    if (outobjs != outobjsmem)
      om$dealloc (ptr = outobjs);
    outobjs = NULL;
    }

  if (sf1_tracedata)
    {
    sf1_tracedata->num_grps = num_grps[FIRST];
    sf1_tracedata->num_subgrps_grp = num_subgrps_grp[FIRST];
    sf1_tracedata->num_elems_subgrp = num_elems_subgrp[FIRST];
    sf1_tracedata->elems = elems[FIRST];
    sf1_tracedata->subgrp_rev = subgrp_rev[FIRST];
    sf1_tracedata->elem_rev = elem_rev[FIRST];
    sf1_tracedata->grp_closed = grp_closed[FIRST];
    sf1_tracedata->subgrp_closed = subgrp_closed[FIRST];
    sfinttrace_alloced[FIRST] = FALSE;
    }

  if (sfs2_tracedata)
    {
    sfs2_tracedata->num_grps = num_grps[SECOND];
    sfs2_tracedata->num_subgrps_grp = num_subgrps_grp[SECOND];
    sfs2_tracedata->num_elems_subgrp = num_elems_subgrp[SECOND];
    sfs2_tracedata->elems = elems[SECOND];
    sfs2_tracedata->subgrp_rev = subgrp_rev[SECOND];
    sfs2_tracedata->elem_rev = elem_rev[SECOND];
    sfs2_tracedata->grp_closed = grp_closed[SECOND];
    sfs2_tracedata->subgrp_closed = subgrp_closed[SECOND];
    sfinttrace_alloced[SECOND] = FALSE;
    }

ret_end:

  /* 
     deallocate memory  for the lists used exclusively by
     the EMpush_coinc_ed() function
  */

  if(push_coinc_list_1[0])
        om$dealloc(ptr = push_coinc_list_1[0]);

  if(push_coinc_list_1[1])
        om$dealloc(ptr = push_coinc_list_1[1]);

  if(delete_list_1[0])
        om$dealloc(ptr = delete_list_1[0]);

  if(delete_list_1[1])
        om$dealloc(ptr = delete_list_1[1]);

  if(push_coinc_list_2[0])
        om$dealloc(ptr = push_coinc_list_2[0]);

  if(push_coinc_list_2[1])
        om$dealloc(ptr = push_coinc_list_2[1]);

  if(delete_list_2[0])
        om$dealloc(ptr = delete_list_2[0]);
  if(delete_list_2[1])
        om$dealloc(ptr = delete_list_2[1]);


  /*
   * This should logically be in the 'formatting' piece of the code. But
   * due to the special nature of these arguments (input/output) any 
   * output generated is returned (inspite of error condition). This list
   * is then not messed with for freeing purposes. The caller has to do
   * the freeing.
   */

  if (sf1_inters)
    *sf1_inters = inters[FIRST];

  if (sfs2_inters)
    *sfs2_inters = inters[SECOND];

  /*
   * Deallocate the memory that has been allocated
   * for use by this function, locally.
   */

  for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
    if (!(opinx == FIRST ? sf1_inters : sfs2_inters))
      {
      EMinters_data_free (&msg_loc, inters[opinx], MAXINT, NULL,
       EMsfintedpar_free);
      EMinters_free (inters[opinx], MAXINT);
      }

    if (sfinttrace_alloced[opinx])
      {
      EMsfinttrace_free (&msg_loc, num_grps[opinx], num_subgrps_grp[opinx],
       num_elems_subgrp[opinx], elems[opinx], subgrp_rev[opinx],
       elem_rev[opinx], grp_closed[opinx], subgrp_closed[opinx]);
      }
    }

  /*
   * The message return code may have to be altered, based on 'savemsg'
   * and/or the 'no intersection' state or other options.
   */

  if (EMSerror (savemsg))
    *msg = savemsg;

  if (*msg == EMS_I_NoIntersection || *msg == EMS_I_IntersectOrient)
    {
    if (inters_opts & EMS_SFINT_MUSTINTERSECT)
      *msg = EMS_E_NoIntersection;
    else if (int1req || int2req)
      *msg = EMS_I_NotFound;
    }
  else if (inters_opts & EMS_SFINT_MARKEDDELINFO && *msg == EMS_S_Success &&
           nummarkeddel)
    *msg = EMS_I_Clipped;

  /*
   * On a failure with the  auto-double-check option being set, proceed
   * to call this method recursively with the double-check option set. This,
   * in the hope of better performance with the double-checking algorithm.
   * I/O arguments must be rid of any memory that might have gotten allocated
   * in this call.
   */

  if (EMSerror (*msg) &&
      inters_opts & EMS_SFINT_AUTODOUBLECHECK &&
      !double_chk)
    {

    /** REMOVED. This was causing raised eyebrows during rib processing ******
    if (status_str && strncmp (&status_str[SECOND], "pecial", 6) != MATCH)
      {
      strcpy (loc_status_str, "Special ");
      strcat (loc_status_str, status_str);
      strcpy (status_str, loc_status_str);
      }
     *************************************************************************/

    if (num_inters)
      *num_inters = 0;

    for (opinx=FIRST; opinx<=SECOND; opinx++)
      {
      inters_loc_ptr = opinx == FIRST ? sf1_inters : sfs2_inters;
      if (inters_loc_ptr)
        {
        EMinters_data_free (&msg_loc, *inters_loc_ptr, MAXINT, NULL,
         EMsfintedpar_free);
        EMinters_free (*inters_loc_ptr, MAXINT);
        *inters_loc_ptr = NULL;
        }
      }

    loc_inters_opts = inters_opts | EMS_SFINT_DOUBLECHECK;
    loc_inters_opts &= ~EMS_SFINT_MUSTNOAMBIGUOUS;
    stat_OM = EMintersect_surfaces (msg, sf1, sf1env, numsfs2, sfs2, sfs2env,
               loc_inters_opts, world_opts, param_opts,
               trim_opts, const_args, num_inters, sf1_inters, sfs2_inters,
               sf1_tracedata, sfs2_tracedata, inters_outputobj,
               inters_endptsobj, status_str);
    }

  if (EMSerror (*msg) && !EMSerror (stat_OM))
    stat_OM = OM_E_ABORT;
  else if (EMSerror (stat_OM) && !EMSerror (*msg))
    *msg = EMS_E_OMerror;

  if (_use_timers)
     stop_timer (T_EMINTERSECT_SURFACES, FALSE, "");

  return (stat_OM);
}





/*
 * A locally used function to detect if a given element is degenerate
 * or not.
 */

static IGRboolean degelem (intobj, inx)
struct EMSintobj *intobj;
IGRint inx;
{
  while (inx--)
    intobj = intobj->next;
  return (intobj->props & EMSintobj_uvdegenerate);
}


/*
 * A locally used function that simply sets the bits in the intersection
 * elements for extensive checking for duplicates in the intersection list.
 */

static void mark_for_dupinters (mattyp, mat, inters)
IGRshort *mattyp;
IGRmatrix mat;
struct EMSinters *inters;
{
  IGRboolean on_bdry, in_world;
  IGRshort location;
  IGRlong i, stat_OM, msg_loc, send_msg;
  IGRdouble chrdhttol, lentol, tolfactor;
  IGRdouble tmppts[NUM_INTERNAL_SAMPLES*3], samplepts[NUM_INTERNAL_SAMPLES][2];
  GRobjid ed_sfobj, sfobj;
  GRspacenum sfos;
  struct EMSintobj *intobj;
  struct EMSsfintedpar *epar;
  struct EMSpartolbasis partolb;
  struct EMSptloc_info ptloc_info;
  extern IGRlong EMinternalpt();

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chrdhttol);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  tolfactor = chrdhttol / lentol;
  in_world = TRUE;

  while (inters)
    {
    intobj = inters->cvs;
    sfobj = inters->this_obj.objid;
    sfos = inters->this_obj.osnum;

    stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
               mattyp, mat, &in_world, FALSE, &partolb.tol), 
               targetid = sfobj, targetos = sfos, senderid = NULL_OBJID);
    if (EMSerror (stat_OM & msg_loc))
      {
      inters = inters->next;
      continue;
      }
    partolb.tol *= tolfactor;
    EMadjust_paramtol (&msg_loc, NULL, partolb.tol, &partolb.tol);
    partolb.is_valid = TRUE;

    while (intobj)
      {
      /*
       * Check if the intobj already has the "dupother" properties set,
       * implying that the intobj lies along an existing edge. If so, skip.
       */

      if (intobj->props & EMSintobj_dupothersurf)
        {
        intobj = intobj->next;
        continue;
        }

      /*
       * Sometimes an intobj is created out of an edge that already exists
       * on this surface. In this case, it does not make sense to check
       * for duplicates. Look for this condition and if it exists,
       * skip.
       */

      if (intobj->this_uvintobj.datatype == EMSdata_object)
        {
        ed_sfobj = NULL_OBJID;
        om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
         &ed_sfobj, NULL), targetid = intobj->this_uvintobj.data.object->objid,
         targetos = sfos, senderid = NULL_OBJID);
        if (ed_sfobj == sfobj)
          {
          intobj = intobj->next;
          continue;
          }
        }

      /*
       * Obtain internal points on the intersection-edge and perform a
       * point-location to check if these points lie on any boundary. If
       * all of them do then the entire edge possibly lies along an existing
       * edge.
       */

      on_bdry = FALSE;
      
      if (intobj->this_uvintobj.datatype != EMSdata_null)
      {
        stat_OM = EMinternalpt (&msg_loc, NULL, NULL, &intobj->this_uvintobj,
                  EMScvint_middle, NUM_INTERNAL_SAMPLES, tmppts);
      }
      if (EMSerror (stat_OM & msg_loc) ||
          (intobj->this_uvintobj.datatype == EMSdata_null))
        {
        intobj = intobj->next;
        continue;
        }
      if (intobj->this_uvintobj.datatype == EMSdata_curve3d)
        EM3dto2d (tmppts, NUM_INTERNAL_SAMPLES);
      OM_BLOCK_MOVE (tmppts, samplepts, NUM_INTERNAL_SAMPLES *
       2 * sizeof (IGRdouble));
 
      for (i=0; i<NUM_INTERNAL_SAMPLES; i++)
        {
        ptloc_info.options = EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP |
                             EMS_PTLOC_USECHTTOL | EMS_PTLOC_INCHTTOL |
                             EMS_PTLOC_XYZ_ONEDGE;
        stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&send_msg,
                   message EMSloopset.EMpt_location (&msg_loc, samplepts[i],
                   &ptloc_info, &partolb)), targetid = sfobj, targetos = sfos,
                   senderid = NULL_OBJID);
        if (EMSerror (stat_OM & send_msg & msg_loc))
          continue;

        location = ptloc_info.location;
        if (location == EMS_L_ONEDGE || location == EMS_L_ONVRTX)
          {
          on_bdry = TRUE;
          break;
          }
        }

      if (on_bdry) 
        {
        /*
         * This intobj lies along an existing edge. This may have
         * duplicates on this and/or other adjacent surfaces. Also,
         * it's counterpart intobj may have a possibility of duplicates
         * on it's surface (intersecting with the adjacent surface of
         * this intobj). NOTE: The other-intobj (if it exists), may not
         * lie on an edge.
         */

        intobj->props |= (EMSintobj_dupthissurf | EMSintobj_dupothersurf |
                          EMSintobj_overlap);
        if (intobj->other_intobj_node)
          intobj->other_intobj_node->props |= EMSintobj_dupthissurf;

        /*
         * Check if it's sfintedpars point to valid edge-ids. If not
         * try and get that info. This kind of information is critical
         * for further downstream processing.
         */

        if ((epar = (struct EMSsfintedpar *) intobj->more_info) &&
            !(intobj->props & EMSintobj_nontriminfo))
          {
          for (i=FIRST; i<=SECOND; i++)
            {
            if (IF_NULL_OBJID (epar->edgeid))
            EMgetincinfo (&msg_loc, sfos, &intobj->this_uvintobj, i,
             NULL, mattyp, mat, sfobj, chrdhttol, partolb.tol, 
             epar);
            epar = epar->next;
            }
          }
    	}
      intobj = intobj->next;
      }
    inters = inters->next;
    }
  return;
}

end implementation EMSsurface;
