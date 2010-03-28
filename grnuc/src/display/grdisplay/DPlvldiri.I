/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: DPlvldir
     METHOD NAME:


-----
%SC%    

-----
%EN%
     ON ENTRY:

-----
%EX%
     ON EXIT:

-----
%MD%

    MODULES AND METHODS INVOKED:

    Modules:
    -------------------------------------------------------------------------
   
                 
    Methods:
    -------------------------------------------------------------------------



-----
%RL%

     RELATIONS REFERENCED:

-----
%NB%

     NOTES:

-----
%UI% 

     USER INTERFACE DESCRIPTION:

-----
%CH%

     CHANGE HISTORY:
 	12/10/86
	08/25/94	Sudha	Fix TR# 119419506 - check if the keyed in layer
				LHS and RHS are same. If they are same, error out.
        
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

  Method Name:  init
     
     
  Method Description:

----*/
/*EH*/

class implementation DPlvldir;

#include "grimport.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "msdef.h"
#include "dpdef.h"

/* prototype files */
%safe
#include "DPgetggid.h"
#include "DPlvldiri.h"
%endsafe

#define NULL 0
#define TRUE 1
#define FALSE 0


/*--------------------------------------------------------------*/
/*	method: construct					*/
/*--------------------------------------------------------------*/

method super_construct()

{


ME.DPlvldir->init_flag = 1; /*used in wakeup for only one init*/

 return(OM_S_SUCCESS);

}

/***************************** SU_gra_place *******************************/

method place(OM_p_CHANSELECT chan)


 {
   int stat;
   OM_S_CHANSELECT   chandef;

/* mod is rhs of instance data of super_class*/
                  

  if(chan!=0)
   {
	
			
	chandef.type = OM_e_addr;
	chandef.u_sel.addr = &ME.global_class->mod;

		
	stat = om$send  (msg = message Root.connect(*chan, NULL, 
						my_id,OM_Gw_current_OS, 
						chandef, NULL ), 
				   senderid = my_id, 
				   targetid = sender_id);
						

    if (!(stat&1))
     {
#ifdef DEBUG
      printf("OM_connect_me error\n");
      om$report_error(sts = stat);
#endif
      return(OM_W_ABORT);
     }
    }
   else 
     return(OM_W_ABORT);
   return(OM_S_SUCCESS);
 }




/*<B>*/

/***************************** SU_grdpb_delete *******************************/

method delete (int f_defer_flag)

/*<E>*/

 {
#ifdef DEBUG
  printf("Sorry the super dplvldir cannot be deleted\n");
#endif
  return(OM_S_SUCCESS);
 }



/*<B>*/

/************************** super_wakeup ****************************/

