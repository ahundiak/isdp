#if !defined(_XCMISC_H)
#define  _XCMISC_H  1

#if defined(__cplusplus)
extern "C" {
#endif
#if defined(__STDC__) || defined(__cplusplus)
extern char *exefile        (void);
extern void  exit           (int status);
extern void  _exit          (int status);
extern int   exitadd        (int (*func)());
extern int   exitdel        (int (*func)());
extern void  getargs        (int *argc_p, char ***argv_p, char ***envp_p);
extern void *namecache_init (int size, int usedups);
extern int   namecache_add  (void *cache, char *name);
extern char *namecache_fini (void *cache);
extern int   slock          (int *lockptr);
extern int   slockw         (int *lockptr);
extern char *stralloc       (char *string);
extern void  strfree        (char *string);
extern int   trapreturn     (void (*fn)(), void *arg);
extern char *whence         (char *name, char *workdir);
#else  /* K&R "C" */
extern char *exefile        ();
extern void  exit           ();
extern void  _exit          ();
extern int   exitadd        ();
extern int   exitdel        ();
extern void  getargs        ();
extern void *namecache_init ();
extern int   namecache_add  ();
extern char *namecache_fini ();
extern int   slock          ();
extern int   slockw         ();
extern char *stralloc       ();
extern void  strfree        ();
extern int   trapreturn     ();
extern char *whence         ();
#endif
#if defined(__cplusplus)
}
#endif

#endif
