#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCccommand.C */
extern int LCcheck_command __((IGRint *response, IGRchar *response_data, struct GRevent *event1));

#if defined(__cplusplus)
}
#endif


#undef __
