#ifndef VPextInfo_include
#define VPextInfo_include

// Usual c stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#define VP_EXT_INFO_MAX 64

/* -----------------------------------
 * Gather up all the bevel information 
 */
typedef struct 
{
  TGRobj_env bevelOE;
  TGRobj_env footOE;

  IGRchar    spec   [128];
  IGRchar    process[128];
  
  IGRdouble  stock;
  IGRint     hasStock;
  
  IGRdouble  gap;
  IGRint     hasGap;
  
  IGRdouble  adjust;
  IGRint     hasAdjust;

  IGRdouble  thickness;    // The thickness of the thinner adjacent plate
  IGRint     hasThickness;
  
  IGRpoint   pt0,pt1,ptm;  // beg, end and middle points
} TVPextBevelInfo;

typedef struct 
{
  IGRint cnt;
  TVPextBevelInfo info[VP_EXT_INFO_MAX];
} TVPextBevelInfos;

/* ----------------------------------------
 * Gather up all the plate edge information
 */
typedef struct {
  
  TVPextBevelInfo *bevelInfo;

  TGRbsp_curve *crv3D;
  TGRbsp_curve *crv3Dx;
  
  TGRbsp_curve *crv2D;
  TGRbsp_curve *crv2Dstk;

} TVPextEdgeInfo;

typedef struct {
  IGRint cnt;
  TVPextEdgeInfo info[VP_EXT_INFO_MAX];
} TVPextEdgeInfos;

/* --------------------------------------------------------
 * Hole information
 */
typedef struct {
  IGRchar macName[64];
  IGRint type;
} TVPextHoleInfo;

typedef struct {
  IGRint cnt;
  TVPextHoleInfo info[VP_EXT_INFO_MAX];
} TVPextHoleInfos;

/* --------------------------------------------------------
 * Label information
 */
typedef struct {
  IGRint type;      // 1 = edge
  IGRint index;
  
  IGRchar  text[64];
  IGRpoint org3D;
  IGRpoint org2D;

} TVPextLabelInfo;

typedef struct {
  IGRint cnt;
  TVPextLabelInfo info[VP_EXT_INFO_MAX];
} TVPextLabelInfos;

/* --------------------------------------------------------
 * Holds the plate tree
 */
typedef struct {
  TGRobj_env plateOEs[VP_EXT_INFO_MAX];
  IGRint cnt;
} TVPextPlates;

/* --------------------------------------------------------
 * Need to organize all the plate information
 */
typedef struct 
{
  TGRobj_env curPlateOE;
  TGRobj_env srcPlateOE;

  TGRobj_env curSrfOE;
  TGRobj_env srcSrfOE;

  TGRbsp_surface *srcSrfBsp;  
  TGRmdenv_info   srcSrfMat;

  IGRpoint  srcSrfCenter;
  IGRvector srcSrfNormal;
  IGRchar   srcSrfDirection[32];
  
  TVPextPlates     plates;
  TVPextEdgeInfos  edges;
  TVPextBevelInfos bevels;
  TVPextLabelInfos labels;
  TVPextHoleInfos  holes;
  
  IGRchar desc[128];

  IGRint  presentOffset;
  
} TVPextPlateInfo;

/* --------------------------------------------------------
 * Super object for controlling the entire process
 */
typedef struct 
{
  struct {
    FILE *data;
    FILE *beams;
    FILE *bevels;
    FILE *plates;
    FILE *labels;
    FILE *ets;
    FILE *cutouts;
    FILE *holes;
  } file;

  TVPextPlateInfo *plateInfo;
  
} TVPextMasterInfo;

/* --------------------------------------------------------
 * VPextMaster.I
 */
extern TVPextMasterInfo *VPextGetMasterInfo    __(());
extern IGRstat           VPextInitMasterInfo   __(());
extern IGRstat           VPextDeleteMasterInfo __(());

extern FILE *VPextGetBeamTraceFile();
extern FILE *VPextGetBevelTraceFile();
extern FILE *VPextGetPlateTraceFile();
extern FILE *VPextGetLabelTraceFile();

extern FILE *VPextGetEtTraceFile();
extern FILE *VPextGetHoleTraceFile();
extern FILE *VPextGetCutoutTraceFile();

extern IGRstat VPextOpenDataFile  __((IGRchar *fileName));
extern IGRstat VPextCloseDataFile __((IGRchar *fileName));

/* --------------------------------------------------------
 * VPextProd.I
 */
extern IGRstat VPextExtractPlate  __((TGRobj_env *plateOE));

/* -------------------------------------------------------
 * VPextPlate.I
 */
extern IGRstat VPextProcessPlate    __((TGRobj_env *plateOE));

extern IGRstat VPextGetPlateTree    __((TVPextPlateInfo *plateInfo));
extern IGRstar VPextGetPlateSurface __((TVPextPlateInfo *plateInfo));

extern IGRstar VPextGetPlateMaterialDirection __((IGRvector vec, 
                                                  IGRchar *dir));

/* -------------------------------------------------------
 * VPextMark.I
 */
extern IGRstar VPextGetPlateMarkLines 
__((TVPextPlateInfo *plateInfo));

extern IGRstar VPextGetPlateMarkLine  
__((TVPextPlateInfo *plateInfo,
    TGRobj_env      *plateOE,
    TGRid           *markID));

/* -------------------------------------------------------
 * Plate specific processing
 */

extern IGRstar VPextGetBevelForEdge __((
  TGRbsp_curve     *crv,
  TVPextBevelInfos *bevels,
  IGRint           *bevelInd));

extern IGRstar VPextGetPlateBevels __((
  TVPextPlateInfo *plateInfo));

extern IGRstar VPextWritePlateEdges __((
  TVPextPlateInfo *plateInfo));

extern IGRstar VPextWritePlateHoles __((
  TVPextPlateInfo *plateInfo));

extern IGRstar VPextSetPlateEdge __((
  TVPextPlateInfo *plateInfo, 
  TGRobj_env      *edgeOE));


/* -----------------------------------------
 * For the datum plane sub-system
 */
typedef struct 
{
  IGRpoint  point;
  IGRvector normal;
} TVDplane;

#if defined(__cplusplus)
}
#endif

#endif
