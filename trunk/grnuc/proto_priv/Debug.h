#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/debug/Debug.c */
extern int DB_activate __((struct deb_head *p_deb_head, unsigned int nb_class, unsigned int nb_method, unsigned int step_size));
extern int DB_desactivate __((struct deb_head *p_deb_head));
extern int DB_clear __((struct deb_head *p_deb_head));
extern int DB_mod_default_level __((int default_level, struct deb_head *p_deb_head));
extern int DB_mod_class_level __((int level, char *classname, struct deb_head *p_deb_head));
extern int DB_debug __((int level, char *classname, char *methodname, struct deb_head *p_deb_head));
extern int DB_add_class __((char *classname, struct deb_head *p_deb_head));
extern int DB_remove_class __((char *classname, struct deb_head *p_deb_head));
extern int DB_modify_class __((char *old_classname, char *new_classname, struct deb_head *p_deb_head));
extern int DB_give_classname __((struct deb_head *p_deb_head, char *p_classname[]));
extern int DB_give_nb_class __((struct deb_head *p_deb_head, int *p_nb_class));
extern int DB_add_method __((char *classname, char *methodname, struct deb_head *p_deb_head));
extern int DB_remove_method __((char *classname, char *methodname, struct deb_head *p_deb_head));
extern int DB_give_nb_method __((struct deb_head *p_deb_head, char *classname, int *p_nb_method));
extern int DB_give_methodname __((struct deb_head *p_deb_head, char *classname, char *p_methodname[]));
extern int DB_clear_method __((char *classname, struct deb_head *p_deb_head));
extern int DB_in_list __((char *methodname, struct deb_head *p_deb_head, unsigned int index_head, unsigned short *p_index_list));
extern int DB_method_deb __((char *methodname, struct deb_head *p_deb_head, unsigned int index_head));
extern unsigned short DB_class_index __((char *classname, struct deb_head *p_deb_head));
extern int DB_add_name __((char name[], struct d_name *p_name));
extern int DB_remove_name __((struct d_name *p_name));
extern int insert_method __((struct d_name *p_method, struct deb_head *p_deb_head, unsigned int index_head));
extern int DB_print __((struct deb_head deb_head));
extern int DB_write __((struct deb_head *p_deb_head, char *p_filename));
extern int DB_read __((struct deb_head *p_deb_head, char *p_filename));

#if defined(__cplusplus)
}
#endif


#undef __
