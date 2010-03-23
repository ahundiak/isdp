/* This program kills the Font Server ipc.  Use "killfs" to kill the	*/
/* daemon as well as the ipc.						*/


#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/msg.h>


main ()
{
	static key_t	shmkey = 0x48535346;
	static key_t	semkey = 0x4D535346;
	static key_t	msgkey0 = 0x48515346;
	static key_t	msgkey1 = 0x49515346;
	int		shmid, semid, msqid;

	shmid = shmget (shmkey, 0, 0666);
	if (shmid == -1)
	{
		printf ("Shm not created!\n");
	}
	else
	{
		if (shmctl (shmid, IPC_RMID, 0) != 0)
			printf ("Can't kill the shm!\n");
	}

	semid = semget (semkey, 1, 0666);
	if (semid == -1)
	{
		printf ("Sem not created!\n");
	}
	else
	{
		if (semctl (semid, IPC_RMID, 0, 0) != 0)
			printf ("Can't kill the sem!\n");
	}

	msqid = msgget (msgkey0, 0666);
	if (msqid == -1)
	{
		printf ("Msg queue 0 not created!\n");
	}
	else
	{
		if (msgctl (msqid, IPC_RMID, 0) != 0)
			printf ("Can't kill msg queue 0!\n");
	}

	msqid = msgget (msgkey1, 0666);
	if (msqid == -1)
	{
		printf ("Msg queue 1 not created!\n");
	}
	else
	{
		if (msgctl (msqid, IPC_RMID, 0) != 0)
			printf ("Can't kill msg queue 1!\n");
	}
}
