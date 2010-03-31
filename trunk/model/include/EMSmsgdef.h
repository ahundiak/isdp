# ifndef EMSmsgdef_include
# define EMSmsgdef_include 1

/* macros and definitions to help construct the messages */

# ifndef EMSmsgassist_include
# include "EMSmsgassist.h"
# endif

/* message numbers */

# ifndef EMSmsgnumdef_include
# include "EMSmsgnumdef.h"
# endif

/* messages */

# define EMS_S_BadOrder    EMS_MakeMsg (EMS_m_BadOrder, SUCC)
# define EMS_I_BadOrder    EMS_MakeMsg (EMS_m_BadOrder, INFO)
# define EMS_W_BadOrder    EMS_MakeMsg (EMS_m_BadOrder, WARN)
# define EMS_E_BadOrder    EMS_MakeMsg (EMS_m_BadOrder, ERRO)
# define EMS_F_BadOrder    EMS_MakeMsg (EMS_m_BadOrder, FATL)

# define EMS_S_BaseName    EMS_MakeMsg (EMS_m_BaseName, SUCC)
# define EMS_I_BaseName    EMS_MakeMsg (EMS_m_BaseName, INFO)
# define EMS_W_BaseName    EMS_MakeMsg (EMS_m_BaseName, WARN)
# define EMS_E_BaseName    EMS_MakeMsg (EMS_m_BaseName, ERRO)
# define EMS_F_BaseName    EMS_MakeMsg (EMS_m_BaseName, FATL)

# define EMS_S_ChanCountNot1    EMS_MakeMsg (EMS_m_ChanCountNot1, SUCC)
# define EMS_I_ChanCountNot1    EMS_MakeMsg (EMS_m_ChanCountNot1, INFO)
# define EMS_W_ChanCountNot1    EMS_MakeMsg (EMS_m_ChanCountNot1, WARN)
# define EMS_E_ChanCountNot1    EMS_MakeMsg (EMS_m_ChanCountNot1, ERRO)
# define EMS_F_ChanCountNot1    EMS_MakeMsg (EMS_m_ChanCountNot1, FATL)

# define EMS_S_ChanCountWrong    EMS_MakeMsg (EMS_m_ChanCountWrong, SUCC)
# define EMS_I_ChanCountWrong    EMS_MakeMsg (EMS_m_ChanCountWrong, INFO)
# define EMS_W_ChanCountWrong    EMS_MakeMsg (EMS_m_ChanCountWrong, WARN)
# define EMS_E_ChanCountWrong    EMS_MakeMsg (EMS_m_ChanCountWrong, ERRO)
# define EMS_F_ChanCountWrong    EMS_MakeMsg (EMS_m_ChanCountWrong, FATL)

# define EMS_S_Closed    EMS_MakeMsg (EMS_m_Closed, SUCC)
# define EMS_I_Closed    EMS_MakeMsg (EMS_m_Closed, INFO)
# define EMS_W_Closed    EMS_MakeMsg (EMS_m_Closed, WARN)
# define EMS_E_Closed    EMS_MakeMsg (EMS_m_Closed, ERRO)
# define EMS_F_Closed    EMS_MakeMsg (EMS_m_Closed, FATL)

# define EMS_S_Coincident    EMS_MakeMsg (EMS_m_Coincident, SUCC)
# define EMS_I_Coincident    EMS_MakeMsg (EMS_m_Coincident, INFO)
# define EMS_W_Coincident    EMS_MakeMsg (EMS_m_Coincident, WARN)
# define EMS_E_Coincident    EMS_MakeMsg (EMS_m_Coincident, ERRO)
# define EMS_F_Coincident    EMS_MakeMsg (EMS_m_Coincident, FATL)

# define EMS_S_DirName    EMS_MakeMsg (EMS_m_DirName, SUCC)
# define EMS_I_DirName    EMS_MakeMsg (EMS_m_DirName, INFO)
# define EMS_W_DirName    EMS_MakeMsg (EMS_m_DirName, WARN)
# define EMS_E_DirName    EMS_MakeMsg (EMS_m_DirName, ERRO)
# define EMS_F_DirName    EMS_MakeMsg (EMS_m_DirName, FATL)

# define EMS_S_DynamicMemoryAllocated \
        EMS_MakeMsg (EMS_m_DynamicMemoryAllocated, SUCC)
# define EMS_I_DynamicMemoryAllocated \
        EMS_MakeMsg (EMS_m_DynamicMemoryAllocated, INFO)
