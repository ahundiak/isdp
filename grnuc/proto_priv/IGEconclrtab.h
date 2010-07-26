#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args)()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* IGEconclrtab.I */
extern IGRint (*DPset_load_vlt_ptr(IGRint (*)()))();

#if defined(__cplusplus)
}
#endif

#undef __
