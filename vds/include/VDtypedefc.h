/* $Id: VDtypedefc.h,v 1.5 2001/05/17 14:08:21 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDtypedefc.h
 *
 * Description: Master .c include file
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDtypedefc.h,v $
 *      Revision 1.5  2001/05/17 14:08:21  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:06:12  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/01 15:33:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/10 16:24:27  art
 *      sp merge
 *
 * Revision 1.5  2000/12/08  15:32:34  pinnacle
 * ah
 *
 * Revision 1.4  2000/12/07  17:33:08  pinnacle
 * ah
 *
 * Revision 1.3  2000/12/06  14:38:56  pinnacle
 * ah
 *
 * Revision 1.2  2000/10/27  12:44:34  pinnacle
 * ah
 *
 * Revision 1.1  2000/10/15  12:45:26  pinnacle
 * ag
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/15/00  ah      Created
 * 01/10/01  ah      sp merge
 * 05/17/01  ah      Include VDparamet.h instead of parametric.h
 ***************************************************************************/

/* -----------------------------------------------
 * Just to get things started, make a master
 * include file for c programing
 *
 * Seems to work pretty good, Many of the .C/.I files can in fact
 * include this file instead and they work just fine.  But compile time is
 * greatly reduced.
 *
 * And as long as the codes uses no om macros, then it's easy to change to .c
 */

/* -----------------------------------------------
 * Skip if the regular one was loaded
 */
#ifndef VDtypedef_include

#ifndef VDtypedefc_include
#define VDtypedefc_include

/* -----------------------------------------------
 * Use this as a flag for other files to indicate
 * that this is a c only process
 */
#define c_ONLY 1

/* -----------------------------------------------
 * Some of these get defined by our standard grmake process
 * Need to track down where but have not done so yet
 * The math.h under Forte will not compile as it defined
 * things differently for sparc vs i386
 * For now, just make them go away
 * 
 * 01/10/01 The problem with sparc should now be solved
 * with the new version of mkmk
 */
#if 0
#ifdef   sparc
#undef   sparc
#endif
#ifdef  _sparc
#undef  _sparc
#endif
#ifdef __sparc__
#undef __sparc__
#endif
#endif

/* -----------------------------------------------
 * Verified that __STDC__ is defined
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#ifndef   _STDIO_H
#include "stdio.h"
#endif

/* -----------------------------------------------
 * Not sure about this, not in /usr/include
 * /ingr/grnucsrc/unix_include/c400/standards.h
 * How is the system working now?
 * Ignored some where
 *
 * This is in vds/include/standards.h, it's almost an empty
 * file once used for Intergraph standard macros
 * Keep here for historical reasons
 */
#ifndef  _STANDARDS_H_
//#include "standards.h"
#endif

#ifndef  _STDLIB_H
#include "stdlib.h"
#endif

#ifndef  _STRING_H
#include "string.h"
#endif

#ifndef  _MALLOC_H
#include "malloc.h"
#endif

/* ---------------------------------------------
 * May need to skip for ppl's but work on it later
 * No real reason for ppl's to use this file anyways
 */
#ifndef  _MATH_H
#include "math.h"
#endif

/* ------------------------------------------------
 * Copy of exnuc/include/igrtypedef.h
 */
#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#ifndef NULL
#define NULL	0
#endif

typedef short	IGRboolean;
typedef short 	IGRshort;
typedef long  	IGRlong;
typedef int   	IGRint;
typedef double  IGRdouble;
typedef char	IGRchar;

typedef unsigned char  IGRuchar;
typedef unsigned short IGRushort;
typedef unsigned int   IGRuint;
typedef unsigned long  IGRulong;

typedef	 IGRdouble  IGRvector [3];
typedef  IGRdouble  IGRmatrix[16];
typedef  IGRdouble  IGRpoint  [3];

/* ----------------------------------------------
 * $EXNUC/include/OMtypes.h
 * In a few cases a c program will include OMminimum.h
 * Mainly for scanning object spaces
 */
#ifndef OM_D_MINIMUM
typedef	unsigned int 		OMuint;
typedef unsigned long int 	OMulong;
typedef unsigned short int 	OMuword;
typedef short int 		OMword;
typedef unsigned char 		OMbyte;
typedef unsigned short int 	uword;

typedef unsigned long int	OM_S_OBJID;
typedef unsigned long int      *OM_p_OBJID;

#define OM_K_MAXINT             ((int) 0x7fffffff)
#define OM_K_NOTUSING_CLASSID   ((OMuword) -1)
#define OM_K_NOT_AN_OS          ((OMuword) -1)

extern OMuword OM_Gw_current_OS;

/* ----------------------------------------------
 * $EXNUC/include/OMminimum.h
 */
