/*
******************************************************************************
** $Id: a2b32.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: a2b32.h
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
**     mytypes.h - Header containing general type definitions.
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

#if !defined(_A2B32_H_)
#define _A2B32_H_

#include "mytypes.h"

/*
==============================================================================
Function: Ascii32FormatIsOK

Parameters:
    buf - (IN) - Character buffer containing ASCII password to be verified.

Description:
    This function validates the format of the ASCII password.

Return Values:
    This function returns a boolean value: 0 -> format NOT valid, 1 -> format
    IS valid.
==============================================================================
*/
#if defined(_STD_C_)
int Ascii32FormatIsOK ();
#else
int Ascii32FormatIsOK (char *buf);
#endif

#if !defined(_A2B32_DECONLY_)

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

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void Bin2Asc32 ();
#else
void Bin2Asc32 (unchar *bbuf, int ocharcnt, char *abuf);
#endif

#endif /* !defined(_A2B32_DECONLY_) */

#if !defined(_A2B32_ENCONLY_)

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

Return Values: none
==============================================================================
*/

#if defined(_STD_C_)
void Asc2Bin32 ();
#else
void Asc2Bin32 (char *abuf, int obytes, unchar *bbuf);
#endif

#endif /* !defined(_A2B32_ENCONLY_) */

#endif /* _A2B32_H_ */
