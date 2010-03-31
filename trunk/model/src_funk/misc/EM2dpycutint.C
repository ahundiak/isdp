/*
  DESCRIPTION

    This function is used to determine "cutting" intersection between a
    2D-polyline (C-poly) and another that bounds an area (W-poly). Cutting
    intersection is different from a regular intersection in that the area
    bounded by W-poly is taken into consideration. C-poly is said to have
    an intersection with W-poly, iff it "cuts" into or out of the area so
    bounded. The convention adopted is that area will be on the right while
    traversing W-poly. W-poly should be flagged as reversed if the area
    is to it's left.

    It follows that W-poly must be closed or form a part of closed boundary.
    If the input W-poly is open this function ignores any intersection
    occurring at the start-point of W-poly. If an intersection takes
    place at the stop-point it obtains the bounds of the area at this
    end-point by requesting for a subsequent segment. This is done through
    a user-provided-function call. If this attempt fails for any reason,
    an intersection is returned regardless of whether it is cutting or
    non-cutting. C-poly is treated as an open polyline.

    A characteristic of the intersections returned is that two coincident
    intersections that might have resulted are altogether rejected. For
    example when C-poly has a single point in common with W-poly, there
    is a possibility of two intersections being output as per the
    "cutting interesction" definition. But such coincident pairs are
    consistently rejected.

    The output is appended (accumulated) to any that might already exist
    on the argument-list. Thus it is very important to NULL (or zero) out
    the output arguments. See notes.

    The boundary of this area, that is W-poly, can be optionally treated
    as hole or area. Also, the end-points of C-poly can be treated specially
    by returning intersections (if they exist) at these points regardless
    of whether it was a cutting intersection or not.

    The output consists of a linked list of EMSpypoint that contains the
    intersection points on C-poly. Also embedded in the EMSpypoint-structure
    is the relative orientation of C-poly w.r.t. W-poly at the intersection
    point. That is, is going from area-to-hole or hole-to-area, etc.
    Usually W-poly will be an EMSedge and information about the relative
    position of the intersection point on this edge can be returned in
    a linked-list of type EMSsfintedpar. Either of these outputs are
    optional and when both these pointers are NULL by value, the function
    exits the moment an intersection is found. This way, it can be used
    to merely detect an intersection. In this case an intersection condition
    is reflected in the return code.

  ARGUMENTS

    num_inwpts		- Input: Number of points in W-poly (bounds an
			   area).
    inwpts		- Input: The points in W-poly.
    wprops		- Input: Properties of W-poly, viz, whether it
			   is open, whether the traversal should
			   take place in the reverse order - EMED_OPEN,
                           EMED_REVERSED.These masks are defined in EMSbnddef.h
    wrange		- Input: The range of W-poly. For best results expand
			   the box by atleast zero-length tolerance. If NULL
			   this box is computed.
    num_incpts		- Input: Number of points in C-poly (possibly 
			   intersecting polyline).
    incpts		- Input: The points in C-poly.
    crange		- Input: The range of C-poly. For best results expand
			   the box by atleast zero-length tolerance. If NULL
			   this box is computed.
    options		- Input: This bit-mask provides for some special
 			   processing that might be desired. Currently,
			   the following options are supported:
                            EMS_INTER_CUTTING - The intersection is defined
                             as the point of cross-over from hole to area.
                             The W-geometry is regarded as belonging to
                             hole or belonging to area depending on how the
                             the bdry-is-area option is set. If not set then
                             an intersection is construed everytime C-geometry
                             meets W-geometry.
                            EMS_INTER_BDRYISAREA - Makes sense only if
                             the "cutting" option is on. If set, the bdry is
                             treated as belonging to area.
                            EMS_INTER_STARTPT - Regardless of the intersection
			      being cutting or not, if the start-point
			      of C-vector is common with W-vector return it
                              as an intersection.
                            EMS_INTER_STOPPT - The above criteria for the
			      stop-point.
                            EMS_INTER_REMZEROEND - It removes any "degenerate"
                              intersection that may have been created at the
                              ends. See emsinterdef.h for more explanation.
                           These masks are defined in EMSbnddef.h
    bastol		- Input: The basis tolerance from which all other 
			  tolerances may be derived using the function
			  EFextract_par. The various tolerances used are
                          BSTOLLENVEC and BSTOLCOLLINVEC.
    getadjseg		- Input: A pointer to the function that should
			   be invoked to get the poly-segment following the
			   last one in W-poly. If NULL, then no attempt
			   is made to get subsequent segment and an
                           intersection at the stop-point (if any) gets
                           returned regardless.
    getadjseg_info	- Input: The structure which is used by this functions
			   to communicate with the above function. See
			   notes.
    wedgeid		- Input: If W-poly is the geometry of an
			   EMSedge, it's objid. Else is set to NULL_OBJID.
    partinfo		- Input: If this is EMSedge part geomtry, the
			   structure indicating the active portion of this
			   geometry.
    num_inters		- Output: The number of intersections found.
    winters		- Output: The output linked list indicating 
			   intersections on W-poly. If NULL this output is
			   skipped.
    cinters		- Output: The output linked list indiacting
			   intersections on C-poly. If NULL this output is
			   skipped.

  RETURN VALUE

    This function returns an IGRboolean value. It returns TRUE if an
    intersection was found, FALSE if no intersection detected.

    The return code on the argument list will be one of the following:
 
    EMS_S_Success
      - If all went well but no intersection
        was found.
    EMS_I_Intersect
      - If all went well and atleast one interesction
        was found.

    EMS_E_Fail
      - A failure occurred in the call to the user-supplied
        function to get adjacent segment.
    EMS_E_NoDynamicMemory
      - A failure to allocate dynamic memory
    
  NOTES

    The pointer to the structure EMSgetadjgeom is used as the only argument
    to the function getadjgeom(). The fields 'this_edge', 'at_start' and
    'adjdata' will be set by this function. The 'msg' field is checked for
    a sucessful return. On successful completion of the function the output
    is expected in 'adjdata'. The field 'geninfo' remains unaltered and
    can be used by the caller to communicate some information to the
    extraction function.

    Since this function accumulates the output, the user should make sure
    the output arguments are correctly zeroed or nulled out. Inside the
    this function, the arguments should read as follows:
      *num_inters == 0, *winters == NULL, *cinters == NULL.

    The 'props' field in the EMSpypoint structure and the 'intloc' field in
    the EMSsfintedpar structure are set to indicate tha relative orientation
    and position of the intersecting points w.r.t. to the entire linestring
    and NOT w.r.t. the individual segment/spans.

  ALGORITHM

    The lowest function called here has been written assuming area on
    the left as traversal proceeds along the W-poly segments. This causes
    some distortion in the general flow of this routine. But attempt has
    been made to well document this within the code. Further, this low-level
    function has been written to understand boundary as hole. This again
    causes special handling.

  NOTES
  
    See file emsinterdef.h for options

  HISTORY

    SS  :  06/10/87     :  Creation
    SCW :  13-Feb-1997  :  included emsmacros_c.h rather than emsmacros.h
*/

