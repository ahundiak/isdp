/*
	I/VDS	Copy
*/
#include "OMerrordef.h"
#include "UNIXerrdef.h"
#include "DIdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "v_globalmsg.h"

#define	MS_FACILITY_CODE	0x800
#define GR_FACILITY_CODE	0x804
/*----------------------------------------------------------------------------*/
long VD_chgEMSseverity( inMsg ) long inMsg ; {
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

} /* VD_chgEMSseverity */
/*----------------------------------------------------------------------------*/
#ifdef	NOT_USED

long VD_setErrMsg( inMsg ) long inMsg ; {

	long		outMsg ;

	switch( inMsg >> 16 ) {
		case EMS_FacilityCode	: outMsg = VD_chgEMSseverity( inMsg ) ;
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

} /* VD_setErrMsg */
/*----------------------------------------------------------------------------*/
static long VD_getEMSmsgKey( msg ) long msg ; {

	switch( EMS_Message( msg ) ) {
	case EMS_m_NoIntersection 	: msg = VD_gI_SfSlEltsNoIntersect ;
					  break ;	
	case EMS_m_BoolFail	  	: msg = VD_gE_BooleanFailure ;
					  break ;
	case EMS_m_IntersectClosure	: msg = VD_gE_IntxCvsNotClosed ;
					  break ;
	case EMS_m_IntersectOrient	: msg = VD_gE_IntxCvsImproperOrient ;
					  break ;
	case EMS_m_IntersClosureOrient	: msg = VD_gE_IntersOrientClosure ;
					  break ;
	case EMS_m_Intersect		: msg = VD_gE_BadIntersectionResults ;
					  break ;
	case EMS_m_NoDynamicMemory	: msg = VD_gE_NoDynMem ;
					  break ;
	case EMS_m_NoMoreLoops		: msg = VD_gE_NoValidBdriesToImpose ;
					  break ;
	case EMS_m_Fail			: msg = VD_gE_OperationFailed ;
					  break ;
	case EMS_m_InvalidArg		: msg = VD_gE_InvalidArgument ;
					  break ;
	case EMS_m_Success	  	: msg = VD_gI_EmptyMessage ;
					  break ;
	case EMS_m_Interrupt		: msg = VD_gI_ProcessingInterrupt ;
					  break ;
	case EMS_m_NoSolution		: msg = VD_gI_NoSolutionFound;
					  break ;
	case EMS_m_IntersectTrim	: msg = VD_gE_CouNoExtEle ;
					  break ;
	default				:
		if( msg & 1 ) {
			msg = VD_gI_EmptyMessage ;
		} else {
			msg = VD_gE_OperationFailed ;
		}
		break ;
	}
	return msg ;

} /* VD_getEMSmsgKey */
/*----------------------------------------------------------------------------*/
static long VD_getDImsgKey( msg ) long msg ; {

	switch( msg ) {
	case DIR_W_DIR_NOT_FOUND	: msg = VD_gE_DirNotFound	; break;
	case DIR_E_SYNTAX		: msg = VD_gE_DirSyntax		; break;
	case DIR_E_DIR_DUP		: msg = VD_gE_DupName		; break;
	case DIR_W_NAME_NOT_FOUND	: msg = VD_gE_NameNotFound	; break;
	case DIR_E_NAME_DUP	  	: msg = VD_gE_DupName		; break;
	case DIR_E_NO_NAME		: msg = VD_gE_NotNamed		; break;
	case DIR_E_INVARG		: msg = VD_gE_InvalidArgument	; break;
	default :
			msg = msg & 1
				? VD_gI_EmptyMessage
				: VD_gE_OperationFailed ;
			break ;
	}
	return msg ;

} /* VD_getDImsgKey */
/*----------------------------------------------------------------------------*/
static long VD_getUNIXmsgKey( msg ) long msg ; {

	switch( msg ) {
		case UNIX_E_ENOENT	: msg = VD_gE_ENOENT 	; break;
		case UNIX_E_ENOTDIR	: msg = VD_gE_ENOTDIR 	; break;
		case UNIX_E_EPERM	: msg = VD_gE_EPERM	; break ;
		case UNIX_E_EACCES	: msg = VD_gE_EACCES	; break;
		default			: msg = VD_gE_OperationFailed	; break;
	}
	return msg ;

} /* VD_getUNIXmsgKey */
/*----------------------------------------------------------------------------*/
long VD_getMsgKey( msg ) long msg ; {

	if( msg & 1 ) {
		msg = VD_gI_EmptyMessage ;
	} else switch( msg >> 16 ) {
		case UNIX_FACILITY_CODE : msg = VD_getUNIXmsgKey( msg ) ; break ;
		case EMS_FacilityCode   : msg = VD_getEMSmsgKey ( msg ) ; break ;
		case DIR_FACILITY_CODE  : msg = VD_getDImsgKey  ( msg ) ; break ;
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
				msg = VD_gE_OperationFailed  ; break ;
			}
	}
	return msg ;

} /* VD_getMsgKey */

#endif
/*----------------------------------------------------------------------------*/

