#include "OMminimum.h"

#include "igr_include/igrtypedef.h"
#include "igr_include/igr.h"
#include "bsgeom_cvsf.h"

#include "GRtypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "EMSpwapi.h"
#include "PWapi/mdstptgm.h"

static void set_pypt_contain_props
(
  enum PWcontaintype leftcont,
  enum PWcontaintype rightcont,
  PWboolean          bdry_is_area,
  unsigned short     *p_props
);

/*
  DESCRIPTION

  This function expects the lists - p_pypt and p_edpar - to be allocated
  by the caller. The size of these lists should be 2 times the number of
  elements in the input, p_cvregions list. This function will fill in the
  fields of the output lists. 

  NOTES

  One of the fields to be specially taken note of is the "info" field in both 
  the output list nodes. These will be initialized to point to their 
  counterparts in the other list. If the curve-region overlaps an existing
  edge, this fact is marked in the pypoint output list using the START_OVERLAP
  and STOP_OVERLAP property bits.
*/

void pwCnvtCvregionEMS 
(
  struct PWcvregion_list *p_cvregions,
  struct EMSpypoint *p_pypt,
  struct EMSsfintedpar *p_edpar,
  PWboolean bdry_is_area,
  double uvtol
)
{
  int i, num_bdrys;
  double squvtol = uvtol * uvtol;
  struct EMSpypoint *p_pypt_tmp, *p_pypt_tmp1;
  struct EMSsfintedpar *p_edpar_tmp, *p_edpar_tmp1;
  struct PWcvregion_list *p_cvregs_tmp;

  /*
   * Each node of EMSpypt list is made to point to the corresponding
   * EMSsfintedpar and vice-versa.
   */

  num_bdrys = 0;
  p_cvregs_tmp = p_cvregions;
  while (p_cvregs_tmp)
  {
    num_bdrys++;
    p_cvregs_tmp = p_cvregs_tmp->p_next;
  }

  p_pypt_tmp = p_pypt;
  p_edpar_tmp = p_edpar;
  for (i=0; i<num_bdrys*2; i++)
  {
    p_pypt_tmp->info = (char *) p_edpar_tmp;
    p_edpar_tmp->info = (char *) p_pypt_tmp;

    p_pypt_tmp = p_pypt_tmp->next;
    p_edpar_tmp = p_edpar_tmp->next;
  }

  /*
   * Fill the output linked-list, proceeding pairwise. Some of the information
   * stored in the cvregion list may not be transferrable into the output 
   * lists. 
   */

  p_pypt_tmp = p_pypt;
  p_edpar_tmp = p_edpar;
  p_cvregs_tmp = p_cvregions;
  while (p_cvregs_tmp)
  {
    p_pypt_tmp1 = p_pypt_tmp;
    p_edpar_tmp1 = p_edpar_tmp;

    for (i=START; i<=STOP; i++)
    {
      pwCnvtCvintptEMS (&p_cvregs_tmp->cvregion.regbounds[i],
       p_pypt_tmp, p_edpar_tmp, bdry_is_area);

      /*
       * Transfer the curve-region information (eg: overlap) into the
       * pypt linked list
       */

      if (i == START)
      {
        if (pwGetContainCvregion (&p_cvregs_tmp->cvregion) == 
             PWcontain_on)
        {
          p_pypt_tmp->props |= EMS_PYPT_START_OVERLAP;
          p_pypt_tmp->next->props |= EMS_PYPT_STOP_OVERLAP;
        }
      }

      /*
       * Move on to the subsequent EMSpypoint and EMSsfintedpar structures
       */

      p_pypt_tmp = p_pypt_tmp->next;
      p_edpar_tmp = p_edpar_tmp->next;
    }

    if (pwDistSqPtPt2d (p_pypt_tmp1->point, p_pypt_tmp1->next->point) < 
                       squvtol)
    {
      if (p_edpar_tmp1->edgeid != p_edpar_tmp1->next->edgeid)
      {
        p_pypt_tmp1->props |= EMS_PYPT_ENDMARKER;
        p_pypt_tmp1->next->props |= EMS_PYPT_ENDMARKER;
      }
    }

  /*
   * Move on to the subsequent PWcvregion structure
   */

  p_cvregs_tmp = p_cvregs_tmp->p_next;
  }

  return;
}