method wake_up ()

 {
IGRlong status;
FILE    *input_file;
char file_name[80];
char buffer[256];
int dimension;
char noeof;
IGRint msg;
IGRint j;
IGRint line;

noeof = 0;
if ( ME.DPlvldir->init_flag )
{
ME.DPlvldir->init_flag = 0;				/*init only once*/

/*initize instance data to reflect no entries in lvldir*/

dimension = 0; 					/*need first struct for lvldir*/

OM_SET_DIMENSION(ME.DPlvldir->lvldir,dimension);
OM_SET_DIMENSION(ME.DPlvldir->back_up,dimension);

/*************************************************************

	open level file

*************************************************************/

status = TRUE;

for ( j = 0 ; status == TRUE ; j++ )
{
 if (status = ex$get_path(index=j, path=file_name, len=sizeof(file_name)))
 {
  strcat ( file_name,"config/DPlvldir" );

  /* open input /config/DPlvldir */

  input_file = (FILE *)fopen(file_name, "r");
  if ( input_file != NULL )
   {

   /***********************************************************

	read each record 

   ************************************************************/

    while ( ! noeof ) /*stay in loop until all records read*/
     {
      if (fgets (buffer,256,input_file) == 0 )
       {
       noeof = 1;
       }
      else  /*have record*/
       {
        strip_blanks ( buffer );

	/******************************************************
	YES WE HAVE LEVELS ADD TO LVLDIR
	******************************************************/


        status = om$send(mode = OM_e_wrt_object,
                       	     msg = message DPlvldir.add_name_to_lvldir
				(&msg,buffer),
                       	     senderid = my_id,
                       	     targetid = my_id);
        if (!status || ! ( 1 & msg ))
		{
		goto error; /*would not translate*/
					   /*or after a dash must be 1 lev*/
		}

       } /* end else have levels */
     } /*end of while eof found*/
    status = fclose ( input_file );    
    status = om$send(mode = OM_e_wrt_object,
                       	     msg = message DPlvldir.verify
				             (&msg,&line),
                       	     senderid = my_id,
                       	     targetid = my_id);
        if (!status || ! ( 1 & msg ))
		{
        OM_SET_DIMENSION(ME.DPlvldir->lvldir,0);
		goto error; /*would not translate*/
					   /*or after a dash must be 1 lev*/
		}
      return ( OM_S_SUCCESS ); /*made it through level definition*/
   } /*end of if open worked*/
  }/*end path found*/
 }/*end for no file found*/
#ifdef DEBUG
printf ( " error opening DPlvldir file  \n" );
#endif
}/*end of init true*/
return ( OM_S_SUCCESS );


error:
     status = fclose ( input_file );    
#ifdef DEBUG
     printf ( "error in DPlvldir file statement # %d. \n");
#endif
     OM_SET_DIMENSION(ME.DPlvldir->back_up,0);
     OM_SET_DIMENSION(ME.DPlvldir->lvldir,0);
     return ( OM_S_SUCCESS );
 

}

/********************** super_sleep ***************************/

/* need to undefine sleep included from stdlib.h */
%undef sleep

method sleep(IGRint type)

{
  return(OM_S_SUCCESS);
}

method create_temp()
{
IGRint nchar;
nchar = OM_DIMENSION_OF (me^^DPlvldir.lvldir);
OM_SET_DIMENSION(ME.DPlvldir->back_up,nchar);
OM_BLOCK_MOVE(me^^DPlvldir.lvldir,me^^DPlvldir.back_up,nchar);
OM_SET_DIMENSION(ME.DPlvldir->lvldir,0);
return (1);
}



method verify(IGRint *msg;IGRint *line)
{
IGRint nchar;
IGRchar *ptr_to_next;
IGRchar col1[256];
IGRchar col2[256];
IGRshort nlevels;
IGRshort level;
IGRlong levels[32];
IGRchar not_exit;
IGRint status;

*line = 0;
not_exit = TRUE;
ptr_to_next = 0;

while (not_exit)
{
   status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.get_lvl_def
			      (msg,&ptr_to_next,(sizeof (col1)), col1,
					(sizeof (col2)),col2),
				senderid = my_id,
				targetid = my_id);


    if (!( 1 & status))
	        {
#ifdef DEBUG
            printf("Error in COrevlvl get_lvl_def");
#endif
  	        goto error;
            }
    if ( *msg == MSFAIL ) 
            {
            /*have gone through all names all is okay*/
            *msg = MSSUCC; /*good verify*/
            OM_SET_DIMENSION(ME.DPlvldir->back_up,0);/*do not need backup*/
            return (OM_S_SUCCESS);
            }

           /* fix for TR# 119419506 - 
 	   * check if layer L.H.S and R.H.S are same, and if they are same error out.
	   * for example "a=a" is an invalid layer. When such layer is keyed in 
	   * it enters an infinite loop and runs out of swap 
	   */
	   status = GRmatch( col1, col2);
	   if ( status ) 
	   {
	      *msg = DPINVINP;
	      goto error;
	   }

           /*send this level name thru DPlvldir to see if it is okay*/
           status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.convert_lev_string
			      (msg,col1, &nlevels, &level,
				levels),
				senderid = my_id,
				targetid = my_id);
 	      if (!( 1 & status))
	        {
#ifdef DEBUG
            printf("Error in DPlvldir convert_level_string");
#endif
  	        goto error;
            }
          if ( *msg == DPINVINP ) 
            {
            not_exit = FALSE;
            nchar = OM_DIMENSION_OF (me^^DPlvldir.back_up);
            OM_SET_DIMENSION(ME.DPlvldir->lvldir,nchar);
            OM_BLOCK_MOVE(me^^DPlvldir.back_up,me^^DPlvldir.lvldir,nchar);
            OM_SET_DIMENSION(ME.DPlvldir->back_up,0);
            *msg = MSFAIL; /*bad verify*/
            }
     *line = *line + 1;
     }/*end while*/
