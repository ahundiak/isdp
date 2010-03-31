/*
  OPTIONS

  EMS_O_Majority:
  With this option set, a sliver is construed ONLY when the majority of the
  samplepts yield a point coincidence. This is one way, a spurious sliver
  detection can be avoided when the edge is only 'touching' another edge and
  not really 'overlapping' it. With this latter option, when this edge is
  determined as forming a sliver, only one pair of edges is returned from
  this invocation (this edge with another one in the loopset). Note that it
  is possible though, that this edge may have an overlap with more than
  one edge of the loopset. All such pairs are not returned.

  EMS_O_Stop:
  If this option is set, then this method will return an OM_I_STOP_SENDING,
  thus interrupting the traversal. The message return code will be set to
  EMS_I_Found. Use this option, when you require simply a TRUE/FALSE value
  from the method, as to whether there is a sliver or not.

  num_slivers and sliver_edges can be NULL:
  These output arguments can be NULL. This will be the case when the caller
  is only interested in the return code of whether a sliver was found or not.
  Also, if these arguments are input as NULL, the option EMS_O_Stop gets
  automatically implied.
*/

class implementation EMSedge;

#include "emsdebug.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/cvinternpts.h"
#include "PWapi/edgeom.h"
#include "PWapi/degengm.h"
#include "PWapi/cvlenquery.h"

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_EMSptedge_class_id;

method EMchksliver (IGRlong *msg; IGRushort options;
                    IGRdouble uvtol;
                    IGRint num_samplepts_edge;
                    IGRint *num_slivers;
                    GRobjid (**sliver_edges)[2])
{
  IGRboolean unique;
  IGRint i, k, l, count, blksize, majority_count_down;
  IGRlong msg_loc, stat_OM;
  GRobjid coincedge, (*loc_sliver_edges)[2];
  GRclassid classid;
  struct EMSpartolbasis ptolbas;
  struct PWcvdata eddata;
  struct PWcvpt *uvpts;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$get_classid (object = me, p_classid = &classid);
  if (om$is_ancestry_valid (subclassid = classid, 
       superclassid = OPP_EMSptedge_class_id) == OM_S_SUCCESS ||
      ME.EMSedge->ed_props & EMED_DEGENERATE)
    {
    *msg = EMS_I_Degenerate;
    goto ret_end;
    }

  /*
   * Since further processing depends so much on the edge not being degenerate
   * make a geometric check for this anyway. (The property-bit checked for
   * above is unreliable as it may have been set w.r.t to some other
   * tolerance). More importantly, we have to ensure that the edge can
   * generate atleast 'num_samplepts_edge' unique points on the edge, each 
   * distinct from each other and from the end-points of the edge. In other
   * words the edge must be atleast: (num_samplepts_edge + 1) * lentol, long.
   *
   * In other words, for atleast one sample point to be processed, the edge
   * must be atleast 2 * lentol. If the edge is smaller than this, the edge
   * is summarily rejected as too small. Further, if the length of the edge
   * is now smaller than (num_samplepts_edge + 1) * lentol, then the
   * number of sample-points to be used is reduced so that the criterion can
   * be met.
   */

  msg_loc = PW_GetEdGeomStack (my_id, OS, eddata);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  EMerr_hndlr (pwIsDegenCvdata (&eddata, 2 * uvtol), *msg, EMS_I_Degenerate,
   ret_end);

  if (pwIsDegenCvdata (&eddata, (num_samplepts_edge + 1) * uvtol))
  {
    num_samplepts_edge = (int) (pwCvdataLen (&eddata) / uvtol) - 1;
    EMerr_hndlr (!num_samplepts_edge, *msg, EMS_E_EdgeError, ret_end);
  }

  /*
   * If not other output other than a status is desired, we may as well as
   * stop when a sliver is found.
   */

  if (!num_slivers || !sliver_edges)
    options |= EMS_O_Stop;

  /*
   * Obtain uv-points on this edge internal to it's geometry.
   */
   
  uvpts = (struct PWcvpt *) alloca (num_samplepts_edge * 
           sizeof (struct PWcvpt));
  msg_loc = pwGetCvdataInternalPts (&eddata, num_samplepts_edge, uvtol, uvpts);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  /*
   * At each internal point check if there is a coincidence with
   * any other edge. This could be a point coincidence too (a single
   * touch at this point). If found so and if this is a unique pair of
   * "coincident" edges, output this. If the option EMS_O_Majority is
   * set, then count the number of hits. If this forms a majority, then
   * output the first pair found, if it is unique. If the option EMS_O_Stop
   * is set then return an OM_I_STOP_SENDING to prevent further searches.
   * Also, if the user has hit the "Stop" button during the processing,
   * terminate the processing and return the EMS_I_Interrupt.
   */

  ptolbas.tol = uvtol;
  ptolbas.is_valid = TRUE;
  majority_count_down = (num_samplepts_edge / 2) + 1;
  for (i=0; i<num_samplepts_edge; i++)
    {
    if (IGEstop())
      {
      *msg = EMS_I_Interrupt;
      stat_OM = OM_I_STOP_SENDING;
      goto ret_end;
      }

    coincedge = NULL_OBJID;
    stat_OM = om$send (msg = message EMSedge.EMptcoinc (&msg_loc, uvpts[i].pt,
               &coincedge, NULL, NULL, NULL, &ptolbas), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

    if (msg_loc == EMS_I_Found)
      {
      if (options & EMS_O_Majority && --majority_count_down)
        continue;

      if (num_slivers && sliver_edges)
        {
        loc_sliver_edges = (GRobjid (*)[]) *sliver_edges;

        unique = TRUE;
        for (k=0; k<*num_slivers; k++)
          {
          count = 0;
          for (l=FIRST; l<=SECOND; l++)
            if (my_id == loc_sliver_edges[k][l] ||
                coincedge == loc_sliver_edges[k][l])
              count++;
          if (count > 1)
            {
            unique = FALSE;
            break;
            }
          }

        if (unique)
          {
          blksize = (*num_slivers + 1) * 2 * sizeof (GRobjid);
          if (*num_slivers)
            loc_sliver_edges = (GRobjid (*)[]) om$realloc (ptr = (IGRchar *) 
                                loc_sliver_edges, size = blksize);        
          else
            loc_sliver_edges = (GRobjid (*)[]) om$malloc (size = blksize);
          EMerr_hndlr (!loc_sliver_edges, *msg, EMS_E_NoDynamicMemory, 
           ret_end);

          loc_sliver_edges[*num_slivers][FIRST] = my_id;
          loc_sliver_edges[*num_slivers][SECOND] = coincedge;

          *sliver_edges = loc_sliver_edges;
   
          (*num_slivers)++;
          }
        }

      *msg = EMS_I_Found;
      if (options & EMS_O_Stop)
        stat_OM = OM_I_STOP_SENDING;
      break;
      }
    }

ret_end:
   DEBUG_REPORT (EMSerror (*msg), "EMSedge.EMchksliver", 
    my_id, *msg);
   return (stat_OM);
}

end implementation EMSedge;

