/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"
#include "dmalloc.def"

/* Function:	dba_sort */
int dba_sort (univ_size, mem_ptr, rec_length, fkey)
long univ_size;
char *mem_ptr;
int rec_length;
struct dba_key *fkey;
{
  char *sa, *sb;
  double ddiff, r8a, r8b;
  long j, k, l, m, jj, ldiff=0, i4a, i4b;
  short swap, exit, i2a, i2b;
  struct dba_key *ckey;
  static char *s1_ptr, built=0;
  static unsigned long s1_size=500;

  if (!built) { s1_ptr = dba_dmalloc (s1_size, DM_STATIC);  built = 1; }
  if (rec_length > s1_size)
    { s1_size = rec_length;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
  for (m = univ_size;  m/2 > 0; )
    { m /= 2;  k = univ_size - m;
    for (j=0; j<k; j++)
      { jj = j;  swap = 1;
      while (swap)
        { swap = 0;  exit = 0;  l = jj + m;
        for (ckey=fkey; !exit && ckey; ckey=ckey->nkey)
          { sa = mem_ptr + (jj * rec_length) + ckey->offset;
          sb = mem_ptr + (l * rec_length) + ckey->offset;
          switch (ckey->type)
            { case SORT_SHORT:  /* case SCR_SHORT: */
              memcpy (&i2a, sa, 2);  memcpy (&i2b, sb, 2);
              ldiff = ( i2a - i2b ) * ckey->sign;  break;
            case SORT_INT:  /* case SCR_INT: */  case SCR_LONG:
              memcpy (&i4a, sa, 4);  memcpy (&i4b, sb, 4);
              ldiff = ( i4a - i4b ) * ckey->sign;  break;
/*
            case SORT_FLOAT:  case SCR_FLOAT:
              memcpy (&r4a, sa, 4);  memcpy (&r4b, sb, 4);
              ddiff = ( r4a - r4b ) * ckey->sign;
              if ( ddiff == 0) ldiff = 0;
              else ldiff = ddiff<0 ? -1 : 1;  break;
*/
            case SORT_DOUBLE:  /* case SCR_DOUBLE: */
              memcpy (&r8a, sa, 8);  memcpy (&r8b, sb, 8);
              ddiff = ( r8a - r8b ) * ckey->sign;
              if ( ddiff == 0) ldiff = 0;
              else ldiff = ddiff<0 ? -1 : 1;  break;
            case SORT_CHAR:  /* case SCR_CHAR: */
              ldiff = strncmp( sa, sb, ckey->length );
              ldiff *= ckey->sign;  break; }
          exit = ldiff != 0;  swap = ldiff>0 ? 1 : 0;
          if (swap)
            { sa = mem_ptr + (jj * rec_length);
            sb = mem_ptr + (l * rec_length);
            memcpy (s1_ptr, sa, rec_length);
            memcpy (sa, sb, rec_length);
            memcpy (sb, s1_ptr, rec_length);
            jj -= m;  swap = jj>=0; } } } } }
  return (0);
}
