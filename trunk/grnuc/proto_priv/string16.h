#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/EX_src/string16.c */
extern short *cvt8to16 __((unsigned char *in));
extern int vsprintf16 __((int va_alist));
extern int sprintf16 __((int va_alist));
extern int is_conv_char __((int character));
extern unsigned char *CX16to8 __((short *short_ptr));
extern short *CX8to16 __((unsigned char *char_ptr));
extern short *strcpy16 __((short *short1_ptr, short *short2_ptr));
extern int strlen16 __((short *ptr_short));
extern int strcmp16 __((short *s1, short *s2));
extern int strncmp16 __((short *s1, short *s2, size_t cnt));
extern short *strncpy16 __((short *short1_ptr, short *short2_ptr, size_t cnt));
extern short *strcat16 __((short *short1_ptr, short *short2_ptr));
extern short *strncat16 __((short *short1_ptr, short *short2_ptr, size_t cnt));
extern short *strdup16 __((short *s));
extern short *strchr16 __((short *s, int find_let));
extern short *strrchr16 __((short *s, int find_let));
extern short *strpbrk16 __((short *s1, short *s2));
extern int strspn16 __((short *s1, short *s2));
extern int strcspn16 __((short *s1, short *s2));
extern short *strtok16 __((short *s1, short *s2));
extern int fwritestr16 __((short *str, FILE *out, int special));
extern int get_configuration_data __((char *config_file, char *config_param, char *param_value));

#if defined(__cplusplus)
}
#endif


#undef __
