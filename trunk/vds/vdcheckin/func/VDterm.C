/*-----------------------------------------------------------------------------
 * 
 * I/VDS
 *
 * File:        vdcheckin/func/VDterm.C
 *
 * Description: Created when fixing TR 179800237
 *
 * Dependencies:
 *
 * Reference:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/08/96        Sundar          creation date
 *      02/24/96        Ravi 		Added the function VDreportterm()
 *---------------------------------------------------------------------------*/

int VDterm (char *env)
{
	char CmdString[1024] ;
	int rc=1;

#ifdef ENV5
      sprintf (CmdString,
              "/usr/ip32/vt200/vterm  -N %s -T \"VDS access to database\" &",env);
#else
 sprintf (CmdString,
               "xterm  -T \"VDS access to database\" -e telnet %s &", env);
#endif
 
      return rc= system (CmdString);
}


int VDreportterm (char *server, char *cmd_name, char *env)
{
        char CmdString[1024] ;
        int rc=1;

#ifdef ENV5
      sprintf (CmdString,
              "/usr/ip32/vt200/vterm -N %s -T %s -f %s &", server, cmd_name, env);
#else
 sprintf (CmdString,
               "xterm  -T %s  -e telnet %s &", cmd_name, server);
#endif

      return rc= system (CmdString);
}
