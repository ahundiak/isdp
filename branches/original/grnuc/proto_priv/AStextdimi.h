#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/csrc_130/AStextdimi.I */
extern int print_IGResintx __((struct IGResintx *tx_attr));
static pre_process_string __((struct IGResintx *tx_attr, struct GRdisplay *display));

#if defined(__cplusplus)
}
#endif


#undef __
