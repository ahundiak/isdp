#include "main.h"
#include "defs.h"
    
/*****************************************************************************/
/* the routines in this file are used to deal with multiple products with    */
/* the same name                                                             */
/*									     */
/* multname_note	notification routine for the selection form          */
/* multname             displays the form and fills it with info             */
/* unsel_mult           unselects products with the common name              */
/*****************************************************************************/
    
    
extern struct prodnode	header;
extern struct fsdata	fs_table[];
extern Form	delform;
extern Form	revform;
extern Form	statform;
extern	short	srcmedia;
extern	int	curr_fs;
extern	int	multname_butt;
extern	int	mess_row;
extern unsigned long my_arch;
extern short show_all_plats;

Form	multnameform[20];  /* array of multnameforms */
int	multindex = 0;


/*ARGSUSED*/
multname_note(f_label, g_label, value, fp)

int f_label;	/* form label      */
int g_label;	/* gadget label    */
double value;	/* value of gadget */
Form fp;	/* form pointer    */

{
    int	row, pos, text_len, flag, i, j;
    int	oldrow;
    char	prodnum[PRODNUM_LEN];
    int	sts;
    char	*uptr;
    char	line[MAXLINE];
    int	one_selected = FALSE;
    char	name[PRODNAME_LEN];
    double	percent;
    char	uname[PRODNAME_LEN];
    
    switch(g_label)
    {
	case FI_ACCEPT:
	    /* see if any of the products listed were selected */
	    FIfld_get_num_rows(fp, MN_FIELD, &row);
	    
	    for (i = 0; i < row; i++)
	    {
		FIfld_get_select(fp, MN_FIELD, i, 0, &flag);
		if (flag)
		{
		    one_selected = TRUE;
		    break;
		} /* if */
	    } /* for */
	
	    /* if none were selected, pop the button back up */
	    
	    if (!one_selected)
	    {	
		FIf_get_user_pointer(delform, &uptr);
		    
		oldrow = atoi(uptr);
		if (oldrow != -1)
		{
		    for (i = 0; i <= 5; i++)
			FIfld_set_select(delform, ASCII_LIST, oldrow, i, FALSE);
		}
	    } /* if */
	    
	    FIf_get_user_pointer(fp, &uptr);
	    i = 0;
	    while (uptr[i++] != ' ') {}
	    strcpy(name, uptr);
	    name[i-1] = '\0';
	    
	    FIf_erase(fp);
	    
	    /* set the form in the array of multname forms to NULL */
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
		{
		    multnameform[i] = NULL;
		    break;
		} /* if */
	    } /* for */
	break;
	    
	case MN_FIELD:
	    FIg_reset(statform, MESSBOX);
	    mess_row = 0;
	    
	    FIfld_get_active_row(fp, MN_FIELD, &row, &pos);
	    FIfld_get_text_length(fp, MN_FIELD, row, 0, &text_len);
	    FIfld_get_text(fp, MN_FIELD, row, 0, text_len, prodnum, &flag, &pos);
	    
	    FIf_get_user_pointer(fp, &uptr);
	    i = 0;
	    while (uptr[i++] != ' ') {}
	    strcpy(name, uptr);
	    name[i-1] = '\0';
	    
	    sts = set_selected_ascii(delform, name, prodnum, flag, TRUE);
	    
	    if (sts == FALSE)
	    {
		FIfld_set_select(fp, MN_FIELD, row, 0, FALSE);
		FIfld_set_select(fp, MN_FIELD, row, 1, FALSE);
		FIfld_set_select(fp, MN_FIELD, row, 2, FALSE);
		FIfld_set_select(fp, MN_FIELD, row, 3, FALSE);
		FIfld_set_select(fp, MN_FIELD, row, 4, FALSE);
		return;
	    } /* if */
	
	    if (flag)
		sprintf(line, "added %s %s to the %s deliver set",
			name, prodnum, fs_table[curr_fs].name);
	    else
		sprintf(line, "removed %s %s from the %s deliver set",
			name, prodnum, fs_table[curr_fs].name);
	    
	    FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
	    
	    if (revform)
		show_current(revform);
	    break;
	} /* switch */
} /* multname_note */



multname(name, butt_num)

char	*name;
int	butt_num;	/* gadget label for the button that this product is on */

/*****************************************************************************/
/* this routine displays the form for multiple named products                */
/* the user pointer for the form is the string "name butt_num"               */
/*****************************************************************************/

{
    int		sts, row = 0;
    Form	form;
    struct	prodnode *pptr;
    char	*status;
    char	*uptr;
    int		i, j;
    char	uname[PRODNAME_LEN];
    char	path[MAXPATHLEN];

    /* make sure that a form for the multname is not alredy displayed */
    
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
    

    sprintf(path, "%s/multname.form", MYSTUFFDIR);    
    sts = FIf_new(MULTNAMEFORM, path,
		  multname_note, &form);
    if (chkerror (sts, "creating form"))
	exit(1);

#ifdef XFORMS
    Set_form_class(multname_note);
#endif
    
    /* set up the user pointer */
    uptr = (char *)calloc(1, PRODNAME_LEN+4);
    sprintf(uptr, "%s %d", name, butt_num);
    FIf_set_user_pointer(form, uptr);
    
    FIg_set_text(form, MN_TITLE, name);  /* put the name of the product on the form */
    
    /* list the product numbers and stuff */
    
    for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
    {
	if (!(strcmp(pptr->prodname, name)))
	{
	    if ((!(pptr->arch & my_arch)) && (!show_all_plats))
			continue;
		
	    FIfld_set_text(form, MN_FIELD, row, 0, pptr->prodnumber, FALSE);
	    FIfld_set_text(form, MN_FIELD, row, 1, pptr->prodtitle, FALSE);
	    FIfld_set_text(form, MN_FIELD, row, 2, pptr->prodversion, FALSE);
	    
	    /* acertain product status */
	    status = statustext[chk_prod_status(pptr->prodnumber)];
	    FIfld_set_text(form, MN_FIELD, row, 3, status, FALSE);
	    
	    if ((srcmedia == CDROM) || (srcmedia == NETCDROM))
		if ((atoi(pptr->flags)) && !(pptr->pstat & HAVEKEY))
		    FIfld_set_text(form, MN_FIELD, row, 4, "key", FALSE);
		    
	    row++;
	} /* if */
    } /* for */
    
    sts = FIf_display(form);
    if (chkerror (sts, "displaying form"))
	exit(1);
    
    multnameform[multindex++] = form;
} /* multname */




unsel_mult(name)
char	*name;

/****************************************************************************/
/* this routine unselects all products that have the name name              */
/* it updates the file system gadgets                                       */
/****************************************************************************/

{
    struct	prodnode *pptr;
    char	*uptr;
    int		i, j;
    char	uname[PRODNAME_LEN];
    
    for (pptr = header.flink; pptr != &header; pptr = pptr->flink)
    {
	if ((!(strcmp(pptr->prodname, name))) && (pptr->pstat & SELECTED))
	{
	    set_selected_ascii(delform, pptr->prodname, pptr->prodnumber,
			       FALSE, TRUE);
	}
    }

    /* if the multname form for this name is displayed -- erase it */
    
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
	{
	    FIf_erase(multnameform[i]);
	    multnameform[i] = NULL;
	    break;
	} /* if */
    } /* for */
} /* unsel_mult */


