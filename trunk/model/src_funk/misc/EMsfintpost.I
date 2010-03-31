/*
  DESCRIPTION

    The following function may be called as a post-processing step to a
    surf-surf intersection call. A number of calls to this function in
    a specific sequence may be necessary to accomplish the requisite
    post-processing. Each invocation performs a small, specific task.

    The basic idea is to do an N-squared comparison of all the intobjs
    inside an EMSinters-list against all others. Actually, the pairs that
    are compared have to satisfy specified properties before they become
    candidates for the comparison (example: the EMSintobj_dupthissurf must
    be set on one of the pair and EMSintobj_coincident must NOT be set on
    the other of the pair). A criterion is looked for to be satisfied
    (example: the two intobjs being compared are coincident). When found
    to be satisfied an action is performed on one or both the intobjs
    (example: delete the "first" one in the pair). The exception to the rule
    is that sometimes it may not be a pair that's processed but just a single
    intobj, depending on the action specified.

    "A_checkpresent" is the set of properties that must be satisfied 
    and "A_checkabsent" is the set of properties that must NOT be present
    for an intobj to become the first of a candidate pair (hereinafter
    called the 'marked' intobj). A NULL in either of these positions implies
    a dont-care (eg: NULLs for both arguments means every intobj is a
    potential candidate for the first of the pair). For those actions looking
    for single intobjs, the "B_checkpresent" and "B_checkabsent" properties
    are ignored.

    "B_checkpresent" is the set of properties that must be satisfied
    and "B_checkabsent" is the set of properties that must NOT be present
    for an intobj to become a candidate for the second of the pair (hereinafter
    called 'unmarked'). A NULL in either of these position implies
    a dont-care.
 
    The following criteria are catered to by this function. This criterion
    is specified via the "check" enumerated type argument. Also, the
    action that needs to be taken if the criterion is satisified is specified 
    within the bits of the same "actoptions". Some of the actions taken
    are automatic and inherent in the "check" type chosen.

    1) chk_dupsamesurf:
       Candidate pairs are investigated for being coincident. The search
       for these pairs is limited to within the same surface. On being found
       coincident, the action to remove one or both the 'marked' and/or the
       'unmarked' is taken, depending on what has been specified in the
       "actoptions". "num_samplepts" is the number of sample-points that
       will be used to detect coincidence. If the 'marked' intersection had
       the EMSintobj_dupthissurf property turned on, it is turned off.

    2) chk_dupothersurf:
       Candidate pairs are investigated for being coincident. The search
       for these pairs is done across surfaces. On being found coincident,
       the action to remove one or both the 'marked' and/or the
       'unmarked' is taken, depending on what has been specified in the
       "actoptions". "num_samplepts" is the number of sample-points that
       will be used to detect coincidence.

    3) chk_deletable:
       Candidate single intobj is investigated for being deletable by
       virtue of it being marked EMSintobj_deletable. On finding such 
       an intobj, it is unconditionally deleted.

    4) chk_nonoriented:
       Candidate single intobjs are investigated for being non-orientable. 
       Their non-orientability is simply gleaned from the fact that they
       are marked EMSintobj_nonoriented. These are, typically, intersections 
       occurring along a tangency. Today, they are unconditionally deleted.
       This is a good action if the intersection is regarded as a non-cutting
       tangency situation (the neighorhood on either side of the intersection
       is on the same side of the other surface). But if this is a cutting
       tangency, then this is a wrong action. Therefore, today, a cutting
       tangency situation will always fail with a closure problem.

    5) chk_redundant:
       Candidate single intobjs that are checked for being redundant. These are
       the intobjs marked EMSintobj_xyzdegenerate (geometrically
       redundant) AND are found topologically redundant. In other words,
       their absence will not destroy topological or geometric continuity.
       If redundancy is determined the intobj is deleted.

    6) chk_noconnect:
       Candidate pairs within a surface are investigated for being
       geometrically contiguous and topologically well-defined (that is,
       non-NULL information about the incident edge is present). If found,
       the fwd-noconnet or the bwd-noconnect pointers are set so as to prevent
       their linkup into the same sub-group, later on. This should cause
       an appropriate 'split' to take place. Today, a conservative approach
       of doing this only when the topological incidence information points
       to a vertex, is taken.
   
    7) chk_opporiented:
       Candidate pairs on the same surface are first investigated for being
       coincident. When found so, they are further tested for being oppositely
       oriented. On passing this test, both the intobjs are marked as
       non-oriented. This is done, since their orientation w.r.t. the
       solid is suspect. Further processing (example: calling this
       same function with EMSfixsfint_chk_nonoriented) can correct this
       situation. "num_samplepts" is the number of sample-points that
       will be used to detect coincidence.

    8) chk_midptcoinc:
       Candidate pairs on the same surface are investigated to see if an
       end-point of intobj-B lies in the middle of intobj-A. If found so,
       such a pair becomes an eligible pair. If the option is set to split
       intobjs if necessary, then, intobj-A is split into two intobjs
       (the EMSinters list is actually altered to now contain the two intobjs
       instead of the one). The 'other' intobj is also split so consistency
       is maintained. At the end of such a call (with the option set to
       'splitinters'), there should be no candidate pairs that touch each
       other at points other than their endpoints. Caveat: In the current
       implementation, if 'splitinters' option is not set, the number of
       eligible candidates may not reflect the exact number of pairs that
       are truly eligible. The only purpose num_eligible would serve in this
       case would be to tell you a YES or a NO.

    "num_candidates" returns the number of candidates found. 
    "num_eligible" returns the number of candidates that were found eligible.
    Either of these are optional arguments (NULL will suffice).

  NOTES
   
    The input intersection list must contain model-space data if the
    option is to process coincidence.

    After the call some of the intersections may have the "marked" bit
    set in their props. This bit should be manually turned off after
    the sequence of calls to this function is complete.

  BUGS 
    
    For now, a maximum of 30 sampling points can be asked for geometric
    testing. This restriction should be lifted by doing mallocs if necessary.

    For now, it is hoped that a maximum of 10 degenerate, contiguos edges are
    all that occur before a non-degenerate edge is reached. This is used
    in testing for duplicates with degenerate-intersections that lie
    at the end-points of other intersections.

    The processing for non-oriented intersections currently involves
    an unconditional removal of such an intersection. This amounts to
    an assumption that such intersections are always "non-cutting", that
    is, the intersecting surfaces do not "dig" into each other.

  HISTORY

    SS  : 06/23/94   :  Added the functionality to split intersection objects
                        against each other.
    SAM : 05/19/94   :  Before checking for noconnect check if the
                        EMSintobj_nontriminfo is set in the intobj props.
			In such a case do not check.
    NP  : 01/06/93   :  Arguments "A/Bcheckpresent" and "A/Bcheckabsent" had 
                        been declared as IGRushort. Changed them to IGRulong, 
                        since we have changed intobj->props field to IGRulong 
                        some time ago. (EMfixsfintout and delsfintdup fns.).
    NP  : 12/24/93   :  Intobj delete criteria in function "delsfintdup" was 
                        not considering that there might be intersections 
                        between surfaces of the SAME inters list.
    NP  : 12/08/93   :  Added function "EFkeep_correct_intobj" inside the 
                        "delsfintdup" function. This function will enable the 
                        correct intobj (from a pair that is oppositely 
                        oriented) to be kept (if there IS a correct intobj)
                        else it simply deletes both. This is our first attempt
                        at handling a non-manifold intersection on a surface
                        other than simply deleting both.
    NP  : 05/27/93   :  Funtction "EMmkintlist" is now called by a new
                        name, "EMmakeintlist", due to addition of two new
                        curve type parameters.
                        NOTE:  The "cctype" variable used in EMmkintdata is 
                               used as the curve type in the call to 
                               EMmakeintlist.
    NP  : 04/20/92   :  In "EMdelsfintdup" function, added code to check if a
                        pair of duplicates flow opposite to each other, in 
                        which case mark them both as non-orientable, so that 
                        they can be deleted in a subsequent call to 
                        EMfixsfintout. Also cleaned up the code to remove
                        compiler warnings.
    SS  :  12/26/90  :  Added the option to change the class of a uv-object
                        to "EMSdummy" if found lying along an edge. The
                        check is performed only on the data found to have
                        duplicates.
    SS  :  03/12/89  :  Added the option to remove topologically redundant
                        intersections.
    SS  :  09/06/89  :  Modified so that either or both intersection lists
			can be passed in.
    SS  :  10/27/88  :  Altered the logic stated below to make it more
                        discriminatory.
    SS  :  09/12/88  :  Altered the logic to remove coincident, degenerate
                        intersections that lie at end-points of some other
                        intersection and do not have legitimate incident
                        edge information.
    SS  :  08/12/88  :  Changed the argument checkagainst to now correspond
                        with B_checkpresent, B_checkabsent.
    SS  :  02/02/88  :  Changed the single options field to checkthese,
                        checkagainst and actoptions. This should give more
                        flexibility in calling the function.
    SS  :  12/01/87  :  Generalized the function to also orient the 
                        non-oriented intersections.
    SS  :  10/29/87  :  Creation
*/

