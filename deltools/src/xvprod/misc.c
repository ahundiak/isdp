#include <varargs.h>
#include "main.h"
#include "defs.h"
#include "infp.h"

#define LONGLINE 2048

/****************************************************************************/
/* this file contains lots of stuff -- here is a list:                      */
/*									    */
/* visible    returns true if a product is visible                          */
/* first      returns the first visible product on a list                   */
/* next       returns the next product on a list                            */
/* last	      returns the last product on a list                            */
/* prev       return the previous product on a list                         */
/* node_copy  copies one product node to another                            */
/* unselect_products  sets all of the products to unselected                */
/* set_selected_ascii  selects/deselects a product                          */
/* inq_product  selects a product that was keyed in                         */
/* cap_case & cap    changes a string to all caps                           */
/* message    puts a message in the delivery form message box               */
/* messprintf   works like printf to put a message in the message box       */
/* show_current   puts info about the current product in the README form    */
/* fix_line       takes tabs out of strings so that they can be displayed   */
/* power          returns an infp number                                    */
/* my_decrypt     decrypts an infp number                                   */
/* my_crypt       encrypts a password into an infp number                   */
/* curr_location                                                            */
/* strsubset      returns true if one string is a subset of another         */
/* get_month2  returns 3 letter month for number 1-12                       */
/* get_fs_number  given a file sys name it return the number in the table   */
/* scroll_to_1st_selected  given a field gadget will scroll to 1st sel line */
/****************************************************************************/

#define README_FILE	"README"

char		button_array[2][MAXROW*MAXCOL][MAXPROD];
int		multname_array[MAXROW*MAXCOL];
int		mess_row=0;
char		force_dest[64];

extern struct prodnode *curr_hdr;
extern struct prodnode *start;
extern struct prodnode header;
extern struct prodnode classheader;
extern struct prodnode loadedheader;
extern struct prodnode *current_product;
extern	Form classform, connform, delform, revform, statform, fsform, rem_delform;
extern	int curr_fs;
extern	int num_fs;
extern	int topind;
extern	struct fsdata	fs_table[];
extern	Form prod_list[2][4];
extern	short srcmedia;
extern	FILE *logf;
extern	percent;	/* percent scrolled on local form */
extern	int	class;
extern	short	multimenu;
extern	short	allvis;
extern	unsigned long	my_arch; /* platform of the local machine */
extern	short	show_all_plats;  /* when true show all platform products */

extern char *GetMountPoint();
extern infp oper();
extern	char	*factorize();

int	visible(p, pptr)
struct prodnode	*p, *pptr;
{
	if (multimenu && strcmp(p->prodclass, pptr->prodclass))
		return(0);
	if ((p->pstat & 0xf) == LOAD_ERRORS)
		return(1);
	if (allvis && (p->attr & ATTR_INVISIBLE))
		return(1);
	if (!allvis && !(p->attr & ATTR_INVISIBLE))
		return(1);
	return(0);
}

struct prodnode	*first(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;

	/*
	 * if were in the class menu, then return the first class pointer
	 */
	if (class)
		return(h->flink);

	/*
	 * return the first visible entry or one with errors
	 */
	for (p = h->flink; p != h; p = p->flink)
		if (visible(p, pptr))
			break;

	/*
	 * if we didn't find any entries, then go to allvis mode.
	 */
	if (p == h) {
		allvis = !allvis;
		p = first(pptr, h);
	}
	return(p);
}

struct prodnode	*next(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;

	if (class)
		return(pptr->flink);

	/*
	 * return the next visible entry or one with errors
	 */
	for (p = pptr->flink; p != h; p = p->flink)
		if (visible(p, pptr))
			break;

	return(p);
}

struct prodnode	*last(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;

	if (class)
		return(h->blink);

	/*
	 * otherwise, return the visible entry or one with errors
	 */
	for (p = h->blink; p != h; p = p->blink)
		if (visible(p, pptr))
			break;

	/*
	 * if we don't have any visible entries, then go to allvis mode.
	 */
	if (p == h) {
		allvis = !allvis;
		p = last(pptr, h);
	}
	return(p);
}

struct prodnode	*prev(pptr, h)
struct prodnode	*pptr, *h;
{
	struct prodnode	*p;

