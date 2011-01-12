/*
-------------------------------------------------------------------------------
Name:			OMUNIXcode.c
Author:			Tara Gibbs
Creation Date:		Feb 19867
Operating System(s):	Unix SYSV, v2
Abstract:

This module contains Operating Specific routines for OM.

----
Notes:

----
Revision History:

jkm001	16-may-1986	added routine OM_init_intOS_name to seed random number
			generator.

jkm002			added routine to determine if sufficient disk space
			exists to write an os. **Moved to OMFiledOSi.I**
jkm003  7-jan-1987	added routine to examine a file name an determine
			what kind of file it is, e.g. special, readonly, etc.
jkm004  18-jun-1987	added the dynamic load primitive

ems001  02-dec-1991    Added the function som_is_om_file.

-------------------------------------------------------------------------------
*/

#include	<errno.h>		/* UNIX error codes */
#include 	<stdio.h>		/* standar i/o structs */
#include  <stdlib.h>
#include 	<sys/types.h>		/* special data types */
#include 	<sys/stat.h>		/* struct for stat call */
#include	<fcntl.h>
#include 	<time.h>
#include	<string.h>
#ifdef CLIX
#include	<sys/sysingr.h>
#endif
#ifdef BSD
#include	<vfork.h>
#endif
#ifdef SUNOS5
#include	<unistd.h>
#endif
#ifdef IRIX
#include        <invent.h>
#endif
#if defined (IRIX5) || defined (SUNOS5) || !defined (NT)
typedef unsigned long long	uint64_t;
#include	<sys/swap.h>
#endif

#ifndef NT
#include	<dload.h>		/* for dynamic loader */
#endif
#include 	"OMminimum.h"
#include        "OMprimitives.h"
#include 	"OMlimits.h"
#include 	"OMOSfilehdr.h"
#include 	"OMerrordef.h"
#include 	"UNIXerrdef.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMintprims.h"
#include	"OMmetaclass.h"

#define 	UNIX_K_FILENAMELEN	14

#ifdef SUNOS
extern int      stat();
extern time_t   time();
#endif

extern OM_S_CSD *OM_GA_CSDarray;
extern OMuint   OM_Gi_CSDarraySize;
extern OM_S_SYSINFO *OM_Gp_SYSINFO;

/*
-------------------------------------------------------------------------------
Routine Name:	OM_get_time
Abstract:		
	Returns a string of the form:
				mmddyyyyhhmm
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	t	pointer to char	    pointer to date/time string

Modules Invoked:
	time
	localtime

-------------------------------------------------------------------------------
*/

void 	OM_get_time( t )
char 	*t;
	
{
  time_t time_loc;
  struct tm *tm;

  time( &time_loc );
  tm = localtime( &time_loc );
  sprintf( t, "%02d%02d%04d%02d%02d", tm->tm_mon+1, tm->tm_mday, 
		1900+tm->tm_year, tm->tm_hour, tm->tm_min);
}


/*
-------------------------------------------------------------------------------
Routine Name:	OM_extract_filename
 
Abstract:		

Returns a returns a filename (without PATH or directory stuff). It allows
the user to specify a maximum number of characters to return.

----
Sample Invocation:

	OM_extract_filename( input_name, result_name, max_length );

----
Entry Variable Description:


char		*input_name	The input string (complete filename)
int		max_length	maximum number of characters to return

----
Exit Variable Description:

char		*result_name	resultant filename (only)

----
Modules Invoked:

	strncpy
	strrchr

----
Notes:

Actual number of characters returned is minimum of UNIX filename length 
(14 characters) and max_length.

----
Change History:

-------------------------------------------------------------------------------
*/

void	OM_extract_filename (inname, outname, maxlen)

char	*inname, *outname;
int	maxlen;
{
  char	*p_start;
  int	minmaxlen;
  
/* find point after last "/" in hypothetical PATH name... */

#ifndef NT
  if (NULL == (p_start = strrchr (inname, '/'))) p_start = --inname;
#else
  if (NULL == (p_start = strrchr (inname, '\\'))) p_start = --inname;
#endif
  p_start++;
  
  minmaxlen = 
    (((maxlen - UNIX_K_FILENAMELEN) > 0) ? UNIX_K_FILENAMELEN:maxlen);
  strncpy (outname, p_start, minmaxlen);

  outname[minmaxlen] = '\0';		/* strncpy does not add a NULL */
}


