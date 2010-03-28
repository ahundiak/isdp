/* PPL include file with functions for controling forms */

#include "exfi.h"

/* note that these variables are declared globally */

char  unused;
GRobj set_id, FORM_ID[10];

int form_resp;

/* variable form_flag is used to determin the state of a form

   0 = not yet initialised
   1 = initialised but not displayed
   2 = initialised and displayed
*/

short form_flag[10];


int form_init(n,form_name)         // declared as integer to return error codes
char form_name[20];
int n;
{
int ret,msg,gads[8];
	set_id = NULL_OBJID;

	if ( ! ci$send(msg = message FIform.init_form( &msg,
			n,
			MY_ID,
			(short) 1,
			&set_id,
			unused,
			form_name),
		construct = 1,
		targetid = FORM_ID[n],
		targetos = "OM_TransOS_0"))
	{
		write("INIT Failed \n");
		return 0;
	}

	if (msg !=1)
	{
		write("INIT Failed \n");
		return 0;
        }


if(n==0)	{
// erase the mdc gadgets
 gads[0] = MDCTEXT;
 gads[1] = MDC;
 gads[2] = MATTEXT;
 gads[3] = MATERIAL;
 gads[4] = DATABASE;
 gads[5]=  UNUSED1;
 gads[6] = UNUSED2;
 ci$send( msg = message FIform.erase_gadgets(&msg,
                        	7,
                        	gads),
                	targetid = FORM_ID[0],
                	targetos = "OM_TransOS_0");
}
	ci$send(msg = message FIform.display_form(&ret, -1, -1),
		targetid = FORM_ID[n],
		targetos = "OM_TransOS_0");


	if (ret != 1)
	{
		write("Display form failed in init_form \n");
		return 0;
        }

	return 1;
}

form_erase(n,fin,res)
int n,fin,res;
{	
int ret,msg;
	ci$send( msg = message FIform.erase_form(fin,res),
		targetid = FORM_ID[n],
		targetos = "OM_TransOS_0" );
	return ret;
}

form_sleep()
{
int fmi;

        for( fmi=0 ; fmi<10 ; fmi=fmi+1 )
        {
	   if (form_flag[fmi] == 2)
	   {
              form_erase(fmi,1,0);
	      form_flag[fmi] == 1;
	   }
        }
}

form_terminate(n)
int n;
{
int ret,msg;

	ci$send( msg = message FIform.delete(1),
		targetid = FORM_ID[n],
		targetos = "OM_TransOS_0" );
	return ret;
}

form_delete()
{
int fmi;

        for( fmi=0 ; fmi<10 ; fmi=fmi+1 )
        {
	   if (form_flag[fmi] != 0)
	   {
              form_terminate(fmi);
	   }
        }
}

form_redisplay(n)
int n;
{
int ret,msg;

	ci$send( msg = message FIform.display_form(&ret,-1,-1),
               	targetid = FORM_ID[n],
               	targetos = "OM_TransOS_0" );
	return ret;
}

form_wakeup()
{
int ret;
int fmi;


        for( fmi=0 ; fmi<10 ; fmi=fmi+1 )
        {
	   if (form_flag[fmi] == 2)
	   {
              ret = form_redisplay(fmi);

	      if (ret != 1)
	      {
		   write("Redisplay form failed in form_wakeup\n");
		   exit;
	      }
	      else
		   form_flag[fmi] == 0;
	   }
        }
}

form_putvalue(n,gadgetnum,dtype,i1,d1,str)
int    n,gadgetnum,dtype,i1;
double d1;
char str[80];
{
int ret,msg;
struct EXFI_data_st put_data_st;

	put_data_st.label = gadgetnum;
	put_data_st.type  = dtype;

        if( dtype == 2 )
           put_data_st.value.ivalue = i1;
        else if( dtype == 3 )
           put_data_st.value.dvalue = d1;
        else 
           strcpy( put_data_st.value.alpha , str );
       

	ci$send( msg = message FIform.put_by_value(&msg,1,&put_data_st),
               	targetid = FORM_ID[n],
               	targetos = "OM_TransOS_0" );
}


form_getvalue(n,gadgetnum,dtype,i1,d1,str)
int    n,gadgetnum,*dtype,*i1;
double *d1;
char   *str;
{
int ret,msg;
struct EXFI_data_st get_data_st;

	get_data_st.label = gadgetnum;

	ci$send( msg = message FIform.get_by_value(&msg,1,&get_data_st),
               	targetid = FORM_ID[n],
               	targetos = "OM_TransOS_0" );

	*dtype = get_data_st.type;

        if( *dtype == EXFI_INT )
           *i1 = get_data_st.value.ivalue;
        else if( *dtype == EXFI_DOUBLE )
           *d1 = get_data_st.value.dvalue;
        else 
           strcpy( str , get_data_st.value.alpha );
      
}

