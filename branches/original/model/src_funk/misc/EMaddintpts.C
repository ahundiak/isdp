/*

  HISTORY

    4/13/93  NP  If the midpt of an xyz segment is being introduced into the
                 linestring of intersection data, but the pt is  NOT lying on 
                 the surface, then subsiture it with the nearest pt that 
                 actually lies on the surface.
                 Also, a check is added to print a message to the screen if 
                 this routine adds even a single pt to the intersection data. 
                 When math returns correct linestrings, we should not have to
                 add ANY points to the data.
    4/21/93  NP  Error out if new points are introduced & if the global 
                 variable "_allow_intersection_fixing" is false.
                 

  RETURN VALUES
                 
    EMS_S_Useless -
     All went well but this call was a no-op.
    EMS_S_Success -
     All went well with this call having added points.

    EMS_E_BSerror - 
     Math Error
    EMS_E_Fail -
     Points need to be added, but restricted by the global flag.
    EMS_E_NoSolution - 
     Mid-point of an xyz-segment did not lie on the surface or,
     the data is such that even MAX_ADDPTS number of
     insertions will not achieve the desired results.
     UPDATE: Midpt of xyz segment will be forced to lie on surface. Therefore
             "EMS_E_NoSolution" error will be produced only in the latter case.
                                                                 NP 4/13/93
    EMS_E_NoDynamicMemory - 
     Just what it says
*/

#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdebug.h"

/*
 * This is the parameter on the uv-line segment at which the surface is
 * evaluated in order to test if this model-space point does lies within
 * chord-height tolerance of the corresponding xyz-line segment. If not,
 * then another uv-point is introduced within this uv-line segment which
 * is the parametric evaluation of the mid-point of xyz-line segment.
 */

#define TEST_PARAM 0.45

/*
 * The maximum number of points that may be added into the incoming
 * set of points. This limit is imposed to prevent the function from
 * going into an infinite loop when the data itself is "corrupt"
 */

#define MAX_ADDPTS 1000


#define  FIRST  0
#define  SECOND 1

#define U 0
#define V 1

#define X 0
#define Y 1
#define Z 2

extern IGRboolean _allow_intersection_fixing;

void EMaddintpts (msg, srf1, srf2, num_grps, numpts_grp, 
                  xyzpts, uvpts1, uvpts2, options)
IGRlong *msg;
struct IGRbsp_surface *srf1, *srf2;
IGRlong num_grps, *numpts_grp;
IGRdouble **xyzpts, **uvpts1, **uvpts2;
IGRshort  options;

