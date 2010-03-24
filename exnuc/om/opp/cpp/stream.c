#include "cpp.h"
#include "fio.h"

void cpp_deactivate ()
 {
  if ((active_stream) && (active_stream->filer_stack))
   fio_deactivate();
 }

void cpp_activate ()
 {
  if ((active_stream) && (active_stream->filer_stack))
   fio_activate();
 }


