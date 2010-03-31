# ifndef EMSmsgnumdef_include
# define EMSmsgnumdef_include 1

# define EMS_m_BadOrder         2
# define EMS_m_BaseName         3
# define EMS_m_ChanCountNot1    4
# define EMS_m_ChanCountWrong   5

# define EMS_m_Closed                   6
# define EMS_m_Coincident               7
# define EMS_m_DirName                  8
# define EMS_m_DynamicMemoryAllocated   9

# define EMS_m_EarlyClosure 10
# define EMS_m_EndOnSide    11
# define EMS_m_Fail         12
# define EMS_m_FileOpen     13

# define EMS_m_Init         14
# define EMS_m_InvalidArg   15
# define EMS_m_MakeName     16
# define EMS_m_Modified     17

# define EMS_m_MustOverride     18
# define EMS_m_NoSolution       19
# define EMS_m_NoStackMemory    20
# define EMS_m_NotFound         21

# define EMS_m_NotUnique    22
# define EMS_m_OnFace       23
# define EMS_m_OnSide       24
# define EMS_m_Open         25

# define EMS_m_ParOutOfBounds   26
# define EMS_m_PipeOpen         27
# define EMS_m_PipeRead         28
# define EMS_m_Rational         29

# define EMS_m_StackMemoryAllocated 30
# define EMS_m_Success               1
# define EMS_m_Unlink               31
# define EMS_m_Useless              32

/* All messages before this line were released prior to
    19-Jan-1987 -- J. Brooke King */

# define EMS_m_FileClose 33 /* jBk 28-Jan-1987 */

/* 16-March-1987 Sunit requested these:  */

# define EMS_m_InvalidCase  34
# define EMS_m_AlreadySplit 35
# define EMS_m_NotSplit     36
# define EMS_m_EdgeError    37

# define EMS_m_LoopError    38
# define EMS_m_LoopsetError 39
# define EMS_m_OMerror      40

/* 23-March-1987 Chopra requested this:  */

# define EMS_m_SurfaceError 41

/* 23-March-1987 I thought this would be consistent:  */

# define EMS_m_CurveError 42

/* 23-March-1987 Siki requested this: */

# define EMS_m_OutOfBounds 43

/* 24-March-1987 Prasad requested this: */

# define EMS_m_NoDynamicMemory 44

/* 25-March-1987 Siki requested this: */

# define EMS_m_Intersect        45
# define EMS_m_IntersectTrim    46
# define EMS_m_IntersectClosure 47
# define EMS_m_IntersectOrient  48

/* 26-March-1987 Chopra requested this: */

# define EMS_m_BSerror  49
# define EMS_m_MAerror  50

/* 1-April-1987 Siki really requested this!  (Not April Fooling) */

# define EMS_m_NoMoreLoops 51

/* 3-April-1987 Allen said Dave asked for this: */

# define EMS_m_InvalidSend   52

/* 7-April-1987 Allen requested this: */

# define EMS_m_NoResponse   53

/* 9-April-1987 Allen got these from Siki and Sunit: */

# define EMS_m_NestError     54
# define EMS_m_TreeModError  55
# define EMS_m_PtLocError    56

/* I got these from Chopra and Dave  */

# define EMS_m_InactiveLoop  57

/* 8-May-1987 Sunit requested these: */

# define EMS_m_InAreaTrim       58
# define EMS_m_InHoleTrim       59

/* 11-May-1987 Siki requested this: */

# define EMS_m_NoIntersection   60

# define EMS_m_BoolFail         61

/* 12-June-1987 J. Brooke King needed this for GIFT */

# define EMS_m_LocalModsInModel 62

/* 16 June 87 Added for returning a more meaningful error return code
   while placing a solid of projection surf to plane */

# define EMS_m_DegenerateEdge   63

/* 8 July 87 Added for EMSmanip and EMSgroup */

# define EMS_m_NoLocation   64
# define EMS_m_NoDisplay    65

/* 15 July 87 Added for rule line table display and locate */

# define EMS_m_NotUpToDate  66

/* Sept 21 87  for capped solids */