#include "EMS.h"
#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMSprop.h"

static void map_back();
static IGRboolean checkfollwpt();

#define X 0
#define Y 1

#define INIT_WVEC_SIZE 200
#define INIT_HOLD_SIZE 10

IGRboolean EM2dpycutint (msg, 
                         num_inwpts, inwpts, wprops, wrange, 
                         num_incpts, incpts, crange,
                         options, bastol, getadjseg, getadjseg_info,
                         wedgeid, partinfo, num_inters, winters, cinters)
IGRlong *msg;
IGRint num_inwpts, num_incpts;
IGRdouble inwpts[][2], *wrange, incpts[][2], *crange;
IGRushort wprops, options;
IGRdouble bastol;
IGRlong (*getadjseg)();
struct EMSgetadjgeom *getadjseg_info;
GRobjid wedgeid;
struct EMSpartedinfo *partinfo;
IGRint *num_inters;
struct EMSsfintedpar **winters;
struct EMSpypoint **cinters;
{
  IGRboolean nextseg_found, intdir_reverse, cutting_int, bdryisarea, remzeropt;
  IGRboolean hold_processing, int_found, last_wseg;
  IGRboolean wold, cold, *wvec_bxint, wvec_bxint_buff[INIT_WVEC_SIZE];
  IGRboolean w_spans_removed, c_spans_removed;
  IGRushort orntprops, intopts;
  IGRint num_wpts, num_cpts;
  IGRint innum_inters, numsgint, i, j, k, last_inx, count;
  IGRlong msg_loc, stat_func;
  IGRdouble wrange_mem[4], crange_mem[4], csgrange[4], subsq_pts[4];
  IGRdouble lentol, *poly_wrange, *poly_crange;
  IGRdouble *foll_wpt, cpar[2], wpar[2], intpt[2][2];
  IGRdouble (*wpts)[2], (*cpts)[2];
  struct IGRpolyline poly;
  struct EMSpypoint *loc_cinters, pypthold_mem[INIT_HOLD_SIZE];
  struct EMSsfintedpar *loc_winters, eparhold_mem[INIT_HOLD_SIZE];
  struct EMSinthold inthold;
  struct EMSpartedinfo *loc_partinfo;
  enum EMScvinttype wint_type[2], cint_type[2];
  enum EMSrelorient relorient[2];
  void EM2dbx();
  void EMint_preprocess(), EMint_process(), EMint_afterprocess();
  IGRboolean EFextract_par(), EM2dsegbxint(), EM2dsgcutint();
  
