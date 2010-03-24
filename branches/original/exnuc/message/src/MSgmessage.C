#include "string.h"
#include "igrtypedef.h"
#include "exms.h"
#include "msmacros.h"
#include "UMS.h"

int MSget_message (msgnumber, buffer, nbytes)
IGRlong msgnumber;
IGRchar **buffer;
int *nbytes;
{
    return (UMSRetPtrByNum ( buffer, nbytes, msgnumber));
}

