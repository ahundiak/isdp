/*
  DESCRIPTION

    The following functions are intended to supplement dp$dynamics to provide
    a way by which data-point/cursor constraints can be specified. Some of the
    types of constraints are: point restricted to lie on a specified curve
    w.r.t to the view, point restricted to lie in a specified Z-plane
    w.r.t. the view, etc.

    The user specifies, typically via a command-object call, the kind
    of constraint required. Such constraints can be set by software too.
    These constraints are set here by invoking the relevant function. The
    constraint remains in effect until it is replaced by some other constraint
    or is removed by a call to EMremove_constraints(): Currently the constraint
    function calls are the following:
    a) IGRboolean EMconstrain_ptoncrv (crv). The input argument is a pointer
       to the curve structure of the curve that is to be used as the
       constraint. The point is maintained to within the chord-height
       tolerance of the curve.
    b) IGRboolean EMconstrain_ptzdepth (zpt). The input argument is the point 
       whose z-depth in each view controls the z-value of the data-point.
    c) IGRboolean EMconstrain_ptonline (pt1, pt2). pt1 and pt2 define a 
       non-degenerate line in model-space. The cursor is constrained to move 
       along this line.
    d) IGRboolean EMconstrain_ptondata (type, mxtyp, mx, datatype, data). The
       argument type is enumerated and specifies the kind of constraint (one
       of the above), and data points to one of types listed in the union
       EMSdata, containing the constraint data. If the data type is a
       graphics-object a matrix might have to be specified to obtain geometry.
       NULL in place of mxtyp/mx denotes an identity matrix.
    e) IGRboolean EMremove_constraints(). This function call removes any
       constraint that may be active.
    If the return value is TRUE, all's well, else an error condition has
    occurred.

    For such constraints to apply on data-point inputs (with dynamics or
    without), the EMconstrain function must be called on the data-button:
    a) The function - IGRboolean EMconstrain (button) - MUST be called
       as the FIRST statement inside the dynamics function which is specified
       in the call to dp$dynamics. The single argument, button, is a pointer
       to the EX_button structure passed to the dynamics function. It contains
       the current cursor position in world coordinates. EMconstraint,
       transforms the point in the button according to the active constraints
       that is present at the time. A TRUE return value indicates an all's
       well condition. A FALSE value indicates some problem.
    b) This same function - EMconstraint - is called on the button obtained
       with the 'getevent' call, when the response happens to be a data-point.
       This will transform the data-point consistent with the active
       constraint.
   
    To obtain the current constraint the following function is called,
    which returns the constraint denoted by it's type and data:
       EMget_constraint (constype, datatype, datasize, data). If any of the
       arguments is NULL, that argument is ignored. "constype" argument
       returns an enumerated type EMSconstraintype. "datatype" returns
       enumerated type EMSdatatype which indicates the type of data stored
       for this constraint. "datasize" returns the size in bytes of the
       data actually stored. "data: should be pointer to an address of
       already allocated memory of size atleast = "datasize". "data" can be
       typecast into IGRpolyline or IGRbsp_curve depending on "datatype".
       "data" is returned partitioned according to the "datatype".

  HISTORY

    SS  :  04/03/89  :  Creation
    SS  :  07/17/89  :  Removed the code dealing with window-information
                        and put it into the file EMwininfo.I
 Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "ex.h"
#include "dpdef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "mamulmx.h"
#include "malnbcpro.h"
#include "ma2lnpro.h"
#include "bsparameters.h"
#include "bsdistptpts.h"

#define X 0
#define Y 1
#define Z 2
#define W 3

#define EMS_CONSTRAIN_NULL 	0
#define EMS_CONSTRAIN_ONCRV 	1
#define EMS_CONSTRAIN_ONZDEPTH	2
#define EMS_CONSTRAIN_ONLINE 	3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

%safe
static IGRdouble cht_tol;
static IGRshort constrain_type = EMS_CONSTRAIN_NULL;
static IGRchar *constrain_data = NULL;
static IGRint constrain_size = NULL;
static IGRint constrain_data_size = NULL;
static IGRboolean ptoncrv();
static IGRboolean ptzdepth();
static IGRboolean ptonline();
%endsafe

from GRvg import GRgenabsg;

IGRboolean EMconstrain_ptoncrv (crv)
struct IGRbsp_curve *crv;
{
  IGRboolean stat_func;
  IGRlong msg_loc;
  struct IGRbsp_curve *constrain_crv;

  stat_func = TRUE;

  GRbc_size (crv->order, crv->num_poles, crv->rational, crv->num_boundaries,
   constrain_size);
  if (constrain_data_size < constrain_size)
    {
    if (constrain_data_size)
      constrain_data = (IGRchar *) om$realloc (ptr = constrain_data,
                        size = constrain_size);
    else
      constrain_data = (IGRchar *) om$malloc (size = constrain_size);
    EMerr_hndlr (!constrain_data, stat_func, FALSE, ret_end);
    constrain_data_size = constrain_size;
    }
  constrain_crv = (struct IGRbsp_curve *) constrain_data;
  GRbc_partition (constrain_crv, crv->order, crv->num_poles, crv->rational,
   crv->num_boundaries);

  constrain_crv->order = crv->order;
  constrain_crv->periodic = crv->periodic;
  constrain_crv->non_uniform = crv->non_uniform;
  constrain_crv->num_poles = crv->num_poles;
  constrain_crv->num_knots = crv->num_knots;
  constrain_crv->rational = crv->rational;
  constrain_crv->planar = crv->planar;
  constrain_crv->phy_closed = crv->phy_closed;
  constrain_crv->num_boundaries = crv->num_boundaries;

  OM_BLOCK_MOVE (crv->poles, constrain_crv->poles, 3 * crv->num_poles *
   sizeof (IGRdouble));
  OM_BLOCK_MOVE (crv->knots, constrain_crv->knots, crv->num_knots * 
   sizeof (IGRdouble));
  if (crv->rational && crv->weights)
    OM_BLOCK_MOVE (crv->weights, constrain_crv->weights, crv->num_poles *
     sizeof (IGRdouble));
  if (crv->num_boundaries && crv->bdrys)
    OM_BLOCK_MOVE (crv->bdrys, constrain_crv->bdrys, 2 * crv->num_boundaries *
     sizeof (IGRdouble));

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);

  constrain_type = EMS_CONSTRAIN_ONCRV;

ret_end:
  return (stat_func);
}


IGRboolean EMconstrain_ptzdepth (zpt)
IGRpoint zpt;
{
  IGRboolean stat_func = TRUE;
  IGRint padding;
  struct IGRpolyline *constrain_py;
  
  padding = 8;
  constrain_size = sizeof (struct IGRpolyline) + sizeof (IGRpoint) + padding;
  if (constrain_data_size < constrain_size)
    {
    if (constrain_data_size)
      constrain_data = (IGRchar *) om$realloc (ptr = constrain_data,
                        size = constrain_size);
    else
      constrain_data = (IGRchar *) om$malloc (size = constrain_size);
    EMerr_hndlr (!constrain_data, stat_func, FALSE, ret_end);
    constrain_data_size = constrain_size;
    }
  constrain_py = (struct IGRpolyline *) constrain_data;
  constrain_py->points = constrain_py->points + 1;
  
  constrain_py->num_points = 1;
  OM_BLOCK_MOVE (zpt, constrain_py->points, sizeof (IGRpoint));

  constrain_type = EMS_CONSTRAIN_ONZDEPTH;

ret_end:
  return (stat_func);
}


IGRboolean EMconstrain_ptonline (lnpt1, lnpt2)
IGRpoint lnpt1, lnpt2;
{
  IGRboolean stat_func = TRUE;
  IGRint padding;
  IGRlong msg_loc;
  IGRdouble lentol;
  struct IGRpolyline *constrain_py;
  
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  EMerr_hndlr (BSdistptpts (&msg_loc, lnpt1, lnpt2) <= lentol, stat_func,
    FALSE, ret_end);

  padding = 8;
  constrain_size = sizeof (struct IGRpolyline) + 2 * sizeof (IGRpoint) + 
                    padding;
  if (constrain_data_size < constrain_size)
    {
    if (constrain_data_size)
      constrain_data = (IGRchar *) om$realloc (ptr = constrain_data,
                        size = constrain_size);
    else
      constrain_data = (IGRchar *) om$malloc (size = constrain_size);
    EMerr_hndlr (!constrain_data, stat_func, FALSE, ret_end);
    constrain_data_size = constrain_size;
    }
  constrain_py = (struct IGRpolyline *) constrain_data;
  constrain_py->points = constrain_py->points + 1;
  
  constrain_py->num_points = 2;
  OM_BLOCK_MOVE (lnpt1, constrain_py->points, sizeof (IGRpoint));
  OM_BLOCK_MOVE (lnpt2, ++constrain_py->points, sizeof (IGRpoint));
  
  constrain_type = EMS_CONSTRAIN_ONLINE;

ret_end:
  return (stat_func);
}


IGRboolean EMconstrain_ptondata (typ, inmxtyp, inmx, datatype, data)
enum EMSconstraintype typ;
IGRshort *inmxtyp;
IGRmatrix inmx;
enum EMSdatatype datatype;
IGRchar *data;
{
  IGRboolean stat_func;
  IGRshort mxtyp_mem, *mxtyp;
  IGRlong msg_loc, stat_OM;
  IGRmatrix mx_mem, *mx;
  GRspacenum osnum;
  GRobjid objid;
  struct IGRbsp_curve *cv;
  IGRboolean EMconstrain_ptoncrv();
  extern void EMidmatrix();
  extern IGRlong EMgetabsg();
  
  stat_func = TRUE;

  switch (typ)
    {
    case EMSconstrain_tocrv:
      if (datatype == EMSdata_object)
        {
        osnum = ((struct GRid *) data)->osnum;
        objid = ((struct GRid *) data)->objid;

        if (!inmxtyp || !inmx)
          {
          mxtyp = &mxtyp_mem;
          mx = (IGRmatrix *)mx_mem;
          EMidmatrix (&msg_loc, mxtyp, mx);
          }
        else
          {
          mxtyp = inmxtyp;
          mx = (IGRmatrix *)inmx;
          }

        stat_OM = EMgetabsg (&msg_loc, mxtyp, mx, osnum, objid, &cv);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), stat_func, FALSE, ret_end);

        stat_func = EMconstrain_ptoncrv (cv);
        }
      else
        stat_func = FALSE;
      break;

    default:
      stat_func = FALSE;
    }

ret_end:
  return (stat_func);
}

IGRboolean EMremove_constraints()
{
  constrain_type = EMS_CONSTRAIN_NULL;
  constrain_size = 0;
  return (TRUE);
}


IGRboolean EMconstrain (button)
struct EX_button *button;
{
  IGRboolean stat_func;

  if (constrain_type == EMS_CONSTRAIN_NULL)
    return (TRUE);

  switch (constrain_type)
    {
    case EMS_CONSTRAIN_ONCRV:
      stat_func = ptoncrv (button);
      break;
    case EMS_CONSTRAIN_ONZDEPTH:
      stat_func = ptzdepth (button);
      break;
    case EMS_CONSTRAIN_ONLINE:
      stat_func = ptonline (button);
      break;
    default:
      stat_func = FALSE;
    }

  return (stat_func);  
}


void EMget_constraint (constype, datatype, datasize, data)
enum EMSconstraintype *constype;
enum EMSdatatype *datatype;
IGRint *datasize;
IGRchar *data;
{
  if (constype)
    {
    if (constrain_type == EMS_CONSTRAIN_NULL)
      *constype = EMSconstrain_null;
    else if (constrain_type == EMS_CONSTRAIN_ONCRV)
      *constype = EMSconstrain_tocrv;
    else if (constrain_type == EMS_CONSTRAIN_ONZDEPTH)
      *constype = EMSconstrain_tozdepth;
    else
      *constype = EMSconstrain_toline;
    }

  if (datatype)
    *datatype = (constrain_type == EMS_CONSTRAIN_NULL ? 
                 EMSdata_null : (constrain_type == EMS_CONSTRAIN_ONCRV ? 
                                 EMSdata_curve3d : EMSdata_poly3d));

  if (datasize)
    *datasize = constrain_size;

  if (data && constrain_size)
    OM_BLOCK_MOVE (constrain_data, data, constrain_size);

  return;
}


/*
  DESCRIPTION
    
    The following functions are intended for local use and are not
    for public use. They are used solely within this file.
  
  HISTORY

    SS  :  04/03/89  :  Creation
*/


