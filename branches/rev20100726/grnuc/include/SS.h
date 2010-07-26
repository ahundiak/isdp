#ifndef SS_include
#define SS_include

/*
 * This file contains the typedefs and structure definitions for the
 * Smart Sketch interfaces.
 *
 * Dependencies: igrtypedef.h
 *               igetypedef.h
 *               igr.h
 *               igrdp.h
 *               dpstruct.h
 *               SSdef.h
 */

typedef struct SSObject 
/* To contain the objects we are scanning */
{
  struct GRid  grid                               /* The object              */;
  int          type                               /* Is it a LINE, ARC, ...  */;
  int          NbKeyPoints                        /* How many key points     */;
  IGRpoint     KeyPoints [SS_MAX_KEYPOINTS]       /* The keypoints           */;
  char         KeyPointActive [SS_MAX_KEYPOINTS]  /* is KeyPoints active?    */;
  struct DPele_header *buffers                    /* display buffers         */;
  int          NbBuffers                          /* # of buffers            */;
  IGRpoint     ExtendedPoints [2]                 /* infinite line (if any)  */;
  double       Radius                             /* the radius (if any)     */;
} SSObject;


typedef struct SSUserInfo 
/* To be passed in the R-tree */
{
  double         tolerance      /* The tolerance                             */;
  IGRpoint       point          /* The Data Point                            */;
  struct IGRline *PBoreLine     /* The bore line (NULL if point locate)      */;
  IGRpoint       ConstraintPoint/* The Constraint Point  (what we lock to)   */;
  short          type           /* Matrix type                               */;
  IGRmatrix      matrix         /* Matrix                                    */;
  struct GRid    module         /* The module                                */;
  SSObject       *p_object      /* The selected object                       */;
} SSUserInfo;

struct SSDisplayInfo
{
  short offset [2];
  char  string [SS_MAX_CONSTR_STRING];
  int   font_descr;
};


/* 
 *  Externs for global symbols in src/co/smartco/SSGlob.C
 */
extern SSObject         SSObjects [SS_MAX_OBJECTS];
extern int              SSnb_objects;
extern int              SSRefLock;
extern struct IGRplane  SSRefPlane;
extern IGRvector        SSRefXaxis; 
extern IGRvector        SSRefYaxis;
extern IGRmatrix        SSRefMatrix;
extern IGRmatrix        SSInvRefMatrix;
extern short            SSRefMatTyp;
extern int              SSLastAvailable;
extern int              SSLastConstraintType;
extern IGRdouble        SSLastDataPoint [3];
extern IGRdouble        SSLastConstraintPoint [6];
extern IGRdouble        SSLastKeypoint [6];
extern SSObject        *SSLastObject1; 
extern SSObject        *SSLastObject2;
extern int              SSLastConstraintType;
extern struct           SSDisplayInfo SStext [SS_MAX_CONSTRAINT_TYPES ];
extern int              SSums_keys[SS_MAX_CONSTRAINT_TYPES ];
extern IGRmatrix        SSRotMat60; /* 60 degrees for the parallel icon */
extern int              SSNewElementType;
extern IGRpoint         SSNewPoints [3];
extern struct GRid      SSLastWindow;
extern double           SSLastTolerance; 
extern double           SSViewToWorld [16]; 
extern double           SSWorldToView [16];
extern IGRpoint         SSFirstBoreLinePoint;
extern IGRpoint         SSSecondBoreLinePoint; 
extern struct IGRline   SSBoreLine;
extern int              SSDisplayMode;
extern int              SSNewFlag;
extern SSObject         SSNewObject1;
extern SSObject         SSNewObject2;
#endif
