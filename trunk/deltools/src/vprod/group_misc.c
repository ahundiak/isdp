#include "main.h"
#include "defs.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <netdb.h>
#include "req.h"
#include <sys/types.h>
#include <fcntl.h>
#include <ctype.h>
#include <termio.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "dipdef.h"

#define LONGLINE 2048

/*
 *  This module contains routines that are used to manipulate the
 *  remote machine definition and group form.
 *
 *  add_remote      adds a machine with a given node name and file system.
 *  show_remotes    displays the defined remote machines in a field gadget.
 *  ma_select_name  selects the given name in a field
 *  ma_delete       deletes the specified machine
 *  save_except     saves exceptions to the machines file
 *  show_except     displays the existing exceptions for a machine.
 *  make_remote_changes  if a machine is changed - change it in the groups file.
 *  add_group       adds a group when given the name of the group.
 *  show_groups	    displays the defined groups in a field gadget.
 *  get_group       finds the named group and selects it
 *  delete_group       deletes the named group from the groups file.
 *  select_group_members  marks the members of the group selected
 *  select_single_machine sets the selected value for the single machine.
 *  check_platform  makes sure that the entered platform is valid - upper caseses it
 *  ma_multi_select
 *  list_o_machines  puts the existing machines into a linked list
 *  get_stats	   gets the total number of remotes, groups, and packages
 *  validate	    validates the node and root password
 */

extern	Form	remoteform;
extern  Form	rem_delform;
extern  Form	statform;
extern  Form	rem_infoform;
extern  int	verbose;
extern  int	sk;
extern  int	xfersize;
extern  REQUEST *request;
extern  REPLY   *reply;
extern  int	nettype;


char	*encrypted_key;

extern	char	*my_crypt();

extern char *cpu_types[];

int	total_groups=0;
int	total_remotes=0;
extern int total_packs;

struct group_node *galloc()
{
	return((struct group_node *) malloc(sizeof(struct group_node)));
}

struct group_node	*group_header = NULL;


struct remote_node *ralloc()
{
	return((struct remote_node *) malloc(sizeof(struct remote_node)));
}


int add_remote(name, fs, pass, platform)

char	*name;
char	*fs;
char	*pass;
char	*platform;

/***************************************************************************/
/* this routine saves all of the machines that have been defined in a file */
/***************************************************************************/

{
	FILE 	*of, *fopen();
	char	line[LONGLINE], cmpline[512];
	static char	str[LONGLINE];

	/* check for the /.vprod directory */
	if (system("test -d /.vprod"))
		mkdir("/.vprod", 0700);

	/* check for duplicate node name in the file */
	if (NULL != (of = fopen("/.vprod/machines", "r")))
	{
		sprintf(cmpline, "NODENAME=%s", name);
		while (fgets(line, LONGLINE, of))
		{
			line[strlen(line) - 1] = '\0';
			if (!(strcmp(line, cmpline)))
			{
				fclose(of);
				return(FALSE);
			} /* if */
		} /* while */
		fclose(of);
	} /* if */

	if (NULL == (of = fopen("/.vprod/machines", "a")))
		return(FALSE);
	chmod("/.vprod/machines", 0600);

	str[0] = '\0';
	if (pass[0] != '\0')
		strcpy(str, my_crypt(pass));

	sprintf(line, "NODENAME=%s\nDEFAULT_FS=%s\nRPW=%s\nPLATFORM=%s\n", name,
		fs, str, platform);

	fputs(line, of);
	fclose(of);

	total_remotes++;
	FIfld_set_value(rem_infoform, INFO_MACH, 0, 0,
		(double)(total_remotes), FALSE);
	return(TRUE);
} /* add_remote */



show_remotes(fp, g_label)

Form	fp;
int	g_label;

/****************************************************************************/
/* this routine reads the file of remote machines and displays them         */
/****************************************************************************/

