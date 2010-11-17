#include "stdlib.h"
#include "stdio.h"

/* -----------------------------------------------
 * Get a file via ftp
 */
#include <sys/types.h>
#include <sys/stat.h>
int ftp_get(
  char *host,
  char *user,
  char *password,
  char *dir,
  char *fileName)
{
  char   cmd[256];
  struct stat fileStat;
 
  sprintf(cmd,
    "ftp -n %s > ftp_get.out <<END_SCRIPT\n"
    "quote USER %s\n"
    "quote PASS %s\n"
    "bin\n"
    "cd  %s\n"
    "get %s\n"
    "quit\n"
    "END_SCRIPT\n",host,user,password,dir,fileName);

  /* Execute it */
  system(cmd);

  /* Check for errors in file */
  stat("ftp_get.out",&fileStat);
  if (fileStat.st_size) 
  {
    logMsg(1,1,"*** Problem getting %s %s %s %s\n",
      host,user,dir,fileName);
    system("cat ftp_get.out");
    return 0;
  }

  /* Clean up */
  remove("ftp_get.out");
  return 1;
}


