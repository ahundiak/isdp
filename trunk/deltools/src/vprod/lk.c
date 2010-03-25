#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
#include <sys/sysingr.h>
#endif
#include "main.h"
#include "defs.h"

#define FLAG_I  0
#define SLOT_I  1
#define PN_I    2
#define KEY_I   3
#define FILE_I  4
#define VERS_I  5

#define CID_I	6
#define EVCFG_I	7

#define RING    ".cmsdr."

extern short	srcmedia;
extern short	takedefaults;
extern char	*machine;
extern char	deltools_home[];
extern char	*ingrhome;
extern short	foldcase;
extern short    iso_9660;

#ifdef XFORMS
extern Display	*display;
#endif

extern char     *crypt();

extern void	build_pn15();

unsigned int	decode_slot;

#define	ACCEPTED_FORM	1

Form	keyform;
extern Form delform;

int	accepted_form;
static int	loops;
static char	loadkey[KEY_LEN] = {""};
static int	key_ok;
static struct prodnode	*spptr;
static int	sfd;
static char	*keyf = NULL;
static char     *envstr[8] = { NULL, NULL, NULL, NULL,
				   NULL, NULL, NULL, NULL };
unsigned short	authtypv = 0, evalsnv= 0, doing_custid=0, cidpr=0;
char		*snfsv=NULL, *keyfsv=NULL;
char		evalPN[PRODNUM_LEN]={""};
char		evalSN[KEY_LEN]={""};
char		evalCID[CUSTID_LEN]={""};

/*ARGSUSED*/
void
loadkey_note ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
    int             status;
    char	    msg[80];
    char	    keyinput[64];
    char	    custid[66]="";
    extern  	    unsigned short cdtype, sssn;
    char	    whichmsg[3][20]={"load key", "serial number", "serialization index"}; 
    char	    fname[256];
    extern	    unsigned short authtypv, evalsnv, doing_custid, cidpr;
    FILE	    *f;

    if (!doing_custid || g_label == FI_CANCEL) {
      switch ( g_label ) 
      {
	case FI_CANCEL:
	    doing_custid=0;
	    cidpr=0;
	    FIf_erase(fp);
	    accepted_form = FALSE;
	    return;

	case LK_KEYFIELD: 
	    status = FIg_get_text (fp, g_label, keyinput);
	    if ( status != FI_SUCCESS )
	    {
	      accepted_form = FALSE;
              return;
	    }
	    
	    if (*keyinput == NULL) {
		accepted_form = FALSE;
		return;
	    }
	    /* Verify provided load key */
	    strncpy(loadkey, keyinput, KEY_LEN-1);
	    authtypv=0;
	    if (strlen(loadkey) > 14)
		goto validate;

/* Move to valid_key!
	    lkndx=atoi(&loadkey[8]);
	    prdndx=atoi(&spptr->prodindx[0]);
	    if (lkndx != prdndx){
	    	authtypv=2;		
		key_ok=0;
		goto notvalid;
	    }
*/
	    authtypv=1;
	    if ( authtypv && (loadkey[0] == 'E' || loadkey[0] == 'e')) {
		FIg_erase(fp, LK_PROMPT);
		FIg_set_justification(fp, LK_PROMPT, FI_CENTER_JUSTIFIED);
		FIg_set_text(fp, LK_PROMPT, "Please enter your customer-id");
		FIg_display(fp, LK_PROMPT);
		FIg_reset(fp, LK_KEYFIELD);
		FIg_erase(fp, LK_KEYFIELD);
		FIg_display(fp, LK_KEYFIELD);
		FIf_display(fp);
		FIfld_pos_cursor(fp, LK_KEYFIELD, 0, 0, 0, 0, 0, 0);
		doing_custid=1;
		return;
	    }
      } /*switch*/
    } /*not custid*/
    else {
      doing_custid=0;
      cidpr=1;
      status = FIg_get_text (fp, g_label, keyinput);
      if ( status != FI_SUCCESS ) {
	accepted_form = FALSE;
	return;
	}
      if (*keyinput == NULL) {
	accepted_form = FALSE;
	return;
	}
      /* handle custid input */
      sprintf(fname, "%s/%s/%s", ingrhome, KEYSDIR, "cfg");
      if (access(fname, (R_OK | W_OK | X_OK))){
	mkdir(fname, 0755);
      }
      sprintf(fname, "%s/%s/%s/%s", ingrhome, KEYSDIR, "cfg","sf.dat");
      if ((f = fopen(fname, "r+")) == NULL){
	if ((f = fopen(fname, "w+")) == NULL){ /* create the file */
	    FIg_erase(fp, LK_MSG);
	    FIg_set_text(fp, LK_MSG,"Couldn't create Eval sf.dat");
	    FIg_display(fp, LK_MSG);
	    FIf_display(fp);
	    accepted_form = FALSE;
	    sleep(3);
	    FIf_erase(fp);
#ifndef XFORMS
	    FIf_display(delform);
#endif        
            PRINT "Eval-sn cfg file failure! \n" );
	    return;
        }
      }
    strncpy(custid, keyinput, KEY_LEN-1);
    sprintf(envstr[CID_I], "CUSTID=%s", custid);
    putenv(envstr[CID_I]);
    sprintf(fname, "%s/%s", ingrhome, KEYSDIR);
    sprintf(envstr[EVCFG_I], "SWESRT=%s", fname);
    putenv(envstr[EVCFG_I]);
    fclose(f);
    evalsnv=1;
    } /* end custid else */   
