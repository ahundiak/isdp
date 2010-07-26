#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/so/DEdisyours.I */
extern int DEshow_only_man_soo __((void));
extern int DEshow_all_soo __((void));

#if defined(__cplusplus)
}
#endif


#undef __