# define EMS_W_DynamicMemoryAllocated \
        EMS_MakeMsg (EMS_m_DynamicMemoryAllocated, WARN)
# define EMS_E_DynamicMemoryAllocated \
        EMS_MakeMsg (EMS_m_DynamicMemoryAllocated, ERRO)
# define EMS_F_DynamicMemoryAllocated \
        EMS_MakeMsg (EMS_m_DynamicMemoryAllocated, FATL)

# define EMS_S_EarlyClosure    EMS_MakeMsg (EMS_m_EarlyClosure, SUCC)
# define EMS_I_EarlyClosure    EMS_MakeMsg (EMS_m_EarlyClosure, INFO)
# define EMS_W_EarlyClosure    EMS_MakeMsg (EMS_m_EarlyClosure, WARN)
# define EMS_E_EarlyClosure    EMS_MakeMsg (EMS_m_EarlyClosure, ERRO)
# define EMS_F_EarlyClosure    EMS_MakeMsg (EMS_m_EarlyClosure, FATL)

# define EMS_S_EndOnSide    EMS_MakeMsg (EMS_m_EndOnSide, SUCC)
# define EMS_I_EndOnSide    EMS_MakeMsg (EMS_m_EndOnSide, INFO)
# define EMS_W_EndOnSide    EMS_MakeMsg (EMS_m_EndOnSide, WARN)
# define EMS_E_EndOnSide    EMS_MakeMsg (EMS_m_EndOnSide, ERRO)
# define EMS_F_EndOnSide    EMS_MakeMsg (EMS_m_EndOnSide, FATL)

# define EMS_S_Fail    EMS_MakeMsg (EMS_m_Fail, SUCC)
# define EMS_I_Fail    EMS_MakeMsg (EMS_m_Fail, INFO)
# define EMS_W_Fail    EMS_MakeMsg (EMS_m_Fail, WARN)
# define EMS_E_Fail    EMS_MakeMsg (EMS_m_Fail, ERRO)
# define EMS_F_Fail    EMS_MakeMsg (EMS_m_Fail, FATL)

# define EMS_S_FileOpen    EMS_MakeMsg (EMS_m_FileOpen, SUCC)
# define EMS_I_FileOpen    EMS_MakeMsg (EMS_m_FileOpen, INFO)
# define EMS_W_FileOpen    EMS_MakeMsg (EMS_m_FileOpen, WARN)
# define EMS_E_FileOpen    EMS_MakeMsg (EMS_m_FileOpen, ERRO)
# define EMS_F_FileOpen    EMS_MakeMsg (EMS_m_FileOpen, FATL)

# define EMS_S_Init    EMS_MakeMsg (EMS_m_Init, SUCC)
# define EMS_I_Init    EMS_MakeMsg (EMS_m_Init, INFO)
# define EMS_W_Init    EMS_MakeMsg (EMS_m_Init, WARN)
# define EMS_E_Init    EMS_MakeMsg (EMS_m_Init, ERRO)
# define EMS_F_Init    EMS_MakeMsg (EMS_m_Init, FATL)

# define EMS_S_InvalidArg    EMS_MakeMsg (EMS_m_InvalidArg, SUCC)
# define EMS_I_InvalidArg    EMS_MakeMsg (EMS_m_InvalidArg, INFO)
# define EMS_W_InvalidArg    EMS_MakeMsg (EMS_m_InvalidArg, WARN)
# define EMS_E_InvalidArg    EMS_MakeMsg (EMS_m_InvalidArg, ERRO)
# define EMS_F_InvalidArg    EMS_MakeMsg (EMS_m_InvalidArg, FATL)

# define EMS_S_MakeName    EMS_MakeMsg (EMS_m_MakeName, SUCC)
# define EMS_I_MakeName    EMS_MakeMsg (EMS_m_MakeName, INFO)
# define EMS_W_MakeName    EMS_MakeMsg (EMS_m_MakeName, WARN)
# define EMS_E_MakeName    EMS_MakeMsg (EMS_m_MakeName, ERRO)
# define EMS_F_MakeName    EMS_MakeMsg (EMS_m_MakeName, FATL)

# define EMS_S_Modified    EMS_MakeMsg (EMS_m_Modified, SUCC)
# define EMS_I_Modified    EMS_MakeMsg (EMS_m_Modified, INFO)
# define EMS_W_Modified    EMS_MakeMsg (EMS_m_Modified, WARN)
# define EMS_E_Modified    EMS_MakeMsg (EMS_m_Modified, ERRO)
# define EMS_F_Modified    EMS_MakeMsg (EMS_m_Modified, FATL)

