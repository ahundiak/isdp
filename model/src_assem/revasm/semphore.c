/*
 * This file contains a simpler and easier to understand interface to the 
 * System V semaphore system calls. There are 7 routines available to the 
 * user:
 * 
 *    id = sem_create(key, initval);  $ create with initial value or open
 *    id = sem_open(key );            $ open ( must already exist )
 *    sem_wait(id);                   $ wait = P = down by 1
 *    sem_signal(id);                 $ signal = V = up by 1
 *    sem_op(id, amount);             $ wait if (amount < 0)
 *                                    $ signal if (amount > 0)
 *    sem_close(id);                  $ close
 *    sem_rm(id);                     $ remove (delete)
 *
 *
 * We create and use a 3-member set for the reqested semaphore.
 * The first member, [0], is the actual semaphore value, and the second 
 * member, [1], is a counter used to know when all processes have finished
 * with the semaphore. The counter is initialised to a larger number,
 * decremented on every create or open and incremented on every close.
 * This way we can use the "adjust" feature provided by System V so that
 * any process that exit's without calling sem_close() is accounted for. 
 * It doesn't help us if the last process does this, but it will work if
 * any process other than the last does an exit (intentional or unintentional).
 * The third member, [2], of the semaphore set is used as a lock variable
 * to avoid any race conditions in the sem_create() and sem_close() functions.
 *
 */


#include   <sys/types.h>
#include   <sys/ipc.h>
#include   <sys/sem.h>

#include   <errno.h>
extern   int errno;

#define BIGCOUNT	10000

/*
 * Define the semaphore arrays for the semop() calls
 */

static struct sembuf op_lock[2] = {
      2, 0, 0,             /* wait for [2] (lock) to equal 0 */
      2, 1, SEM_UNDO       /* then increment [2] to 1 - this locks it */
                           /* UNDO to release the lock if processes
                              exits before explicitly unlocking */
};

static struct sembuf op_endcreate[2] = {
      1, -1, SEM_UNDO, /* decrement [1](proc counter) with undo on exit */
                       /* UNDO to adjust proc counter if process exits
                          before explicitly calling sem_close() */
      2, -1, SEM_UNDO  /* then decrement [2] (lock) back to 0 */
};

static struct sembuf op_open[1] = {
      1, -1, SEM_UNDO  /* decrement [1] (proc counter) with undo on exit */
};

static struct sembuf op_close[3] = {
      2, 0, 0,         /* wait for [2] (lock) to equal 0 */
      2, 1, SEM_UNDO,  /* then increment [2] to 1 - this locks it */
      1, 1, SEM_UNDO,  /* then increment [1] (proc counter) */
};

static struct sembuf op_unlock[1] = {
      2, -1, SEM_UNDO  /* decrement [2] (lock) back to 0 */
};

static struct sembuf op_op[1] = {
      0, 99, SEM_UNDO  /* decrement or increment [0] with undo on exit */
                       /* the 99 is set to the actual amount to add or
                          subtract (positive or negative) */
};


/*****************************************************************************
 * Create a semaphore with a specified initial value.
 * If the semaphore already exists, we dont initialise it.
 * We return the semaphore ID if all OK, else -1.
 ****************************************************************************/

int sem_create(key, initval)
key_t key;
int   initval;
{
register int    id, semval;
union    semun {
   int             val;
   struct semid_ds *buf;
   ushort          *array;
}semctl_arg;

	if(key == IPC_PRIVATE)
             return(-1);          /* not intended for private semaphores */

    	if(key == (key_t) -1)
             return(-1);          /* probaly an ftok() error by caller */

again:  if((id = semget(key, 3, 0666 | IPC_CREAT)) < 0)
             return(-1);          /* permissions problem or tables full */

/*
 * When the semaphore is created, we know that the value of all 3 members
 * is 0. Get a lock on the semaphore by waiting for [2] to equal 0, then
 * increment it.
 * 
 * There is a reace condition here. There is a possibility that between the
 * semget() above and the semop() below, another process can call our 
 * sem_close() function which can remove the semaphore if that process is
 * the last one using it. Therefore, we handle the error condition of an
 * invalid semaphore ID specially below, and if it does happen, we just go 
 * back and create it again.
 */

	if(semop(id, &op_lock[0], 2) < 0) 
	{
		if(errno == EINVAL)
			goto again;
		perror("cant lock");
		return(-1);
	}

	/* 
	 * Get the value of the process counter. If it equals 0, then no one
      	 * has initialised the semaphore yet.
	 */

	if((semval = semctl(id, 1, GETVAL, 0)) < 0)
	{
		perror("cant GETVAL");
		return(-1);
	}

	if(semval == 0)
	{
		/*
		 * We could initialise by doing a SETALL, but that would
 		 * clear the adjust value that we set when we locked the
		 * semaphore above. Instead, we'll do 2 system calls to
		 * initialise [0] and [1]
		 */

		semctl_arg.val = initval;
		if(semctl(id, 0, SETVAL, semctl_arg) < 0)
		{
			perror("cant SETVAL of [0]");
			return(-1);
		}

		semctl_arg.val = BIGCOUNT;
		if(semctl(id, 1, SETVAL, semctl_arg) < 0)
		{
			perror("cant SETVAL of [1]");
			return(-1);
		}
	}
	/*
	 * Decrement the process counter and then release the lock.
	 */
	if(semop(id, &op_endcreate[0], 2) < 0)
	{
		perror("cant endcreate");
		return(-1);
	}

	return(id);
}

