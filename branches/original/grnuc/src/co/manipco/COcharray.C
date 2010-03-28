/* #######################    APOGEE COMPILED   ######################## */
#include "coimport.h"
#include "igrtypedef.h"

extern IGRint COch_delete();
extern IGRint COch_undelete();
extern IGRint COch_undel_toggle();
/*
extern IGRint COch_symbology();
extern IGRint COch_color();
extern IGRint COch_layer();
extern IGRint COch_style();
extern IGRint COch_weight();
*/
extern IGRint COch_name();
extern IGRint COch_dis_on();
extern IGRint COch_dis_off();
extern IGRint COch_loc_on();
extern IGRint COch_loc_off();
extern IGRint COch_cp_parallel();

IGRint CO_GA_change_dummy();
/*
typedef IGRint (*CO_p_FUNCPTR)();

CO_p_FUNCPTR CO_GA_change[] = 
{
    CO_GA_change_dummy, /*    0    * /
    COch_delete,                            /*    1     * /
    COch_undelete,                          /*    2     * /
    COch_undel_toggle,                      /*    3     * /
    COch_symbology,                         /*    4     * /
    COch_color,                             /*    5     * /
    COch_layer,                             /*    6     * /
    COch_style,                             /*    7     * /
    COch_weight,                            /*    8     * /
    COch_name,                              /*    9     * /
    COch_dis_on,                            /*    10    * /
    COch_dis_off,                           /*    11    * /
    COch_loc_on,                            /*    12    * /
    COch_loc_off,                           /*    13    * /
    COch_cp_parallel,                       /*    14    * /
};
*/

#define CO_GA_change_count   14


IGRint CO_GA_change_dummy()
{
#ifdef DEBUG
	printf ("WARNING: ");
	printf ("CO_GA_change_dummy called\n");
#endif
	return (FALSE);
}


IGRint CO_GA_change_index_in_range (index)

IGRint  index;

{
	if ((index > 0) && (index <= CO_GA_change_count))
	{
		return (TRUE);
	}
	else
	{
#ifdef DEBUG
		printf ("WARNING: CO_GA_change function ");
		printf ("index is out of range\n");
#endif
		return (FALSE);
	}
}
