/*
  DESCRIPTION

    This function may be used to take a collection of curves (GRcurve) and to
    output implied area(s) in the form of planar composite curves (a
    planar GRbspline if the area is enclosed by a single curve). The
    area can be computed taking the projections of the curves onto a
    specified plane - P (the natural plane of the set of curves is a special
    case; for this P is input as NULL). A point (or more than one point) is
    input which is known to be definitely in the area that is desired (or
    areas that are desired). These points are actually input in the form
    of borelines which yield the effective area-points as the intersection
    of the boreline with the projection plane - P. 

    In general, self intersections within a curve are not taken into account.
    But, if a single curve is input, intersections with itself are computed
    and search for the enclosed area is carried out. Even if no such
    intersections are found, the curve is processed anyway to see if the
    area criterion is satisfied by the entire curve.

  ARGUMENTS

    msg			- Output: The error/information return code.

    numcvs, cvs		- Input/Output: Number of input curves and the curves
			  themselves. The GRlc_info structure's
                          geom_parms.polygon_inx field is used as output
			  to indicate that a part of this curves contour
			  has been copied for the output area curve. If
                          this field is set to TRUE, then atleast a part has
			  been used up, else it is set to FALSE.

    numareas, areapts	- Input: Number of areas expected as output, with
			  corresponding points in the areas. These points
			  area actually input as borelines. See description
                          above, where,
			   areapts[2I] and areapts[2I+1], 0 < I < numareas.
                          represent the two points of the boreline for
			  the Ith area.

    projplane		- Input: The plane onto which the curves are to be
			  projected for the computation of the area. If
			  set to NULL, the first few poles encountered
			  within the set of curves are used to determine
			  the plane of projection.

    const_list		- Input: All the fields of this structure must
			  be initialized by the caller as if it was being
			  sent for a single B-spline curve GRconstruct.
                          The curve is constructed in the os indicated
                          by const_list->env_info->md_id.osnum. The
                          geometry field is of course manipulated by this
                          function and must be NULL on input. No other
                          field is looked at or manipulated by this function,
                          directly.

    options		- Input: EMmkarea_outside - If this option is set
			   the area computed is the one that is the outermost
			   with respect to the given area-point. The given
			   area point must be outside the area to be output.

    areacvs		- Output: The object-ids of the curves that form
			  the required areas. If any of the areas could
			  not be computed the objid is set to NULL_OBJID.

  RETURN VALUE

    On successful computation of area(s)
      - EMS_S_Success
    If one or more of the areas requested was not found
      - EMS_I_NotFound
    On error
      - EMS_E_...

    If a particular area was not computed correctly, the corresponding
    planar curve object-id will be output as NULL_OBJID.

  NOTES

    This function can output only closed curves.

  HISTORY

    SS  :  05/03/89  :  Creation
    NP  :  05/27/93  :  Changed name of function "EMmkintlist" to the new name
                        "EMmakeintlist" necessitated due to a addition of two
                        new parameters. Right now the new parameters, relating
                        to "curve type" are set to NULL (==> intobj will set 
                        curve_type to "EMfreeform_curve"). 
                        NOTE: TRY AND SET CURVE_TYPE MEANINGFULLY IN THE 
                              MAKEINTLIST FUNCTION. IT SEEMS TO BE AVAILABLE.

    Sudha  06/16/93     Modified for BSprototype ansification
*/

class implementation GRbcsubbc;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "emsinterdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "madef.h"

%safe
#include <math.h>
#include "matypemx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "malnplise.h"
#include "madetplan.h"
#include "bspartofcv.h"
#include "bsfreecv.h"
#include "bscvkttol2.h"
#include "bscvcv_int.h"
#include "bscvarrevt.h"
#include "bsbx2.h"
#include "bsalloccv.h"
static void dumfunc();
%endsafe

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRcompcurve_class_id;

/*
 * Constants used within this file. The names are hopefully
 * self explanatory.
 */

#define X 0
#define Y 1
#define Z 2

#define MY     0
#define OTHER  1

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define XMIN 0
#define YMIN 1
#define ZMIN 2
#define XMAX 3
#define YMAX 4
#define ZMAX 5

#define NUM_STATIC_CVS      10
#define NUM_STATIC_INTPARS   3
#define NUM_STATIC_CVCOMPS   5

#define DEFINITE_SMALLER    -1

#define RAY_DELX 10
#define RAY_DELY 20

#define FACTOR_SMALL_XYZ_LEN  5

#define STARTPAR  0.0
#define STOPPAR   1.0

/*
 * Structure used within this file to store useful information
 * about the curve generated within the course of processing.
 */

struct cvinfo
  {
  IGRint numpars;
  struct GRparms *intpars;
  struct GRparms intparsmem[NUM_STATIC_INTPARS];
  IGRint numcomps;
  OM_S_OBJECT_LINKAGE *comps;
  GRclassid *cvclass;
  OM_S_OBJECT_LINKAGE compsmem[NUM_STATIC_CVCOMPS];
  GRclassid cvclassmem[NUM_STATIC_CVCOMPS];
  };

struct cvintinfo
  {
  GRclassid cvclass;
  IGRint cvinx;
  };


IGRlong EMmkarea (msg, numcvs, cvs, numareas, areapts, projplane, const_list,
                  options, areacvs)
