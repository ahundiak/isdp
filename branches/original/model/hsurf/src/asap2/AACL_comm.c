
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/* AACL_comm.c */

#define ASAPII_GLOBALS 1

#include <stdio.h>
#include <AAdef.h>
#include <AAcomm.h>

#define FALSE	0
#define TRUE	1

/*--- interprocessor communications area -------------------------------------*/

extern volatile int   ASAPII_comm_int[];
extern volatile char *ASAPII_comm_ptr[];

#if STATS
/*--- statistics counters ---*/

extern int request_high_bytes, answer_high_bytes;
extern int request_high_num, answer_high_num;
#endif


/*--- extern functions ---*/

extern void enter_critical (int, volatile int*, volatile int*, volatile int*);
extern void exit_critical (int, volatile int*, volatile int*);


/*--- AACL_get_answer_ptr ----------------------------------------------------*/

int AACL_get_answer_ptr
 (int	answer_size,
  int	answer_type,
  char	**answer_addr
 )

/*
DESCRIPTION
	Allocates space in answer buffer for a packet of size "answer_size"
	plus overhead (2 ints and double boundary padding, if any).
	Puts answer_size and answer_type into buffer and returns pointer
	to first byte after header (double aligned).

	NOTE:	returned answer_addr will be NULL if there is currently
		not enough space in the buffer.

	Function value is:
		TRUE if answer is small enough to fit in buffer,
		FALSE if answer can never fit into buffer.
*/
{
  char	*buf_ptr = NULL;

  /* round up to double boundary */
  answer_size = on_boundary_of (answer_size, double) + 2 * sizeof (int);

  if (answer_size <= ANSWER_BUFFER_SIZE)
  {
    enter_critical (ASAPII_PROCESS, &ASAPII_WANTS_ANSWER,
		    &CLIPPER_WANTS_ANSWER, &FAVORED_ANSWER);

    if (ANSWER_BUFFER_COUNT == 0)
      buf_ptr = ANSWER_HEAD = ANSWER_TAIL = ANSWER_BEGIN;
    else if (ANSWER_HEAD > ANSWER_TAIL)
    {
      if (ANSWER_HEAD - ANSWER_TAIL >= answer_size)
	buf_ptr = ANSWER_TAIL;
    }
    else if (ANSWER_HEAD < ANSWER_TAIL)
    {
      if (ANSWER_END - ANSWER_TAIL >= answer_size)
	buf_ptr = ANSWER_TAIL;
      else
      {
	if (ANSWER_HEAD - ANSWER_BEGIN >= answer_size)
	  buf_ptr = ANSWER_BEGIN;
	if (ANSWER_TAIL != ANSWER_END)
	  *(int *) ANSWER_TAIL = CONTINUATION;
	ANSWER_TAIL = ANSWER_BEGIN;
      }
    }
    /* else ANSWER_HEAD == ANSWER_TAIL
     *
     * Careful!  This condition could occur for two different reasons:
     *   1) the tail has caught up to the head => buffer is full.
     *   2) the head has caught up with the tail => buffer is empty.
     * If the buffer is completely empty, you can reset head and tail
     * to the the beginning of the buffer (handled above at count==0).
     */

    exit_critical (ASAPII_PROCESS, &ASAPII_WANTS_ANSWER, &FAVORED_ANSWER);

    if (buf_ptr)
    {
      *(int *) buf_ptr = answer_size;
      buf_ptr += sizeof (int);
      *(int *) buf_ptr = answer_type;
      buf_ptr += sizeof (int);
    }
    *answer_addr = buf_ptr;
    return TRUE;
  }
  else
    return FALSE;

} /* AACL_get_answer_ptr */


/*--- AACL_answer_complete ---------------------------------------------------*/

AACL_answer_complete (void)