# define EMS_m_Degenerate 67
# define EMS_m_TopCapDegenerate 68
# define EMS_m_BottomCapDegenerate 69
# define EMS_m_BothCapsDegenerate 70

/* 9 Oct 87 Added to indicate end of search or processing */
 
#define EMS_m_Found  71
 
/* Added by Sunit*/
 
# define EMS_m_DegenerateLoop   72
# define EMS_m_OpenLoop   73
# define EMS_m_CoincedentTrim   74
 
/*
 * Added by Chopra
 */
 
# define EMS_m_NoValidBnd  75
# define EMS_m_NoTrimBnd   76
# define EMS_m_MkfCollapse 77
# define EMS_m_MkfGrouping 78
# define EMS_m_MkfGrExit   79
 

# define EMS_m_NoMore            80     /* Codes intended to be generic. SS */
# define EMS_m_Ambiguous         81

# define EMS_m_FeatureLoop       82

# define EMS_m_Stop              83     /* Code to be used to stop execution */

# define EMS_m_NeedGrpInfo       84

# define EMS_m_CvsNonCoplanar    85         /* Added by Gupta */
# define EMS_m_DiffSrfOrder      86

# define EMS_m_RndGrExit         87
# define EMS_m_RndInterfere      88

# define EMS_m_IntersClosureOrient 89

# define EMS_m_Interrupt         90

# define EMS_m_Clipped           91

# define EMS_m_NoCommonEdge      92       /* Added by Sunit 04-Mar-89 */

# define EMS_m_ChangeClass       93

# define EMS_m_CantRecompute     94

# define EMS_m_RecomputeOccurred 95

# define EMS_m_AutoStk           96        /* Added by Ashok 11-May-90 */

# define EMS_m_FoundOther        97

# define EMS_m_NoxsectionPlane   98        /* Added by Inasu on June 4, 1990 */

# define EMS_m_DirectlyOwned     99        /*DLB 5/29/91*/

# define EMS_m_BadElement       100
# define EMS_m_BadPlane         101
# define EMS_m_NotSupported     102

# define EMS_m_Cycle            103
# define EMS_m_Merge            104

# define EMS_m_AllIntersectionsDeleted 105  /* NP 7/24/92 */

# define EMS_m_WasLastGroupComp        106  /* DLB 12/31/92 */

# define EMS_m_ArcLenPar 107 /* pp 05/31/93 */

/*
 * Following messages are intended for Add/Remove Material Functionality.
 * -- Sanjay
 */
#define  EMS_m_AddRmNoIntToNextSurf   108  /* No Intersection with the to-next
                                              surface. */
#define  EMS_m_AddRmNoIntFromSurf     109  /* No Intersection with the "FROM"
                                              surface selected. */
#define  EMS_m_AddRmNoIntToSurf       110  /* No Intersection with the "TO"
                                              surface selected. */
#define  EMS_m_AddRmInfinite          111  /* End Cap of the Secondary Solid
                                              does not Intersects with the
                                              base solid in case of Finite/
                                              added case. */
#define  EMS_m_AddRmErrorInConst      112  /* Error in Constructing the Add/Rmv
                                              Material Feature */
#define  EMS_m_AddRmDisjoint          113  /* No Intersection between the 
                                              Secondary and Base solids */


/*
 * Following message numbers intended for variational geometry 
 *
 * DLB - someone should have followed the obvious rules and made the following
 * continue up from 106 instead of DOWN from 999!!!!
 */

#define EMS_m_PtEvaluated       999
#define EMS_m_LocusEvaluated    998
#define EMS_m_Redundant         997
#define EMS_m_Conflicting       996
#define EMS_m_Exceeded          995 
#define EMS_m_UnderConstrained  994
#define EMS_m_ASerror           993
#define EMS_m_Construct         992
#define EMS_m_Connect           991
#define EMS_m_Assoc             990
#define EMS_m_GRvg              989
#define EMS_m_GRgraphics        988
#define EMS_m_DPRerror          987
#define EMS_m_ASsferror         986
#define EMS_m_GRconnector       985
#define EMS_m_Insufficient      984
#define EMS_m_InvalidTopology   983
#define EMS_m_FullyConstrained  982


#endif
