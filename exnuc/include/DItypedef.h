




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

   /*
    *  This include is dependent of the following include files:
    *
    *		OMminimum.h
    */

#ifndef DItypedef_include

#  define DItypedef_include

  
   /*
    *  Structures that redefine OM releated stuctures to the DI based 
    *  structures.  These structures are definded in OMminimum.h which
    *  is included in Root.S.
    */

   typedef  OM_S_OBJID DIobjid;
   typedef  OM_S_OBJECT_LINKAGE DIobjlink; 
   typedef  uword DIspacenum;
   typedef  uword DIclassid;
   typedef  uword DIchannum;
   typedef  OM_S_OBJECTHDR DIobjecthdr;
   
   struct digrid {
                   DIspacenum osnum	/* object space number	*/;
                   DIobjid    objid	/* object identifier	*/;
                 };

#define DIgrid struct digrid

#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#ifndef NULL
#define NULL	0
#endif

typedef short	DIboolean;
typedef short 	DIshort;
typedef long  	DIlong;
typedef int   	DIint;
typedef double  DIdouble;
typedef char	DIchar;

typedef	 DIdouble  DIvector[3];

typedef  DIdouble  DImatrix[16];

typedef  DIdouble  DIpoint[3];

typedef struct 
{
  DIobjid objid		/* objid that has a name	*/;
  DIint   count		/* number of synonyms		*/;
  DIchar  **names	/* directories and objects name */;
} DIunode		/* there is one untree per os	*/;

#endif