class implementation Root;

%safe
#include <math.h>
%endsafe
#include "EMS.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "bserr.h"
#include "bsparameters.h"

#define FIRST  0
#define SECOND 1

#define START  0
#define STOP   1

#define FIRST_INTERNAL 2

/*
 * The maximum number of sampling points that may be used to detect
 * coincidence between two linear objects. Also a good number for internal
 * sampling.
 */

#define MAX_NUM_SAMPLEPTS 30

from EMSedge import EMtangent, EMget_bcxyz_geom;

#define EMerr_exit(sts, label) if (EMSerror (sts)) goto label;

%safe
static void delsfintdup(), delredundant(), chknoconnect(), midptcoinc();
static  IGRboolean deldgncoinc();
static void EFkeep_correct_intobj();
%endsafe

IGRlong EMfixsfintout (msg, inters1, modenv1, inters2, modenv2,
                       altxyztol, num_samplepts, 
                       A_checkpresent, A_checkabsent,
                       B_checkpresent, B_checkabsent, 
                       criterion, actoptions,
                       num_candidates, num_eligible)
IGRlong *msg;
struct GRmdenv_info *modenv1, *modenv2;
struct EMSinters **inters1, **inters2;
IGRdouble *altxyztol;
IGRint num_samplepts;
IGRulong A_checkpresent, A_checkabsent, B_checkpresent, B_checkabsent;
IGRushort actoptions;
IGRint *num_candidates, *num_eligible;
{
  IGRboolean delopt, is_candidate;
  IGRshort *mattyp;
  IGRint inx, num_deleted, num_eligible_loc, num_candidates_loc;
  IGRlong msg_loc, stat_OM;
  IGRdouble *mat, uvlentol, bastol, lentol;
  GRspacenum intos;
  struct EMSinters *inters_loc1, *inters_loc2;
  struct EMSintobj *intobj_loc;
  struct EMSintobj *intobj_next;
  extern void EMdelintobj(), EMcmpinters();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (num_eligible)
    *num_eligible = 0;
  if (num_candidates)
    *num_candidates = 0;

  num_deleted = 0;
  delopt = actoptions & 
            (EMSfixsfint_act_delmarked | EMSfixsfint_act_delunmarked);

  /*
   * Obtain the xyz tolerance. This is of course
   * common to all surfaces. 
   */

  EMerr_hndlr (num_samplepts > MAX_NUM_SAMPLEPTS, *msg, 
   EMS_E_InvalidArg, ret_end);

  if (altxyztol)
    lentol = *altxyztol;
  else
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, lentol);

  /*
   * Process each intersection list.
   */

  for (inx=0; inx<2; inx++)
    {
    if (inx == 0)
      {
      if (!inters1)
        continue;
      mattyp = &modenv1->matrix_type;
      mat = modenv1->matrix;
      inters_loc1 = *inters1;
      intos = inters_loc1->this_obj.osnum;
      }
    else
      {
      if (!inters2)
        continue;
      mattyp = &modenv2->matrix_type;
      mat = modenv2->matrix;
      inters_loc1 = *inters2;
      intos = inters_loc1->this_obj.osnum;
      }

    /* 
     * Process each surface in the intersection list. Those criterion
     * checks that relate to intobjs within the same surface are
     * processed in the following while-loop.
     */

    while (inters_loc1)
      {
      intobj_loc = inters_loc1->cvs;

      /*
       * Obtain the uv-space tolerances. This is specific
       * to each individual surface. Do this only in the cases
       * where uv-tol is required.
       */

      if (criterion == chk_noconnect ||
          criterion == chk_midptcoinc ||
          criterion == chk_redundant)
        {
        msg_loc = EMget_partol_inters (inters_loc1, mattyp, mat, &uvlentol);
        EMerr_exit (msg_loc, ret_end);

        BSEXTRACTPAR (&msg_loc, BSTOLBASIS, bastol);
        uvlentol *= (lentol / bastol);
        }

      /*
       * For a given intobj, first check if it is a potential candidate.
       * If it is found so, then further check if it is eligible using
       * the specified criterion. If so then, perform the action. A
       * lot of times here, the criterion check and the action are
       * being performed within a function being called.
       */

      while (intobj_loc)
        {
        intobj_next = intobj_loc->next;
 
        /*
         * Do the candidacy check. For a criterion that requires a pair,
         * this is only half the check. The B_checkpresent and B_checkabsent
         * need to be applied to find the second of the pair.
         */

        is_candidate = 
             (A_checkpresent ? 
              (intobj_loc->props & A_checkpresent) == A_checkpresent : TRUE) &&
             (A_checkabsent ? 
              !(intobj_loc->props & A_checkabsent) : TRUE);
        if (! is_candidate)
          goto Next1;

        if (criterion == chk_dupsamesurf)
          {
          /*
           * The function call below locates all coincident intobjs based on
           * a regular sample-pts, geometric check. If one of the pair of
           * coincident intobjs is xyz-degenerate, then a special criterion is
           * used (encoded in the function - deldgncoinc) to determine if
           * this can be truly contrued as coincident. The candidacy and
           * eligibility of any pairs found is done within the function.
           */

          delsfintdup (&msg_loc, mattyp, mat, num_samplepts,
           lentol, intobj_loc, &intobj_next, 
           actoptions, B_checkpresent, B_checkabsent,
           inters_loc1, &num_candidates_loc, &num_eligible_loc);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          if (num_candidates)
            *num_candidates += num_candidates_loc;
          if (num_eligible)
            *num_eligible += num_eligible_loc;

          if (delopt)
            num_deleted += num_eligible_loc;
          }

        else if (criterion == chk_deletable)
          {
          /*
           * This single intobj is a candidate. If it has it's deletable
           * property on, it is eligible. Perform the needful.
           */

          if (num_candidates)
            (*num_candidates)++;

          if (intobj_loc->props & EMSintobj_deletable)
            {
            if (num_eligible)
              (*num_eligible)++;
            if (intobj_next == intobj_loc)
              intobj_next = intobj_loc->next;
            EMdelintobj (&msg_loc, intobj_loc);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

            num_deleted++;
            }
          }

        else if (criterion == chk_nonoriented)
          {
          /*
           * This single intobj is a candidate. If it has it's non-oriented
           * property on, it is eligible. Some extensive works needs to
           * be done in order to "very correctly" process this situation.
           * For now, treat the situation as equivalent to a non-cutting
           * tangency case. This is good more than 80% of the time.
           */

          if (num_candidates)
            (*num_candidates)++;

          if (intobj_loc->props & EMSintobj_nonoriented)
            {
            if (num_eligible)
              (*num_eligible)++;
            if (intobj_next == intobj_loc)
              intobj_next = intobj_loc->next;
            EMdelintobj (&msg_loc, intobj_loc);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

            num_deleted++;
            }
          }

        else if (criterion == chk_redundant)
          {
          /*
           * This candidate becomes eligible if it is first of all
           * geometrically degenerate and then topological redundant. The
           * check fo that redundancy is inside the following function.
           * If found redundant, the action to delete it is also performed
           * inside.
           */

          if (num_candidates)    
            (*num_candidates)++;

          if (intobj_loc->props & EMSintobj_xyzdegenerate)
            {
            delredundant (&msg_loc, intobj_loc, intos, uvlentol, &intobj_next, 
             &num_eligible_loc);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            if (num_eligible)
              *num_eligible += num_eligible_loc;

            num_deleted += num_eligible_loc;
            }
          }

        else if (criterion == chk_noconnect)
          {
          /*
           * This candidate is investigated for having end-conditions
           * relative to other intobjs end-condition that indicate that
           * they should not be strung together in a set, even though
           * they are geometrically contiguous. That is, a break needs to
           * be introduced.
           */

          if (num_candidates)    
            (*num_candidates)++;
          chknoconnect (intobj_loc, uvlentol, &num_eligible_loc);
          if (num_eligible)
            *num_eligible += num_eligible_loc;
          }
 
        else if (criterion == chk_opporiented)
          {
          /*
           * The function call below locates all coincident intobjs just 
           * as in the case of chk_dupsamesurf. The actoptions argument
           * indicate that the members of the pair, if found, oppositely
           * oriented must have their non-oriented property set. No
           * deletion of intobjs takes place here.
           */

          delsfintdup (&msg_loc, mattyp, mat, num_samplepts,
           lentol, intobj_loc, &intobj_next, 
           EMSfixsfint_act_setnonorient, B_checkpresent, B_checkabsent,
           inters_loc1, &num_candidates_loc, &num_eligible_loc);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          if (num_candidates)    
            *num_candidates += num_candidates_loc;
          if (num_eligible)
            *num_eligible += num_eligible_loc;
          }

        else if (criterion == chk_midptcoinc)
          {
          /*
           * The function call below locates the intobjs that have an end-point
           * coincidence with the middle region of intobj_loc. The actoptions
           * argument indicates whether the intobj_loc is required to be split
           * at this point or not.
           */

          midptcoinc (&msg_loc, mattyp, mat, uvlentol, lentol,
           intobj_loc, &intobj_next, actoptions & EMSfixsfint_act_splitinters,
           B_checkpresent, B_checkabsent, inters_loc1,
           &num_candidates_loc, &num_eligible_loc);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          if (num_candidates)    
            *num_candidates += num_candidates_loc;
          if (num_eligible)
            *num_eligible += num_eligible_loc;
          }

        Next1:
        intobj_loc = intobj_next;
        }
      inters_loc1 = inters_loc1->next;
      }

    /*
     * Now process the intobjs to look for criterion that related to
     * pairs formed across surfaces. This is done in the following
     * while-loop.
     */

    inters_loc1 = inx == 0 ? *inters1 : *inters2;
    while (inters_loc1)
      {
      intobj_loc = inters_loc1->cvs;
      while (intobj_loc)
        {
        intobj_next = intobj_loc->next;

        /*
         * Do the candidacy check for the first of the pair.
         * The B_checkpresent and B_checkabsent is applied within the
         * inner loop.
         */

        is_candidate = 
             (A_checkpresent ? 
              (intobj_loc->props & A_checkpresent) == A_checkpresent : TRUE) &&
             (A_checkabsent ? 
              !(intobj_loc->props & A_checkabsent) : TRUE);
        if (! is_candidate)
          goto Next2;

        if (criterion == chk_dupothersurf)
          {
          /*
           * Loop over all the other surfaces and call the function that
           * checks if an intobj is coincident with any in the given
           * linked list of intobjs. The rest is quite similar to the
           * processing for chk_dupsamesurf. The clearing of the property
           * that indicates that there is a potential duplicate on the
           * other surface is deferred until all the surfaces have been
           * processed. This deferring is done to ensure that all duplicates
           * related to any of the markings are processed.
           */

          inters_loc2 = inx == 0 ? *inters1 : *inters2;
          while (inters_loc2)
            {
            if (inters_loc2 != inters_loc1)
              {
              delsfintdup (&msg_loc, mattyp, mat, 
               num_samplepts, lentol, intobj_loc, &intobj_next, 
               actoptions, B_checkpresent, B_checkabsent,
               inters_loc2, &num_candidates_loc, &num_eligible_loc);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
              if (num_candidates)    
                *num_candidates += num_candidates_loc;
              if (num_eligible)
                *num_eligible += num_eligible_loc;
        
              if (delopt)
                num_deleted += num_eligible_loc;

              if (num_eligible_loc && (actoptions & EMSfixsfint_act_delmarked))
                break;
              }
            inters_loc2 = inters_loc2->next;
            }
          }

        Next2:
        intobj_loc = intobj_next;
        }
      inters_loc1 = inters_loc1->next;
      }

    /*
     * Post process each intobj in the intersection list.
     */

    inters_loc1 = inx == 0 ? *inters1 : *inters2;
    while (inters_loc1)
      {
      intobj_loc = inters_loc1->cvs;
      while (intobj_loc)
        {
        if (criterion == chk_dupsamesurf)
          {
          if (actoptions & EMSfixsfint_act_delunmarked)
            {
            /* 
             * Since all the coincidences, w.r.t this intobj_loc would have
             * been processed, and those that are true duplicates have
             * been removed, turn this property off (the 'unmarked' intobjs
             * of the pairs found have been deleted, hence there would be
             * no "duplicates" of this intobj_loc left on this surface).
	     */
             intobj_loc->props &= ~EMSintobj_dupthissurf;
            }
          }
  
        else if (criterion == chk_dupothersurf)
          {
          if (actoptions & EMSfixsfint_act_delunmarked)
            {
            /* 
             * By similar reasoning as above, we should be turning the
             * dupothersurf property off.
             */

            if (actoptions & EMSfixsfint_act_delunmarked)
              intobj_loc->props &= ~EMSintobj_dupothersurf;
            }
          }

        intobj_loc = intobj_loc->next;
        }
      inters_loc1 = inters_loc1->next;
      }
    }
 
  /*
   * Check if any of the intersection lists have ended up containing 
   * zero number of EMSintobj nodes. Remove such EMSinters nodes and
   * if this leaves a list empty, flag this occurence in an appropriate
   * return code.
   */

  if (num_deleted)
    {
    for (inx=0; inx<2; inx++)
      {
      EMcmpinters (&msg_loc, inx == 0 ? inters1 : inters2);
      if (msg_loc == EMS_I_NoMore)
        *msg = msg_loc;
      }
    }    

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMfixsfintout");
  return (stat_OM);
}



