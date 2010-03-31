class implementation Root;

#include "EMS.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlcdef.h"
#include "EMSprop.h"

#define DEBUG 0

extern GRclassid OPP_GRcurve_class_id;
extern GRclassid OPP_EMSloop_class_id, OPP_EMSedge_class_id;
extern GRclassid OPP_GRcompcurve_class_id, OPP_GRbspline_class_id;
extern GRclassid OPP_EMSboundary_class_id;
/*
#if NOT_THROUGH_LOCATE_CONTROL_FORM
 extern IGRboolean EMSbdryelems_locatable_flag;
#endif
*/

%safe
IGRboolean locate_tangent_edges=1;
%endsafe

/*
  DESCRIPTION

    Function that determines if a particular classid is eligible as indicated
    by the class-list structure. The w_flags field in the structure
    can be one of the following -
      0 - No formal constant defined - classid must match exactly
      1 - OM_CLST_subclass - classid must subclass
      2 - OM_CLST_negation - classid must not be in the classlist.
    The return value is TRUE if the given classid is eligible w.r.t to
    the input class-list.

  HISTORY
    
    SS  :  03/30/88  :  Creation
    rlw :  01/30/89  :  Reworked to repair problems.
                        Note that this function is only a rough check.
    rlw :  02/01/89  :  The w_flags is bits and I did not know this.
    pp  :  09/20/89  :  Made changes to support locate control interface
                        for surf edge curves and surf loop curves.
*/

IGRboolean EMclass_eligible (classid, classlist)
GRclassid classid;
OM_p_CLASSLIST classlist;
{
 IGRboolean	eligible;

 if ((! classlist) ||
     (classlist->w_flags & OM_CLST_negation) ||
     (classlist->w_count == 0) ||
     (classlist->p_classes == NULL))
  eligible = TRUE;
 else
  {
   IGRint	numclasses, i;
   IGRlong	stat_OM;
   GRclassid	*classes;

   eligible = FALSE;
   numclasses = classlist->w_count;
   classes = classlist->p_classes;
   for (i = 0; (i < numclasses) && (! eligible); i++)
    {
     stat_OM = om$is_ancestry_valid(
      subclassid = classes[i],
      superclassid = classid);
     if (stat_OM == OM_S_SUCCESS)
      eligible = TRUE;
     else
      {
       stat_OM = om$is_ancestry_valid(
        subclassid = classid,
        superclassid = classes[i]);
       if (stat_OM == OM_S_SUCCESS)
        eligible = TRUE;
      }
    } /*  for (i = 0; (i < numclasses) && (! eligible); i++) */
  }

 return(eligible);
}

/*
  DESCRIPTION

    Function used to check if boundary elements are eligible 
    to be located within a call to locate. a) The environment should indicate
    boundary elements to be locatable, b) the classlist must indicate
    GRcurve, c) properties must include read-only objects, d) the owner
    action bits must specify rigid-children as locatable.

  HISTORY

    SS  :  03/30/88  :  Creation
    rlw :  01/30/89  : Removed planarity and physically closed checks as
                       these cannot be performed based on the surface's
                       properties.
    pp  :  02/12/89  : Boundary eligibility is determined by calling
                       a function to take advantage of the locate
                       control interface.
*/

IGRboolean EMbdrys_eligible (cvl, sfinfo)
struct GRlc_cvl *cvl;
struct EMSsfinfo *sfinfo;
{
  IGRshort idmattyp;
  IGRint eligible;
  IGRulong lcprop, lcownact, requested_properties;
  IGRlong stat_OM, msg_loc;
  IGRmatrix idmat;
  struct GRlc_locate *lcattr;
  OM_p_CLASSLIST lcclass;
  void EMidmatrix();
  IGRboolean EMclass_eligible();
  IGRboolean EFboundary_curves_locatable();
  extern IGRlong GRloccheck();

  /*
   * Check if the environment is set to locate surface boundary
   * elements.
   */

   /*
    * Changed the following code to call a function to determine
    * boundary eligibility.
    * pp (02/12/89)
    */
  eligible = EFboundary_curves_locatable();

  if (!eligible)
   {
#if DEBUG
    fprintf(stderr, "\nBoundary locate is not on");
#endif
    goto ret_end;
   }

  /*
   * Check if the locate type is set to bore-line locate or point-locate.
   * If not, boundary locate is not supported.
   */

