
/* - special conversion routine GRvar$GRvar - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "ex.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "OMport.h"

struct GRvar_instance
{
    IGRlong                      num_variables;
    struct OM_sd_varlenarr_descr var_list;
};


#if defined(__STDC__) || defined(__cplusplus)
GRvar_OMPORT_GRvar(short classid, char *ME, struct GRvar_instance *me)
#else
GRvar$GRvar(classid, ME, me)
short classid;
char *ME;
struct GRvar_instance *me;
#endif
{
    struct GRIOvar_def *variables;
    int                 sts, index, num_entries;
    short               type;

#if defined(__STDC__) || defined(__cplusplus)
    sts = OMPORT_CONV_INT(&me->num_variables, 1);
    num_entries = OMPORT_INTEGER_VALUE ( &me->var_list.i_count );

    variables = (struct GRIOvar_def *)((unsigned int) (&me->var_list) +
			OMPORT_INTEGER_VALUE (&me->var_list.i_offset));
#else
    sts = om$conv_int(&me->num_variables, 1);
    num_entries = om$integer_value ( &me->var_list.i_count );

    variables = (struct GRIOvar_def *)((unsigned int) (&me->var_list) +
			om$integer_value (&me->var_list.i_offset));
#endif

    for( index = 0 ; index < num_entries; index++)
    {
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_SHORT(&variables[index].type, 1);
        type = OMPORT_SHORT_VALUE(&variables[index].type);
#else
        sts = om$conv_short(&variables[index].type, 1);
        type = om$short_value(&variables[index].type);
#endif

        switch (type)
        {
            case GRIO_VAR_FLOAT:
 
#if defined(__STDC__) || defined(__cplusplus)
                sts = OMPORT_CONV_DOUBLE(&variables[index].contents.fvalue, 1);
#else
                sts = om$conv_double(&variables[index].contents.fvalue, 1);
#endif
                break;

            case GRIO_VAR_INT:

#if defined(__STDC__) || defined(__cplusplus)
                sts = OMPORT_CONV_INT(&variables[index].contents.ivalue, 1);
#else
                sts = om$conv_int(&variables[index].contents.ivalue, 1);
#endif
                break;

            case GRIO_VAR_STRING:  /* no conversion necessary */
                break;

            case GRIO_VAR_POINT:

#if defined(__STDC__) || defined(__cplusplus)
                sts = OMPORT_CONV_DOUBLE(variables[index].contents.point, 3);
#else
                sts = om$conv_double(variables[index].contents.point, 3);
#endif
                break;

            default:  /* unknown type */
#ifdef DEBUG
                printf("Unknown variable type for GRvar during tranos\n");
#endif
                break;
        }
    }
    return(1);
}
