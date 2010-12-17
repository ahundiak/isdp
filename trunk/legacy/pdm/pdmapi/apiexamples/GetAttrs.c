#include <stdio.h>
#include <PDMapi_hdr.h>

main()
{
  int	debug_toggles[8] = {1,1,1,1,0,0,1,1};
  char	**debug_paths = NULL;
  char	environment[9],pdmuser[14],pdmpass[14];
  long	status;
  struct	pdmWorkingArea *working_ptr = NULL;
  struct attribute_info *attr_list = NULL;

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

  printf("\nRetrieving attributes\n");
  status = pdmoGetPartAttributes("cat30", "part1_30", "a", &attr_list);
  if (status != PDM_S_SUCCESS)
    printf("\npdmoGetPartAttributes failed\n");

  printf("\nFreeing attribute structure\n");
  status = pdmoFreeAttrStructure(&attr_list);
  if (status != PDM_S_SUCCESS)
    printf("\npdmoFreeAttrStructure failed\n");

  status = pdmoDebugOff();

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

  exit(0);

}

