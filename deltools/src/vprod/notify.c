#include "main.h"
#include "defs.h"
#include <sys/utsname.h>

/****************************************************************************/
/* this file contains these notification routines:                          */
/*									    */
/* connect_note		 for the connection form                            */
/* notification_routine  for the command button form                        */
/* review_note           for the README browser form                        */
/* deliver_note_a        for the local delivery form - ascii format         */
/* pack_note             for the package form                               */
/* remote_note		 for the remote machines form                       */
/* stat_note		 for the message box form                           */
/* fs_note		 for the file system form                           */
/* install_note		 for the load form                                  */
/* setup_note		 for the remote setup form                          */
/* group_note		 for the group form                                 */
/* rem_del_note		 for the remote delivery form                       */
/* prompt_note		 for the prompt form                                */
/****************************************************************************/


extern  prompt_note();
extern  rem_del_note();
extern	rem_info_note();
extern  pack_note();
extern  group_note();
extern  remote_note();
extern  setup_note();
extern  install_note();
extern  show_prod_note();
extern	class_form_note();
extern	deliver_note_a();
extern  stat_note();
extern  fs_note();
extern	notification_routine();
extern	time_note();
extern 	char *media_connect();
extern 	char *curr_location();
extern struct prodnode *first(), *last(), *prev(), *next();
extern char *get_month2();
extern char *tempnam();

extern	char button_array[2][MAXROW*MAXCOL][MAXPROD];
extern	int  multname_array[MAXROW*MAXCOL];

extern	hostname[];
extern	acctname[];
extern	localcmd[];
extern	tapecmd[];

extern	int	when;	/* time of remote delivery info */
extern	int	month;
extern	int	day;
extern	int	year;
extern  int	hour;
extern  int	min;
extern  int	meridian;
extern	short	st_group_enabled;
extern	short	sd_group_enabled;

extern  char ws_script[STRSIZ];
extern  char ws_beta_script[STRSIZ];
extern	char ws_prodlist[STRSIZ];

extern  struct prodnode *current_product;
extern	struct prodnode header;
extern	struct prodnode classheader;
extern	struct prodnode loadedheader;
extern	struct prodnode *curr_hdr;
extern	struct prodnode *start;

extern	unsigned long my_arch;
extern	int	class;
extern	short	multimenu;
extern  short   local_menu;  /* keep track of the state of the local menu */
extern	short	allvis;
extern	int mess_row;
extern	short verbose;
extern	short takedefaults;
extern  short minus_x;
extern	int curr_fs;
extern	struct fsdata fs_table[];
extern	int	num_fs;		/* number of local file systems */
extern	char	force_dest[];
extern	struct utsname	un;

extern	short	help_avail;

char path[MAXPATHLEN];

/* remote information */
extern	int	total_remotes;
extern	int	total_groups;
extern	int	total_packs;
int	sel_remotes=0;
int	sel_groups=0;
int	sel_packs=0;

int	max_simul_del = MAX_DEF;  /* maximum number of simultaneous deliveries - MAX */

int	validate_mode = TRUE; /* validate remotes as they are added */

Form	classform;
Form	delform;	
Form	statform;
Form	fsform;
Form	revform;
Form	rem_delform;
Form	remoteform;
Form	timeform;
Form	prod_list[2][4];
Form	show_sel_form;
Form	show_prod_form;
Form	installform;
Form	setupform;
Form	groupform;
Form	packform;
Form	rem_infoform;
Form	promptform;

extern  Form	mainform;
extern	Form	connform;
extern	Form	multnameform[20];

short	show_all_plats;
short	srcmedia=0;
int	percent=0;
int	last_active_class;
int	pack_mode = FALSE;	/* true when remote form is in package mode */
int	main_wno;		/* number of the vprod.form window */
extern int	xcoll, ycoll;  /* initial collapse position */

char	connstr[STRSIZ];
char	host[20], acctnm[20], pass[20];

