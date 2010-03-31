/* - special conversion routine EMSsfdlift_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "OMport.h"
#include "EMSasfeatdef.h"

   struct GRid				/* object identifier structure	*/
   {
 	GRspacenum osnum;		/* space number of object	*/
	GRobjid	   objid;		/* object id of object		*/
   };

struct EMSint_info {
	struct 	GRid		sf_GRid;
	unsigned char		lift_operation;
	IGRvector		draft_vec;
	IGRdouble		mx_exlp_dangle;
	IGRboolean		uniform_surface;
	IGRboolean		no_fillets;
	IGRint			num_ed_infos;
	IGRint			num_lps;
	struct	EMSint_lp_info	*lps_info;
};

struct EMSint_lp_info {
	struct	GRid		lp_GRid;
	IGRboolean		is_uniform;
	IGRdouble		draft_angle;
	IGRboolean		fillet;
	IGRint			num_eds;
	struct	EMSint_ed_info	*ed_info;
};

struct EMSint_ed_info {
	struct	GRid		ed_GRid;
	unsigned short		ed_sf_type;
	unsigned char		ed_cv_type;
	unsigned short		ed_constraint_type;
	IGRdouble		draft_angle;
	IGRint			offset_code;
};

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSsfdlift_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{

        int sts, count1, count2, buf_len;
        char *buffer;
	short num_views, uniform_surface, no_fillets, is_uniform;
	int num_lps, num_eds;

	struct EMSint_info	*p_int_info;
	struct EMSint_lp_info	*p_int_lp_info;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

        if(!buf_len) return (1);

	sts = OMPORT_CONV_DOUBLE( buffer, 1 );
	buffer += sizeof( double );
	num_views = OMPORT_SHORT_VALUE( buffer );
	sts = OMPORT_CONV_SHORT( buffer, 1 );
	buffer += sizeof(short);

	/* Align to next 8-byte boundary*/
	buffer += ( sts = (unsigned int)buffer % 8 ) ? ( 8 - sts ) : ( sts );
	sts = OMPORT_CONV_SHORT(buffer, 2 * num_views );
	buffer += (2 * num_views * sizeof( short ));

	/* Align to next 8-byte boundary*/
	buffer += ( sts = (unsigned int)buffer % 8 ) ? ( 8 - sts ) : ( sts );
	p_int_info = ( struct EMSint_info *)buffer;
	num_lps = OMPORT_INTEGER_VALUE(&p_int_info->num_lps);
	uniform_surface = OMPORT_SHORT_VALUE(&p_int_info->uniform_surface);
	no_fillets = OMPORT_SHORT_VALUE(&p_int_info->no_fillets);
	sts = OMPORT_CONV_BY_TEMPLATE_NAME(buffer, "EMSinfo_T", 1 );
	buffer += sizeof( struct EMSint_info );

	if(uniform_surface && no_fillets) return (1);

	for(count1=0;count1<num_lps;count1++) {

		/* Align to next 8-byte boundary*/
		buffer += ( sts = (unsigned int)buffer % 8 ) ? ( 8 - sts ) : ( sts );

		p_int_lp_info = (struct EMSint_lp_info *)buffer;
		num_eds = OMPORT_INTEGER_VALUE(&p_int_lp_info->num_eds);
		is_uniform = OMPORT_SHORT_VALUE(&p_int_lp_info->is_uniform);

		sts = OMPORT_CONV_BY_TEMPLATE_NAME(buffer, "EMSlp_info_T", 1 );
		buffer += sizeof( struct EMSint_lp_info );
		
		if(is_uniform) continue;

		for(count2=0;count2<num_eds;count2++) {

			/* Align to next 8-byte boundary*/
			buffer += ( sts = (unsigned int)buffer % 8 ) ? ( 8 - sts ) : ( sts );
			sts = OMPORT_CONV_BY_TEMPLATE_NAME(buffer, "EMSed_info_T", 1 );
			buffer += sizeof( struct EMSint_ed_info );
			
		}

	}

	return(1);
}
