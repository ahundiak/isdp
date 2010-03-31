#if defined (__) 
#undef __
#endif


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*---NCd_co_op_dm.c------------------------------------------*/

extern void NCupdate_const_dm_block_front_dexels __(( struct trapezoid * ));

extern void NCupdate_const_dm_swvol_back_dexels  __(( struct trapezoid * ));

extern void NCupdate_const_dm_tool_front_dexels  __(( struct trapezoid * ));

extern void NCupdate_const_dm_tool_back_dexels   __(( struct trapezoid * ));

/*---NCd_co_op_ht.c------------------------------------------*/

extern void NCupdate_const_ht_block_front_dexels __(( struct trapezoid * ));

extern void NCupdate_const_ht_swvol_back_dexels  __(( struct trapezoid * ));

extern void NCupdate_const_ht_tool_front_dexels  __(( struct trapezoid * ));

extern void NCupdate_const_ht_tool_back_dexels   __(( struct trapezoid * ));

/*---NCd_noshad.c--------------------------------------------*/

extern void NCupdate_block_back_dexels  __(( struct trapezoid * ));

extern void NCupdate_swvol_front_dexels __(( struct trapezoid * ));

/*---NCd_sm_op_dm.c------------------------------------------*/

extern void NCupdate_smooth_dm_block_front_dexels __(( struct trapezoid * ));

extern void NCupdate_smooth_dm_swvol_back_dexels  __(( struct trapezoid * ));

extern void NCupdate_smooth_dm_tool_front_dexels  __(( struct trapezoid * ));

extern void NCupdate_smooth_dm_tool_back_dexels   __(( struct trapezoid * ));

/*---NCd_sm_op_ht.c------------------------------------------*/

extern void NCupdate_smooth_ht_block_front_dexels __(( struct trapezoid * ));

extern void NCupdate_smooth_ht_swvol_back_dexels  __(( struct trapezoid * ));

extern void NCupdate_smooth_ht_tool_front_dexels  __(( struct trapezoid * ));

extern void NCupdate_smooth_ht_tool_back_dexels   __(( struct trapezoid * ));

/*---NCgen_swvol.c-------------------------------------------*/

extern void NCbuild_swept_volume __(( void ));

/*---NCmath.c------------------------------------------------*/

extern void create_rotation_matrix    __(( IGRpoint,
                                           IGRpoint,
                                           IGRpoint,
                                           IGRdouble m1[3 ][3 ] ));

extern void rotate_points             __(( IGRdouble m1[3 ][3 ],
                                           IGRint,
                                           IGRpoint * ));

extern void translate_points          __(( IGRpoint,
                                           IGRint,
                                           IGRpoint * ));

extern void copy_points               __(( IGRint,
                                           IGRint,
                                           IGRint,
                                           IGRpoint *,
                                           IGRint,
                                           IGRint,
                                           IGRpoint * )); 

extern void generate_orthogonal_basis __(( IGRpoint,
                                           IGRpoint,
                                           IGRpoint,
                                           IGRpoint ));

/*---NCmemory.c--------------------------------------------------*/

struct NCdexel *NCget_next_dexel    __(( struct NCdexel * ));

extern void NCinit_dexel_buffers    __(( IGRint,
                                         struct NCdexel **,
                                         NCzbuf **,
                                         NCzbuf **,
                                         NCcbuf ** )); 

extern void NCcleanup_dexel_buffers __(( void ));

extern void NCfree_dexel            __(( struct NCdexel ** ));

extern void NCalloc_dexel           __(( struct NCdexel ** ));

/*---NCmilling.c-------------------------------------------------*/

extern int ShadedNC __(( IGRint,
                         struct HSNC_mode_parms,
                         IGRdouble *,
                         struct HSNC_return_parms * ));

/*---NCorient.c--------------------------------------------------*/

extern void NCupdate_orientation_vectors __(( void ));

extern void NCinit_orientation           __(( void ));

extern void NCchange_orientation         __(( IGRdouble m1[3 ][3 ] ));

/*---NCpaint.c---------------------------------------------------*/

extern void NCpaint          __(( void ));

extern void NCpaint_sim_tool __(( IGRint *,
                                  IGRint *,
                                  IGRint *,
                                  IGRint * ));

/*---NCsimulate.c------------------------------------------------*/

extern void NCupdate_sim_location __(( void ));

extern void NCinit_simulation     __(( void ));

extern void free_simbuf           __(( void ));

extern void NCcleanup_simulation  __(( IGRboolean ));

extern void NCupdate_sim_buffer   __(( IGRboolean ));

extern void NCupdate_sim_speed    __(( IGRint ));

extern void NCdisplay_sim_tool    __(( void ));

extern void NCmove_sim_tool       __(( IGRboolean, IGRboolean ));

extern int NCtoolpath_dir         __(( IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint *,
                                       IGRint *,
                                       IGRint *,
                                       IGRint * ));

extern int NCtoolpath_fxdir       __(( IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint,
                                       IGRint *,
                                       IGRint *,
                                       IGRint *,
                                       IGRint * ));

extern int NCremove_tool_region   __(( IGRboolean ));

extern int NCupdate_tool_color    __(( short ));

extern int  NCconvert_tool_color  __(( simDexel *,
                                       simDexel *));

extern void NCdebug_tool_map      __(( simDexel *));

/*---NCsubtract.c----------------------------------------------------*/

extern int NCsubtract_dexel    __(( NCzbuf,
                                    NCzbuf,
                                    unsigned char,
                                    int,
                                    IGRboolean * ));

extern int NCsubtract_sim_tool __(( IGRint,
                                    IGRint,
                                    IGRint,
                                    IGRint,
                                    IGRint ));

/*---NCtool.c--------------------------------------------------------*/

extern void NCcleanup_tool       __(( void ));

extern void NCinit_tool_vars     __(( void ));

extern void NCchange_active_tool __(( struct IGRbsp_curve * ));

/*---NCtool_pbust.c--------------------------------------------------*/

extern void NCtile_tool __(( void ));

extern int NCtool_pbust __(( struct HSvertex * ));

/*---NCtoolpath.c----------------------------------------------------*/

extern void NCinit_toolpath            __(( IGRpoint ));

extern void NCcleanup_toolpath         __(( void ));

extern void NCinit_toolpath_position   __(( IGRpoint,
                                            IGRpoint ));

extern void NCupdate_toolpath_position __(( void ));

extern void NCset_tax_toolpath         __(( struct IGRbsp_curve * ));

extern void NCset_fax_toolpath         __(( IGRint,
                                            IGRdouble *,
                                            IGRdouble * ));

extern IGRboolean NCget_next_position  __(( void ));

/*---NCtrap.c--------------------------------------------------------*/

extern int NCcleanup_trap       __(( void ));

extern int NCsave_trap          __(( struct trapezoid * ));

extern int NCdexelize_workpiece __(( void ));

extern int NCdexelize_swvol     __(( void ));

extern int NCdexelize_tool      __(( void ));

/*---NCwindow.c------------------------------------------------------*/

extern void NCsetup_shading_window __(( IGRint,
                                        IGRint,
                                        IGRdouble,
                                        IGRdouble,
                                        IGRboolean,
                                        IGRboolean,
                                        unsigned int,
                                        unsigned int,
                                        unsigned char *,
                                        IGRint,
                                        IGRint,
                                        IGRint,
                                        IGRint )); 

extern IGRboolean NCinit_window    __(( void ));

extern void NCcleanup_window       __(( void ));


#if defined(__cplusplus)
}
#endif


#undef __
