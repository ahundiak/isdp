#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COspmain.c */
extern int PIgetplotdata __((PIplotdata **pd));
extern int PIgetcreate __((PIcreate **cd));
extern int get_modtype_data __((char *run_name, char *logo_ptr, char *module_class, char *srch_path, char *config_path, char *product_path));
extern int PIfindprod __((char *product, char *path));
extern int main __((int argc, char **argv));

#if defined(__cplusplus)
}
#endif


#undef __
