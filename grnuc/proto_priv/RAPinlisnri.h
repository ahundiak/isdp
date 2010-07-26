#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/rap/RAPinlisnri.I */
extern short RAP_suspend_record __((void));
extern short RAP_resume_record __((void));
extern unsigned int RAPFormListener __((char *formName, struct FI_data_st *formData));
extern unsigned int RAP_record_string __((char *command_key, char *command_name_ptr));
extern long RAP_get_keyboard_data __((char *character, int count));
extern long RAP_get_button_data __((void));

#if defined(__cplusplus)
}
#endif


#undef __
