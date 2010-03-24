#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "exms.h"
#include "msdef.h"
#include "FI.h"
#include <ctype.h>
#include <msmacros.h>
#include <UMS.h>

extern int EX_batch_mode;
extern IGRshort MS_Gs_messages_on;
static IGRint  (*MS_GA_function[MS_NO_FUNCTIONS]) ();
/*
 *	Perform initialization -- null varialbes and retrieve 
 *	string from the file
 */

int MS_init (MS_msg, msgnumb, msgname, in_buff, field, justification)
struct MS_sd_msg *MS_msg;
IGRlong msgnumb;
IGRchar *msgname;
IGRchar *in_buff;
IGRint field, justification;
{ 
    int temp_just;
    IGRint temp_field = 3 , ret_code;
    IGRchar *temp;
    
    if (in_buff ) {
        ret_code = 0;
        if (MS_Gs_messages_on) {
            if (field) {
                temp_field = field;
            }
            if (justification != -1)
              {
                temp_just = justification;
              }
            else
              {
              temp_just = FI_CENTER_JUSTIFIED;
              }
            MS_display_message (temp_field, temp_just, in_buff, NULL, 0,0);
	}
    }
    else {
        strcpy (MS_msg->out_msg, "");
        MS_msg->no_msg = msgnumb;
	if (msgname)
	        strcpy (MS_msg->msgname, msgname);
	else
		MS_msg->msgname[0] = 0;
        ret_code = MS_retrieve_msg (MS_msg);
        if (ret_code == UMS_S_SUCCESS)
         {
	     temp = strchr (MS_msg->in_msg, '\n');
	     if (temp) {
	        *temp = '\0';
	    }
            ret_code = 1;
        }
        else   {
            if (msgname) {
                printf ("\n Error finding key <%s> \n", msgname);
            }
            else if (msgnumb != -1) {
                printf ("\n Error finding key <%d> \n", msgnumb);
            }
            ret_code = 0;
        }
    }
    return (ret_code);
}


/*
 *	Display the message in a field if specified or use
 *	default built into message number 
 */

void MS_dis_msg (field, justification, MS_msg, delay_time,  seconds)
IGRint field;
IGRint justification;
struct MS_sd_msg *MS_msg;
IGRint delay_time, seconds;
{
    IGRint temp_test;
    if (MS_Gs_messages_on || ( !MS_Gs_messages_on && EX_batch_mode )) {
        temp_test = MS_msg->no_msg & 7;

        /*
         *	Subtract so #defines for MS_GA_function array can be used.
         */
  	     
        temp_test--;
        if ( temp_test < 0 || temp_test > 6 )
           {
           temp_test = 0;
           }
        if (!field)   {

  	    /*
  	     *	Check to see if message field is requested 
  	     */
  	     
	    if (temp_test == MS_M_STATUS)   {
	    	if (justification == -1) {
	    	    justification =  FI_CENTER_JUSTIFIED;
	    	}
	        field = 1;
	    }

  	    /*
  	     *	Check to see if prompt field is requested 
  	     */
  	     
	    else if (temp_test ==  MS_P_STATUS)   {
	    	if (justification == -1) {
	    	    justification = FI_RIGHT_JUSTIFIED;
	    	}
	        field = 3;
	    }

  	    /*
  	     *	Check to see if error box is requested 
  	     */
  	     
	    else  if (temp_test == MS_F_STATUS){
	        field = -1;
            }
            
  	    /*
  	     *	Otherwise put message in status field
  	     */
  	     
	    else {
	    	if (justification == -1) {
	    	    justification =  FI_CENTER_JUSTIFIED;
	    	}
	        field = 2;
	    }
        }
        else {

/* 
   if a field is specified make sure that there is a justification
   also spedified.
*/            

            if (justification == -1) {
                if (field == 1 || field == 2) {
                    justification =  FI_CENTER_JUSTIFIED;
                }
                else if (field == 3) {
                    justification = FI_RIGHT_JUSTIFIED;
                }
                else if (field == 4) {
                    justification = FI_LEFT_JUSTIFIED;
                }
            }
        }
        (*MS_GA_function[temp_test]) (field, justification, MS_msg->out_msg,
                                         MS_msg, delay_time, seconds);
    }
}