	if (class)
		return(pptr->blink);

	/*
	 * return the previous visible entry or one with errors
	 */
	for (p = pptr->blink; p != h; p = p->blink)
		if (visible(p, pptr))
			break;

	return(p);
}

node_copy(new, pptr)
struct prodnode *new, *pptr;

/****************************************************************************/
/* this routine copies the info from prodnode pptr into prodnode new        */
/* be sure to malloc the space for new before calling this routine          */
/****************************************************************************/

{
    strcpy(new->prodname, pptr->prodname);
    strcpy(new->prodnumber, pptr->prodnumber);
    strcpy(new->prodtitle, pptr->prodtitle);
    strcpy(new->prodversion, pptr->prodversion);
    strcpy(new->prodclass, pptr->prodclass);
    strcpy(new->date, pptr->date);
    strcpy(new->flags, pptr->flags);
    strcpy(new->srcdir, pptr->srcdir);
    strcpy(new->unixdir, pptr->unixdir);
    strcpy(new->loadeddir, pptr->loadeddir);
    strcpy(new->loadedvers, pptr->loadedvers);
    new->blocksize = pptr->blocksize;
    new->multname  = pptr->multname;
    new->attr  = pptr->attr;
    new->load_priority  = pptr->load_priority;
    new->pstat  = pptr->pstat;
    strcpy(new->destfs, pptr->destfs);
    new->arch  = pptr->arch;
}

unselect_products(start, hdr)
struct prodnode *start;
struct prodnode *hdr;
{
    struct prodnode *curr_prod;

    for (curr_prod = start; curr_prod != hdr && curr_prod != &header;
	    curr_prod = next(curr_prod, hdr)) {
	curr_prod->pstat &= ~SELECTED;
    }
}


int
set_selected_ascii (fp, name, number, val, flag)

Form	fp;
char	*name;
char	*number;
int	val;
int	flag;

/****************************************************************************/
/* this routine sets the selected field for the product name to val         */
/* if there was not enough space it returns 0, otherwise 1                  */
/* if flag is true then update file system gadgets and count class selections*/
/****************************************************************************/

