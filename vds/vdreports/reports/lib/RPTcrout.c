#include	<stdio.h>
#include	<signal.h>
#include	<sys/signal.h>
#include	"RPTcode.h"

void under ()
 {
  char  title[80], subline[80];
  char  sub[2];
  int	i, l_t;
  
  popquote( sub, 2);
  popint(&l_t);
  popquote( title, l_t);

  subline[0] = 0;
  for (i=0;i<l_t;i++)
    {
     subline[i] = sub[0];
    }
  subline[l_t] = 0;

  retquote (subline, l_t);
 }


void element_desc ()
 {
  char  string[240], d1[240], d2[240], d3[240], d4[240], d5[240], d6[240];
  int   len, l[7], l_curr=0, len0=0, len1=0, len2=0, len3=0, len4=0;
  int   c[5], nc=0, i;

  d1[0] = 0;
  d2[0] = 0;
  d3[0] = 0;
  d4[0] = 0;
  d5[0] = 0;
  d6[0] = 0;
  c[0] = 0;
  c[1] = 0;
  c[2] = 0;
  c[3] = 0;
  c[4] = 0;

  popint(&len);
  popquote (string, len);

  for (i=0; i<len; i++)
    {
     if (string[i] == ',')
      {
       c[nc] = i;
       nc++;
      }
    }


  for (i=0; i<=c[0]; i++)
    d1[i] = string[i];
  d1[c[0]+1] = 0;
  nc = c[0];

  if (c[1] != 0)
   {
    for (i=c[0]+1; i<=c[1]; i++)
      d2[i-c[0]-1] = string[i];
    d2[c[1]-c[0]] = 0;

    for (i=c[1]+1; i<len; i++)
      d3[(i-c[1]-1)] = string[i];
    d3[(len-1-c[1])] = 0;
   }

  if (c[2] != 0)
   {
    for (i=c[1]+1; i<=c[2]; i++)
      d3[i-c[1]-1] = string[i];
    d3[c[2]-c[1]] = 0;

    for (i=c[2]+1; i<len; i++)
      d4[i-c[2]-1] = string[i];
    d4[len-1-c[2]] = 0;
   }

  if (c[3] != 0)
   {
    for (i=c[2]+1; i<=c[3]; i++)
      d4[i-c[2]-1] = string[i];
    d4[c[3]-c[2]] = 0;

    for (i=c[3]+1; i<len; i++)
      d5[i-c[3]-1] = string[i];
    d5[len-1-c[3]] = 0;
   }

  if (c[4] != 0)
   {
    for (i=c[3]+1; i<=c[4]; i++)
      d5[i-c[3]-1] = string[i];
    d5[c[4]-c[3]] = 0;

    for (i=c[4]+1; i<len; i++)
      d6[i-c[4]-1] = string[i];
    d6[len-1-c[4]] = 0;
   }


  l[0] = strlen(d1);
  l[1] = strlen(d2);
  l[2] = strlen(d3);
  l[3] = strlen(d4);
  l[4] = strlen(d5);
  l[5] = strlen(d6);

  
  for(i=0; i<=6; i++)
    {
     l_curr = l_curr + l[i];
     if (l_curr <= 40)
       len0 = l_curr;
     else if ((l_curr-len0) <= 37)
       len1 = l_curr;
     else if ((l_curr-len0-len1) <= 37)
       len2 = l_curr;
     else if ((l_curr-len0-len1-len2) <= 37)
       len3 = l_curr;
     else if ((l_curr-len0-len1-len2-len3) <= 37)
       len4 = l_curr;
    }

  for (i=0;i<=len0;i++)
     d1[i] = string[i];
  d1[len0+1] = 0;
  nc = len0;

  if (len1 != 0)
    {
     for (i=len0;i<len1;i++)
        d2[i-len0] = string[i];
     d2[len1-len0] = 0;
     nc = len1;
    }
  else
     d2[0] = 0;

  if (len2 != 0)
    {
     for (i=len1;i<len2;i++)
        d3[i-len1] = string[i];
     d3[len2-len1] = 0;
     nc = len2;
    }
  else
     d3[0] = 0;

  if (len3 != 0)
    {
     for (i=len2;i<len3;i++)
        d4[i-len2] = string[i];
     d4[len3-len2] = 0;
     nc = len3;
    }
  else
     d4[0] = 0;

  if (len4 != 0)
    {
     for (i=len3;i<len4;i++)
        d5[i-len3] = string[i];
     d5[len4-len3] = 0;
     nc = len4;
    }
  else
     d5[0] = 0;

  for (i=nc; i<len; i++)
     d6[i-nc] = string[i];
  d6[len-nc] = 0;

  l[1] = strlen(d1); retquote (d1, l[1]);
  l[2] = strlen(d2); retquote (d2, l[2]);
  l[3] = strlen(d3); retquote (d3, l[3]);
  l[4] = strlen(d4); retquote (d4, l[4]);
  l[5] = strlen(d5); retquote (d5, l[5]);
  l[6] = strlen(d6); retquote (d6, l[6]);
 }


