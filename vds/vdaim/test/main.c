#include <stdio.h>
#include <assert.h>

#include "VDPaimPostMan.h"

int main(int argc, char *argv[])
{
  int sts;
  char user[100],server[100],env[100];

  /* ==========================================
   * pca4402 - Production aim
   * pca4407 - avondale nothing
   * pca4408 - avondale nothing
   * 
   * pcz0407 - Intergraph test
   * pink Oracle 11
   * test itf
   */
  assert(argc > 1);
  
  sts = VDPaimPostManConnect(argv[1]);
  printf("Connect Status %d\n",sts);

  if (sts) return 0;

  VDPaimGetServerInfo(user, server, env);
  printf("INFO User %s, Server %s, Env %s\n",user,server,env);

  VDPaimPostManDisConnect();
  return 0;

}