{
	struct prodnode *curr_prod;
	int	found = FALSE;
	struct prodnode *other_selected, *the_prod;
	int	i;
	char	readmefile[64];
	char	fs[10];		/* file system name */
	char	dfs[16];
	int	cfs;
	int	fsbutt;

	the_prod = header.flink;    /* this used to be the_prod = start -- why? */
	other_selected = NULL;

	/* look for the product that matches the product number */

	while ((!found) && (the_prod != &header ))
	{
	    if (!(strcmp(number, the_prod->prodnumber)))
	    {
		if (!(the_prod->arch & my_arch) && (!show_all_plats)) {
		     the_prod = the_prod->flink;
		     continue;
		}

		curr_prod = the_prod;
		found = TRUE;
	    } /* if */
	    else if (the_prod->pstat & SELECTED)    /* look for another selected product */
		other_selected = the_prod;

	    the_prod = the_prod->flink;
	} /* while */

	if (!found)		/* if it was not found, forget it */
	    return(FALSE);

	/*
	 * If the product has an explicit destination, then dest_fs
	 * should be set from that -- NOT from the curr_fs button.
	 */
	if (curr_prod->unixdir[0] == '/')
	{
	    strcpy(dfs, GetMountPoint(curr_prod->unixdir));
	    for (i = 0; (i < num_fs) && strcmp(dfs, fs_table[i].name); i++)
		;
	    if (i < num_fs)
		cfs = i;
	}
	else
	{
	    cfs = curr_fs;
	    strcpy(dfs, fs_table[cfs].name);
	}

	if ( flag && ((curr_prod->pstat & NEW) ||
	     (curr_prod->loadeddir[0] &&
	      strcmp(dfs, GetMountPoint(curr_prod->loadeddir)))))
	{
	    /* make sure that there is room */
	    if (((fs_table[cfs].selected + curr_prod->blocksize) > 
		    fs_table[cfs].space) && (val) && (flag))
	    {
		messprintf("Not enough space for %s\n", 
			curr_prod->prodname);
		return(FALSE);
	    } /* if */
	}


	if (val == 1)	/* if product was selected */
	{
	    if (atoi(curr_prod->flags))
	    {
		/* Product has load key */
		sprintf(readmefile, "%s/%s", curr_prod->srcdir, README_FILE);
		if (check_key(readmefile, curr_prod))
		    return(FALSE);
	    }
	    if ((curr_prod->pstat & SELECTED) && (curr_prod->destfs[0] != '\0') &&
		(strcmp(curr_prod->destfs, fs_table[cfs].name) != 0)) {
		/*
		 * It was selected for another filesystem, so
		 * now that it's moving, delete the space from the other's
		 * selected amount.
		 */
		for (i = 0; i < num_fs; i++) {
		    if (strcmp(curr_prod->destfs, fs_table[i].name) == 0) {
			if ((curr_prod->pstat & NEW) ||
			   ((curr_prod->loadeddir[0] &&
			       strcmp(fs_table[i].name, GetMountPoint(curr_prod->loadeddir)))))
			    fs_table[i].selected -= curr_prod->blocksize;
			    messprintf("Removed %s from the %s delivery set\n",
				curr_prod->prodname, fs_table[i].name);
		    }
		}
	    }
	    strcpy(curr_prod->destfs, fs_table[cfs].name);
	    if (curr_prod->unixdir[0] == '/') {
		messprintf("This product must be installed in the %s file system.\n", curr_prod->destfs);
		strcpy(force_dest, curr_prod->destfs);
	    }

	    if ((curr_prod->pstat & NEW) ||
		(curr_prod->loadeddir[0] &&
		    strcmp(curr_prod->destfs, GetMountPoint(curr_prod->loadeddir))))
		fs_table[cfs].selected += curr_prod->blocksize;

	    /* And make sure we update the class node to say that one
	     * more of its products were selected... 
	     */

	    /* And make sure that we do not count it twice by
	     * checking to see if it is already selected
	     */
	    if ((flag) && !(curr_prod->pstat & SELECTED))
	    {
		curr_prod->clink->pstat++;
		update_class(curr_prod);
	    } /* if */
	    curr_prod->pstat |= SELECTED;
	    strcpy(fs, fs_table[cfs].name);
	} /* if */
	else		/* else it was unselected */
	{
	    if (flag) {
		for (i = 0; (i < num_fs) && strcmp(curr_prod->destfs, fs_table[i].name); i++)
		    ;

		if (i == num_fs) {  /* something is wrong */
		    flag = FALSE;
		    return(FALSE);
		}
	    
		fsbutt = i + 54;
		curr_prod->destfs[0] = '\0'; 
		if ((curr_prod->pstat & NEW) ||
		    (curr_prod->loadeddir[0] &&
		    strcmp(fs_table[i].name, GetMountPoint(curr_prod->loadeddir))))
		    fs_table[i].selected -= curr_prod->blocksize;
	    }

	    curr_prod->pstat &= ~SELECTED;

	    /*
	     * Update class node to indicate one fewer was selected.
	     */
	    if (flag) {
		curr_prod->clink->pstat--; 
		update_class(curr_prod);
	    }
	} /* else */

	/* update the file system gadgets */
	if (flag) {
	    FIg_set_value(fsform, BLOCKS_SEL_1, (double) fs_table[topind].selected);
	    FIg_set_value(fsform, BLOCKS_SEL_2, (double) fs_table[topind+1].selected);
	} /* if */

	/* find current product */

	if (val == 1)
	{
	    if (fp != rem_delform)
		    FIfld_set_text(fp, CURRENT_PROD, 0, 0, name, FALSE);
	    current_product = curr_prod;
	} /* if */
	/* check if it was unselected and the current product */
	else if (!(strcmp(current_product->prodname, curr_prod->prodname)))
	{
	    current_product = NULL;
	    if (fp != rem_delform)
		    FIg_reset(fp, CURRENT_PROD);
	} /* else */

	if ((val) || (current_product))	/* we got what we came for */
	    return(TRUE);

	if (other_selected)   /* if another is selected */
	{
	    current_product = other_selected;
	    if (fp != rem_delform)
		    FIfld_set_text(fp, CURRENT_PROD, 0, 0, other_selected->prodname, 
				FALSE);
	} /* if */

	if (other_selected == NULL)   /* look at rest for another selected */
	{
	    i = 0;
	    while ((i < header.blocksize) && (other_selected == NULL))
	    {
		if (curr_prod->pstat & SELECTED)
		{
		    other_selected =  curr_prod;
		    current_product = other_selected;
		} /* if */
		curr_prod = curr_prod->flink;
		i++;
	    } /* while */
	} /* if */

	if ((other_selected) && (fp != rem_delform))  /* others were selected */
	    FIfld_set_text(fp, CURRENT_PROD, 0, 0, other_selected->prodname, 
			FALSE);

	return(TRUE);
} /* set_selected_ascii */




