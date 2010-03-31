
/*
  OVERVIEW

    The functions below are used to construct surface objects and B-spline
    surface geometries. In the latter, given the analytical definition of a
    surface the functions available in this file will construct an equivalent
    BS definition for the surface. 

  NOTES

    Required memory must be allocated by the caller.
*/

class implementation EMSsubbs;

/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>
#include <alloca.h>

#include "igrtypedef.h"
#include "igr.h"               /* BS */
#include "bs.h"                
#include "gr.h"
#include "grdpbdef.h"

#include "PWminimum.h"         /* Pathway */
#include "PWerror.h"         
#include "PWgmdata.h"         

/* Prototypes */

#include "bsvalues.h"
#include "bsparallogr.h"
#include "bscylinder1.h"
#include "bsrttrncon1.h"
#include "bsprepsphr.h"
#include "bstoraxctrd.h"
#include "bssf_proj.h"
#include "bssf_rev.h"
#include "bsellcylcon.h"
#include "bsptonnsdsf.h"

#include "bsorthovec.h"
#include "bsprepcarc.h"
#include "bsprepcirc.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#include "PWapi/sfcons.h"
#include "PWapi/mkvec.h"
#include "PWapi/dotp.h"
#include "PWapi/crossp.h"
#include "PWapi/normvec.h"
#include "PWapi/cvgeom.h"
#include "PWapi/revvec.h"
/*
#include "PWapi/sfinit.h"
*/
#include "PWapi/objcons.h"
#include "PWapi/objdel.h"
#include "PWapi/sftype.h"
#include "PWapi/dpquery.h"
#include "PWapi/symb.h"

/*
  DESCRIPTION

  The following function creates a surface object out of the B-spline geometry
  provided. The class of the surface object construct is decided by the
  "sftype" argument that is input. The various types are defined in the
  include file -- "bsgeom_cvsf.h". The type of BSGEN_BSP_SF will always work,
  since any geometry can be housed inside an object of this generic class.

  The caller needs to check for a PW_K_NullObjid being returned as a 
  means of tracking any error during the construction.
*/

PWobjid pwCreateSfObj
( 
 struct IGRbsp_surface *pSurfGeom,
 int sftype,
 PWosnum osnum
)
{
  long LongRc=EMS_S_Success;
  PWresult status=PW_K_Success;
  short  ActLayr=0,Action=0,Props=0;
  PWobjid SfObj=PW_K_NullObjid;
  struct IGRdisplay ActDisplay;
  	
  struct GRmd_env ModuleInfo;  	
  struct GRpost_info PostInfo;

  struct GRsymbology ActiveSymb;
  PWobjid NewId=PW_K_NullObjid;
  PWclassid  sfclass = 0;

  status = pwGetDpbParam(osnum, grdpb_active_level,(IGRchar *)&ActLayr);
  status = pwGetDpbParam(osnum, grdpb_module_env,(IGRchar *)&ModuleInfo);
  status = pwGetDpbParam(osnum, grdpb_active_display,(IGRchar *)&ActDisplay);

  sfclass = pwSfClassid(sftype);
		
  SfObj = omCreateObjFromClassid(osnum, sfclass);
  OnErrorState (SfObj == PW_K_NullObjid,  status, SetError (PW_K_Pathway, 
                 PW_K_Internal), wrapup);


  // Initialize symbology 

  ActiveSymb.level = ActLayr;
  ActiveSymb.display_attr = ActDisplay;
  
  status = pwPutSymb(SfObj, osnum, &ActiveSymb); 

  PostInfo.construct_flag = FALSE;

  status = om$send( msg = message EMSsubbs.EMinitInstance(&LongRc,
						  &ModuleInfo,
						  &PostInfo,
						  (char *)pSurfGeom,
						  &NewId),
        	senderid = NULL_OBJID,
		targetid = SfObj,
		targetos = osnum);
  OnErrorState (IsError (status&LongRc), status, SetError (PW_K_Pathway, 
                PW_K_Internal), wrapup);

  if (NewId != PW_K_NullObjid && NewId != SfObj)
  {
    omDeleteObject (SfObj, osnum);
    SfObj = NewId;     
  }

  Action = 1;      	 	
  Props  = GRIS_LOCATABLE|GRIS_DISPLAYABLE;

  status = om$send ( msg = message GRgraphics.GRchgprops( &LongRc, 
							 &Action,
							 &Props ),
		    senderid = NULL_OBJID,
		    targetid = SfObj,
		    targetos = osnum );
  OnErrorState (IsError (status&LongRc), status, SetError (PW_K_Pathway, 
                PW_K_Internal), wrapup);

wrapup:
  if (IsError (status & LongRc) && SfObj != PW_K_NullObjid)
  {
    omDeleteObject (SfObj, osnum);
    SfObj = PW_K_NullObjid;
  }
  return  SfObj;
}


