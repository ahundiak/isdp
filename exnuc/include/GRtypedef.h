   /*
    *  This include is dependent of the following include files:
    *
    *		OMminimum.h
    */

#ifndef GRtypedef_include

#  define GRtypedef_include

  
   /*
    *  Structures that redefine OM releated stuctures to the GR based 
    *  structures.  These structures are definded in OMminimum.h which
    *  is included in Root.S.
    */

/*  The following ifndef if to prevent conflict with igetypedef.h  */

#ifndef IGE_GR_defns
#define IGE_GR_defns 1

   typedef  OM_S_OBJID GRobjid;
   typedef  OM_S_OBJECT_LINKAGE GRobjlink; 
   typedef  uword GRspacenum;
   typedef  uword GRclassid;
   typedef  uword GRchannum;
   typedef  OM_S_OBJECTHDR GRobjecthdr;

#endif
   
#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#ifndef NULL
#define NULL	0
#endif

typedef short	GRboolean;
typedef short 	GRshort;
typedef long  	GRlong;
typedef int   	GRint;
typedef double  GRdouble;
typedef char	GRchar;

#endif
