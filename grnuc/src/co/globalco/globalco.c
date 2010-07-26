/*
 *  mrm - functions referenced by arrays below
 */

extern int COch_delete();
#ifndef IDRAW
extern int COch_undelete();
extern int COch_undel_toggle();
#endif
extern int COch_name();
extern int COch_dis_on();
extern int COch_dis_off();
extern int COch_loc_on();
extern int COch_loc_off();
extern int COch_cp_parallel();
extern int CO_GA_change_dummy();
extern int COmn_move();
extern int COmn_copy();
extern int COmn_align();
extern int COmn_cp_align();
extern int COmn_mirrorv();
extern int COmn_cp_mirrorv();
extern int COmn_mirrorh();
extern int COmn_cp_mirrorh();
extern int COmn_mirrorl();
extern int COmn_cp_mirrorl();
extern int COmn_rotate_aa();
extern int COmn_cp_rotate_aa();
#ifndef IDRAW
extern int COmn_rotate_ax();
extern int COmn_cp_rotate_ax();
#endif
extern int COmn_rotate_3pts();
extern int COmn_cp_rotate_3pts();
extern int COmn_scale_as();
extern int COmn_cp_scale_as();
#ifndef IDRAW
extern int COmn_scale_3pts();
extern int COmn_cp_scale_3pts();
#endif
extern int CO_GA_manip_dummy();
extern int COev_pt_angle_from();
extern int COev_pt_angle_to();
extern int COev_pt_center();
extern int COev_pt_end();
extern int COev_pt_intersection();
extern int COev_pt_key();
extern int COev_pt_mid();
extern int COev_pt_project();
extern int COev_pt_perpendicular_from();
extern int COev_pt_perpendicular_to();
extern int COev_pt_tangent_from();
extern int COev_pt_tangent_to();
extern int COev_pt_tentative_key();
extern int COev_pt_snap();
extern int  CO_GA_ev_func_dummy();

typedef int (*CO_p_FUNCPTR)();

/*
 *  mrm - array of function pointers used by the change commands
 */

CO_p_FUNCPTR CO_GA_change[] = 
{
    CO_GA_change_dummy,                     /*    0    */
    COch_delete,                            /*    1     */
#ifdef IDRAW
    CO_GA_change_dummy,                     /*    2d    */
    CO_GA_change_dummy,                     /*    3d    */
#else
    COch_undelete,                          /*    2     */
    COch_undel_toggle,                      /*    3     */
#endif
    CO_GA_change_dummy,                     /*    4     */
    CO_GA_change_dummy,                     /*    5     */
    CO_GA_change_dummy,                     /*    6     */
    CO_GA_change_dummy,                     /*    7     */
    CO_GA_change_dummy,                     /*    8     */
    COch_name,                              /*    9     */
    COch_dis_on,                            /*    10    */
    COch_dis_off,                           /*    11    */
    COch_loc_on,                            /*    12    */
    COch_loc_off,                           /*    13    */
    COch_cp_parallel,                       /*    14    */
    CO_GA_change_dummy,                     /*    15    */
};

/*
 *  mrm - array of function pointers used by the manipulation commands
 */

CO_p_FUNCPTR CO_GA_manip[] = 
{
    CO_GA_manip_dummy,                      /*    0    */
    COmn_move,                              /*    1     */
    COmn_copy,                              /*    2     */
    COmn_align,                             /*    3     */
    COmn_cp_align,                          /*    4     */
    COmn_mirrorv,                           /*    5     */
    COmn_cp_mirrorv,                        /*    6     */
    COmn_mirrorh,                           /*    7     */
    COmn_cp_mirrorh,                        /*    8     */
    COmn_mirrorl,                           /*    9     */
    COmn_cp_mirrorl,                        /*    10    */
    COmn_rotate_aa,                         /*    11    */
    COmn_cp_rotate_aa,                      /*    12    */
#ifdef IDRAW
    CO_GA_manip_dummy,                      /*    13d   */
    CO_GA_manip_dummy,                      /*    14d   */
#else
    COmn_rotate_ax,                         /*    13    */
    COmn_cp_rotate_ax,                      /*    14    */
#endif
    COmn_rotate_3pts,                       /*    15    */
    COmn_cp_rotate_3pts,                    /*    16    */
    COmn_scale_as,                          /*    17    */
    COmn_cp_scale_as,                       /*    18    */
#ifdef IDRAW
    CO_GA_manip_dummy,                      /*    19d   */
    CO_GA_manip_dummy,                      /*    20d   */
#else
    COmn_scale_3pts,                        /*    19    */
    COmn_cp_scale_3pts,                     /*    20    */
#endif
};

/*
 *  mrm - array of function pointers used by the event generator commands
 */

CO_p_FUNCPTR CO_GA_ev_func[] = 
{
    CO_GA_ev_func_dummy,                    /*    0    */
    COev_pt_angle_from,                     /*    1     */
    COev_pt_angle_to,                       /*    2     */
    COev_pt_center,                         /*    3     */
    COev_pt_end,                            /*    4     */
    COev_pt_intersection,                   /*    5     */
    COev_pt_key,                            /*    6     */
    COev_pt_mid,                            /*    7     */
    COev_pt_project,                        /*    8     */
    COev_pt_perpendicular_from,             /*    9     */
    COev_pt_perpendicular_to,               /*    10    */
    COev_pt_tangent_from,                   /*    11    */
    COev_pt_tangent_to,                     /*    12    */
    COev_pt_tentative_key,                  /*    13    */
    COev_pt_snap                            /*    14    */
};

/*
 *  mrm - font descriptor used to display coordinate system triad labels
 */
 
int CSfont_descr = 0;

char	COdpad[512] = {0};


/*
 * jhw - active drawing view flag used in scaling measurements
 */
int CODrawviewActive = 0;
