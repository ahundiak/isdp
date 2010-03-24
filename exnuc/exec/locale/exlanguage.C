#include "igrtypedef.h"

static IGRchar EX_language[40];

EX_set_language (language)
IGRchar *language;
{
    strcpy (EX_language, language);
    return (1);
}

EX_inq_language (language)
IGRchar *language;

{
    strcpy (language, EX_language);
    return (1);
}
