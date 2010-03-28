#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/super_para/super_parai.I */
extern int ASsuper_construct __((void));
extern int ASunmount_macro_lib __((GRspacenum osnum, IGRint pos));

#if defined(__cplusplus)
}
#endif


#undef __