int inq_product(fp, name, flag)

Form	fp;
char	*name;
int	flag;

/****************************************************************************/
/* this routine returns 1 if name is a product 0 if not a product           */
/* and it returns 2 if it is a multiple name product                        */
/* 3 = not enough space for the product                                     */
/* 4 = key problem                                                          */
/* it sets the product to selected if it exists                             */
/* it scrolls to show the product if it exists                              */
/* if flag is true the file system gadgets are updated                      */
/****************************************************************************/

{
	struct  prodnode *curr_prod, *last_prod, *found_prod;
	int	found = FALSE;
	char	readmefile[64];
	int	count = 1, i, j, row, num_rows, pos, sel_flag, len;
	char	pname[10];
	char	dfs[16];
	char	*uptr;
	int	cfs, moving;

	curr_prod = header.flink;
	last_prod = NULL;

	do
	{
	    if (!strcmp(name, curr_prod->prodname) &&
		(curr_prod->arch & my_arch || show_all_plats)) {

		if (flag) 
		{
		    /*
		     * If the product has an explicit destination, then dest_fs
		     * should be set from that -- NOT from the curr_fs button.
		     */
		    if (curr_prod->unixdir[0] == '/')
		    {
			strcpy(dfs, GetMountPoint(curr_prod->unixdir));
			for (i = 0; (i < num_fs) && strcmp(dfs, fs_table[i].name); i++)
			    ;
			if (i < num_fs)
			    cfs = i;
		    }
		    else
		    {
			cfs = curr_fs;
			strcpy(dfs, fs_table[cfs].name);
		    }

		    if ((curr_prod->pstat & NEW) ||
			(curr_prod->loadeddir[0] &&
			strcmp(dfs, GetMountPoint(curr_prod->loadeddir))))
		    {
			/* make sure that there is room */
			if ((fs_table[cfs].selected + curr_prod->blocksize) > 
			     fs_table[cfs].space)
			{
			    messprintf("Not enough space for %s\n", 
				       curr_prod->prodname);
			    return(3);
			} /* if */
		    }
		}
		
		if (atoi(curr_prod->flags)) {
		    /* Product has load key */
		    sprintf(readmefile, "%s%s", curr_prod->srcdir, README_FILE);
		    if (check_key(readmefile, curr_prod))
			return(4);
		}

		found_prod = curr_prod;
		current_product = curr_prod;

		/* see if the name has more that one product */
		if ((NULL != last_prod) && 
		    !strcmp(curr_prod->prodname, last_prod->prodname) &&
		    ((curr_prod->arch & my_arch) && (last_prod->arch & my_arch)))
		{
		    curr_prod->multname = TRUE;
		    last_prod->multname = TRUE;
		    last_prod->pstat &= ~SELECTED;
		    curr_prod->pstat &= ~SELECTED;
		    found = 2;
		}
		else
		{
		    found = 1;
		}
	    } /* if */
	    
	    count++;
	    last_prod = curr_prod;
	    curr_prod = curr_prod->flink;
	} while (curr_prod != &header);

	if (found == 1)
	{

	    if (flag && fsform)
	    {
		moving = 0;
		if ((found_prod->pstat & SELECTED) && (found_prod->destfs[0] != '\0') &&
		    (strcmp(found_prod->destfs, fs_table[cfs].name) != 0))
		{
		    /*
		     * It was selected for another filesystem, so
		     * now that it's moving, delete the space from the other's
		     * selected amount.
		     */
		    for (i = 0; i < num_fs; i++) {
			if (strcmp(found_prod->destfs, fs_table[i].name) == 0) {
			    if ((found_prod->pstat & NEW) ||
			       ((found_prod->loadeddir[0] && 
				   strcmp(fs_table[i].name, GetMountPoint(found_prod->loadeddir)))))
				fs_table[i].selected -= found_prod->blocksize;
			    messprintf("Removed %s from the %s delivery set\n",
				    found_prod->prodname, fs_table[i].name);

			    moving = 1;
			}
		    }
		}
		strcpy(found_prod->destfs, fs_table[cfs].name);
		if (found_prod->unixdir[0] == '/') {
		    messprintf("This product must be installed in the %s file system.\n", found_prod->destfs);

		    strcpy(force_dest, found_prod->destfs);
		}
		if ( moving ||
		  (!(found_prod->pstat & SELECTED) &&
		     ((found_prod->pstat & NEW) ||
		     (found_prod->loadeddir[0] && strcmp(fs_table[cfs].name, GetMountPoint(found_prod->loadeddir))))))
		    fs_table[cfs].selected += found_prod->blocksize;

		FIg_set_value(fsform, BLOCKS_SEL_1, (double) fs_table[topind].selected);
		FIg_set_value(fsform, BLOCKS_SEL_2, (double) fs_table[topind+1].selected);
		
	    }
	    /*
	     * Add the product in the class tallies -- but only if it
	     * hasn't previously been selected.
	     *
	     */
	    if (flag && !(found_prod->pstat & SELECTED))
	    {
		found_prod->clink->pstat++;
		if (fp == delform)
		    update_class(found_prod);
	    } /* if */
		
	    found_prod->pstat |= SELECTED;
	    
	    if (fp == delform)
	    {
		/* if it is in this class - highlight it */
		if ((curr_hdr == found_prod->clink) || (multimenu == 0))
		    list_products(delform);
	    }
	    else
		list_products_2(fp, PK_PRODLIST);
	} /* if */
	else if (found == 2)
	{
	    if (fp == delform)
	    {
		if ((curr_hdr == found_prod->clink) || (multimenu == 0))
		{
		    /* See if the product is on the form now.  Set its
		     * line ON, but we leave the product unselected.
		     */

		    FIfld_get_num_rows(fp, ASCII_LIST, &num_rows);
		    for (row = 0; row < num_rows; row++)
		    {
			/* get the name */
			FIfld_get_text_length(fp, ASCII_LIST, row, 0, &len);
			FIfld_get_text(fp, ASCII_LIST, row, 0, len, pname, &sel_flag, &pos);
			if (strcmp(pname, found_prod->prodname) == 0) {
			    for (j = 0; j < 6; j++)
				FIfld_set_select(fp, ASCII_LIST, row, j, TRUE);
			
			    /* set up the user pointer to indicate the
			     * selected row for the multname notify routine.
			     */
			    uptr = (char *)calloc(1, 5);
			    sprintf(uptr, "%d", row);
			    FIf_set_user_pointer(fp, uptr);
			}
		    }
		}
	    }
	}
	return(found);
} /* inq_product */



cap_case(s)

char *s;	/* string to be changed */

/************************************************************/
/* this function changes string s to be all capital letters */
/************************************************************/

{
	char	*tmp;	/* temp pointer to the string */

	tmp = s;

	while (*tmp)
	{
		*tmp = cap(*tmp);  /* change each letter */
		*tmp++;
	} /* while */

} /* cap_case */



int
cap(c)

int c;		/* ascii value of letter to be changed */

/********************************************************************/
/* this function returns a capital c if possible, otherwise it just */
/* returns c                                                        */
/********************************************************************/

{
	if (c >= 'a' && c <= 'z')		/* lower case letter */
		return(c - ('a' - 'A'));

	else					/* another type of char */
		return(c);
} /* cap */




message(fp, str)
Form fp;
char *str;

/**********************************************************************/
/* this routine prints a message to the delivery form message box     */
/**********************************************************************/

{
	int sts;
	int	gadget;

	if (fp == statform)
	    gadget = MESSBOX;
	else if (fp == connform)
	    gadget = MESSAGE;
	
	if (!(strcmp(str, "!!!ClEaR")))
	{
		mess_row = 0;
		FIg_reset(fp, gadget);
	} /* if */
	else
	{
		FIfld_set_text(fp, gadget, mess_row++, 0, str, FALSE);

		if (mess_row > 4)
			sts = FIfld_set_active_row(fp, gadget, mess_row-1, 0);
	} /* else */
} /* message */


