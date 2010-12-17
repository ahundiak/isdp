/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

#define DBA_REV1 3
#define DBA_REV2 2

extern int dba_library_timestamp, dba_rev1, dba_rev2, dba_slow_read,
  dba_first_turbo;

/* Function:	dba_lib_open 

Description: 	all text library read and write functions

Author: 	Brian Potter
*/
struct dba_library *dba_lib_open (filespec, mode)
char *filespec, *mode;
{
  char string[512];
  struct dba_library *lib_ptr;
  int status, add_to_list=0;
  char b_mode[16];
  FILE *fptr, *fopen();
  struct stat buf;
  static struct dba_library *flib, *llib;
#ifdef _MAC_
  int fn;
#endif

  if (strcmp (mode, "r") == 0) add_to_list = 1;

  strcpy(b_mode, mode);
  strcat(b_mode, "b");
  fptr = fopen (filespec, b_mode);
  if (!fptr) return (0);

#ifdef __hpux
  status = dba_file_lock (fptr->__fileL | fptr->__fileH << 8, mode);
#elif defined (_MAC_)
  fn = fileno (fptr);
  status = dba_file_lock (fn, mode);
#else
  status = dba_file_lock (fptr->_file, mode);
#endif
  if (status) 
    { fclose (fptr);
    return (0); }

  status = stat (filespec, &buf);

  for (lib_ptr=flib; lib_ptr; lib_ptr=lib_ptr->nlib)
    if (strcmp (lib_ptr->name, filespec) == 0) break;

  if (lib_ptr && lib_ptr->mtime == buf.st_mtime)
    { ++lib_ptr->open_num;
    if (lib_ptr->open_num > lib_ptr->open_size) 
      { ++lib_ptr->open_size;
      lib_ptr->ptr_a = dba_drealloc (lib_ptr->ptr_a, 4 * lib_ptr->open_size); }
    lib_ptr->ptr = lib_ptr->ptr_a[lib_ptr->open_num-1] = fptr;
    return (lib_ptr); }

  if (!lib_ptr)
    { dba_malloc_lib (&lib_ptr);
    if (add_to_list) 
      { dba_add_lib (&flib, &llib, lib_ptr);
      lib_ptr->listed = 1; }
    lib_ptr->name = dba_dstrdup (filespec, DM_MEMBER); }

  lib_ptr->open_num = 1;
  lib_ptr->ptr = lib_ptr->ptr_a[0] = fptr;
  lib_ptr->mtime = buf.st_mtime;
  lib_ptr->rebuild = 1;

  status = fread (string, 512, 1, lib_ptr->ptr);
  if (string[0] != 4 || string[1] != 1) return (0);
  dba_int_swap_bytes (&string[76]);
  memcpy (&lib_ptr->ld_bl, &string[76], 4);
  dba_short_swap_bytes (&string[80]);
  memcpy (&lib_ptr->ld_by, &string[80], 2);
  dba_int_swap_bytes (&string[82]);
  memcpy (&lib_ptr->nd_bl, &string[82], 4);
  dba_int_swap_bytes (&string[106]);
  memcpy (&lib_ptr->num_mod, &string[106], 4);
  dba_int_swap_bytes (&string[200]);
  memcpy (&lib_ptr->top_i_bl, &string[200], 4);
  dba_int_swap_bytes (&string[204]);
  memcpy (&lib_ptr->timestamp, &string[204], 4);
  dba_library_timestamp = lib_ptr->timestamp;
  dba_int_swap_bytes (&string[208]);
  memcpy (&lib_ptr->rev1, &string[208], 4);
  dba_rev1 = lib_ptr->rev1;
  dba_int_swap_bytes (&string[212]);
  memcpy (&lib_ptr->rev2, &string[212], 4);
  dba_rev2 = lib_ptr->rev2;

  dba_int_swap_bytes (&string[216]);
  memcpy (&lib_ptr->top_s_bl, &string[216], 4);
  dba_int_swap_bytes (&string[220]);
  memcpy (&lib_ptr->nd_s_bl, &string[220], 4);
  dba_short_swap_bytes (&string[224]);
  memcpy (&lib_ptr->nd_s_by, &string[224], 2);

  if (lib_ptr->rev1 > DBA_REV1 
    || (lib_ptr->rev1 == DBA_REV1 && lib_ptr->rev2 > DBA_REV2))
    dba_printf ("                        **** WARNING ****\n\n \
Accessing a %02d.%02d library with %02d.%02d software is NOT recommended.\n",
      lib_ptr->rev1, lib_ptr->rev2, DBA_REV1, DBA_REV2);

  return (lib_ptr);
}
/* Function:    dba_malloc_lib */
int dba_malloc_lib (lib_ptr)
struct dba_library **lib_ptr;
{
  *lib_ptr = (struct dba_library *) dba_dmalloc (sizeof (struct dba_library), 
    DM_OTHER);
  memset (*lib_ptr, 0, sizeof (struct dba_library));

  (*lib_ptr)->open_size = 1;
  (*lib_ptr)->ptr_a = dba_dcalloc (4, 1, DM_MEMBER);

  return (0);
}
/* Function:    dba_add_lib */
int dba_add_lib (flib, llib, lib)
struct dba_library **flib, **llib, *lib;
{
  if (!(*flib)) *flib = lib;
  else (*llib)->nlib = lib;

  lib->nlib = 0;
  *llib = lib;

