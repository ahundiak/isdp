class implementation COrlocks;



#include "coimport.h"


#define _start 0

method toggle_lock ( long * sts )
{
  int		  status = OM_S_SUCCESS;

     /* temporary attribute variables */
     struct GRrgdpb           raster_symb;

     IGRlong                  ok;                         
     IGRlong                  buffersize;
     IGRlong                  nret;
     IGRlong   	              l = 0;

     /* 
      * Get the active raster symbology.
      */
     buffersize = sizeof( struct GRrgdpb );
     status = gr$get_raster_graphics( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &raster_symb,
                                      nret = &nret);
     _error_ck2(status,ok,sts);

     switch (me->mytype)
     {
          case RGTRANSON:
               raster_symb.rg_props |= GRIS_TRANSPARENT;
               l = GR_I_RgBckTran;
               break;

          case RGTRANSOFF:
               raster_symb.rg_props &= (~GRIS_TRANSPARENT);
               l = GR_I_RgBckNTran;
               break;

          case RGFASTDISP:
               raster_symb.rg_props |= GRIS_FASTDIS;
               l = GR_I_RgFastDisp;
               break;

          case RGREGDISP:
               raster_symb.rg_props &= (~GRIS_FASTDIS);
               l = GR_I_RgRegDisp;
               break;

          case RGBORDDISPON:
               raster_symb.rg_props |= GRIS_BORDDIS;
               l = GR_I_RgBorDisp;
               break;

          case RGBORDDISPOFF:
               raster_symb.rg_props &= (~GRIS_BORDDIS);
               l = GR_I_RgNBorDisp;
               break;

          case RGGRIDLINEON:
               raster_symb.rg_props |= GRIS_PARTDIS;
               l = GR_I_RgGridOn;
               break;

          case RGGRIDLINEOFF:
               raster_symb.rg_props &= (~GRIS_PARTDIS);
               l = GR_I_RgGridOff;
               break;

          case RGAUTODEFON:
               raster_symb.auto_def = TRUE;
               l = GR_I_RgADefOn;
               break;

          case RGAUTODEFOFF:
               raster_symb.auto_def = FALSE;
               l = GR_I_RgADefOff;
               break;

          case RGFILLON:
               raster_symb.fill_mode = TRUE;
               l = GR_I_RgFillOn;
               break;

          case RGFILLOFF:
               raster_symb.fill_mode = FALSE;
               l = GR_I_RgFillOff;
               break;

     }

     /*
      * Update the raster data parameter block.
      */
     buffersize = sizeof( struct GRrgdpb );
     status = gr$put_raster_graphics( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &raster_symb);
     _error_ck2(status,ok,sts);

     /* Construct the appropriate raster toggle message */
     ex$message(msgnumb = l,
		field = ERROR_FIELD,
                justification = CENTER_JUS,
                seconds = 25);
quit:
  return OM_S_SUCCESS;
}

end implementation COrlocks;
