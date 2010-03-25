#include	<stdlib.h>
#ifdef SunOS_4
#include <5curses.h>
#else
#include <curses.h>
#endif
#include "main.h"

extern	int	search_from_start;
extern  int	pageno;
extern	long	offsets[MAXPAGE];
extern	long	sect_offsets[MAXSECTIONS][MAXSPAGE];

char	sect_array[MAXSECTIONS][MAXSECTION_LEN+1];
int	num_sections=1;
int	sect_page;
char	last_word[MAXLINE] = { '\0' };
long	last_found = 0;
int	last_count = 0;
int	last_p_bytes = 0;

int	found_end_of_section = FALSE;
int	displaying_a_section = FALSE;

/*
 * This module contains routines that manipulate the README browser
 *
 * find_section		finds the named section and displays it
 * entire_readme	shows the entire readme file on the form
 * search_forward	finds the next occurance of the given word
 * save_to_file		save the display to the specified file
 */


void
fix_line(s)
char	*s;		/* string to be changed */

/************************************************************************/
/* this procedure changes all of the tabs in s to the correct number of */
/* spaces                                                               */
/************************************************************************/

{
    char	*tmp, *holder;		/* strings, pieces of the whole */
    int		colcount;		/* index                        */
    
    s[strlen(s) - 1] = '\0';
    
    colcount = 0;  /* set current column to begining */
    
    holder = (char*) calloc(1, MAXLINE +1);	
    if (!holder) {
	fprintf(stderr, "Error : memory allocation");
	return;
    } /* if */
    
    tmp = s;
    
    
    while (*tmp) {
	if (*tmp == '\t') {
	    strcpy(holder, tmp+1);	/* hold rest of string */
	    
	    do {	/* put spaces over to multiple of 8 */
		*tmp++ = ' ';
		++colcount;
	    } while (colcount % 8);
	    
	    *tmp = '\0';
	    
	    strcat(tmp, holder);	/* attach rest of string */
	    
	} /* if */
	
	else {
	    ++colcount;
	    tmp++;
	} /* else */
    } /* while */
} /* fix_line */


void
cap_case(s)
char *s;	/* string to be changed */

/************************************************************/
/* this function changes string s to be all capital letters */
/************************************************************/

{
    char	*tmp;	/* temp pointer to the string */
    
    tmp = s;
    
    while (*tmp) {
	/* *tmp = cap(*tmp);   change each letter */
	*tmp = toupper(*tmp);
	*tmp++;
    } /* while */
    
} /* cap_case */


int show_current(top, filename)

WINDOW	*top;
char	*filename;

{
    static char	prodname[20], prodtitle[80];
    static char	prodversion[15];
    FILE	*of;
    char	line[MAXLINE*2], tmp[MAXLINE * 2];
    char	*tp;
    
    if (NULL == (of = fopen(filename, "r"))) {
	printf("Can not read file: %s\n", filename);
	exit(1);
    } /* if */
    
    prodname[0] = '\0';
    prodtitle[0] = '\0';
    prodversion[0] = '\0';
    
    while (fgets(line, MAXLINE, of)) {
	fix_line(line);
	strcpy(tmp, line);
	cap_case(tmp);
	
	/* Skip leading spaces */
	tp = tmp;
	while ((*tp == ' ') || (*tp == '\t'))
	    tp++;
	
	if (!(strncmp(tp, "PRODUCT:", strlen("PRODUCT:")))) {
	    get_second_word(tp, prodname);
	    get_descr(tp, prodtitle);
	} /* if */
	if (!(strncmp(tp, "VERSION:", strlen("VERSION:"))))
	    get_second_word(tp, prodversion);
	
	if (!(strncmp(tp, "END OF VERSION INFORMATION",
		      strlen("END OF VERSION INFORMATION"))))
	    break;
	
    } /* while */
    
    if (prodname[0] != '\0') 
	mvwprintw(top, 1, 1, "%s:", prodname);
    
    if (prodtitle[0] != '\0')
	mvwprintw(top, 1, 15, "%s", prodtitle); 
    
    mvwaddstr(top, 2, 1, "Version:");
    
    if (prodversion[0] != '\0')
	mvwprintw(top, 2, 15, "%s", prodversion);
    
    wrefresh(top);
    fclose(of);
    return TRUE;
} /* show_current */


get_second_word(from_str, to_str)

char	*from_str;
char	*to_str;