  return (0);
}
/* Function:	dba_lib_close */
int dba_lib_close (lib_ptr)
struct dba_library *lib_ptr;
{
#ifdef _MAC_
  int fn;
#endif
#ifdef __hpux
  dba_file_unlock(lib_ptr->ptr->__fileL | lib_ptr->ptr->__fileH << 8);
#elif defined (_MAC_)
  fn = fileno (lib_ptr->ptr);
  dba_file_unlock (fn);
#else
  dba_file_unlock(lib_ptr->ptr->_file);
#endif
  fclose (lib_ptr->ptr);
  --lib_ptr->open_num;
  if (lib_ptr->open_num)
    lib_ptr->ptr = lib_ptr->ptr_a[lib_ptr->open_num-1];
  else
    lib_ptr->ptr = 0;

  if (!lib_ptr->listed) dba_free_library (&lib_ptr);
  return (0);
}
/* Function:	dba_free_library */
int dba_free_library (lib_ptr)
struct dba_library **lib_ptr;
{
  if ((*lib_ptr)->ptr_a) dba_dfree ((*lib_ptr)->ptr_a);
  if ((*lib_ptr)->name) dba_dfree ((*lib_ptr)->name);
  if ((*lib_ptr)->temps) dba_dfree ((*lib_ptr)->temps);
  dba_dfree (*lib_ptr);
  *lib_ptr = 0;