{
  IGRboolean stat_func, needs_checking[2], onsrf;
  IGRchar *tempptr;
  IGRshort dim;
  IGRint i, j, k, curr_inx, srfinx, dirinx, sideinx;
  IGRint inxlim, inxfact, numaddpts;
  IGRlong msg_loc;
  IGRlong dummy_stat;
  IGRdouble tol, tolsq;
  IGRdouble *xyzseg, *uv1seg, *uv2seg, uvpt1[2], uvpt2[2], xyzpt[3];
  IGRdouble lengthsq[2], seglensq, *poles;
  struct IGRbsp_surface *srf;
  extern void BSsfeval();
  extern IGRboolean BSprptonsf();
  void EMinsertpts();
  IGRdouble EMmdistptseg();

  *msg = EMS_S_Useless;

  numaddpts = 0;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tol);
  tolsq = tol * tol;

  if (options & EMS_O_No_SfCheck)
    {
    /*
     * The caller wants to insert points irrespective of the 
     * type of the surface. So skip the check for type of surface. -- RC
     */

    needs_checking[FIRST] = srf1 ? TRUE : FALSE;
    needs_checking[SECOND] = srf2 ? TRUE : FALSE;
    }
  else
    {
    /*
     * Determine if any of these surfaces warrant an "add-points" on their
     * intersections. This preliminary determination is done by the
     * following criteria, which if satisfied, indicates further 
     * checking is warranted:
     *   i) The surface is planar and rational,
     *  ii) The surface is planar,  non-rational and length along u=0 is not
     *      equal to length along u=1 or the length along v=0 is not equal
     *      to length along v=1.
     */

    for (srfinx=FIRST; srfinx<SECOND+1; srfinx++)
      {
      needs_checking[srfinx] = FALSE;
      if (!(srf = (srfinx == FIRST ? srf1 : srf2)) || !srf->planar)
        continue;
      else if (srf->rational)
        {
        needs_checking[srfinx] = TRUE;
        continue;
        }

      for (dirinx=U; dirinx<V+1; dirinx++)
        {
        if (dirinx == U)
          {
          inxlim = srf->u_num_poles - 1;
          inxfact = 3;
          }
        else
          {
          inxlim = srf->v_num_poles - 1;
          inxfact = srf->u_num_poles * 3;
          }

        for (sideinx = FIRST; sideinx<SECOND+1; sideinx++)
          {
          lengthsq[sideinx] = 0.0;
          if (dirinx == U)
            poles = (sideinx == FIRST ? 
                     srf->poles :
                     &srf->poles[(srf->u_num_poles * (srf->v_num_poles-1))*3]);
          else
            poles = (sideinx == FIRST ? 
                     srf->poles :
                     &srf->poles[(srf->u_num_poles-1)*3]);
          for (i=0, j=0, k=inxfact; i<inxlim; i++, j+=inxfact, k+=inxfact)
            lengthsq[sideinx] += 
                ((poles[k] - poles[j]) * (poles[k] - poles[j]) +
                 (poles[k+1] - poles[j+1]) * (poles[k+1] - poles[j+1]) +
                 (poles[k+2] - poles[j+2]) * (poles[k+2] - poles[j+2]));
          } 
  
        if (fabs (lengthsq[FIRST] - lengthsq[SECOND]) > tolsq)
          {
          needs_checking[srfinx] = TRUE;
          break;
          }
        }
      } 
    }

  /*
   * The surface that needs checking has it's uv-linestring segments,
   * iteratively evaluated at their mid-points. If the model-space point
   * so obtained, is off the model-space linestring by more than chord-height
   * tolerance, a new intersection point is generated and added. This point
   * is the evaluation at the mid-point of the model-space line-segment.
   * All the three sets of data - xyzpts, uvpts1 and uvpts2 are updated.
   * If uvpts2 is NULL, this part is left alone.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, tol);
  tol += MINDOUBLE;
  for (srfinx=FIRST; srfinx<SECOND+1; srfinx++)
    {
    if (needs_checking[srfinx])
      {
      if (srfinx == SECOND)
        {
        tempptr = (IGRchar *) srf1;
        srf1 = srf2;
        srf2 = (struct IGRbsp_surface *) tempptr;

        tempptr = (IGRchar *) uvpts1;
        uvpts1 = uvpts2;
        uvpts2 = (IGRdouble **) tempptr;        
        }

      for (i=0; i<num_grps; i++)
        {
        curr_inx = 0;
        numaddpts = 0; 
        do
          {
          xyzseg = &xyzpts[i][curr_inx*3];
          uv1seg = &uvpts1[i][curr_inx*2];
          if (uvpts2)
            uv2seg = &uvpts2[i][curr_inx*2];

          uvpt1[U] = uv1seg[U] + TEST_PARAM * (uv1seg[2+U] - uv1seg[U]);
          uvpt1[V] = uv1seg[V] + TEST_PARAM * (uv1seg[2+V] - uv1seg[V]);

          BSsfeval (srf1, uvpt1[U], uvpt1[V], 0, xyzpt, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          if (sqrt (EMmdistptseg (&msg_loc, xyzseg, &xyzseg[3], xyzpt,
               3, NULL, &seglensq, NULL)) > tol && 
              sqrt (seglensq) > tol)
            {
            xyzpt[X] = xyzseg[X] + 0.5 * (xyzseg[3+X] - xyzseg[X]);
            xyzpt[Y] = xyzseg[Y] + 0.5 * (xyzseg[3+Y] - xyzseg[Y]);
            xyzpt[Z] = xyzseg[Z] + 0.5 * (xyzseg[3+Z] - xyzseg[Z]);

            stat_func = BSprptonsf (&msg_loc, srf1, xyzpt, &uvpt1[U], 
                         &uvpt1[V], &onsrf);
            EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
           
            if (!onsrf)
              {
              BSsfeval (srf1, uvpt1[U], uvpt1[V], 0, xyzpt, &msg_loc);
              EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
              }
   
            if (srf2 && uvpts2)
              {
              stat_func = BSprptonsf (&msg_loc, srf2, xyzpt, &uvpt2[U],
                           &uvpt2[V], &onsrf);
              EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
              }

            EMinsertpts (&msg_loc, dim = 3, 1, xyzpt, curr_inx+1, 
             numpts_grp[i], &xyzpts[i]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

            EMinsertpts (&msg_loc, dim = 2, 1, uvpt1, curr_inx+1, 
             numpts_grp[i], &uvpts1[i]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

            if (uvpts2)
              {
              EMinsertpts (&msg_loc, dim = 2, 1, uvpt2, curr_inx+1, 
               numpts_grp[i], &uvpts2[i]);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
              }

            numpts_grp[i]++;
            numaddpts++;
            }
          else
            curr_inx++;
          }
        while (curr_inx < numpts_grp[i]-1 && numaddpts <= MAX_ADDPTS);
        EMerr_hndlr (numaddpts > MAX_ADDPTS, *msg, EMS_E_NoSolution, ret_end);
        } 
      }
    }

  EMerr_hndlr (numaddpts && !_allow_intersection_fixing, *msg, EMS_E_Fail,
   ret_end);

  DEBUG_REPORT (numaddpts, "EMaddintpts", numaddpts, NULL);
  if (numaddpts)
    *msg = EMS_S_Success;

ret_end:
  dummy_stat = TRUE;
  EMWRAPUP (*msg, dummy_stat, "EMaddintpts");
}
