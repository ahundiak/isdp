/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
		
 	This function optimizes the class for surface of revolution.
     Note "The curve element and the axis line have to be planar".
     Depending on the input curve's properties and the position of
     the axis line  in relation to the curve it refines the original
     class EMSrevol to the following classes:

     New class				Input conditions
     --------- 	 	        ----------------
	 1) EMStorus			If curve is a circle and revolution 
							 angle = 360.0.

       1.5) EMSptorus			If curve is an arc and axis does not
							 pass thru centre

	 2) EMSpcone			If curve is a line segment & revolution
							 angle < 360.0.
	  
 	 3) EMScone				If curve is a line segment & revolution
							 angle == 360.0.
	
	 4) EMSpcylindr			If curve is a line segment, parallel to 
							 axis line and revolution angle < 360.0.

	 5) EMScylindr			If curve is a line segment, parallel to
							 axis line and revolution angle == 360.0.

	 6) EMSsphere			If curve is a half circle, with it's end
							 points along the axis line and revolution
							 angle == 360.0.

       6.5) EMSpsphere			If curve is an arc and the axis passes
							 thru centre.

	 7) EMSsphere			If curve is a half ellipse, with it's end
							 points along the axis line and revolution
							 angle == 360.0.

NOTES
=====

ARGUMENTS
=========
	
VARIABLE      TYPE					 MODE	 DESCRIPTION
--------      ----   	 		     ----    -----------
EMmsg	     (IGRlong *)			 Output  Return status, return status
										      other than EMS_S_Success 
											  implies failure.

curve_info   (struct GRlc_info *)	 Input   Locate info of the curve.

curve_struct (struct IGRbsp_curve *) Input   Curve structure.

axis_line    (IGRdouble *)		     Input   Two points defining the axis
											  line.

is_full_
 revolution  (IGRin)   		         Input   Non zero implies ~360.0.

classid 	 (OMuword *)			 Input   New class id.
	

HISTORY
=======

        Sudha           08-jul-93       Modified for BSprototypes ansification	
        Jack            11-Jun-93       Added a condition for doing my
                                        last fix.  Also replaced use of
                                        _create_special_partial_surfaces
                                        with WANT_POST220_BEHAVIOR.
        Jack            23-Jan-93       Added else to allow creation of
                                        a partial torus when a circle is
                                        revolved less than 360 degrees.
        PP              23-June-89      Fixed a problem which shows up
                                        when a curve buffer is passed.See
                                        comments below.
	SAM		17-Feb-88	Creation.
*/
class implementation Root;

#include "EMS.h"

#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

/* igr.h replacement */
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif
/* end of igr.h replacement */

/* gr.h replacement */
# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif
/* end of gr.h replacement */

#include <stdio.h>
%safe
#include <math.h>
%endsafe
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "EMSmsgdef.h"
#include "bsunwght_p.h"
#include "bstst_plan.h"
#include "bsdistptli.h"

extern OMuword OPP_EMSrevol_class_id, OPP_EMStorus_class_id,
                           OPP_EMSptorus_class_id,
			   OPP_EMSelpsoid_class_id, OPP_EMSsphere_class_id,
                           OPP_EMSpsphere_class_id,
			   OPP_EMScone_class_id, OPP_EMSpcone_class_id,
			   OPP_EMScylindr_class_id, OPP_EMSpcylindr_class_id;

from GRconic import GRgetarc;
from GRvg import GRgetsize, GRgetgeom;

extern IGRboolean WANT_POST220_BEHAVIOR;

IGRlong EFget_surface_of_revolution_class(
 EMmsg,
 curve_info,
 curve_struct,
 axis_line,
 is_full_revolution,
 classid)

