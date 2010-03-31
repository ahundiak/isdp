#ifndef _PWminimum_include
#define _PWminimum_include

/*
 * Some commonly used constants. These make for better readability and should
 * be used whenever applicable.
 */
#define NULL 0

#define X  0
#define Y  1
#define Z  2

#define U  0
#define V  1

#define MINIMUM  0
#define MAXIMUM  1

#define TRUE  1
#define FALSE 0

#define START  0
#define STOP   1

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define LEFT  0
#define RIGHT 1

#define PREV  0
#define NEXT  1

/*
 * Some general limits and constants used in the system. These are generic
 * and can be used in any sub-system.
 */

#define PW_K_MaxCharOnLine	80     /* Max chars on an ASCII output line */
#define PW_K_MaxCharFilename    128    /* This is sort of a standard */
#define PW_K_MaxStringLen       80     /* Max chars in a string (default) */
#define PW_K_PathMax	        1023   /* Max chars for a path */

/*
 * Following is the complete list of sub-system (or facility) codes that
 * are used within a Pathway-based code holder. 12-bits are used to hold this
 * quantity. Examples of their use is in the attribute identifier and in the
 * error code. This sub-system code is usually positioned in the most 
 * significant 12 bits of the word. Add a new sub-system code at the bottom of
 * this list (and never remove any from the middle).
 *
 * While adding new sub-system codes, remember to update the file - printerr.c
 * which contains the functions to return the corresponding ASCII string.
 */

#define PW_K_Pathway		0x000
#define PW_K_Trimming		0x001
#define PW_K_Orientation	0x002
#define PW_K_PtLocation		0x003
#define PW_K_PathwayMath	0x004
#define PW_K_BspMath		0x005
#define PW_K_OM                 0x250
#define PW_K_EMS                0x028
#define PW_K_MessageString      0x03c

/*
 * This typedef is used in defining the return type of functions that return
 * an error code. This definition must always be used in the prototypes.
 */

typedef unsigned int PWresult;

/*
 * Type definitions for commonly occurring datatypes. Some of these datatypes
 * (points) can be written to and read from files.
 */
typedef short  PWboolean;
typedef double PWpoint2d[2];
typedef double PWpoint[3];
typedef double PWvector2d[2];
typedef double PWvector[3];
typedef double PWmatrix[16];
#ifndef PPL
typedef PWpoint2d PWrange2d[2];
typedef PWpoint PWrange[2];
#else
typedef double PWrange2d[4];
typedef double PWrange[6];
#endif
 
enum  PWdisplaymode  
{
  PWbackground_draw, 
  PWbackground_erase, 
  PWhighlight_draw, 
  PWhighlight_erase,
  PWunknown 
};
 


/*
 * Generic enumerated types that deal with enumerating a relative direction
 * with respect to a given one. Typically, PWdirtype is used to clarify a 
 * a cross-product result and PWrelvectype is used to clarify a dot-product
 * result. One must remember that the enumeration is mutually exclusive
 * within a type. So, in the case of PWrelvectype - even though 'aligned'
 * is forward pointing wrt to a given vector, it is more specific than 
 * that. Conversely, if 'fwd_pointing' has been chosen it implies that it
 * is NOT aligned (and therefore the relative direction lies somewhere in
 * between aligned and normal).
 */

enum PWdirtype
{
  PWdir_unknown,
  PWdir_left,
  PWdir_right,
  PWdir_along
};

enum PWrelvectype
{
  PWrelvec_unknown,
  PWrelvec_aligned,
  PWrelvec_normal,
  PWrelvec_anti_aligned,
  PWrelvec_fwd_pointing,
  PWrelvec_bwd_pointing
};

/*
 * Datatype that identifies an object uniquely in the data-base.
 * This identifier is based on the OM database, which is currently
 * the only means of persistence. Read and write (print) functions are
 * provided. Related information like classid and other constants are also
 * defined.
 */

#define OS OM_Gw_current_OS
#define PW_K_NullObjid 0xffffffff
#define PW_K_NullClass 0xffff

typedef unsigned long PWobjid;
typedef unsigned short PWosnum;
typedef unsigned short int PWclassid;

struct PWid
{
  PWobjid objid;
  PWosnum osnum;
};
 
/*
 * This structure should be rarely used. In the event that a need is felt
 * to send an OM message to an object rather than use a C-function (perhaps
 * one does not exist), the following structure can be used. It is the
 * equivalent of OM_S_MESSAGE (did not want to include the entire OMminimum.h
 * in here to get that definition).
 */

struct methselect
{
  PWclassid DefClassid;
  PWclassid ReqClassid;
  unsigned short FuncIndex;
};

struct PWommsg
{
  struct methselect select;
  unsigned short size;
  char *p_arglist;
};

#endif
