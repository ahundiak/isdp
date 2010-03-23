/*
 *   Bitstream standard macros and definitions
 *
 *   A NOTE ON BOOLEAN VALUES:
 *        FALSE/false is zero. TRUE/true is only guaranteed to be non-zero.
 *        These constants will work across the assignment (=) operator,
 *        but not across the equivalence (==) operator,
 *        due to truncation and sign extension.
 *        The only good test for TRUE/true (non-zero) is: if (expression)
 *        The only valid for FALSE/false (zero) is: if (! expression)
 *   REMEMBER to cast defined values when using them in return() statements.
 *
 *  1)  30-Dec-86   tpl     added parentheses around READ and write macros
 *                          that OR values together
 */


#include <stdio.h>

/**** MACHINE DEPENDANT DECLARATIONS ****/

#ifdef apollo
/* includes and macro definitions only for APOLLO */

#include "/sys/ins/base.ins.c"
#include "/usr/include/fcntl.h"

#define assert_trap pfm_$error_trap(0x120010)

#define   READ      0
#define   WRITE     (O_WRONLY | O_CREAT | O_TRUNC)
#define   OMODE     0666   /* read/write permission for all users */

typedef   int       pointr;     /* pointer on MC68000 CPU */

#define MAX_READ  131072
#define MAX_WRITE 131072

/*
 *   The following are defined by the Apollo system in /sys/ins/base.ins.c:
 *   typedef   unsigned char boolean;
 *   #define   true      ((unsigned char) 0xffff)
 *   #define   false     ((unsigned char) 00)
 *   void is built-in as a data type for functions not returning a value
 */
#endif /* apollo */
#ifdef MSDOS
/* macro definitions and type declarations only for IBM PC */

#include <fcntl.h>

#define LINT_ARGS

#define assert_trap exit(0)

/* definitions that control memory usage. see alloc.c, bmap.c, and main.c for more
 * details on each. define all three of these (ms_dos) or none (apollo).
 */
#define BMAPS_IN_TEMP_FILE          /* images stored in temp file instead of memory */
#define MAX_STORED_BMAP     16383   /* maximum size of image stored in file */
#define MAX_BMAP_BYTES      32768   /* maximum size of bitmap BFG can generate */

typedef unsigned char boolean;

#define   READ      (O_RDONLY | O_BINARY)
#define   WRITE     (O_WRONLY | O_BINARY | O_CREAT | O_TRUNC)
#define   OMODE     0666   /* S_IREAD | S_IWRITE from sys/stat.h */

typedef   unsigned long    pointr;     /* pointer on PC AT huge model */

#define MAX_READ  65500
#define MAX_WRITE 65500

#endif /* MSDOS */
#ifdef IPRO
/* includes and macro definitions only for interpro */

#include <fcntl.h>

#define assert_trap exit(0)

#define   READ      0
#define   WRITE     (O_WRONLY | O_CREAT | O_TRUNC)
#define   OMODE     0666   /* read/write permission for all users */

typedef   unsigned long  pointr;     /* pointer on interpro */

#define MAX_READ  131072
#define MAX_WRITE 131072

typedef   unsigned char boolean;

#endif /* interpro */

/**** STANDARD BITSTREAM DECLARATIONS ****/

#define assert_msg  "\nASSERTION FAILED %s[%d].\n"
#define assert(a)  if (!(a)) { fprintf(stderr, assert_msg,__FILE__,__LINE__); assert_trap; }

#define   NO        0
#define   YES       1
#define   FALSE     0
#define   TRUE      1
#define   NOT_OK    0
#define   OKAY      1
#define   SUCCEED   0
#define   FAIL      1
#define   RD_WR     2
#define   EOJ       -1
#define   NOT_EOF   0

#define   FUNCTION
#define   DECLARE   {
#define   BEGIN
#define   END       }

#define   MAX(a, b) ((a) > (b) ? (a) : (b))
#define   MIN(a, b) ((a) < (b) ? (a) : (b))
#define   ABS(a)    ((a) >  0  ? (a) : (-a))
#define   ROUND(a)  ((a) >= 0  ? (a) + .5 : (a) - .5)

#define   FIX7(n)   (((n) & 0x80) ? ((n) | ~0x7f) : ((n) & 0x7f))
#define   UFIX8(n)  ((n) & 0xff)
#define   UFIX16(n) ((unsigned)((n) & 0xffff))
#define   UFIX32(n) ((unsigned)((n) & 0xffffffff))

#define   MAX15     32767
#define   MIN15    -32768
#define   UMAX16    65535

#define   MAX31     2147483647L
#define   MIN31    -2147483648L
#define   UMAX32    4294967295L

#define   EMAXP     10e38
#define   EMINP     10e-38
#define   EMAXN    -10e-38
#define   EMINN    -10e38

#define   global

typedef   char      fix7,
                    fix8,
                    chr8,
                    chr;

typedef   unsigned char
                    ufix8,
                    bool8,
                    bit8;

typedef   short     fix15,
                    fix16,
                    bool16,
                    chr16,
                    aligned;

typedef   unsigned short
                    ufix16,
                    bit16,
                    field16;

typedef   long      fix31,
                    fix32;

typedef   unsigned long
                    ufix32,
                    bit32,
                    field32,
                    bool32;

typedef   int       bool,
                    fix,
                    fdes;       /* file descriptor for 'open', 'create' */

typedef   unsigned  ufix;

typedef   double    real;       /*  "real" should be used when it doesn't
                  matter with respect to accuracy or data storage whether
                  to use "double" or "float", but when the most important
                  consideration is execution efficiency. Such is the case
                  with Apollo's "C" compiler for the DN300, although this
                  might not be universally true.                        */