error:
return (OM_S_SUCCESS);
}

method get_lvl_def ( IGRint *msg;
					 IGRchar **ptr_to_next;
				     IGRshort size_col1;
					 IGRchar *col1;
					 IGRshort size_col2;
					 IGRchar *col2)
{
IGRchar *null_char;
IGRchar *equal_char;
IGRchar *semi_char;
IGRchar *start_of_string;
IGRchar *find_last_string;
IGRchar *last_char;
IGRlong last;
IGRshort number_of_char;
IGRchar form_string[132];

find_last_string = & ( ME.DPlvldir->lvldir[0] );
last = OM_DIMENSION_OF (me^^DPlvldir.lvldir);
last_char = find_last_string + last;
*msg = MSSUCC;
if(*ptr_to_next == NULL )
 {
 start_of_string = & ( ME.DPlvldir->lvldir[0] );
 }
else 
 {
 start_of_string = *ptr_to_next ;
 }
if (  ( (IGRint) start_of_string > (IGRint) last_char ) ||
     ( (IGRint) start_of_string == (IGRint) last_char ) )
 {
 *msg = MSFAIL;
 }
else
 {

 null_char = strchr ( start_of_string,NULL ); /*find null*/
 null_char++; /*pointing to next string*/
 *ptr_to_next = null_char;
 strncpy (form_string,start_of_string,132);
 form_string[131] = '\0';

 equal_char = strchr ( form_string,'=' ); /*find equal*/
 *equal_char = 0;
 equal_char++; /*now points to definition*/
 
 number_of_char =  strlen (form_string);
 if (number_of_char > (size_col1 - 1))	
   {
   number_of_char = size_col1;
   }
 strncpy (col1,start_of_string,number_of_char);
 col1[number_of_char] = 0;

 semi_char = strchr ( equal_char,';' ); /*find end*/ 
 if ( semi_char )
  {
   *semi_char = 0; /*null end*/
  }
 number_of_char =  strlen (equal_char);
 if (number_of_char > (size_col2 - 1))	
   {
   number_of_char = size_col2;
   }
 strncpy (col2,equal_char,number_of_char);
 col2[number_of_char] = 0;

 } /*end of if*/
 return (OM_S_SUCCESS);

}    

method init_lvldir ()

{
     OM_SET_DIMENSION(ME.DPlvldir->lvldir,0);
     return (OM_S_SUCCESS);
}

method translate_level_to_number (IGRint *msg; 
				 IGRchar buffer[];
				 IGRshort *nlevels;
				 IGRshort *level)

/*this method initializes level and nlevels*/
/*and translates the level name to a level number*/				 
{
IGRlong levels[32]; /*for this routine not used*/
IGRint status;

*nlevels = 0;

           status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.convert_lev_string
			      (msg,buffer, nlevels, level,
				levels),
				senderid = my_id,
				targetid = my_id);

return (OM_S_SUCCESS);
}
method translate_level_to_mask ( IGRint *msg;
				 IGRchar buffer[];
				 IGRlong levels[])

/* this method fills the 32 int levels array with mask */
/* levels 0-1023 it also initializes the array*/

{
IGRshort nlevels;
IGRshort level;
IGRint status;
IGRint i;

   for ( i = 0 ; i < 32 ; i++)
	{
	levels[i] = 0;
	}

           status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.convert_lev_string
			      (msg,buffer, &nlevels, &level,
					levels),
				senderid = my_id,
				targetid = my_id);

return (OM_S_SUCCESS);
}

 
method convert_lev_string (IGRint *msg; 
				 IGRchar buffer[];
				 IGRshort *nlevels;
				 IGRshort *level;
				 IGRlong levels[])
				 

