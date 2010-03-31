/*
  DESCRIPTION

    This function is used to string together the pieces of surface-surface
    intersection, so as to output groups which have between it's lowest 
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

    Each of the subgroups is output as an EMSintobj linked-list. A sequence
    of these linked-list forms a group.
 
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

    An action that this function takes before performing the trace in uv-space
    is that it scans the EMSintobj list for the given EMSinters node looking
    for an EMSintobj marked with the "EMSintobj_marked" property. It makes
    this the first element in the EMSintobj list thus ensuring that the
    first sub-group will start it's trace from this EMSintobj. This provides
    some level of control to the user as to what the starting node for the
    trace should be.

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
    
    Interpretation of output:
    ------------------------

    num_grps - gives the number of groups
    num_subgrps_grp[i] - gives the number of subgroups in the ith group.
    num_elems_subgrp[i][j] - gives the number of elements in the jth
                             subgroup of the ith group.
    elems[i][j] - gives the EMSintobj linked-list for jth subgroup in the
                  ith group of curves.
    subgrp_rev[i][j] - if TRUE, means that the jth subgroup of the ith group 
                       needs to be reversed to maintain continuity.
    elem_rev[i][j][k] - if TRUE, means that the kth element in the jth 
                        subgroup of the ith group needs to be reversed to 
                        maintain continuity.
    grp_closed[i] - if TRUE, means that the ith group is closed when
                    considering the curve in world space.
    subgrp_closed[i][j] - if TRUE, means that the ith group is closed when
                          considering the curve in world space.

  NOTES

    To deallocate the memory that was allocated in this function for the
    output, the function EMsfinttrace_free should be called. It is described 
    toward the end of this file. Any memory that was not allocated here
    is not deallocated by theis function. For example: in the "elems" array
    the EMintobj structures are not deallocated but their carrier
    3-dimensional array is.

    

  RETURN VALUE

    Upon exit the completion code will be one of the following:

      Success codes:
      - EMS_S_Success 
           if succeeded, with no ambiguities
      - EMS_I_Ambiguous
           if more than one paths were available to complete the trace
           but the "best" one was chosen.

      Error codes:
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_Fail
          Call to a math function returned error.
      - EMS_E_SurfaceError
          Invocation of a surface method failed.
      - EMS_E_EdgeError
          Invocation of a surface method failed.
      - EMS_E_OMerror
          Call to an OM-primitive failed or,
          Invocation of a method on some object failed.

  ASSUMPTION

    The type of intersection elements are assumed to be curves. Any points
    are ignored. The model-space curves can be of type EMSdata_poly3d,
    EMSdata_curve3d or EMSdata_object (GRcurve). The paramteric-space curves
    can be of type EMSdata_poly2d, EMSdata_curve3d or EMSdata_object (EMSedge).

  ALGORITHM

    The curves are first traced in parametric-space of each of the surfaces
    using the general-trace function. These form the subgroups. Treating
    these subgroups as units (storing their related information in a
    local-structure array) a second trace is performed in model-space.
    The second trace is performed only if model-space data exists.

  HISTORY

    SS  :  03/01/87  :  Creation
    SS  :  05/07/87  :  Added the alternate-tolerance field in the argument
                        list.
    SS  :  06/22/88  :  Modified function to support fwd and bwd
		        fields in the EMSintobj structure.
    SS  :  03/28/89  :  Passing the degenerate flags correctly for both
		        uv and xyz traces.
    SS  :  08/15/89  :  Removed the assumption that every EMSinters node
		        has atleast one EMSintobj connected to it.
    SS  :  09/11/89  :  Modified code to use the 'noconnectuv' property
                        which now unambiguously specifies a definite lack
                        of connection in uv-space. No such property bit
                        exists to indicate a 'no-connection' in xyz space.
    NP  :  06/14/93  :  Modified to move ALL intobjs marked "EMSintobj_marked"
                        to the top of the inters list, so that these may begin
                        the trace.
    SM  :  07/01/93  :  Added checks to use the fwd/bwd pointers in conjuction
                        with the connectuv/noconnectuv properties, ONLY if 
                        the 2 intobjs in question are in the same uv space.
                        This will now enable setting up the connectivity
                        information for an intobj which is noconnectuv to
                        any other intobj on the same surface, but has known
                        connection to another intobj on a different surface.
                        If WANT_POST220_... flag is not set, old behavior is
                        maintained.
    Sudha  07/09/93  :  Modified for BSprototypes anisfication
    SY  :  08/17/93  :  Add local varible trtol for the first EMgentracer.
                        If only XYZ data passed in, trtol is assigned xyztol.
			Otherwise, trtol is uvtol.
*/

class implementation Root;

#include "EMS.h"
#include <stdio.h>
%safe 
#include <math.h>
%endsafe
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSstruct.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FWD 0
#define BWD 1

#define FIRST 0
#define LAST  1

struct traceinfo
  {
  IGRint numcvs;
  struct EMSintobj *cvs;
  struct EMSintobj *lastcv;
  IGRboolean *elem_rev;
  IGRboolean grpclosed;
  };

#ifndef IDRAW
from EMSsubbs import EMpartolbasis;
#endif

%safe
static IGRboolean is_same_uv();
%endsafe
 
void EMsfinttrace (msg, mattyp, mat, inters, altuvtol, altxyztol, num_grps,
                   num_subgrps_grp, num_elems_subgrp, elems, 
                   subgrp_rev, elem_rev, grp_closed, subgrp_closed)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSinters *inters;
