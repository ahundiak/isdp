/*
**      NAME:                                                   comc2pw.c
**      AUTHORS:                                                Grace Oliver
**      CREATION DATE:                                  5/93
**      ABSTRACT:	Dan Karier created following to support C2 security.
**					This file is NOT part of comwrap.c because risapp
**					can NOT be dependent on the SECURE product.
**
** 		The routines in this group deal with passwords and possibly
** 		secure password information.
**
**      REVISION HISTORY:
**
**		02/96: Modified password verification to support HP-UX trusted
**             systems with protected password database.       surjit
**
*/

/*
**      INCLUDES
*/
#include <errno.h>
#if defined(unix)
#include <sys/types.h>
#endif
#include "risdebug.h"
#if defined(__Sol2__) || defined(Soli)
#include <shadow.h>
#endif
#if defined(sun)
#include <pwd.h>
#endif
#if defined(__hpux__)
#include <pwd.h>
#include <sys/stat.h>
#include <hpsecurity.h>
#include <prot.h>
#endif

/*
**      DEFINES
*/

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comc2pw_c
/*START_PRT_INCLUDE*/
#include "sys.prt"
#include "comdebug.prt"
# if !defined(sun)
# include "wrap.prt"
# endif
/*STOP_PRT_INCLUDE*/
#include "comc2pw.prt"

/*
**      VARIABLES
*/

/*
**      FUNCTIONS
*/

/*****************************************************************************/

#if defined(__clipper__) || defined(sco)
# define C2
#endif

#if defined(C2)
# define SecureWare
# define SYSV_3
# define BT
# define SEC_NET_TTY
# if defined(__clipper__)
#  include <sys/immu.h>
#  include <sys/region.h>
#  include <sys/inode.h>
#  include <sys/param.h>
#  include <sys/proc.h>
#  include <sys/sec/auditsysc.h>
#  include <sys/sec/sectypes.h>
#  include <sys/sec/security.h>
#  include <tcb/prot.h>
#  include <tcb/protcmd.h>
# endif /* clipper */
# if defined(sco)
#  include <sys/auditsysc.h>
#  include <sys/security.h>
#  include <prot.h>
#  include <protcmd.h>
# endif /* sco */

	/*
	** getprpwnam() is part of the SecureWare C2 implementation.
	** It exists only on systems with C2 security, and is the
	** method for getting an encrypted password out of a
	** secure database.
	*/

extern struct pr_passwd *RIScom_getprpwnam(
	char *name)
{
	struct pr_passwd *status;
	COM_DBG(("RIScom_getprpwnam(name: <%s>)\n", name));
	do
	{
		errno = -1;
		if ((status = getprpwnam(name)) == NULL)
		{
			COM_DBG(("getprpwnam returns 0, errno = %d\n", errno));
		}
	}
	while (status == NULL && errno == EINTR);
	COM_DBG(("RIScom_getprpwnam: complete\n"));
	return status;
}
#endif /* C2 */

#if defined(__Sol2__) || defined(Soli)
extern struct spwd *RIScom_getspnam(
	const char *name)
{
	struct spwd *status;
	COM_DBG(("RIScom_getspnam(name: <%s>)\n", name));
	do
	{
		errno = -1;
		if ((status = getspnam(name)) == NULL)
		{
			COM_DBG(("getspnam returns 0, errno = %d\n", errno));
		}
	}
	while (status == NULL && errno == EINTR);
	COM_DBG(("RIScom_getspnam: complete\n"));
	return status;
}
#endif /* Solaris */

#if defined(__hpux__)
extern struct pr_passwd *RIScom_getprpwnam(
	char *name)
{
	struct pr_passwd *status;
	COM_DBG(("RIScom_getprpwnam(name: <%s>)\n", name));
	do
	{
		errno = -1;
		if ((status = getprpwnam(name)) == NULL)
		{
			COM_DBG(("getprpwnam returns 0, errno = %d\n", errno));
		}
	}
	while (status == NULL && errno == EINTR);
	COM_DBG(("RIScom_getprpwnam: complete\n"));
	return status;
}
#endif /* HP-UX trusted system */

/*****************************************************************************/

	/*
	** This routine tells us whether we can get a password out of
	** the password file (via getpwnam) or whether we have to
	** use getprpwnam or some other method to get the password
	** out of a protected database.  
	*/

