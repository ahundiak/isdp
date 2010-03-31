

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong  ECtrm_prf __(( IGRint              task,
                               struct GRparms      *geom_parms,      
                               struct GRmd_env     *old_mdenv,
                               struct GRid         *grid_1,
                               IGRboolean          closed_1,
                               struct GRid         *grid_2,
                               IGRboolean          closed_2,
                               IGRpoint            appar,
                               IGRint              *control,
                               struct GRid         *new_grid_1,
                               struct GRid         *new_grid_2,
                               IGRpoint            s_i_point,
                               IGRpoint            s_E_point,
                               struct GRid         *saved_grid_1,
                               struct GRid         *saved_grid_2 ));

#if defined(__cplusplus)
}
#endif


#undef __

