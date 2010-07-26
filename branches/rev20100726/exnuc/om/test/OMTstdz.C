#define NULL 0
#include "OMminimum.h"


/* opl version 1.3.0 */


int SendTime_OM_class_init();
int SendTime2_OM_class_init();

OM_p_FUNCPTR OM_GA_class_definitions[]=
 {
  SendTime_OM_class_init,
  SendTime2_OM_class_init,
 };

int OM_Gi_number_of_defns=2;


OMuword OPP_SendTime2_class_id = 65535;
OMuword OPP_SendTime_class_id = 65535;


OMuword SendTime$dummy10_method_index = 65535;
OMuword SendTime$dummy5_method_index = 65535;
OMuword SendTime$dummy_method_index = 65535;
