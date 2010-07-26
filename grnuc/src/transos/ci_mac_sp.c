#include "OMport.h"
#include "igrtypedef.h"
#include "ci_macro.h"

struct ci_mac_def_instance
  {
  struct ci_mac_st  desc;
  IGRint temp_feet_num;
  IGRint intern_feet_num;
  IGRint extern_feet_num;
};

#if defined(__STDC__) || defined(__cplusplus)
ci_mac_def_OMPORT_ci_mac_def(short classid, char *ME, struct ci_mac_def_instance *me)
#else
ci_mac_def$ci_mac_def(classid, ME, me)
short classid;
char *ME;
struct ci_mac_def_instance *me;
#endif
  {
  int  sts;
  char *data;

#if defined(__STDC__) || defined(__cplusplus)
  if(OMPORT_SHORT_VALUE(&me->desc.int_size))
#else
  if(om$short_value(&me->desc.int_size))
#endif
    printf("WARNING: internal data of ci_macro %s are not converted",me->desc.ci_name);
  return(1);
}

