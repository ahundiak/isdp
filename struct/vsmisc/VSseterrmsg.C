/*
	I/STRUCT
*/
#include "OMerrordef.h"
#include "UNIXerrdef.h"
#include "DIdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"

#define	MS_FACILITY_CODE	0x800
#define GR_FACILITY_CODE	0x804
/*----------------------------------------------------------------------------*/
long VSchgEMSseverity( inMsg ) long inMsg ; {
	long		outMsg ;

#define HANDLE( pat ) case EMS_m_##pat : outMsg = EMS_E_##pat ; break

	switch( EMS_Message( inMsg ) ) {
		HANDLE( NoIntersection 		) ;
		HANDLE( BoolFail	  	) ;
		HANDLE( IntersectClosure	) ;
		HANDLE( IntersectOrient		) ;
		HANDLE( IntersClosureOrient	) ;
		HANDLE( Intersect		) ;
		HANDLE( NoDynamicMemory		) ;
		HANDLE( NoMoreLoops		) ;
		HANDLE( BSerror			) ;
		HANDLE( BadOrder		) ;
		HANDLE( BaseName		) ;
		HANDLE( ChanCountNot1		) ;
		HANDLE( ChanCountWrong		) ;
		HANDLE( Closed			) ;
		HANDLE( Coincident		) ;
		HANDLE( DirName			) ;
		HANDLE( EarlyClosure		) ;
		HANDLE( EndOnSide		) ;
		HANDLE( Fail			) ;
		HANDLE( FileOpen		) ;
		HANDLE( InvalidArg		) ;
		HANDLE( NoSolution		) ;
		HANDLE( ParOutOfBounds		) ;
		HANDLE( InvalidCase		) ;
		HANDLE( EdgeError		) ;
		HANDLE( LoopsetError		) ;
		HANDLE( SurfaceError		) ;
		HANDLE( IntersectTrim		) ;
		
		default : outMsg = inMsg ; break ;
	}
	return outMsg ;

} /* VSchgEMSseverity */
/*----------------------------------------------------------------------------*/
long VSsetErrMsg( inMsg ) long inMsg ; {

	long		outMsg ;

	switch( inMsg >> 16 ) {
		case EMS_FacilityCode	: outMsg = VSchgEMSseverity( inMsg ) ;
					  break ;
		default			:
		case OM_FACILITY_CODE 	: /* Same as DIR_FACILITY_CODE ! */
		case UNIX_FACILITY_CODE :
		case GR_FACILITY_CODE	: outMsg = inMsg ; break ;
		case MS_FACILITY_CODE	:
			switch( inMsg ) {
			case MSSUCC	: outMsg = EMS_S_Success	; break;
			case MSFAIL	: outMsg = EMS_E_Fail		; break;
			case MSINARG	: outMsg = EMS_E_InvalidArg	; break;
			default		: outMsg = inMsg		; break;
			}
			break ;
	}
	return outMsg ;	

} /* VSsetErrMsg */
/*----------------------------------------------------------------------------*/
static long VSgetEMSmsgKey( msg ) long msg ; {

	switch( EMS_Message( msg ) ) {
	case EMS_m_NoIntersection 	: msg = VS_gI_SfSlEltsNoIntersect ;
					  break ;	
	case EMS_m_BoolFail	  	: msg = VS_gE_BooleanFailure ;
					  break ;
	case EMS_m_IntersectClosure	: msg = VS_gE_IntxCvsNotClosed ;
					  break ;
	case EMS_m_IntersectOrient	: msg = VS_gE_IntxCvsImproperOrient ;
					  break ;
	case EMS_m_IntersClosureOrient	: msg = VS_gE_IntersOrientClosure ;
					  break ;
	case EMS_m_Intersect		: msg = VS_gE_BadIntersectionResults ;
					  break ;
	case EMS_m_NoDynamicMemory	: msg = VS_gE_NoDynMem ;
					  break ;
	case EMS_m_NoMoreLoops		: msg = VS_gE_NoValidBdriesToImpose ;
					  break ;
	case EMS_m_Fail			: msg = VS_gE_OperationFailed ;
					  break ;
	case EMS_m_InvalidArg		: msg = VS_gE_InvalidArgument ;
					  break ;
	case EMS_m_Success	  	: msg = VS_gI_EmptyMessage ;
					  break ;
	case EMS_m_Interrupt		: msg = VS_gI_ProcessingInterrupt ;
					  break ;
	case EMS_m_NoSolution		: msg = VS_gI_NoSolutionFound;
					  break ;
	case EMS_m_IntersectTrim	: msg = VS_gE_CouNoExtEle ;
					  break ;
	default				:
		if( msg & 1 ) {
			msg = VS_gI_EmptyMessage ;
		} else {
			msg = VS_gE_OperationFailed ;
		}
		break ;
	}
	return msg ;

} /* VSgetEMSmsgKey */
/*----------------------------------------------------------------------------*/
static long VSgetDImsgKey( msg ) long msg ; {

	switch( msg ) {
	case DIR_W_DIR_NOT_FOUND	: msg = VS_gE_DirNotFound	; break;
	case DIR_E_SYNTAX		: msg = VS_gE_DirSyntax		; break;
	case DIR_E_DIR_DUP		: msg = VS_gE_DupName		; break;
	case DIR_W_NAME_NOT_FOUND	: msg = VS_gE_NameNotFound	; break;
	case DIR_E_NAME_DUP	  	: msg = VS_gE_DupName		; break;
	case DIR_E_NO_NAME		: msg = VS_gE_NotNamed		; break;
	case DIR_E_INVARG		: msg = VS_gE_InvalidArgument	; break;
	default :
			msg = msg & 1
				? VS_gI_EmptyMessage
				: VS_gE_OperationFailed ;
			break ;
	}
	return msg ;

} /* VSgetDImsgKey */
/*----------------------------------------------------------------------------*/
static long VSgetUNIXmsgKey( msg ) long msg ; {

	switch( msg ) {
		case UNIX_E_ENOENT	: msg = VS_gE_ENOENT 	; break;
		case UNIX_E_ENOTDIR	: msg = VS_gE_ENOTDIR 	; break;
		case UNIX_E_EPERM	: msg = VS_gE_EPERM	; break ;
		case UNIX_E_EACCES	: msg = VS_gE_EACCES	; break;
		default			: msg = VS_gE_OperationFailed	; break;
	}
	return msg ;

} /* VSgetUNIXmsgKey */
/*----------------------------------------------------------------------------*/
long VSgetMsgKey( msg ) long msg ; {

	if( msg & 1 ) {
		msg = VS_gI_EmptyMessage ;
	} else switch( msg >> 16 ) {
		case UNIX_FACILITY_CODE : msg = VSgetUNIXmsgKey( msg ) ; break ;
		case EMS_FacilityCode   : msg = VSgetEMSmsgKey ( msg ) ; break ;
		case DIR_FACILITY_CODE  : msg = VSgetDImsgKey  ( msg ) ; break ;
		default		        :
			switch( EMS_Facility( msg ) ) {
			/*
			 * Is it an EMS message sub-system key ?
			 * The case "1 << 10" is due to a Message Builder bug,
			 * according to EMS...
			 */
			case EMS_MessageSubsystem_FacilityCode :
			case (EMS_MessageSubsystem_FacilityCode | (1 << 10)) :
				break ;
			default :
				msg = VS_gE_OperationFailed  ; break ;
			}
	}
	return msg ;

} /* VSgetMsgKey */
/*----------------------------------------------------------------------------*/