IGRlong *msg;
IGRint numcvs;
struct GRlc_info *cvs;
IGRint numareas;
IGRpoint areapts[];
struct IGRplane *projplane;
struct GRvg_construct *const_list;
IGRushort options;
GRobjid *areacvs;
{
  IGRboolean stat_func, sftrace_malloc, found, atend[2], dumbool, selfoutput;
  IGRboolean **subgrp_rev, ***elem_rev, *grp_closed, **subgrp_closed;
  IGRuchar cvtype;
  IGRushort saveprops, revflag1, revflag2;
  IGRshort four = 4, turn, idmattyp;
  IGRuint numcomps;
  IGRint j, k, inx, inxlim, tempmininx, cvinx, cvinx1, cvinx2;
  IGRint areainx, tryinx, intinfoinx;
  IGRint numocvs, num_grps, *num_subgrps_grp, **num_elems_subgrp;
  IGRlong two = 2, i, blksize, numret, numparsmem, numintpts, numovlpmem, 
          numovlps=0, msg_loc, stat_OM;
  IGRdouble par1, par2;
  IGRdouble *intpts, *intpar[2];
  IGRdouble *intovpts, *intovpar1, *intovpar2, *intovpar3, *intovpar4;
  IGRdouble startpar, stoppar, midpar, minlnpar, mincvpar, tempminpar;
  IGRdouble cvsrange[6], cvmin[3], cvmax[3], knots[4];
  IGRdouble raytol, lentol, colltol, partol, small_lenpar, small_len;
  IGRpoint xyareapt, xform_areapts[2];
  IGRpoint pt, *pts, raypts[2], cvpts[2], turnpts[3];
  IGRpoint planept, normpt, origin, zaxis;
  IGRmatrix idmat;
  GRspacenum cvos, construct_os;
  GRobjid cvobj, obj1, obj2;
  GRobjid *ocvobjs, ocvobjsmem[NUM_STATIC_CVS];
  GRclassid cvclass, *compclass;
  struct cvinfo *cvinfos, *cvinfos_ptr, cvinfosmem[NUM_STATIC_CVS];
  struct GRid *cvid, nullobj;
  struct GRparms *parptr, *mypars, *otpars, temppar;
  struct IGRbsp_curve *cv, *pcv, *projcv, raycv;
  struct EMSinters *cvparts;
  struct EMSintobj *cvintobj, *mincvintobj, ***elems;
  struct EMSdataselect cvintdata;
  struct IGRplane plane, xyplane;
  struct IGRline line;
  struct IGRpolyline py;
  struct GRpost_info post_info;
  struct GRmdenv_info *cvenv, *env1, *env2, env1mem, env2mem;
  struct GRmdenv_info toxypln, toxypln_0z, fromxypln;
  struct GRprops grprops;
  struct cvintinfo *cvintinfos, *cvintinfos_ptr, cvintinfosmem[NUM_STATIC_CVS];
  struct Root_connect_Msg conn_args;
  OM_S_CHANSELECT chan_to_comps, chan_to_owners;
  OM_S_OBJECT_LINKAGE *comps;
  OM_S_MESSAGE messg;
extern void EMtoplnxform() , EMidmatrix() , 
EMmakeintlist() ;
extern void EMswapintobj() , EMsfinttrace() ;
  extern void EMsfinttrace_free(), EMinters_data_free(), EMinters_free();
extern IGRboolean EMget_bounded_line() ;
extern IGRboolean EMcnvtpybsn() , EFproject_curve_onto_plane() ;
  extern IGRshort EMturn();
  extern IGRlong EMmake_chanselect(), EMgetabsg();
  extern IGRlong EFget_the_edge_type_for_an_object();
  extern IGRlong EFget_clipped_edge_type();
  extern IGRlong EFget_classid_for_an_edge_type();
  extern IGRboolean EFget_new_linear_edge_type();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  for (i=0; i<numareas; i++)
    areacvs[i] = NULL_OBJID;
  for (i=0; i<numcvs; i++)
    cvs[i].geom_parms.polygon_inx = FALSE;

  cvinfos = NULL;
  cvintinfos = NULL;
  pcv = NULL;
  mypars = NULL;
  otpars = NULL;
  cvparts = NULL;
  ocvobjs = NULL;
  intpts = intpar[FIRST] = intpar[SECOND] = NULL;
  intovpts = intovpar1 = intovpar2 = intovpar3 = intovpar4 = NULL;
  num_subgrps_grp = NULL;
  num_elems_subgrp = NULL;
  elems = NULL;
  subgrp_rev = NULL;
  elem_rev = NULL;
  grp_closed = NULL;
  subgrp_closed = NULL;
  sftrace_malloc = FALSE;

  cvintdata.datatype = EMSdata_curve3d;
  cvintdata.data.curve = NULL;
  nullobj.objid = NULL_OBJID;
  nullobj.osnum = OM_Gw_current_OS;
  construct_os = const_list->env_info->md_id.osnum;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, colltol);

  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  EMomerr_exit (stat_OM, ret_end);
  stat_OM = EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Obtain the plane for projection, if it has not already
   * been passed in. In this case the projection plane is the 
   * plane defined by the first three non-coincident and non-collinear
   * points that are encountered.
   */

  if (projplane)
    plane = *projplane;
  else
    {
    plane.point = planept;
    plane.normal = normpt;

    found = FALSE;
    for (cvinx=0; cvinx<numcvs; cvinx++)
      {
      cvenv = &cvs[cvinx].module_info.md_env;
      cvid = &cvs[cvinx].located_obj;
      blksize = cvinx ? 2 : 3;
      i = 0;
      j = cvinx ? 1 : 0;
      stat_OM = om$send (msg = message GRvg.EMgetpoles (&msg_loc, 
                               &cvenv->matrix_type, cvenv->matrix, &i,
                               &blksize, turnpts[j], blksize, &numret, 
                               &dumbool),
                         targetid = cvid->objid, targetos = cvid->osnum,
                         senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

      if (cvinx == FIRST && numret < 3)
        continue;
      else
        {
        blksize = 3;
        stat_func = MAdetplane (&msg_loc, (IGRdouble *)turnpts, &blksize, &lentol,
                     &plane);
        if (msg_loc == MASDGENRAT)
          continue;
        EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_MAerror,
         ret_end);
        found = TRUE;
        break;
        }
      }
    if (!found)
      {
      OM_BLOCK_MOVE (turnpts[FIRST], planept, sizeof (IGRpoint));
      normpt[X] = normpt[Y] = 0.0;
      normpt[Z] = 1.0;
      }
    }

  /*
   * The transformations that need to be applied onto the curves in order
   * to project them onto the plane are obtained. First, this matrix is
   * computed wrt a unit environment matrix. If a particular curve's 
   * environment matrix is not identity then this matrix has to be figured
   * into the transform. It's inverse which will transform the curves back to
   * the projection plane is also obtained. These matrices are used in
   * computing the intersections, etc.
   */

  EMidmatrix (&msg_loc, &idmattyp, idmat);
  EMtoplnxform (&msg_loc, plane.point, plane.normal, &idmattyp, idmat,
   &toxypln.matrix_type, toxypln.matrix,
   &fromxypln.matrix_type, fromxypln.matrix, NULL);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);

  origin[X] = origin[Y] = origin[Z] = 0.0;
  zaxis[X] = zaxis[Y] = 0.0;
  zaxis[Z] = 1.0;
  xyplane.point = origin;
  xyplane.normal = zaxis;

  /*
   * Intersect all the curves with each other. If a single curve is input,
   * intersect it with itself. The number  of parametric intersections
   * returned is twice the number of intersections indicated in the
   * self-intersection method.
   *
   * During the intersection, the curves are treated as projected onto
   * the projection-plane, which in turn is transformed into the xy-plane.
   * The parameters at which these intersections occur are stored in the
   * corresponding "cvinfo" structure, sorted by parameter value.
   */

  if (numcvs > NUM_STATIC_CVS)
    cvinfos = (struct cvinfo *) om$malloc (size = numcvs * 
               sizeof (struct cvinfo));
  else
    cvinfos = cvinfosmem;
  EMerr_hndlr (!cvinfos, *msg, EMS_E_NoDynamicMemory, ret_end);
  
  for (i=0; i<numcvs; i++)
    {
    cvinfos[i].numpars = 0;
    cvinfos[i].intpars = cvinfos[i].intparsmem;
    cvinfos[i].numcomps = 0;
    cvinfos[i].comps = cvinfos[i].compsmem;
    cvinfos[i].cvclass = cvinfos[i].cvclassmem;
    }

  if (numcvs == 1)
    selfoutput = TRUE;
  else
    selfoutput = FALSE;

  for (cvinx1=0; cvinx1<numcvs+(selfoutput ? 0:-1); cvinx1++)
    {
    cvid = &cvs[cvinx1].located_obj;
    cvenv = &cvs[cvinx1].module_info.md_env;
    if (cvenv->matrix_type != MAIDMX)
      {
      env1 = &env1mem;
      stat_func = MAmulmx (&msg_loc, &four, &four, &four,
                   toxypln.matrix, cvenv->matrix, env1->matrix);
      EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
       ret_end);

      stat_func = MAtypemx (&msg_loc, env1->matrix, &env1->matrix_type);
      EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
       ret_end);
      }
    else
      env1 = &toxypln;

    for (cvinx2=cvinx1+(selfoutput ? 0:1); cvinx2<numcvs; cvinx2++)
      {
      numintpts = 0;
      numparsmem = 0;
      numovlpmem = 0;

      if (cvinx1 == cvinx2)
        {
        /*
         * The transformation matrix is further modified to contain the
         * projection onto the Z=0 plane. This is done here unlike for
         * what is done with with EMcrvcrvint, because no option is present
         * that will allow a projection onto Z=0 plane inside the 
         * self-intersection method.
         */

        idmat[10] = 0.0;
        stat_func = MAmulmx (&msg_loc, &four, &four, &four, idmat, 
                     toxypln.matrix, toxypln_0z.matrix);
        EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror, 
         ret_end);
        stat_func = MAtypemx (&msg_loc, toxypln_0z.matrix, 
                     &toxypln_0z.matrix_type);
        EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
         ret_end);

        if (cvenv->matrix_type != MAIDMX)
          {
          env1 = &env1mem;
          stat_func = MAmulmx (&msg_loc, &four, &four, &four,
                       toxypln_0z.matrix, cvenv->matrix, env1->matrix);
          EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
           ret_end);
          stat_func = MAtypemx (&msg_loc, env1->matrix, &env1->matrix_type);
          EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
                       ret_end);
          }
        else
          env1 = &toxypln_0z;

        stat_OM = om$send (msg = message GRcurve.EMcrvslfint (&msg_loc,
                                 NULL, env1, &numparsmem, &numintpts, NULL,
                                 &mypars, NULL,
                                 &numovlpmem, &numovlps, NULL, NULL), 
                           targetid = cvid->objid, targetos = cvid->osnum,
                           senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
        numintpts += numintpts;
        }
      else
        {
        cvenv = &cvs[cvinx2].module_info.md_env;
        if (cvenv->matrix_type != MAIDMX)
          {
          env2 = &env2mem;
          stat_func = MAmulmx (&msg_loc, &four, &four, &four,
                       toxypln.matrix, cvenv->matrix, env2->matrix);
          EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
           ret_end);

          stat_func = MAtypemx (&msg_loc, env2->matrix, &env2->matrix_type);
          EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
           ret_end);
          }
        else
          env2 = &toxypln;

        stat_OM = om$send (msg = message GRcurve.EMcrvcrvint (&msg_loc,
                   NULL, env1, NULL, &cvs[cvinx2].located_obj, env2,
                   EMS_CVINT_ZEROZDEPTH, &numparsmem, &numintpts, NULL,
                   &mypars, &otpars, NULL, &numovlpmem, &numovlps, NULL, NULL,
                   NULL), targetid = cvid->objid, targetos = cvid->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
        }

      if (numintpts)
        {
        inxlim = cvinx1 == cvinx2 ? MY : OTHER;
        for (inx=MY; inx<=inxlim; inx++)
          {
          cvinfos_ptr = &cvinfos[inx == MY ? cvinx1 : cvinx2];
          blksize = cvinfos_ptr->numpars + numintpts;
          if (blksize >= NUM_STATIC_INTPARS)
            {
            parptr = cvinfos_ptr->intpars;
            blksize *= sizeof (struct GRparms);
            if (parptr != cvinfos_ptr->intparsmem)
              {
              parptr = (struct GRparms *) om$realloc (ptr = (char *) parptr,
                        size = blksize);
              EMerr_hndlr (!parptr, *msg, EMS_E_NoDynamicMemory, ret_end);
              }
            else
              {
              parptr = (struct GRparms *) om$malloc (size = blksize);
              EMerr_hndlr (!parptr, *msg, EMS_E_NoDynamicMemory, ret_end);

              blksize = cvinfos_ptr->numpars * sizeof (struct GRparms);
              OM_BLOCK_MOVE (cvinfos_ptr->intpars, parptr, blksize);
              }
            cvinfos_ptr->intpars = parptr;
            }

          parptr = inx == MY ? mypars : otpars;
          blksize = numintpts * sizeof (struct GRparms);
          OM_BLOCK_MOVE (parptr, &cvinfos_ptr->intpars[cvinfos_ptr->numpars],
           blksize);
          cvinfos_ptr->numpars += numintpts;
          om$dealloc (ptr = parptr);
          if (inx == MY)
            mypars = NULL;
          else
            otpars = NULL;
          }
        }
      }
    }

  /*
   * If only a single was input and there was some self intersection
   * detected, the processing for this curve from this point on is
   * like any other. But if no self intersection was detected then
   * processing for area proceeds as if the entire curve was an eligible
   * piece as an area boundary. In the latter case, retain the flag
   * so that later processing may realize this special case.
   */

  if (selfoutput && numintpts)
    selfoutput = FALSE;

  /*
   * Sort the parameters obtained on each of the curves in the ascending
   * order. If the curve was a composite curve, the parameter sorting 
   * is done within a component and then across components in the ascending
   * order.
   */

  for (cvinx=0; cvinx<numcvs; cvinx++)
    {
    cvid = &cvs[cvinx].located_obj;
    cvobj = cvid->objid;
    cvos = cvid->osnum;
    cvinfos_ptr = &cvinfos[cvinx];
    numintpts = cvinfos_ptr->numpars;

    stat_OM = om$get_classid (objid = cvobj, osnum = cvos, 
               p_classid = &cvclass);
    EMomerr_exit (stat_OM, ret_end);

    stat_OM = om$is_ancestry_valid (subclassid = cvclass, 
               superclassid = OPP_GRcompcurve_class_id);
    if (stat_OM != OM_S_SUCCESS)
      {
      cvinfos[cvinx].numcomps = 1;
      cvinfos[cvinx].comps[0].S_objid = cvobj;
      cvinfos[cvinx].cvclass[0] = cvclass;
      }
    else
      {
      stat_OM = om$get_channel_count (objid = cvobj, osnum = cvos,
                 p_chanselect = &chan_to_comps, count = &numcomps);
      EMomerr_exit (stat_OM, ret_end);

      cvinfos[cvinx].numcomps = numcomps;
      if (numcomps > NUM_STATIC_CVCOMPS)
        {
        cvinfos_ptr->comps = (OM_p_OBJECT_LINKAGE) om$malloc (size = numcomps *
                              sizeof (OM_S_OBJECT_LINKAGE));
        cvinfos_ptr->cvclass = (GRclassid *) om$malloc (size = numcomps *
                               sizeof (GRclassid));
        }
      comps = cvinfos_ptr->comps;
      compclass = cvinfos_ptr->cvclass;
      EMerr_hndlr (!comps || !compclass, *msg, EMS_E_NoDynamicMemory, ret_end);

      stat_OM = om$get_channel_objects (objid = cvobj, osnum = cvos,
                 p_chanselect = &chan_to_comps, list = comps, size = numcomps,
                 count = &numcomps);
      EMomerr_exit (stat_OM, ret_end);

      for (i=0; i<numcomps; i++)
        {
        stat_OM = om$get_classid (objid = comps[i].S_objid, osnum = cvos,
                   p_classid = &compclass[i]);
        EMomerr_exit (stat_OM, ret_end);
        }
      }

    for (i=0; i<numintpts-1; i++)
      {
      for (j=i+1; j<numintpts; j++)
        {
        obj1 = cvinfos_ptr->intpars[i].leaf_id.objid;
        obj2 = cvinfos_ptr->intpars[j].leaf_id.objid;
        par1 = cvinfos_ptr->intpars[i].u;
        par2 = cvinfos_ptr->intpars[j].u;

        if (obj1 != obj2)
          for (k=0; k<numcomps; k++)
            if ( obj1 == comps[k].S_objid)
              {
              par1 = DEFINITE_SMALLER;
              break;
              }
            else if (obj2 == comps[k].S_objid)
              {
              par2 = DEFINITE_SMALLER;
              break;
              }
      
        if (par1 > par2)
          {
          temppar = cvinfos_ptr->intpars[j];
          cvinfos_ptr->intpars[j] = cvinfos_ptr->intpars[i];
          cvinfos_ptr->intpars[i] = temppar;
          }
        }
      }
    }

  /*
   * If a curve is closed, extract the portion from the start-point to
   * the first intersection point and the portion from the last intersection
   * point to the stop-point. This, only if the extractions do not produce
   * degenerate segments (first intersection is at start-point, etc). These
   * segments are also possible contributors to the area(s).
   */

  for (cvinx=0; cvinx<numcvs; cvinx++)
    {
    cvinfos_ptr = &cvinfos[cvinx];
    if (cvinfos_ptr->numpars < 2)
      continue;

    cvid = &cvs[cvinx].located_obj;
    cvos = cvid->osnum;
    cvobj = cvid->objid;
    cvenv = &cvs[cvinx].module_info.md_env;
    stat_OM = om$send (msg = message GRvg.GRgeomprops (&msg_loc,
               &cvenv->matrix_type, cvenv->matrix, &grprops),
               targetid = cvobj, targetos = cvos, senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

    if (grprops.phy_closed)
      {
      stat_OM = EMgetabsg (&msg_loc, &cvenv->matrix_type, cvenv->matrix,
                 cvos, cvobj, &cv);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

      BScvkttol2 (cv->order, cv->knots, cv->num_poles, cv->poles,
       cv->weights, &partol, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      numintpts = 0;
      if (atend[FIRST] = 
          cvinfos_ptr->intpars[0].u > STARTPAR+partol)
        numintpts++;
      if (atend[SECOND] = 
          cvinfos_ptr->intpars[cvinfos_ptr->numpars-1].u < STOPPAR-partol)
        numintpts++;

      if (!numintpts)
        continue;

      blksize = cvinfos_ptr->numpars + numintpts;
      if (blksize >= NUM_STATIC_INTPARS)
        {
        parptr = cvinfos_ptr->intpars;
        blksize *= sizeof (struct GRparms);
        if (parptr != cvinfos_ptr->intparsmem)
          {
          parptr = (struct GRparms *) om$realloc (ptr = (char *) parptr,
                    size = blksize);
          EMerr_hndlr (!parptr, *msg, EMS_E_NoDynamicMemory, ret_end);
          }
        else
          {
          parptr = (struct GRparms *) om$malloc (size = blksize);
          EMerr_hndlr (!parptr, *msg, EMS_E_NoDynamicMemory, ret_end);

          blksize = cvinfos_ptr->numpars * sizeof (struct GRparms);
          OM_BLOCK_MOVE (cvinfos_ptr->intpars, parptr, blksize);
          }
        cvinfos_ptr->intpars = parptr;
        }

      for (i=FIRST; i<=SECOND; i++)
        {
        if (atend[i])
          {
          temppar.u = i == FIRST ? STARTPAR : STOPPAR;
          temppar.polygon_inx = FALSE;
          temppar.leaf_id.osnum = cvos;
          temppar.leaf_id.objid = cvinfos_ptr->comps[i == FIRST ? 
                                   FIRST : cvinfos_ptr->numcomps-1].S_objid;

          inxlim = cvinfos_ptr->numpars;
          if (i == FIRST)
            {            
            blksize = inxlim * sizeof (struct GRparms);
            OM_BLOCK_MOVE (&cvinfos_ptr->intpars[FIRST],
             &cvinfos_ptr->intpars[SECOND], blksize);
            inx = FIRST;
            }
          else
            inx = inxlim;

          blksize = sizeof (struct GRparms);
          OM_BLOCK_MOVE (&temppar, &cvinfos_ptr->intpars[inx], blksize);
          cvinfos_ptr->numpars++;
          }
        }
      }
    }

  /*
   * Extract the geometry of the consecutive parts of these curves, starting
   * from the first intersection point and upto the last one. Only these
   * geometries will contribute towards making the area(s). In the case of
   * composite curves, if the part to be extracted spans across curves, extract
   * the individual pieces making up this part. If the geometry to be extracted
   * is degenerate, then do not extract it. The geometry is generated in
   * the xy-plane obtained by the transformation matrix followed by a
   * projection (same as at intersection time). Care is taken to see that the
   * curve geometries and their classes after transformation are consistent.
   * The extracted geometries are placed into the EMSinters linked-list 
   * structure for further processing. Also, store the curve's class ids as
   * the more-info in the field in the EMSintobj for the curve. If no curve is
   * found with two or more intersections no output is possible. Return a
   * NotFound code in this case. An exception to this rule is when only
   * one curve has been input. If no intersections are found on such a
   * curve, the entire curve itself is taken in for further area processing.
   */

  numcomps = 0;
  for (i=0; i<numcvs; i++)
    {
    cvinfos_ptr = &cvinfos[i];
    for (j=0; j<cvinfos_ptr->numpars-1; j++)
      {
      obj1 = cvinfos_ptr->intpars[j].leaf_id.objid;
      obj2 = cvinfos_ptr->intpars[j+1].leaf_id.objid;
      for (k=0; k<cvinfos_ptr->numcomps; k++)
        {
        if (obj1 == cvinfos_ptr->comps[k].S_objid)
          cvinx1 = k;
        if (obj2 == cvinfos_ptr->comps[k].S_objid)
          {
          cvinx2 = k;
          break;
          }
        }
      numcomps += (cvinx2 - cvinx1) + 1;
      }
    }
  if (numcomps > NUM_STATIC_CVS)
    cvintinfos = (struct cvintinfo *) om$malloc (size = numcomps *
                  sizeof (struct cvintinfo));
  else
    cvintinfos = cvintinfosmem;
  EMerr_hndlr (!cvintinfos, *msg, EMS_E_NoDynamicMemory, ret_end);

  intinfoinx = 0;
  for (cvinx=0; cvinx<numcvs; cvinx++)
    {
    cvenv = &cvs[cvinx].module_info.md_env;
    if (cvenv->matrix_type != MAIDMX)
      {
      cvenv = &env1mem;
      stat_func = MAmulmx (&msg_loc, &four, &four, &four,
                   toxypln.matrix, cvenv->matrix, cvenv->matrix);
      EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
       ret_end);

      stat_func = MAtypemx (&msg_loc, cvenv->matrix, &cvenv->matrix_type);
      EMerr_hndlr (EMSerror (stat_func & msg_loc), *msg, EMS_E_MAerror,
       ret_end);
      }
    else
      cvenv = &toxypln;

    cvinfos_ptr = &cvinfos[cvinx];
    cvos = cvs[cvinx].located_obj.osnum;

    inxlim = selfoutput ? 1 : cvinfos_ptr->numpars-1;
    for (i=0; i<inxlim; i++)
      {
      if (!selfoutput)
        {
        obj1 = cvinfos_ptr->intpars[i].leaf_id.objid;
        obj2 = cvinfos_ptr->intpars[i+1].leaf_id.objid;
        }
      else
        {
        obj1 = cvinfos_ptr->comps[0].S_objid;
        obj2 = cvinfos_ptr->comps[cvinfos_ptr->numcomps-1].S_objid;
        }

      for (j=0; j<cvinfos_ptr->numcomps; j++)
        {
        if (obj1 == cvinfos_ptr->comps[j].S_objid)
          cvinx1 = j;
        if (obj2 == cvinfos_ptr->comps[j].S_objid)
          {
          cvinx2 = j;
          break;
          }
        }

      for (j=cvinx1; j<=cvinx2; j++)
        {
        cvobj = cvinfos_ptr->comps[j].S_objid;

        stat_OM = EMgetabsg (&msg_loc, &cvenv->matrix_type, cvenv->matrix,
                   cvos, cvobj, &cv);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

        if (j == cvinx1 && !selfoutput)
          startpar = cvinfos_ptr->intpars[i].u;
        else
          startpar = cv->knots[cv->order-1];

        if (j == cvinx2 && !selfoutput)
          stoppar = cvinfos_ptr->intpars[i+1].u;
        else
          stoppar = cv->knots[cv->num_poles];

        BScvkttol2 (cv->order, cv->knots, cv->num_poles, cv->poles,
         cv->weights, &partol, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        if (fabs (stoppar - startpar) < partol)
          continue;

        BSalloccv (cv->order, cv->num_poles+2*cv->order-1, cv->rational, 
         cv->num_boundaries, &pcv, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);

        midpar = (startpar + stoppar) / 2.0;
        stat_func = BSpartofcv (&msg_loc, cv, startpar, midpar, stoppar,
                     pcv);
        EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_BSerror,
         ret_end);

        cvclass = cvinfos_ptr->cvclass[j];
        if (!selfoutput)
          {
          stat_OM = EFget_the_edge_type_for_an_object (NULL_OBJID, cvos,
                     cvclass, &cvtype);
          EMomerr_exit (stat_OM, ret_end);
          stat_OM = EFget_clipped_edge_type (&msg_loc, cvtype, &cvtype);
          EMomerr_exit (stat_OM, ret_end);
          EFget_new_linear_edge_type (cvtype, pcv->num_poles, &cvtype);
          stat_OM = EFget_classid_for_an_edge_type (&cvclass, cvtype);
          EMomerr_exit (stat_OM, ret_end);
          }

        BSalloccv (pcv->order, pcv->num_poles, pcv->rational,
         pcv->num_boundaries, &projcv, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);

        stat_func = EFproject_curve_onto_plane (NULL, pcv, cvclass, &xyplane,
                     zaxis, NULL_OBJID, projcv, &cvclass, &msg_loc);
        EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
         ret_end);
        cvintdata.data.curve = projcv;

        BSfreecv (&msg_loc, pcv);
        pcv = NULL;

        cvintinfos_ptr = &cvintinfos[intinfoinx++];
        cvintinfos_ptr->cvclass = cvclass;
        cvintinfos_ptr->cvinx = cvinx;
        EMmakeintlist (&msg_loc, &cvparts, NULL, &nullobj, NULL,
         NULL, NULL, NULL, NULL, NULL, &cvintdata, NULL, FALSE, FALSE,
         cvintinfos_ptr, NULL, NULL, NULL, NULL, NULL, TRUE, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    }
  EMerr_hndlr (!cvparts, *msg, EMS_I_NotFound, ret_end);

  /*
   * Obtain the range box surrounding the curve geometries just extracted.
   * This helps in computing a ray from the given area-point(s) that will
   * intersect enclosing curves. This ray is used in the first attempt
   * to find an enclosed area.
   */

  cvsrange[XMIN] = MAXDOUBLE;
  cvsrange[YMIN] = MAXDOUBLE;
  cvsrange[ZMIN] = 0.0;
  cvsrange[XMAX] = -MAXDOUBLE;
  cvsrange[YMAX] = -MAXDOUBLE;
  cvsrange[ZMAX] = 0.0;
  cvintobj = cvparts->cvs;
  while (cvintobj)
    {
    cv = cvintobj->this_uvintobj.data.curve;
    BSbx2 (&msg_loc, &cv->num_poles, (IGRpoint *)cv->poles, cv->weights, cvmin, cvmax);
    if (cvmin[X] < cvsrange[XMIN])
      cvsrange[XMIN] = cvmin[X];
    if (cvmin[Y] < cvsrange[YMIN])
      cvsrange[YMIN] = cvmin[Y];
    if (cvmax[X] > cvsrange[XMAX])
      cvsrange[XMAX] = cvmax[X];
    if (cvmax[Y] > cvsrange[YMAX])
      cvsrange[YMAX] = cvmax[Y];
    cvintobj = cvintobj->next;
    }

  /*
   * For every area that needs to be generated, the following is per-
   * formed:
   */

  for (areainx=0; areainx<numareas; areainx++)
    {
    /*
     * Obtain the effective area point. This point is expected to lie
     * inside the flattened area. It is obtained as the intersection
     * of the boreline that stands for this area-point with the
     * projection plane. The boreline is first transformed using the
     * same matrix that transformed the curves and intersected with the
     * transformed projection plane, which is simply, the xy-plane.
     */

    stat_func = MAptsxform (&msg_loc, &two, toxypln.matrix,
                 areapts[areainx * 2], (IGRdouble *)xform_areapts);
    EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
     ret_end);

    line.point1 = xform_areapts[FIRST];
    line.point2 = xform_areapts[SECOND];
    stat_func = MAlnplisect (&msg_loc, &line, &xyplane, &lentol, xyareapt,
                 &par1);
    EMerr_hndlr (!stat_func, *msg, EMS_E_MAerror, ret_end);
    xyareapt[Z] = 0.0;

    /*
     * Applying the criteria described below a starting curve object is
     * found which is also oriented in the direction of the final output.
     * This starting curve object is returned in 'mincvintobj'. A second
     * try is performed (the first failing) before giving up. 
     */

    found = FALSE;
    for (tryinx=FIRST; tryinx<=SECOND; tryinx++)
      {
      /*
       * Obtain a ray starting from the given area-point and going outward at 
       * an angle of A to the horizontal. The ray extends beyond the range box
       * of the curves. Angle A is computed such that it's relationship to any
       * symmetry is less probable. Angle A is - i) arctan(RAY_DELY/RAY_DELX)
       * and during a second try, ii) 180+arctan(2*RAY_DELY/RAY_DELX). An
       * equivalent curve structure for the ray is built. The first pole is
       * always the area-point. The second pole is the outer ray-point.
       */

      line.point1 = xyareapt;
      line.point2 = pt;
      pt[Z] = 0.0;

      pt[X] = xyareapt[X] + (tryinx == FIRST ? RAY_DELX : -RAY_DELX);
      pt[Y] = xyareapt[Y] + (tryinx == FIRST ? RAY_DELY : -2*RAY_DELY);
      stat_func = EMget_bounded_line (cvsrange, &line, raypts, &msg_loc);
      EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
       ret_end);
      OM_BLOCK_MOVE (xyareapt, raypts[FIRST], sizeof (IGRpoint));

      py.num_points = 2;
      py.points = (double *) raypts;

      raycv.poles = (double *) cvpts;
      raycv.knots = (double *) knots;
      raycv.weights = NULL;
      raycv.bdrys = NULL;

      stat_func = EMcnvtpybsn (&msg_loc, 3, &py, &raycv);
      EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
       ret_end);

      /*
       * This ray is then intersected with all the part geometries.
       * There must be an intersection otherwise the potential area-loop
       * is not closed. The intersections are sorted along the ray. If we
       * view the set of curve geometries along the Z-axis from the positive
       * side, the curves bounding the area must go clockwise. This is the
       * convention used. Therefore, the ray hitting the first curve must 
       * observe the curve flowing to the right. If this is not the case
       * the curve's direction must be reversed.
       */

      BScvkttol2 (raycv.order, raycv.knots, raycv.num_poles, raycv.poles,
                  raycv.weights, &raytol, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);


      cvintobj = cvparts->cvs;
      mincvintobj = NULL;
      minlnpar = MAXDOUBLE;

      while (cvintobj)
        {
        cv = cvintobj->this_uvintobj.data.curve;
        stat_func = BScvcv_int (&msg_loc, &raycv, cv, (IGRint *)&numintpts, &intpts,
                     &intpar[FIRST], &intpar[SECOND], &numovlps, &intovpts,
                     &intovpar1, &intovpar2);
        EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_BSerror,
         ret_end);

        if (numovlps)
          {
          om$dealloc (ptr = intovpts);
          intovpts = NULL;
          om$dealloc (ptr = intovpar1);
          intovpar1 = NULL;
          om$dealloc (ptr = intovpar2);
          intovpar2 = NULL;
          }

        if (numintpts)
          {
          tempminpar = MAXDOUBLE;
          tempmininx = 0;
          for (i=0; i<numintpts; i++)
            if (intpar[FIRST][i] < tempminpar)
              {
              tempmininx = i;
              tempminpar = intpar[FIRST][i];
              }
          if (tempminpar < minlnpar)
            {
            minlnpar = tempminpar;
            mincvpar = intpar[SECOND][tempmininx];
            mincvintobj = cvintobj;
            }
          }
        cvintobj = cvintobj->next;
        }

      if (mincvintobj)
        {
	typedef	IGRpoint	dummy[2];

         /*
         * Determine if the curve turns right or left, relative to the 
         * direction of the ray at the first intersection point. If this
         * cannot be determined go for the second try. If this is the second
         * try, set a return code of NotFound and proceed with the next
         * area processing.
         */
       
        small_lenpar = minlnpar - FACTOR_SMALL_XYZ_LEN * raytol;
        pts = (IGRpoint *) raycv.poles;
        turnpts[FIRST][X] = pts[FIRST][X] + small_lenpar *
                             (pts[SECOND][X] - pts[FIRST][X]);
        turnpts[FIRST][Y] = pts[FIRST][Y] + small_lenpar *
                             (pts[SECOND][Y] - pts[FIRST][Y]);
        turnpts[FIRST][Z] = 0.0;

        small_len = FACTOR_SMALL_XYZ_LEN * lentol;
        cv = mincvintobj->this_uvintobj.data.curve;

        BScvarrevt (cv, &mincvpar, 1, small_len, (dummy *)turnpts[SECOND/*and THIRD*/],
         &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        turn = EMturn (&msg_loc, turnpts[FIRST], turnpts[SECOND],
                turnpts[THIRD], colltol);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        if (turn == EMS_L_LEFT || turn == EMS_L_RIGHT)
          {
          if (turn == EMS_L_LEFT)
            mincvintobj->reversed = !mincvintobj->reversed;
          }
        else
          continue;

        /*
         * The curve that was first hit by the ray is now made the first 
         * element in the intersection list. The trace function will pick this
         * curve up and using it's direction try and trace out the area that
         * encloses the space on the right hand side of the curves. The first
         * group output by the trace function is the group defining the 
         * required area. If this is the second try and still a closed group
         * is not found then output the open group, flagging this condition.
         */

        EMswapintobj (&msg_loc, TRUE, cvparts->cvs, mincvintobj);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        EMsfinttrace (&msg_loc, NULL, NULL, cvparts, &lentol, NULL, &num_grps,
         &num_subgrps_grp, &num_elems_subgrp, &elems, &subgrp_rev, &elem_rev,
         &grp_closed, &subgrp_closed);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        sftrace_malloc = TRUE;
    
        if (!grp_closed[FIRST])
          {
          EMsfinttrace_free (&msg_loc, num_grps, num_subgrps_grp,
           num_elems_subgrp, elems, subgrp_rev, elem_rev, grp_closed,
           subgrp_closed);
          sftrace_malloc = FALSE;
          }
        else
          {
          found = TRUE;
          break;
          }
        }
      }

    /*
     * If the trace was successfully completed, then the area-curve for this
     * input can be formatted. Else, a NotFound code is returned.
     */

    if (!found)
      {
      *msg = EMS_I_NotFound;
      continue;
      }

    /*
     * A composite curve is made out of the elements in this first, closed
     * group. If the number of elements is one then the output curve is
     * a single B-spline curve.
     */
   
    numocvs = num_elems_subgrp[FIRST][FIRST];
    if (numocvs > NUM_STATIC_CVS)
      ocvobjs = (GRobjid *) om$malloc (size = numocvs * sizeof (GRobjid));
    else
      ocvobjs = ocvobjsmem; 
    EMerr_hndlr (!ocvobjs, *msg, EMS_E_NoDynamicMemory, ret_end);

    saveprops = const_list->properties;
    cvintobj = elems[FIRST][FIRST];
    for (i=0; i<numocvs; i++)
      {
      cvintinfos_ptr = (struct cvintinfo *) cvintobj->more_info;
      cvs[cvintinfos_ptr->cvinx].geom_parms.polygon_inx = TRUE;
      cvclass = cvintinfos_ptr->cvclass;
      cv = cvintobj->this_uvintobj.data.curve;

      const_list->geometry = (char *) cv;
      if (numocvs > 1)
        const_list->properties |= GR_RIGID_RELATIONSHIP;

      stat_OM = om$construct (classid = cvclass,
                 msg = message GRgraphics.GRconstruct (const_list), 
                 osnum = construct_os, p_objid = &cvobj);
      const_list->properties = saveprops;
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (*const_list->msg), *msg, EMS_E_CurveError,
       ret_end);
      ocvobjs[i] = cvobj;

      revflag1 = elem_rev[FIRST][FIRST][i] ? 0x1 : 0x0;
      revflag2 = cvintobj->reversed ? 0x1 : 0x0;
      if (revflag1 ^ revflag2)
        {
        stat_OM = om$send (msg = message GRcurve.GRrevparm (&msg_loc,
                   const_list->env_info), targetid = cvobj, 
                   targetos = construct_os, senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
        }

      cvintobj = cvintobj->next;
      }

    if (numocvs > 1)
      {
      stat_OM = om$construct (classid = OPP_GRcompcurve_class_id,
                 msg = message GRgraphics.GRconstruct (const_list), 
                 osnum = construct_os, p_objid = &cvobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (*const_list->msg), *msg, EMS_E_CurveError,
       ret_end);

      conn_args.to_sel = chan_to_comps;
      conn_args.to_idx = 0;
      conn_args.fr_sel = chan_to_owners;
      conn_args.fr_os = construct_os;
      stat_OM = om$make_message (classname = "Root", methodname = "connect", 
                 size = sizeof (conn_args), p_arglist = &conn_args,
                 p_msg = &messg);
      EMomerr_exit (stat_OM, ret_end);

      for (i=0; i<numocvs; i++)
        {
        conn_args.fr_objid = ocvobjs[i];
        conn_args.fr_idx = i;
        stat_OM = om$send (msg = &messg, targetid = cvobj,
                   targetos = construct_os, 
                   senderid = ocvobjs[i]);
        EMomerr_exit (stat_OM, ret_end);
        }

      post_info.construct_flag = TRUE;
      stat_OM = om$send (msg = message GRvg.GRpostabsg (&msg_loc,
                 const_list->env_info, &post_info, NULL, &cvobj),
                 targetid = cvobj, targetos = construct_os,
                 senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);
      }

    EMsfinttrace_free (&msg_loc, num_grps, num_subgrps_grp, num_elems_subgrp,
     elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    sftrace_malloc = FALSE;

    /*
     * The output curve has to be transformed back onto the
     * projection plane.
     */

    stat_OM = om$send (msg = message GRgraphics.GRxform (&msg_loc,
               const_list->env_info, &fromxypln.matrix_type, fromxypln.matrix,
               &cvobj), targetid = cvobj, targetos = construct_os,
               senderid = NULL_OBJID);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_CurveError, ret_end);

    areacvs[areainx] = cvobj;
    }