/*
-------------------------------------------------------------------------------
Routine Name:	OM_init_intOS_name
 
Abstract:		
 
 Routine to seed the random number generator. it uses system calls to
 get the time of day ( number of seconds since Jan 1, 1970),
 then calls srand to seed the generator.

----
Sample Invocation:

	OM_init_intOS_name();

----
Modules Invoked:

	time	.. to get the number of seconds since Jan 1, 1970
	srand   .. to seed the random number generator
----
Change History:

-------------------------------------------------------------------------------
*/

void OM_init_intOS_name()
{
	long tod;
	tod = time((long *) 0);
	srand( (int) tod ); /*  use tod as  a seed	*/
}



/****************************************************************************/
int	som_verify_filename(filename)

char 	*filename;
{
/*	routine to examine a file name and determine one or more of
	the following:
	Is the file a special file, like a pipe or a directory?
	Is the pathname valid?	
	Can this process open the file for write?
	if the file exists, can it be opened for read or read/write?

	This routine is used by the logic to construct an os to determine
	whether or not the os can be constructed.

	arguments:
	char	*filename	name of the file to examine.
	int     *p_flag  	place for flag bits to indicate results

	return values:
	
*/

FILE *fp;

#ifndef NT
struct stat status;

	if (stat(filename, &status))
#else
struct _stat status;

	if (_stat(filename, &status))
#endif
	{
	/* if the status failed, we know that either the file doesnt
	/* exist or the directory was bad or protected */
	/* the 'ENOENT' error message is for bad file or directory */
	if (errno == ENOENT)
	{
		fp = fopen(filename, "a");
		if (!fp)
		{
		/* this condition might be a bad file spec */
			 return(OM_E_INACCESSABLE_FILE);
		}
		else 
		{ 
		   fclose(fp);
#ifndef NT		   
		   unlink(filename);
#else
		   _unlink(filename);
#endif		   
		   return(OM_I_NOEXIST_WRITEABLE_FILE);
		}
	}
	else
	/* if there were a protection violation, we would see this */
     	    return(OM_E_INACCESSABLE_FILE);
	}

	/* if the status succeeded, it could be for one of several reasons:
	o the file is a directory or other special file.
	o the file is protected, but was accessable
	o the file exists and is readable but not writable.
	o the file exists and is readable and writable.
	*/

	/* check if directory or other special file. */
	
	if (status.st_mode & 040000)	 /* validating swap directories */
		return(OM_E_FILEISDIR);

	if (status.st_mode & 0070000)
		return(OM_E_SPECIAL_FILE);

	/* to determine the readability and writability of this file,
	/* we will try to open the file for read, then if that succeeds,
	/* close and try to open for read/write.
	*/

	fp = fopen(filename,"r");
	if (!fp)
	{
		/* coulndt open the file for reading */
		/* if we can't read the file, it is inaccessable. we dont
		/* count files which are write only.*/
		return(OM_E_INACCESSABLE_FILE);
	}
	else
	{
		fclose(fp);
		fp = fopen(filename,"r+");

		if(!fp)
			return(OM_I_EXIST_READONLY_FILE);
		else
		{
			fclose(fp);
			return(OM_I_EXIST_READ_WRITE_FILE);
		}	
	}	/* end if if the file opened for read */
}

#if 1
int som_dynamic_load(char *object_file)
{
#ifndef NT    
   if (!dload(object_file, TEXTREF | DATAREF | TEXTREDEF |
      DATAREDEF | OVERLOAD))
   {
      fprintf (stderr, "som_dynamic_load: Error during dload of %s\n",
         object_file);
      return(OM_E_ERROR);
   }
#endif   
   return(OM_S_SUCCESS);
}
#endif

#define OM44        0x00040004    /*  translates to 1.1  */
#define OM45        0x00050004    /*  translates to 1.2  */
#define OM13        0x00030001
#define OM14        0x00040001
#define OM_MAGIC    0x4d4f

#ifdef BIG_ENDIAN

#define MO_MAGIC    0x4f4d

static unsigned short endian_short(s)
unsigned short s;
{
   unsigned short t=s>>8;
  
   s = s << 8;
   t = t | s;
   return (t);
}

static unsigned int endian_int(s)
unsigned int s;
{
   unsigned int t=s>>24, m;

   m = s & 0x00ff0000;
   m = m >> 8;
   t = t | m;
   m = s & 0x0000ff00;
   m = m << 8;
   t = t | m;
   m = s & 0x000000ff;
   m = m << 24;
   t = t | m;
   return(t);
}
#endif  /* BIG_ENDIAN */

