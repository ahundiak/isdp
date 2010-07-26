#ifndef GRchanpass_include
#define GRchanpass_include

/*
History

        AIC 05 Feb 92   Creation
*/

typedef struct
{
        OM_S_CHANSELECT *chansel;
        OM_E_WRT_FLAG   mode;
        int             from_ndx;
        int             to_ndx;
        char            *user_arg;
} GR_S_PATH_LIST;

#endif