/******************************************************************************
 Open a semaphore that must already exist.
 This function should be used, instead of sem_create(), if the caller knows
 that the semaphore must already exist. For ex, a client from a client-server
 pair would use this, if its the server's responsibility to create the 
 semaphore.
 Return the semaphore ID if all OK, else -1
******************************************************************************/

int sem_open(key)
key_t key;
{
register int id;

	if(key == IPC_PRIVATE)
		return(-1);

	if(key == (key_t)-1)
		return(-1);

	if((id = semget(key, 3, 0)) < 0)
		return(-1);	/* doesnot exist, or tables full */

	/*
	 * Decrement the process counter. We dont need a lock to do this
	 */
	if( semop(id, &op_open[0], 1) < 0)
	{
		perror("sem_open:cant open"); 
		return(-1);
	}

	return(id);
}

/******************************************************************************
 Remove a semaphore.
 This function is intended to be called by a server, for ex, when it is being
 shutdown, as we do an IPC_RMID on the semaphore, regardless whether other
 processes may be using it or not.
 Most other processes should use sem_close() below
******************************************************************************/

sem_rm(id)
int    id;
{
	if(semctl(id, 0, IPC_RMID, 0) < 0)
	{
		perror("cant remove id");
		return;
	}
}

/******************************************************************************
 Close a semaphore.
 Unlike the remove function, this function is for a process to call before it
 exits, when it is done with the semaphore. We "decrement"  the counter of
 processes using the semaphore, and if this was the last one, remove it
******************************************************************************/

sem_close(id)
int    id;
{
register int semval;

	/*
	 * Get a lock on the semaphore and then increment [1] - the
	 * process counter
	 */
	if( semop(id, &op_close[0], 3) < 0)
	{
		perror("cant semop");
		return;
	}

	/*
	 * Now that we have a lock, read the value of the process
	 * counter to see if this is the last reference to the semaphore
	 */
	if((semval = semctl(id, 1, GETVAL, 0)) < 0) 
	{
		perror("cant GETVAL");
		return;
	}
	
	if(semval > BIGCOUNT)
	{
		perror("sem[1] > BIGCOUNT");
		return(-1);
	}
	else if(semval == BIGCOUNT)
		sem_rm(id);
	else
		if(semop(id, &op_unlock[0], 1) < 0)
		{
			perror("cant unlock");
			return(-1);
		}
}

/******************************************************************************
 Wait until a semaphore's value is greater than 0, then decrement it by 1
 and return. DOWN operation.
 *****************************************************************************/

sem_wait(id)
int      id;
{
	sem_op(id, -1);
}

/******************************************************************************
 Increment a semaphore by 1.
 UP operation.
 *****************************************************************************/

sem_signal(id)
int      id;
{
	sem_op(id, 1);
}
	 
/******************************************************************************
 General semaphore operation. Increment or decrement by a user-specified amount
 (positive or negative), cant be zero.
 *****************************************************************************/

sem_op(id, value)
int      id;
int      value;
{
	op_op[0].sem_op = value;

	if(value == 0)
	{
		perror("cant have value == 0");
		return;
	}

	if(semop(id, &op_op[0], 1) < 0)
	{
		perror("semop error");
		return;
	}
}
 