/*
 * This function transforms the given button-point to stay on a given
 * curve. The transformed point is computed as the closest point to the
 * bore-line in the view in which the button is generated.
 */

#define XCOMP_BLINE 8
#define YCOMP_BLINE 9
#define ZCOMP_BLINE 10

static IGRboolean ptoncrv (button)
struct EX_button *button;
{
  IGRboolean stat_func;
  IGRlong msg_loc;
  IGRdouble t, u;
  IGRpoint lnpt1, lnpt2;
  IGRpoint lnpt, cvpt;
  IGRmatrix viewmat;
  struct IGRline line;
  struct IGRbsp_curve *constrain_crv;
  extern IGRboolean EMgetwininfo();

  constrain_crv = (struct IGRbsp_curve *) constrain_data;

  stat_func = EMgetwininfo (button->objid, button->osnum, 
               viewmat, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  if (!stat_func)
    goto ret_end;

  lnpt1[X] = button->x;
  lnpt1[Y] = button->y;
  lnpt1[Z] = button->z;
  lnpt2[X] = lnpt1[X] + viewmat[XCOMP_BLINE];
  lnpt2[Y] = lnpt1[Y] + viewmat[YCOMP_BLINE];
  lnpt2[Z] = lnpt1[Z] + viewmat[ZCOMP_BLINE];
  line.point1 = lnpt1;
  line.point2 = lnpt2;

  stat_func = MAlnbcproj (&msg_loc, &line, constrain_crv, &cht_tol,
               lnpt, cvpt, &t, &u);
  EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_func, FALSE, ret_end);

