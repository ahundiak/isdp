

// Function library

// created by:   J.H.Kidd  I(UK)    12 feb 1988 and modified on dates shown

// functions are used by including this file in the start of a ppl program

#include "bstypes.h"



extern int BShelix1();

// anglf(x1,y1,x2,y2)

// this function returns the angle (in radians) in the top view (global coords)
// given by the two points x1,y1 & x2,y2.


double anglf(x1,y1,x2,y2)      // function declared as a double
double x1,y1,x2,y2;
{
   double tfang,tfx,tfy; 

   tfx = (x2 - x1);
   tfy = (y2 - y1);


   if ( tfx==0.0 )
   {
      if ( tfy >0 )
         tfang = 1.5707963;
      else
         if ( tfy<0 )
            tfang = 4.712389;
         else
            tfang=999.0;     // error - coincedent points!
   }
   else
   {
      if( tfx>0.0 )
      {
         if( tfy>0.0 )
            tfang = atan(tfy/tfx);
         else
            tfang = 6.2831853 + atan(tfy/tfx);
      }
      else
         tfang = 3.1415927 + atan(tfy/tfx);
   }

   return tfang;

}

//------------------------------------------------------------------

// 27 apr 1989

/* define functions to enter data points in dl, di, dx and xy mode */

extern sprintf();

dlfunc(x,y,z)
double x,y,z;
{
   char str1[40];

   sprintf(str1,"%lf,%lf,%lf",x,y,z);
   ci$put( cmd="dl" );
   ci$put( string=str1 );
}

difunc(d,a)
double d,a;
{
   char str1[40];

   sprintf(str1,"%lf,%lf",d,a);
   ci$put( cmd="di" );
   ci$put( string=str1 );
}

xyfunc(x,y,z)
double x,y,z;
{
   char str1[40];

   sprintf(str1,"%lf,%lf,%lf",x,y,z);
   ci$put( cmd="xy" );
   ci$put( string=str1 );
}

// function to split a string into subdata
// data is stored in a linked list of structures

// functions malloc() and free() must be declared as extern is the 
// calling program
extern	char 	*malloc();

extern  free();
#define SSTR 1
#define SINT 2
#define SREAL 3

/* define structure data type */

typedef struct structname
{
   int  subtype;
   struct structname *next;       /* pointer to next structure in list */
   union
   {
      char *str;
      int  ival;
      double dval;
   } subval;
} splitstruct;

/* define pointers to these structures */

splitstruct *stjk,*stcur,*header;

/* define function as type pointer to structure */

splitstruct *dcstr(sp,del,max)
int max;
char del,*sp;
{
int dcslen,dcnc,dci,dctc,dctt;

   dcslen = strlen(sp);
   dctc = 0;

   /* obtain memory for header structure */

   header = (splitstruct *)malloc(sizeof(splitstruct) );   
   stcur = header;

   header->subtype = SINT;
   header->subval.ival = 1;

   /* loop through characters of input string - testing for the delimeter */
   
   for ( dci=0 ; ( dci<max ) && ( dctc<dcslen ) ; dci=dci+1 )  
   {
   
      /* obtain memory for next structure  */

      stjk = (splitstruct *)malloc(sizeof(splitstruct) );   

sdctcopy:
      /* count the number of characters (dcnc) in substring */

      for( dcnc=0 ; (sp[dctc] != del) && (dctc<dcslen) ; dcnc = dcnc + 1 )
      {
         dctc = dctc + 1;        /* increment total num chars read by one    */
      }

     /* check if null string - ie if no chars found between delimeters     */

      if ( dcnc == 0 )
      {
         dctc = dctc + 1;        /* increment total num chars read by one    */
         /* if more characters left - jump back for next substring */
         if( dctc<dcslen )goto sdctcopy; 
      }
      else
      {
         /* obtain memory for substring */

         stjk->subval.str = (char *)malloc( dcnc+1 );   

         /* copy substring to new memory */
         
         for( dctt=0 ; dctt<dcnc ; dctt=dctt+1 )
         {
            stjk->subval.str[dctt] = sp[dctc-dcnc+dctt];
         }
         strcpy(&stjk->subval.str[dctt],"");

         stjk->subtype = SINT;

         /* string extracted - is it infact an integer or float? */

         for( dctt=0 ; dctt<dcnc ; dctt=dctt+1 )
         {
            if( (stjk->subval.str[dctt])=='.' )
            {
              if( stjk->subtype == SREAL )
              {
                 stjk->subtype = SSTR; /* too many dec pts, ie string */
                 break;
              }
              else
              {
              stjk->subtype = SREAL;
              }
            }
            else 
            {
              if( (stjk->subval.str[dctt])<'0' |
                                    (stjk->subval.str[dctt])>'9' )
              {
                 stjk->subtype = SSTR;
                 break;
              }
            }
         }
         
         if ( stjk->subtype == SINT )
           stjk->subval.ival = atoi ( stjk->subval.str );
         else
           if ( stjk->subtype == SREAL )
             stjk->subval.dval = atof ( stjk->subval.str );


         dctc = dctc + 1;
      }

      /* set pointer in last structure to point to this structure */

      stcur->next = stjk;
      stcur = stjk;           /* current pointer moved on to latest */

   }


   /* check if last string was a null - if so free memory and do not process */

   if ( dcnc == 0 )
   {
      free( (char *)stjk );
      dci = dci - 1;
   }

   header->subval.ival = dci-1;

   return header;
}

