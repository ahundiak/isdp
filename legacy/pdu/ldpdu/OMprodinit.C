#define NULL 0
#include "OMminimum.h"


/* opl version 2.4.0 */


#include "version.h"



INGR_p_PRODUCT_DEF Pdu_appl_version[]=
 {
  0
 };

int COpdu_OM_class_init();
int global_class_OM_class_init();
int PDUstartup_OM_class_init();
int PDUasmmgr_OM_class_init();

OM_p_FUNCPTR Pdu_class_definitions[]=
 {
  COpdu_OM_class_init,
  global_class_OM_class_init,
  PDUstartup_OM_class_init,
  PDUasmmgr_OM_class_init,
   0
 };

OMuword OPP_COpdu_class_id = 65535;
OMuword OPP_PDUstartup_class_id = 65535;
OMuword OPP_global_class_class_id ;
OMuword OPP_CEO_LOCATE_class_id ;
OMuword OPP_PDUasmmgr_class_id ;
OMuword OPP_super_cmd_class_id ;


OMuword COpdu_OPP_get_message_type_method_index ;
OMuword COpdu_OPP_display_status_method_index ;
OMuword global_class_OPP_wake_up_method_index ;
OMuword global_class_OPP_sleep_method_index ;
OMuword COpdu_OPP_save_default_view_method_index ;
OMuword COpdu_OPP_display_status_message_method_index ;
OMuword COpdu_OPP_store_origin_id_method_index ;
OMuword COpdu_OPP_default_view_method_index ;
OMuword COpdu_OPP_pdu_cleanup_method_index ;
OMuword COpdu_OPP_check_default_view_method_index ;
OMuword COpdu_OPP_pdu_chg_wf_state_method_index ;
OMuword COpdu_OPP_get_prompt_type_method_index ;
OMuword COpdu_OPP_list_parts_method_index ;
OMuword COpdu_OPP_pdu_internal_method_index ;
OMuword COpdu_OPP_disconnect_located_method_index ;
OMuword COpdu_OPP_save_point_method_index ;
OMuword COpdu_OPP_store_GRpart_id_method_index ;
OMuword COpdu_OPP_store_view_method_index ;
OMuword COpdu_OPP_display_command_method_index ;
OMuword COpdu_OPP_pdu_external_method_index ;
OMuword COpdu_OPP_mydebug_method_index = 65535;
OMuword COpdu_OPP_close_invis_file_method_index = 65535;
OMuword COpdu_OPP_disp_cmd_cancelled_method_index = 65535;
OMuword COpdu_OPP_pdu_validate_wf_method_index = 65535;
OMuword COpdu_OPP_verify_command_method_index = 65535;
OMuword COpdu_OPP_check_origins_method_index = 65535;
OMuword COpdu_OPP_list_origins_method_index = 65535;
OMuword COpdu_OPP_display_design_form_method_index = 65535;
