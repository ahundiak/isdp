#include <assert.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <errno.h>
#include <stdio.h>
#include "ipcl.h"

#define NOT 	!
#define SYSERR -1
#define NULL	0
#define SUPER_USER	0

static char		initialization_performed=0, id_toggle=1;
static unsigned short	real_uid, real_gid, effective_uid, effective_gid;
static p_IPCL_msgbuf	deathrow=0;
static int		msg_queue;

/*  IPCL_deathrow:	Stores in a linked list of IPCL_msgbuf structures all of
 *			the IPC structures that are known to have been
 *			allocated.  Upon exit they shall all be deleted.
 */
 
void IPCL_deathrow( msgbuf )

p_IPCL_msgbuf	msgbuf;		/* pointer to an IPCL_msgbuf describing the IPC
				 * structure to be queued for deletion
				 */
{
 p_IPCL_msgbuf	tmp_ptr;
 
 tmp_ptr = deathrow;
 deathrow = (p_IPCL_msgbuf)malloc( sizeof( IPCL_msgbuf) );
 deathrow->Next = tmp_ptr;
 deathrow->type = msgbuf->type;
 deathrow->id = msgbuf->id;
 
}


/*  IPCL_exit:	removes all of the IPC structures queued on "deathrow"
 *
 *		Upon exit from IPCL_exit the effective user and group id are set
 *		to the saved effective user and group id's
 */
 
void IPCL_exit()
{
 p_IPCL_msgbuf	tmp_ptr;
 
 assert( initialization_performed );

 if( id_toggle ) { setuid( effective_uid );  setgid( effective_gid ); }
 
 while( deathrow ) {
 
	switch( deathrow->type ) {
		case IPCL_MES:
			msgctl( deathrow->id, IPC_RMID, 0 );  break;
						
		case IPCL_SEM:
			semctl( deathrow->id, IPC_RMID, 0 );  break;
			
		case IPCL_SHM:
			shmctl( deathrow->id, IPC_RMID, 0 );  break;
	}
	
	tmp_ptr = deathrow;
	deathrow = deathrow->Next;
	free( tmp_ptr );
 }
}

/*  IPCL_init:  Creates or identifies a message queue to be used for the cleanup
 *		of all IPC structures.
 *		
 *		Saves real and effective user and group id's and sets the
 *		effective to real id's upon exit.  IPC structures will be
 *		created under the effective user and group id's	as defined when 
 *		the process was exec'd.  Any other products of the associated
 *		image will be generated with respect to the real user and group
 *		id's.
 *
 *		If flags & IPCL_NOSWITCH then the effective id's will remain
 * 		equal to that which was defined on exec.  Therefore it is the
 *		saved-effective user and group id that describes the owner of
 *		all of the generated files and IPC structures.
 *
 *		The key and protection used for the creation of the queue are
 *		IPCL_QKEY and IPCL_QPROT respectively.  They are defined in
 *		"ipcl.h".
 *
 *		IPCL_init returns the message queue id upon success or -1 for
 *		failure in which case errno will be set accordingly
 */

int	IPCL_init( qid, key, protection, flags )
int	qid;		/* Queue id.  Only used If going to identify a queue
			 * that has already been created by the called
			 * process (flags == IPC_ALLOC).  IPCL_init is called
			 * to put the message queue on death row and make the
			 * queue known to all the IPCL routines.
			 *
			 * key and protection are only used if IPCL_init is to
			 * attach to the queue (flags == IPC_CREAT) or create 
			 * the queue (IPC_CREAT | IPC_EXECL).
			 */
key_t	key;		/* if key = 0 use default key IPCL_QKEY */
int	protection;	/* if protection = 0 use default protection IPCL_QPROT */
int	flags;		/* low order nine bits:		permission
			 * remaining bits:		flags
			 *		IPC_ALLOC == already allocated by the
			 *			      same process
			 *		IPC_CREAT == create (return success if
			 *			     already exists)
			 *   IPC_EXCL | IPC_CREAT == only create if doesn't
			 *			     already exist
			 *	    IPCL_NOSWITCH == leave effective id's as
			 *			     defined by exec.
			 */
{
 IPCL_msgbuf	msg;

	if(NOT  initialization_performed ) {			/* remember initial real and effective user and group id's	*/
		if( id_toggle = NOT ( flags & IPCL_NOSWITCH ) ) {
			if( ( real_uid = getuid() ) == SUPER_USER ) {	/* if "real" user is su then don't toggle		*/
				id_toggle = 0;
			} else {
				real_gid = getgid();
				effective_uid = geteuid();
				effective_gid = getegid();
			}
		}
		initialization_performed++;
	} else {						/* allow for possibility that IPCL_init was called previously	*/
		if( id_toggle ) {
			if( effective_uid != geteuid() ) 
				if( SYSERR == setuid( effective_uid ) ) { errno = EPERM; return( SYSERR ); }
			if( effective_gid != getegid() )
				if( SYSERR == setgid( effective_gid ) ) { errno = EPERM; return( SYSERR ); }
		}
	}
	
	if( flags & IPC_CREAT )
		qid = msgget(  ( (key) ? key : IPCL_QKEY ),  ( (protection) ? protection : IPCL_QPROT ) | flags);
	
	if( (msg_queue = qid) != SYSERR ) {
		msg.Mtype = IPCL_MTYP; msg.type = IPCL_MES; msg.id = qid;
		msgsnd( msg_queue,(struct msgbuf *) &msg, IPCL_MSGSIZ, NULL );
	}
	
	if( id_toggle ) { int save_errno = errno;  setuid( real_uid );  setgid( real_gid ); errno = save_errno; }
	return( qid );
}

