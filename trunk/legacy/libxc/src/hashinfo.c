#include <stdio.h>
#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   _hashinfo  --  report certain performance information to stdout.  This  *
 *		    information includes the following statistics:	     *
 *									     *
 *			options in effect				     *
 *		 	number of slots					     *
 *			number of records				     *
 *			distribution (expressed as % of perfect)	     *
 *			number of slots not hit				     *
 *			longest chain length				     *
 *			shortest chain length				     *
 *			total space allocated (not including malloc headers) *
 *			space in free records				     *
 *			space in free headers				     *
 *			number records allocated			     *
 *			number records free				     *
 *			number headers allocated			     *
 *			number headers free				     *
 *									     *
 *****************************************************************************/

void _hashinfo (table, name)

HASHTABLE *table;
char      *name;
{
  int     numrecords = 0;
  int     nohits     = 0;
  int     free_recs  = 0;
  int     free_heads = 0;
  int     length;
  int     longestlen;
  int     shortestlen;
  int     worst, wrong;
  int     min, max, len1, len2;
  int     index;
  char  **ptr;
  HCHAIN *chain;

  /* first, determine the total number of records */

  for (index = 0; index < table->tbllength; index++)
    for (chain = table->body[index]; chain; chain = chain->next)
      numrecords++;

  /* initialization for % of perfect calculation */

  min   = numrecords / table->tbllength;
  len2  = numrecords - min * table->tbllength;
  len1  = table->tbllength - len2;
  max   = (len2 == 0 ? min : min + 1);
  worst = numrecords - max;
  wrong = 0;

  /* other initialization */

  longestlen  = 0;
  shortestlen = numrecords;  

  /* make a second pass through the table to gather statistics */

  for (index = 0; index < table->tbllength; index++) {

    /* determine the length of this chain */

    length = 0;
    for (chain = table->body[index]; chain; chain = chain->next)
      length++;

    /* compare this length against the shortest and longest so far known */

    if (length > longestlen)
      longestlen = length;
    if (length < shortestlen)
      shortestlen = length;

    /* increrment number of slots not hit if length is zero */

    if (length == 0)
      nohits++;

    /* determine the number of records that are placed "wrong" with respect to
       the perfect distribution (this information is needed later to calculate
       % of perfect */

    if (length <= min) {
      if (len1 == 0)
        len2--;
      else if (--len1 == 0)
        min = max;
    }
    else if (length >= max) {
      wrong += length - max;
      if (len2 == 0)
        len1--;
      else if (--len2 == 0)
        max = min;
    }
  }

  /* determine the number of free chain headers */

  for (chain = table->hfree; chain; chain = chain->next)
    free_heads++;

  /* determine the number of free data records */

  for (ptr = (char **)table->rfree; ptr; ptr = (char **)*ptr)
    free_recs++;

  /* finally, output the statistics to stdout */

  printf ("STATISTICS SUMMARY FOR HASH TABLE \"%s\"\n\n", name);
  printf ("  options in effect:        ");
  if (table->options & INDKEY)
    printf (" INDKEY");
  if (table->options & VLREC)
    printf (" VLREC");
  if (table->options & DUPS)
    printf (" DUPS");  
  if (table->options & NOMEM)
    printf (" NOMEM");
  if (table->options & MALLOC)
    printf (" MALLOC");
  if (table->options & KEEP)
    printf (" KEEP");
  if (table->options & FREE)
    printf (" FREE");
  if (table->options & MBLOCK)
    printf (" MBLOCK");
  printf ("\n");
  printf ("  number of slots:           %d\n", table->tbllength);
  printf ("  number of records:         %d\n", numrecords);
  printf ("  distribution:              %.2f%% of perfect\n", worst == 0 ?
                (double)100 : (double)(100 * (worst - wrong)) / (double)worst);
  printf ("  number of slots not hit:   %d\n", nohits);
  printf ("  longest chain length:      %d\n", longestlen);
  printf ("  shortest chain length:     %d\n", shortestlen);
  printf ("  number records allocated:  %d\n", table->options & NOMEM ?
                                                   0 : free_recs + numrecords);
  printf ("  number records free:       %d\n", free_recs);
  printf ("  number headers allocated:  %d\n", free_heads + numrecords);
  printf ("  number headers free:       %d\n", free_heads);
}