extern int RIScom_secure_password()
{
/* Only __clipper__ and sco has C2 defined */
#if defined(C2)

# if defined(__clipper__)
	return syscall(AUDIT_SECURITY, SEC_SINFOP);
# elif defined(sco)
	return 1;
# else
	!!! ERROR - How to handle SECURE Database !!!
# endif /* clipper et al */

#else /* not C2 */

# if defined(__clipper__) || defined(sun)  || defined(DOS) || defined(WIN32) || defined(vms)
	return 0;
# elif defined(__Sol2__) || defined(Soli)
	return 1;
# elif defined(__hpux__)
	return iscomsec(); /* check for trusted system */
# else
	!!! ERROR - How to handle SECURE Database !!!
# endif /* clipper et al */

#endif  /* C2 or NOT C2 */
}

/*****************************************************************************/

#if defined(unix)

	/*
	**  Given a passwd structure, get an encrypted password.
	**  This will be obtained from the passwd structure or 
	**  possibly from a secure password database, depending on
	**  security.
	*/

extern void RIScom_get_password(
	struct passwd * pw, 		/* ptr to filled-in passwd structure */
	char          * usr,		/* username */
	int           * flagp, 		/* set this if we get a non-null password */ 
	char          * buf)		/* put password into this */
{
	COM_DBG(("RIScom_get_password: usr <%s>\n", usr));

	if (!RIScom_secure_password()) /* non-secure system */
	{
		/*
		** It is important that the flag be set correctly and that
		** the buffer be initialized to something other than a null
		** string (because that means something special).
		*/

		COM_DBG(("RIScom_get_password: non-secure password\n"));
		COM_DBG(("RIScom_get_password: pw->pw_passwd <%s>\n", 
			*pw->pw_passwd ? pw->pw_passwd : "none"));

		if (pw->pw_passwd && *pw->pw_passwd)
		{
			*flagp = 1;	/* got a password */
			strcpy(buf,pw->pw_passwd);
		}
		else
		{
			*flagp = 0;
			*buf = 'x';
			*(buf+1) = '\0';
		}
	}
	else /* secure system */
	{

#if defined(C2)
		/*
		** For C2 security, the password does not come back in the pw
		** structure.  We have to use another function call to get it.
		*/
		struct pr_passwd *pr_pw;

		COM_DBG(("RIScom_get_password: C2 security\n"));
		pr_pw = RIScom_getprpwnam(usr);
		COM_DBG(("RIScom_get_password: pr_pw->ufld.fd_encrypt <%s>\n", 
			pr_pw->ufld.fd_encrypt ? pr_pw->ufld.fd_encrypt : "none" ));

		if (pr_pw && pr_pw->ufld.fd_encrypt && *pr_pw->ufld.fd_encrypt)
		{
			*flagp = 1;	/* got a password */
			strcpy(buf,pr_pw->ufld.fd_encrypt);
		}
		else
		{
			*flagp = 0;
			*buf = 'x';
			*(buf+1) = '\0';
		}
#endif /* C2 */

#if defined(__Sol2__) || defined(Soli)
		struct spwd *spwd_pw;

		COM_DBG(("RIScom_get_password: Solaris security\n"));
		spwd_pw = (struct spwd *)RIScom_getspnam(usr);
		COM_DBG(("RIScom_get_password: spwd_pw->sp_pwdp <%s>\n", 
			spwd_pw->sp_pwdp ? spwd_pw->sp_pwdp : "none" ));

		if (spwd_pw && spwd_pw->sp_pwdp && *spwd_pw->sp_pwdp)
		{
			*flagp = 1; /* got a password */
			strcpy(buf,spwd_pw->sp_pwdp);
		}
		else
		{
			*flagp = 0;
			*buf = 'x';
			*(buf+1) = '\0';
		}
#endif /* Solaris */

#if defined(__hpux__)
		struct pr_passwd *pr_pw;
		COM_DBG(("RIScom_get_password: HP-UX Trusted System\n"));
		pr_pw = RIScom_getprpwnam(usr);
		COM_DBG(("RIScom_get_password: pr_pw->ufld.fd_encrypt <%s>\n", 
			pr_pw->ufld.fd_encrypt ? pr_pw->ufld.fd_encrypt : "none" ));

		if (pr_pw && pr_pw->ufld.fd_encrypt && *pr_pw->ufld.fd_encrypt)
		{
			*flagp = 1; /* got a password */
			strcpy(buf,pr_pw->ufld.fd_encrypt);
		}
		else
		{
			*flagp = 0;
			*buf = 'x';
			*(buf+1) = '\0';
		}
#endif

	}
}
#endif /* unix */

/******************************************************************************/
