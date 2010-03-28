#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* DPactivate.I */
extern void DPactivate_update __((IGRint update));

#if defined(__cplusplus)
}
#endif


#undef __
