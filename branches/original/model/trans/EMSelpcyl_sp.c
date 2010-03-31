/* - special convertion routine EMSelpcyl_OMPORT_EMSsubbs - */

#include <stdio.h>
#include <unistd.h>
#include "OMport.h"
#include "EMSssprops.h"

struct OM_sd_objecthdr {
unsigned long oid;
unsigned int i_size;
};
struct Root_instance {
struct OM_sd_objecthdr OPPobjecthdr;
};
struct EMSrequester_instance {
struct OM_sd_channel_hdr *to_helpers;
};
struct GRgraphics_instance {
short properties;
short level;
};
struct GRnotify_instance {
struct OM_sd_channel_hdr *notification;
};
struct GRconnector_instance {
struct OM_sd_channel_hdr *to_owners;
};
struct IGRdisplay {
unsigned short color;
unsigned char weight;
unsigned char style;
};
struct GRvg_instance {
struct IGRdisplay display_attr;
};
struct EMSsubbs_instance {
struct OM_sd_channel_hdr *to_loopset;
struct OM_sd_varlenarr_descr packed_data;
int hidden_line;
unsigned char u_rules;
unsigned char v_rules;
unsigned char ss_props;
unsigned char ls_area_for_rtree;
};
struct EMSelpcyl_total_instance {
struct Root_instance Root;
struct GRgraphics_instance GRgraphics;
struct GRconnector_instance GRconnector;
struct GRnotify_instance GRnotify;
struct GRvg_instance GRvg;
struct EMSrequester_instance EMSrequester;
struct EMSsubbs_instance EMSsubbs;
};


EMSelpcyl_OMPORT_EMSsubbs(classid, ME, me)
short classid;
struct EMSelpcyl_total_instance *ME;
struct EMSsubbs_instance *me;
{

	int	sts, len, offset;
	char	*data;
  	unsigned char prop;
	extern  EMSproject_OMPORT_EMSsubbs();

	EMSproject_OMPORT_EMSsubbs(classid, (char *) ME, (char *) me);

	return(1);
}