{
    int	i, j;
    
    i = 0;
    to_str[0] = '\0';

    /* read the first word */
    while ((from_str[i] != ' ') && (from_str[i] != '\t') && from_str[i]) 
	i++;
    
    if (from_str[i] == '\0')
	return;

    /* skip the spaces */
    while ((from_str[i] == ' ') || (from_str[i] == '\t'))
	i++;
    
    if (from_str[i] == '\0')
	return;

    /* now we're on the second word */
    
    j = 0;
    while ((from_str[i] != ' ') && (from_str[i] != '\t') && 
	   (from_str[i] != '\n') && (from_str[i] != '\0')) {
	to_str[j] = from_str[i];
	i++;
	j++;
    } /* while */
    to_str[j] = '\0';
} /* get_second_word */



get_descr(from_str, to_str)

char	*from_str;
char	*to_str;

{
    int	i, j;
    
    i = 0;
    to_str[0] = '\0';

    /* read the first word */
    while ((from_str[i] != ' ') && (from_str[i] != '\t') && from_str[i]) 
	i++;
    
    if (from_str[i] == '\0')
	return;

    /* skip the spaces */
    while ((from_str[i] == ' ') || (from_str[i] == '\t'))
	i++;
    
    if (from_str[i] == '\0')
	return;

    /* read the second word */
    while ((from_str[i] != ' ') && (from_str[i] != '\t') && from_str[i])
	i++;
    
    if (from_str[i] == '\0')
	return;

    /* skip the spaces */
    while ((from_str[i] == ' ') || (from_str[i] == '\t'))
	i++;
    
    if (from_str[i] == '\0')
	return;

    /* now we're on the third word */
    
    j = 0;
    while ((from_str[i] != '\n') && (from_str[i] != '\0')) {
	to_str[j] = from_str[i];
	i++;
	j++;
    } /* while */
    to_str[j] = '\0';
} /* get_descr */



get_sections(filename)

char	*filename;

/* can you say state machine? */

{
    char	inputstr[MAXLINE], tmp[MAXLINE], curr_section[MAXSECTION_LEN];
    char	*tp;
    extern	char *strrchr();
    int		page = 0, sect_page = 0, line = 0, sline = 0;
    int		sect_index = 1;
    int		state = 1, good_stuff;
    FILE	*of;
    long	bookmark;
    
    if ((of = fopen(filename, "r")) == NULL) {
	return;
    }
    
    strcpy(sect_array[0], "Entire README");
    
    while (state == 1) {
	/* state #1 -- waiting for dashes */
	
	while (fgets(inputstr, MAXLINE, of)) {
	    
	    line++;
	    if (((line % (LINES - 11)) == 0) && (offsets[page+1] == -1))
		offsets[++page] = ftell(of);
	    
	    if (!(strncmp(inputstr, "---", 3)))
		break;
	} /* while */
	
	/* state #2 -- looking for PRODUCT SECTIONS of other sections */
	
	if (!(fgets(inputstr, MAXLINE, of))) {
	    fclose(of);
	    return;
	}
	
	line++;
	if (((line % (LINES - 11)) == 0) && (offsets[page+1] == -1))
	    offsets[++page] = ftell(of);
	
	strcpy(tmp, inputstr);
	cap_case(tmp);
	if (!(strncmp(tmp, "PRODUCT SECTIONS", strlen("PRODUCT SECTIONS"))))
	    state = 3;
	else {
	    tp = strrchr(inputstr, '\n');
	    if (tp != NULL)
		*tp = '\0';
	    strcpy(curr_section, inputstr);
	    state = 5;
	} /* else */
	
	if (!(fgets(inputstr, MAXLINE, of))) {  /* make sure the next line is dashes */
	    fclose(of);
	    return;
	}
	
	line++;
	if (((line % (LINES - 11)) == 0) && (offsets[page+1] == -1))
	    offsets[++page] = ftell(of);
	
	if (strncmp(inputstr, "---", 3)) {
	    fclose(of);
	    return;
	}
	
	if (state == 5) {
	    sect_page = 0;
	    sline = 0;
	    sect_offsets[sect_index][0] = ftell(of);
	}
	
	good_stuff = FALSE;
	while ((state == 3) || (state == 5)) {
	    /* state #3 -- within PRODUCT SECTIONS get the sections */
	    /* state #5 -- within normal section get the stuff */
	    /* make sure that there is stuff here */
	    
	    if (!(fgets(inputstr, MAXLINE, of))) {
		fclose(of);
		return;
	    }
	    
	    line++;
	    if (((line % (LINES - 11)) == 0) && (offsets[page+1] == -1)) 
		offsets[++page] = ftell(of);
	    
	    sline++;
	    if (((sline % (LINES - 11)) == 0) &&
		(sect_offsets[sect_index][sect_page+1] == -1)) 
		sect_offsets[sect_index][++sect_page] = ftell(of);
	    
	    if (!(strncmp(inputstr, "---", 3))) {
		bookmark = ftell(of);
		if (!(fgets(inputstr, MAXLINE, of))) {
		    fclose(of);
		    return;
		}
		else {
		    line++;
		    if (((line % (LINES - 11)) == 0) && (offsets[page+1] == -1)) 
			offsets[++page] = ftell(of);
			
		    strcpy(tmp, inputstr);
		    cap_case(tmp);
		    if (strncmp(tmp, "END OF", strlen("END OF"))) {
			fseek(of, bookmark, 0);
			sline++;
			if (((sline % (LINES - 11)) == 0) &&
			    (sect_offsets[sect_index][sect_page+1] == -1)) 
			    sect_offsets[sect_index][++sect_page] = ftell(of);
			continue;
		    }
		    else { 
			break;
		    }
		}
	    }
	    else if (inputstr[0] != '\n')
		good_stuff = TRUE;
	} /* while */
	
	if ((good_stuff) && (state == 5)) {
	    num_sections = sect_index;
	    strcpy(sect_array[sect_index], curr_section);
	    sect_index++;
	} /* if */
	
    /* state #7 -- what happened to #6 and #4 */
	
	if (!(fgets(inputstr, MAXLINE, of))) {
	    fclose(of);
	    return;
	}
	
	line++;
	if (((line % (LINES - 11)) == 0) &&
	    (offsets[page+1] == -1)) 
	    offsets[++page] = ftell(of);
	
	if (strncmp(inputstr, "---", 3)) {
	    fclose(of);
	    return;
	}
	
	state = 1;
    } /* while */
    
    fclose(of);
} /* get_sections */


