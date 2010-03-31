/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "OMminimum.h"
#include <stdio.h>

extern void OM_PMS();

void EMS_PMS()
{
    fprintf(stderr,"The Slim Goodbody performance monitoring system.");
    OM_PMS();
    return;
}

void EMS_ODEN()
{
    IGRchar	dict_name[100];
    fprintf(stderr, "\nEnter dictionary name-> ");
    fscanf(stdin, "%s", dict_name);
#ifdef ODEN
    om$oden(dictionary= dict_name);
#endif
    return;
}

void EMS_PEEK_QUEUE()
{
    int resp;
    if (EX_peek_event_queue(&resp))
      fprintf(stderr, "\nresponse on queue is %d\n", resp);
    else
      fprintf(stderr, "\nqueue is empty\n");
    return;
}

void EMS_PRINT_QUEUE()
{
   print_queue();
   return;
}

end implementation EMSsurface;
