void lower_ (str, len)
char *str;
int *len;
{
    int ii;

    ii = *len;
    while (ii--)
    {
        char cc;

        cc = *str;
        *str++ = tolower (cc);
    }

    return;
}
