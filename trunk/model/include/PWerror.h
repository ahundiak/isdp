#ifndef _PWerror_include
#define _PWerror_include

#ifndef _STDIO_H
#include <stdio.h>
#endif

#include <string.h>
#include "PWapi/printerr.h"
#include "PWapi/dbglevel.h"

/*--------------Constants/Structs/Defs related to the error stack----------- */

/*
 * The stack consists of instances of the following structure. This structure
 * has the fields to hold all kinds of information. Some fields may be 
 * not used for a particular error type. This structure is the medium of
 * communication with the outside world too.
 */

struct PWerrentry
{
  PWresult  retcode;

  enum 
  {
    PWerrentry_null,
    PWerrentry_id,
    PWerrentry_idval,
    PWerrentry_idid
  } type;

  PWobjid id1;
  PWobjid id2;
  double val;
};

#include "PWapi/errstack.h"
#include "PWapi/errlogfile.h"

/*------------------------Completion Code Creation---------------------------*/

/*
 * The term "completion code", "return code", "error code" or "result" are used
 * interchangebly throughout the system. They all refer to the 32-bit word
 * (typedef-ed as PWresult) that a function can return packing it with 
 * information about the success/failure/operation of the function. It consists
 * of three parts:
 * a) Code for the sub-system or facility  (11 bits starting at bit-26)
 *    These codes are listed in the "minimum" include file.
 * b) Code for the kind of condition that occurred (12 bits starting 
 *    at bit-14). These codes are listed later in this file.
 * c) Code for the type of return code -- Success, Information, Error, etc.
 *    (3 bits starting at bit-2). These are listed below.
 * NB:bit-0 is the lowest order bit and bit-31 is the highest. Note that in
 *    the above definition bit-15 and bit-27 thru bit-31 are unused. This
 *    scheme was being followed earlier and there really did not seem to be
 *    any point in changing it.
 */
#define PW_K_Success      0x00000001
#define PW_K_Information  0x00000003
#define PW_K_Error        0x00000002
#define PW_K_Warning      0x00000000
#define PW_K_Fatal        0x00000004

/*
 * Following macros are used to get the three parts of an error code.
 * These are the sole means of accessing this information.
 */
#ifndef GetSubsys
#define GetSubsys(code) (((code) & 0x07ff0000) >> 16)
#endif

#ifndef GetCode
#define GetCode(code) (((code) & 0x00007ff8) >> 3)
#endif

#ifndef GetCodeType
#define GetCodeType(code) ((code) & 0x00000007)
#endif

/*
 * Following macros are used to create the three-part error code. Note that
 * the 0x000 subsystem defaults to the "Pathway system", 0x0000 condition code
 * defaults to "unspecified condition" and 0x1 is the code type for "success".
 * Thus, the generic success and failure codes are trivial. Different macros
 * are used to set informational or error conditions. Macro to set the success
 * code is added for completeness.
 */

#define SetSuccess(subsys, code) \
         ((subsys) << 16 | (code) << 3 | PW_K_Success)

#define SetInfo(subsys, code) \
         ((subsys) << 16 | (code) << 3 | PW_K_Information)

#define SetError(subsys, code) \
         ((subsys) << 16 | (code) << 3 | PW_K_Error)

#define SetWarning(subsys, code) \
         ((subsys) << 16 | (code) << 3 | PW_K_Warning)

#define SetFatal(subsys, code) \
         ((subsys) << 16 | (code) << 3 | PW_K_Fatal)


/*-----------------------Handling Error Codes--------------------------------*/

/*
 * To be used to check if a return code indicates an error situation.
 * All error codes in Pathway and EMS conform to the standard - LSB being set
 * for non-error. BS-math is a notable exception
 */
#define IsError(code) (!((code) & 1))

/*
 * To be used after a function call that returns an error code. If this is
 * an error situation, the macro forces a branch to the "wrap up" part of the
 * code at the "label". 
 */