/*
  ABSTRACT

    This function takes in an EMSintobj node and an EMSinters node. It
    determines if the EMSintobj node overlaps any of the EMSintobjs in
    the input EMSinters node. If so, deletes one or both of them based
    on the actoption flags. An overlap is construed if EMSintobj is a 
    subset of one of the EMSinters' nodes or if one of the EMSinter's nodes
    is a subset of the input EMSintobj. The number of sampling points
    used to determine overlap is also specified.
*/

static void delsfintdup (msg, mattyp, mat, num_samplepts, lentol, intobj,
                         intobj_next, actoption, 
                         B_checkpresent, B_checkabsent,
                         inters, num_candidates, num_eligible)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
IGRint num_samplepts;
IGRdouble lentol;
struct EMSintobj *intobj, **intobj_next;
IGRushort actoption;
IGRulong B_checkpresent, B_checkabsent;
struct EMSinters *inters;
IGRint *num_candidates, *num_eligible;
{
  IGRboolean coincident, terminate, intobj_samplepts_obtd;
  IGRboolean some_atmiddle, opposite_flow=FALSE;
  IGRint i, inx, inxlim, numelig;
  IGRlong msg_loc, stat_OM;
  IGRdouble intobj_samplepts[MAX_NUM_SAMPLEPTS+2][3];
  IGRdouble inters_samplepts[MAX_NUM_SAMPLEPTS+2][3];
  IGRdouble degentol, mindist[MAX_NUM_SAMPLEPTS+2];
  IGRdouble *samplepts;
  GRspacenum intos;
  struct IGRbsp_curve xyzcv;
  struct EMSpypoint projpts[MAX_NUM_SAMPLEPTS+2];
  struct EMSintobj *intobj_loc, *intobj_loc_next;
  struct EMSintobj *intobj_proj, *intobj_del, *intobj_sample;
  extern void EMdelintobj(), BSsfptseval(), BSsfkttol2();
  extern IGRint EMinternalpt(), EMprojectpt(), EFget_clipped_edge_type();
  extern void EFkeep_correct_intobj();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_candidates = 0;
  *num_eligible = 0;

  xyzcv.poles = NULL;
  xyzcv.knots = NULL;
  xyzcv.weights = NULL;
 
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, degentol);

  intobj_samplepts_obtd = FALSE;
  intobj_loc = inters->cvs;
  intos = inters->this_obj.osnum;
  terminate = FALSE;
  numelig = 0;
  while (intobj_loc && !terminate)
    {
    intobj_loc_next = intobj_loc->next;
    /* added another condition inside the if statement. Since our code allows
     * intersections between surfaces of the SAME inters list, then what may
     * happen in "dupother" mode is that "intobj_loc" may very well be the 
     * "other_intobj_node" of the incoming "intobj". Trap this. (NP 12/24/93).
     */
    if ((intobj_loc != intobj) && (intobj_loc->other_intobj_node != intobj) && 
        (B_checkpresent ? 
         (intobj_loc->props & B_checkpresent) == B_checkpresent : TRUE) &&
        (B_checkabsent ? 
         !(intobj_loc->props & B_checkabsent) : TRUE))
      {
      (*num_candidates)++;

      /*
       * Obtain sample points on the pair being checked for
       * duplicity.
       */

      if (!intobj_samplepts_obtd)
        {
        stat_OM = EMinternalpt (&msg_loc, mattyp, mat, &intobj->this_xyzintobj,
                   EMScvint_middle, num_samplepts, intobj_samplepts);
        EMerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        intobj_samplepts_obtd = FALSE;
        }
  
      stat_OM = EMinternalpt (&msg_loc, mattyp, mat,
                 &intobj_loc->this_xyzintobj, EMScvint_middle, num_samplepts,
                 inters_samplepts);
      EMerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      /*
       * Determine coincidence if any
       */

      inxlim = num_samplepts+1;
      for (i=0; i<inxlim; i++)
        projpts[i].next = &projpts[i+1];
      projpts[inxlim].next = NULL;

      for (inx=FIRST; inx<=SECOND; inx++)
        {
        coincident = TRUE;
        if (inx == FIRST)
          {
          samplepts = (IGRdouble *) inters_samplepts;
          intobj_sample = intobj_loc;
          intobj_proj = intobj;
          }
        else
          {
          samplepts = (IGRdouble *) intobj_samplepts;
          intobj_sample = intobj;
          intobj_proj = intobj_loc;
          }
  
        /*
         * Project the sample points onto the element, obtaining 
         * minimum distance information and also the topological position
         * of the minimum distance point (among other things).
         */

        stat_OM = EMprojectpt (&msg_loc, mattyp, mat, 
                   &intobj_proj->this_xyzintobj, num_samplepts, samplepts,
                   degentol, projpts, mindist);
        EMerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  

        /*
         * If any of the minimum distances is greater than the specified
         * tolerance, no coincidence has occurred. Also, if none of
         * the sample points lie in the "middle" of the element it implies
         * that one of the elements is degenerate w.r.t. the specified
         * tolerance and lies at the endpoints of the other. In this case,
         * a condition of no-coincidence is construed.
         *
         * Since the time the above condition was put in, it has been
         * experienced that in the case of degeneracy as described above,
         * an intersection object having NULL-edges as incident-edges at
         * it's end points needs to be treated as coincident. Thus, 
         * eliminating spurious degenerate pieces produced due to tolerance
         * problems, which can only cause failure. On the other hand, if
         * such degenerate pieces have non-NULL-edge information at both
         * ends, their existence is valid and not spurious.
         *
         * 10/21/88:
         * It so came to pass that the previous criteria too fell short of
         * a good one. The new criteria is encoded in the local function -
         * deldgncoinc. See the function for explanation.
         */

        some_atmiddle = FALSE;
        for (i=0; i<num_samplepts; i++)
          {
          if (mindist[i] > lentol)
            {
            coincident = FALSE;
            break;
            }
          if (projpts[i].props & EMS_PYPT_ATMIDDLE)
            some_atmiddle = TRUE;
          }
        
        /*
         * It is not sufficient for the minimum distances to be within
         * tolerance. Atleast one of the projected points must be
         * in the midddle. Now, if the minimum distance criteria is
         * is satisifed and all the points are at the end, then this can
         * because of two reasons - 1) because the sample intobj is 
         * degenerate or 2) because the sample intobj is not degenerate
         * but is yet smaller than the tolerance being used to check
         * for coincidence. In the former case we need to investigate
         * further whether a coincidence needs to be construed (deldgncoinc)
         * and in the latter we must conclude that no coincidence is
         * present.
         */

        if (coincident)
          {
          if (intobj_sample->props & EMSintobj_xyzdegenerate)
            {
            if (!deldgncoinc (intobj_sample, intobj_proj, intos))
              coincident = FALSE;
            }
          else 
            {
            if (!some_atmiddle) 
              coincident = FALSE;
            }
          }

        /*
         * If there has been any coincidence, break out  of the search
         * for coincidence.
         */

        if (coincident)
          break; 
        }
  
      if (coincident)
        {
        /*
         * Process the action-options. 
         * 1) In the case where the options specify, deletion for the intobjs,
         *    honor it here.
         * 2) In the case of "check opposite orientation", when two
         *    non-degenerate coincident, intobjs are found to be flowing in
         *    opposite directions, both of them are marked as non-oriented.
         */

        if (actoption & 
            (EMSfixsfint_act_delmarked | EMSfixsfint_act_delunmarked))
          {
          (*num_eligible)++;

          for (inx=FIRST; inx<=SECOND; inx++)
            {
            if (inx == FIRST && actoption & EMSfixsfint_act_delmarked)
              intobj_del = intobj;
            else if (inx == SECOND && actoption & EMSfixsfint_act_delunmarked)
              intobj_del = intobj_loc;
            else
              intobj_del = NULL;

            if (intobj_del)
              {
              if (*intobj_next == intobj_del)
                *intobj_next = intobj_del->next;
              if (intobj_loc_next == intobj_del)
                intobj_loc_next = intobj_del->next;
              /* This next statement is due to the fact that our code  allows 
               * intersection between surfaces on the same inters list.Therefore
               * in "dupother" mode, when we check for duplicates on other
               * surfaces of incoming "intobj"'s inters list, the "other_intobj"
               *  of the duplictate intobj could very well be the incoming 
               * "intobj_next". Trap this situation. (NP 12/24/93).
               */
              if (*intobj_next == intobj_del->other_intobj_node)
                *intobj_next = intobj_del->other_intobj_node->next;
              EMdelintobj (&msg_loc, intobj_del);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
              if (intobj_del == intobj)
                terminate = TRUE;
              }
            }
          }

        else if (actoption & EMSfixsfint_act_setnonorient &&
                 !(intobj->props & EMSintobj_xyzdegenerate) &&
                 !(intobj_loc->props & EMSintobj_xyzdegenerate))
          {
          (*num_eligible)++;

          if (projpts[FIRST].span_inx + projpts[FIRST].param >
              projpts[SECOND].span_inx + projpts[SECOND].param)
            opposite_flow = TRUE;
          else
            opposite_flow = FALSE;
	  if (intobj->reversed)
            opposite_flow = !opposite_flow;
          if (intobj_loc->reversed)
            opposite_flow = !opposite_flow;

          if (opposite_flow)
            {
               EFkeep_correct_intobj(&msg_loc, NULL, mattyp, mat, &lentol, 
                                      intobj, intobj_loc); 
               EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
            }
          }
        }
      }
    intobj_loc = intobj_loc_next;
    }

