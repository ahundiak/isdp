#if !defined(_ERROR_H)
#define  _ERROR_H  1

/* defines for error severity levels */

#define ERR_INFO     0
#define ERR_WARNING  1
#define ERR_ERROR    2
#define ERR_FATAL    3

#define ERR_DFLT (void (*)())0

/* error descriptor structure */

typedef struct {
                 void (*handler[4]) ();
                 char  *prefix[4];
                 char **msgtbl;
                 char  *sysprefix;

               } ERRDESCR;

/* error routines */

#if defined (__cplusplus)
extern "C" {
#endif
#if defined(__STDC__) || defined (__cplusplus)
extern void   report_error (ERRDESCR *Estruct, int msg_id,
                                      int severity, void (*cleanup_fn)(), ...);
extern void   report_syserr (void);
extern void (*trap_errors (void (*function)())) ();
#else /* K&R "C" */
extern void   report_error ();
extern void   report_syserr ();
extern void (*trap_errors ()) ();
#endif
#if defined(__cplusplus)
}
#endif

#endif
