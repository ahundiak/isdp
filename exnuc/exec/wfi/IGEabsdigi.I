
class implementation IGEabsdig;

#include <OMerrordef.h>
#include <exmacros.h>
#include <exdef.h>
#include <wl.h>
#include <exwl.h>

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <limits.h>

extern Display *EXdisplay;
extern int      Help_active();

#define MAX_WINDOW    40
#define MAX_REGION    20
#define MAX_TOTAL     60
#endif

#if defined( ENV5 )

method activate(IGRlong *msg; IGRint win_no )
{
   IGRint status;
   int    digix,digiy;
   int   fm;
   int   rno;  
   int   mask;

     
    if( ME.IGEabsdig->fm == 1)
    {
       status = Inq_dig_fm(&digix,&digiy);    
    }
    else
    {
	status = Inq_dig(&digix,&digiy);
    }
    status = Create_dig_region(ME.IGEabsdig->fm,0,0,digix,digiy,&rno);
    if( status != 0 )
    {
        printf("\n IGEabsdig activate MAX_REGION exceeded");
    }                                    
    else
    {
        WLuint32              lwin;
        WLuint32              ctx_num;
        WLuint16              lscreen;
        int                   lscreen_type;
        EXwindata            *p_windata;
        struct WLnative_info  native_info;

        /*
         * Store the 'rno' returned by the above call in the instance.
         * This value is needed by the delete call.
         * Added this code for a problem faced by Mike Heatherly. - Srikanth. 
         */
         
         ME.IGEabsdig->rno = rno;
        
        /*=======================*/
        /*  get the WL defaults  */
        /*=======================*/

        status = WLget_active_screen ( &lscreen, &lscreen_type );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        status = CMget_active_context ( lscreen, &ctx_num );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        /*====================================================*/
        /*  register the digitizer window with the WL system  */
        /*====================================================*/

        native_info.base_win = rno;

        status = WLadd_hardware_window ( rno, ctx_num, &native_info, &lwin );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

        /*========================================================*/
        /*  now store the osnum and objid in WL user data fields  */
        /*========================================================*/

        p_windata = (EXwindata*)malloc (sizeof (EXwindata));
        if (!p_windata) return (OM_E_NODYNMEM);

        p_windata->id      = EX_DIGITIZER_WINDOW;
        p_windata->win_os  = OM_Gw_current_OS;
        p_windata->win_oid = my_id;

        status = WLset_user_data ( lwin, (void**)&p_windata, NULL );
        if (status != WL_SUCCESS)
        {
           return (OM_E_ERROR);
        }

       /*========================================================*/
       /*  store the logical window number in the instance data  */
       /*========================================================*/

       ME.IGEgadget->win_no = lwin;

        status = Inq_trackarea(&fm,&ME.IGEabsdig->x1,&ME.IGEabsdig->y1,
                                   &ME.IGEabsdig->x2,&ME.IGEabsdig->y2);
        if (status != 0)
        {
            printf("\nIGEabsdig activate inq trackarea error\n");
        }

        else
        {
            if ( fm == 0 )  /* track area not on floating menu */
	    {
               status = Set_trackarea( ME.IGEabsdig->fm,0,0,200,200);
               if (status != 0)
               {
                  printf("\n IGEabsdig set track area error");
               }
	    }

            /* set dig btn */
            mask = 7;  /* 0111  button 0 1 2 */
            status = Set_dig_btn(rno,mask);
            if (status != 0)
            {
               printf ("\n IGEabsdig set btn error\n");
            }
            else
            {
                 status = ex$add_win_to_exec(win_num = rno,
                                             objid = my_id,
                                             osnum = 1);
                 if(! (1 &status) )
                 {
                     printf("IGEabsdig add win to exec error\n");
                 }
            }
        }
    }
    return (status);
 }                  

method convert_pnt( IGRlong *msg; int *response; struct EX_button *pnt1)
{
    IGRlong    status = OM_S_SUCCESS;
    long byte_count;

               pnt1->window = ME.IGEgadget->win_no;
               pnt1->objid = my_id;
               pnt1->osnum = OM_Gw_current_OS;
               if ( EX_DATA == (*response & EX_DATA) )
                    *response  = ABS_DIG | EX_HARDWARE_GENERATED;

               byte_count = sizeof ( struct EX_button );
               status = ex$putque ( msg = msg,
                                    pos = BACK,
                                    response = response,
                                    byte = &byte_count,
                                    buffer = (char *)pnt1 );
         /*    EXputq_back ( msg, response, &byte_count, pnt1 ); */
               return(status);

}



method delete( int flag )
{
      IGRlong status;
     
/*     Delete_dig_region(ME.IGEgadget->win_no);  Mike Heatherly's problem  -Mohan */
     Delete_dig_region(ME.IGEabsdig->rno);
     Set_trackarea(ME.IGEabsdig->fm,ME.IGEabsdig->x1,ME.IGEabsdig->y1,
                                    ME.IGEabsdig->x2,ME.IGEabsdig->y2);

     status =  om$send ( mode = OM_e_wrt_message,
                         msg = message Root.delete(0),
                         senderid = my_id,
                         targetid = my_id);
     if(! (1&status) )
     {
          printf("IGEabsdig delete self error \n");
     }
     return(status);
}




method create( int fm )
{
    ME.IGEabsdig->fm = fm;

    return(OM_S_SUCCESS);
}