{
	FILE	*of, *fopen();
	char	line[LONGLINE], node[LONGLINE];
	int	i, row;

	if (NULL == (of = fopen("/.vprod/machines", "r")))
		return;

	FIg_reset(fp, g_label);

	row = 0;
	while (fgets(line, LONGLINE, of))
	{
		line[strlen(line)-1] = '\0';
	
		/* seperate node name and NODENAME tag */
		i = 0;
		while ((line[i] != '=') && (line[i] != '\0'))
			i++;
		strcpy(node, line+i+1);
		line[i] = '\0';

		if (!(strcmp(line, "NODENAME")))
			FIfld_set_text(fp, g_label, row, 0, node, FALSE);
		else if (!(strcmp(line, "DEFAULT_FS")))
			FIfld_set_text(fp, g_label, row, 1, node, FALSE);
		else if (!(strcmp(line, "PLATFORM")))
			FIfld_set_text(fp, g_label, row++, 2, node, FALSE);
	} /* while */
	total_remotes=row;
	FIfld_set_value(rem_infoform, INFO_MACH, 0, 0,
		(double)(total_remotes), FALSE);
	fclose(of);
} /* show_remotes */



int
list_o_machines()

/****************************************************************************/
/* this routine reads the file of remote machines and puts them into the    */
/* linked list of machines. Originated from machines_on_buttons             */
/****************************************************************************/

{

	FILE	*of, *fopen();
	char	line[LONGLINE], node[MAXHOST];
	int	found, i, node_count;
	struct group_node *curr_group;
	struct remote_node *curr_node;

	if (NULL == (of = fopen("/.vprod/groups", "r")))
		return(-1);

	found = FALSE;
	node_count = 0;

	group_header = NULL;

	group_header = galloc();
	group_header->groupname[0] = '\0';
	group_header->selected = FALSE;
	group_header->members = NULL;
	group_header->num_members = 0;
	group_header->next = NULL;
	curr_group = group_header;

       /* get the nodes out of the group file */
	while (fgets(line, LONGLINE, of)) {
	    if (!found) {   /* if we have not found the beginning of a group */
		if (!(strncmp(line, "#begin_group", strlen("#begin_group")))) {
		    line[strlen(line) - 1] = '\0';
		    found = TRUE;
		    if (group_header->groupname[0]  == '\0') {
			strcpy(group_header->groupname, line+13);
			group_header->num_members  = 0;
		    } else {
			curr_group->next = galloc();
			curr_group = curr_group->next;
			strcpy(curr_group->groupname, line+13);
			curr_group->selected = FALSE;
			curr_group->num_members = 0;
		    }
		    curr_group->members = NULL;
		    curr_group->next = NULL;
		} /* if */
	    } else  { /* if we have are in a group */
		if (!(strncmp(line, "#end_group", strlen("#end_group")))) {
		    found = FALSE;
		} else if (!(strncmp(line, "NODENAME=", strlen("NODENAME=")))) {
		    /* look for a member */
		    i=0;
		    while (line[i++] != '=') {}
		    strcpy(node, line+i);
		    node[strlen(node) -1] = '\0';
			
		    if (curr_group->members == NULL) {
			curr_node = ralloc();
			curr_group->members = curr_node;
		    } else {
			curr_node->next = ralloc();
			curr_node = curr_node->next;
		    } /* if */

		    curr_group->num_members++;
		    strcpy(curr_node->nodename, node);
		    curr_node->selected = FALSE;
		    curr_node->next = NULL;
		    node_count++;
		} /* else if */
	    } /* else */
	} /* while */
	fclose(of);

	/*
	 * Now make a "catch-all" group with all machines.
	 * Go into machines file and get stuff out of it.
	 */
	if (node_count) {
	    curr_group->next = galloc();
	    curr_group = curr_group->next;
	    curr_group->groupname[0] = '\0';
	    curr_group->selected = FALSE;
	    curr_group->members = NULL;
	    curr_group->num_members = 0;
	    curr_group->next = NULL;
	}
	    
	if (NULL == (of = fopen("/.vprod/machines", "r")))
	    return(-1);
	while (fgets(line, LONGLINE, of)) {
	    if (!strncmp(line, "NODENAME=", strlen("NODENAME="))) {
		/* look for a member */
		i=0;
		while (line[i++] != '=') {}
		strcpy(node, line+i);
		node[strlen(node) -1] = '\0';
		    
		if (curr_group->members == NULL) {
		    curr_node = ralloc();
		    curr_group->members = curr_node;
		} else {
		    curr_node->next = ralloc();
		    curr_node = curr_node->next;
		} /* if */

		curr_group->num_members++;
		strcpy(curr_node->nodename, node);
		curr_node->selected = FALSE;
		curr_node->next = NULL;
	    }    
	}
	fclose(of);

	return(0);
} /* list_o_machines */




