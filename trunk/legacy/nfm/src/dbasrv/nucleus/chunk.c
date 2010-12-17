/* $Revision: 1.1 $ */
#include "dba.ext"

#define CHUNKSIZE	32000L

/*
    Function:	dba_put_chunk
    Author:	Tim A. Thompson
    Date:	9-30-92
*/

int dba_put_chunk (lib, buf, size)
struct dba_library *lib;
char *buf;
long size;
{
  long bites, i, frag;
  int status;

  bites = size / CHUNKSIZE;
  for (i=0; i<bites; i++) {
    status = dba_put_record (lib, &buf[i*CHUNKSIZE], CHUNKSIZE);
    if (!status)
      return status;
  }
  frag = size % CHUNKSIZE;
  if (frag)
    return dba_put_record (lib, &buf[i*CHUNKSIZE], frag);
  return 1;
}


/*
    Function:	dba_get_chunk
    Author:	Tim A. Thompson
    Date:	9-30-92
*/

int dba_get_chunk (lib, buf, size)
struct dba_library *lib;
char *buf;
long size;
{
  long bites, i, frag;
  char *ptr;
  int status;

  bites = size / CHUNKSIZE;
  for (i=0; i<bites; i++) {
    ptr = &buf[i*CHUNKSIZE];
    status = dba_get_record (lib, &ptr, NP, NP, 1);
    if (!status)
      return status;
  }
  frag = size % CHUNKSIZE;
  if (frag) {
    ptr = &buf[i*CHUNKSIZE];
    return dba_get_record (lib, &ptr, NP, NP, 1);
  }
  return 1;
}
