#include "main.h"

int	last_readme_row = 0;

/*
 * This module contains routines that manipulate the README browser
 *
 * find_section		finds the named section and displays it
 * entire_readme	shows the entire readme file on the form
 * search_forward	finds the next occurance of the given word
 * search_backward	finds the last occurance of the given word
 * save_to_file		save the display to the specified file
 * get_sections		gets all of the sections in the file
 */

extern Form statform;


find_section(fp, sect)

Form	fp;
char	*sect;

/*****************************************************************************/
/* this routine finds sect in the readme file and displays just that section */
/*****************************************************************************/

{
	char	line1[MAXLINE], line2[MAXLINE];
	char	tmp[MAXLINE], tmp2[MAXLINE];
	FILE	*of, *fopen();
	int	found, row;
	int	prod_section;

	if (NULL == (of = fopen("/tmp/README", "r")))
		return;

	strcpy(tmp, sect);
	tmp2[0] = '\0';
	strcat(tmp2, "END OF ");
	strcat(tmp2, tmp);

	FIg_reset(fp, README);

	FIg_erase(fp, RM_TEXT);
	FIg_set_text(fp, RM_TEXT, sect);
	FIg_display(fp, RM_TEXT);
	
	found = FALSE;
	prod_section = FALSE;
	row = 0;

	while (fgets(line1, MAXLINE, of))
	{
		line1[strlen(line1) - 1] = '\0';  /* line1 is pristine text */
		strcpy(line2, line1);		 /* line2 is caps */

		cap_case(line2);
		cap_case(tmp);
		cap_case(tmp2);

		/* skip over the product sections section */

		if ((prod_section) && (strncmp(line2, "END OF PRODUCT SECTIONS",
			strlen("END OF PRODUCT SECTIONS"))))
			continue;
		else
			prod_section = FALSE;

		if (!(strncmp(line2, "PRODUCT SECTIONS", strlen("PRODUCT SECTIONS"))))
		{
			prod_section = TRUE;
			continue;
		} /* if */

		if (!(strcmp(line2, tmp)))
		{
			fgets(line1, MAXLINE, of);
			if (!(strncmp(line1, "---", 3)))
			{
				found = TRUE;
				fgets(line1, MAXLINE, of);
			} /* if */
		} /* if */
		else if (!(strcmp(line2, tmp2)))
		{
			/* erase that line of dashes and then quit */
			FIfld_set_text(fp, README, row-1, 0, " ", FALSE);
			break;
		} /* else if */

		if (found)
		{
			fix_line(line1);
			FIfld_set_text(fp, README, row++, 0, line1, FALSE);
		} /* if */

	} /* while */
	fclose(of);
} /* find_section */



entire_readme(fp)

Form fp;

/****************************************************************************/
/* this routine displays the entire readme file on the form                 */
/****************************************************************************/

{
	char	line[MAXLINE];
	FILE	*of, *fopen();
	int	row;

	if (NULL == (of = fopen("/tmp/README", "r")))
		return;

	FIg_reset(fp, README);

	FIg_erase(fp, RM_TEXT);
	FIg_set_text(fp, RM_TEXT, "README:");
	FIg_display(fp, RM_TEXT);
	
	row = 0;

	while (fgets(line, MAXLINE, of))
	{
		line[strlen(line) - 1] = '\0';

		fix_line(line);
		FIfld_set_text(fp, README, row++, 0, line, FALSE);
	} /* while */
	fclose(of);
} /* entire_readme */



search_forward(fp, word)

Form	fp;
char	*word;

/***************************************************************************/
/* this routine searches forward in the text to find word. It wraps        */
/* around to the beginning if the word cannot be found from the current pos*/
/***************************************************************************/

