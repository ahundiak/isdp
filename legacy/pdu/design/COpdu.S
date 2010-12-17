class specification COpdu (1:0) of CEO_LOCATE;


#include <PDUint.h>
#include <igrdp.h>
#include <go.h>


instance COpdu
{
  struct GRvg_construct		constr_list;
  struct GRdpb_text_symb	text_symb;
  struct PDUptr_info		ptr_info;
  struct PDUview_info		view_info;
  struct PDUid			part;
  IGRchar			file_name[40];
  IGRchar			usage_id [40];
  IGRchar			quantity [10];
  };


message pdu_internal ( long * sts );

message pdu_external ( long * sts );

message display_command ( long * sts );

message disp_cmd_cancelled ( long * sts );

message display_status ( long * sts );

message display_status_message ( long * sts );

message get_message_type ( long * sts );

message get_prompt_type ( long * sts );

message pdu_chg_wf_state ( long * sts );

message pdu_validate_wf ( long * sts );

message pdu_cleanup ( long * sts );

message close_invis_file ( long * sts );

message disconnect_located ( long * sts );

message save_point ( long * sts );

message display_design_form ( long * sts );

message check_default_view ( long * sts );

message store_view ( long * sts );

message default_view ( long * sts );

message save_default_view ( long * sts );

message store_GRpart_id ( long * sts );

message store_origin_id ( long * sts );

override init;

override debug;

message mydebug ( long * sts );

message verify_command ( long * sts );

message list_parts ( long * sts );

message list_origins ( long * sts );

message check_origins ( long * sts );

end specification COpdu;