  eligible = cvl->attributes.type == GR_bl_loc || 
              cvl->attributes.type == GR_pt_loc;
  if (!eligible)
   {
#if DEBUG
    fprintf(stderr, "\nLocate type is not bore line or point locate");
    fprintf(stderr, "\nType is %d", cvl->attributes.type);
#endif
    goto ret_end;
   }

  /*
   * Check if the class list indicates that boundary elements (subclasses of
   * GRcurve that they are), are eligible.
   * Note that this is a very rough check designed to toss out elements
   * which cannot be possibly located by the classlist specified.
   */

  lcattr = &cvl->attributes.obj_attr;
  lcclass = cvl->classes;

/*
 * Added the boundary part to enable us to locate boundary elements
 * directly through lc$locate.
 * pp (12/10/89)
 */

  eligible = EMclass_eligible (OPP_GRcurve_class_id, lcclass) ||
             EMclass_eligible (OPP_EMSboundary_class_id, lcclass);
  if (!eligible)
   {
#if DEBUG
    IGRchar	string[80];
    IGRlong	i, sts;

    fprintf(stderr, "\nClass being sought is not a subclass of GRcurve");
    fprintf(stderr, "\nClass match flag is %d", lcclass->w_flags);
    fprintf(stderr, "\nThere are %d classes eligible", lcclass->w_count);
    for (i = 0; i < lcclass->w_count; i++)
     {
      sts = om$get_classname(
       osnum = 2,
       classid = lcclass->p_classes[i],
       classname = string);
      if (1 & sts)
       fprintf(stderr, "\nClass *%s* is eligible", string);
      else
       fprintf(stderr, "\nError getting class name");
     }
#endif
    goto ret_end;
   }

  /*
   * Check if the properties indicate that the boundary elements (read-only
   * things that they are) are eligible.
   */

  lcprop = lcattr->properties;
  eligible = lcprop & LC_READ_ONLY;
  if (!eligible)
   {
#if DEBUG
    fprintf(stderr, "\nOperation is not read-only");
    fprintf(stderr, "\nOperation type is %x", lcprop);
#endif
    goto ret_end;
   }

  /*
   * Check if the owner action bits indicate that the boundary elements, (rigid
   * children that they are), are eligible.
   */

  lcownact = lcattr->owner_action;
  eligible = lcownact & LC_RIGID_COMP;
  if (!eligible)
   {
#if DEBUG
    fprintf(stderr, "\nRigid children bit not set");
    fprintf(stderr, "\nOwner actions bits are %x", lcownact);
#endif
    goto ret_end;
   }

  /*
   * Check if the graphics-properties and the level indicate that the
   * boundary elemenst, (dependent on the surface that they are), are 
   * eligible.
   */

  eligible = FALSE;
  EMidmatrix (&msg_loc, &idmattyp, idmat);
  requested_properties =                    /* rlw 01/30/89 */
   cvl->attributes.obj_attr.properties |
   LC_PLANAR_NON_PLANAR | 
   LC_PHY_OPEN_CLOSED;
  stat_OM = GRloccheck (&msg_loc, &idmattyp, idmat, &sfinfo->props,
             &requested_properties, &sfinfo->symb.level,
             cvl->levels, &sfinfo->id.objid);
  if (EMSerror (stat_OM) || msg_loc != MSSUCC)
   {
#if DEBUG
    fprintf(stderr, "\nGRloccheck failed");
    fprintf(stderr, "\nSurface properties are %x", sfinfo->props);
    fprintf(stderr, "\nRequest properties are %x", 
     cvl->attributes.obj_attr.properties);
#endif
    goto ret_end;
   }
  else
    eligible = TRUE;

ret_end:
  return (eligible);
}



/*
  DESCRIPTION

    The default function check that returns TRUE if the information
    passed in about a given loop indicates eligibility. In the case of
    locating xyz elems: check to see if GRcompcurve is in the class
    list. Also check if the number of edge in the loop are greater than
    1 (GRcompcurve should have more than one component). In the case
    of locating uv elems: check to see if EMSloop is in the class
    list.

  NOTE

    This function DOES NOT conform to the arguments expected by the 
    function that may be specified in the EMSlcinfo structure. But this
    is the function invoked if no function is given in the
    EMSlcinfo structure. This function should be a trivial check.

  HISTORY

    SS  :  05/09/88  :  Creation
    rlw :  01/30/89  :  Modified to check to ensure that only objects
                        of the proper class are located.
    pp  :  10/12/89  :  Modified to allow location of loops through lc$locate.
*/

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRboolean EMloop_eligiblen (options, edcount, lpprops, classlist,ingrid)
IGRushort options;
IGRint edcount;
IGRushort lpprops;
OM_p_CLASSLIST classlist;
struct GRid *ingrid;
{
  IGRboolean eligible;
  extern IGRboolean EFloop_curves_locatable();
  OMuword inclassid;

