/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION

 This method constructs a surface of revolution given a curve ( Single 
 or Composite ), two points defining a rotation axis, start angle, and
 a sweep angle.

 The rotation is carried out via the right hand rule.

 The angles should be in degrees.

 In case of a composite curve, a composite surface is formed.

RETURN VALUES

 construct_list->msg    MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated
                        MSINARG - no buffer or curve data passed in, or
                          math flagged curve as bad
                        GRSNOINVTRAN - if input matrix is not invertible
                        GRSDGNEXCEED - if range exceeds design limits

 msg                    same value as construct_list->msg

NOTES

 This object will delete itself if an error occurs.
 The object won't delete the composite surface, the composite surface
  would delete itself.
 The curve being revolved is reparameterized before revolution.  This
 implies that the input curve buffer will be modified.

 The argument new_objid of type (OM_S_OBJID *) is added, for a single
 curve it is same as "my_id" but given a composite curve to revolve, it
 is the id of a composite surface object belonging to EMSrevcompsf class.

HISTORY

 08/21/92 : NP  : Modified for ANSI compliance.
 08/23/89 : PP  : Fixed a problem which causes square root domain errors
                  whenever a non-identity matrix is passed in construct_list
                  environment.
 06/29/88 : AIC : Fixed planarity.
 02/11/88 : sam : Modified such as depending on input, EMSrevol is 
                   substituted by it's subclasses.
 01/11/88 : sam : Modified such that the curve being revolved
                   could be a composite curve.
 09/21/87 : rlw : Modified such that the curve being revolved is
                  reparameterized before being revolved.
 05/23/87 : pp  : Changed the argument list so that the method
                  also accepts a curve buffer as an alternative
                  form of input for the purpose of creating a
                  surface of revolution
 09/24/86 : rlw : The beginning
*/

class implementation EMSrevol;

#include "EMS.h"
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_EMSrevcompsf_class_id;
extern OMuword OPP_EMSrevol_class_id;

#include "bserr.h"
#include "bsconic.h" /* for BSCIRCLE_NUM_POLES_MAX AND BSCIRCLE_ORDER */ 
#include "msdef.h"
#include "maerr.h"
#include "EMSsweep.h"
#include "OMmacros.h"
#include "emsdattyp.h" /* For EMSdata_curve3d */

from EMSswcompsf import EMsweep_composite_curve;

method EMrevolve_curve(
 struct GRvg_construct *construct_list;
 struct GRlc_info *curve_info; 
 struct IGRbsp_curve *incurve;
 double axis_line[2][3];
 double start_angle;
 double sweep_angle; 
 int is_full_revolution;
 IGRboolean pos_orient_flag;
 OM_S_OBJID *new_objid;
 int *msg)