# define EMS_S_MustOverride    EMS_MakeMsg (EMS_m_MustOverride, SUCC)
# define EMS_I_MustOverride    EMS_MakeMsg (EMS_m_MustOverride, INFO)
# define EMS_W_MustOverride    EMS_MakeMsg (EMS_m_MustOverride, WARN)
# define EMS_E_MustOverride    EMS_MakeMsg (EMS_m_MustOverride, ERRO)
# define EMS_F_MustOverride    EMS_MakeMsg (EMS_m_MustOverride, FATL)

# define EMS_S_NoSolution    EMS_MakeMsg (EMS_m_NoSolution, SUCC)
# define EMS_I_NoSolution    EMS_MakeMsg (EMS_m_NoSolution, INFO)
# define EMS_W_NoSolution    EMS_MakeMsg (EMS_m_NoSolution, WARN)
# define EMS_E_NoSolution    EMS_MakeMsg (EMS_m_NoSolution, ERRO)
# define EMS_F_NoSolution    EMS_MakeMsg (EMS_m_NoSolution, FATL)

# define EMS_S_NoStackMemory    EMS_MakeMsg (EMS_m_NoStackMemory, SUCC)
# define EMS_I_NoStackMemory    EMS_MakeMsg (EMS_m_NoStackMemory, INFO)
# define EMS_W_NoStackMemory    EMS_MakeMsg (EMS_m_NoStackMemory, WARN)
# define EMS_E_NoStackMemory    EMS_MakeMsg (EMS_m_NoStackMemory, ERRO)
# define EMS_F_NoStackMemory    EMS_MakeMsg (EMS_m_NoStackMemory, FATL)

# define EMS_S_NotFound    EMS_MakeMsg (EMS_m_NotFound, SUCC)
# define EMS_I_NotFound    EMS_MakeMsg (EMS_m_NotFound, INFO)
# define EMS_W_NotFound    EMS_MakeMsg (EMS_m_NotFound, WARN)
# define EMS_E_NotFound    EMS_MakeMsg (EMS_m_NotFound, ERRO)
# define EMS_F_NotFound    EMS_MakeMsg (EMS_m_NotFound, FATL)

# define EMS_S_NotUnique    EMS_MakeMsg (EMS_m_NotUnique, SUCC)
# define EMS_I_NotUnique    EMS_MakeMsg (EMS_m_NotUnique, INFO)
# define EMS_W_NotUnique    EMS_MakeMsg (EMS_m_NotUnique, WARN)
# define EMS_E_NotUnique    EMS_MakeMsg (EMS_m_NotUnique, ERRO)
# define EMS_F_NotUnique    EMS_MakeMsg (EMS_m_NotUnique, FATL)

# define EMS_S_OnFace    EMS_MakeMsg (EMS_m_OnFace, SUCC)
# define EMS_I_OnFace    EMS_MakeMsg (EMS_m_OnFace, INFO)
# define EMS_W_OnFace    EMS_MakeMsg (EMS_m_OnFace, WARN)
# define EMS_E_OnFace    EMS_MakeMsg (EMS_m_OnFace, ERRO)
# define EMS_F_OnFace    EMS_MakeMsg (EMS_m_OnFace, FATL)

# define EMS_S_OnSide    EMS_MakeMsg (EMS_m_OnSide, SUCC)
# define EMS_I_OnSide    EMS_MakeMsg (EMS_m_OnSide, INFO)
# define EMS_W_OnSide    EMS_MakeMsg (EMS_m_OnSide, WARN)
# define EMS_E_OnSide    EMS_MakeMsg (EMS_m_OnSide, ERRO)
# define EMS_F_OnSide    EMS_MakeMsg (EMS_m_OnSide, FATL)

# define EMS_S_Open    EMS_MakeMsg (EMS_m_Open, SUCC)
# define EMS_I_Open    EMS_MakeMsg (EMS_m_Open, INFO)
# define EMS_W_Open    EMS_MakeMsg (EMS_m_Open, WARN)
# define EMS_E_Open    EMS_MakeMsg (EMS_m_Open, ERRO)
# define EMS_F_Open    EMS_MakeMsg (EMS_m_Open, FATL)

