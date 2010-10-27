
%{
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

/* vdyylex() always return 0 ; permit to signal some unexpected in vdyylex()*/  
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

int yywrap() {
#  	ifdef DEBUG
	printf("C'est fini\n");
#  	endif
        state = NORMAL;
  	BEGIN 0;  /* Very important if more than one call */
        return( 1 ) ;
        }



/*===== to replace the getc ================================================*/
char    vdgetc ( yyin )
FILE *yyin;
{
  if ((VDinput_index < 0) || (VDinput_index == strlen ( VDinput_stream )))
    return ( -1 );
  else
    return ( VDinput_stream [VDinput_index++] );
}
/*==========================================================================*/
#undef input
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr)\
                                         :vdgetc(yyin))==10\
                                             ?(yylineno++,yytchar)\
                                             :yytchar)==EOF?0:yytchar)
                 
%}

/*---------------------------------------------------------------------------*/
/*----- 	Mots contenus dans une expression                       -----*/
/*---------------------------------------------------------------------------*/

SR		","

BL		([ \t\n])+

EXP_A1		"[a-zA-Z]"

EXP_N1		"[0-9]"

CRO_A1		"["[a-zA-Z]-[a-zA-Z]"]"

CRO_N1		"["[0-9]-[0-9]"]"

CRO_N		"["-?([0-9])+--?([0-9])+(","[0-9]+)?"]"

EXP_AN		(([a-z]|[A-Z]|[0-9]|{CRO_A1}|{CRO_N1}|"*"|"?"|":"|"-"|"'"|"_"|".")+)

NEG              "~"

%START  C_EXP_AN C_CRO_N ALL_FALSE 
/*---------------------------------------------------------------------------*/
/*----- 	Regles regissant la syntaxe d'une expression            -----*/
/*---------------------------------------------------------------------------*/

%%

<ALL_FALSE>({SR}|{BL}|{EXP_AN}|{CRO_N}|.) {
#ifdef DEBUG
      printf("Etat tout faux , ignore input <%s>\n",yytext);
#endif
   BEGIN ALL_FALSE;
}

{EXP_AN}/{NEG} {
#ifdef DEBUG
   printf("Expression negation\n");
#endif
    lex_errkey = VD_E_LocNegCom;
    the_lex_return = 1;
    BEGIN ALL_FALSE;
}

{CRO_N}/{NEG} {
#ifdef DEBUG
   printf("crochet negation\n");
#endif
  lex_errkey = VD_E_LocNegCom;
  the_lex_return = 1;
  BEGIN ALL_FALSE;
}

{NEG} {
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


<C_CRO_N>({SR}|{BL}) {
#  ifdef DEBUG
   printf("regle 1 ter, text: <%s>\n", yytext); 
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

<C_CRO_N>{EXP_AN} {
#  ifdef DEBUG
   printf("regle 1 bis, text: <%s>\n", yytext); 
#  endif
   /* First verify it is follow by one of the 5 chars for end of expression  
      It would be better to do it in lex vocabulary but the end of string
      seems to pose problem */            
    input();
    if(yytchar == '\0' || yytchar == ',' || yytchar == '\b' 
      || yytchar == '\t' || yytchar == '\n')
      {
      /* In this case prefix contain the C_CRO_N and yytext the EXP_AN */
      if(state == NORMAL)
       fill_reg(prefix,EXPAND,"",yytext,&VDreg,&VDcur_ln,&VDnb_alloc_ln);
      else {
        fill_reg(prefix,EXPAND,"",yytext,&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
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

<C_EXP_AN>{CRO_N} {
#  ifdef DEBUG
   printf("regle 2 bis, text: <%s>\n", yytext); 
#  endif
    /* First verify it is follow by one of the 5 chars  */
    input();
    if(yytchar == '\0' || yytchar == ',' || yytchar == '\b' 
       || yytchar == '\t' || yytchar == '\n')
     {
     /* In this case prefix contain the EXP_AN and yytext the CRO_N*/
      if(state == NORMAL)
         fill_reg(yytext,EXPAND,prefix,"",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
      else
      {
         fill_reg(yytext,EXPAND,prefix,"",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
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

<C_EXP_AN>({SR}|{BL}) {
#  ifdef DEBUG
   printf("regle 2 ter, text: <%s>\n", yytext); 
#  endif
    unput(yytchar);
   /* In this case prefix contain the EXP_AN */
   if(state == NORMAL)
     fill_reg(prefix,FILL_TABLE,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
   else {
       fill_reg(prefix,FILL_TABLE,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
       state = NORMAL;
   }
   BEGIN 0;
  }


({BL}) {
#  ifdef DEBUG
   printf("regle 0\n");
#  endif
   state = NORMAL;
   BEGIN 0;
  }

{SR} {
#  ifdef DEBUG
   printf("regle 0 bis\n");
#  endif
   state = NORMAL;
   BEGIN 0;
  }

{EXP_AN} {
#  ifdef DEBUG
   printf("regle 1, text: <%s>\n", yytext); 
#  endif
   strcpy(prefix,yytext); /* Remember the prefix */ 
   suffix[0]='\0';

   /* Is it end of file ? */
   if(input() != '\0')
   {
         unput(yytchar);  /* No, wait next state for filling table */
  }
   else  /* Yes, Fill table */
   {
     if(state == NORMAL)  
        fill_reg(yytext,FILL_TABLE,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
     else
     {
         fill_reg(yytext,FILL_TABLE,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
         state = NORMAL;
     }
   }   
   BEGIN C_EXP_AN;
}


{CRO_N} {
#  ifdef DEBUG
   printf("regle 2, text: <%s>\n", yytext); 
#  endif

   strcpy(prefix,yytext);
   suffix[0] = '\0';

    /* Is it end of file */
   if(input() != '\0')
   {
         unput(yytchar); /* Wait next state for filling table */
    }
    else
    {   /* Yes, expand and fill table */
       if(state == NORMAL)
         fill_reg(yytext,EXPAND,"","",&VDreg,&VDcur_ln,&VDnb_alloc_ln);
        else 
        {  
           fill_reg(yytext,EXPAND,"","",&VDNreg,&VDNcur_ln,&VDNnb_alloc_ln);
           state = NORMAL; 
        }
     }  
   BEGIN C_CRO_N;
 }

"[". {
#ifdef DEBUG
  printf(" Erreur crochet pas ferme\n");
#endif
   lex_errkey = VD_E_LocUnExp;
   lex_errmsg = (char *)malloc(strlen(yytext) + 10);
   if(lex_errmsg != NULL)
     sprintf(lex_errmsg," <%s>", yytext);
   state = NORMAL;
   the_lex_return = 1;
   BEGIN ALL_FALSE;
}


. {
#  ifdef DEBUG
   printf( "Tout faux: <%s>\n", yytext) ;
#  endif
   lex_errkey = VD_E_LocUnExp;
   lex_errmsg = (char *)malloc(strlen(yytext) + 10);
   if(lex_errmsg != NULL)
      sprintf(lex_errmsg," <%s>",yytext);
   state = NORMAL;
   the_lex_return = 1;
   BEGIN ALL_FALSE;
   }

%%
/* Fin Regles */

