/*
  OVERVIEW

  This file consists of functions related to typing a given Surface Entity.


  HISTORY

  SS    : 05/05/95  :  Creation
*/

class implementation EMSsurface;

#include "bsgeom_cvsf.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sftype.h" 
#include "PWapi/sfprops.h"

extern PWclassid OPP_EMSsurface_class_id;
extern PWclassid OPP_EMScompsurf_class_id;
extern PWclassid OPP_EMSsolid_class_id;
extern PWclassid OPP_EMSsubbs_class_id;

/*
  ABSTRACT

  Functions to test if the given object is a surface-entity or more 
  specifically, a composite surface or a simple surface (3 functions).
*/

PWboolean pwIsSurface
(
  PWobjid  sfobj,
  PWosnum  sfos
)
{
  PWclassid sfclass=OM_K_NOTUSING_CLASSID;

  om$get_classid (objid = sfobj, osnum = sfos, p_classid = &sfclass);
  if ((om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id,
       subclassid = sfclass)) == OM_S_SUCCESS)
    return (PWboolean) TRUE;
  else
    return (PWboolean) FALSE;
}

PWboolean pwIsCompSf
(
  PWobjid  sfobj,
  PWosnum  sfos
)
{
  PWclassid sfclass=OM_K_NOTUSING_CLASSID;

  om$get_classid (objid = sfobj, osnum = sfos, p_classid = &sfclass);
  if ((om$is_ancestry_valid (superclassid = OPP_EMScompsurf_class_id,
       subclassid = sfclass)) == OM_S_SUCCESS)
    return (PWboolean) TRUE;
  else
    return (PWboolean) FALSE;
}

PWboolean pwIsSolid
(
  PWobjid  sfobj,
  PWosnum  sfos
)
{
  PWclassid sfclass=OM_K_NOTUSING_CLASSID;

  om$get_classid (objid = sfobj, osnum = sfos, p_classid = &sfclass);
  if ((om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id,
       subclassid = sfclass)) == OM_S_SUCCESS)
    return (PWboolean) TRUE;
  else
    return (PWboolean) FALSE;
}

PWboolean pwIsSimpleSf
(
  PWobjid  sfobj,
  PWosnum  sfos
)
{
  PWclassid sfclass=OM_K_NOTUSING_CLASSID;

  om$get_classid (objid = sfobj, osnum = sfos, p_classid = &sfclass);
  if ((om$is_ancestry_valid (superclassid = OPP_EMSsubbs_class_id,
       subclassid = sfclass)) == OM_S_SUCCESS)
    return (PWboolean) TRUE;
  else
    return (PWboolean) FALSE;
}

/*
  ABSTRACT
 
  This function returns the type of this surface as one of the constants
  defined by the BSPMATH layer. See file bsgeom_cvsf.h for the listing 
  of the types.
*/

