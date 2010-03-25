#include "main.h"

#define TOTAL_COMPARE	6

extern	short	srcmedia;

extern	char hostname[];
extern	char acctname[];
extern	char tapecmd[];
extern	char localcmd[];
extern	int	xcoll;
extern	int	ycoll;

extern  char	*def_file;


char	*compare[TOTAL_COMPARE] = {"host", "acct", 
		"tape", "local", "xcoll", "ycoll"};


read_def()

/***************************************************************************/
/* this routine reads the defaults from the vprod.def file                 */
/***************************************************************************/

{
	FILE	*of, *fopen();
	char	line[MAXLINE];
	int	i, found;
	char	xtext[5], ytext[5];

	if (NULL == (of = fopen(def_file, "r")))
		return;

	while (fgets(line, MAXLINE, of))
	{
		line[strlen(line)-1] = '\0';
		
		i = 0;
		found = FALSE;
		while ((i < TOTAL_COMPARE) && (!found))
			if (!(strncmp(line, compare[i], strlen(compare[i]))))
				found = TRUE;
			else
				i++;

		if (!found)
			continue;

		switch(i)
		{
		 case 0:  /* host */
			strncpy(hostname, line+5, MAXHOST);
			break;

		 case 1:   /* acct */
			strncpy(acctname, line+5, MAXACCT);
			break;

		  case 2:  /* cmd for tape */
			strncpy(tapecmd, line+5, MAXHOST);
			break;

		  case 3:  /* local dir */
			strncpy(localcmd, line+6, MAXHOST);
			break;

		  case 4:	/* xcoll */
			strncpy(xtext, line+6, 4);
			xcoll = atoi(xtext);
			break;

		  case 5:       /* ycoll */
			strncpy(ytext, line+6, 4);
			ycoll = atoi(ytext);
			break;
		} /* switch */

	} /* while */

	fclose(of);
} /* read_rc */


write_def(form)

Form form;

/*****************************************************************************/
/* this routine writes the current setup into the defaults file vftp.rc      */
/*****************************************************************************/

{
	char	dir[MAXLINE];
	FILE	*of, *fopen();
	int	made_dir=FALSE;

	/* check for the /.vprod directory */
	if (system("test -d /.vprod"))
	{
		mkdir("/.vprod", 0700);
		made_dir=TRUE;
	} /* if */	

	/* open the vprod.def file for writing */

	if (NULL == (of = fopen(def_file, "a")))
		return;

	/* write the setup to the file */

	/*get hostname text */
	if (srcmedia == TAPE)
		FIg_get_text(form, HOST_FIELD, tapecmd);
	else if (srcmedia == LOCAL_DIR)
		FIg_get_text(form, HOST_FIELD, localcmd);
	else if ((srcmedia == NETWORK) || (srcmedia == NETCDROM))
	{
		FIg_get_text(form, HOST_FIELD, hostname);		
		FIg_get_text(form, ACCT_FIELD, acctname);
	} /* else */

	sprintf(dir, "tape=%s\n", tapecmd);
	fputs(dir, of);

	sprintf(dir, "local=%s\n", localcmd);
	fputs(dir, of);

	sprintf(dir, "host=%s\n", hostname);
	fputs(dir, of);

	sprintf(dir, "acct=%s\n", acctname);
	fputs(dir, of);

	fclose(of);
} /* write_rc */



write_coll()

/****************************************************************************/
/* this routine writes the collapse position of the vprod.form window to    */
/* defaults file                                                            */
/****************************************************************************/

{
	FILE	*of, *fopen();
	int	made_dir=FALSE;
	char	xtext[30], ytext[30];


	/* check for the /.vprod directory */
	if (system("test -d /.vprod"))
	{
		mkdir("/.vprod", 0700);
		made_dir=TRUE;
	} /* if */	

	/* open the vprod.def file for writing */

	if (NULL == (of = fopen(def_file, "a")))
		return;

	/* write the setup to the file */

	sprintf(xtext, "xcoll=%d\n", xcoll);
	sprintf(ytext, "ycoll=%d\n", ycoll);

	fputs(xtext, of);
	fputs(ytext, of);

	fclose(of);
} /* write_coll */