#define OnErrorCode(errcode, label) \
         if (IsError (errcode)) \
         { \
           pwPrintFileLine ((char *) strrchr((char *) __FILE__, '/') ? \
                             (char *) strrchr((char *) __FILE__, '/')+1 : \
                             (char *) __FILE__, \
                            (int) __LINE__); \
           goto label; \
         }

/*
 * To be used in situations where the error code does NOT conform to the
 * standard (eg: BS-math). It is also to be used where custom checks for
 * error conditions have to be made. The idea is to branch to wrap-up on
 * error. The variable holding the error return code is set to the indicated
 * code before the branch.
 */
#define OnErrorState(state, retval, errcode, label) \
         if (state) \
         { \
           retval = errcode; \
           if (IsError ((retval))) \
             pwPrintFileLine ((char *) strrchr((char *) __FILE__, '/') ? \
                               (char *) strrchr((char *) __FILE__, '/')+1 : \
                               (char *) __FILE__, \
                              (int) __LINE__); \
           goto label; \
         }

/*-----------------------Examples of handling error codes--------------------*/

/*
   Following are some examples of use of the above macros.

   a)  retval = PW_K_Success;
   
   b)  OnErrorState (retval != BSSUCC, retval,
        SetError(PW_K_Trimming, PW_K_Outside), wrapup);

   c)  p_genptr = malloc (x);
       OnErrorState (!p_genptr, retval, SetError(0, PW_K_NoDynamicMemory),
        wrapup);

   d)  retval = pwSomeFunc (arg1, arg2);
       OnErrorCode (retval, wrapup);

       if (GetCodeType (retval) == PW_K_Information)
       {
         if (GetCode (retval) == PW_K_OutOfBounds)
           ...
         else if (GetCode (retval) == PW_K_NoSolution)
           ...
       }
 */

/*-------------------------Debugging constants-------------------------------*/

/*
 * The system provides different levels of debug setting. Functions exist
 * to set these levels during runtime. The code exhibits different trace
 * behaviour depending on the setting, increasing in sophistication with the
 * levels. 
 */
#define PW_K_MaxDebugLevel   3

#define PW_K_DebugNull       0
#define PW_K_DebugWarning    1
#define PW_K_DebugTrace      2
#define PW_K_DebugTraceHigh  3

/*-------------------------Wrapup Macros------------------------------------*/

/*
 * The following macros are to be used at the wrapup of functions. This family
 * of macros always take in, at a minimum, an error code and an ASCII string
 * that identifies the exact function where this error is taking place. If
 * the error code indicates all is well, then this macro behaves as a noop.
 * But if there is an error, the following action is performed (further, 
 * specific actions are taken that vary from macro to macro):
 * 1) If the global debug-level has been set to anything other than zero (0),
 *    the error code is interpreted and printed.
 * 2) The error code and string are put into the error-handler stack
 *    which can later be queried by the GUI or anybody else.
 */

/*
 * Plain, vanilla wrapup macro that does the minimum. 
 */
#define PW_Wrapup(retcode, idstr) \
         if (IsError (retcode)) \
         { \
           if (pwGetDebugLevel()) \
             pwPrintError (retcode, idstr); \
           pwPushError (retcode); \
         } \
         else if (pwGetDebugLevel() >= PW_K_DebugTraceHigh) \
         { \
           pwPrintError (NULL, idstr); \
         }

/*
 * Wrapup function that takes in an id that is usually the object-id of the 
 * object that is being worked upon. This way the caller has an idea of
 * what object caused the error. The functions provided to interpret the
 * error-handler stack can translate the error condition back to human
 * language.
 */
#define PW_WrapupId(retcode, idstr, id) \
         if (IsError (retcode)) \
         { \
           if (pwGetDebugLevel()) \
             pwPrintErrorId (retcode, idstr, id); \
           pwPushErrorId (retcode, id); \
         } \
         else if (pwGetDebugLevel() >= PW_K_DebugTraceHigh) \
         { \
           pwPrintErrorId (NULL, idstr, id); \
         }