/*ARGSUSED*/
connect_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	int	sts;
	char	cmd[60];
	char	*str;
	short	tmp_media;
	char	line[MAXLINE];

	FIg_reset(fp, MESSAGE);

	switch(g_label)
	{
	 case FLOPPY:
	 case CDROM:
		/* erase the network gadgets */
		FIg_erase(fp, HOST_TEXT);
		FIg_erase(fp, LOCAL_TEXT);
		FIg_erase(fp, DEVICE_TEXT);
		FIg_erase(fp, HOST_FIELD);
		FIg_erase(fp, ACCT_TEXT);
		FIg_erase(fp, ACCT_FIELD);
		FIg_erase(fp, PASS_TEXT);
		FIg_erase(fp, PASS_FIELD);

		if (g_label == FLOPPY) {
			FIfld_set_text(fp, MESSAGE, 0, 0, 
				"Insert floppy and click on the", FALSE);
			FIfld_set_text(fp, MESSAGE, 1, 0,
				"\"Make Connection\" button.", FALSE);
		} else {
			FIfld_set_text(fp, MESSAGE, 0, 0, 
				"Insert CD/ROM and click on the", FALSE);
			FIfld_set_text(fp, MESSAGE, 1, 0,
				"\"Make Connection\" button.", FALSE);
		}

		srcmedia = g_label;

		break;

	 case NETCDROM:
		srcmedia = g_label;

		FIg_erase(fp, DEVICE_TEXT);
		FIg_erase(fp, LOCAL_TEXT);
		
		/* display the network gadgets */
		FIg_display(fp, HOST_TEXT);
		FIg_display(fp, HOST_FIELD);
		FIg_display(fp, ACCT_TEXT);
		FIg_display(fp, ACCT_FIELD);
		FIg_display(fp, PASS_TEXT);
		FIg_display(fp, PASS_FIELD);

		if (hostname[0] != '\0')
		{
			FIfld_set_text(fp, HOST_FIELD, 0, 0, hostname, FALSE);
			FIfld_set_text(fp, ACCT_FIELD, 0, 0, acctname, FALSE);

			/* tell them that they need to type in a password */
			sprintf(line, "Please type the password for %s.%s",
				hostname, acctname);
			FIfld_set_text(fp, MESSAGE, 0, 0, line, FALSE);
			FIfld_pos_cursor(fp, PASS_FIELD, 0, 0, 0, 0, 0, 0);
		} /* if */
		else
			FIfld_pos_cursor(fp, HOST_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case LOCAL_DIR:
		/* erase the network gadgets */
		FIg_erase(fp, HOST_TEXT);
		FIg_erase(fp, DEVICE_TEXT);
		FIg_display(fp, HOST_FIELD);
		FIg_display(fp, LOCAL_TEXT);
		FIg_erase(fp, ACCT_TEXT);
		FIg_erase(fp, ACCT_FIELD);
		FIg_erase(fp, PASS_TEXT);
		FIg_erase(fp, PASS_FIELD);
		FIg_reset(fp, HOST_FIELD);

		FIfld_set_text(fp, HOST_FIELD, 0, 0, localcmd, FALSE);

		FIfld_pos_cursor(fp, HOST_FIELD, 0, 0, 0, 0, 0, 0);
		srcmedia = g_label;
		host[0] = acctnm[0] = pass[0] = '\0';
		break;

	 case TAPE:
		srcmedia = g_label;

		FIg_erase(fp, HOST_TEXT);
		FIg_erase(fp, LOCAL_TEXT);
		FIg_erase(fp, ACCT_TEXT);
		FIg_erase(fp, ACCT_FIELD);
		FIg_erase(fp, PASS_TEXT);
		FIg_erase(fp, PASS_FIELD);

		FIg_display(fp, DEVICE_TEXT);
		FIg_display(fp, HOST_FIELD);
		FIg_reset(fp, HOST_FIELD);

		if (tapecmd[0])
		    FIfld_set_text(fp, HOST_FIELD, 0, 0, tapecmd, FALSE);
		else
		    FIfld_set_text(fp, HOST_FIELD, 0, 0, TAPE_DEVICE, FALSE);

		FIfld_pos_cursor(fp, HOST_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case NETWORK:	
		srcmedia = g_label;

		FIg_erase(fp, DEVICE_TEXT);
		FIg_erase(fp, LOCAL_TEXT);
		
		/* display the network gadgets */
		FIg_display(fp, HOST_TEXT);
		FIg_display(fp, HOST_FIELD);
		FIg_display(fp, ACCT_TEXT);
		FIg_display(fp, ACCT_FIELD);
		FIg_display(fp, PASS_TEXT);
		FIg_display(fp, PASS_FIELD);

		if (hostname[0] != '\0')
		{
			FIfld_set_text(fp, HOST_FIELD, 0, 0, hostname, FALSE);
			FIfld_set_text(fp, ACCT_FIELD, 0, 0, acctname, FALSE);

			/* tell them that they need to type in a password */
			sprintf(line, "Please type the password for %s.%s",
				hostname, acctname);
			FIfld_set_text(fp, MESSAGE, 0, 0, line, FALSE);
			FIfld_pos_cursor(fp, PASS_FIELD, 0, 0, 0, 0, 0, 0);
		} /* if */
		else
			FIfld_pos_cursor(fp, HOST_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case GO:
		mess_row=0;

		if (srcmedia == 0)
		{
			FIfld_set_text(fp, MESSAGE, 0, 0, 
				"Please select the media type", FALSE);
			return;
		} /* if */

		FIfld_set_text(fp, MESSAGE, 0, 0, "Working...", FALSE);

		cmd[0] = '\0';

		if ((srcmedia == NETWORK) || (srcmedia == NETCDROM))
		{
			FIg_get_text(fp, HOST_FIELD, host);
			FIg_get_text(fp, ACCT_FIELD, acctnm);
			FIg_get_text(fp, PASS_FIELD, pass);
			if (host[0] == '\0')
			{
				FIfld_set_text(fp, MESSAGE, 0, 0,
				"Host must be specified", FALSE);
				return;
			} /* if */

			if (acctnm[0] == '\0')
			{
				FIfld_set_text(fp, MESSAGE, 0, 0,
				"Account must be specified", FALSE);
				return;
			} /* if */

			if (pass[0] == '\0')
				sprintf(cmd, "%s@%s", acctnm,host);
			else
				sprintf(cmd, "%s@%s:%s", acctnm, host, pass);

		} /* if */
		else if ((srcmedia == TAPE) || (srcmedia == LOCAL_DIR)) {
		    FIg_get_text(fp, HOST_FIELD, cmd);
		    if (srcmedia == TAPE && cmd[0] == '\0')
			strcpy(cmd, TAPE_DEVICE);
		}

		write_def(fp);  /* save responses in defaults file */

		tmp_media = srcmedia;	/* save value of srcmedia in case of failure */
		str = media_connect(cmd);

		if (str != NULL)
		{
			FIg_reset(fp, MESSAGE);
			mess_row = 0;
			FIfld_set_text(fp, MESSAGE, 0, 0, str, FALSE);
			srcmedia = tmp_media;
			return;
		} /* if */

		strcpy(connstr, cmd);

		sts = get_prod_list();

		if (sts)
		{
			FIg_reset(fp, MESSAGE);
			mess_row = 0;
			FIfld_set_text(fp, MESSAGE, 0, 0,
				"Unable to retrieve product list", FALSE);
			return;
		} /* if */
		
		if (execute_info_script(ws_beta_script, BEGIN, FALSE) == 255)
			terminate(7);

		if (execute_info_script(ws_script, BEGIN, FALSE) == 255)
			terminate(7); 

		/*
		 * prepare to read product list file
		 */

		classheader.blocksize = 0;
		classheader.pstat = 0;
		classheader.prodclass[0] = '\0';
		classheader.flink = &classheader;
		classheader.blink = &classheader;

		header.blocksize = 0;
		header.arch = 0;	/* number of products for local platform */
		header.flink = &header;
		header.blink = &header;
		curr_hdr = &header;

		if (srcmedia == NETCDROM)
		    get_key_data("/usr/tmp/keyfile");
		else if (srcmedia == CDROM)
		    get_key_data(generate_key_filename(ws_prodlist));

		sts = read_prodlist_file(ws_prodlist, &header);
		if (sts < 0)
		{
			FIg_reset(fp, MESSAGE);
			mess_row = 0;
			FIfld_set_text(fp, MESSAGE, 0, 0,
				"Unable to create product list", FALSE);
			return;
		}
		else if (sts == 0)
		{
			FIg_reset(fp, MESSAGE);
			mess_row = 0;
			FIfld_set_text(fp, MESSAGE, 0, 0,
				"No products available for your platform", FALSE);
			return;
		} /* if */

		/* If there's only one class out there, go into "All Products"
		 * mode to spare the user the hassle of selecting the
		 * only available class...
		 */
		if (classheader.blocksize == 1)
		{
		    local_menu = 0;
		    multimenu = 0;
		}
		else
		{
		    local_menu = 1;
		    multimenu = 1;
		}
		class = 0;
		
		if (srcmedia == NETCDROM)
		    get_key_data("/usr/tmp/keyfile");
		else if (srcmedia == CDROM)
		    get_key_data(generate_key_filename(ws_prodlist));


		FIf_erase(fp);

		if (mainform == NULL)
		{
		    sprintf(path, "%s/vprod.form", MYSTUFFDIR);
		    sts = FIf_new(VPRODFORM, path,
				  notification_routine, &mainform);
		    if (chkerror (sts, "creating form"))
			exit(1);

#ifdef XFORMS
		    Set_form_class(mainform);
		    /*FIg_erase(mainform, FI_COLLAPSE);*/
		    if (!help_avail)
			FIg_disable(mainform, FI_HELP);
#endif

		    sts = FIf_display(mainform);
		    if (chkerror (sts, "displaying form"))
			exit(1);

#ifndef XFORMS
		    FIf_get_window(mainform, &main_wno);
		    Set_win_collapse_org(main_wno, xcoll, ycoll);
#endif

		    /* put it in local delivery mode by default */
		    FIg_set_state_on(mainform, LOCAL_DEL);
		    notification_routine(VPRODFORM, LOCAL_DEL, (double)1, mainform);

		} /* if */
		else
		{
			FIf_reset(mainform);
		} /* else */
		break;

	 case QUIT:
	 case FI_CANCEL:
		FIf_delete(fp);

		if (mainform)
			FIf_reset(mainform);
		break;
	
#ifndef XFORMS
	 case FI_HELP:
		Help_mode(STANDARD_WINDOW_ONLY);
		Help_origin(100,150);
		Help_toc();
		break;
#endif
	} /* switch */
} /* connect_note */



/*ARGSUSED*/
notification_routine(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	int	sts, dispstat;
	int	i;
	char	deltitle[64];
	char	fslabel[3][32];

	if (value < 0)
		return;

	switch (g_label)
	{
	 case FI_CANCEL:
		sts=FIf_delete(fp);
		if(chkerror(sts, "erasing form"))
			return;

		if (classform)
			FIf_delete(classform);
		if (delform)
			FIf_delete(delform);
		if (revform)
			FIf_delete(revform);
		if (timeform)
			FIf_delete(timeform);
		if (statform) 
			FIf_delete(statform);
		if (fsform)
			FIf_delete(fsform);
		if (show_sel_form)
			FIf_delete(show_sel_form);
		if (show_prod_form)
			FIf_delete(show_prod_form);
		if (installform)
			FIf_delete(installform);
		if (setupform)
			FIf_delete(setupform);
		if (remoteform)
			FIf_delete(remoteform);
		if (groupform)
			FIf_delete(groupform);
		if (packform)
			FIf_delete(packform);
		if (rem_delform)
			FIf_delete(rem_delform);
		if (rem_infoform)
			FIf_delete(rem_infoform);
		if (promptform)
			FIf_delete(promptform);
		for (i = 0; i < 20; i++) {
		    if (multnameform[i])
			FIf_delete(multnameform[i]);
		}
		break;


#ifndef XFORMS
	 case FI_HELP:
		Help_mode(STANDARD_WINDOW_ONLY);
		Help_origin(100,150);
		Help_toc();
		break;
#endif

	 case LOCAL_DEL:
		/* get rid of forms that might be up from the remote environment */
		if (revform) {
			FIf_delete(revform);
			revform = NULL;
		}
		if (timeform) {
			FIf_delete(timeform);
			timeform = NULL;
		}
		if (remoteform) {
			FIf_delete(remoteform);
			remoteform = NULL;
		}
		/*
		 * Leave this one around, ok?
		if (statform) {
			FIf_delete(statform);
			statform = NULL;
		}
		*/
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

		percent = 0;
		show_all_plats = FALSE;

		if (!delform) {
		    sprintf(path, "%s/prod_a.form", MYSTUFFDIR);
		    sts = FIf_new(DELFORM, path,
				    deliver_note_a, &delform);
		    if (chkerror (sts, "creating form"))
			    return;
#ifdef XFORMS
		    Set_form_class(delform);
#endif
		    }

		if (!statform) {
		    sprintf(path, "%s/stat.form", MYSTUFFDIR);
		    sts = FIf_new(STATFORM, path,
				    stat_note, &statform);
		    if (chkerror (sts, "creating form"))
			    return;
#ifdef XFORMS
		    Set_form_class(statform);
#endif
		}

		if (!fsform) {
		    sprintf(path, "%s/fsavail.form", MYSTUFFDIR);
		    sts = FIf_new(FSFORM, path,
				    fs_note, &fsform);
		    if (chkerror (sts, "creating form"))
			    return;
#ifdef XFORMS
		    Set_form_class(fsform);
#endif
		}

		/* Unselect all products, and
		 * set all "selected in class" counts to 0
		 */
		multimenu = 0;
		unselect_products(header.flink, &header);
		for (curr_hdr = classheader.flink; curr_hdr != &classheader;
				    curr_hdr = curr_hdr->flink)
		    curr_hdr->pstat = 0;

		multimenu = 1;
		/* display classes and let user select one */
		if (!classform) {
		    sprintf(path, "%s/classes.form", MYSTUFFDIR);
		    sts = FIf_new(CLASSFORM, path,
				    class_form_note, &classform);
		    if (chkerror(sts, "creating classform"))
			    return;
#ifdef XFORMS
		    Set_form_class(classform);
#endif
		}

		for (curr_hdr = classheader.flink; curr_hdr != &classheader;
				    curr_hdr = curr_hdr->flink)
			if (curr_hdr->blocksize != 0)
				break;

		start = first(curr_hdr, &header);
		strcpy(deltitle, curr_hdr->prodclass);
		strcat(deltitle, ":");
		FIg_erase(delform, DEL_TITLE);
		FIg_set_text(delform, DEL_TITLE, deltitle);
		FIg_display(delform, DEL_TITLE);

		/* set up the forms */
		show_classes(classform);
		list_products(delform);
		FIg_set_justification(fsform, BLOCKS_FREE_1, FI_RIGHT_JUSTIFIED);
		FIg_set_justification(fsform, BLOCKS_FREE_2, FI_RIGHT_JUSTIFIED);
		show_filesystems(fsform);
		scroll_filesystems(fsform, (100*curr_fs)/num_fs);

		/* display the forms */
		FIf_is_displayed(delform, &dispstat);
		if (!dispstat) {
		    sts = FIf_display(delform);
		    if (chkerror (sts, "displaying form"))
			return;
		}

		/* display the classform and select the first class */
		sts = FIf_display(classform);
		if (chkerror (sts, "displaying classform"))
			return;
		FIfld_set_select(classform, CLASSES, 1, 0, TRUE);
		FIfld_set_select(classform, CLASSES, 1, 1, TRUE);
		FIfld_set_select(classform, CLASSES, 1, 2, TRUE);
		FIfld_set_active_row(classform, CLASSES, 1, 1);

		/* display the messagebox form */
		FIf_is_displayed(statform, &dispstat);
		if (!dispstat)
		{
		    sts = FIf_display(statform);
		    if (chkerror (sts, "displaying statform"))
			return;
		}

		/* display the file system form */
		FIf_is_displayed(fsform, &dispstat);
		if (!dispstat)
		{
		    sts = FIf_display(fsform);
		    if (chkerror (sts, "displaying fsform"))
			return;
		}
#ifdef SunOS_4
		/* If we're a Sun, then "/home" should be the
		 * default filesystem destination, if it's
		 * a mounted file system.  Find the
		 * button that corresponds to it and select it.
		 */
		if (strcmp("/home", GetMountPoint("/home")) == 0)
		{
		    FIg_get_text(fsform, FS1, fslabel[1]);
		    if (strcmp(fslabel[1], "/home") == 0) {
			FIg_set_state_on(fsform, FS1);
			fs_note(FSFORM, FS1, (double)1, fsform);
		    }
		    else {
			FIg_get_text(fsform, FS2, fslabel[2]);
			if (strcmp(fslabel[2], "/home") == 0) {
			    FIg_set_state_on(fsform, FS2);
			    fs_note(FSFORM, FS2, (double)1, fsform);
			}
			else {
			    /* Neither of the two buttons was labeled
			     * with "/home".  Find the entry and scroll
			     * the filesystems panel to it.
			     */
			    for (i = 0; (i < num_fs) && strcmp(fs_table[i].name, "/home"); i++)
				;

			    if (i < num_fs) {
				/* found it */
				scroll_filesystems(fsform, (100*i)/num_fs);
				FIg_set_state_on(fsform, FS1);
				fs_note(FSFORM, FS1, (double)1, fsform);
			    }
			}
		    }
		}
#endif /* SunOS_4 */
	    break;

	 case REMOTE_DEL:
		/* remove any old local forms */
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
		for (i = 0; i < 20; i++) {
		    if (multnameform[i]) {
			FIf_delete(multnameform[i]);
			multnameform[i] = NULL;
		    }
		}

		pack_mode = FALSE;
		show_all_plats = TRUE;

		/*
		 * Unselect all the products, and clear
		 * the "selected in class" counts to 0.
		 */
		multimenu=0;
		unselect_products(header.flink, &header);
		for (curr_hdr = classheader.flink; curr_hdr != &classheader;
				    curr_hdr = curr_hdr->flink)
		    curr_hdr->pstat = 0;

		if (!setupform) {
		    sprintf(path, "%s/setup.form", MYSTUFFDIR);
		    sts = FIf_new(SETUPFORM, path,
				setup_note, &setupform);
		    if (chkerror (sts, "creating form"))
			return;
#ifdef XFORMS
		    Set_form_class(setupform);
#endif
		}

		sts = FIf_display(setupform);
		if (chkerror (sts, "displaying form"))
			return;
		break;

	 case CHANGE_CONN:
		/* get rid of old forms */
		if (show_sel_form) {
			FIf_delete(show_sel_form);
			show_sel_form = NULL;
		}
		if (show_prod_form) {
			FIf_delete(show_prod_form);
			show_prod_form = NULL;
		}
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
		if (rem_delform) {
			FIf_delete(rem_delform);
			rem_delform = NULL;
		}
		if (timeform) {
			FIf_delete(timeform);
			timeform = NULL;
		}
		if (remoteform) {
			FIf_delete(remoteform);
			remoteform = NULL;
		}
		if (statform) {
			FIf_delete(statform);
			statform = NULL;
		}
		if (fsform) {
			FIf_delete(fsform);
			fsform = NULL;
		}
		if (revform) {
			FIf_delete(revform);
			revform = NULL;
		}
		if (timeform) {
			FIf_delete(timeform);
			timeform = NULL;
		}
		if (remoteform) {
			FIf_delete(remoteform);
			remoteform = NULL;
		}
		if (statform) {
			FIf_delete(statform);
			statform = NULL;
		}
		if (setupform) {
			FIf_delete(setupform);
			setupform = NULL;
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


		/* shut down the current connection */
		execute_info_script(ws_script, END, TRUE);
		execute_info_script(ws_beta_script, END, FALSE);
		unlink(ws_script);
		unlink(ws_beta_script);

		/* turn verbose and minus_x off so that messages will not display
		 * on the calling window
		 */
		verbose = 0;
		minus_x = 0;

		/* show the connection form */
		    sprintf(path, "%s/connect.form", MYSTUFFDIR);
		sts = FIf_new(CONNECTFORM, path,
				connect_note, &connform);
		if (chkerror (sts, "creating form"))
			exit(1);
#ifdef XFORMS
		Set_form_class(connform);
		if (!help_avail)
		    FIg_disable(connform, FI_HELP);
#endif

		/* erase the gadgets for network stuff */
		FIg_erase(connform, HOST_TEXT);
		FIg_erase(connform, LOCAL_TEXT);
		FIg_erase(connform, DEVICE_TEXT);
		FIg_erase(connform, HOST_FIELD);
		FIg_erase(connform, ACCT_TEXT);
		FIg_erase(connform, ACCT_FIELD);
		FIg_erase(connform, PASS_TEXT);
		FIg_erase(connform, PASS_FIELD);

		sts = FIf_display(connform);
		if (chkerror (sts, "displaying form"))
			exit(1);
	
		FIf_erase(fp);
		mainform = NULL;

		break;
	} /* switch */
}/* notification_routine */



/*ARGSUSED*/
review_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	int	row, pos, flag, len;
	char	sect[MAXLINE];
	char	search_word[MAXLINE];

	switch (g_label)
	{
	 case FI_CANCEL:
		FIf_delete(fp);
		revform = NULL;

		if (access("/tmp/README", 04) == 0)
		    unlink("/tmp/README");
		else if (access("/tmp/fixes.com", 04) == 0)
		    unlink("/tmp/fixes.com");

		if (delform)
			FIg_set_value(delform, REVIEW_PROD, (double)0);
		break;

	 case SECTIONS:
		FIfld_get_active_row(fp, SECTIONS, &row, &pos);
		FIfld_get_select(fp, SECTIONS, row, 0, &flag);

		if (!flag)
		{
			FIfld_set_select(fp, SECTIONS, row, 0, TRUE);
			return;
		} /* if */
	
		if (row == 0)   /* if the want the entire readme file */
		{
			entire_readme(fp);
			return;
		} /* if */

		FIfld_get_text_length(fp, SECTIONS, row, 0, &len);
		FIfld_get_text(fp, SECTIONS, row, 0, len, sect, &flag, &pos);

		find_section(fp, sect);
		break;

	 case SEARCH_PREV:
	 case SEARCH_NEXT:
	 case SEARCH_TEXT:
		FIg_get_text(fp, SEARCH_TEXT, search_word);

		if (search_word[0] == '\0')
			return;

		if (g_label == SEARCH_PREV)
			search_backward(fp, search_word);
		else
			search_forward(fp, search_word);

		break;

	 case SAVE_FILE:
		FIg_get_text(fp, SAVE_FILE, search_word);
		save_to_file(fp, search_word);
		break;
	} /* switch */
} /* review_note */





/*ARGSUSED*/
deliver_note_a(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{

	char	line[MAXLINE];
	char	name[PRODNAME_LEN];
	char	number[PRODNUM_LEN];
	char	uname[PRODNAME_LEN];
	int	sts, i, j;
	struct 	prodnode *pptr;
	int	auto_cnt;
	char	*uptr;
	int	row, pos, sel_flag, len, save_curr_fs;

	FIg_reset(statform, MESSBOX);
	mess_row = 0;

	switch (g_label)
	{
	 case ASCII_LIST:
		/* get the selected/unselected row */
		FIfld_get_active_row(fp, ASCII_LIST, &row, &pos);

		/* get the name */
		FIfld_get_text_length(fp, ASCII_LIST, row, 0, &len);
		FIfld_get_text(fp, ASCII_LIST, row, 0, len, name, &sel_flag, &pos);

		/* find out if the product is a multname product */
		FIfld_get_text(fp, ASCII_LIST, row, 6, 2, line, &sel_flag, &pos);
		if (atoi(line) == 1) {
			if (sel_flag) {
				/* set up the user pointer to indicate the
				 * selected row.
				 */
				uptr = (char *)calloc(1, 5);
				sprintf(uptr, "%d", row);
				FIf_set_user_pointer(fp, uptr);

				multname(name, -1);
			}
			else
				unsel_mult(name);
		}
		else {
		    /* get the number */
		    FIfld_get_text_length(fp, ASCII_LIST, row, 1, &len);
		    FIfld_get_text(fp, ASCII_LIST, row, 1, len, number, &sel_flag, &pos);
		
		    force_dest[0] = 0;
		    sts = set_selected_ascii(fp, name, number, sel_flag, TRUE);

		    if (!sts)  /* if selecting failed unselect it */
			for (i = 0; i <= 5; i++)
				FIfld_set_select(fp, ASCII_LIST, row, i, FALSE);
		    else if (sel_flag) {
			if (force_dest[0])
			    messprintf("Added %s to the %s delivery set.\n",
				    name, force_dest);
			else
			    messprintf("Added %s to the %s delivery set.\n",
				    name, fs_table[curr_fs].name);
		    }
		}
		break;

	 case AUTO_SEL:         /* automatic selection of products by version */

		auto_cnt = 0;
		save_curr_fs = curr_fs;  /* keep track of the current file sys */

		for (pptr = header.flink; pptr != &header; pptr = pptr->flink) {
		    if (pptr->pstat & NEEDS_UPDATING && pptr->arch & my_arch )  /* if needs updated */
		    {
				curr_fs = get_fs_number(pptr->loadeddir);
				set_selected_ascii(fp, pptr->prodname, 
				   pptr->prodnumber, TRUE, TRUE);
				auto_cnt++;
		    }
		}

		curr_fs = save_curr_fs;  /* set it back */
		
		if (auto_cnt == 0) 
		    FIfld_set_text(statform, MESSBOX, 0, 0, "No products need updating.", FALSE);
		else {
		   FIfld_set_text(statform, MESSBOX, 0, 0, "All products that need to be updated have been selected.", FALSE);
		   list_products(fp);
		}
		break;

	 case CURRENT_PROD:  /* they typed their own current product */
		FIg_reset(statform, MESSBOX);
		mess_row = 0;

		FIg_get_text(fp, CURRENT_PROD, name);
		cap_case(name);

		/* see if this is a multname product that is already diplayed */
		for (i = 0; i < 20; i++)
		{
			if (multnameform[i] == NULL)
				continue;
	
			FIf_get_user_pointer(multnameform[i], &uptr);

			j = 0;
			while (uptr[j++] != ' ') {}
			strcpy(uname, uptr);
			uname[j-1] = '\0';

			if (!(strcmp(uname, name)))
				return;
		} /* for */

		force_dest[0] = 0;
		sts = inq_product(fp, name, TRUE);  /* 2 = multiple products */
							/* 1 = just a product */
							/* 0 = not a product */
							/* 3 = not enough space */
							/* 4 = load key problem */

		if (sts == 2)
		{
			multname(name, -1);
			return;
		} 
		else if (sts == 0)   /* if it is not a product */
			messprintf("%s is not a deliverable product.", name);
		else if ((sts == 3) || (sts == 4))  /* not enough room or no load key */
			return;
		else
		{
		    if (force_dest[0])
			messprintf("Added %s to the %s delivery set.\n",
				name, force_dest);
		    else
			messprintf("Added %s to the %s delivery set.\n",
				name, fs_table[curr_fs].name);

		    if (revform)
			show_current(revform);
		} /* else */

		break;

	 case REVIEW_PROD:
		if (value)
		{
			if (current_product == NULL)
			{
				FIfld_set_text(statform, MESSBOX, 0, 0,
					"Select product to review", FALSE);
				FIg_set_value(fp, REVIEW_PROD, (double)0);
				return;
			} /* if */

			    sprintf(path, "%s/new_view.form", MYSTUFFDIR);
			sts = FIf_new(REVIEWFORM, path,
				review_note, &revform);
			if (chkerror (sts, "creating form"))
				return;
#ifdef XFORMS
			Set_form_class(revform);
#endif

			show_current(revform);

			sts = FIf_display(revform);
			if (chkerror (sts, "displaying form"))
				return;

		} /* if */
		else
		{
			FIf_delete(revform);
			revform = NULL;
		} /* else */
		break;

	 case DO_INSTALL:
		/* show the installation form */
		    sprintf(path, "%s/load.form", MYSTUFFDIR);
		sts = FIf_new(INSTALLFORM, path,
					install_note, &installform);
			if (chkerror (sts, "creating form"))
				exit(1);
#ifdef XFORMS
			Set_form_class(installform);
#endif
		/* display any previously defined values */
		FIg_set_value(installform, VERBOSE, (double)verbose);
		FIg_set_value(installform, DEFAULT, (double)takedefaults);
		FIg_set_value(installform, SHOW_SCRIPT, (double)minus_x);
		sts = FIf_display(installform);
		if (chkerror (sts, "displaying form"))
			exit(1);
		break;

	 case UNSEL_ALL:
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			if (pptr->pstat & SELECTED) {
				set_selected_ascii(fp, pptr->prodname, pptr->prodnumber,
					FALSE, TRUE);
				update_class(pptr);
			}

		list_products(fp);
		FIg_reset(fp, CURRENT_PROD);

		FIfld_set_text(statform, MESSBOX, 0, 0, "All products are unselected.", FALSE);
		break;
	} /* switch */
} /* deliver_note_a */






/*ARGSUSED*/
pack_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	char	line[MAXLINE];
	char	number[PRODNUM_LEN];
	int	sts, row, pos, len, flag, i;
	char	pack_name[MAXPROD], name[MAXPROD];
	char	defaults_file[MAXPATHLEN];
	char	**packagelist;
	char	**numberlist;
	int	counter;
	struct	prodnode *pptr;
/*	char	*calloc(); */
	struct 	prodnode **optionlist;
	int 	next_opt;

	FIg_reset(statform, MESSBOX);
	mess_row = 0;

	switch (g_label)
	{
	 case PK_PRODLIST:
		/* get the selected/unselected row */
		FIfld_get_active_row(fp, PK_PRODLIST, &row, &pos);

		/* get the name */
		FIfld_get_text_length(fp, PK_PRODLIST, row, 0, &len);
		FIfld_get_text(fp, PK_PRODLIST, row, 0, len, name, &flag, 
			&pos);

		/* get the number */
		FIfld_get_text_length(fp, PK_PRODLIST, row, 1, &len);
		FIfld_get_text(fp, PK_PRODLIST, row, 1, len, number, &flag, 
			&pos);
		
		sts = set_selected_ascii(fp, name, number, flag, FALSE);

		if (!sts)  /* if selecting failed unselect it */
			for (i = 0; i <= 5; i++)
				FIfld_set_select(fp, PK_PRODLIST, row, i, FALSE);
		break;

	 case PK_README:
		if (current_product == NULL)
		{
			FIfld_set_text(statform, MESSBOX, 0, 0,
				"Select product to review", FALSE);
			return;
		} /* if */


		sprintf(path, "%s/new_view.form", MYSTUFFDIR);
		sts = FIf_new(REVIEWFORM, path,
			review_note, &revform);
		if (chkerror (sts, "creating form"))
			return;
#ifdef XFORMS
		Set_form_class(revform);
#endif

		show_current(revform);

		sts = FIf_display(revform);
		if (chkerror (sts, "displaying form"))
			return;
		break;

	 case PK_CURRPROD:  /* they typed their own current product */
		FIg_reset(statform, MESSBOX);

		FIg_get_text(fp, PK_CURRPROD, pack_name);
		if (pack_name[0] != '\0') {
		    cap_case(pack_name);

		    if (!(inq_product(fp, pack_name, FALSE))) {   /* if it is not a product */
			sprintf(line, "%s is not a deliverable product", pack_name);
		        FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		    } else {
			sprintf(line, "selected the %s product", pack_name);
			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		    }
		}
		break;
	 
	 case PK_ADD:
		FIg_get_text(fp, PK_FIELD, pack_name);
		FIg_get_text(fp, PK_USEFILE, defaults_file);

		if (pack_name[0] == '\0') {
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Please enter the name of the package", FALSE);
			return;
		} /* if */

		/* make an array of products like optionlist */

		packagelist = (char **)calloc(header.blocksize, PRODNAME_LEN);
		numberlist = (char **)calloc(header.blocksize, PRODNUM_LEN);

		counter = 0;
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			if (pptr->pstat & SELECTED)
			{
				packagelist[counter] = pptr->prodname;
				numberlist[counter] = pptr->prodnumber;
				counter++;
			} /* if */


		if (counter == 0)
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Select the products that compromise the package", 
				FALSE);
		else
		{
			sts = make_pack(pack_name, packagelist, numberlist, 
				counter, defaults_file);
			show_packages(fp, PK_SEL); 

			if (sts)
			{
				FIg_enable(fp, PK_DEL);
				FIg_enable(fp, PK_EDIT);
				sprintf(line, "Created %s package\n", pack_name);
			}
			else
				sprintf(line, "Failed to create %s package\n", pack_name);

			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);

			FIfld_get_num_rows(fp, PK_SEL, &row);
			FIfld_set_select(fp, PK_SEL, row-1, pos, TRUE);
			FIfld_set_active_row(fp, PK_SEL, row-1, pos); 

			FIfld_set_text(fp, PK_FIELD, 0, 0, "", FALSE);
			FIfld_pos_cursor(fp, PK_FIELD, 0, 0, 0, 0, 0, 0); 
		} /* else */
		break;

	 case PK_DEL:
		FIfld_get_active_row(fp, PK_SEL, &row, &pos); 
		FIfld_get_text_length(fp, PK_SEL, row, 0, &len); 
		FIfld_get_text(fp, PK_SEL, row, 0, len, pack_name, &flag,
			&pos); 

		if (flag)
		{
			del_pack(fp, pack_name, TRUE);
			show_packages(fp, PK_SEL);
			FIfld_set_text(fp, PK_FIELD, 0, 0, "", FALSE);
			FIfld_pos_cursor(fp, PK_FIELD, 0, 0, 0, 0, 0, 0);
		} /* if */
		else
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Select the package to be deleted", FALSE);
		break;		

	 case PK_EDIT:
		FIfld_get_active_row(fp, PK_SEL, &row, &pos);
		FIfld_get_text_length(fp, PK_SEL, row, 0, &len);
		FIfld_get_text(fp, PK_SEL, row, 0, len, pack_name, &flag,
			&pos);

		FIg_get_text(fp, PK_USEFILE, defaults_file);

		if (!flag)
		{
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Select the package to be edited", FALSE);
			return;
		} /* if */

		packagelist = (char **)calloc(header.blocksize, PRODNAME_LEN);
		numberlist = (char **)calloc(header.blocksize, PRODNUM_LEN);

		counter = 0;
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			if (pptr->pstat & SELECTED)
			{
				packagelist[counter] = pptr->prodname;
				numberlist[counter] = pptr->prodnumber;
				counter++;
			} /* if */


		if (counter == 0)
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Select the products that compromise the package", 
				FALSE);
		else
		{
			del_pack(fp, pack_name, FALSE);
			sts = make_pack(pack_name, packagelist, numberlist,
				counter, defaults_file);
			show_packages(fp, PK_SEL); 

			if (sts)
				sprintf(line, "Saved changes to %s package\n", pack_name);
			else
				sprintf(line, "Failed to save changes to %s package\n", pack_name);

			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
			FIfld_get_num_rows(fp, PK_SEL, &row);
			FIfld_set_select(fp, PK_SEL, row-1, pos, TRUE);
			FIfld_set_active_row(fp, PK_SEL, row-1, pos); 
		} /* else */
		break;

	 case PK_SEL:
		FIfld_get_active_row(fp, PK_SEL, &row, &pos);
		FIfld_get_text_length(fp, PK_SEL, row, 0, &len);
		FIfld_get_text(fp, PK_SEL, row, 0, len, pack_name, &flag,
			&pos);

		/* first unselect all of the selected products */
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
		    if (pptr->pstat & SELECTED) {
			set_selected_ascii(fp, pptr->prodname, pptr->prodnumber,FALSE, FALSE);
			}

		get_package(fp, PK_PRODLIST, pack_name, TRUE, flag);   /* true = reset first */
		scroll_to_1st_selected(fp, PK_PRODLIST);

		FIfld_set_text(fp, PK_FIELD, 0, 0, pack_name, FALSE);
		FIg_enable(fp, PK_DEL);
		FIg_enable(fp, PK_EDIT);
		break;

	 case PK_RESET:
		/* unselect the products */
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			pptr->pstat &= ~SELECTED;
		list_products_2(fp, PK_PRODLIST);

		/* unselect the package */
		FIfld_get_active_row(fp, PK_SEL, &row, &pos);
		FIfld_set_select(fp, PK_SEL, row, 0, FALSE);

		FIg_reset(fp, PK_CURRPROD);
		FIg_reset(fp, PK_FIELD);
		FIfld_pos_cursor(fp, PK_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case PK_FIELD:   /* they entered a package name */
		/* if the name entered exists display the package */
		FIg_get_text(fp, PK_FIELD, pack_name);
		if (pack_name[0] == '\0')
			return;

		sts = FALSE;
		/* select the entered package if it exists and show its contents*/
		FIfld_get_num_rows(fp, PK_SEL, &row);
		for (i = 0; i < row; i++)
		{
			FIfld_get_text_length(fp, PK_SEL, i, 0, &len);
			FIfld_get_text(fp, PK_SEL, i, 0, len, name, &flag,
				&pos);
			if (!(strcmp(pack_name, name)))
			{
				FIfld_set_select(fp, PK_SEL, i, 0, TRUE);
				FIfld_set_active_row(fp, PK_SEL, i, pos);
				get_package(fp, PK_PRODLIST, pack_name, TRUE, TRUE);
				sts = TRUE;
			} /* if */
			else
				FIfld_set_select(fp, PK_SEL, i, 0, FALSE);
		} /* for */

		if (!sts)   /* they entered a package that does not exist */
		{
			FIg_disable(fp, PK_DEL);
			FIg_disable(fp, PK_EDIT);
		}
		else
		{
			FIg_enable(fp, PK_DEL);
			FIg_enable(fp, PK_EDIT);
		} /* else */
		break;
	
	 case PK_ANSWER:
		FIfld_get_active_row(fp, PK_SEL, &row, &pos);
		FIfld_get_text_length(fp, PK_SEL, row, 0, &len);
		FIfld_get_text(fp, PK_SEL, row, 0, len, pack_name, &flag,
			&pos);

		if (!flag) {
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Select the package for which to defaults are to be set", 
				FALSE);
			return;
		} /* if */

		optionlist = (struct prodnode **)malloc(sizeof (struct prodnode *) * header.blocksize);

		next_opt = 0;
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			if (pptr->pstat & SELECTED)  {
		    		optionlist[next_opt] = pptr;
		    		next_opt++;
			} /* if */

		/* do the preprocessing */	
		putenv("ANSWERS=/usr/tmp/.packans");
		act_on_products(optionlist, next_opt, PREPBASE);
		put_defaults_in_package(pack_name, "/usr/tmp/.packans");
		putenv("ANSWERS=\"\"");

		FIfld_set_text(statform, MESSBOX, 0, 0, "Preprocessing complete.", FALSE);
		break;
	} /* switch */
} /* pack_note */




