class implementation Root;

#include "EMS.h"
#include <stdio.h>
#include "bserr.h"
#include "msdef.h"     /* MSINARG ... */
#include "emsdef.h"
#include "maerr.h"
#include "godef.h"
#include "GRtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "griodef.h"
#include "go.h"
#include "grio.h"
#include "OMerrordef.h"
#include "emserr.h"

from GRgraphics import GRconstruct;

/*

Name
  EFMakeSkinSurface

Abstract
 This function creates the geometry of a skinning surface. 
Synopsis
OUT:	IGRlong *msg; return message.
IN:	IGRlong num_trace; number of traces.
IN:	struct GRlc_info *trcobj; traces locate info.
IN:	IGRlong num_cross; number of cross-sections.
IN:	struct GRlc_info *crsobj; cross-sections locate info.
IN:	IGRboolean surface_is_open; surface to be open?
IN:	struct GRlc_info tangent_surfaces[4]; locate info for the tangent surfs.
IN:	IGRboolean absolute_orientation; cross-sections to be absolutely oriented?
IN:	IGRboolean no_height_scaling; vary height proportional to width?
IN:	struct IGRbsp_curve *shape_law; shape law curve.
IN:	struct IGRbsp_curve *orient_law; orientation law curve.
IN:	IGRboolean smooth; smooth traces and cross-sections.
OUT:	struct IGRbsp_surface **surface; resulting surface.

Description
 Get the geometries of each of the traces,cross-sections, etc... and call
 the math to construct a skinning surface.
Return Value
 IGRlong: OM_S_SUCCESS or OM_E_ABORT. 
Notes

Index

Keywords
 surface,skinning,geometry
History
  06/22/93 : Carlos M. Diaz : created

 */
IGRlong EFMakeSkinSurface ( msg,
			num_trace,
			trcobj,
			num_cross,
			crsobj, 
			surface_is_open,
			tangent_surfaces,
			absolute_orientation,
			no_height_scaling,
			shape_law,
			orient_law,
			smooth,
			surface) 
IGRlong *msg; 
IGRlong num_trace;
struct GRlc_info *trcobj;
IGRlong num_cross;
struct GRlc_info *crsobj;
IGRboolean surface_is_open;
struct GRlc_info tangent_surfaces[4];
IGRboolean absolute_orientation;
IGRboolean no_height_scaling;
struct IGRbsp_curve *shape_law;
struct IGRbsp_curve *orient_law;
IGRboolean smooth;
struct IGRbsp_surface **surface; 
{
  extern    IGRlong EMget_the_geometry();
  IGRlong   sts,i;
  struct    IGRbsp_curve **cross_sections, **trace_curves;
  struct    IGRbsp_surface *tangent_sf[4];
  BSrc      rc;
  /*
  * Initialize
  */

  rc = BSSUCC;
  *msg = MSSUCC;
  cross_sections = NULL;
  trace_curves = NULL;
  tangent_sf[0] = NULL;
  tangent_sf[1] = NULL;
  tangent_sf[2] = NULL;
  tangent_sf[3] = NULL;
  /*
 * Input validation
 */
  if ((num_trace < 1) ||
      (num_cross < 1) ||
      ((num_trace > 2) && (num_cross < 2)))
  {
    *msg = MSINARG;
    goto wrapup;
  }

 /*
 * Allocate space for the cross sections
 */
  cross_sections = (struct IGRbsp_curve **) stackalloc (
      (num_cross + 1) * sizeof(struct IGRbsp_curve *));
  if (!cross_sections)
  {
    *msg = MANOMEMORY;
    goto wrapup;
  }
  for (i = 0; i <= num_cross; i++) cross_sections[i] = NULL;
  /*
 * Get the curve defintion for the cross sections
 */
  for (i = 0; i < num_cross; i++)
  {
    sts = EMget_the_geometry(
        &crsobj[i],
        TRUE,
        TRUE,
        FALSE,
        crsobj[i].located_obj.objid,
        &cross_sections[i],
        msg);
    if (!(1&sts)) goto wrapup;      
    if (smooth)
    {
     BSarclnparc(&rc,cross_sections[i]);
     EMerr_hndlr((rc != BSSUCC), *msg, MSFAIL, wrapup);
    }
   } /* for (i = 0; i < num_cross; i++) */

