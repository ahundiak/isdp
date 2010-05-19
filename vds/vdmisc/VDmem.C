/* $Id: VDmem.C,v 1.2 2001/01/22 17:46:06 hans Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdmisc / VDmem.C
 *
 * Description:
 *	Memory allocation and checking routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDmem.C,v $
 *      Revision 1.2  2001/01/22 17:46:06  hans
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.10  1996/05/06  22:54:16  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by tlbriggs for vds.240
 *
 * Revision 1.9  1996/05/06  16:26:50  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by tlbriggs for vds.240
 *
 * Revision 1.8  1996/05/03  15:30:28  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by tlbriggs for vds.240
 *
 * Revision 1.7  1996/04/26  02:04:18  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by v240_int for vds.240
 *
 * Revision 1.6  1996/04/18  23:12:14  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by v240_int for vds.240
 *
 * Revision 1.5  1995/08/23  21:48:56  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/08/23  20:37:42  pinnacle
 * Replaced: vdmisc for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/18  18:51:08  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by rmanem for vds.240
 *
 * Revision 1.2  1995/08/17  18:42:26  pinnacle
 * Replaced: vdmisc/VDmem.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/08/16  23:39:56  pinnacle
 * Created: vdmisc/VDmem.C by tlbriggs for vds.240
 *
 * History:
 *	08/15/95	tlb	created
 *	08/17/95	tlb	Added VD_memChk, fix bug with VD_malloc
 *	08/18/95	rmanem	Fixed bug in VD_free
 *	08/22/95	tlb	Added VD_realloc, VD_calloc, 
 *				Improve reporting formats
 *	08/23/95	tlb	Remove extra argument to VD_free
 *	04/10/96	tlb	Remove calls to UI_status - used in VDSloaddata
 *				Change printf to fprintf on VD_memFile
 *				Add VD_memFStatus
 *	04/25/96	tlb	Add fflush to all prints
 *				Write all errors to both stderr and log file
 *	05/03/96	tlb	Change realloc to leave one extra block -
 *					memory scratch after block
 *	05/06/96	tlb	Fix Restart, add initialization of statics
 *	05/06/96	tlb	Fix realloc
 *
 *************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include "VDmem.h"
#include "exproto.h"

int	VD_memChk;		/* set to enable VDS allocation and free */
int	VD_memTrace;		/* set to trace VDS allocation and free */

FILE *	VD_memFile = stdout;	/* file to write checking/trace info */

#define	NAME_LEN	15

typedef struct {
	char*	ptr;			/* address of ptr allocated */
	char	type;			/* type : U, M, R, C */
	short	line;			/* line where allocated */
	char	file[NAME_LEN];		/* file name where allocated */
	} VD_memList_t;

static struct {
	int		prevTot ;	/* previous number of pointers */
	int		num ;		/* number of VDS allocations */
	int		blk ;		/* number of blocks allocated*/
	VD_memList_t	*list ;		/* list of VDS allocations */
	} VD_memPtr =  { 0, 0, 0, NULL };

/*
 * block allocation size
 *	allocate list in blocks of this size
 */
#define	BLK_SIZE	100


/* Print formats */
#define FAIL(m,l,f)							\
    	fprintf(stderr,"Error: Memory %s failed at line %d of file %s\n", \
							m , l, f );	\
   	if (VD_memFile != stdout)					\
		fprintf (VD_memFile, 					\
			"Error: Memory %s failed at line %d of file %s\n",\
							m , l, f );	\
   	fflush(stdout); fflush(stderr); fflush(VD_memFile);

#define	ZERO(m,l,f)							\
   	fprintf (stderr, "Error: %s of 0 bytes at line %d of file %s\n", \
							m , l , f );	\
   	if (VD_memFile != stdout)					\
    		fprintf (stderr,"Error: %s of 0 bytes at line %d of file %s\n",\
							m , l , f );	\
   	fflush(stdout); fflush(stderr); fflush(VD_memFile);

#define TRACE_ALLOC(m, p, s, f, l)					\
   	fprintf (VD_memFile, "\t\t    0x%x = %s (%d)\t at %s(%d)\n", 	\
							p, m , s , f , l ); \
   	fflush(stderr); fflush(VD_memFile);

/*====================================================================*
 *  Internal functions
 *====================================================================*/
