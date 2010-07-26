#ifndef UOMtls_included
#define UOMtls_included 1

#define _FOR_LIST(typ,init,ptr) \
{ typ * ptr, * _ptr_s = 0; \
  for (ptr = (init); ptr != _ptr_s; \
    _ptr_s ? 0 : (_ptr_s = (init)), ptr = ptr->next) {

#define _REV_LIST(typ,init,ptr) \
{ typ * ptr, * _ptr_s = 0; \
  if (ptr = (init)) \
    for (ptr = ptr->prev; ptr != _ptr_s; \
      _ptr_s ? 0 : (_ptr_s = ptr), ptr = ptr->prev) {

#define _END_LIST }}

#endif          /* #ifndef UOMtls_included above */
