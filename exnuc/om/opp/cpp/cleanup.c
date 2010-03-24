#include "mallocdbg.h"
#include "cpp.h"
#include "fio.h"


static void free_defines(tt)
struct define_symbol *tt;
 {
  struct cpp_token *ta,*tb;

  free (tt->symb.name);
  ta = tt->parameters;
  while (ta) { tb = ta->flink; free (ta); ta = tb; }
  ta = tt->define_tokens;
  while (ta) { tb = ta->flink; free (ta); ta = tb; }
  free (tt);
 }


static void free_symbol(tt)
struct symbol *tt;
 {
  free (tt->name);
  free (tt);
 }


void cpp_stream_close()
 {
  while (active_stream->filer_stack) fio_close();
  delete_symbol_table (active_stream->define_table,free_defines);
  delete_symbol_table (active_stream->omdef_table,free_omdef);
  delete_symbol_table (active_stream->file_table,free_symbol);
  free (active_stream);
  active_stream = 0;
 }


void free_everything()
 {
  cpp_stream_close();
  ff_free();
 }