  eligible = FALSE;
  if (options & EMSlcopt_xyzelem)
    {
     if (edcount > 1)		/* Literal check if composites are eligible */
      {
       IGRlong	sts, loc_msg;

       sts = lc$classchek(
         rc = &loc_msg,				/* Not set by Rajeesh */
         classid_to_check = OPP_GRcompcurve_class_id, 
         eligible_classes = classlist);
       eligible = sts;
      } /* if (edcount > 1) */
    }
  else
    {
     if (ingrid)
     {
      IGRlong sts;

      sts = om$get_classid(objid = ingrid->objid,
                           osnum = ingrid->osnum,
                           p_classid = &inclassid);
      if (!(1&sts)) return (1);
     }
     else inclassid = OPP_EMSloop_class_id;

    if (EMclass_eligible (inclassid, classlist))
      eligible = TRUE;
    }

  return (eligible);
}



/*
  DESCRIPTION

    The default function check that returns TRUE if the information
    passed in about a given edge indicates eligibility. The check is 
    performed to see if the the curve-type passed in is in the
    classlist in the case of model-space edge locate. In the case of 
    uv-edge locate, the function returns TRUE, regardless.

  NOTE

    This function DOES NOT conform to the arguments expected by the 
    function that may be specified in the EMSlcinfo structure. But this
    is the function invoked if no function is given in the
    EMSlcinfo structure. This function should be a trivial check.

  HISTORY

    SS  :  03/30/88  :  Creation
    rlw :  01/30/89  :  Modified to check to ensure that only objects
                        of the proper class are located.
    pp  :  10/12/89  :  Modified to allow location of edges through lc$locate.
    WBC :  02/07/92  :  Modified to allow location of a seam edge unless it is
                        also a tangent edge.
*/

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRboolean EMedge_eligiblen (options, cvtype, edprops, classlist,ingrid)
IGRushort options;
IGRuchar cvtype;
IGRushort edprops;
OM_p_CLASSLIST classlist;
struct GRid *ingrid;
{
  IGRboolean eligible;
  extern IGRboolean EFedge_curves_locatable();
  OMuword inclassid; 

  if (options & EMSlcopt_hitormiss)
    eligible = edprops & EMED_NATURAL ? !(options & EMSlcopt_nonatedge) :
                                        TRUE;
  else if (options & EMSlcopt_xyzelem)
   {
    eligible = !(edprops & EMED_SUBORDINATE) && !(edprops & EMED_DEGENERATE) &&
                !((edprops & EMED_SEAM) && (edprops & EMED_TANGENT));
    if (eligible)
     {
      extern	IGRlong EFget_classid_for_an_edge_type();
      OMuword	classid;
      IGRlong	sts, loc_msg;

      sts = EFget_classid_for_an_edge_type(
        &classid,
        cvtype);
      if (! (1 & sts))
       eligible = FALSE;
      else
       {
        sts = lc$classchek(
         rc = &loc_msg,				/* Not set by Rajeesh */
         classid_to_check = classid,
         eligible_classes = classlist);
        eligible = sts;
       }
     } /* if (eligible) */
   }
  else
  {
   if (ingrid)
   {
      IGRlong sts;

      sts = om$get_classid(objid = ingrid->objid,
                           osnum = ingrid->osnum,
                           p_classid = &inclassid);
      if (!(1&sts)) return (1);
   }
   else inclassid = OPP_EMSedge_class_id;

    if (EMclass_eligible (inclassid, classlist))
    {

     if (locate_tangent_edges)
      eligible = !(edprops & EMED_SUBORDINATE) && !(edprops & EMED_DEGENERATE); 
     else
      eligible = !(edprops & EMED_SUBORDINATE) && !(edprops & EMED_DEGENERATE) 
                  && !(edprops & EMED_TANGENT);
    }
  }

  return (eligible);
}

end implementation Root;
