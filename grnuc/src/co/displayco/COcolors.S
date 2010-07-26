class specification COcolors (1:0) of CEO_LOCATE;



#include "griodef.h"


instance COcolors
{
	IGRchar	    file_nme[GR_MAX_CHAR];
	IGRshort    valid_name;
	IGRshort    ld_clr_tbl;
	IGRint      type_of_file;
};


message init_act ( long * sts );

override form_notification;

message loadclrtbl ( long * sts );

message ld_can_ctb ( long * sts );

message save_file ( long * sts );

message get_file ( long * sts );

end specification COcolors;