{
char t_exit;
char is_dash;
char had_dash;
int current_byte;
int i,j,k;
char tmpbuf[256];
int tmplev1 = 0;
int tmplev2;
int num_char;
int status=OM_S_SUCCESS;

*msg = MSSUCC;
num_char = strlen ( buffer );
t_exit = FALSE;	/*exit on ; or # chars */
is_dash = FALSE;	/*assume no dash */
had_dash = FALSE;	/*assume no dash */
i = 0;		/*counter thru tmpbuf*/
        
for(current_byte = 0 ; current_byte <= num_char;current_byte++)	
 {
  /*********************************************************
          look for ending delimeter
  *********************************************************/
     if ( t_exit ) goto wrapup; /*if had ; before num chars*/
     if ( (buffer[current_byte] == '-') || 
		(buffer[current_byte] == ',') ||
		   (buffer[current_byte] == ';') || (current_byte == num_char))
      { /*start if delimeter found end delimeter*/
         if ( buffer[current_byte] == ';' ) t_exit = TRUE;
    	 is_dash = FALSE; /*assume not a dash */
	 if ( buffer[current_byte] == '-' )
	    {
	    is_dash = TRUE; /*is dash must remember for next number*/
	    }
	 if ( i == 0  )
	    {
	    goto error;
	    }
	 else  /*have something in tmpbuf-convert it */
	    {
	    tmpbuf[i] = 0; /*null pointer for last character*/
            for ( k = 0 ; k < i ; k++ )
                {
/*               status = isalnum(tmpbuf[k]); */
		/*** FIX 90N0466 ***/
                 status = !(isalpha(tmpbuf[k]));
                 if (!status )
                  break;
                 }

             if (status)
                 {
			/*convert this string to a number*/
	          status = sscanf ( tmpbuf,"%d",&tmplev2);
 					/*can you convert*/
                  }
	       if ( !status )
	       { /*start not converted see if it is in table*/
               if ( is_dash || had_dash )
		  {
		  /*if you had dash and would not translate error*/
                  goto error;
                  }
  	       status = om$send(mode = OM_e_wrt_object,
                       		msg = message DPlvldir.translate_name_to_number
				(msg,tmpbuf,nlevels,level,levels),
                       		senderid = my_id,
                       		targetid = my_id);
	       if (!status || ! ( 1 & *msg))
		   {
		   goto error; /*would not translate*/
		   }
	       else  /*good return from translation method*/
		   {
		   goto next;
		   }
		} /*end of !scanf*/
	   else
	    { /*start of did translate from scanf*/
	      if ( is_dash )
		   {
		   tmplev1 = tmplev2; /*save this number*/
		   had_dash = TRUE;
		   goto next;
		   }
	      else /*not a dash but did you have one earlier*/
		   {
		   if ( !had_dash )
		      {
		      tmplev1 = tmplev2;		      		
	    	      }
		    if ( tmplev1 > tmplev2  || tmplev1 < 0 ||
					tmplev2 >1023 )
			           goto error;
                    had_dash = FALSE;
		    is_dash = FALSE; /*reset for next series*/
		    for ( j = tmplev1; j <= tmplev2 ; j++ )
		         {
			 ( *nlevels )++;
			 *level = tmplev2; /*set for active level*/
			 levels[j/32] |= (1 << (j % 32));
		         }					 
		      } /* end of else ! is_dash*/
	     } /*end of translate from scanf*/
next:
	 i = 0;
	} /*end of else something in tmpbuf*/
     } /*end if delimeter - or , */
  else /*not a delimeter*/
     {
     tmpbuf[i] = buffer[current_byte];
     i++;
     if  ( i > 80 )
        {
        goto error;
	}
     } /*end not delimeter*/
  }  /*end for*/
wrapup:
 return ( TRUE );
   
error:
 *msg = DPINVINP;
 return ( TRUE );

}