/*--------------------------------------------------------------------*/
static int
VD_memInitList ( )
{
	char	*ptr;

	/* allocate list if doesn't exist
	 *	can't use _MALLOC - will call self
	 */
	if (!VD_memPtr.list) {
		VD_memPtr.list = (VD_memList_t *)
				malloc (BLK_SIZE * sizeof(VD_memList_t));
		if (!VD_memPtr.list) {
		   	fprintf (stderr, 
			    	"Error: Initial memory allocation failed %s\n",
						"in VD_malloc debugging");
			fflush(stderr);
			if (VD_memFile != stdout) {
		   		fprintf (VD_memFile, 
				"Error: Initial memory allocation failed %s\n",
						"in VD_malloc debugging");
				fflush(VD_memFile);
				}
			return FALSE;
			}
		else {
			/* initialize block varaibles */
			VD_memPtr.blk = 1;
			VD_memPtr.num = 0;
			if (BSdbglev == 20)
				VD_memPtr.prevTot = BSlist_al.number ;
			}
		}

	/* realloc list if full */
	if (VD_memPtr.num >= VD_memPtr.blk * BLK_SIZE - 1) {
		VD_memPtr.blk++;
		ptr = (char *) (realloc (VD_memPtr.list,
			      VD_memPtr.blk * BLK_SIZE *sizeof(VD_memList_t)));
		if (ptr) 
			VD_memPtr.list = (VD_memList_t *)ptr;
		else {
		   	fprintf (stderr,
				    "Error: Memory reallocation failed %s\n",
						"in VD_malloc debugging");
			fflush(stderr);
			if (VD_memFile != stdout) {
		   		fprintf (VD_memFile,
				       "Error: Memory reallocation failed %s\n",
						"in VD_malloc debugging");
				fflush(VD_memFile);
				}
			VD_memPtr.blk--;
			return FALSE;
			}
		}
	return TRUE;
}

/*--------------------------------------------------------------------*/
static void
VD_memUpdateList (int	index,
		char	*ptr,
		char	type,
		int	line,
		char 	* file,
		int	is_append)		/* appending to list */
{
	if (!VD_memInitList ())
		return ;

	VD_memPtr.list[index].ptr = ptr;
	VD_memPtr.list[index].type = type;
	VD_memPtr.list[index].line = line;
	strncpy (VD_memPtr.list[index].file, file, NAME_LEN-1);
	VD_memPtr.list[index].file[NAME_LEN-1] = '\0';

	if (is_append)
		VD_memPtr.num++;
}

/*====================================================================*
 *  External functions
 *====================================================================*/
/* check whether VDS memory checking on
 *	returns type of checking
 */
int
VD_memIsOn()
{
	if (BSdbglev == 20)	return (2);
	else if (VD_memChk)	return (1);
	else			return (0);
}

/*--------------------------------------------------------------------*/
/* Turn VDS memory checking on
 *	If BS memory checking is active - VDS checking is also
 *	returns type of checking
 */
int
VD_memOn()
{
	VD_memChk = 1; 
	if (BSdbglev == 20)	return (2);
	else			return (1);
}

/*--------------------------------------------------------------------*/
/* Turn VDS memory checking off
 *	Cannot be turned off if BS memory checking is active
 *	returns success or failure
 */
int
VD_memOff()
{
	VD_memChk = 0; 
	if (BSdbglev == 20)	return (0);
	else 			return (1);
}

/*--------------------------------------------------------------------*/
/* Open memory debug file
 */
int
VD_memOpenFile (char *name)
{
	FILE	*outfile;
	int	status = TRUE;

	/* Close file if not stdout */
	VD_memCloseFile();
	
	/* Open file if not 'stdout' */
	if (!strcmp (name, "stdout"))
		outfile = stdout;
	else
		status = (( outfile = fopen (name, "a")) != NULL);
	
	if (status) 
		VD_memFile = outfile;
	else {
		fprintf (stderr, "Cannot open VDS memory log file: %s\n",
						name);
		fflush(stderr);
 		}

	return status;
}
/*--------------------------------------------------------------------*/
/* Close memory debug file
 *	Reset to stdout
 */
int
VD_memCloseFile ()
{
	/* Close file if not stdout */
	if (VD_memFile != stdout) 
		fclose(VD_memFile);
	VD_memFile = stdout;
	return TRUE;
}
/*--------------------------------------------------------------------*/
void
VD_memPrintHeader (char *header)
{
	fprintf(VD_memFile, "\n%s\n", header);
}
/*--------------------------------------------------------------------*/
/* Reset VDS free pointer list
 */
