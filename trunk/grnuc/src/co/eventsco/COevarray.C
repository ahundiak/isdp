/* #######################    APOGEE COMPILED   ######################## */
#include "coimport.h"
#include "igrtypedef.h"

extern IGRlong COev_pt_angle_from();
extern IGRlong COev_pt_angle_to();
extern IGRlong COev_pt_center();
extern IGRlong COev_pt_end();
extern IGRlong COev_pt_intersection();
extern IGRlong COev_pt_key();
extern IGRlong COev_pt_mid();
extern IGRlong COev_pt_project();
extern IGRlong COev_pt_perpendicular_from();
extern IGRlong COev_pt_perpendicular_to();
extern IGRlong COev_pt_tangent_from();
extern IGRlong COev_pt_tangent_to();
extern IGRlong COev_pt_tentative_key();
extern IGRlong COev_pt_snap();

IGRlong CO_GA_ev_func_dummy();
/*
typedef IGRlong (*CO_p_FUNCPTR)();

CO_p_FUNCPTR CO_GA_ev_func[] = 
{
    CO_GA_ev_func_dummy,               /*    0    * /
    COev_pt_angle_from,                     /*    1     * /
    COev_pt_angle_to,                       /*    2     * /
    COev_pt_center,                         /*    3     * /
    COev_pt_end,                            /*    4     * /
    COev_pt_intersection,                   /*    5     * /
    COev_pt_key,                            /*    6     * /
    COev_pt_mid,                            /*    7     * /
    COev_pt_project,                        /*    8     * /
    COev_pt_perpendicular_from,             /*    9     * /
    COev_pt_perpendicular_to,               /*    10    * /
    COev_pt_tangent_from,                   /*    11    * /
    COev_pt_tangent_to,                     /*    12    * /
    COev_pt_tentative_key,                  /*    13    * /
    COev_pt_snap                            /*    14    * /
};
*/

#define CO_GA_ev_func_count   13


IGRlong CO_GA_ev_func_dummy()
{
#ifdef DEBUG
    printf ("WARNING: CO_GA_ev_func_dummy called\n");
#endif
    return (FALSE);
}


IGRboolean CO_GA_ev_func_index_in_range (index)
IGRlong index;
{
    if ((index > 0) && (index <= CO_GA_ev_func_count))
    {
        return (TRUE);
    }
    else
    {
#ifdef DEBUG
        printf ("WARNING: CO_GA_ev_func function index is out of range\n");
#endif
        return (FALSE);
    }
}