/*  IPCL_get:	Provides a front end for all of the IPC "get" routines (semget,
 *		msgget, shmget).  IPCL_get will ensure that the effective user
 *		and group id are equal to the saved set-user and group id (exec)
 *		before any IPC structure is created.
 *
 *		IPCL_init must be called before any attempt to invoke IPCL_get
 *		is made.
 *
 *		IPCL_get returns the structure id upon success or -1 for failure
 *		in which case errno will be set accordingly
 */
 
int IPCL_get( type, key, misc, flags )

int type;		/* What type of structure is to be created:
			 *		IPCL_MES == message queue
 			 *		IPCL_SEM == semaphore
 			 *		IPCL_SHM == shared memory segment
 			 */
key_t	key;		/* the key in which to reference the IPC structure */
int	misc;		/* for IPCL_SEM misc represents the number of semaphores
 			 * for IPCL_SHM misc represents the size of the segment	
 			 * for IPCL_MES misc is meaningless
 			 */
int	flags;		/* the flags for creation of the IPC structure	*/
{
 IPCL_msgbuf	msg;
 int qid;
 
 assert( initialization_performed );

 if( id_toggle )
	if( ( SYSERR == setuid( effective_uid ) )  ||  ( SYSERR == setgid( effective_gid ) ) ) { errno = EPERM; return( SYSERR ); }
 
 switch( type ) {
 	case	IPCL_MES:
		qid = msgget( key,  flags);  break;
		
 	case	IPCL_SEM:
		qid = semget( key, misc, flags);  break;
		
 	case	IPCL_SHM:
 		qid = shmget( key, misc, flags);  break;
 		
 	default:
 		qid = SYSERR; errno = 0;
 }
 
 if( qid != SYSERR ) {
	msg.Mtype = IPCL_MTYP;	msg.type = type;  msg.id = qid;
	msgsnd( msg_queue,(struct msgbuf *) &msg, IPCL_MSGSIZ, NULL );
 }  	

 if( id_toggle ) { int save_errno = errno; setuid( real_uid ); setgid( real_gid ); errno = save_errno; }
 return( qid );
}

/*  IPCL_ctl:	Provides a front end for all of the IPC "ctl" routines (semctl,
 *		msgctl, shmctl).  IPCL_ctl will ensure that the effective user
 *		and group id are equal to the saved set-user and group id (exec)
 *		before any IPC structure is modified.
 *
 *		IPCL_init must be called before any attempt to invoke IPCL_ctl
 *		is made.
 *
 *		IPCL_ctl returns the value as returned from the invoked "ctl"
 *		routine or -1 for failure in which case errno will be set
 *		accordingly
 */
 
int IPCL_ctl( type, id, semnum, cmd, misc )

int type;		/* What type of structure is to be modified:
			 *		IPCL_MES == message queue
 			 *		IPCL_SEM == semaphore
 			 *		IPCL_SHM == shared memory segment
 			 */
int id;			/* id of pertinent IPC structure */
int semnum;		/* for semctl only. */
int cmd;		/* control command */
int misc;		/* for IPCL_SEM misc represents ( union semnum ) 
 			 * for IPCL_SHM misc represents ( struct shmid_ds *)
 			 * for IPCL_MES misc represents ( struct msgiq_ds *)
 			 */
{
 int status;

 assert( initialization_performed );

 if( id_toggle )
	if( ( SYSERR == setuid( effective_uid ) )  ||  ( SYSERR == setgid( effective_gid ) ) ) { errno = EPERM; return( SYSERR ); }
 
 switch( type ) {
 	case	IPCL_MES:
		status = msgctl( id, cmd, (struct msqid_ds *)misc);  break;
		
 	case	IPCL_SEM:
 		status = semctl( id, semnum, cmd, misc ); break;
		
 	case	IPCL_SHM:
 		status = shmctl( id, cmd, (struct shmid_ds *)misc); break;
 		
 	default:
 		status = SYSERR; errno = 0;
 }
 
 if( id_toggle ) { int save_errno = errno; setuid( real_uid ); setgid( real_gid ); errno = save_errno; }
 return( status );
}

