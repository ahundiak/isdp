/* $Id: VDnfmCrypt.c,v 1.2 2001/02/11 17:59:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdris/c/VDnfmCrypt.c
 *
 * Description: Encrytion routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDnfmCrypt.c,v $
 * Revision 1.2  2001/02/11 17:59:46  ahundiak
 * Renamed VDris2 to VDrisc
 *
 * Revision 1.1  2001/02/01 21:58:19  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/01/01  ah      Header
 *
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDnfmc.h"

#define NFM_FIXED_ENCRYPT_LENGTH 25
#define NFM_MAX_PASSWD_LENGTH    14
#define NFM_PASSWD               50

#define C1  23
#define C2  43

/* -----------------------------------------------
 * Based in NFMencrypt with debug statements removed
 */
IGRstat VDnfmEncrypt(char *passwd, char *e_passwd)
{
  IGRstat retFlag = 0;
  
  long  status;
  int   c, i, j, k, sum, len, offset;
  int   shift_count, padding_len;
  char  temp_str [NFM_FIXED_ENCRYPT_LENGTH + 1];

  static int seeded = 0;

  // Arg check
  if (e_passwd == NULL) goto wrapup;
  *e_passwd = 0;
  if (passwd == NULL) goto wrapup;
  
  // Seed it
  if (!seeded)
  {
    srand ((unsigned) time ((long *) 0));
    seeded = 1;
  }

  len = strlen (passwd);

  if (len >= NFM_MAX_PASSWD_LENGTH)
  {
    goto wrapup;
  }
  

  sprintf (temp_str, "%02d%s", len, passwd);

  padding_len = NFM_FIXED_ENCRYPT_LENGTH - (len + 2);
 
  for (i = 0; i < padding_len; i++)
    temp_str [(len + 2) + i] = (rand () % ('~' - ' ')) + ' ';

  temp_str[(len + 2) + i] = '\0';

  sum = 0;

  for (i = 0; i < strlen (temp_str); i++)
    sum += temp_str [i];
  
  for (i = 0; i < NFM_FIXED_ENCRYPT_LENGTH; i++)
  {
    c =  temp_str [i];
    if (! isprint (c))
    {
      goto wrapup;
      
    }

    sum -= c;
    offset = (i + C1) * sum;
    c += offset;

    while (c > 0x7e)    c = c - 0x7f + 0x20;

    shift_count = ((i + C2) * sum) % 4;
    j = c & 0x0f;
    c ^= j;

    for (k = 0; k < shift_count; k++)
    {
      j <<= 1;
      if (j & 0x10)
      {
	j |= 1;
	j &= 0x0f;
      }
    }
    temp_str [i] = c | j;
  }
  
  strcpy (e_passwd, temp_str);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Based in NFMdecrypt with debug statements removed
 */

IGRstat VDnfmDecrypt (char *e_passwd, char *passwd)
{
  IGRstat retFlag = 0;
  
  int   c, i, j, k, atoi ();
  int   len, sum, offset, shift_count;
  char  temp_str [NFM_PASSWD], temp_str1 [NFM_PASSWD],  len_str [3];

  // Arg check
  if (passwd == NULL) goto wrapup;
  *passwd = 0;
  if (e_passwd == NULL) goto wrapup;
  

  if (! strlen (e_passwd))
  {
    goto wrapup;    
  }
  strcpy (temp_str1, e_passwd);

  len = strlen (temp_str1);
  sum = 0;

  for (i = len - 1; i >= 0; i--)
  {
    c = temp_str1 [i];
    shift_count = ((i +  C2) * sum) % 4;
    j = c & 0x0f;
    c ^= j;
    
    for (k = 0; k < shift_count; k++)
    {
      if (j & 0x01)
	j |= 0x10;
      
      j >>= 1;
      j &= 0x0f;
    }
    
    c = c | j;
    offset = (i + C1) * sum;
    c -= offset;
    while (c < 0x20)  c = c - 0x20 + 0x7f;
    
    temp_str1 [i] = c;
    sum += c;
  }
  
  strncpy(len_str, temp_str1, 2);
  len_str [2] = 0;
  len = atoi (len_str);
  
  strncpy (temp_str, temp_str1 + 2, len);
  temp_str [len] = 0;
  
  strcpy (passwd, temp_str);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}
