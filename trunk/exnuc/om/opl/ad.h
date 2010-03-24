#include "exsysdep.h"

#ifdef SUNOS

#include <stdio.h>
#include <sys/types.h>
#include <a.out.h>
#include <ar.h>
#ifndef	_ADFCN_H
#define _ADFCN_H

struct  adfile {
        FILE    *ioptr;			/* system I/O pointer value */
	off_t	fileSize;		/* file size from fstat	*/
        struct exec header;     	/* the file header of the opened file */
	unsigned short	archive;	/* is it an archive? 	*/
	long	offset;			/* offset into archive file */
	struct ar_hdr	arhdr;	        /* current archive header */
	/*	Memory map stuff	*/
	char	*tables;	/* Array containing sym and string tables */
	char	*mapmem;	/* Beginning of mmap'ed memory		  */
	char	*strings;	/* Pointer to string table		  */
	size_t	mapLen;		/* Length of array			  */
	unsigned int strSize;	/* Size of the string table		  */
};

/*
        provide a structure "type" definition, and the associated
        "attributes"
*/

#define ADFILE          struct adfile
#define IOPTR(x)	(x)->ioptr
#define FILESZ(x)	(x)->fileSize
#define	OFFSET(x)	(x)->offset
#define HEADER(x)	(x)->header
#define ARHDR(x)	(x)->arhdr
#define ADFSZ		sizeof(ADFILE)

/*	Memory map information 		*/
#define	STRSIZE(x)	(x)->strSize
#define MAPLEN(x)	(x)->mapLen
#define MAPMEM(x)	(x)->mapmem
#define TABLES(x)	(x)->tables
#define STRINGS(x)	(x)->strings

ADFILE	*adopen(),
      	*adaopen();

int	adclose(),
	adaclose();

#define SUCCESS 1
#define FAILURE 0

#define TEXT 0
#define DATA 1

#endif

#endif