/*
**-------------------------------------------------------------------
**
**   function:  som_is_om_file
**
**     Will return TRUE (1) if given file is an OM object space of
**      either 4.4 (1.1) 
**             4.5 (1.2)
**             1.3 
**             1.4
**             2.0 (and above)
**
**     Otherwise return FALSE (0).
**
**   Arguments:
**
**       Type          Name         I/O          Description
**      ______    _______________   ___  __________________________________
**
**      char *    filename           I   Name of file to check
**      short *   p_major            O   Major version number of file
**      short *   p_minor            O   Minor version number of file
**      char *    p_mach_type        O   Machine type of file (C,S,...)
**      int *     p_file_type        O   User defined file type (cell,sheet...)
**
**
**     If file is an OM object space the function will also fill in
**      the major and minor version numbers (1.1, 1.2, 1.3, 1.4, 2.0, ...)
**
**     Also as an added bonus for 2.0 files and up - we'll return the 
**     machine type (such as C for Clipper, S for Sun, etc).  If its is 
**     less than a 2.0 file then a NULL will be returned.
**
**     Hey - why we're being so generous - we'll also return the field
**     in the header which specifies the user defined file type (such
**     as Ems_cell_file, Ems_drawing_file, etc).  Once again, if the
**     file is less than a 2.0 file then a NULL will be returned.
**
**     And since you called today - we'll throw in a set of Ginsu knives,
**     a bamboo steamer, and some wind chimes.
**
**-------------------------------------------------------------------
*/

int som_is_om_file ( filename, p_major, p_minor, p_mach_type, p_file_type )
char  *filename;
short *p_major, *p_minor;
char  *p_mach_type;
int   *p_file_type;

