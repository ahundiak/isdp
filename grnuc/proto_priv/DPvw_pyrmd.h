#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPvw_pyrmd.I */
extern IGRint DPshow_pyramid __((IGRlong *msg, GRobjid win_objid));

#if defined(__cplusplus)
}
#endif


#undef __
