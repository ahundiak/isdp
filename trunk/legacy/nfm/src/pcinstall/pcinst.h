/******************************************************************************
  
 SOURCE FILE: pcinst.h
  
 AUTHOR: Melania M Seward
  
 DATE: 09/03/93
  
 SDM NUMBER:
  
 DESCRIPTION: This header file is the the PC NFM installation program.
  
   FUNCTIONS INVOKED:

 PARAMETERS:
  
  ON ENTRY:
  
  ON EXIT:
  
 EXTERNAL VARIABLES:
  
 CHANGE HISTORY:
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "CLIstruct.h"

#define PC_NFS		1
#define FTP		2
#define WOLLENGONG	3

#define CLI_S_SUCCESS 0L
#define CLI_E_FAILURE 1L
