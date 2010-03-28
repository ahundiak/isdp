#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpdynamics.I */
extern IGRint DPdynamics __((IGRint (*dyn_fun )(), IGRchar *addnal_info, IGRint *flags,
                             IGRint (*dyn_fun1)(), IGRchar *addnal_info1));
extern IGRint DPdynflags __((IGRlong *msg, IGRboolean *set_inq, IGRboolean *dyn_on, IGRboolean *all_windows));

#if defined(__cplusplus)
}
#endif


#undef __