/*
  DESCRIPTION

    Returns the B-spline representation of a bounded plane given two points 
    defining the base of the plane and a height point. The vertices of the 
    plane will contain all these three points.

  NOTES
  
    All the memory for the output surface must be allocated by the caller. 
    Caller should allocate memory required for : 
      u_num_poles : 2, v_num_poles : 2 , u_order : 2, v_order : 2 and 
      non-rational i.e. rational=0

    The natural normal of the surface is : (basept1-basept2) *
                                           (heightpt-basept2)
*/

PWresult pwCreatePlaneBsp
(
  PWpoint basept1,
  PWpoint basept2,
  PWpoint heightpt,
  struct IGRbsp_surface *p_plane
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;

  BSparallogr (basept1, basept2, heightpt, p_plane, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  p_plane->pos_orient = TRUE;

wrapup : 

  PW_Wrapup (PWsts, "pwCreatePlaneBsp");
  return PWsts;
}


/*
  DESCRIPTION

    Returns the B-spline representation of a bounded cylinder given base
    center and top center defining the height and the axis and the radius
    of the cylinder. 

  NOTES

    All the memory for the output surface must be allocated by the caller. 
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 2 , u_order : 3, v_order : 2 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing towards the axis
    of revolution, then pos_orient is TRUE otherwise it is FALSE.
*/

PWresult pwCreateCylinderBsp
(
  PWpoint base_center,
  PWpoint top_center,
  double  radius,
  struct IGRbsp_surface *p_cylinder
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean natside=FALSE;

  BScylinder1 (&BSmsg, base_center, top_center, &radius, p_cylinder);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  p_cylinder->pos_orient = TRUE;

  BSptonnsdsf (p_cylinder, base_center, &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  if (!natside)
    p_cylinder->pos_orient = FALSE;
  else
    p_cylinder->pos_orient = TRUE;

wrapup : 

  PW_Wrapup (PWsts, "pwCreateCylinderBsp");
  return PWsts;
}

/*
  DESCRIPTION

    Returns the B-spline representation of a bounded cone given base center 
    and top center (defining the height and the axis) and the base and top
    radii.

  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 2 , u_order : 3, v_order : 2 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing towards the axis
    of revolution, then pos_orient is TRUE otherwise it is FALSE.
*/

PWresult pwCreateConeBsp
(
  PWpoint base_center,
  PWpoint top_center,
  double  base_radius,
  double  top_radius,
  struct IGRbsp_surface *p_cone
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean natside=FALSE;

  BSrttrncon1 (base_center, top_center, base_radius, top_radius, p_cone, 
               &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  p_cone->pos_orient = TRUE;

  BSptonnsdsf (p_cone, ((base_radius > top_radius) ? base_center : top_center),
               &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  if (!natside)
    p_cone->pos_orient = FALSE;
  else
    p_cone->pos_orient = TRUE;

wrapup :

  PW_Wrapup (PWsts, "pwCreateConeBsp");
  return PWsts;
}

/*
  DESCRIPTION

    Returns the B-spline representation of a bounded elliptical cylinder 
    given base center and top center defining the height and the major 
    axis point defining the major axis and the major radius and  minor 
    axis point defining the minor axis and the minor radius of the base
    ellipse.

  NOTES

    All the memory for the output surface must be allocated by the caller. 
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 2 , u_order : 3, v_order : 2 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing towards the axis
    of revolution, then pos_orient is TRUE otherwise it is FALSE.
*/

PWresult pwCreateElpCylinderBsp
(
  PWpoint  base_center,
  PWpoint  top_center,
  PWpoint  major_axispt,
  PWpoint  minor_axispt, 
  struct IGRbsp_surface *p_elpcylinder
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWpoint heightpt={0.0,0.0,0.0};
  PWboolean natside=FALSE;

  pwMakeVec (base_center, top_center, heightpt);

  BSellcylcon (base_center, major_axispt, minor_axispt, heightpt, (double) 1, 
               p_elpcylinder, &BSmsg); 
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway, 
                PW_K_InvalidArg), wrapup);

  p_elpcylinder->pos_orient = TRUE;

  BSptonnsdsf (p_elpcylinder, base_center, &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  if (!natside)
    p_elpcylinder->pos_orient = FALSE;
  else
    p_elpcylinder->pos_orient = TRUE;

wrapup : 

  PW_Wrapup (PWsts, "pwCreateElpCylinderBsp");
  return PWsts;
}

/*
  DESCRIPTION

    Returns the B-spline representation of a bounded elliptical cone 
    given base center and top center defining the height and the major 
    axis point defining the major axis and the major radius and  minor 
    axis point defining the minor axis and the minor radius of the base
    ellipse. The scale is the ratio of the top major axis and base major
    axis.

  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 2 , u_order : 3, v_order : 2 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing towards the axis
    of revolution, then pos_orient is TRUE otherwise it is FALSE.
*/

PWresult pwCreateElpConeBsp
(
  PWpoint  base_center,
  PWpoint  top_center,
  PWpoint  major_axispt,
  PWpoint  minor_axispt,
  double   scale,
  struct IGRbsp_surface *p_elpcone
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWpoint heightpt={0.0,0.0,0.0};
  PWboolean natside=FALSE;

  pwMakeVec (base_center, top_center, heightpt);

  BSellcylcon (base_center, major_axispt, minor_axispt, heightpt, scale,
               p_elpcone, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  p_elpcone->pos_orient = TRUE;

  BSptonnsdsf (p_elpcone, base_center, &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  if (!natside)
    p_elpcone->pos_orient = FALSE;
  else
    p_elpcone->pos_orient = TRUE;

wrapup :

  PW_Wrapup (PWsts, "pwCreateElpConeBsp");
  return PWsts;
}

/*
  DESCRIPTION

    Returns the B-spline representation of a bounded sphere given center 
    and radius of the sphere.

  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 5, v_num_poles : 7 , u_order : 3, v_order : 3 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing towards the axis
    of revolution, then pos_orient is TRUE otherwise it is FALSE.
*/

PWresult pwCreateSphereBsp
(
  PWpoint center,
  double  radius,
  struct IGRbsp_surface *p_sphere
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;
  PWboolean natside=FALSE;

  BSsts = BSprepsphr (&BSmsg, center, &radius, p_sphere);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  p_sphere->pos_orient = TRUE;

  BSptonnsdsf (p_sphere, center, &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  if (!natside)
    p_sphere->pos_orient = FALSE;
  else
    p_sphere->pos_orient = TRUE;

wrapup :

  PW_Wrapup (PWsts, "pwCreateSphereBsp");
  return PWsts;
}

/*
  DESCRIPTION

    Returns the B-spline representation of a bounded torus given base center, 
    base radius (defining the base circle i.e. generating curve) and the torus
    axis points. 
    
  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 7 , u_order : 3, v_order : 3 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing center of the 
    base circle (generating circle), then pos_orient is TRUE otherwise it 
    is FALSE.
*/

PWresult pwCreateTorusBsp
(
  PWpoint base_center, 
  double  base_radius,
  PWpoint tor_axispt1,
  PWpoint tor_axispt2,
  struct IGRbsp_surface *p_torus
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean natside=FALSE;

  BStoraxctrd (base_radius, base_center, tor_axispt1, tor_axispt2, p_torus, 
               &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  p_torus->pos_orient = TRUE;

  BSptonnsdsf (p_torus, base_center, &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  if (!natside)
    p_torus->pos_orient = FALSE;
  else
    p_torus->pos_orient = TRUE;

wrapup :

  PW_Wrapup (PWsts, "pwCreateTorusBsp");
  return PWsts;
}


/*
  DESCRIPTION

    Returns the B-spline representation of a bounded cylinder given base
    center and top center defining the height and the axis and the radius
    of the cylinder.

  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 2 , u_order : 3, v_order : 2 and
      rational i.e. rational=1

    The natural normal of the surface : U X V, Generating curve always forms
    the U-Curve on the surface.
*/

PWresult pwCreateProjSfBsp
(
  struct IGRbsp_curve *p_cv,
  PWpoint axispt1,
  PWpoint axispt2,
  struct IGRbsp_surface *p_sfproj
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;

  BSsts = BSsf_proj (&BSmsg, p_cv, axispt1, axispt2, p_sfproj);
  OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  p_sfproj->pos_orient = TRUE;

wrapup :

  PW_Wrapup (PWsts, "pwCreateProjSfBsp");
  return PWsts;
}


/*
  DESCRIPTION

    Returns the B-spline representation of a bounded cylinder given base
    center and top center defining the height and the axis and the radius
    of the cylinder.

  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 2 , u_order : 3, v_order : 2 and
      rational i.e. rational=1

    The natural normal of the surface : U X V, Generating curve always forms
    the U-Curve on the surface.
*/

PWresult pwCreateRevSfBsp
(
  struct IGRbsp_curve *p_cv,
  PWpoint axispt1,
  PWpoint axispt2,
  PWboolean full,
  double stang,
  double swang,
  struct IGRbsp_surface *p_sfrev
)
{
  PWresult PWsts=PW_K_Success;
  BSrc BSmsg=BSSUCC;
  PWboolean BSsts=TRUE;

  BSsts = BSsf_rev (&BSmsg, axispt1, axispt2, p_cv, &full, full ? NULL : &stang,
                    full ? NULL : &swang, p_sfrev);
  OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  p_sfrev->pos_orient = TRUE;

wrapup :

  PW_Wrapup (PWsts, "pwCreateRevSfBsp");
  return PWsts;
}


/*
  DESCRIPTION

    Returns the B-spline representation of a bounded torus given torus center,
    torus axis, torus radius (major radius), base_radius (defining the base
    circle i.e. the generating curve). 

    The torus radius can be smaller than base radius. In which case, there two
    possible outputs : 1 - An Apple, 2 - A Lemon. The sign of torus radius 
    differentiates these two cases. If the torus radius is +ve it is an "Apple" 
    otherwise it is a "Lemon". If the torus radius is equal to the base radius
    it will error out.
 
  NOTES

    All the memory for the output surface must be allocated by the caller.
    Caller should allocate memory required for :
      u_num_poles : 7, v_num_poles : 7 , u_order : 3, v_order : 3 and
      rational i.e. rational=1

    If the natural normal of the output surface is pointing inwards, then 
    pos_orient is TRUE otherwise it is FALSE.
*/

PWresult pwCreateTorusBsp1
(
  PWpoint tor_center,
  PWvector tor_axis,
  double tor_radius,
  double base_radius,

  struct IGRbsp_surface *p_torus
)
{
  PWresult PWsts=PW_K_Success;
  PWboolean BSsts=TRUE;
  BSrc BSmsg=BSSUCC;

  int i=0;
  PWvector orthovec;
  PWpoint base_center, insidept;
  PWboolean natside=FALSE;
  
  double raddiff=0.0;
  double bastol=0.0;

  BSEXTRACTPAR ( &BSmsg, BSTOLBASIS, bastol);

  BSsts = BSorthovec (&BSmsg, tor_axis, orthovec);
  OnErrorState (!BSsts || BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);

  pwNormVec (orthovec, orthovec);

  for (i=0; i<3; i++)
    base_center[i] = tor_center[i] + orthovec[i] * fabs (tor_radius);

  /* if (fabs (tor_radius) <= fabs(base_radius)) */
  raddiff = fabs(base_radius) - fabs(tor_radius);

  if ((fabs(raddiff) < bastol && raddiff <= 0.0) || 
       fabs (tor_radius) < fabs(base_radius))
  {
    PWpoint startpt, endpt, axispt;
    PWvector cs, ce, normal, unit_normal, vec;
    double dotp=0, ang=0, genrad=0;
    struct IGRbsp_curve arc;
    PWboolean full=TRUE;

    /*
     * get the intersection points of the base circle with the axis of 
     * revolution.
     */

    genrad = sqrt ((base_radius * base_radius) - (tor_radius * tor_radius));
    for (i=0; i<3; i++)
    {
      startpt[i] = tor_center[i] + tor_axis[i] * genrad;  
      endpt[i] = tor_center[i] - tor_axis[i] * genrad;  
    }

    /*
     * normal to the base circle : Cross product of torus axis and a vector in 
     * the plane of the base circle.
     */

    pwCross (tor_axis, orthovec, normal);
    pwNormVec (normal, normal);

    /*
     * Normal to the base circle should be pointing in such a way that the
     * right part of arc is generated. Make sure that, it points in the right
     * direction by looking at the sign of torus radius and the sweep angle of 
     * the generating arc. If the sign of the torus radius is "+ ve" then the
     * angle of the generating arc should be greater than 180 deg and if it
     * is "-ve" it the angle should be less than 180 deg. 
     */

    pwMakeVec (base_center, startpt, cs);
    pwMakeVec (base_center, endpt, ce);
    dotp = pwDot (cs, ce) / (base_radius * base_radius);
    if (dotp < -1)
      dotp = -1;
    else if (dotp > 1)
      dotp = 1;
    
    ang = acos (dotp);
  
    cs[0] /= base_radius; cs[1] /= base_radius; cs[2] /= base_radius;

    pwCross (normal, cs, vec);
    pwNormVec (ce, ce);

    ang = (pwDot (vec, ce) >= 0) ? ang : (2 * M_PI - ang);
    
    if ((tor_radius > 0.0 && ang < M_PI) || (tor_radius < 0.0 && ang > M_PI))
    {
      pwRevVec (normal, normal);
    }

    /*
     * Create the generating arc.
     */
    PWsts = PW_AllocBspCvStack (BSCIRCLE_NUM_POLES_MAX, BSCIRCLE_ORDER, TRUE,
                                arc);
    OnErrorCode (PWsts, wrapup);

    if ((fabs(base_radius) - fabs(tor_radius)) < bastol)
    {
      /*
       * Vortex case degeneracy
       */
      double temprad=0.0;

      temprad = fabs(base_radius);
      BSsts = BSprepcirc (&BSmsg, base_center, &temprad, normal,
                          &arc, unit_normal, NULL);
      OnErrorState (BSERROR (BSmsg), PWsts,
                    SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
    }
    else
    {
      /*
       * Apple and lemon case degeneracy
       */
      BSsts = BSprepcarc (&BSmsg, startpt, base_center, endpt, normal, &arc, 
                          unit_normal, NULL);
      OnErrorState (BSERROR (BSmsg), PWsts,
                    SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);
    }

    for (i=0; i<3; i++)
      axispt[i] = tor_center[i] + tor_axis[i];

    /*
     * Create the full surface of revolution by using this generating arc.
     */

    BSsts = BSsf_rev (&BSmsg, tor_center, axispt, &arc, &full, NULL, NULL, 
                      p_torus); 
    OnErrorState (BSERROR (BSmsg), PWsts,
                  SetError (PW_K_Pathway, PW_K_InvalidArg), wrapup);

    memcpy (insidept, tor_center, sizeof (PWpoint));
  }
  else
  {
    PWpoint axispt;

    for (i=0; i<3; i++)
      axispt[i] = tor_center[i] + tor_axis[i];

    BStoraxctrd (fabs(base_radius), base_center, tor_center, axispt, p_torus, 
                 &BSmsg);
    OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                  PW_K_InvalidArg), wrapup);

    memcpy (insidept, base_center, sizeof (PWpoint));
  } 

  /*
   * Set the pos_orient, depending whether the torus bounds void / material.
   */

  BSptonnsdsf (p_torus, insidept, &natside, &BSmsg);
  OnErrorState (BSERROR (BSmsg), PWsts, SetError (PW_K_Pathway,
                PW_K_InvalidArg), wrapup);
 
  if (!natside)
    p_torus->pos_orient = FALSE;
  else
    p_torus->pos_orient = TRUE;

wrapup : 

  PW_Wrapup (PWsts, "pwCreateTorusBsp");
  return PWsts;
}  

end implementation EMSsubbs;
