#include "machine.h"

/************************************************************************
*									*
* Contents:								*	
*		NFMencrypt()						*
*		NFMdecrypt()						*
************************************************************************/
#define INCLUDE_EXTERN	1
#include "NFMsysinc.h"



int NFMencrypt (passwd, e_passwd)
  char *passwd, *e_passwd;
  {
    char *fname="NFMencrypt";
    long  status;
    int   c, i, j, k, sum, len, offset;
    int   shift_count, padding_len;
    char  temp_str [NFM_FIXED_ENCRYPT_LENGTH + 1];

    static int seeded = 0;

    e_passwd [0] = 0;

    _NFMdebug (( fname,"Source = <%s> Destination <%s>\n","NOT PRINTED",e_passwd ));

    if (! seeded)
     {
       srand ((unsigned) time ((long *) 0));
       seeded = 1;
     }

    if (! passwd)
     {
       _NFMdebug ((fname," SOURCE IS NULL:source <%s> status = <0x%.8x>\n","NOT PRINTED", NFM_S_SUCCESS));
       return (NFM_S_SUCCESS);
     }

    len = strlen (passwd);

    if (len >= NFM_MAX_PASSWD_LENGTH)
    {
       status = NFM_E_PASSWD_TOO_LONG;
       ERRload_struct(NFM,status,"%d%d",len,NFM_MAX_PASSWD_LENGTH);
       _NFMdebug((fname,"Password length is too long: Length <%d> maximum \
length <%d>: status <0x%.8x>\n",len,NFM_MAX_PASSWD_LENGTH,status));
       return (status);
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
           status = NFM_E_NONPRINT_CHAR_IN_PASSWD;
           ERRload_struct(NFM,status,"%s%d","NOT PRINTED",i);
	   _NFMdebug((fname,"Password <%s> has nonprintable character at \
location <%d>. Status <0x%.8x>\n","NOT PRINTED",i,NFM_E_NONPRINT_CHAR_IN_PASSWD));
           return (status);
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

    _NFMdebug((fname,"SUCCESSFUL: Encrypted Password <%s> : status <0x%.8x>\n",
e_passwd,NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

int NFMdecrypt (e_passwd, passwd)
  char *e_passwd, *passwd;
  {
    char *fname="NFMdecrypt ";
    int   c, i, j, k, atoi ();
    int   len, sum, offset, shift_count;
    char  temp_str [NFM_PASSWD], temp_str1 [NFM_PASSWD],  len_str [3];
    passwd [0] = 0;

    _NFMdebug ((fname,"Source = <%s> Destination = <%s>\n  ", e_passwd,"NOT PRINTED"));

    if (! e_passwd)
     {
	_NFMdebug((fname,"Source = <%s> is NULL : status = <0x%.8x>\n",e_passwd,NFM_S_SUCCESS));
       return (NFM_S_SUCCESS);
     }

    if (! strlen (e_passwd))
     {
	_NFMdebug((fname,"Source = <%s> length is NULL : status = <0x%.8x>\n",e_passwd,NFM_S_SUCCESS));
       return (NFM_S_SUCCESS);
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

    _NFMdebug((fname,"SUCCESSFUL:Password is <%s>: Status <0x%.8x>\n","NOT PRINTED",NFM_S_SUCCESS));
    return(NFM_S_SUCCESS);
  }
