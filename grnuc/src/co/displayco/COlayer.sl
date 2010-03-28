/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */

options         "t"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COlayer
super_class     CEO
start_state     terminate

/* Specification section .. code for .S file */

specification

#include "lydef.h"
#include "layer.h"
#include "gr.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "godef.h"


instance 
{
  IGRlong   num_in_group;    /* number of named layer groups (me->group) */
  IGRlong   total_num_names; /* total layers displayed at any given time */
  IGRlong   elig_mask[32];   /* on/off mask of layers */
  IGRlong   elements_on_layer[MAX_LVLDEF];  /* array of number of ele. on ly */
  IGRshort  group_flag;     /* flag telling we are in the named(group) mode */
  IGRshort  eligibility;    /* search criteria flag */
  IGRshort  occupied;       /* search criteria flag */
  IGRshort  init_occupied;  /* flag saying we need to call COlayer.occupied */
  IGRshort  occupied_enabled;    /* flag telling if occupied field is used */
  IGRshort  eligibility_enabled; /* flag telling if elig/stat field is used */
  IGRshort  display_ind[MAX_LVLDEF];   /* array of indexes into me->group or
                                          me->ind_ly to display if not 
                                          consecutive */
  IGRshort     active_layer;
  GRspacenum   lvl_osnum;   /* DPlvldir osnum */
  GRobjid	   lvl_oid;     /* DPlvldir objid */
  struct GRlayer     group[MAX_LVLDEF];   /* named layers information */
  struct GRindlayer  ind_ly[MAX_LVLDEF];  /* individual layers info */
}


implementation

action search (struct GRlayer *group; struct GRindlayer *ind_ly;
           IGRchar *number; IGRchar *name;
           IGRchar *elig;  IGRchar *occupied; IGRint *num_layer;
           IGRshort  *found; IGRshort group_flag) extern

action display_layer_field (IGRlong *in_msg; IGRshort in_flags;
                     IGRshort  *display_ind; IGRint total_num_rows;
                     IGRchar *form_ptr) extern

action form_notification extern

action num_name ( IGRlong *in_msg) extern

action form_init extern

action occupied extern


action init
{
  /*
   *  Set the eligibility flag.
   */

  me->eligibility_enabled = FALSE;

  /*
   * Call the parent's init.
   */

  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO.init(type, str_ptr),
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
  }

}