{
   int            i, f;
   int            ihdr[128];
   unsigned short shdr[256];
   char           chdr[512];
#ifndef NT   
   struct stat    buf;

      if (stat(filename, &buf)) {
#else
   struct _stat    buf;

      if (_stat(filename, &buf)) {
#endif   

#ifdef VERBOSE
      fprintf(stderr,"som_is_om_file::Could not open file %s\n",filename);
      perror("System error");
#endif
      return 0;
   }

#ifndef NT   
   if (!(f = open(filename, O_RDONLY))) {
#else   
   if (!(f = _open(filename, _O_RDONLY | _O_BINARY))) {
#endif    
#ifdef VERBOSE
      fprintf(stderr,"som_is_om_file::Could not open file %s\n",filename);
      perror("System error");
#endif
      return 0;
   }

#ifndef NT   
   for (i=0; i<128; ++i) 
     if (sizeof(int) != read(f, &ihdr[i], sizeof(int)))
        return 0;

   lseek(f,0,0);
   for (i=0; i<256; ++i) 
     if ( sizeof(short) != read(f, &shdr[i], sizeof(short)))
        return 0;

   lseek(f,0,0);

   for (i=0; i<512; ++i) 
     if ( sizeof(char) != read(f, &chdr[i], sizeof(char)))
        return 0;

   close (f);
#else
   for (i=0; i<128; ++i) 
     if (sizeof(int) != _read(f, &ihdr[i], sizeof(int)))
        return 0;

   _lseek(f,0,0);
   for (i=0; i<256; ++i) 
     if ( sizeof(short) != _read(f, &shdr[i], sizeof(short)))
        return 0;

   _lseek(f,0,0);

   for (i=0; i<512; ++i) 
     if ( sizeof(char) != _read(f, &chdr[i], sizeof(char)))
        return 0;

   _close (f);
#endif

   *p_mach_type = 0;
   *p_file_type = 0;

   if ( ihdr[0] == OM44 ) {
      if ((ihdr[11] - ihdr[9]) == 8) {
         *p_major = 1;
         *p_minor = 1;
         return 1;
      }
      else
         return 0;
   }

   if ( ihdr[0] == OM45 ) {
      if (((ihdr[10] - ihdr[9])  == 68) && 
          ((ihdr[10] - ihdr[11]) == 64)) {
         *p_major = 1;
         *p_minor = 2;
         return 1;
      }
      else 
         return 0;
   }

   if ( ihdr[0] == OM13 ) {
      if (((ihdr[10] - ihdr[9])  == 68) && 
          ((ihdr[10] - ihdr[11]) == 64)) {
         *p_major = 1;
         *p_minor = 3;
         return 1;
      }
      else 
         return 0;
   }

   if ( ihdr[0] == OM14 ) {
      if (((ihdr[10] - ihdr[9])  == 68) && 
          ((ihdr[10] - ihdr[11]) == 64)) {
         *p_major = 1;
         *p_minor = 4;
         return 1;
      }
      else 
         return 0;
   }

   /*  Now with the magic number approach we can return the 
   **  major and minor numbers without further checks - this
   **  will allow this function to be somewhat immortal
   **  (ie. no more update per release)
   */

#ifdef BIG_ENDIAN
   if ( shdr[0] == MO_MAGIC ) {
      *p_major     = endian_short(shdr[1]);
      *p_minor     = endian_short(shdr[2]);
      *p_file_type = endian_int(ihdr[126]);
      if (chdr[246] == 'C' && chdr[251] == 'S' )   /* account for CLIX/Sun */
         *p_mach_type = 'S';
      else
         *p_mach_type = chdr[246];
      return 1;
   }
#endif

#ifdef LITTLE_ENDIAN

   if ( shdr[0] == OM_MAGIC ) {
      *p_major     = shdr[1];
      *p_minor     = shdr[2];
      *p_file_type = ihdr[126];
      if (chdr[246] == 'C' && chdr[251] == 'S' )   /* account for CLIX/Sun */
         *p_mach_type = 'S';
      else
         *p_mach_type = chdr[246];
      return 1;
   }

#endif   /* sun/clipper */

   return 0;   
}


#include <fcntl.h>

static int tracex = 0;

/* avail_om is meaningless now that we don't use blkalloc blocks for
   om data anymore.  Always set it to zero in case anyone is still
   requesting this value.  total_free is now the same as avail_swap,
   in case anyone is still requesting this value.
*/
int som_get_mem_info(int *avail_swap,
                 int *total_swap,
                 int *phys_mem,
                 int *avail_om, /* OBS - left in, but always 0 */
                 int *total_om,
                 int *total_free /* OBS - set equal to avail_free */)
{
   int   free_swap = 0; /* Used for both *avail_swap & *total_free */

   if (tracex)
   {
     printf(">>> som_get_mem_info ");
     if (avail_swap) printf("avail_swap ");
     if (total_swap) printf("total_swap ");
     if (phys_mem)   printf("phys_mem ");
     if (avail_om)   printf("avail_om ");
     if (total_om)   printf("total_om ");
     if (total_free) printf("total_free ");
     printf("\n");
   }
#ifdef   SYSV

/* ----- Gathering avail_swap, total_free or total_swap for SYSV ----- */

#ifdef   IRIX5
   /* Get swap info for IRIX5 only */

   if (avail_swap || total_free)
   {
      swapctl(SC_GETFREESWAP, &free_swap);
      free_swap *= 512;
   }
   if (total_swap)
   {
      swapctl(SC_GETSWAPTOT, total_swap);
      *total_swap *= 512;
   }
#endif

#ifdef SUNOS5
   if (avail_swap || total_free || total_swap)
   {
      int   ii, count, tot=0;
      struct swptable
      {
         int            swt_n;
         struct swapent swt_ent[50];
      } swaptab;
      char  namebuf[1025];

      if (swaptab.swt_n = swapctl(SC_GETNSWP, NULL))
      {
         if (swaptab.swt_n > 50)
            swaptab.swt_n = 50;
         for(ii=0; ii<swaptab.swt_n; ii++) {
            swaptab.swt_ent[ii].ste_path = namebuf;
            swaptab.swt_ent[ii].ste_pages = 0;
            swaptab.swt_ent[ii].ste_free  = 0;
         }
         if (swapctl(SC_LIST, (struct swaptable *) &swaptab) == -1)
         {
	    perror("swapctl failed");
         }
         else
         {
           if (tracex) printf("swt_n: %d\n",swaptab.swt_n);

            for(ii=0; ii<swaptab.swt_n; ii++)
            {
               tot += swaptab.swt_ent[ii].ste_pages;
               free_swap += swaptab.swt_ent[ii].ste_free;
            }
         }
         free_swap *= OM_Gp_SYSINFO->pageSize;
      }
      if (total_swap)
         *total_swap = tot * OM_Gp_SYSINFO->pageSize;
   }

#endif

#if defined (IRIX4) || defined (CLIX)
#ifdef   CLIX
   if (total_swap)
#else
   if (avail_swap || total_swap)
#endif
   {
      int   p[2], total, freeSwap, execSts, pid2=0;
      int   pid=0;
      FILE  *fp;
      char  *alist[3], buf[50], *routine = "/etc/swap";

      alist[0] = routine;
      alist[1] = "-l";
      alist[2] = 0;
      if (pipe(p) < 0)
      {
         fprintf(stderr, "pipe failed\n");
         perror(0);
         return NULL;
      }

#ifdef CLIX
      if (0 == (pid = vfork()))
#else
      if (0 == (pid = fork()))
#endif
      {
#ifndef NT        
         (void) close(p[0]);
         (void) close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) close(p[1]);
#else
         (void) _close(p[0]);
         (void) _close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) _close(p[1]);
#endif         
         (void) execvp(routine, alist);
         fprintf(stderr, "execvp: %s: failed\n", buf);
         _exit(1);
      }
      if (-1 == pid)
      {
#ifdef CLIX
         fprintf(stderr, "vfork failed\n");
#else
         fprintf(stderr, "fork failed\n");
#endif
         return NULL;
      }
      else if (pid)
      {
         while (pid != pid2)
         {
            pid2 = wait(&execSts);
            if ((pid2 == -1) && (errno != EINTR))
            {
               perror("");
               break;
            }
         }
#ifndef NT         
         (void) close(p[1]);
#else
         (void) _close(p[1]);
#endif         
         fp = (FILE *) fdopen(p[0], "r");
         fscanf(fp, "%s%s%s%s%s", &buf[0],&buf[0],&buf[0],&buf[0],&buf[0]);
#ifndef CLIX
         if (total_swap)
            *total_swap = 0;
#else
         *total_swap = 0;
#endif
         while(fscanf(fp, "%s%s%s%d%d", &buf[0], &buf[0], &buf[0], &total, &freeSwap)
            != EOF)
         {
#ifndef CLIX
            if (total_swap)
               *total_swap += total;
            free_swap += freeSwap;
#else
            *total_swap += total;
#endif
         }
#ifndef CLIX
	 if (total_swap)
            *total_swap *= 512;     /* Convert blocks to bytes */
#else
         *total_swap *= 512;     /* Convert blocks to bytes */
#endif
         fclose(fp);
      }
   }

#ifdef CLIX
   if (avail_swap || total_free)
      free_swap = syscall(SYSINGR, SINGRAVAILSMEM);
#else
   if (avail_swap || total_free)
      free_swap *= 512;
#endif
#endif   /* CLIX or IRIX4 */


/* ----- Gathering phys_mem for SYSV systems ----- */

#ifdef CLIX
   if (phys_mem)
      *phys_mem = syscall(SYSINGR, SINGRMEMSIZE);
#endif

#ifdef IRIX
   if (phys_mem)
   {
      inventory_t   *buf;

      *phys_mem = -1;
      setinvent();
      while (1)
      {
         if (!(buf = getinvent()))
            break;
#ifdef IRIX5
         if ((buf->inv_class == INV_MEMORY) && (buf->inv_type == INV_MAIN))
         {
            *phys_mem = buf->inv_state;
            break;
         }
#else
         if ((buf->class == INV_MEMORY) && (buf->type == INV_MAIN))
         {
            *phys_mem = buf->state;
            break;
         }
#endif
      }
      endinvent();
   }
#endif

#ifdef SUNOS5

   if (phys_mem)
   {
      int   pid, pid2, execSts, p[2];
      FILE  *fp;
      char  *alist[3], *routine = "/etc/prtconf";
      char  buf[50];

      pid2 = 0;
      alist[0] = routine;
      alist[1] = 0;
      if (pipe(p) < 0)
      {
         fprintf(stderr, "pipe failed\n");
         perror(0);
         return NULL;
      }

      if (0 == (pid = fork()))
      {
#ifndef NT        
         (void) close(p[0]);
         (void) close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) close(p[1]);
#else
         (void) _close(p[0]);
         (void) _close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) _close(p[1]);
#endif
         
         (void) execvp(routine, alist);
         fprintf(stderr, "execvp: %s: failed\n", buf);
         _exit(1);
      }
      if (-1 == pid)
      {
         fprintf(stderr, "fork failed\n");
         return NULL;
      }
      else if (pid)
      {
#ifndef NT        
         (void) close(p[1]);
#else
         (void) _close(p[1]);
#endif         
         fp = (FILE *) fdopen(p[0], "r");
         fscanf(fp, "%s%s%s%s%s%s%s",
            &buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0]);
         fscanf(fp, "%d", phys_mem);
         while (pid != pid2)
         {
            pid2 = wait(&execSts);
            if ((pid2 == -1) && (errno != EINTR))
            {
               perror("");
               break;
            }
         }
         *phys_mem *= 1048576;
         fclose(fp);
      }
   }
