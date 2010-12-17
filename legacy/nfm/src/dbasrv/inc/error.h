/* $Revision: 1.1 $ */
/* defines for error severity levels */

#define ERR_INFO     0
#define ERR_WARNING  1
#define ERR_ERROR    2
#define ERR_FATAL    3

#define ERR_DFLT (int (*)())0

/* error descriptor structure */

typedef struct {
                 int  (*handler[4]) ();
                 char  *prefix[4];
                 char **msgtbl;
                 char  *sysprefix;

               } ERRDESCR;

/* error routines */

void   report_error ();
void   report_syserr ();
int  (*trap_errors ()) ();
