# include "stdio.h"
# define U(x) x
# define NLSTATE vdyyprevious=VDYYENEWLINE
# define BEGIN vdyybgin = vdyysvec + 1 +
# define INITIAL 0
# define VDYYELERR vdyysvec
# define VDYYESTATE (vdyyestate-vdyysvec-1)
# define VDYYEOPTIM 1
# define VDYYELMAX 200
# define output(c) putc(c,vdyyout)
# define input() (((vdyytchar=vdyysptr>vdyysbuf?U(*--vdyysptr):getc(vdyyin))==10?(vdyylineno++,vdyytchar):vdyytchar)==EOF?0:vdyytchar)
# define unput(c) {vdyytchar= (c);if(vdyytchar=='\n')vdyylineno--;*vdyysptr++=vdyytchar;}
# define vdyymore() (vdyymorfg=1)
# define ECHO fprintf(vdyyout, "%s",vdyytext)
# define REJECT { nstr = vdyyreject(); goto vdyyfussy;}
int vdyyleng; extern char vdyytext[];
int vdyymorfg;
extern char *vdyysptr, vdyysbuf[];
int vdyytchar;
FILE *vdyyin = {stdin}, *vdyyout = {stdout};
extern int vdyylineno;
struct vdyysvf { 
	struct vdyywork *vdyystoff;
	struct vdyysvf *vdyyother;
	int *vdyystops;};
struct vdyysvf *vdyyestate;
extern struct vdyysvf vdyysvec[], *vdyybgin;
/*---------------------------------------------------------------------------*/
/*-----|VDregexp.l   Regles de syntaxe d'une expression              |----*/
/*---------------------------------------------------------------------------*/

/* #define DEBUG  */

/* Two constant for state */
#include "VDmsg.h"
#define NEGATION 1        /* The next input will be in negative list */
#define NORMAL   0

/* Two constant for call to fill_reg */
#define EXPAND 1
#define FILL_TABLE 2

#define EXP_MAX_LEN 128

/* vdvdyylex() always return 0 ; permit to signal some unexpected in vdvdyylex()*/  
int the_lex_return;  


extern char    *VDinput_stream /* keyboard line simulation */;
extern int     VDinput_index;

extern char **VDreg,**VDNreg;
extern int VDcur_ln,VDnb_alloc_ln, VDNcur_ln,VDNnb_alloc_ln;

/* extern fill_reg(char *,int ,char *,char *,char ***,int *,int *); */

static int state = NORMAL;

static char prefix[EXP_MAX_LEN],suffix[EXP_MAX_LEN];
char *lex_errmsg;
long lex_errkey;

int vdyywrap() {
#  	ifdef DEBUG
	printf("C'est fini\n");
#  	endif
        state = NORMAL;
  	BEGIN 0;  /* Very important if more than one call */
        return( 1 ) ;
        }



/*===== to replace the getc ================================================*/
char    vdgetc ( vdyyin )
FILE *vdyyin;
{
  if ((VDinput_index < 0) || (VDinput_index == strlen ( VDinput_stream )))
    return ( -1 );
  else
    return ( VDinput_stream [VDinput_index++] );
}
/*==========================================================================*/
#undef input
# define input() (((vdyytchar=vdyysptr>vdyysbuf?U(*--vdyysptr)\
                                         :vdgetc(vdyyin))==10\
                                             ?(vdyylineno++,vdyytchar)\
                                             :vdyytchar)==EOF?0:vdyytchar)
                 