ret_end:
  if (xyzcv.poles)
    om$dealloc (ptr = xyzcv.poles);
  if (xyzcv.knots)
    om$dealloc (ptr = xyzcv.knots);
  if (xyzcv.weights)
    om$dealloc (ptr = xyzcv.weights);

  EMWRAPUP (*msg, stat_OM, "delsfintdup");
  return;
}

/* DESCRIPTION: 
 * This function takes in two intobjs that are oppositely oriented on a surface.
 * The function will determine which of the two intobjs needs to be deleted
 * (or rather marked non-oriented for deletion later) or whether BOTH need to be
 * deleted. Simply put, if both the non-oriented intobjs lie in the MIDDLE of a 
 * surface, then it is a truly non-manifold situation (such as a wedge lying on
 * a block with only line contact) then our solution is to delete BOTH the 
 * intobjs. However, if the intersection in on an edge of a surface AND that 
 * edge has no common edge (happens in features such as ribs, where we intersect
 * rib surfaces individually with solids) then the function determines which of 
 * the two intobjs is to be deleted. Since there are TWO intersections on this 
 * surface (intobj1 and intobj2), the two other surfaces involved are checked to * see which of them will produce the correct intersection.
 */
  
#argsused
static void EFkeep_correct_intobj(EFmsg, options, mattyp, mat, altxyztol, 
                                  intobj1, intobj2)