{
	int	row, pos, off, len, flag;
	int	count;
	char	line[MAXLINE];
	char	tmp_word[MAXLINE];

	strcpy(tmp_word, word);

	FIg_reset(statform, MESSBOX);

	FIfld_get_active_row(fp, SECTIONS, &row, &pos);

	if (row != 0)			/* display all of README */
	{
		FIfld_set_select(fp, SECTIONS, 0, 0, TRUE);
		FIfld_set_active_row(fp, SECTIONS, 0, 0);
		FIfld_set_text(statform, MESSBOX, 0, 0,
			"Searching the entire README...", FALSE);
		entire_readme(fp);
		FIg_reset(statform, MESSBOX);
	} /* if */

	FIfld_get_num_rows(fp, README, &row);
	FIfld_get_select(fp, README, last_readme_row, 0, &flag);

	if (!flag)     /* find the current position */
		FIfld_get_row_offset(fp, README, &off);
	else
		off = last_readme_row +1;

	for (count = off; count < row; count++)  /* look forward form current pos */
	{
		FIfld_get_text_length(fp, README, count, 0, &len);
		FIfld_get_text(fp, README, count, 0, len, line, &flag, &pos);

		cap_case(line);
		cap_case(word);

/*		if (strsubset(line, word)) */
		if (strstr(line, word))
		{
			last_readme_row = count;
			if ((row > 20) && (count > 15))
			{
				FIfld_set_active_row(fp, README, count, 5);
				FIfld_set_select(fp, README, count, 0, TRUE);
			} /* if */
			else
				FIfld_set_select(fp, README, count, 0, TRUE);
			break;			
		} /* if */
	} /* for */

	if (count >= row)   /* we need to wrap around */
	{
		for (count = 0; count < off; count++)
		{
			FIfld_get_text_length(fp, README, count, 0, &len);
			FIfld_get_text(fp, README, count, 0, len, line, &flag, &pos);

			cap_case(line);
			cap_case(word);

/*			if (strsubset(line, word)) */
			if (strstr(line, word))
			{
				last_readme_row = count;
				FIfld_set_active_row(fp, README, count, 5);
				FIfld_set_select(fp, README, count, 0, TRUE);
				break;			
			} /* if */
		} /* for */

		if (count >= off)	/* can't find it */
		{
			sprintf(line, "Cannot find %s", tmp_word);
			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		} else 
			FIfld_set_text(statform, MESSBOX, 0, 0, 
				"Wrapped to beginning of file to find text", FALSE);
	} /* if */
} /* search_forward */



search_backward(fp, word)

Form	fp;
char	*word;

/***************************************************************************/
/* this routine searches backward in the text to find word. It wraps       */
/* to the end of the file if the word cannot be found before the current pos */
/***************************************************************************/

{
	int	row, pos, off, len, flag;
	int	count;
	char	line[MAXLINE];
	char	tmp_word[MAXLINE];

	strcpy(tmp_word, word);

	FIg_reset(statform, MESSBOX);

	FIfld_get_active_row(fp, SECTIONS, &row, &pos);

	if (row != 0)			/* display all of README */
	{
		FIfld_set_select(fp, SECTIONS, 0, 0, TRUE);
		FIfld_set_active_row(fp, SECTIONS, 0, 0);
		FIfld_set_text(statform, MESSBOX, 0, 0,
			"Searching the entire README...", FALSE);
		entire_readme(fp);
		FIg_reset(statform, MESSBOX);
	} /* if */

	FIfld_get_num_rows(fp, README, &row);
	FIfld_get_select(fp, README, last_readme_row, 0, &flag);

	if (!flag)        /* find the current position */
		FIfld_get_row_offset(fp, README, &off);
	else
		off = last_readme_row -1;
	
	for (count = off; count > 0; count--) /* go backword from current pos */
	{
		FIfld_get_text_length(fp, README, count, 0, &len);
		FIfld_get_text(fp, README, count, 0, len, line, &flag, &pos);

		cap_case(line);
		cap_case(word);

/*		if (strsubset(line, word)) */
		if (strstr(line, word))
		{
			last_readme_row = count;
			if ((row > 20) && (count > 15))
			{
				FIfld_set_active_row(fp, README, count, 5);
				FIfld_set_select(fp, README, count, 0, TRUE);
			} /* if */
			else
				FIfld_set_select(fp, README, count, 0, TRUE);
			break;			
		} /* if */
	} /* for */

	if ((count == 0) && (off < row))   /* we need to wrap around */
	{
		for (count = row; count > off; count--)
		{
			FIfld_get_text_length(fp, README, count, 0, &len);
			FIfld_get_text(fp, README, count, 0, len, line, &flag, &pos);

			cap_case(line);
			cap_case(word);

/*			if (strsubset(line, word)) */
			if (strstr(line, word))
			{
				last_readme_row = count;
				FIfld_set_active_row(fp, README, count, 5);
				FIfld_set_select(fp, README, count, 0, TRUE);
				break;			
			} /* if */
		} /* for */
	
		if (count <= off)	/* can't find it */
		{
			sprintf(line, "Cannot find %s", tmp_word);
			FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
		} else
			FIfld_set_text(statform, MESSBOX, 0, 0,
				"Wrapped to end of file to find text", FALSE);
	} /* if */
} /* search_backward */