# define EMS_S_ParOutOfBounds    EMS_MakeMsg (EMS_m_ParOutOfBounds, SUCC)
# define EMS_I_ParOutOfBounds    EMS_MakeMsg (EMS_m_ParOutOfBounds, INFO)
# define EMS_W_ParOutOfBounds    EMS_MakeMsg (EMS_m_ParOutOfBounds, WARN)
# define EMS_E_ParOutOfBounds    EMS_MakeMsg (EMS_m_ParOutOfBounds, ERRO)
# define EMS_F_ParOutOfBounds    EMS_MakeMsg (EMS_m_ParOutOfBounds, FATL)

# define EMS_S_PipeOpen    EMS_MakeMsg (EMS_m_PipeOpen, SUCC)
# define EMS_I_PipeOpen    EMS_MakeMsg (EMS_m_PipeOpen, INFO)
# define EMS_W_PipeOpen    EMS_MakeMsg (EMS_m_PipeOpen, WARN)
# define EMS_E_PipeOpen    EMS_MakeMsg (EMS_m_PipeOpen, ERRO)
# define EMS_F_PipeOpen    EMS_MakeMsg (EMS_m_PipeOpen, FATL)

# define EMS_S_PipeRead    EMS_MakeMsg (EMS_m_PipeRead, SUCC)
# define EMS_I_PipeRead    EMS_MakeMsg (EMS_m_PipeRead, INFO)
# define EMS_W_PipeRead    EMS_MakeMsg (EMS_m_PipeRead, WARN)
# define EMS_E_PipeRead    EMS_MakeMsg (EMS_m_PipeRead, ERRO)
# define EMS_F_PipeRead    EMS_MakeMsg (EMS_m_PipeRead, FATL)

# define EMS_S_Rational    EMS_MakeMsg (EMS_m_Rational, SUCC)
# define EMS_I_Rational    EMS_MakeMsg (EMS_m_Rational, INFO)
# define EMS_W_Rational    EMS_MakeMsg (EMS_m_Rational, WARN)
# define EMS_E_Rational    EMS_MakeMsg (EMS_m_Rational, ERRO)
# define EMS_F_Rational    EMS_MakeMsg (EMS_m_Rational, FATL)

# define EMS_S_StackMemoryAllocated \
        EMS_MakeMsg (EMS_m_StackMemoryAllocated, SUCC)
# define EMS_I_StackMemoryAllocated \
        EMS_MakeMsg (EMS_m_StackMemoryAllocated, INFO)
# define EMS_W_StackMemoryAllocated \
        EMS_MakeMsg (EMS_m_StackMemoryAllocated, WARN)
# define EMS_E_StackMemoryAllocated \
        EMS_MakeMsg (EMS_m_StackMemoryAllocated, ERRO)
# define EMS_F_StackMemoryAllocated \
        EMS_MakeMsg (EMS_m_StackMemoryAllocated, FATL)

# define EMS_S_Success    EMS_MakeMsg (EMS_m_Success, SUCC)
# define EMS_I_Success    EMS_MakeMsg (EMS_m_Success, INFO)
# define EMS_W_Success    EMS_MakeMsg (EMS_m_Success, WARN)
# define EMS_E_Success    EMS_MakeMsg (EMS_m_Success, ERRO)
# define EMS_F_Success    EMS_MakeMsg (EMS_m_Success, FATL)

# define EMS_S_Unlink    EMS_MakeMsg (EMS_m_Unlink, SUCC)
# define EMS_I_Unlink    EMS_MakeMsg (EMS_m_Unlink, INFO)
# define EMS_W_Unlink    EMS_MakeMsg (EMS_m_Unlink, WARN)
# define EMS_E_Unlink    EMS_MakeMsg (EMS_m_Unlink, ERRO)
# define EMS_F_Unlink    EMS_MakeMsg (EMS_m_Unlink, FATL)

# define EMS_S_Useless    EMS_MakeMsg (EMS_m_Useless, SUCC)
# define EMS_I_Useless    EMS_MakeMsg (EMS_m_Useless, INFO)
# define EMS_W_Useless    EMS_MakeMsg (EMS_m_Useless, WARN)
# define EMS_E_Useless    EMS_MakeMsg (EMS_m_Useless, ERRO)
# define EMS_F_Useless    EMS_MakeMsg (EMS_m_Useless, FATL)

