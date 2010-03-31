# include <ctype.h>

int strlen_ (inputstr, maxlen)
char *inputstr;
int maxlen;
{
    int len = 0, ii;
    char *str;

    for (str = inputstr, ii = 1; ii <= maxlen; ii++, str++)
    {
        if (! isascii (*str)) break;
        if (! isprint (*str)) break;
        if (isgraph (*str)) len = ii;
    }

    return len;
}