validate:
	    key_ok = valid_key(spptr, loadkey, sfd, custid);
notvalid:
	    if (!key_ok) {
		sprintf(msg, "Incorrect %s - \"%s %s\". %s!", 
			whichmsg[authtypv], loadkey, custid,
			     (loops++ < 2) ? "Try again" : "Sorry");
		FIg_erase(fp, LK_MSG);
		FIg_set_text(fp, LK_MSG, msg);
		FIg_display(fp, LK_MSG);
		FIg_reset(fp, LK_KEYFIELD);
		FIg_erase(fp, LK_KEYFIELD);
		FIg_display(fp, LK_KEYFIELD);
		if (cidpr) {
		  cidpr=0;
		  /*FIg_erase(fp, LK_PROMPT);*/
		  FIg_set_justification(fp, LK_PROMPT, FI_CENTER_JUSTIFIED);
		  if ((srcmedia == CDROM) || (srcmedia == NETCDROM && sssn))
		    FIg_set_text(fp, LK_PROMPT, "Enter your load-key or serial-no");
		  else
		    FIg_set_text(fp, LK_PROMPT, "Enter your load-key");
		}
	        FIf_display(fp);
		FIfld_pos_cursor(fp, LK_KEYFIELD, 0, 0, 0, 0, 0, 0);
		if (loops > 2) {
		    accepted_form = FALSE;
		    sleep(3);
		    FIf_erase(fp);
#ifndef XFORMS
		    FIf_display(delform);
#endif
		}
	    return;
	    }
	    else {
		accepted_form = TRUE;
		sprintf(msg, "%s \"%s\" accepted.", whichmsg[authtypv], loadkey);
		FIg_erase(fp, LK_MSG);
		FIg_set_text(fp, LK_MSG, msg);
		FIg_display(fp, LK_MSG);
		FIf_display(fp);
		sleep(3);
		FIf_erase(fp);
#ifndef XFORMS
		FIf_display(delform);
#endif
	    }
} /* loadkey_note */



/* NOTE:  THIS ROUTINE RETURNS "1" if the load key is valid and "0"
 *        if it is invalid.
 */
int
valid_key(pptr, loadkey, fd, custid)
struct prodnode	*pptr;
char loadkey[];
int fd;
char custid[];
{
    struct init_s {
	    int	fd;
	    char	*num, *access, *pflag;
	    int	iproc;
    }	init;
    int		found;
    FILE	*pfd;
    char	path[128];
    char	cmd[128], timestr[64], answer[64];
    char	*cp;
    char	longnum[32];
    int	result;
    unsigned int lkndx, prdndx;
    extern  	unsigned short cdtype, sssn;
    extern  	char *keyfsv, *snfsv;    
    extern 	char evalPN[PRODNUM_LEN];
    extern	char evalSN[KEY_LEN];
    extern	char evalCID[CUSTID_LEN];
    build_pn15(longnum, pptr->prodnumber, pptr->prodversion);

    sprintf(path, "%sREADME", pptr->srcdir);
    if (iso_9660 && foldcase) {
	for (cp = path+strlen(GetMountPoint(path)); *cp; cp++)
	    *cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
    }
/*++*/
    lkndx=atoi(&loadkey[8]);
    prdndx=atoi(&pptr->prodindx[0]);
    if (lkndx != prdndx){
	authtypv=2;		
	key_ok=0;
	result = -1;
	return(0);
    }
/*--*/
    if (srcmedia == NETCDROM) {
	if (authtypv && !sssn) {
	    PRINT "Server does not support serial numbers!");
	    result = -1;
	}
	else
	    result = net_keyverify(pptr, loadkey, custid);
    }
    else {
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
	if (iso_9660) {
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
#ifdef OLD_LOADKEY_METHOD
	    sprintf(cmd, "/usr/tmp/%s%d %s", RING, getpid(),
		    crypt(timestr, "sw"));
#else
	    sprintf(cmd, "%s/%s %s", deltools_home,
		    RING, timestr);
#endif
	    pfd = popen(cmd, "r");
	    while (fgets(answer, 128, pfd) != NULL);
	    result = pclose(pfd);
	    decode_slot = atoi(answer);
	    found = (result >> 8);
	}
	else {
	    init.fd = fd;
	    init.num = longnum;
	    init.access = loadkey;
	    init.pflag =  pptr->flags;
	    
	    result = syscall(125, SINGRNABDRINIT, &init);
	    decode_slot = init.iproc;
	}
#else /* Sun */
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
#ifdef OLD_LOADKEY_METHOD
	sprintf(cmd, "/usr/tmp/%s%d %s", RING, getpid(),
		crypt(timestr, "sw"));
#else
	sprintf(cmd, "%s/%s %s", deltools_home,
		RING, timestr);
#endif
	pfd = popen(cmd, "r");
	while (fgets(answer, 128, pfd) != NULL);
	result = pclose(pfd);
	decode_slot = atoi(answer);
	found = (result >> 8);
#endif
    }

    if (result == 0) {
	if (evalsnv) {
/*	    VPROD relies on loadkey/sn to be saved in order to work. Since 
	    eval SN are not saved, we'll just save the last one. This means 
	    eval products can only be done one at a time */
	    strcpy(evalPN,pptr->prodnumber);
	    strcpy(evalSN,loadkey);
	    strcpy(evalCID,custid);
	}	
	if (srcmedia != NETCDROM && !evalsnv) {
	    if (authtypv)
		keyf = snfsv;
	    else
		keyf = keyfsv;
	    make_keyfile_entry(keyf, pptr->prodnumber, pptr->prodversion, loadkey, authtypv);
	}
	return(1);
    }
    else
	return(0);
}

