/*
******************************************************************************
** $Id: a2b64.c 1.3.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: a2b64.c
**
** This module implements the 6 bit binary -> alphanumeric character mapping
** facilities used when converting binary password information into printable
** form.
******************************************************************************
** Build Requirements
**
** Libraries:
**
** Dependencies:
**     mytypes.h - Header containing general type definitions.
**
** Compilation Directives:
**
**     _A2B64_DECONLY_ - This directive will exclude the Binary -> ASCII
**                       conversion functions and tables.
**     _A2B64_ENCONLY_ - This directive will exclude the ASCII -> Binary
**                       conversion functions and tables.
**     _A2B64_TEST_    - Includes main() function for basic testing.  This
**                       function is located at the end of the module.
**     _STD_C_	       - Change Ansi code.
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

static char appl_version_id[] = "$Id: a2b64.c 1.3.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $";

#include <stdio.h>
#include <ctype.h>

#include "a2b64.h"

/*
==============================================================================
Function: Ascii64FormatIsOK

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
int Ascii64FormatIsOK (buf)
    char *buf;
#else
int Ascii64FormatIsOK (char *buf)
#endif
{
    char ch;
    int  retval = 1;

    for (; ch = toupper(*buf); ++buf) {
	if (!(   (ch == '.')
	      || (ch == '/')
	      || ((ch >= '0') && (ch <= '9'))
	      || ((ch >= 'A') && (ch <= 'Z')))) {

	    retval = 0;
	    break;
	}
    }

    return retval;
}

#if !defined(_B2A64_DECONLY_)

/*
** This table defines the 6 bit binary -> ASCII conversions needed to represent
** binary data as an alphanumeric string.
*/
static char B2A64[] = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

/*
==============================================================================
Function: Bin2Asc64

Parameters:
    bbuf     - (IN)   - Buffer containing binary data which is to be converted
                        to alphanumeric characters.
    ocharcnt - (IN)   - Number of output characters expected.
    abuf     - (OUT)  - Buffer into which ASCII representation of "bbuf" will
                        be written.
    B2A64    - (G:IN) - Mapping table which maps 6 bit binary values onto
                        an alphanumeric character set.

Description:
    This function converts each 6 bit chunk of binary data in "bbuf" into
    alphanumeric characters.  "ocharcnt" alphanumeric characters are written
    into "abuf".

    Note that the number of ASCII output characters is used to determine the
    amount of binary data which must be converted.

Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void Bin2Asc64 (bbuf, ocharcnt, abuf)
    unchar *bbuf;
    int ocharcnt;
    char *abuf;
#else
void Bin2Asc64 (unchar *bbuf, int ocharcnt, char *abuf)
#endif
{
    int i, j;   /* Indexing variables. */
    int cnt;    /* Used to keep track of the number of characters produced. */

    /*
    ** The following loop converts successive 3 byte groups into 6 bit
    ** values.  These 6 bit values are used to obtain an ASCII character
    ** from the vector B2A64.
    */
    for (i = j = 0, cnt = ocharcnt / 4; cnt--;) {
	abuf[j++] = B2A64[(bbuf[i] >> 2) & 0x3f];
	abuf[j++] = B2A64[((bbuf[i] << 4) | ((bbuf[i+1] >> 4) & 0x0f)) & 0x3f];
	++i;
	abuf[j++] = B2A64[((bbuf[i] << 2) | (bbuf[i+1] >> 6)) & 0x3f];
	++i;
	abuf[j++] = B2A64[bbuf[i] & 0x3f];
	++i;
    }

    /*
    ** Partition any remaining bytes. 
    */
    switch (cnt = ocharcnt % 4) {
      case 3 :
	  abuf[j+2] = B2A64[((bbuf[i+1] << 2) | (bbuf[i+2] >> 6)) & 0x3f];
      case 2 :
	  abuf[j+1] = B2A64[((bbuf[i] << 4) | ((bbuf[i+1] >> 4) & 0x0f)) & 0x3f];
      case 1:
	  abuf[j]   = B2A64[(bbuf[i] >> 2) & 0x3f];
    }

    abuf[j+cnt] = '\0';
}

#endif /* !defined(_B2A64_DECONLY_) */

#if !defined(_B2A64_ENCONLY_)

/*
** This table defines the ASCII -> 6 bit binary conversions needed to recover
** binary information from passwords.
*/
static unchar A2B64[] = {
    /*   0 */  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /*  16 */  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    /*  32 */  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    /*  48 */  2,3,4,5,6,7,8,9,10,11,0,0,0,0,0,0,
    /*  64 */  0,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,
    /*  80 */  27,28,29,30,31,32,33,34,35,36,37,0,0,0,0,0,
    /*  96 */  0,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,
    /* 112 */  53,54,55,56,57,58,59,60,61,62,63,0,0,0,0,0
};

/*
==============================================================================
Function: Asc2Bin64

Parameters:
    abuf   - (IN)   - Buffer containing alphanumeric characters from which
                      binary data must be extracted.
    obytes - (IN)   - Number of output bytes expected.
    bbuf   - (OUT)  - Buffer into which binary data will be written.
    A2B64  - (G:IN) - Table used to map alphanumeric characters onto their
                      binary counterparts.

Description:
    This function converts each alphanumeric character into its corresponding
    6 bit chunk of binary data.  These chunks are combined and written into
    "bbuf".  "obytes" output bytes are written into "bbuf".

    Note that the number of binary output bytes is used to determine the
    number of ASCII characters which must be converted.

Routines: none

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void Asc2Bin64 (abuf, obytes, bbuf)
    char *abuf;
    int obytes;
    unchar *bbuf;
#else
void Asc2Bin64 (char *abuf, int obytes, unchar *bbuf)
#endif
{
    int i, j;   /* Indexing variables. */
    int cnt;    /* Used to keep track of the number of characters produced. */

    for (i = j = 0, cnt = obytes / 3; cnt--;) {
	bbuf[i++] = ((A2B64[abuf[j]] << 2) | (A2B64[abuf[j+1]] >> 4)) & 0x0ff;
	++j;
	bbuf[i++] = ((A2B64[abuf[j]] << 4) | (A2B64[abuf[j+1]] >> 2)) & 0x0ff;
	++j;
	bbuf[i++] = ((A2B64[abuf[j]] << 6) | A2B64[abuf[j+1]]) & 0x0ff;
	j += 2;
    }

    switch (cnt = obytes % 3) {
      case 2 :
	  bbuf[i+1] = ((A2B64[abuf[j+1]] << 4) | (A2B64[abuf[j+2]] >> 2)) & 0x0ff;
      case 1 :
	  bbuf[i]   = ((A2B64[abuf[j]] << 2) | (A2B64[abuf[j+1]] >> 4)) & 0x0ff;
    }
}

#endif /* !defined(_B2A64_ENCONLY_) */

#if defined(_A2B64_TEST_)

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

    Bin2Asc64(bbuf,6,abuf);
    printf("\nASCII value : %s\n",abuf);  fflush(stdout);

    Asc2Bin64(abuf,4,bbuf);
    val = (bbuf[0] << 24) | (bbuf[1] << 16) | (bbuf[2] << 8) | bbuf[3];
    printf("Binary value: %ld\n\n",val);  fflush(stdout);
    
    exit(0);
}

#endif