#endif

#if defined( CLIX ) && defined( X11 )

#include <X11/extensions/XDigitizer.h>

method activate(IGRlong *msg; IGRint win_no )
{

/*   int    digix,digiy; */
/*   int   rno;          */

   unsigned long digix,digiy;
   long   origx,origy;
   int   fm;
   DigRegion rno;
   unsigned long   mask;
   int   surface; 
   int   status;
   WLuint32    lwin;
   OMuword     lwin_os;
   OM_S_OBJID  lwin_oid;

/*
   
   DigConfig config; 

    get_config( EXdisplay, &config);

*/

    surface = ( ME.IGEabsdig->fm == 1 ) ? FloatingMenuSurface : DigitizerSurface;

    status = XGetDigitizerGeometry( EXdisplay, surface, &origx, &origy, &digix, &digiy);
    if( ( ( status == NoDigitizer ) && ( surface == DigitizerSurface ) ) ||
        ( ( status == NoFloatingMenu ) && ( surface == FloatingMenuSurface ) ) )
    {
       return( OM_E_ERROR );
    }

    rno = XCreateDigitizerRegion( EXdisplay, surface, origx, origy, digix, digiy);

    if( (rno != NoDigitizer) && (rno != NoFloatingMenu) && 
        (rno != BadValue  )  && (rno != BadAlloc ) )
    {

        status = XGetTrackAreaGeometry( EXdisplay, &fm, 
	     (long *) &ME.IGEabsdig->x1, (long *) &ME.IGEabsdig->y1, &digix,&digiy );

        if (status == NoDigitizer )
        {
            printf("\nIGEabsdig activate inq trackarea error\n");
        }

        else
        {
            if ( fm == DigitizerSurface )  /* track area not on floating menu */
	    {
               XSetTrackAreaGeometry( EXdisplay, fm,0,0,200,200);
	    }

            ME.IGEabsdig->x2 = ME.IGEabsdig->x1 + digix;
	    ME.IGEabsdig->y2 = ME.IGEabsdig->y1 + digiy;

            /* set dig btn */
            mask = DigitizerButton1Mask | DigitizerButton2Mask | DigitizerButton3Mask ;
                 /* mask= 7   0x0111  button 0 1 2 */

            XSetDigitizerButton(EXdisplay,rno,mask);

            XSetDigitizerButtonEvent( EXdisplay, rno, DigButtonPressMask |
	                   DigButtonReleaseMask | DigButtonTimeoutMask );

            status = ex$add_win_to_exec(win_num = rno, objid = my_id,osnum = 1);
            if(! (1 &status) )
            {
                printf("IGEabsdig add win to exec error\n");
            }
            EX_trans_win (rno, &lwin, &lwin_os, &lwin_oid);
            /* EX_scr[slot] = -1;         dig win  screen set to -1 */
            ME.IGEgadget->win_no = lwin;
        }
    }
    else
    {
        printf("\n IGEabsdig activate Create Region Error");
    }                                    


    return (status);
 }                  

method convert_pnt( IGRlong *msg; int *response; struct EX_button *pnt1)
{
    IGRlong    status = OM_S_SUCCESS;
    long byte_count;

               pnt1->window = ME.IGEgadget->win_no;
               pnt1->objid = my_id;
               pnt1->osnum = OM_Gw_current_OS;
               if ( EX_DATA == (*response & EX_DATA) )
                    *response  = ABS_DIG | EX_HARDWARE_GENERATED;

               byte_count = sizeof ( struct EX_button );
               status = ex$putque ( msg = msg,
                                    pos = BACK,
                                    response = response,
                                    byte = &byte_count,
                                    buffer = (char *)pnt1 );
         /*    EXputq_back ( msg, response, &byte_count, pnt1 ); */
               return(status);

}


method delete( int flag )
{
     int        status;
     int        surface;    
     WLuint16   lscreen;
     int        lscreen_type;
     WLuint32   lwin;
     WLuint32   ctx_num;
     struct WLnative_info  native_info;

     lwin = ME.IGEgadget->win_no;

     status = WLget_active_screen ( &lscreen, &lscreen_type );
     if (status != WL_SUCCESS) return (OM_E_ERROR);

     status = CMget_active_context ( lscreen, &ctx_num );
     if (status != WL_SUCCESS) return (OM_E_ERROR);

     status = WLget_native_info ( lwin, ctx_num, &native_info );
     if (status != WL_SUCCESS) return (OM_E_ERROR);

     XDestroyDigitizerRegion( EXdisplay, native_info.base_win);

     surface = ( ME.IGEabsdig->fm == 1 ) ? FloatingMenuSurface : DigitizerSurface;
 
     XSetTrackAreaGeometry( EXdisplay, surface, ME.IGEabsdig->x1,ME.IGEabsdig->y1,
        (ME.IGEabsdig->x2 - ME.IGEabsdig->x1),(ME.IGEabsdig->y2-ME.IGEabsdig->y1) );

     status =  om$send ( mode = OM_e_wrt_message,
                         msg = message Root.delete(0),
                         senderid = my_id,
                         targetid = my_id);
     if(! (1&status) )
     {
          printf("IGEabsdig delete self error \n");
     }
     return(status);
}



method create( int fm )
{
    ME.IGEabsdig->fm = fm;

    return(OM_S_SUCCESS);
}
#endif




end implementation IGEabsdig;
  
