class specification HSlghtsrc (1:0) of GRclhdr;

#include "go.h"
#include "hslight.h"

instance HSlghtsrc
{
	struct HS_light_source LightSource;
	channel
	{
			(many_to_many, initial=1, increment=0)
	} to_dpb;
};

message HSget_light( IGRint *msg; struct HS_light_source *light );
message HSput_light( IGRint *msg; struct HS_light_source *light;
		struct GRsymbology light_symb );
message HScreate_light_source_graphics( IGRint *msg; struct HS_light_source *light; struct GRsymbology light_symb );
message HStoggle_displayability( IGRint *msg );
override GRgetobjinfo, GRcptform, GRcopy, GRxform_owner, GRget_locate_properties;

end specification HSlghtsrc;