/*******************************************************************/

// function to obtain a real value from the user with the option
// of accepting a default, entering a value, or using a data point
// tthe response is returned via the last field

// get float from keyin, moveon ,datapoint

// NB: a non zero value must be entered;

// If the user selects D_RESET - this function returns  0.0 to the main program


double getfloat_kmd( default1, strp, subp0, subang, subsc, resp )

double default1;	// default measurment
char   *strp;		// first part of prompt
double subp0[3];	// origin for measurement point
double subang;		// angle of measure
double subsc;		// scale - operates on measured value when resp = DATA
			//       - if subsc = 2
			//	   then value passed back = value measured / 2
int    *resp;		// response to be returned
{
	char   prompt1[80];
        struct GRevent subevent;
        double subdum, *subp1, subpd[3], tempang;

	strcpy(prompt1,strp);
	strcat(prompt1," [");
	if( default1 == floor(default1) )
	   strcat(prompt1,itoa((int)floor(default1)) );
	else
	   strcat(prompt1,ntoa(default1) );
	strcat(prompt1,"] MOVE_ON / DATA pt");

subv1:
        ci$getevent( event = &subevent,
                stackable = 1,
                prompt = prompt1,
		data = subp1 );

	*resp = subevent.response;

	message( "" );

	switch ( subevent.response )
	{
	case D_RESET:
                return 0.0;                    // reject to last event

	case STRING:
	case VALUE:
                // if string is blank user accepted the default
                if( strcmp(subevent.event.keyin,"")==0 )
		{
                   return default1;
		}
		else
                {
                   if( ( subdum = atof(subevent.event.keyin))==0 )
                   {
                        message( "Invalid Entry - Try Again");
                        goto subv1;
                   }
                   else
                   {
                        return subdum;
                   }
                }
 
        case RESET: // MOVE_ON selected

                return default1;

        case DATA: // DATA point entered

		// measure length from origin [subp0] to data point [subp1] in
		// the measurment angle [subang]

		tempang = anglf(subp0[0],subp0[1],subp1[0],subp1[1]);
		subpd[0] = subp1[0] - subp0[0];
		subpd[1] = subp1[1] - subp0[1];
		subdum = sqrt( subpd[0]*subpd[0] + subpd[1]*subpd[1] );
		if ( subdum == 0 )
		{
                        message( "Invalid Entry - Try Again");
                        goto subv1;
		}
		else
		{
			return subdum*cos(tempang-subang)/subsc;
		}

	default:
                message( "Invalid Entry - Try Again");
                goto subv1;
        }

}

/*******************************************************************/

// function to obtain a real value from the user with the option
// of entering a value, or using a data point
// the response is returned via the last field

// NB: a non zero value must be entered;