save_to_file(fp, filename)

Form	fp;
char	*filename;

/**************************************************************************/
/* this routine saves the contents of the display to the file             */
/**************************************************************************/

{
	char	line[MAXLINE];
	FILE	*of, *fopen();
	int	row, count, len, flag, pos;

	FIg_reset(statform, MESSBOX);

	if (NULL == (of = fopen(filename, "w")))
	{
		FIfld_set_text(statform, MESSBOX, 0, 0, "Failed to create file",
			FALSE);
		return;
	} /* if */

	FIfld_get_num_rows(fp, README, &row);

	for(count = 0; count < row; count++)
	{
		FIfld_get_text_length(fp, README, count, 0, &len);
		FIfld_get_text(fp, README, count, 0, len, line, &flag, &pos);
		fputs(line, of);
		if (line[strlen(line) -1] != '\n')
			fputs("\n", of);
	} /* while */

	fclose(of);
	
	sprintf(line, "Saved display to %s", filename);
	FIfld_set_text(statform, MESSBOX, 0, 0, line, FALSE);
} /* save_it */


get_sections(fp, of)

Form	fp;
FILE	*of;

/**************************************************************************/
/* this routine is a state machine that gets all of the sections out of   */
/* the README file: product defined and the usual sections                */
/**************************************************************************/

{
	char	instr[MAXLINE], tmp[MAXLINE], curr_section[MAXLINE];
	int	row = 0, sec_row = 1;
	int	state = 1, good_stuff;

	FIg_reset(fp, README);

  while (state == 1)
  {
	/* state #1 -- waiting for dashes */

	while (fgets(instr, MAXLINE, of))
	{
		fix_line(instr);
		FIfld_set_text(fp, README, row++, 0, instr, FALSE);
		if (!(strncmp(instr, "---", 3)))
			break;
	} /* while */

	/* state #2 -- looking for PRODUCT SECTIONS of other sections */

	if (!(fgets(instr, MAXLINE, of)))
		return;
	fix_line(instr);
	FIfld_set_text(fp, README, row++, 0, instr, FALSE);
	strcpy(tmp, instr);
	cap_case(tmp);
	if (!(strncmp(tmp, "PRODUCT SECTIONS", strlen("PRODUCT SECTIONS"))))
		state = 3;
	else
	{
		instr[strlen(instr) -1] = '\0';
		strcpy(curr_section, instr);
		state = 5;
	} /* else */

	if (!(fgets(instr, MAXLINE, of)))   /* make sure the next line is dashes */
		return;
	fix_line(instr);
	FIfld_set_text(fp, README, row++, 0, instr, FALSE);
	if (strncmp(instr, "---", 3))
	{
		entire_readme(fp);
		return;
	}

	good_stuff = FALSE;
	while ((state == 3) || (state == 5))
	{
		/* state #3 -- within PRODUCT SECTIONS get the sections */
		/* state #5 -- within normal section get the stuff */
		/* make sure that there is stuff here */

		if (!(fgets(instr, MAXLINE, of)))
			return;
		fix_line(instr);

		FIfld_set_text(fp, README, row++, 0, instr, FALSE);

		if (!(strncmp(instr, "---", 3)))
			break;
		else if (instr[0] != '\n')
			good_stuff = TRUE;
	} /* while */

	if ((good_stuff) && (state == 5))
		FIfld_set_text(fp, SECTIONS, sec_row++, 0, curr_section, FALSE);
	
	/* state #7 -- what happened to #6 and #4*/
	if (!(fgets(instr, MAXLINE, of)))
		return;
	
	fix_line(instr);
	FIfld_set_text(fp, README, row++, 0, instr, FALSE);
	strcpy(tmp, instr);
	cap_case(tmp);
	if (strncmp(tmp, "END OF", strlen("END OF")))
	{
		entire_readme(fp);
		return;
	}

	if (!(fgets(instr, MAXLINE, of)))
		return;

	fix_line(instr);
	FIfld_set_text(fp, README, row++, 0, instr, FALSE);
	if (strncmp(instr, "---", 3))
	{
		entire_readme(fp);
		return;
	}

	state = 1;
  } /* while */

	fclose(of);
} /* get_sections */
