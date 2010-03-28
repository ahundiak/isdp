/* - special conversion routine dim_param$dim_param - */

#include "OMport.h"

static char *template[] = {
	"DMenv_p_tmp",
	"DMloc_p_tmp",
	"DMmisc_p_tmp",
	"DMsenv_p_tmp",
	"DMglob_p_tmp",
	"DMweld_p_tmp"  };

struct dim_param_instance {
int version_no;
int type;
struct OM_sd_varlenarr_descr data;
};

#if defined(__STDC__) || defined(__cplusplus)
dim_param_OMPORT_dim_param(short classid, char *ME, struct dim_param_instance *me)
#else
dim_param$dim_param(classid, ME, me)
short classid;
char *ME;
struct dim_param_instance *me;
#endif
{
	int sts;
	char *data;
	int type;

#if defined(__STDC__) || defined(__cplusplus)
	type = OMPORT_INTEGER_VALUE ( &me->type );

	sts = OMPORT_INTEGER_VALUE ( &me->data.i_count );
#else
	type = om$integer_value ( &me->type );

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

	if((type<0) || (type>5)) return (1);

#if defined(__STDC__) || defined(__cplusplus)
	sts = OMPORT_CONV_BY_TEMPLATE_NAME(data, template[type], 1);
#else
	sts = om$conv_by_template_name(data, template[type], 1);
#endif

	if(!sts) return(0);

        return(1);

}
