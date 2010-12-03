#include <stdio.h>

#include "VDPaimPostMan.h"

int main(int argc, char *argv[])
{
  int sts;
  char user[100],server[100],env[100];
  
  sts = VDPaimPostManConnect("pink"); // pca4402 - avd production, pcz0407 ingr test
  printf("Connect Status %d\n",sts);

  if (sts) return 0;

  VDPaimGetServerInfo(user, server, env);
  printf("INFO User %s, Server %s, Env %s\n",user,server,env);

  VDPaimPostManDisConnect();
  return 0;

}