/*ARGSUSED*/
remote_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	char	name[MAXHOST], pass[MAXHOST], platform[MAXHOST], fs[MAXHOST];
	char	line[MAXLINE];
	char	def_fs[DIR_LEN];
	int	sts;
	int	len, pos, flag, row, i, stat_row;

	switch (g_label)
	{
	 case MA_RESET:    /* unselect all of the machines */
		FIg_reset(fp, MA_FIELD);
		FIg_reset(fp, MA_FS);
		FIg_reset(fp, MA_PASS);
		FIg_reset(fp, MA_PLATFORM);
		FIg_reset(fp, MA_EXCEPT);
		FIg_reset(fp, MA_ADD);
		FIg_reset(fp, MA_DEL);

		FIg_enable(fp, MA_SEL);
		FIfld_get_num_rows(fp, MA_SEL, &row);
		for (i = 0; i < row; i++)
		{
			FIfld_set_select(fp, MA_SEL, i, 0, FALSE);
			FIfld_set_select(fp, MA_SEL, i, 1, FALSE);
			FIfld_set_select(fp, MA_SEL, i, 2, FALSE);
		}
		FIfld_pos_cursor(fp, MA_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case MA_ADD:
		FIg_reset(statform, MESSBOX);

		FIg_get_text(fp, MA_FIELD, name);
		if (name[0] == '\0') {
			FIfld_set_text(statform, MESSBOX, 0, 0,
			 "Please enter the name of the machine to be added", FALSE);
			return;
		}

		FIg_get_text(fp, MA_FS, def_fs);
		FIg_get_text(fp, MA_PASS, pass);
		FIg_get_text(fp, MA_PLATFORM, platform);

		if (def_fs[0] == '\0') {  /* being stubborn */
			strcpy(def_fs, "/usr");
			FIfld_set_text(fp, MA_FS, 0, 0, "/usr", FALSE);
		} /* if */

		if (platform == '\0') {
			strcpy(platform, "CLIPPER");
			FIfld_set_text(fp, MA_PLATFORM, 0, 0, "CLIPPER", FALSE);
		} else {
			sts = check_platform(platform);
			if (!sts) {
				FIfld_set_text(statform, MESSBOX, 0, 0,
					"Error: not a legal platform", FALSE);
				return;
			} else
				FIg_set_text(fp, MA_PLATFORM, platform);
		}
		
		if (name[0] != '\0')
		{
			/* do validation if they want it */
			if (validate_mode) {
				FIfld_set_text(statform, MESSBOX, 0, 0, 
					"Validating node/password combination...", FALSE);
				sts = validate(name, pass);
				if (!sts) {
					FIg_reset(statform, MESSBOX);
					stat_row = 0;
					FIfld_set_text(statform, MESSBOX, stat_row++, 0,
						"Invalid nodename/password combination", FALSE);
					FIfld_set_text(statform, MESSBOX, stat_row++, 0,
						"Remote machine will still be added", FALSE);
				}
			}

			FIfld_set_text(statform, MESSBOX, stat_row++, 0, "Adding...", FALSE);
			sts = add_remote(name, def_fs, pass, platform);
			save_except(fp, name, def_fs, pass, platform);

			if (!sts) {
				FIfld_set_text(statform, MESSBOX, stat_row++, 0,
					"Can not add node", FALSE);
				return;
			} else {
				sprintf(line, "Added remote node %s", name);
				FIfld_set_text(statform, MESSBOX, stat_row++, 0, line, FALSE);
			} /* else */

			show_remotes(fp, MA_SEL);

			FIfld_get_num_rows(fp, MA_SEL, &row);
			if (row > 9)
				FIfld_set_active_row(fp, MA_SEL, row-1, 8);

			FIg_reset(fp, MA_FIELD);
			FIfld_pos_cursor(fp, MA_FIELD, 0, 0, 0, 0, 0, 0);
		} else {
			FIg_reset(statform, MESSBOX);
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Specify nodename and default file system",
				FALSE);
		}
		break;

	 case MA_DEL:
		FIg_reset(statform, MESSBOX);

		FIg_get_text(fp, MA_FIELD, name);
		if (name[0] == '\0') {
			FIfld_set_text(statform, MESSBOX, 0, 0,
			  "Please select or enter a remote machine.", FALSE);
			return;
		}

		FIfld_set_text(statform, MESSBOX, 0, 0, "Working...", FALSE);
		sts = ma_delete(fp, name);


		show_remotes(fp, MA_SEL);		/* update forms */
		FIg_reset(statform, MESSBOX);
		
		if (!sts)
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Can not delete node(s)", FALSE);
		else {
			sprintf(line, "Deleted remote node %s", name);
			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		}

		FIg_reset(fp, MA_FIELD);
		FIg_enable(fp, MA_ADD);
		FIfld_pos_cursor(fp, MA_FIELD, 0, 0, 0, 0, 0, 0);
		break;
		
	 case MA_SEL:
		FIg_reset(statform, MESSBOX);

		/* get the row that they selected */
		FIfld_get_active_row(fp, MA_SEL, &row, &pos);
		FIfld_get_select(fp, MA_SEL, &row, 0, &flag);

		/* put the fs into the fs field */
		FIfld_get_text_length(fp, MA_SEL, row, 1, &len);
		FIfld_get_text(fp, MA_SEL, row, 1, len, name, &flag, &pos);
		FIfld_set_text(fp, MA_FS, 0, 0, name, FALSE);

		/* put the platform into the platform field */
		FIfld_get_text_length(fp, MA_SEL, row, 2, &len);
		FIfld_get_text(fp, MA_SEL, row, 2, len, name, &flag, &pos);
		FIfld_set_text(fp, MA_PLATFORM, 0, 0, name, FALSE);

		/* put the name of the machine into the name field */
		FIfld_get_text_length(fp, MA_SEL, row, 0, &len);
		FIfld_get_text(fp, MA_SEL, row, 0, len, name, &flag, &pos);
		FIfld_set_text(fp, MA_FIELD, 0, 0, name, FALSE);
		FIg_disable(fp, MA_FIELD);

		FIg_disable(fp, MA_ADD);
		FIg_enable(fp, MA_DEL);
		FIg_enable(fp, MA_EDIT);

		show_except(fp, name);
		FIfld_pos_cursor(fp, MA_EXCEPT, 0, 0, 0, 0, 0, 0);
		break;

	 case MA_EDIT:
		FIg_reset(statform, MESSBOX);

		FIg_get_text(fp, MA_FIELD, name);
		if (name[0] == '\0') {
			FIfld_set_text(statform, MESSBOX, 0, 0,
			 "Please select or enter the name of the machine to be edited",
			 FALSE);
			return;
		}

		FIg_get_text(fp, MA_FS, fs);
		FIg_get_text(fp, MA_PASS, pass);
		FIg_get_text(fp, MA_PLATFORM, platform);

		if (platform == '\0') {
			strcpy(platform, "CLIPPER");
			FIfld_set_text(fp, MA_PLATFORM, 0, 0, "CLIPPER", FALSE);
		} else {
			sts = check_platform(platform);
			if (!sts) {
				FIfld_set_text(statform, MESSBOX, 0, 0,
					"Error: not a legal platform", FALSE);
				return;
			} else
				FIg_set_text(fp, MA_PLATFORM, platform);
		}

		if (def_fs[0] == '\0') {  /* being stubborn */
		    if (strcmp(platform, "CLIPPER") == 0 ||
			strcmp(platform, "INTEL_SCO") == 0 ||
			strcmp(platform, "MIPS_IRIX") == 0 ||
			strcmp(platform, "RS6000") == 0) {
			strcpy(def_fs, "/usr");
			FIfld_set_text(fp, MA_FS, 0, 0, "/usr", FALSE);
		    }
		    else if (strcmp(platform, "SUN") == 0) {
			strcpy(def_fs, "/home");
			FIfld_set_text(fp, MA_FS, 0, 0, "/home", FALSE);
		    }
		    else if (strcmp(platform, "SPARC_SOLARIS") == 0) {
			strcpy(def_fs, "/opt/ingr");
			FIfld_set_text(fp, MA_FS, 0, 0, "/opt/ingr", FALSE);
		    }
		} /* if */

		save_except(fp, name, fs, pass, platform);
		show_remotes(fp, MA_SEL);

		FIfld_set_text(statform, MESSBOX, 0, 0, "Saved changes.", FALSE);

		FIg_enable(fp, MA_FIELD);
		FIg_enable(fp, MA_ADD);
		FIg_reset(fp, MA_FIELD);
		FIfld_pos_cursor(fp, MA_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case MA_FIELD:
		FIg_reset(statform, MESSBOX);
		FIg_get_text(fp, MA_FIELD, name);

		if (name[0] == '\0')
			return;

		sts = ma_select_name(fp, name);

		if (!sts) {       /* if it is a new entry */
			FIg_disable(fp, MA_DEL);
			FIg_disable(fp, MA_EDIT);
			return;
		} else
			scroll_to_1st_selected(fp, MA_SEL);

		show_except(fp, name);

		FIg_disable(fp, MA_FIELD);
		FIg_disable(fp, MA_ADD);
		FIg_enable(fp, MA_DEL);
		FIg_enable(fp, MA_EDIT);
		FIfld_pos_cursor(fp, MA_EXCEPT, 0, 0, 0, 0, 0, 0);
		break;

	 case MA_PLATFORM:
		FIg_get_text(fp, MA_PLATFORM, platform);
		if (platform == '\0') {
			strcpy(platform, "CLIPPER");
			FIfld_set_text(fp, MA_PLATFORM, 0, 0, "CLIPPER", FALSE);
		} else {
			sts = check_platform(platform);
			if (!sts) {
				FIfld_set_text(statform, MESSBOX, 0, 0,
					"Error: not a legal platform", FALSE);
				return;
			} else
				FIg_set_text(fp, MA_PLATFORM, platform);
		}
		break;

	  case MA_VALIDATE:
		validate_mode = (int)value;
		break;
	} /* switch */
} /* remote_note */




