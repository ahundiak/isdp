/* #######################    APOGEE COMPILED   ######################## */
#include "coimport.h"
#include "igrtypedef.h"

extern IGRint COmn_move();
extern IGRint COmn_copy();
extern IGRint COmn_align();
extern IGRint COmn_cp_align();
extern IGRint COmn_mirrorv();
extern IGRint COmn_cp_mirrorv();
extern IGRint COmn_mirrorh();
extern IGRint COmn_cp_mirrorh();
extern IGRint COmn_mirrorl();
extern IGRint COmn_cp_mirrorl();
extern IGRint COmn_rotate_aa();
extern IGRint COmn_cp_rotate_aa();
extern IGRint COmn_rotate_ax();
extern IGRint COmn_cp_rotate_ax();
extern IGRint COmn_rotate_3pts();
extern IGRint COmn_cp_rotate_3pts();
extern IGRint COmn_scale_as();
extern IGRint COmn_cp_scale_as();
extern IGRint COmn_scale_3pts();
extern IGRint COmn_cp_scale_3pts();

IGRint CO_GA_manip_dummy();
/*
typedef IGRint (*CO_p_FUNCPTR)();

CO_p_FUNCPTR CO_GA_manip[] = 
{
    CO_GA_manip_dummy, /*    0    * /
    COmn_move,                              /*    1     * /
    COmn_copy,                              /*    2     * /
    COmn_align,                             /*    3     * /
    COmn_cp_align,                          /*    4     * /
    COmn_mirrorv,                           /*    5     * /
    COmn_cp_mirrorv,                        /*    6     * /
    COmn_mirrorh,                           /*    7     * /
    COmn_cp_mirrorh,                        /*    8     * /
    COmn_mirrorl,                           /*    9     * /
    COmn_cp_mirrorl,                        /*    10    * /
    COmn_rotate_aa,                         /*    11    * /
    COmn_cp_rotate_aa,                      /*    12    * /
    COmn_rotate_ax,                         /*    13    * /
    COmn_cp_rotate_ax,                      /*    14    * /
    COmn_rotate_3pts,                       /*    15    * /
    COmn_cp_rotate_3pts,                    /*    16    * /
    COmn_scale_as,                          /*    17    * /
    COmn_cp_scale_as,                       /*    18    * /
    COmn_scale_3pts,                        /*    19    * /
    COmn_cp_scale_3pts,                     /*    20    * /
};
*/

#define CO_GA_manip_count   20


IGRint CO_GA_manip_dummy()
{
#ifdef DEBUG
	printf ("WARNING: ");
	printf ("CO_GA_manip_dummy called\n");
#endif
	return (FALSE);
}


IGRint CO_GA_manip_index_in_range (index)

IGRint  index;

{
	if ((index > 0) && (index <= CO_GA_manip_count))
	{
		return (TRUE);
	}
	else
	{
#ifdef DEBUG
		printf ("WARNING: CO_GA_manip function ");
		printf ("index is out of range\n");
#endif
		return (FALSE);
	}
}