  *msg = EMS_S_Success;

  /*
   * Initialize local variables.
   */

  wvec_bxint = NULL;
  EFextract_par (BSTOLLENVEC, bastol, &lentol, &msg_loc);
  innum_inters = *num_inters;
  inthold.num_inhold = 0;
  inthold.pypts = pypthold_mem;
  inthold.epars = winters ? eparhold_mem : NULL;
  inthold.malloc_at = INIT_HOLD_SIZE+1;

  /*
   * Remove all degenerate spans from the input polylines, if they are present.
   * These cause erroneous intersection results to be produced on account
   * of tolerancing issues. If certain spans were removed from the input
   * data, special processing may be necessary to return the intersection 
   * results relative to the original input. The partinfo being passed
   * in will now be invalid wrt to the changed geometry. So, re-doing the
   * parameters on account of the partinfo is done during the map-back
   * (when the special processing is done).
   */

  loc_partinfo = partinfo;
  if (EMcount_degen_spans (num_inwpts, inwpts, NULL, 2, lentol))
    {
    wpts = (IGRdouble (*)[]) alloca (num_inwpts * 2 * sizeof (IGRdouble));
    EMremove_degen_spans (num_inwpts, inwpts, NULL, &num_wpts, wpts, NULL,
     2, lentol);
    w_spans_removed = TRUE;
    }
  else
    {
    num_wpts = num_inwpts;
    wpts = inwpts;
    w_spans_removed = FALSE;
    }
  if (w_spans_removed)
    loc_partinfo = NULL;

  if (EMcount_degen_spans (num_incpts, incpts, NULL, 2, lentol))
    {
    cpts = (IGRdouble (*)[]) alloca (num_incpts * 2 * sizeof (IGRdouble));
    EMremove_degen_spans (num_incpts, incpts, NULL, &num_cpts, cpts, NULL,
     2, lentol);
    c_spans_removed = TRUE;
    }
  else
    {
    num_cpts = num_incpts;
    cpts = incpts;
    c_spans_removed = FALSE;
    }

  /*
   * Obtain the range of the input polylines.
   * Widen the C-range by "tolerance" to be sure
   * no spurious, trivial rejections take place.
   */

  if (crange)
    poly_crange = crange;
  else
    {
    poly_crange = crange_mem;
    EM2dbx (num_cpts, cpts, poly_crange);
    EM2dbxinc (poly_crange, lentol);
    }

