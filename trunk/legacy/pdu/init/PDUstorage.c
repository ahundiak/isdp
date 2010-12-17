#include	<stdio.h>
#include	<PDUstorage.h>
#include	<PDUfile_def.h>
#include	<PDUproto.h>

extern struct PDUstorage     *storage;

void PDUstorage_init()
  {

  if (storage == NULL)
    storage = (struct PDUstorage *) malloc (sizeof(struct PDUstorage));

  storage->storage_no = 0;
  storage->storage_name = NULL_STRING;
  storage->node_name = NULL_STRING;
  storage->user_name = NULL_STRING;
  storage->passwd = NULL_STRING;
  storage->path_name = NULL_STRING;
  }