int
ma_select_name(fp, name)

Form	fp;
char	*name;

/*****************************************************************************/
/* this routine finds the entered name in the field gadet and selects it     */
/* it unselects all other rows                                               */
/*****************************************************************************/

{
	int	j, i, row, flag, pos, len;
	char	tmp[MAXHOST], line[LONGLINE];

	FIfld_get_num_rows(fp, MA_SEL, &row);

	/* look for the name in the list */
	j = FALSE;
	for (i = 0; i < row; i++)
	{
	    FIfld_get_text_length(fp, MA_SEL, i, 0, &len);
	    FIfld_get_text(fp, MA_SEL, i, 0, len, tmp, &flag, &pos);

	    if (!(strcmp(name, tmp)))  /* if they are same */
	    {
		FIfld_set_select(fp, MA_SEL, i, 0, TRUE);
		FIfld_set_select(fp, MA_SEL, i, 1, TRUE);
		FIfld_set_select(fp, MA_SEL, i, 2, TRUE);

		FIfld_get_text_length(fp, MA_SEL, i, 1, &len);
		FIfld_get_text(fp, MA_SEL, i, 1, len, tmp, &flag, &pos);
		FIfld_set_text(fp, MA_FS, 0, 0, tmp, FALSE);

		FIfld_get_text_length(fp, MA_SEL, i, 2, &len);
		FIfld_get_text(fp, MA_SEL, i, 2, len, tmp, &flag, &pos);
		FIfld_set_text(fp, MA_PLATFORM, 0, 0, tmp, FALSE);

		j = TRUE;
		break;
	    } /* if */
	} /* for */

	if (!j)   /* if it was not found */
	{
	    sprintf(line, "Machine %s is not defined", name);
	    FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
	} /* if */
	return(j);
} /* ma_select_name */



/*ARGSUSED*/
int ma_delete(fp, name)

Form	fp;
char	*name;

/*****************************************************************************/
/* this routine deletes the machine named name from the machines file        */
/* and all references to it in the groups file                               */
/* calling show_remotes is the responsibility of the calling routine         */
/*****************************************************************************/

{
	FILE 	*of1, *of2, *fopen();
	char	line[LONGLINE], cmpline[512];
	int	found, pass;

	for (pass = 0; pass < 2; pass++)
	{
	    if (pass == 0)
	    {
		if (NULL == (of1 = fopen("/.vprod/machines", "r")))
		    return(FALSE);

		if (NULL == (of2 = fopen("/.vprod/.vma", "w")))
		{
		    fclose(of1);
		    return(FALSE);
		} /* if */
		chmod("/.vprod/.vma", 0600);
	    } /* if */
	    else
	    {
		if (NULL == (of1 = fopen("/.vprod/groups", "r")))
		    return(TRUE);

		if (NULL == (of2 = fopen("/.vprod/.vgrp", "w"))) {
		    fclose(of1);
		    return(TRUE);
		} /* if */
		chmod("/.vprod/.vgrp", 0600);
	    } /* else */

	    found = FALSE;
	    while (fgets(line, LONGLINE, of1)) {
		if ((!(strncmp(line, "NODENAME", strlen("NODENAME"))))
		   || (!(strncmp(line, "#end_group", strlen("#end_group")))))
		    found = FALSE;

		sprintf(cmpline, "NODENAME=%s", name);
		if(!(strncmp(line, cmpline, strlen(cmpline))))
		    found = TRUE;

		if (!found)
		    fputs(line, of2);
	    } /* while */

	    fclose(of1);
	    fclose(of2);

	    if (pass == 0)
	    {
		system("mv /.vprod/.vma /.vprod/machines");
		chmod("/.vprod/machines", 0600);
	    }
	    else
	    {
		system("mv /.vprod/.vgrp /.vprod/groups");
		chmod("/.vprod/groups", 0600);
	    }
	} /* for */
	total_remotes--;
	FIfld_set_value(rem_infoform, INFO_MACH, 0, 0,
		(double)(total_remotes), FALSE);
	return(TRUE);
} /* ma_delete */