/*
 *	Called from macro to have a central output routine
 */

int MS_out_msg (MS_msg, buff, field, justification, delay_time, seconds,
                                                          buffer_size)
struct MS_sd_msg *MS_msg;
IGRchar *buff;
IGRint  field;
IGRint  justification;
IGRint  delay_time;
IGRint  seconds;
IGRint buffer_size;
{
    MS_format_message (MS_msg);
    if (buff)   
      {
      if (buffer_size)
         {
         	strncpy (buff, MS_msg->out_msg,buffer_size - 1);
            buff[buffer_size - 1] = 0;
         }
      else
         {
	      strcpy (buff, MS_msg->out_msg);
         }
     }
    else   
     {
	 MS_dis_msg (field, justification, MS_msg, delay_time, seconds);
     }
     return(1);
}

/*
 *	insert invisible IGRchar in types -- for now '\1' before 
 *	each %
 */


void MS_fix_type (MS_msg, type)
IGRchar *type;
struct MS_sd_msg  *MS_msg;

{
    IGRchar *t_u_type, *t1_u_type;
    IGRchar s_u_type[81];

    strcpy (MS_msg->u_type, type);
    MS_msg->no_args = 0;
    strcpy (s_u_type, MS_msg->u_type);
    strcpy (MS_msg->for_type, "%");
    t1_u_type = &s_u_type[1];
    while (t_u_type = strchr (t1_u_type, '%'))   {
    IGRchar temp_message[200];
    
	*t_u_type = '\0';
        sprintf (temp_message, "%s%c%%",t1_u_type,'\1');
        strcat (MS_msg->for_type, temp_message);
	t1_u_type = t_u_type;
	t1_u_type++;
	MS_msg->no_args++;
    }
    strcat (MS_msg->for_type, t1_u_type);
    MS_msg->no_args++;
}


/*
 *	Substitute in all variables necessary into the string
 *
 *	$<number>         -----   substitute a particular variable 
 *                                up to 99.
 *      $*                -----   substitute all variables here
 *	$$                -----   $ into the output string
 *      $<anything else>  -----   $ into the string
 *                                (error case actually)
 */

void MS_format_message (MS_msg)
struct MS_sd_msg	*MS_msg;

{
    IGRchar s_in_msg[UMS_MAX_BUFLEN];
    IGRchar s_variables[UMS_MAX_BUFLEN];
    IGRchar *t_in_msg, *t_variables;

    /*
     *	Check for special case of blank message.  Msgbuild puts in
     *	"\1\1" for case of blanks.
     */
     
    if (MS_msg->in_msg[0] == MS_BLANK && MS_msg->in_msg[1] == MS_BLANK) {
        strcpy (MS_msg->out_msg, "");
    }
    else {
        strcpy (s_variables, MS_msg->variables);
        strcpy (s_in_msg, MS_msg->in_msg);
        strcpy (MS_msg->out_msg, "");
        t_in_msg = strchr(s_in_msg, '$');
    
	/*
	 *	while there is a $ in string 
	 */

        while (t_in_msg)   {
    	    *t_in_msg = '\0';
	    strcat (MS_msg->out_msg, s_in_msg);
	    t_in_msg++;

	/*
	 *  Substitute the correct variable into string based on 
	 *  number -- which must be 99 or less
	 */

	    if (isdigit (*t_in_msg))   {
	    IGRint number;
	        number = atoi (t_in_msg);
	        t_in_msg++;
	        if (number > 9)   {
		    t_in_msg++;
	        }
	        if (number <= MS_msg->no_args)   {
		    t_variables = s_variables;
		    while (--number)   {
		        t_variables = strchr (s_variables, '\1');
		        t_variables++;
       		        strcpy (s_variables, t_variables);

		    }
		    if (t_variables = strchr (s_variables, '\1'))   {
		        *t_variables = '\0';
		    }
		    strcat (MS_msg->out_msg, s_variables);
		    strcpy (s_variables, MS_msg->variables);
	        }
	    }

	/*
	 * substitute all varaibles here
	 */

	    else if (*t_in_msg == '*')   {
	    IGRint count = MS_msg->no_args;

	        t_in_msg++;
	        while (--count)   {
		    t_variables = strchr (s_variables, '\1');
		    *t_variables = '\0';
		    strcat (MS_msg->out_msg, s_variables);
		    t_variables++;
		    strcpy (s_variables, t_variables);
	        }
	        strcat (MS_msg->out_msg, s_variables);
	        strcpy (s_variables, MS_msg->variables);
	    }

	/*
	 *  leave a $ in string
         */

	    else if (*t_in_msg == '$')   {
	        t_in_msg++;
	        strcat (MS_msg->out_msg, "$");
	    }

	/*
	 * The $ was not followed by any recognized token -- perform	
	 * some random default action
	 */

	    else   {
	        *t_in_msg = '\0';
	        t_in_msg++;
	        strcat (MS_msg->out_msg, s_in_msg);
	    }
	    strcpy (s_in_msg,t_in_msg);
            t_in_msg = strchr (s_in_msg, '$');
        }
        strcat (MS_msg->out_msg, s_in_msg);
    }
}

