#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRcustmenu.C */
extern IGRint GRcustomize_menus __((void));

#if defined(__cplusplus)
}
#endif


#undef __