// If the user selects D_RESET - this function returns  0.0 to the main program

// get float from keyin, moveon 

double getfloat_kd( strp, subp0, subang, subsc, resp )

char   *strp;		// first part of prompt
double subp0[3];	// origin for measurement point
double subang;		// angle of measure
double subsc;		// scale - operates on measured value when resp = DATA
			//       - if subsc = 2
			//	   then value passed back = value measured / 2
		
int    *resp;		// response to be returned
{
	char   prompt1[80];
        struct GRevent subevent;
        double subdum, *subp1, subpd[3], tempang;

	strcpy(prompt1,strp);
	strcat(prompt1," (Key-in / DATA pt)");

subv1:
        ci$getevent( event = &subevent,
                stackable = 1,
                prompt = prompt1,
		data = subp1 );

	*resp = subevent.response;

	message( "" );

	switch ( subevent.response )
	{
	case D_RESET:
                return 0.0;                    // reject to last event

	case STRING:
	case VALUE:
                // if string is blank user accepted the default
                if( strcmp(subevent.event.keyin,"")==0 )
		{
                        message( "Invalid Entry - Try Again");
                        goto subv1;
		}
		else
                {
                   if( ( subdum = atof(subevent.event.keyin))==0 )
                   {
                        message( "Invalid Entry - Try Again");
                        goto subv1;
                   }
                   else
                   {
                        return subdum;
                   }
                }
 
        case DATA: // DATA point entered

		// measure length from origin [subp0] to data point [subp1] in
		// the measurment angle [subang]

		tempang = anglf(subp0[0],subp0[1],subp1[0],subp1[1]);
		subpd[0] = subp1[0] - subp0[0];
		subpd[1] = subp1[1] - subp0[1];
		subdum = sqrt( subpd[0]*subpd[0] + subpd[1]*subpd[1] );
		if ( subdum == 0 )
		{
                        message( "Invalid Entry - Try Again");
                        goto subv1;
		}
		else
		{
			return subdum*cos(tempang-subang)/subsc;
		}

	default:
                message( "Invalid Entry - Try Again");
                goto subv1;
        }

}

/*******************************************************************/

// function to obtain a real value from the user with the option
// of accepting a default

// NB: a non zero value must be entered;

// If the user selects D_RESET - this function returns  0.0 to the main program

// get float from keyin, moveon 

double getfloat_km( default1, strp )

double default1;	// default measurment
char   *strp;		// first part of prompt
{
	char   prompt1[80];
        struct GRevent subevent;
        double subdum;

	strcpy(prompt1,strp);
	strcat(prompt1," [");
	if( default1 == floor(default1) )
	   strcat(prompt1,itoa((int)floor(default1)) );
	else
	   strcat(prompt1,ntoa(default1) );
	strcat(prompt1,"] MOVE_ON");

subd1:
        ci$getevent( event = &subevent,
                stackable = 1,
                prompt = prompt1 );

	message( "" );

        if ( subevent.response == D_RESET )
        {
                return 0.0;                    // reject to last event
         }
        else if( subevent.response == STRING || subevent.response == VALUE )
        {
                // if string is blank user accepted the default
                if( strcmp(subevent.event.keyin,"")==0 )
		{
		   return default1;
		}
		else
                {
                   if( ( subdum = atof(subevent.event.keyin))==0 )
                   {
                        message( "Invalid Entry - Try again");
                        goto subd1;
                   }
                   else
                   {
                        return subdum;
                   }
                }
        }
        else if ( subevent.response == RESET ) // MOVE_ON selected
        {
                return default1;
        }
        else
        {
                message( "Invalid Entry - Try again");
                goto subd1;
        }

}


//************************************************************************
// get_group_id, get_group_count, get_group_member

#define NULL_OBJ	(GRobj ) 0	// for all group functions

// the following include files are required

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

//************************************************************************

// get_group_id

// function to return group id give object id of group member

// function is of type GRobj and returns the group id on the
// GRconnector.to_owners channel of the member object

// the number of objects on the channel determins what is returned

// if number of group ids = 0 ..... element was not a member of a group
//				    or count macro failed
//				    NULL_OBJ is returned

