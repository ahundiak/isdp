#include <stdio.h>


main()
{
int fd;

printf("start\n");

fd = mkclient("jenny",1585);

printf("File descriptor %d\n",fd);
printf("End\n");

}




