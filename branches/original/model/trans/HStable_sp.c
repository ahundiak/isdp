#include "OMport.h"


struct HStable_instance {
int entry_size;
char *new_entry_ptr;
short num_fields;
struct OM_sd_varlenarr_descr field_sizes;
struct OM_sd_varlenarr_descr offsets;
short  num_entries;
struct OM_sd_varlenarr_descr entries;
struct OM_sd_varlenarr_descr dir_name; 
struct OM_sd_varlenarr_descr num_links;
struct OM_sd_channel_hdr     *to_parent;
struct OM_sd_channel_hdr     *notification;
};

HStable_OMPORT_HStable(classid, ME, me)
short classid;
char *ME;
struct HStable_instance *me;
  {
  int  sts;
  char *data;
  int  nb_entry;

  data = OMPORT_VLA_VALUE(&me->entries);
  nb_entry = OMPORT_SHORT_VALUE(&me->num_entries);
  sts = OMPORT_CONV_BY_TEMPLATE_NAME(data,"HS_SYMB_T",nb_entry);
  if(!sts) return(0);

  return(1);
}

