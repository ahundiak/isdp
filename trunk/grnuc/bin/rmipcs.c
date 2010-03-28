# include <stdio.h>

main (argc, argv)
int argc;
char *argv[];
{
    char cmd[256];

    strcpy(cmd, "ipcrm ");
    strcat(cmd, argv[1]);
    return system (cmd);
}
