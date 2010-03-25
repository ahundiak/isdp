/*
******************************************************************************
** $Id: a2b32.c 1.3.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: a2b32.c
**
** This module implements the 5 bit binary -> alphanumeric character mapping
** facilities used when converting binary password information into printable
** form.
******************************************************************************
** Build Requirements
**
** Libraries:
**
** Dependencies:
**     mytypes.h  - Header containing general type definitions.
**
** Compilation Directives:
**
**     _A2B32_DECONLY_ - This directive will exclude the Binary -> ASCII
**                       conversion functions and tables.
**     _A2B32_ENCONLY_ - This directive will exclude the ASCII -> Binary
**                       conversion functions and tables.
**     _A2B32_TEST_    - Includes main() function for basic testing.  This
**                       function is located at the end of the module.
**     _STD_C_	       - Change Ansi code.
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

#include <ctype.h>
#include "a2b32.h"

/*
==============================================================================
Function: Ascii32FormatIsOK

Parameters:
    buf - (IN) - Character buffer containing ASCII password to be verified.

Description:
    This function validates the format of the ASCII password.

Routines: none

Return Values:
    This function returns a boolean value: 0 -> format NOT valid, 1 -> format
    IS valid.
==============================================================================
*/

#if defined(_STD_C_)
int Ascii32FormatIsOK (buf)
    char *buf;
#else
int Ascii32FormatIsOK (char *buf)
#endif
{
    char ch;
    int  retval = 1;

    for (; ch = toupper(*buf); ++buf) {
	if (!(   ((ch >= '2') && (ch <= '9'))
	      || ((ch >= 'A') && (ch <= 'K'))
	      || ((ch >= 'M') && (ch <= 'N'))
	      || ((ch >= 'P') && (ch <= 'Z')))) {
	    retval = 0;
	    break;
	}
    }

    return retval;
}

#if !defined(_A2B32_DECONLY_)

/*
** This table defines the 5 bit binary -> ASCII conversions needed to represent
** binary data as an alphanumeric string.
*/
static char B2A32[] = "23456789abcdefghijkmnpqrstuvwxyz";

/*
==============================================================================
Function: Bin2Asc32

Parameters:
    bbuf     - (IN)   - Buffer containing binary data which is to be converted
                        to alphanumeric characters.
    ocharcnt - (IN)   - Number of output characters expected.
    abuf     - (OUT)  - Buffer into which ASCII representation of "bbuf" will
                        be written.
    B2A32    - (G:IN) - Mapping table which maps 5 bit binary values onto
                        an alphanumeric character set.

Description:
    This function converts each 5 bit chunk of binary data in "bbuf" into
    alphanumeric characters.  "ocharcnt" alphanumeric characters are written
    into "abuf".

    Note that the number of ASCII output characters is used to determine the
    amount of binary data which must be converted.

Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void Bin2Asc32 (bbuf, ocharcnt, abuf)
    unchar *bbuf;
    int ocharcnt;
    char *abuf;
#else
void Bin2Asc32 (unchar *bbuf, int ocharcnt, char *abuf)
#endif
{
    int i, j;   /* Indexing variables. */
    int cnt;    /* Used to keep track of the number of characters produced. */

    /*
    ** The following loop converts successive 5 byte groups into 5 bit
    ** values.  These 5 bit values are used to obtain an ASCII character
    ** from the vector B2A.
    */
    for (i = j = 0, cnt = ocharcnt / 8; cnt--;) {
	abuf[j++] = B2A32[(bbuf[i] >> 3) & 0x1f];
	abuf[j++] = B2A32[((bbuf[i] << 2) | ((bbuf[i + 1] >> 6) & 0x03)) & 0x1f];
	++i;
	abuf[j++] = B2A32[(bbuf[i] >> 1) & 0x1f];
	abuf[j++] = B2A32[((bbuf[i] << 4) | ((bbuf[i + 1] >> 4) & 0x0f)) & 0x1f];
	++i;
	abuf[j++] = B2A32[((bbuf[i] << 1) | ((bbuf[i + 1] >> 7) & 0x01)) & 0x1f];
	++i;
	abuf[j++] = B2A32[(bbuf[i] >> 2) & 0x1f];
	abuf[j++] = B2A32[((bbuf[i] << 3) | ((bbuf[i + 1] >> 5) & 0x07)) & 0x1f];
	++i;
	abuf[j++] = B2A32[bbuf[i] & 0x1f];
	++i;
    }

    /*
    ** Partition any remaining bytes. 
    */
    switch (cnt = ocharcnt % 8) {
      case 7:
	abuf[j+6] = B2A32[((bbuf[i+3] << 3) | ((bbuf[i+4] >> 5) & 0x07)) & 0x1f];
      case 6:
	abuf[j+5] = B2A32[(bbuf[i+3] >> 2) & 0x1f];
      case 5:
	abuf[j+4] = B2A32[((bbuf[i+2] << 1) | ((bbuf[i+3] >> 7) & 0x01)) & 0x1f];
      case 4:
	abuf[j+3] = B2A32[((bbuf[i+1] << 4) | ((bbuf[i+2] >> 4) & 0x0f)) & 0x1f];
      case 3:
	abuf[j+2] = B2A32[(bbuf[i+1] >> 1) & 0x1f];
      case 2:
	abuf[j+1] = B2A32[((bbuf[i] << 2) | ((bbuf[i+1] >> 6) & 0x03)) & 0x1f];
      case 1:
	abuf[j] = B2A32[(bbuf[i] >> 3) & 0x1f];
	break;
    }

    abuf[j+cnt] = '\0';
}

