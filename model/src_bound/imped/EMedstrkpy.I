/*
  DESCRIPTION

    This method returns the geometry of this edge stroked to within chord-
    height of it's model space counterpart. A linear edge is stroked further
    only if it is an ISO-edge. A natural edge is stroked to within cht in xyz.
    And a bs-edge is stroked in xyz. The output geometry of this method is in
    xyz and/or uv.

    When the EMS_GETB_COMPATIBLEXYZ option is used, this method will return
    the xyz data solely from the non-subordinate edges out of the pair of
    common edges. Otherwise it is always the polyline xyz counterpart of this
    edge

    The option EMS_GETB_COMPATIBLEUV, will return uv data that contains
    the same number of points as the non-subordinate, polylined edge will
    have. Otherwise it is always the polyline uv geometry of this edge (natural
    edge and iso-edges will return their two-point geometry. The option
    EMS_GETB_STROKEISO can be used to force the iso-edge to be stroked).

    The option EMS_GETB_CONSISTLFXYZVTX / EMS_GETB_CONSISTRTXYZVTX will obtain
    the end-points of the xyz-geometry requested as the end-point of the
    edge with the largest objid out of the many edges that terminate at this
    vertex.

    The option EMS_GETB_CONSISTLFUVVTX / EMS_GETB_CONSISTRTUVVTX will obtain
    the end-points of the uv-geometry requested as the end-point of the
    edge with the largest objid out of the two edges that terminate at this
    vertex.

    The first call to this method must initialize the output arguments
    to NULLS. All memory is allocated inside the call to this method.

  BUGS

    The technique used here to obtain compatible uv is brute force and
    can be made more efficient in the future by special casing. The current
    code gives the worst case performance.

  HISTORY
    NP       :  03/09/93  : Insufficient memory was being allocated in two
                            places for "locuvpts".
    NP       :  12/01/92  : Modified to return TWO points for a degenerate edge
                            instead of one.
    NP/SS    :  08/26/91  : Modified to allow reduction of points on
		            stroked edges, within chord-height.
    SS       :  06/14/90  :  Creation. Initial stuff from EMedpack
    Sudha       06/04/93    modified to include BSprototype header files

*/

class implementation EMSedge;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfeval.h"
#include "bsmdstptscv.h"
#include "bscvarreval.h"
#include "bschtptstcv.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/eded.h"

#define NATEDGE  0
#define LINEDGE  1
#define ISOEDGE  2
#define BSEDGE   3

#define U 0
#define V 1

#define FIRST  0
#define SECOND 1

#define LEFT  0
#define RIGHT 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSnatedge_class_id, OPP_EMSbsedge_class_id;
extern GRclassid OPP_EMSlinedge_class_id, OPP_EMSptedge_class_id;

from GRvg import GRgenabsg;

