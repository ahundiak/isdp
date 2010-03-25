/*
******************************************************************************
** $Id: esne.c 1.1.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: esne.c
**
** This module implements the Evaluation Serial Number Encryption algorithms.
******************************************************************************
*/

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <string.h>
#include "snerr.h"
#include "a2b32.h"
#include "crc32.h"
#include "esne.h"

static int SerialNumberOK OF((char *snbr));


/*
==============================================================================
Function: CreateEvalSnbrRec

Parameters: none

Description:
    This function is used to dynamically allocate an EvalSnbrRec
    object.

Routines: none

Return Values:
    This routine returns a NULL pointer if an object cannot be allocated.
    Otherwise, a pointer to the allocated object is returned.
==============================================================================
*/

EvalSnbrRec *CreateEvalSnbrRec ()
{
    return (EvalSnbrRec *) calloc(1,sizeof(EvalSnbrRec));
}

/*
==============================================================================
Function: DeleteEvalSnbrRec

Parameters:
    edsrec - (OUT) - EvalSnbrRec object to deallocate.  A NULL pointer
                     is recognized and ignored.

Description:
    This function deallocates the specified EvalSnbrRec.

Routines: none

Return Values: none
==============================================================================
*/

void DeleteEvalSnbrRec (esrec)
    EvalSnbrRec *esrec;
{
    if (esrec) free(esrec);
}

/*
==============================================================================
Function: InitEvalSnbrRec

Parameters:
    esrec - (OUT) - EvalSnbrRec structure to be initialized.
    
Description:
    This function initializes the specified EvalSnbrRec structure.
    Note that a NULL pointer is recognized and ignored.

Routines: none

Return Values: none
==============================================================================
*/

void InitEvalSnbrRec (esrec)
    EvalSnbrRec *esrec;
{
    if (esrec) memset((char *)esrec,0,sizeof(EvalSnbrRec));
}

#if !defined(_ESNE_DECONLY_)

/*
==============================================================================
Function: EncryptEvalSerialNumber

Parameters:

Description:

Routines:

Return Values:

==============================================================================
*/

int EncryptEvalSerialNumber (esrec)
    EvalSnbrRec *esrec;
{
    /*
    ** The caller must specify the day, month, year, customer, and prodindex.
    */

    if (!esrec || !esrec->day
	       || esrec->day > 31
	       || esrec->month > 11
	       || esrec->year > 31
	       || (strlen(esrec->prodindex) != 6)) {

        snerrno = SN_DATA_ERR;
    }
    else {
        ulong  crc;
        char   *tmptr;
        unchar bbuf[4];
        char   abuf[6];

        /*
        ** Encode expiration date and CRC over customer's name into a binary
        ** vector.
        */
        bufcrc((unchar *)esrec->customer,strlen(esrec->customer),&crc);
        crc &= 0x07ff;

        bbuf[0] = (crc >> 3) & 0x0ff;
        bbuf[1] = ((crc & 0x07) << 5) | esrec->year;
        bbuf[2] = (esrec->month << 4) | (esrec->day >> 1);
        bbuf[3] = esrec->day << 7;

        /*
        ** Encrypt this binary data.
        */
        {
	    unchar sum;
            int    i;

            /* Swap the bytes around just to make things interesting. */
            sum = bbuf[1];
            bbuf[1] = bbuf[2];
            bbuf[2] = sum;

            /*
            ** Now XOR the binary data with the checksum over the "prodindex"
	    ** string.  Add the string position to the mask to liven things up.
            */
            for (sum = 0, tmptr = esrec->prodindex; *tmptr; ++tmptr) sum += *tmptr;
	    for (i = 0; i < 4; ++i) bbuf[i] ^= sum;
        }

        /*
        ** Map the binary data to printable ASCII and then create the serial
	** number.
        */
        Bin2Asc32(bbuf,5,abuf);

        tmptr = esrec->snbr;
        *tmptr = 'E';
        strcat(strcpy(tmptr + 1,abuf),esrec->prodindex);
        bufcrc((unchar *) tmptr,strlen(tmptr),&crc);
	crc %= 100;
	tmptr[6] = '0' + (crc / 10);
	tmptr[7] = '0' + (crc % 10);
        strcpy(tmptr + 8,esrec->prodindex);
    }

    return snerrno;
}

#endif /* !defined(_ESNE_DECONLY_) */