/* A handy interface to MESSAGE() above!  Now you can print into the
 * message box with simple "printf" style commands!  Most excellent!
 */

/* VARARGS */
messprintf(va_alist)
va_dcl
{
    va_list	args;
    char	messstr[512];
    char	*fmt;

    va_start(args);

    fmt = va_arg(args, char *);
    vsprintf(messstr, fmt, args);

    va_end(args);

    if (logf) {
	fseek(logf, 0L, 2);
	fprintf(logf, messstr);
	fflush(logf);
    }

    if (statform)
	message(statform, messstr);
    else if (connform)
	message(connform, messstr);
    else
	fprintf(stderr, messstr);
}

show_current(fp)

Form fp;

{
	char blocks[10];

	if (current_product == NULL)
	{
		FIf_reset(fp);
		return;
	} /* if */

	if (review(current_product) == 1)
	{
		FIf_reset(fp);
		return;
	}

	FIg_erase(fp, NAME_TEXT);
	FIg_set_text(fp, NAME_TEXT, current_product->prodname);
	FIg_display(fp, NAME_TEXT);
	FIg_erase(fp, NUMBER_TEXT);
	FIg_set_text(fp, NUMBER_TEXT, current_product->prodnumber);
	FIg_display(fp, NUMBER_TEXT);
	FIg_set_text(fp, TITLE, current_product->prodtitle);
	sprintf(blocks, "%d", current_product->blocksize);
	FIg_set_text(fp, BLOCKS, blocks);
	FIg_set_text(fp, VERSION, current_product->prodversion);

	if (current_product->pstat & NEW)
		FIg_set_text(fp, STATUS, "New");
	else if (current_product->pstat & WORKSTATION_NEWER)
		FIg_set_text(fp, STATUS, "Workstation Newer");
	else if (current_product->pstat & UP_TO_DATE)
		FIg_set_text(fp, STATUS, "Up To Date");
	else
		FIg_set_text(fp, STATUS, "Needs Updating");

	FIfld_set_select(fp, SECTIONS, 0, 0, TRUE);
} /* show_current */


void
fix_line(s)

char	*s;		/* string to be changed */

/************************************************************************/
/* this procedure changes all of the tabs in s to the correct number of */
/* spaces                                                               */
/************************************************************************/

{
	char	*tmp, *holder;		/* strings, pieces of the whole */
	int	colcount;		/* index                        */


	colcount = 0;  /* set current colomn to begining */

	holder = (char*) calloc(1, MAXLINE +1);	
	if (!holder)
	{
		fprintf(stderr, "Error : memory allocation");
		return;
	} /* if */

	tmp = s;


	while (*tmp)
	{
		if (*tmp == '\t')
		{
			strcpy(holder, tmp+1);	/* hold rest of string */
			
			do	/* put spaces over to multiple of 8 */
			{
				*tmp++ = ' ';
				++colcount;
			}while (colcount % 8);
		
			*tmp = '\0';

			strcat(tmp, holder);	/* attach rest of string */

		} /* if */

		else
		{
			++colcount;
			tmp++;
		} /* else */
	} /* while */
} /* fix_line */



infp power(base, exp)

int	base;
unsigned exp;

/****************************************************************************/
/* this function finds the value of base to the exp power and returns the   */
/* value in a infp number                                                   */
/****************************************************************************/

{
	int	count = 0;
	infp	result;
	infp	in_base;

	infpInit(&result, 1);
	infpInit(&in_base, base);

	for (count = 1; exp > 0; --exp)
		result = oper('*', result, in_base);		

	return(result);
} /* power */


char	*my_decrypt(pass_num)

char	*pass_num;

/*****************************************************************************/
/* this routine decrypts a godel number created by my_crypt                  */
/*****************************************************************************/

{
	infp	pass;

	infpInit(&pass, 0);
	infpSetStr(&pass, pass_num);
	
	pass_num = factorize(&pass); 
	return(pass_num);
} /* my_decrypt */


char *my_crypt(pass)

char	*pass;

/***************************************************************************/
/* this routine crypts a password                                          */
/***************************************************************************/

