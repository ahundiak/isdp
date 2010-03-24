/* list_tool.h */
#ifndef _COB_list_tool_dot_h
#define _COB_list_tool_dot_h

/* ------- 2-way linked list macros --------------------------------- */

/* ------- list defining structure */

#define _COB_list(typ,list_name) struct {typ * next, * prev;} list_name

/* usage:					*/
/*   struct my_struct				*/
/*     {					*/
/*       ...					*/
/*       _COB_list (struct my_struct, my_list);	*/
/*       ...					*/
/*     };					*/
/*						*/
/*   struct my_struct	* the_root;		*/

/* ------- insert a new record after an existing record */
/*   usage: _COB_insert_after (new_ptr, my_list, old_ptr); */

#define _COB_insert_after(ptr,lst,exist) \
  ((ptr)->lst.next = (exist)->lst.next, \
   (ptr)->lst.prev = (exist), \
   (ptr)->lst.next->lst.prev = (ptr), \
   (exist)->lst.next = (ptr))

/* ------- insert a new record before an existing record */
/*   usage: _COB_insert_before (new_ptr, my_list, old_ptr); */

#define _COB_insert_before(ptr,lst,exist) \
  ((ptr)->lst.next = (exist), \
   (ptr)->lst.prev = (exist)->lst.prev, \
   (ptr)->lst.prev->lst.next = (ptr), \
   (exist)->lst.prev = (ptr))

/* ------- append a new record to the very end of an existing list */
/*   usage: _COB_append_to_list (new_ptr, my_list, the_root); */

#define _COB_append_to_list(ptr,lst,root) \
  ((root) ? _COB_insert_before ((ptr), lst, (root)) : \
  ((root) = (ptr), (ptr)->lst.next = (ptr), (ptr)->lst.prev = (ptr)))

/* ------- insert a new record at the beginning (head) of an existing list */
/*   usage: _COB_insert_head (new_ptr, my_list, the_root); */

#define _COB_insert_head(ptr,lst,root) \
  ((root) ? _COB_insert_before ((ptr), lst, (root)) : \
  ((ptr)->lst.next = (ptr), (ptr)->lst.prev = (ptr)), (root) = (ptr))

#define _COB_insert_head_ansi(ptr,lst,root,rootnotype,roottype) \
  ((root) ? _COB_insert_before ((ptr), lst, (root)) : \
  ((ptr)->lst.next = (ptr), (ptr)->lst.prev = (ptr)), (rootnotype) = roottype (ptr))

/* ------- remove a record from a list.  record may be head or anywhere else */
/*   usage: _COB_remove_from_list (a_ptr, my_list, the_root); */

#define _COB_remove_from_list(ptr,lst,root) \
  ((ptr)->lst.prev->lst.next = (ptr)->lst.next, \
   (ptr)->lst.next->lst.prev = (ptr)->lst.prev, \
   (root) == (ptr) ? root = (ptr)->lst.next : 0, \
   (root) == (ptr) ? root = 0 : 0)

/* ------- remove head record from list */
/*   usage: _COB_remove_head (the_ptr_removed, my_list, the_root); */

#define _COB_remove_head(ptr,lst,root) \
  ((ptr)=(root), _COB_remove_from_list ((ptr), lst, (root)))

/* ------- loop for each record on list, forward (use lst.next) */
/*   where: */
/*     ptr is the pointer to the current record (loop variable, local) */
/*     lst is the list name in the record */
/*     init is an initial value for the loop variable (usually root) */
/*     typ is the record type that contains the list structure */
/*   note: loop ends with _COB_end_for_list */
/*   usage: _COB_for_list (ptr, my_list, the_root, struct my_struct) */
/*            ...  */
/*          _COB_end_for_list */

#define _COB_for_list(ptr,lst,init,typ) \
{ typ * ptr, * _ptr_s = 0; \
  for (ptr = (init); ptr != _ptr_s; \
    _ptr_s ? 0 : (_ptr_s = ptr), ptr = ptr->lst.next) {

/* ------- loop for each record on list, reverse (use lst.prev) */
/*   see _COB_for_list () above.  first loop variable is (init)->prev */
/*   note: loop ends with _COB_end_for_list */
/*   usage: _COB_rev_for_list (ptr, my_list, the_root, struct my_struct) */
/*            ...  */
/*          _COB_end_for_list */

#define _COB_rev_for_list(ptr,lst,init,typ) \
{ typ * ptr, * _ptr_s = 0; \
  if (ptr = (init)) \
    for (ptr = ptr->lst.prev; ptr != _ptr_s; \
      _ptr_s ? 0 : (_ptr_s = ptr), ptr = ptr->lst.prev) {

#define _COB_end_for_list }}

#endif
