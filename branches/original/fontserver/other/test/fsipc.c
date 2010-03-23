/* This little program prints out information about the shared memory	*/
/* used by the Font Server daemon.					*/


#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>


#define	SEM_KEY		0x4D535346	/* "FSSM"			*/
#define	SHM_KEY		0x48535346	/* "FSSH"			*/


main ()
{
	int	GCShmId, GCSemId;

	GCShmId = shmget (SHM_KEY, 0, 0444);
	if (GCShmId != -1)
	{
		char	*GCShmAddr;

		GCShmAddr = (char *) shmat (GCShmId, NULL, 0);
		if (GCShmAddr != (char *) -1)
		{
			struct shmid_ds	shmBuf;

			printf ("Addr: 0x%08x\n", GCShmAddr);
			shmctl (GCShmId, IPC_STAT, &shmBuf);
			printf ("Size: 0x%08x\n", shmBuf.shm_segsz);
		}
		else
			printf ("Can't attach to shared memory.\n");

		shmdt (GCShmAddr);
	}
	else
		printf ("Shared memory not created.\n");

	GCSemId = semget (SEM_KEY, 1, 0666);
	if (GCSemId != -1)
	{
		int	value;

		value = semctl (GCSemId, 0, GETVAL, &value);
		printf ("Semaphore value: %d\n", value);
	}
	else
		printf ("Semaphore not created.\n");
}