IGRlong *EFmsg, options;
IGRdouble *mat, *altxyztol;
IGRshort *mattyp;
struct EMSintobj *intobj1, *intobj2;
{

/* steps:
 * -----
 * NOTE: This algorithm is based on the assumtion that the intobjs have been 
 *       created as part of a UNION or DIFFERENCE operation. The only difference
 *       if the operation is INTERSECTION is to switch the intobj deletion
 *       criteria at the very end. i.e. if intobj1 has been deemed to be deleted
 *       or marked non-oriented using the algorithm below (which is written for
 *       UNION), then if it is an INTERSECTIOIN case, we delete intobj2 instead.
 *       Sometime later we should define an option taht will indicate the type
 *       of the boolean operation that created these intobjs.
 *
 * 1. Get the edge that is coincident with the intobjs.
 *
 * 2. Consider the three surfaces involved.
 *    S - This surface (on which intobj1 and intobj2 lie)
 *    S1- Surface that produced intobj1
 *    S2- Surface that produced intobj2
 *
 *    Get unit tangents to each of these surfaces. Do this by getting the unit 
 *    tangents to the corresponding edges, getting correponding NATURAL normals
 *    and taking the cross-product.
 *
 * 3. Take dot products S.S1 and S.S2
 *
 * 4. The larger dot product (due to smaller angle and hence closer surface)
 *    defines the surface that defines correct orientation of an intobj on S for
 *    the given operation. Currently we will ASSUME this as being the UNION 
 *    operation, but later we may have to pass in an option that will let us
 *    decide the dominant surface based upon it.
 *
 * 5. Keep the intobj corresponding to the dominant surface. Mark the other as
 *    non-oriented.
 */

  BSrc rc;
  IGRlong msg_loc, sts, i;
  struct GRid coinc_edgeid, this_sf, other_sf1, other_sf2, other_ed1, other_ed2;
  struct GRid *edid, *sfid;
  OM_S_CHANSELECT chan_to_common;
  OMuint count;
  struct GRmd_env modenv;
  struct IGRbsp_curve coinc_ed_geom;
  struct IGRbsp_surface *sfgeom;
  struct EMSdataselect geom;
  GRspacenum thisos;
  IGRpoint ref_pt, sfpt;
  IGRvector tangent1, tangent2, tangent3, natnorm1, natnorm2, natnorm3;
  IGRvector *tangent, *natnorm, sftangent1, sftangent2, sftangent3;
  IGRdouble xyztol, dotprod1, dotprod2;

  extern void EFget_coincident_edge();
  extern IGRlong EMgetabsg();
  extern void EMgetsfnorm();
  extern IGRboolean BSmdistptsf(), BScrossp();
  extern IGRdouble BSdotp();
  extern IGRint EMgetvggeom();

  *EFmsg = EMS_S_Success;
  sts    = OM_S_SUCCESS;

  thisos = intobj1->this_obj_node->this_obj.osnum; 

  /* INITIALIZATIONS */
  coinc_ed_geom.weights = NULL;
  coinc_ed_geom.poles   = NULL;
  coinc_ed_geom.knots   = NULL;
  coinc_ed_geom.bdrys   = NULL;
  sfgeom                = NULL;
  