  return (0);
}
/* Function:	dba_lookup_key */
int dba_lookup_key (lib_ptr, key_ptr, type, time_val)
struct dba_library *lib_ptr;
char *key_ptr;
int type;
time_t *time_val;
{
  char name[31];
  int status, itype, s_byte, key_lng, k_byte;
  long bytes, k_block, block;

  switch (type) { 
    case DATBAS:  case USERDATA:  case ASCII:  case BINARY:
      itype = 0;  break;
    case UD_S:  case ASC_S:  case BIN_S:
      itype = ALL_STR;  break;
    default:
      itype = type;  break; 
  }
  strncpy (name, key_ptr, 30);
  name[30] = 0;
  dba_pad_string (name, 20, ' ');
  sprintf (&name[20], "%2d", itype);
  status = dba_turbo_get_index (lib_ptr, name, &key_lng, &k_block, &k_byte, 
    &block, &s_byte);
  if (!status) { 
    status = dba_turbo_get_index (lib_ptr, key_ptr, &key_lng, 
      &k_block, &k_byte, &block, &s_byte);
    if (status) { 
/* this caused crash on older libs 1/6/93 blp
      status = dba_get_template_type (lib_ptr, block, s_byte, &old_type);
      status = dba_delete_key (lib_ptr, key_ptr, old_type, 0);
      switch (old_type) { 
        case DATBAS:  case USERDATA:  case ASCII:  case BINARY:
          old_type = 0;  break;
        case UD_S:  case ASC_S:  case BIN_S:
          old_type = ALL_STR;  break; 
      }
      sprintf (&name[20], "%2d", old_type);
      status = dba_update_index (lib_ptr, name, block, k_block, k_byte); 
      ++lib_ptr->num_mod;
      dba_update_hdr (lib_ptr);
      if (old_type != itype) return (0); 
*/
    }
    else {
/* 3/19/93 blp - this key was only created for a brief uncertified period
      { sprintf (&name[20], "%2d", type);
      status = dba_turbo_get_index (lib_ptr, name, &key_lng, 
        &k_block, &k_byte, &block, &s_byte);
      if (!status) return (0); } }
*/
      return (0); 
    }
  }
  bytes = (block - 1) * 512 + s_byte + 14;
  if (s_byte >= 494) bytes += 6;
  status = fseek (lib_ptr->ptr, bytes, 0);
  if (status) return (0);
  if (time_val)
    { status = fread (time_val, 4, 1, lib_ptr->ptr);
    dba_int_swap_bytes (time_val); }
  else
    status = fseek (lib_ptr->ptr, 4, 1);  

  ++dba_first_turbo;
  dba_get_record (NP,NP,NP,NP,1);

  return (1);
}
/* Function:	dba_insert_key */
int dba_insert_key (lib_ptr, key_ptr, time_val, type)
struct dba_library *lib_ptr;
char *key_ptr;
time_t time_val;
int type;
{
  char name[30];
  int status;
  long itmp, bytes, nd_block;
  static char hdr_ptr[] = { 16,0,0,-83,0,0,1,0,0,0,0,0,0,0 };

  nd_block = dba_add_block (lib_ptr);  if (!nd_block) return (0);
  bytes = (nd_block - 1) * 512 + 6;
  status = fseek (lib_ptr->ptr, bytes, 0);  if (status) return (0);
  status = fwrite (hdr_ptr, 14, 1, lib_ptr->ptr);
  if (!time_val) time (&time_val);
  dba_int_swap_copy (&itmp, &time_val);
  status = fwrite (&itmp, 4, 1, lib_ptr->ptr);
  dba_update_rcnt (lib_ptr);

  switch (type)
    { case DATBAS:  case USERDATA:  case ASCII:  case BINARY:
      type = 0;  break;
    case UD_S:  case ASC_S:  case BIN_S:
      type = ALL_STR;  break; }

  strcpy (name, key_ptr);
  dba_pad_string (name, 20, ' ');
  sprintf (&name[20], "%2d", type);
  if (lib_ptr->rev1 < DBA_REV1 
    || (lib_ptr->rev1 == DBA_REV1 && lib_ptr->rev2 < DBA_REV2))
    { lib_ptr->rev1 = DBA_REV1;
    lib_ptr->rev2 = DBA_REV2; }
  dba_put_end (NP, name, nd_block);

  return (1);
}
/* Function:	dba_delete_key */
int dba_delete_key (lib_ptr, key_ptr, type, save_block)
struct dba_library *lib_ptr;
char *key_ptr;
int type, save_block;
{
  char name[30], string[512];
  int status, itype, k_byte, s_byte, key_lng;
  long bytes, w_bytes, k_block, block;
  short length, stmp;

  switch (type)
    { case DATBAS:  case USERDATA:  case ASCII:  case BINARY:
      itype = 0;  break;
    case UD_S:  case ASC_S:  case BIN_S:
      itype = ALL_STR;  break;
    default:
      itype = type;  break; }

  strcpy (name, key_ptr);
  dba_pad_string (name, 20, ' ');
  sprintf (&name[20], "%2d", itype);
  status = dba_turbo_get_index (lib_ptr, name, &key_lng, &k_block, &k_byte,
    &block, &s_byte);
  if (!status)
    { status = dba_turbo_get_index (lib_ptr, key_ptr, &key_lng, 
      &k_block, &k_byte, &block, &s_byte);
    if (!status) 
/* 3/19/93 blp - this key was only created for a brief uncertified period
      { sprintf (&name[20], "%2d", type);
        status = dba_turbo_get_index (lib_ptr, name, &key_lng, 
          &k_block, &k_byte, &block, &s_byte);
        if (!status) return (0); } }
*/
      return (0); }

  bytes = (k_block - 1) * 512;
  status = fseek (lib_ptr->ptr, bytes, 0);  if (status) return (0);
  status = fread (&length, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&length);
  length = length - 7 - key_lng;
  status = fseek (lib_ptr->ptr, -2, 1);  if (status) return (0);
  dba_short_swap_copy (&stmp, &length);
  status = fwrite (&stmp, 2, 1, lib_ptr->ptr);
  bytes = k_byte + 7 + key_lng - 2;
  status = fseek (lib_ptr->ptr, bytes, 1);  if (status) return (0);
  w_bytes = 510 - bytes;
  status = fread (string, (int) w_bytes, 1, lib_ptr->ptr);
  bytes = (w_bytes + 7 + key_lng) * -1;
  status = fseek (lib_ptr->ptr, bytes, 1);  if (status) return (0);
  status = fwrite (string, (int) w_bytes, 1, lib_ptr->ptr);
  --lib_ptr->num_mod;
  if (!lib_ptr->num_mod) lib_ptr->top_i_bl = 0;
  if (save_block)
    dba_save_block (lib_ptr, block);
  dba_update_hdr (lib_ptr);

  return (1);
}
/* Function:	dba_turbo_get_record */
int dba_turbo_get_record (lib_ptr, text_ptr, maxlng, lng, binary)
struct dba_library *lib_ptr;
char **text_ptr;
unsigned long *maxlng, *lng;
int binary;
{
  char *libbuf;
  int status;
  long bytes_left, bytes_read;
  short rec_lng, next_bytes;
  unsigned long buflng, offset, blocks;
  static char **libbuf_a;
  static short *eor_a, nested, size, *loaded_a;
  static unsigned long *buflng_a, *bufsiz_a, *offset_a, *blocks_a;

  if (dba_first_turbo != nested)
    { nested = dba_first_turbo;
    if (!libbuf_a)
      { libbuf_a = (char **) dba_dcalloc (4, 1, DM_STATIC);
      eor_a = (short *) dba_dcalloc (2, 1, DM_STATIC);
      loaded_a = (short *) dba_dcalloc (2, 1, DM_STATIC);
      buflng_a = (unsigned long *) dba_dcalloc (4, 1, DM_STATIC);
      bufsiz_a = (unsigned long *) dba_dcalloc (4, 1, DM_STATIC);
      offset_a = (unsigned long *) dba_dcalloc (4, 1, DM_STATIC);
      blocks_a = (unsigned long *) dba_dcalloc (4, 1, DM_STATIC); 
      size = 1; }
    else if (nested > size)
      { size = nested;
      libbuf_a = (char **) dba_drealloc (libbuf_a, 4 * nested);
      libbuf_a[nested-1] = 0;
      eor_a = (short *) dba_drealloc (eor_a, 2 * nested);
      loaded_a = (short *) dba_drealloc (loaded_a, 2 * nested);
      loaded_a[nested-1] = 0;
      buflng_a = (unsigned long *) dba_drealloc (buflng_a, 4 * nested);
      bufsiz_a = (unsigned long *) dba_drealloc (bufsiz_a, 4 * nested);
      offset_a = (unsigned long *) dba_drealloc (offset_a, 4 * nested);
      blocks_a = (unsigned long *) dba_drealloc (blocks_a, 4 * nested); } }

  if (!lib_ptr && binary == 1)
    { loaded_a[dba_first_turbo - 1] = 0;
    eor_a[dba_first_turbo - 1] = 0;
    return (0); }
  if (!lib_ptr && binary == 2)
    { eor_a[nested-1] = 1;
    --nested;
    --dba_first_turbo;
    return (0); }

  if (eor_a[nested-1]) return (0);

  if (!loaded_a[nested-1])
    { loaded_a[nested-1] = 1;
    eor_a[nested-1] = 0;
    status = fseek (lib_ptr->ptr, -8, 1);  if (status) return (0);
    status = fread (&blocks_a[nested-1], 4, 1, lib_ptr->ptr);
    status = fseek (lib_ptr->ptr, -20, 1);  if (status) return (0);
    if (!blocks_a[nested-1] || blocks_a[nested-1] > 1000)
      blocks_a[nested-1] = 20;
    if (!libbuf_a[nested-1])
      { bufsiz_a[nested-1] = blocks_a[nested-1] * 512;
      libbuf_a[nested-1] = dba_dmalloc (bufsiz_a[nested-1], DM_STATIC); }
    if (blocks_a[nested-1] * 512 > bufsiz_a[nested-1])
      { bufsiz_a[nested-1] = blocks_a[nested-1] * 512;
      libbuf_a[nested-1] = dba_drealloc (libbuf_a[nested-1], 
        bufsiz_a[nested-1]); }
    status = fread (libbuf_a[nested-1], 512, blocks_a[nested-1], lib_ptr->ptr); 
    buflng_a[nested-1] = blocks_a[nested-1] * 512;
    offset_a[nested-1] = 24; }

  libbuf = libbuf_a[nested-1];
  buflng = buflng_a[nested-1];
  offset = offset_a[nested-1];
  blocks = blocks_a[nested-1];

  bytes_left = 512 - (offset % 512);
  if (bytes_left == 512) bytes_left = 0;
  if (!bytes_left)
    { if (offset == buflng)
      { status = fread (libbuf, 512, blocks, lib_ptr->ptr);
      offset = 0; }
    offset += 6; }

  memcpy (&rec_lng, &libbuf[offset], 2);  offset += 2;
  dba_short_swap_bytes (&rec_lng);
  if (lng) *lng = rec_lng;
  if (rec_lng % 2) ++rec_lng;
  if (!binary && rec_lng + 1 > *maxlng)
    { *maxlng = rec_lng + 1;
    *text_ptr = dba_drealloc (*text_ptr, *maxlng); }
  bytes_left = 512 - (offset % 512);
  if (bytes_left == 512) bytes_left = 0;
  if (bytes_left < rec_lng)
    { next_bytes = rec_lng - bytes_left;  rec_lng = bytes_left; }
  else next_bytes = 0;
  if (rec_lng)
    { memcpy (*text_ptr, &libbuf[offset], rec_lng);
    offset += rec_lng; }
  bytes_read = rec_lng;
  while (next_bytes)
    { if (offset == buflng)
      { status = fread (libbuf, 512, blocks, lib_ptr->ptr);
      offset = 0; }
    offset += 6;
    if (next_bytes > 506) rec_lng = 506;
    else rec_lng = next_bytes;
    next_bytes -= rec_lng;
    memcpy (&(*text_ptr)[bytes_read], &libbuf[offset], rec_lng);
    offset += rec_lng;
    bytes_read += rec_lng; }
  if (bytes_read == 4
    && (*text_ptr)[0] == 119 && (*text_ptr)[1] == 0 && (*text_ptr)[2] == 119)
    { (*text_ptr)[0] = 0;
    eor_a[nested-1] = 1;
    --nested;
    --dba_first_turbo;
    return (0); }
  if (!binary) (*text_ptr)[bytes_read] = 0;

  offset_a[nested-1] = offset;

  return (1);
}
/* Function:	dba_put_record */
int dba_put_record (lib_ptr, text_ptr, lng)
struct dba_library *lib_ptr;
char *text_ptr;
unsigned long lng;
{
  int status;
  long length, bytes, block, nd_block;
  short rec_lng, stmp;

  bytes = ftell (lib_ptr->ptr);
  block = (bytes - 1) / 512 + 1;
  bytes %= 512;  if (bytes) bytes = 512 - bytes;
  if (!lng) rec_lng = length = strlen (text_ptr);
  else rec_lng = length = lng;
  if (length % 2) ++length;
  if (bytes < 2)
    { nd_block = dba_add_block (lib_ptr);  if (!nd_block) return (0);
    dba_to_master (lib_ptr, block, nd_block);
    bytes = (nd_block - 1) * 512 + 6;
    status = fseek (lib_ptr->ptr, bytes, 0);  if (status) return (0);
    bytes = 506; }
  dba_short_swap_copy (&stmp, &rec_lng);
  status = fwrite (&stmp, 2, 1, lib_ptr->ptr);  bytes -= 2;
  while (bytes < length)
    { dba_update_rcnt (lib_ptr);
    status = fwrite (text_ptr, (int) bytes, 1, lib_ptr->ptr);
    nd_block = dba_add_block (lib_ptr);
    if (!nd_block) return (0);
    block = nd_block;
    text_ptr += bytes;  length -= bytes;
    bytes = (nd_block - 1) * 512 + 6;
    status = fseek (lib_ptr->ptr, bytes, 0); 
    bytes = 506; }
  status = fwrite (text_ptr, (int) length, 1, lib_ptr->ptr);
  dba_update_rcnt (lib_ptr);
  return (1);
}
/* Function:	dba_put_end */
int dba_put_end (lib_ptr, key_ptr, data_block)
struct dba_library *lib_ptr;
char *key_ptr;
long data_block;
{
  char *text_ptr;
  int length=5, status, key_lng, k_byte, s_byte;
  long bytes, block, nd_block, k_block, blocks, itmp;
  static char key[30], string[5] = { 3, 0, 119, 0, 119 };
  static long dblock;

  if (!lib_ptr)
    { strcpy (key, key_ptr);
    dblock = data_block;
    return (0); }

  text_ptr = string;
  bytes = ftell (lib_ptr->ptr);
  block = lib_ptr->ld_bl = (bytes - 1) / 512 + 1;
  lib_ptr->ld_by = bytes % 512;
  if (lib_ptr->ld_by) bytes = 512 - lib_ptr->ld_by;  else bytes = 0;
  lib_ptr->ld_by += 6;
  if (bytes < 5)
    { dba_update_rcnt (lib_ptr);
    status = fwrite (text_ptr, (int) bytes, 1, lib_ptr->ptr);
    nd_block = dba_add_block (lib_ptr);
    if (!nd_block) return (0);
    text_ptr += bytes;
    length -= bytes;
    lib_ptr->ld_bl = nd_block;
    lib_ptr->ld_by = length + 1;
    dba_to_master (lib_ptr, block, nd_block);
    bytes = (nd_block - 1) * 512 + 6;
    status = fseek (lib_ptr->ptr, bytes, 0); }
  status = fwrite (text_ptr, length, 1, lib_ptr->ptr);
  dba_update_rcnt (lib_ptr);
  dba_update_hdr (lib_ptr);

  blocks = lib_ptr->ld_bl - dblock + 1;
  bytes = (dblock - 1) * 512 + 16;
  status = fseek (lib_ptr->ptr, bytes, 0);
  if (status) return (0);
  dba_int_swap_copy (&itmp, &blocks);
  status = fwrite (&itmp, 4, 1, lib_ptr->ptr);

  if (lib_ptr->top_i_bl)
    { status = dba_get_index (lib_ptr, key, &key_lng, &k_block, &k_byte, 
      &block, &s_byte);
    if (status) return (0); }
  else
    { k_block = dba_add_block (lib_ptr);
    k_byte = 12;
    lib_ptr->top_i_bl = k_block;
    dba_update_hdr (lib_ptr); }

  dba_update_index (lib_ptr, key, dblock, k_block, k_byte);
  ++lib_ptr->num_mod;
  dba_update_hdr (lib_ptr);

  return (1);
}
/* Function:	dba_turbo_get_index */
int dba_turbo_get_index (lib_ptr, key_ptr, key_lng, key_block, key_byte, 
  data_block, data_byte)