#endif /* !defined(_A2B32_DECONLY_) */

#if !defined(_A2B32_ENCONLY_)

/*
** This table defines the ASCII -> 5 bit binary conversions needed to recover
** binary information from passwords.
*/
static unchar A2B32[] = {
    /*   0 */  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /*  16 */  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /*  32 */  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /*  48 */  0,0,0,1,2,3,4,5,6,7,0,0,0,0,0,0,
    /*  64 */  0,8,9,10,11,12,13,14,15,16,17,18,0,19,20,0,
    /*  80 */  21,22,23,24,25,26,27,28,29,30,31,0,0,0,0,0,
    /*  96 */  0,8,9,10,11,12,13,14,15,16,17,18,0,19,20,0,
    /* 112 */  21,22,23,24,25,26,27,28,29,30,31,0,0,0,0,0
};

/*
==============================================================================
Function: Asc2Bin32

Parameters:
    abuf   - (IN)   - Buffer containing alphanumeric characters from which
                      binary data must be extracted.
    obytes - (IN)   - Number of output bytes expected.
    bbuf   - (OUT)  - Buffer into which binary data will be written.
    A2B32  - (G:IN) - Table used to map alphanumeric characters onto their
                      binary counterparts.

Description:
    This function converts each alphanumeric character into its corresponding
    5 bit chunk of binary data.  These chunks are combined and written into
    "bbuf".  "obytes" output bytes are written into "bbuf".

    Note that the number of binary output bytes is used to determine the
    number of ASCII characters which must be converted.

Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void Asc2Bin32 (abuf, obytes, bbuf)
    char *abuf;
    int obytes;
    unchar *bbuf;
#else
void Asc2Bin32 (char *abuf, int obytes, unchar *bbuf)
#endif
{
    int i, j;   /* Indexing variables. */
    int cnt;    /* Used to keep track of the number of characters produced. */

    for (i = j = 0, cnt = obytes / 5; cnt--;) {
	bbuf[i++] = (A2B32[abuf[j]] << 3) | (A2B32[abuf[j + 1]] >> 2);
	++j;
	bbuf[i++] = (A2B32[abuf[j]] << 6) | (A2B32[abuf[j + 1]] << 1) | (A2B32[abuf[j + 2]] >> 4);
	j += 2;
	bbuf[i++] = (A2B32[abuf[j]] << 4) | (A2B32[abuf[j + 1]] >> 1);
	++j;
	bbuf[i++] = (A2B32[abuf[j]] << 7) | (A2B32[abuf[j + 1]] << 2) | (A2B32[abuf[j + 2]] >> 3);
	j += 2;
	bbuf[i++] = (A2B32[abuf[j]] << 5) | A2B32[abuf[j + 1]];
	j += 2;
    }

    switch (cnt = obytes % 5) {
      case 4 :
	bbuf[i+3] = (A2B32[abuf[j+4]] << 7) | (A2B32[abuf[j+5]] << 2) | (A2B32[abuf[j+6]] >> 3);
      case 3 :
	bbuf[i+2] = (A2B32[abuf[j+3]] << 4) | (A2B32[abuf[j+4]] >> 1);
      case 2 :
	bbuf[i+1] = (A2B32[abuf[j+1]] << 6) | (A2B32[abuf[j+2]] << 1) | (A2B32[abuf[j+3]] >> 4);
      case 1 :
	bbuf[i] = (A2B32[abuf[j]] << 3) | (A2B32[abuf[j+1]] >> 2);
    }
}

#endif /* !defined(_A2B32_ENCONLY_) */

#if defined(_A2B32_TEST)

#include <stdio.h>

int main (int argc, char *argv[])
{
    char   abuf[20];
    unchar bbuf[20];
    ulong  val;
    char   valstr[20];

    printf("Enter integer value: ");
    scanf("%s",valstr);
    val = atol(valstr);
    printf("Value read = %lu (%08x)\n",val,val);  fflush(stdout);

    bbuf[3] = val & 0x00ff;
    bbuf[2] = (val >> 8) & 0x00ff;
    bbuf[1] = (val >> 16) & 0x00ff;
    bbuf[0] = (val >> 24) & 0x00ff;

    Bin2Asc32(bbuf,7,abuf);
    printf("\nASCII value : %s\n",abuf);  fflush(stdout);

    Asc2Bin32(abuf,4,bbuf);
    val = (bbuf[0] << 24) | (bbuf[1] << 16) | (bbuf[2] << 8) | bbuf[3];
    printf("Binary value: %ld\n\n",val);  fflush(stdout);
    
    exit(0);
}

#endif