/*ARGSUSED*/
stat_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{

} /* stat_note */



/*ARGSUSED*/
install_note(f_label, g_label, val, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double val;	/* value of gadget */
Form fp;	/* form pointer    */

{
	double	value, preproc;
	int	i;
	int 	next_opt;
	struct 	prodnode *pptr, *new;
	struct 	prodnode **optionlist;

	switch (g_label) {
	 case FORGET_IT:
		FIf_delete(fp);
		installform = NULL;		
		break;

	 case LOAD_IT:
		/* get the values */
		FIg_get_value(fp, VERBOSE, &value);
		verbose = (short)value;

		FIg_get_value(fp, SHOW_SCRIPT, &value);
		minus_x = (short)value;

		FIg_get_value(fp, PREPROC, &preproc);

		FIg_get_value(fp, DEFAULT, &value);
		takedefaults = (short)value;

		/* make the to-be-installed array optionlist */
		
		optionlist = (struct prodnode **)malloc(sizeof (struct prodnode *) * header.blocksize);

		next_opt = 0;
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink) {
			if (pptr->pstat & SELECTED) 
			{
	    			optionlist[next_opt] = pptr;
				
				/* add new products to loaded list */
				if ((pptr->pstat & NEW) && (!preproc)) {
					new = (struct prodnode *)calloc(1, sizeof(struct prodnode));
					node_copy(new, optionlist[next_opt]);
					ins_prod_node(new, &loadedheader, 0); 
					strcpy(new->loadeddir, new->destfs);
					strcat(new->loadeddir, "/");
					strcat(new->loadeddir, new->unixdir);
				}

		    		next_opt++;
			} /* if */
		} /* for */

		/* do the preprocessing */	
		if (preproc)		/* if only preprocessing */
		{
			act_on_products(optionlist, next_opt, PREPBASE);
			FIf_delete(fp);
			installform = NULL;		
			return;
		}
			
		/* do the installation */	
		act_on_products(optionlist, next_opt, INSTALLBASE);

		/* reset the file system info */
		show_filesystems(fsform);
		scroll_filesystems(fsform, (100*curr_fs)/num_fs);

		/* unselect the products that loaded successfully */
		for (i = 0; i < next_opt; i++)
		{
			if (optionlist[i]->pstat & DOWNLOAD_OK) {
				set_selected_ascii(delform, 
					optionlist[i]->prodname, 
					optionlist[i]->prodnumber, FALSE, 
					TRUE);
			}
			update_class(optionlist[i]);
		} /* for */

		list_products(delform);
		FIg_reset(delform, CURRENT_PROD);
		FIf_delete(fp);
		installform = NULL;		
		break;
	}

} /* install_note */