{
 IGRlong        sts, EFget_surface_of_revolution_class(), class_ret;
 OMuword        new_classid;
 struct         IGRbsp_curve *curve;
 IGRboolean	use_grdelete_and_not_rootdelete = FALSE;
 IGRchar        *generic_pointer = NULL;

/*
 * Initialize
 */
 *msg = MSSUCC;
 *new_objid = my_id;
 new_classid = OPP_EMSrevol_class_id;
 curve = NULL;
/*
 * Get the curve defintion
 */
 if (curve_info) /* Is a curve object: (Composite or Single curve) */
  {
     OMuword classid;
     sts = om$get_classid(objid = curve_info->located_obj.objid,
                          osnum = curve_info->located_obj.osnum,
                          p_classid = &classid);
     if (! (1 & sts))
     {
      *(construct_list->msg) = MSFAIL;
      goto wrapup;
     }
     sts = om$is_ancestry_valid(subclassid = classid,
                                superclassid = OPP_EMScomposite_class_id);
     
     if(sts == OM_S_SUCCESS) /* Is a Composite curve object */
     {
      IGRint ii, jj;
      struct GRlc_info lc_info;
      struct EMSsweep sweep_parms;
     
      sweep_parms.type = EMRevolve;
      OM_BLOCK_MOVE(curve_info, &lc_info, sizeof(struct GRlc_info));
/*
 *    OM_BLOCK_MOVE(axis_line, sweep_parms.data.rev_data.axis,
 *                      6*(sizeof(double)));
 */
      sweep_parms.data.rev_data.axis = (IGRdouble *)axis_line;
      sweep_parms.data.rev_data.start_angle = start_angle;
      sweep_parms.data.rev_data.sweep_angle = sweep_angle;
      sweep_parms.data.rev_data.full_rev = is_full_revolution;
      sts = om$construct(classid = OPP_EMSrevcompsf_class_id,
                         osnum   = curve_info->located_obj.osnum,
                         p_objid = new_objid,
                         msg =message EMSswcompsf.EMsweep_composite_curve(
                            construct_list,
                            &lc_info,
                            &sweep_parms,
                            &my_id));
      if (! (1 & sts))
      {
       *(construct_list->msg) = MSFAIL;
       goto ret_sts;
      }
      return(OM_S_SUCCESS); /* Exit if task is over */
     }/* Is a  Composite curve object */
    else /* Not a Composite curve object: (Single curve object) */
    { 
     IGRint type;
/*
 * Genabsg was being done before. This caused problems whenever a
 * non-identity matrix was being passed in construct_list environment.
 * This is because EMput_revolved_format was calling  a method which was
 * using the abstract buffer.
 * pp (06/23/89)
 */

     EMgetvggeom (
                   construct_list->msg,
                   &curve_info->module_info.md_env.matrix_type,
                   curve_info->module_info.md_env.matrix,
                   &curve_info->located_obj,
                   &generic_pointer,
                   &type);
     if (type != EMSdata_curve3d)
     {
      *(construct_list->msg) = EMS_E_InvalidArg;
      goto wrapup;
     }

/* end pp */

     if (! (1 & sts))
     {
      *(construct_list->msg) = MSFAIL;
      goto wrapup;
     }
     curve = (struct IGRbsp_curve *) generic_pointer;
    } /* Not a Composite curve object: (Single curve object) */
  } /* Is a Curve object: (Composite or Single) */
 else if (incurve) /* Not a curve object: Is a curve buffer */
  curve = incurve;
 else /* Something rotten came in */
  {
    *(construct_list->msg) = MSINARG;
    goto wrapup; 
  } /* Something rotten came in */

  /*
   * Fix the paramaterization.
   */
  if (curve->num_poles > curve->order)
  {
  extern     void          BSarclnparc();
    IGRlong       loc_msg;

    BSarclnparc(&loc_msg, curve);
    if(loc_msg != BSSUCC) { *(construct_list->msg) = MSFAIL;goto wrapup; }

    curve->non_uniform = TRUE;          /* Math forgets to do this */
  }

  /*
   * Refine the class of revolved surface
   */
  sts = EFget_surface_of_revolution_class(&class_ret, curve_info, curve,
        axis_line, is_full_revolution, &new_classid);
  if(!(1&sts&class_ret))
  new_classid = OPP_EMSrevol_class_id;

  /*
   * Construct a new object, if necessary
   */
  if(new_classid != OPP_EMSrevol_class_id)
  {
    sts = om$construct(classid = new_classid, p_objid = new_objid);
    if(!(1&sts)) { *(construct_list->msg) = MSFAIL; goto wrapup; }
  }

  /*
   * Store the surface definition in the revolution format.
   */
  {
    struct GRpost_info  info;

    info.construct_flag = TRUE;
    sts = om$send(msg = message EMSrevol.EMputRevolvedFormat
                  (construct_list->msg, construct_list->env_info, &info,
                   curve, (IGRdouble *)axis_line, 
                   (IGRboolean) is_full_revolution,
                   start_angle, sweep_angle, pos_orient_flag),
                   targetid = *new_objid);
    if(! (1 & sts)) goto wrapup;
    
    use_grdelete_and_not_rootdelete = TRUE;
  }

  /*
   * Fill the instance data and such. Note: The planar bit is set
   * in GRgraphics->properties by EMputRevolvedFormat. Construct
   * will not honor the old properties, so that property is
   * extracted from the instance data before calling GRconstruct.
   */
  construct_list->geometry = NULL;
  if(me^^GRgraphics.properties & GRIS_PLANAR)
    construct_list->properties |= GRIS_PLANAR;
  else construct_list->properties &= ~GRIS_PLANAR;
  sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
                targetid = *new_objid);
  if (!(1 & sts)) goto wrapup;

/*
 * End of routine
 */
wrapup:
 if (generic_pointer) om$dealloc(ptr = generic_pointer);
 *msg = *(construct_list->msg);

/* if(*new_objid != my_id) ie: surface class got refined and this refined
    surface has a new objectid, hence delete the old object ( my_id)
*/
  if(*new_objid != my_id)
  {
   sts = om$send(msg = message Root.delete(1), targetid = my_id);
  }


/* If failure occured GRdelete OR Root.delete *new_objid (It could be
    the refined surface object (diff objectid) OR old surface (my_id))
*/
  if(!(1&*(construct_list->msg)))
  {
   if(use_grdelete_and_not_rootdelete)
   {
    IGRlong loc_msg;
    sts =om$send(msg = message GRvg.GRdelete(&loc_msg, 
			&(curve_info->module_info)),
		 targetid = *new_objid);
   }
   else
   {
    sts =om$send(msg = message Root.delete(1),
		 targetid = *new_objid);
   }
  }

/*
 if ( (!(1 & *msg)) || (new_classid != OPP_EMSrevol_class_id) )
 {
  sts = om$send(msg = message Root.delete(1), targetid = my_id);
  if( (!(1 & *msg)) && (*new_objid != my_id) )
  {
   sts = om$send(msg = message Root.delete(1), targetid = *new_objid);
  }
 }
*/

/* If error occured in projection of a composite curve , it would come
    here. The composite surface has deleted itself (with its children)
    and also the surface which was about to become its child
*/

ret_sts:
 if(1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);

}

end implementation EMSrevol;
