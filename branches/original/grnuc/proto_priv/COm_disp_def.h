#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_disp_def.I */
extern int ACbuild_env __((GRspacenum osnum, struct GRmd_env *lib_env));
extern int ACcreate_window __((GRspacenum osnum, struct GRid *window, struct GRid *gragad, int screen, int xor, int yor, int xl, int yl));
extern int ACdisplay_macro __((struct GRid *macro, struct GRid *default_opt, struct sup *dup, int Nb_Max_Temp, struct GRid *window));
extern int ACerase_macro __((struct GRid *macro, struct GRid *default_opt, struct sup *dup, int Nb_Max_Temp, struct GRid *window));

#if defined(__cplusplus)
}
#endif


#undef __