method EMgetstrkpy (IGRlong *msg;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct IGRbsp_surface *srfgeom;
                    struct EMSpartolbasis *partolbas;
                    IGRushort options;
                    IGRint *num_xyzpts, *num_uvpts;
                    IGRdouble **xyzpts, **uvpts)
{
  IGRboolean oncrv, reversed, gotxyzcv, primrtend, xyz_reduced, *edrtends;
  IGRshort edtype, *indexarray;
  IGRushort ed_props, nxted_props;
  IGRint i, j, inx, num_internal, blksize, u, v ;
  IGRint nump_xyz=0, nump_uv=0, commed_exists, count, dumint;
  IGRlong msg_loc, stat_OM, msg_loc_dum;
  IGRdouble (*locxyzpts)[3], (*locuvpts)[2], *params, uv2pts[2][2];
  IGRdouble *ptr, (*ptr3)[3], *myupars, uvendpt[2], chttol;
  IGRpoint xyzendpt;
  GRobjid srfid, myfulled, nxtedge, primedge, *vtxedges;
  GRclassid myfulled_class;
  struct IGRpolyline uvpy, dumpy;
  struct IGRbsp_curve xyzcv, uvcv, myxyzcv;
  struct IGRbsp_surface *locsrfgeom;
  struct GRmdenv_info mdenv_info;
  OM_S_CHANSELECT chan_to_common;
  OM_S_OBJECT_LINKAGE objlink;
  extern void EMfixendjumps(), EMcnvtpypts(), EMrevpyline();
  extern IGRlong EMgetnxtedges(), EFsspbtol_by_geom();
  extern void EFreduce_pts(), EFcompress_array();

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  if (xyzpts)
    *xyzpts = NULL;
  if (uvpts)
    *uvpts = NULL;
  if (num_xyzpts)
    *num_xyzpts = 0;
  if (num_uvpts)
    *num_uvpts = 0;

  uvpy.points = NULL;
  xyzcv.poles = NULL;
  xyzcv.knots = NULL;
  xyzcv.weights = NULL;
  uvcv.poles = NULL;
  uvcv.knots = NULL;
  uvcv.weights = NULL;
  myxyzcv.poles = NULL;
  myxyzcv.knots = NULL;
  myxyzcv.weights = NULL;
  locxyzpts = NULL;
  locuvpts = NULL;
  params = NULL;
  vtxedges = NULL;
  edrtends = NULL;
  myupars = NULL;

  mdenv_info.matrix_type = *mattyp;
  OM_BLOCK_MOVE (mat, mdenv_info.matrix, sizeof (IGRmatrix));
  uvpy.num_points = 0;
  ed_props = ME.EMSedge->ed_props;

  /*
   * All the following logic assumes that there are basically
   * 4 kinds of edges to deal with:
   * 1) Natural edge
   * 2) Linear edge
   * 3) Iso edge
   * 4) BS-edge
   * First determine the kind of edge this is.
   */

  if (ed_props & EMED_ISO)
    edtype = ISOEDGE;
  else if (ed_props & EMED_NATURAL)
    edtype = NATEDGE;
  else
    {
    myfulled = pwGetEdOfPartEd (my_id, OS);
    OnErrorState (myfulled == PW_K_NullObjid, *msg, EMS_E_EdgeError,
     ret_end);

    stat_OM = om$get_classid (objid = myfulled, p_classid = &myfulled_class);
    EMomerr_exit (stat_OM, ret_end);

    if (myfulled_class == OPP_EMSlinedge_class_id)
      edtype = LINEDGE;
    else if (myfulled_class == OPP_EMSbsedge_class_id)
      edtype = BSEDGE;
    else if (myfulled_class == OPP_EMSnatedge_class_id)
      edtype = NATEDGE;
    else if (myfulled_class == OPP_EMSptedge_class_id)
      edtype = LINEDGE;
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}
    }

  /*
   * Obtain the relevant xyz-polyline geometry. Only in the case where solely
   * uvpts have been asked for and this happens to be a LINEDGE we do not
   * need to get xyzpts.
   */
  xyz_reduced = FALSE;
  gotxyzcv = FALSE;
  reversed = FALSE;
  if (ed_props & EMED_SUBORDINATE)
    {
    if (uvpts && options & EMS_GETB_COMPATIBLEUV ||
        xyzpts && options & EMS_GETB_COMPATIBLEXYZ)
      {
      EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);

      stat_OM = om$get_channel_objects (object = me,
                 p_chanselect = &chan_to_common, list = &objlink,
                 size = 1, count = (OMuint *)&commed_exists);
      EMomerr_exit (stat_OM, ret_end);

      if (commed_exists)
        {
        stat_OM = om$send (msg = message EMSedge.EMsendmsg_changing_props
                   (&msg_loc_dum, EMED_DEGENERATE, EMS_O_OFF, 
                    message EMSedge.EMget_bcxyz_geom (&msg_loc,
                    &mdenv_info, NULL, NULL, 0, MAXINT, FALSE, NULL, &xyzcv)),
                   targetid = objlink.S_objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);

        if (ed_props & EMED_REVERSE_CONNECT)
          reversed = TRUE;

        gotxyzcv = TRUE;
        }
      }
    }

  if (!gotxyzcv && (xyzpts || (uvpts && 
                              ((options & EMS_GETB_COMPATIBLEUV &&
                                edtype != LINEDGE) ||
                               (options & EMS_GETB_STROKEISO &&
                                edtype == ISOEDGE)))))
    {
    stat_OM = om$send (msg = message EMSedge.EMsendmsg_changing_props
               (&msg_loc_dum, EMED_DEGENERATE, EMS_O_OFF, 
                message EMSedge.EMget_bcxyz_geom (&msg_loc,
                 &mdenv_info, NULL, NULL, 0, MAXINT, FALSE, NULL, &xyzcv)),
               targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
     ret_end);

    gotxyzcv = TRUE;
    }
  
  if (gotxyzcv)
    {
    if (xyzcv.order == 2)
      {
      nump_xyz = xyzcv.num_poles;
      locxyzpts = (IGRpoint *)xyzcv.poles;
      if (xyzcv.rational)
        for (i=0; i<nump_xyz; i++)
          for (j=0; j<3; j++)
            locxyzpts[i][j] /= xyzcv.weights[i];

      BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
      
      if (options & EMS_GETB_REDUCEDATA)
      {	/** "dim" is hardcoded to 3, 'cos we need xyz (and not uv) points **/
	EFreduce_pts (nump_xyz, 3, locxyzpts, chttol, &indexarray);
	count = nump_xyz;
	EFcompress_array (&nump_xyz, 3, locxyzpts, indexarray);
	if (nump_xyz < count)
	  xyz_reduced = TRUE;
	free (indexarray);
      }/*if*/

      xyzcv.poles = NULL;
      params = xyzcv.knots;
      OM_BLOCK_MOVE (&params[1], params, nump_xyz * sizeof (IGRdouble));
      xyzcv.knots = NULL;
      }
    else
      {
      BSchtptstcv (&xyzcv, &nump_xyz, &locxyzpts, &params, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      /* If math returns a single point due to degeneracy of the edge, then
       * simply duplicate that point, so that we always return AT LEAST two
       * points. Otherwise, FEM has a major problem in triangulation. This fix
       * is for order > 2. However, if the order is 2 for the degenerate XYZ
       * geometry, then the code in the "if" part of this "if-else" above takes
       * care of returning 2 points. So all cases are covered.
       * NP 12/1/92.
       */

      if (nump_xyz ==1)
        { locxyzpts = (IGRdouble (*)[]) om$realloc (ptr = (IGRchar *)locxyzpts,
                    size = 6 * sizeof (IGRdouble));   /* note special cast */
          EMerr_hndlr (!locxyzpts, *msg, EMS_E_NoDynamicMemory, ret_end);
          OM_BLOCK_MOVE( &((*locxyzpts)[0]), &((*locxyzpts)[3]),
                                                  3 * sizeof(IGRdouble));
          params = (IGRdouble *) om$realloc (ptr = (IGRchar *)params,
                                     size = 2 * sizeof (IGRdouble));
          EMerr_hndlr (!params, *msg, EMS_E_NoDynamicMemory, ret_end);

          /* set the parameters */
          params[0] = 0.0;
          params[1] = 1.0;

          nump_xyz = 2;
        }
      }

    if (reversed)
      {
      dumpy.num_points = nump_xyz;
      dumpy.points = (IGRdouble *)locxyzpts;
      EMrevpyline (&msg_loc, &dumpy, 3, NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      dumpy.points = params;
      EMrevpyline (&msg_loc, &dumpy, 1, NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }

  /*
   * Obtain the relevant uv-polyline geometry. For optimization and/or
   * compatibility the uv-geometry is obtained through different means.
   */

  if (uvpts)
    {
    nump_uv = 0;
    if (options & EMS_GETB_COMPATIBLEUV || 
        (options & EMS_GETB_STROKEISO && edtype == ISOEDGE))
      {
      if ((options & EMS_GETB_COMPATIBLEUV && ed_props & EMED_SUBORDINATE) ||
	   xyz_reduced )
        {
        num_internal = nump_xyz - 2;
        if (num_internal)
          {
          if (!srfgeom)
            {
            stat_OM = om$send (msg = message EMSedge.EMgetsurface_info
                       (&msg_loc, &srfid, NULL), targetid = my_id);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
             ret_end);

            stat_OM = om$send (msg = message GRvg.GRgenabsg (&msg_loc, mattyp,
                       mat, (IGRchar **)&locsrfgeom), targetid = srfid);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
             ret_end);
            }
          else
            locsrfgeom = srfgeom;

          stat_OM = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
                     &mdenv_info, NULL, locsrfgeom, 0, MAXINT, FALSE, NULL,
                     &myxyzcv), targetid = my_id);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
           ret_end);

          blksize = nump_xyz * (sizeof (IGRdouble) +
                                sizeof (IGRpoint) +
                                sizeof (IGRdouble));
          myupars = (IGRdouble *)om$malloc (size = blksize);
          EMerr_hndlr (!myupars, *msg, EMS_E_NoDynamicMemory, ret_end);

          BSmdstptscv (nump_xyz, locxyzpts, &myxyzcv, myupars,
           (IGRpoint *)&myupars[nump_xyz], &myupars[nump_xyz + nump_xyz*3],
           &oncrv, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
          }

        stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc, 0,
                   MAXINT, FALSE, NULL, &uvcv, partolbas, NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);

        locuvpts = (IGRdouble (*)[]) om$malloc (size = nump_xyz * 3 *
                    sizeof (IGRdouble ));

        EMerr_hndlr (!locuvpts, *msg, EMS_E_NoDynamicMemory, ret_end);
        ptr3 = (IGRpoint *)locuvpts;

        if (num_internal)
          {
          BScvarreval (&msg_loc, &uvcv, &myupars[SECOND], num_internal, 0,
           ptr3[SECOND]);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
          }

        if (uvcv.rational)
          {
          inx = 0;
          uvcv.poles[inx] /= uvcv.weights[inx];
          uvcv.poles[inx+1] /= uvcv.weights[inx];
          inx = uvcv.num_poles-1;
          uvcv.poles[inx * 3] /= uvcv.weights[inx];
          uvcv.poles[inx * 3 + 1] /= uvcv.weights[inx];
          }

        OM_BLOCK_MOVE (uvcv.poles,
         ptr3[FIRST], sizeof (IGRpoint));
        OM_BLOCK_MOVE (&uvcv.poles[(uvcv.num_poles-1)*3], 
         ptr3[nump_xyz-1], sizeof (IGRpoint));
        EM3dto2d (locuvpts, nump_xyz);
        nump_uv = nump_xyz;
        }
      else if (edtype == BSEDGE)
        {
        stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc, 0,
                   MAXINT, FALSE, NULL, &uvcv, partolbas, NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);

        locuvpts = (IGRdouble (*)[]) om$malloc (size = nump_xyz * 3 *
                    sizeof (IGRdouble));
        EMerr_hndlr (!locuvpts, *msg, EMS_E_NoDynamicMemory, ret_end);

        BScvarreval (&msg_loc, &uvcv, params, nump_xyz, 0, (IGRdouble *)locuvpts);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
        EM3dto2d (locuvpts, nump_xyz);
        nump_uv = nump_xyz;
        }
      else if (edtype == NATEDGE || edtype == ISOEDGE)
        {
        locuvpts = (IGRdouble (*)[]) om$malloc (size = nump_xyz * 2 *
                    sizeof (IGRdouble));
        EMerr_hndlr (!locuvpts, *msg, EMS_E_NoDynamicMemory, ret_end);

        uvpy.points = (IGRdouble *)uv2pts;
        stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc, 0,
                   MAXINT, FALSE, NULL, &uvpy, partolbas, NULL),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);
        uvpy.points = NULL;
        
        ptr = (IGRdouble *)locuvpts;
        for (i=0, u=0, v=1; i<nump_xyz; i++, u+=2, v+=2)
          {
          ptr[u] = uv2pts[FIRST][U] +
                    params[i] * (uv2pts[SECOND][U] - uv2pts[FIRST][U]);
          ptr[v] = uv2pts[FIRST][V] +
                    params[i] * (uv2pts[SECOND][V] - uv2pts[FIRST][V]);
          }
        nump_uv = nump_xyz;
        }
      }

    if (!nump_uv)
      {
      stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc, 0,
                 MAXINT, FALSE, NULL, &uvpy, partolbas, NULL),
                 targetid = my_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
       ret_end);
      locuvpts = (IGRdouble (*)[])uvpy.points;
      uvpy.points = NULL;
      nump_uv = uvpy.num_points;
      }
    }

  /*
   * Unless computation of "dominant" end-points of the geometries has been
   * restricted, get these end-points and replace existing uv and/or xyz
   * end-points by these. The "dominant" end-point is taken to be the 
   * end-point of the edge with the highest objid-number.
   */

  if (uvpts)
    {
    for (inx=LEFT; inx<=RIGHT; inx++)
      {
      if (inx == LEFT ? options & EMS_GETB_CONSISTLFUVVTX :
                        options & EMS_GETB_CONSISTRTUVVTX)
        {
        stat_OM = EMgetnxtedges (&msg_loc, NULL, my_id, OM_Gw_current_OS, 
                   inx == LEFT ? FALSE : TRUE, 1, &count,
                   &nxtedge, &nxted_props, &dumint);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

        if (nxtedge > my_id)
          {
          stat_OM = om$send (msg = message EMSedge.EMendpts (&msg_loc,
                     inx == LEFT ? NULL : uvendpt,
                     inx == LEFT ? uvendpt : NULL,
                     NULL, NULL, NULL), targetid = nxtedge);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          OM_BLOCK_MOVE (uvendpt, locuvpts[inx == LEFT ? 0 : nump_uv],
           2 * sizeof (IGRdouble));
          }
        }
      }
    }

  if (xyzpts)
    {
    for (inx=LEFT; inx<=RIGHT; inx++)
      {
      if (inx == LEFT ? options & EMS_GETB_CONSISTLFXYZVTX :
                        options & EMS_GETB_CONSISTRTXYZVTX)
        {
	count = 0;
        stat_OM = om$send (msg = message EMSedge.EMgetvtxedges (&msg_loc,
                   NULL, inx == LEFT ? FALSE : TRUE, 0,
                   &count, &vtxedges, &edrtends),
                   targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
         ret_end);

        if (count)
          {
          primedge = vtxedges[FIRST];
          primrtend = edrtends[FIRST];
          for (i=0; i<count; i++)
            if (vtxedges[i] > primedge)
              {
              primedge = vtxedges[i];
              primrtend = edrtends[i];
              }

          stat_OM = om$send (msg = message EMSedge.EMgetsurface_info (&msg_loc,
                     &srfid, NULL), targetid = primedge);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
           ret_end);

          stat_OM = om$send (msg = message GRvg.GRgenabsg (&msg_loc, mattyp,
                     mat, (IGRchar **)&locsrfgeom), targetid = srfid);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError,
           ret_end);

          stat_OM = om$send (msg = message EMSedge.EMendpts (&msg_loc,
                     primrtend ? NULL : uvendpt,
                     primrtend ? uvendpt : NULL,
                     NULL, NULL, NULL), targetid = primedge);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          if (uvendpt[U] < 0.0)
            uvendpt[U] = 0.0;
          if (uvendpt[U] > 1.0)
            uvendpt[U] = 1.0;
          if (uvendpt[V] < 0.0)
            uvendpt[V] = 0.0;
          if (uvendpt[V] > 1.0)
            uvendpt[V] = 1.0;
          BSsfeval (locsrfgeom, uvendpt[U], uvendpt[V], 0, (IGRpoint *)xyzendpt, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

          OM_BLOCK_MOVE (xyzendpt, locxyzpts[inx == LEFT ? 0 : nump_xyz-1],
           sizeof (IGRpoint));

          om$dealloc (ptr = vtxedges);
          vtxedges = NULL;
          om$dealloc (ptr = edrtends);
          edrtends = NULL;
          }
        }
      }
    }

  if (xyzpts)
    {
    *xyzpts = (IGRdouble *)locxyzpts;
    *num_xyzpts = nump_xyz;
    locxyzpts = NULL;
    }

  if (uvpts)
    {
    *uvpts = (IGRdouble *)locuvpts;
    *num_uvpts = nump_uv;
    locuvpts = NULL;
    }