  if ((num_cross > 1) &&
      (! surface_is_open))
  {
    sts = EMget_the_geometry(
        &crsobj[0],
        TRUE,
        TRUE,
        FALSE,
        crsobj[0].located_obj.objid,
        &cross_sections[num_cross],
        msg); 
    if (!(1&sts)) goto wrapup;
    if (smooth)
    {
     BSarclnparc(&rc,cross_sections[num_cross]);
     EMerr_hndlr((rc != BSSUCC), *msg, MSFAIL, wrapup);
    }      
    num_cross++;
  } /* if ((num_cross > 1) && (! surface_is_open)) */
  /*
 * Allocate space for the trace curves
 */
  trace_curves = (struct IGRbsp_curve **) stackalloc (
      (num_trace + 1) * sizeof(struct IGRbsp_curve *));
  if (!trace_curves)
  {
    *msg = MANOMEMORY;
    goto wrapup;
  }
  for (i = 0; i <= num_trace; i++) trace_curves[i] = NULL;
  /*
 * Get the trace curves
 */
  for (i = 0; i < num_trace; i++)
  {
    sts = EMget_the_geometry(
        &trcobj[i],
        TRUE,
        TRUE,
        FALSE,
        trcobj[i].located_obj.objid,
        &trace_curves[i],
        msg); 
    if (!(1 & sts)) goto wrapup;
    if (smooth)
    {
     BSarclnparc(&rc,trace_curves[i]);
     EMerr_hndlr((rc != BSSUCC), *msg, MSFAIL, wrapup);
    }    
  } /*  for (i = 0; i < num_trace; i++) */
  /*
 * Get the supporting tangent surfaces
 */
  if (tangent_surfaces)
  {
    for (i = 0; i < 4; i++)
    {
      if ((tangent_surfaces[i].located_obj.objid) != NULL_OBJID)
      {
        sts = EMget_the_geometry(
            &tangent_surfaces[i],
            FALSE,
            FALSE,
            FALSE,
	    tangent_surfaces[i].located_obj.objid,
            &tangent_sf[i],
            msg);
        if (!(1 & sts)) goto wrapup;
      } /* if (tangent_surfaces[i].located_obj.objid != NULL_OBJID) */
    } /* for (i = 0; i < 4; i++) */
  } /* if (tangent_surfaces) */
  /*
 * Get the surface definition
 */
  {
    extern  void BSmvxsectrc();

    BSmvxsectrc(
        (IGRint) num_trace,
        trace_curves,
        (IGRint) num_cross,
        cross_sections,
        TRUE,                     /* on site */
    ! no_height_scaling,
        NULL,                     /* trace parameters */
    absolute_orientation,
        NULL,                     /* view matrix */
    NULL,                     /* origins */
    NULL,                     /* x axis */
    NULL,                     /* y axis */
    FALSE,                    /* constant direction */
    ! surface_is_open,
        shape_law,
        &shape_law,
        orient_law,
        &orient_law,
        tangent_sf[0],
        tangent_sf[1],
        tangent_sf[2],
        tangent_sf[3],
        surface,
        &rc);

    if (rc != BSSUCC)
    {
      fprintf(stderr, "\nMath error %d in BSmvxsectrc\n", rc);
      *msg = MSFAIL;
      goto wrapup;
    }
  }
  /*
 * End of routine
 */
wrapup:
  for (i = 0; i < 4; i++)
  {
    if (tangent_sf[i]) free(tangent_sf[i]);
  }
  if (1 & (*msg))
    return(OM_S_SUCCESS);
  else
    return(OM_E_ABORT);
}

end implementation Root;
