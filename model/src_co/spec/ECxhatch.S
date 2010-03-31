/* ###################   APOGEE COMPILED   ################## */
class specification ECxhatch (1:0) of ECautoplane;
/*
 Description

  This class provides instance data and methods for
  a command which supports cross hatching a planar 
  surface.  A surface can be identified or the
  command will accept a planar closed curve possibly
  auto searching inside this curve.
 
 Notes

    The following parameters are used in cross hatching
    a plane:

      a) Active angle - is used as cross hatch angle.

      b) Active area pattern delta x - is used as spacing
         between cross-hatched u-lines.

      c) Active area pattern delta y - is used as spacing
          between cross-hatched v-lines.

      d) (0,0,0) - is used as the cross-hatch origin.  

 History

  09/10/87 : RC  : Creation Date
  12/03/87 : RC  : Modified for version 1.1.0 and 
                   also to cross hatch in both directions.
  07/28/88 : rlw : Rewrote the command to support identification of
                   curves with possible auto search.
  04/18/89 : rlw : Modified to use status display form and parameters
                   used by wireframe cross hatching.
  09/29/89 : rlw : Modified instance data such that there is no difference
                   between the active properties and that which is on the
                   status display form.
  04/02/91 : msm : Changed to c-based form. 
 */

instance ECxhatch
{
 IGRdouble	hatch_angle;
 IGRdouble	hatch_spacing;
 IGRlong	material_type;
};

/*
 * Overrides
 */
override
/*
 * These messages support the material
 * patterns via the status display form.
 */
 init,
 update_status_form,
 status_disp,
/*
 * This message informs the user of
 * the currently active parameters
 */
 wakeup,
/*
 * This message is overridden to disable
 * the undo by backup when a planar surface
 * is cross hatched.
 */
 perform_duty,
/*
 * This message performs the cross hatch
 */
perform_construction;

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

end specification ECxhatch;
