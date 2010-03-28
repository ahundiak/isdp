/* AAcomm.h
 *
 * comunications area definitions
 */
#ifndef AAcomm_dot_h
#define AAcomm_dot_h 1

#define CLIPPER_PROCESS	0
#define ASAPII_PROCESS	1
#define CONTINUATION	-1

#define ASAPII_READY		(ASAPII_comm_int[0])
#define CLIPPER_WANTS_REQUEST	(ASAPII_comm_int[1])
#define ASAPII_WANTS_REQUEST	(ASAPII_comm_int[2])
#define FAVORED_REQUEST		(ASAPII_comm_int[3])
#define CLIPPER_WANTS_ANSWER	(ASAPII_comm_int[4])
#define ASAPII_WANTS_ANSWER	(ASAPII_comm_int[5])
#define FAVORED_ANSWER		(ASAPII_comm_int[6])
#define REQUEST_BUFFER_COUNT	(ASAPII_comm_int[7])
#define REQUEST_BUFFER_METER	(ASAPII_comm_int[8])
#define REQUEST_BUFFER_SIZE	(ASAPII_comm_int[9])
#define ANSWER_BUFFER_COUNT	(ASAPII_comm_int[10])
#define ANSWER_BUFFER_METER	(ASAPII_comm_int[11])
#define ANSWER_BUFFER_SIZE	(ASAPII_comm_int[12])

#define REQUEST_HEAD	(ASAPII_comm_ptr[0])
#define REQUEST_TAIL	(ASAPII_comm_ptr[1])
#define REQUEST_BEGIN	(ASAPII_comm_ptr[2])
#define REQUEST_END	(ASAPII_comm_ptr[3])
#define ANSWER_HEAD	(ASAPII_comm_ptr[4])
#define ANSWER_TAIL	(ASAPII_comm_ptr[5])
#define ANSWER_BEGIN	(ASAPII_comm_ptr[6])
#define ANSWER_END	(ASAPII_comm_ptr[7])

#endif
