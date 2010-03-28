/* $RCSfile: fsgncch.h $$Revision: 1.1 $$Date: 1990/07/31 10:54:14 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _GENCACHE
#define _GENCACHE	0


/** Generic Cache routines **/
extern	int	_GCEnter ();
extern	void	_GCExit ();
extern	void	_GCLockSem ();
extern	void	_GCUnlockSem ();
extern	void	_GCSetMemory ();
extern	int	_GCSharedMemory ();
extern	int	_GCSharedAddr ();
extern	int	_GCShInited ();
extern	void	_GCSetSharedValue ();
extern	long	_GCGetSharedValue ();
extern	void	_GCSetPurgeFunc ();
extern	char	*_GCAlloc ();
extern	void	_GCRelease ();
extern	char	*_GCRealloc ();
extern	void	_GCLock ();
extern	void	_GCUnlock ();
extern	int	_GCLocked ();
extern	void	_GCSetPurge ();
extern	int	_GCGetPurge ();
extern	void	_GCPurge ();
extern  void    _GCShExit (void);
extern  Int     _GCShEnter (int ownerFlag);


#endif
