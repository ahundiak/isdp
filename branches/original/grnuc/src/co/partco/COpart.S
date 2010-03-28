class specification COpart (1:0) of COdpb, COtools, CEO_GSLOCATE;



#include <coimport.h>
#include <FI.h>
#include <grownerdef.h>
#include <growner.h>
#include <grsymdef.h>
#include <grsym.h>
#include <grsymmacros.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <msdef.h>
#include <msmacros.h>
#include "part.h"
#include "partdef.h"
#include "partmacros.h"
#include "partco.h"
#include "grmessage.h"


instance COpart
{
    struct GRid                 part;
    IGRint                      num_attrs;
    variable IGRchar            attr[10][MAX_ATTR];
    variable IGRchar            value[10][MAX_VALUE];
    variable IGRint             type[10];
    IGRint                      num_objects;
    variable struct GRobj_env   object[25];
    variable struct format      format[5];
    IGRint                      num_processed;
    variable struct GRid        parts[10];
    IGRint                      num_parts;
    IGRint                      parts_processed;
};


override arg_name_to_value;

message gather_objects (IGRint * msg );

message true (IGRint * msg; IGRint query);

override dynamics;

message place_part (IGRint * msg; struct GRevent * origin);

message get_attribute_prompt (IGRlong * sts);

message set_attribute (IGRchar * new_value);

message highlight_part ();

message get_attributes (IGRint * msg; IGRint statics; IGRint dynamics);

message get_all_parts (IGRint * msg);

message list_parts (IGRint * msg; IGRint command);

message update_partslist (IGRint * msg);

message store_format (IGRint * msg; IGRchar * format);

message do_Global_attr_message ();

message update_form_attributes_by_label (IGRint          label;
                                        IGRint        * msg;
                                        IGRint          number_label;
                                        IGRint          name_label;
                                        IGRint          static_label;
                                        IGRint          dynamic_label );

message update_form_by_label (IGRint label; IGRint * msg);

message reset_form_by_label (IGRint label; IGRint * msg);

message query_form_by_label (IGRint label; IGRint * msg);

override form_notification;

message modify_part (IGRint label; IGRint * msg);

message modify_part_attributes (IGRint label; IGRint * msg);

message update_active_row (IGRint label; IGRint * msg);

override display_form_by_label;

message construct (IGRint * msg; IGRint object; IGRint dynamics);

message stack_delete (IGRint * msg; IGRint number; IGRint erase);

end specification COpart;
