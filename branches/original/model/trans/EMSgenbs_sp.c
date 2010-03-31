#include "OMminimum.h"
#include "OMport.h"

struct Root_instance {
struct OM_sd_objecthdr OPPobjecthdr;
};


 struct GRgraphics_instance
  {
   short properties;
   short level;
  };
 struct GRconnector_instance
  {
   OM_p_CHANNEL_HDR    to_owners;
  };
 struct GRnotify_instance
  {
   OM_p_CHANNEL_HDR    notification;
  };
 struct IGRdisplay
  {
   unsigned short color;
   unsigned char weight;
   unsigned char style;
  } ;
 struct GRvg_instance
  {
   struct IGRdisplay display_attr;
  };
 struct EMSrequester_instance
  {
   OM_p_CHANNEL_HDR    to_helpers;
  };
 struct EMSsubbs_instance
  {
   OM_p_CHANNEL_HDR    to_loopset;
   struct OM_sd_varlenarr_descr packed_data_descr;
   int hidden_line;
   unsigned char u_rules;
   unsigned char v_rules;
   unsigned char ss_props;
   unsigned char ls_area_for_rtree;
  };
struct EMSgenbs_total_instance
 {
  struct Root_instance Root;
  struct GRgraphics_instance GRgraphics;
  struct GRconnector_instance GRconnector;
  struct GRnotify_instance GRnotify;
  struct GRvg_instance GRvg;
  struct EMSrequester_instance EMSrequester;
  struct EMSsubbs_instance EMSsubbs;
 };

EMSgenbs_OMPORT_EMSsubbs(classid, ME, me )
short classid;
struct EMSgenbs_total_instance *ME;
struct EMSgenbs_total_instance *me;
{
	int	sts, len, offset;
	char	*data;

	/* Get the VLA size */
	len = OMPORT_DIMENSION_OF(&ME->EMSsubbs.packed_data_descr);

	/* Determine the beginning of the VLA */
	data = (char *) OMPORT_VLA_VALUE(&ME->EMSsubbs.packed_data_descr);

	if(len) {

		/* We are about to translate the following struct 
			{
			  unsigned IGRchar      u_order;
			  unsigned IGRchar      v_order;
			  unsigned IGRchar      bs_props;
			  unsigned IGRchar      unused;
			  unsigned IGRshort     u_num_poles;
			  unsigned IGRshort     v_num_poles;
			  IGRdouble             double_data[];
			}
		*/
		

		data += 4; /* First four fields  are bytes */
		
		sts = OMPORT_CONV_SHORT(data, 2); /* next two fields */
		
		data += ( 2 * sizeof(short) );

		/* Determine the remaining no_of bytes. These contain
			doubles only */
		offset = 4 + (2 * sizeof(short) );
		len = len - offset; /* remaining # of bytes */

		/* Determine the no_of doubles that follow */
		len = len / sizeof( double );
		sts = OMPORT_CONV_DOUBLE(data, len);
	}
	
	return(1);
}


