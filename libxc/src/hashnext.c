#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashnext  --  Traverse hash table in a linear fashion:  returns next    *
 *		   element in sequence.					     *
 *									     *
 *****************************************************************************/

void *hashnext (table)

HASHTABLE *table;
{
  /* If linear mode is not active, find first element and return that setting
     linear mode on. */

  if (!table->linear) {
    table->c_index = 0;
    while (!table->body[table->c_index])
      if (++table->c_index == table->tbllength) {
        table->c_index = -1;
        return 0;
      }
    table->linear  = 1;
    table->c_chain = (HCHAIN *)&table->body[table->c_index];
    return table->c_chain->next->record;
  }

  /* if the delete flag is set, then the current entry is the one we
     need to return; otherwise make the next entry the current one */

  if (!table->delete)
    table->c_chain = table->c_chain->next;
  else table->delete = 0;

  /* we have reached the end of the current chain if the current entry became
     NULL above:  find the next non-empty chain if this is the case (return
     NULL if a non-empty chain was not found) */

  if (!table->c_chain->next) {
    while (++table->c_index < table->tbllength)
      if (table->body[table->c_index]) {
        table->c_chain = (HCHAIN *)&table->body[table->c_index];
        return table->c_chain->next->record;
      }
    table->linear = 0;
    return 0;
  }
  return table->c_chain->next->record;
}
