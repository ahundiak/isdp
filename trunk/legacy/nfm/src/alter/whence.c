#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

char *whence( filename , dummy )
char *filename, *dummy;
{
    char *s, s1[1000], s2[2], str[100];
    char *strtok(), *getcwd();
    FILE *fp;
    struct stat buf;

    s2[0] = ':';
    s2[1] = '\0';

    if(!stat( filename, &buf))
    {
        if( *filename == '/' )
            return filename;
    }
    strcpy(s1 , getenv( "PATH" ));
    s = strtok( s1, s2);
    while( s != NULL)
    {
        if( *s == '.' )
            s = getcwd( NULL, 100 );
        str[0] = '\0';
        strcpy(str, s);
        strcat(str, "/");
        strcat(str, filename);
        if(!stat( str, &buf))
            return str;
        s = strtok( NULL, s2);
    }
    return NULL;
}