method add_name_to_lvldir (IGRint *msg;
				 IGRchar *buffer)
{
int dimension;
int nchar;
int ntotal;


*msg = MSSUCC;
nchar = strlen ( buffer );
dimension = OM_DIMENSION_OF ( me^^DPlvldir.lvldir );
ntotal = nchar + dimension + 1;  /*add 1 for null*/
OM_SET_DIMENSION(ME.DPlvldir->lvldir,ntotal);
strcpy ( &(ME.DPlvldir->lvldir[dimension]),buffer);

ME.DPlvldir->lvldir[ntotal - 1] = 0;

return (OM_S_SUCCESS);
}


method translate_name_to_number (IGRint *msg; IGRchar *level_name;
				 IGRshort *nlevels; IGRshort *level; 
				 IGRlong *levels)

{
IGRlong status;
IGRchar save_name[256];
IGRchar match_found;
IGRchar *null_char;
IGRchar *equal_char;
IGRchar *start_of_string;
IGRchar *last_char;
IGRlong last;
IGRlong number_of_char;

*msg = MSSUCC;
match_found = FALSE;
start_of_string = & ( ME.DPlvldir->lvldir[0] );
last = OM_DIMENSION_OF (me^^DPlvldir.lvldir);
last_char = start_of_string + last;
while ( start_of_string < last_char )
 {
 equal_char = strchr ( start_of_string,'=' ); /*find equal*/
 number_of_char = equal_char - start_of_string;
 if ( number_of_char > 256 )
    {
    *msg = DPINVINP;
    goto error;
    }
 strncpy ( save_name,start_of_string,number_of_char );
 save_name[number_of_char] = 0; /*null terminate name*/
 equal_char++; /*now points to start of string to decode*/

 /* fix for TR# 119419506 - 
  * check if layer L.H.S and R.H.S are same, and if they are same error out.
  * for example "a=a" is an invalid layer. When such layer is keyed in 
  * it enters an infinite loop and runs out of swap 
  */
 status = GRmatch( save_name, equal_char);
 if ( status ) 
 {
    *msg = DPINVINP;
    goto error;
  }

 status = GRmatch ( level_name,save_name);
 if ( status )
    {  /*found a match set up # levels for user*/
	match_found = TRUE;
	/*everything to right of the = must be bit set in */
	/*level mask buffer*/
        status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.convert_lev_string
			      (msg,equal_char,nlevels,level, levels),
				senderid = my_id,
				targetid = my_id);
	   if ( !status || ! ( 1 & *msg ) )
		{
#ifdef DEBUG
		printf ("Error in DPlvldir in converting namedlevels\n");
#endif
		goto error;
		}
   } /*end found match*/
 null_char = strchr ( start_of_string,'\0' ); /*find null*/
 null_char++; /*pointing to next string*/
 start_of_string = null_char;
 } /*end of while*/
if ( ! (match_found) )
	   {
	   *msg = DPINVINP;
	   return ( OM_S_SUCCESS );
	   }
error:
return (OM_S_SUCCESS);
}    

method translate_number_to_name (IGRint *msg; 
				IGRchar one_or_all_flag; IGRshort level;
				IGRchar **ptr_to_next;IGRshort *ret_nlev;
				IGRlong *size_name;  IGRchar *level_name)
				 

