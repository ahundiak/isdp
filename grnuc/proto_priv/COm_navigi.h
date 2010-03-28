#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_navigi.I */
extern int COm_make_command_active __((OM_S_OBJID cmd, GRspacenum osnum));
extern int COm_navig_router __((int f_label, int g_label, double value, char *fp));
extern int ASformat_par __((char *template_name, struct GRid *object, char *format));

#if defined(__cplusplus)
}
#endif


#undef __