save_except(fp, name, newfs, pass, platform)

Form	fp;
char	*name;
char	*newfs;
char	*pass;
char	*platform;

/*****************************************************************************/
/* this routine reads the execptions field gadget and saves that info into   */
/* the file for machine name                                                 */
/*****************************************************************************/

{
	int	row, i, len, flag, pos;
	char	prod[PRODNAME_LEN], fs[MAXHOST];
	FILE	*of1, *of2, *fopen();
	char	line[LONGLINE], cmpline[512];

	FIfld_get_num_rows(fp, MA_EXCEPT, &row);
	if (row == 0)   /* if there aren't any exceptions - don't do all this */
	    return(FALSE);

	/* open the machine file and a temp file */
	if (NULL == (of1 = fopen("/.vprod/machines", "r")))
	    return(FALSE);

	if (NULL == (of2 = fopen("/.vprod/.vma", "w")))
	{
	    fclose(of1);
	    return(FALSE);
	} /* if */
	chmod("/.vprod/.vma", 0600);

	/* moves stuff over from file1 to file2 until name is found */
	while (fgets(line, LONGLINE, of1))
	{
	    sprintf(cmpline, "NODENAME=%s", name);
	    if(!(strncmp(line, cmpline, strlen(cmpline))))
	    {
		fputs(line, of2);     /* write the node name to file2 */
	    
		if (fgets(line, LONGLINE, of1))  /* put in new default fs */
		{
		    if (newfs[0] != '\0')
			sprintf(line, "DEFAULT_FS=%s\n", newfs);
		    fputs(line, of2);
		} /* if */

		if (fgets(line, LONGLINE, of1))  /* put in new  password */
		{
		    if (pass[0] == '\0')
			    sprintf(line, "RPW=%s\n", pass);
		    else
			    sprintf(line, "RPW=%s\n", my_crypt(pass));

		    fputs(line, of2);
		} /* if */

		if (fgets(line, LONGLINE, of1))  /* put in new platform */
		{
		    if (platform[0] != '\0')
			sprintf(line, "PLATFORM=%s\n", platform);
		    fputs(line, of2);
		} /* if */
		break;
	    } /* if */
	    else
		fputs(line, of2);
	} /* while */

	/* put the exceptions in file 2 now */
	for (i = 0; i < row; i++)
	{
	    FIfld_get_text_length(fp, MA_EXCEPT, i, 0, &len);
	    FIfld_get_text(fp, MA_EXCEPT, i, 0, len, prod, &flag, &pos);

	    FIfld_get_text_length(fp, MA_EXCEPT, i, 1, &len);
	    FIfld_get_text(fp, MA_EXCEPT, i, 1, len, fs, &flag, &pos);

	    if ((prod[0] == '\0') || (fs[0] == '\0'))
		continue;

	    cap_case(prod);
	    sprintf(cmpline, "EXCEPTION %s=%s\n", prod, fs);
	    fputs(cmpline, of2);
	} /* for */

	/* jump over old exception definitions */
	while (fgets(line, LONGLINE, of1))
	    if (strncmp(line, "EXCEPTION", strlen("EXCEPTION")))
	    {
		fputs(line, of2);
		break;
	    } /* if */

	/* finish putting file1 into file2 */
	while (fgets(line, LONGLINE, of1))
	    fputs(line, of2);

	fclose(of1);
	fclose(of2);

	system("mv /.vprod/.vma /.vprod/machines");
	chmod("/.vprod/machines", 0600);
/*	sprintf(line, "Saved changes for remote node %s", name);
	FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE); */
	return(TRUE);
} /* save_except */


show_except(fp, name)

Form	fp;
char	*name;

/****************************************************************************/
/* this routine puts the existing exceptions on the form for the machine    */
/* name                                                                     */
/****************************************************************************/

