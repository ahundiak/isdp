/*
NAME

EFprintcode -- put string of a message code in a stream

HISTORY

05 Mar 1989 SM	Added EMS_I_NoCommonEdge
09 Jan 1989 jBk Replaced em$xsMessage invocations with ex$message
                invocations.
                Accordingly, replaced EMScimacros.h inclusion
                with inclusion of msmacros.h.
03 May 1988 jBk Added temporary case to accomodate problem with
                message builder.
13 Apr 1988 jBk Use message subsystem to output some messages.
23 Mar 1988 jBk Added checks and output for severities PROMPT,
                MESSAGE, and SLEV7.
?? ??? ???? jBk Genesis.
*/

# include <stdio.h>
# include "OMprimitives.h"  /* om$report_error */
# include "OMerrordef.h"    /* OM_S_SUCCESS */
# include "EMSmsgdef.h"     /* EMS message definitions */
# include "EMStypedef.h"    /* EMSrc */
# include "msdef.h"         /* MS codes */
# include "maerr.h"         /* MA codes */

/* MS_MAX_MSG_LENGTH */
# include "msdef.h"

/* ex$message */
# include "msmacros.h"

/* message subsystem supported messages */
/*
# include "EC_I.h"
# include "EC_F.h"
# include "EC_M.h"
# include "EC_P.h"
*/

