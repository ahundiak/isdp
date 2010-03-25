#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
#include <sys/sysingr.h>
#endif
#include "defs.h"

#define FLAG_I	0
#define SLOT_I	1
#define PN_I	2
#define KEY_I	3
#define FILE_I	4
#define VERS_I	5
#define CID_I	6
#define EVCFG_I	7

#define RING	".cmsdr."
extern short    verbose;        /*set if "-v" cmd line option present*/
extern short	srcmedia;
extern short	takedefaults;
extern char	*machine;

extern char	deltools_home[];
extern char	*ingrhome;
extern void	build_pn15();

#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
extern short	iso_9660;
#endif

unsigned int	decode_slot;

int	check_key(path, pptr)
char	*path;
struct prodnode	*pptr;
{
	register	pass, found, ok = 0;
	int	fd;
	char	*c;
	char	*keyf = NULL;
	char	*keyfsv = NULL;
	char	*snfsv = NULL;
	static char	loadkey[KEY_LEN] = {""};
	static char	custid[66] = {"customer-id"};
	char		fname[256];
	char	keyinput[64];
	static char	*envstr[8] = { NULL, NULL, NULL, NULL,
				       NULL, NULL, NULL, NULL };
	extern char	*crypt();
	extern char	*net_keyreq();
	extern int	find_keyfile_entry();
	extern int	make_keyfile_entry();
	extern char	*generate_key_filename();
	extern char	*generate_sn_filename();
	FILE		*pfd;
	FILE		*f;
	char		cmd[128], timestr[64], answer[64];
	int		result;
	char		longnum[32];
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
#  ifdef ANCIENT
	struct init_s {
		int	fd;
		char	*num, *access, *pflag;
		int	iproc;
	}	init;
#  endif
#endif
	unsigned 	short	authtyp = 0, evalsn = 0;
	extern  	unsigned short cdtype, sssn;
	char		msg[2][14]={"load key", "serial number"}; 
	unsigned int lkndx, prdndx;
	build_pn15(longnum, pptr->prodnumber, pptr->prodversion);

	fd = -1;

	if (!envstr[FLAG_I]) {
		envstr[FLAG_I] = (char *)malloc(32);
		envstr[SLOT_I] = (char *)malloc(32);
		envstr[PN_I] = (char *)malloc(32);
		envstr[KEY_I] = (char *)malloc(32);
		envstr[FILE_I] = (char *)malloc(320);
		envstr[VERS_I] = (char *)malloc(32);
		envstr[CID_I] = (char *)malloc(65);
		envstr[EVCFG_I] = (char *)malloc(32);
		if (!envstr[FLAG_I] || !envstr[SLOT_I] || !envstr[PN_I] ||
			!envstr[KEY_I] || !envstr[FILE_I] || !envstr[VERS_I] ||
			 !envstr[CID_I] || !envstr[EVCFG_I] ) {
			PRINT "Memory allocation failure\n");
			return(-1);
		}
	}

	/*
	 * if pptr->flags is zero, then no key is required
	 */
	if (!atoi(pptr->flags)) {
		sprintf(envstr[FLAG_I], "FLAGS=0");
		putenv(envstr[FLAG_I]);
		return(0);
	}

	found = 0;
	if (srcmedia == NETCDROM) {
		if ((c = net_keyreq(pptr))) {
			strncpy(loadkey, c, KEY_LEN);
			++found;
		        if (strlen(loadkey) > 14)
			    authtyp=0;
			else
			    authtyp=1;
		}
	} else {
		/*
		 * make sure that we have a valid source file out there
		 */
		fd = open(path, O_RDONLY);
		if (fd < 0)
			return(-1);
		/*
		 * try to find the key
		 */
		authtyp=0;
		if ((keyf = generate_key_filename(path))) {
		    keyfsv = keyf;
		    found = find_keyfile_entry(keyf, pptr->prodnumber, pptr->prodversion, loadkey, authtyp);
		}
		if (!found ) {	/* try serial no. file */
		    authtyp=1;
		    if ((keyf = generate_sn_filename(path))) {
			snfsv = keyf;
		    	found = find_keyfile_entry(keyf, pptr->prodnumber, pptr->prodversion, loadkey, authtyp);
		    }
		}
	}
	for (pass = 0; pass < 2; ++pass) {
		if (found && !pass)
			PRINT "\nUsing %s found for %s (%s).\n",
				&msg[authtyp][0], pptr->prodname, longnum);
		else if (takedefaults && !isatty(0)) {
			/*
			 * don't prompt for a key when we're taking default
			 * answers and redirecting stdin --
			 * keeps from hanging remote_newprod
			 */
			PRINT "\nNo authorization key known for product %s (%s).\n",
				pptr->prodname, longnum);
			break;
		} else {
		if ((srcmedia == CDROM) || (srcmedia == NETCDROM && sssn))
			    PRINT "\nEnter load key or serial no. for %s (%s): ",	pptr->prodname, longnum);
			else
			    PRINT "\nEnter load key for %s (%s): ",pptr->prodname, longnum);
			/*
			 * TR 289300357
			 * "loadkey" is just long enough to hold the key
			 * If user mis-types, or uses ^H instead of
			 * "real" erase key, result is too long and
			 * causes a core dump.
			 *
			 * Put it in a longer string, then copy it
			 * into the actual string using strncpy.
			 */
			gets(keyinput);
			strncpy(loadkey, keyinput, KEY_LEN-1);

		        if (strlen(loadkey) > 14)
			    authtyp=0;