{
	FILE	*of, *fopen();
	char	line[LONGLINE], cmpline[512];
	int	i, row;

	FIg_reset(fp, MA_EXCEPT);

	/* find the machine in the file */
	if (NULL == (of = fopen("/.vprod/machines", "r")))
	    return;

	while (fgets(line, LONGLINE, of))
	{
	    sprintf(cmpline, "NODENAME=%s", name);
	    if(!(strncmp(line, cmpline, strlen(cmpline))))
		break;
	} /* while */

	/* read the default_fs line */
	if (!(fgets(line, LONGLINE, of)))
	    return;
	if (strncmp(line, "DEFAULT_FS", strlen("DEFAULT_FS")))
	    return;

	/* read the password line */
	if (!(fgets(line, LONGLINE, of)))
	    return;
	if (strncmp(line, "RPW", strlen("RPW")))
	    return;

	/* read the platform line */
	if (!(fgets(line, LONGLINE, of)))
	    return;
	if (strncmp(line, "PLATFORM", strlen("PLATFORM")))
	    return;

	/* read all of the exceptions -- look for NODENAME */
	row = 0;
	while (fgets(line, LONGLINE, of))
	{
	    if (!(strncmp(line, "EXCEPTION", strlen("EXCEPTION"))))
	    {
		line[strlen(line) - 1] = '\0';  /* get rid of CR */

		i = 0;
		while (line[i++] != ' ') {}
	    
		strcpy(cmpline, line+i);   /* get product */

		i = 0;
		while (cmpline[i++] != '=') {}

		strcpy(line, cmpline+i);   /* get file system */
		cmpline[i-1] = '\0';

		FIfld_set_text(fp, MA_EXCEPT, row, 0, cmpline, FALSE);
		FIfld_set_text(fp, MA_EXCEPT, row++, 1, line, FALSE);
	    } /* if */
	    else if (!(strncmp(line, "NODENAME", strlen("NODENAME"))))
		break;
	} /* while */

	fclose(of);
} /* show_except */



int add_group(fp, name)

Form	fp;
char	*name;

/****************************************************************************/
/* this routine adds the group name to the group file                       */
/****************************************************************************/

{
	FILE	*of, *of2, *fopen();
	char	line[LONGLINE], cmpline[512];
	int 	row, i, sel_flag, len, pos, found;
	char	*mach[MAXHOST];

	/* check for the /.vprod directory */
	if (system("test -d /.vprod"))
	    mkdir("/.vprod", 0700);

	/* check for duplicate group name in the file */
	if (NULL != (of = fopen("/.vprod/groups", "r"))) {
	    sprintf(cmpline, "#begin_group %s", name);
	    while (fgets(line, LONGLINE, of)) {
		line[strlen(line) - 1] = '\0';
		if (!(strcmp(line, cmpline))) {
		    fclose(of);
		    return(FALSE);
		} /* if */
	    } /* while */
	    fclose(of);
	} /* if */

	if (NULL == (of = fopen("/.vprod/groups", "a")))
	    return(FALSE);
	chmod("/.vprod/groups", 0600);

	if (NULL == (of2 = fopen("/.vprod/machines", "r")))
	{
	    fputs("#end_group\n", of);		
	    fclose(of);
	    return(TRUE);
	} /* if */

	sprintf(line, "#begin_group %s\n", name);
	fputs(line, of);
	line[0] = '\0';

	/* get all of the selected machines and put them in the file */
	FIfld_get_num_rows(fp, MA_SEL, &row);
	for (i = 0; i < row; i++)
	{
	    FIfld_get_select(fp, MA_SEL, i, 0, &sel_flag);

	    if (!sel_flag)
		continue;

	    FIfld_get_text_length(fp, MA_SEL, i, 0, &len);
	    FIfld_get_text(fp, MA_SEL, i, 0, len, mach, &sel_flag, &pos);
	
	    found = FALSE;
	    sprintf(cmpline, "NODENAME=%s", mach);
	    if (line[0] == '\0')
		fgets(line, LONGLINE, of2);  /* do this the first time */
	    do {
		if (!found) {
		    line[strlen(line) - 1] = '\0';
		    if (!(strcmp(line, cmpline)))
		    {
			fputs(line, of);
			fputs("\n", of);
			found = TRUE;
		    } /* if */
		} else {
		    if (!(strncmp(line, "NODENAME=", strlen("NODENAME="))))
			break;
		}
	    } while (fgets(line, LONGLINE, of2));
	} /* for */
	
	fputs("#end_group\n", of);

	fclose(of2);
	fclose(of);

	total_groups++;
	FIfld_set_value(rem_infoform, INFO_GROUPS, 0, 0,
		(double)(total_groups), FALSE);
	return(TRUE);
} /* add_group */