void
write_section(bot, i)
WINDOW	*bot;
int	i;

{
    werase(bot);
    mvwaddstr(bot, 1, 1, "Section:");
    mvwprintw(bot, 1, 12, "%s", sect_array[i]); 
#ifndef MY_OWN_BOX
    box(bot, 0, 0);
#else
    my_box(bot, ACS_VLINE, ACS_HLINE);
#endif
    wnoutrefresh(bot);
    doupdate();
} /* write_section */



#ifdef SUPERFLUOUS
int cap(c)
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




int strsubset(s1,s2)
char 	*s1;	/* the big string */
char	*s2;	/* the sub string */

/******************************************************************/
/* this procedure returns true if s2 is a subset of s1, otherwise */
/* it returns false                                               */
/******************************************************************/

{
    char	*temp;		/* temp pointer to string s2 */
    
    while (*s1) {
	temp = s2;
	
	/* find the first matching letter */
	while ((*s1++ != *temp) && (*s1)){} 
	
	if (!(*s1--))	/* not even one matching letter */
	    return FALSE;
	
	s1++;
	temp++;	/* move to second letter */
	
	if (!*temp)		/* only one letter in temp */
	    return TRUE;
	
	while (*s1++ == *temp++) {   /* make sure all letters match */
	    if (!*temp)
		return TRUE;
	    
	    if ((!*s1) && (*temp))
		return FALSE;
	} /* while */
	
	s1--;
    } /* while */
    return FALSE;
} /* strsubset */

#endif /* SUPERFLUOUS */

find_section(win, sect_ind, of)
WINDOW	*win;
int	sect_ind;
FILE	*of;

/*****************************************************************************/
/* this routine finds sect in the readme file and displays just that section */
/*****************************************************************************/

{
    char	line1[MAXLINE], line2[MAXLINE];
    char	tmp[MAXSECTION_LEN], tmp2[MAXLINE];
    int	found, row;
    int	prod_section;
    
    wmove(win, 0, 1);
    werase(win);
    found_end_of_section = FALSE;
    
    strcpy(tmp, sect_array[sect_ind]);
    
    tmp2[0] = '\0';
    strcat(tmp2, "END OF ");
    strcat(tmp2, tmp);
    
    if (displaying_a_section) {  /* if we are in the middle of showing */
	/* a section then we do not need to   */
	found = TRUE;
    }
    else {			     /* find the beginning                 */
	found = FALSE;
    }
    
    prod_section = FALSE;
    row = 1;
    
    fseek(of, sect_offsets[sect_ind][sect_page], 0);
    
    while(fgets(line1, MAXLINE, of)) {
	strcpy(line2, line1);		 /* line2 is caps */
	
	cap_case(line2);
	cap_case(tmp);    /* tmp is section name */
	cap_case(tmp2);   /* tmp2 is endof section name */
	
	if (!(strncmp(line2, tmp2, strlen(tmp2)))) {
	    /* erase that line of dashes and then quit */
	    wmove(win, row-1, 1);
	    wclrtoeol(win);
	    found_end_of_section = TRUE;
	    break;
	}
	
	if (row >= (LINES-10))
	    break;
	
	mvwprintw(win, row++, 1, "%s", line1); 
    }
    
#ifndef MY_OWN_BOX
    box(win, 0, 0);
#else
    my_box(win, ACS_VLINE, ACS_HLINE);
#endif
    if (!found_end_of_section)
	mvwaddch(win, LINES-10, 2, ACS_DARROW);
    
    if (sect_page > 0) 
	mvwaddch(win, 0, 2, ACS_UARROW);
    
    wnoutrefresh(win);
    doupdate();
} /* find_section */




