#define PDM_XNS_PORT    11
#define PDM_TCP_PORT    1801

/***********************************************************************
 *                                                                     *
 *  PDM Command Request structure -                                    *
 *                                                                     *
 *  This structure is how PDM sends command requests from the          *
 *  client to the server.  It is also used to tell the server          *
 *  whether or not to expect a data buffer along with the command.     *
 *                                                                     *
 ***********************************************************************/

typedef struct PDMcmd_st
  {
	long	command;
	long	operation;
	long	entity;
	long	user_id;
	long	buffer_size;
  } *PDMcmd_ptr;

/***********************************************************************
 *                                                                     *
 *  PDM return status structure -                                      *
 *                                                                     *
 *  A structure is provided to allow multiple statuses to be returned  *
 *  to PDU.                                                            *
 *                                                                     *
 *  The buffer_size is provided to let the client software know        *
 *  that there is a return buffer expected.  If buffer_size = 0,       *
 *  then no buffer is to be returned.                                  *
 *                                                                     *
 ***********************************************************************/

typedef struct PDMsts_st
  {
	long	PDMstatus;
	long	NFMstatus;
	long	SQLstatus;
	long	MEMstatus;
	long	buffer_size;
  } *PDMsts_ptr;
