/*
  DESCRIPTION:

    This method invokes the special math for cylinder-cylinder
    intersection. It should return intelligent xyz-curves but for now
    to leave the rest of the system unperturbed we returned the stroked
    version of the curve.

  HISTORY
   
    SS  :  05/14/90  :  Creation
*/

class implementation EMScylindr;

#include "EMS.h"
#include "OMmacros.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsedgedef.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#define POINT      0
#define LINE       1
#define CIRCLE     2
#define ELLIPSE    3
#define CIRCARC    6
#define ELLIPARC   7
#define GENBC      999

#define MAXNUM_QUADINT  20

extern GRclassid OPP_EMScylindr_class_id, OPP_EMSpcylindr_class_id;
extern GRclassid OPP_EMApcylindr_class_id;

extern IGRboolean _new_sfsfint_math;

method EMget_int_data (
        IGRlong			*msg; 
        IGRushort	options;
        struct EMSdataselect	*other_data;
	struct IGRbsp_surface	*my_geom;
	struct IGRbsp_surface	*other_geom;
        IGRdouble		*my_uvrange;
        IGRdouble		*other_uvrange;
        struct EMSpartolbasis	*my_partol;
        struct EMSpartolbasis	*other_partol;
	IGRint			*num_pieces;
	struct EMSdataselect	**my_xyz_data;
	struct EMSdataselect	**other_xyz_data;
	struct EMSdataselect	**my_uv_data;
	struct EMSdataselect	**other_uv_data;
        IGRdouble		***correl_params;
	IGRchar			*curve_type;
	IGRushort	*intinfo)
{
  IGRboolean sendwrtmsg, hiorder;
  IGRshort *oncyl, inttype;
  IGRint i, j, k, inx, numpts, num_grps, numint_grp[MAXNUM_QUADINT];
  IGRint total_cvs;
  IGRlong stat_OM, msg_loc;
  IGRdouble lentol, chttol, *xyzpts, *pars, *myuvpts, *otheruvpts;
  GRclassid myclass, otherclass;
  struct IGRpolyline *py;
  struct GRid *other_obj;
  struct BSgeom_bsp_curve *intcvs[MAXNUM_QUADINT];
  struct BSgeom_bsp_curve intcvs_mem[MAXNUM_QUADINT];
  struct BSgeom_bsp_surf mysrf, othersrf;
  struct IGRbsp_curve *cv;
  struct EMSdataselect *datasel;
  extern void BSquadsfint(), BSchtptstcv(), BSprptscyl();
  extern IGRboolean BSfreecv();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *my_xyz_data = NULL;
  *other_xyz_data = NULL;
  *my_uv_data = NULL;
  *other_uv_data = NULL;
  *correl_params = NULL;
  *num_pieces = 0;
  *intinfo  = 0;

  pars = NULL;
  oncyl = NULL;
  xyzpts = NULL;
  myuvpts = NULL;
  otheruvpts = NULL;
  total_cvs = 0;

 if (_new_sfsfint_math)
     return (om$send(
      mode = OM_e_wrt_message,
      msg = message EMSsubbs.EMget_int_data(
       msg,
       options,
       other_data,
       my_geom,
       other_geom,
       my_uvrange,
       other_uvrange,
       my_partol,
       other_partol,
       num_pieces,
       my_xyz_data,
       other_xyz_data,
       my_uv_data,
       other_uv_data,
       correl_params,
       curve_type,
       intinfo),
      targetid = my_id));

  sendwrtmsg = FALSE;
  if (other_data->datatype != EMSdata_object)
    sendwrtmsg = TRUE;
  else
    {
    other_obj = other_data->data.object;
    om$get_classid (objid = other_obj->objid, osnum = other_obj->osnum,
     p_classid = &otherclass);

    stat_OM = om$is_ancestry_valid (subclassid = otherclass,
               superclassid = OPP_EMScylindr_class_id);
    if (stat_OM != OM_S_SUCCESS)
      sendwrtmsg = TRUE;
    }

  if (sendwrtmsg)
    {
    stat_OM = om$send (mode = OM_e_wrt_message,
               msg = message EMScone.EMget_int_data (msg, options,
               other_data, my_geom, other_geom, my_uvrange, other_uvrange,
               my_partol, other_partol, num_pieces,
               my_xyz_data, other_xyz_data,
               my_uv_data, other_uv_data, correl_params, curve_type, intinfo),
               targetid = my_id);
    goto ret_end;
    }

  /*
   * Call the special math function to do the intersection
   */
  
  om$get_classid (object = me, p_classid = &myclass);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);

  num_grps = 0;
  for (i=0; i<MAXNUM_QUADINT; i++)
    {
    intcvs_mem[i].bspcv = NULL;
    intcvs[i] = &intcvs_mem[i];
    }

  mysrf.geom_prop = FALSE;
  mysrf.type = (myclass == OPP_EMSpcylindr_class_id ||
                myclass == OPP_EMApcylindr_class_id) ? 4 : 2;
  mysrf.bounded = TRUE;
  mysrf.bspsf = my_geom;
  othersrf.geom_prop = FALSE;
  othersrf.type = (otherclass == OPP_EMSpcylindr_class_id ||
                   otherclass == OPP_EMApcylindr_class_id) ? 4 : 2;
  othersrf.bounded = TRUE;
  othersrf.bspsf = other_geom;

  BSquadsfint (&mysrf, &othersrf, &num_grps, numint_grp, intcvs, &msg_loc);
  if (msg_loc != BSSUCC && msg_loc != BSCOINCIDENT)
    {
    fprintf (stderr, "Error from BSquadsfint - %d\n", msg_loc);
    *msg = EMS_E_BSerror;
    goto ret_end;
    }
  EMerr_hndlr (!num_grps, *msg, EMS_I_NoIntersection, ret_end);

  /*
   * Obtain the uv-data for the output intersection curves and at the same
   * time format the data into the output.
   */

  for (i=0; i<num_grps; i++)
    total_cvs += numint_grp[i];

  *my_xyz_data = (struct EMSdataselect *) om$malloc (size = total_cvs
                  * sizeof(struct EMSdataselect));
  EMerr_hndlr (!(*my_xyz_data), *msg, EMS_E_NoDynamicMemory, ret_end);

  *my_uv_data = (struct EMSdataselect *) om$malloc (size = total_cvs
                 * sizeof(struct EMSdataselect));
  EMerr_hndlr (!(*my_uv_data), *msg, EMS_E_NoDynamicMemory, ret_end);

  *other_uv_data = (struct EMSdataselect *) om$malloc (size = total_cvs
                    * sizeof(struct EMSdataselect));
  EMerr_hndlr (!(*other_uv_data), *msg, EMS_E_NoDynamicMemory, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
  inx = 0;
  for (i=0; i<num_grps; i++)
    {
    for (j=0; j<numint_grp[i]; j++)
      {
      /*
       * For this curve obtain the xyz, myuv and otheruv data. The memory
       * for each of these should be directly outputtable.
       */

      cv = intcvs[inx]->bspcv;
      if (intcvs[inx]->type != POINT && intcvs[inx]->type != LINE)
        {
        hiorder = /*TRUE*/ FALSE;
        BSchtptstcv (cv, &numpts, &xyzpts, &pars, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        om$dealloc (ptr = pars);
        pars = NULL;
        }
      else
        {
        hiorder = FALSE;
        xyzpts = (IGRdouble *) om$malloc (size = 2 * sizeof (IGRpoint));
        EMerr_hndlr (!xyzpts, *msg, EMS_E_NoDynamicMemory, ret_end);

        OM_BLOCK_MOVE (cv->poles, xyzpts, 2 * sizeof (IGRpoint));
        if (cv->rational && cv->weights)
          for (k=0; k<6; k++)
            xyzpts[k] *= cv->weights[k%3];

        numpts = 2;
        }

      oncyl = (IGRshort *) om$malloc (size = numpts * sizeof (IGRshort));
      EMerr_hndlr (!oncyl, *msg, EMS_E_NoDynamicMemory, ret_end);

      myuvpts = (IGRdouble *) om$malloc (size = numpts * 2 *
                 sizeof (IGRdouble));
      EMerr_hndlr (!myuvpts, *msg, EMS_E_NoDynamicMemory, ret_end);

      BSprptscyl (&mysrf, numpts, xyzpts, FALSE, myuvpts, oncyl,
       &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      otheruvpts = (IGRdouble *) om$malloc (size = numpts * 2 *
                    sizeof (IGRdouble));
      EMerr_hndlr (!otheruvpts, *msg, EMS_E_NoDynamicMemory, ret_end);

      BSprptscyl (&othersrf, numpts, xyzpts, FALSE, otheruvpts, oncyl,
       &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      om$dealloc (ptr = oncyl);
      oncyl = NULL;

      /*
       * Put these into the data select formats.
       */

      datasel = &(*my_xyz_data)[inx];
      if (hiorder)
        {
        datasel->datatype = EMSdata_curve3d;
        datasel->data.curve = cv;
        intcvs[inx]->bspcv = NULL;

        om$dealloc (ptr = xyzpts);
        xyzpts = NULL;
        }
      else
        {
        datasel->datatype = EMSdata_poly3d;
        py = (struct IGRpolyline *) om$malloc (size =
              sizeof (struct IGRpolyline));
        EMerr_hndlr (!py, *msg, EMS_E_NoDynamicMemory, ret_end);
        datasel->data.poly = py;

        py->num_points = numpts;
        py->points = xyzpts;
        xyzpts = NULL;
        }

      datasel = &(*my_uv_data)[inx];
      datasel->datatype = EMSdata_poly2d;
      py = (struct IGRpolyline *) om$malloc (size =
            sizeof (struct IGRpolyline));
      EMerr_hndlr (!py, *msg, EMS_E_NoDynamicMemory, ret_end);
      datasel->data.poly = py;

      py->num_points = numpts;
      py->points = myuvpts;
      myuvpts = NULL;

      datasel = &(*other_uv_data)[inx];
      datasel->datatype = EMSdata_poly2d;
      py = (struct IGRpolyline *) om$malloc (size =
            sizeof (struct IGRpolyline));
      EMerr_hndlr (!py, *msg, EMS_E_NoDynamicMemory, ret_end);
      datasel->data.poly = py;

      py->num_points = numpts;
      py->points = otheruvpts;
      otheruvpts = NULL;

      inx++;
      }
    }
  *other_xyz_data = *my_xyz_data;
  *intinfo |= (EMSintdata_samexyzdat | EMSintdata_matcheddat);
  *num_pieces = total_cvs;

  /* 
   * Set the curve type. All the curve types are assumed to be the
   * same as the non-point one.
   */

  *curve_type = EMpoint;
  for (i=0; i<total_cvs; i++)
    {
    inttype = intcvs[i]->type;
    if (inttype == LINE)
      {
      *curve_type = EMlinesegment;
      break;
      }
    else if (inttype == CIRCLE)
      {
      *curve_type = EMcircle;
      break;
      }
    else if (inttype == ELLIPSE)
      {
      *curve_type = EMellipse;
      break;
      }
    else if (inttype == CIRCARC)
      {
      *curve_type = EMcircular_arc;
      break;
      }
    else if (inttype == ELLIPARC)
      {
      *curve_type = EMelliptical_arc;
      break;
      }
    else if (inttype != POINT)
      {
      *curve_type = EMfreeform_curve;
      break;
      }
    }
  *curve_type = EMlinestring;

ret_end:
  if (oncyl)
    om$dealloc (ptr = oncyl);
  if (pars)
    om$dealloc (ptr = pars);
  if (xyzpts)
    om$dealloc (ptr = xyzpts);
  if (myuvpts)
    om$dealloc (ptr = myuvpts);
  if (otheruvpts)
    om$dealloc (ptr = otheruvpts);
  for (i=0; i<total_cvs; i++)
    if (intcvs[i]->bspcv)
      BSfreecv (&msg_loc, intcvs[i]->bspcv);

  EMWRAPUP (*msg, stat_OM, "EMScylindr.EMget_int_data")
  return (stat_OM);
}

end implementation EMScylindr;