{
IGRlong status;
IGRchar save_name[256];
IGRchar match_found;
IGRchar *null_char;
IGRchar *equal_char;
IGRchar *start_of_string;
IGRchar *find_last_string;
IGRchar *last_char;
IGRlong last;
IGRlong number_of_char;
IGRlong levels[32];
IGRshort match_number_levels;
IGRshort number_levels;
IGRlong i;
IGRchar not_finished;
IGRshort retlev;
IGRshort num_matches;

if ( level < 0 || level > 1023 )
   {
    *msg = DPINVINP;
    goto error;
   }
num_matches =  0;
match_number_levels = 1024; /*init to max*/
find_last_string = & ( ME.DPlvldir->lvldir[0] );
last = OM_DIMENSION_OF (me^^DPlvldir.lvldir);
last_char = find_last_string + last;
*msg = MSSUCC;
match_found = FALSE;
if(( one_or_all_flag == NULL ) || (*ptr_to_next == NULL ))
 {
 start_of_string = & ( ME.DPlvldir->lvldir[0] );
 }
else 
 {
 start_of_string = *ptr_to_next ;
 }
not_finished = TRUE;
while (( (IGRint) start_of_string < (IGRint) last_char ) && (not_finished ))
 {
 equal_char = strchr ( start_of_string,'=' ); /*find equal*/
 number_of_char = equal_char - start_of_string;
 if ( number_of_char > 256 )
    {
    *msg = DPINVINP;
    goto error;
    }
 equal_char++; /*now points to start of string to decode*/

 /*find all levels that go with this name*/

 for ( i = 0 ; i < 32 ; i++)
	{
	levels[i] = 0;
	}
 number_levels = 0; /*new count each time*/

 status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.convert_lev_string
			      (msg,equal_char,&number_levels, &retlev,levels),
				senderid = my_id,
				targetid = my_id);
if ( !status || ! ( 1 & *msg ) )
		{
#ifdef DEBUG
		printf ("Error in DPlvldir in converting namedlevels\n");
#endif
	   *msg = MSFAIL;
		goto error;
		}

 if ( levels[level/32] & ( 1 << (level % 32)) ) /*is owr level in ths name*/
   {
   num_matches++;
   match_found = TRUE;
    if ( match_number_levels >= number_levels )
      {

        strncpy ( save_name,start_of_string,number_of_char );
        save_name[number_of_char] = 0; /*null terminate name*/
        match_number_levels = number_levels;
	if(ret_nlev != NULL)
	{
            *ret_nlev = number_levels;
	}
        if ( one_or_all_flag ) /*if want each match exit*/
         {
          not_finished = FALSE;
         }
      } /*end of match_num > ret_num */
    } /*end of level set in mask*/      
 null_char = strchr ( start_of_string,NULL ); /*find null*/
 null_char++; /*pointing to next string*/
 if ( one_or_all_flag )
   {
    *ptr_to_next = null_char;
   }
 start_of_string = null_char;
 } /*end of while*/
if ( ! (match_found) )
	   {
	   *msg = DPINVINP;
	   return ( OM_S_SUCCESS );
	   }
else
     	{
	/*match found transfer to user buffer*/
	number_of_char = strlen ( save_name );
	if (number_of_char > (*size_name - 1))	
           {
	   number_of_char = *size_name - 1;/*max to transfer*/
	   *msg = DPTRUNC;
	   }	  
    if ( num_matches != 1 )
      {
      *msg = DPAMBIGUOUS;
      }
	strncpy (level_name,save_name,number_of_char);
	level_name[number_of_char] = 0;
error:
        return (OM_S_SUCCESS);
	}
}    

int strip_blanks ( buffer )
char *buffer;

{
int nchar;
int i,j;
char semicolon;

 semicolon = FALSE;
 nchar = strlen (buffer);
 j = 0;
 for ( i = 0 ; i <= nchar ; i++ )
   {
    switch (buffer[i])
     {
      case ' ':
	    if ( !semicolon )	
 	    break;
     default:
           buffer[j] = buffer[i];
	   if ( buffer[j] == 0xa )  /*if newline put null and exit*/
	      {
	       buffer[j] = 0;
	       return(0);
	      }
           else if ( buffer[j] == ';' )
	      {
	      semicolon = TRUE;
	      }
	   j++;
     } /*end of switch*/
   } /*end of for*/
return(0);
} /*end strip_blank*/

IGRint DPlev_num_to_name ( IGRlong     *msg,
                           IGRchar     one_to_all_flag,
                           IGRshort    number,
                           IGRchar     **ptr_to_next,
                           IGRshort    *ret_nlev,
                           IGRlong     *size_name,
                           IGRchar     *name,
                           GRobjid     mod_objid,
                           GRobjid     objid,
                           GRspacenum  osnum )