ret_end:
  if (uvpy.points)
    om$dealloc (ptr = uvpy.points);
  if (xyzcv.poles)
    om$dealloc (ptr = xyzcv.poles);
  if (xyzcv.knots)
    om$dealloc (ptr = xyzcv.knots);
  if (xyzcv.weights)
    om$dealloc (ptr = xyzcv.weights);
  if (myxyzcv.poles)
    om$dealloc (ptr = myxyzcv.poles);
  if (myxyzcv.knots)
    om$dealloc (ptr = myxyzcv.knots);
  if (myxyzcv.weights)
    om$dealloc (ptr = myxyzcv.weights);
  if (uvcv.poles)
    om$dealloc (ptr = uvcv.poles);
  if (uvcv.knots)
    om$dealloc (ptr = uvcv.knots);
  if (uvcv.weights)
    om$dealloc (ptr = uvcv.weights);
  if (params)
    om$dealloc (ptr = params);
  if (vtxedges)
    om$dealloc (ptr = vtxedges);
  if (edrtends)
    om$dealloc (ptr = edrtends);
  if (locxyzpts)
    om$dealloc (ptr = locxyzpts);
  if (locuvpts)
    om$dealloc (ptr = locuvpts);
  if (myupars)
    om$dealloc (ptr = myupars);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMgetstrkpy")
  return (stat_OM);
}

end implementation EMSedge;