{
	static char	str[LONGLINE];
	infp	product, result;
	static unsigned pt[] = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37,
	41, 43, 47, 53, 61, 71, 73, 79, 83, 89, 97 };

	int	i = 0;
	str[0] = '\0';

	infpInit(&product, 1);

	while ((pass[i] != '\0') && (i < 23))
	{
		result = power(pt[i], pass[i] - ' '+1);
		product = oper('*', product, result);
		i++;
	} /* while */

	infpPrint(str, &product);
	return(str);
} /* my_crypt */




char *curr_location(pnumber)
char *pnumber;
{
    struct prodnode *pptr;
    char	*mntpnt;
    int found = 0;

    for (pptr = loadedheader.flink; pptr != &loadedheader; pptr = pptr->flink) {
	if (strcmp(pptr->prodnumber, pnumber) == 0) {
	    found = 1;
	    break;
	}
    }
    if (!found)
	return (NULL);
    else {
        if ((mntpnt = GetMountPoint(pptr->loadeddir)) == NULL)
	    return (NULL);
	else 
	    return(mntpnt);
    }
}



int
strsubset(s1,s2)

char 	*s1;	/* the big string */
char	*s2;	/* the sub string */

/******************************************************************/
/* this procedure returns true if s2 is a subset of s1, otherwise */
/* it returns false                                               */
/******************************************************************/

{
	char	*temp;		/* temp pointer to string s2 */

	while (*s1)
	{
		temp = s2;

		/* find the first matching letter */
		while ((*s1++ != *temp) && (*s1)){} 

		if (!(*s1--))	/* not even one matching letter */
			return FALSE;

		s1++;
		temp++;	/* move to second letter */

		if (!*temp)		/* only one letter in temp */
			return TRUE;

		while (*s1++ == *temp++)   /* make sure all letters match */
		{
			if (!*temp)
				return TRUE;
		
			if ((!*s1) && (*temp))
				return FALSE;

		} /* while */
				

		s1--;

	} /* while */
	return(FALSE);
} /* strsubset */

char *
get_month2(num)
int num;

{
	char wait_time[5];

	wait_time[0] = '\0';

	switch (num) 
	{
         case 1:
        	strcpy(wait_time, "Jan ");
                break;
         case 2:
                strcpy(wait_time, "Feb ");
                break;
         case 3:
                strcpy(wait_time, "Mar ");
                break;
         case 4:
                strcpy(wait_time, "Apr ");
                break;
         case 5:
                strcpy(wait_time, "May ");
                break;
	 case 6:
		strcpy(wait_time, "Jun ");
		break;
	 case 7:
		strcpy(wait_time, "Jul ");
		break;
	 case 8:
		strcpy(wait_time, "Aug ");
		break;
	 case 9:
		strcpy(wait_time, "Sep ");
		break;
	 case 10:
		strcpy(wait_time, "Oct ");
		break;
	 case 11:
		strcpy(wait_time, "Nov ");
		break;
	case 12:
		strcpy(wait_time, "Dec ");
		break;
	} /* switch */

	return(wait_time);
} /* get_month2 */


int
get_fs_number(loadeddir)

/**************************************************************************/
/* this routine gets the gadget label of the given directory's fs         */
/**************************************************************************/
 
char *loadeddir;

{
	int	i;
	char	fs[DIR_LEN];

	for (i = 0; i < strlen(loadeddir); i++)  {
		fs[i] = loadeddir[i];
		if (loadeddir[i+1] == '/') {
			fs[i+1] = '\0';
			break;
		}
	}

	for (i = 0; i < num_fs; i++) {
		if (!strcmp(fs, fs_table[i].name))
		{
			return(i);
		}
	}
	return(curr_fs);
} /* get_fs_number */



scroll_to_1st_selected(fp, gadget)

Form fp;
int  gadget;

/*****************************************************************************/
/* this routine scrolls the field gadget to the first selected line          */
/*****************************************************************************/


{
	int row, num_rows, sel_flag;

	FIfld_get_num_rows(fp, gadget, &num_rows);

	for (row = 0; row < num_rows; row++) {
		FIfld_get_select(fp, gadget, row, 0, &sel_flag);

		if (sel_flag) {
			FIfld_set_active_row(fp, gadget, row, 0);
			return;
		}
	}
} /* scroll_to_1st_selected */