int  search_forward(rm, word, fd, recurs)

WINDOW	*rm;
char	*word;
FILE	*fd;
int	recurs;

/***************************************************************************/
/* count the number of lines to move to find the word                      */
/***************************************************************************/

{
    int	count, page_bytes;
    char	line[MAXLINE];
    char	tmp_word[MAXLINE];
    int	found;
    int	spage;
    long	currloc;
    
    if (*word == '\0') {
	if (*last_word == '\0') 
	    return(TRUE);
	else
	    strcpy(word, last_word);
    }
    
    strcpy(tmp_word, word);
    cap_case(tmp_word);
    
    found = FALSE;
    
    if (strcmp(word, last_word) != 0 || recurs) {
	fseek(fd, offsets[pageno], 0);
	count = 1;
	page_bytes = 0;
    }
    else {
	fseek(fd, last_found, 0);
	count = last_count;
	page_bytes = last_p_bytes;
    }
    
    while (NULL != (fgets(line, MAXLINE, fd))) {
	cap_case(line);
	
	if (count < (LINES-11)) {
	    page_bytes += strlen(line);
	    count++;
	}
	else {
	    page_bytes = strlen(line); 
	    count = 1;
	}
	
	/*		if (strsubset(line, tmp_word)) */
	if (strstr(line, tmp_word)) {
	    found = TRUE;
	    break;
	} /* if */
    } /* while */
    
    if (!found) {  /* if it was not found, backup and start at the beginning */
	if (search_from_start)
	    return(FALSE); 
	
	rewind(fd);
	pageno = 0;
	search_from_start = TRUE;
	search_forward(rm, word, fd, 1);
    }
    else {  /* if it was found, back up and display the right page */
	strcpy(last_word, word);
	currloc = ftell(fd);
	last_found = currloc;
	
	last_count = count;
	last_p_bytes = page_bytes;
	
	for (spage = 0; offsets[spage] != -1; spage++) {
	    if ((offsets[spage+1] > currloc) ||
		(offsets[spage+1] == -1))
		break;
	}
	pageno = spage;
	fseek(fd, offsets[pageno], 0);
	
	search_page(rm, fd, count-1);
	search_from_start = FALSE;
	return(TRUE);
    } /* else */
} /* search_forward */



save_to_file(fd, sect_ind, filenm)

FILE	*fd;
int	sect_ind;
char	*filenm;

/**************************************************************************/
/* this routine saves the contents of the display to the file             */
/**************************************************************************/

{
    FILE	*of;
    char	line1[MAXLINE], line2[MAXLINE];
    char	tmp[MAXSECTION_LEN], tmp2[MAXLINE];
    int		found;
    int		prod_section;
    
    if (NULL == (of = fopen(filenm, "w")))
	return;
    
    strcpy(tmp, sect_array[sect_ind]);
    cap_case(tmp);    /* tmp is section name */
    
    tmp2[0] = '\0';
    strcat(tmp2, "END OF ");
    strcat(tmp2, tmp);
    cap_case(tmp2);   /* tmp2 is endof section name */

    prod_section = FALSE;
    found = FALSE;
    
    while (fgets(line1, MAXLINE, fd)) {
	strcpy(line2, line1);		 /* line2 is caps */
	cap_case(line2);
	
	/* skip over the product sections section */
	
	if ((prod_section) && (strncmp(line2, "END OF PRODUCT SECTIONS",
				       strlen("END OF PRODUCT SECTIONS"))))
	    continue;
	else
	    prod_section = FALSE;
	
	if (!(strncmp(line2, "PRODUCT SECTIONS", strlen("PRODUCT SECTIONS")))) {
	    prod_section = TRUE;
	    continue;
	} /* if */
	
	if (!strncmp(line2, tmp, strlen(tmp))) {
	    fgets(line1, MAXLINE, fd);
	    if (!(strncmp(line1, "---", 3))) {
		found = TRUE;
		fgets(line1, MAXLINE, fd);
	    } /* if */
	} /* if */
	else if (!strncmp(line2, tmp2, strlen(tmp2)))
	    break;
	
	if (found) {
	    fputs(line1, of);
	    if (line1[strlen(line1) -1] != '\n')
		fputs("\n", of);
	} /* if */
    } /* while */
    
    fclose(of);
} /* save_it */













