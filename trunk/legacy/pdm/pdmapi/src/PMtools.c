#include <stdio.h>
#include <PDMapi_value.h>
#include <PDMapi_struc.h>
#include <PDUerror.h>
#include <PDUuser.h>
#include <PDMproto.h>
#include <PDUproto.h>

extern struct PDUuser *user;
extern int PDU_IS_LOGGED_IN;

/*  ALR  This file contains API tools for supporting the API functions. */


long pdmcheck_log_in()
{
  if (PDU_IS_LOGGED_IN == 1)
    return(1);
  else
    return(0);   
}