//    			  = 1 ..... successfull group obj returned

//			  > 1 ..... main group id returned

// Note:  the group must be in the main object space
//        ie osnum = 2;

GRobj	get_group_id( obj_member )

GRobj	obj_member;
{

int	num_chan_obj;
GRobj	obj_group[10];

struct	OM_sd_chanselect	my_chansel;

char	classname[30];

short	osn;

int	msg, i0;


	// count objects in the group 

	my_chansel.type = OM_e_name;
	my_chansel.u_sel.name = "GRconnector.to_owners";

        msg = om$get_channel_count (
                                osnum           = 2,
                                objid           = obj_member,
                                p_chanselect    = &my_chansel,
                                count           = &num_chan_obj );

        if ( msg != OM_S_SUCCESS )
        {
                write("om$get_channel_count : msg = ",msg,"\n");
                om$report_error ( sts = msg );
		return NULL_OBJ;
        }
	else if ( num_chan_obj == 0 )
	{
		write( "no objects on GRconnector.to_owners channel\n");
		return NULL_OBJ;
	}
	else
	{

        	for ( i0=0 ; i0 < num_chan_obj ; i0=i0+1 )
        	{
                	msg = om$get_objid_at_index (
                                osnum           = 2,
                                objid           = obj_member,
                                p_chanselect    = &my_chansel,
                                index           = i0,
                                osnumaddr       = &osn,
                                objidaddr       = &obj_group[i0]
							);
                	if ( msg != OM_S_SUCCESS )
                	{
                        	write("om$get_objid_at_index: msg = ",msg,"\n");
                        	om$report_error ( sts = msg );
				return NULL_OBJ;
                	}
			else
			{
        			msg = om$get_classname ( osnum = 2,
                               		objid = obj_group[i0],
					classname = classname );

//write( "classname",i0," = ",classname," obj = ",obj_group[i0],"\n");


                		if ( msg != OM_S_SUCCESS )
                		{
                        		write("om$get_classname: msg = ",msg,"\n");
                        		om$report_error ( sts = msg );
					return NULL_OBJ;
                		}

				// test if next obj is a group
				// note that obj type GRdrawsheet are ignored

				else if( strcmp( classname,"GRdrawsheet" )==0 )
				{
					// GRdrawsheet - ignored
				}
				else if( strcmp( classname,"GRgrgrp" )!=0 )
				{
					write( "Not a Group Member!\n" );
					return NULL_OBJ;
				}
			}
		}
		if( strcmp(classname,"GRdrawsheet")==0 )
		{
			return obj_group[i0-2];
		}
		else
		{
			return obj_group[i0-1];
		}
        }
}


//************************************************************************
// get_group_member

// function to return a group member given group id and index

// function is of type GRobj and returns the group member id found on the
// GRcmpowner.to_components channel of the group object

// if no group member found ....  NULL_OBJ is returned


// Note:  the group must be in the main object space
//        ie osnum = 2;

GRobj	get_group_member( obj_group , index )
int	index;
GRobj	obj_group;
{

int	num_chan_obj;
GRobj	obj_member;

struct	OM_sd_chanselect	my_chansel;

char	classname[30];

short	osn;

int	msg, i0;


	// check the object passed to this function is a group

	msg = om$get_classname ( osnum = 2,
       		objid = obj_group,
		classname = classname );

	if ( msg != OM_S_SUCCESS )
	{
		write("om$get_classname: msg = ",msg,"\n");
		om$report_error ( sts = msg );
		return NULL_OBJ;
	}
	else if( strcmp( classname,"GRgrgrp" )!=0 )
	{
		write( "Not a Group!\n" );
		return NULL_OBJ;
	}
	else
	{
		// test for elements on the group

		my_chansel.type = OM_e_name;
		my_chansel.u_sel.name = "GRcmpowner.to_components";

        	msg = om$get_channel_count (
                                osnum           = 2,
                                objid           = obj_group,
                                p_chanselect    = &my_chansel,
                                count           = &num_chan_obj );

        	if ( msg != OM_S_SUCCESS )
        	{
                	write("om$get_channel_count : msg = ",msg,"\n");
                	om$report_error ( sts = msg );
			return NULL_OBJ;
        	}
		else if ( num_chan_obj == 0 )
		{
			write( "no objects on GRconnector.to_owners channel\n");
			return NULL_OBJ;
		}
		else if ( num_chan_obj < index )
		{
			write( "invalid index - < num_chan_obj\n");
			return NULL_OBJ;
		}
		else
		{
               		msg = om$get_objid_at_index (
                                osnum           = 2,
                                objid           = obj_group,
                                p_chanselect    = &my_chansel,
                                index           = index,
                                osnumaddr       = &osn,
                                objidaddr       = &obj_member);

               		if ( msg != OM_S_SUCCESS )
               		{
                       		write("om$get_objid_at_index: msg = ",msg,"\n");
                       		om$report_error ( sts = msg );
				return NULL_OBJ;
               		}
		}
		return obj_member;
	}
}

