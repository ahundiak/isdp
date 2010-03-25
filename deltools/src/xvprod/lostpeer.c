#include "main.h"
#include "defs.h"

#define	ACCEPTED_FORM	1

#define LP_MESSAGE	12
#define LP_BUTTON	13

Form	lp_form;

extern	Form    classform;
extern	Form    delform;
extern	Form    statform;
extern	Form    fsform;
extern	Form    revform;
extern	Form    rem_delform;
extern	Form    remoteform;
extern	Form    timeform;
extern	Form    prod_list[2][4];
extern	Form    show_sel_form;
extern	Form    show_prod_form;
extern	Form    installform;
extern	Form    setupform;
extern	Form    groupform;
extern	Form    packform;
extern	Form    rem_infoform;
extern	Form    promptform;
extern  Form    mainform;
extern  Form    connform;
extern  Form    multnameform[20];

extern	FILE	*logf;
extern	char	ws_script[];
extern	char	ws_beta_script[];


/*ARGSUSED*/
void
lostpeer_note ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
    switch ( g_label ) 
    {
	case LP_BUTTON:
	    FIf_erase(fp);
	    break;
    } /* switch */
} /* lostpeer_note */


/* 
 * We've lost our network connection to the server.
 * Put up a panel informing the user of this sad fact.
 * When they click the OK button, then close everything
 * down and exit.
 */
/*ARGSUSED*/
void
lostpeer(sig)
int sig;
{
    char	fpath[STRSIZ];
    int		sts, i;

    sprintf(fpath, "%s/lpeer.form", MYSTUFFDIR);

    sts = FIf_new(LOSTPEERFORM, fpath, lostpeer_note, &lp_form);
    if (chkerror(sts, "creating loadkey form"))
	    exit(1);

#ifdef XFORMS
    Set_form_class(lp_form);
#else
    FIf_set_window_level(lp_form, FI_HIGH_PRIORITY);
#endif
    sts = FIf_display(lp_form);
    process_form(lp_form);

    PRINT "Exiting...\n");

    sleep(3);
    FIf_delete(lp_form);
    lp_form = NULL;

    if (classform) {
	FIf_delete(classform);
	classform = NULL;
    }
    if (delform) {
	FIf_delete(delform);
	delform = NULL;
    }
    if (revform) {
	FIf_delete(revform);
	revform = NULL;
    }
    if (timeform) {
	FIf_delete(timeform);
	timeform = NULL;
    }
    if (statform) {
	FIf_delete(statform);
	statform = NULL;
    }
    if (fsform) {
	FIf_delete(fsform);
	fsform = NULL;
    }
    if (show_sel_form) {
	FIf_delete(show_sel_form);
	show_sel_form = NULL;
    }
    if (show_prod_form) {
	FIf_delete(show_prod_form);
	show_prod_form = NULL;
    }
    if (installform) {
	FIf_delete(installform);
	installform = NULL;
    }
    if (setupform) {
	FIf_delete(setupform);
	setupform = NULL;
    }
    if (remoteform) {
	FIf_delete(remoteform);
	remoteform = NULL;
    }
    if (groupform) {
	FIf_delete(groupform);
	groupform = NULL;
    }
    if (packform) {
	FIf_delete(packform);
	packform = NULL;
    }
    if (rem_delform) {
	FIf_delete(rem_delform);
	rem_delform = NULL;
    }
    if (rem_infoform) {
	FIf_delete(rem_infoform);
	rem_infoform = NULL;
    }
    if (promptform) {
	FIf_delete(promptform);
	promptform = NULL;
    }
    for (i = 0; i < 20; i++) {
	if (multnameform[i]) {
	    FIf_delete(multnameform[i]);
	    multnameform[i] = NULL;
	}
    }

    execute_info_script(ws_script, END, TRUE);
    execute_info_script(ws_beta_script, END, FALSE);
    unlink(ws_script);
    unlink(ws_beta_script);

    if (logf)
	fclose(logf);

    sync(); sync();
    exit(2);
}
