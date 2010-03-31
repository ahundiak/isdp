void upper_ (str, len)
char *str;
int *len;
{
    int ii;

    ii = *len;
    while (ii--)
    {
        char cc;

        cc = *str;
        *str++ = toupper (cc);
    }

    return;
}