//************************************************************************
// get_group_count

// function to return the number of members of a group given group id

// function is of type int and returns the number of members in the group on the
// GRcmpowner.to_components channel of the group object

// if no group member found ....  0 is returned


// Note:  the group must be in the main object space
//        ie osnum = 2;

get_group_count( obj_group )
GRobj	obj_group;
{

int	num_chan_obj;

struct	OM_sd_chanselect	my_chansel;

char	classname[30];

short	osn;

int	msg, i0;


	// check the object recieved is a group object

	msg = om$get_classname ( osnum = 2,
       		objid = obj_group,
		classname = classname );


	if ( msg != OM_S_SUCCESS )
	{
		write("om$get_classname: msg = ",msg,"\n");
		om$report_error ( sts = msg );
		return 0;
	}
	else if( strcmp( classname,"GRgrgrp" )!=0 )
	{
		write( "Not a Group!\n" );
		return 0;
	}
	else
	{

		my_chansel.type = OM_e_name;
		my_chansel.u_sel.name = "GRcmpowner.to_components";

        	msg = om$get_channel_count (
                                osnum           = 2,
                                objid           = obj_group,
                                p_chanselect    = &my_chansel,
                                count           = &num_chan_obj );

        	if ( msg != OM_S_SUCCESS )
        	{
                	write("om$get_channel_count : msg = ",msg,"\n");
                	om$report_error ( sts = msg );
			return 0;
        	}
		else if ( num_chan_obj == 0 )
		{
			write( "no objects on GRconnector.to_owners channel\n");
			return 0;
		}
		else
		{
			return num_chan_obj;
		}
	}
}

//**********************************************************************

// the next functions are similar to the grooup functions

// they do not have any element tests on them so use with care

//**********************************************************************


