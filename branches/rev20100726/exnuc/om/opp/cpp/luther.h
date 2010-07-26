#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./om/opp/cpp/luther.c */
int luther_char_value __((char *s));
void luther_unget_tok __((struct cpp_token *tt));
void luther_get_tok __((void));
void luther_tok_from_string __((char **s));
void luther_open __((char *filename));
void luther_getc __((struct char_data *a));

#if defined(__cplusplus)
}
#endif