/*
DESCRIPTION
	Completes answer by moving buffer pointer in communications area
	which allows Clipper to see the packet.  Also increments buffer count.
	Sets buffer meter to indicate how full the answer buffer is
	(used by load leveling functions on Clipper).
*/
{
#if METERING || STATS
  int meter;
#endif

  enter_critical (ASAPII_PROCESS, &ASAPII_WANTS_ANSWER,
		  &CLIPPER_WANTS_ANSWER, &FAVORED_ANSWER);

  ANSWER_TAIL += *(int *) ANSWER_TAIL;
  ++ANSWER_BUFFER_COUNT;

#if METERING || STATS
  if (ANSWER_HEAD <= ANSWER_TAIL)
    meter = ANSWER_TAIL - ANSWER_HEAD;
  else
    meter = ANSWER_BUFFER_SIZE - (ANSWER_HEAD - ANSWER_TAIL);
#endif
#if METERING
  ANSWER_BUFFER_METER = meter >> 11; /* 10 bit result */
#endif

#if STATS
  if (meter > answer_high_bytes)
    answer_high_bytes = meter;
  if (ANSWER_BUFFER_COUNT > answer_high_num)
    answer_high_num = ANSWER_BUFFER_COUNT;
#endif

  exit_critical (ASAPII_PROCESS, &ASAPII_WANTS_ANSWER, &FAVORED_ANSWER);

} /* AACL_answer_complete */


/*--- AACL_get_request_ptr ---------------------------------------------------*/

int AACL_get_request_ptr
 (int	*request_type,
  char	**request_ptr
 )

/*
DESCRIPTION
	Returns type of next request in buffer and pointer to request data.
	Function value is FALSE if there is no request from Clipper.
	else TRUE.
*/
{
  char	*tmp;

  if (REQUEST_BUFFER_COUNT == 0)
    return FALSE;

  enter_critical (ASAPII_PROCESS, &ASAPII_WANTS_REQUEST,
		  &CLIPPER_WANTS_REQUEST, &FAVORED_REQUEST);

  if (REQUEST_HEAD == REQUEST_END)
    REQUEST_HEAD = REQUEST_BEGIN;
  else if (*(int *) REQUEST_HEAD == CONTINUATION)
    REQUEST_HEAD = REQUEST_BEGIN;
  tmp = REQUEST_HEAD;

  exit_critical (ASAPII_PROCESS, &ASAPII_WANTS_REQUEST, &FAVORED_REQUEST);

  tmp += sizeof (int);
  *request_type = *(int *) tmp;
  tmp += sizeof (int);
  *request_ptr = tmp;
  return TRUE;

}  /* AACL_get_request_ptr */


/*--- AACL_request_complete --------------------------------------------------*/

void AACL_request_complete (void)

/*
DESCRIPTION
	Completes request processing by moving communications area pointer
	and decrementing request buffer count.  Pointer is set to next
	request in buffer by using size in header (hidden from outside world).
	Sets request buffer meter to indicate how full request buffer is.
*/
{
#if METERING || STATS
  int meter;
#endif

  enter_critical (ASAPII_PROCESS, &ASAPII_WANTS_REQUEST,
		  &CLIPPER_WANTS_REQUEST, &FAVORED_REQUEST);

#if METERING || STATS
  if (REQUEST_HEAD <= REQUEST_TAIL)
    meter = REQUEST_TAIL - REQUEST_HEAD;
  else
    meter = REQUEST_BUFFER_SIZE - (REQUEST_HEAD - REQUEST_TAIL);
#endif
#if METERING
  REQUEST_BUFFER_METER = meter >> 9; /* 10 bit result */
#endif

#if STATS
  if (meter > request_high_bytes)
    request_high_bytes = meter;
  if (REQUEST_BUFFER_COUNT > request_high_num)
    request_high_num = REQUEST_BUFFER_COUNT;
#endif

  REQUEST_HEAD += *(int *) REQUEST_HEAD;
  --REQUEST_BUFFER_COUNT;

  exit_critical (ASAPII_PROCESS, &ASAPII_WANTS_REQUEST, &FAVORED_REQUEST);

} /* AACL_request_complete */