/*ARGSUSED*/
fs_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	char	fsys[80];
	int	i;
	int	sts;

	switch(g_label) {
	 case FS_SCROLL:
		scroll_filesystems(fp, (int)value);
		break;

	 case FS1:
	 case FS2:
		/* get the name of the filesystem off of the button */
		FIg_get_text(fp, g_label, fsys);

		/* set the current file system */
		for (i = 0; i < num_fs; i++) {
			if (!(strcmp(fsys, fs_table[i].name))) {
				if (i != curr_fs) {   /* if the current fs is changing */
					fs_table[i].current_fs = TRUE;
					curr_fs = i;
				}
			}
			else
				fs_table[i].current_fs = FALSE;
		}

		/* update any visible forms */
		list_products(delform);

		if (show_sel_form)
			show_selected(show_sel_form, fs_table[curr_fs].name);
		else if (show_prod_form)
			show_fs(show_prod_form, fs_table[curr_fs].name);

		break;

	 case REVIEW_FS:
		/* make sure that the review_selected form is not up */
		if (show_sel_form) {
			FIf_delete(show_sel_form);
			show_sel_form = NULL;
			FIg_set_value(fp, REVIEW_SELECTED, (double)0);
		}

		if (show_prod_form)
			return;

		    sprintf(path, "%s/show_prod.form", MYSTUFFDIR);
		sts = FIf_new(SHOW_PRODS, path,
				show_prod_note, &show_prod_form);
		if (chkerror (sts, "creating form"))
			exit(1);
#ifdef XFORMS
		Set_form_class(show_prod_form);
#endif

		sts = FIf_display(show_prod_form);
		if (chkerror (sts, "displaying form"))
			exit(1);

		show_fs(show_prod_form, fs_table[curr_fs].name);
		break;

	 case REVIEW_SELECTED:
		/* make sure that the review_fs form is not up */
		if (show_prod_form) {
			FIf_delete(show_prod_form);
			show_prod_form = NULL;
			FIg_set_value(fp, REVIEW_FS, (double)0);
		}

		if (show_sel_form)
			return;

		    sprintf(path, "%s/show_sel.form", MYSTUFFDIR);
		sts = FIf_new(SHOW_SEL, path,
				show_prod_note, &show_sel_form);
		if (chkerror (sts, "creating form"))
			exit(1);

#ifdef XFORMS
		Set_form_class(show_sel_form);
#endif
		sts = FIf_display(show_sel_form);
		if (chkerror (sts, "displaying form"))
			exit(1);

		show_selected(show_sel_form, fs_table[curr_fs].name);
		break;

	 case REVIEW_AVAIL:
		if (show_sel_form) {
			FIf_delete(show_sel_form);
			show_sel_form = NULL;
		}

		if (show_prod_form) {
			FIf_delete(show_prod_form);
			show_prod_form = NULL;
		}
		break;
	}
} /* fs_note */


