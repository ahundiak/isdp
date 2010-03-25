#ifdef SecureWare
/* Copyright (c) 1988, SecureWare, Inc.
 *   All rights reserved.
 */

#ident "@(#)login_sec.c	2.28 11:52:28 2/15/90 SecureWare"

/*
 * This Module contains Proprietary Information of SecureWare, Inc. and
 * should be treated as Confidential.
 */

/*LINTLIBRARY*/

/*
 * This file is part of a library to make commands more secure.
 * This file contains those routines that are added to the
 * login command.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <pwd.h>
#include <grp.h>
#include <stdio.h>
#include <termio.h>
#include <errno.h>
#include <sys/param.h>
#ifdef SEC_NET_TTY
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#endif
#include <sys/immu.h>
#include <sys/region.h>
#include <sys/param.h>
#include <sys/proc.h>
#include <sys/inode.h>
/*#include <sys/sectypes.h>*/
#include <sys/security.h>
#include <sys/audit.h>
#include <prot.h>
#include <protcmd.h>


#define	ATTEMPTS	4	/* login attempts allowed this connection */
#define	TYPEIN_TIME	10	/* in seconds, this time is liberal */
#define	NO_ENTRY	"::"
#define	SYSTEM_CONSOLE	"console"
#define OVERRIDE_USER	"root"

int want_a_timeout = 0;
int is_a_problem = 0;

char auditbuf[80];

priv_t log_old_privs[SEC_SPRIVVEC_SIZE];

static struct pr_passwd *current_prpwd = (struct pr_passwd *) 0;
static struct pr_term *current_prtc = (struct pr_term *) 0;
static struct pr_passwd noprot;
static struct pr_default dflt;
static struct termio initial_settings;
static char *save_tty_path = (char *) 0;
static int term_group = -1;
static int delay_between_attempts = 0;
static mask_t nosprivs[SEC_SPRIVVEC_SIZE];
static struct passwd **pwd_ref;
static char bad_username[9];
static int	timeout_occurred = 0 ;
#ifdef SEC_NET_TTY
static int is_network = 0;
#endif
/*static int login_type = ES_LOGIN_LOCAL;*SCO*/

extern struct passwd nouser;

struct pr_passwd *login_bad_user();
struct pr_passwd *alt_login_bad_user();
void login_delay();
struct pr_term *login_bad_tty();
void alt_login_delay();
char *login_crypt();
char *no_prompt_login_crypt();
void alt_end_authentication();
static void timeout();
static int execute();
static void check_valid_tty();
static void impossible_user();
static void cancel_process();
static void cancel_process_but_no_exit();
static void reset_tty_discr_and_bye();
static void end_authentication();
static void failure_override();
static void alt_failure_override();
static struct pr_term *check_devasg();
#ifdef SEC_NET_TTY
static struct pr_term *check_devasg_net();
#endif

extern long time();
extern int ioctl();
extern int nice();
extern int fstat();
extern char *ctime();
extern char *strcpy();
extern char *strncpy();
extern char *strrchr();
extern char *malloc();
extern char *realloc();
extern int fork();
extern int execl();
extern int wait();
extern int strcmp();
extern struct group *getgrnam();



/*
 * Exit the program now.  Used instead of exit(2) alone to update the
 * Authentication database with the failures.
 */
void
login_die(code)
	int code;
{
	cancel_process(code, current_prpwd, current_prtc);
}




/*
 * This routine is called when it expected that a user has a password.
 * If there is no password, this routine forces the user to get one now.
 * Return success indicator of 1 if successful else 0.
 */