  if (altxyztol)
    xyztol = *altxyztol;
  else
  { BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyztol);
  }

  coinc_edgeid.osnum = thisos;
  EFget_coincident_edge (&msg_loc, NULL, mattyp, mat, NULL, altxyztol, intobj1, 
                         &coinc_edgeid.objid);
  EMerr_hndlr (!(1&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

  /* If the intobj does not lie on an edge, then the correct solution in this
   * true non-manifold case in which the oppositely-oriented intobjs lie in the
   * middle of the surface is to mark both the intobjs as non-oriented and exit.
   */
  if (msg_loc == EMS_I_NotFound)
  {
    intobj1->props |= EMSintobj_nonoriented;
    intobj2->props |= EMSintobj_nonoriented;
#ifdef DEBUG
    printf("Not on edge..delete both\n");
#endif
  }
  else
  {
    /* check if this edge has a common edge. If there IS a common edge and hence
     * a common surface, the correct solution is to mark BOTH the incoming 
     * intobjs as non-orientable. Otherwise, we follow the steps defined above.
     */
  
    EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
    count = 0;
    om$get_channel_count (objid = coinc_edgeid.objid,  
                          p_chanselect = &chan_to_common, count = &count);
  
    if (count)
    {
      intobj1->props |= EMSintobj_nonoriented;
      intobj2->props |= EMSintobj_nonoriented;
#ifdef DEBUG
    printf("Common edge exists..delete both\n");
#endif
    }
    else 
    {
      this_sf = intobj1->this_obj_node->this_obj;
  
      EMerr_hndlr(!intobj1->other_intobj_node || !intobj2->other_intobj_node,
                   *EFmsg, EMS_E_Fail, wrapup);
      other_sf1 = intobj1->other_intobj_node->this_obj_node->this_obj;
      other_sf2 = intobj2->other_intobj_node->this_obj_node->this_obj;
  
      /* now get the edges from the other_sf1 and other_sf2 that are coincident 
       * with "coinc_edge".
       */
  
      other_ed1.osnum = thisos;
      EFget_coincident_edge(&msg_loc, NULL, mattyp, mat, NULL, altxyztol, 
                             intobj1->other_intobj_node, &other_ed1.objid);
      EMerr_hndlr (!(1&msg_loc) || (msg_loc == EMS_I_NotFound), 
                     *EFmsg, EMS_E_Fail, wrapup);
  
      other_ed2.osnum = thisos;
      EFget_coincident_edge(&msg_loc, NULL, mattyp, mat, NULL, altxyztol, 
                             intobj2->other_intobj_node, &other_ed2.objid);
      EMerr_hndlr (!(1&msg_loc) || (msg_loc == EMS_I_NotFound), 
                     *EFmsg, EMS_E_Fail, wrapup);
  
      /* Get all three tangents (coinc_edge, other_ed1, other_ed2).
       * Since only the "md_env" field of the "modenv" struct is used by the 
       * EMtangent method, we set the "md_id" to NULL_OBJID.This should be fine.
       * Also, we should calculate the tangents at the SAME point for all three
       * surfaces/edges. Use the midpt of coinc_edge as the ref. point.
       */
      modenv.md_env.matrix_type = *mattyp;
      OM_BLOCK_MOVE(mat, modenv.md_env.matrix, sizeof (IGRmatrix));
      modenv.md_id.objid = NULL_OBJID;
      modenv.md_id.osnum = OM_Gw_current_OS;
  
      coinc_ed_geom.weights = NULL;
      coinc_ed_geom.poles   = NULL;
      coinc_ed_geom.knots   = NULL;
      coinc_ed_geom.bdrys   = NULL;
  
      sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
                              &(modenv.md_env), &this_sf, NULL, 0,
                              MAXINT, FALSE, NULL, &coinc_ed_geom),
                        targetid = coinc_edgeid.objid,
                        targetos = coinc_edgeid.osnum,
                        senderid = NULL_OBJID);
      EMerr_hndlr(! (1 & sts & msg_loc), *EFmsg, EMS_E_EdgeError, wrapup);
  
      /* find the midpt of the edge. This will be the reference point for ALL 
       * the three tangents.
       */
  
      geom.datatype   = EMSdata_curve3d;
      geom.data.curve = &coinc_ed_geom;
  
      sts = EMinternalpt (&msg_loc, mattyp, mat, &geom, EMScvint_middle, 
                             1, (IGRdouble *)ref_pt);
      EMerr_hndlr(! (1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup);
  
  
      for (i=0; i<3; i++)
      {
        if (i==0)
          {sfid = &this_sf;   tangent = &tangent1; edid = &coinc_edgeid;}
        else if (i==1)
          {sfid = &other_sf1; tangent = &tangent2; edid = &other_ed1;}
        else
          {sfid = &other_sf2; tangent = &tangent3; edid = &other_ed2;}
  
        sts = om$send (msg = message EMSedge.EMtangent (&msg_loc, &modenv, 
                                   &(sfid->objid), ref_pt, 1.0, NULL, *tangent),
                        targetid = edid->objid,
                        targetos = edid->osnum,
                        senderid = NULL_OBJID);
        EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_EdgeError, wrapup);
  
      }
  
      /* Now get all three NATURAL normals (this_sf, other_sf1/2) at the SAME 
       * ref_pt. Since we are getting abstract geometry, we need not free it.
       */
      for (i=0; i<3; i++)
      {
        if (i==0)
          {natnorm = &natnorm1; sfid = &this_sf;}
        else if (i==1) 
          {natnorm = &natnorm2; sfid = &other_sf1;}
        else 
          {natnorm = &natnorm3; sfid = &other_sf2;}
  
        sfgeom = NULL;
/*******
        sts =  EMgetabsg(&msg_loc, mattyp, mat, sfid->osnum, sfid->objid, 
                         (IGRchar **)&sfgeom);
        EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_SurfaceError, wrapup);
*******/   
        sts = EMgetvggeom(&msg_loc,mattyp,mat,sfid,(IGRchar **)&sfgeom,NULL);
        EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_SurfaceError, wrapup);
 
        (void) EMgetsfnorm (&msg_loc, sfgeom, ref_pt, sfpt, *natnorm, NULL);
        EMerr_hndlr(!(1&msg_loc), *EFmsg, EMS_E_SurfaceError, wrapup);

        if (sfgeom)
          {om$dealloc(ptr = sfgeom); sfgeom=NULL;}
      }
   
  
      /* Get the inward surface tangent at the ref point, for each of the three
       * surfaces. Since the tangents calc. above are ALONG the direction of the
       * boundary, the cross product of the tangent with the NATURAL normal will
       * give us the required INWARD surface tangent (TxN). Make sure that all 
       * the * above are unit vectors.
       */
  
       MAunitvc( &msg_loc, tangent1, tangent1);
       MAunitvc( &msg_loc, tangent2, tangent2);
       MAunitvc( &msg_loc, tangent3, tangent3);
       MAunitvc( &msg_loc, natnorm1, natnorm1);
       MAunitvc( &msg_loc, natnorm2, natnorm2);
       MAunitvc( &msg_loc, natnorm3, natnorm3);
  
       BScrossp(&rc,tangent1,natnorm1,sftangent1);
       BScrossp(&rc,tangent2,natnorm2,sftangent2);
       BScrossp(&rc,tangent3,natnorm3,sftangent3);
  
       /* now we need to find that surface which is closest to this_sf.Therefore
        * the surface whose tangent makes the largest dot product with 
        * sftangent1 is the one we need.Accordingly, the intobj created by that
        * surface is the one that is correctly oriented.Therefore mark the 
        * intobj created by the other surface as non-oriented (to be deleted 
        * later).
        */
  
       dotprod1 = BSdotp (&rc, sftangent1, sftangent2);
       dotprod2 = BSdotp (&rc, sftangent1, sftangent3);
  
       EMerr_hndlr(dotprod1 == dotprod2, *EFmsg, EMS_E_Fail, wrapup);
  
       if (dotprod1 > dotprod2)
         intobj2->props  |= EMSintobj_nonoriented;
       else
         intobj1->props  |= EMSintobj_nonoriented;
     }

  }/*else*/  
  
wrapup:

  if (coinc_ed_geom.weights)
    {om$dealloc(ptr=coinc_ed_geom.weights);}
  if (coinc_ed_geom.poles)
    {om$dealloc(ptr=coinc_ed_geom.poles);}
  if (coinc_ed_geom.knots)
    {om$dealloc(ptr=coinc_ed_geom.knots);}
  if (coinc_ed_geom.bdrys)
    {om$dealloc(ptr=coinc_ed_geom.bdrys);}
  if (sfgeom)
    {om$dealloc(ptr=sfgeom);}

  EMWRAPUP (*EFmsg, sts, "EFkeep_correct_intobj");
}