EMSrc EFprintcode (fp, code)
FILE *fp;
EMSrc code;
{
    EMSrc value = EMS_S_Success, EFprintSeverityLevel ();
    extern unsigned int OM_Gf_verbose_warning;
 
/********* SM Sept 3, 1992
    if (!ems_do_print_error_messages && !OM_Gf_verbose_warning)
    {
      return(value);
    }
****************/

/****DLB - removed reference to ems_do_print_error_messages 12/8/92*****/
    if (!OM_Gf_verbose_warning)
    {
      return(value);
    }
    
    if (! fp) fp = stderr;

    (void)fflush (stdout);
    /* just to make sure no one gets confused
        -- j. Brooke King 23-Apr-1987 */

    switch (EMS_Facility (code))
    {
    case (EMS_MessageSubsystem_FacilityCode | (1 << 10)):
        /* need the above case to get around a temporary bug in
            the message builder */
    case EMS_MessageSubsystem_FacilityCode:
/*
        {
            char buffer[MS_MAX_MSG_LENGTH + 1];

            ex$message (
                msgnumb = code,
                buff = buffer
            );

            (void)fprintf (fp, buffer);
        }
*/
	fprintf (fp, "Error code in message sub-system undeciphered\n");
        break;
    case EMS_FacilityCode:
        {
            (void)fprintf (fp, "EMS-");

            value = EFprintSeverityLevel (fp, code);

            switch (EMS_Message (code))
            {
            case EMS_m_BadOrder:
                (void)fprintf (fp, "BadOrder"); break;
            case EMS_m_BaseName:
                (void)fprintf (fp, "BaseName"); break;
            case EMS_m_ChanCountNot1:
                (void)fprintf (fp, "ChanCountNot1"); break;
            case EMS_m_ChanCountWrong:
                (void)fprintf (fp, "ChanCountWrong"); break;
            case EMS_m_Closed:
                (void)fprintf (fp, "Closed"); break;

            case EMS_m_Coincident:
                (void)fprintf (fp, "Coincident"); break;
            case EMS_m_DirName:
                (void)fprintf (fp, "DirName"); break;
            case EMS_m_DynamicMemoryAllocated:
                (void)fprintf (fp, "DynamicMemoryAllocated"); break;
            case EMS_m_EarlyClosure:
                (void)fprintf (fp, "EarlyClosure"); break;
            case EMS_m_EndOnSide:
                (void)fprintf (fp, "EndOnSide"); break;

            case EMS_m_Fail:
                (void)fprintf (fp, "Fail"); break;
            case EMS_m_FileOpen:
                (void)fprintf (fp, "FileOpen"); break;
            case EMS_m_Init:
                (void)fprintf (fp, "Init"); break;
            case EMS_m_InvalidArg:
                (void)fprintf (fp, "InvalidArg"); break;
            case EMS_m_MakeName:
                (void)fprintf (fp, "MakeName"); break;

            case EMS_m_Modified:
                (void)fprintf (fp, "Modified"); break;
            case EMS_m_MustOverride:
                (void)fprintf (fp, "MustOverride"); break;
            case EMS_m_NoSolution:
                (void)fprintf (fp, "NoSolution"); break;
            case EMS_m_NoStackMemory:
                (void)fprintf (fp, "NoStackMemory"); break;
            case EMS_m_NotFound:
                (void)fprintf (fp, "NotFound"); break;

            case EMS_m_NotUnique:
                (void)fprintf (fp, "NotUnique"); break;
            case EMS_m_OnFace:
                (void)fprintf (fp, "OnFace"); break;
            case EMS_m_OnSide:
                (void)fprintf (fp, "OnSide"); break;
            case EMS_m_Open:
                (void)fprintf (fp, "Open"); break;
            case EMS_m_ParOutOfBounds:
                (void)fprintf (fp, "ParOutOfBounds"); break;

            case EMS_m_PipeOpen:
                (void)fprintf (fp, "PipeOpen"); break;
            case EMS_m_PipeRead:
                (void)fprintf (fp, "PipeRead"); break;
            case EMS_m_Rational:
                (void)fprintf (fp, "Rational"); break;
            case EMS_m_StackMemoryAllocated:
                (void)fprintf (fp, "StackMemoryAllocated"); break;
            case EMS_m_Success:
                (void)fprintf (fp, "Success"); break;

            case EMS_m_Unlink:
                (void)fprintf (fp, "Unlink"); break;
            case EMS_m_Useless:
                (void)fprintf (fp, "Useless"); break;
            case EMS_m_FileClose:
                (void)fprintf (fp, "FileClose"); break;
            case EMS_m_InvalidCase:
                (void)fprintf (fp, "InvalidCase"); break;
            case EMS_m_AlreadySplit:
                (void)fprintf (fp, "AlreadySplit"); break;

            case EMS_m_NotSplit:
                (void)fprintf (fp, "NotSplit"); break;
            case EMS_m_EdgeError:
                (void)fprintf (fp, "EdgeError"); break;
            case EMS_m_LoopError:
                (void)fprintf (fp, "LoopError"); break;
            case EMS_m_LoopsetError:
                (void)fprintf (fp, "LoopsetError"); break;
            case EMS_m_OMerror:
                (void)fprintf (fp, "OMerror"); break;

            case EMS_m_SurfaceError:
                (void)fprintf (fp, "SurfaceError"); break;
            case EMS_m_CurveError:
                (void)fprintf (fp, "CurveError"); break;
            case EMS_m_OutOfBounds:
                (void)fprintf (fp, "OutOfBounds"); break;
            case EMS_m_NoDynamicMemory:
                (void)fprintf (fp, "NoDynamicMemory"); break;

            case EMS_m_Intersect:
                (void)fprintf (fp, "Intersect"); break;
            case EMS_m_IntersectTrim:
                (void)fprintf (fp, "IntersectTrim"); break;
            case EMS_m_IntersectClosure:
                (void)fprintf (fp, "IntersectClosure"); break;
            case EMS_m_IntersectOrient:
                (void)fprintf (fp, "IntersectOrient"); break;

            case EMS_m_BSerror:
                (void)fprintf (fp, "BSerror"); break;
            case EMS_m_MAerror:
                (void)fprintf (fp, "MAerror"); break;
            case EMS_m_NoMoreLoops:
                (void)fprintf (fp, "NoMoreLoops"); break;
            case EMS_m_InvalidSend:
                (void)fprintf (fp, "InvalidSend"); break;

            case EMS_m_NoResponse:
                (void)fprintf (fp, "NoResponse"); break;
            case EMS_m_NestError:
                (void)fprintf (fp, "NestError"); break;
            case EMS_m_TreeModError:
                (void)fprintf (fp, "TreeModError"); break;
            case EMS_m_PtLocError:
                (void)fprintf (fp, "PtLocError"); break;

            case EMS_m_InactiveLoop:
                (void)fprintf (fp, "InactiveLoop"); break;
            case EMS_m_InAreaTrim:
                (void)fprintf (fp, "InAreaTrim"); break;
            case EMS_m_InHoleTrim:
                (void)fprintf (fp, "InHoleTrim"); break;
            case EMS_m_NoIntersection:
                (void)fprintf (fp, "NoIntersection"); break;
            case EMS_m_AllIntersectionsDeleted:
                (void)fprintf (fp, "AllIntersectionsDeleted"); break;

            case EMS_m_BoolFail:
                (void)fprintf (fp, "BoolFail"); break;
            case EMS_m_DegenerateEdge:
                (void)fprintf (fp, "Degenerate edges present"); break;
            case EMS_m_LocalModsInModel:
                (void)fprintf (fp, "LocalModsInModel"); break;
            case EMS_m_NoLocation:
                (void)fprintf (fp, "NoLocation"); break;

            case EMS_m_NoDisplay:
                (void)fprintf (fp, "NoDisplay"); break;
            case EMS_m_NotUpToDate:
                (void)fprintf (fp, "NotUpToDate"); break;
            case EMS_m_Degenerate:
                (void)fprintf (fp, "Degenerate"); break;
            case EMS_m_TopCapDegenerate:
                (void)fprintf (fp, "TopCapDegenerate"); break;

            case EMS_m_BottomCapDegenerate:
                (void)fprintf (fp, "BottomCapDegenerate"); break;
            case EMS_m_BothCapsDegenerate:
                (void)fprintf (fp, "BothCapsDegenerate"); break;

            case EMS_m_Found:
                (void)fprintf (fp, "Found"); break;
            case EMS_m_DegenerateLoop:
                (void)fprintf (fp, "DegenerateLoop"); break;

            case EMS_m_OpenLoop:
                (void)fprintf (fp, "OpenLoop"); break;
            case EMS_m_CoincedentTrim:
                (void)fprintf (fp, "CoincidentTrim"); break;
            case EMS_m_NoValidBnd:
                (void)fprintf (fp, "NoValidBnd"); break;
            case EMS_m_NoTrimBnd:
                (void)fprintf (fp, "NoTrimBnd"); break;

            case EMS_m_MkfCollapse:
                (void)fprintf (fp, "MkfCollapse"); break;
            case EMS_m_MkfGrouping:
                (void)fprintf (fp, "MkfGrouping"); break;
            case EMS_m_MkfGrExit:
                (void)fprintf (fp, "MkfGrExit"); break;

            case EMS_m_NoMore:
                (void)fprintf (fp, "NoMore"); break;
            case EMS_m_Ambiguous:
                (void)fprintf (fp, "Ambiguous"); break;

            case EMS_m_Stop:
                (void)fprintf (fp, "Stop"); break;

            case EMS_m_NeedGrpInfo:
                (void)fprintf (fp, "NeedGrpInfo"); break;

            case EMS_m_CvsNonCoplanar:
                (void)fprintf (fp, "CvsNonCoplanar"); break;

            case EMS_m_DiffSrfOrder:
                (void)fprintf (fp, "DiffSrfOrder"); break;

            case EMS_m_RndGrExit:
                (void)fprintf (fp, "RndGrExit"); break;

            case EMS_m_RndInterfere:
                (void)fprintf (fp, "RndInterfere"); break;

            case EMS_m_IntersClosureOrient:
                (void)fprintf (fp, "IntersClosureOrient"); break;

            case EMS_m_NoCommonEdge:
                (void)fprintf (fp, "NoCommonEdge"); break;



            case EMS_m_PtEvaluated:
                (void)fprintf (fp, "PtEvaluated"); break;

            case EMS_m_LocusEvaluated:
                (void)fprintf (fp, "LocusEvaluated"); break;

            case EMS_m_Redundant:
                (void)fprintf (fp, "Redundant"); break;

            case EMS_m_Conflicting:
                (void)fprintf (fp, "Conflicting"); break;

            case EMS_m_Exceeded:
                (void)fprintf (fp, "Exceeded"); break;

            case EMS_m_UnderConstrained:
                (void)fprintf (fp, "UnderConstrained"); break;

            case EMS_m_ASerror:
                (void)fprintf (fp, "ASerror"); break;

            case EMS_m_Construct:
                (void)fprintf (fp, "Construct"); break;

            case EMS_m_Connect:
                (void)fprintf (fp, "Connect"); break;

            case EMS_m_Assoc:
                (void)fprintf (fp, "Assoc"); break;

            case EMS_m_GRvg:
                (void)fprintf (fp, "GRvg"); break;

            case EMS_m_GRgraphics:
                (void)fprintf (fp, "GRgraphics"); break;

            case EMS_m_DPRerror:
                (void)fprintf (fp, "DPRerror"); break;

            case EMS_m_ASsferror:
                (void)fprintf (fp, "ASsferror"); break;

            case EMS_m_GRconnector:
                (void)fprintf (fp, "GRconnector"); break;

            case EMS_m_Insufficient:
                (void)fprintf (fp, "Insufficient"); break;

            case EMS_m_InvalidTopology:
                (void)fprintf (fp, "InvalidTopology"); break;

            case EMS_m_FullyConstrained:
                (void)fprintf (fp, "FullyConstrained"); break;

            case EMS_m_AddRmNoIntToNextSurf:
                (void)fprintf (fp, "AddRmNoIntToNextSurf"); break;

            case EMS_m_AddRmNoIntFromSurf:
                (void)fprintf (fp, "AddRmNoIntFromSurf"); break;

            case EMS_m_AddRmNoIntToSurf:
                (void)fprintf (fp, "AddRmNoIntToSurf"); break;

            case EMS_m_AddRmInfinite:
                (void)fprintf (fp, "AddRmInfinite"); break;

            case EMS_m_AddRmErrorInConst:
                (void)fprintf (fp, "AddRmErrorInConst"); break;

            case EMS_m_AddRmDisjoint:
                (void)fprintf (fp, "AddRmDisjoint"); break;

            default:
                (void)fprintf (fp, "UnknownEMSMessage");
                value = EMS_I_InvalidArg;
            } /* switch (message) */
        }
        break;
    case OM_FACILITY_CODE:
        {
            (void)fprintf (fp, "\n");
            om$report_error (sts = code);
            (void)fflush (stdout);
            /* since om$report_error goes to stdout
                -- j. Brooke King 23-Apr-1987 */
        }
        break;
    default: /* switch (EMS_Facility (code)) */
        switch (code)
        {
        case OM_S_SUCCESS:
            {
                (void)fprintf (fp, "\n");
                om$report_error (sts = code);
                (void)fflush (stdout);
                /* since om$report_error goes to stdout
                    -- j. Brooke King 23-Apr-1987 */
            }
            break;
        case MAOVF:
            (void)fprintf (fp,
            "\nMAOVF overflow or underflow\n");
            break;
        case MANEGSRT:
            (void)fprintf (fp,
            "\nMANEGSRT negative input to square root\n");
            break;
        case MAZDIV:
            (void)fprintf (fp,
            "\nMAZDIV divide by zero\n");
            break;
        case MADGENRAT:
            (void)fprintf (fp,
            "\nMADGENRAT degenerate case -- error\n");
            break;
        case MANONPLANAR:
            (void)fprintf (fp,
            "\nMANONPLANAR non planar\n");
            break;
        case MAEINFSOLUTION:
            (void)fprintf (fp,
            "\nMAEINFSOLUTION infinite solution\n");
            break;
        case MANOPROJECT:
            (void)fprintf (fp,
            "\nMANOPROJECT projection failed\n");
            break;
        case MANOTCOMPLETE:
            (void)fprintf (fp,
            "\nMANOTCOMPLETE processing not complete\n");
            break;
        case MASDGENRAT:
            (void)fprintf (fp,
            "\nMASDGENRAT degenerate case -- severe error\n");
            break;
        case MADDNE:
            (void)fprintf (fp,
            "\nMADDNE derivative does not exist\n");
            break;
        case MAKNTI:
            (void)fprintf (fp,
            "\nMAKNTI knot index could not be found\n");
            break;
        case MANOSOLUTION:
            (void)fprintf (fp,
            "\nMANOSOLUTION no solution could be determined\n");
            break;
        case MANOMEMORY:
            (void)fprintf (fp,
            "\nMANOMEMORY no memory could be allocated\n");
            break;
        case MAINFSOLUTION:
            (void)fprintf (fp,
            "\nMAINFSOLUTION infinite number of solutions\n");
            break;
        case MAIDGENRAT:
            (void)fprintf (fp,
            "\nMAIDGENRAT degenerate case\n");
            break;
        case MAINOTUNIQUE:
            (void)fprintf (fp,
            "\nMAINOTUNIQUE more solutions exist than the one located\n");
            break;
        case MSSUCC:
            (void)fprintf (fp,
            "\nMSSUCC successful completion\n");
            break;
        case MSFAIL:
            (void)fprintf (fp,
            "\nMSFAIL error\n");
            break;
        case MSINARG:
            (void)fprintf (fp,
            "\nMSINARG invalid argument\n");
            break;
        default:
            (void)fprintf (
                fp,
                "Message not hardcoded:\n(Unknown code:  0x%x == 0x%x-",
                code,
                EMS_Facility (code)
            );

            value = EFprintSeverityLevel (fp, code);

            fprintf (fp, "0x%x)", EMS_Message (code));

/*
            {
                char buffer[MS_MAX_MSG_LENGTH + 1];

                ex$message (
                    msgnumb = code,
                    buff = buffer
                );

                (void)fprintf (
                    fp, " via message subsystem:\n%s\n", buffer
                );
            }
*/
        } /* switch (code) */
    } /* switch (EMS_Facility (code)) */

    (void)fflush (fp);
    /* just to make sure no one gets confused
        -- j. Brooke King 23-Apr-1987 */

    return value;
}

EMSrc EFprintSeverityLevel (fp, code)
FILE *fp;
EMSrc code;
{
    EMSrc value = EMS_S_Success;

    switch (EMS_SeverityLevel (code))
    {
    case WARN: (void)fprintf (fp, "W-"); break;
    case SUCC: (void)fprintf (fp, "S-"); break;
    case ERRO: (void)fprintf (fp, "E-"); break;
    case INFO: (void)fprintf (fp, "I-"); break;
    case FATL: (void)fprintf (fp, "F-"); break;
    case PROMPT: (void)fprintf (fp, "P-"); break;
    case MESSAGE: (void)fprintf (fp, "M-"); break;
    case SLEV7: (void)fprintf (fp, "7-"); break;
    default:
        (void)fprintf (
            fp,
            "UnknownSeverity_%u-",
            EMS_SeverityLevel(code)
        );
        value = EMS_I_InvalidArg;
    } /* switch (severity) */

    return value;
}