short pwSfType 
(
  PWobjid sfobj,
  PWosnum sfos
)
{
  short sftype;
  PWclassid myclass;
  extern PWclassid OPP_EMScylindr_class_id, OPP_EMAcylindr_class_id,
                   OPP_EMSpcylindr_class_id, OPP_EMApcylindr_class_id,
                   OPP_EMSrevol_class_id, OPP_EMArevol_class_id,
                   OPP_EMSproject_class_id, OPP_EMAproject_class_id,
                   OPP_EMScone_class_id, OPP_EMAcone_class_id,
                   OPP_EMSpcone_class_id, OPP_EMApcone_class_id,
                   OPP_EMStorus_class_id, OPP_EMAtorus_class_id,
                   OPP_EMSptorus_class_id, OPP_EMAptorus_class_id,
                   OPP_EMSsphere_class_id, OPP_EMAsphere_class_id,
                   OPP_EMSpsphere_class_id, OPP_EMApsphere_class_id;

  om$get_classid (objid = sfobj, osnum = sfos, p_classid = &myclass);

  if ((myclass == OPP_EMScylindr_class_id) ||
      (myclass == OPP_EMAcylindr_class_id))
  {
    sftype = BSFULL_CYL;
  }
  else if ((myclass == OPP_EMSpcylindr_class_id) ||
           (myclass == OPP_EMApcylindr_class_id))
  {
    sftype = BSPART_CYL;
  }
  else if ((myclass == OPP_EMSrevol_class_id) ||
           (myclass == OPP_EMArevol_class_id))
  {
    sftype = BSSF_OF_REV;
  }
  else if ((myclass == OPP_EMSproject_class_id) ||
           (myclass == OPP_EMAproject_class_id))
  {
    sftype = BSSF_OF_PROJ;
  }
  else if ((myclass == OPP_EMScone_class_id) ||
           (myclass == OPP_EMAcone_class_id))
  {
    sftype = BSFULL_CONE;
  }
  else if ((myclass == OPP_EMSpcone_class_id) ||
           (myclass == OPP_EMApcone_class_id))
  {
    sftype = BSPART_CONE;
  }
  else if ((myclass == OPP_EMStorus_class_id) ||
           (myclass == OPP_EMAtorus_class_id))
  {
    sftype = BSTORUS;
  }
  else if ((myclass == OPP_EMSptorus_class_id) ||
           (myclass == OPP_EMAptorus_class_id))
  {
    sftype = BSPART_TORUS;
  }
  else if ((myclass == OPP_EMSsphere_class_id) ||
           (myclass == OPP_EMAsphere_class_id))
  {
    sftype = BSSPHERE;
  }
  else if ((myclass == OPP_EMSpsphere_class_id) ||
           (myclass == OPP_EMApsphere_class_id))
  {
    sftype = BSPART_SPHERE;
  }
  else if (pwIsRectPlane (sfobj, sfos))
  { 
    sftype = BSRECT_PLANE;
  }
  else
  {
    sftype = BSGEN_BSP_SF;
  }

  return (sftype);
}

/*
  ABSTRACT
 
  This function returns the classid that corresponds to the input surface
  type. The type is a defined constant in the BSPMATH layer. See file
  bsgeom_cvsf.h for the listing of the types.

 
  NOTES

  This function always returns the non-associative class of the surface.
*/

PWclassid pwSfClassid
(
  short sftype
)
{
  PWclassid myclass;
  extern PWclassid OPP_EMScylindr_class_id,
                   OPP_EMSpcylindr_class_id,
                   OPP_EMSrevol_class_id,
                   OPP_EMSproject_class_id,
                   OPP_EMScone_class_id,
                   OPP_EMSpcone_class_id,
                   OPP_EMStorus_class_id,
                   OPP_EMSptorus_class_id,
                   OPP_EMSsphere_class_id,
                   OPP_EMSpsphere_class_id,
                   OPP_EMSplane_class_id,
                   OPP_EMSgenbs_class_id;

  if (sftype == BSFULL_CYL)
  {
    myclass = OPP_EMScylindr_class_id;
  }
  else if (sftype == BSPART_CYL)
  {
    myclass = OPP_EMSpcylindr_class_id;
  }
  else if (sftype == BSSF_OF_REV)
  {
    myclass = OPP_EMSrevol_class_id;
  }
  else if (sftype == BSSF_OF_PROJ)
  {
    myclass = OPP_EMSproject_class_id;
  }
  else if (sftype == BSFULL_CONE)
  {
    myclass = OPP_EMScone_class_id;
  }
  else if (sftype == BSPART_CONE)
  {
    myclass = OPP_EMSpcone_class_id;
  }
  else if (sftype == BSTORUS)
  {
    myclass = OPP_EMStorus_class_id;
  }
  else if (sftype == BSPART_TORUS)
  {
    myclass = OPP_EMSptorus_class_id;
  }
  else if (sftype == BSSPHERE)
  {
    myclass = OPP_EMSsphere_class_id;
  }
  else if (sftype == BSPART_SPHERE)
  {
    myclass = OPP_EMSpsphere_class_id;
  }
  else if (sftype == BSRECT_PLANE)
  { 
    myclass = OPP_EMSplane_class_id;
  }
  else
  {
    myclass = OPP_EMSgenbs_class_id;
  }

  return (myclass);
}

end implementation EMSsurface;

