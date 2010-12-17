/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

static long index_count;

/* Function:  dba_get_lib_index
   Author:    Brian Potter
   Date:      20-MAR-1993
*/

int dba_get_lib_index (lib_ptr)
struct dba_library *lib_ptr;
{
  long size;

  index_count = 0;

  if (lib_ptr->top_i_bl)
    { size = lib_ptr->num_mod * sizeof (struct dba_lib_index);
    if (lib_ptr->size == 0)
      { lib_ptr->temps = (struct dba_lib_index *) dba_dmalloc (size, DM_OTHER);
      lib_ptr->size = size; }
    if (size > lib_ptr->size)
      lib_ptr->temps = (struct dba_lib_index *) dba_drealloc (lib_ptr->temps, 
        size);
    dba_get_indexes (lib_ptr, lib_ptr->top_i_bl); }

  lib_ptr->rebuild = 0;

  return (0);
}
/* Function:	dba_get_indexes */

int dba_get_indexes (lib_ptr, key_block)
struct dba_library *lib_ptr;
long key_block;
{
  char key[23];
  int status, key_byte;
  long data_block;
  struct dba_lib_index *index;
  unsigned char key_lng;
  unsigned short length, bytes_read, data_byte;
  unsigned long bytes, save;

  bytes = (key_block - 1) * 512;
  status = fseek (lib_ptr->ptr, bytes, 0);
  status = fread (&length, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&length);
  status = fseek (lib_ptr->ptr, 10, 1);
  bytes_read = 0;
read_key:
  if (bytes_read == length) return (0);
  key_byte = bytes_read + 12;
  status = fread (&data_block, 4, 1, lib_ptr->ptr);
  dba_int_swap_bytes (&data_block);
  status = fread (&data_byte, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&data_byte);
  status = fread (&key_lng, 1, 1, lib_ptr->ptr);
  bytes_read += 7;
  status = fread (key, key_lng, 1, lib_ptr->ptr);
  bytes_read += key_lng;
  key[key_lng] = 0;

  if (data_byte == 65535)
    { save = ftell (lib_ptr->ptr);
    dba_get_indexes (lib_ptr, data_block);
    status = fseek (lib_ptr->ptr, save, 0); }
  else
    { index = lib_ptr->temps + index_count;
    ++index_count;
    strncpy (index->key, key, 22);  index->key[22] = 0;
    index->key_block = key_block;
    index->key_byte = key_byte;
    index->data_block = data_block;
    index->data_byte = data_byte; }
  goto read_key;
}
