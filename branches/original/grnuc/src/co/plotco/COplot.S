class specification COplot (1:0) of CEO_LOCATE;



#include "grmessage.h"
#include "FI.h"
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"


instance COplot
{
    PIplotdata pd;          /* contains plot submission data */
    PIcreate cd;            /* contains plotfile creation data */
};


message plot_init ();

message plot_wakeup ();

message plot_sleep ();

override form_notification;

message plot_delete ( long * sts );

message store_window ();

message getpd (PIplotdata **pd);

message getcd (PIcreate **cd);

end specification COplot;
