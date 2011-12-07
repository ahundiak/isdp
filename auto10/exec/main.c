/* 
 * File:   main.c
 * Author: impd
 *
 * Created on December 4, 2010, 8:20 AM
 */

#include <stdio.h>
#include <stdlib.h>
// #include "config.h"

/*
 * 
 */
int main(int argc, char** argv)
{
    int result;

    result = multiple(6,7);

    printf("Hello from %s %d\n",argv[0],result);
    return (EXIT_SUCCESS);
}

