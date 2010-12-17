/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							lu62ibm.h
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
#pragma linkage(XCIDRM, OS)
#pragma linkage(XCWOE, OS)
#pragma linkage(CMACCP, OS)
#pragma linkage(CMRCV, OS)
#pragma linkage(CMSEND, OS)
#pragma linkage(CMDEAL, OS)

/* Conversation type */
#define CM_BASIC_CONVERSATION			0
#define CM_MAPPED_CONVERSATION			1

/* Data received */
#define CM_NO_DATA_RECEIVED				0
#define CM_DATA_RECEIVED				1
#define CM_COMPLETE_DATA_RECEIVED 		2
#define CM_INCOMPLETE_DATA_RECEIVED		3

/* Deallocate type */
#define CM_DEALLOCATE_SYNC_LEVEL		0
#define CM_DEALLOCATE_FLUSH				1
#define CM_DEALLOCATE_CONFIRM			2
#define CM_DEALLOCATE_ABEND				3

/* Error direction */
#define CM_RECEIVE_ERROR				0
#define CM_SEND_ERROR					1

/* Fill */
#define CM_FILL_LL						0
#define CM_FILL_BUFFER					1

/* Prepare to receive type */
#define CM_PREP_TO_RECEIVE_SYNC_LEVEL	0
#define CM_PREP_TO_RECEIVE_FLUSH		1
#define CM_PREP_TO_RECEIVE_CONFIRM		2

/* Receive type */
#define CM_RECEIVE_AND_WAIT				0
#define CM_RECEIVE_IMMEDIATE			1

/* Request to send received */
#define CM_REQ_TO_SEND_NOT_RECEIVED		0
#define CM_REQ_TO_SEND_RECEIVED			1

/* Return code */
#define CM_OK							0
#define CM_ALLOCATE_FAILURE_NO_RETRY	1
#define CM_ALLOCATE_FAILURE_RETRY		2
#define CM_CONVERSATION_TYPE_MISMATCH	3
#define CM_SECURITY_NOT_VALID			6
#define CM_SYNC_LVL_NOT_SUPPORTED_PGM	8
#define CM_TPN_NOT_RECOGNIZED			9
#define CM_TP_NOT_AVAILABLE_NO_RETRY	10
#define CM_TP_NOT_AVAILABLE_RETRY		11
#define CM_DEALLOCATED_ABEND			17
#define CM_DEALLOCATED_NORMAL			18
#define CM_PARAMATER_ERROR				19
#define CM_PRODUCT_SPECIFIC_ERROR		20
#define CM_PROGRAM_ERROR_NO_TRUNC		21
#define CM_PROGRAM_ERROR_PURGING		22
#define CM_PROGRAM_ERROR_TRUNC			23
#define CM_PROGRAM_PARAMETER_CHECK		24
#define CM_PROGRAM_STATE_CHECK			25
#define CM_RESOURCE_FAILURE_NO_RETRY	26
#define CM_RESOURCE_FAILURE_RETRY		27
#define CM_UNSUCCESSFUL					28

/* Return control */
#define CM_WHEN_SESSION_ALLOCATED		0
#define CM_IMMEDIATE					1

/* Send type */
#define CM_BUFFER_DATA					0
#define CM_SEND_AND_FLUSH				1
#define CM_SEND_AND_CONFIRM				2
#define CM_SEND_AND_PREP_TO_RECEIVE		3
#define CM_SEND_AND_DEALLOCATE			4

/* Status received */
#define CM_NO_STATUS_RECEIVED			0
#define CM_SEND_RECEIVED				1
#define CM_CONFIRM_RECEIVED				2
#define CM_CONFIRM_SEND_RECEIVED		3
#define CM_CONFIRM_DEALLOC_RECEIVED		4

/* Sync level */
#define CM_NONE							0
#define CM_CONFIRM						1

/* Conversation security type */
#define XC_SECURITY_NONE				0
#define XC_SECURITY_SAME				1
#define XC_SECURITY_PROGRAM				2

/* Event type */
#define XC_ALLOCATION_REQUEST			0
#define XC_INFORMATION_INPUT			1
#define XC_RESOURCE_REVOKED				2
#define XC_CONSOLE_INPUT				3

/* resource manager type */
#define XC_PRIVATE						0
#define XC_LOCAL						1
#define XC_GLOBAL						2

/* security level flag */
#define XC_REJECT_SECURITY_NONE			0
#define XC_ACCEPT_SECURITY_NONE			1

/* service mode */
#define XC_SINGLE						0
#define XC_SEQUENTIAL					1
#define XC_MULITIPLE					2


extern XCIDRM(char * resource_id, int *resource_manager_type,
			  int *service_mode, int *security_level_flag,
			  int *return_code);
extern XCWOE(char *resource_id, char *conversation_id,
			 int *event_type, int *data_length,
			 char *console_input_buffer, int *return_code);
extern CMACCP(char *conversation_id, int *return_code);
extern CMRCV(char *conversation_id, char *buffer, int *req_len,
			 int *data_rec, int *rec_len, int *status_rec,
			 int *req_to_send_rec, int *return_code);
extern CMSEND(char *conversation_id, char *buffer, int *send_len,
			  int *req_to_send_rec, int *return_code);
extern CMDEAL(char *conversation_id, int *return_code);
