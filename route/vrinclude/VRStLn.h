
/****************************************************************************/
/*     FILE NAME   -  VRStLn.h                                              */
/*                                                                          */
/*     CHANGE HISTORY                                                       */
/*                                                                          */
/*     19-OCT-93  hv       Initial Version                                  */
/*                                                                          */
/****************************************************************************/

/*       structures for LINK objects includeing fiber/lead                  */
/*       connectivity                                                    */

#ifndef  VRStLn_include

#define  VRStLn_include

/*     structure to ID a position of a topo eq connector    */

#define    VRFO_T_REMOVE    -1
#define    VRFO_T_UNASSIGN   0
#define    VRFO_T_CONNECT    1
#define    VRFO_T_SPLICE     2

#define VRGD_SPLINE               0x0001
#define VRGD_STRING               0x0002
#define VRGD_RWAY                 0x0004

#define VRGD_FIXED_XS             0x0010
#define VRGD_FREED_XS             0x0020

#define VRGD_SHAPE_ROUND          0x0100
#define VRGD_SHAPE_SQUARE         0x0200

#define VRGD_SH_R_ST              "ROUND"
#define VRGD_SH_S_ST              "RECTANGULAR"

struct VRLn_eqpt {
                     char      Mod_Seqno[VRFODF_seqno];
                     char      Pos_Name[VRFODF_posnam];
                  };

/*     structure to describe connections of a fiber to a topo equipment
       connector     */

struct VRLn_Cbconnect {
                        struct VRLn_eqpt     FibEnds[2];
                               char          FibDes[VRFODF_fibdes];
                      };

/*      Array of structures to describe connectivity
        for a multi lead cable (variable)                 */

struct     VRLn_mult     {

                IGRshort        nFibNo;
                IGRchar         szSEQ[13];
         struct VRLn_Cbconnect  ODconnect;
			};

struct VRCL_pntmap
               {
                  IGRdouble     dX;
                  IGRdouble     dY;
                  IGRdouble     dZ;
               };

struct VRCL_sectmap
               {
                  IGRshort      type;
                  IGRshort      numvert;
                  IGRshort      strno;
                  IGRshort      parno;
                  IGRdouble     dFrom;
                  IGRdouble     dTo;
               };

struct VRCL_bendmap
               {
                  IGRshort      secno;
                  IGRshort      vtxno;
                  IGRdouble     rad;
               };

struct VRGD_vectors {
                      IGRdouble     param;
                      IGRdouble     rotang;
                    };

#endif