IGRlong *EMmsg;
struct GRlc_info *curve_info;
struct IGRbsp_curve *curve_struct;
IGRdouble axis_line[2][3];
IGRint is_full_revolution;
OMuword			*classid;
{
 IGRpoint plane_normal;
 IGRuchar edge_type;
 IGRboolean is_planar;
 struct IGRplane plane;
 struct IGRbsp_curve *curve = NULL;
 IGRlong EFget_the_edge_type_for_an_object(), sts, mthd_stat, rc, 
	     curve_size;
 IGRdouble *poles_buff = NULL;

 GRobjid objid;
 GRspacenum osnum;
 struct GRmdenv_info *grmdenv_info = NULL;

 sts = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 *classid = OPP_EMSrevol_class_id;
 edge_type = EMfreeform_curve;
 plane.normal = &plane_normal[0];
 
/*
 EMerr_hndlr((!curve_struct) || (!curve_info), *EMmsg, EMS_E_InvalidArg,
*/

/* Begin pp */

 EMerr_hndlr((!curve_struct) && (!curve_info), *EMmsg, EMS_E_InvalidArg,
             wrapup);
/* end pp  */

 if(curve_struct) curve = curve_struct;

 if(curve_info)
 {
  objid = curve_info->located_obj.objid;  
  osnum = curve_info->located_obj.osnum;
  grmdenv_info = &(curve_info->module_info.md_env);

  sts = EFget_the_edge_type_for_an_object(
			objid,
			osnum,
			NULL,
			&edge_type);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_CurveError, wrapup);
  if(!curve)
  {
   sts = om$send(msg = message GRvg.GRgetsize(
		    			  &mthd_stat,
					      &(grmdenv_info->matrix_type),
						  grmdenv_info->matrix,
	  					  &curve_size),
				 senderid = NULL_OBJID,
				 targetos = osnum,
			     targetid = objid);
   EMerr_hndlr(!(1&sts&mthd_stat), *EMmsg, EMS_E_CurveError, wrapup);
  
   curve = (struct IGRbsp_curve *) om$malloc(size = curve_size);
   EMerr_hndlr(!curve, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

   sts = om$send(msg = message GRvg.GRgetgeom (
						  &mthd_stat,
						  &(grmdenv_info->matrix_type),
						  grmdenv_info->matrix,
						  (IGRchar *) curve),
			     senderid = NULL_OBJID,
				 targetos = osnum,
			     targetid = objid);
   EMerr_hndlr(!(1&sts&mthd_stat), *EMmsg, EMS_E_CurveError, wrapup);
  }
 }

 if((curve->order ==2) && (curve->num_poles == 2) && (!curve->rational))
   edge_type = EMlinesegment;


 if( (edge_type == EMlinesegment)  || (edge_type == EMcircle) || 
     (edge_type == EMcircular_arc) || ( edge_type == EMelliptical_arc) )
 {
  IGRlong npoles = curve->num_poles;
  poles_buff = (IGRdouble *) om$malloc(size = (npoles+2) * sizeof(IGRpoint));
  EMerr_hndlr(!poles_buff, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 
  if(!curve->rational) OM_BLOCK_MOVE(curve->poles, poles_buff, 
									sizeof(IGRpoint)*npoles);
  else
  {
   sts = BSunwght_p(&rc,curve->poles, curve->weights, &npoles,
 				    poles_buff);
   EMerr_hndlr(!sts, *EMmsg, EMS_E_BSerror, wrapup);
  }
 
  OM_BLOCK_MOVE(axis_line, &poles_buff[3*npoles], 
				 sizeof(IGRpoint)*2);

  BStst_plan(npoles + 2, poles_buff, NULL, &is_planar, 
			 plane.normal, &rc);
  EMerr_hndlr(!(rc == BSSUCC), *EMmsg, EMS_E_BSerror, wrapup);
  
  if(!is_planar) goto wrapup;
  else
  {
   if(edge_type == EMcircle)
   { /* It shouldn't come so far with curve_struct & ~curve_info */
	if(is_full_revolution) *classid = OPP_EMStorus_class_id;
        else if( WANT_POST220_BEHAVIOR )
                *classid = OPP_EMSptorus_class_id;
   }
   else
   {
    IGRdouble dist_tol, dist_tolsq, min_dist1, min_dist2, pt1_pt2_distsq;
    IGRboolean status_val;


    BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
	dist_tolsq = dist_tol * dist_tol;

    status_val = BSdistptli(&rc, &poles_buff[0],
							&axis_line[0][0], &axis_line[1][0], 
							&min_dist1);
    EMerr_hndlr(!status_val||!(rc==BSSUCC),*EMmsg,EMS_E_BSerror,wrapup);

    status_val = BSdistptli(&rc, &poles_buff[(npoles-1)*3], 
						    &axis_line[0][0],&axis_line[1][0], 
						    &min_dist2);
    EMerr_hndlr(!status_val||!(rc==BSSUCC),*EMmsg,EMS_E_BSerror,wrapup);

    pt1_pt2_distsq = (poles_buff[0] - poles_buff[((npoles-1)*3)+0])*
					  (poles_buff[0] - poles_buff[((npoles-1)*3)+0]) +
				     (poles_buff[1] - poles_buff[((npoles-1)*3)+1])* 
					  (poles_buff[1] - poles_buff[((npoles-1)*3)+1]) +
				     (poles_buff[2] - poles_buff[((npoles-1)*3)+2])* 
					  (poles_buff[2] - poles_buff[((npoles-1)*3)+2]);

    if(edge_type == EMlinesegment)
    { 
     if(fabs
            ((min_dist1-min_dist2)*(min_dist1-min_dist2)-pt1_pt2_distsq)
              < dist_tolsq
       ) goto wrapup;

     *classid = OPP_EMSpcone_class_id;
     if(is_full_revolution)
      *classid = OPP_EMScone_class_id;

     if(fabs(min_dist1 - min_dist2) < dist_tol)
     {
      if(is_full_revolution)
       *classid = OPP_EMScylindr_class_id;
      else
       *classid = OPP_EMSpcylindr_class_id;
     }
    }
    else /* edge_type == EMelliptical_arc || EMcircular_arc. */
    {   /* It shouldn't come this far with ~curve_info */

     if(is_full_revolution && (min_dist1<dist_tol)&&(min_dist2<dist_tol))
     {
	  IGRdouble min_distcen;
	  struct IGRarc arc;

	  sts = om$send(msg = message GRconic.GRgetarc(
							&mthd_stat,
							&(grmdenv_info->matrix_type),
							grmdenv_info->matrix,
							&arc),
 				    senderid = NULL_OBJID,
					targetid = objid,
					targetos = osnum);
	  EMerr_hndlr(!(1&sts&mthd_stat), *EMmsg, EMS_E_CurveError, wrapup);
	 
      status_val = BSdistptli(&rc, arc.origin, 
							 &axis_line[0][0], &axis_line[1][0], 
							 &min_distcen);
    EMerr_hndlr(!status_val||!(rc==BSSUCC),*EMmsg,EMS_E_BSerror,wrapup);
	
	  if(min_distcen > dist_tol) goto wrapup;
     
      if(edge_type == EMcircular_arc)
      {
	   if(fabs(pt1_pt2_distsq - (4 * arc.prim_axis * arc.prim_axis)) 
			  < dist_tolsq)
        *classid = OPP_EMSsphere_class_id;
      }
      else /* edge_type == EMelliptical_arc */
	  {
       if( (fabs(pt1_pt2_distsq - (4 * arc.prim_axis * arc.prim_axis))
                < dist_tolsq)
          ||
           (fabs(pt1_pt2_distsq - (4 * arc.sec_axis * arc.sec_axis))
                < dist_tolsq)
         )
         *classid = OPP_EMSelpsoid_class_id;
      }
     } /* arc end pts on the axis and is_full_revolution */
    else if (WANT_POST220_BEHAVIOR && edge_type == EMcircular_arc)
     {
      IGRdouble min_distcen;
      struct IGRarc arc;

      sts = om$send(msg = message GRconic.GRgetarc (&mthd_stat,
             &grmdenv_info->matrix_type, grmdenv_info->matrix, &arc),
             senderid = NULL_OBJID, targetid = objid, targetos = osnum);
      EMerr_hndlr (EMSerror (sts & mthd_stat), *EMmsg, EMS_E_CurveError,
       wrapup);
	 
      status_val = BSdistptli (&rc, arc.origin,
                    &axis_line[0][0], &axis_line[1][0], &min_distcen);
      EMerr_hndlr (!status_val || rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (min_distcen > dist_tol)
        *classid = OPP_EMSptorus_class_id;
      else
        *classid = OPP_EMSpsphere_class_id;
     } /* WANT_POST220_BEHAVIOR && edge_type == EMcircular_arc */
    } /* edge_type == EMcircular_arc || EMelliptical_arc */
   } /* edge_type == EMlinesegment ||EMcircular_arc ||EMelliptical_arc */
  } /* Curve and the Axis are planar */
 } /* edge_type == circle || lineseg || circular arc || elliptical arc */


wrapup:

if(poles_buff)             om$dealloc(ptr = poles_buff);
if(!curve_struct && curve) om$dealloc(ptr = curve);

EMWRAPUP(*EMmsg, sts, "In EFsfrevclass.I ");

return(sts);

}
end implementation Root;