/*ARGSUSED*/
setup_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	int sts;
	char	line[MAXLINE];
	char	cmd[MAXLINE];
	char	tmp_file[MAXPATHLEN];
	char	month_text[5];
	FILE	*fileptr, *popen();
	struct 	prodnode *pptr;

	if (g_label != STEP6_EXECUTE) {
		/* erase any old remote form that may be displayed */
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
			FIf_erase(rem_delform);  /* we want to keep this info */
		}
		if (timeform) {
			FIf_delete(timeform);
			timeform = NULL;
		}
	}


	/* set up the statistics form */

	if (!rem_infoform) {
		    sprintf(path, "%s/rem_info.form", MYSTUFFDIR);
		sts = FIf_new(REM_INFOFORM, path,
				rem_info_note, &rem_infoform);
		if (chkerror (sts, "creating form"))
				return;
#ifdef XFORMS
		Set_form_class(rem_infoform);
#endif

	        sts = FIf_display(rem_infoform);
		if (chkerror (sts, "displaying form"))
				return;

		/* fill in remote info form */
		get_stats();	/* get the total values */
		FIfld_set_value(rem_infoform, INFO_MACH, 0, 0, 
			(double)(total_remotes), FALSE);
		FIfld_set_value(rem_infoform, INFO_GROUPS, 0, 0,
			(double)(total_groups), FALSE);
		FIfld_set_value(rem_infoform, INFO_PACK, 0, 0,
			(double)(total_packs), FALSE);

		FIfld_set_value(rem_infoform, INFO_SEL_MACH, 0, 0, 
			(double)0, FALSE);
		FIfld_set_value(rem_infoform, INFO_SEL_GROUPS, 0, 0,
			(double)0, FALSE);
		FIfld_set_value(rem_infoform, INFO_SEL_PACK, 0, 0,
			(double)0, FALSE);

		display_rem_date(rem_infoform);
	}

	if ((g_label == STEP1_MACHINES) || (g_label == STEP2_GROUPS) ||
	    (g_label == STEP3_PACKAGES)) {

		sel_remotes = 0;
		sel_groups  = 0;
		sel_packs   = 0;

		FIfld_set_value(rem_infoform, INFO_SEL_MACH, 0, 0, 
			(double)0, FALSE);
		FIfld_set_value(rem_infoform, INFO_SEL_GROUPS, 0, 0,
			(double)0, FALSE);
		FIfld_set_value(rem_infoform, INFO_SEL_PACK, 0, 0,
			(double)0, FALSE);

		if (rem_delform) {
			FIf_delete(rem_delform);
			rem_delform = NULL;
		}
	}

	switch(g_label) {
	 case STEP1_MACHINES:
		    sprintf(path, "%s/rem_mach.form", MYSTUFFDIR);
		sts = FIf_new(REMOTEFORM, path,
				remote_note, &remoteform);
		if (chkerror (sts, "creating form"))
			exit(1);
#ifdef XFORMS
		Set_form_class(remoteform);
#endif
		
		FIfld_set_num_rows(remoteform, MA_EXCEPT, 0);
		show_remotes(remoteform, MA_SEL);

		/* show the value of validate_mode */
		FIg_set_value(remoteform, MA_VALIDATE, (double)validate_mode);

		sts = FIf_display(remoteform);
		if (chkerror (sts, "displaying form"))
			exit(1);

		FIfld_pos_cursor(remoteform, MA_FIELD, 0, 0, 0, 0, 0, 0);
		break;
	 case STEP2_GROUPS:
		    sprintf(path, "%s/group.form", MYSTUFFDIR);
		sts = FIf_new(GROUPFORM, path,
				group_note, &groupform);
		if (chkerror (sts, "creating form"))
			exit(1);
#ifdef XFORMS
		Set_form_class(groupform);
#endif

		show_remotes(groupform, GROUP_MACH);
		show_groups(groupform, GROUP_SEL);

		sts = FIf_display(groupform);
		if (chkerror (sts, "displaying form"))
			exit(1);
		
		FIfld_pos_cursor(groupform, GROUP_FIELD, 0,0,0,0,0,0);
		break;
	 case STEP3_PACKAGES:
		    sprintf(path, "%s/pack.form", MYSTUFFDIR);
		sts = FIf_new(PACKFORM, path,
				pack_note, &packform);
		if (chkerror (sts, "creating form"))
			exit(1);
#ifdef XFORMS
		Set_form_class(packform);
#endif

		/* unselect the products and list them */
		for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
			if (pptr->pstat & SELECTED)
				set_selected_ascii(fp, pptr->prodname, pptr->prodnumber,
					FALSE, FALSE);
		list_products_2(packform, PK_PRODLIST);

		/* list the packages */
		show_packages(packform, PK_SEL);
		FIg_set_text(packform, PK_USEFILE, "/usr/ip32/.defaults");

		sts = FIf_display(packform);
		if (chkerror (sts, "displaying form"))
			exit(1);
		FIfld_pos_cursor(packform, PK_FIELD, 0, 0, 0, 0, 0, 0);
		break;
	 case STEP4_DELIVERY:
		if (!rem_delform) {
		    /* if the form has not been displayed before, fill it in */
		    sprintf(path, "%s/rem_del.form", MYSTUFFDIR);
			sts = FIf_new(REM_DELFORM, path,
					rem_del_note, &rem_delform);
			if (chkerror (sts, "creating form"))
				exit(1);
#ifdef XFORMS
		Set_form_class(rem_delform);
#endif

			show_packages(rem_delform, RD_PACKAGES);

			/* unselect the products and list them */
			for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
				if (pptr->pstat & SELECTED)
					set_selected_ascii(fp, pptr->prodname, pptr->prodnumber,
						FALSE, FALSE);

			list_products_2(rem_delform, RD_PRODUCTS);
			show_groups(rem_delform, RD_GROUPS);
			list_o_machines();
			show_remotes(rem_delform, RD_MACHINES);

			/* fill in max simultaneous deliveries field*/
			sprintf(line, "%d", max_simul_del);
			FIg_set_text(rem_delform, RD_SIMUL_DEL, line);
		}
		sts = FIf_display(rem_delform);
		if (chkerror (sts, "displaying form"))
		    exit(1);
		break;
	 case STEP5_TIME:
		    sprintf(path, "%s/time.form", MYSTUFFDIR);
		sts = FIf_new(TIMEFORM, path,
				time_note, &timeform);
		if (chkerror (sts, "creating form"))
			exit(1);
#ifdef XFORMS
		Set_form_class(timeform);
#endif

		/* Update gadgets on form for current date and time, but 
		 * disable them (since the "NOW" button is the default.
		 */

		get_time(timeform);
		get_date(timeform);

		FIg_disable(timeform, SD_GROUP);
		sd_group_enabled = 0;
		FIg_disable(timeform, ST_GROUP);
		st_group_enabled = 0;
		
		display_rem_date(rem_infoform);

		sts = FIf_display(timeform);
		if (chkerror (sts, "displaying form"))
			exit(1);		
		break;
	 case STEP6_EXECUTE:
		FIg_reset(statform, MESSBOX);
		messprintf("!!!ClEaR");
		messprintf("Working...");
		sts = expand();          /* make the linked lists */

		if (sts == 1)  /* make sure that they selected products and nodes */
		{
			FIg_reset(statform, MESSBOX);
			FIfld_set_text(statform, MESSBOX, 0, 0, "No products are selected",
				FALSE);
			return;
		}
		else if (sts == 2)
		{
			FIg_reset(statform, MESSBOX);
			FIfld_set_text(statform, MESSBOX, 0, 0, "No remote nodes are selected",
				FALSE);
			return;
		}

		if ((host[0] == '\0') || (acctnm[0] == '\0')) {
			/* if we are connected to a local directory - we need this info */
		    sprintf(path, "%s/prompt.form", MYSTUFFDIR);
			sts = FIf_new(PROMPTFORM, path,
					prompt_note, &promptform);
			if (chkerror (sts, "creating form"))
				exit(1);
#ifdef XFORMS
			Set_form_class(promptform);
#endif

	                /* put in the local node in the review only field */
			strcpy(host, un.nodename);
			FIg_set_text(promptform, PR_NODE, host);

			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Enter the needed information and then click", FALSE);
			FIfld_set_text(statform, MESSBOX, 1, 0,
				"on the \"Execute Delivery\" button", FALSE);

			sts = FIf_display(promptform);
			if (chkerror (sts, "displaying form"))
				exit(1);
			return;
		}

		strcpy(tmp_file, tempnam("/.vprod", (char *)NULL));
		make_rm_list(rem_delform, tmp_file);    /* make the remote commands file */
		if (when != NOW)
		{
		    strcpy(month_text, get_month2(month));
		    if (meridian)
		    {
			sprintf(cmd, "echo \"DATAFILE=%s; export DATAFILE; /usr/ip32/deltools/node/remote_newprod; rm \\$DATAFILE\" | at %02d:%02dpm %s %d 2>&1",
				tmp_file, hour, min, month_text, day);

			if (fileptr = popen(cmd, "r")) {
			    while (fgets(line, MAXLINE, fileptr))
				messprintf(line);
			    sts = pclose(fileptr);
			    if (sts >> 8)
				sprintf(line, "ERROR: execution of remote_newprod failed\n");
			    else
				sprintf(line, "Delivery will be made at %02d:%02dpm %02d-%02d-%02d\n",
				     hour, min, month, day, year%100);
			}
			else
			    sprintf(line, "ERROR: Could not spawn remote_newprod.\n");
		    }
		    else
		    {
			sprintf(cmd, "echo \"DATAFILE=%s; export DATAFILE; /usr/ip32/deltools/node/remote_newprod; rm \\$DATAFILE\" | at %02d:%02dam %s %d 2>&1",
				tmp_file, hour, min, month_text, day);

			if (fileptr = popen(cmd, "r")) {
			    while (fgets(line, MAXLINE, fileptr))
				messprintf(line);
			    sts = pclose(fileptr);
			    if (sts >> 8)
				sprintf(line, "ERROR: execution of remote_newprod failed\n");
			    else
				sprintf(line, "Delivery will be made at %02d:%02dam %02d-%02d-%02d\n",
				 hour, min, month, day, year%100);
			}
			else
			    sprintf(line, "ERROR: Could not spawn remote_newprod.\n");
		    }
		    FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		}
		else
		{
		    sprintf(cmd, "DATAFILE=%s; export DATAFILE; /usr/ip32/deltools/node/remote_newprod 2>&1",
			    tmp_file);
		    if (fileptr = popen(cmd, "r")) {
			while (fgets(line, MAXLINE, fileptr))
			    messprintf(line);
			sts = pclose(fileptr);
			if (sts >> 8)
			    messprintf("ERROR: execution of remote_newprod failed\n");
			else
			    messprintf("Remote delivery completed.");
		    }
		    else
			messprintf("ERROR: Could not spawn remote delivery.\n");

		    sprintf(cmd, "rm %s", tmp_file);
		    system(cmd);
		}

		/* reset the remote stats form */
		sel_remotes = 0;
		sel_groups  = 0;
		sel_packs   = 0;

		FIfld_set_value(rem_infoform, INFO_SEL_MACH, 0, 0, 
			(double)0, FALSE);
		FIfld_set_value(rem_infoform, INFO_SEL_GROUPS, 0, 0,
			(double)0, FALSE);
		FIfld_set_value(rem_infoform, INFO_SEL_PACK, 0, 0,
			(double)0, FALSE);
		break;
	}

	if (!statform) {
		    sprintf(path, "%s/stat.form", MYSTUFFDIR);
	    sts = FIf_new(STATFORM, path,
		    stat_note, &statform);
	    if (chkerror (sts, "creating form"))
		return;
#ifdef XFORMS
	    Set_form_class(statform);
#endif

	    sts = FIf_display(statform);
	    if (chkerror (sts, "displaying statform"))
		return;
	}


} /* setup_note */


