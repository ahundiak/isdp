#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/palco/COpallib.I */
extern int COpal_palette_locate_func __((void));

#if defined(__cplusplus)
}
#endif


#undef __
