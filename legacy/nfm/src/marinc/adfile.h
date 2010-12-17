#define adfcb qq264
#define ad_fgetc qq265
#define ad_fgets qq266
#define ad_filbuf qq267
#define ad_fopen qq268
#define ad_fread qq269
#define ad_fseek qq270
#define ad_ftell qq271
#define ad_setvbuf qq272
#define mylseek qq273
#define initadfilepak qq274
#define ad_fclose qq275

#ifndef ADFILESTRUDEFINED
typedef struct AD_FILESTRU {
  long bufpos;             /* position from which buf was filled */
  int handle;              /* dos file handle */
  int lvl;                 /* bytes left in buf */
  unsigned short bufbytes; /* valid bytes read into buffer */
  short nexchind;          /* index of next char in buffer */
#ifndef WIN
  char *cbuf;              /* pointer to this file's buffer */
#else
  LPSTR cbuf;
#endif
  unsigned short cbufsiz;  /* size of buffer */
  char mallocedbuf;        /* 1 if we allocated the buffer */
  short eofflag;           /* 1 if filbuf fails */
  int flags;               /* hold access modes */
} AD_FILE;
#define ADFILESTRUDEFINED
#endif

AD_FILE adfcb[20];  /* global file control blocks */

extern unsigned char ad_fgetc _((AD_FILE *f));
extern AD_FILE *ad_fopen _((void *path,void *accessmodes));
extern int ad_fclose _((AD_FILE *f));
extern int ad_setvbuf _((AD_FILE *f, char *buf, int buftype, unsigned short size));
extern int ad_fseek _((AD_FILE *f, long offset, int whence));
extern int ad_fread _((void *buf, unsigned int size, unsigned int num, AD_FILE *f));
extern char *ad_fgets _((char *s, int n, AD_FILE *f));
extern void initadfilepak _((void));
extern long ad_ftell _((AD_FILE *f));

#ifndef FILEDEBUG
#define ad_getc(f) \
  ((--((f)->lvl) >= 0) ? ((f)->cbuf[(f)->nexchind++]) : \
     ad_fgetc(f))
#else
#define ad_getc(f) \
  ( \
   printf("ad_getc at level %d\n",(f)->lvl), \
   (--((f)->lvl) >= 0) ? ((f)->cbuf[(f)->nexchind++]) : \
     ad_fgetc(f))
#endif
#define ad_feof(f) (f)->eofflag