int	check_key(path, pptr)
char	*path;
struct prodnode	*pptr;
{
	register	found;
	int	fd;
	char	*c, *cp;
	extern	char	*snfsv, *keyfsv;
	char	custid[66] = {""};
	extern char	*net_keyreq();
	extern int	find_keyfile_entry();
	extern int	make_keyfile_entry();
	extern char	*generate_key_filename();
	extern char	*generate_sn_filename();
	extern char 	evalPN[PRODNUM_LEN];
	extern char 	evalSN[KEY_LEN];
	extern char 	evalCID[CUSTID_LEN];
	char	        whichmsg[2][14]={"load key", "serial number"}; 
	int	sts;
	char	product[64];
	char	fpath[MAXPATHLEN];
	char	longnum[32];
	extern  	unsigned short cdtype, sssn;

	fd = -1;

	build_pn15(longnum, pptr->prodnumber, pptr->prodversion);

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
			 !envstr[CID_I] || !envstr[EVCFG_I] )
			PRINT "Memory allocation failure\n");
        }

	/*
	 * if pptr->flags is zero, then no key is required
	 */
	if (!atoi(pptr->flags)) {
		sprintf(envstr[FLAG_I], "FLAGS=0");
		putenv(envstr[FLAG_I]);
		return(0);
	}

/********************************************/
/*		Check if this is the last evaluation product selected. We have to do
		this because of the way vprod works and eval serial nos are not saved
		Note that VPROD can only do one evaluation product at a time.*/
