/* #######################    APOGEE COMPILED   ######################## */
class implementation COlayer;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <FI.h>
#include "lydef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

%safe
#include "COlyfmnot.h"

%endsafe

method form_init (IGRint *sts)
{
  IGRlong    msg, status;
  IGRint     fm_ind;
  IGRshort   in_flags;
  IGRchar    *form_ptr;
  extern int comp_names();
  int        is_displayed;

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*
   * Initialize some instance data.
   */

  me->group_flag = L_On_Flag;
  me->eligibility = L_Ign_Flag;
  me->occupied = L_Ign_Flag;
  me->occupied_enabled = FALSE;
  me->init_occupied = TRUE;  /* this indicates that we will need to call
                                COlayer.occupied when the occ_toggle is on */

  /*
   * Get the form pointer.
   */

  status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM, &form_ptr,
                         &fm_ind, (int *)&msg),
                   senderid = my_id,
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
    *sts = status;
    goto quit;
  }

  /*
   * Turn on the gadgets for eligibility if it is enabled (as in layer subform
   * for COvwchar and form for COlocly).
   */

  if (me->eligibility_enabled)
  {
    FIg_display(form_ptr, ELIG_ROLL);
    FIfld_set_mode(form_ptr, LAYER_FIELD, 3, FI_INSERT);
  }

  /*
   * Initializes the GRlayer and GRindlayer structures in instance data.
   */

  status = om$send(msg = message COlayer.num_name(&msg),
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
    *sts = status;
    goto quit;
  }

  /*
   * Sort the named layers.
   */

  qsort( (char *) me->group, (unsigned) me->num_in_group,
         sizeof(struct GRlayer), (IGRint (*)())comp_names);

  /* 
   * Initialize the layer field on the form.
   */

  in_flags = GROUP;
  status = om$send(msg = message COlayer.display_layer_field (&msg, in_flags,
                                             NULL, me->num_in_group, form_ptr),
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
    *sts = status;
    goto quit;
  }

  /*
   * Display form here
   */

  /*   itr 245  -  form displaying twice.  dhm  12/19/91  */

  FIf_is_displayed(form_ptr, &is_displayed);

  if (!is_displayed)
  {
    FIf_display(form_ptr);
/*
    status = om$send(msg = message CEO.display_form_by_label(GRLAYERS_FORM,
                                                             &msg),
                     senderid = my_id,
                     targetid = my_id);
    if (! (1&status) )
    {
      om$report_error(sts = status);
      *sts = status;
    }
*/
  }

quit:
  return(status);

}

end implementation COlayer;