/*ARGSUSED*/
group_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	char	name[MAXHOST], cmpline[MAXHOST];
	char	line[MAXLINE];
	int	sts;
	int	len, pos, flag, row, i;

	switch (g_label) {
	 case GROUP_FIELD:
                FIg_get_text(fp, GROUP_FIELD, name);

                if (name[0] == '\0')
                        return;

		/* select the group if the group_sel gadget */
		FIfld_get_num_rows(fp, GROUP_SEL, &row);
		for (i = 0; i<row; i++) {
			FIfld_get_text_length(fp, GROUP_SEL, i, 0, &len);
			FIfld_get_text(fp, GROUP_SEL, i, 0, len, cmpline,
				&flag, &pos);
			if (!(strcmp(cmpline, name))) {
				FIfld_set_select(fp, GROUP_SEL, i, 0, TRUE);
				FIfld_set_active_row(fp, GROUP_SEL, i, pos);
			}
		}


                sts = get_group(fp, name, GROUP_MACH, TRUE, TRUE);

                if (!sts)       /* if this group does not exist */
                {
                        FIg_disable(fp, GROUP_DEL);
                        FIg_disable(fp, GROUP_EDIT);
			sprintf(line, "Group %s is not defined", name);
			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
                } /* if */
                else
                {
                        FIg_enable(fp, GROUP_DEL);
                        FIg_enable(fp, GROUP_EDIT);
                }
		break;

	 case GROUP_SEL:
                FIfld_get_active_row(fp, GROUP_SEL, &row, &pos);
                FIfld_get_select(fp, GROUP_SEL, row, 0, &flag);

                FIfld_get_text_length(fp, GROUP_SEL, row, 0, &len);
                FIfld_get_text(fp, GROUP_SEL, row, 0, len, name, &flag,
                	&pos);

                get_group(fp, name, GROUP_MACH, TRUE, flag);
		scroll_to_1st_selected(fp, GROUP_MACH);
                FIfld_set_text(fp, GROUP_FIELD, 0, 0, name, FALSE);
                FIg_enable(fp, GROUP_DEL);
                FIg_enable(fp, GROUP_EDIT);

		if (!flag)
			FIg_reset(fp, GROUP_FIELD);
		break;

	 case GROUP_MACH:

		break;

	 case GROUP_ADD:
                FIg_reset(statform, MESSBOX);
                FIg_get_text(fp, GROUP_FIELD, name);

                if (name[0] == '\0')
                {
                        FIfld_set_text(statform, MESSBOX, 0, 0,
                                "Please enter then name of the group", FALSE);
                        return;
                } /* if */

                sts = add_group(fp, name);

                if (!sts)
                        sprintf(line, "Failed to create group: %s", name);
                else
                        sprintf(line, "Created group %s", name);

                FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);

                show_groups(fp, GROUP_SEL);

                FIg_enable(fp, GROUP_DEL);
                FIg_enable(fp, GROUP_EDIT);

                FIfld_get_num_rows(fp, GROUP_SEL, &row);
                if (row > 10)
                        FIfld_set_active_row(fp, GROUP_SEL, row-1, 9);

                FIg_reset(fp, GROUP_FIELD);
                FIfld_pos_cursor(fp, GROUP_FIELD, 0, 0, 0, 0, 0, 0);
		break;

	 case GROUP_DEL:
		FIg_reset(statform, MESSBOX);

		FIg_get_text(fp, GROUP_FIELD, name);

		FIfld_set_text(statform, MESSBOX, 0, 0, "Working...", FALSE);
		if (name[0] != '\0')
			sts = delete_group(fp, name);
		else
		{
			FIfld_get_active_row(fp, GROUP_SEL, &row, &pos);
			FIfld_get_select(fp, GROUP_SEL, row, 0, &flag);

			if (flag)
			{
				FIfld_get_text_length(fp, GROUP_SEL, row, 0, &len);
				FIfld_get_text(fp, GROUP_SEL, row, 0, len, name, &flag,
					&pos);

				sts = delete_group(fp, name);
			} /* if */
			else
			{
				FIfld_set_text(statform, MESSBOX, 0, 0, 
					"Please enter or select a group", FALSE);
				return;
			} /* else */
		} /* else */

		show_groups(fp, GROUP_SEL);
		FIg_reset(statform, MESSBOX);

		if (!sts)
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Can not delete group", FALSE);
		else
		{
			sprintf(line, "Deleted group %s", name);
			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		} /* else */

		break;

	 case GROUP_EDIT:
		FIg_reset(statform, MESSBOX);

		FIg_get_text(fp, GROUP_FIELD, name);

		if (name[0] != '\0')
			sts = delete_group(fp, name);
		else
		{
			FIfld_get_active_row(fp, GROUP_SEL, &row, &pos);
			FIfld_get_select(fp, GROUP_SEL, row, 0, &flag);

			if (flag)
			{
				FIfld_get_text_length(fp, GROUP_SEL, row, 0, &len);
				FIfld_get_text(fp, GROUP_SEL, row, 0, len, name, &flag,
					&pos);

				sts = delete_group(fp, name);
			} /* if */
			else
			{
				FIfld_set_text(statform, MESSBOX, 0, 0, 
					"Please enter or select a group", FALSE);
				return;
			} /* else */
		} /* else */

		sts = add_group(fp, name);

		show_groups(fp, GROUP_SEL);
		get_group(fp, name, GROUP_MACH, TRUE, TRUE);

		sprintf(line, "Saved changes to group %s", name);
		FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);		

		FIfld_get_num_rows(fp, GROUP_SEL, &row);
		FIfld_set_select(fp, GROUP_SEL, row-1, pos, TRUE);
		FIfld_set_active_row(fp, GROUP_SEL, row-1, pos); 

		break;

	 case GROUP_RESET:
		FIg_reset(fp, GROUP_FIELD);
		FIg_reset(fp, GROUP_ADD);
		FIg_reset(fp, GROUP_DEL);
		FIg_reset(fp, GROUP_EDIT);
		FIg_enable(fp, GROUP_SEL);

		/* unselect all of the machines */
		FIfld_get_num_rows(fp, GROUP_MACH, &row);
		for (i = 0; i < row; i++) {
			FIfld_set_select(fp, GROUP_MACH, i, 0, FALSE);
			FIfld_set_select(fp, GROUP_MACH, i, 1, FALSE);
			FIfld_set_select(fp, GROUP_MACH, i, 2, FALSE);
		}

		/* unselect the groups */
		FIfld_get_num_rows(fp, GROUP_SEL, &row);
		for (i = 0; i< row; i++) 
			FIfld_set_select(fp, GROUP_SEL, i, 0, FALSE);

		FIfld_pos_cursor(fp, GROUP_FIELD, 0, 0, 0, 0, 0, 0);
		break;
	} /* switch */
} /* group_note */



