#ifdef ENV5
#include <tools.h>
#endif
#ifdef X11
#include <limits.h>
#endif
#include <stdio.h>
#include <OMminimum.h>
#include <OMerrordef.h>
#include <igrtypedef.h>
#include <igetypedef.h>
#include <msdef.h>
#include <exdef.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include <exproto.h>
#include <string.h>
#include <ctype.h>
#ifdef X11

#include <X11/Xlib.h>
#include <X11/Xutil.h>
extern Display *EXdisplay;
extern int      EXscreen;
extern int      Help_active();

#if defined( CLIX )
extern  int INGR_DigButtonPress;
extern  int INGR_DigButtonRelease;
extern  int INGR_DigButtonPress_class;
extern  int INGR_DigButtonRelease_class;

#endif


#endif

extern char *bsearch();
#define CSWFIdebug 0

#define EX_MAX_BUTTON      128
#define BUFSIZE            128
#define NOSPACE            1
#define ONESPACE           0
#define LOWERCASE          1
#define SAMECASE           0

struct EXbt /* button match table */
{
    char key[20];
    int  index;
};

struct button_cmd
{
   int  conv_flag;
   int  response;
   char button_str[15];
};
static struct button_cmd  button_list[EX_MAX_BUTTON+1];

#ifdef NT
/*helpnt*/
#define		DOWN		1		/* down		*/
#endif

#ifdef X11

/* Button types */

#define		UP		0		/* up		*/
#define		DOWN		1		/* down		*/
#define		SINGLE_CLICK	2		/* click	*/
#define		DOUBLE_DOWN	3		/* double down	*/
#define		DOUBLE_CLICK	4		/* double click	*/
#define		TRIPLE_DOWN	5		/* triple down	*/
#define		UP_DOWN_UP	6		/* up down up	*/
#define		UP_DOWN		7		/* up down	*/


#define         LEFT_BUTTON     0
#define         MIDDLE_BUTTON   1
#define         RIGHT_BUTTON    2



int EX_button_AST ( response, response_data, xevent, transition )
   int *response;
   char *response_data;
   XEvent  *xevent;
   int  transition;
#endif

#ifdef ENV5

int EX_button_AST ( response, response_data )
   int *response;
   char *response_data;
#endif

#ifdef NT

int EX_button_AST ( response, response_data )
   int *response;
   char *response_data;
#endif