show_groups(fp, g_label)

Form	fp;
int	g_label;

/****************************************************************************/
/* this routine reads the file of groups and displays them                  */
/****************************************************************************/

{
	FILE	*of, *fopen();
	char	line[LONGLINE], group[LONGLINE];
	int	i, row;

	if (NULL == (of = fopen("/.vprod/groups", "r")))
	    return;

	FIg_reset(fp, g_label);

	row = 0;
	while (fgets(line, LONGLINE, of))
	{
	    line[strlen(line)-1] = '\0';
	
	    /* seperate group name and #begin_group tag */
	    i = 0;
	    while ((line[i] != ' ') && (line[i] != '\0'))
		i++;
	    strcpy(group, line+i+1);
	    line[i] = '\0';

	    if (!(strcmp(line, "#begin_group")))
		FIfld_set_text(fp, g_label, row++, 0, group, FALSE);
	} /* while */ 
	total_groups = row;	
	fclose(of);
} /* show_groups */



int get_group(fp, name, mach_gadget, reset, sel_flag)

Form	fp;
char	*name;
int	mach_gadget;
int	reset;
int	sel_flag;

/*****************************************************************************/
/* this routine (un)selects the remote machines that are contained in group name   */
/* if reset is true then machines that are not within the group are unselected */
/* if sel_flag is true the machines are selected, other wise they are unselected */
/*****************************************************************************/

{
	FILE	*of, *fopen();
	char	line[LONGLINE], cmpline[512], node[MAXHOST];
	int	found, i;

	if (NULL == (of = fopen("/.vprod/groups", "r")))
		return(FALSE);

	sprintf(cmpline, "#begin_group %s\n", name);
	found = FALSE;

	while (fgets(line, LONGLINE, of))   /* get the nodes out of the group file */
	{
		if (!found)
		{
			if (!(strcmp(line, cmpline)))
			{
				if (reset)
					show_remotes(fp, mach_gadget);
				found = TRUE;
			} /* if */
		} /* if */
		else 
		{
			if (!(strcmp(line, "#end_group\n")))
				break;
			else if(!(strncmp(line, "NODENAME=", 
				strlen("NODENAME="))))
			{
				i=0;
				while (line[i++] != '=') {}
				strcpy(node, line+i);
				node[strlen(node) -1] = '\0';
				ma_multi_select(fp, mach_gadget, node, sel_flag);
			} /* else if */
		} /* else */
	} /* while */
	return(found);
} /* get_group */



int delete_group(fp, name)

Form	fp;
char	*name;

/*****************************************************************************/
/* this routine deletes the named group from the groups file                 */
/*****************************************************************************/

{
	FILE	*of1, *of2, *fopen();
	char	line[LONGLINE], cmpline[512];
	int	found;

	FIg_reset(fp, GROUP_FIELD);

	if (NULL == (of1 = fopen("/.vprod/groups", "r")))
		return(FALSE);

	if (NULL == (of2 = fopen("/.vprod/.grps", "w")))
	{
		fclose(of1);
		return(FALSE);
	} /* if */
	chmod("/.vprod/.grps", 0600);

	found = FALSE;
	while (fgets(line, LONGLINE, of1))
	{
		if (!(strncmp(line, "#begin_group", strlen("#begin_group"))))
			found = FALSE;

		sprintf(cmpline, "#begin_group %s", name);
		if(!(strncmp(line, cmpline, strlen(cmpline))))
			found = TRUE;

		if (!found)
			fputs(line, of2);
	} /* while */

	fclose(of1);
	fclose(of2);

	system("mv /.vprod/.grps /.vprod/groups");
	chmod("/.vprod/groups", 0600);

	total_groups--;
	FIfld_set_value(rem_infoform, INFO_GROUPS, 0, 0,
		(double)(total_groups), FALSE);
	return(TRUE);
} /* delete_group */




select_group_members(fp, group_name, val)

