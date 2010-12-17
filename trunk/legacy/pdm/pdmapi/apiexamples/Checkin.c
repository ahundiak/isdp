#include <stdio.h>
#include <PDMapi_hdr.h>

main()
{
  int	debug_toggles[8] = {1,1,1,1,0,0,1,1};
  char	**debug_paths = NULL;
  char	environment[9],pdmuser[14],pdmpass[14];
  long	status;
  struct	pdmWorkingArea *working_ptr = NULL;
  struct	file_info *file_list = NULL;

  /*  Turn on Debug  */

  debug_paths = (char**) malloc (sizeof (char *) * 8);

  debug_paths[0] = (char *) malloc (80);
  debug_paths[1] = (char *) malloc (80);
  debug_paths[2] = (char *) malloc (80);
  debug_paths[3] = (char *) malloc (80);
  debug_paths[4] = (char *) malloc (80);
  debug_paths[5] = (char *) malloc (80);
  debug_paths[6] = (char *) malloc (80);
  debug_paths[7] = (char *) malloc (80);

  printf("\nTurning on Debug \n");

  status = pdmoDebugOn (debug_toggles,debug_paths);
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from debug on <0x%.8x>\n",status);
    printf("\nExiting with errors\n");
    exit(1);
  }

  strcpy(environment,"mychelle");
  strcpy(pdmuser,"nfmadmin");
  strcpy(pdmpass,"nfmadmin");

  printf("\n\nLogging into environment %s\n",environment);

  status = pdmoLogin(environment,pdmuser,pdmpass,&working_ptr);
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from login <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nLogin successful\n");

  printf("\nchecking in 1001\n");
  status = pdmoCheckinPart("shane", "1001", "-", "1001", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1002\n");
  status = pdmoCheckinPart("shane", "1002", "-", "1002", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1003\n");
  status = pdmoCheckinPart("shane", "1003", "-", "1003", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1004\n");
  status = pdmoCheckinPart("shane", "1004", "a", "1004", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1005\n");
  status = pdmoCheckinPart("shane", "1005", "-", "1005", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1006\n");
  status = pdmoCheckinPart("shane", "1006", "-", "1006", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1007\n");
  status = pdmoCheckinPart("shane", "1007", "-", "1007", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1008\n");
  status = pdmoCheckinPart("shane", "1008", "-", "1008", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1009\n");
  status = pdmoCheckinPart("shane", "1009", "-", "1009", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");

  printf("\nchecking in 1010\n");
  status = pdmoCheckinPart("shane", "1010", "-", "1010", "Y");
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from Checkin <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nCheckin successful\n");


  /*  Log out of environment */

  printf("\nLogging out of environment %s\n",environment);

  status = pdmoLogout();

  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from logout <0x%.8x>",status);
    printf("\nExiting with errors\n");
    exit(1);
  }
  else
    printf("\nLogout successful\n");

  status = pdmoDebugOff();
  exit(0);

}