struct dba_library *lib_ptr;
char *key_ptr;
int *key_byte, *data_byte, *key_lng;
long *key_block, *data_block;
{
  int cnt;
  struct dba_lib_index *index;

  if (lib_ptr->rebuild) dba_get_lib_index (lib_ptr);

  dba_upper (key_ptr);

  for (cnt=0; cnt < lib_ptr->num_mod; ++cnt)
    { index = lib_ptr->temps + cnt;
    if (strcmp (key_ptr, index->key) == 0)
      { *key_lng = strlen (key_ptr);
      *key_block = index->key_block;
      *key_byte = index->key_byte;
      *data_block = index->data_block;
      *data_byte = index->data_byte;
      return (1); } }

  return (0);
}
/* Function:	dba_get_index */
int dba_get_index (lib_ptr, key_ptr, key_lng, key_block, key_byte, 
  data_block, data_byte)
struct dba_library *lib_ptr;
char *key_ptr;
int *key_byte, *data_byte, *key_lng;
long *key_block, *data_block;
{
  char key[50], temp_key[50];
  unsigned char ckey_lng;
  int status;
  unsigned short length, k_byte, s_byte;
  long bytes, bytes_read, k_block, block;

  dba_upper (key_ptr);

  k_block = lib_ptr->top_i_bl;
  bytes = (k_block - 1) * 512;
  status = fseek (lib_ptr->ptr, bytes, 0);  if (status) return (0);
read_blk:
  status = fread (&length, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&length);
  if (status != 1) return (0);
  if (length == 0)
    { *key_block = k_block;  *key_byte = 12;  return (0); }
  status = fseek (lib_ptr->ptr, 10, 1);  if (status) return (0);
  bytes_read = 0;
read_key:
  k_byte = bytes_read + 12;
  status = fread (&block, 4, 1, lib_ptr->ptr);
  dba_int_swap_bytes (&block);
  if (status != 1) return (0);
  status = fread (&s_byte, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&s_byte);
  if (status != 1) return (0);
  status = fread (&ckey_lng, 1, 1, lib_ptr->ptr);
  if (status != 1) return (0);
  *key_lng = ckey_lng;
  bytes_read += 7;
  status = fread (key, ckey_lng, 1, lib_ptr->ptr);
  if (status!=1) return (0);  
  bytes_read += ckey_lng;
  key[ckey_lng] = 0;

  strcpy (temp_key, key);
  while (temp_key[strlen (temp_key) - 1] == ' ')
    temp_key[strlen (temp_key) - 1] = 0;

  status = strcmp (temp_key, key_ptr);
  if (status >= 0 && s_byte == 65535) 
    { bytes = (block - 1) * 512;
    status = fseek (lib_ptr->ptr, bytes, 0);  if (status) return (0);
    k_block = block;  goto read_blk; }
  else if (status == 0)
    { *key_block = k_block;  *key_byte = k_byte;
    *data_block = block;  *data_byte = s_byte;
    return (1); }
  else if (status > 0)
    { *key_block = k_block;  *key_byte = k_byte;  return (0); }
  else if (bytes_read == length && s_byte == 65535)
    { bytes = (block - 1) * 512;
    status = fseek (lib_ptr->ptr, bytes, 0);  if (status) return (0);
    k_block = block;  goto read_blk; }
  else if (bytes_read == length)
    { *key_block = k_block;  *key_byte = k_byte + ckey_lng + 7;  return (0); }
  goto read_key;
}
/* Function:	dba_add_block */
int dba_add_block (lib_ptr)
struct dba_library *lib_ptr;
{
  char string[512];
  int next_block, status;