/*++++++++++++++++++++++*/
			else {
			    authtyp=1;
/* Moved Serialization ndx from here */
			}/*else*/
/*----------------------*/
			custid[0] = '\0';
			if ( authtyp && (loadkey[0] == 'E' || loadkey[0] == 'e')) {
			    PRINT "\nEnter your id ");
			    gets(custid);
		    	    sprintf(envstr[CID_I], "CUSTID=%s", custid);
		    	    putenv(envstr[CID_I]);
			    VPRINT ("ESN=",loadkey );
			    VPRINT ("CID=",custid );
			    sprintf(fname, "%s/%s", ingrhome, KEYSDIR);
		    	    sprintf(envstr[EVCFG_I], "SWESRT=%s", fname);
		    	    putenv(envstr[EVCFG_I]);
			    sprintf(fname, "%s/%s/%s", ingrhome, KEYSDIR, "cfg");
			    if (access(fname, (R_OK | W_OK | X_OK)))
			        mkdir(fname, 0755);
			    sprintf(fname, "%s/%s/%s/%s", ingrhome, KEYSDIR, "cfg","sf.dat");
			    if ((f = fopen(fname, "r+")) == NULL)
			        if ((f = fopen(fname, "w+")) == NULL){ /* create the file */
				    VPRINT1 ("Couldn't create Eval sf.dat\n" );
				    return(-1);
				}
				fclose(f);
				evalsn=1;	/* remember this*/
			}
		}
/* Put serialization index test */
			    if (authtyp) {
/*
			    if (verbose)
			      PRINT "VERBOSE: LKndx=%s  Pndx=%s\n", &loadkey[8], &pptr->prodindx[0]);
*/
			      lkndx=atoi(&loadkey[8]);
			      prdndx=atoi(&pptr->prodindx[0]);
			    if (lkndx != prdndx){
				PRINT "\nIncorrect Serialization index - \"%s\". %s!\n", loadkey,
				  pass ? "Sorry" : "Try again");
				  continue;
			      }/*test*/
			    }
		if (srcmedia == NETCDROM) {
			if (authtyp && !sssn) {
			    PRINT "Server does not support serial number authorization!\n");
			    found = -1;
			}
			else
			    found = net_keyverify(pptr, loadkey, custid);
		}
		else {
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
# ifdef ANCIENT
		    /*
		     * set these each attempt since the syscall will change
		     * the init values when a failure occurs (don't know why)
		     */
		    init.num = longnum;
		    init.pflag = pptr->flags;
		    init.access = loadkey;
		    init.fd = fd;
		    found = syscall(125, SINGRNABDRINIT, &init);
		    decode_slot = init.iproc;

# else /* ANCIENT */
		    sprintf(envstr[PN_I], "PRODNUMBER=%s", longnum);
		    putenv(envstr[PN_I]);
		    sprintf(envstr[FLAG_I], "FLAGS=%s", pptr->flags);
		    putenv(envstr[FLAG_I]);
		    sprintf(envstr[KEY_I], "KDATA=%s", loadkey);
		    putenv(envstr[KEY_I]);
		    sprintf(envstr[FILE_I], "KF=%s", path);
		    putenv(envstr[FILE_I]);

		    sprintf(envstr[VERS_I], "PRODVERSION=%s", pptr->prodversion);
		    putenv(envstr[VERS_I]);

		    sprintf(timestr, "%d", time(0)/2);
		    sprintf(cmd, "%s/%s %s", deltools_home,
			    RING, timestr);
		    pfd = popen(cmd, "r");
		    while (fgets(answer, 128, pfd) != NULL);
		    result = pclose(pfd);
		    decode_slot = atoi(answer);
		    found = (result >> 8);
# endif /* ANCIENT */
#else  /* Sun */
                        sprintf(envstr[PN_I], "PRODNUMBER=%s", longnum);
                        putenv(envstr[PN_I]);
                        sprintf(envstr[FLAG_I], "FLAGS=%s", pptr->flags);
                        putenv(envstr[FLAG_I]);
                        sprintf(envstr[KEY_I], "KDATA=%s", loadkey);
                        putenv(envstr[KEY_I]);
                        sprintf(envstr[FILE_I], "KF=%s", path);
                        putenv(envstr[FILE_I]);
			sprintf(envstr[VERS_I], "PRODVERSION=%s", pptr->prodversion);
			putenv(envstr[VERS_I]);

			sprintf(timestr, "%d", time(0)/2);
			sprintf(cmd, "%s/%s %s", deltools_home,
				RING, timestr);
                        pfd = popen(cmd, "r");
                        while (fgets(answer, 128, pfd) != NULL);
                        result = pclose(pfd);
                        decode_slot = atoi(answer);
                        found = (result >> 8);
#endif
		}
		if (found == 0) {
			if (srcmedia != NETCDROM && !evalsn) {
			    if (authtyp)
				keyf = snfsv;
			    else
				keyf = keyfsv;
			    make_keyfile_entry(keyf, pptr->prodnumber, pptr->prodversion, loadkey, authtyp);
			}
			++ok;
			break;
		}
		PRINT "\nAuthorization Failed - \"%s\". %s!\n", loadkey,
			pass ? "Sorry" : "Try again");
	}
	if (fd != -1)
		close(fd);
	if (!ok)
		return(-1);

	sprintf(envstr[FLAG_I], "FLAGS=%s", pptr->flags);
	putenv(envstr[FLAG_I]);
	sprintf(envstr[SLOT_I], "SRCSLOT=%d", decode_slot);
	putenv(envstr[SLOT_I]);

	fflush(stdout);

	return(0);
}
