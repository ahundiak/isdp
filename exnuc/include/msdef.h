#ifndef msdef_include
#define msdef_include

#define		MSSUCC		0x08008009	/* successful completion */
#define		MSFAIL		0x08008012	/* error		 */
#define		MSINARG		0x0800801a	/* invalid argument	 */

/*----MS_MAX_MSG_LENGTH must be the same as UMS_MAX_BUFLEN from UMS.h
      we cannot not use the real #define because customers do not get UMS.h*/

#define		MS_MAX_MSG_LENGTH	512    /* see above comment */
#define         MS_NO_MSG       -1

/*
	for use in the ex$message macro -- argument justification
    justification is form justification
*/

#define CENTER_JUS 2
#define RIGHT_JUS  1
#define LEFT_JUS   0

/*
	for use in the ex$message macro -- argument field
*/

#define MESSAGE_FIELD 1
#define ERROR_FIELD   2
#define PROMPT_FIELD  3
#define KEYIN_FIELD   4

/*
	return codes used by the message system
*/

#define MS_E_MSGTABLEMEM	10
#define MS_E_CANNOTREOPEN	20
#define MS_I_NOMSGINFILE	30

/*
	For use with the ms$onoff macro 
*/

#define MS_ON			 1
#define MS_OFF			 2
#define MS_SET			 3
#define MS_NO_STATE		-1

#define MS_CHAR_DELIMITER	 1
#define MS_BLANK                 1
#define MS_MAX_TABLE             200

/*
	for use ms$function macro
*/


#define MS_S_STATUS		0
#define MS_E_STATUS		1
#define MS_I_STATUS		2
#define MS_F_STATUS		3
#define MS_P_STATUS		4
#define MS_M_STATUS		5
#define MS_BOX_STATUS		6

#define MS_NO_FUNCTIONS		7

#define MS_ALL_STATUS		21
#define MS_SYSTEM_STATUS	20

#define MS_IMMEDIATE             0
#define MS_SYSTEM_TIME          -1
#define MS_SLEEP_TIME            5
#endif
