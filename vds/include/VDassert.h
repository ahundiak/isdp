/* $Id: VDassert.h,v 1.3.4.1 2004/03/29 16:25:21 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDassert.h
 *
 * Description: Assert Debugging Routines
 *
 *
 * Revision History:
 *      $Log: VDassert.h,v $
 *      Revision 1.3.4.1  2004/03/29 16:25:21  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/07 19:04:51  jdsauby
 *      backed up a version for debug macro problems.  -jds
 *
 *      Revision 1.1  2001/01/09 21:56:39  art
 *      ah
 *
 * Revision 1.1  2000/07/24  20:45:24  pinnacle
 * ah
 *
 * Revision 1.4  2000/07/20  20:18:26  pinnacle
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/21/00  ah      Created
 * 01/09/01  ah      sp merge
 * 02/13/04  ah      Fixed abort macro
 * 11/17/10  ah      SOL10 Check in
 ***************************************************************************/

/* -----------------------------------------------
 * The initial goal of this file was to provide a means to
 * guard against unexpected NULL pointers.
 *
 * Pretty much everyone seems to agree that in a debug version
 * Lots of explicit checks for null pointers is a good idea.
 *
 * For delivered software, opinions vary.
 *
 * One theory is to remove the check completely resulting in the
 * smallest fastest code.  The problem is if nulls are not uncovered
 * during testing then core dump.
 *
 * Another theory is to leave the checks, handle nulls gracefully
 * but suppress warnings.  This tends to require more code (for
 * the gracefull handling but should cut down on file size.
 *
 * The plan is to test the file size concept by adding a bunch of code
 * with asserts then compling with and without the error messages.
 *
 * The third plan is to ship with the debug code fully enabled.
 * This would probably be really good for service packs and other
 * quick fix or last minute changes.  
 *
 * This was file was created to allow exploring the various options
 * without messing up existing code.
 *
 * Also want to look at the possibility of saving these messages
 * to a file and maybe notifying someone automatically when one is recieved.
 * This avoids the issue of the user ignoring back screen messages.
 */

/* -----------------------------------------------
 * By design, skip the usual check against multiple inclusions
 * to allow including with different master control
 * flags set
 */

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------
 * Utility for setting trace file and function name
 * Use this routine instead of __FILE__ to prevent multiple
 * copies of static data and to optionally provide different information
 * 
 * ffn - Function File Name
 *  fn - Function Name
 */
#define VDASSERT_FFN(str)            \
  static char *ffn() { return str; } \
  static int traceFlagx

#define VDASSERT_FN(str)      \
  char fn[] = str;            \
  int  traceFlag = traceFlagx

/* ------------------------------------------
 * Send all assert messages through here
 */
extern int VDassertPrint __((int type, int level, char *ffn, char *fn, int line, char *msg));

/* ------------------------------------------
 * This is intended to be the most commonly
 * used assert, if the assert fails, then goto
 * hardcoded wrapup label
 */
#define VDASSERTW(f)                                   \
  if (f) NULL;                                         \
  else {                                               \
    VDassertPrint(0,0,ffn(),fn,__LINE__,NULL);         \
    goto wrapup;                                       \
  }

/* ---------------------------------------------
 * If assert fails, just continue executing
 */
#define VDASSERTC(f)                           \
  if (f) NULL;                                 \
  else {                                       \
    VDassertPrint(0,0,ffn(),fn,__LINE__,NULL); \
  }

/* ---------------------------------------------
 * If assert fails, goto specified label
 */
#define VDASSERTL(f,label)                     \
  if (f) NULL;                                 \
  else {                                       \
    VDassertPrint(0,0,ffn(),fn,__LINE__,NULL); \
    goto label;                                \
  }

/* ---------------------------------------------
 * If assert fails, abort
 */
#define VDASSERTA(f)                           \
  if (f) NULL;                                 \
  else {                                       \
    VDassertPrint(0,0,ffn(),fn,__LINE__,NULL); \
    abort();                                   \
  }

/* ------------------------------------------
 * This is intended to be the most commonly
 * used assert, if the assert fails, then goto
 * hardcoded wrapup label
 */
#define VDASSERTWM(f,str)                     \
  if (f) NULL;                                \
  else {                                      \
    VDassertPrint(0,0,ffn(),fn,__LINE__,str); \
    goto wrapup;                              \
  }

/* ---------------------------------------------
 * If assert fails, just continue executing
 */
#define VDASSERTCM(f,str)                     \
  if (f) NULL;                                \
  else {                                      \
    VDassertPrint(0,0,ffn(),fn,__LINE__,str); \
  }

/* ---------------------------------------------
 * If assert fails, goto specified label
 */
#define VDASSERTLM(f,label,str)               \
  if (f) NULL;                                \
  else {                                      \
    VDassertPrint(0,0,ffn(),fn,__LINE__,str); \
    goto label;                               \
  }

/* ---------------------------------------------
 * If assert fails, abort
 */
#define VDASSERTAM(f,label,str)               \
  if (f) NULL;                                \
  else {                                      \
    VDassertPrint(0,0,ffn(),fn,__LINE__,str); \
    abort();                                  \
  }

/* ---------------------------------------------
 * Fake macro to flag when the user forgets
 * the use the control letters
 * Otherwise, a call to VDASSERT is made
 */
#define VDASSERT(a,b,c,d,e) NULL;

/* ---------------------------------------------
 * Be nice to keep track of asserts generated
 * especially during tesing
 */

typedef struct 
{
  IGRint  type;
  IGRint  level;
  IGRchar desc[128];
} TVDassertInfo;

extern IGRstat VDassertClearStack __(());
extern IGRstat VDassertPrintStack __(());
extern IGRstat VDassertGetStack   __((IGRint *cnt, TVDassertInfo **info));
extern IGRstat VDassertHaveAssert __(());
extern IGRstat VDassertInitStack  __((IGRint max));
extern IGRstat VDassertFreeStack  __(());

/* ------------------------- */
#if defined(__cplusplus)
}
#endif



