/* #######################    APOGEE COMPILED   ######################## */
/*
 * Class :
 *
 *      GRpart
 *
 * Abstract :
 *
 *      This class defines the behavior for parts.
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation date.
 *      jhw                 8/30/93 Added GRrigid_connecting override.
 *
 */
class specification GRpart (1:1) of GRoups, ACdiowner;

#include "part.h"

instance GRpart
{
    variable IGRuchar    attr_type[];
};

/* 
 * Private Messages
 */
message GRcopy_attributes   ( IGRlong     * msg;
                              struct GRid * part;
                              IGRint        types );

/*
 * Public Messages
 */
message GRnum_attributes    ( IGRlong *  msg;
                              IGRint  *  num );

message GRadd_attribute     ( IGRlong *  msg;
                              IGRchar *  attr;
                              IGRchar *  value;
                              IGRint     type );

message GRmod_attribute     ( IGRlong *  msg;
                              IGRchar *  attr;
                              IGRchar *  value;
                              IGRint  *  type );
                                                            
message GRget_attribute     ( IGRlong *  msg;
                              IGRchar *  attr;
                              IGRint  *  index;
                              IGRchar *  value;
                              IGRint  *  type );

message GRchg_part          ( IGRlong *  msg;
                              IGRchar *  catalog;
                              IGRchar *  number;
                              IGRchar *  revision );

override debug,
         GRgetname,
         GRchgname,
         GRputname,
         GRconstruct,
         GRcopy,
         GRcopy_owner,
         GRdelete,
         GRdrop,
         GRgetobjinfo,
         GRflexconn,
         GRadd_to_active_owner,
         GRgetsymb,
         GRcomponent_disconnecting,
         ACcreate,
         ACadd_component,
         ACadd_attribute_by_type,
         ACmod_attribute,
         ACrem_attribute,
         ACrem_att_at_index,
         GRget_channel_type,
         GRget_locate_properties,
         GRrigid_connecting,
         unknown,
         IGRdir.remove,
         GRcptform;

override GRanalyze_element;

end specification GRpart;
