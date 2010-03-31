#include "OMminimum.h"
#include "OMport.h"
#include "EMSssprops.h"

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

struct EMSproject_total_instance
 {
  struct Root_instance Root;
  struct GRgraphics_instance GRgraphics;
  struct GRconnector_instance GRconnector;
  struct GRnotify_instance GRnotify;
  struct GRvg_instance GRvg;
  struct EMSrequester_instance EMSrequester;
  struct EMSsubbs_instance EMSsubbs;
 };

EMSproject_OMPORT_EMSsubbs(classid, ME, me)
short classid;
struct EMSproject_total_instance *ME;
struct EMSproject_total_instance *me;
/* EMSproject class does not have any instance declared by it. So "me"
   also points to to the "total instance" */
{ 
	int	sts, len, offset;
	char	*data;
  	unsigned char prop;
	extern  EMSgenbs_OMPORT_EMSsubbs(), EMSrevol_OMPORT_EMSsubbs();


	switch(ME->EMSsubbs.ss_props & EMSformat)
	{
	  case EMSbsplineFormat:
	     EMSgenbs_OMPORT_EMSsubbs(classid, (char *) ME, (char *) me);
	     break;

	  case EMSprojectedFormat:
		/* Get the VLA size */
		len = OMPORT_DIMENSION_OF(&ME->EMSsubbs.packed_data_descr);
		if(!len) return(1);

		/* Determine the beginning of the VLA */
		data = (char *) OMPORT_VLA_VALUE(&ME->EMSsubbs.packed_data_descr);

		/* We are about to translate the following struct 
		struct EMSprojectedSurfaceHeader
		{
		  unsigned char             pj_props;
		  unsigned char             order;
		  unsigned short            num_poles;
		  unsigned int              unused;
		  union EMSprojectionFormat projection_data;
		};

		*/

		data += 2; /* First 2 fields are bytes. So no need for
			      any translation. Just increment pointer by 2
			    */
		
		sts = OMPORT_CONV_SHORT(data, 1); /* translate the short */
		
		data += sizeof(short);

		sts = OMPORT_CONV_INT(data, 1); /* translate the int */

		data += sizeof(int);

		/* Determine the remaining numberof bytes. Fortunately
		   the data in the union are made up of doubles only. So
		   translate all of them in one shot
		*/

		offset = 2 + sizeof(short) + sizeof(int);
		len = len - offset;

		/* Determine the number of doubles that follow */

		len = len / sizeof( double );

		sts = OMPORT_CONV_DOUBLE(data, len);

	     	break;

   	  case EMSrevolvedFormat:
	     EMSrevol_OMPORT_EMSsubbs(classid, (char *) ME, (char *) me);
	     break;
	}

	return(1);
}