/*
 * This is a locally used function in delsfintdup, which encodes the
 * criteria for determining whether a given degenerate intobj, coincident
 * with another intobj at it's end-point, should be "kept" or treated as a
 * duplicate and thus deleted. Such a coincidence cannot be resolved
 * by geometric checks alone. The predisposition is to call the degenerate
 * piece non-coincident or unique; but there are circumstances when such
 * an intobj is indeed a duplicate or spurious intersection, topologically 
 * speaking.
 */

static IGRboolean deldgncoinc (intobj_dgn, intobj_proj, intos)
struct EMSintobj *intobj_dgn, *intobj_proj;
GRspacenum intos;
{
  IGRboolean this_on_null, other_on_null, delete;
  GRobjid edid_dgn, next_edid_dgn, edid_proj, next_edid_proj;
  GRobjid other_edid_dgn, other_next_edid_dgn;
  struct EMSsfintedpar *edinfo_dgn, *edinfo_proj, *other_edinfo_dgn;
  struct EMSintobj *other_intobj_dgn=NULL;
  enum EMScvinttype edloc_dgn, next_edloc_dgn;
  enum EMScvinttype edloc_proj, next_edloc_proj;
  extern IGRboolean EMis_sametopology();

  delete = FALSE;

  /*
   * For a topological check the topological information must be
   * present on the degenerate edge. If it isn't, accept the coincidence.
   */

  edinfo_dgn = (struct EMSsfintedpar *) intobj_dgn->more_info;
  if (!edinfo_dgn || intobj_dgn->props & EMSintobj_nontriminfo)
    {
    delete = TRUE;
    goto ret_end;
    }

  /*
   * If the topological information of the intobj-pair (or of the singleton)
   * suggests that there is no incident edge on both ends, they are topological
   * orphans and cannot negate their geometric coincidence on the strength of 
   * topology.
   */

  edid_dgn = edinfo_dgn->edgeid;
  next_edid_dgn = edinfo_dgn->next->edgeid;
  this_on_null = IF_NULL_OBJID (edid_dgn) ||
                 IF_NULL_OBJID (next_edid_dgn);

  other_intobj_dgn = intobj_dgn->other_intobj_node;
  if (!other_intobj_dgn)
    other_on_null = TRUE;
  else
    {
    other_edinfo_dgn = (struct EMSsfintedpar *) other_intobj_dgn->more_info;
    if (!other_edinfo_dgn || other_intobj_dgn->props & EMSintobj_nontriminfo)
      other_on_null = TRUE;
    else
      {
      other_edid_dgn = other_edinfo_dgn->edgeid;
      other_next_edid_dgn = other_edinfo_dgn->next->edgeid;
      other_on_null = IF_NULL_OBJID (other_edid_dgn) ||
                      IF_NULL_OBJID (other_next_edid_dgn);
      }
    }
  
  if (this_on_null && other_on_null)
    {
    delete = TRUE;
    goto ret_end;
    }
 
  /*
   * If projection-intersection is also degenerate, check if one is 
   * a topological duplicate of the other.
   */

  if (intobj_proj->props & EMSintobj_xyzdegenerate &&
      (intobj_proj->more_info && 
       !(intobj_proj->props & EMSintobj_nontriminfo)))
    {
    if (IF_EQ_OBJID 
         (intobj_proj->this_obj_node->this_obj.objid,
          intobj_dgn->this_obj_node->this_obj.objid))
      {
      edloc_dgn = edinfo_dgn->intloc;
      next_edloc_dgn = edinfo_dgn->next->intloc;

      edinfo_proj = (struct EMSsfintedpar *) intobj_proj->more_info;
      edid_proj = edinfo_proj->edgeid;
      edloc_proj = edinfo_proj->intloc;
      next_edid_proj = edinfo_proj->next->edgeid;
      next_edloc_proj = edinfo_proj->next->intloc;

      if ((EMis_sametopology (edloc_proj, edid_proj, 
                              edloc_dgn, edid_dgn, intos, NULL) ||
           EMis_sametopology (edloc_proj, edid_proj, 
                              next_edloc_dgn, next_edid_dgn, intos, NULL)) &&
          (EMis_sametopology (next_edloc_proj, next_edid_proj, 
                              edloc_dgn, edid_dgn, intos, NULL) ||
           EMis_sametopology (next_edloc_proj, next_edid_proj, 
                              next_edloc_dgn, next_edid_dgn, intos, NULL)))
        {
        delete = TRUE;
        goto ret_end;
        }
      }
    }

ret_end:
  /*
   * The following logic is to take care of flagging an otherwise
   * non-deletable degenerate intersection as deletable if there
   * isn't a single corresponding non-deletable "project" intobj
   * encountered by it. In other words, if the degenerate intobj
   * is geometrically coincident with only deletable intobjs, then
   * the degenerate intobj must be deleted, regardless. A marked
   * degenerate-intobj indicates that it has been found to be coincident
   * w.r.t to a deletable intobj.
   */

  if (!delete)
    {
    if (!other_intobj_dgn)
      other_intobj_dgn = intobj_dgn;

    if (! (intobj_dgn->props & EMSintobj_deletable &&
          !(intobj_dgn->props & EMSintobj_marked)) &&
        ! (other_intobj_dgn->props & EMSintobj_deletable &&
          !(other_intobj_dgn->props & EMSintobj_marked)))
      {
      if (intobj_proj->props & EMSintobj_deletable)
        {
        if (!(intobj_dgn->props & EMSintobj_marked))
          {
          intobj_dgn->props |= (EMSintobj_deletable | EMSintobj_marked);
          other_intobj_dgn->props |= (EMSintobj_deletable | EMSintobj_marked);
          }
        }
      else
        {
        if (intobj_dgn->props & EMSintobj_marked)
          {
          intobj_dgn->props &= ~EMSintobj_deletable;
          other_intobj_dgn->props &= ~EMSintobj_deletable;
          }
        }
      }
    }
  return (delete);
}  



/*
   ABSTRACT

     This function takes in an EMSintobj node and it determines if the 
     EMSintobj node is topologically redundant. If so, deletes it. This 
     function is assuming that the input intobj is degenerate. A redundancy 
     can then be construed:

     o If the incident edge information for both the ends of this intersection
       point is topologically equivalent (same edge or the same vertex).
     o If the incident information for either of the ends is topologically
       equivalent to an incident edge information for any other intobj
       on this surface.
*/

