#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/condit/COm_condit4.I */
extern int ACprint_condition __((struct ACcond_val *condition, char *text));

#if defined(__cplusplus)
}
#endif


#undef __