# define C_EXP_AN 2
# define C_CRO_N 4
# define ALL_FALSE 6
# define VDYYENEWLINE 10
vdyylex(){
int nstr; extern int vdyyprevious;
while((nstr = vdyylook()) >= 0)
vdyyfussy: switch(nstr){
case 0:
if(vdyywrap()) return(0); break;
case 1:
{
#ifdef DEBUG
      printf("Etat tout faux , ignore input <%s>\n",vdyytext);
#endif
   BEGIN ALL_FALSE;
}
break;
case 2:
{
#ifdef DEBUG
   printf("Expression negation\n");
#endif
    lex_errkey = VD_E_LocNegCom;
    the_lex_return = 1;
    BEGIN ALL_FALSE;
}
break;
case 3:
{
#ifdef DEBUG
   printf("crochet negation\n");
#endif
  lex_errkey = VD_E_LocNegCom;
  the_lex_return = 1;
  BEGIN ALL_FALSE;
}
break;
case 4:
{
#ifdef DEBUG
     printf("Regle negation\n");
#endif
   if(state == NEGATION){
       lex_errkey = VD_E_LocTwoNeg;
       the_lex_return = 1;
       BEGIN ALL_FALSE;
    }
   else 
   {  
      state = NEGATION;
      BEGIN 0;
   }
}
break;
case 5:
{
#  ifdef DEBUG
   printf("regle 1 ter, text: <%s>\n", vdyytext); 
#  endif
   
    /* In this case prefix contain the C_CRO_N */
   if(state == NORMAL)
       fill_reg(prefix,EXPAND,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
   else {
        fill_reg(prefix,EXPAND,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
        state = NORMAL;
      }
   BEGIN 0;
 }
break;
case 6:
{
#  ifdef DEBUG
   printf("regle 1 bis, text: <%s>\n", vdyytext); 
#  endif
   /* First verify it is follow by one of the 5 chars for end of expression  
      It would be better to do it in lex vocabulary but the end of string
      seems to pose problem */            
    input();
    if(vdyytchar == '\0' || vdyytchar == ',' || vdyytchar == '\b' 
      || vdyytchar == '\t' || vdyytchar == '\n')
      {
      /* In this case prefix contain the C_CRO_N and vdyytext the EXP_AN */
      if(state == NORMAL)
       fill_reg(prefix,EXPAND,"",vdyytext,&VDreg,&VDcur_ln,&VDnb_alloc_ln);
      else {
        fill_reg(prefix,EXPAND,"",vdyytext,&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
        state = NORMAL;
       }
       BEGIN 0;
     }
     else
     {
       lex_errkey = VD_E_LocMisCom;
       the_lex_return = 1;
       BEGIN ALL_FALSE;
     } 
}
break;
case 7:
{
#  ifdef DEBUG
   printf("regle 2 bis, text: <%s>\n", vdyytext); 
#  endif
    /* First verify it is follow by one of the 5 chars  */
    input();
    if(vdyytchar == '\0' || vdyytchar == ',' || vdyytchar == '\b' 
       || vdyytchar == '\t' || vdyytchar == '\n')
     {
     /* In this case prefix contain the EXP_AN and vdyytext the CRO_N*/
      if(state == NORMAL)
         fill_reg(vdyytext,EXPAND,prefix,"",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
      else
      {
         fill_reg(vdyytext,EXPAND,prefix,"",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
         state = NORMAL;
       }      
      BEGIN 0;
     }
    else
     {
       lex_errkey = VD_E_LocMisCom;
       the_lex_return = 1;
       BEGIN ALL_FALSE;
     } 
}
break;
case 8:
{
#  ifdef DEBUG
   printf("regle 2 ter, text: <%s>\n", vdyytext); 
#  endif
    unput(vdyytchar);
   /* In this case prefix contain the EXP_AN */
   if(state == NORMAL)
     fill_reg(prefix,FILL_TABLE,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
   else {
       fill_reg(prefix,FILL_TABLE,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
       state = NORMAL;
   }
   BEGIN 0;
  }
break;
case 9:
{
#  ifdef DEBUG
   printf("regle 0\n");
#  endif
   state = NORMAL;
   BEGIN 0;
  }
break;
case 10:
{
#  ifdef DEBUG
   printf("regle 0 bis\n");
#  endif
   state = NORMAL;
   BEGIN 0;
  }
break;
case 11:
{
#  ifdef DEBUG
   printf("regle 1, text: <%s>\n", vdyytext); 
#  endif
   strcpy(prefix,vdyytext); /* Remember the prefix */ 
   suffix[0]='\0';

   /* Is it end of file ? */
   if(input() != '\0')
   {
         unput(vdyytchar);  /* No, wait next state for filling table */
  }
   else  /* Yes, Fill table */
   {
     if(state == NORMAL)  
        fill_reg(vdyytext,FILL_TABLE,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
     else
     {
         fill_reg(vdyytext,FILL_TABLE,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
         state = NORMAL;
     }
   }   
   BEGIN C_EXP_AN;
}
break;
case 12:
{
#  ifdef DEBUG
   printf("regle 2, text: <%s>\n", vdyytext); 
#  endif

   strcpy(prefix,vdyytext);
   suffix[0] = '\0';

    /* Is it end of file */
   if(input() != '\0')
   {
         unput(vdyytchar); /* Wait next state for filling table */
    }
    else
    {   /* Yes, expand and fill table */
       if(state == NORMAL)
         fill_reg(vdyytext,EXPAND,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
        else 
        {  
           fill_reg(vdyytext,EXPAND,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
           state = NORMAL; 
        }
     }  
   BEGIN C_CRO_N;
 }
break;
case 13:
{
#ifdef DEBUG
  printf(" Erreur crochet pas ferme\n");
#endif
   lex_errkey = VD_E_LocUnExp;
   lex_errmsg = (char *)malloc(strlen(vdyytext) + 10);
   if(lex_errmsg != NULL)
     sprintf(lex_errmsg," <%s>", vdyytext);
   state = NORMAL;
   the_lex_return = 1;
   BEGIN ALL_FALSE;
}
break;
case 14:
{
#  ifdef DEBUG
   printf( "Tout faux: <%s>\n", vdyytext) ;
#  endif
   lex_errkey = VD_E_LocUnExp;
   lex_errmsg = (char *)malloc(strlen(vdyytext) + 10);
   if(lex_errmsg != NULL)
      sprintf(lex_errmsg," <%s>",vdyytext);
   state = NORMAL;
   the_lex_return = 1;
   BEGIN ALL_FALSE;
   }
break;
case -1:
break;
default:
fprintf(vdyyout,"bad switch vdyylook %d",nstr);
} return(0); }
/* end of vdyylex */
/* Fin Regles */

int vdyyvstop[] = {
0,

14,
0,

9,
14,
0,

9,
0,

11,
14,
-2,
0,

10,
14,
0,

14,
0,

4,
14,
0,

8,
9,
14,
0,

8,
9,
0,

8,
10,
14,
0,

14,
0,

5,
9,
14,
0,

5,
9,
0,

6,
11,
14,
-2,
0,

5,
10,
14,
0,

14,
0,

1,
14,
0,

1,
9,
14,
0,

1,
9,
0,

1,
11,
14,
-2,
0,

1,
10,
14,
0,

1,
14,
0,

1,
4,
14,
0,

11,
-2,
0,

2,
0,

13,
0,

13,
0,

13,
0,

13,
0,

13,
0,

13,
0,

6,
11,
-2,
0,

13,
0,

13,
0,

1,
11,
-2,
0,

13,
0,

13,
0,

13,
0,

11,
12,
-2,
-3,
0,

7,
11,
12,
-2,
-3,
0,

6,
11,
12,
-2,
-3,
0,

1,
11,
12,
-2,
-3,
0,

12,
-3,
0,

2,
3,
0,

7,
12,
-3,
0,

1,
12,
-3,
0,

3,
0,
0};
# define VDYYETYPE char
struct vdyywork { VDYYETYPE verify, advance; } vdyycrank[] = {
0,0,	0,0,	1,9,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	1,10,	1,11,	
10,11,	10,11,	16,17,	16,17,	
20,21,	20,21,	14,35,	26,27,	
26,27,	0,0,	19,0,	0,0,	
0,0,	0,0,	14,35,	14,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	10,11,	
24,0,	16,17,	0,0,	20,21,	
1,12,	0,0,	26,27,	1,12,	
0,0,	1,13,	1,12,	1,12,	
2,12,	1,12,	37,53,	2,12,	
30,0,	2,13,	2,12,	2,12,	
38,54,	19,39,	40,56,	1,12,	
19,40,	43,59,	14,36,	44,60,	
1,12,	14,37,	1,12,	2,12,	
48,64,	49,65,	50,66,	24,36,	
2,12,	52,67,	24,43,	3,16,	
3,17,	55,71,	57,74,	61,77,	
63,78,	69,84,	14,38,	4,16,	
4,17,	73,87,	0,0,	30,47,	
0,0,	75,84,	30,48,	24,44,	
1,14,	80,93,	70,32,	76,41,	
1,12,	81,45,	1,12,	96,95,	
2,14,	83,84,	86,87,	92,93,	
2,12,	3,12,	99,98,	30,49,	
3,12,	101,100,	3,18,	3,12,	
3,12,	4,12,	14,38,	0,0,	
4,12,	0,0,	4,18,	4,12,	
4,12,	0,0,	0,0,	24,44,	
3,12,	0,0,	0,0,	1,15,	
95,102,	3,12,	69,85,	0,0,	
4,12,	0,0,	73,88,	2,15,	
0,0,	4,12,	75,90,	30,49,	
5,20,	5,21,	80,94,	0,0,	
0,0,	0,0,	0,0,	0,0,	
6,20,	6,21,	83,95,	86,98,	
92,100,	0,0,	0,0,	0,0,	
0,0,	3,19,	0,0,	0,0,	
0,0,	3,12,	0,0,	0,0,	
0,0,	4,19,	0,0,	0,0,	
0,0,	4,12,	5,22,	0,0,	
0,0,	5,22,	0,0,	5,23,	
5,22,	5,22,	6,22,	5,22,	
0,0,	6,22,	0,0,	6,23,	
6,22,	6,22,	0,0,	6,22,	
0,0,	5,22,	0,0,	0,0,	
3,15,	0,0,	5,22,	0,0,	
5,22,	6,22,	0,0,	7,25,	
4,15,	0,0,	6,22,	0,0,	
6,22,	0,0,	0,0,	7,26,	
7,27,	0,0,	0,0,	0,0,	
0,0,	0,0,	8,28,	0,0,	
0,0,	8,28,	0,0,	8,29,	
8,28,	8,28,	5,24,	0,0,	
0,0,	0,0,	5,22,	0,0,	
5,22,	0,0,	6,24,	0,0,	
0,0,	8,28,	6,22,	0,0,	
6,22,	7,28,	8,28,	0,0,	
7,28,	0,0,	7,29,	7,28,	
7,28,	0,0,	7,28,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
7,28,	5,15,	0,0,	0,0,	
0,0,	7,28,	0,0,	7,28,	
0,0,	6,15,	8,30,	0,0,	
0,0,	0,0,	8,28,	36,52,	
36,52,	36,52,	36,52,	36,52,	
36,52,	36,52,	36,52,	36,52,	
36,52,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	7,30,	0,0,	0,0,	
0,0,	7,28,	0,0,	7,28,	
0,0,	0,0,	0,0,	0,0,	
0,0,	8,31,	39,55,	39,55,	
39,55,	39,55,	39,55,	39,55,	
39,55,	39,55,	39,55,	39,55,	
47,63,	47,63,	47,63,	47,63,	
47,63,	47,63,	47,63,	47,63,	
47,63,	47,63,	0,0,	0,0,	
7,31,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,0,	
12,0,	12,0,	12,0,	12,32,	
12,0,	12,0,	12,32,	12,0,	
12,0,	12,32,	12,32,	12,0,	
12,32,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	12,32,	12,0,	
12,0,	12,0,	12,0,	12,32,	
12,0,	12,32,	53,68,	0,0,	
0,0,	53,69,	53,69,	53,69,	
53,69,	53,69,	53,69,	53,69,	
53,69,	53,69,	53,69,	59,75,	
59,75,	59,75,	59,75,	59,75,	
59,75,	59,75,	59,75,	59,75,	
59,75,	0,0,	0,0,	12,33,	
12,0,	12,0,	12,0,	12,32,	
12,0,	12,32,	56,72,	0,0,	
0,0,	56,73,	56,73,	56,73,	
56,73,	56,73,	56,73,	56,73,	
56,73,	56,73,	56,73,	66,82,	
66,82,	66,82,	66,82,	66,82,	
66,82,	66,82,	66,82,	66,82,	
66,82,	0,0,	0,0,	12,0,	
12,0,	12,0,	12,34,	12,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,0,	22,0,	
22,0,	22,0,	22,41,	22,0,	
22,0,	22,41,	22,0,	22,0,	
22,41,	22,41,	22,0,	22,41,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	22,41,	22,0,	22,0,	
22,0,	22,0,	22,41,	22,0,	
22,41,	64,79,	0,0,	0,0,	
64,80,	64,80,	64,80,	64,80,	
64,80,	64,80,	64,80,	64,80,	
64,80,	64,80,	67,83,	67,83,	
67,83,	67,83,	67,83,	67,83,	
67,83,	67,83,	67,83,	67,83,	
0,0,	0,0,	22,42,	22,0,	
22,0,	22,0,	22,41,	22,0,	
22,41,	68,83,	68,83,	68,83,	
68,83,	68,83,	68,83,	68,83,	
68,83,	68,83,	68,83,	71,86,	
71,86,	71,86,	71,86,	71,86,	
71,86,	71,86,	71,86,	71,86,	
71,86,	0,0,	0,0,	0,0,	
0,0,	0,0,	22,0,	22,0,	
22,0,	22,34,	22,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,0,	28,0,	28,0,	
28,0,	28,45,	28,0,	28,0,	
28,45,	28,0,	28,0,	28,45,	
28,45,	28,0,	28,45,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
28,45,	28,0,	28,0,	28,0,	
28,0,	28,45,	28,0,	28,45,	
72,86,	72,86,	72,86,	72,86,	
72,86,	72,86,	72,86,	72,86,	
72,86,	72,86,	74,89,	74,89,	
74,89,	74,89,	74,89,	74,89,	
74,89,	74,89,	74,89,	74,89,	
0,0,	0,0,	0,0,	0,0,	
0,0,	28,46,	28,0,	28,0,	
28,0,	28,45,	28,0,	28,45,	
77,91,	77,91,	77,91,	77,91,	
77,91,	77,91,	77,91,	77,91,	
77,91,	77,91,	78,92,	78,92,	
78,92,	78,92,	78,92,	78,92,	
78,92,	78,92,	78,92,	78,92,	
0,0,	0,0,	0,0,	0,0,	
0,0,	28,0,	28,0,	28,0,	
28,34,	28,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,0,	32,0,	32,0,	32,0,	
32,32,	32,0,	32,0,	32,32,	
32,0,	32,0,	32,32,	32,32,	
32,0,	33,50,	33,50,	33,50,	
33,50,	33,50,	33,50,	33,50,	
33,50,	33,50,	33,50,	32,32,	
32,0,	32,0,	32,0,	32,0,	
32,32,	32,0,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
32,33,	32,0,	32,0,	32,0,	
32,32,	32,0,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
33,51,	33,51,	33,51,	33,51,	
32,0,	32,0,	32,0,	32,34,	
32,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,0,	
41,0,	41,0,	41,0,	41,41,	
41,0,	41,0,	41,41,	41,0,	
41,0,	41,41,	41,41,	41,0,	
42,57,	42,57,	42,57,	42,57,	
42,57,	42,57,	42,57,	42,57,	
42,57,	42,57,	41,41,	41,0,	
41,0,	41,0,	41,0,	41,41,	
41,0,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	41,42,	
41,0,	41,0,	41,0,	41,41,	
41,0,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	42,58,	
42,58,	42,58,	42,58,	41,0,	
41,0,	41,0,	41,34,	41,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,0,	45,0,	
45,0,	45,0,	45,45,	45,0,	
45,0,	45,45,	45,0,	45,0,	
45,45,	45,45,	45,0,	46,61,	
46,61,	46,61,	46,61,	46,61,	
46,61,	46,61,	46,61,	46,61,	
46,61,	45,45,	45,0,	45,0,	
45,0,	45,0,	45,45,	45,0,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	45,46,	45,0,	
45,0,	45,0,	45,45,	45,0,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	46,62,	46,62,	
46,62,	46,62,	45,0,	45,0,	
45,0,	45,34,	45,0,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	54,70,	54,70,	54,70,	
54,70,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	60,76,	
60,76,	60,76,	60,76,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	65,81,	65,81,	65,81,	
65,81,	79,92,	79,92,	79,92,	
79,92,	79,92,	79,92,	79,92,	
79,92,	79,92,	79,92,	84,96,	
84,96,	84,96,	84,96,	84,96,	
84,96,	84,96,	84,96,	84,96,	
84,96,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,0,	
85,0,	85,0,	85,0,	85,32,	
85,0,	85,0,	85,32,	85,0,	
85,0,	85,32,	85,32,	85,0,	
87,99,	87,99,	87,99,	87,99,	
87,99,	87,99,	87,99,	87,99,	
87,99,	87,99,	85,32,	85,0,	
85,0,	85,0,	85,0,	85,32,	
85,0,	93,101,	93,101,	93,101,	
93,101,	93,101,	93,101,	93,101,	
93,101,	93,101,	93,101,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	85,33,	
85,0,	85,0,	85,0,	85,32,	
85,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	85,0,	
85,0,	85,0,	85,97,	85,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,0,	88,0,	
88,0,	88,0,	88,32,	88,0,	
88,0,	88,32,	88,0,	88,0,	
88,32,	88,32,	88,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	88,32,	88,0,	88,0,	
88,0,	88,0,	88,32,	88,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	88,33,	88,0,	
88,0,	88,0,	88,32,	88,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	88,0,	88,0,	
88,0,	88,97,	88,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,0,	90,0,	90,0,	
90,0,	90,41,	90,0,	90,0,	
90,41,	90,0,	90,0,	90,41,	
90,41,	90,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
90,41,	90,0,	90,0,	90,0,	
90,0,	90,41,	90,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	90,42,	90,0,	90,0,	
90,0,	90,41,	90,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	90,0,	90,0,	90,0,	
90,97,	90,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,0,	94,0,	94,0,	94,0,	
94,45,	94,0,	94,0,	94,45,	
94,0,	94,0,	94,45,	94,45,	
94,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	94,45,	
94,0,	94,0,	94,0,	94,0,	
94,45,	94,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
94,46,	94,0,	94,0,	94,0,	
94,45,	94,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
94,0,	94,0,	94,0,	94,97,	
94,0,	0,0,	0,0,	0,0,	
0,0};
struct vdyysvf vdyysvec[] = {
0,	0,	0,
vdyycrank+-1,	0,		0,	
vdyycrank+-9,	vdyysvec+1,	0,	
vdyycrank+-66,	vdyysvec+1,	0,	
vdyycrank+-74,	vdyysvec+1,	0,	
vdyycrank+-131,	vdyysvec+1,	0,	
vdyycrank+-139,	vdyysvec+1,	0,	
vdyycrank+-198,	0,		0,	
vdyycrank+-175,	vdyysvec+7,	0,	
vdyycrank+0,	0,		vdyyvstop+1,
vdyycrank+3,	0,		vdyyvstop+3,
vdyycrank+0,	vdyysvec+10,	vdyyvstop+6,
vdyycrank+-324,	0,		vdyyvstop+8,
vdyycrank+0,	0,		vdyyvstop+12,
vdyycrank+-17,	0,		vdyyvstop+15,
vdyycrank+0,	0,		vdyyvstop+17,
vdyycrank+5,	0,		vdyyvstop+20,
vdyycrank+0,	vdyysvec+16,	vdyyvstop+24,
vdyycrank+0,	0,		vdyyvstop+27,
vdyycrank+-12,	vdyysvec+14,	vdyyvstop+31,
vdyycrank+7,	0,		vdyyvstop+33,
vdyycrank+0,	vdyysvec+20,	vdyyvstop+37,
vdyycrank+-451,	0,		vdyyvstop+40,
vdyycrank+0,	0,		vdyyvstop+45,
vdyycrank+-26,	vdyysvec+14,	vdyyvstop+49,
vdyycrank+0,	0,		vdyyvstop+51,
vdyycrank+10,	0,		vdyyvstop+54,
vdyycrank+0,	vdyysvec+26,	vdyyvstop+58,
vdyycrank+-578,	0,		vdyyvstop+61,
vdyycrank+0,	0,		vdyyvstop+66,
vdyycrank+-42,	vdyysvec+14,	vdyyvstop+70,
vdyycrank+0,	0,		vdyyvstop+73,
vdyycrank+-705,	vdyysvec+12,	vdyyvstop+77,
vdyycrank+705,	0,		0,	
vdyycrank+0,	0,		vdyyvstop+80,
vdyycrank+0,	0,		vdyyvstop+82,
vdyycrank+223,	0,		vdyyvstop+84,
vdyycrank+5,	vdyysvec+36,	vdyyvstop+86,
vdyycrank+11,	0,		vdyyvstop+88,
vdyycrank+254,	0,		vdyyvstop+90,
vdyycrank+13,	vdyysvec+39,	vdyyvstop+92,
vdyycrank+-832,	vdyysvec+22,	vdyyvstop+94,
vdyycrank+832,	0,		0,	
vdyycrank+16,	vdyysvec+36,	vdyyvstop+98,
vdyycrank+18,	0,		vdyyvstop+100,
vdyycrank+-959,	vdyysvec+28,	vdyyvstop+102,
vdyycrank+959,	0,		0,	
vdyycrank+264,	0,		vdyyvstop+106,
vdyycrank+23,	vdyysvec+47,	vdyyvstop+108,
vdyycrank+24,	0,		vdyyvstop+110,
vdyycrank+25,	0,		0,	
vdyycrank+0,	vdyysvec+38,	0,	
vdyycrank+28,	vdyysvec+36,	0,	
vdyycrank+345,	0,		0,	
vdyycrank+1022,	0,		0,	
vdyycrank+32,	vdyysvec+39,	0,	
vdyycrank+377,	0,		0,	
vdyycrank+33,	0,		0,	
vdyycrank+0,	vdyysvec+44,	0,	
vdyycrank+355,	vdyysvec+53,	0,	
vdyycrank+1080,	0,		0,	
vdyycrank+34,	0,		0,	
vdyycrank+0,	vdyysvec+49,	0,	
vdyycrank+35,	vdyysvec+47,	0,	
vdyycrank+472,	0,		0,	
vdyycrank+1138,	0,		0,	
vdyycrank+387,	0,		0,	
vdyycrank+482,	vdyysvec+53,	0,	
vdyycrank+501,	0,		0,	
vdyycrank+37,	vdyysvec+68,	0,	
vdyycrank+1,	0,		0,	
vdyycrank+511,	vdyysvec+56,	0,	
vdyycrank+596,	0,		0,	
vdyycrank+41,	vdyysvec+72,	0,	
vdyycrank+606,	0,		0,	
vdyycrank+45,	vdyysvec+68,	0,	
vdyycrank+2,	0,		0,	
vdyycrank+628,	0,		0,	
vdyycrank+638,	vdyysvec+64,	0,	
vdyycrank+1213,	0,		0,	
vdyycrank+49,	vdyysvec+79,	0,	
vdyycrank+4,	0,		0,	
vdyycrank+0,	vdyysvec+70,	0,	
vdyycrank+57,	vdyysvec+68,	0,	
vdyycrank+1223,	0,		0,	
vdyycrank+-1280,	vdyysvec+12,	vdyyvstop+112,
vdyycrank+58,	vdyysvec+72,	0,	
vdyycrank+1280,	0,		0,	
vdyycrank+-1407,	vdyysvec+12,	vdyyvstop+117,
vdyycrank+0,	vdyysvec+76,	0,	
vdyycrank+-1534,	vdyysvec+22,	vdyyvstop+123,
vdyycrank+0,	vdyysvec+81,	0,	
vdyycrank+59,	vdyysvec+79,	0,	
vdyycrank+1297,	0,		0,	
vdyycrank+-1661,	vdyysvec+28,	vdyyvstop+129,
vdyycrank+2,	0,		vdyyvstop+135,
vdyycrank+6,	vdyysvec+84,	0,	
vdyycrank+0,	0,		vdyyvstop+138,
vdyycrank+0,	vdyysvec+95,	vdyyvstop+141,
vdyycrank+13,	vdyysvec+87,	0,	
vdyycrank+0,	vdyysvec+95,	vdyyvstop+145,
vdyycrank+16,	vdyysvec+93,	0,	
vdyycrank+0,	0,		vdyyvstop+149,
0,	0,	0};
struct vdyywork *vdyytop = vdyycrank+1788;
struct vdyysvf *vdyybgin = vdyysvec+1;
char vdyymatch[] = {
00  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,011 ,012 ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
011 ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,01  ,01  ,01  ,01  ,01  ,01  ,01  ,
'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,'0' ,
'0' ,'0' ,01  ,01  ,01  ,01  ,01  ,01  ,
01  ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,'A' ,
'A' ,'A' ,'A' ,01  ,01  ,01  ,01  ,01  ,
01  ,'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,
'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,
'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,'a' ,
'a' ,'a' ,'a' ,01  ,01  ,01  ,01  ,01  ,
0};
char vdyyextra[] = {
0,0,1,1,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
#ident	"@(#)libl:lib/ncform	1.3	1.2 (Intergraph) 3/10/88"
int vdyylineno =1;
# define VDYYEU(x) x
# define NLSTATE vdyyprevious=VDYYENEWLINE
char vdyytext[VDYYELMAX];
struct vdyysvf *vdyylstate [VDYYELMAX], **vdyylsp, **vdyyolsp;
char vdyysbuf[VDYYELMAX];
char *vdyysptr = vdyysbuf;
int *vdyyfnd;
extern struct vdyysvf *vdyyestate;
int vdyyprevious = VDYYENEWLINE;
vdyylook(){
	register struct vdyysvf *vdyystate, **lsp;
	register struct vdyywork *vdyyt;
	struct vdyysvf *vdyyz;
	int vdyych, vdyyfirst;
	struct vdyywork *vdyyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *vdyylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	vdyyfirst=1;
	if (!vdyymorfg)
		vdyylastch = vdyytext;
	else {
		vdyymorfg=0;
		vdyylastch = vdyytext+vdyyleng;
		}
	for(;;){
		lsp = vdyylstate;
		vdyyestate = vdyystate = vdyybgin;
		if (vdyyprevious==VDYYENEWLINE) vdyystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(vdyyout,"state %d\n",vdyystate-vdyysvec-1);
# endif
			vdyyt = vdyystate->vdyystoff;
			if(vdyyt == vdyycrank && !vdyyfirst){  /* may not be any transitions */
				vdyyz = vdyystate->vdyyother;
				if(vdyyz == 0)break;
				if(vdyyz->vdyystoff == vdyycrank)break;
				}
			*vdyylastch++ = vdyych = input();
			vdyyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(vdyyout,"char ");
				allprint(vdyych);
				putchar('\n');
				}
# endif
			vdyyr = vdyyt;
			if ( (int)vdyyt > (int)vdyycrank){
				vdyyt = vdyyr + vdyych;
				if (vdyyt <= vdyytop && vdyyt->verify+vdyysvec == vdyystate){
					if(vdyyt->advance+vdyysvec == VDYYELERR)	/* error transitions */
						{unput(*--vdyylastch);break;}
					*lsp++ = vdyystate = vdyyt->advance+vdyysvec;
					goto contin;
					}
				}
# ifdef VDYYEOPTIM
			else if((int)vdyyt < (int)vdyycrank) {		/* r < vdyycrank */
				vdyyt = vdyyr = vdyycrank+(vdyycrank-vdyyt);
# ifdef LEXDEBUG
				if(debug)fprintf(vdyyout,"compressed state\n");
# endif
				vdyyt = vdyyt + vdyych;
				if(vdyyt <= vdyytop && vdyyt->verify+vdyysvec == vdyystate){
					if(vdyyt->advance+vdyysvec == VDYYELERR)	/* error transitions */
						{unput(*--vdyylastch);break;}
					*lsp++ = vdyystate = vdyyt->advance+vdyysvec;
					goto contin;
					}
				vdyyt = vdyyr + VDYYEU(vdyymatch[vdyych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(vdyyout,"try fall back character ");
					allprint(VDYYEU(vdyymatch[vdyych]));
					putchar('\n');
					}
# endif
				if(vdyyt <= vdyytop && vdyyt->verify+vdyysvec == vdyystate){
					if(vdyyt->advance+vdyysvec == VDYYELERR)	/* error transition */
						{unput(*--vdyylastch);break;}
					*lsp++ = vdyystate = vdyyt->advance+vdyysvec;
					goto contin;
					}
				}
			if ((vdyystate = vdyystate->vdyyother) && (vdyyt= vdyystate->vdyystoff) != vdyycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(vdyyout,"fall back to state %d\n",vdyystate-vdyysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--vdyylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(vdyyout,"state %d char ",vdyystate-vdyysvec-1);
				allprint(vdyych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(vdyyout,"stopped at %d with ",*(lsp-1)-vdyysvec-1);
			allprint(vdyych);
			putchar('\n');
			}
# endif
		while (lsp-- > vdyylstate){
			*vdyylastch-- = 0;
			if (*lsp != 0 && (vdyyfnd= (*lsp)->vdyystops) && *vdyyfnd > 0){
				vdyyolsp = lsp;
				if(vdyyextra[*vdyyfnd]){		/* must backup */
					while(vdyyback((*lsp)->vdyystops,-*vdyyfnd) != 1 && lsp > vdyylstate){
						lsp--;
						unput(*vdyylastch--);
						}
					}
				vdyyprevious = VDYYEU(*vdyylastch);
				vdyylsp = lsp;
				vdyyleng = vdyylastch-vdyytext+1;
				vdyytext[vdyyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(vdyyout,"\nmatch ");
					sprint(vdyytext);
					fprintf(vdyyout," action %d\n",*vdyyfnd);
					}
# endif
				return(*vdyyfnd++);
				}
			unput(*vdyylastch);
			}
		/* you may or may not be reading from vdyyin - we really   */
		/* can't tell at this point. So whenver vdyytext[0] is set */
		/* to 0, this indicates end of file			 */
		if (vdyytext[0] == 0 /* && feof(vdyyin) */ )
			{
			vdyysptr=vdyysbuf;
			return(0);
			}
		vdyyprevious = vdyytext[0] = input();
		if (vdyyprevious>0)
			output(vdyyprevious);
		vdyylastch=vdyytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
vdyyback(p, m)
	int *p;
{
if (p==0) return(0);
while (*p)
	{
	if (*p++ == m)
		return(1);
	}
return(0);
}
	/* the following are only used in the lex library */
vdyyinput(){
	return(input());
	}
vdyyoutput(c)
  int c; {
	output(c);
	}
vdyyunput(c)
   int c; {
	unput(c);
	}
