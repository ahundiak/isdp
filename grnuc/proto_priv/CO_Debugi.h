#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/debug/CO_Debugi.I */
static Activate_pde_index __((void));
static Add_pde_bottom __((void));
static Create_pd __((void));
static Deactivate_pde_index __((void));
static Delete_pde_index __((void));
static Process_pd __((void));
extern int display_class __((struct deb_head *p_deb_head, struct menu *p_menu));
extern int display_method __((struct deb_head *p_deb_head, char *classname, struct menu *p_menu));
extern int alloc_menu __((struct menu *p_menu, int size_menu));
extern int free_menu __((struct menu *p_menu));

#if defined(__cplusplus)
}
#endif


#undef __