GRobj	get_parent( obj_member )
GRobj	obj_member;
{

int	num_chan_obj;
GRobj	obj_group[10];
struct	OM_sd_chanselect	my_chansel;
char	classname[30];
short	osn;
int	msg, i0;

	// count objects in the group as a validity test

	my_chansel.type = OM_e_name;
	my_chansel.u_sel.name = "GRconnector.to_owners";

        msg = om$get_channel_count (
                                osnum           = 2,
                                objid           = obj_member,
                                p_chanselect    = &my_chansel,
                                count           = &num_chan_obj );

        if ( msg != OM_S_SUCCESS )
        {
                write("om$get_channel_count : msg = ",msg,"\n");
                om$report_error ( sts = msg );
		return ;
        }
	else if ( num_chan_obj == 0 )
	{
		write( "no objects on GRconnector.to_owners channel\n");
		return ;
	}
	else
	{

        	for ( i0=0 ; i0 < num_chan_obj ; i0=i0+1 )
        	{
                	msg = om$get_objid_at_index (
                                osnum           = 2,
                                objid           = obj_member,
                                p_chanselect    = &my_chansel,
                                index           = i0,
                                osnumaddr       = &osn,
                                objidaddr       = &obj_group[i0]);

                	if ( msg != OM_S_SUCCESS )
                	{
                        	write("om$get_objid_at_index: msg = ",msg,"\n");
                        	om$report_error ( sts = msg );
				return ;
                	}
			else
			{
        			msg = om$get_classname ( osnum = 2,
                               		objid = obj_group[i0],
					classname = classname );
write( "classname ",i0," = ",classname," obj = ",obj_group[i0],"\n");

                		if ( msg != OM_S_SUCCESS )
                		{
                        		write("om$get_classname: msg = ",msg,"\n");
                        		om$report_error ( sts = msg );
					return ;
                		}
			}
		}
		if( strcmp(classname,"GRdrawsheet")==0 )
		{
			return obj_group[i0-2];
		}
		else
		{
			return obj_group[i0-1];
		}
        }
}
//**********************************************************************
GRobj	list_members( obj_group )
GRobj	obj_group;
{

int	num_chan_obj,i;
GRobj	obj_member;

struct	OM_sd_chanselect	my_chansel;

char	classname[30];

short	osn;

int	msg, i0;


	msg = om$get_classname ( osnum = 2,
       		objid = obj_group,
		classname = classname );

	write( "testing owner channel on ",classname,"\n" );

	if ( msg != OM_S_SUCCESS )
	{
		write("om$get_classname: msg = ",msg,"\n");
		om$report_error ( sts = msg );
		return ;
	}
	else
	{
		// test for elements on the group

		my_chansel.type = OM_e_name;
		my_chansel.u_sel.name = "GRcmpowner.to_components";

        	msg = om$get_channel_count (
                                osnum           = 2,
                                objid           = obj_group,
                                p_chanselect    = &my_chansel,
                                count           = &num_chan_obj );

        	if ( msg != OM_S_SUCCESS )
        	{
                	write("om$get_channel_count : msg = ",msg,"\n");
                	om$report_error ( sts = msg );
			return ;
        	}
		else if ( num_chan_obj == 0 )
		{
			write( "no objects on GRconnector.to_owners channel\n");
			return ;
		}
		else
		{
			write( num_chan_obj," objects on channel\n");

			for( i=0 ; i<num_chan_obj ; i=i+1 )
			{
               		   msg = om$get_objid_at_index (
                                osnum           = 2,
                                objid           = obj_group,
                                p_chanselect    = &my_chansel,
                                index           = i,
                                osnumaddr       = &osn,
                                objidaddr       = &obj_member);

               		   if ( msg != OM_S_SUCCESS )
               		   {
                       		write("om$get_objid_at_index: msg = ",msg,"\n");
                       		om$report_error ( sts = msg );
				return ;
               		   }
			   else
			   {
				msg = om$get_classname ( osnum = 2,
       					objid = obj_member,
					classname = classname );

				write( "object on GRconnector.to_owners = ");
				write( classname,"\n");
			   }
			}
		}
		return obj_member;
	}
}

//************************************************************************

#ifndef junk_include
#define junk_include

int			rtcd;
int			Action;
struct IGRbsp_curve 	*bspline_curvep;
struct IGRdisplay	dis;
struct GRvg_construct   cst;
struct GRid      	dspGRid;
struct GRmd_env		MOD_ENV;
extern  int	free();
extern int 	GRfindmod(),
	 	init_cnst_list();

#define SUCCESS  	134250505
#define	DRAW			GRbd	// 0 DRAW THE OBJECT
#define ERASE			GRbe	// 1 ERASE THE OBJECT
#define HILITE			GRhd	// 2 HIGHLITE THE OBJECT
#define ERASEHILITE		GRhe	// 3 ERASE HIGHLITE THE OBJECT
#define DRAW_HILITE		GRbdhd	// 4 DRAW AND HIGHLITE THE OBJECT
#define ERASE_ERASEHILITE 	GRbehe	// 5 ERASE AND UNHIGHLITE THE OBJECT
#define DRAW_ERASEHILITE	GRbdhe	// 6 DRAW AND UNHIGHLITE THE OBJECT
#define ERASE_HILITE		GRbehd	// 7 ERASE AND HIGHLITE THE OBJECT
#define HALFHILITE		GRhhd	// 8 HALF HILITE THE OBJECT
#define HILITE_OVER		GRhdo	// 9 HILITE ANY OBJECT DISPLAYABLE OR NOT
#define HALFHILITE_OVER		GRhhdo	// 10 HALF HILITE SAME AS HILITE_OVER
#define ERASEHILITE_OVER	GRheo	// 11 ERASE HILITE_OVER
#define DRAW_ERASEHILITE_OVER	GRbdheo	// 12 DRAW AND UNHILITE ANY OBJECT
#define ERASE_ERASEHILITE_OVER	GRbeheo	// 13 ERASE AND UNHILITE ANY OBJECT
#define NODISPLAY		14	// 14 DON'T DO ANY DISPLAY WITH THE OBJECT