{
   struct EX_button mypnt;
   int window, x, y, state, btype;
#ifdef ENV5
   int timetag;
#endif
   int status;
   IGRlong ret ,no_bytes;
   int local_resp;
#ifdef X11
   WLuint32    lwin;
   OMuword     lwin_os;
   OM_S_OBJID  lwin_oid;
#endif

/*
   printf("button, BUTTON EVENT\n");
   printf("button, calling Get button data\n");

*/

#ifdef X11
   status = TRUE;
   if (WL_SUCCESS != EX_trans_win(xevent->xbutton.window, &lwin, &lwin_os, 
                                  &lwin_oid))
   {
   return(1);
   }
   else
   {
      window = xevent->xbutton.window;
   }

   x      = xevent->xbutton.x;
   y      = xevent->xbutton.y;
   btype  = xevent->xbutton.button - 1;
   state  = transition;



#if defined( CLIX )
   /* use down for now, have problems call XCheckWindowEvent with 
					     digbuttonpress/release mask */

   if  (state == DOWN) state = SINGLE_CLICK;

   if (( xevent->type  == INGR_DigButtonPress ) &&
       ( btype == LEFT_BUTTON )    && 
       ( state == SINGLE_CLICK)   )     
   {
#else

   if ((window < 0)  && (btype == LEFT_BUTTON) && (state == SINGLE_CLICK))
   {

#endif

#endif

#ifdef ENV5
   status = EX_get_button_data(&window,&x,&y,&btype,&state,&timetag);

   /* btype == LEFT_BUTTON, MIDDLE_BUTTON RIGHT_BUTTON               */
   /* state == transition state UP, DOWN, SINGLE_CLICK, DOUBLE_CLICK 
                                                            etc...     */
/*
   printf("window= %d, x= %d, y= %d\n",window,x,y);
   printf("btype= %d, state = %d \n",btype,state);
*/

   /* check for pocket menu */

   if ((window < 0)  && (btype == LEFT_BUTTON) && (state == SINGLE_CLICK))
   {

#endif 

#ifdef NT
/*helpnt*/
/*     status = EX_get_button_data(&window,&x,&y,&btype,&state,&timetag);*/

   /* btype == LEFT_BUTTON, MIDDLE_BUTTON RIGHT_BUTTON               */
   /* state == transition state UP, DOWN, SINGLE_CLICK, DOUBLE_CLICK 
                                                            etc...     */
   /* check for pocket menu */

/*     if((window < 0)  && (btype == LEFT_BUTTON) && (state == SINGLE_CLICK))*/

   if (TRUE)
   {

#endif 

   /* command button from dig win */

      mypnt.x=x;
      mypnt.y=y;
      mypnt.z=0;
      mypnt.window = window;
      mypnt.objid =NULL_OBJID;  /* gragad id */
      mypnt.osnum = 0;
      mypnt.numb = btype;
      mypnt.clicks = state;
      mypnt.button_down = (state==DOWN);
      *response = DATA;

      status = EX_conv_pnt(window, &mypnt, response);
      if(!(1&status))
      {
         return(OM_W_ABORT);
      } 
   }
   else
   {      
      /* convert mouse btype and state to            response */
      /* state=DOUBLE_CLICK indicates double click            */
      /* standard button assignment is command, data, reset   */

      local_resp = button_list[ btype * 8 + state].response;
      *response= local_resp | EX_HARDWARE_GENERATED;
      strcpy(response_data, button_list[btype * 8 + state].button_str);

      if  (local_resp != -1)  /* -1 means button not defined */
      {
/*
 * Modified : 02/01/92 : Richard Watson
 * 
 * Command strings and command keys are the only response types which
 * need to have 2 events put on the event queue.  This happens, for example,
 * when the snap is mapped to the middle button on double click.  In this
 * case the logic will push the command on the menu and also push the
 * converted point on the menu.
 * Other events such as a data point (orginally accounted for in this design)
 * don't need this behaviour.  They only want the converted point pushed on
 * the event queue.
 * The modification to the code allows other buttons to share a similar
 * behaviour with the data point.  This is done by specifying in the
 * 'button_file' that that action is to convert the point.
 * In my particular case I wish that Resets be pushed on the queue with the
 * correct coordinates of the point at which the Reset occurred.
 *
 */
         if ((local_resp == CMD_STRING) || (local_resp == EX_CMD_KEY) ||
             (button_list[btype * 8 + state].conv_flag !=1))
         {
            /* put on software queue */

            no_bytes = strlen(response_data) + 1;
            status = EXputq_back (&ret, response, &no_bytes, response_data);
         }
      }          
      else
      {
         status = 0;
      }

      if (button_list[btype * 8 + state].conv_flag == 1) 
      {
         mypnt.x=x;
         mypnt.y=y;
         mypnt.z=0;
         mypnt.window = window;
         mypnt.objid =NULL_OBJID;  /* gragad id */
         mypnt.osnum = 0;
         mypnt.numb = btype;
         mypnt.clicks = state;
         mypnt.button_down = (state==DOWN);
    
         /* convert x,y to database coordinate */

         /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
           check response first, 

           if it is not a CMD_STRING (9)  -- converted point will have the same
                                             response specified.

           if it is a CMD_STRING(9)     -- converted point will have the
                     EX_CMD_KEY(23)        response as DATA. SO this converted
                                           point can be recognized by the 
                                           GRgetevent as a data point, and used
                                           by the command associated with the
                                           button. 
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&*/

         if ((local_resp == CMD_STRING) || (local_resp == EX_CMD_KEY))
            *response = DATA;

         status = EX_conv_pnt (window, &mypnt, response);
         if(!(1&status))
         {
            return (OM_W_ABORT);
         } 
      }
   }      

   return(status);
}

 
int EX_is_button_defined ( btype, state )
int btype, state;
{
   return (button_list[ btype * 8 + state].response == -1 ? 0 : 1);
}


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  EX_load_button
 
     Abstract:   This function will load the mouse button  definition
                 into the memory button_list
-----
%SC%

      value = EX_load_button( msg, file_name)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *file_name     char         pointer to file_name

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         long        - return code:
                                   EXSUCC - succeeded.



     value =    TRUE if succeeded
                FALSE if failed.

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:

-----
%CH%
     CHANGE HISTORY:
      ht  8/12/86       creation date.  
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/




    static struct EXbt button_table[] ={ 

                                        {"0doubleclick",4},
                                        {"0doubledown",3},
                                        {"0down",1},
                                        {"0singleclick",2},
                                        {"0tripledown",5},
                                        {"0up",0},
                                        {"0updown",7},
                                        {"0updownup",6},
                                        {"10doubleclick",84},
                                        {"10doubledown",83},
                                        {"10down",81},
                                        {"10singleclick",82},
                                        {"10tripledown",85},
                                        {"10up",80},
                                        {"10updown",87},
                                        {"10updownup",86},
                                        {"11doubleclick",92},
                                        {"11doubledown",91},
                                        {"11down",89},
                                        {"11singleclick",90},
                                        {"11tripledown",93},
                                        {"11up",88},
                                        {"11updown",95},
                                        {"11updownup",94},
                                        {"12doubleclick",100},
                                        {"12doubledown",99},
                                        {"12down",97},
                                        {"12singleclick",98},
                                        {"12tripledown",101},
                                        {"12up",96},
                                        {"12updown",103},
                                        {"12updownup",102},
                                        {"13doubleclick",108},
                                        {"13doubledown",107},
                                        {"13down",105},
                                        {"13singleclick",106},
                                        {"13tripledown",109},
                                        {"13up",104},
                                        {"13updown",111},
                                        {"13updownup",110},
                                        {"14doubleclick",116},
                                        {"14doubledown",115},
                                        {"14down",113},
                                        {"14singleclick",114},
                                        {"14tripledown",117},
                                        {"14up",112},
                                        {"14updown",119},
                                        {"14updownup",118},
                                        {"15doubleclick",124},
                                        {"15doubledown",123},
                                        {"15down",121},
                                        {"15singleclick",122},
                                        {"15tripledown",125},
                                        {"15up",121},
                                        {"15updown",127},
                                        {"15updownup",126},
                                        {"1doubleclick",12},
                                        {"1doubledown",11},
                                        {"1down",9},
                                        {"1singleclick",10},
                                        {"1tripledown",13},
                                        {"1up",8},
                                        {"1updown",15},
                                        {"1updownup",14},
                                        {"2doubleclick",20},
                                        {"2doubledown",19},
                                        {"2down",17},
                                        {"2singleclick",18},
                                        {"2tripledown",21},
                                        {"2up",16},
                                        {"2updown",23},
                                        {"2updownup",22},
                                        {"3doubleclick",28},
                                        {"3doubledown",27},
                                        {"3down",25},
                                        {"3singleclick",26},
                                        {"3tripledown",29},
                                        {"3up",24},
                                        {"3updown",31},
                                        {"3updownup",30},
                                        {"4doubleclick",36},
                                        {"4doubledown",35},
                                        {"4down",33},
                                        {"4singleclick",34},
                                        {"4tripledown",37},
                                        {"4up",32},
                                        {"4updown",39},
                                        {"4updownup",38},
                                        {"5doubleclick",44},
                                        {"5doubledown",43},
                                        {"5down",41},
                                        {"5singleclick",42},
                                        {"5tripledown",45},
                                        {"5up",40},
                                        {"5updown",47},
                                        {"5updownup",46},
                                        {"6doubleclick",52},
                                        {"6doubledown",51},
                                        {"6down",49},
                                        {"6singleclick",50},
                                        {"6tripledown",53},
                                        {"6up",48},
                                        {"6updown",55},
                                        {"6updownup",54},
                                        {"7doubleclick",60},
                                        {"7doubledown",59},
                                        {"7down",57},
                                        {"7singleclick",58},
                                        {"7tripledown",61},
                                        {"7up",56},
                                        {"7updown",63},
                                        {"7updownup",62},
                                        {"8doubleclick",68},
                                        {"8doubledown",67},
                                        {"8down",65},
                                        {"8singleclick",66},
                                        {"8tripledown",69},
                                        {"8up",64},
                                        {"8updown",71},
                                        {"8updownup",70},
                                        {"9doubleclick",76},
                                        {"9doubledown",75},
                                        {"9down",73},
                                        {"9singleclick",74},
                                        {"9tripledown",77},
                                        {"9up",72},
                                        {"9updown",79},
                                        {"9updownup",78}
                              };


static int butcmp (x,z)
char *x;
struct EXbt *z;  
{
   char *y;
   y = z->key;
   return(strcmp(x,y));
}


int EX_load_button ( msg, file_name )

long         *msg;
char         *file_name;
{

    int      status;
    long     i;
    short    index;
    struct EXbt  *tent;
    FILE        *fp;
    char  keynam[30]; 
    int   response;
    int   conv_flag;
    char  button_str[257];
    char  s[BUFSIZE];
    int   line_num;
    
    int tnum = sizeof( button_table) / sizeof(struct EXbt);
 
    status = TRUE;
    *msg = EXSUCC;
    line_num = 0;
    
    /* initialize each button entry to not valid */

    for( i = 0; i < EX_MAX_BUTTON; i++)
    {
       button_list[i].conv_flag = 0;          
       button_list[i].response  = -1;          
       button_list[i].button_str[0] = '\0';
    }

    if (! ( fp = fopen ( file_name, "r" )))
    {
        /* printf("error opening button file\n");   */
        *msg = EXFAIL;
        status = FALSE;
    }
    else
    {
       while ( fgets(s, BUFSIZE, fp) != NULL )
       { 
          line_num++; 
          if((s[0] == '#') || (s[0] == ' ') || (s[0] == '\t') || (s[0] == '\n'))
	      continue;

          if( sscanf(s,"%[^,],%ld,%ld,%[^\n]\n",
                        keynam, &response, &conv_flag, button_str) == 4 )
          {			
             EX_clean_str( keynam,NOSPACE,LOWERCASE);
             tent = (struct EXbt *) bsearch(keynam,button_table,tnum,
                            sizeof(struct EXbt),butcmp);
             if (tent) 
             {
                index =  (short)((unsigned char) tent->index);
                if (index < EX_MAX_BUTTON)
                {
                    button_list[index].response = response;
                    button_list[index].conv_flag = conv_flag;
                    EX_clean_str(button_str,ONESPACE,SAMECASE);
                    strcpy(button_list[index].button_str,button_str);
                }
             }
	  }
	  else
	  {
             printf("EX_load_button possible error in button_file line %d\n", line_num);
	  }
       }
       fclose(fp);       
    }
    return ( status );
} /* end EX_load_button */



#define B1DOUBLECLICK  12


int EX_define_input_generator( response,response_data)
  int *response;
  char *response_data;
{    
    int status;
    struct EX_cmd my_cmd;
    EX_clean_str( response_data,ONESPACE,SAMECASE);/*leave one blank*/
    status = ex$get_cmd_info( string=response_data, mode = *response ,cmdstr = &my_cmd );
    if ( status )
    {
	button_list[B1DOUBLECLICK].conv_flag = 1;/*puts point on que*/
	button_list[B1DOUBLECLICK].response = EX_CMD_KEY;
	strcpy( button_list[B1DOUBLECLICK].button_str,my_cmd.command_key);
	return (1);
    }

    return (0);/*invalid input*/
  }

int EX_clean_str(x,no_space,lower)
char *x;
int no_space;   /*  = 1  to delete every space   */ 
                /*  = 0  one space between words */
int lower;      /*  = 1  convert to lower case   */
                /*  = 0  do not change case      */		
{
    char *y;
    y = x;

    while( isspace(*x) ) x++;  /* leading spaces */
    while( *x )
    {
      if(no_space)
      {
         while( isspace(*x) ) x++;  
      }
      else
      {
         while( isspace(*x) && isspace(*(x+1))) x++; 
         if( isspace(*x) && ( *(x+1) == '\0') ) x++;
      }
      if( lower )
      {
          if( isupper(*x) )  *x = tolower(*x);
      }
      if( *x == '\t') *x = ' '; 
      *y++ = *x++;
    }
    *y = '\0';
    return(1);
}