struct OM_sd_classlist {
  OMuword	w_count;		/* size of array of classids      */
  OMuword       w_flags;                /* flag word                      */

#define         OM_CLST_subclass  1     /* pass to subclasses of classes  */
                                        /* in classlist also              */
#define         OM_CLST_negation  2     /* pass to all classes NOT in the */
                                        /* classlist                      */
#define         OM_CLST_internal  0x80  /* for internal OM use only       */

  OMuword	*p_classes;		/* array of classids              */
};
typedef struct OM_sd_classlist	OM_S_CLASSLIST;
typedef struct OM_sd_classlist *OM_p_CLASSLIST;
#endif

/* ----------------------------------------------
 * $EXNUC/include/igetypedef.h
 */
typedef  OM_S_OBJID          GRobjid;
typedef  uword               GRspacenum;
typedef  uword               GRclassid;
typedef  uword               GRchannum;
//pedef  OM_S_OBJECT_LINKAGE GRobjlink; 
//pedef  OM_S_OBJECTHDR      GRobjecthdr;

/* ---------------------------------------------
 * This is an extern in om but is there really
 * a need for it to be?
 */
//extern OM_S_OBJID NULL_OBJID;
#define NULL_OBJID   ((OM_S_OBJID) -1)
#define NULL_CLASSID ((OMuword) -1)
#define NULL_OSNUM   ((OMuword) -1)

/* ----------------------------------------------
 * $GRNUC/include/gr.h (with typedef's added)
 */
  
struct GRid	     /* object identifier structure */
{
  GRspacenum osnum;  /* space number of object */
  GRobjid    objid;  /* object id of object    */
};
typedef struct GRid TGRid;
  
struct GRmdenv_info
{
  IGRshort  matrix_type;
  IGRmatrix matrix;
};
typedef struct GRmdenv_info TGRmdenv_info;

struct GRmd_env
{
  struct GRid	      md_id;
  struct GRmdenv_info md_env;
};
typedef struct GRmd_env TGRmd_env;

struct GRobjid_set
{
  IGRint   num_ids;
  GRobjid *objids;
};
typedef struct GRobjid_set TGRobjid_set;

struct GRobj_env // growner.h
{
  struct GRid       obj_id;
  struct GRmd_env   mod_env;
};
typedef struct GRobj_env TGRobj_env;

/* -----------------------------------------------
 * grnuc display stuff
 */
struct IGRdisplay			/* element display attributes	*/
{
	short    unsigned  color;	/* color index			*/
	IGRuchar           weight;	/* weight index			*/
	IGRuchar           style;	/* position # for line style    */
};

struct GRsymbology
{
    struct IGRdisplay display_attr;	/* display attributes		*/
    short             level;		/* level index			*/
};

typedef struct GRsymbology TGRsymbology;

/* -----------------------------------------------
 * Display modes dp.h
 */
#ifndef   dp_include
#include "dp.h"
#endif

/* -----------------------------------------------
 * ret_struct parametric.h
 */
#ifndef   VDparamet_include
#include "VDparamet.h"
#endif

typedef struct ret_struct Tret_struct;

/* -----------------------------------------------
 * And a few more
 */
typedef IGRlong    IGRstat;

typedef OMuword    VDclassid;
typedef OMuword    VDosnum;
typedef OM_S_OBJID VDobjid;

typedef OMuword    TVDclassid;
typedef OMuword    TVDosnum;
typedef OM_S_OBJID TVDobjid;

/* -------------------------------------------------
 * vds/vdah/c/VDfrm2.c
 */
extern void UI_status __((IGRchar *buf));

/* -------------------------------------------------
 * vds/vdah/c/VDstr.c
 */
extern void strupr __((IGRchar *str));
extern void strlwr __((IGRchar *str));

/* -------------------------------------------------
 * vds/vdah/c/VDom.c
 */
#define RESET 2
#define DI_PATH_MAX 1023

extern IGRint EX_findmod __((VDobjid *objid, VDosnum *osnum));

#define EX_CONFIG_PATH 0
extern IGRint EX_getpath __((IGRint index, IGRchar *path, IGRint len , IGRint type));

extern IGRint ASend_fence __((void));
extern IGRint VDstart_var_fence __((TGRobj_env *setOE, IGRint *locNum, TGRobj_env **locOEs));

extern IGRint VDputResponse __((IGRint response));

/* -----------------------------------------
 * Structure defining a VDprcAttr: 
 * vds/include/vdprocinfo.h
 */
struct VD_s_procAttr {
        IGRdouble       density;         
        IGRdouble       mass;         
        IGRdouble       volume;         
        IGRdouble       area;         
        IGRdouble       cog[3];
        IGRdouble       dim[3];
        IGRdouble       range[6];
        IGRdouble       moment[6];
        IGRdouble       loc[3];
	IGRdouble       axis[9];
} ;
typedef struct VD_s_procAttr VDprcAttr ;
#define vdprocinfo_include

/* ------------------------- */
#if defined(__cplusplus)
}
#endif
#endif
#endif

