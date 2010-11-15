/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							risasync.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef RISASYNC_H
#define RISASYNC_H
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/

/*	modes for execute_mode flag */

#define START_MODE		0x01
#define FINISH_MODE		0x02
#define BLOCKING_MODE	0x04

#define SYNC_MODE			(START_MODE|FINISH_MODE|BLOCKING_MODE)
#define ASYNC_START_MODE	(START_MODE)
#define ASYNC_TEST_MODE		(FINISH_MODE)
#define ASYNC_WAIT_MODE		(FINISH_MODE|BLOCKING_MODE)

/* macros for testing execute_mode flag */

#define IN_START_MODE(mode) \
((mode) & START_MODE)

#define IN_START_MODE_ONLY(mode) \
(((mode) & START_MODE) && !((mode) & FINISH_MODE))

#define IN_START_OR_FINISH_MODE(mode) \
(1)

#define IN_FINISH_MODE(mode) \
((mode) & FINISH_MODE)

#define IN_FINISH_MODE_ONLY(mode) \
(((mode) & FINISH_MODE) && !((mode) & START_MODE))

/* States for statements */
#define SELECT_INTO_STATE		1
#define EXECUTE_IMM_STATE		2
#define EXECUTE_STATE			3
#define FETCH_STATE				4
#define CLOSE_STATE				5
#define CLEAR_STATE				6
#define COMPLETE_ERROR_STATE	7
#define COMPLETE_EOD_STATE		8
#define COMPLETE_SUCCESS_STATE	9

/* Macros for testing states */
#define IN_ASYNC_STATE(state) ((state) != 0)

#define IN_INCOMPLETE_STATE(state) \
((state) == SELECT_INTO_STATE || \
(state) == EXECUTE_IMM_STATE || \
(state) == EXECUTE_STATE || \
(state) == FETCH_STATE || \
(state) == CLOSE_STATE || \
(state) == CLEAR_STATE)

#define IN_COMPLETE_STATE(state) \
((state) == COMPLETE_ERROR_STATE || \
(state) == COMPLETE_EOD_STATE || \
(state) == COMPLETE_SUCCESS_STATE)

/*
**	TYPES
*/

/*
**	VARIABLES
*/

#endif