ret_end:
  if (cvinfos)
    {
    for (i=0; i<numcvs; i++)
      {
      cvinfos_ptr = &cvinfos[i];
      if (cvinfos_ptr->intpars != cvinfos_ptr->intparsmem)
        om$dealloc (ptr = cvinfos_ptr->intpars);
      if (cvinfos_ptr->comps && cvinfos_ptr->comps != cvinfos_ptr->compsmem)
        om$dealloc (ptr = cvinfos_ptr->comps);
      if (cvinfos_ptr->cvclass && 
          cvinfos_ptr->cvclass != cvinfos_ptr->cvclassmem)
        om$dealloc (ptr = cvinfos_ptr->cvclass);
      }
    if (cvinfos != cvinfosmem)
      om$dealloc (ptr = cvinfos);
    }
  if (ocvobjs && ocvobjs != ocvobjsmem)
    om$dealloc (ptr = ocvobjs);
  if (cvintinfos && cvintinfos != cvintinfosmem)
    om$dealloc (ptr = cvintinfos);
    
  if (mypars)
    om$dealloc (ptr = mypars);
  if (otpars)
    om$dealloc (ptr = otpars);

  if (intpts)
    om$dealloc (ptr = intpts);
  if (intpar[FIRST])
    om$dealloc (ptr = intpar[FIRST]);
  if (intpar[SECOND])
    om$dealloc (ptr = intpar[SECOND]);
  if (intovpts)
    om$dealloc (ptr = intovpts);
  if (intovpar1)
    om$dealloc (ptr = intovpar1);
  if (intovpar2)
    om$dealloc (ptr = intovpar2);
  if (intovpar3)
    om$dealloc (ptr = intovpar3);
  if (intovpar4)
    om$dealloc (ptr = intovpar4);

  if (pcv)
    BSfreecv (&msg_loc, pcv);

  EMinters_data_free (&msg_loc, cvparts, MAXINT, NULL, dumfunc);
  EMinters_free (cvparts, MAXINT);

  if (sftrace_malloc)
    EMsfinttrace_free (&msg_loc, num_grps, num_subgrps_grp, num_elems_subgrp,
     elems, subgrp_rev, elem_rev, grp_closed, subgrp_closed);

  EMWRAPUP (stat_OM, *msg, "EMmkarea");
  return (stat_OM);
}

static void dumfunc(){return;}

end implementation GRbcsubbc;

