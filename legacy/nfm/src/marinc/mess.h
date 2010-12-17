/* UNIXOS is no more defined. Changed UNIXOS to OS_UNIX.
   This file was mess.dat. Moved it to mess.h
                              ------ Jujare 29, Dec 95 */
#if defined(UNIXOS) || defined(WIN)
char message[]="AUTODIRECT Version 3.21  Serial 1111  Copyright (C) 1990--1992 Stephen M. Richards";
#else
char message[]="AUTODIRECT Version 3.21  Copyright (C) 1990--1992 Stephen M. Richards";
#endif
