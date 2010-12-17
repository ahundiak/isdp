#include <stdio.h>
#include <PDMapi_hdr.h>

main()
{
  int	debug_toggles[8] = {1,1,1,1,0,0,1,1};
  char	**debug_paths = NULL;
  char	environment[9],pdmuser[14],pdmpass[14];
  long	status;
  struct	pdmWorkingArea *working_ptr = NULL;
  struct	chg_file_info *file_list = NULL;

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

  printf("\n\nLoading change file structure with first file\n");

  status = pdmoLoadChangeStructure("file", "changed file", "api_oct1.m01", "api_oct1.d01", "api_oct1.m01", "api_oct1.d01", "i", NULL, 2, &file_list);
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from loading file structure <0x%.8x>",
      status);
    printf("\nFreeing change structure");

    status = pdmoFreeChangeStructure(&file_list);

    printf("\nExiting with errors\n");
    exit(1);
  }

  printf("\n\nLoading change file structure with second file\n");

  status = pdmoLoadChangeStructure("file", "changed file", "api_oct2.m01", NULL, "api_oct2.m01", NULL, "i", NULL, 2, &file_list);
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from loading file structure <0x%.8x>",
      status);
    printf("\nFreeing change structure");

    status = pdmoFreeChangeStructure(&file_list);

    printf("\nExiting with errors\n");
    exit(1);
  }

  /*  Free change file structure  */

  printf("\nFreeing change file structure\n");

  status = pdmoFreeChangeStructure(&file_list);

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

