#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nodein/NDchannel.I */
extern int NDget_channel __((OM_S_CHANSELECT **father, OM_S_CHANSELECT **children));
extern int NDget_obj_size __((void));

#if defined(__cplusplus)
}
#endif


#undef __