int
login_need_passwd(pr, prtc, pnopassword)
	register struct pr_passwd *pr;
	register struct pr_term *prtc;
	register int *pnopassword;
{
	register int passwd_status;
	struct pr_passwd save_data;
	char nullpwok = 0;

	/* If no password required, return a 1 else continue */

	if((pnopassword == (int *) 0) || (*pnopassword == 0))
		return(1);

	if (pr->uflg.fg_nullpw)
		nullpwok = pr->ufld.fd_nullpw;
	else if (pr->sflg.fg_nullpw)
		nullpwok = pr->sfld.fd_nullpw;

	if (nullpwok || pr->uflg.fg_encrypt && pr->ufld.fd_encrypt[0])
		return 1;

	printf("You don't have a password.\n");
	(void) fflush(stdout);

	passwd_status = execute(PASSWD_PROGRAM, pr->ufld.fd_uid,
				pr->ufld.fd_name);

	/*
	 * We must close and re-open the Protected Password database
	 * here because the passwd program should have updated
	 * the user's entry.  Since pr now points to a static area, we
	 * need to use save_data to hold the data while written.
	 */
	save_data = *pr;
	endprpwent();
	setprpwent();
	pr = getprpwnam(save_data.ufld.fd_name);
	current_prpwd = pr;
	if (pr == (struct pr_passwd *) 0)  {
		audit_login(pr, (struct passwd *) 0,
                               prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
		  "Protected Password information suddenly vanished\n");
		failure_override(&save_data, prtc);
		exit(1);
	}

	if (passwd_status < 0) {
		audit_login(pr, (struct passwd *) 0,
                               prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf(stderr, "Cannot execute passwd program\n");
		failure_override(&save_data, prtc);
		cancel_process(1, pr, prtc);
	}
	else if (passwd_status > 0) {
		audit_login(pr, (struct passwd *) 0,
                               prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf(stderr, "Login aborted due to no password.\n");
		failure_override(&save_data, prtc);
		cancel_process(1, pr, prtc);
	}

	return(1);
}


/*
 * Check for an expired password.  Invoke the passwd program if the
 * passwd is indeed expired.  Returns the possible changed protected
 * password pointer.
 */
struct pr_passwd *
login_check_expired(pr, prtc)
	register struct pr_passwd *pr;
	register struct pr_term *prtc;
{
	register time_t expiration;
	register time_t last_change;
	time_t expiration_time;
	register time_t now;
	register int passwd_status;
	struct pr_passwd save_data;
	struct pr_default *df;

	/*
	 * If null password, do not check for expiration
	 */

	if (!pr->uflg.fg_encrypt || (pr->ufld.fd_encrypt[0] == '\0'))
		return pr;

	now = time((long *) 0);

	if (pr->uflg.fg_schange)
		last_change = pr->ufld.fd_schange;
	else
		last_change = (time_t) 0;

	if (pr->uflg.fg_expire)
		expiration = pr->ufld.fd_expire;
	else if (pr->sflg.fg_expire)
		expiration = pr->sfld.fd_expire;
	else
		expiration = (time_t) 0;

	df = getprdfnam(AUTH_DEFAULT);

	/*
	 * A 0 or missing expiration field means there is no
	 * expiration.
	 */
	expiration_time = expiration ? last_change + expiration : 0;

	if (expiration_time && now > expiration_time)  {
		audit_auth_entry(pr->ufld.fd_name, OT_PRPWD,
                        "password expired");
		printf ("Your password has expired.\n");
		(void) fflush(stdout);

		passwd_status = execute(PASSWD_PROGRAM, pr->ufld.fd_uid,
					pr->ufld.fd_name);

		/*
		 * We must close and re-open the Protected Passwd database here
		 * because the passwd program should have updated
		 * the user's entry.  Since pr now points to a static area, we
		 * need to use save_data to hold the data while written.
		 */
		save_data = *pr;
		endprpwent();
		setprpwent();
		pr = getprpwnam(save_data.ufld.fd_name);
		current_prpwd = pr;
		if (pr == (struct pr_passwd *) 0)  {
			audit_login(pr, (struct passwd *) 0,
                                prtc->ufld.fd_devname, ES_LOGIN_FAILED);
			fprintf (stderr,
			  "Protected Password information suddenly vanished\n");
			failure_override(&save_data, prtc);
			exit(1);
		}

		if (passwd_status < 0) {
			audit_login(pr, (struct passwd *) 0,
                                prtc->ufld.fd_devname, ES_LOGIN_FAILED);
			fprintf(stderr, "Cannot execute passwd program\n");
			failure_override(&save_data, prtc);
			cancel_process(1, pr, prtc);
		}
		else if (passwd_status > 0) {
			audit_login(pr, (struct passwd *) 0,
                                prtc->ufld.fd_devname, ES_LOGIN_FAILED);
			fprintf(stderr,
				"Login aborted due to no new password.\n");
			failure_override(&save_data, prtc);
			cancel_process(1, pr, prtc);
		}
	} 
/* not defined in SCO
else if (df && df->sflg.fg_pw_expire_warning && expiration_time &&
		   expiration_time - now <= df->sfld.fd_pw_expire_warning) {
		printf("\nYour password will expire on %s\n",
			ctime(&expiration_time));
	}
*/

	return pr;
}


/*
 * This is the point of no return for detection of a bad login and the
 * leaving of the login program.  We need to delay in case someone tries
 * to relog into a dedicated line, where there is no hardware hangup to
 * cause an inconvenience delay.
 */
static void
cancel_process(exit_code, pr, prtc)
	int exit_code;
	struct pr_passwd *pr;
	register struct pr_term *prtc;
{

/*
 *
 *	Turn off the alarm(2) so that we don't end up calling timeout()
 *	while we are cleaning up.  This isn't a problem if we were
 *	called from timeout().
 *
 */

	alarm(0) ;

	if (pr != (struct pr_passwd *) 0)
		(void) login_bad_user(pr, prtc);
	if (prtc != (struct pr_term *) 0)
		(void) login_bad_tty(prtc, pr);
	else if (pr != (struct pr_passwd *) 0)
		impossible_user(&pr, pwd_ref);
	if ((pr != (struct pr_passwd *) 0) || (prtc != (struct pr_term *) 0))
		login_delay("exit");
	reset_tty_discr_and_bye(exit_code);
}


/*
 * Perform actions upon recognition of a bad login attempt.  For bad
 * accounts, do nothing.  For good accounts, update the database
 * entry for the account with the time of attempt and that this is
 * another bad attempt.
 */
struct pr_passwd *
login_bad_user(pr, prtc)
	struct pr_passwd *pr;
	struct pr_term *prtc;
{
	struct pr_passwd save_data;
	int	save_alarm ;


	/*
	 * If this login name really doesn't exist, don't even try
	 * to update the Protected Password database.  The less time taken
	 * here than for good accounts that really are updated is
	 * obscured by sleeping login_delay().
	 * Also, reset static current_prpwd in case we get an
	 * alarm signal. For user names that have been set to NO_ENTRY,
	 * restore the original name used at login for auditing the
	 * failed attempt. Then restore NO_ENTRY upon return.
	 */
	if (strcmp(pr->ufld.fd_name, NO_ENTRY) == 0)  {
		strncpy(pr->ufld.fd_name,bad_username,8);

		/*
		 * Audit an unsuccessful login attempt.
		 */
		if ((prtc != (struct pr_term *) 0) && prtc->uflg.fg_devname)
			audit_login(pr, (struct passwd *) 0,
				prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		else
			audit_login(pr, (struct passwd *) 0,
				(char *) 0, ES_LOGIN_FAILED);

		strcpy(pr->ufld.fd_name,NO_ENTRY);
		current_prpwd = (struct pr_passwd *) 0;
		return pr;
	}


	/*
	 * We need the save area to avoid clashing with the static area when
	 * putprpwnam updates the file.  Then, we need to re-establish a new
	 * pr pointer based on what the new entry looks like, later on in this
	 * routine.
	 */
	save_data = *pr;
	pr = &save_data;
	pr->uflg.fg_ulogin = 1;
	pr->ufld.fd_ulogin = time((long *) 0);
	if (pr->uflg.fg_nlogins)
		pr->ufld.fd_nlogins++;
	else  {
		pr->uflg.fg_nlogins = 1;
		pr->ufld.fd_nlogins = 1;
	}
	pr->uflg.fg_unsuctty = 1;
	strncpy(pr->ufld.fd_unsuctty, prtc->ufld.fd_devname,
	  sizeof(prtc->ufld.fd_devname));

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prpwd = (struct pr_passwd *) 0;

/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	save_alarm = alarm(0) ;

	if (!putprpwnam(pr->ufld.fd_name, pr))  {
		audit_login(pr, (struct passwd *) 0, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Can't rewrite protected password entry for user %s\n",
			 pr->ufld.fd_name);
		login_delay("exit");
		exit(1);
	}

/*
 *
 *	Reset possible alarm(2)
 *
 */

	alarm(save_alarm) ;

	/*
	 * We must re-open the Protected Password database here
	 * because the file has been updated and putprpwent()
	 * has closed the file.
	 */
	setprpwent();
	pr = getprpwnam(save_data.ufld.fd_name);
	current_prpwd = pr;
	if (pr == (struct pr_passwd *) 0)  {
		audit_login(pr, (struct passwd *) 0, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Protected Password database problem\n");
		login_delay("exit");
		exit(1);
	}

	/*
	 * Audit an unsuccessful login attempt.
	 */
	if ((prtc != (struct pr_term *) 0) && prtc->uflg.fg_devname)
		audit_login(pr, (struct passwd *) 0,
		 	prtc->ufld.fd_devname,  ES_LOGIN_FAILED);
	else
		audit_login(pr, (struct passwd *) 0,
               		    (char *) 0, ES_LOGIN_FAILED);

	return pr;
}


/*
 * Set the login UID.  Before that, make sure that the account is
 * not locked.  Note we do this after the password is obtained to
 * make sure that the real user of the account gets the locked/nolocked
 * status.  Also, let the user know when he last logged in successfully
 * and his last unsuccessful attempt.
 *
 * Locking is done by the Account Administrator unconditionally, by
 * exceeding the number of bad consecutive attempts or by having the
 * password expire.
 *
 * To prevent denial of use of the system by a malicious person who locks
 * the superuser account by repeated attempting logins, we unconditionally
 * allow the superuser account access on the system console.
 */
void
login_set_user(pr, prtc, p)
	register struct pr_passwd *pr;
	register struct pr_term *prtc;
	register struct passwd *p;
{
	register int users_group;
	register int su_on_console;
	time_t last_login;
	time_t last_bad;
	char *ptime;
#ifdef SEC_NET_TTY
	struct hostent *hp;
	struct dev_asg *dvag;
#endif

	/*
	 * Allow the superuser to log into the console.  This prevents
	 * someone from locking the superuser account or /dev/console
	 * with repeated failures.  We still audit the lock so the
	 * SSO can detect the problem.
	 */
	su_on_console = ((pr != (struct pr_passwd *) 0) &&
			 pr->uflg.fg_uid &&
			 (pr->ufld.fd_uid == 0) &&
			 (prtc != (struct pr_term *) 0) &&
			 prtc->uflg.fg_devname &&
			 (strcmp(SYSTEM_CONSOLE, prtc->ufld.fd_devname) == 0));

	/*
	 * See if any condition will prevent a superuser login.
	 * Locked_out() will still audit the lock even if the superuser
	 * access is given.
	 */
	if (locked_out(pr))  {
		if (su_on_console)
			fprintf(stderr,
			 "Account is disabled but console login is allowed.\n");
		else  {
			fprintf(stderr,
			 "Account is disabled -- see Account Administrator.\n");
			cancel_process(1, pr, prtc);
		}
	}


	/* check for retired account */

	if (pr->uflg.fg_type && ISBITSET(pr->ufld.fd_type, AUTH_RETIRED_TYPE)) {
		audit_login(pr, p, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf(stderr,
		 "Account has been retired -- logins are no longer allowed.\n");
		cancel_process(1, pr, prtc);
	}


	/*
	 * Set the ownership of the terminal.  Under most conditions, we
	 * set the group to the special terminal group.  If that group
	 * does not exist, we set the group to the user's login group.
	 */
	if (term_group == -1)
		users_group = p->pw_gid;
	else
		users_group = term_group;
	if ((save_tty_path == (char *) 0) ||
	    (chown(save_tty_path, pr->ufld.fd_uid, users_group) != 0))  {
		audit_login(pr, p, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf(stderr, "Cannot set terminal mode.\n");
		cancel_process(1, pr, prtc);
	}

	if (!pr->uflg.fg_uid || (setluid(pr->ufld.fd_uid) != 0))  {
		audit_login(pr, p, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf(stderr, "Bad login user id.\n");
		cancel_process(1, pr, prtc);
	}


	/*
	 * Print the last times logins were attempted to this account.
	 */
	if (pr->uflg.fg_ulogin)
		last_bad = pr->ufld.fd_ulogin;
	else
		last_bad = (time_t) 0;

	if (pr->uflg.fg_slogin)
		last_login = pr->ufld.fd_slogin;
	else
		last_login = (time_t) 0;

	(void) fflush(stdout);

	if (last_login == 0)
		ptime = "NEVER";
	else {
		ptime = ctime(&last_login);
		ptime[strlen(ptime)-1] = '\0'; /* strip newline */
	}
	fprintf(stderr, "Last   successful login for %s: %s",
	  pr->ufld.fd_name, ptime);
	if (pr->uflg.fg_suctty) {
#ifdef SEC_NET_TTY
            dvag = getdvagnam(pr->ufld.fd_suctty);
            if (dvag != (struct dev_asg *) 0 &&
		    ISBITSET (dvag->ufld.fd_type, AUTH_DEV_REMOTE)) {
		int i,j;
		char real_addr[5],
		     hex_addr[7];
		sscanf(pr->ufld.fd_suctty,"%8x",&hex_addr);
		hex_addr[4] = 0;
		i = strlen(hex_addr);
	/*do this next bit because the hex address is backwards*/
		for(j = 0; j < i; j++)
			real_addr[j] = hex_addr[i-j-1];
		real_addr[i] = 0;
		hp = gethostbyaddr((char *)real_addr,strlen(real_addr),AF_INET);
                fprintf(stderr, " from %s", hp->h_name);
		endhostent();
            }
            else
                if (ISBITSET (dvag->ufld.fd_type, AUTH_DEV_TERMINAL))
#endif
                        fprintf(stderr, " on %s", pr->ufld.fd_suctty);
        }
	putc ('\n', stderr);

	if (last_bad == 0)
		ptime = "NEVER";
	else {
		ptime = ctime(&last_bad);
		ptime[strlen(ptime)-1] = '\0'; /* strip newline */
	}
	fprintf(stderr, "Last unsuccessful login for %s: %s",
		pr->ufld.fd_name, ptime);
	if (pr->uflg.fg_unsuctty) {
#ifdef SEC_NET_TTY
            dvag = getdvagnam(pr->ufld.fd_unsuctty);
            if (dvag != (struct dev_asg *) 0 &&
		    ISBITSET (dvag->ufld.fd_type, AUTH_DEV_REMOTE)) {
		int i,j;
		char hex_addr[7],
		     real_addr[5];
		sscanf(pr->ufld.fd_unsuctty, "%8x", &hex_addr);
		hex_addr[4] = 0;
		i = strlen(hex_addr);
	/*do this next bit because the hex address is backwards*/
		for(j = 0; j < i; j++)
			real_addr[j] = hex_addr[i - j - 1];
		real_addr[i] = 0;
                hp = gethostbyaddr((char *)real_addr, i, AF_INET);
                fprintf(stderr, " from %s", hp->h_name);
		endhostent();
            }
            else
                if (ISBITSET (dvag->ufld.fd_type, AUTH_DEV_TERMINAL))
#endif
                        fprintf(stderr, " on %s", pr->ufld.fd_unsuctty);
        }
	putc ('\n', stderr);
	(void) fflush(stderr);
}




/*
 * This stub does nothing in the secure version.
 */

login_chown_tty(ttyn,uid,gid)
char *ttyn;
ushort uid, gid;
{
}

/*
 * These are stubs for the secure version that are called to set the user
 * and group ids. These are set elsewhere so these hooks do nothing.
 */

void
login_setuid(uid)
ushort uid;
{
}

void
login_setgid(gid)
ushort gid;
{
}

/*
 * This hook is used in the secure version to return a value which
 * indicates that the password aging check succeeds.
 */

login_aging_check(when, now, minweeks, maxweeks)
time_t when, now, minweeks, maxweeks;
{
	return(0);
}


/*
 * Delay for the number of seconds specified in the terminal control
 * entry for this terminal.  So the user still knows that the system
 * is responsive, print out a wait message (using reason string
 * supplied) and print a dot for each second waited.
 */
void
login_delay(reason)
	char *reason;
{
	int seconds;

	(void) fflush(stderr);
	if (delay_between_attempts == 0)
		return;
	printf("\nWait for login %s: ", reason);
	(void) fflush(stdout);
	for (seconds = 0; seconds < delay_between_attempts; seconds++)  {
		sleep(1);
		printf(".");
		(void) fflush(stdout);
	}
	printf("\n");
	(void) fflush(stdout);
}


/*
 * Find the protected password entry for the user and fill in the argument
 * ppr with it.  If the user cannot be found fill in a bogus entry to
 * use that will 1) allow login to still prompt for a password in the
 * usual way, and 2) not match ANY possible user name.  Fill in the ppwd
 * with the passwd equivalent of "no user" for the same reason.
 * We consider it the case that the user cannot be found if the passwd
 * entry and pr_passwd do not fully reflect the same user.
 */
void
login_fillin_user(user, ppr, ppwd)
	char *user;
	struct pr_passwd **ppr;
	struct passwd **ppwd;
{
	/*
	 * Save this so that later in login_bad_user(), the impossible_user()
	 * routine can be called with the proper pwd argument.
	 */
	pwd_ref = ppwd;

	*ppr = getprpwnam(user);
	if (*ppr == (struct pr_passwd *) 0) {
		/*
		 * if the root account has disappeared from the protected
		 * password database, allow the login anyway.  The check
		 * in login_validate() will continue the process.
		 */
		if (strcmp(user, OVERRIDE_USER) == 0)
			return;
		strncpy(bad_username,user,8);	/* save for auditing */
		impossible_user(ppr, ppwd);
	}
	else if (!(*ppr)->uflg.fg_name || !(*ppr)->uflg.fg_uid ||
		 ((*ppr)->ufld.fd_uid != (*ppwd)->pw_uid) ||
		 (strcmp((*ppr)->ufld.fd_name, (*ppwd)->pw_name) != 0))  {
		audit_auth_entry((*ppwd)->pw_name, OT_PRPWD,
"user appears in /etc/passwd but not in Protected Password database");
		impossible_user(ppr, ppwd);
	}
	else current_prpwd = *ppr;
}


int
login_validate(pprpwd, pprtc, pnopassword)
	register struct pr_passwd **pprpwd;
	register struct pr_term **pprtc;
	int *pnopassword;
{
	register int is_valid_password = 1;

	/*
	 * if there is a problem with the protected password database,
	 * allow a root account login at the console.  If there is a valid
	 * protected password entry, force the password check on the root
	 * account.  Otherwise, an invalid terminal control entry means
	 * that the system should reject the login.
	 */
	if (*pprpwd == (struct pr_passwd *) 0) {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (*pprtc)->ufld.fd_devname, ES_LOGIN_FAILED);
		failure_override(*pprpwd, *pprtc);
	}
	if (*pprtc == (struct pr_term *) 0 &&
	    strcmp((*pprpwd)->ufld.fd_name, OVERRIDE_USER)) {
		audit_login(pprpwd, (struct passwd *) 0, (struct pr_term *) 0, ES_LOGIN_FAILED);
		exit(1);
	}
/* not defined in SCO
	if ((*pprpwd)->uflg.fg_pwchanger) {
		char *pwchanger, buf[16];

		pwchanger = pw_idtoname((*pprpwd)->ufld.fd_pwchanger);
		if (pwchanger == NULL) {
			sprintf(buf, "uid #%u", (*pprpwd)->ufld.fd_pwchanger);
			pwchanger = buf;
		}
		printf("Your password was changed by %s on %s", pwchanger,
			ctime(&(*pprpwd)->ufld.fd_schange));
	}
*/
	if ((*pprpwd)->ufld.fd_encrypt[0] == '\0')
		check_valid_tty(*pprtc, *pprpwd);
	else  {
		if(pnopassword != (int *) 0)
			*pnopassword = 0;

		if(strcmp(login_crypt("Password:", (*pprpwd)->ufld.fd_encrypt),
				      (*pprpwd)->ufld.fd_encrypt) == 0)
			check_valid_tty(*pprtc, *pprpwd);
		else  {
			if (*pprpwd && *pprtc) {
				*pprpwd = login_bad_user(*pprpwd, *pprtc);
				*pprtc = login_bad_tty(*pprtc, *pprpwd);
			}
			printf("Login incorrect\n");
			if ((*pprtc != (struct pr_term *) 0) &&
                                                     (*pprtc)->uflg.fg_devname)
                                        audit_login(pprpwd, (struct passwd *) 0, (*pprtc)->ufld.fd_devname, ES_LOGIN_FAILED);
                                else
                                        audit_login(pprpwd, (struct passwd *) 0,
                                                (char *) 0, ES_LOGIN_FAILED);
			login_delay("retry");
			is_valid_password = 0;
		}
	}

	return is_valid_password;
}


/*
 * Set the process file creation mask to be restrictive.  If the user
 * wants it more lax, he has to open it up explicitly.  Also catch
 * login timeouts as failed login attempts.
 */
void
login_set_sys()
{
	umask(~SEC_DEFAULT_MODE);
	signal(SIGALRM, timeout);
}


/*
 * Find the terminal in the terminal control database.  Then, use the
 * information in the entry to set the alarm clock for login timeouts.
 * We make sure that stdin, stdout, and stderr are character special
 * files and that they point to the same device.
 * Also save the terminal settings in case we timeout later (so we can
 * restore any funny modes that we may be in due to getpasswd(3) settings).
 */
struct pr_term *
login_term_params(tty_path, tty_name)
	char *tty_path;
	char *tty_name;
{
	register struct group *g;
	register struct pr_term *pr;
	struct stat in_buf;
	struct stat out_buf;
	struct stat err_buf;

	save_tty_path = tty_path;

	pr = getprtcnam(tty_name);

	/*
	 * if terminal control database yields a failure, check the device
	 * assignment database for a synonym device.
	 */
	if (pr == (struct pr_term *) 0)
		pr = check_devasg(tty_path);

	if (pr == (struct pr_term *) 0)  {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		fprintf(stderr,
		  "Cannot obtain database information on this terminal\n");
		/*
		 * if there is no entry for the console, the database is
		 * corrupted and a root login should be allowed
		 */
		if (strcmp(tty_name, SYSTEM_CONSOLE) == 0)
			return((struct pr_term *) 0);
		exit(1);
	}

	g = getgrnam("terminal");
	if (g != (struct group *) 0)
		term_group = g->gr_gid;
	endgrent();

	if (pr->uflg.fg_logdelay)
		delay_between_attempts = pr->ufld.fd_logdelay;
	else if (pr->sflg.fg_logdelay)
		delay_between_attempts = pr->sfld.fd_logdelay;
	else
		delay_between_attempts = 0;

	/*
	 * Make sure stdin, stdout, and stderr are terminals and they
	 * are one and the same.
	 */
	if ((fstat(fileno(stdin), &in_buf) != 0) ||
	    (fstat(fileno(stdout), &out_buf) != 0) ||
	    (fstat(fileno(stderr), &err_buf) != 0) ||
	    ((in_buf.st_mode & S_IFMT) != S_IFCHR) ||
	    ((out_buf.st_mode & S_IFMT) != S_IFCHR) ||
	    ((err_buf.st_mode & S_IFMT) != S_IFCHR) ||
	    (in_buf.st_rdev != out_buf.st_rdev) ||
	    (out_buf.st_rdev != err_buf.st_rdev))  {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		fprintf(stderr, "Error in terminal setup.\n");
		exit(1);
	}

	/*
	 * Get the tty settings in case we need to restore them later.
	 * If the ioctl fails, we don't have a terminal to play with where
	 * it should be.  We do this before the alarm is activated so we
	 * are sure to read the information here before the alarm clock
	 * will cause it to be used in timeout().
	 */
	if (ioctl(fileno(stdin), TCGETA, &initial_settings) != 0)  {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		fprintf(stderr, "Cannot obtain settings for this terminal\n");
		exit(1);
	}

	/*
	 * Use the login timeout value from the terminal control dbase
	 * entry if there is one defined. Otherwise, use the following.
	 * Base alarm on rate of login attempts.  Add TYPEIN_TIME seconds
	 * on each attempt to account for some of the overhead in typing in
	 * password.
	 */

	if(pr->sflg.fg_login_timeout)
	    (void) alarm(pr->sfld.fd_login_timeout);
	else
	    (void) alarm(ATTEMPTS * (TYPEIN_TIME + delay_between_attempts));

	current_prtc = pr;
	return pr;
}




#ifdef SEC_NET_TTY
struct pr_term *
login_net_term_params(tty_path, hostname)
        char *tty_path;
        char *hostname;
{
        register struct group *g;
        register struct pr_term *pr;
        struct stat in_buf;
        struct stat out_buf;
        struct stat err_buf;

        struct hostent *hp = gethostbyname(hostname);
        char host_entry[14];
        int i;
        char *addr;

	login_type = ES_LOGIN_REMOTE;

        if (hp == NULL) {
		audit_auth_entry(hostname, 0, "current host is not in \'/etc/hosts\'");
                fprintf("No entry for this hosts in \'/etc/hosts\'.\n");
                exit(1);
        }
        addr = hp->h_addr_list[0];
        for (i = 0; i < hp->h_length; i++)
                sprintf (&host_entry[i*2], "%2.2x", addr[i] & 0xff);
        strcat(host_entry, "0000");

        save_tty_path = tty_path;

        pr = getprtcnam(host_entry);

        /*
         * if terminal control database yields a failure, check the device
         * assignment database for a synonym device.
         */
        if (pr == (struct pr_term *) 0)
                pr = check_devasg_net(host_entry);

        if (pr == (struct pr_term *) 0)  { 
		audit_auth_entry(host_entry, OT_TERM_CNTL,
                 "current host is not in Terminal Control Database");
		fprintf(stderr,
                  "Cannot obtain database information on this host\n");
                exit(1);
        }

        g = getgrnam("terminal");
        if (g != (struct group *) 0)
                term_group = g->gr_gid;
        endgrent();

        if (pr->uflg.fg_logdelay)
                delay_between_attempts = pr->ufld.fd_logdelay;
        else if (pr->sflg.fg_logdelay)
                delay_between_attempts = pr->sfld.fd_logdelay;
        else
                delay_between_attempts = 0;

	/*
         * Make sure stdin, stdout, and stderr are terminals and they
         * are one and the same.
         */
        if ((fstat(fileno(stdin), &in_buf) != 0) ||
            (fstat(fileno(stdout), &out_buf) != 0) ||
            (fstat(fileno(stderr), &err_buf) != 0) ||
            ((in_buf.st_mode & S_IFMT) != S_IFCHR) ||
            ((out_buf.st_mode & S_IFMT) != S_IFCHR) ||
            ((err_buf.st_mode & S_IFMT) != S_IFCHR) ||
            (in_buf.st_rdev != out_buf.st_rdev) ||
            (out_buf.st_rdev != err_buf.st_rdev))  {
                audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
                fprintf(stderr, "Error in terminal setup.\n");
                exit(1);
        }
	
        /*
         * Get the tty settings in case we need to restore them later.
         * If the ioctl fails, we don't have a terminal to play with where
         * it should be.  We do this before the alarm is activated so we
         * are sure to read the information here before the alarm clock
         * will cause it to be used in timeout().
         */
        if (ioctl(fileno(stdin), TCGETA, &initial_settings) != 0)  {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		fprintf(stderr, "Cannot obtain settings for this terminal\n");
                exit(1);
        }

        /*
         * Use the login timeout value from the terminal control dbase
         * entry if there is one defined. Otherwise, use the following.
         * Base alarm on rate of login attempts.  Add TYPEIN_TIME seconds
         * on each attempt to account for some of the overhead in typing in
         * password.
         */

        if(pr->sflg.fg_login_timeout)
            (void) alarm(pr->sfld.fd_login_timeout);
        else
            (void) alarm(ATTEMPTS * (TYPEIN_TIME + delay_between_attempts));

        current_prtc = pr;
        is_network = 1;
        return pr;
}
#endif

/*
 * For a sublogin, re-execute the login command with a special
 * environment indicating a sublogin.
 */
void
login_do_sublogin(envinit)
	char *envinit[];
{
	execle(LOGIN_PROGRAM, "login", (char *) 0, &envinit[0]);
	printf("No login program on root\n");
}


/*
 * This routine is called on each bad login attempt.  The number of consecutive
 * bad attempts is set or incremented, the user (if he exists in the system) is
 * noted along with the time, and this information is written as the new
 * entry for this terminal in the terminal control database.
 */
struct pr_term *
login_bad_tty(pr, prpw)
	struct pr_term *pr;
	struct pr_passwd *prpw;
{
	struct pr_term save_data;
	int	save_alarm ;


	if (timeout_occurred) {
		if (prpw != (struct pr_passwd *) 0)
			impossible_user(&prpw, pwd_ref) ;
		return(pr) ;
	}

	/*
	 * pr until now has pointed to a static area that will get
	 * munged upon the file rewrite.  We have it point to a local
	 * save area until the write is finished.
	 */
	save_data = *pr;
	pr = &save_data;

	pr->uflg.fg_ulogin = 1;
	pr->ufld.fd_ulogin = time((long *) 0);

	if (pr->uflg.fg_nlogins)
		pr->ufld.fd_nlogins++;
	else  {
		pr->uflg.fg_nlogins = 1;
		pr->ufld.fd_nlogins = 1;
	}

	if ((prpw == (struct pr_passwd *) 0) || !prpw->uflg.fg_uid)
		pr->uflg.fg_uuid = 0;
	else  {
		pr->uflg.fg_uuid = 1;
		pr->ufld.fd_uuid = prpw->ufld.fd_uid;
	}

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prtc = (struct pr_term *) 0;


/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	save_alarm = alarm(0) ;

	if (!putprtcnam(pr->ufld.fd_devname, pr))  {
		fprintf (stderr,
			 "Can't rewrite terminal control entry for %s\n",
			 pr->ufld.fd_devname);
		login_delay("exit");
		exit(1);
	}


/*
 *
 *	Reset possible alarm(2)
 *
 */

	alarm(save_alarm) ;

	/*
	 * We must re-open the Terminal Control database here like above
	 * because the file has been updated and putprtcent()
	 * has closed the file.
	 */
	setprtcent();
	pr = getprtcnam(save_data.ufld.fd_devname);
	current_prtc = pr;
	if (pr == (struct pr_term *) 0)  {
		audit_login(prpw, (struct passwd *) 0, pr->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Terminal Control information suddenly vanished\n");
		login_delay("exit");
		exit(1);
	}

	/*
	 * After a login attempt, reset the system's idea of the user
	 * so the previous user will not get nailed for future actions
	 * like timeout or forced login exit.
	 */
	if (prpw != (struct pr_passwd *) 0)
		impossible_user(&prpw, pwd_ref);

	return pr;
}


/*
 * This routine is called when the user has been authenticated and will
 * login this time.  The terminal in the terminal control database
 * reflects that a valid user logged in and any unsuccessful attempt count
 * is eliminated.
 */
struct pr_term *
login_good_tty(pr, prpw)
	struct pr_term *pr;
	struct pr_passwd *prpw;
{
	struct pr_term save_data;
	int	save_alarm ;

	/*
	 * pr until now has pointed to a static area that will get
	 * munged upon the file rewrite.  We have it point to a local
	 * save area until the write is finished.
	 */
	save_data = *pr;
	pr = &save_data;

	pr->uflg.fg_slogin = 1;
	pr->ufld.fd_slogin = time((long *) 0);

	pr->uflg.fg_nlogins = 0;

	if ((prpw == (struct pr_passwd *) 0) || !prpw->uflg.fg_uid)
		pr->uflg.fg_uid = 0;
	else  {
		pr->uflg.fg_uid = 1;
		pr->ufld.fd_uid = prpw->ufld.fd_uid;
	}

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prtc = (struct pr_term *) 0;


/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	save_alarm = alarm(0) ;

	if (!putprtcnam(pr->ufld.fd_devname, pr))  {
		audit_login(prpw, (struct passwd *) 0, pr->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Can't rewrite terminal control entry for %s\n",
			 pr->ufld.fd_devname);
		failure_override(prpw, pr);
		login_delay("exit");
		exit(1);
	}


/*
 *
 *	Reset possible alarm(2)
 *
 */

	alarm(save_alarm) ;

	/*
	 * We must re-open the Terminal Control database here like
	 * above because the file has been updated and putprtcent()
	 * has closed the file.
	 */
	setprtcent();
	pr = getprtcnam(save_data.ufld.fd_devname);
	current_prtc = pr;
	if (pr == (struct pr_term *) 0)  {
		audit_login(prpw, (struct passwd *) 0, pr->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Terminal Control information suddenly vanished\n");
		failure_override(prpw, &save_data);
		login_delay("exit");
		exit(1);
	}

	return pr;
}


/*
 * This routine is called when the user has been authenticated and will
 * login this time.  The user in the protected password database
 * reflects that a valid user logged in and any unsuccessful attempt count
 * is eliminated.
 */
void
login_good_user(pprpwd, pprtc, pwd)
	register struct pr_passwd **pprpwd;
	register struct pr_term **pprtc;
	register struct passwd *pwd;
{
	register struct pr_passwd *prpwd;
	register struct pr_term *prtc;
	register mask_t *sysprivs;
	register int new_nice;
	struct pr_passwd save_data;
	mask_t curr_sysprivs[SEC_SPRIVVEC_SIZE];
	int	save_alarm ;

	prpwd = *pprpwd;
	prtc = *pprtc;

	/*
	 * We need the save area to avoid clashing with the static area when
	 * putprpwnam updates the file.  Then, we need to re-establish a new
	 * pprpwd pointer based on what the new entry looks like, later on in
	 * this routine.
	 */
	save_data = *prpwd;
	prpwd = &save_data;
	prpwd->uflg.fg_slogin = 1;
	prpwd->ufld.fd_slogin = time((long *) 0);
	prpwd->uflg.fg_nlogins = 0;
	prpwd->uflg.fg_suctty = 1;
/* not defined in SCO
	prpwd->uflg.fg_pwchanger = 0;
*/
	strncpy(prpwd->ufld.fd_suctty, prtc->ufld.fd_devname,
	  sizeof(prtc->ufld.fd_devname));

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prpwd = (struct pr_passwd *) 0;


/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	save_alarm = alarm(0) ;

	if (!putprpwnam(prpwd->ufld.fd_name, prpwd))  {
		audit_login(prpwd, pwd, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Can't rewrite protected password entry for user %s\n",
			 prpwd->ufld.fd_name);
		failure_override(prpwd, prtc);
		login_delay("exit");
		exit(1);
	}


/*
 *
 *	Reset possible alarm(2)
 *
 */

	alarm(save_alarm) ;

	/*
	 * We must re-open the Protected Password database here like above
	 * because the file has been updated and putprtcent()
	 * has closed the file.
	 */
	setprpwent();
	prpwd = getprpwnam(save_data.ufld.fd_name);
	current_prpwd = prpwd;
	if (prpwd == (struct pr_passwd *) 0)  {
		audit_login(prpwd, pwd, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
		fprintf (stderr,
			 "Protected Password information suddenly vanished\n");
		failure_override(&save_data, prtc);
		login_delay("exit");
		exit(1);
	}

	/*
	 * Set the user's special audit parameters.
	 */
	audit_adjust_mask(prpwd);


	/*
	 * Set the priority if necessary.  Since the return value
	 * of nice(2) can normally be -1 from the documentation, and
	 * -1 is the error condition, we key off of errno, not the
	 * return value to find if the change were successful.
	 * Note we must do this before the setuid(2) below.
	 */
	errno = 0;
	if (prpwd->uflg.fg_nice)
		new_nice = prpwd->ufld.fd_nice;
	else if (prpwd->sflg.fg_nice)
		new_nice = prpwd->sfld.fd_nice;

	if (prpwd->uflg.fg_nice || prpwd->sflg.fg_nice)  {
		(void) nice(new_nice);
		if (errno != 0)  {
			audit_login(prpwd, pwd, prtc->ufld.fd_devname, ES_LOGIN_FAILED);
                        fprintf(stderr, "Bad priority setting.\n");
			login_delay("exit");
			exit(1);
		}
	}

	/*Now is the time to get the groups of the users. This was added
	 *for posix compliance.
	 */
/*
	(void)initialize_groups(pwd->pw_name,pwd->pw_gid);
*/
	/*
	 * We must do the setgid before the setuid because once the setuid
	 * is done, we are no longer the superuser and a setgid to any
	 * group other than login's group would fail.
	 */
	if (setgid(pwd->pw_gid) != 0) {
		audit_login(prpwd, pwd, prtc->ufld.fd_devname,ES_LOGIN_FAILED); 
		fprintf(stderr, "Bad group id.\n");
		login_delay("exit");
		exit(1);
	}
	/*
         * Audit a successful login attempt.
         */
        audit_login(prpwd, pwd, prtc->ufld.fd_devname, ES_LOGIN); 

	/*
	 * Since we were able to set login id for the process, following 
	 * setuid call is not expected to fail.
	 */
	if (setuid(pwd->pw_uid) != 0) {
		fprintf(stderr, "Bad user id.\n");
		login_delay("exit");
		exit(1);
	}

	/*
	 * Set the system privilege mask for this process.  Do this after
	 * setting all other identity parameters for the user because
	 * this will turn off self-audit and the audit subsystem will now
	 * expect the login process to be established COMPLETELY for the user.
	 */
	if (prpwd->uflg.fg_sprivs)
		sysprivs = prpwd->ufld.fd_sprivs;
	else if (prpwd->sflg.fg_sprivs)
		sysprivs = prpwd->sfld.fd_sprivs;
	else
		sysprivs = nosprivs;


	/*
	 * Shutdown completely the use of the Authentication database.
	 */
	end_authentication(pprpwd, pprtc);

	/*
	 * Following setpriv calls are not expected to fail, since they are
         * tyring to set privileges, which are subset of current process's
         * privileges.
	 */
	(void) getpriv(SEC_EFFECTIVE_PRIV, curr_sysprivs);
	if (setpriv(SEC_EFFECTIVE_PRIV, sysprivs) != 0)
	{
		fprintf(stderr, "Unable to set kernel authorizations.\n");
		login_delay("exit");
		exit(1);
	}
}


/*
 * Not only get the encrypted password, but also clear out the cleartext
 * as soon as possible afterwards to prevent a penetration attempt to
 * read the value (from /dev/mem possibly) or from a failing of memory
 * clearing code for new processes.
 */
char *
login_crypt(prompt, seed)
	char *prompt;
	char *seed;
{
	char *ciphertext;
	char *pass;

	pass = getpasswd(prompt, AUTH_MAX_PASSWD_LENGTH);
	ciphertext = bigcrypt(pass, seed);

	/*
	 * This special entry into getpasswd() will clear the cleartext
	 * string without doing anything else.
	 */
	(void) getpasswd((char *) 0, AUTH_MAX_PASSWD_LENGTH);

	return ciphertext;
}


/*
 * This routine is called when SIGALRM goes off due to an expired alarm(2).
 * The alarm is to stop logins after a reasonable time if no correct login
 * is entered.  Here, we let the user know why his connection is about to
 * break and then update the Authentication database.  We reset the terminal
 * mode before we leave so we can leave the terminal in the state we found
 * it, because timeouts in routines like getpasswd() cause annoyances.
 * (This last bit is really only helpful in debugging, but it does not
 * harm normal operation.)
 */
static void
timeout()
{
	ioctl(fileno(stdin), TCSETAF, &initial_settings);

	fflush(stdout);
	audit_login(current_prpwd, (struct passwd *) 0, current_prtc->ufld.fd_devname, ES_LOGIN_FAILED);
	fprintf(stderr, "\nLogin timed out\n");
	fflush(stderr);
	timeout_occurred = 1 ;
	cancel_process(1, current_prpwd, current_prtc);
}


/*
 * Check with this entry in the terminal control database to make sure that
 * the terminal is not unconditionally locked or locked because of too many
 * consecutive bad login attempts.  Ignore the lock on the console if the
 * superuser is logging in there.
 */
static void
check_valid_tty(pr, prpw)
	register struct pr_term *pr;
	register struct pr_passwd *prpw;
{
	register int locked;
	register int max_tries;
	register int attempts;
	register int su_on_console;;

	/*
	 * in a failure situation, allow root on console to login.
	 * This check allows root password to be checked even if
	 * terminal control database is invalid
	 */
	if (pr == (struct pr_term *) 0 || prpw == (struct pr_passwd *) 0)
		failure_override(prpw, pr);

	/*
	 * Check for unconditional lock on the terminal.
	 */
	if (pr->uflg.fg_lock)
		locked = pr->ufld.fd_lock;
	else if (pr->sflg.fg_lock)
		locked = pr->sfld.fd_lock;
	else
		locked = 0;

	/*
	 * Check for too many tries on the terminal.
	 */
	if (pr->uflg.fg_max_tries)
		max_tries = pr->ufld.fd_max_tries;
	else if (pr->sflg.fg_max_tries)
		max_tries = pr->sfld.fd_max_tries;
	else
		max_tries = 0;

	if (pr->uflg.fg_nlogins)
		attempts = pr->ufld.fd_nlogins;
	else if (pr->sflg.fg_nlogins)
		attempts = pr->sfld.fd_nlogins;
	else
		attempts = 0;

	/*
	 * Allow the superuser to log into the console.  This prevents
	 * someone from locking the superuser account or /dev/console
	 * with repeated failures.  We still audit the lock so the
	 * SSO can detect the problem.
	 */
	su_on_console = ((prpw != (struct pr_passwd *) 0) &&
			 prpw->uflg.fg_uid &&
			 (prpw->ufld.fd_uid == 0) &&
			 pr->uflg.fg_devname &&
			 (strcmp(SYSTEM_CONSOLE, pr->ufld.fd_devname) == 0));

	if (locked || ((max_tries != 0) && (attempts >= max_tries)))  {
	 audit_lock(pr->ufld.fd_devname, ES_TERM_LOCK, attempts);
		if (su_on_console)
			fprintf(stderr,
			"Terminal is disabled but root login is allowed.\n");
		else  {
#ifdef SEC_NET_TTY
			if (is_network)
                                fprintf(stderr,
                        "Host is disabled -- see Account Administrator. \n");
                        else 
#endif
				fprintf(stderr,
			"Terminal is disabled -- see Account Administrator.\n");
			cancel_process(1, prpw, pr);
		}
	}
}


/*
 * This routine cuts off all references to the Authentication database.
 * It loses the in core references we have as well as closing any open
 * files.
 */
static void
end_authentication(prpwd, prtc)
	struct pr_passwd **prpwd;
	struct pr_term **prtc;
{
	*prpwd = (struct pr_passwd *) 0;
	*prtc = (struct pr_term *) 0;
	current_prpwd = (struct pr_passwd *) 0;
	current_prtc = (struct pr_term *) 0;

	endprpwent();
	endprfient();
	endprtcent();
	endprdfent();
	endgrent();
	endpwent();
}


/*
 * This routine executes a command as the given uid and uses name as
 * the argument.  We do this as a subprocess so that we do not change
 * the ownership of the current process.  Return codes:
 * < 0	pgm_path could not be executed
 * = 0	pgm_path ran successfully
 * > 0	pgm_path ran unsuccessfully
 */
static int
execute(pgm_path, uid, user)
	char *pgm_path;
	int uid;
	char *user;
{
	register int child_pid;
	register int return_code;
	int wait_stat;

	(void) fflush(stdout);

	child_pid = fork();

	switch (child_pid)
	{
		case -1:
			/*
			 * Could not fork for some reason.
			 */
			return_code = -1;
			break;

		case 0:
			/*
			 * Child -- change user and execute program.
			 */
			if (setuid(uid) == 0)
				(void) execl(pgm_path,
				             strrchr(pgm_path,'/')+1,
					     user, (char *) 0);

			/*
			 * This makes a negative return code from execute().
			 */
			_exit(255);
			break;

		default:
			/*
			 * Parent -- just wait for child without
			 *	      interruptions.
			 */
			enter_quiet_zone();
			do  {
				return_code = wait(&wait_stat);
			}
			while ((return_code != child_pid) &&
			       (return_code != -1));
			exit_quiet_zone();

			/*
			 * Force sign extension so we'll make an
			 * exit() from the child, with bit 0x80 set
			 * returned here forced to be a short and then
			 * int, a negative number.  E.g., exit(255)
			 * from the child returns 0xFF00 here.  As a
			 * signed short, that number is negative.
			 */
			if (return_code == child_pid)
				return_code = (int) (short) wait_stat;
			break;
	}

	return return_code;
}


/*
 * Fill in both the passwd and pr_passwd entries provided with names
 * and passwords that cannot ever be matched.  This allows the authentication
 * procedure to continue to a point where the authentication can be done
 * unconditrionally on both good and bad entries.  Such a scheme, expanded
 * from the existing UNIX method, reduces a covert channel whereby an
 * intruder could determine valid and invalid login names based on either
 * the messages produced from login program or on the program delay differences
 * in processing good and bad entries.
 */
static void
impossible_user(ppr, ppwd)
	struct pr_passwd **ppr;
	struct passwd **ppwd;
{
	struct pr_default *df;

	noprot.uflg.fg_name = 1;
	noprot.uflg.fg_encrypt = 1;

	/*
	 * Since ':' is the delimiter of the passwd and protected passwd
	 * files, it cannot ever be part of a name.  Nothing will ever
	 * match this!
	 */
	(void) strcpy(noprot.ufld.fd_name, NO_ENTRY);
	(void) strcpy(noprot.ufld.fd_encrypt, NO_ENTRY);

	/*
	 * For the non-user, use system default values.
	 */
	df = getprdfnam(AUTH_DEFAULT);
	if (df != (struct pr_default *) 0)
		dflt = *df;
	noprot.sfld = dflt.prd;
	noprot.sflg = dflt.prg;

	*ppr = &noprot;
	current_prpwd = *ppr;
	*ppwd = &nouser;
}


/*
 * If possible, reset the terminal mode to no access and give back the
 * terminal so that no one can open it when not in use.  Then, leave the
 * program.
 */
static void
reset_tty_discr_and_bye(code)
	int code;
{
	if (save_tty_path != (char *) 0)  {
		(void) chmod(save_tty_path, 0);
		if (term_group == -1)
			(void) chown(save_tty_path, 0, 0);
		else
			(void) chown(save_tty_path, 0, term_group);

	}

	(void) fflush(stdout);
	(void) fflush(stderr);

	/*
	 * Do this sleep to allow time for output to the line before the
	 * physical hangup.  Otherwise, there is a good chance the last
	 * message to the line will be truncated.
	 */
	sleep(3);

	exit(code);
}

/*
 * routine returns true if the account specified should allow logins on
 * the terminal regardless of the condition of the databases.  This is
 * an "out" to allow the system to be returned to a normal state.
 *
 * This routine starts up a shell with all privileges.
 *
 * Eventually, there should be a B1 definition does not assume a root account.
 */

static char *failure_env[] = {
	"HOME=/",
	(char *) 0,
	"SHELL=/bin/sh",
	(char *) 0
};

static void
failure_override(pr, prtc)
struct pr_passwd *pr;
struct pr_term *prtc;
{
	mask_t privs[SEC_SPRIVVEC_SIZE];
	char logname_env[64];
	int i;

	/*
	 * If there is a protected password or a terminal control entry and
	 * the user is not root or the terminal is not the console, return.
	 */
	if ((pr != (struct pr_passwd *) 0 &&
	     strcmp(pr->ufld.fd_name, OVERRIDE_USER)) ||
	    (prtc != (struct pr_term *) 0 &&
	     strcmp(prtc->ufld.fd_devname, SYSTEM_CONSOLE)))
		return;

	/* Notify that the override is taking place. */
	fprintf(stderr, "\nThe security databases are corrupt.\n");
	fprintf(stderr, "However, %s login at terminal %s is allowed\n\n",
	  OVERRIDE_USER, SYSTEM_CONSOLE);

	/* do everything necessary to log into an account at the console */
	setgid(0);
	setuid(0);
	/* set up a privilege mask that allows all defined privileges */
	memset(privs, '\0', sizeof(privs));
	for (i = 0; i <= SEC_MAX_SPRIV; i++)
		ADDBIT(privs, i);

	/* set kernel authorizations and, for B1, base privilege set */
	setpriv(SEC_EFFECTIVE_PRIV, privs);
	chdir("/");
	for (i = 0; i < NSIG; i++)
		signal(i, SIG_DFL);

	/* put user name in environment */
	sprintf(logname_env, "LOGNAME=%s", OVERRIDE_USER);
	failure_env[1] = logname_env;
	execle("/bin/sh", "-sh", (char *) 0, failure_env);
	fprintf(stderr, "Impossible to execute /bin/sh!\n");
	exit(1);
}

/*
 * check the device assignment database for a synonym device matching the
 * terminal pathname specified.  If found, return the corresponding terminal
 * control database entry.
 */

static struct pr_term *
check_devasg(tty)
char *tty;
{
	int i;
	struct dev_asg *dvag;
	char *cp;

	setdvagent();
	while ((dvag = getdvagent()) != (struct dev_asg *) 0)
		if (dvag->uflg.fg_devs)
			for (i = 0; cp = dvag->ufld.fd_devs[i]; i++)
				if (strcmp(cp, tty) == 0)
					return getprtcnam(dvag->ufld.fd_name);
	return (struct pr_term *) 0;
}

#ifdef SEC_NET_TTY
static struct pr_term *
check_devasg_net(host_entry)
char *host_entry;
{
        int i;
        struct dev_asg *dvag;
        char *cp;

        setdvagent();
        while ((dvag = getdvagent()) != (struct dev_asg *) 0)
                if (dvag->uflg.fg_devs)
                        for (i = 0; cp = dvag->ufld.fd_devs[i]; i++)
                                if (strcmp(cp, host_entry) == 0)
                                        return getprtcnam(dvag->ufld.fd_name);
        return (struct pr_term *) 0;
}
#endif



#if defined(SECURE_ROOT)
/*
 * terminal_regrade()-this routine will perform the necessary functions to
 * regrade the sensitivity level and caveat set of a terminal device. To
 * do so, the existing device nodes must be removed and re-created to avoid
 * the link count enforcement in the setlabel(2) code. This check enforces
 * the mandatory increasing tree. By removing and re-creating the devices,
 * it can be assured that the reference count on the node will be one when
 * opened by getty or zero in the case of initcond. If the count is > 1,
 * ordinarily the setlabel(2) will fail. However, if the link count == 2
 * and the target is a character special device and the process is privileged
 * the call will succeed. The count will be two when he chslabel(2) call is
 * made since it does an namei() on the target pathname.
 */

terminal_regrade(prtc,mand_ir)
struct pr_term *prtc;
mand_ir_t *mand_ir;
{
	struct dev_asg *dev;
	int fd, i, devcount = 0;
	struct stat statbuf;
	char newdev[20];
	char devnm[14];
	char remdev[20];
	char *tty;

	if(!prtc->uflg.fg_devname)
		return(0);

	/*
	 * Get the device assignment database entry.
	 */

	if((dev = getdvagnam(prtc->ufld.fd_devname)) == (struct dev_asg *) 0) {
		fprintf(stderr,"Can not get terminal device assignment entry");
		return(0);
	}
#ifdef SEC_NET_TTY
	if (is_network) {
                tty = strrchr(save_tty_path, '/');
                tty++;
                strcpy(devnm,tty);
        }
        else
#endif
		strncpy(devnm,prtc->ufld.fd_devname,sizeof(prtc->ufld.fd_devname));

	/*
	 * Stat(2) the device to get the major/minor for mknod(2). Also,
	 * since the user and group have already been set, use the stat
	 * information to set these on the new device.
	 */

#ifdef SEC_NET_TTY
	if (is_network) {
                sprintf(newdev, "/dev/%s", tty);
                sprintf(remdev, "/dev/%s", tty);
        }
        else
#endif
		sprintf(newdev,"/dev/%s",prtc->ufld.fd_devname);

	if(stat(newdev,&statbuf) == -1) {
		fprintf(stderr,"Unable to stat terminal device");
		return(0);
	}

	/*
	 * Count the number of alias devices
	 */

	for(i=0; ; i++) {
		if(dev->ufld.fd_devs[i])
			devcount++;
		else break;
	}

	/*
	 * For the real device, create a new temporary node. Then unlink
	 * the real device name. Next, link the real device to the new
	 * node giving a link count of 2 for the new device inode. Then
	 * lastly, remove the temporary node leaving a new device inode
	 * for the real device with a link count of 1. The mode of the
	 * new node is left 000 to prevent discretionary access.
	 */

	sprintf(newdev,"/dev/%s-t",devnm);
	if(mknod(newdev,S_IFCHR,statbuf.st_rdev) == -1) {
		fprintf(stderr,"Can not create temporary node");
		return(0);
	}

	if(chmod(newdev,statbuf.st_mode & 0777) == -1) {
		fprintf(stderr,"Unable to chmod new device node\n");
		return(0);
	}

	if(chown(newdev,statbuf.st_uid,statbuf.st_gid) == -1) {
		fprintf(stderr,"Unable to chown new device node\n");
		return(0);
	}

#ifdef SEC_NET_TTY
	if (is_network) {
                unlink(remdev);
                if(link(newdev,remdev) == -1) {
                        fprintf(stderr,"Unable to link new device node\n");
                        return(0);
                }
        }
        else {
#endif
		unlink(dev->ufld.fd_devs[0]);
		if(link(newdev,dev->ufld.fd_devs[0]) == -1) {
			fprintf(stderr,"Unable to link new device node\n");
			return(0);
		}
#ifdef SEC_NET_TTY
	}
#endif
	unlink(newdev);

	/*
	 * Regrade the device according to the specified sensitivity level.
	 */

#ifdef SEC_NET_TTY
	if (is_network) {
                if(chslabel(remdev,mand_ir) == -1) {
                        fprintf(stderr,"Unable to regade terminal device\n");
                        return(0);
                }
        }
        else {
#endif
		if(chslabel(dev->ufld.fd_devs[0],mand_ir) == -1) {
			fprintf(stderr,"Unable to regade terminal device\n");
			return(0);
		}
#ifdef SEC_NET_TTY
	}
#endif

	/*
	 * If the device count is > 1, then alias devices exist. The
	 * aliases must be unlinked and relinked to the new real device
	 * node after it has been regraded.
	 */

#ifdef SEC_NET_TTY
	if (!is_network) {
#endif
		if(devcount > 1) {
			for(i=1;  i < devcount; i++) {
				if(!dev->ufld.fd_devs[i])
					break;

				unlink(dev->ufld.fd_devs[i]);
				link(dev->ufld.fd_devs[0],dev->ufld.fd_devs[i]);
			}
		}
#ifdef SEC_NET_TTY
	}
#endif
	/*
	 * The stdin, stdout, and stderr streams still point to the old
	 * device node that was unlinked. Open the new node, and then
	 * close the old streams dup'ing the new node for use by the
	 * login user.
	 */

#ifdef SEC_NET_TTY
	if (is_network) {
                if((fd = open(remdev,O_RDWR)) == -1) {
                        fprintf(stderr,"Unable to open newly regraded terminal device\n");
                        return(0);
                }
        } 
	else {
#endif
		if((fd = open(dev->ufld.fd_devs[0],O_RDWR)) == -1) {
	    		fprintf(stderr,"Unable to open newly regraded terminal device\n");
	    		return(0);
		}
#ifdef SEC_NET_TTY
	}
#endif
	close(0);
	dup(fd);
	close(1);
	dup(fd);
	close(2);
	dup(fd);
	close(fd);

	return(1);
}
#endif
#include <stdio.h>
#include <grp.h>
#include <sys/types.h>
#include <sys/param.h>

/*this routine will initialize the groups the user can belong to. THis was */
/*for posix compliance.							   */
/* not in SCO
struct group *getgrent();
initialize_groups(uname,agroup)
char *uname;
char agroup;
{
gid_t groups[NGROUPS],ngroups = 0;
struct group *grp;
int i;

if (agroup >= 0)
	groups[ngroups++] = agroup;
setgrent();
while(grp = getgrent())
{
	if (grp->gr_gid == agroup)
		continue;
	for (i = 0; grp->gr_mem[i]; i++)
		if (!strcmp(grp->gr_mem[i],uname))
		{
			if (ngroups == NGROUPS)
			{
				goto toomany;
			}
			groups[ngroups++] = grp->gr_gid;
		}
}
toomany:

endgrent();
if(_setgroups(ngroups,groups) < 0)
{
	perror("setgroups");
	return -1;
}
return 0;
}
*/ 	/*end of initgroups*/


/************************************/

int
alt_login_need_passwd(pr, pnopassword)
	register struct pr_passwd *pr;
	register int *pnopassword;
{
	char nullpwok = 0;

	/* If no password required, return a 1 else continue */

	if((pnopassword == (int *) 0) || (*pnopassword == 0))
		return(1);

	if (pr->uflg.fg_nullpw)
		nullpwok = pr->ufld.fd_nullpw;
	else if (pr->sflg.fg_nullpw)
		nullpwok = pr->sfld.fd_nullpw;

	if (nullpwok || pr->uflg.fg_encrypt && pr->ufld.fd_encrypt[0])
		return 1;

/*the system is configured so every user must have a password. However */
/*the guy trying to login now does not have one. If he got to here by */
/*through either xdm,smgr, or somewhere else, we can't */
/*force him. In this case, set is_a_problem to reflect the correct message*/
/*and let the calling program worry with it.				*/

	is_a_problem = 1; /*let folks know which message*/
	return (0);
}


/*
 * Check for an expired password.  Invoke the passwd program if the
 * passwd is indeed expired.  Returns the possible changed protected
 * password pointer.
 */
struct pr_passwd *
alt_login_check_expired(pr)
	register struct pr_passwd *pr;
{
	register time_t expiration;
	register time_t last_change;
	time_t expiration_time;
	register time_t now;
	struct pr_default *df;

	/*
	 * If null password, do not check for expiration
	 */

	if (!pr->uflg.fg_encrypt || (pr->ufld.fd_encrypt[0] == '\0'))
		return pr;

	now = time((long *) 0);

	if (pr->uflg.fg_schange)
		last_change = pr->ufld.fd_schange;
	else
		last_change = (time_t) 0;

	if (pr->uflg.fg_expire)
		expiration = pr->ufld.fd_expire;
	else if (pr->sflg.fg_expire)
		expiration = pr->sfld.fd_expire;
	else
		expiration = (time_t) 0;

	df = getprdfnam(AUTH_DEFAULT);

	/*
	 * A 0 or missing expiration field means there is no
	 * expiration.
	 */
	expiration_time = expiration ? last_change + expiration : 0;

	if (expiration_time && now > expiration_time)  
	{
		audit_auth_entry(pr->ufld.fd_name, OT_PRPWD,
                        "password expired");
		is_a_problem = 5; /*set the error message*/
	}
/* not defined in SCO.
 else if (df && df->sflg.fg_pw_expire_warning && expiration_time &&
		   expiration_time - now <= df->sfld.fd_pw_expire_warning) 
			is_a_problem = 6;*/ /*set the message*/
	return pr;
}
/*
 * This is the point of no return for detection of a bad login from programs
 * other than login(1). It will do everything that cancel_process() does
 * with the exception of attempting to reset the terminal line or delaying
 * the next login attempt.
 */
static void
cancel_process_but_no_exit(pr)
	struct pr_passwd *pr;
{

/*
 *
 *	Turn off the alarm(2) so that we don't end up calling timeout()
 *	while we are cleaning up.  This isn't a problem if we were
 *	called from timeout().
 *
 */

	if(want_a_timeout)
		alarm(0) ;

	if (pr != (struct pr_passwd *) 0)
		(void) alt_login_bad_user(pr);
	else if (pr != (struct pr_passwd *) 0)
		impossible_user(&pr, pwd_ref);
}


/*
 * Perform actions upon recognition of a bad login attempt.  For bad
 * accounts, do nothing.  For good accounts, update the database
 * entry for the account with the time of attempt and that this is
 * another bad attempt.
 */
struct pr_passwd *
alt_login_bad_user(pr)
	struct pr_passwd *pr;
{
	struct pr_passwd save_data;
	int	save_alarm ;
	static char c_window[]={"window"};

	/*
	 * If this login name really doesn't exist, don't even try
	 * to update the Protected Password database.  The less time taken
	 * here than for good accounts that really are updated is
	 * obscured by sleeping login_delay().
	 * Also, reset static current_prpwd in case we get an
	 * alarm signal. For user names that have been set to NO_ENTRY,
	 * restore the original name used at login for auditing the
	 * failed attempt. Then restore NO_ENTRY upon return.
	 */
	if (strcmp(pr->ufld.fd_name, NO_ENTRY) == 0)  {
		strncpy(pr->ufld.fd_name,bad_username,8);

		/*
		 * Audit an unsuccessful login attempt.
		 */
		audit_login(pr, (struct passwd *) 0,
				c_window, ES_LOGIN_FAILED);

		strcpy(pr->ufld.fd_name,NO_ENTRY);
		current_prpwd = (struct pr_passwd *) 0;
		return pr;
	}


	/*
	 * We need the save area to avoid clashing with the static area when
	 * putprpwnam updates the file.  Then, we need to re-establish a new
	 * pr pointer based on what the new entry looks like, later on in this
	 * routine.
	 */
	save_data = *pr;
	pr = &save_data;
	pr->uflg.fg_ulogin = 1;
	pr->ufld.fd_ulogin = time((long *) 0);
	if (pr->uflg.fg_nlogins)
		pr->ufld.fd_nlogins++;
	else  {
		pr->uflg.fg_nlogins = 1;
		pr->ufld.fd_nlogins = 1;
	}
	pr->uflg.fg_unsuctty = 1;
	strcpy(pr->ufld.fd_unsuctty, c_window);

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prpwd = (struct pr_passwd *) 0;

/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	if(want_a_timeout)  /*do only if calling program wants timer action*/
		save_alarm = alarm(0) ;

	if (!putprpwnam(pr->ufld.fd_name, pr))  {
		audit_login(pr, (struct passwd *) 0, c_window, ES_LOGIN_FAILED);
		/*it's up to the calling program to handle this*/
		is_a_problem = 7;
		return pr;
	}

/*
 *
 *	Reset possible alarm(2)
 *
 */

	if(want_a_timeout)
		alarm(save_alarm) ;

	/*
	 * We must re-open the Protected Password database here
	 * because the file has been updated and putprpwent()
	 * has closed the file.
	 */
	setprpwent();
	pr = getprpwnam(save_data.ufld.fd_name);
	current_prpwd = pr;
	if (pr == (struct pr_passwd *) 0)  {
		audit_login(pr, (struct passwd *) 0, c_window, ES_LOGIN_FAILED);
		/*up to calling program to handle*/
		is_a_problem = 8;
		return pr;
	}

	/*
	 * Audit an unsuccessful login attempt.
	 */
	audit_login(pr, (struct passwd *) 0,
	 	c_window, (char *) 0, ES_LOGIN_FAILED); 

	return pr;
}


/*
 * Set the login UID.  Before that, make sure that the account is
 * not locked.  Note we do this after the password is obtained to
 * make sure that the real user of the account gets the locked/nolocked
 * status.  Also, let the user know when he last logged in successfully
 * and his last unsuccessful attempt.
 *
 * Locking is done by the Account Administrator unconditionally, by
 * exceeding the number of bad consecutive attempts or by having the
 * password expire.
 *
 * To prevent denial of use of the system by a malicious person who locks
 * the superuser account by repeated attempting logins, we unconditionally
 * allow the superuser account access on the system console.
 */
void
alt_login_set_user(pr, console_flag, p)
	register struct pr_passwd *pr;
	int console_flag;    /* if set to 1, then this is the "console" for*/
			     /*this windowing system.			   */
	register struct passwd *p;
{
	register int su_on_console;
	static char c_window[]={"window"};

	/*
	 * Allow the superuser to log into the console.  This prevents
	 * someone from locking the superuser account or /dev/console
	 * with repeated failures.  We still audit the lock so the
	 * SSO can detect the problem.
	 */
	su_on_console = ((pr != (struct pr_passwd *) 0) &&
			 pr->uflg.fg_uid &&
			 (pr->ufld.fd_uid == 0) && console_flag);

	/*
	 * See if any condition will prevent a superuser login.
	 * Locked_out() will still audit the lock even if the superuser
	 * access is given.
	 */
	if (locked_out(pr))  {
		if (su_on_console)
			is_a_problem=0x0f;
		else  
		{
			cancel_process_but_no_exit(pr);
			is_a_problem = 0x09;
			return;
		}
	} 


	/* check for retired account */

	if (pr->uflg.fg_type && ISBITSET(pr->ufld.fd_type, AUTH_RETIRED_TYPE)) 
	{
		audit_login(pr, p, c_window, ES_LOGIN_FAILED);
		cancel_process_but_no_exit(pr);
		is_a_problem = 0x0a;
		return;
	}


}


void
xdm_login_set_user(pr, console_flag, p)
        register struct pr_passwd *pr;
	int console_flag; /* will be 1 if this is the console for a windowing system*/
        register struct passwd *p;
{
        register int su_on_console;
	static char c_window[]={"window"};

        /*
         * Allow the superuser to log into the console.  This prevents
         * someone from locking the superuser account or /dev/console
         * with repeated failures.  We still audit the lock so the
         * SSO can detect the problem.
         */
        su_on_console = ((pr != (struct pr_passwd *) 0) &&
                         pr->uflg.fg_uid &&
                         (pr->ufld.fd_uid == 0) && console_flag);

        /*
         * See if any condition will prevent a superuser login.
         * Locked_out() will still audit the lock even if the superuser
         * access is given.
         */
	
        if (locked_out(pr))  {
                if (su_on_console)
			is_a_problem = 0x0f; /*Account is disabled but console login is allowed.*/
                else  {
			/*Account is disabled -- see Account Administrator.*/
                        cancel_process_but_no_exit(pr);
			is_a_problem = 0x09;
			return;
                }
        }


        /* check for retired account */

        if (pr->uflg.fg_type && ISBITSET(pr->ufld.fd_type, AUTH_RETIRED_TYPE)) {
                audit_login(pr, p, c_window, ES_LOGIN_FAILED);
		/* Account has been retired -- logins are no longer allowed.*/
                cancel_process_but_no_exit(pr);
		is_a_problem = 0x0a;
		return;
        }




}


/*
 * Delay for the number of seconds specified in the terminal control
 * entry for this terminal.  So the user still knows that the system
 * is responsive, print out a wait message (using reason string
 * supplied) and print a dot for each second waited, if the calling
 * program was login(1).
 */
void
alt_login_delay()
{
	int seconds;

	if (delay_between_attempts == 0)
		return;
	for (seconds = 0; seconds < delay_between_attempts; seconds++)  
		sleep(1);

}


int
alt_login_validate(pprpwd, console_flag, pnopassword,ppwd)
	register struct pr_passwd **pprpwd;
	int console_flag;  /*1 if this is the console for the windowing system*/
	int *pnopassword;
	char **ppwd; /*password as the user typed it in*/
{
	register int is_valid_password = 1;
	static char c_window[] = {"window"};

	/*
	 * if there is a problem with the protected password database,
	 * allow a root account login at the console.  If there is a valid
	 * protected password entry, force the password check on the root
	 * account.  Otherwise, an invalid terminal control entry means
	 * that the system should reject the login.
	 */
	if (*pprpwd == (struct pr_passwd *) 0) {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        c_window, ES_LOGIN_FAILED);
		alt_failure_override(*pprpwd, console_flag);
	}
/* not in SCO
	if ((*pprpwd)->uflg.fg_pwchanger) 
		is_a_problem = 0x11;
*/
	if ((*pprpwd)->ufld.fd_encrypt[0] == '\0')
		return is_valid_password;
	else  {
		if(pnopassword != (int *) 0)
			*pnopassword = 0;

		if(strcmp(no_prompt_login_crypt((*ppwd), (*pprpwd)->ufld.fd_encrypt),
				      (*pprpwd)->ufld.fd_encrypt) == 0)
			return is_valid_password;
		else  {
			if (*pprpwd) 
				*pprpwd = alt_login_bad_user(*pprpwd);
			if(is_a_problem == 0) /*set if not set already*/
				is_a_problem = 0x12;
			audit_login(pprpwd, (struct passwd *)0,c_window,
			ES_LOGIN_FAILED);
			alt_login_delay();
			is_valid_password = 0;
		}
	}

	return is_valid_password;
}

/*
 * Find the terminal in the terminal control database.  Then, use the
 * information in the entry to set the alarm clock for login timeouts.
 * We make sure that stdin, stdout, and stderr are character special
 * files and that they point to the same device.
 * Also save the terminal settings in case we timeout later (so we can
 * restore any funny modes that we may be in due to getpasswd(3) settings).
 */
struct pr_term *
alt_login_term_params(tty_path, tty_name)
	char *tty_path;
	char *tty_name;
{
	register struct group *g;
	register struct pr_term *pr;
	struct stat in_buf;
	struct stat out_buf;
	struct stat err_buf;

	save_tty_path = tty_path;

	pr = getprtcnam(tty_name);

	/*
	 * if terminal control database yields a failure, check the device
	 * assignment database for a synonym device.
	 */
	if (pr == (struct pr_term *) 0)
		pr = check_devasg(tty_path);

	if (pr == (struct pr_term *) 0)  
	{
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		is_a_problem = 0x14;
		/*
		 * if there is no entry for the console, the database is
		 * corrupted and a root login should be allowed
		 */
		if (strcmp(tty_name, SYSTEM_CONSOLE) == 0)
		{
			is_a_problem = 0x29;
			return ((struct pr_term *)0);
		}
		return((struct pr_term *) 0);
	}

	g = getgrnam("terminal");
	if (g != (struct group *) 0)
		term_group = g->gr_gid;
	endgrent();

	if (pr->uflg.fg_logdelay)
		delay_between_attempts = pr->ufld.fd_logdelay;
	else if (pr->sflg.fg_logdelay)
		delay_between_attempts = pr->sfld.fd_logdelay;
	else
		delay_between_attempts = 0;

	/*
	 * Make sure stdin, stdout, and stderr are terminals and they
	 * are one and the same.
	 */
	if ((fstat(fileno(stdin), &in_buf) != 0) ||
	    (fstat(fileno(stdout), &out_buf) != 0) ||
	    (fstat(fileno(stderr), &err_buf) != 0) ||
	    ((in_buf.st_mode & S_IFMT) != S_IFCHR) ||
	    ((out_buf.st_mode & S_IFMT) != S_IFCHR) ||
	    ((err_buf.st_mode & S_IFMT) != S_IFCHR) ||
	    (in_buf.st_rdev != out_buf.st_rdev) ||
	    (out_buf.st_rdev != err_buf.st_rdev))  
	{
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		is_a_problem = 0x15;
		return((struct pr_term *) 0);
	}

	/*
	 * Get the tty settings in case we need to restore them later.
	 * If the ioctl fails, we don't have a terminal to play with where
	 * it should be.  We do this before the alarm is activated so we
	 * are sure to read the information here before the alarm clock
	 * will cause it to be used in timeout().
	 */
	if (ioctl(fileno(stdin), TCGETA, &initial_settings) != 0)  
	{
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		is_a_problem = 0x16;
		return((struct pr_term *) 0);
	}

	/*
	 * Use the login timeout value from the terminal control dbase
	 * entry if there is one defined. Otherwise, use the following.
	 * Base alarm on rate of login attempts.  Add TYPEIN_TIME seconds
	 * on each attempt to account for some of the overhead in typing in
	 * password.
	 */

	if(want_a_timeout)  /*do only if calling program wants a timeout set*/
	{
		if(pr->sflg.fg_login_timeout)
		    (void) alarm(pr->sfld.fd_login_timeout);
		else
		    (void) alarm(ATTEMPTS * (TYPEIN_TIME + delay_between_attempts));
	}

	current_prtc = pr;
	return pr;
}


struct pr_term *
xdm_login_term_params(tty_path, tty_name)
        char *tty_path;
        char *tty_name;
{
        register struct group *g;
        register struct pr_term *pr;

        save_tty_path = tty_path;

        pr = getprtcnam(tty_name);

        /*
         * if terminal control database yields a failure, check the device
         * assignment database for a synonym device.
         */
        if (pr == (struct pr_term *) 0)
                pr = check_devasg(tty_path);

        if (pr == (struct pr_term *) 0)  {
                audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (struct pr_term *) 0, ES_LOGIN_FAILED);
		is_a_problem = 0x14; /*cannot obtain database information on this terminal*/
                /*
                 * if there is no entry for the console, the database is
                 * corrupted and a root login should be allowed
                 */
                if (strcmp(tty_name, SYSTEM_CONSOLE) == 0)
                        is_a_problem = 0x29;
		return((struct pr_term *) 0);
        }

        g = getgrnam("terminal");
        if (g != (struct group *) 0)
                term_group = g->gr_gid;
        endgrent();

        if (pr->uflg.fg_logdelay)
                delay_between_attempts = pr->ufld.fd_logdelay;
        else if (pr->sflg.fg_logdelay)
                delay_between_attempts = pr->sfld.fd_logdelay;
        else
                delay_between_attempts = 0;


        /*
         * Use the login timeout value from the terminal control dbase
         * entry if there is one defined. Otherwise, use the following.
         * Base alarm on rate of login attempts.  Add TYPEIN_TIME seconds
         * on each attempt to account for some of the overhead in typing in
         * password.
         */

	if(want_a_timeout) /*do only if calling program wants timeouts set*/
	{
	        if(pr->sflg.fg_login_timeout)
        	    (void) alarm(pr->sfld.fd_login_timeout);
	        else
        	    (void) alarm(ATTEMPTS * (TYPEIN_TIME + delay_between_attempts));
	}

        current_prtc = pr;
        return pr;
}


/*
 * For a sublogin, re-execute the login command with a special
 * environment indicating a sublogin.
 */
void
alt_login_do_sublogin(envinit)
	char *envinit[];
{
	execle(LOGIN_PROGRAM, "login", (char *) 0, &envinit[0]);
	is_a_problem = 0x18;
}



/*
 * This routine is called when the user has been authenticated and will
 * login this time.  The user in the protected password database
 * reflects that a valid user logged in and any unsuccessful attempt count
 * is eliminated.
 */
void
alt_login_good_user(pprpwd,pwd)
	register struct pr_passwd **pprpwd;
	register struct passwd *pwd;
{
	register struct pr_passwd *prpwd;
	register mask_t *sysprivs;
	register int new_nice;
	struct pr_passwd save_data;
	mask_t curr_sysprivs[SEC_SPRIVVEC_SIZE];
	static char c_window[] = {"window"};
	int	save_alarm ;

	prpwd = *pprpwd;

	/*
	 * We need the save area to avoid clashing with the static area when
	 * putprpwnam updates the file.  Then, we need to re-establish a new
	 * pprpwd pointer based on what the new entry looks like, later on in
	 * this routine.
	 */
	save_data = *prpwd;
	prpwd = &save_data;
	prpwd->uflg.fg_slogin = 1;
	prpwd->ufld.fd_slogin = time((long *) 0);
	prpwd->uflg.fg_nlogins = 0;
	prpwd->uflg.fg_suctty = 1;
/*	prpwd->uflg.fg_pwchanger = 0; *not in SCO*/
	strncpy(prpwd->ufld.fd_suctty, c_window,sizeof(c_window));

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prpwd = (struct pr_passwd *) 0;


/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	if(want_a_timeout)  /*do only if calling program wanted timeouts set*/
		save_alarm = alarm(0) ;

	if (!putprpwnam(prpwd->ufld.fd_name, prpwd))  {
		audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
		alt_failure_override(prpwd, 1);
		is_a_problem = 0x07;
		return;
	}


/*
 *
 *	Reset possible alarm(2)
 *
 */

	if(want_a_timeout)
		alarm(save_alarm) ;

	/*
	 * We must re-open the Protected Password database here like above
	 * because the file has been updated and putprtcent()
	 * has closed the file.
	 */
	setprpwent();
	prpwd = getprpwnam(save_data.ufld.fd_name);
	current_prpwd = prpwd;
	if (prpwd == (struct pr_passwd *) 0)  {
		audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
		alt_failure_override(&save_data, 1);
		is_a_problem = 0x02;
		return;
	}

	/*
	 * Set the user's special audit parameters.
	 */
	audit_adjust_mask(prpwd);


	/*
	 * Set the priority if necessary.  Since the return value
	 * of nice(2) can normally be -1 from the documentation, and
	 * -1 is the error condition, we key off of errno, not the
	 * return value to find if the change were successful.
	 * Note we must do this before the setuid(2) below.
	 */
	errno = 0;
	if (prpwd->uflg.fg_nice)
		new_nice = prpwd->ufld.fd_nice;
	else if (prpwd->sflg.fg_nice)
		new_nice = prpwd->sfld.fd_nice;

	if (prpwd->uflg.fg_nice || prpwd->sflg.fg_nice)  {
		(void) nice(new_nice);
		if (errno != 0)  {
			audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
			is_a_problem = 0x1b;
			return;
		}
	}

	/*Now is the time to get the groups of the users. This was added
	 *for posix compliance.
	 */
/*
	(void)initialize_groups(pwd->pw_name,pwd->pw_gid);
*/
	/*
	 * We must do the setgid before the setuid because once the setuid
	 * is done, we are no longer the superuser and a setgid to any
	 * group other than login's group would fail.
	 */
	if (setgid(pwd->pw_gid) != 0) {
		audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
		is_a_problem = 0x1c;
		return;
	}
	/*
         * Audit a successful login attempt.
         */
        audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);

	/*
	 * Since we were able to set login id for the process, following 
	 * setuid call is not expected to fail.
	 */
	if (setuid(pwd->pw_uid) != 0) {
		is_a_problem = 0x1d;
		return;
	}

	/*
	 * Set the system privilege mask for this process.  Do this after
	 * setting all other identity parameters for the user because
	 * this will turn off self-audit and the audit subsystem will now
	 * expect the login process to be established COMPLETELY for the user.
	 */
	if (prpwd->uflg.fg_sprivs)
		sysprivs = prpwd->ufld.fd_sprivs;
	else if (prpwd->sflg.fg_sprivs)
		sysprivs = prpwd->sfld.fd_sprivs;
	else
		sysprivs = nosprivs;


	/*
	 * Shutdown completely the use of the Authentication database.
	 */
	alt_end_authentication(pprpwd);

	/*
	 * Following setpriv calls are not expected to fail, since they are
         * tyring to set privileges, which are subset of current process's
         * privileges.
	 */
	(void) getpriv(SEC_EFFECTIVE_PRIV, curr_sysprivs);
	if (setpriv(SEC_EFFECTIVE_PRIV, sysprivs) != 0)
	{
		is_a_problem = 0x1e;
		return;
	}
}


/*
 * This routine is called when the user has been authenticated and will
 * login this time.  The user in the protected password database
 * reflects that a valid user logged in and any unsuccessful attempt count
 * is eliminated.
 */
void
alt_login_user_ok_update_passwd_entry(pprpwd,pwd)
	register struct pr_passwd **pprpwd;
	register struct passwd *pwd;
{
	register struct pr_passwd *prpwd;
	struct pr_passwd save_data;
	static char c_window[] = {"window"};
	int	save_alarm ;

	prpwd = *pprpwd;

	/*
	 * We need the save area to avoid clashing with the static area when
	 * putprpwnam updates the file.  
	 */
	save_data = *prpwd;
	prpwd = &save_data;
	prpwd->uflg.fg_slogin = 1;
	prpwd->ufld.fd_slogin = time((long *) 0);
	prpwd->uflg.fg_nlogins = 0;
	prpwd->uflg.fg_suctty = 1;
/*	prpwd->uflg.fg_pwchanger = 0; *not in SCO*/
	strncpy(prpwd->ufld.fd_suctty, c_window,sizeof(c_window));

	/*
	 * Need to erase this in case we get an alarm signal for
	 * too much time.
	 */
	current_prpwd = (struct pr_passwd *) 0;


/*
 *
 *	Disable the alarm(2) so that it does not go off while we are
 *	updating the base.  We will reset the alarm(2) if the update
 *	succeeds.  Ignore the amount of time we took doing the update.
 *
 */

	if(want_a_timeout)  /*do only if calling program wanted timeouts set*/
		save_alarm = alarm(0) ;

	if (!putprpwnam(prpwd->ufld.fd_name, prpwd))  {
		audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
		alt_failure_override(prpwd, 1);
		is_a_problem = 0x07;
		return;
	}

	/*
         * Audit a successful login attempt.
         */
        audit_login(prpwd, pwd, c_window, ES_LOGIN);

	/*
	 * Shutdown completely the use of the Authentication database.
	 */
	alt_end_authentication(pprpwd);


}/*end of alt_login_ok_user_update_passwd_entry*/


/*this next routine is set up for screen manager. They needed a routine they*/
/*could call after the fact to give shell windows an identity for the user*/
/*In this case, the user sometime ago logged into the workstation user window*/
/*and was correctly authenticated. At that time, the protected password */
/*database was updated and closed.*/

void alt_login_give_user_identity(pwd)
struct passwd *pwd;
{
	register struct pr_passwd *prpwd;
	register mask_t *sysprivs;
	register int new_nice;
	mask_t curr_sysprivs[SEC_SPRIVVEC_SIZE];
	static char c_window[] = {"window"};

	setprpwent(); /*open protected password database and find the user*/
	prpwd = getprpwnam(pwd->pw_name);
	current_prpwd = prpwd;
	if (prpwd == (struct pr_passwd *) 0)  {
		audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
		is_a_problem = 0x02;
		return;
	}

	/*
	 * Set the user's special audit parameters.
	 */
	audit_adjust_mask(prpwd);


	/*
	 * Set the priority if necessary.  Since the return value
	 * of nice(2) can normally be -1 from the documentation, and
	 * -1 is the error condition, we key off of errno, not the
	 * return value to find if the change were successful.
	 * Note we must do this before the setuid(2) below.
	 */
	errno = 0;
	if (prpwd->uflg.fg_nice)
		new_nice = prpwd->ufld.fd_nice;
	else if (prpwd->sflg.fg_nice)
		new_nice = prpwd->sfld.fd_nice;

	if (prpwd->uflg.fg_nice || prpwd->sflg.fg_nice)  {
		(void) nice(new_nice);
		if (errno != 0)  {
			audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
			is_a_problem = 0x1b;
			return;
		}
	}

	/*Now is the time to get the groups of the users. This was added
	 *for posix compliance.
	 */
/*
	(void)initialize_groups(pwd->pw_name,pwd->pw_gid);
*/
	/*
	 * We must do the setgid before the setuid because once the setuid
	 * is done, we are no longer the superuser and a setgid to any
	 * group other than login's group would fail.
	 */
	if (setgid(pwd->pw_gid) != 0) {
		audit_login(prpwd, pwd, c_window, ES_LOGIN_FAILED);
		is_a_problem = 0x1c;
		return;
	}
	/*
	 * Since we were able to set login id for the process, following 
	 * setuid call is not expected to fail.
	 */
	if (setuid(pwd->pw_uid) != 0) {
		is_a_problem = 0x1d;
		return;
	}

	/*
	 * Set the system privilege mask for this process.  Do this after
	 * setting all other identity parameters for the user because
	 * this will turn off self-audit and the audit subsystem will now
	 * expect the login process to be established COMPLETELY for the user.
	 */
	if (prpwd->uflg.fg_sprivs)
		sysprivs = prpwd->ufld.fd_sprivs;
	else if (prpwd->sflg.fg_sprivs)
		sysprivs = prpwd->sfld.fd_sprivs;
	else
		sysprivs = nosprivs;


	/*
	 * Following setpriv calls are not expected to fail, since they are
         * tyring to set privileges, which are subset of current process's
         * privileges.
	 */
	(void) getpriv(SEC_EFFECTIVE_PRIV, curr_sysprivs);
	if (setpriv(SEC_EFFECTIVE_PRIV, sysprivs) != 0)
	{
		is_a_problem = 0x1e;
		return;
	}
	/*
	 * Shutdown completely the use of the Authentication database.
	 */
	alt_end_authentication(prpwd);
}


char *
no_prompt_login_crypt(password,seed)
	char *password;
	char *seed;
{
        char *ciphertext;

        ciphertext = bigcrypt(password, seed);

        return ciphertext;
}



/*
 * This routine cuts off all references to the Authentication database.
 * It loses the in core references we have as well as closing any open
 * files.
 */
void
alt_end_authentication(prpwd)
	struct pr_passwd **prpwd;
{
	*prpwd = (struct pr_passwd *) 0;
	current_prpwd = (struct pr_passwd *) 0;
	current_prtc = (struct pr_term *) 0;

	endprpwent();
	endprfient();
	endprtcent();
	endprdfent();
	endgrent();
	endpwent();
}

/*
 * routine returns true if the account specified should allow logins on
 * the terminal regardless of the condition of the databases.  This is
 * an "out" to allow the system to be returned to a normal state.
 *
 * This routine starts up a shell with all privileges.
 *
 * Eventually, there should be a B1 definition does not assume a root account.
 */

static void
alt_failure_override(pr, console_flag)
struct pr_passwd *pr;
int console_flag;
{
	mask_t privs[SEC_SPRIVVEC_SIZE];
	char logname_env[64];
	int i;

	/*
	 * If there is a protected password or a terminal control entry and
	 * the user is not root or the terminal is not the console, return.
	 */
	if ((pr != (struct pr_passwd *) 0 &&
	     strcmp(pr->ufld.fd_name, OVERRIDE_USER)) ||
	     !console_flag)
		return;

	/* Notify that the override is taking place. */
	is_a_problem = 0x23;

	/* do everything necessary to log into an account at the console */
	setgid(0);
	setuid(0);
	/* set up a privilege mask that allows all defined privileges */
	memset(privs, '\0', sizeof(privs));
	for (i = 0; i <= SEC_MAX_SPRIV; i++)
		ADDBIT(privs, i);

	/* set kernel authorizations and, for B1, base privilege set */
	setpriv(SEC_EFFECTIVE_PRIV, privs);
	chdir("/");
	for (i = 0; i < NSIG; i++)
		signal(i, SIG_DFL);

	/* put user name in environment */
	sprintf(logname_env, "LOGNAME=%s", OVERRIDE_USER);
	failure_env[1] = logname_env;
	execle("/bin/sh", "-sh", (char *) 0, failure_env);
}


/*this routine is for validating user's who are comming in through rlogin*/
/*But not just any rlogin user. This is for users who either either system*/
/*is in /etc/hosts.equiv or their name exists in the rhosts file.	*/


int
login_validate_4_remote_with_hostequiv(pprpwd, pprtc, pnopassword)
	register struct pr_passwd **pprpwd;
	register struct pr_term **pprtc;
	int *pnopassword;
{
	register int is_valid_password = 1;

	/*
	 * if there is a problem with the protected password database,
	 * allow a root account login at the console.  If there is a valid
	 * protected password entry, force the password check on the root
	 * account.  Otherwise, an invalid terminal control entry means
	 * that the system should reject the login.
	 */
	if (*pprpwd == (struct pr_passwd *) 0) {
		audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
                        (*pprtc)->ufld.fd_devname, ES_LOGIN_FAILED);
		failure_override(*pprpwd, *pprtc);
	}
	if (*pprtc == (struct pr_term *) 0 &&
	    strcmp((*pprpwd)->ufld.fd_name, OVERRIDE_USER)) {
		audit_login(pprpwd, (struct passwd *) 0, (struct pr_term *) 0, ES_LOGIN_FAILED);
		exit(1);
	}
/* *not in SCO
	if ((*pprpwd)->uflg.fg_pwchanger) {
		char *pwchanger, buf[16];

		pwchanger = pw_idtoname((*pprpwd)->ufld.fd_pwchanger);
		if (pwchanger == NULL) {
			sprintf(buf, "uid #%u", (*pprpwd)->ufld.fd_pwchanger);
			pwchanger = buf;
		}
		printf("Your password was changed by %s on %s", pwchanger,
			ctime(&(*pprpwd)->ufld.fd_schange));
	}
*/
/*really, all we need to do is besure all's ok with the tty in the tty database*/
/*the password matter's not since the user passed ok through hosts.equiv or*/
/*the .rhosts.								   */
	check_valid_tty(*pprtc, *pprpwd);
	return is_valid_password;
}


#endif