#define set_up_easy()  set_up_cnst();

#define set_up_cnst()\
   if( MOD_ENV.md_id.osnum == 0) ci$get_module_info(md_env=&MOD_ENV);\
   if( dspGRid.objid == 0 && dspGRid.osnum == 0)\
   {\
    init_cnst_list();\
    get_symb();\
    dis.color      = cnst_list.color;\
    dis.weight     = cnst_list.weight;\
    dis.style      = cnst_list.style;\
    cst.msg        = &rtcd;\
    cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;\
    cst.display    = &dis;\
    cst.env_info   = &MOD_ENV;\
    cst.newflag    = 0;\
    cst.level      = cnst_list.level;\
    cst.geometry   = 0;\
    cst.class_attr = 0;\
    cst.name       = 0;\
    GRfindmod(&dspGRid);\
    }


// PUT A NAME ON AN OBJECT WITH A CHECK AND AN INCREMENTER
char	object_name[132];
int	counter,counter1;

#define put_name(name,object)\
  rtcd = -1;\
  counter=0;\
  strcpy(object_name,(name));\
  while( rtcd != SUCCESS)\
  {\
    ci$send(msg = message GRvg.GRputname(\
		&rtcd,\
		object_name),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);\
    if( rtcd == SUCCESS) break;\
    counter=counter+1;\
    strcpy(object_name,(name));\
    strcat(object_name,itoa(counter));\
  }\
  strcpy(name,object_name);

#define name_display(object,name,disp)\
	  if( strcmp((name),"0") != 0 )\
	  {\
            put_name((name), (object));\
	  }\
	  if((disp) != 1)\
	  {\
	     display_w_opt((object), (disp));\
	  }


// DISPLAY AN OBJECT
int	display;

/* this function you must supply the display value 0-13 or one of the above */
/* defined display functions						    */

#define display_w_opt(object,disp)\
\
   set_up_easy();\
\
   display = (disp);\
   if( display >= DRAW && display <= ERASE_ERASEHILITE_OVER)\
   {\
   ci$send(msg = message GRgraphics.GRdisplay(\
		&rtcd,\
		&MOD_ENV.md_env.matrix_type,\
		MOD_ENV.md_env.matrix,\
		&display,\
		&dspGRid),\
	   	targetid = (object).objid,\
		targetos = (object).osnum);\
   }



/*---------------------- gr$make_composite_curve ------------------------*/

#omdef gr$make_composite_curve(
			GRids_in,
			GRid_out,
			name     = "0", 				
			disp     = DRAW)      				

 make_comp_curve( (GRids_in), (GRid_out), (name), (disp));			
#endomdef


struct GRlc_info *LCINF;
int	loopy,rt1;

#define  make_comp_curve( objs_in, object, name, disp)\
\
  ci$get_module_info( md_env = &MOD_ENV);\
  Action = 0;\
  while(1)\
	{\
  	   if((objs_in)[Action].objid == 0 || (objs_in)[Action].objid == -1 ) break;\
	   Action = Action+1;\
	}\
  LCINF = (struct GRlc_info *) malloc ( Action * sizeof(struct GRlc_info));\
\
  for(loopy = 0; loopy < Action; loopy=loopy+1)\
  {\
	LCINF[loopy].located_obj = (objs_in)[loopy];\
	LCINF[loopy].module_info = MOD_ENV;\
  }\
	(object).objid = NULL_OBJID;\
	(object).osnum = MOD_ENV.md_id.osnum;\
