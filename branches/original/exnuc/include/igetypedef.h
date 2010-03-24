




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

#ifndef igetypedef_include

#  define igetypedef_include

  
   /*
    *  Structures that redefine OM releated stuctures to the GR based 
    *  structures.  These structures are definded in OMminimum.h which
    *  is included in Root.S.
    */

/*  The following ifndef if to prevent conflict with GRtypedef.h  */

#ifndef IGE_GR_defns
#define IGE_GR_defns 1

   typedef  OM_S_OBJID GRobjid;
   typedef  OM_S_OBJECT_LINKAGE GRobjlink; 
   typedef  uword GRspacenum;
   typedef  uword GRclassid;
   typedef  uword GRchannum;
   typedef  OM_S_OBJECTHDR GRobjecthdr;

#endif

#endif






