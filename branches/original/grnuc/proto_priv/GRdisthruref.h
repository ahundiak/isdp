#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRdisthruref.I */
extern int ACset_disthruref __((void));
extern int ACreset_disthruref __((void));
extern long GRdisthruref __((long *msg, OM_S_MESSAGE *display_msg, struct GRid *graphics_object));

#if defined(__cplusplus)
}
#endif


#undef __