  if (wrange)
    poly_wrange = wrange;
  else
    {
    poly_wrange = wrange_mem;
    EM2dbx (num_wpts, wpts, poly_wrange);
    }

  /*
   * Check if the range boxes of the two polylines
   * intersect at all. 
   */

  if (!EM2dbxbxint (poly_wrange, poly_crange))
    {
    /*
     * None of this object's segments lie within
     * the range of the input polyline. Simply
     * exit.
     */

    goto ret_end;
    }

  /*
   * Create an array containing information
   * whether a segment of this object has been
   * trivially rejected or not.
   */

  if (num_wpts-1 > INIT_WVEC_SIZE)
    {
    wvec_bxint = (IGRboolean *) malloc ((num_wpts - 1) * 
                  sizeof (IGRboolean));
    EMerr_hndlr (!wvec_bxint, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  else
    wvec_bxint = wvec_bxint_buff;

  count = 0;
  for (i=0; i<num_wpts-1; i++)
    if (wvec_bxint[i] = EM2dsegbxint (&wpts[i][X], poly_crange)) count++;

  if (!count)
    {
    /*
     * None of this object's segments lie within
     * the range of the input polyline. Simply
     * exit.
     */
      
    goto ret_end;
    }

  /*
   * Set the local flags and variables that indicate the state of
   * the processing and any special processing that might be required.
   * Some explanation for the various flags is given below:
   *
   * Since the segment-intersection function understands boundary as
   * hole, some gyrations are necessary when boundary is to be treated as 
   * area. To get all the internal "cutting" intersections in this case,
   * it is sufficient to toggle the hole portion to area (achieved by
   * reversing the original direction of traversal). Here, by internal
   * intersections is meant, intersections not occuring at the stop-point
   * (start-point ignored anyway). This way, criteria for transition 
   * (hole-area) gets toggled at the boundary and the desired effect can
   * be achieved.
   * Example: A segment that once went from hole to boundary (that is hole)
   * producing no intersection, now goes from area to boundary (that is hole)
   * and produces an intersection. But the final relative orientation will
   * be flagged as going from hole-to-area.
   *
   * In order to get the correct intersection (if any) at the stop-point the
   * following, adjacent W-poly segment has to be introduced in the
   * appropriate position and this is different for the case when boundary
   * is being treated as hole.
   */

  nextseg_found = FALSE;  
  foll_wpt = NULL;
  loc_cinters = NULL;
  if (cinters && *cinters && (*cinters)->span_inx >= 0)
    {
    loc_cinters = *cinters;
    while (loc_cinters->next && loc_cinters->next->span_inx >=0)
      loc_cinters = loc_cinters->next;
    cold = TRUE;
    }
  else
    cold = FALSE;

  loc_winters = NULL;
  if (winters && *winters && (*winters)->edgepar.span_inx >= 0)
    {
    loc_winters = *winters;
    while (loc_winters->next && loc_winters->next->edgepar.span_inx >= 0)
      loc_winters = loc_winters->next;
    wold = TRUE;
    }
  else
    wold = FALSE;

  bdryisarea = NULL;
  if (options & EMS_INTER_CUTTING)
    {
    cutting_int = TRUE;
    intdir_reverse = !(wprops & EMED_REVERSED);
    if (options & EMS_INTER_BDRYISAREA)
      {
      bdryisarea = TRUE;
      intdir_reverse = !intdir_reverse;
      }
    else
      bdryisarea = FALSE;
    }
  else
    {
    cutting_int = FALSE;
    intdir_reverse = FALSE;
    }
  remzeropt = options & EMS_INTER_REMZEROEND;

  /*
   * Perform the intersection calculation, looping
   * over every input-polyline segment for every
   * segment of this edge.
   */

  for (i=0; i<num_cpts-1; i++)
    {
    /*
     * Obtain the range of the current inpoly-segment,
     * widening it to safeguard against spurious 
     * rejections.
     */

    csgrange[0] = cpts[i][X];
    csgrange[1] = cpts[i][Y];
    csgrange[2] = cpts[i+1][X];
    csgrange[3] = cpts[i+1][Y];
    if (csgrange[0] > csgrange[2]) 
      {
      csgrange[0] = csgrange[2];
      csgrange[2] = cpts[i][X];
      }
    if (csgrange[1] > csgrange[3])
      {
      csgrange[1] = csgrange[3];
      csgrange[3] = cpts[i][Y];
      }
    EM2dbxinc (csgrange, lentol);
 
    /*
     * The existence of a "cutting" intersection
     * at end-point is ambiguos in the case of an
     * open linestring. The "following" point is used
     * to determine the area at this region of the 
     * linestring. This auxilliary point is used
     * solely for the purpose of determining end-point
     * intersection. Therefore, if intersection at the logical
     * endpoint of this edge can be trivially eliminated,
     * there is no need to gather this information at the time.
     *
     * If this information is considered necessary and it hasn't
     * been obtained previously, the logical subsequent point is
     * got by taking into account this edge and it's loop's
     * orientation. 
     *
     * Intersection at the begin point of this edge is to be ignored and
     * only intersection (if any) at the other endpoint is to be considered.
     * It turns out that regardless of the direction of traversal dictated
     * by the flag "intdir_reverse", the subsequent point is to be inserted
     * in the following order: subsequent-point, followed by the first
     * traversal point, followed by the second traversal point and so on.
     * The logic turns out this way because the TRAVERSAL START-POINT
     * in either case (reverse traversal or not) is really the TRUE STOP-POINT
     * of the edge.
     */

    last_inx = (bdryisarea ? !intdir_reverse : intdir_reverse) ? 
                num_wpts-1 : 0;
    if (cutting_int && !nextseg_found && 
        EM2dptinbx (csgrange, wpts[last_inx]))
      {
      nextseg_found = TRUE;
      if (getadjseg && wprops & EMED_OPEN)
        {
        getadjseg_info->this_edge = wedgeid;
        getadjseg_info->at_stop = TRUE;
        poly.points = subsq_pts;
        getadjseg_info->adjdata.data.poly = &poly;
        stat_func = (*getadjseg)(getadjseg_info);
        EMerr_hndlr (EMSerror (stat_func & getadjseg_info->msg), *msg,
         EMS_E_Fail, ret_end);
        if (getadjseg_info->msg != EMS_I_OutOfBounds)
          foll_wpt = &subsq_pts[2];
        }
      else if (!(wprops & EMED_OPEN))
        foll_wpt = wpts[last_inx ? 1 : num_wpts-2];
      if (! checkfollwpt (foll_wpt, 
                          wpts[last_inx], wpts[last_inx ? num_wpts-2 : 1],
                          bastol))
        foll_wpt = NULL;
      }

    /*
     * If the options dictate that even a non-cutting intersection
     * at endpoints must be output, set the segment intersection options mask
     * accordingly. If a double-checking algorithm needs to be invoked
     * set the local options mask to indicate this.
     */

    intopts = NULL;
    if (i == 0 && options & EMS_INTER_STARTPT)
      intopts |= EMS_INTER_STARTPT;
    if (i == num_cpts-2 && options & EMS_INTER_STOPPT)
      intopts |= EMS_INTER_STOPPT;

    /*
     * The sequence of "wpts" given is different
     * for "intdir_reverse" and "!intdir_reverse".
     * Hence the two sets of code. If "intdir_reverse" this
     * object is traversed in reverse.
     */
  
    if (intdir_reverse)
      {
      if (foll_wpt && !bdryisarea &&
          wvec_bxint[num_wpts-2] &&
          EM2dsegbxint (wpts[num_wpts-2], csgrange) &&
          EM2dsgcutint (foll_wpt, wpts[num_wpts-1], wpts[num_wpts-2],
           cpts[i], cpts[i+1], bastol, intopts, &numsgint, 
           wint_type, cint_type, wpar, cpar, intpt, relorient))
        {
        for (k=0; k<numsgint; k++)
          {
          if (wint_type[k] == EMScvint_middle)
            continue;

          EMint_preprocess (&msg_loc, num_wpts-2, i, 1.0, cpar[k], 
           EMScvint_rtend, &cint_type[k], intpt[k], relorient[k], bdryisarea,
           remzeropt, num_cpts, wedgeid, &orntprops, &inthold, 
           &hold_processing);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

          if (! hold_processing)
            {
            EMerr_hndlr (!winters && !cinters, *msg, EMS_I_Intersect, ret_end);
  
            EMint_process (&msg_loc, wold ? &loc_winters->next : winters, 
             cold ? &loc_cinters->next : cinters, num_wpts-2, i, 1.0, cpar[k],
             EMScvint_rtend, cint_type[k], intpt[k], wedgeid, orntprops,
             loc_partinfo);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
            (*num_inters)++;
            }
          }
        }

      for (j=num_wpts-1; j>0; j--)
        {
        last_wseg = j<2;
        if (wvec_bxint[j-1] &&
            EM2dsegbxint (wpts[j-1],csgrange) &&
            EM2dsgcutint (wpts[j], wpts[j-1], 
             last_wseg ? (bdryisarea ? foll_wpt : NULL) : wpts[j-2],
             cpts[i], cpts[i+1], bastol, intopts, &numsgint, 
             wint_type, cint_type, wpar, cpar, intpt, relorient))
          {
          for (k=0; k<numsgint; k++)
            {
            if (last_wseg && !bdryisarea && wint_type[k] != EMScvint_middle)
              continue;
            else if (!last_wseg || !bdryisarea)
              wint_type[k] = EMScvint_middle;

            EMint_preprocess (&msg_loc, j-1, i, 1.0-wpar[k], cpar[k], 
             wint_type[k], &cint_type[k], intpt[k], relorient[k],
             bdryisarea, remzeropt, num_cpts, wedgeid, &orntprops, &inthold,
             &hold_processing);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
  
            if (! hold_processing)
              {
              EMerr_hndlr (!winters && !cinters, *msg, EMS_I_Intersect, 
               ret_end);
  
              EMint_process (&msg_loc, wold ? &loc_winters->next : winters, 
               cold ? &loc_cinters->next : cinters, j-1, i, 1.0-wpar[k], 
               cpar[k], wint_type[k], cint_type[k], intpt[k],
               wedgeid, orntprops, loc_partinfo);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
              (*num_inters)++;
              }
            }
          }
        }
      }  
    else /* !intdir_reverse */
      {
      if (foll_wpt && !bdryisarea &&
          wvec_bxint[0] &&
          EM2dsegbxint (wpts[0], csgrange) &&
          EM2dsgcutint (foll_wpt, wpts[0], wpts[1], cpts[i], cpts[i+1],
           bastol, intopts, &numsgint, wint_type, cint_type, wpar, cpar, 
           intpt, relorient))
        {
        for (k=0; k<numsgint; k++)
          {
          if (wint_type[k] == EMScvint_middle)
            continue;

          EMint_preprocess (&msg_loc, 0, i, 0.0, cpar[k], EMScvint_rtend, 
           &cint_type[k], intpt[k], relorient[k], bdryisarea, remzeropt, 
           num_cpts, wedgeid, &orntprops, &inthold, &hold_processing);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

          if (! hold_processing)
            {
            EMerr_hndlr (!winters && !cinters, *msg, EMS_I_Intersect, ret_end);
  
            EMint_process (&msg_loc, wold ? &loc_winters->next : winters, 
             cold ? &loc_cinters->next : cinters, 0, i, 0.0, cpar[k],
             EMScvint_rtend, cint_type[k], intpt[k], wedgeid, orntprops, 
             loc_partinfo);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
            (*num_inters)++;
            }
          }
        }

      /*
       * All the processing for non-cutting intersection is done within this
       * for-loop, when the option has been so set. This for-loop of course 
       * handles the case of cutting-intersection also.
       */

      for (j=0; j<num_wpts-1; j++)
        {
        last_wseg = j>num_wpts-3;
        if (wvec_bxint[j] &&
            EM2dsegbxint (wpts[j],csgrange) &&
            (cutting_int ?
             EM2dsgcutint (wpts[j], wpts[j+1], 
              last_wseg ? (bdryisarea ? foll_wpt : NULL) : wpts[j+2],
              cpts[i], cpts[i+1], bastol, intopts, &numsgint, 
              wint_type, cint_type, wpar, cpar, intpt, relorient) :
             EF2dpyint (&bastol, cpts[i], cpts[i+1], wpts[j], wpts[j+1],
              wint_type, wpar, cint_type, cpar, intpt, &msg_loc)))
          {
          numsgint = cutting_int ? numsgint : 1;
          for (k=0; k<numsgint; k++)
            {
            if (cutting_int)
              {
              if (last_wseg && !bdryisarea && wint_type[k] != EMScvint_middle)
                continue;
              else if (!last_wseg || !bdryisarea)
                wint_type[k] = EMScvint_middle;
              }
            else
              {
              if (j && !last_wseg)
                wint_type[k] = EMScvint_middle;
              relorient[k] = EMSrelorient_unknown;
              }

            EMint_preprocess (&msg_loc, j, i, wpar[k], cpar[k],
             wint_type[k], &cint_type[k], intpt[k], relorient[k],
             bdryisarea, remzeropt, num_cpts, wedgeid, &orntprops, &inthold,
             &hold_processing);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
  
            if (! hold_processing)
              {
              EMerr_hndlr (!winters && !cinters, *msg, EMS_I_Intersect, 
               ret_end);
  
              EMint_process (&msg_loc, wold ? &loc_winters->next : winters, 
               cold ? &loc_cinters->next : cinters, j, i, wpar[k], cpar[k],
               wint_type[k], cint_type[k], intpt[k], wedgeid, orntprops, 
               loc_partinfo);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
              (*num_inters)++;
              }
            }
          }
        }
      }
    }

  /*
   * Check to see if any of the intersections required any post-processing.
   * If so call the post-processor to output any remaining valid
   * intersections.
   */

  if (inthold.num_inhold)
    {
    EMint_afterprocess (&msg_loc, 
     (cutting_int ? NULL : EMS_INTER_ONEOFTWO) | options,
     wold ? &loc_winters->next : winters, 
     cold ? &loc_cinters->next : cinters,
     num_inters, &inthold, loc_partinfo);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }

  /*
   * If the input was altered (removal of degenerate spans), we must now
   * process the intersections to have them specified relative to the
   * original input.
   */

  if (*num_inters > innum_inters &&
      (w_spans_removed || c_spans_removed))
    {
    if (w_spans_removed && winters)
      map_back (TRUE, (IGRchar *) (wold ? loc_winters->next : *winters), 
       num_inwpts, inwpts, wprops & EMED_REVERSED, partinfo, lentol);
    if (c_spans_removed && cinters)
      map_back (FALSE, (IGRchar *) (cold ? loc_cinters->next : *cinters), 
       num_incpts, incpts, FALSE, NULL, lentol);
    }

ret_end:
  /*
   * Deallocate all the memory that was allocated by
   * during this method and that is not going to be
   * returned.
   */

  if (wvec_bxint && num_wpts-1 > INIT_WVEC_SIZE) 
    free (wvec_bxint);
  if (inthold.num_inhold > INIT_HOLD_SIZE)
    {
    free (inthold.pypts);
    if (inthold.epars)
      free (inthold.epars);
    }

  int_found = FALSE;
  if (! EMSerror (*msg) && (*num_inters > innum_inters))
    {
    *msg = EMS_I_Intersect;
    int_found = TRUE;
    }
       
  if (EMSerror (*msg)) printf ("Error in EM2dpycutint %d", *msg);
  return (int_found);
}


/*
 * A locally used function to test if the first point is collinear 
 * and lies along the vector defined by the given two points.
 */

#define ZERO 0

static IGRboolean checkfollwpt (inpt, pt1, pt2, bastol)
IGRdouble *inpt, *pt1, *pt2, bastol;
{
  IGRboolean sign;
  IGRlong msg_loc;
  IGRdouble vec[2], vecp[2], val;
  IGRdouble coltol;
  IGRboolean EFextract_par();
  IGRint EM2dcrossp();

  if (!inpt)
    return (FALSE);

  EFextract_par (BSTOLCOLLINVEC, bastol, &coltol, &msg_loc);

  vec[X] = pt2[X] - pt1[X];
  vec[Y] = pt2[Y] - pt1[Y];
  vecp[X] = inpt[X] - pt1[X];
  vecp[Y] = inpt[Y] - pt1[Y];
  if (fabs (vecp[X]) > bastol || fabs (vecp[Y]) > bastol)
    {
    sign = EM2dcrossp (&coltol, vec, vecp, &val, &val);
    if (sign == ZERO)
      {
      val = vec[X] * vecp[X] + vec[Y] * vecp[Y];
      if (val < 0)
        return (TRUE);
      else
        return (FALSE);
      }
    else
     return (TRUE);
    }
  else
    return (FALSE);
}


static void map_back (is_w, inters, num_inpts, inpts, rev, part, tol)
IGRboolean is_w;
IGRchar *inters;
IGRint num_inpts;
IGRdouble (*inpts)[2];
IGRboolean rev;
struct EMSpartedinfo *part;
IGRdouble tol;
{
  IGRint start_parinx, stop_parinx;
  IGRlong msg_loc;
  IGRdouble mindist, *pt;
  struct IGRpolyline py;
  struct EMSpypoint pypt, *pypts;
  struct EMSsfintedpar *edpars;
  struct EMSedgebound inpar, outpar;
  
  if (is_w)
    edpars = (struct EMSsfintedpar *) inters;
  else
    pypts = (struct EMSpypoint *) inters;

  py.num_points = num_inpts;
  py.points = (IGRdouble *) inpts;
  while (is_w ? (IGRchar *) edpars : (IGRchar *) pypts)
    {
    pt = is_w ? edpars->point : pypts->point;
    EMcnvtpypts (&msg_loc, &py, 2, 1, pt, tol, &pypt, &mindist);
    if (part)
      {
      inpar.span_inx = pypt.span_inx;
      inpar.param = pypt.param;
      start_parinx = (part->edprops & EMED_REVERSED ? 1 : 0);
      stop_parinx = (part->edprops & EMED_REVERSED ? 0 : 1);
      EMcnvtedpar (&msg_loc, &part->edbdry[start_parinx], 
       &part->edbdry[stop_parinx], &inpar, &outpar);
      pypt.span_inx = outpar.span_inx;
      pypt.param = outpar.param;
      }

    if (rev)
      {
      if (pypt.props & EMS_PYPT_ATSTART)
        {
        pypt.props |= EMS_PYPT_ATSTOP;
        pypt.props &= ~EMS_PYPT_ATSTART;
        }
      else if (pypt.props & EMS_PYPT_ATSTOP)
        {
        pypt.props |= EMS_PYPT_ATSTART;
        pypt.props &= ~EMS_PYPT_ATSTOP;
        }
      }

    if (is_w)
      {
      edpars->edgepar.span_inx = pypt.span_inx;
      edpars->edgepar.param = pypt.param;
      OM_BLOCK_MOVE (pypt.point, edpars->point, 2 * sizeof (IGRdouble));
      if (pypt.props & EMS_PYPT_ATSTOP)
        edpars->intloc = EMScvint_rtend;
      else if (pypt.props & EMS_PYPT_ATSTART)
        edpars->intloc = EMScvint_lfend;
      else if (pypt.props & EMS_PYPT_ATMIDDLE)
        edpars->intloc = EMScvint_middle;
      else
        edpars->intloc = EMScvint_unknown;

      edpars = edpars->next;
      }
    else
      {
      pypts->span_inx = pypt.span_inx;
      pypts->param = pypt.param;
      OM_BLOCK_MOVE (pypt.point, pypts->point, 2 * sizeof (IGRdouble));
      pypts->props = pypt.props;
 
      pypts = pypts->next;
      }
    }

  return;
}