/*
  DESCRIPTION
  
    This function translates information from a PWcvintpt structure into
    the EMS equivalent pair of structures - EMSpypoint and EMSsfintedpar.
*/

void pwCnvtCvintptEMS 
(
  struct PWcvintpt *p_cvintpt,
  struct EMSpypoint *p_pypt,
  struct EMSsfintedpar *p_edpar,
  PWboolean bdry_is_area
)
{
  enum PWcontaintype leftcont, rightcont;

  /*
   * Set the fields in the EMSpypt structure. Also, set the
   * relative containment bit-properties available from the cvintpt
   * structure.
   */

  pwCnvtCvptEMSpypt (&p_cvintpt->cvpt, p_pypt);

  leftcont = pwGetContainCvintpt (p_cvintpt, LEFT);
  rightcont = pwGetContainCvintpt (p_cvintpt, RIGHT);
  set_pypt_contain_props (leftcont, rightcont, bdry_is_area, &p_pypt->props);

  /*
   * Set the fields in the EMSsfintedpar structure
   */

  pwCnvtCvptEMSsfed (&p_cvintpt->sibling, p_edpar);

  return;
}

/*
  DESCRIPTION
  
    This function translates all relevant information from a PWcvpt structure
    into the EMS equivalent structure - EMSpypoint.
*/

void pwCnvtCvptEMSpypt
(
  struct PWcvpt *p_cvpt,
  struct EMSpypoint *p_pypt
)
{
  enum PWtopopostype topopos;

  /*
   * Set the topological postion fields in the EMSpypt structure.
   */

  topopos = pwGetTopoposCvpt (p_cvpt);
  if (topopos == PWtopopos_start)
    p_pypt->props |= EMS_PYPT_ATSTART;
  else if (topopos == PWtopopos_stop)
    p_pypt->props |= EMS_PYPT_ATSTOP;
  else if (topopos == PWtopopos_middle)
    p_pypt->props |= EMS_PYPT_ATMIDDLE;
  else 
    p_pypt->props |= EMS_PYPT_POSUNKNOWN;

  /*
   * The transition information in the EMSpypt structure is set to
   * "unknown".
   */

  p_pypt->props |= EMS_PYPT_RELUNKNOWN;

  /*
   * Fill the info about the point's geometry.
   */

  memcpy (p_pypt->point, p_cvpt->pt, 3 * sizeof (double));
  p_pypt->param = p_cvpt->cvparam.spanpar;
  p_pypt->span_inx = p_cvpt->cvparam.spaninx;

  return;
}

/*
  ABSTRACT

  This function converts the enumerated PWtopopostype into the version
  in EMS - EMScvinttype. A corresponding function does the conversion
  the other way around.
*/

enum EMScvinttype pwEMSTopopos
(
  enum PWtopopostype topopos
)
{
  if (topopos == PWtopopos_start)
    return EMScvint_lfend;
  else if (topopos == PWtopopos_stop)
    return EMScvint_rtend;
  else if (topopos == PWtopopos_middle)
    return EMScvint_middle;
  else 
    return EMScvint_unknown;
}

enum PWtopopostype pwPWCvint
(
  enum EMScvinttype cvint
)
{
  if (cvint == EMScvint_lfend)
    return PWtopopos_start;
  else if (cvint == EMScvint_rtend)
    return PWtopopos_stop;
  else if (cvint == EMScvint_middle)
    return PWtopopos_middle;
  else 
    return PWtopopos_unknown;
}


/*
  DESCRIPTION
  
    This function translates all relevant information from a PWcvpt structure
    into the EMS equivalent structure - EMSsfintedpar.
*/

void pwCnvtCvptEMSsfed
(
  struct PWcvpt *p_cvpt,
  struct EMSsfintedpar *p_sfed
)
{
  /*
   * Set the topological postion enum in the EMSsfintedpar structure.
   */

  p_sfed->intloc = pwEMSTopopos (pwGetTopoposCvpt (p_cvpt));

  /*
   * The id of the curve/edge on which this point sits, is transferred.
   */

  p_sfed->edgeid = p_cvpt->cvid;

  /*
   * Fill the info about the point's geometry.
   */

  p_sfed->edgepar.param = p_cvpt->cvparam.spanpar;
  p_sfed->edgepar.span_inx = p_cvpt->cvparam.spaninx;
  memcpy (p_sfed->point, p_cvpt->pt, 2 * sizeof (double));

  return;
}

