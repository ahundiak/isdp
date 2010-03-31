/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "emsinterdef.h"   /* EMS_INTER...     */
# include "emsdef.h"        /* MAXINT           */
# include "EMSopt.h"        /* EMS<un>trim...   */
# include "bsisfprtlns.h"   /* BSpartgrp        */

# define INTERSECTION_OPTIONS \
         (EMS_INTER_BDRYISAREA | \
          EMS_INTER_CUTTING | \
          EMS_INTER_STARTPT | \
          EMS_INTER_STOPPT | \
          EMS_INTER_REMZEROEND)

void EFtrimPartingLines(EMmsg, srf_id, md_env, options, numgrps, partgrps)

IGRlong                 *EMmsg;
GRobjid                 srf_id;
struct GRmd_env         *md_env;
IGRushort       options;
IGRint                  *numgrps;
struct BSpartgrp        **partgrps;

/*
Abstract

    This function trims parting lines against the boundaries of
    the given surface object.

Arguments

    srf_id - input
        The id of the surface whose boundaries will be used to
        trim the parting lines.

    md_env - input
        The module environment of the surface.

    options - input (defined in EMSopt.h)
        EMStrimWorldData
        EMStrimParametricData
        (EMSuntrimmed... options are ignored)

    numgrps - output
        The number of parting line groups resulting from the trim.

    partgrps - output
        The parting line groups resulting from the trim operation.

Notes

    This function assumes that the surface is in the current
    object space. This will always be true if the caller is the
    surface whose id is srf_id.

    The memory for the untrimmed parting line are freed by this
    routine after the corresponding trimmed parting lines are
    generated.

History

    30 Aug 1988 AIC  Genesis
    16 Feb 1992 Jack Removed this om$dealloc's of grp since doing this
                     deallocates the whole array rather than just the
                     one slot.  The whole array will get deallocated 
                     after returning from this routine. 
    27 Aug 1992 NP   Modified for ANSI compliance.
*/

{
  IGRlong               sts = OM_S_SUCCESS;
  IGRint                i, j, new_numgrps = 0;
  IGRint                num_bdrys;
  struct IGRpolyline    inpoly2d, inpoly3d, outpoly;
  struct EMSdataselect  ingeom;
  struct EMSpypoint     *bdrys = NULL, *this_bdry;
  struct BSpartgrp      *grp, *nextgrp, *lastgrp = NULL;

  extern void   EMgetactpy(), EMpypoint_free(), EFfixTrimPoints();

  /*
   * Verify input
   */
  if(! *partgrps) { *EMmsg = EMS_I_NoSolution; goto wrapup; }
  if(! (options & (EMStrimWorldData | EMStrimParametricData)))
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }

  /*
   * Initialize
   */
  grp = *partgrps;
  nextgrp = grp->next;
  ingeom.datatype = EMSdata_poly2d;
  ingeom.data.poly = &inpoly2d;

  /*
   * Generate the trim points for each parting line.
   */
  for(i = 0; i < *numgrps; i ++)
  {
    /*
     * Initialize the 2d and 3d polygons.
     */
    inpoly2d.num_points = grp->num;
    inpoly2d.points = (IGRdouble *)grp->par;
    inpoly3d.num_points = grp->num;
    inpoly3d.points = (IGRdouble *)grp->pts;

    /*
     * Get the trim points
     */
    num_bdrys = 0;
    sts = om$send(msg = message EMSsubbs.EMparttrim(EMmsg,
                  &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &ingeom, INTERSECTION_OPTIONS, &num_bdrys,
                  &bdrys, NULL), senderid = srf_id, targetid = srf_id);
    if(! (1 & sts)) goto wrapup;

    /*
     * Fix the trim points
     */
    EFfixTrimPoints(EMmsg, num_bdrys, bdrys, &inpoly3d);

    /*
     * Generate the trimmed parting line
     */
    if(num_bdrys)
    {
      /*
       * Increment the parting line counter by the number of
       * active sections.
       */
      new_numgrps += num_bdrys;

      /*
       * Extract a parting line for each active section.
       */
      for(j = 0, this_bdry = bdrys;
          j < num_bdrys;
          j ++, this_bdry = this_bdry->next->next)
      {
        struct BSpartgrp  *newgrp;

        /*
         * Create a new partgrp (newgrp).
         */
        outpoly.num_points = 0;
        outpoly.points = NULL;
        newgrp = (struct BSpartgrp *)om$malloc(size = sizeof(*newgrp));
        if(options & EMStrimWorldData)
        {
          EMgetactpy(EMmsg, &inpoly3d, 3, this_bdry, &outpoly);
          newgrp->num = outpoly.num_points;
          newgrp->pts = (IGRpoint *) (outpoly.points);
          outpoly.points = NULL;
        }
        else newgrp->pts = NULL;
        if(options & EMStrimParametricData)
        {
          EMgetactpy(EMmsg, &inpoly2d, 2, this_bdry, &outpoly);
          newgrp->num = outpoly.num_points;
          newgrp->par = (BSpair *) (outpoly.points);
        }
        else newgrp->par = NULL;

        /*
         * Insert the new partgrp (newgrp).
         */
        newgrp->next = nextgrp;
        if(lastgrp) lastgrp->next = newgrp;
        else *partgrps = newgrp;
        lastgrp = newgrp;
      }

      /*
       * Free the untrimmed partgrp (grp).
       */
      if(grp->par) om$dealloc(ptr = grp->par);
      grp->par = NULL;
      if(grp->pts) om$dealloc(ptr = grp->pts);
      grp->pts = NULL;

      /*
       * Free the parting line trim information.
       */
      EMpypoint_free(bdrys, MAXINT);
    }
    else /* Parting line group is outside the active surface area */
    {
      /*
       * Remove the current parting line group (grp) from the list.
       */
      if(lastgrp) lastgrp->next = grp->next;
      else *partgrps = nextgrp;

      /*
       * Free the current parting line group (grp).
       */
      if(grp->par) om$dealloc(ptr = grp->par);
      grp->par = NULL;
      if(grp->pts) om$dealloc(ptr = grp->pts);
      grp->pts = NULL;
    }

    /*
     * Set the grp and nextgrp pointers.
     */
    grp = nextgrp;
    if(grp) nextgrp = grp->next;

  } /* for i < *numgrps */

  *numgrps = new_numgrps;
  if(! new_numgrps) *EMmsg = EMS_I_NoSolution;

wrapup:
  EMWRAPUP(*EMmsg, sts, "EFtrimPartingLines")
  return;
}

end implementation EMSsubbs;
