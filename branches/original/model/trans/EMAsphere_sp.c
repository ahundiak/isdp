/* - special convertion routine EMAgenbs_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REgenbs.h"
#include "REassoc.h"
#include "OMport.h"

struct EMSassoc_instance {
  struct OM_sd_varlenarr_descr info;
  unsigned char type;
};

EMAsphere_OMPORT_EMSassoc(classid, ME, me)
short  classid;
char   *ME;
struct EMSassoc_instance *me;
{
  int sts; 

  if( me->type == EMS_ASskinning_surface ||
      me->type == EMS_ASfunction )
      sts = EMAsubbs_OMPORT_EMSassoc(classid, ME, me);

  return(1);
}
