/* ###################   APOGEE COMPILED   ################## */
class specification ECfilletsf (1:0) of ECconstruct;
/*
 Description

  This is the command object for placing a fillet surface.
  This class is needed to process the status display form
  which allows a law curve to be specified.
 
 History

  09/19/89 : rlw : Creation date
  04/03/91 : msm : Changed to c-based form. Overrode 'status_disp' method.
 */
instance ECfilletsf
{
 IGRchar	law_name[MAX_CHAR];
 IGRint         ext_ind,cnv_ind,cnc_ind, form_number;
 IGRdouble      rho;

};
/*
 * Overrides
 */
override
/*
 * These messages support the
 * options via the status display form.
 */
 init,
 update_status_form,
 status_disp,
/*
 * This method constructs the surface.
 */
perform_construction;

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

end specification ECfilletsf;
