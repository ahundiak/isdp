#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include "NETerrordef.h"


/* These defines are required in this file only */
/* Maximum file descriptors on which connection is pending 
   shared memory key for use by NFM */

/* Change MAX_FDS to 255 and use #256 to save LOCK */

#define 	MAX_FDS		255
#define		SHMKEY		1500

/* static structures and variables used in this file */

typedef struct SHM {
                        long pid ;
                        int fd ;
                   } SHM ;

static  SHM	*shm_ptr ;
static int shmid ;



int NETattach_shm()
{
	
	if((shmid = shmget (SHMKEY, (MAX_FDS+1) * sizeof (SHM) , 0666 | IPC_CREAT)) < 0)
		return(NET_E_GET_SHM);
	if((shm_ptr = (SHM *)shmat(shmid , (char *)0 , 0)) == (SHM *)-1)
		return(NET_E_ATTACH_SHM) ;	
	return(NET_S_SHM_SUCCESS);
}

int NETinsert_shm(pid , fd)
	long pid;
	int fd ;
{
	SHM *d_ptr ;
	int i = 0;
	d_ptr = shm_ptr ;	
	if(shm_ptr == (SHM * )-1)
		return(NET_E_SHM_OVERFLOW);
	i=0;
	while(i< MAX_FDS && (d_ptr + i) ->pid !=0 ) i++ ;
	if(i == MAX_FDS) return(NET_E_SHM_OVERFLOW) ;
	(d_ptr+i)->pid = pid ;
	(d_ptr+i)-> fd = fd ;
	return(NET_S_SHM_SUCCESS);
}
int NETget_fd_from_shm(pid , fd)
	long pid;
	int *fd ;
{
	SHM *d_ptr ;
	int i = 0;
	d_ptr = shm_ptr ;	
	if(shm_ptr == (SHM * )-1)
		return(NET_E_SHM_OVERFLOW);
	i=0;
	while(i< MAX_FDS && (d_ptr + i) ->pid !=pid ) i++ ;
	if(i == MAX_FDS) return(NET_E_SHM_OVERFLOW) ;
	*fd = (d_ptr+i)-> fd ;
	(d_ptr+i)->pid = 0 ;
	return(NET_S_SHM_SUCCESS);
}
	
int NETinit_shm()
{
	SHM *d_ptr ;
	int i = 0;
	if(shm_ptr == (SHM * )-1)
		return(NET_E_SHM_OVERFLOW);
	d_ptr = shm_ptr ;	
	i=0;
	while(i< MAX_FDS )
	{
		d_ptr->pid = 0;
		d_ptr++;
		i++;
	}
	NETset_lock(0);
	return(NET_S_SHM_SUCCESS);
}

/* This function retrieves the value of the lock stored in MAX_FDS+1 
   location */

int NETcheck_lock(lock)
	int *lock;
{
	SHM *d_ptr;
	if(shm_ptr == (SHM * )-1)
		return(NET_E_SHM_OVERFLOW);
	d_ptr=shm_ptr+MAX_FDS;

	*lock = d_ptr->fd;
	return(NET_S_SUCCESS);
}
/* This function sets the value of the lock stored in MAX_FDS+1 
   location */
int NETset_lock(lock)
	int lock;
{
	SHM *d_ptr;
	if(shm_ptr == (SHM * )-1)
		return(NET_E_SHM_OVERFLOW);
	d_ptr=shm_ptr+MAX_FDS;

	d_ptr->fd=lock;
	return(NET_S_SUCCESS);
}