# define EMS_S_FileClose    EMS_MakeMsg (EMS_m_FileClose, SUCC)
# define EMS_I_FileClose    EMS_MakeMsg (EMS_m_FileClose, INFO)
# define EMS_W_FileClose    EMS_MakeMsg (EMS_m_FileClose, WARN)
# define EMS_E_FileClose    EMS_MakeMsg (EMS_m_FileClose, ERRO)
# define EMS_F_FileClose    EMS_MakeMsg (EMS_m_FileClose, FATL)

# define EMS_I_InvalidCase  EMS_MakeMsg (EMS_m_InvalidCase, INFO)
# define EMS_E_InvalidCase  EMS_MakeMsg (EMS_m_InvalidCase, ERRO)

# define EMS_I_AlreadySplit EMS_MakeMsg (EMS_m_AlreadySplit, INFO)
# define EMS_E_AlreadySplit EMS_MakeMsg (EMS_m_AlreadySplit, ERRO)

# define EMS_I_NotSplit     EMS_MakeMsg (EMS_m_NotSplit, INFO)
# define EMS_E_NotSplit     EMS_MakeMsg (EMS_m_NotSplit, ERRO)

# define EMS_E_EdgeError    EMS_MakeMsg (EMS_m_EdgeError, ERRO)
# define EMS_I_EdgeError    EMS_MakeMsg (EMS_m_EdgeError, INFO)

# define EMS_W_LoopError    EMS_MakeMsg (EMS_m_LoopError, WARN)
# define EMS_I_LoopError    EMS_MakeMsg (EMS_m_LoopError, INFO)
# define EMS_E_LoopError    EMS_MakeMsg (EMS_m_LoopError, ERRO)

# define EMS_E_LoopsetError EMS_MakeMsg (EMS_m_LoopsetError, ERRO)
# define EMS_I_LoopsetError EMS_MakeMsg (EMS_m_LoopsetError, INFO)

# define EMS_E_OMerror      EMS_MakeMsg (EMS_m_OMerror, ERRO)

# define EMS_E_SurfaceError EMS_MakeMsg (EMS_m_SurfaceError, ERRO)
# define EMS_I_SurfaceError EMS_MakeMsg (EMS_m_SurfaceError, INFO)

# define EMS_E_CurveError   EMS_MakeMsg (EMS_m_CurveError, ERRO)

# define EMS_S_OutOfBounds  EMS_MakeMsg (EMS_m_OutOfBounds, SUCC)
# define EMS_I_OutOfBounds  EMS_MakeMsg (EMS_m_OutOfBounds, INFO)
# define EMS_W_OutOfBounds  EMS_MakeMsg (EMS_m_OutOfBounds, WARN)
# define EMS_E_OutOfBounds  EMS_MakeMsg (EMS_m_OutOfBounds, ERRO)
# define EMS_F_OutOfBounds  EMS_MakeMsg (EMS_m_OutOfBounds, FATL)

# define EMS_E_NoDynamicMemory  EMS_MakeMsg (EMS_m_NoDynamicMemory, ERRO)

# define EMS_I_Intersect    EMS_MakeMsg (EMS_m_Intersect, INFO)
# define EMS_E_Intersect        EMS_MakeMsg (EMS_m_Intersect, ERRO)

# define EMS_I_IntersectTrim    EMS_MakeMsg (EMS_m_IntersectTrim, INFO)
# define EMS_E_IntersectTrim    EMS_MakeMsg (EMS_m_IntersectTrim, ERRO)

# define EMS_E_IntersectClosure EMS_MakeMsg (EMS_m_IntersectClosure, ERRO)

# define EMS_I_IntersectOrient  EMS_MakeMsg (EMS_m_IntersectOrient, INFO)
# define EMS_E_IntersectOrient  EMS_MakeMsg (EMS_m_IntersectOrient, ERRO)

# define EMS_E_BSerror        EMS_MakeMsg (EMS_m_BSerror, ERRO)
# define EMS_I_BSerror        EMS_MakeMsg (EMS_m_BSerror, INFO)

# define EMS_E_MAerror        EMS_MakeMsg (EMS_m_MAerror, ERRO)

# define EMS_I_NoMoreLoops  EMS_MakeMsg (EMS_m_NoMoreLoops, INFO)
# define EMS_E_NoMoreLoops  EMS_MakeMsg (EMS_m_NoMoreLoops, ERRO)

# define EMS_I_InvalidSend  EMS_MakeMsg (EMS_m_InvalidSend, INFO)
# define EMS_E_InvalidSend  EMS_MakeMsg (EMS_m_InvalidSend, ERRO)