Form	fp;
char	*group_name;
int	val;

/***************************************************************************/
/* this routine selects the members of the select group.  it sets the value*/
/* of the member button to val                                             */
/***************************************************************************/

{
	struct	group_node *curr_group;
	struct	remote_node *curr_node;
	int	found = FALSE;

	curr_group = group_header;

	while ((curr_group != NULL) && (!found))
	{
		if (!(strcmp(curr_group->groupname, group_name)))
		{
			curr_group->selected = (int)val;
			curr_node = curr_group->members;
			found = TRUE;

			while (curr_node != NULL)
			{
				select_single_machine(fp, curr_node->nodename, 
					val);
				curr_node->selected = (int)val;
				curr_node = curr_node->next;
			} /* while */
		} /* if */
		curr_group = curr_group->next;
	} /* while */
} /* select_group_members */




/*ARGSUSED*/
select_single_machine(fp, node_name, val)

Form	fp;
char	*node_name;
double	val;

/***************************************************************************/
/* this routine selects a single machine in every group that is it listed  */ 
/***************************************************************************/

{
	struct	group_node *curr_group;
	struct	remote_node *curr_node;
	int	found;
	int	all_are_selected = TRUE;     /* if last selected */
					     /* select the group */

	curr_group = group_header;

	while (curr_group != NULL)         /* look through each group for this node */
	{
		curr_node = curr_group->members;

		found = FALSE;
		while (curr_node != NULL)
		{
			if (!(strcmp(curr_node->nodename, node_name)))
			{
				curr_node->selected = (int)val;
				found = TRUE;
				if ((int)val == 0) {
					curr_group->selected = FALSE;
				}
			} /* if */

			if (((int)val == 1) && (all_are_selected))
				all_are_selected = curr_node->selected;
					
			curr_node = curr_node->next;
		} /* while */

		/* if this node was in this group and unselected and */
		/* no other nodes in the group were selected         */
		/* unselect the group                                */

		if ((found) && ((int)val == 1) && (all_are_selected))
			curr_group->selected = TRUE;

		all_are_selected = TRUE;
		curr_group = curr_group->next;
	} /* while */
} /* select_single_machine */



int
check_platform (platform)

/****************************************************************************/
/* this routine makes sure that the entered platform is valid - if it is    */
/* not all caps - then it does the work for the stupid user                 */
/****************************************************************************/

char *platform;

{
	char	tmp[MAXHOST];
	int	i;

	strcpy(tmp, platform);
	cap_case(tmp);
	for (i = 0; (i < NUM_ARCH && cpu_types[i]); i++) {
	    if (strcmp(tmp, cpu_types[i]) == 0) {
		strcpy(platform, tmp);
		return(TRUE);
	    }
	}
#ifdef old
	if ((!strcmp(tmp, "SUN")) || (!strcmp(tmp, "CLIPPER"))) {
		strcpy(platform, tmp);
		return(TRUE);
	}
#endif

	return(FALSE);
} /* check_platform */



ma_multi_select(fp, gadget, name, flag)

Form	fp;
int	gadget;
char	*name;
int	flag;

/*****************************************************************************/
/* this routine finds the entered name in the field gadet and selects it     */
/*****************************************************************************/

{
	int	i, row, len, pos, sel_flag;
	char	tmp[MAXHOST];

	FIfld_get_num_rows(fp, gadget, &row);

	/* look for the name in the list */

	for (i = 0; i < row; i++)
	{
		FIfld_get_text_length(fp, gadget, i, 0, &len);
		FIfld_get_text(fp, gadget, i, 0, len, tmp,
			&sel_flag, &pos);

		if (!(strcmp(name, tmp)))  /* if they are same */
		{
			FIfld_set_select(fp, gadget, i, 0, flag);
			FIfld_set_select(fp, gadget, i, 1, flag);
			FIfld_set_select(fp, gadget, i, 2, flag);
		} /* if */
	} /* for */
} /* ma_multi_select */



get_stats()

/**************************************************************************/
/* this routine gets the number of remotes, groups, and packages so that  */
/* the info can be displayed on the rem_info.form                         */
/**************************************************************************/

