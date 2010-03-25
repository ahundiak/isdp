#ifndef lint
static char	*sccsid = "@(#)$Header: /usr7/deltools/Deltools/src/newprod/RCS/fksyslg.c 1.1.51.1.1.1 1997/09/08 21:49:36 pinnacle Exp $";
#endif

/*
 * Fake syslog routines for systems that don't have syslog.
 * Taken from an idea by Paul McKenny, <mckenny@sri-unix.arpa>.
 * (Unfortunately, Paul, I can't distribute the real syslog code
 * as you suggested ... sigh.)
 *
 * Warning: this file contains joe code that may offend you.
 */

#include "defs.h"
#include "fakesyslog.h"

#ifdef FAKESYSLOG

#include <stdlib.h>
#include <stdio.h>
#include <sys/signal.h>
#include <sys/types.h>

#ifdef FAKEAPPEND
#include <sys/file.h>
#endif

#ifdef FCNTL
#include <fcntl.h>
#endif

extern	int	errno;
extern	int	sys_nerr;
extern	char	*sys_errlist[];

static FILE	*logfp;
static int	failed = 0;
static char	*ident = "syslog";
static char name[20];
static int 	opt = 0;
#ifndef BSD_42
static int	fac = 0;
#endif

extern char	*strcpy(), *strcat(), *ctime();
extern time_t	time();

void
resetlog(dummy)
	int dummy;
{
	closelog();
	failed = 0;
	if (logfp == NULL) {
#ifdef BSD_42
		openlog(ident, opt);
#else
		openlog(ident, opt, fac);
#endif
		if (logfp == NULL) {
			failed = 1;
			return;
		}
	}
}

#ifdef BSD_42
openlog(newident,logopt)
	char *newident;
	int logopt;
#else
openlog(newident,logopt,facility)
	char *newident;
	int logopt, facility;
#endif
{
	char logfile[128];
	int fd;

	strcpy(logfile, BASEDIR);
	strcat(logfile, FAKELOGFILE);

#ifdef FAKEAPPEND
/*
 * why can't stdio give us the capability of O_APPEND?
 */

	gethostname(name,19);

	fd = open(logfile, O_WRONLY|O_APPEND|O_CREAT, 0664);
	if (fd < 0)
		logfp = NULL;
	else
		logfp = fdopen(fd, "a");
#else
	logfp = fopen(logfile, "a");
#endif
	(void)signal(SIGHUP, resetlog);

	if (newident && *newident)
		ident = newident;
	opt = logopt;
#ifndef BSD_42
	fac = facility;
#endif
}

closelog()
{
	if (logfp) {
		(void)fclose(logfp);
		failed = 0;
		logfp = NULL;
	}
}

/*ARGSUSED*/
setlogmask(maskpri)
	int maskpri;
{
}

syslog(pri, msg, x1, x2, x3, x4, x5, x6)
	int	pri;
	char	*msg, *x1, *x2, *x3, *x4, *x5, *x6;
{
	char		buf[1024];
	char		*cp, *bp;
	time_t		clock;

	if (failed)
		return;

	if (logfp == NULL) {
#ifdef BSD_42
		openlog(ident, opt);
#else
		openlog(ident, opt, fac);
#endif
		if (logfp == NULL) {
			failed = 1;
			return;
		}
	}

	(void) time(&clock);
	(void) strcpy(buf, ctime(&clock)+4);
	*(bp = buf + 16) = '\0';

	(void) sprintf(bp, "%s %s",name, ident ? ident : "");
	bp += strlen(bp);

	if (opt&LOG_PID) {
		/* don't cache getpid() - who knows when we'll fork() */
		(void) sprintf(bp, "[%d]", getpid());
		bp += strlen(bp);
	}

	if (ident) {
		(void) strcat(bp, ": ");
		bp += 2;
	} else {
		(void) strcat(bp, " ");
		bp ++;
	}

	for (cp = msg; *cp; cp++) {
		if (*cp == '%' && cp[1] == 'm') {
			*bp = '\0';
			if (errno >= sys_nerr || errno < 0) {
				char	work[32];
				(void)sprintf(work, "unknown error #%d", errno);
				(void)strcat(bp, work);
			} else
				(void)strcat(bp, sys_errlist[errno]);
			bp = buf + strlen(buf);
			cp++;
		} else {
			*bp++ = *cp;
		}
	}
	*bp = '\0';
	/* Ah, the semantic security of C ... */
	if (bp[-1] != '\n')
		(void) strcat(bp, "\n");

	fprintf(logfp, buf, x1, x2, x3, x4, x5, x6);
	(void) fflush(logfp);
}

#endif
