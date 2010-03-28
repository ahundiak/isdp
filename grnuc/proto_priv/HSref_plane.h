#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/stubs/HSref_plane.c */
extern void HSsetup_ref_plane_for_window __((GRobjid id, GRspacenum num));

#if defined(__cplusplus)
}
#endif


#undef __