void
VD_memReset()
{
	if (VD_memPtr.list) {
		free (VD_memPtr.list);
		VD_memPtr.list = NULL;
		}
	VD_memPtr.blk = 0;
        VD_memPtr.num = 0;
	if (BSdbglev == 20)
		VD_memPtr.prevTot = BSlist_al.number ;
}

/*--------------------------------------------------------------------*/
void
VD_memStatus()
{
	/* both BS and VDS allocation active */
	if (BSdbglev == 20) {

		/* should notify user, but can't use this in VDSloaddata
		 * 	UI_status ("Checking memory allocation..."); 
	 	 */

		fprintf (VD_memFile, "\nMemory allocation status: \n");

		/* BSchkmemo writes to stdout
	  	 */
		BSchkmemo();


		/* Reset previous numvber of free pointers */
		if (!VD_memPtr.list && !VD_memPtr.prevTot )
			VD_memPtr.prevTot = BSlist_al.number ;

		fprintf (VD_memFile," *-* Unfreed pointers: \tincrease: %d",
				     BSlist_al.number -  VD_memPtr.prevTot);
		fprintf (VD_memFile, "\tVDS total: %d\n", VD_memPtr.num);
		VD_memPtr.prevTot = BSlist_al.number ;

		if (BSalloczero) {
			fprintf (VD_memFile, 
				" *** Allocation of 0 bytes was attempted\n");
			BSalloczero = 0;
			};
		if (BSfreezero) {
			fprintf (VD_memFile, 
				" *** Free of 0 bytes was attempted\n");
			BSfreezero = 0;
			};
		}
	/* VDS allocation avctive only */
	else if (VD_memChk)
		fprintf (VD_memFile,"\n %s Unfreed VDS pointers: %d\n", "*-*",
							VD_memPtr.num);
	fflush (VD_memFile);
}
/*--------------------------------------------------------------------*/
/*
 * Print status to a file
 */
void
VD_memFStatus( char* header)
{
	/* both BS and VDS allocation active */
	if (BSdbglev == 20) {

		fprintf (VD_memFile, "\n%s: memory allocation: \n", header);

		/* Reset previous numvber of free pointers */
		if (!VD_memPtr.list && !VD_memPtr.prevTot )
			VD_memPtr.prevTot = BSlist_al.number ;

		fprintf (VD_memFile," *-* Unfreed pointers: \tincrease: %d",
				     BSlist_al.number -  VD_memPtr.prevTot);
		fprintf (VD_memFile, "\tVDS total: %d\n", VD_memPtr.num);
		VD_memPtr.prevTot = BSlist_al.number ;

		if (BSalloczero) {
			fprintf (VD_memFile, 
				" *** Allocation of 0 bytes was attempted\n");
			BSalloczero = 0;
			};
		if (BSfreezero) {
			fprintf (VD_memFile, 
				" *** Free of 0 bytes was attempted\n");
			BSfreezero = 0;
			};
		}
	/* VDS allocation avctive only */
	else if (VD_memChk)
		fprintf (VD_memFile,"\n %s Unfreed VDS pointers: %d\n", "*-*",
							VD_memPtr.num);
	fflush (VD_memFile);
}