# define EMS_I_NoResponse   EMS_MakeMsg (EMS_m_NoResponse, INFO)

# define EMS_E_NestError  EMS_MakeMsg (EMS_m_NestError, ERRO)

# define EMS_E_TreeModError  EMS_MakeMsg (EMS_m_TreeModError, ERRO)

# define EMS_E_PtLocError  EMS_MakeMsg (EMS_m_PtLocError, ERRO)

# define EMS_I_InactiveLoop    EMS_MakeMsg (EMS_m_InactiveLoop, INFO)

# define EMS_I_InAreaTrim    EMS_MakeMsg (EMS_m_InAreaTrim, INFO)

# define EMS_E_InAreaTrim    EMS_MakeMsg (EMS_m_InAreaTrim, ERRO)

# define EMS_I_InHoleTrim    EMS_MakeMsg (EMS_m_InHoleTrim, INFO)

# define EMS_E_InHoleTrim    EMS_MakeMsg (EMS_m_InHoleTrim, ERRO)

# define EMS_I_NoIntersection    EMS_MakeMsg (EMS_m_NoIntersection, INFO)

# define EMS_E_NoIntersection    EMS_MakeMsg (EMS_m_NoIntersection, ERRO)
# define EMS_E_AllIntersectionsDeleted  EMS_MakeMsg(EMS_m_AllIntersectionsDeleted, ERRO)

# define EMS_I_BoolFail    EMS_MakeMsg (EMS_m_BoolFail, INFO)
# define EMS_E_BoolFail    EMS_MakeMsg (EMS_m_BoolFail, ERRO)
# define EMS_F_BoolFail    EMS_MakeMsg (EMS_m_BoolFail, FATL)

# define EMS_W_LocalModsInModel EMS_MakeMsg (EMS_m_LocalModsInModel, WARN)

# define EMS_E_DegenerateEdge  EMS_MakeMsg (EMS_m_DegenerateEdge, ERRO)
# define EMS_I_DegenerateEdge  EMS_MakeMsg (EMS_m_DegenerateEdge, INFO)

# define EMS_I_NoLocation  EMS_MakeMsg (EMS_m_NoLocation, INFO)

# define EMS_I_NoDisplay  EMS_MakeMsg (EMS_m_NoDisplay, INFO)

# define EMS_W_NotUpToDate  EMS_MakeMsg (EMS_m_NotUpToDate, WARN)
# define EMS_E_NotUpToDate  EMS_MakeMsg (EMS_m_NotUpToDate, ERRO)

# define EMS_I_Degenerate EMS_MakeMsg (EMS_m_Degenerate, INFO)
# define EMS_I_TopCapDegenerate EMS_MakeMsg (EMS_m_TopCapDegenerate, INFO)

# define EMS_I_BottomCapDegenerate \
    EMS_MakeMsg (EMS_m_BottomCapDegenerate, INFO)

# define EMS_I_BothCapsDegenerate \
    EMS_MakeMsg (EMS_m_BothCapsDegenerate, INFO)

# define EMS_I_Found  EMS_MakeMsg (EMS_m_Found, INFO)
 
# define EMS_I_DegenerateLoop  EMS_MakeMsg (EMS_m_DegenerateLoop, INFO)
# define EMS_E_DegenerateLoop  EMS_MakeMsg (EMS_m_DegenerateLoop, ERRO)
# define EMS_E_OpenLoop  EMS_MakeMsg (EMS_m_OpenLoop, ERRO)
# define EMS_I_OpenLoop  EMS_MakeMsg (EMS_m_OpenLoop, INFO)
# define EMS_I_CoincedentTrim EMS_MakeMsg (EMS_m_CoincedentTrim, INFO)
# define EMS_E_CoincedentTrim EMS_MakeMsg (EMS_m_CoincedentTrim, ERRO)
 
 /*
  * Added by Chopra
  */
 
# define EMS_E_NoValidBnd EMS_MakeMsg (EMS_m_NoValidBnd, ERRO)
# define EMS_E_NoTrimBnd  EMS_MakeMsg (EMS_m_NoTrimBnd, ERRO)
# define EMS_E_MkfCollapse EMS_MakeMsg (EMS_m_MkfCollapse, ERRO)
# define EMS_E_MkfGrouping EMS_MakeMsg (EMS_m_MkfGrouping, ERRO)
# define EMS_E_MkfGrExit   EMS_MakeMsg (EMS_m_MkfGrExit, ERRO)
 