#if !defined(_ESNE_ENCONLY_)

/*
==============================================================================
Function: DecryptEvalSerialNumber

Parameters:

Description:

Routines:

Return Values:

==============================================================================
*/

int DecryptEvalSerialNumber (esrec)
    EvalSnbrRec *esrec;
{
    /*
    ** Caller must supply snbr and customer fields.
    */

    if (!esrec || (esrec->snbr[0] != 'E') || (strlen(esrec->snbr) != 14))
        snerrno = SN_DATA_ERR;
    else if (!SerialNumberOK(esrec->snbr))
        snerrno = SN_BAD_ECHKSUM;
    else {
        ulong  crc;
        unchar bbuf[4];
        char   abuf[6];

        strcpy(esrec->prodindex,esrec->snbr+8);

        strncpy(abuf,esrec->snbr+1,5);
        abuf[5] = '\0';

        Asc2Bin32(abuf,4,bbuf);

        {
            int    i;
            unchar sum;
            char   *tmptr;

            /*
            ** Now XOR the binary data with the checksum over the "prodindex"
	    ** string.  Add the string position to the mask to liven things up.
            */
            for (sum = 0, tmptr = esrec->prodindex; *tmptr; ++tmptr) sum += *tmptr;
	    for (i = 0; i < 4; ++i) bbuf[i] ^= sum;

            /* Swap the bytes around just to make things interesting. */
            sum = bbuf[1];
            bbuf[1] = bbuf[2];
            bbuf[2] = sum;
        }

        /*
        ** Validate checksum over customer name.  If valid, extract
	** expiration date from the serial number.
        */
        bufcrc((unchar *)esrec->customer,strlen(esrec->customer),&crc);

        if ((((ulong)bbuf[0] << 3) | (bbuf[1] >> 5)) != (crc & 0x07ff))
            snerrno = SN_BAD_CHKSUM;
        else {
            esrec->year = bbuf[1] & 0x1f;
            esrec->month = bbuf[2] >> 4;
            esrec->day = ((bbuf[2] & 0x0f) << 1) | (bbuf[3] >> 7);
        }
    }

    return snerrno;
}

#endif /* !defined(_ESNE_ENCONLY_) */

/*
==============================================================================
Function: SerialNumberOK

Parameters:

Description:

Routines:

Return Values:

==============================================================================
*/

static int SerialNumberOK (snbr)
    char *snbr;
{
    ulong crc;
    char  crcbuf[3];
    char  tmpsnbr[13];

    strncpy(crcbuf,snbr+6,2);
    crcbuf[2] = '\0';
    strncpy(tmpsnbr,snbr,6);
    tmpsnbr[6] = '\0';
    strcat(tmpsnbr,snbr+8);
    bufcrc((unchar *) tmpsnbr,strlen(tmpsnbr),&crc);

    return (crc % 100 == atoi(crcbuf));
}

/*
#include "a2b32.c"
#include "crc32.c"
#include "snerr.c"


int main (int argc, char *argv[])
{
    EvalSnbrRec esrec;
    EvalSnbrRec esrec2;

    InitEvalSnbrRec(&esrec);
    esrec.month = atoi(argv[1]);
    esrec.day = atoi(argv[2]);
    esrec.year = atoi(argv[3]) - 1993;
    strcpy(esrec.prodindex,argv[4]);
    strcpy(esrec.customer,argv[5]);

    if (EncryptEvalSerialNumber(&esrec)) {
	printf("Encryption failed with value %d\n",snerrno);
    }
    else {
	printf("\nCustomer: %s\nSerial Number: %s\nExpires: %d/%d/%d\n\n",esrec.customer,
                                                                        esrec.snbr,
                                                                        esrec.month,
                                                                        esrec.day,
                                                                        esrec.year + 93);
	InitEvalSnbrRec(&esrec2);
	strcpy(esrec2.snbr,esrec.snbr);
	strcpy(esrec2.customer,esrec.customer);
	if (DecryptEvalSerialNumber(&esrec2)) {
	    printf("\nDecryption failed with value %d\n",snerrno);
	}
	else {
	    printf("\nDate = %d/%d/%d\nIndex = %s\nCustomer = %s\n\n",esrec.month,esrec.day,
                                                           esrec.year+93,esrec.prodindex,esrec.customer);
	}
    }

    exit(snerrno);
}

*/
