
/* $Id: VCstructs.h,v 1.1.1.1 2001/01/04 21:12:35 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCstructs.h
 *
 * Description:
 *
 *      Structures defined for VC cabling system
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCstructs.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/11/30  16:09:06  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by r250_int for route
 *
 * Revision 1.12  1997/11/09  07:02:08  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by apazhani for cabling
 *
 * Revision 1.11  1997/09/10  17:45:20  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by apazhani for cabling
 *
 * Revision 1.10  1997/07/31  19:43:44  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.9  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.8  1997/04/29  12:59:44  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.7  1997/04/28  21:42:18  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.6  1997/03/14  18:17:08  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/01/20  20:06:30  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.4  1996/11/15  18:22:20  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/10/25  13:43:12  pinnacle
 * Replaced: vcinclude/VCstructs.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:47:52  pinnacle
 * Created: vcinclude/VCstructs.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *      09/10/97    Alwin       Added structure VCParams, used for dynamics.
 *      11/09/97    Alwin       Removed static from definition of VCParams.
 *
 *************************************************************************/

#ifndef VCstructs_include
#define VCstructs_include

/**********************************************************************/

struct   VCcab_connect         /*  cable connect instance table   */
{
   struct  VCTpos       FibEnds[2];
           IGRshort     nEndStat[2];                 /*  future  */
           IGRshort     nFibStat;                  /*   ??   */
           IGRchar      LeadNam[VC_MAX_LEAD_ID];
           IGRchar      SigNam[VC_MAX_SIG_ID];
};

struct   VCterm_sigtab        /*  instance table for signals per pos   */
{
           IGRshort     nPkey;
           IGRchar      SigNam[VC_MAX_SIG_ID];
};

/**********************************************************************/
/*                    placement info structures                       */

struct VCCL_pntmap                      /*  cable parent point map */
{
           IGRdouble     dX;
           IGRdouble     dY;
           IGRdouble     dZ;
};

struct VCCL_sectmap                    /*   cable section map   */
{
           IGRshort      cbstat;      /*  section recompute status    */
           IGRshort      type;        /*  section type                */
           IGRshort      numvert;     /*  number of vertices          */
           IGRshort      strno;       /*  string number (child)       */
           IGRshort      parno;       /*  parent number               */
           IGRshort      nCP;         /*  connectpoint of other obj   */
           IGRshort      iFrom;       /*  start index                 */
           IGRshort      iTo;         /*  stop index                  */

    /*   following offsets are used to spread cables on connectpoints */

           IGRdouble     dY0;         /*  Y offset on cpt 0           */
           IGRdouble     dZ0;         /*  Z offset on cpt 0           */
           IGRdouble     dY1;         /*  Y offset on cpt 1           */
           IGRdouble     dZ1;         /*  Z offset on cpt 1           */
};

/*   NOTE:   start/stop indices may contain partial following of a
             guide. instead of the connectpoints. convert to FP...    */

struct VCCL_bendmap                 /*   cable changed bendradius map */
{
           IGRshort      secno;
           IGRshort      vtxno;
           IGRdouble     rad;
};

struct  VCCableInfo                 /*   cable instance topology structure */
{                                   /*   transfer only.................... */
        IGRshort        nCPbeg;
        IGRshort        nCPend;
        IGRshort        NbVertices;
        IGRshort        NbSections;
        IGRdouble      *pVertex;
 struct VCCL_sectmap   *pSect;
};

struct  VCGuideInfo                 /*   guide info structure   */
{
        IGRdouble       dSize1;   /*  diameter if non DB     */
        IGRdouble       dSize2;
};

struct     VCTermInfo               /*   terminal info structure  */
{
        IGRshort        nCpt;       /*   cable connectpoint (end)            */
        IGRshort        nOff;       /*   number of Offset/orientation values */
        IGRdouble      *dOffVal;    /*   offset/orientation mbt parent       */
        IGRchar         szMacNam[VC_MAX_ID];
};

union  VCtag
{
  struct VCTermInfo   Term;
  struct VCGuideInfo  Guide;
  struct VCCableInfo  Cable;
};

struct  VCGenInfo
{
  IGRint      nStat;
  IGRint      nType;
  IGRchar     szCode[VC_MAX_CCODE];
  IGRchar     szTagno[VC_MAX_TAGNO];
  IGRboolean  bNoMtoFlg;
  IGRchar     cRep;
  IGRshort    nNbAttr;
  IGRshort    nNbTopo;
  IGRshort    nProduct;
  union       VCtag         Attr;
};

/*     structures for terminals connectpoint manager    */

struct VCP_ptmgr   /*    terminals only    */
{
   IGRboolean     bAdded;       /*  Added after placement  */
   IGRboolean     bFree;        /*  non-directional        */
   IGRdouble      dX;           /*  X displacement   */
   IGRdouble      dY;           /*  Y displacement   */
   IGRdouble      dZ;           /*  Z displacement   */
   IGRdouble      dOff1;        /*  Connect axis xy angle   */
   IGRdouble      dOff2;        /*  Connect axis azimuth angle   */
   IGRdouble      dOff3;        /*  Orientation rotation angle   */
                                /*  vector generation???         */
};

/*     VC connectpoint reference    */

struct VCx_list
{
  IGRshort    nPtype;
  IGRshort    nPchnix;
  IGRshort    nPmycpt;
  IGRshort    nPocpt;
};

/*     VC terminal passthru    */

struct VCT_passthru
{
  struct VCx_list       Cab1;
  struct VCx_list       Cab2;
         IGRshort       nLeads;
};

/*     Fiberoptic assigned connectors     */

struct  VCFo_Conn
{
  IGRshort            nTyp[2];
  IGRchar             FO_0[VC_MAX_ID];
  IGRchar             FO_1[VC_MAX_ID];
};

/*     VC object expander      */

#define  VCEX_CHAR      1
#define  VCEX_DBL       2
#define  VCEX_INT       3

union  VCEXun
{
    IGRchar    EXc[8];
    IGRdouble  EXd;
    IGRint     EXi;
};

struct VCEXpan
{
  IGRshort       type;

  union VCEXun    AT;
};

struct VCMLPoint
{
  IGRpoint        xyz;
};

/*    embedded terminal instance communicator     */

struct VCET_ins
{
  IGRint        Type;
  IGRint        Statx;
  IGRint        Product;
  IGRchar       szCode[VC_MAX_CCODE];
  IGRchar       szTag[VC_MAX_TAGNO];
  IGRchar       cRep;
};

/* The static struct VCParams, has been changed to struct VCParams. removed
by alwin */
struct VCParams
{
   struct GRid      CompId;
   struct GRmd_env  md_env;
   struct GRid      Parent;
};

#endif