IGRdouble *altuvtol, *altxyztol;
IGRint *num_grps, **num_subgrps_grp, ***num_elems_subgrp;
struct EMSintobj ****elems;
IGRboolean ***subgrp_rev, ****elem_rev, **grp_closed, ***subgrp_closed;
{
  IGRboolean **grp_closed1, ***elem_rev1;
  IGRboolean in_world = TRUE, reverse_flag;
  IGRboolean fwd1, fwd2, degen_link=FALSE;
  IGRchar ****elems1, ***elems2, **elemptrs;
  IGRushort chkprops;
  IGRshort dim, padding;
  IGRint num_sfs, totnum_cvs, blksize, num_cvs, tot_numgrps;
  IGRint i, j, k, l;
  IGRint *num_grps1, **num_elems_grp1, *tempmemptr;
  IGRlong stat_OM, msg_loc;
  IGRdouble *endpts, *tanvecs, start_pts[6], stop_pts[6];
  IGRdouble uvtol, xyztol, tol_basis, trtol;
  IGRdouble sqrval1, sqrval2, del1[3], del2[3], len1, len2;
  struct EMSinters *inters_loc;
  struct EMSintobj *intobj_loc, *intobj1, *intobj2;
  struct EMSintobj *intobj_next, *intobj_prev, *intobj_tmp;
  struct EMSintobj *cont_intobj, *cont_intobj1, *cont_intobj2;
  struct EMSintobj *nocont_intobj, *nocont_intobj1, *nocont_intobj2;
  struct traceinfo *sftrace;
  struct GRid sfid;
  struct EMStraceinfo *trcinfo, *trcinfo_loc;
  enum EMSdatatype xyztype, uvtype;
  extern IGRboolean EFextract_par();
  extern IGRint EMgetendpts_xyz(), EMgetendpts_uv();
  extern void EMgentracer();
  IGRboolean same_uv = FALSE;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_grps = 0;
  *num_subgrps_grp = NULL;
  *num_elems_subgrp = NULL;
  *elems = NULL;
  *subgrp_rev = NULL;
  *elem_rev = NULL;
  *grp_closed = NULL;
  *subgrp_closed = NULL;

  sftrace = NULL;
  num_grps1 = NULL;
  num_elems_grp1 = NULL;
  elems1 = NULL;
  grp_closed1 = NULL;
  elem_rev1 = NULL;
  endpts = NULL;
  tanvecs = NULL;
  elemptrs = NULL;
  elems2 = NULL;
  tempmemptr = NULL;
  trcinfo = NULL;
  degen_link=FALSE;

  /*
   * The tracing is to be conducted with the model
   * space tolerance equal to twice the chord-height
   * tolerance. If an alternate model-space tolerance is
   * specified, then that is used instead.
   */

  if (!altxyztol)
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, xyztol);
  else
    xyztol = *altxyztol;

  /*
   * Re-arrange the EMSintobjs list on each EMSinters node such that ALL the
   * intobjs in a given EMSinters marked with "EMSintobj_marked",are moved to 
   * the top of the list.
   */

  inters_loc = inters;
  while (inters_loc)
  {
    intobj_prev = inters_loc->cvs;

    /* start from second intobj */
    intobj_loc = intobj_prev? intobj_prev->next : NULL;

    while (intobj_loc)
    {
      intobj_next = intobj_loc->next;
      if ( (intobj_loc->props  & EMSintobj_marked) && 
          !(intobj_prev->props & EMSintobj_marked))
      {
        intobj_prev->next = intobj_next;
        intobj_loc->next = inters_loc->cvs;
        inters_loc->cvs = intobj_loc;
        /*"intobj_prev" does not change*/
      }
      else
        intobj_prev = intobj_loc;

      intobj_loc = intobj_next;
    }

    inters_loc = inters_loc->next;
  }

  /*
   * Count the number of surfaces involved. Also the maximum number
   * of curves that any surface has. If number of surfaces or number of
   * total curves is zero then return an error code.
   */

  num_sfs = 0;
  totnum_cvs = 0;
  inters_loc = inters;
  chkprops = EMSintobj_uvdegenerate |
             EMSintobj_fwd_noconnectuv | EMSintobj_bwd_noconnectuv;
  while (inters_loc)
    {
    num_sfs++;
    totnum_cvs += inters_loc->num_cvs;
    inters_loc = inters_loc->next;
    }
  EMerr_hndlr (!num_sfs || !totnum_cvs, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Check to see what kind of data has been
   * output for each individual curve. A single
   * sampling is enough. The rest of the intersection
   * curves are assumed to have this same type.
   */

  inters_loc = inters;
  xyztype = EMSdata_null;
  uvtype = EMSdata_null;
  while (inters_loc)
    {
    if (inters_loc->num_cvs)
      {
      xyztype = inters->cvs->this_xyzintobj.datatype;
      uvtype = inters->cvs->this_uvintobj.datatype;
      }

    intobj_loc = inters_loc->cvs;
    while (intobj_loc)
      { 
      if (intobj_loc->this_xyzintobj.datatype == EMSdata_null)
        xyztype = EMSdata_null;
      if (intobj_loc->this_uvintobj.datatype == EMSdata_null)
        uvtype = EMSdata_null;

      if(uvtype == EMSdata_null || xyztype == EMSdata_null) break;

      intobj_loc = intobj_loc->next;
      }

    if(uvtype == EMSdata_null || xyztype == EMSdata_null) break;
    inters_loc = inters_loc->next;
    }

  /*
   * Allocate space for array to hold a priori contiguity info. This will be
   * eventually be passed to the general trace function after
   * initialization. The biggest size of the array that may ever be
   * required on a single call to the trace function is equal to the
   * total number of curves.
   */

  trcinfo = (struct EMStraceinfo *) alloca (totnum_cvs *
             sizeof (struct EMStraceinfo));

  /*
   * TRACE-1:
   * Malloc temporary arrays
   * to hold volatile information output from trace
   * done on a per surface basis. This information is 
   * later used for the global trace.
   */

  padding = 20; /* bytes */
  dim = (xyztype == EMSdata_null ? 2 : 3);
  blksize = /* For the num_grps1 array */
              (num_sfs * sizeof (IGRint)) +
            /* For the num_elems_grp1 array */
              (num_sfs * sizeof (IGRint *)) +
            /* For the elems1 array */
              (num_sfs * sizeof (IGRchar ***)) +
            /* For the elem_rev1 array */
              (num_sfs * sizeof (IGRboolean **)) +
            /* For the grp_closed1 array */
              (num_sfs * sizeof (IGRboolean *)) +
            /* For the endpts array */
              (totnum_cvs * dim * 2 * sizeof (IGRdouble)) +
            /* For the tanvecs array */
              (totnum_cvs * dim * 2 * sizeof (IGRdouble)) +
            /* For the elemptrs array */
              (totnum_cvs * sizeof (IGRchar *)) +
            /* Padding to take care of misallignments */
              padding;

  tempmemptr = (IGRint *) om$malloc (size = blksize);
  EMerr_hndlr (!tempmemptr, *msg, EMS_E_NoDynamicMemory, ret_end);

  num_grps1 = (IGRint *) tempmemptr;
  num_elems_grp1 = (IGRint **) &num_grps1[num_sfs];
  elems1 = (IGRchar ****) &num_elems_grp1[num_sfs];
  elem_rev1 = (IGRboolean ***) &elems1[num_sfs];
  grp_closed1 = (IGRboolean **) &elem_rev1[num_sfs];

  endpts = (IGRdouble *) (GRalign_double (&grp_closed1[num_sfs]));
  tanvecs = (IGRdouble *) &endpts[totnum_cvs * dim * 2];
  elemptrs = (IGRchar **) &tanvecs[totnum_cvs * dim * 2];

  for (i=0; i<num_sfs; i++)
    num_grps1[i] = 0;

  /*
   * String out the curves based on uv-information (or xyz
   * information if uv is not available) on a per surface
   * basis, storing the relevant information in the
   * allocated arrays.
   */

  dim = (uvtype == EMSdata_null ? 3 : 2);
  tot_numgrps = 0;
  inters_loc = inters;
  for (i=0; i<num_sfs; i++)
    {
    intobj_loc = inters_loc->cvs;
    for (j=0; j<inters_loc->num_cvs; j++)
      {
      /*
       * Get the endpoints of the intersection
       * curve.
       */

      if (uvtype == EMSdata_null)
        {
        EMgetendpts_xyz (&msg_loc, mattyp, mat, &intobj_loc->this_xyzintobj,
         intobj_loc->reversed, 2, start_pts, stop_pts);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      else
        {
        EMgetendpts_uv (&msg_loc, &intobj_loc->this_uvintobj, 
         intobj_loc->reversed, 2, start_pts, stop_pts);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      k = j * 2 * dim;
      blksize = dim * sizeof (IGRdouble);
      OM_BLOCK_MOVE (start_pts, &endpts[k], blksize);
      OM_BLOCK_MOVE (stop_pts, &endpts[k+dim], blksize);

      /*
       * Get the unit-tangent vectors at the endpoints
       * of the intersection curve. These are to be directed
       * inward, towards the line-string.
       */

      sqrval1 = 0.0;
      sqrval2 = 0.0;
      for (l=0; l<dim; l++)
        {
        del1[l] = start_pts[dim+l] - start_pts[l];
        del2[l] = stop_pts[dim+l] - stop_pts[l];
        sqrval1 += del1[l] * del1[l];
        sqrval2 += del2[l] * del2[l];
        }
      len1 = sqrt (sqrval1);
      len2 = sqrt (sqrval2);
      for (l=0; l<dim; l++)
        {
        tanvecs[k+l] = del1[l] / len1;
        tanvecs[k+dim+l] = del2[l] / len2;
        }

      /* 
       * Obtain the pointer that defines the quantity
       * being traced, viz, the EMintobj-structures.
       */

      elemptrs[j] = (IGRchar *) intobj_loc;
      intobj_loc = intobj_loc->next;
      }

    /*
     * If any link-ups are known, initialize the trace-info array with
     * this information. It is assumed that if such pointers exist then
     * they are valid.
     */

    num_cvs = inters_loc->num_cvs;
    intobj_loc = inters_loc->cvs;
    for (j=0; j<num_cvs; j++)
      {
      trcinfo_loc = &trcinfo[j];

      /*
       * Initialize the degeneracy indicator
       */

      trcinfo_loc->degenerate = intobj_loc->props & EMSintobj_uvdegenerate;

      /*
       * Initialize the known forward continuity indicators
       */

      trcinfo_loc->known_fwd_cont = FALSE;
      cont_intobj = intobj_loc->props & EMSintobj_fwd_connectuv ?
                     intobj_loc->fwd : NULL;

      if (cont_intobj && !is_same_uv(intobj_loc, cont_intobj))
        cont_intobj = NULL;

      if (cont_intobj)
        {
        for (k=0; k<num_cvs; k++)
          {
          intobj_tmp = (struct EMSintobj *) elemptrs[k];
          cont_intobj1 = intobj_tmp->props & EMSintobj_fwd_connectuv ?
                          intobj_tmp->fwd : NULL;

          if(cont_intobj1 && !is_same_uv(intobj_tmp, cont_intobj1))
           cont_intobj1 = NULL;

          cont_intobj2 = intobj_tmp->props & EMSintobj_bwd_connectuv ?
                          intobj_tmp->bwd : NULL;

          if(cont_intobj2 && !is_same_uv(intobj_tmp, cont_intobj2))
           cont_intobj2 = NULL;

          if (intobj_tmp == intobj_loc)
            cont_intobj1 = NULL;

          if (cont_intobj == intobj_tmp &&
              (cont_intobj1 == intobj_loc || cont_intobj2 == intobj_loc))
            {
            trcinfo_loc->known_fwd_cont = TRUE;
            trcinfo_loc->fwd_cont = k;
            break;
            }
          }

        if (!trcinfo_loc->known_fwd_cont)
          {
          intobj_loc->fwd = NULL;
          intobj_loc->props &= ~EMSintobj_fwd_connectuv;
          }
        }

      /*
       * Initialize the known backward continuity indicators
       */

      trcinfo_loc->known_bwd_cont = FALSE;
      cont_intobj = intobj_loc->props & EMSintobj_bwd_connectuv ?
                     intobj_loc->bwd : NULL;

      if(cont_intobj && !is_same_uv(intobj_loc, cont_intobj))
       cont_intobj = NULL;

      if (cont_intobj)
        {
        for (k=0; k<num_cvs; k++)
          {
          intobj_tmp = (struct EMSintobj *) elemptrs[k];
          cont_intobj1 = intobj_tmp->props & EMSintobj_fwd_connectuv ?
                          intobj_tmp->fwd : NULL;

          if(cont_intobj1 && !is_same_uv(intobj_tmp, cont_intobj1))
           cont_intobj1 = NULL;

          cont_intobj2 = intobj_tmp->props & EMSintobj_bwd_connectuv ?
                          intobj_tmp->bwd : NULL;

          if(cont_intobj2 && !is_same_uv(intobj_tmp, cont_intobj2))
           cont_intobj2 = NULL;

          if (intobj_tmp == intobj_loc)
            cont_intobj2 = NULL;

          if (cont_intobj == intobj_tmp &&
              (cont_intobj1 == intobj_loc || cont_intobj2 == intobj_loc))
            {
            trcinfo_loc->known_bwd_cont = TRUE;
            trcinfo_loc->bwd_cont = k;
            break;
            }
          }

        if (!trcinfo_loc->known_bwd_cont)
          {
          intobj_loc->bwd = NULL;
          intobj_loc->props &= ~EMSintobj_bwd_connectuv;
          }
        }

      /*
       * Initialize the known forward NO-continuity indicators
       */

      trcinfo_loc->known_no_fwd_cont = FALSE;
      trcinfo_loc->no_fwd_cont = -1;
      if (intobj_loc->props & EMSintobj_fwd_noconnectuv)
        {
        trcinfo_loc->known_no_fwd_cont = TRUE;

        nocont_intobj = intobj_loc->fwd;

        if(nocont_intobj && !is_same_uv(intobj_loc, nocont_intobj))
           nocont_intobj = NULL;

        if (nocont_intobj)
          {
          for (k=0; k<num_cvs; k++)
            {
            intobj_tmp = (struct EMSintobj *) elemptrs[k];
            nocont_intobj1 = intobj_tmp->props & EMSintobj_fwd_noconnectuv ?
                              intobj_tmp->fwd : NULL;

            if(nocont_intobj1 && !is_same_uv(intobj_tmp, nocont_intobj1))
             nocont_intobj1 = NULL;

            nocont_intobj2 = intobj_tmp->props & EMSintobj_bwd_noconnectuv ?
                              intobj_tmp->bwd : NULL;

            if(nocont_intobj2 && !is_same_uv(intobj_tmp, nocont_intobj2))
             nocont_intobj2 = NULL;

            if (intobj_tmp == intobj_loc)
              nocont_intobj1 = NULL;

            if (nocont_intobj == intobj_tmp &&
                (nocont_intobj1 == intobj_loc ||
                 nocont_intobj2 == intobj_loc))
              {
              trcinfo_loc->known_no_fwd_cont = TRUE;
              trcinfo_loc->no_fwd_cont = k;
              break;
              }
            }

          if (!trcinfo_loc->known_no_fwd_cont)
            {
            intobj_loc->fwd = NULL;
            intobj_loc->props &= ~EMSintobj_fwd_noconnectuv;
            }
          }
        }

      /*
       * Initialize the known backward NO-continuity indicators
       */

      trcinfo_loc->known_no_bwd_cont = FALSE;
      trcinfo_loc->no_bwd_cont = -1;
      if (intobj_loc->props & EMSintobj_bwd_noconnectuv)
        {
        trcinfo_loc->known_no_bwd_cont = TRUE;

        nocont_intobj = intobj_loc->bwd;

        if(nocont_intobj && !is_same_uv(intobj_loc, nocont_intobj))
         nocont_intobj = NULL;

        if (nocont_intobj)
          {
          for (k=0; k<num_cvs; k++)
            {
            intobj_tmp = (struct EMSintobj *) elemptrs[k];
            nocont_intobj1 = intobj_tmp->props & EMSintobj_fwd_noconnectuv ?
                              intobj_tmp->fwd : NULL;

            if(nocont_intobj1 && !is_same_uv(intobj_tmp, nocont_intobj1))
             nocont_intobj1 = NULL;

            nocont_intobj2 = intobj_tmp->props & EMSintobj_bwd_noconnectuv ?
                              intobj_tmp->bwd : NULL;

            if(nocont_intobj2 && !is_same_uv(intobj_tmp, nocont_intobj2))
             nocont_intobj2 = NULL;

            if (intobj_tmp == intobj_loc)
              nocont_intobj1 = NULL;

            if (nocont_intobj == intobj_tmp &&
                (nocont_intobj1 == intobj_loc ||
                 nocont_intobj2 == intobj_loc))
              {
              trcinfo_loc->known_no_bwd_cont = TRUE;
              trcinfo_loc->no_bwd_cont = k;
              break;
              }
            }

          if (!trcinfo_loc->known_no_bwd_cont)
            {
            intobj_loc->bwd = NULL;
            intobj_loc->props &= ~EMSintobj_bwd_noconnectuv;
            }
          }
        }

      intobj_loc = intobj_loc->next;
      }

    /*
     * Obtain the uv-space zero-length tolerance. If an alternate tolerance
     * is specified, use it, else if it can be directly obtained from
     * the surface, obtain it, else just set the tolerance to zero. Then
     * call the tracer function.
     */

    if (inters_loc->cvs && inters_loc->cvs->this_obj_node)
      sfid = inters_loc->cvs->this_obj_node->this_obj;
    else
      sfid.objid = NULL_OBJID;

    if (uvtype != EMSdata_null)
    {
    if (altuvtol)
      uvtol = *altuvtol;
    else if (!IF_NULL_OBJID (sfid.objid))
      {
#     ifndef IDRAW
      stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                 mattyp, mat, &in_world, FALSE, &tol_basis),
                 targetid = sfid.objid, targetos = sfid.osnum, 
                 senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
      EFextract_par (BSTOLLENVEC, tol_basis, &uvtol, &msg_loc);
#     endif
      }
    else
      uvtol = 0.0;
    trtol = uvtol;
    }
    else
    trtol = xyztol;
    

    /*
     * Call the general tracing function with all the collected
     * information.
     */

    EMgentracer (&msg_loc, inters_loc->num_cvs, dim, endpts, tanvecs, 
     elemptrs, trtol, trcinfo, &num_grps1[i], &num_elems_grp1[i], &elems1[i], 
     &elem_rev1[i], &grp_closed1[i]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    if (msg_loc == EMS_I_Ambiguous)
      *msg = msg_loc;

    /*
     * Rearrange the EMSintobj linked-list on this
     * surface-node. This linked list can now be 
     * interpreted, using num_grps1[i], 
     * num_elems_grp[i], etc.
     */

    for (j=0; j<num_grps1[i]; j++)
      for (k=0; k<num_elems_grp1[i][j]; k++)
        {
        if (j == 0 && k == 0)
          {
          inters_loc->cvs = (struct EMSintobj *) elems1[i][0][0];
          intobj_loc = inters_loc->cvs;
          }
        else
          {
          if(intobj_loc)
           {
            intobj_loc->next = (struct EMSintobj *) elems1[i][j][k];
            intobj_loc = intobj_loc->next;
           }
          }
        }
    if(intobj_loc)
    {
     intobj_loc->next = NULL;
     inters_loc = inters_loc->next;
    }

    tot_numgrps += num_grps1[i];
    }

  /*
   * TRACE-2:
   * Build an array of the locally defined structure that
   * binds together relevant information on the first level trace of 
   * all the surfaces. This array of structures is then traced out based
   * on xyz-information at the endpts of the group  they represent. If no 
   * xyz-information is available or if the number of surfaces is one
   * and the number of groups already generated for the surface is just one,
   * this second trace will not be performed.
   * The output data is then based only on the first trace.
   */

  if (xyztype != EMSdata_null)
    {
    sftrace = (struct traceinfo *) om$malloc (size = tot_numgrps *
               sizeof (struct traceinfo));
    EMerr_hndlr (!sftrace, *msg, EMS_E_NoDynamicMemory, ret_end);

    inters_loc = inters;
    for (i=0, k=0; i<num_sfs; i++)
      {
      intobj_loc = inters_loc->cvs;
      for (j=0; j<num_grps1[i]; j++)
        {
        sftrace[k].numcvs = num_elems_grp1[i][j];
        sftrace[k].cvs = intobj_loc;
        sftrace[k].elem_rev = elem_rev1[i][j];
        for (l=0; l<sftrace[k].numcvs; l++)
          intobj_loc = intobj_loc->next;
        sftrace[k].grpclosed = grp_closed1[i][j];
        k++;
        }
      inters_loc = inters_loc->next;
      }

    /*
     * Prepare the information required to trace on a global basis, 
     * using the local-structure array - "sftrace". This global trace
     * doesn't need to worry about groupings that might intersect at
     * an internal endpoint. The reasoning is as follows:
     * The first trace outputs groupings that do not intersect at internal
     * endpoints. The only place where there could possibly be such
     * an intersection in the global trace is at the boundaries of the
     * surfaces. Which implies that multiple endpoints (from more than
     * one group) exist at the boundary. But this is impossible as the
     * first trace would have concatenated these two groups into one,
     * resulting in neither end-points remaining on the boundary. QED.
     */

    for (i=0, j=0; i<tot_numgrps; i++, j+=6)
      {
      /*
       * Get the endpoints of the groups represented
       * by each sftrace element. Also the field 'lastcv' is initialized
       * to the last curve in the group.
       */

      intobj_loc = sftrace[i].cvs;
      reverse_flag = (intobj_loc->reversed && !sftrace[i].elem_rev[0]) ||
                      (!intobj_loc->reversed && sftrace[i].elem_rev[0]);
      EMgetendpts_xyz (&msg_loc, mattyp, mat, &intobj_loc->this_xyzintobj,
       reverse_flag, 1, &endpts[j], stop_pts);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      intobj_loc = intobj_loc;
      num_cvs = sftrace[i].numcvs;
      for (k=0; k<num_cvs-1; k++)
        intobj_loc = intobj_loc->next;
      sftrace[i].lastcv = intobj_loc;

      reverse_flag = 
             (intobj_loc->reversed && !sftrace[i].elem_rev[num_cvs-1]) ||
              (!intobj_loc->reversed && sftrace[i].elem_rev[num_cvs-1]);
      EMgetendpts_xyz (&msg_loc, mattyp, mat, &intobj_loc->this_xyzintobj,
       reverse_flag, 1, start_pts, &endpts[j+3]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      /*
       * Obtain the pointer that defines the quantity
       * being traced, viz, the sftrace-structures.
       */

      elemptrs[i] = (IGRchar *) &sftrace[i];
      }

    /*
     * If any link-ups are known between these subgroups, build
     * the trace-information array. It is possible that the uv-trace
     * performed above has caused some of the connections in xyz to
     * have changed. A validity check is performed to see if the 
     * connections are only across free ends of these subgroups.
     * Further, if a subgroup is closed then a closed group must
     * result from this subgroup. To force this, connectivity pointers
     * are set up that point the start of the group to the stop and
     * vice-versa.
     */

    degen_link = FALSE;	

    for (i=0; i<tot_numgrps; i++)
      {
      trcinfo_loc = &trcinfo[i];

      trcinfo_loc->degenerate = TRUE;
      intobj_loc = sftrace[i].cvs;
      for (j=0; j<sftrace[i].numcvs; j++)
        {
        if (! (intobj_loc->props & EMSintobj_xyzdegenerate))
          {
          trcinfo_loc->degenerate = FALSE;
          break;
          }
        intobj_loc = intobj_loc->next;
        }

      if(trcinfo_loc->degenerate)
       {
        intobj_loc = sftrace[i].cvs;
        for (j=0; j<sftrace[i].numcvs; j++)
         {
          if ( (intobj_loc->props & EMSintobj_degen_ornt_right) ||
               (intobj_loc->props & EMSintobj_degen_ornt_left))
          {
           degen_link = TRUE;
           break;
          }
          intobj_loc = intobj_loc->next;
         }
       }

      trcinfo_loc->known_fwd_cont = FALSE;
      if (sftrace[i].grpclosed && !degen_link)
        {
        trcinfo_loc->known_fwd_cont = TRUE;
        trcinfo_loc->fwd_cont = i;
        trcinfo_loc->known_bwd_cont = TRUE;
        trcinfo_loc->bwd_cont = i;
        }
      intobj_loc = sftrace[i].lastcv;
      cont_intobj = sftrace[i].elem_rev[sftrace[i].numcvs-1] ?
                     (fwd1 = FALSE, intobj_loc->bwd) : 
                     (fwd1 = TRUE, intobj_loc->fwd);

      same_uv = is_same_uv(cont_intobj, intobj_loc);

      if (cont_intobj &&
          !(fwd1 ? (intobj_loc->props & EMSintobj_fwd_noconnectuv)&&same_uv :
                 (intobj_loc->props & EMSintobj_bwd_noconnectuv) && same_uv))
        {
        for (j=0; j<tot_numgrps; j++)
          {
          intobj1 = sftrace[j].cvs;
          cont_intobj1 = sftrace[j].elem_rev[0] ? 
                          (fwd2 = TRUE, intobj1->fwd) :
                          (fwd2 = FALSE, intobj1->bwd);
          if (intobj_loc == intobj1 && fwd1 == fwd2)
            cont_intobj1 = NULL;

          intobj2 = sftrace[j].lastcv;
          cont_intobj2 = sftrace[j].elem_rev[sftrace[j].numcvs-1] ?
                          (fwd2 = FALSE, intobj2->bwd) : 
                          (fwd2 = TRUE, intobj2->fwd);
          if (intobj_loc == intobj2 && fwd1 == fwd2)
            cont_intobj2 = NULL;

          if ((cont_intobj1 == intobj_loc &&
               cont_intobj == intobj1) ||
              (cont_intobj2 == intobj_loc &&
               cont_intobj == intobj2))
            {
            trcinfo_loc->known_fwd_cont = TRUE;
            trcinfo_loc->fwd_cont = j;
            break;
            }
          }

        if (!trcinfo_loc->known_fwd_cont &&
            !(fwd1 ? intobj_loc->props & EMSintobj_fwd_noconnectuv :
                     intobj_loc->props & EMSintobj_bwd_noconnectuv))
          {
          if (fwd1)
            {
            intobj_tmp = intobj_loc->fwd;
            if (intobj_tmp->fwd == intobj_loc)
              intobj_tmp->fwd = NULL;
            else if (intobj_tmp->bwd == intobj_loc)
              intobj_tmp->bwd = NULL;
            intobj_loc->fwd = NULL;
            }
          else
            {
            intobj_tmp = intobj_loc->bwd;
            if (intobj_tmp->fwd == intobj_loc)
              intobj_tmp->fwd = NULL;
            else if (intobj_tmp->bwd == intobj_loc)
              intobj_tmp->bwd = NULL;
            intobj_loc->bwd = NULL;
            }
          }
        }

      trcinfo_loc->known_bwd_cont = FALSE;
      if (sftrace[i].grpclosed && !degen_link)
        {
        trcinfo_loc->known_fwd_cont = TRUE;
        trcinfo_loc->fwd_cont = i;
        trcinfo_loc->known_bwd_cont = TRUE;
        trcinfo_loc->bwd_cont = i;
        }
      intobj_loc = sftrace[i].cvs;
      cont_intobj = sftrace[i].elem_rev[0] ?
                     (fwd1 = TRUE, intobj_loc->fwd) : 
                     (fwd1 = FALSE, intobj_loc->bwd);

      same_uv = is_same_uv(cont_intobj, intobj_loc);

      if (cont_intobj &&
          !(fwd1 ? (intobj_loc->props & EMSintobj_fwd_noconnectuv)&&same_uv :
                   (intobj_loc->props & EMSintobj_bwd_noconnectuv)&&same_uv))
        {
        for (j=0; j<tot_numgrps; j++)
          {
          intobj1 = sftrace[j].cvs;
          cont_intobj1 = sftrace[j].elem_rev[0] ? 
                          (fwd2 = TRUE, intobj1->fwd) :
                          (fwd2 = FALSE, intobj1->bwd);
          if (intobj_loc == intobj1 && fwd1 == fwd2)
            cont_intobj1 = NULL;

          intobj2 = sftrace[j].lastcv;
          cont_intobj2 = sftrace[j].elem_rev[sftrace[j].numcvs-1] ?
                          (fwd2 = FALSE, intobj2->bwd) : 
                          (fwd2 = TRUE, intobj2->fwd);
          if (intobj_loc == intobj2 && fwd1 == fwd2)
            cont_intobj2 = NULL;

          if ((cont_intobj1 == intobj_loc &&
               cont_intobj == intobj1) ||
              (cont_intobj2 == intobj_loc &&
               cont_intobj == intobj2))
            {
            trcinfo_loc->known_bwd_cont = TRUE;
            trcinfo_loc->bwd_cont = j;
            break;
            }
          }

        if (!trcinfo_loc->known_bwd_cont &&
            !(fwd1 ? intobj_loc->props & EMSintobj_fwd_noconnectuv :
                     intobj_loc->props & EMSintobj_bwd_noconnectuv))
          {
          if (fwd1)
            {
            intobj_tmp = intobj_loc->fwd;
            if (intobj_tmp->fwd == intobj_loc)
              intobj_tmp->fwd = NULL;
            else if (intobj_tmp->bwd == intobj_loc)
              intobj_tmp->bwd = NULL;
            intobj_loc->fwd = NULL;
            }
          else
            {
            intobj_tmp = intobj_loc->bwd;
            if (intobj_tmp->fwd == intobj_loc)
              intobj_tmp->fwd = NULL;
            else if (intobj_tmp->bwd == intobj_loc)
              intobj_tmp->bwd = NULL;
            intobj_loc->bwd = NULL;
            }
          }
        }
 
      trcinfo_loc->known_no_fwd_cont = FALSE;
      trcinfo_loc->no_fwd_cont = -1;
      trcinfo_loc->known_no_bwd_cont = FALSE;
      trcinfo_loc->no_bwd_cont = -1;
      }

    /*
     * Call the general tracing function with all the collected
     * information.
     */

    EMgentracer (&msg_loc, tot_numgrps, 3, endpts, NULL, elemptrs, xyztol,
     trcinfo, num_grps, num_subgrps_grp, &elems2, subgrp_rev, grp_closed);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    if (msg_loc == EMS_I_Ambiguous)
      *msg = msg_loc;

    /*
     * Format (malloc-ing memory if needed) the rest of 
     * the output.
     */

    *num_elems_subgrp = (IGRint **) om$malloc (size = *num_grps * 
                         sizeof (IGRint *));
    EMerr_hndlr (!*num_elems_subgrp, *msg, EMS_E_NoDynamicMemory, ret_end);
    for (i=0; i<*num_grps; i++)
      {
      (*num_elems_subgrp)[i] = (IGRint *) om$malloc (size =
                                (*num_subgrps_grp)[i] * sizeof (IGRint));
      EMerr_hndlr (!(*num_elems_subgrp)[i], *msg, EMS_E_NoDynamicMemory, 
       ret_end);
  
      for (j=0; j<(*num_subgrps_grp)[i]; j++)
        (*num_elems_subgrp)[i][j] = 
            ((struct traceinfo *) elems2[i][j])->numcvs;
      }

    *elems = (struct EMSintobj ***) om$malloc (size = *num_grps *
              sizeof (struct EMSintobj **));
    EMerr_hndlr (!*elems, *msg, EMS_E_NoDynamicMemory, ret_end);
    for (i=0; i<*num_grps; i++)
      {
      (*elems)[i] = (struct EMSintobj **) om$malloc (size =
                     (*num_subgrps_grp)[i] * sizeof (struct EMSintobj *));
      EMerr_hndlr (!(*elems)[i], *msg, EMS_E_NoDynamicMemory, ret_end);

      for (j=0; j<(*num_subgrps_grp)[i]; j++)
        (*elems)[i][j] = ((struct traceinfo *) elems2[i][j])->cvs;
      }
  
    *elem_rev = (IGRboolean ***) om$malloc (size = *num_grps *
                 sizeof (IGRboolean **));
    EMerr_hndlr (!*elem_rev, *msg, EMS_E_NoDynamicMemory, ret_end);
    for (i=0; i<*num_grps; i++)
      {
      (*elem_rev)[i] = (IGRboolean **) om$malloc (size = 
                        (*num_subgrps_grp)[i] * sizeof (IGRboolean *));
      EMerr_hndlr (!(*elem_rev)[i], *msg, EMS_E_NoDynamicMemory, ret_end);
      for (j=0; j<(*num_subgrps_grp)[i]; j++)
        {
        (*elem_rev)[i][j] = (IGRboolean *) om$malloc (size =
                             (*num_elems_subgrp)[i][j] * sizeof (IGRboolean));
        EMerr_hndlr (!(*elem_rev)[i][j], *msg, EMS_E_NoDynamicMemory, ret_end);

        for (k=0; k<(*num_elems_subgrp)[i][j]; k++)
          (*elem_rev)[i][j][k] = 
              ((struct traceinfo *) elems2[i][j])->elem_rev[k];
        }
      }

    *subgrp_closed = (IGRboolean **) om$malloc (size = *num_grps *
                      sizeof (IGRboolean *));
    EMerr_hndlr (!*subgrp_closed, *msg, EMS_E_NoDynamicMemory, ret_end);
    for (i=0; i<*num_grps; i++)
      {
      (*subgrp_closed)[i] = (IGRboolean *) om$malloc (size = 
                        (*num_subgrps_grp)[i] * sizeof (IGRboolean));
      EMerr_hndlr (!(*subgrp_closed)[i], *msg, EMS_E_NoDynamicMemory, ret_end);

      for (j=0; j<(*num_subgrps_grp)[i]; j++)
        (*subgrp_closed)[i][j] = 
                    ((struct traceinfo *) elems2[i][j])->grpclosed;
      }
    }
  else
    {
    /*
     * The second trace need not be performed but the output should
     * nevertheless be uniform. The relevant output variables have
     * memory malloced for them and are then initialized.
     */

    *num_grps = tot_numgrps;
    *num_subgrps_grp = (IGRint *) om$malloc (size = tot_numgrps *
                        sizeof (IGRint));
    *num_elems_subgrp = (IGRint **) om$malloc (size = tot_numgrps *
                         sizeof (IGRint *));
    *elems = (struct EMSintobj ***) om$malloc (size = tot_numgrps *
              sizeof (struct EMSintobj **));
    *subgrp_rev = (IGRboolean **) om$malloc (size = tot_numgrps *
                 sizeof (IGRboolean *));
    *elem_rev = (IGRboolean ***) om$malloc (size = tot_numgrps *
                 sizeof (IGRboolean **));
    *grp_closed = (IGRboolean *) om$malloc (size = tot_numgrps *
                   sizeof (IGRboolean));    
    *subgrp_closed = (IGRboolean **) om$malloc (size = tot_numgrps *
                   sizeof (IGRboolean *));    
    EMerr_hndlr (!*num_subgrps_grp || !*num_elems_subgrp ||  !*elems ||
     !*subgrp_rev || !*elem_rev || !*grp_closed || !*subgrp_closed, *msg,
     EMS_E_NoDynamicMemory, ret_end);

    inters_loc = inters;
    for (i=0, k=0; i<num_sfs; i++)
      for (j=0; j<num_grps1[i]; j++)
        {
        (*num_subgrps_grp)[k] = 1;

        (*num_elems_subgrp)[k] = (IGRint *) om$malloc (size = sizeof (IGRint));
        EMerr_hndlr (!(*num_elems_subgrp)[k], *msg, EMS_E_NoDynamicMemory, 
         ret_end);
        (*num_elems_subgrp)[k][0] = num_elems_grp1[i][j];

        (*elems)[k] = (struct EMSintobj **) om$malloc (size =
                       sizeof (struct EMSintobj *));
        EMerr_hndlr (!(*elems)[k], *msg, EMS_E_NoDynamicMemory, ret_end);
        (*elems)[k][0] = (struct EMSintobj *) elems1[i][j][0];

        (*subgrp_rev)[k] = (IGRboolean *) om$malloc (size = 
                            sizeof (IGRboolean));
         EMerr_hndlr (!(*subgrp_rev)[k], *msg, EMS_E_NoDynamicMemory, ret_end);
        (*subgrp_rev)[k][0] = FALSE;

        (*elem_rev)[k] = (IGRboolean **) om$malloc (size =
                          sizeof (IGRboolean *));
        (*elem_rev)[k][0] = (IGRboolean *) om$malloc (size =
                             (*num_elems_subgrp)[k][0] * sizeof (IGRboolean));
        EMerr_hndlr (!(*elem_rev)[k] || !(*elem_rev)[k][0], *msg,
         EMS_E_NoDynamicMemory, ret_end);
        for (l=0; l<(*num_elems_subgrp)[k][0]; l++)
          (*elem_rev)[k][0][l] = elem_rev1[i][j][l];

        (*grp_closed)[k] = grp_closed1[i][j];

        (*subgrp_closed)[k] = (IGRboolean *) om$malloc (size =
                               sizeof (IGRboolean));
        EMerr_hndlr (!(*subgrp_closed)[k], *msg, EMS_E_NoDynamicMemory, 
         ret_end);
        (*subgrp_closed)[k][0] = grp_closed1[i][j];

	k++;
        }
    }

ret_end:
  /*
   * Deallocate any working memory that is not
   * to be output and which has been malloced 
   * here.
   */

  if (sftrace)
    om$dealloc (ptr = sftrace);
  if (num_grps1)
    for (i=0; i<num_sfs; i++)
      EMgentracer_free (num_grps1[i], num_elems_grp1[i], elems1[i],
       elem_rev1[i], grp_closed1[i]);
  if (tempmemptr)
    om$dealloc (ptr = tempmemptr);
  if (elems2)
    {
    for (i=0; i<*num_grps; i++)
      om$dealloc (ptr = elems2[i]);
    om$dealloc (ptr = elems2);
    }

  EMWRAPUP (*msg, stat_OM, "EMsfinttrace");
}

/*
  ABSTRACT:

   The following function is to be used in conjunction with
   EMsfinttrace. All the output memory that has been malloced within
   the trace function should be deallocated using this function.
   If this function is not used for the deallocation, the user
   does so at his own risk.
*/

void EMsfinttrace_free (msg, num_grps, num_subgrps_grp, num_elems_subgrp,
                        elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed)
IGRlong *msg;
IGRint num_grps, *num_subgrps_grp, **num_elems_subgrp;
IGRchar ***elems;
IGRboolean **subgrp_rev, ***elem_rev, *grp_closed, **subgrp_closed;
{
  IGRint i, j;

  *msg = EMS_S_Success;

  if (num_grps)
    {
    if (subgrp_closed)
      {
      for (i=0; i<num_grps; i++)
        if (subgrp_closed[i])
          om$dealloc (ptr = subgrp_closed[i]);
      om$dealloc (ptr = subgrp_closed);
      }

    if (grp_closed)
      om$dealloc (ptr = grp_closed);

    if (elem_rev)
      {
      for (i=0; i<num_grps; i++)
        {
        if (elem_rev[i])
          {
          EMerr_hndlr (!num_subgrps_grp, *msg, EMS_E_InvalidArg, ret_end);
          for (j=0; j<num_subgrps_grp[i]; j++)
            if (elem_rev[i][j]) 
              om$dealloc (ptr = elem_rev[i][j]);
          om$dealloc (ptr = elem_rev[i]);
          }
        }
      om$dealloc (ptr = elem_rev);
      } 

    if (subgrp_rev)
      {
      for (i=0; i<num_grps; i++)
        if (subgrp_rev[i])
          om$dealloc (ptr = subgrp_rev[i]);
      om$dealloc (ptr = subgrp_rev);
      } 

    if (elems)
      {
      for (i=0; i<num_grps; i++)
        if (elems[i])
          om$dealloc (ptr = elems[i]);
      om$dealloc (ptr = elems);
      }

    if (num_elems_subgrp)
      {
      for (i=0; i<num_grps; i++)
        if (num_elems_subgrp[i])
          om$dealloc (ptr = num_elems_subgrp[i]);
      om$dealloc (ptr = num_elems_subgrp);
      }

    if (num_subgrps_grp)
      om$dealloc (ptr = num_subgrps_grp);
    }

ret_end:;
}

#include "emsmacros.h"
#include "bsparameters.h"

extern IGRboolean WANT_POST220_BEHAVIOR;

static IGRboolean is_same_uv(intobj1, intobj2)
struct EMSintobj *intobj1, *intobj2;
{
 IGRboolean same_uv = TRUE; /* default */
 struct GRid sf1, sf2;

 if(!intobj1 || !intobj2)
  goto wrapup;

 if(!intobj1->this_obj_node || !intobj2->this_obj_node)
  goto wrapup;

 if(!WANT_POST220_BEHAVIOR)
  goto wrapup;

 sf1 = intobj1->this_obj_node->this_obj;
 sf2 = intobj2->this_obj_node->this_obj;

 if(IF_NULL_OBJID(sf1.objid) || IF_NULL_OBJID(sf2.objid))
  goto wrapup;

 if(!IF_EQ_GRID(sf1, sf2))
  same_uv = FALSE;

wrapup:
return(same_uv);
}

end implementation Root;
