#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRputkybf.C */
extern void GRput_keybuff __((char *str));

#if defined(__cplusplus)
}
#endif


#undef __