/*ARGSUSED*/
rem_info_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{

}

/*ARGSUSED*/
rem_del_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	int	row, pos, len, flag, i, sts;
	char	name[MAXPROD], number[16];
	char	pack_name[MAXPROD];
	char	group_name[MAXHOST];

	switch(g_label) {
	 case RD_PACKAGES:
		FIfld_get_active_row(fp, RD_PACKAGES, &row, &pos);
		FIfld_get_text_length(fp, RD_PACKAGES, row, 0, &len);
		FIfld_get_text(fp, RD_PACKAGES, row, 0, len, pack_name, &flag,
			&pos);

		get_package(fp, RD_PRODUCTS, pack_name, TRUE, flag);   /* true = reset fist */
		scroll_to_1st_selected(fp, RD_PRODUCTS);		

		if (flag)
			sel_packs++;
		else
			sel_packs--;
		FIfld_set_value(rem_infoform, INFO_SEL_PACK, 0, 0,
			(double)(sel_packs), FALSE);
		break;

	 case RD_PRODUCTS:
		/* get the selected/unselected row */
		FIfld_get_active_row(fp, RD_PRODUCTS, &row, &pos);

		/* get the name */
		FIfld_get_text_length(fp, RD_PRODUCTS, row, 0, &len);
		FIfld_get_text(fp, RD_PRODUCTS, row, 0, len, name, &flag, 
			&pos);

		/* get the number */
		FIfld_get_text_length(fp, RD_PRODUCTS, row, 1, &len);
		FIfld_get_text(fp, RD_PRODUCTS, row, 1, len, number, &flag, 
			&pos);
		
		sts = set_selected_ascii(fp, name, number, flag, FALSE);

		if (!sts)  /* if selecting failed unselect it */
		    for (i = 0; i <= 5; i++)
			FIfld_set_select(fp, RD_PRODUCTS, row, i, FALSE);

		break;

	 case RD_GROUPS:
                FIfld_get_active_row(fp, RD_GROUPS, &row, &pos);
                FIfld_get_select(fp, RD_GROUPS, row, 0, &flag);

                FIfld_get_text_length(fp, RD_GROUPS, row, 0, &len);
                FIfld_get_text(fp, RD_GROUPS, row, 0, len, group_name, 
			&flag, &pos);

                get_group(fp, group_name, RD_MACHINES, FALSE, flag);
		select_group_members(fp, group_name, TRUE);
		scroll_to_1st_selected(fp, RD_MACHINES);

		if (flag)
			sel_groups++;
		else
			sel_groups--;
		FIfld_set_value(rem_infoform, INFO_SEL_GROUPS, 0, 0,
			(double)(sel_groups), FALSE);

		/* now find out how many machines are selected */
		sel_remotes=0;
		FIfld_get_num_rows(fp, RD_MACHINES, &row);
		for (i = 0; i<row; i++) {
			FIfld_get_select(fp, RD_MACHINES, i, 0, &flag);
			if (flag)
				sel_remotes++;
		}
		FIfld_set_value(rem_infoform, INFO_SEL_MACH, 0, 0,
			(double)(sel_remotes), FALSE);
		break;

	 case RD_MACHINES:
		/* get the selected/unselected row */
		FIfld_get_active_row(fp, RD_MACHINES, &row, &pos);

		/* get the name */
		FIfld_get_text_length(fp, RD_MACHINES, row, 0, &len);
		FIfld_get_text(fp, RD_MACHINES, row, 0, len, name, &flag, 
			&pos);

		select_single_machine(fp, name, (double)flag);

		if (flag)
			sel_remotes++;
		else
			sel_remotes--;
		FIfld_set_value(rem_infoform, INFO_SEL_MACH, 0, 0,
			(double)(sel_remotes), FALSE);
		break;
	
	case RD_SIMUL_DEL:  /* number of simultaneous deliveries - MAX keyword */
		/* get the text */
		FIg_get_text(fp, RD_SIMUL_DEL, name);

		if (name[0] == '\0') {
			sprintf(name, "%d", max_simul_del);
			FIg_set_text(fp, RD_SIMUL_DEL, name);
		}

		max_simul_del = atoi(name);

		if (max_simul_del <= 0) {
			max_simul_del = MAX_DEF;
			sprintf(name, "%d", max_simul_del);
			FIg_set_text(fp, RD_SIMUL_DEL, name);
		}
		break;
	}
}


/*ARGSUSED*/
prompt_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
	switch (g_label) {
	 case FI_ACCEPT:
		FIg_get_text(fp, PR_NODE, host);
		FIg_get_text(fp, PR_ACCT, acctnm);
		FIg_get_text(fp, PR_PASS, pass);

		FIf_delete(fp);
		promptform = NULL;
		break;
	} /* switch */
} /* prompt_note */
