/* - special conversion routine DMsrc$DMsrc - */

#include "OMport.h"

static char *template[] = {
	"DMkeypt_tmp",
	"DMkeyseg_tmp",
	"DM2ptseg_tmp",
	"DMaxis_tmp",
	"DMradcen_tmp",
	"DMtanpt_tmp",
	"DMintpt_tmp",
	"DMmidpt_tmp",
	"DMptdist_tmp",
	"DMarc_tmp",
	"DMcenpt_tmp",
	"DMedgept_tmp",
	"DMedgeseg_tmp",
	"DMpt_tmp",
	"DMln_tmp"
	};

struct DMsrc_instance {
char type;
struct OM_sd_varlenarr_descr data;
};

#if defined(__STDC__) || defined(__cplusplus)
DMsrc_OMPORT_DMsrc(short classid, char *ME, struct DMsrc_instance *me)
#else
DMsrc$DMsrc(classid, ME, me)
short classid;
char *ME;
struct DMsrc_instance *me;
#endif
{
	int sts;
	char *data;

#if defined(__STDC__) || defined(__cplusplus)
	sts = OMPORT_INTEGER_VALUE ( &me->data.i_count );
#else
	sts = om$integer_value ( &me->data.i_count );
#endif

	if(!sts) return(1);

#if defined(__STDC__) || defined(__cplusplus)
	data = (char *)((unsigned int) (&me->data) +
		   OMPORT_INTEGER_VALUE (&me->data.i_offset) );
#else
	data = (char *)((unsigned int) (&me->data) +
		   om$integer_value (&me->data.i_offset) );
#endif

	if((me->type<0) || (me->type>14)) return (0);

#if defined(__STDC__) || defined(__cplusplus)
	sts = OMPORT_CONV_BY_TEMPLATE_NAME(data, template[me->type], 1);
#else
	sts = om$conv_by_template_name(data, template[me->type], 1);
#endif

	if(!sts) return(0);

        return(1);

}