/*
  DESCRIPTION

    This function takes in an EMSdataselect and converts it into a
    PW??data - either PWcvdata or PWsfdata - depending on which function
    is called.
*/

void pwCnvtEMSCvdata 
(
  struct EMSdataselect *p_datasel,
  struct PWcvdata *p_cvdata
)
{
  if (p_datasel->datatype == EMSdata_poly2d)
  {
    p_cvdata->datatype = PWcvdata_py2d;
    p_cvdata->data.py2d.num_pts = p_datasel->data.poly->num_points;
    p_cvdata->data.py2d.p_pts = (PWpoint2d *) p_datasel->data.poly->points;
  }
  else if (p_datasel->datatype == EMSdata_poly3d)
  {
    p_cvdata->datatype = PWcvdata_py;
    p_cvdata->data.py.num_pts = p_datasel->data.poly->num_points;
    p_cvdata->data.py.p_pts = (PWpoint *) p_datasel->data.poly->points;
  }
  else if (p_datasel->datatype == EMSdata_curve3d)
  {
    p_cvdata->datatype = PWcvdata_bspcv;
    p_cvdata->data.p_bspcv = p_datasel->data.curve;
  }
  else
  {
    p_cvdata->datatype = PWcvdata_null;
  }

  return;
}


/*
  DESCRIPTION

  This function takes in an EMSdataselect which represents a curve (1
  parametric dimensional) and MOVES the data into the PWcvdata structure.
  The EMSdataselect structure will not have any geometry pointers left in it.
  These are simply moved into the PWcvdata's appropriate fields. The 
  memory is now with the PWcvdata from this point on. A free on EMSdataselect
  will have no effect.

  
  NOTES

  If data contained in EMSdataselect cannot be handled here, the resulting
  "datatype" in the PWcvdata will be PWcvdata_null.
*/

void pwMoveEMSCvdata 
(
  struct EMSdataselect *p_datasel,
  struct PWcvdata *p_cvdata
)
{
  pwCnvtEMSCvdata (p_datasel, p_cvdata);
  if (p_cvdata->datatype != PWcvdata_null)
  {
    switch (p_datasel->datatype)
    {
      case EMSdata_poly2d:
      case EMSdata_poly3d:
        p_datasel->data.poly->points = NULL;
        break;

      case EMSdata_curve3d:
        p_datasel->data.curve = NULL;
        break;

      case EMSdata_object:
        /* TBD */
        break;
    }
    p_datasel->datatype = EMSdata_null;
  }

  return;
}


/*
  DESCRIPTION

  This function takes in a PWcvdata and MOVES it into an EMSdataselect. The
  Cvdata structure will not have any geometry pointers left in it. These are
  simply moved into the EMSdataselect's appropriate fields. The memory is
  with EMSdataselect from this point on. A free on PWcvdata will have no
  effect.
*/

