#define AS_status(Msg_to_send)\
  {\
  if(!(status & 0x00000001))\
    {\
    return(status);\
  }\
}\


/* Possibles actions :                                                        */

#define CONTINUE   0                 /* Continue the current process          */
#define RET_STATUS 1                 /* Return with the status of the message */
#define RET_VALUE  2                 /* Return with the value specified       */
#define GOTO_VALUE 3                 /* Go to the specified value             */

/* Macro definition                                                           */

#omdef as$status(sts     = status,
                 msg     = NULL,
                 test    = (!(status &0x00000001)),
                 action  = CONTINUE,
                 value   = NULL,
                 string   = NULL)
#if ((om$specified(sts))&&(!om$specified(test)))
if(!((sts) &0x00000001))\
#else
if(test)\
#endif
  {
#if om$specified(action)
#if om$specified(value)
#if om$equal(action,RET_VALUE)
   return((value));\
#else if om$equal(action,GOTO_VALUE)
   goto value;\
#endif
#endif
   if((action) == RET_STATUS) return((sts));\
#endif
   }\
#endomdef

/*

How to use this macro:
---------------------

OMuint sts      : Name of status to analyse. Default name is "status".

int    test     : Test to apply (generaly function of sts). Default test
		  is "(!(status &0x00000001))".

char   *message : Specific message to print out if "test" is verified.
		  Defaut is no specific message printed out.
		  In every case the following message is printed out :
                  "Error at line XX of the file YY", and if "test" isn't
                  specified, error from om$report_error().

short  action   : Action to do if "test" is verified. Default is no action.
		  The eligible actions are :

                  RET_STATUS : Execute a "return(sts)",

                  RET_VALUE  : If "value" is specified, execute "return(value)",

                  GOTO_VALUE : If "value" is specified, execute a "goto value".

int   value     : Value used with following actions : RET_VALUE and GOTO_VALUE.


Note :	If integration version, no error messages will be printed out but
----	actions will be executed.
*/