void shape_determination()
 {
  char	name[20], temp[20];
  int	len, green, red, i;

  popint(&len);
  popquote (name, len);

  for (i=0;i<4;i++) temp[i] = name[i];
  temp[4] = 0;

  if      (strcmp(temp, "RECT") == 0) green = 0;
  else if (strcmp(temp, "OVAL") == 0) green = 1;
  else			              green = 2;

  retint(green);
  

  for (i=5;i<9;i++) temp[i-5] = name[i];
  temp[4] = 0;

  if      (strcmp(temp, "RECT") == 0) red = 0;
  else if (strcmp(temp, "OVAL") == 0) red = 1;
  else			              red = 2;

  retint(red);
 }


void fraction_format ()
 {
  double	number, f_val;
  int		divider, i_val, str_1, str_2;
  char		str[10];

  popint(&divider);
  popdub(&number);

/*
  printf("Enter in fraction_format with (%f/%d)\n", number, divider);
B
*/

  str_1 = number / 1.0;
  f_val = (number - str_1) * divider;
  i_val = (number - str_1) * divider;
  f_val = f_val - i_val;

  if (f_val == 0.0 && i_val == 0)
   {
    sprintf( str, "%d", str_1);
   }
  else 
   {
    if (f_val >= 0.5)
      {
       str_2 = i_val + 1;
      }
     else
      {
       str_2 = i_val;
      }

    reduction ( &str_2, &divider);

    if (str_1 == 0)
     {
      if (str_2 == 0)
        strcpy(str, "0");
      else
        sprintf( str, "%d/%d", str_2, divider);
     }
    else if (str_2 == 0)
     {
      sprintf( str, "%d",  str_1);
     }
    else
     {
      sprintf( str, "%d %d/%d",  str_1, str_2, divider);
     }

    if (divider == 1)
     {
      str_1 = str_1+1;
      sprintf( str, "%d", str_1);
     }
   }

/*
  printf("Exit from fraction_format with (%s)\n", str);
*/

  retquote( str, strlen(str));
 }


reduction ( p_number, p_divider)
  int           *p_number;
  int           *p_divider;
 {
  double        d_num;
  double        d_div;
  int           i_num;
  int           i_div;

/*
  printf("Enter in with reduction (%d/%d)\n", *p_number, *p_divider);
*/

  if (*p_number != 0)
    {
     d_num = *p_number / 2.0;
     i_num = d_num;
     d_div = *p_divider / 2.0;
     i_div = d_div;
   
     if ( ((d_num - i_num) == 0.0) && ((d_num - i_num) == 0.0) )
       {
        *p_number  = d_num;
        *p_divider = d_div;
        reduction ( p_number, p_divider);
       }
    }

/*
  printf("Exit from reduction with (%d/%d)\n", *p_number, *p_divider);
*/
 }


void length_unit_convert ()
{
  	float	input;
  	int	order;
  	int	imperial;
	int	i;
	float	factor;
	float	output;

  	popint (&imperial);
  	popint (&order);
  	popflo (&input);

	if (imperial == 1) factor = 12.0;	/* IN	-->	FT */
 	else		   factor = 1000.0;	/* MM 	-->	M  */

	output = input;

	for ( i=0; i<order; i++) output = output / factor;

  	retflo (&output);
}