{
IGRint sts;
GRobjid dplvldir_id;
GRobjid NOD_id;
GRobjid mod_id;
GRspacenum mod_osnum;
IGRlong status = FALSE;

 *msg = MSSUCC;
 if (  objid != NULL_OBJID ) 
   {
   dplvldir_id = objid;
    }
  else
    { 
    
    if ( mod_objid == NULL_OBJID ) 
      { 
      status = ex$get_cur_mod( id=&mod_id, 
				osnum=&mod_osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in DPlvldir get_cur_mod");
#endif
	   *msg = MSFAIL;
	    goto error;
	}
      }
    else
      {
      mod_id = mod_objid;
      mod_osnum = osnum;
      }
   status = ex$get_NOD(NODname="IGENOD",pobjid=&NOD_id,
			modid=mod_id,
			mod_osnum=mod_osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in DPlvldir get_NOD");
#endif
	   *msg = MSFAIL;
	    goto error;
	}
    status = ex$get_objid_from_NOD(NODobjid=NOD_id,
					objname="DPLVLDIR",
					pobjid=&dplvldir_id,
					modid=mod_id,
					mod_osnum=mod_osnum);
	if (!( 1 & status))
	 {
#ifdef DEBUG
          printf("Error in COlevel get_dplvldir_oid");
#endif
	   *msg = MSFAIL;
	  goto error;
         }
     }
   if (ret_nlev != NULL)
   {
   	*ret_nlev = 0;/*init*/
   }
   status = om$send ( mode = OM_e_wrt_object,
			      msg = message DPlvldir.translate_number_to_name
			      (&sts,one_to_all_flag,number,ptr_to_next,
				ret_nlev,size_name, name),
				senderid = NULL_OBJID,
				targetid = dplvldir_id,
				targetos = mod_osnum);

    
    return(status);
error:
    *msg = MSFAIL;
    return(status);
}

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPlevel_to_number ( IGRlong     *msg,
			   IGRchar     *name,
			   IGRshort    *level,
			   GRobjid     mod_objid,
			   GRobjid     objid,
			   GRspacenum  osnum )
#else
IGRint DPlevel_to_number (msg,name,level,mod_objid,objid,osnum)

IGRlong *msg;
IGRchar *name;
IGRshort *level;
GRobjid mod_objid;
GRobjid objid;
GRspacenum osnum;
#endif

{
IGRint sts;
GRobjid dplvldir_id;
GRobjid NOD_id;
GRobjid mod_id;
GRspacenum mod_osnum;
IGRlong status;
IGRshort nlevels;

 *msg = MSSUCC;
 if (  objid != NULL_OBJID ) 
   {
   dplvldir_id = objid;
    }
  else
    { 
    
    if ( mod_objid == NULL_OBJID ) 
      { 
      status = ex$get_cur_mod( id=&mod_id, 
				osnum=&mod_osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in DPlvldir get_cur_mod");
#endif
	    *msg = MSFAIL;
	    goto error;
	}
      }
    else
      {
      mod_id = mod_objid;
      mod_osnum = osnum;
      }
   status = ex$get_NOD(NODname="IGENOD",pobjid=&NOD_id,
			modid=mod_id,
			mod_osnum=mod_osnum);
	if (!( 1 & status))
	{
#ifdef DEBUG
	    printf("Error in DPlvldir get_NOD");
#endif
	    *msg = MSFAIL;
	    goto error;
	}
    status = ex$get_objid_from_NOD(NODobjid=NOD_id,
					objname="DPLVLDIR",
					pobjid=&dplvldir_id,
					modid=mod_id,
					mod_osnum=mod_osnum);
	if (!( 1 & status))
	 {
#ifdef DEBUG
          printf("Error in COlevel get_dplvldir_oid");
#endif
	  *msg = MSFAIL;
	  goto error;
         }
     }
   status = om$send ( mode = OM_e_wrt_object,
	      msg = message DPlvldir.translate_level_to_number
			      (&sts,name,&nlevels,level),
				senderid = NULL_OBJID,
				targetid = dplvldir_id,
				targetos = osnum);
    
  if ( !status ||  ! ( 1 & *msg ))
     {
	*msg = MSFAIL;
	goto error;
     }
  if ( nlevels != 1 )
     {
	*msg = DPINVINP;
     } 
error:
    return ( TRUE );
}

end implementation DPlvldir;
