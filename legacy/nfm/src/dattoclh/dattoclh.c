#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pwd.h>
#include "NFMerrordef.h"
#define  MAXLINE 256

char admin_path[30];

main(int argc, char **argv)
{

    FILE *dat;
    char string[256];
    char datfile[256];
    struct passwd *pwd;

    /* PS - to print the usage */
    if(argc > 1)
    {
        if ( !(strcmp(argv[1], "-?")) )
        {
            fprintf(stdout, "Usage: %s \n\n", argv[0]);
            exit(0);
        }
     }

    pwd = getpwnam( "nfmadmin" );

    admin_path[0] = 0;
    sprintf(admin_path, "%s/%s", pwd->pw_dir, "clh_info");
 
    datfile[0] = 0;
    sprintf( datfile, "%s/%s", admin_path, "NFMser.dat" );

    dat = fopen( datfile, "r");
    if( dat == NULL )
    {
         printf("Error opening file NFMser.dat\n");
         exit(0);
    }

    while(1)
    {
        fgets(string, MAXLINE, dat);

        if( feof(dat) ) break;
        if( string[0] == '#' ) continue;

        if( write_ser_files( string ) == -1 )
        {
            printf("Error in writing Server files\n");
            exit(0);
        }
    }

    fclose(dat);

    datfile[0] = 0;
    sprintf( datfile, "%s/%s", admin_path, "NFMowne.dat" );

    dat = fopen( datfile, "r" );
    if( dat == NULL )
    {
        printf("Error opening file NFMowne.dat\n");
        exit(0);
    }

    while(1)
    {
        fgets(string, MAXLINE, dat);

        if( feof(dat) ) break;
        if( string[0] == '#' ) continue;

        if( write_env_files( string ) == -1 )
        {
            printf("Error in writing Environment files\n");
            exit(0);
        }
    }

    fclose(dat);

}

write_ser_files(string)
char *string;
{
    char *s, fbuf[128];
    char ser_file[50];
    FILE *file1;
    struct hostent *hostent_ptr;
    struct in_addr *addptr;

    s = strtok( string, "\001" );

    ser_file[0] = 0;
    sprintf(ser_file, "%s/%s", admin_path, s);
 
    file1 = fopen( ser_file, "w");
    if( file1 == NULL )
    {
        printf("Error opening file %s\n", s );
        return(-1);
    }

/* Node name */
    s = strtok( NULL, "\001" );
    sprintf( fbuf, "Nodename : %s\n", s );
    fputs( fbuf, file1 );

/* TCP address */
    hostent_ptr = gethostbyname( s );
    if( hostent_ptr == NULL)
    {
        printf("gethostbyname failed for node %s\n", s );
        printf("Cannot find tcp_address for node %s\n", s );
        fclose( file1 );
        return(-1);
    }
    addptr = (struct in_addr *) (*hostent_ptr->h_addr_list);

    sprintf( fbuf, "tcp_address : %s\n", inet_ntoa(*addptr) );
    fputs( fbuf, file1 );

    fclose( file1 );
    return(0);

}

write_env_files(string)
char *string;
{
    char *s, fbuf[128];
    char env_file[50];
    char e_prop16[50];
    FILE *file1;
    struct hostent *hostent_ptr;
    struct in_addr *addptr;

    s = strtok( string, "\001" );

    env_file[0] = 0;
    sprintf(env_file, "%s/%s", admin_path, s);

    file1 = fopen( env_file, "w");
    if( file1 == NULL )
    {
        printf("Error opening file %s\n", s );
        return(-1);
    }

    s = strtok( NULL, "\001" );

/* Nodename */
    s = strtok( NULL, "\001" );
    sprintf( fbuf, "Nodename : %s\n", s );
    fputs( fbuf, file1 );

/* TCP address */
    hostent_ptr = gethostbyname( s );
    if( hostent_ptr == NULL)
    {
        printf("gethostbyname failed for node %s\n", s );
        printf("Cannot find tcp_address for node %s\n", s );
        fclose( file1 );
        return(-1);
    }
    addptr = (struct in_addr *) (*hostent_ptr->h_addr_list);

    sprintf( fbuf, "tcp_address : %s\n", inet_ntoa(*addptr) );
    fputs( fbuf, file1 );

/* Network protocol - 'tcp' for all non-clix platforms */
    if( NFMencrypt("tcp", e_prop16) != NFM_S_SUCCESS )
    {
         printf("Encrypt failed\n");
         fclose( file1 );
         return(-1);
    }
    sprintf( fbuf, "NETPROP16 : %s\n", e_prop16);
    fputs( fbuf, file1 );

/* Schema name */
    s = strtok( NULL, "\001" );
    sprintf( fbuf, "NETPROP20 : %s\n", s );
    fputs( fbuf, file1 );

/* Schema passwd */
    s = strtok( NULL, "\001" );
    sprintf( fbuf, "NETPROP21 : %s\n", s );
    fputs( fbuf, file1 );

/* User name */
    s = strtok( NULL, "\001" );
    sprintf( fbuf, "NETPROP17 : %s\n", s );
    fputs( fbuf, file1 );

/* User passwd */
    s = strtok( NULL, "\001" );
    sprintf( fbuf, "NETPROP18 : %s\n", s );
    fputs( fbuf, file1 );

    fclose( file1 );
    return(0);

}
