#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/UT_src/UTstring.c */
extern char chr __((int x));
extern char *fgetstab __((char buf[], int maxbuf, int tabchar, FILE *in));
extern int isndelim __((int c));
extern int isnumstr __((char str[]));
extern int isoperator __((int c));
extern int islower_alpha __((int Char));
extern int tolower_alpha __((char *Char));
extern int isupper_alpha __((int Char));
extern int toupper_alpha __((char *Char));
extern int isnumeric __((int Char));
extern int isalphanumeric __((int Char));
extern int isstrstr __((char str[]));
extern int ord __((int x));
extern char *skipchar __((char *buf, int argch));
extern char *skiptochar __((char *buf, int argch));
extern int straddesc __((char str[], int ch));
extern char *strccat __((char buf[], int c));
extern int strccnt __((char buf[], int c));
extern char *strccpy __((char d[], char s[], int c));
extern int strCdel __((char buf[], int c, int dir));
extern char *strcdup __((char str[], int c, int cnt));
extern int strcindex __((char buf[], int c));
extern int strclast __((char buf[], int c));
extern int strcleft __((char buf[], int c));
extern int strcleftright __((char buf[], int c, int *left, int *right));
extern int strcright __((char buf[], int c));
extern int strcsqz __((char buf[], int c, int r1, int r2));
extern char *strcsub __((char buf[], int c));
extern char *strcsubindex __((char buf[], int n, int c));
extern int strexist __((char *list[], char *string, int maxlist));
extern int strileft __((char buf[], int cindex, int c));
extern int striright __((char buf[], int cindex, int c));
extern int strisub __((char oldstr[], char insstr[], int s, int f));
extern char *strlshft __((char buf[], int cindex, int shift));
extern int strnleft __((char buf[], int c));
extern int strnright __((char buf[], int c));
extern char *strrcpy __((char dbufd[], char sbufs[], int sstart, int send));
extern char *strssub __((char dbuf[], char vbuf[], char sbuf[]));
extern char *strwidth __((char str[], int colwidth, int just));
extern char *strwsub __((char dbuf[], char vbuf[], char sbuf[]));
extern char *strzero __((char str[], int cnt));
extern int getbufint __((char buf[], int *lastdigit));
extern char *getbufstr __((char buf[], int *lastdigit));
extern int iswhitespace __((int c));
extern char *strfind __((char *char_string, char *cmpstring));
extern char *strfind16 __((short *char_string, short *cmpstring));
extern int move_ubytes __((unsigned char *s_array, unsigned char *d_array, int n));
extern int move_bytes __((char *s_array, char *d_array, int n));
extern GGitem_list *UT_find_GGitem_list __((GGlist typeface_name, GGitem_list *typeface_names, int num_typefaces, int *typeface_index));
extern GGlist *UT_find_GGlist __((GGlist typeface_name, GGlist *typeface_names, int num_typefaces, int *typeface_index, int len));
extern int UT_find_path __((Typepath *typeface_changes, Typepath *end_changes, Typepath **typepath_ptr, Typepath typeface));

#if defined(__cplusplus)
}
#endif


#undef __
