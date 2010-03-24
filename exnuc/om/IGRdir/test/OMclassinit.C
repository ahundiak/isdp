#define NULL 0
#include "OMminimum.h"


/* opl version 1.3.0 */


int myclass_OM_class_init();
int dummy_OM_class_init();
int tst_dir_OM_class_init();

OM_p_FUNCPTR OM_GA_class_definitions[]=
 {
  myclass_OM_class_init,
  dummy_OM_class_init,
  tst_dir_OM_class_init,
 };

int OM_Gi_number_of_defns=3;


OMuword OPP_myclass_class_id = 65535;
OMuword OPP_dummy_class_id = 65535;
OMuword OPP_tst_dir_class_id = 65535;


OMuword tst_dir$test_pass_method_index = 65535;
OMuword dummy$test_pass_method_index = 65535;
OMuword dummy$test_connect_method_index = 65535;