void pwMoveCvdataEMS
(
  struct PWcvdata *p_cvdata,
  struct EMSdataselect *p_datasel
)
{
  int dim;
  double *p_double, *p_cvdouble;
  struct IGRpolyline *p_py;
  
  switch (p_cvdata->datatype)
  {
    case PWcvdata_pt2d:
    case PWcvdata_pt:
    case PWcvdata_py2d:
    case PWcvdata_py:

      if (p_cvdata->datatype == PWcvdata_pt2d ||
          p_cvdata->datatype == PWcvdata_py2d)
        p_datasel->datatype = EMSdata_poly2d;
      else
        p_datasel->datatype = EMSdata_poly3d;

      p_py = (struct IGRpolyline *) malloc (sizeof (struct IGRpolyline));

      if (p_cvdata->datatype == PWcvdata_pt2d)
      {
        p_py->num_points = 2;
        p_cvdouble = (double *) p_cvdata->data.pt2d;
        dim = 2;
      }
      else if (p_cvdata->datatype == PWcvdata_pt)
      {
        p_py->num_points = 2;
        p_cvdouble = (double *) p_cvdata->data.pt;
        dim = 3;
      }
      else if (p_cvdata->datatype == PWcvdata_py2d)
      {
        p_py->num_points = p_cvdata->data.py2d.num_pts;
        p_cvdouble = (double *) p_cvdata->data.py2d.p_pts;
        p_cvdata->data.py2d.p_pts = NULL;
        dim = 2;
      }
      else
      {
        p_py->num_points = p_cvdata->data.py.num_pts;
        p_cvdouble = (double *) p_cvdata->data.py.p_pts;
        p_cvdata->data.py.p_pts = NULL;
        dim = 3;
      }

      if (p_cvdata->datatype == PWcvdata_pt2d || 
          p_cvdata->datatype == PWcvdata_pt)
      {
        p_double = (double *) malloc (2 * dim * sizeof (double));
        memcpy (p_double, p_cvdouble, dim * sizeof (double));
        memcpy (&p_double[dim], p_cvdouble, dim * sizeof (double));
      }
      else
      {
        p_double = p_cvdouble;
      }

      p_py->points = p_double;
      p_datasel->data.poly = p_py;
      break;

    case PWcvdata_bspcv:
      
      p_datasel->datatype = EMSdata_curve3d;
      p_datasel->data.curve = p_cvdata->data.p_bspcv;
      p_cvdata->data.p_bspcv = NULL;
      break;

    case PWcvdata_gmbspcv:

      p_datasel->datatype = EMSdata_curve3d;
      p_datasel->data.curve = p_cvdata->data.p_gmbspcv->bspcv;
      p_cvdata->data.p_gmbspcv->bspcv = NULL;
      if (p_cvdata->data.p_gmbspcv->array1)
        free (p_cvdata->data.p_gmbspcv->array1);
      free (p_cvdata->data.p_gmbspcv);
      p_cvdata->data.p_gmbspcv = NULL;

      break;

  }
  return;
}


/*
  Helper functions
*/
static void set_pypt_contain_props 
(
  enum PWcontaintype leftcont, 
  enum PWcontaintype rightcont, 
  PWboolean          bdry_is_area, 
  unsigned short     *p_props
)
{
  if (leftcont == PWcontain_out && rightcont == PWcontain_in)
    *p_props |= EMS_PYPT_HOLEAREA;
  else if (leftcont == PWcontain_in && rightcont == PWcontain_out)
    *p_props |= EMS_PYPT_AREAHOLE;
  else if (leftcont == PWcontain_out && rightcont == PWcontain_out)
    *p_props |= EMS_PYPT_HOLEHOLE;
  else if (leftcont == PWcontain_in && rightcont == PWcontain_in)
    *p_props |= EMS_PYPT_AREAAREA;

  else if (bdry_is_area)
  {
    if (leftcont == PWcontain_in && rightcont == PWcontain_on ||
        leftcont == PWcontain_on && rightcont == PWcontain_in ||
        leftcont == PWcontain_on && rightcont == PWcontain_on)
      *p_props |= EMS_PYPT_AREAAREA;
    else if (leftcont == PWcontain_out && rightcont == PWcontain_on)
      *p_props |= EMS_PYPT_HOLEAREA;
    else if (leftcont == PWcontain_on && rightcont == PWcontain_out)
      *p_props |= EMS_PYPT_AREAHOLE;
    else 
      *p_props |= EMS_PYPT_RELUNKNOWN;
  }
  else
  {
    if (leftcont == PWcontain_out && rightcont == PWcontain_on ||
        leftcont == PWcontain_on && rightcont == PWcontain_out ||
        leftcont == PWcontain_on && rightcont == PWcontain_on)
      *p_props |= EMS_PYPT_HOLEHOLE;
    else if (leftcont == PWcontain_in && rightcont == PWcontain_on)
      *p_props |= EMS_PYPT_AREAHOLE;
    else if (leftcont == PWcontain_on && rightcont == PWcontain_in)
      *p_props |= EMS_PYPT_HOLEAREA;
    else 
      *p_props |= EMS_PYPT_RELUNKNOWN;
  }

  return;
}

