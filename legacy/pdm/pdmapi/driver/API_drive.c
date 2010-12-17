#include <stdio.h>
#include <PDMapi_value.h>
#include <PDMapi_struc.h>
#include <PDUerror.h>


main()
{
  char  buffer[180];
  char  env_name[9],pdmuser[14],pdmpass[14];
  long status;
  struct pdmWorkingArea *store_ptr;



  printf("Enter environment name \n");
  gets(buffer);
  strcpy(env_name,buffer);

  printf("Enter pdm user name \n");
  gets(buffer);
  strcpy(pdmuser,buffer);

  printf("Enter pdm password \n");
  gets(buffer);
  strcpy(pdmpass,buffer);


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
  printf("Logout of environment \n");

  status = pdmoLogout();
  if (status != PDM_S_SUCCESS)
  {
    printf("Return status from logout <0x%.8x> \n",status);
    exit(1);
  }


exit(0);
}
