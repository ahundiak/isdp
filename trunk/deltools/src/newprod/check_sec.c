#if defined(SecureWare) || defined(SCO)
/*
 *  	check_sec.c
 *	routines to do specific checks under C2 security
 *
 *	rhost_check()	- takes hostent pointer and validates it using
 *			  the appropriate secure library calls
 *			  (getprtcnam()).
 *
 *	check_lock()	- checks the appropriate flags for various locks
 *			  in the audit database.  Returns 1 if locked
 *			  out, 0 otherwise.
 *
 *	update_login()	- updates the audit database with the user
 *			  information to indicate that access has taken
 *			  place.  A flag of 1 will indicate that
 *			  validation failed and increment the
 *			  appropriate values.  A 0 flag will clear all
 *			  flags to indicate a successful login has been
 *			  made. [ This routine may not be valid for all
 *			  types of account accesses. ]
 */

#include <sys/types.h>
#include <stdio.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include <sys/immu.h>
#include <sys/region.h>
#include <sys/proc.h>
#include <sys/inode.h>
#ifdef SCO
#include <sys/security.h>
#include <sys/audit.h>
#include <prot.h>
#include <protcmd.h>
#else
#include <sys/sec/sectypes.h>
#include <sys/sec/security.h>
#include <sys/sec/audit.h>
#include <tcb/prot.h>
#include <tcb/protcmd.h>
#endif

struct pr_term *
rhost_check(hp)
struct hostent *hp;
{
        register struct pr_term *pr;
        char host_entry[14];
        int i;
        char *addr;

        if (hp == NULL) {
	    audit_auth_entry("nohost", 0, "not a valid host addr in \'/etc/hosts\'", ET_LOGIN);
	    return(NULL);
        }

        addr = hp->h_addr_list[0];
        for (i = 0; i < hp->h_length; i++)
                sprintf (&host_entry[i*2], "%2.2x", addr[i] & 0xff);
        strcat(host_entry, "0000");

        pr = getprtcnam(host_entry);

        if (pr == (struct pr_term *) 0)  {
	    audit_auth_entry(host_entry, OT_TERM_CNTL,
                 "current host is not in Terminal Control Database", ET_LOGIN);
        }

	return (pr);
}


check_lock(prpwd)
struct pr_passwd *prpwd;
{
	if ( locked_out(prpwd) ||
             (prpwd->uflg.fg_type && ISBITSET(prpwd->ufld.fd_type,
					      AUTH_RETIRED_TYPE) ) ) {
			return(1);
	}
	return(0);
}

void
update_login(prpwd,flag)
struct pr_passwd *prpwd;
int flag;
{
  	if (flag) {
          	prpwd->uflg.fg_nlogins=1;
                prpwd->ufld.fd_nlogins++;
        	putprpwnam(prpwd->ufld.fd_name,prpwd);
		return;
	}
        prpwd->uflg.fg_nlogins=0;
        prpwd->ufld.fd_nlogins=0;
        putprpwnam(prpwd->ufld.fd_name,prpwd);
}

#endif