# define EMS_I_NoMore EMS_MakeMsg (EMS_m_NoMore, INFO)

# define EMS_I_Ambiguous EMS_MakeMsg (EMS_m_Ambiguous, INFO)
# define EMS_E_Ambiguous EMS_MakeMsg (EMS_m_Ambiguous, ERRO)

# define EMS_I_FeatureLoop EMS_MakeMsg (EMS_m_FeatureLoop, INFO)

# define EMS_I_Stop EMS_MakeMsg (EMS_m_Stop, INFO)
# define EMS_E_Stop EMS_MakeMsg (EMS_m_Stop, ERRO)
# define EMS_I_NeedGrpInfo EMS_MakeMsg (EMS_m_NeedGrpInfo, INFO)

# define EMS_I_CvsNonCoplanar EMS_MakeMsg (EMS_m_CvsNonCoplanar, INFO)
# define EMS_I_DiffSrfOrder EMS_MakeMsg (EMS_m_DiffSrfOrder, INFO)

# define EMS_I_RndGrExit   EMS_MakeMsg (EMS_m_RndGrExit, INFO)
# define EMS_E_RndGrExit   EMS_MakeMsg (EMS_m_RndGrExit, ERRO)
# define EMS_E_RndInterfere   EMS_MakeMsg (EMS_m_RndInterfere, ERRO)

# define EMS_E_IntersClosureOrient \
                            EMS_MakeMsg (EMS_m_IntersClosureOrient, ERRO)

# define EMS_I_Interrupt EMS_MakeMsg (EMS_m_Interrupt, INFO)

# define EMS_I_Clipped EMS_MakeMsg (EMS_m_Clipped, INFO)

/* Added by Sunit. 04-Mar-89. */

# define EMS_I_NoCommonEdge EMS_MakeMsg (EMS_m_NoCommonEdge, INFO)

# define EMS_I_ChangeClass EMS_MakeMsg (EMS_m_ChangeClass, INFO)

# define EMS_I_CantRecompute EMS_MakeMsg (EMS_m_CantRecompute, INFO)
# define EMS_W_CantRecompute EMS_MakeMsg (EMS_m_CantRecompute, WARN)
# define EMS_E_CantRecompute EMS_MakeMsg (EMS_m_CantRecompute, ERRO)

# define EMS_I_RecomputeOccurred EMS_MakeMsg (EMS_m_RecomputeOccurred, INFO)

/* Added by Ashok  11-May-90 */
# define EMS_I_AutoStk EMS_MakeMsg (EMS_m_AutoStk, INFO)

# define EMS_I_FoundOther EMS_MakeMsg (EMS_m_FoundOther, INFO)

/* Added by Inasu on June 4, 1990  */

# define EMS_I_NoxsectionPlane   EMS_MakeMsg (EMS_m_NoxsectionPlane,INFO)

# define EMS_I_BadElement        EMS_MakeMsg (EMS_m_BadElement, INFO)
# define EMS_E_BadElement        EMS_MakeMsg (EMS_m_BadElement, ERRO)

# define EMS_I_BadPlane          EMS_MakeMsg (EMS_m_BadPlane, INFO)
# define EMS_E_BadPlane          EMS_MakeMsg (EMS_m_BadPlane, ERRO)

# define EMS_I_NotSupported      EMS_MakeMsg (EMS_m_NotSupported, INFO)
# define EMS_E_NotSupported      EMS_MakeMsg (EMS_m_NotSupported, ERRO)

# define EMS_I_Cycle      EMS_MakeMsg (EMS_m_Cycle, INFO)
# define EMS_E_Cycle      EMS_MakeMsg (EMS_m_Cycle, ERRO)

# define EMS_I_Merge      EMS_MakeMsg (EMS_m_Merge, INFO)
# define EMS_E_Merge      EMS_MakeMsg (EMS_m_Merge, ERRO)

# define EMS_I_ArcLenPar EMS_MakeMsg (EMS_m_ArcLenPar, INFO)

/*
 * The following message definitions are intended for variational geometry
 */