/*		else if (!strcmp(longnum,evalPN)) {
		    strcpy(loadkey,evalSN);
		    strcpy(custid,evalCID);
		    found = (int)loadkey[0];
		    authtypv=1;
		    evalsnv=1;
		}
*/
/********************************************/
	found = 0;
	key_ok = 0;
	if (srcmedia == NETCDROM) {
		if ((c = net_keyreq(pptr))) {
		    strncpy(loadkey, c, KEY_LEN);
		    ++found;
		    if (strlen(loadkey) > 14)
			authtypv=0;
		    else
			authtypv=1;
		}
	} else {
		/*
		 * make sure that we have a valid source file out there
		 */
		if (iso_9660 && foldcase) {
		    for (cp = path + strlen(GetMountPoint(path)); *cp; cp++)
			*cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
		}
		fd = open(path, O_RDONLY);
		if (fd < 0)
			return(-1);
		/*
		 * try to find the key
		 */
		authtypv=0;
		if ((keyf = generate_key_filename(path))) {
		    keyfsv = keyf;
		    found = find_keyfile_entry(keyf, pptr->prodnumber, pptr->prodversion, loadkey, authtypv);
		}
		if (!found) {	/* try serial no. file */
		    authtypv=1;
		    if ((keyf = generate_sn_filename(path))) {
			snfsv = keyf;
		    	found = find_keyfile_entry(keyf, pptr->prodnumber, pptr->prodversion, loadkey, authtypv);
		    }
		}
	}

	if (!strcmp(longnum,evalPN)) {
		strcpy(loadkey,evalSN);
		strcpy(custid,evalCID);
		found = (int)loadkey[0];
		authtypv=1;
		evalsnv=1;
	}
	if (!found && takedefaults)
	{
		/*
		 * don't prompt for a key when we're taking default
		 * answers -- keeps from hanging remote_newprod
		 */
		PRINT "\nNo authorization key known for product %s (%s).\n",
				pptr->prodname, longnum);
		if (fd != -1)
		    close(fd);
		return(-1);
	} 
	else if (found) {
		/*
		 * We've got a load key -- but is it correct?
		 */
		PRINT "\nUsing %s found for %s (%s).\n",
			&whichmsg[authtypv][0], pptr->prodname, longnum);
		if ((key_ok = valid_key(pptr, loadkey, fd, custid)) == 0)
		{
			PRINT "\nIncorrect %s - \"%s\".\n",&whichmsg[authtypv][0], loadkey);
			if (takedefaults && !isatty(0))
			{
    			    if (fd != -1)
			        close(fd);
			    return(-1);
			}
		}
		else
		{
		    sprintf(envstr[FLAG_I], "FLAGS=%s", pptr->flags);
		    putenv(envstr[FLAG_I]);
		    sprintf(envstr[SLOT_I], "SRCSLOT=%d", decode_slot);
		    putenv(envstr[SLOT_I]);
		    if (fd != -1)
		        close(fd);
		    return(0);
		}
	}
	/* Check if an Eval. SN has been entered */
	/*
	 * We don't have a valid key, and we're not running in
	 * takedefaults mode, so we put up a form to get the load key
	 * and wait until it's processed. 
	 */
	spptr = pptr;
	sfd = fd;
	evalsnv=0;
	sprintf(product,"%s (%s)", pptr->prodname, longnum);
	sprintf(fpath, "%s/loadkey.form", MYSTUFFDIR);
	sts = FIf_new(LOADKEYFORM, fpath,
                            loadkey_note, &keyform);

#ifdef XFORMS
	Set_form_class(keyform);
#else
	FIf_set_window_level(keyform, FI_HIGH_PRIORITY);
#endif
	if (chkerror(sts, "creating loadkey form"))
		exit(1);
	FIg_set_justification(keyform, LK_PROD, FI_CENTER_JUSTIFIED);
	FIg_set_justification(keyform, LK_MSG, FI_CENTER_JUSTIFIED);
	FIg_set_text(keyform, LK_PROD, product);
	FIg_set_text(keyform, LK_MSG, "");
	    FIg_set_justification(keyform, LK_PROMPT, FI_CENTER_JUSTIFIED);
	if ((srcmedia == CDROM) || (srcmedia == NETCDROM && sssn)){
	    FIg_set_text(keyform, LK_PROMPT, "Enter your load-key or serial-no.");
	}
	else
	    FIg_set_text(keyform, LK_PROMPT, "Enter your load-key.");
	loops = 0;
	sts = FIf_display(keyform);
#ifndef XFORMS
	FIfld_pos_cursor(keyform, LK_KEYFIELD, 0, 0, 0, 0, 0, 0);
#endif
	process_form(keyform);

	FIf_delete(keyform);

	if (!accepted_form || !key_ok) {
	    if (fd != -1)
    		close(fd);
	    return(-1);
	}
	else if (key_ok == 1)
	{
	    sprintf(envstr[FLAG_I], "FLAGS=%s", pptr->flags);
	    putenv(envstr[FLAG_I]);
	    sprintf(envstr[SLOT_I], "SRCSLOT=%d", decode_slot);
	    putenv(envstr[SLOT_I]);

	    return(0);
	}
	else
	    return(-1);
}

int process_form( form )
int form;
{
#ifndef XFORMS
	int event;
#else 
	XEvent event;
	int trans;
#endif
	int display_status;
	int send_to_forms;

	for(;;)
	{
#ifndef XFORMS
		Wait_for_next ( FI_EVENT_MASK, &event );
#else
		XNextEvent(display, &event);
		if (event.type == ButtonPress || event.type == ButtonRelease)
		    FI_get_transition(&event, &trans);
#endif
		send_to_forms = TRUE;
		

		if ( send_to_forms )
		{
#ifndef XFORMS
			if ( ! FI_process_event ( event ) )
				FI_clear_event ( event );
#else
			FI_process_event(&event, trans);
#endif
		}

		FIf_is_displayed ( form, &display_status );

		if ( ! display_status ) break;
	}

	if ( accepted_form == TRUE )
	    return ( ACCEPTED_FORM );
	else
	    return ( ! ACCEPTED_FORM );
}
