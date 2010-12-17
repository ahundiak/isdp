
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* adrfrd.c -- library routines for accessing autocad drawing files */
/* read real and long from file */
#include "adrhdr.h"

#ifndef OLDCHDR
double frdreal(void)  /* read a double precision real from file */
#else
double frdreal()
#endif
{
#ifndef BIGENDIAN
  double r;

  ad_fread((char *)&r,SIZEOFDOUBLE,1,adin.dwgfiler SUBN);
  return(r);
#else
  short i;

  ad_fread(adin.unixunion.unixdata,SIZEOFDOUBLE,1,adin.dwgfiler SUBN);
  for (i=0; i<4; i++) {
    adin.unixchar=adin.unixunion.unixdata[i];
    adin.unixunion.unixdata[i]=adin.unixunion.unixdata[7-i];
    adin.unixunion.unixdata[7-i]=adin.unixchar;
  }

  return(adin.unixunion.unixdoub);
#endif
}

#ifndef OLDCHDR
long frdlong(void)  /* read a long integer from file */
#else
long frdlong()
#endif
{
#ifndef BIGENDIAN
  long l;

  ad_fread((char *)&l,SIZEOFLONG,1,adin.dwgfiler SUBN);
  return(l);
#else
  ad_fread(adin.unixunion.unixdata,SIZEOFLONG,1,adin.dwgfiler SUBN);
  adin.unixchar=adin.unixunion.unixdata[0]; adin.unixunion.unixdata[0]=adin.unixunion.unixdata[3]; adin.unixunion.unixdata[3]=adin.unixchar;
  adin.unixchar=adin.unixunion.unixdata[1]; adin.unixunion.unixdata[1]=adin.unixunion.unixdata[2]; adin.unixunion.unixdata[2]=adin.unixchar;
  return(adin.unixunion.unixlong);
#endif
}


/* MSSP 29 Dec 93. replaced UNIXOS with OS_UNIX */
#ifndef OS_UNIX
#ifndef AD3
double rdreal(void)
{
  double r;

  r = *((double *)adin.entptr);
  adin.entptr+=SIZEOFDOUBLE;
  return(r);
}

void rd2real(void *a)
{
  memcpy(a,adin.entptr,2*SIZEOFDOUBLE);
  adin.entptr+=2*SIZEOFDOUBLE;
}

void rd3real(void *a)
{
  memcpy(a,adin.entptr,3*SIZEOFDOUBLE);
  adin.entptr+=3*SIZEOFDOUBLE;
}

#endif
#endif

#if defined(BIGENDIAN) && defined(QUADWORDALIGNED)
double rdreal()
{
  double r;
  short i;

  memcpy(adin.unixunion.unixdata,adin.entptr,SIZEOFDOUBLE);
  for (i=0; i<4; i++) {
    adin.unixchar=adin.unixunion.unixdata[i];
    adin.unixunion.unixdata[i]=adin.unixunion.unixdata[7-i];
    adin.unixunion.unixdata[7-i]=adin.unixchar;
  }
  adin.entptr+=SIZEOFDOUBLE;
  return(adin.unixunion.unixdoub);
}


void rd2real(a)
char *a;
{
  double r;
  short i,j;

  for (j=0; j<2; j++) {
    memcpy(adin.unixunion.unixdata,adin.entptr,SIZEOFDOUBLE);
    for (i=0; i<4; i++) {
      adin.unixchar=adin.unixunion.unixdata[i];
      adin.unixunion.unixdata[i]=adin.unixunion.unixdata[7-i];
      adin.unixunion.unixdata[7-i]=adin.unixchar;
    }
    adin.entptr+=SIZEOFDOUBLE;
    memcpy(a,&adin.unixunion.unixdoub,SIZEOFDOUBLE);
    a+=SIZEOFDOUBLE;
  }
}

void rd3real(a)
char *a;
{
  double r;
  short i,j;

  for (j=0; j<3; j++) {
    memcpy(adin.unixunion.unixdata,adin.entptr,SIZEOFDOUBLE);
    for (i=0; i<4; i++) {
      adin.unixchar=adin.unixunion.unixdata[i];
      adin.unixunion.unixdata[i]=adin.unixunion.unixdata[7-i];
      adin.unixunion.unixdata[7-i]=adin.unixchar;
    }
    adin.entptr+=SIZEOFDOUBLE;
    memcpy(a,&adin.unixunion.unixdoub,SIZEOFDOUBLE);
    a+=SIZEOFDOUBLE;
  }
}


short frdw()
{
  short i;

  i=(ad_getc(adin.dwgfiler SUBN) & 255);
  i+=(ad_getc(adin.dwgfiler SUBN)<<8);
  return(i);
}

long buf2long(lptr)
char *lptr;
{
  adin.unixunion.unixdata[3]=lptr[0];
  adin.unixunion.unixdata[2]=lptr[1];
  adin.unixunion.unixdata[1]=lptr[2];
  adin.unixunion.unixdata[0]=lptr[3];
  return(adin.unixunion.unixlong);
}

double buf2double(lptr)
char *lptr;
{
  adin.unixunion.unixdata[7]=lptr[0];
  adin.unixunion.unixdata[6]=lptr[1];
  adin.unixunion.unixdata[5]=lptr[2];
  adin.unixunion.unixdata[4]=lptr[3];
  adin.unixunion.unixdata[3]=lptr[4];
  adin.unixunion.unixdata[2]=lptr[5];
  adin.unixunion.unixdata[1]=lptr[6];
  adin.unixunion.unixdata[0]=lptr[7];
  return(adin.unixunion.unixdoub);
}

short buf2short(lptr)
char *lptr;
{
  adin.unixunion.unixdata[1]=lptr[0];
  adin.unixunion.unixdata[0]=lptr[1];
  return(adin.unixunion.unixshort);
}

#endif

#if defined(QUADWORDALIGNED) && !defined(BIGENDIAN)
double rdreal()
{
  double r;
  short i;

  memcpy(adin.unixunion.unixdata,adin.entptr,SIZEOFDOUBLE);
  adin.entptr+=SIZEOFDOUBLE;
  return(adin.unixunion.unixdoub);
}


void rd2real(a)
char *a;
{
  double r;
  short i,j;

  memcpy(a,adin.entptr,2*SIZEOFDOUBLE);
  adin.entptr+=2*SIZEOFDOUBLE;
}

void rd3real(a)
char *a;
{
  double r;
  short i,j;

  memcpy(a,adin.entptr,3*SIZEOFDOUBLE);
  adin.entptr+=3*SIZEOFDOUBLE;
}


long buf2long(lptr)
char *lptr;
{
  memcpy(adin.unixunion.unixdata,lptr,SIZEOFLONG);
  return(adin.unixunion.unixlong);
}

double buf2double(lptr)
char *lptr;
{
  memcpy(adin.unixunion.unixdata,lptr,SIZEOFDOUBLE);
  return(adin.unixunion.unixdoub);
}

short buf2short(lptr)
char *lptr;
{
  memcpy(adin.unixunion.unixdata,lptr,SIZEOFSHORT);
  return(adin.unixunion.unixshort);
}

#endif

