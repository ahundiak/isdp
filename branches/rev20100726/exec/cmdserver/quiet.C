#include <stdio.h>
#include <exdef.h>
#define   testing   0

extern int  EX_batch_mode;
extern int EX_help_quiet;
extern int EX_disp_quiet;
extern short MS_Gs_messages_on;

static int EX_quiet_old;
static int EX_quiet_new[EX_CMD_STACK_SIZE];
static int rear = EX_CMD_STACK_SIZE - 1, front = EX_CMD_STACK_SIZE - 1;

void EX_push_quiet( respon )
int  respon;
{

   int    oldmode, resp;
   void EX_print_quiet( );


 if ( EX_batch_mode == EX_INTERACT )
 {

   resp = respon;

   /* beginning stage store the old mode */
   if( rear == front )
   { 
	oldmode = 0;
        if( EX_help_quiet) oldmode |= EX_HELP_QUIET;
        if( EX_disp_quiet) oldmode |= EX_DISP_QUIET;
        if( MS_Gs_messages_on == 0 ) oldmode |= EX_MSG_QUIET;
	EX_quiet_old = oldmode;
   }
   /* set new mode */
   rear = ( ++rear ) % EX_CMD_STACK_SIZE;
   resp &= 0xffff0000; 
   EX_quiet_new[rear] = resp;

   if (resp & EX_HELP_QUIET)  EX_help_quiet = 1;
   else EX_help_quiet = 0;
   if (resp & EX_DISP_QUIET)  EX_disp_quiet = 1;
   else EX_disp_quiet = 0;
   if (resp & EX_MSG_QUIET)   MS_Gs_messages_on = 0;
   else MS_Gs_messages_on = 1;

   if( rear == front ) front = (++front) % EX_CMD_STACK_SIZE;
 }

/*	 
printf("In push  \n");
EX_print_quiet();
*/
}


void EX_pop_quiet(  )
{
   void EX_print_quiet( );   

 if ( EX_batch_mode == EX_INTERACT )
 {

   if( front != rear )
   {
       rear--;
       if(rear < 0 ) rear = EX_CMD_STACK_SIZE - 1; 
       if( rear == front )
       {
	   if (EX_quiet_old & EX_HELP_QUIET)  EX_help_quiet = 1;
	   else EX_help_quiet = 0;
	   if (EX_quiet_old & EX_DISP_QUIET)  EX_disp_quiet = 1;
	   else EX_disp_quiet = 0;
	   if (EX_quiet_old & EX_MSG_QUIET)   MS_Gs_messages_on = 0;
	   else MS_Gs_messages_on = 1;
       }
       else
       {
	   if (EX_quiet_new[rear] & EX_HELP_QUIET)  EX_help_quiet = 1;
	   else EX_help_quiet = 0;
	   if (EX_quiet_new[rear] & EX_DISP_QUIET)  EX_disp_quiet = 1;
	   else EX_disp_quiet = 0;
	   if (EX_quiet_new[rear] & EX_MSG_QUIET)   MS_Gs_messages_on = 0;
	   else MS_Gs_messages_on = 1;
       }	    
   }
 }

/*
printf("In pop \n");
EX_print_quiet();
*/
}

void EX_swap_quiet(  )
{
   int rear_1 , temp;
   void EX_print_quiet( );

   if( rear != front )
   {
        rear_1 = ( rear == 0 )? EX_CMD_STACK_SIZE : rear - 1;
        temp = EX_quiet_new[rear];
	EX_quiet_new[rear] = EX_quiet_new[rear_1];
	EX_quiet_new[rear_1] = temp;

	if (EX_quiet_new[rear] & EX_HELP_QUIET)  EX_help_quiet = 1;
	else EX_help_quiet = 0;
	if (EX_quiet_new[rear] & EX_DISP_QUIET)  EX_disp_quiet = 1;
	else EX_disp_quiet = 0;
	if (EX_quiet_new[rear] & EX_MSG_QUIET)   MS_Gs_messages_on = 0;
	else MS_Gs_messages_on = 1;
   }
   else printf("queue empty\n");
/*
printf("In swap \n");
EX_print_quiet();   
*/
}

void EX_clear_quiet ()
{
   void EX_print_quiet( );

   rear = front = EX_CMD_STACK_SIZE - 1;
/*
printf("In clear \n");
EX_print_quiet();
*/
}



void EX_print_quiet( )
{
   int i;
/*   printf("EX_help_quiet=%d  MS_Gs_messages_on = %hd  EX_disp_quiet = %d\n",EX_help_quiet, MS_Gs_messages_on,EX_disp_quiet);*/
printf(" 2 front=<%d> rear=<%d>       EX_quiet_new=<%d>\n",front,rear,EX_quiet_new[rear]);   
   for ( i = 0; i< EX_CMD_STACK_SIZE; ++i)
       printf("  %d ",EX_quiet_new[i]);
   printf("\n");
   printf("_______________________________\n");
}

#    if testing


int EX_help_quiet;
int EX_disp_quiet;
short MS_Gs_messages_on;

main()
{

   struct EX_quietnode *f;
   int   new, flag, terminate;
int end,first,num;
   int new1;
 terminate = 0;
 while( terminate == 0 )
 {
    printf( "clear 0 push 1 pop 2 swap 3 end 4: ");
    if ( ((num = scanf("%d",&new)) == -1) || (num == 0 ) || (new == 4)) terminate = 1;
    if( !terminate)
    {
        switch ( new )
	{
	    case 1:
		flag = 0;
		printf(" help 1 msg 2 dis 4 : ");
		new1 = 0;
		if ( ((num = scanf("%d",&new1)) == -1) || (num == 0 )) new1 = -1;
		if ( new1 > 0 )
	        {
/*		    while ( new1 > 0 )
		    {
		       if ( new1 >= 4)   {  flag |= EX_DISP_QUIET; new1 -= 4; }
		       if ( new1 >= 2)   {  flag |= EX_MSG_QUIET;  new1 -= 2; }
		       if ( new1 >= 1)   {  flag |= EX_HELP_QUIET; new1 -= 1; }
		    }
		    EX_push_quiet(flag);
*/		    EX_push_quiet(new1);
/*		    printf("\nIn push \n");
		    EX_print_quiet(); 
		    printf("~~~~~~~~~~~~~~~~~~~~~\n"); */
           	}
                break;

	   case 3 :
		EX_swap_quiet();
/*		printf("\nIn swap \n");
		EX_print_quiet(); 
		printf("~~~~~~~~~~~~~~~~~~~~~\n");  */
                break;

	   case 2:
		EX_pop_quiet();
/*		printf("\nIn pop \n");
		EX_print_quiet(); 
		printf("~~~~~~~~~~~~~~~~~~~~~\n");  */
                break;

	   case 0:
		EX_clear_quiet();
/*		printf("\nIn clear \n");
		EX_print_quiet(); 
		printf("~~~~~~~~~~~~~~~~~~~~~\n");  */
                break;
	   default:
	        break;
	}
    }
 }
} 

#    endif