#endif   /* SUNOS5 */
#endif   /* SYSV */

#ifdef BSD
   int   p[2], total, used, execSts, pid2=0;
   int   pid=0;
   FILE  *fp;
   char  *alist[3], buf[50], *routine = "/etc/pstat";
   char  *routine2 = "/etc/dmesg";

   if (total_swap || avail_swap || total_free)
   {
      if (total_swap)
         *total_swap = 0;
      if (avail_swap)
         *avail_swap = 0;
      if (total_free)
         *total_free = 0;
      alist[0] = routine;
      alist[1] = "-s";
      alist[2] = 0;
      if (pipe(p) < 0)
      {
         fprintf(stderr, "pipe failed\n");
         perror(0);
         return NULL;
      }

      if (0 == (pid = vfork()))
      {
#ifndef NT        
         (void) close(p[0]);
         (void) close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) close(p[1]);
#else         
         (void) _close(p[0]);
         (void) _close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) _close(p[1]);
#endif
         (void) execvp(routine, alist);
         fprintf(stderr, "execvp: %s: failed\n", routine);
         _exit(1);
      }
      if (-1 == pid)
      {
         fprintf(stderr, "vfork failed\n");
         return NULL;
      }
      else if (pid)
      {
         while (pid != pid2)
         {
            pid2 = wait(&execSts);
            if ((pid2 == -1) && (errno != EINTR))
            {
               perror("");
               break;
            }
         }
#ifndef NT         
         (void) close(p[1]);
#else         
         (void) _close(p[1]);
#endif	 
         fp = (FILE *) fdopen(p[0], "r");
         fscanf(fp, "%s%s%s%s%s%s%d%s%s%d%s%s", &buf[0],&buf[0],&buf[0],
            &buf[0],&buf[0],&buf[0],&used,&buf[0],&buf[0],&free_swap,&buf[0],&buf[0]);
         if (total_swap)
            *total_swap += (free_swap + used) * 1024; /* Convert kbytes to bytes */
         fclose(fp);
      }

      if (avail_swap || total_free)
         free_swap *= 1024;
   }

   if (phys_mem)
   {
      pid2 = 0;
      alist[0] = routine2;
      alist[1] = 0;
      if (pipe(p) < 0)
      {
         fprintf(stderr, "pipe failed\n");
         perror(0);
         return NULL;
      }

      if (0 == (pid = vfork()))
      {
#ifndef NT        
         (void) close(p[0]);
         (void) close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) close(p[1]);
#else
         (void) _close(p[0]);
         (void) _close(1);
         (void) fcntl(p[1], F_DUPFD, 1);
         (void) _close(p[1]);
#endif
         (void) execvp(routine2, alist);
         fprintf(stderr, "execvp: %s: failed\n", buf);
         _exit(1);
      }
      if (-1 == pid)
      {
         fprintf(stderr, "vfork failed\n");
         return NULL;
      }
      else if (pid)
      {
#ifndef NT      
         (void) close(p[1]);
#else
         (void) _close(p[1]);
#endif         
         fp = (FILE *) fdopen(p[0], "r");
         fscanf(fp, "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
            &buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],
            &buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0],
            &buf[0],&buf[0],&buf[0],&buf[0],&buf[0],&buf[0]);
         fscanf(fp, "%d", phys_mem);
         while (pid != pid2)
         {
            pid2 = wait(&execSts);
            if ((pid2 == -1) && (errno != EINTR))
            {
               perror("");
               break;
            }
         }
         *phys_mem *= 1024;
         fclose(fp);
      }
   }

#endif /* #ifdef BSD */

   if (total_free)
      *total_free = free_swap;
   if (avail_swap)
      *avail_swap = free_swap;
   if (avail_om)
      *avail_om = 0;
   if (total_om)
   {
      OMuint   ii;

      for (*total_om = ii = 0; ii<OM_Gi_CSDarraySize; ii++)
      {
         if (OM_GA_CSDarray[ii].flag & OM_INUSE)
            *total_om += OM_GA_CSDarray[ii].p_pcd->i_totalWsheap;
      }
   }

   return 1;
}