# define EMS_I_PtEvaluated EMS_MakeMsg (EMS_m_PtEvaluated, INFO)
# define EMS_I_LocusEvaluated EMS_MakeMsg (EMS_m_LocusEvaluated, INFO)
# define EMS_E_Degenerate EMS_MakeMsg (EMS_m_Degenerate, ERRO)
# define EMS_I_Redundant EMS_MakeMsg (EMS_m_Redundant, INFO)
# define EMS_I_Conflicting EMS_MakeMsg (EMS_m_Conflicting, INFO)
# define EMS_I_Exceeded EMS_MakeMsg (EMS_m_Exceeded, INFO)
# define EMS_I_UnderConstrained EMS_MakeMsg (EMS_m_UnderConstrained, INFO)
# define EMS_E_ASerror EMS_MakeMsg (EMS_m_ASerror, ERRO)
# define EMS_E_Construct EMS_MakeMsg (EMS_m_ASerror, ERRO)
# define EMS_E_Connect EMS_MakeMsg (EMS_m_Connect, ERRO)
# define EMS_E_Assoc EMS_MakeMsg (EMS_m_Assoc, ERRO)
# define EMS_I_Assoc EMS_MakeMsg (EMS_m_Assoc, INFO)
# define EMS_E_GRvg EMS_MakeMsg (EMS_m_GRvg, ERRO)
# define EMS_E_GRgraphics EMS_MakeMsg (EMS_m_GRgraphics, ERRO)
# define EMS_E_DPRerror EMS_MakeMsg (EMS_m_DPRerror, ERRO)
# define EMS_E_ASsferror EMS_MakeMsg (EMS_m_ASsferror, ERRO)
# define EMS_E_GRconnector EMS_MakeMsg (EMS_m_GRconnector, ERRO)
# define EMS_I_Insufficient EMS_MakeMsg (EMS_m_Insufficient, INFO)
# define EMS_I_InvalidTopology EMS_MakeMsg (EMS_m_InvalidTopology, INFO)
# define EMS_I_FullyConstrained EMS_MakeMsg (EMS_m_FullyConstrained, INFO)

# define EMS_I_DirectlyOwned EMS_MakeMsg (EMS_m_DirectlyOwned, INFO)

# define EMS_I_WasLastGroupComp EMS_MakeMsg (EMS_m_WasLastGroupComp, INFO)


/*
 * Following Messages are Intended For Add/Remove Material Functinality
 * --- Sanjay
 */
#define EMS_E_AddRmNoIntToNextSurf EMS_MakeMsg (EMS_m_AddRmNoIntToNextSurf,ERRO)

#define EMS_E_AddRmNoIntFromSurf   EMS_MakeMsg (EMS_m_AddRmNoIntFromSurf, ERRO)
#define EMS_E_AddRmNoIntToSurf     EMS_MakeMsg (EMS_m_AddRmNoIntToSurf, ERRO)
#define EMS_E_AddRmInfinite        EMS_MakeMsg (EMS_m_AddRmInfinite, ERRO)
#define EMS_E_AddRmDisjoint        EMS_MakeMsg (EMS_m_AddRmDisjoint, ERRO)
#define EMS_E_AddRmErrorInConst    EMS_MakeMsg (EMS_m_AddRmErrorInConst, ERRO)

#define EMS_I_AddRmNoIntToNextSurf EMS_MakeMsg (EMS_m_AddRmNoIntToNextSurf,INFO)
#define EMS_I_AddRmNoIntFromSurf   EMS_MakeMsg (EMS_m_AddRmNoIntFromSurf, INFO)
#define EMS_I_AddRmNoIntToSurf     EMS_MakeMsg (EMS_m_AddRmNoIntToSurf, INFO)
#define EMS_I_AddRmInfinite        EMS_MakeMsg (EMS_m_AddRmInfinite, INFO)
#define EMS_I_AddRmDisjoint        EMS_MakeMsg (EMS_m_AddRmDisjoint, INFO)
#define EMS_I_AddRmErrorInConst    EMS_MakeMsg (EMS_m_AddRmErrorInConst, INFO)

#define EMS_W_AddRmNoIntToNextSurf EMS_MakeMsg (EMS_m_AddRmNoIntToNextSurf,WARN)
#define EMS_W_AddRmNoIntFromSurf   EMS_MakeMsg (EMS_m_AddRmNoIntFromSurf, WARN)
#define EMS_W_AddRmNoIntToSurf     EMS_MakeMsg (EMS_m_AddRmNoIntToSurf, WARN)
#define EMS_W_AddRmInfinite        EMS_MakeMsg (EMS_m_AddRmInfinite, WARN)
#define EMS_W_AddRmDisjoint        EMS_MakeMsg (EMS_m_AddRmDisjoint, WARN)
#define EMS_W_AddRmErrorInConst    EMS_MakeMsg (EMS_m_AddRmErrorInConst, WARN)

#endif