  button->x = cvpt[X];
  button->y = cvpt[Y];
  button->z = cvpt[Z];

ret_end:
  return (stat_func);
}


/*
 * This function takes the button-point and maps it to the
 * z view coordinate of the constraining point, defined earlier.
 * This function was originally in the file EMmaptozview.C
 *
 * dhm    11/11/88    creation date.
 */

static IGRboolean ptzdepth (button)
struct EX_button *button;
{
  IGRboolean stat_func;
  IGRshort s_four = 4, s_one = 1;
  IGRlong msg_loc;
  IGRdouble *constrain_zpt;
  IGRdouble hpt[4], constrain_hview_zpt[4], button_hview_pt[4], newpt[4];
  IGRmatrix viewmat, worldmat;
  extern IGRboolean EMgetwininfo();

  constrain_zpt = ((struct IGRpolyline *) constrain_data)->points;

  /*
   * Get the view matrix for converting points from
   * world to view.
   */

  stat_func = EMgetwininfo (button->objid, button->osnum, 
               viewmat, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  if (!stat_func)
    goto ret_end;

  /*
   * Mapping the pre-specified Z-depth point to the view system. The point
   * is obtained in homogenous co-ordinates.
   */

  hpt[X] = constrain_zpt[X];
  hpt[Y] = constrain_zpt[Y];
  hpt[Z] = constrain_zpt[Z];
  hpt[W] = 1.0;

  stat_func = MAmulmx (&msg_loc, &s_four, &s_four, &s_one, viewmat, hpt,
               constrain_hview_zpt);
  EMerr_hndlr(!stat_func || EMSerror (msg_loc), stat_func, FALSE, ret_end);

  /* 
   * Mapping the button-point to the view system. The point is
   * obtained in homogenous coordinates.
   */

  hpt[X] = button->x;
  hpt[Y] = button->y;
  hpt[2] = button->z;
  hpt[W] = 1.0;

  stat_func = MAmulmx(&msg_loc, &s_four, &s_four, &s_one, viewmat, hpt,
               button_hview_pt);
  EMerr_hndlr(!stat_func || EMSerror (msg_loc), stat_func, FALSE, ret_end);

  /*
   * Set the button view point's Z-value equal to constrain-pt's view Z-depth.
   * This changed button point will then be mapped back to world.
   */

  hpt[X] = button_hview_pt[X];
  hpt[Y] = button_hview_pt[Y];
  hpt[Z] = constrain_hview_zpt[Z];
  hpt[W] = 1.0;

  stat_func = EMgetwininfo (button->objid, button->osnum, 
               NULL, worldmat, NULL, NULL, NULL, NULL, NULL, NULL);
  if (!stat_func)
    goto ret_end;

  stat_func = MAmulmx (&msg_loc, &s_four, &s_four, &s_one, worldmat, hpt,
   newpt);
  EMerr_hndlr(!stat_func || EMSerror (msg_loc), stat_func, FALSE, ret_end);

  button->x = newpt[X];
  button->y = newpt[Y];
  button->z = newpt[Z];

ret_end:
  return(stat_func);
}

/*
 * This function is used to constrain a point-button to lie along a
 * given line.
 */

static IGRboolean ptonline (button)
struct EX_button *button;
{
  IGRboolean stat_func;
  IGRlong msg_loc;
  IGRdouble blnt, clnt;
  IGRdouble *constrain_lnpt1, *constrain_lnpt2 = NULL;
  IGRpoint blnpt1, blnpt2;
  IGRpoint blnpt, clnpt;
  IGRmatrix viewmat;
  struct IGRline bline, cline;
  extern IGRboolean EMgetwininfo();

  constrain_lnpt1 = ((struct IGRpolyline *) constrain_data)->points;
  constrain_lnpt1 = ++((struct IGRpolyline *) constrain_data)->points;

  stat_func = EMgetwininfo (button->objid, button->osnum, 
               viewmat, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  if (!stat_func)
    goto ret_end;

  blnpt1[X] = button->x;
  blnpt1[Y] = button->y;
  blnpt1[Z] = button->z;
  blnpt2[X] = blnpt1[X] + viewmat[XCOMP_BLINE];
  blnpt2[Y] = blnpt1[Y] + viewmat[YCOMP_BLINE];
  blnpt2[Z] = blnpt1[Z] + viewmat[ZCOMP_BLINE];
  bline.point1 = blnpt1;
  bline.point2 = blnpt2;

  cline.point1 = constrain_lnpt1;
  cline.point2 = constrain_lnpt2;

  stat_func = MA2lnproj (&msg_loc, &bline, &cline, blnpt, clnpt, &blnt, &clnt);
  EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_func, FALSE, ret_end);

  button->x = clnpt[X];
  button->y = clnpt[Y];
  button->z = clnpt[Z];

ret_end:
  return (stat_func);
}

end implementation Root;
