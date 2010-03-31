class implementation Root;

from GRlinear import GRgetpolyline;
from EMSassoc import EMget_parent_info;
from GRgraphics import GRconstruct;

/* old includes of EFMake... */
#include "EMS.h"
#include <stdio.h>
#include "bserr.h"     /* BSSUCC ..   */
#include "msdef.h"     /* MSINARG ... */
#include "maerr.h"     /* MANOMEMORY  */
#include "GRtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "griodef.h"
#include "go.h"
#include "grio.h"
#include "OMerrordef.h"

#include "ems_m_inc.h"
#include "EMSmsgdef.h"            /* EMS_I_NotFound */
#ifndef ECmsg_include
#define ECmsg_include
#include "ECmsg.h"
#endif
#include "EMSdpb.h"
#include "emsdef.h"
#include "emserr.h"              /* EMerr_hndlr */
#include "bsfreesf.h"
#include "bsstk.h"
#include "bsprptsoncv.h"
#include "bsmkcvscp.h"
#include "bsarclnparc.h"
#include "bsmvxsectrc.h"
#include "bsblndxsect.h"
#include "godef.h"

/*

Name
  EFCsecSurf

Abstract
 This function is an argument to ems$associative_element_by_function. 
 It is responsible for the creation and recomputation of the cross-section 
 surface. 
Synopsis
 OUT:	IGRlong *EMmsg; if (1&*EMmsg) then successful else failed. 
 IN:	IGRuint options; not used.
 IN:	GRobjid old_objid; not used.
 IN:	GRobjid new_objid; objid of the newly created object.
 IN:	IGRint num_parents; number of parents.
 IN:	IGRchar *parent_info; information about parents. 
 IN:	IGRchar *recomp_info; information used to perform the recomputation
 IN:	struct GRvg_construct *construct_list; environment information
 OUT:	GRobjid *mod_new_id; same as new_objid if a change class did not occur, 
        else if whatever the id of the new class object is.

Return Value
 IGRlong

Keywords
 profiling,surface,placement,recomputation
History
  02/25/94 : Ralf Burkhart : created from EFSkinSurface (EFCrtSkinSrf.I) 

*/
IGRlong EFCsecSurf (EMmsg, options, old_objid, new_objid, num_parents,
parent_info, recomp_info, construct_list, mod_new_id)

IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
  extern  OMuword OPP_EMAgenbs_class_id;
  extern  IGRlong EMget_the_geometry();

  GRobjid surf_objid;
  IGRlong sts = OM_S_SUCCESS, msg_loc = OM_S_SUCCESS;
  IGRlong num_trace, num_cross, num_cr, num_crs;
  IGRuint *root_type = NULL;
  union   EMSparent_info *roots = NULL;
  struct  EMScross_section_surface *info = NULL;
  int i;

  struct    IGRbsp_surface *srf = NULL;
  struct    IGRbsp_surface *surface = NULL;
  struct    GRlc_info *trcloc = NULL;
  struct    GRlc_info *crsobj = NULL;
  struct    GRlc_info *trcobj = NULL;
  struct    GRlc_info orient_surface;
  IGRpoint  *crsopt = NULL;
  IGRdouble *crsang = NULL;
  IGRchar   *wrkarea;
  IGRint    cnt = 0;
  IGRboolean smooth = FALSE;

  *EMmsg = OM_S_SUCCESS;

  options = options; /* make the compiler happy */
  old_objid = old_objid; 

  /* get recompute information  */
  info = (struct EMScross_section_surface *)recomp_info;

  /* info contains the following:
        info->number_of_sections
        info->number_of_trace_curves
        info->refpln
        info->dirvec
        info->mirror_case
        info->att_method_props
        info->gen_type_props
        info->cross_surf_props
        info->chardata
  */
  num_trace = info->number_of_trace_curves;
  num_cross = info->number_of_sections;

  /* Input validation */
  if (num_trace != 1)
  {
     *EMmsg = MSINARG;
     goto wrapup;
  }

  if (num_cross == 1)
     num_crs = 2;
  else
     num_crs = num_cross;

  trcloc = (struct GRlc_info *) stackalloc ( sizeof (struct GRlc_info) * num_crs);
   EMerr_hndlr(!trcloc, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  crsobj = (struct GRlc_info *) stackalloc ( sizeof (struct GRlc_info) * num_crs);
   EMerr_hndlr(!crsobj, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  trcobj = (struct GRlc_info *) stackalloc ( sizeof (struct GRlc_info) * num_trace);
   EMerr_hndlr(!trcobj, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  crsopt = (IGRpoint *) stackalloc ( sizeof (IGRpoint) * num_crs);
   EMerr_hndlr(!crsopt, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  crsang = (IGRdouble *) stackalloc ( sizeof (IGRdouble) * num_crs);
   EMerr_hndlr(!crsang, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  /* get the parents */
  root_type = (IGRuint *)stackalloc(num_parents * sizeof(IGRuint));
  roots = (union EMSparent_info *)stackalloc(num_parents*sizeof(union EMSparent_info));
   EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  for (i=0; i<num_parents; i++)
   root_type[i] = EMSlcinfo;
   
  sts = om$send (msg = message EMSassoc.EMget_parent_info(&msg_loc, NULL,
                                                          num_parents, parent_info,
                                                          root_type, roots),
            targetid = new_objid,
            senderid = new_objid);
   EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /* unpack hangup points lc_info */
  for (i=0;i<num_cross;i++)
  {
    trcloc[i] = roots->lc_info;
    ++(roots);
  }

  /* unpack cross-sections lc_info */
  for (i=0;i<num_cross;i++,cnt++)
  {
    crsobj[i] = roots->lc_info;
    crsobj[i].geom_parms.polygon_inx = info->chardata[cnt];
    ++(roots);
  }

  /* unpack traces lc_info */
  for (i=0;i<num_trace;i++,cnt++)
  {
    trcobj[i] = roots->lc_info;
    trcobj[i].geom_parms.polygon_inx = info->chardata[cnt];
    ++(roots);
  }

  /* unpack cross-section origins */
  for (i=0;i<num_cross;i++)
  {
     OM_BLOCK_MOVE ((IGRdouble *)&info->chardata[cnt], &crsopt[i], 
                   sizeof(IGRpoint) );
     cnt = cnt + sizeof (IGRpoint);
  }

  /* unpack rotation angles of cross-sections */
  for (i=0;i<num_cross;i++)
  {
     OM_BLOCK_MOVE ((IGRdouble *)&info->chardata[cnt], &crsang[i], sizeof(IGRdouble) );
     cnt = cnt + sizeof (IGRdouble);
  }

  if (info->att_method_props & EMS_FOURTH_ATTCH)
  {
     /* unpack orient surface lc_info */
     OM_BLOCK_MOVE ((struct GRlc_info *)&info->chardata[cnt], &orient_surface,
                    sizeof(struct GRlc_info) );

     /* get the surface geometry */
     sts = EMget_the_geometry(&orient_surface, FALSE, FALSE, FALSE,
                              orient_surface.located_obj.objid, &srf, &msg_loc);
      EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
  }
  else
  {
     srf = NULL;
  }

  if (info->cross_surf_props & EMS_IS_CROSS_SEC_REPARAM)
     smooth = TRUE;

  /* put a duplicate cross_section at the end of trace, if num_cross == 1 */
  if (num_cross == 1)
  {
     OM_BLOCK_MOVE ( &crsobj[0], &crsobj[1], sizeof(struct GRlc_info) );
     OM_BLOCK_MOVE ( &crsopt[0], &crsopt[1], sizeof(IGRpoint) );
     OM_BLOCK_MOVE ( &crsang[0], &crsang[1], sizeof(IGRdouble) );

     num_cr = 1;
     num_cross = 2;
  }
  else
     num_cr = num_cross;

  /* calculate the cross-section surface */
  {
     struct     IGRbsp_curve **cross_sections, **comp_cross_sections, **trace_curves, **crvs_p;
     struct     IGRpolyline poly;
     IGRpoint   *hu_points, pt1;
     IGRdouble  *param = NULL;
     IGRdouble  refpln[12], vec[3];
     IGRboolean all_on_curve;
     IGRint     num_crvs;
     IGRint     att_method, blnd_type, gen_type, action, mirror;
     BSrc       rc;

     /* Initialize */
     rc = BSSUCC;
     cross_sections = NULL;
     comp_cross_sections = NULL;
     trace_curves = NULL;
     crvs_p = NULL;
     hu_points = NULL;
     action = 1;
     gen_type = 1;

     /* get constant data */
     OM_BLOCK_MOVE (&info->refpln,&refpln,(sizeof(IGRdouble) *12) ); 
     OM_BLOCK_MOVE (&info->dirvec,&vec,(sizeof(IGRdouble) *3) ); 
     mirror = info->mirror_case;
     if (info->att_method_props & EMS_FIRST_ATTCH)
        att_method = 1;
     else if (info->att_method_props & EMS_SECOND_ATTCH)
        att_method = 2;
     else
        /* method 3 not implemented */
        att_method = 4;

     if (info->cross_surf_props & EMS_IS_BLEND_TYPE_PARAMETER)
        blnd_type = 1;
     else
        blnd_type = 2;

     /* Allocate space for the cross sections */
     cross_sections = (struct IGRbsp_curve **) stackalloc ( num_cross * sizeof(struct IGRbsp_curve *));
      EMerr_hndlr(!cross_sections, *EMmsg, MANOMEMORY, wrapup);
     for (i = 0; i < num_cross; i++) cross_sections[i] = NULL;

     comp_cross_sections = (struct IGRbsp_curve **) stackalloc ( num_cross * sizeof(struct IGRbsp_curve *));
      EMerr_hndlr(!cross_sections, *EMmsg, MANOMEMORY, wrapup);
     for (i = 0; i < num_cross; i++) comp_cross_sections[i] = NULL;

     /* get the cross-section geometry */
     for (i = 0; i < num_cross; i++)
     {
        sts = EMget_the_geometry(&crsobj[i], TRUE, TRUE, FALSE,
                                 crsobj[i].located_obj.objid, &cross_sections[i], &msg_loc);
        EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);

        /* arclength parametrization, we do this here - and not after make_compatible - because of
        minimizing the number of knots */
        if (smooth)
        {
           BSarclnparc(&rc,cross_sections[i]);
           EMerr_hndlr((rc != BSSUCC), *EMmsg, MSFAIL, wrapup);
        }
     }  

     /* Allocate space for the trace curves */
     trace_curves = (struct IGRbsp_curve **) stackalloc ( num_trace * sizeof(struct IGRbsp_curve *));
      EMerr_hndlr(!trace_curves, *EMmsg, MANOMEMORY, wrapup);
     for (i = 0; i < num_trace; i++) trace_curves[i] = NULL;

     /* Get the trace curve geometry */
     for (i = 0; i < num_trace; i++)
     {
        sts = EMget_the_geometry(&trcobj[i], TRUE, TRUE, FALSE,
                                 trcobj[i].located_obj.objid, &trace_curves[i], &msg_loc); 
        EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
     } 

     /* Allocate space for the hangup points */
     hu_points = (IGRpoint *) stackalloc ( num_cross * sizeof(IGRpoint));
      EMerr_hndlr(!hu_points, *EMmsg, MANOMEMORY, wrapup);
     for (i = 0; i < num_cr; i++) *hu_points[i] = NULL;

     poly.points = pt1;  /* allocates storage */

     /* get the points geometry */
     for (i = 0; i < num_cr; i++)
     {
        sts = om$send ( msg = message GRlinear.GRgetpolyline ( &msg_loc,
                               &trcloc[i].module_info.md_env.matrix_type,
                               trcloc[i].module_info.md_env.matrix, &action,
                               &poly),
                   senderid = NULL_OBJID,
                   targetid = trcloc[i].located_obj.objid,
                   targetos = trcloc[i].located_obj.osnum );
        EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
        OM_BLOCK_MOVE ( &pt1[0], &hu_points[i], sizeof (IGRpoint) );
     }

     /* Allocate space for the parameter values */
     param = (IGRdouble *) stackalloc ( num_cross * sizeof(IGRdouble));
      EMerr_hndlr(!param, *EMmsg, MANOMEMORY, wrapup);

     /* get the parameter values of hangup points */
     BSprptsoncv ( num_cr, hu_points, trace_curves[0], param, &all_on_curve, &rc);
      EMerr_hndlr((rc != BSSUCC), *EMmsg, MSFAIL, wrapup);

     /* put a duplicate cross_section at the end of trace, if num_cross == 1 */
     if (num_cr == 1)
        param[1] = 1.0;

     /* make cross_sections compatible */
     BSmkcvscp( (IGRint) num_cross, cross_sections, comp_cross_sections , &rc);
     EMerr_hndlr((rc != BSSUCC), *EMmsg, MSFAIL, wrapup);

     /* get the blended cross-sections  */
     BSblndxsect ( refpln, (IGRint) num_cross, comp_cross_sections, (IGRdouble *)crsopt, trace_curves[0],
                   param, att_method, vec, NULL, srf, mirror, crsang,
                   blnd_type, gen_type, NULL, NULL, &num_crvs, &crvs_p,
                   NULL, &wrkarea, &rc);
      EMerr_hndlr((rc != BSSUCC), *EMmsg, MSFAIL, wrapup);

     /* get the surface definition */
     BSmvxsectrc( (IGRint) num_trace, &trace_curves[0], num_crvs, crvs_p,
                   TRUE,                    /* on site */
                   FALSE,                   /* no_height_scaling */
                   NULL,                    /* trace parameters */
                   TRUE,                    /* absolute_orientation */
                   NULL,                    /* view matrix */
                   NULL,                    /* origins */
                   NULL,                    /* x axis */
                   NULL,                    /* y axis */
                   FALSE,                   /* constant direction */
                   FALSE,                   /* surface_is_open */
                   FALSE,                   /* no shape_law */
                   NULL,
                   FALSE,                   /* no orient_law */
                   NULL,
                   NULL,                    /* no tangent_sf[0] */
                   NULL,                    /* no tangent_sf[1] */
                   NULL,                    /* no tangent_sf[2] */
                   NULL,                    /* no tangent_sf[3] */
                   &surface,
                   &rc);

     EMerr_hndlr((rc != BSSUCC), *EMmsg, MSFAIL, wrapup);
  }
    construct_list->geometry = (IGRchar *)surface;
    construct_list->newflag = FALSE;

    /* now construct the surface */
    sts = om$construct (osnum = trcobj[0].located_obj.osnum,
                      classid = OPP_EMAgenbs_class_id,
                      p_objid = &surf_objid,
                      msg = message GRgraphics.GRconstruct(construct_list));
    EMerr_hndlr (!(1&sts), *EMmsg, MSFAIL, wrapup);

    *mod_new_id = new_objid = surf_objid;
#ifdef DEBUG
  if (1&sts) {
   printf ("CSecsurf successful\n");
  }
#endif

wrapup:
  if (wrkarea)
     BSstackdealloc ( (char *) wrkarea);

  if (surface)
  {
    sts = BSfreesf( &msg_loc, surface);
  }
  if (!(1&sts))
    return EMS_E_Fail;
  else 
    return EMS_S_Success;
}

end implementation Root;
