/* $Revision: 1.1 $ */
#include "dba.ext"

#ifdef HANGUL
#define isHangul(c)	(((c) & 0x80) ? 1 : 0)
#endif

extern char *dba_errtxt, *dba_fldval;

/* Function:	dba_check_name */
int dba_check_name (text_ptr, ntype)
char *text_ptr;
int ntype;
{
  int count;

#ifdef HANGUL
  if (!isalpha (text_ptr[0] & 0xFF) && !isHangul(text_ptr[0] & 0xFF))
       goto invnam;
#else
  if (!isalpha (text_ptr[0])) goto invnam;
#endif

  for (count=0; count<strlen (text_ptr); ++count)
#ifdef HANGUL
    if (text_ptr[count] != '_' && !isalnum (text_ptr[count] & 0xFF)
                     && !isHangul (text_ptr[count] & 0xFF)) goto invnam;
#else
    if (text_ptr[count] != '_' && !isalnum (text_ptr[count])) goto invnam;
#endif

  dba_lower (text_ptr);

  return (0);

invnam:
  switch (ntype)
    { case 1:
      strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_ENTNAM, NP, 0, NP, NP));
      break;
    case 2:
      strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_ATTNAM, NP, 0, NP, NP));
      break; }

  return (99);
}
/* Function:	dba_check_number */
int dba_check_number (text_ptr, itmp)
char *text_ptr;
int *itmp;
{
  int status;

  status = sscanf (text_ptr, "%d", itmp);
  if (!status || *itmp <= 0)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_POS_INT_REQ, NP, 0, NP, NP));
    return (99); }

  return (0);
}
/* Function:	dba_check_bitoff */
int dba_check_bitoff (alen, itmp)
int alen, *itmp;
{
  int status;

  status = sscanf (dba_fldval, "%d", itmp);
  if (!status || *itmp < 0)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_POS_INT_REQ, NP, 0, NP, NP));
    return (99); }
  else if (*itmp > 7)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_MAX_BIT_OFF, NP, 0, NP, NP));
    return (99); }
  else if (*itmp + alen > 8)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_CROSS_WORD, NP, 0, NP, NP));
    return (99); }

  return (0);
}