/*-------------------------------------------------------------------------*/
void
VD_memPrintPtrs ( )
{
	int	i;

	/* if not in debug mode - do nothing */
	if (BSdbglev != 20 || !VD_memChk )
		goto wrapup;

	/* print list */
	if (VD_memPtr.num) {
		fprintf (VD_memFile, "\n   VDS pointers: %d\n", VD_memPtr.num);
		fprintf (VD_memFile, 
				"       Address      Type Line  File\n");
		for (i=0; i<VD_memPtr.num;  i++)
			fprintf (VD_memFile, "\t0x%x    %c\t%4d   %s\n",
					VD_memPtr.list[i].ptr,
					VD_memPtr.list[i].type,
					VD_memPtr.list[i].line,
					VD_memPtr.list[i].file);

		/* extra line after table */
		putc ('\n', VD_memFile);
		}

	fflush (VD_memFile);
wrapup:
	return;
}
/*-----------------------------------------------------------------------*/
char *
VD_malloc ( 	int	size,
		int	line,
		char 	* file)
{
	char 	*ptr;

	/* null allocation */
	if (!size) {
		ptr = NULL;
		ZERO("Allocation", line, file);
		goto wrapup;
		}

	/* allocation */
	ptr = malloc ( (unsigned )size);
	if (!ptr) {
		FAIL("allocation", line, file);
		goto wrapup;
		}

	/* if debug mode - add ptr to list */
	if (VD_memChk)
		VD_memUpdateList (VD_memPtr.num, ptr, 'M', line, file, TRUE);

wrapup:
	if (VD_memChk && VD_memTrace )
		TRACE_ALLOC ("MALLOC", ptr, size, file, line);
	return (ptr);
}
/*-------------------------------------------------------------------------*/
void
VD_free ( 	char	*ptr,
		int	line,
		char 	* file)
{
	int	i,j;

	/* if not in debug mode - do only free */
	if (!VD_memChk )
		goto free;

	/* Print trace message */
	if (VD_memTrace ) {
		fprintf (VD_memFile, 
			"\t   FREE (0x%x) at %s(%d)", ptr, file, line);
		fflush(VD_memFile);
		}

	/* find  in list */
	for (i=0; i < VD_memPtr.num && VD_memPtr.list[i].ptr != ptr ; )
		i++;

	/* remove from list */
	if ( i < VD_memPtr.num ) {
		if (VD_memTrace)
			fprintf (VD_memFile, "\tfrom %s(%d)\n",
						VD_memPtr.list[i].file,
						VD_memPtr.list[i].line);
		/* shift remainder of list up */
		for (j=i+1; j <VD_memPtr.num; j++)
			memcpy ( (char*) &(VD_memPtr.list[j-1]),
				 (char*) &(VD_memPtr.list[j]),
				 sizeof (VD_memList_t) );
		VD_memPtr.list[VD_memPtr.num].ptr = NULL;
		VD_memPtr.num--;
		}
	else if (VD_memTrace) {
		putc ('\n', VD_memFile);
		fflush(VD_memFile);
		}
free:
	free (ptr);
}
/*-----------------------------------------------------------------------*/
char *
VD_realloc ( 	char	*ptr,
		int	size,
		int	line,
		char 	* file)
{
	int	i;
	char	*new_ptr = ptr;

	/* attempt to realloc a null ptr */
	if (!ptr) {
		ZERO ("Reallocation", line, file);
		goto wrapup;
		}

	/* reallocation */
	new_ptr = realloc ( ptr, (unsigned) size);
	if (!new_ptr) {
		FAIL ("reallocation", line, file);
		goto wrapup;
		}

	/* if not in debug mode - do only realloc */
	if (!VD_memChk )
		goto wrapup;

	/* make sure list is ok */
	if (!VD_memInitList ())
		goto wrapup;

	/* find entry in list */
	for (i=0; i < VD_memPtr.num && VD_memPtr.list[i].ptr != ptr ; )
			i++;

	/* pointer not in list */
	if ( i == VD_memPtr.num)
		VD_memUpdateList (VD_memPtr.num, ptr, 'U', line, file, TRUE);

	/* existing pointer has been reallocated */
	else if (new_ptr != ptr)
		VD_memUpdateList (i, new_ptr, 'R', line, file, FALSE);

wrapup:
	if (VD_memChk && VD_memTrace )
		TRACE_ALLOC ("REALLOC", new_ptr, size, file, line);

	return (new_ptr);
}

/*-----------------------------------------------------------------------*/
char *
VD_calloc ( 	int	size,
		int	line,
		char 	* file)
{
	char 	*ptr;

	/* null allocation */
	if (!size) {
		ptr = NULL;
		ZERO ("Calloc", line, file);
		goto wrapup;
		}

	/* allocation */
	ptr = calloc ( (unsigned )1, (unsigned) size);
	if (!ptr) {
		FAIL ("calloc", line, file);
		goto wrapup;
		}

	/* if debug mode - add ptr to list */
	if (VD_memChk)
		VD_memUpdateList (VD_memPtr.num, ptr, 'C', line, file, TRUE);

wrapup:
	if (VD_memChk && VD_memTrace )
		TRACE_ALLOC ("CALLOC", ptr, size, file, line);

	return (ptr);
}
