/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_save_block */
int dba_save_block (lib_ptr, block)
struct dba_library *lib_ptr;
long block;
{
  int status;
  long nd_block, ld_block, nd_byte, bytes;

  if (!lib_ptr->top_s_bl) {
    nd_block = lib_ptr->top_s_bl = lib_ptr->nd_s_bl = dba_add_block (lib_ptr);
    if (!nd_block) return (0);
    nd_byte = lib_ptr->nd_s_by = 4;
  }
  else {
    nd_block = lib_ptr->nd_s_bl;
    nd_byte = lib_ptr->nd_s_by;
  }
  if (nd_byte == 512) {
    ld_block = nd_block;
    nd_block = lib_ptr->nd_s_bl = dba_add_block (lib_ptr);

    bytes = (ld_block - 1) * 512;
    status = fseek (lib_ptr->ptr, bytes, 0);
    if (status) return (0);
    status = fwrite (&nd_block, 4, 1, lib_ptr->ptr);

    if (!nd_block) return (0);
    nd_byte = lib_ptr->nd_s_by = 4;
  }
  bytes = (nd_block - 1) * 512 + nd_byte;
  status = fseek (lib_ptr->ptr, bytes, 0);
  if (status) return (0);
  status = fwrite (&block, 4, 1, lib_ptr->ptr);
  lib_ptr->nd_s_by += 4;

  return (0);
}
