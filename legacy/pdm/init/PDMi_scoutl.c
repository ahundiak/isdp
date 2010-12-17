#include <stdio.h>
#include <string.h>

#define		TRUE			 1
#define		FALSE			 0

#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "SQLerrordef.h"

#include "PDMmach_id.h"
#include "PDMinit.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "PDMproto.h"

/* local definitions */


extern 	struct	msg_struct   NFMmsg_ptr;
extern 	struct	msg_struct   MEMmsg_ptr;
extern 	struct	msg_struct   SQLmsg_ptr;

extern  int		PDMdebug_on;
extern	char    PDM_DEBUG_FILE[];

#if defined (sco)
int PDMget_substr(const char *mainstr, char *delim, char *searchstr) {
  char buffer[200];
  char *token;

  strcpy (buffer, mainstr);
  token = strtok(buffer, delim);
  while(NULL != token) {
    if (0 != strcmp(token, searchstr)) {
      token = strtok(NULL, delim);
      continue;
    }
    else {
      PDMdebug("PDMget_substr : Success \n");
      return TRUE;
    }
  }
  return FALSE;
}
  
char *PDMget_proddir() {
  char *ingrhome;
  FILE *infile;
  char *ingrfile;
  char buf[200];
  char substr[20][200];
  char *tok;
  int counter, i;

  _PDMdebug("Enter : PDMget_proddir() \n");

  /* Get ingrhome */
  ingrhome = getenv("INGRHOME");
  if (!ingrhome) {
    PDMdebug("INGRHOME is not defined \n");
    return NULL;
  }
  _PDMdebug("INGRHOME is %s \n", ingrhome);

  /* ingrfile name is ingrhome/ingrconfig */
  ingrfile = (char *)malloc(strlen(ingrhome)+1+strlen("ingrconfig")+1);
  if (!ingrfile) {
    _PDMdebug("malloc for ingrfile failed \n");
    return NULL;
  }
  sprintf (ingrfile, "%s/ingrconfig", ingrhome);
  PDMdebug("INGRFILE is %s \n", ingrfile);
  
  if ((FILE *)NULL == (infile = fopen(ingrfile, "r"))) {
    PDMdebug("Ingrconfig file could not be opened \n");
    return NULL;
  }

  while (TRUE) {
    fgets (buf, 200, infile);
    if (feof(infile)) {
      PDMdebug("No PDM entry in config file \n");
      return NULL;
    }
    if (PDMget_substr(buf, "#", "I_PDM")) 
        break;
  }
  tok = strtok(buf, "#");
  counter = 0;
  while (NULL != tok) {
    strcpy (substr[counter++], tok); 
    tok = strtok(NULL, "#");
  }

  for (i=0; i<=counter;i++) {
    if (PDMget_substr(substr[i], "/", "pdm")) {
      PDMdebug("The PDM path is %s \n", substr[i]);
      return substr[i]; 
    }
  }

  PDMdebug("The I_PDM path does not has pdm dir\n");
  return NULL;
}
#endif
