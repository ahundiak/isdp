#include "exsysdep.h"
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <exproto.h>
#ifdef NT
#include <io.h>
#endif
#ifndef NT
#include <utime.h>
#else
#include <sys/utime.h>
#endif
#define	DOT	"."
#define	DELIM	'/'
#define	MAXN	128
#define BLKSIZE    2048

static char *
pname(name)
register char *name;
{
	register c;
	register char *p, *q;
	static	char buf[MAXN];

	p = q = buf;
	while (c = *p++ = *name++)
		if (c == DELIM)
			q = p-1;
	if (q == buf && *q == DELIM)
		q++;
	*q = 0;
	return buf[0]? buf : DOT;
}

static char *
dname(name)
register char *name;
{
	register char *p;

	p = name;
	while (*p)
		if (*p++ == DELIM && *p)
			name = p;
	return name;
}

EX_mv(source, target)
char *source, *target;
{
    char	buf[MAXN];
#if defined(CLIX)
    struct	statl s1, s2;
#elif defined(SUNOS) || defined(IRIX)
    struct	stat  s1, s2;
#elif defined (NT)
    struct	_stat  s1, s2;
#else
#error Windowing system switches must be set!
#endif
#ifndef NT
    struct utimbuf *tbuf;
#else
    struct _utimbuf *tbuf;
#endif
#if defined(CLIX)
    if (statl(source, &s1) < 0)
#elif defined(SUNOS) || defined(IRIX)
    if (stat(source, &s1) < 0)
#elif defined(NT)
    if (_stat(source, &s1) < 0)
#else
#error Windowing system switches must be set!
#endif
    {
       printf( "In EX_mv: cannot 88access %s\n",   source);
       return(0);
    }
#ifndef NT
    if ((s1.st_mode & S_IFMT) == S_IFDIR) 
#else
    if ((s1.st_mode & _S_IFMT) == _S_IFDIR) 
#endif
    {
        printf( "In EX_mv : <%s> directory\n",   source);
        return(0);
    }
#ifndef NT
    if ( access(pname(source), 2) == -1)
#else
    if ( _access(pname(source), 2) == -1)
#endif
    {
	printf( "In EX_mv: cannot unlink %s\n",   source);
	return(0);
    }
#ifndef NT
    s2.st_mode = S_IFREG;
#else
    s2.st_mode = _S_IFREG;
#endif
#if defined(CLIX)
    if (statl(target, &s2) >= 0) 
#elif defined(SUNOS) || defined(IRIX)
    if (stat(target, &s2) >= 0)
#elif defined (NT)
    if (_stat(target, &s2) >= 0)
#else
#error Windowing system switches must be set!
#endif
    {
#ifndef NT
       if ((s2.st_mode & S_IFMT) == S_IFDIR) 
#else
       if ((s2.st_mode & _S_IFMT) == _S_IFDIR) 
#endif
       {
          sprintf(buf, "%s/%s", target, dname(source));
          target = buf;
       }
#if defined(CLIX)
       if (statl(target, &s2) >= 0)
#elif defined(SUNOS) || defined(IRIX)
       if (stat(target, &s2) >= 0)
#elif defined (NT)
    if (_stat(target, &s2) >= 0)

#else 
#error Windowing system switches must be set!
#endif
       {
	  if (s1.st_dev==s2.st_dev && s1.st_ino==s2.st_ino) 
	  {
             return(1);
	  }
#ifndef NT
	  if (unlink(target) < 0) 
#else
	  if (_unlink(target) < 0) 
#endif
	  {
	     printf( "In EX_mv: cannot unlink %s\n",   target);
	     return(0);
	  }
       }
   }
   if ( link(source, target) < 0) 
   {
       int from, to, ct, oflg;
       char fbuf[BLKSIZE];
#ifndef NT
       if((from = open(source, 0)) < 0) {
#else
       if((from = _open(source, 0)) < 0) {
#endif
	       printf( "In EX_mv: cannot open %s\n",   source);
	       return(0);
       }
#ifndef NT
       oflg = access(target, 0) == -1;
       if((to = creat (target, 0666)) < 0) 
#else
       oflg = _access(target, 0) == -1;     
       if((to = _creat (target, 0666)) < 0) 
#endif
       {
          printf( "In EX_mv: cannot create %s\n",   target);
          return(0);
       }
#ifndef NT
       while((ct = read(from, fbuf, BLKSIZE)) != 0)
#else
       while((ct = _read(from, fbuf, BLKSIZE)) != 0)
#endif
       {
#ifndef NT
	  if(ct < 0 || write(to, fbuf, ct) != ct) 
#else
	  if(ct < 0 || _write(to, fbuf, ct) != ct) 
#endif
	  {
	      printf( "In EX_mv: bad copy to %s\n",   target);
#ifndef NT
	      if((s2.st_mode & S_IFMT) == S_IFREG)
#else
	      if((s2.st_mode & _S_IFMT) == _S_IFREG)
#endif
	      {
#ifndef NT
	         unlink(target);
#else
	         _unlink(target);
#endif
	      }
	      return(0);
	  }
       }

#ifndef NT
       tbuf = (struct utimbuf *) malloc((unsigned) sizeof(struct utimbuf));
#else
       tbuf = (struct _utimbuf *) malloc((unsigned) sizeof(struct _utimbuf));
#endif
       tbuf->actime = s1.st_atime;
       tbuf->modtime = s1.st_mtime;
#ifndef NT
       utime(target, tbuf);
#else
       _utime(target, tbuf);
#endif
       free(tbuf);
#ifndef NT
       close(from), close(to);
       if (oflg)  chmod(target, s1.st_mode);
#else
       _close(from), _close(to);
       if (oflg)  _chmod(target, s1.st_mode);
#endif

   }

#ifndef NT
   if (unlink(source) < 0) 
#else
   if (_unlink(source) < 0) 
#endif
   {
	printf( "In EX_mv: cannot unlink %s\n",   source);
	return(0);
   }
   return(1);
}


EX_cp(source, target)
char *source, *target;
{
    char	buf[MAXN];
#if defined(CLIX)
    struct	statl s1, s2;
#elif defined(SUNOS) || defined(IRIX)
    struct	stat s1, s2;
#elif defined (NT)
    struct	_stat s1, s2;
#else
#error Windowing system switches must be set!
#endif
    int from, to, ct, oflg;
    char fbuf[BLKSIZE];

#if defined(CLIX)
    if (statl(source, &s1) < 0)
#elif defined(SUNOS) || defined(IRIX)
    if (stat(source, &s1) < 0)
#elif defined (NT)
    if (_stat(source, &s1) < 0)
#else
#error Windowing system switches must be set!
#endif
    {
       printf( "In EX_cp: cannot access %s\n",   source);
       return(0);
    }
#ifndef NT
    if ((s1.st_mode & S_IFMT) == S_IFDIR) 
#else
    if ((s1.st_mode & _S_IFMT) == _S_IFDIR) 
#endif
    {
        printf( "In EX_cp : <%s> directory\n",   source);
        return(0);
    }
#ifndef NT
    s2.st_mode = S_IFREG;
#else
    s2.st_mode = _S_IFREG;
#endif
#if defined(CLIX)
    if (statl(target, &s2) >= 0)
#elif defined(SUNOS) || defined(IRIX)
    if (stat(target, &s2) >= 0)
#elif defined (NT)
    if (_stat(target, &s2) < 0)
#else
#error Windowing system switches must be set!
#endif
    {
#ifndef NT
       if ((s2.st_mode & S_IFMT) == S_IFDIR) 
#else
       if ((s2.st_mode & _S_IFMT) == _S_IFDIR) 
#endif
       {
          sprintf(buf, "%s/%s", target, dname(source));
          target = buf;
       }
#if defined(CLIX)
       if (statl(target, &s2) >= 0)
#elif defined(SUNOS) || defined(IRIX)
       if (stat(target, &s2) >= 0)
#elif defined (NT)
       if (_stat(target, &s2) >= 0)
#else
#error Windowing system switches must be set!
#endif
       {
	  if (s1.st_dev==s2.st_dev && s1.st_ino==s2.st_ino) 
	  {
             return(1);
	  }
       }
   }

#ifndef NT
   if((from = open(source, 0)) < 0) {
#else
   if((from = _open(source, 0)) < 0) {
#endif
	   printf( "In EX_cp: cannot open %s\n",   source);
	   return(0);
   }
#ifndef NT
   oflg = access(target, 0) == -1;
   if((to = creat (target, 0666  )) < 0) 
#else
   oflg = _access(target, 0) == -1;
   if((to = _creat (target, 0666  )) < 0) 
#endif
   {

      printf( "In EX_cp: cannot create %s\n",   target);
	perror( "IN EX_cp" );
      filetest();
      return(0);
   }
#ifndef NT
   while((ct = read(from, fbuf, BLKSIZE)) != 0)
   {
      if(ct < 0 || write(to, fbuf, ct) != ct) 
#else
   while((ct = _read(from, fbuf, BLKSIZE)) != 0)
   {
      if(ct < 0 || _write(to, fbuf, ct) != ct) 
#endif
      {
	  printf( "In EX_cp: bad copy to %s\n",   target);
#ifndef NT
	  if((s2.st_mode & S_IFMT) == S_IFREG)
#else
	  if((s2.st_mode & _S_IFMT) == _S_IFREG)
#endif
	  {
#ifndef NT
	     unlink(target);
#else
	     _unlink(target);
#endif
	  }
	  return(0);
      }
   }
#ifndef NT
   close(from), close(to);
#else
   _close(from), _close(to);
#endif
   return(1);
}



int EX_rm(file1)
char *file1;
{
    int  status;
#ifndef NT
    status = unlink(file1);
#else
    status = _unlink(file1);
#endif
    if( status == -1)
    {
       printf("EX_rm can not unlink file %s errno = %d\n",file1,errno);
       perror("EX_rm can not unlink file");
       return(0);
    }    
    else
    {
       return(1);  /*success */
    }
} 



