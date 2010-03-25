#ifdef HOSTS_ACCESS

 /*
  * This module implements a simple but effective form of access control
  * based on host (or domain) names, netgroup, internet addresses (or network
  * numbers) and daemon process names, with wild card support.
  * 
  * Diagnostics are reported through syslog(3).
  * 
  * Compile with -DHOSTS_ACCESS in order to enable access control. See the
  * hosts_access(5) manual page for details.
  * 
  * Compile with -DNETGROUP if your library provides support for netgroups.
  * 
  * Author: Wietse Venema, Eindhoven University of Technology, The Netherlands.
  */

#ifndef lint
static char sccsid[] = "@(#) hosts_access.c 1.5 91/05/20 13:28:03";
#endif

#include <stdlib.h>
#include <stdio.h>
#ifndef SYSV
#include <syslog.h>
#else
#include "fakesyslog.h"
#endif
#include <ctype.h>
#include "defs.h"

extern char *fgets();
extern char *strchr();
extern char *strtok();
extern void exit();

#if defined(SVR4) && defined(NEWDIRS)
extern char *ingrhome;
#endif

 /* Path names of the access control files. */

#define HOSTS_ALLOW	"deltools/node/hosts.allow"
#define HOSTS_DENY	"deltools/node/hosts.deny"

 /* Delimiters for lists of daemons or clients. */

static char sep[] = ", \t";

 /* Constants to be used in assignments only, not in comparisons... */

#define	YES		1
#define	NO		0

/* hosts_access - host access control facility */

hosts_access(fullname, iaddr)
char	*fullname;
char	*iaddr;
{
    char hosts_allow[256], hosts_deny[256];
    char hostname[64];
    char *fdp;
    char *c1, *c2;


#if defined(SVR4) && defined(NEWDIRS)
    sprintf(hosts_allow, "%s/%s", ingrhome, HOSTS_ALLOW);
    sprintf(hosts_deny, "%s/%s", ingrhome, HOSTS_DENY);
#else
    sprintf(hosts_allow, "%s/%s", BASEDIR, HOSTS_ALLOW);
    sprintf(hosts_deny, "%s/%s", BASEDIR, HOSTS_DENY);
#endif

    hostname[0] = 0;
    if (fdp = strchr(fullname, '.')) {
	for (c1 = fullname, c2 = hostname; c1 < fdp; c1++, c2++)
	    *c2 = *c1;
	
	*c2 = 0;
    }

    /*
     * If the client is matched by an entry in the file
     * hosts.allow, access is granted. Otherwise, if the
     * client is matched by an entry in hosts.deny, access is
     * denied. Otherwise, access is granted.
     * 
     * If a connection is refused, we write a syslog record
     */

    if ((*fullname && table_match(hosts_allow, fullname)) ||
        (*hostname && table_match(hosts_allow, hostname)) ||
        table_match(hosts_allow, iaddr)) {
	return(0);
    }
    else if ((*fullname && table_match(hosts_deny, fullname)) ||
	    (*hostname && table_match(hosts_deny, hostname)) ||
	    table_match(hosts_deny, iaddr)) {
	syslog(LOG_WARNING, "Refused connection from %s (%s)", fullname, iaddr);
	return(-1);
    }
    else
	return(0);
}

/* table_match - match table entries with fullname */

int     table_match(table, client)
char   *table;
char   *client;
{
    FILE   *fp;
    char    cl_list[BUFSIZ];		/* becomes list of clients */
    int     match = NO;
    int     end;

    /*
     * Process the table one line at a time. Lines that begin with a '#'
     * character are ignored. Non-comment lines are broken at the ':'
     * character (we complain if there is none). The left part is matched
     * against the daemon process name (argv[0]), the right part against the
     * host name. A non-existing table is treated as if it were an empty
     * table.
     */

    if (fp = fopen(table, "r")) {
	while (!match && fgets(cl_list, sizeof(cl_list), fp)) {
	    if (cl_list[end = strlen(cl_list) - 1] != '\n') {
		syslog(LOG_ERR, "%s: line exceeds STDIO buffer size", table);
	    } else {
		cl_list[end] = '\0';		/* strip trailing newline */
	    }
	    if (cl_list[0] == '#')		/* skip comments */
		continue;

	    match = list_match(cl_list, client);
	}
	(void) fclose(fp);
    }
    return (match);
}

/* list_match - match a string against a list of tokens */

int     list_match(list, string)
char   *list;
char   *string;
{
    char   *tok;
    int     tok_len;
    int     str_len;

    /*
     * Process tokens one at a time. If a token has the magic value "ALL" the
     * match always succeeds. If the token is a domain name, return YES if it
     * matches the last fields of the string. If the token has the magic
     * value "LOCAL", return YES if the string does not contain a "."
     * character. If the token is a network number, return YES if it matches
     * the head of the string. If the token looks like a netgroup name,
     * return YES if the string is a (host) member of the netgroup.
     * Otherwise, return YES if the token fully matches the string. Note: we
     * assume that a daemon process name never begins or ends with a "." or
     * "@" character.
     */

    for (tok = strtok(list, sep); tok; tok = strtok((char *) 0, sep)) {
	if (tok[0] == '.') {			/* domain: match last fields */
	    if ((str_len = strlen(string)) > (tok_len = strlen(tok))
		&& strcasecmp(tok, string + str_len - tok_len) == 0)
		return (YES);
#ifdef	NETGROUP
	} else if (tok[0] == '@') {		/* netgroup: look it up */
	    if (innetgr(tok + 1, string, (char *) 0, (char *) 0))
		return (YES);
#endif
	} else if (strcasecmp(tok, "ALL") == 0) {	/* all: match any */
	    return (YES);
	} else if (strcasecmp(tok, "LOCAL") == 0) {	/* local: no dots */
	    if (strchr(string, '.') == 0)
		return (YES);
	} else if (!strcasecmp(tok, string)) {	/* match host name or address */
	    return (YES);
	} else if (tok[(tok_len = strlen(tok)) - 1] == '.'	/* net number */
		   && strncmp(tok, string, tok_len) == 0) {
	    return (YES);
	}
    }
    return (NO);
}

#endif
