/* $Id: VSefp.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/include/VSefp.h
 *
 * Description: Extract For Production
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VSefp.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/01/27  15:45:24  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/10/26  18:04:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/26/99  ah      Added Header
 ***************************************************************************/
#ifndef VSefp_include
#define VSefp_include

#ifndef   VDvla2_include
#include "VDvla2.h"
#endif

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------
 * Make up a little structure for holding a 4x4
 * matrix and broken out vectors from the matrix
 * Add a parameter flag just for grins
 */
typedef struct {
  IGRmatrix mat;

  IGRdouble X[3],Y[3],Z[3],S[3];

  IGRdouble par;    // Model parameter value for base end

  IGRdouble O0[3];  // Base   End origin
  IGRdouble O1[3];  // Offset End origin

} TVDmatInfo;

/* ----------------------------------------------
 * Protos for neat plate routines
 */
extern IGRstat VSefpIsNeatPlate            __((TGRobj_env *plateOE));

extern IGRstat VSefpGetNeatPlate           __((TGRobj_env *plateOE,
                                               TGRobj_env *neatOE, 
                                               TVDvlaOE   *plateVLA));

extern IGRstat VSefpGetAttachedNeatPlateMacro
__((IGRchar    *macName,
    VDosnum     macOS,
    TGRobj_env *plateOE,
    IGRint      treeFlag,
    TGRobj_env *macOE));

#omdef vsefp$GetAttachedNeatPlateMacro(macName  = VDEFP_NEAT_PLATE_MACRO_NAME,
				       macOS    = OM_K_NOT_AN_OS,
                                       plateOE,
                                       treeFlag = 0,
                                       macOE    = NULL)

VSefpGetAttachedNeatPlateMacro((macName),(macOS),(plateOE),(treeFlag),(macOE))
#endomdef

/* ---------------------------------------------------------
 * End Treatment Information
 */
typedef struct {
  TGRobj_env    beamOE;
  TGRobj_env    etOE;
  TGRid         csID;
  TGRmdenv_info csMatrix;
  IGRdouble     csOrg[3];

  IGRdouble distance;
  IGRint    gotIt;
  IGRint    flag;

  IGRchar   macName[128];
  IGRchar   macType[ 32];

  TGRid     et_typeID;
  IGRchar   etType[ 32];

  TGRid     et_outputID;
  IGRdouble xbase,xweb,xflg0,xflg1,m1,m2,m3,m4;
  IGRdouble angle0,angle2;
  
  TGRid     et_paramsID;
  IGRdouble r_scallop,r_snipe,flg_angle,w_snipe;

  TGRid     et_freeID;
  IGRdouble d_lower,d_upper,r_upper,web_angle;

  TVDmatInfo matInfo;
  
} TVSefpEtInfo;

/* -------------------------------------------------
 * VSefpEt.I - End Treatment Routines
 */
extern IGRstat VSefpCheckProcessedMacros 
__((TGRobj_env *beamOE,
    IGRint      nth,
    TVDvlaoe   *macVLA));

extern IGRstat VSefpGetProcessedMacros 
__((TGRobj_env *beamOE, 
    TVDvlaoe   *macVLA));

extern IGRstat VSefpGetEtInfo 
__((TGRobj_env   *beamOE, 
    TGRobj_env   *etOE, 
    TVSefpEtInfo *etInfo));

/* ---------------------------------------------------------
 * Cutout Information
 */
typedef struct {

  TGRobj_env    piece1OE;
  TGRobj_env    piece2OE;
  
  TGRobj_env    cutoutOE;

  TGRid         csID;
  TGRmdenv_info csMatrix;
  IGRdouble     csOrg[3];

  IGRdouble distance;
  IGRint    gotIt;
  IGRint    flag;

  IGRchar   macName[128];
  IGRchar   macType[ 32];

  TGRid     cutID;
  TGRid     markID;
  
  TGRid     idID;
  IGRchar   idType[ 32];

  IGRdouble extra,base,web;
  
} TVSefpCutoutInfo;

/* ------------------------------------
 * Cut out processing
 */
extern IGRstat VSefpGetCutoutInfo __((TGRobj_env       *piece1OE, 
				      TGRobj_env       *cutoutOE, 
				      TVSefpCutoutInfo *cutoutInfo));

/* ----------------------------------------------------------------
 * Beam Information
 */
typedef struct
{
  TGRobj_env beamOE;
  TGRobj_env  srfOE;
  TGRobj_env axisOE;
  
  TGRbsp_surface *srfBsp;
  TGRbsp_curve   *axisBsp;
  IGRdouble       axisEndPt1[3];
  IGRdouble       axisEndPt2[3];  

  TGRid           crossSectionDefID;
  TGRmdenv_info   crossSectionMatrix;

  IGRint          isNotLinear;
  IGRint          isClosed;
  
  TVSefpEtInfo    etInfo0,etInfo1;

  IGRdouble pt1[3];  // End 1 Lower Left Web
  IGRdouble pt2[3];  // End 2 Lower Left Web
  IGRdouble pt3[3];  // End 1 Upper Left Web
  IGRdouble pt4[3];  // End 1 Lower Material
  IGRdouble pt5[3];  // End 2 Straight Beam
  
  IGRchar   desc[128];

  TVDvlaoe  macVLA;  // All the macros with a processed connection
  
  TVDmatInfo matInfo; // Base end information
  IGRmatrix  inv;
  
} TVSefpBeamInfo;

/* --------------------------------------------------------
 * VSefpBeam.I - EFP Beam routines
 */
extern IGRstat VSefpInitBeamInfo        __((TVSefpBeamInfo *beamInfo));
extern IGRstat VSefpFreeBeamInfo        __((TVSefpBeamInfo *beamInfo));
extern IGRstat VSefpVerifyEndTreatments __((TVSefpBeamInfo *beamInfo));
extern IGRstat VSefpGetBeam3dPoints     __((TVSefpBeamInfo *beamInfo));

extern IGRstat VSefpGetBeamInfo         __((TGRobj_env *beamOE, 
					    IGRint noGeom, 
					    TVSefpBeamInfo *beamInfo));


extern IGRstat VSefpGetBeamPoints 
__((TGRobj_env *beamOE, // I - beam
    IGRdouble  *pts));  // O - Array of 5 points

extern IGRstat VSefpComputeEfpBeam __((TGRobj_env *macOE,
				       IGRint      opFlag,
				       IGRint     *feetCnt,
				       TGRid      *feetIDs));

/* --------------------------------------------------------
 * VSefpBeam2d.I - EFP Beam2d routines
 */
extern IGRstat VSefpComputeEfpBeam2d __((TGRobj_env *macOE,
					 IGRint      opFlag,
					 IGRint     *feetCnt,
					 TGRid      *feetIDs));


/* --------------------------------------------------------
 * Determines the "production base end" of a beam
 */
extern IGRstat VSefpGetBeamBaseEnd __((TGRobj_env *beamOE, TVDmatInfo *matInfo));

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif





