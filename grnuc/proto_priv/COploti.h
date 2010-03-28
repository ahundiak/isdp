#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COploti.I */
extern int PIgetplotdata __((PIplotdata **pd));
extern int PIgetcreate __((PIcreate **cd));
extern int COplot_set_help_topic __((int command_type));

#if defined(__cplusplus)
}
#endif


#undef __