\
       ci$send( msg =  message GRcompcurve.EMmakecomp(\
			&rtcd, &MOD_ENV, Action, LCINF, &rt1),\
			targetid = (object).objid,\
			targetos = (object).osnum);\
	free(LCINF);\
\
	name_display((object), (name), (disp));







/*---------------------- gr$place_helix ------------------------

#omdef gr$place_helix(	point1,
			point2,
			point3,
			start_radius = 1,
			end_radius = -1,
			pitch_gap = 1,
			direction = 0,
			num_pitches = 0,
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				
			
 Abstract:
	This macro will create a helix from the set of inputs.

 Arguments:
	point1		I	double[3]	axis point 1 for the helix

	point2		I	double[3]	axis point 2 for the helix

	point3		I	double[3]	start point for the helix

	start_radius	I	double		starting radius must be > 0.

	end_radius	I	double		ending radius. If end_radius
						is < 0 end_radius = start_radius

	pitch_gap	I	double		distance for 1 revolution

	direction	I	int		clockwise=0/counter clockwise=1

	num_pitches	I	int		number of full revolutions,
						if num_pitches = 0, then the
						helix will go the distance 
						between point1 and point2.

	GRid_out	O	struct GRid	output object id for the helix.

	name		I  	char 		optional name for object

	disp		I	int  		display option.

 Sample Call:

#include "ci_easy.h"
#include "ci_wire.h"
main()
{
	double	p1[3], p2[3], p3[3], sr, er, dir, pg, np;
	char	name[132];
	struct GRid	HELIX;

	ci$get(string = name, prompt="key in name for helix");
	ci$get(value = sr, prompt="key in start radius");
	ci$get(value = er, prompt="key in end radius");
	ci$get(value = dir, prompt="key in direction 0/1");
	ci$get(value = pg, prompt="key in pitch gap");
	ci$get(value = np, prompt="key in number of pitches");

	while(1)
	{
		ci$get(point = p1, prompt="identify axis point 1");
		ci$get(point = p2, prompt="identify axis point 2");
		ci$get(point = p3, prompt="identify start point 3");

 		gr$place_helix(	
			point1 = p1,
			point2 = p2,
			point3 = p3,
			start_radius = sr,
			end_radius = er,
			pitch_gap= pg,
			direction = dir,
			num_pitches = np,
			GRid_out = HELIX,	       			
			name = name, 					
			disp = DRAW);
		
	}
}

 Notes:

 Caveats:

 History:

	8/2/90	jvh	Created and documented.

-----------------------------------------------------------------------*/

#omdef gr$place_helix(	point1,
			point2,
			point3,
			start_radius = 1,
			end_radius = -1,
			pitch_gap = 1,
			direction = 0,
			num_pitches = 0,
			GRid_out = TEMP_GRID,	       			
			name = "0", 					
			disp = DRAW)      				

  create_helix( point1,point2,point3, start_radius, end_radius, pitch_gap,num_pitches,direction,GRid_out,name,disp);

#endomdef





IGRboolean	Full,Dir,Tpr;
int		Nm_pit,ChK;

#define create_helix(p1,p2,p3,sr,er,pg,np,dir,object,name,disp)\
\
  set_up_easy();\
  Dir = (dir);\
  Full = 1;\
  Nm_pit = (np);\
  if( Nm_pit == 0)Full = 0;\
  Tpr = 1;\
  if( (sr) == 0) sr = .001;\
  if( (er) <= 0 ){ ChK = 1; er = fabs(sr);}\
\
  BShelix1( (p1), (p2), (p3), fabs(sr), (pg), Full, Nm_pit, Dir,\
		Tpr, (er), &bspline_curvep, &rtcd);\
\
  if( ChK == 1) {(er) = -1; ChK = 0;}\
  cst.geometry	= (char *)bspline_curvep;\
\
  (object).objid = NULL_OBJID;\
  (object).osnum = MOD_ENV.md_id.osnum;\
\
  ci$send(msg = message GRbcsubbc.GRconstruct(&cst),\
                targetid = (object).objid,\
	        targetos = (object).osnum );\
\
  name_display( (object), (name), (disp));

#endif