  memset (string, 0, 512);
  status = fseek (lib_ptr->ptr, 0, 2);
  if (status) return (0);
  status = fwrite (string, 512, 1, lib_ptr->ptr);
  if (status != 1) return (0);
  else
    { next_block = lib_ptr->nd_bl;
    ++lib_ptr->nd_bl;
    dba_update_hdr (lib_ptr);
    return (next_block); }
}
/* Function:	dba_update_rcnt */
int dba_update_rcnt (lib_ptr)
struct dba_library *lib_ptr;
{
  int status;
  long bytes;
  short records;

  bytes = (ftell (lib_ptr->ptr) % 512) * -1;
  if (!bytes) bytes = -512;
  status = fseek (lib_ptr->ptr, bytes, 1);
  status = fread (&records, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&records);
  ++records;
  status = fseek (lib_ptr->ptr, -2, 1);
  dba_short_swap_bytes (&records);
  status = fwrite (&records, 2, 1, lib_ptr->ptr);
  bytes = (bytes * -1) - 2;
  status = fseek (lib_ptr->ptr, bytes, 1);
  return (1);
}
/* Function:	dba_update_hdr */
int dba_update_hdr (lib_ptr)
struct dba_library *lib_ptr;
{
  char string[512];
  int status;

  status = fseek (lib_ptr->ptr, 0, 0);
  status = fread (string, 512, 1, lib_ptr->ptr);
  dba_int_swap_copy (&string[76], &lib_ptr->ld_bl);
  dba_short_swap_copy (&string[80], &lib_ptr->ld_by);
  dba_int_swap_copy (&string[82], &lib_ptr->nd_bl);
  dba_int_swap_copy (&string[106], &lib_ptr->num_mod);
  memcpy (&string[110], &string[106], 4);
  memcpy (&string[116], &string[106], 4);
  dba_int_swap_copy (&string[200], &lib_ptr->top_i_bl);
  dba_int_swap_copy (&string[204], &lib_ptr->timestamp);
  dba_int_swap_copy (&string[208], &lib_ptr->rev1);
  dba_int_swap_copy (&string[212], &lib_ptr->rev2);
  dba_int_swap_copy (&string[216], &lib_ptr->top_s_bl);
  dba_int_swap_copy (&string[220], &lib_ptr->nd_s_bl);
  dba_short_swap_copy (&string[224], &lib_ptr->nd_s_by);
  status = fseek (lib_ptr->ptr, 0, 0);
  status = fwrite (string, 512, 1, lib_ptr->ptr);
  return (1);
}
/* Function:	dba_update_index */
int dba_update_index (lib_ptr, key_ptr, nd_block, k_block, k_byte)
struct dba_library *lib_ptr;
char *key_ptr;
long nd_block, k_block;
int k_byte;
{
  char s1[600], key_lng, key1[50], key2[50], zero_out=0;
  long bytes, ni_block=0, status, count, m_block;
  short length, lng1=0, lng2=0, max1=0, max2=0, nd_byte=6, stmp;

  bytes = (k_block - 1) * 512;
  status = fseek (lib_ptr->ptr, bytes, 0);
  status = fread (&length, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&length);
  key_lng = strlen (key_ptr);  length += 7 + key_lng;
  status = fread (&m_block, 4, 1, lib_ptr->ptr);
  dba_int_swap_bytes (&m_block);
  status = fseek (lib_ptr->ptr, 6, 1);
  status = fread (s1, 500, 1, lib_ptr->ptr);
  dba_int_swap_copy (&s1[k_byte - 12], &nd_block);
  dba_short_swap_copy (&s1[k_byte - 8], &nd_byte);
  memcpy (&s1[k_byte - 6], &key_lng, 1);
  memcpy (&s1[k_byte - 5], key_ptr, key_lng);
  bytes = 512 - k_byte;
  status = fseek (lib_ptr->ptr, -(bytes), 1);
  status = fread (&s1[k_byte - 5 + key_lng], (int) bytes, 1, 
    lib_ptr->ptr);
  if (length > 500) max1 = length / 2;  else max1 = length;
  while (lng1 < max1)
    { lng1 += 6;  key_lng = s1[lng1];
    lng1 += 1;  memcpy (key1, &s1[lng1], key_lng);
    key1[key_lng] = 0;  lng1 += key_lng; }
  status = fseek (lib_ptr->ptr, -512, 1);
  dba_short_swap_copy (&stmp, &lng1);
  status = fwrite (&stmp, 2, 1, lib_ptr->ptr);
  status = fseek (lib_ptr->ptr, 10, 1);
  status = fwrite (s1, lng1, 1, lib_ptr->ptr);
  for (count=lng1; count<500; ++count)
    status = fwrite (&zero_out, 1, 1, lib_ptr->ptr);
  max2 = length - lng1;
  if (max2)
    { while (lng2 < max2)
      { lng2 += 6;  key_lng = s1[lng1 + lng2];
      lng2 += 1;  memcpy (key2, &s1[lng1 + lng2], key_lng);
      key2[key_lng] = 0;  lng2 += key_lng; }
    ni_block = dba_add_block (lib_ptr);  if (!ni_block) return (0);
    bytes = (ni_block - 1) * 512;
    status = fseek (lib_ptr->ptr, bytes, 0);
    dba_short_swap_copy (&stmp, &lng2);
    status = fwrite (&stmp, 2, 1, lib_ptr->ptr);
    status = fseek (lib_ptr->ptr, 10, 1);
    status = fwrite (&s1[lng1], lng2, 1, lib_ptr->ptr); }
  if (lng2 && !m_block) m_block = dba_add_block (lib_ptr);
  if (k_block) dba_to_master (lib_ptr, k_block, m_block);
  if (ni_block) dba_to_master (lib_ptr, ni_block, m_block);
  if (m_block)
    dba_update_master (lib_ptr, m_block, k_block, key1, ni_block, key2);
  return (0);
}
/* Function:	dba_to_master */
int dba_to_master (lib_ptr, block, m_block)
struct dba_library *lib_ptr;
long block, m_block;
{
  int status;
  long bytes, itmp;
  
  bytes = (block - 1) * 512 + 2;
  status = fseek (lib_ptr->ptr, bytes, 0);
  dba_int_swap_copy (&itmp, &m_block);
  status = fwrite (&itmp, 4, 1, lib_ptr->ptr);
  return (0);
}
/* Function:	dba_update_master */
int dba_update_master (lib_ptr, m_block, block1, key1, block2, key2)
struct dba_library *lib_ptr;
char *key1, *key2;
long m_block, block1, block2;
{
  char key_lng, s1[600], key[50];
  int status;
  long bytes, b_read, block=0, this_block=m_block, ni_block=0, itmp;
  short length, lng1=0, lng2=0, max1=0, max2=0, stmp;
  unsigned short neg_word=65535, ustmp;

  bytes = (this_block - 1) * 512;
  status = fseek (lib_ptr->ptr, bytes, 0);
  status = fread (&length, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&length);
  status = fread (&m_block, 4, 1, lib_ptr->ptr);
  dba_int_swap_bytes (&m_block);
  if (!length)
    { length = 14 + strlen (key1) + strlen (key2);
    status = fseek (lib_ptr->ptr, -6, 1);
    dba_short_swap_copy (&stmp, &length);
    status = fwrite (&stmp, 2, 1, lib_ptr->ptr);
    status = fseek (lib_ptr->ptr, 10, 1);
    dba_int_swap_copy (&itmp, &block1);
    status = fwrite (&itmp, 4, 1, lib_ptr->ptr);
    dba_short_swap_copy (&ustmp, &neg_word);
    status = fwrite (&ustmp, 2, 1, lib_ptr->ptr);
    key_lng = strlen (key1);
    status = fwrite (&key_lng, 1, 1, lib_ptr->ptr);
    status = fwrite (key1, key_lng, 1, lib_ptr->ptr);
    dba_int_swap_copy (&itmp, &block2);
    status = fwrite (&itmp, 4, 1, lib_ptr->ptr);
    dba_short_swap_copy (&ustmp, &neg_word);
    status = fwrite (&ustmp, 2, 1, lib_ptr->ptr);
    key_lng = strlen (key2);
    status = fwrite (&key_lng, 1, 1, lib_ptr->ptr);
    status = fwrite (key2, key_lng, 1, lib_ptr->ptr);
    lib_ptr->top_i_bl = this_block;  dba_update_hdr (lib_ptr);  return (0); }
  status = fseek (lib_ptr->ptr, 6, 1);
  status = fread (s1, 500, 1, lib_ptr->ptr);
  status = fseek (lib_ptr->ptr, -500, 1);
  b_read = 0;
  while (block != block1)
    { status = fread (&block, 4, 1, lib_ptr->ptr);
    dba_int_swap_bytes (&block);
    status = fseek (lib_ptr->ptr, 2, 1);
    status = fread (&key_lng, 1, 1, lib_ptr->ptr);
    status = fread (key, key_lng, 1, lib_ptr->ptr);
    key[key_lng] = 0;
    b_read += 7 + key_lng; }
  length -= b_read;
  if (strcmp (key, key1) != 0)
    { b_read -= key_lng + 1;
    key_lng = strlen (key1);
    memcpy (&s1[b_read], &key_lng, 1);
    memcpy (&s1[b_read + 1], key1, key_lng);
    b_read += 1 + key_lng; }
  if (block2)
    { dba_int_swap_copy (&s1[b_read], &block2);
    b_read += 4;
    dba_short_swap_copy (&s1[b_read], &neg_word);
    b_read += 2;
    key_lng = strlen (key2);
    memcpy (&s1[b_read], &key_lng, 1);
    b_read += 1;
    memcpy (&s1[b_read], key2, key_lng);
    b_read += key_lng; }
  status = fread (&s1[b_read], length, 1, lib_ptr->ptr);
  b_read += length;  length = b_read;
  if (length > 500) max1 = length / 2;
  else max1 = length;
  while (lng1 < max1)
    { lng1 += 6;  key_lng = s1[lng1];
    lng1 += 1;  memcpy (key1, &s1[lng1], key_lng);
    key1[key_lng] = 0;  lng1 += key_lng; }
  status = fseek (lib_ptr->ptr, bytes, 0);
  dba_short_swap_copy (&stmp, &lng1);
  status = fwrite (&stmp, 2, 1, lib_ptr->ptr);
  status = fseek (lib_ptr->ptr, 10, 1);
  status = fwrite (s1, lng1, 1, lib_ptr->ptr);
  max2 = length - lng1;
  if (max2)
    { ni_block = dba_add_block (lib_ptr);  if (!ni_block) return (0);
    if (!m_block)
      { m_block = dba_add_block (lib_ptr);  if (!m_block) return (0); }
    while (lng2 < max2)
      { dba_int_swap_copy (&block, &s1[lng1 + lng2]);
      lng2 += 6;
      dba_to_master (lib_ptr, block, ni_block);
      key_lng = s1[lng1 + lng2];  lng2 += 1;
      memcpy (key2, &s1[lng1 + lng2], key_lng);
      key2[key_lng] = 0;  lng2 += key_lng; }
    bytes = (ni_block - 1) * 512;
    status = fseek (lib_ptr->ptr, bytes, 0);
    dba_short_swap_copy (&stmp, &lng2);
    status = fwrite (&stmp, 2, 1, lib_ptr->ptr);
    status = fseek (lib_ptr->ptr, 10, 1);
    status = fwrite (&s1[lng1], lng2, 1, lib_ptr->ptr);
    dba_to_master (lib_ptr, ni_block, m_block); }
  if (m_block) 
    { dba_to_master (lib_ptr, this_block, m_block);
    dba_update_master (lib_ptr, m_block, this_block, key1, ni_block, key2); }
  return (0);
}
/* Function:	dba_get_record */
int dba_get_record (lib_ptr, text_ptr, maxlng, lng, binary)
struct dba_library *lib_ptr;
char **text_ptr;
unsigned long *maxlng, *lng;
int binary;
{
  int status, mode, no_next_block=0;
  short rec_lng, next_bytes;
  long bytes=0, bytes_left, nd_block, bytes_read;

  if (!dba_slow_read)
    { status = dba_turbo_get_record (lib_ptr, text_ptr, maxlng, lng, binary);
    return (status); }
  else if (!lib_ptr) return (0);

  bytes_left = 512 - (ftell (lib_ptr->ptr)) % 512;
  if (bytes_left == 512)
    { status = fseek (lib_ptr->ptr, -510, 1);  if (status) return (0);
    status = fread (&nd_block, 4, 1, lib_ptr->ptr);
    dba_int_swap_bytes (&nd_block);
    if (nd_block)
      { bytes = (nd_block - 1) * 512 + 6;  mode = 0; }
    else 
      { no_next_block = 1;  bytes = 512;  mode = 1; }
    status = fseek (lib_ptr->ptr, bytes, mode);
    if (status) return (0); }
read_rec_lng:
  status = fread (&rec_lng, 2, 1, lib_ptr->ptr);
  dba_short_swap_bytes (&rec_lng);
  if (status != 1) return (0);
  if (lng) *lng = rec_lng;
  if (!rec_lng) 
    { if (!no_next_block)
      { (*text_ptr)[0] = 0;  return (1); }
    else
      { status = fseek (lib_ptr->ptr, 510, 1);  if (status) return (0);
      no_next_block = 0;  goto read_rec_lng; } }
  if (rec_lng % 2) ++rec_lng;
  if (!binary && rec_lng + 1 > *maxlng)
    { *maxlng = rec_lng + 1;
    *text_ptr = dba_drealloc (*text_ptr, *maxlng); }
  bytes_left = 512 - (ftell (lib_ptr->ptr)) % 512;
  if (bytes_left == 512) bytes_left = 0;
  if (bytes_left < rec_lng)
    { next_bytes = rec_lng - bytes_left;  rec_lng = bytes_left; }
  else next_bytes = 0;
  if (rec_lng)
    { status = fread (*text_ptr, rec_lng, 1, lib_ptr->ptr);
    if (status != 1) return (0); }
  bytes_read = rec_lng;
  while (next_bytes)
    { status = fseek (lib_ptr->ptr, -510, 1);  if (status) return (0);
    status = fread (&nd_block, 4, 1, lib_ptr->ptr);
    dba_int_swap_bytes (&nd_block);
    if (nd_block)
      { bytes = (nd_block - 1) * 512 + 6;  mode = 0; }
    else 
      { bytes = 512;  mode = 1; }
    status = fseek (lib_ptr->ptr, bytes, mode);  if (status) return (0);

    if (next_bytes > 506) rec_lng = 506;
    else rec_lng = next_bytes;
    next_bytes -= rec_lng;
    status = fread (&(*text_ptr)[bytes_read], rec_lng, 1, lib_ptr->ptr);
    if (status != 1) return (0);
    bytes_read += rec_lng; }
  if (bytes_read == 4
    && (*text_ptr)[0] == 119 && (*text_ptr)[1] == 0 && (*text_ptr)[2] == 119)
    { status = fseek (lib_ptr->ptr, -6, 1);
    (*text_ptr)[0] = 0;  return (0); }
  if (!binary) (*text_ptr)[bytes_read] = 0;

  return (1);
}