void MS_function (status, function)
IGRint status;
IGRint (*function)();
{
    int (*fun)();
    int  MSerrbox();
    int  MS_display_message();
    IGRint ii;
    	    
    if (!function) {
    	fun = MS_display_message;
    }
    else {
        fun = function;
    }
    if (status == MS_SYSTEM_STATUS) {
        for (ii = 0; ii < MS_NO_FUNCTIONS; ii++) {
            MS_GA_function[ii] = fun;
        }
        MS_GA_function[MS_F_STATUS] = MSerrbox;
    }
    else if (status == MS_S_STATUS) {
        MS_GA_function[MS_S_STATUS] = fun;
    }
    else if (status == MS_E_STATUS) {
        MS_GA_function[MS_E_STATUS] = fun;
    }
    else if (status == MS_F_STATUS) {
        MS_GA_function[MS_F_STATUS] = fun;
    }
    else if (status == MS_I_STATUS) {
        MS_GA_function[MS_I_STATUS] = fun;
    }
    else if (status == MS_P_STATUS) {
        MS_GA_function[MS_P_STATUS] = fun;
    }
    else if (status == MS_M_STATUS) {
        MS_GA_function[MS_M_STATUS] = fun;
    }
    else if (status == MS_BOX_STATUS) {
        MS_GA_function[MS_BOX_STATUS] = fun;
    }
    else if (status == MS_ALL_STATUS) {
        for (ii = 0; ii < MS_NO_FUNCTIONS; ii++) {
            MS_GA_function[ii] = fun;
        }
    }
}

#argsused
int MSmessage (field, msgnumb, msgname, justification, buff, type, var, in_buff,
           delay_time, seconds,buffer_size)
IGRint  field;
IGRlong msgnumb;
IGRchar *msgname;
IGRint  justification;
IGRchar *buff;
IGRchar *type;
IGRchar *var;
IGRchar *in_buff;
IGRint  delay_time;
IGRint  seconds;
IGRint buffer_size;
{
    struct MS_sd_msg MS_msg;
    int status;
    status = MS_init ( &MS_msg, msgnumb, msgname,
                                    in_buff, field, justification);
    if ( status  )
    {
        MS_out_msg ( &MS_msg, buff, field, justification, delay_time, seconds,
                       buffer_size );
    }
 return ( status );
}

int MS_return_sizeof_message(msgnumb,msgkey,nbytes)
IGRlong msgnumb;
IGRchar *msgkey;
IGRint *nbytes;
{
int status;
char *msgptr;
char tmp_buf[UMS_MAX_BUFLEN];

  if (msgnumb == MS_NO_MSG) 
     {
      status = UMSRetPtrByKey(&msgptr,nbytes,msgkey);
     }
  else
     {
       status = UMSRetPtrByNum(&msgptr,nbytes,msgnumb);
     }
  if ( status == UMS_W_NOTINMEM )
    {
      if (msgnumb == MS_NO_MSG) 
       {
        status = _UMSReturnByKey(tmp_buf,msgkey);
       }
     else
       {
       status = _UMSReturnByNum(tmp_buf,msgnumb);
       }
     *nbytes = strlen(tmp_buf);
    }
   if ( status == UMS_S_SUCCESS )
    *nbytes = *nbytes + 1;/*add one character for the null*/
   else 
    *nbytes = 0;
    return(status);
}
