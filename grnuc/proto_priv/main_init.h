#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/gde/gdedriver/main_init.c */
extern int main_form __((void));
extern char *product_path __((char *product));

#if defined(__cplusplus)
}
#endif


#undef __
