class specification HSplotform (1:0) of HSwindow;



#include "FI.h"
#include "HSplot.h"
#include "HSplot_def.h"


instance HSplotform
{
	struct HSplot_info	info;
	};


message which_state ( long * sts );

message get_window_info ( long * sts );

message pre_get_ele ( long * sts );

message HSplot_init ();

message HSplot_wakeup ();

message HSplot_sleep ();

message HSplot_delete ( long * sts );

override form_notification;

message make_plotfile ( long * sts );

end specification HSplotform;