{
	FILE	*of, *fopen();
	char	line[LONGLINE];
	int	count;


	/* get the number of remote nodes */
	if (NULL == (of = fopen("/.vprod/machines", "r")))
		return;

	count = 0;
	while (fgets(line, LONGLINE, of)) {
		if (!(strncmp(line, "NODENAME", strlen("NODENAME"))))
			count++;
	} /* while */
	total_remotes=count;
	fclose(of);

	
	/* get the number of groups */
	if (NULL == (of = fopen("/.vprod/groups", "r")))
	    return;

	count = 0;
	while (fgets(line, LONGLINE, of)) {
	    if (!(strncmp(line, "#begin_group", strlen("#begin_group"))))
		count++;
	} /* while */ 
	total_groups = count;
	fclose(of);


	/* get the number of packages */
	if (NULL == (of = fopen("/.vprod/packages", "r")))
		return;
	
	count = 0;
	while (fgets(line, MAXLINE, of)) {
		if (!(strncmp(line, "#begin_package", strlen("#begin_package"))))
			count++;
	} /* while */
	total_packs = count;
	fclose(of);
} /* get_stats */




validate(node, pass)

char *node, *pass;

/*****************************************************************************/
/* this routine checks to see if node.root.pass works - returns 1 if it does */
/* and 0 if it does not                                                      */
/*****************************************************************************/

{
	struct sockaddr_in	server;
	struct servent	*sp;
	struct hostent	*hp;
	unsigned long	in;
	int     xfersize;
	int	my_sk, save_sk;
	int	save_nettype;

	extern char *errstr;
	extern char *send_request();
	extern char *rx();


#define TCPSERVER       "newprod"
#define TCP  		2


	/*
	 * try a TCP connect - first verify the service exists
	 * if the service doesn't exist, then error out with the inc error
	 */
	 if (!(sp = getservbyname(TCPSERVER, NULL))) {
		return(FALSE);
	 }

	if (!(hp = gethostbyname(node))) {
	    return(FALSE);
	}
	
#ifdef SYSV
	memset(&server, 0, sizeof(server));
	memcpy(&server.sin_addr, hp->h_addr, hp->h_length);
#else
	bzero(&server, sizeof(server));
	bcopy(hp->h_addr, &server.sin_addr, hp->h_length);
#endif

	server.sin_family = hp->h_addrtype;
	server.sin_port = sp->s_port;

	if ((my_sk = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		return(FALSE);
	}

	if (connect(my_sk, (struct sockaddr *)&server, sizeof(server)) < 0) {
		/*
		 * 92/01/22 SCW
		 *	Make sure we close the socket!  Otherwise, TCP/IP
		 *	leaves it in a confused state and it can cause
		 *	a kernel panic when we exit!
		 */
		close(my_sk);
		return(FALSE);
	}

	/* switch-a-roo with global sk */
	save_sk = sk;
	sk = my_sk;

	/*
	 * send the username and password to the server and check for
	 * proper authentication
	 */
	    errstr = "Memory allocation failure";
	    if (!(request = (REQUEST *)calloc(1, sizeof(REQUEST)))) {
		net_disconnect();
		sk = save_sk;
		return(FALSE);
	    }

	    if (!(reply = (REPLY *)calloc(1, sizeof(REPLY)))) {
		net_disconnect();
		sk = save_sk;
		return(FALSE);
	    }

	    save_nettype = nettype;
	    nettype = TCP;

	    request->req_type = (unsigned long)DEFINE_USER;
	    strncpy(request->prodname, "root", PRODNAME_LEN);
	    strncpy(request->prodnum,  pass, PRODNUM_LEN);
	    request->revision = 1;


	    if (!(errstr = send_request())) {

		xfersize = NETSIZE;
		if ((errstr = rx((char *)reply))) {
			net_disconnect();
			nettype = save_nettype;
			sk = save_sk;
			return(FALSE);
		}

		if (reply->rep_type == REPLY_ERROR) {
			net_disconnect();
			nettype = save_nettype;
			sk = save_sk;
			return(FALSE);
		}

		net_disconnect();
		nettype = save_nettype;
		sk = save_sk;
		return(TRUE);
	    }

	net_disconnect();
	nettype = save_nettype;
	sk = save_sk;
	return(FALSE);
} /* validate */