static void delredundant (msg, intobj, intos, uv_chktol, intobj_next, eligible)
IGRlong *msg;
struct EMSintobj *intobj, **intobj_next;
IGRdouble uv_chktol;
GRspacenum intos;
IGRint *eligible;
{
  IGRboolean redundant=FALSE;
  IGRint i, j;
  IGRlong msg_loc, stat_OM;
  struct EMSintobj *intobj_loc;
  struct EMSsfintedpar *endinfo[2], *endinfo_loc[2];
  extern void EMdelintobj();
  extern IGRboolean EMgive_endinfo(), EMis_sametopology();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  *intobj_next = intobj->next;
  *eligible = 0;

  EMerr_hndlr (!intobj->more_info || intobj->props & EMSintobj_nontriminfo ||
               !(intobj->props & EMSintobj_xyzdegenerate),
   *msg, EMS_I_NotFound, ret_end);

  /*
   * This intobj is trivially redundant if the two endpoints of this
   * intobj are topological equivalent.
   */

  EMgive_endinfo (intobj, &endinfo[FIRST], &endinfo[SECOND]);
  redundant = EMis_sametopology (
               endinfo[FIRST]->intloc, endinfo[FIRST]->edgeid,
               endinfo[SECOND]->intloc, endinfo[SECOND]->edgeid, intos, 
               NULL);

  /*
   * If this intobj is also degenerate in uv, then one can also look
   * for redundancy if any of the two endpoints of this intobj
   * are topologically equivalent to an endpoint of any other intobj within
   * this surface. The thinking here is that the split that would have been
   * performed by the degenerate intobj is going to be performed by this
   * other intobj found, and therefore makes the existence of the degenerate
   * intobj redundant.
   */

  if (intobj->props & EMSintobj_uvdegenerate)
    {
    for (intobj_loc = intobj->this_obj_node->cvs;
         intobj_loc;
         intobj_loc = intobj_loc->next)
      {
      if (intobj_loc != intobj)
        {
        if (! EMgive_endinfo (intobj_loc,
               &endinfo_loc[FIRST], &endinfo_loc[SECOND]))
          continue;

        for (i=FIRST; i<=SECOND; i++)
          for (j=FIRST; j<=SECOND; j++)
            if (EMis_sametopology (
                 endinfo[i]->intloc, endinfo[i]->edgeid,
                 endinfo_loc[j]->intloc, endinfo_loc[j]->edgeid, intos, 
                 NULL) &&
                EMis_geomequal_2dpt (
                 endinfo[i]->point, endinfo_loc[j]->point, uv_chktol))
              redundant = TRUE;
        } 
      }
    }

  /*
   * If found redundant, delete the intobj.
   */

  if (redundant)
    {
    EMdelintobj (&msg_loc, intobj);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    (*eligible)++;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "delredundant");
  return;
}


/*
  ABSTRACT

    This function takes in an EMSintobj node and it determines if any
    end-point of this node lies at a vertex. If found so, sets the noconnect
    property so that this will not connect up with another intobj within
    this uv-space. But this function will not override any connectivity
    relationship already present.
*/

#argsused
static void chknoconnect (intobj, tol, eligible)
struct EMSintobj *intobj;
IGRdouble tol;
IGRint *eligible;
{
  IGRboolean num_proc;
  IGRint i;
  struct EMSsfintedpar *endinfo[2];
  extern IGRboolean EMis_onvertex(), EMgive_endinfo();

  /*
   * Obtain end-information of the input intobj 
   */

  if (intobj->props & EMSintobj_nontriminfo )
    goto ret_end;
   
  if (! EMgive_endinfo (intobj, &endinfo[FIRST], &endinfo[SECOND]))
    goto ret_end;

  /*
   * Check each end as lying on a vertex or not. If found so, set that
   * particular end to no-connect in uv-space to any other intobj (by
   * setting the property-bit and setting the appropriate fwd/bwd pointer to
   * NULL).
   */

  num_proc = FALSE;
  for (i=FIRST; i<=SECOND; i++)
    if (EMis_onvertex (endinfo[i]->intloc, endinfo[i]->edgeid))
      {
      if (i == FIRST && !intobj->bwd)
        intobj->props |= EMSintobj_bwd_noconnectuv;
      else if (i == SECOND && !intobj->fwd)
        intobj->props |= EMSintobj_fwd_noconnectuv;

      num_proc = TRUE;
      }

  *eligible = num_proc ? 1 : 0;

ret_end:
  return;
}

/*
  ABSTRACT

    This function checks for candidate intobjs in the inters node supplied
    that have an end-point of theirs that is coincident with the MIDDLE of
    the input intobj. If one such candidate is found eligible NO MORE
    search is carried out. If the option to split is set then the intobj_loc
    is split at this coincident point and the intobj_next updated to reflect
    the first of this pair so that a subsequent call can find other eligibles
    with the split intobjs.
*/

static void midptcoinc (msg, mattyp, mat, uvlentol, xyzlentol, 
                        intobj, intobj_next, 
                        to_split,
                        B_checkpresent, B_checkabsent, inters,
                        num_candidates, num_eligible)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
IGRdouble uvlentol, xyzlentol;
struct EMSintobj *intobj, **intobj_next;
IGRboolean to_split;
IGRulong B_checkpresent, B_checkabsent;
struct EMSinters *inters;
IGRint *num_candidates, *num_eligible;
{
  IGRboolean coincident, terminate;
  IGRint i, j, stat_func;
  IGRlong msg_loc;
  IGRdouble mindist;
  IGRpoint endpt, myendpt;
  struct GRmdenv_info mdenv_info;
  struct EMSpypoint projpt;
  struct EMSintobj *intobj_loc;
  extern IGRboolean EMis_geomequal_3dpt();
  extern IGRint EMinternalpt(), EMprojectpt();

  *msg = EMS_S_Success;

  *num_candidates = 0;
  *num_eligible = 0;

  intobj_loc = inters->cvs;
  terminate = FALSE;
  coincident = FALSE;

  while (intobj_loc && !terminate)
    {
    if (intobj_loc != intobj && 
        (B_checkpresent ? 
         (intobj_loc->props & B_checkpresent) == B_checkpresent : TRUE) &&
        (B_checkabsent ? 
         !(intobj_loc->props & B_checkabsent) : TRUE))
      {
      (*num_candidates)++;

      /*
       * Obtain end-point of the intobj_loc and check if it lies in the
       * middle of the input intobj. Double check this result by examining
       * in XYZ-space, whether the endpoint is at an endpoint. If the latter
       * is true, override the idea that this incidence is in the middle.
       */

      for (i=START; i<=STOP; i++)
        {
        EMinternalpt (&msg_loc, NULL, NULL, &intobj_loc->this_uvintobj,
         i == START ? EMScvint_lfend : EMScvint_rtend, 1, endpt);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        EMprojectpt (&msg_loc, NULL, NULL, &intobj->this_uvintobj, 1,
         endpt, uvlentol, &projpt, &mindist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        if (mindist < uvlentol && projpt.props & EMS_PYPT_ATMIDDLE)
          {
          coincident = TRUE;

          EMinternalpt (&msg_loc, mattyp, mat, &intobj_loc->this_xyzintobj,
           i == START ? EMScvint_lfend : EMScvint_rtend, 1, endpt);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

          for (j=START; j<=STOP; j++)
            {
            EMinternalpt (&msg_loc, mattyp, mat, &intobj->this_xyzintobj,
             j == START ? EMScvint_lfend : EMScvint_rtend, 1, myendpt);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
 
            if (EMis_geomequal_3dpt (endpt, myendpt, xyzlentol))
              {
              coincident = FALSE;
              break;
              }
            }

          if (coincident)
            break;
          }
        }

      if (coincident)
        {
        (*num_eligible)++;

        /*
         * In the case where a split of the intobj is desired, perform this
         * action. The intobj_next output argument is updated to reflect
         * the first of the resultant pair. In this case this pointer is
         * the same as intobj itself (a la behaviour of split_intobj function).
         */

        if (to_split)
          {
          mdenv_info.matrix_type = *mattyp;
          OM_BLOCK_MOVE (mat, mdenv_info.matrix, sizeof (IGRmatrix));
          
          EMsplit_sf_intobj_uv (&msg_loc, EMSintobj_split_ignoreconnect,
           &mdenv_info, intobj, &projpt, NULL, NULL);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

          *intobj_next = intobj;
          }
 
        /*
         * In this implementation we will look only for ONE eligibility.
         * Once found, we can quit this function.
         */

        terminate = TRUE;
        }
      }
    intobj_loc = intobj_loc->next;
    }

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "midptcoinc");
  return;
}

end implementation Root;