/*
 * Wrapup function that takes in an id and a double value. Many a times,
 * a value is in error. The description otherwise is pretty much as
 * for above.
 */
#define PW_WrapupIdVal(retcode, idstr, id, val) \
         if (IsError (retcode)) \
         { \
           if (pwGetDebugLevel()) \
             pwPrintErrorIdVal (retcode, idstr, id, val); \
           pwPushErrorIdVal (retcode, id, val); \
         } \
         else if (pwGetDebugLevel() >= PW_K_DebugTraceHigh) \
         { \
           pwPrintErrorIdVal (NULL, idstr, id, val); \
         }


/*
 * Wrapup function that takes in two ids. Sometimes, two objects are directly
 * interacting (eg: intersection). The description otherwise is pretty much as
 * for above.
 */
#define PW_WrapupIdId(retcode, idstr, id1, id2) \
         if (IsError (retcode)) \
         { \
           if (pwGetDebugLevel()) \
             pwPrintErrorIdId(retcode, idstr, id1, id2); \
           pwPushErrorIdId (retcode, id1, id2); \
         } \
         else if (pwGetDebugLevel() >= PW_K_DebugTraceHigh) \
         { \
           pwPrintErrorIdId (NULL, idstr, id1, id2); \
         }

/*
 * The maximum number of elements that can be registered on the "error stack".
 * If the number of elements to be pushed on the stack exceeds this amount,
 * a record is placed at the top of the stack that indicates that further
 * information has been truncated. It is hoped that enough useful information
 * has already been registered for use before the stack runs out.
 */

#define PW_K_MaxErrStackSize	25

/*-------------------------List of Condition Codes---------------------------*/

/*
 * Following is the complete list of condition codes that are used within a
 * Pathway-based error code. 16-bits are used to hold this quantity. Add a new 
 * code at the bottom of this list (and never remove any from the middle).
 * The code should as far as possible be generic. Also, remember that this
 * ALONG with the other pieces of the error code (sub-system AND the 
 * error/info/succ type) yields the final interpretation. Example: 
 * TRIM-SEQUENCE-ERROR means that something expected to be in sequence within 
 * trimming was found not to be so. Including an error code that said 
 * BadTrimSequence would be non-generic and in fact would read redundantly.
 *
 * ADDING NEW ERROR CODE:
 * The codes are grouped into logical sets. Each set can have upto 32 members
 * (note the hex sequence of numbers in the following sets). Pick the set
 * or create a new one (following the sequencing for the existing order) and
 * add the code. Then add the appropriate error string in printerr.c
 */

#define PW_K_Nothing		0x000

/* System/Generic level */
#define PW_K_DynamicMemory	0x001
#define PW_K_Interrupt		0x002
#define PW_K_Internal		0x003
#define PW_K_NotImplemented	0x004
#define PW_K_InvalidArg		0x005
#define PW_K_Memory		0x006
#define PW_K_EndOfData		0x007
#define PW_K_BadData		0x008

/* Ordering */
#define PW_K_Sequence		0x020
#define PW_K_Unique		0x021
#define PW_K_Ambiguous		0x022
#define PW_K_Cycle		0x023
#define PW_K_Mixture		0x024

/* Geom prop */
#define PW_K_Close		0x040
#define PW_K_Open		0x041
#define PW_K_Bounds		0x042
#define PW_K_Coincident		0x043
#define PW_K_Degenerate		0x044
#define PW_K_Planar		0x045
#define PW_K_NonPlanar		0x046

/* Tolerance */
#define PW_K_Tolerance		0x060

/* Intersection */
#define PW_K_Orient		0x080
#define PW_K_NonOrient		0x081
#define PW_K_Intersect		0x082
#define PW_K_NoIntersect	0x083

/* Gen Condition */
#define PW_K_Modified		0x0a0
#define PW_K_UnModified		0x0a1
#define PW_K_Found		0x0a2
#define PW_K_NotFound		0x0a3

#endif