void length_unit_convert1 ()
{
        float   input;
        int     order;
        int     project_units;
        int     report_units;
        int     i;
        float   factor;
        float   output;

        popint (&report_units);
        popint (&project_units);
        popint (&order);
        popflo (&input);

        if (project_units == 1 && report_units == 1) factor = 12.0;
                                                /* IN   -->     FT */
        else if (project_units == 1 && report_units != 1) factor = 39.37;
                                                /* IN   -->     M */
        else if (project_units != 1 && report_units == 1) factor = 304.8;
                                                /* IN   -->     M */
        else               factor = 1000.0;     /* MM   -->     M  */

        output = input;

        for ( i=0; i<order; i++) output = output / factor;

        retflo (&output);
}



void set_rpt_key ()
{
	char	key[KEY_LEN];
	FILE	*p_file;

  	popquote( key, KEY_LEN);

	p_file = fopen ( KEY_FILE, "w");
	if (p_file != NULL)
	  {
	   fprintf ( p_file, "%s", key);
	   fclose  ( p_file);
	  }
	else printf("Unable to open <%s> file\n", KEY_FILE);
}

get_rpt_key ()
{
	char	key[KEY_LEN];
	FILE	*p_file;

	key[0] = 0;
	p_file = fopen ( KEY_FILE, "r");
	if (p_file != NULL)
	  {
	   fgets ( key, KEY_LEN, p_file);
	   fclose  ( p_file);
	   key[3] = 0;
	  }
	else printf("Unable to open <%s> file\n", KEY_FILE);
        retquote (key, strlen(key));
}

decrypt_key ()
{
	char	key[KEY_LEN];
	char	prod[KEY_LEN];
	char	type[KEY_LEN];
	int	p;
	int	t;

  	popquote( key, KEY_LEN);

	p = t = -1;
	prod[0] = type[0] = 0;

	if ( (key[0] != 0) && (strlen(key) >=3) )
	  {
	   prod[0] = key[0]; prod[1] = key[1]; prod[2] = 0;
	   type[0] = key[2]; type[1] = 0;

	   if      (strcmp (prod, KEY_BEAM) == 0)	p = COD_BEAM;
	   else if (strcmp (prod, KEY_EQUP) == 0)	p = COD_EQUP;
	   else if (strcmp (prod, KEY_HVAC) == 0)	p = COD_HVAC;
	   else if (strcmp (prod, KEY_NOZZ) == 0)	p = COD_NOZZ;
	   else if (strcmp (prod, KEY_OVER) == 0)	p = COD_OVER;
	   else if (strcmp (prod, KEY_PLAT) == 0)	p = COD_PLAT;
	   else if (strcmp (prod, KEY_PIPE) == 0)	p = COD_PIPE;
	   else if (strcmp (prod, KEY_RWAY) == 0)	p = COD_RWAY;
	   else if (strcmp (prod, KEY_STBP) == 0)	p = COD_STBP;
	   else if (strcmp (prod, KEY_VDSP) == 0)	p = COD_VDSP;
	   else if (strcmp (prod, KEY_COMP) == 0)	p = COD_COMP;
	   else printf ("Unknown product key : <%s>\n", prod);
	   retint(p);

	   if      (type[0] == KEY_BOM)		t = COD_BOM;
	   else if (type[0] == KEY_DAT)		t = COD_DAT;
	   else if (type[0] == KEY_DWG)		t = COD_DWG;
	   else if (type[0] == KEY_ERR)		t = COD_ERR;
	   else if (type[0] == KEY_NST)		t = COD_NST;
	   else if (type[0] == KEY_REF)		t = COD_REF;
	   else if (type[0] == KEY_VDS)		t = COD_VDS;
	   else if (type[0] == KEY_VLV)		t = COD_VLV;
	   else if (type[0] == KEY_WGT)		t = COD_WGT;
	   else if (type[0] == KEY_TRK)         t = COD_TRK;
	   else if (type[0] == KEY_SPC)         t = COD_SPC;
	   else printf ("Unknown type key : <%s>\n", type);
	   retint(t);
	  }
}

void stopctrlz()
{
        signal( SIGTSTP, SIG_IGN );
}

