#include <stdio.h>
#include <PDMapi_hdr.h>

main()
{
  char  buffer[180];
  char  env_name[9],pdmuser[14],pdmpass[14];
  long status;
  struct pdmWorkingArea *store_ptr = NULL;
  struct attribute_info *attr_list = NULL;
  int   debug_toggles[8] = {1,1,1,1,0,0,1,1};
  char  **debug_paths = NULL;



  printf("Enter environment name \n");
  gets(buffer);
  strcpy(env_name,buffer);

  printf("Enter pdm user name \n");
  gets(buffer);
  strcpy(pdmuser,buffer);

  printf("Enter pdm password \n");
  gets(buffer);
  strcpy(pdmpass,buffer);

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

  printf("\n");
  printf("Login to environment %s\n",env_name);

  status = pdmoLogin(env_name,pdmuser,pdmpass,&store_ptr);
  if (status != PDM_S_SUCCESS)
    {
      printf("Return status from login <0x%.8x> \n",status);
      exit(1);
    }

  printf("Output from login is saname |%s|, sanum %d userid %d \n",
          store_ptr->saname,store_ptr->sanum,store_ptr->userid);
  printf("\n");



  status = pdmoLoadAttrStructure("trib1", "char(10)", "one", "mjg", &attr_list);
  if (status != PDM_S_SUCCESS)
  {
    printf("pdmoLoadAttrStructure failed\n");
    exit(1);
  }

  status = pdmoLoadAttrStructure("trib2", "real", "two", "1.5", &attr_list);
  if (status != PDM_S_SUCCESS)
  {
    printf("pdmoLoadAttrStructure failed\n");
    exit(1);
  }

  status = pdmoLoadAttrStructure("trib3", "integer", "three", "100", &attr_list);
  if (status != PDM_S_SUCCESS)
  {
    printf("pdmoLoadAttrStructure failed\n");
    exit(1);
  }

  status = pdmoFreeAttrStructure(&attr_list);
  if (status != PDM_S_SUCCESS)
  {
    printf("pdmoFreeAttrStructure failed\n");
    exit(1);
  }

  status = pdmoDebugOff();
  if (status != PDM_S_SUCCESS)
  {
    printf("\nReturn status from debug off <0x%.8x> \n",status);
    printf("\nExiting with errors\n");
    exit(1);
  }

  printf("\n");
  printf("Logout of environment \n");

  status = pdmoLogout();
  if (status != PDM_S_SUCCESS)
  {
    printf("Return status from logout <0x%.8x> \n",status);
    exit(1);
  }


exit(0);
}
