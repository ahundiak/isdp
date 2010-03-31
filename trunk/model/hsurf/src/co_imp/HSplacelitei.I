class implementation HSplacelite;



#include "stdlib.h"
#include "igrtypedef.h"

%safe
#include "math.h"
%endsafe
#include "stdio.h"
#include "wl.h"

#include "exsysdep.h"
#include "values.h"
#include "msmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "exdef.h"
#include "exmacros.h"
#include "igewindef.h"
#include "igecolmacros.h"
#include "igewinmacros.h"
#include "FI.h"
#include "OMerrordef.h"

#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"

#include "hsmsg.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "HSchglitpar.h"
#include "hsanimate.h"
#include "HSsara.h"
#include "hsmath.h"
#include "bstypes.h"


/*-----------------------
 *  for functions
 *     HRfinish_rgb
 *     HRindex_rgb
 *     HRinit_rgb
 */
 
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "HSpr_render.h"

/*--------------------------
 *  for functions
 *     HScolor_compensate
 *     HSread_rasterfile_header
 *     HSread_type27
 *     HSsphmem_man
 *      HSwrite_type27
 */
 
#include "igrdp.h"
#include "hskyoptypes.h"
#include "HSrle.h"

%safe
#include "HSpr_co_func.h"
%endsafe

/*--------------------------
 *  for functions
 *     HSget_light
 *     HSput_light
 */
 
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*-------------------------*/

#define CHECK_RETURN_CODES    0

#include "hsurferrpriv.h"

#define  ROUND(x) x>0 ? (x+0.5):(x-0.5)

#define DEBUG_TWO_D    0
#define DEBUG_MATRICES    0

#define MAX( x, y )    (x > y) ? (x) : (y)
#define MIN( x, y )    (y > x) ? (x) : (y)

#ifdef BIG_ENDIAN 
#include <fcntl.h>
#endif

#define WITHIN_TOLERANCE( y1, y2, tol )    \
    ( ( FABS( ((y2) - (y1)) ) <= (tol) ) )

struct IDlight_dyn_t
    {
    struct DPele_header line_ele;
    IGRdouble           dit_clip_range[6];
    IGRdouble           wld_to_viewport[16];
    IGRdouble           inv_rotation[16];
    IGRdouble           length;    /* line length in dit */
    };

/*
STATIC PROTOTYPES

#ifdef X11
static void HSwindow_event_routine(int, int, Form);
#endif

static void HScvrt_to_primary( OMuword,    IGRchar *, IGRshort, IGRdouble *, IGRchar   * );
static void HSrgb_to_hls ( double, double, double, double *, double *, double * );
static double HSintensity( double, double, double );
static void HShls_to_rgb ( double *, double *, double *, double, double, double );
static void HScalc_new_rgb( struct HS_light_source *, IGRdouble, IGRdouble, IGRdouble );
static void HSdisplay_sphere( WLuint32, WLuint32, Form, unsigned short *, int, struct HS_light_source * );
static void HSfill_color_square( WLuint32, WLuint32, Form, short, unsigned short, unsigned short, unsigned short );
static void HSset_slider_values( Form, IGRdouble, short, struct HS_light_source *, unsigned short *, int short );
static void HSplacelite_continuous_routine ( int, int, double, Form );
static void HSdisplay_light( WLuint32, WLuint32, Form, IGRint, IGRdouble, struct HS_light_source *, unsigned short *, int, short );
static void HSdisplay_form_error( Form, IGRint, IGRint );
static void HShocus_Pocus( struct IDlight_dyn_t *, IGRdouble pts[6] );
*/

/*--- HSwindow_event_routine -----------------------------------------------*/

#ifdef X11
static void HSwindow_event_routine(int label, int event, Form fp)

/*
NAME
    HSwindow_event_routine (static)

KEYWORD
    light_source

DESCRIPTION
    This function displays the window associated with the xform

PARAMETERS
    label (IN) - gadget label
    event (IN) - Forms Interface event code.
    fp (IN) - Form pointer.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    02/03/92 Documented. -Trevor Mink
*/

    {
    unsigned int   cmd_oid;
    unsigned short cmd_os;
    long           msg;

    if (event == FI_DISPLAY)
        {
        FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );

        om$send( senderid = cmd_oid,
                 targetid = cmd_oid,
                 targetos = cmd_os,
                      msg = message HSplacelite.init_form_display(&msg)  );
        }
    } /* HSwindow_event_routine */
#endif

/*--- HScvrt_to_primary -----------------------------------------------*/

static void HScvrt_to_primary( OMuword osnum,
                               IGRchar *unit_type,
                              IGRshort display_alias,
                             IGRdouble *value,
                               IGRchar *string )
/*
NAME
    HScvrt_to_primary (static)

KEYWORD
    light_source

DESCRIPTION
    This function converts a floating point number that is in working
    units to a character string representation that is in primary
    distance units.

PARAMETERS
    osnum (IN) - Object space of current module.
    unit_type (IN) - Value used by co$cvt_imp_to_alias macro.
    display_alias (IN) - ditto.
    value (IN) - The floating point value (double precision) passed in.
    string (OUT) - Character representation of the number passed in.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    IGRlong                 msg;
    IGRlong                 num_alias;
    IGRshort                field_size;
    IGRchar                 temp_string[45];
    struct GRIOreadout_spec readout;

    readout.justification     = GRIO_LEFT_JUSTIFY;
    readout.mode              = GRIO_DECIMAL;
    readout.precision         = 4;
    readout.case_type         = GRIO_DEFAULT_CASE;
    readout.leading_zeros     = TRUE;
    readout.trailing_zeros    = FALSE;
    readout.decimal_char      = GRIO_PERIOD;
    readout.thousands_char    = GRIO_NONE;
    readout.intermeas_spacing = 2;
    readout.intrameas_spacing = 1;
    readout.left_fill_char    = ' ';
    readout.alias_displayed   = display_alias;

    num_alias = 1;
    field_size = sizeof( temp_string );

    co$cvt_imp_to_alias( msg           = &msg,
                         unit_type     = unit_type,
                         working_units = value,
                         num_alias     = &num_alias,
                         osnum         = osnum,
                         readout_spec  = &readout,
                         field_size    = &field_size,
                         cvt_list      = temp_string );

    strcpy( string, temp_string );

    } /* HScvrt_to_primary */

/*--- HSrgb_to_hls -----------------------------------------------------------*/

static void HSrgb_to_hls ( 
        double    red, 
        double  green, 
        double  blue,
        double    *hue, 
        double  *luminance, 
        double  *saturation )
/*
NAME
    HSrgb_to_hls (static)

KEYWORD
    light_source

DESCRIPTION
    This function converts light color/intesity of the form Red, Green, Blue
    into hue, luminance and saturation values.

PARAMETERS
    red (IN) - Intesity of the Red contribution for the light ( [0.0 .. 1.0] ).
    green (IN) - ditto for Green.
    blue (IN) - ditto for Blue.
    hue (OUT) - Value of 0.0 to 360.0. Determine color by a circular color model.
    luminance (OUT) - Measure of the brightness (amount of White light).
    saturation (OUT) - Measure of the amount of hue the light contains.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    double    max, min, max1, min1, rc, gc, bc;

    max1 = MAX( red, green );
    max = MAX( max1, blue );

    min1 = MIN( red, green );
    min = MIN( min1, blue );

    /* calculate luminance */
    *luminance = (max + min) / (2.0);

    /* calculate saturation */
    if (max == min)
        {
        /* red = green = blue : achromatic case */
        *saturation = 0.0;
        }
    else
        {
        if (*luminance <= 0.5)
            *saturation = (max - min) / (max + min);
        else
            *saturation = (max - min) / (2.0 - max - min);

        /* calculate hue */
        rc = (max - red) / (max - min);
        gc = (max - green) / (max - min);
        bc = (max - blue) / (max - min);

        if (max == red)
            *hue = bc - gc;
        else    if (max == green)
            *hue = 2.0 + rc - bc;
        else
            *hue = 4.0 + gc - rc;

        *hue *= 60.0;
        if (*hue < 0.0) *hue += 360.0;
        }

    } /* HSrgb_to_hls */

/*--- HSintensity ------------------------------------------------------------*/

static double HSintensity( 
        double    n1, 
        double  n2, 
        double  hue )
/*
NAME
    HSintensity (static)

KEYWORD
    light_source

DESCRIPTION
    This function takes a hue value along with two values that are functions of
    luminance and saturation, and calculates an intensity for an individual RGB
    color. Thus, it needs to be called three seperate times for a full translation
    to RGB.

PARAMETERS
    n1 (IN) - Function of luminance and saturation.
    n2 (IN) - ditto.
    hue (IN) - Color value (0.0 to 360.0)

GLOBALS USED
    none.

RETURN VALUES
    Returns the intensity for the individual Red, Green, or Blue value.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    if (hue < 0.0)
        hue += 360.0;
    else if (hue > 360.0)
        hue -= 360.0;

    if (hue < 60.0)
        return( n1 + (((n2 - n1) * hue) / 60.0) );
    else if (hue < 180.0)
        return( n2 );
    else if (hue < 240.0)
        return( n1 + (((n2 - n1) * (240.0 - hue)) / 60.0) );
    else
        return( n1 );

    } /* HSintensity */

/*--- HShls_to_rgb -----------------------------------------------------------*/

static void HShls_to_rgb ( 
    double    *red, 
    double  *green, 
    double  *blue,
    double    hue,
    double  luminance,
    double  saturation )
/*
NAME
    HShls_to_rgb (static)

KEYWORD
    light_source

DESCRIPTION
    This function converts light color/intesity of the form hue, luminance,
    saturation into Red, Green, and Blue values.

PARAMETERS
    red (OUT) - Intesity of the Red contribution for the light ( [0.0 .. 1.0] ).
    green (OUT) - ditto for Green.
    blue (OUT) - ditto for Blue.
    hue (IN) - Value of 0.0 to 360.0. Determine color by a circular color model.
    luminance (IN) - Measure of the brightness (amount of White light).
    saturation (IN) - Measure of the amount of hue the light contains.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    double    m1, m2;

    if (luminance <= 0.5)
        m2 = luminance * (saturation + 1.0);
    else
        m2 = luminance + saturation - (luminance * saturation);

    m1 = (2.0 * luminance) - m2;

    if (saturation == 0.0)
        {
        /* achromatic case */
        *red = *green = *blue = luminance;
        }
    else
        {
        /* chromatic case */
        *red = HSintensity( m1, m2, hue + 120.0 );
        *green = HSintensity( m1, m2, hue );
        *blue = HSintensity( m1, m2, hue - 120.0 );
        }

     } /* HShls_to_rgb */

/*--- HScalc_new_rgb ------------------------------------------------------*/

static void HScalc_new_rgb( 
    struct HS_light_source *light,
    IGRdouble              new_hue,
    IGRdouble              new_lum, 
    IGRdouble              new_sat )
/*
NAME
    HScalc_new_rgb (static)

KEYWORD
    light_source

DESCRIPTION
    This function calculates new values for RGB given a new hue and/or luminance
    and/or saturation. It places the RGB into the light source structure passed in.

PARAMETERS
    light (IN/OUT) - Structure containing light source definition (including rgb values).
    new_hue (IN) - New hue (-1 indicate no change).
    new_lum (IN) - New luminance (-1 indicate no change).
    new_sat (IN) - New saturation (-1 indicate no change).

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    double hue, lum, sat;
    double red, green, blue;

    /* convert current RGB to HLS */
    HSrgb_to_hls( light->red/255.0, light->green/255.0, light->blue/255.0,
                  &hue, &lum, &sat );

    if ( new_hue != -1.0 )
       hue = new_hue;
    if ( new_lum != -1.0 )
       lum = new_lum;
    if ( new_sat != -1.0 )
       sat = new_sat;

    /* convert back to RGB */
    HShls_to_rgb( &red, &green, &blue, hue, lum, sat);

    light->red = red * 255.0 + 0.5;
    light->green = green * 255.0 + 0.5;
    light->blue = blue * 255.0 + 0.5;

    } /* HScalc_new_rgb */

/*---- HSdisplay_sphere ------------------------------------------------------*/

static void HSdisplay_sphere( WLuint32 lwin_no,
                              WLuint32 context_no,
                                  Form form_ptr,
                        unsigned short *sph_amb,
                                   int color_plane,
                                struct HS_light_source *ambient )
/*
NAME
    HSdisplay_sphere (static)

KEYWORD
    light_source

DESCRIPTION
    This function draws a sphere on the Ambient light form in the color
    of the Red, Green, and Blue of the ambient light passed in.

PARAMETERS
    lwin_no (IN) - logical window number of the Ambient light form.
    form_ptr (IN) - Pointer to form.
    sph_amb (IN) - RGB values of sphere file.
    color_plane (IN) - Number of planes (on which we're displaying).
    ambient (IN/OUT) - Points to ambient light source definition structure.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    char           *buffer;
    int            bufsiz = 513;
    WLcolorref     WhiteIndex;
    int            center_x, center_y;
    int            i, j, sph_red, sph_grn, sph_blu;
    int            length_i, length_j, area_k;
    int            xloc, yloc, xsize, ysize, WLsts;
    unsigned short sph_comp[3][RGB_YMAX];
    struct WLrect  rect;
    int                 bit_size;
    struct WLcontext_info context_info;


/*     if (color_plane == 9) bufsiz *= 2; */
    WLget_context_info( context_no, &context_info );
    if( context_info.base_depth > 8 ) bufsiz *= 2;
    buffer = (char *)malloc( bufsiz );

    WLhide_cursor( lwin_no, 0 );

    WLpack_index_colorref( IGErgb_to_index( context_no, 2, 1, (int)255, (int)255, (int)255 ), &WhiteIndex, TRUE );
    WLsts = WLset_active_symbology( lwin_no, WhiteIndex, 0, 0, 0, WL_SYMB_CHANGE_COLOR ); 

    FIg_get_location( form_ptr, AMB_GADG, &xloc, &yloc );
    FIg_get_size( form_ptr, AMB_GADG, &xsize, &ysize );
    
    rect.x = xloc+1;
    rect.y = yloc+1;
    rect.width  = xsize - 2;
    rect.height = ysize - 2;

    WLdraw_rectangle( lwin_no, &rect, WL_FILL );

    length_i = SPH_XMAX - SPH_XMIN + 1;
    length_j = SPH_YMAX - SPH_YMIN + 1;

    area_k = length_i * length_j;

    for( i=SPH_XMIN; i <= SPH_XMAX; i++ )
        {
        for (j=SPH_YMIN; j <= SPH_YMAX; j++)
            {
            if( ( sph_amb[MY_RED*area_k + i*length_j + j] == 127 ) && 
                ( sph_amb[MY_GRN*area_k + i*length_j + j] == 127 ) && 
                ( sph_amb[MY_BLU*area_k + i*length_j + j] == 128 ) )
                {
                sph_red = 255; sph_grn = 255; sph_blu = 255;
                }
            else
                {
                sph_red = sph_amb[MY_RED*area_k + i*length_j + j] + ambient->red;  
                sph_grn = sph_amb[MY_GRN*area_k + i*length_j + j] + ambient->green; 
                sph_blu = sph_amb[MY_BLU*area_k + i*length_j + j] + ambient->blue;  
                }
    
            if (sph_red > 255) sph_red = 255;
            if (sph_grn > 255) sph_grn = 255;
            if (sph_blu > 255) sph_blu = 255;

            sph_comp[MY_RED][j] = (unsigned short)sph_red;
            sph_comp[MY_GRN][j] = (unsigned short)sph_grn;
            sph_comp[MY_BLU][j] = (unsigned short)sph_blu;
            }

        center_x = xloc + xsize/2;
        center_y = yloc + ysize/2;
        if( context_info.base_depth <= 8 )
        {
            bit_size = 8 ;
        }
        else
        {
           bit_size = 9 ;
        }

    
        HSwrite_type27( lwin_no, 
                        context_no, 
                        bit_size, 
                        buffer, 
                        i, 
                        SPH_XMIN, 
                        SPH_YMIN, 
                        SPH_XMAX, 
                        SPH_YMAX, 
                        sph_comp, 
                        center_x, 
                        center_y );
        }
        
    WLshow_cursor(lwin_no);
    WLflush(lwin_no);
    
    free( (char *)buffer );
    }


/*--- HSfill_color_square ---------------------------------------------------*/

static void HSfill_color_square( WLuint32 lwin_no,
                                 WLuint32 context_no,
                                     Form form_ptr,
                                    short SR,
                                 unsigned short Red, 
                                 unsigned short Green,
                                 unsigned short Blue )
/*
NAME
    HSfill_color_square (static)

KEYWORD
    light_source

DESCRIPTION
    This function draws the color square on the Ambient light form in the
    color passed in through the Red, Green, and Blue values.

PARAMETERS
    lwin_no (IN) - Logical window number of the Ambient light form.
    context_no (IN) - window context number
    form_ptr (IN) - Pointer to form.
    SR (IN) - Whether or not it's a Save/Restore form.
    Red (OUT) - Intesity of the Red contribution for the light ( [0 .. 255] ).
    Green (OUT) - ditto for Green.
    Blue (OUT) - ditto for Blue.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
    
    2/5/93     M Lanier
        WL converted
*/
    {
    int                 xloc, yloc;
    int                 msg, calib_flag;
    struct WLcmap_entry vlt[256];
    struct WLrect       rect;    
    WLcolorref          ColorRef;
    IGRshort            short_slot;

    ige$get_FI_COLOR_phys_slot( context_no = context_no,
                                FI_DEFINE = FI_LT_YELLOW,
                                phys_slot_num = &short_slot);

    vlt[0].slot = short_slot;
    vlt[0].red = Red << 8;
    vlt[0].green = Green << 8;
    vlt[0].blue = Blue << 8;
    vlt[0].flags = 0;

#   if DEBUG
    fprintf( stderr, "slot = %d\trgb = %d, %d, %d\n",
    vlt[0].slot, vlt[0].red, vlt[0].green, vlt[0].blue );
#   endif

    WLload_cmap_entries( context_no, 1, vlt );

    FIg_get_location( form_ptr, LIGHT_COLOR_SQUARE, &xloc, &yloc );

    WLhide_cursor( lwin_no, 0 );

    WLpack_index_colorref( vlt[0].slot, &ColorRef, TRUE );
    WLset_active_symbology( lwin_no, ColorRef, 0, 0, 0, WL_SYMB_CHANGE_COLOR );

    rect.x = xloc+1;
    rect.y = yloc+1;
    rect.width = 30;
    rect.height = 30;

    WLdraw_rectangle( lwin_no, &rect, WL_FILL );

    WLshow_cursor( lwin_no );
    WLflush( lwin_no );

    } /* HSfill_color_square */

/*--- HSset_slider_values ---------------------------------------------------*/

static void HSset_slider_values( Form form_ptr,
                            IGRdouble max,
                                short scale_change,
               struct HS_light_source *light,
                       unsigned short *sph_amb,
                                  int color_plane,
                                short save_restore )
/*
NAME
    HSset_slider_values (static)

KEYWORD
    light_source

DESCRIPTION
    This function draws the color square on the Ambient light form in the
    color passed in through the Red, Green, and Blue values.

PARAMETERS
    form_ptr (IN) - Pointer to form.
    max (IN) - 100 or 255 depending upon the current scale.
    scale_change (IN) - Flag determining if [0..255] scale changes to [0..100] or vice versa.
    light (IN) - Pointer to current light source being shown on form.
    sph_amb (IN) - Call display_sphere to refresh if it's ambient light.
    color_plane (IN) - Number of planes (that we can use) for displaying raster.
    save_restore (IN) - Whether or not it's a Save/Restore form.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    char   buff[50];
    double red, green, blue, hue, lum, sat;

    /* Get the current value of hue from the slider and convert it */
    /* back to an angle.  This is done because HSrgb_to_hls() does */
    /* not change hue if the color is achromatic, i.e., R=G=B.     */

    FIg_get_value( form_ptr, HUE_SLIDER, &hue );
    if ( max == 100.0 )
        hue = hue/100.0 * 360.0;
    else
        hue = hue/255.0 * 360.0;

    HSrgb_to_hls( light->red/255.0, light->green/255.0, light->blue/255.0, &hue, &lum, &sat );
    hue /= 360.0;

    if( max == 100.0 )
        {
        red = (light->red / 2.55);
        green = (light->green / 2.55);
        blue = (light->blue / 2.55);
        hue *= 100.0;
        lum *= 100.0;
        sat *= 100.0;
        }
    else
        {
        red = light->red;
        green = light->green;
        blue = light->blue;
        hue *= 255.0;
        lum *= 255.0;
        sat *= 255.0;
        }

    if ( scale_change )
        {
        FIg_set_high_value( form_ptr, R_SLIDER, max );
        FIg_set_high_value( form_ptr, G_SLIDER, max );
        FIg_set_high_value( form_ptr, B_SLIDER, max );

        FIg_set_high_value( form_ptr, HUE_SLIDER, max );
        FIg_set_high_value( form_ptr, LUMINANCE_SLIDER, max );
        FIg_set_high_value( form_ptr, SATURATION_SLIDER, max );

        FIg_erase ( form_ptr, R_SLIDER );
        FIg_display ( form_ptr, R_SLIDER );
        FIg_erase ( form_ptr, G_SLIDER );
        FIg_display ( form_ptr, G_SLIDER );
        FIg_erase ( form_ptr, B_SLIDER );
        FIg_display ( form_ptr, B_SLIDER );

        FIg_erase ( form_ptr, HUE_SLIDER );
        FIg_display ( form_ptr, HUE_SLIDER );
        FIg_erase ( form_ptr, LUMINANCE_SLIDER );
        FIg_display ( form_ptr, LUMINANCE_SLIDER );
        FIg_erase ( form_ptr, SATURATION_SLIDER );
        FIg_display ( form_ptr, SATURATION_SLIDER );
        }

    FIg_set_value( form_ptr, R_SLIDER, red );
    FIg_set_value( form_ptr, G_SLIDER, green );
    FIg_set_value( form_ptr, B_SLIDER, blue );

    FIg_set_value( form_ptr, HUE_SLIDER, hue );
    FIg_set_value( form_ptr, LUMINANCE_SLIDER, lum );
    FIg_set_value( form_ptr, SATURATION_SLIDER, sat );

    /* Set keyin values */
    sprintf( buff, "%d", (int)(red+0.5) );
    FIg_set_text( form_ptr, R_KEYIN, buff );
    sprintf( buff, "%d", (int)(green+0.5) );
    FIg_set_text( form_ptr, G_KEYIN,buff );
    sprintf( buff, "%d", (int)(blue+0.5) );
    FIg_set_text( form_ptr, B_KEYIN, buff );

    sprintf( buff, "%d", (int)(hue+0.5) );
    FIg_set_text( form_ptr, HUE_KEYIN, buff );
    sprintf( buff, "%d", (int)(lum+0.5) );
    FIg_set_text( form_ptr, LUMINANCE_KEYIN, buff );
    sprintf( buff, "%d", (int)(sat+0.5) );
    FIg_set_text( form_ptr, SATURATION_KEYIN, buff );

    } /* HSset_slider_values */

/*----- HSplacelite_continuous_routine ---------------------------------------------*/

static void HSplacelite_continuous_routine (
               int form_label,
               int gadget_label,
            double value,
              Form fp )
/*
NAME
    HSplacelite_continuous_routine (static)

KEYWORD
    light_source

DESCRIPTION
    If the RGB and HLS sliders are place into continuous mode, this function
    gets called for every move of the mouse after a slider has been activated
    (by a hold on the mouse). It passed it's parameters on the the form_notification
    routine where it handle the slider input appropriately.

PARAMETERS
    form_label (IN) - Self explanatory.
    gadget_label (IN) - ditto.
    value (IN) - Value (if applicable) of gadget selected.
    fp (IN) - Pointer to form.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
*/
    {
    unsigned int   cmd_oid;
    unsigned short cmd_os;

    FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );

    om$send( senderid = cmd_oid,
             targetid = cmd_oid,
             targetos = cmd_os,
                  msg = message HSplacelite.form_notification( form_label, gadget_label, value, fp ) );
    }

/*--- HSdisplay_light ------------------------------------------------------------*/

static void HSdisplay_light( WLuint32 lwin_no,
                             WLuint32 context_no,
                                 Form form_ptr,
                               IGRint curr_lite,
                            IGRdouble max,
               struct HS_light_source *light,
                       unsigned short *sph_amb,
                                  int color_plane,
                                short save_restore )
/*     
NAME
    HSdisplay_light (static)

KEYWORD
    light_source

DESCRIPTION
    This function draws the color square on the Ambient light form in the
    color passed in through the Red, Green, and Blue values.

PARAMETERS
    lwin_no (IN) - Logical window number of the Ambient light form.
    context_on (IN) - window context number
    form_ptr (IN) - Pointer to form.
    max (IN) - 100 or 255 depending upon the current scale.
    light (IN) - Pointer to current light source being shown on form.
    sph_amb (IN) - Call display_sphere to refresh if it's ambient light.
    color_plane (IN) - Number of planes (that we can use) for displaying raster.
    save_restore (IN) - Whether or not it's a Save/Restore form.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    01/24/92 Documented. -Trevor Mink
    
    2/5/93     M. Lanier
        WL converted
*/
    {
    IGRchar buff[80];
    int     Symbol;

    sprintf( buff, "%d", curr_lite+1 );
    FIg_set_text( form_ptr, LITE_NUM_KEYIN, buff );

    if( light->flags & HS_LIGHT_ENABLED )
        FIg_set_state_on( form_ptr, LIGHT_ON_OFF_TOGGLE );
    else
        FIg_set_state_off( form_ptr, LIGHT_ON_OFF_TOGGLE );

    FIg_erase( form_ptr, LIGHT_TYPE_ICON );
    if( light->flags & HS_LIGHT_PARALLEL && light->flags & HS_LIGHT_DATABASE )
        {
        FIfld_set_select( form_ptr, LIGHT_TYPE_SELECT, DIRECTIONAL_DB, 0, TRUE);
        ex$message( msgnumb = HS_I_DirectDB, buff = buff );
        Symbol = DIRECTIONAL_DB_SYM;
        }
    else if( light->flags & HS_LIGHT_POINT )
        {
        FIfld_set_select( form_ptr, LIGHT_TYPE_SELECT, POINT, 0, TRUE );
        ex$message( msgnumb = HS_I_Point, buff = buff );
        Symbol = POINT_SYM;
        }
#if PUT_RENDERING_BACK
    else if( light->flags & HS_LIGHT_PENCIL )
        {
        FIfld_set_select( form_ptr, LIGHT_TYPE_SELECT, PEN, 0, TRUE );
        ex$message( msgnumb = HS_I_Pen, buff = buff );
        Symbol = PEN_SYM;
        }
#endif
    else if( light->flags & HS_LIGHT_SPOT )
        {
        FIfld_set_select( form_ptr, LIGHT_TYPE_SELECT, SPOT, 0, TRUE );
        ex$message( msgnumb = HS_I_Spot, buff = buff );
        Symbol = SPOT_SYM;
        }
    else
        {
        FIfld_set_select( form_ptr, LIGHT_TYPE_SELECT, DIRECTIONAL_VIEW, 0, TRUE);
        ex$message( msgnumb = HS_I_DirectVw, buff = buff );
        Symbol = DIRECTIONAL_VIEW_SYM;
        }

    FIg_set_symbol_index( form_ptr, LIGHT_TYPE_ICON, Symbol );
    FIg_display( form_ptr, LIGHT_TYPE_ICON );
    FIfld_set_text( form_ptr, LIGHT_TYPE_FIELD, 0, 0, buff, FALSE );

    HSset_slider_values( form_ptr, max, TRUE, light, sph_amb, color_plane, save_restore );

    if ( (light->flags & HS_LIGHT_TYPE) == HS_LIGHT_AMBIENT )
        {
        /* update ambient sphere display */
        if (sph_amb != NULL)
            HSdisplay_sphere( lwin_no, 
                              context_no, 
                              form_ptr, 
                              sph_amb, 
                              color_plane, 
                              light);
        }

    HSfill_color_square( lwin_no, 
                         context_no, 
                         form_ptr, 
                         save_restore,
                         (unsigned short)light->red,
                         (unsigned short)light->green,
                         (unsigned short)light->blue );

    } /* HSdisplay_light */

/*--- HSdisplay_form_error ---------------------------------------------*/

static void HSdisplay_form_error( Form form_ptr,
                                IGRint msg_no,
                                IGRint new_light )
/*
NAME
    HSdisplay_form_error (static)

KEYWORD
    light_source

DESCRIPTION
    This function displays a message in the message strip at the
    bottom of the form, waits three seconds, then displays a message
    relative to the existence of the light.

PARAMETERS
    form_ptr (IN) - Pointer to form.
    msg_no (IN) - Number of the initial message.
    new_light (IN) - Boolean that says if light is new.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    --/--/-- Created. -???
    02/04/92 Documented. -Trevor Mink
*/
{
    IGRchar buff[80];

    ex$message( msgnumb = msg_no, buff = buff );
    FIfld_set_text( form_ptr, STATUS1, 0, 0, buff, FALSE );
    sleep( 3 );

    if ( new_light )
        {
        ex$message( msgnumb = HS_I_DefiningNewLight, buff = buff );
        }
    else
        {
        ex$message( msgnumb = HS_I_ModifyingOldLight, buff = buff );
        }

    FIfld_set_text( form_ptr, STATUS1, 0, 0, buff, FALSE );

    }  /* HSdisplay_form_error */

/*--- HShocus_Pocus ------------------------------------------------------------*/

static void HShocus_Pocus( struct IDlight_dyn_t *dyn_info,
                                      IGRdouble pts[6] )
/*
NAME
    HShocus_Pocus (static)

KEYWORD
    light_source

DESCRIPTION
    This function calculates a vector with orientation relative to the
    viewer given two points in world coordinates.

PARAMETERS
    dyn_info (IN) - Contains various matrices used to convert.
    pts (IN/OUT) - Two points that form the vector.

GLOBALS USED
    none.

RETURN VALUES
    none.

HISTORY
    03/024/92 Created. -Trevor Mink
*/
    {
    IGRlong    msg;
    IGRint     one=1, two=2;
    IGRdouble  vector[3];
    IGRdouble  length;
    IGRdouble  port_pts[6], *light;
    IGRdouble  ar, vector_len, extent_x, extent_y;

    length = dyn_info->length;

    MAptsxform(&msg,&two,dyn_info->wld_to_viewport,pts,port_pts);

    light = &port_pts[3];
    extent_x = dyn_info->dit_clip_range[3]-dyn_info->dit_clip_range[0];
    extent_y = dyn_info->dit_clip_range[4]-dyn_info->dit_clip_range[1];

    /*
      Convert the 2d light pt to angles relative to the screen
      normal, -90 to 90 in increments of 2.
     */

    light[0] = ROUND(((light[0]/extent_x - .5) * 90.0)*2.0);
    light[1] = ROUND(((light[1]/extent_y - .5) * 90.0)*2.0);

#   if DEBUG_TWO_D
    fprintf( stderr, "After conversion of light pt to angles relative to screen normal\n" );
    fprintf( stderr, "light vector = %lf, %lf, %lf\n", light[0], light[1], light[2] );
#   endif

    /* Convert angles to light direction vector */

    vector_len = sqrt ((light[0]*light[0]) + (light[1]*light[1]));
 
    if (vector_len < 10.0)  /* They chose a point close to the center, */
        {                     /* make the vector coming from the eye     */
        light[0] = 0.0;
        light[1] = 0.0;
        light[2] = -1.0;
        }
    else
        {
        ar = vector_len/57.296;

        light[0] = -((sin(ar) * light[0]) / vector_len);
        light[1] = ((sin(ar) * light[1]) / vector_len);
        if (vector_len > 89.90)
            light[2] = 0.0;
        else
            light[2] = -(cos(ar));
        }

    vector[0] = light[0];
    vector[1] = light[1];
    vector[2] = light[2];
 
    /* calculated points in wld sys */

    MAptsxform(&msg,&one,dyn_info->inv_rotation,vector,vector);
    pts[0] = pts[3] + vector[0] * length;
    pts[1] = pts[4] + vector[1] * length;
    pts[2] = pts[5] + vector[2] * length;
     
    /* 
    now pts[3-5] is the location of the light, and pts[0-2] is the
    target of the light. Both points in wld coordinate system 
    */

    } /* HShocus_Pocus */

#if DEBUG_MATRICES

static void HSdump_matrices( IGRdouble coi[3],
                             IGRdouble dit_clip_range[6],
                             IGRdouble vw_rot_no_con[16],
                             IGRdouble world_to_vp[16],
                             IGRdouble world_to_view[16],
                             IGRdouble view_volume[6],
                                IGRint gg_flags,
                             IGRdouble view_angle )
    {
    int i;

    fprintf( stderr, "\ncoi = %lf, %lf, %lf\n", coi[0], coi[1], coi[2] );

    fprintf( stderr, "\ndit_clip_range = %lf %lf %lf -> %lf %lf %lf\n",
        dit_clip_range[0], dit_clip_range[1], dit_clip_range[2],
        dit_clip_range[3], dit_clip_range[4], dit_clip_range[5] );

    fprintf( stderr, "\nVW_ROT_NO_CON = ...\n" );
    for( i = 0; i < 4; i++ )
        {
        fprintf( stderr, "%lf %lf %lf %lf\n", vw_rot_no_con[i*4],
            vw_rot_no_con[i*4+1], vw_rot_no_con[i*4+2], vw_rot_no_con[i*4+3] );
        }

    fprintf( stderr, "\nWLD_TO_VIEWPORT = ...\n" );
    for( i = 0; i < 4; i++ )
        {
        fprintf( stderr, "%lf %lf %lf %lf\n", world_to_vp[i*4],
            world_to_vp[i*4+1], world_to_vp[i*4+2], world_to_vp[i*4+3] );
        }

    fprintf( stderr, "\nWLD_TO_VIEW = ...\n" );
    for( i = 0; i < 4; i++ )
        {
        fprintf( stderr, "%lf %lf %lf %lf\n", world_to_view[i*4],
            world_to_view[i*4+1], world_to_view[i*4+2], world_to_view[i*4+3] );
        }

    fprintf( stderr, "\nview_volume = %lf %lf %lf -> %lf %lf %lf\n",
        view_volume[0], view_volume[1], view_volume[2],
        view_volume[3], view_volume[4], view_volume[5] );

    fprintf( stderr, "\ngg_flags = %x\n", gg_flags );

    fprintf( stderr, "\nview_angle = %lf\n", view_angle );
    }
#endif


#define _get_light 0
#define _get_vector 1
#define _init_gadgets 2
#define _process_form 3
#define _determine_next_state 4
#define _get_origin 5
#define _get_target 6
#define _get_radius 7
#define _get_angle 8
#define _get_window 9

method init_command ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    hs$get_place_light_info( last_light_num = &me->curr_lite,
                             light_flags = &me->light_flags );

    if ( me->light_flags & HS_PLACE_LIGHT_SLIDER_RANGE )
        {
        me->scale = ABSOLUTE;
        me->max = 255.0;
        }
    else
        {
        me->scale = PERCENTAGE;
        me->max = 100.0;
        }

    me->sph_amb = NULL;
    me->save_restore = TRUE;
    me->allocated_window = FALSE;
    me->hwin_no = 65535;
    me->context_no = WL_DEFAULT_CONTEXT;

    
    quit:
  return OM_S_SUCCESS;
}

method restore_color_table ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   if ( me->context_no != WL_DEFAULT_CONTEXT )
   {
      CMremove_form_from_wl (me->lscreen_no, me->lwin_no, me->context_no);
      ige$configure_color_table( );
      me->context_no = WL_DEFAULT_CONTEXT;
      me->hwin_no = 65535;
   }
quit:
  return OM_S_SUCCESS;
}

method free_buffer ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    if (me->changing_ambient)
        HSsphmem_man(NULL, SPH_AMB, MEM_FREE);
    quit:
  return OM_S_SUCCESS;
}

method which_state ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    *sts = me->next_state;
    quit:
  return OM_S_SUCCESS;
}

method process_backup ( IGRint *sts; IGRint current_state )
{
  int		  status = OM_S_SUCCESS;

    switch( current_state )
        {
        case GET_ORIGIN:
            me->next_state = PROCESS_FORM;
            break;

        case GET_TARGET:
            me->next_state = GET_ORIGIN;
            break;

        case GET_RADIUS:
            if ( me->light.flags & HS_LIGHT_POINT )
                me->next_state = GET_ORIGIN;
            else
                me->next_state = GET_TARGET;
            break;

        case GET_ANGLE:
            me->next_state = GET_RADIUS;
            break;

        case GET_WINDOW:
            me->next_state = GET_TARGET;
            break;

        }  /* end: switch */
    quit:
  return OM_S_SUCCESS;
}

method display_prompt ( IGRint *sts; IGRint current_state )
{
  int		  status = OM_S_SUCCESS;

    IGRchar s1[20], s2[20], s3[20];
    IGRdouble temp_ang;

    switch( current_state )
       {
       case GET_LIGHT:
           ex$message( msgnumb = HS_P_EntLghtNum, type = "%1d",
                       var = `me->curr_lite+1`, buff = me->prompt );
           break;

       case GET_ORIGIN:
           ex$message( msgnumb = HS_P_EntLghtOrg, type = "%1d",
                       var = `me->curr_lite+1`, buff = me->prompt );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", FALSE,
                              &me->light.location[0], s1 );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", FALSE,
                              &me->light.location[1], s2 );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", TRUE,
                              &me->light.location[2], s3 );

           ex$message( msgnumb = HS_I_DefLghtOrg, type = "%s%s%s",
                       var = `s1,s2,s3`, buff = me->status );

           ex$message( in_buff = me->status, field = ERROR_FIELD,
                       justification = CENTER_JUS );
           break;

       case GET_TARGET:
           ex$message( msgnumb = HS_P_EntLghtTrg, type = "%1d",
                       var = `me->curr_lite+1`, buff = me->prompt );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", FALSE,
                              &me->light.target[0], s1 );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", FALSE,
                              &me->light.target[1], s2 );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", TRUE,
                              &me->light.target[2], s3 );

           ex$message( msgnumb = HS_I_DefLghtTrg, type = "%s%s%s",
                       var = `s1,s2,s3`, buff = me->status );

           ex$message( in_buff = me->status, field = ERROR_FIELD,
                       justification = CENTER_JUS );
           break;

       case GET_RADIUS:
           ex$message( msgnumb = HS_P_EntLghtRad, type = "%1d",
                       var = `me->curr_lite+1`, buff = me->prompt );

           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_DISTANCE", TRUE,
                              &me->light.radius, s1 );

           ex$message( msgnumb = HS_I_DefLghtRad, type = "%s",
                       var = `s1`, buff = me->status );

           ex$message( in_buff = me->status, field = ERROR_FIELD,
                       justification = CENTER_JUS );
           break;

       case GET_ANGLE:
           ex$message( msgnumb = HS_P_EntSpotAng, type = "%1d",
                       var = `me->curr_lite+1`, buff = me->prompt );

           temp_ang = me->light.angle * 2.0;
           HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_ANGLE", TRUE,
                              &temp_ang, s1 );

           ex$message( msgnumb = HS_I_DefSpotAng, type = "%s",
                       var = `s1`, buff = me->status );

           ex$message( in_buff = me->status, field = ERROR_FIELD,
                       justification = CENTER_JUS );
           break;

       case GET_WINDOW:
           ex$message( msgnumb = HS_P_SelVecWindow, buff = me->prompt );
           break;
       }  /* end: switch */

    quit:
  return OM_S_SUCCESS;
}

method process_light_num ( IGRint *sts; IGRint use_default )
{
  int		  status = OM_S_SUCCESS;

    IGRint val;

    *sts = LIGHT_SOURCE;

    if ( (use_default) || (me->event1.subtype == GRst_DEFAULT) )
       val = me->curr_lite + 1;
    else
       val = me->event1.event.value;

    if( (val < 0) || (val > MAX_LIGHTS) )
        {
        *sts = BAD_LIGHT_NUM;
        ex$message( msgnumb = HS_E_InvLightNum );
        sleep( 3 );
        }
    else
        {
        if ( val == 0 )
            *sts = AMBIENT;
        else /* 'me->curr_lite' keeps the last NON-AMBIENT light source number */
            me->curr_lite = val - 1;

        hs$set_place_light_info( last_light_num = me->curr_lite,
                                 light_flags = me->light_flags );
        }

    quit:
  return OM_S_SUCCESS;
}

method process_origin ( IGRint *sts; IGRint use_default )
{
  int		  status = OM_S_SUCCESS;

    struct HS_light_source *light;

    *sts = OM_S_SUCCESS;

    light = &me->light;

    if ( ! use_default )
        {
        /* store origin point */
        light->location[0] = me->event1.event.button.x;
        light->location[1] = me->event1.event.button.y;
        light->location[2] = me->event1.event.button.z;
        }

    if ( light->flags & HS_LIGHT_POINT )
        me->next_state = GET_RADIUS;
    else
        me->next_state = GET_TARGET;
        
    quit:
  return OM_S_SUCCESS;
}

method process_target ( IGRint *sts; IGRint use_default )
{
  int		  status = OM_S_SUCCESS;

    struct HS_light_source *light;
    IGRdouble    pt[3];

    *sts = OM_S_SUCCESS;

    light = &me->light;

    if ( use_default )
        {
        pt[0] = light->target[0];
        pt[1] = light->target[1];
        pt[2] = light->target[2];
        }
    else
        {
        pt[0] = me->event1.event.button.x;
        pt[1] = me->event1.event.button.y;
        pt[2] = me->event1.event.button.z;
        }

    if ( (light->location[0] == pt[0]) &&
         (light->location[1] == pt[1]) &&
         (light->location[2] == pt[2]) )
        {
        *sts = OM_W_WARNING;
        ex$message( msgnumb = HS_E_InvTarget );
        sleep( 3 );
        }
    else
        {
        /* store target point */
        light->target[0] = pt[0];
        light->target[1] = pt[1];
        light->target[2] = pt[2];

        if ( light->flags & HS_LIGHT_PARALLEL )
            {
            if( light->flags & HS_LIGHT_DATABASE )
                me->next_state = FINISHED_SAVE;
            else
                {
                me->next_state = GET_WINDOW;
#if DEBUG
                fprintf( stderr, "me->next_state == GET_WINDOW (%d)\n", GET_WINDOW );
#endif
                }
            }
        else
            me->next_state = GET_RADIUS;
        }

    quit:
  return OM_S_SUCCESS;
}

method process_radius ( IGRint *sts; IGRint use_default )
{
  int		  status = OM_S_SUCCESS;

    IGRdouble new_radius;

    *sts = OM_S_SUCCESS;

    if ( (use_default) || (me->event1.subtype == GRst_DEFAULT) )
        new_radius = me->light.radius;
    else
        new_radius = me->event1.event.value;

    if ( new_radius <= 0.0 )
        {
        *sts = OM_W_WARNING;
        ex$message( msgnumb = HS_E_InvRadius );
        sleep( 3 );
        }
    else
        {
        /* store radius */
        me->light.radius = new_radius;

        if ( me->light.flags & HS_LIGHT_SPOT )
            me->next_state = GET_ANGLE;
        else
            me->next_state = FINISHED_SAVE;
        }

    quit:
  return OM_S_SUCCESS;
}

method process_angle ( IGRint *sts; IGRint use_default )
{
  int		  status = OM_S_SUCCESS;

    IGRdouble new_angle, min, max;
    IGRchar   s1[30], s2[30];

    *sts = OM_S_SUCCESS;

    if ( (use_default) || (me->event1.subtype == GRst_DEFAULT) )
        new_angle = me->light.angle * 2.0;
    else
        new_angle = me->event1.event.value;

    min = M_PI/180.0;  /* 1.0 degrees */
    max = 179.0*M_PI/180.0;  /* 179.0 degrees */

    if ( ((new_angle+0.00000001) < min) || ((new_angle-0.000000001) > max) )
        {
        *sts = OM_W_WARNING;

        HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_ANGLE", FALSE,
                           &min, s1 );
        HScvrt_to_primary( me->ModuleInfo.md_id.osnum, "UOM_ANGLE", TRUE,
                           &max, s2 );

        ex$message( msgnumb = HS_E_InvSpotAng, type = "%s%s",
                    var = `s1,s2` );
        sleep( 3 );
        }
    else
        {
        /* store angle */
        new_angle /= 2.0;  /* convert to half-angle required by tiler */
        me->light.angle = new_angle;

        me->next_state = FINISHED_SAVE;
        }

    quit:
  return OM_S_SUCCESS;
}

method process_window ( IGRint *sts; IGRint use_default )
{
  int		  status = OM_S_SUCCESS;

    *sts = OM_S_SUCCESS;

#   if DEBUG
    fprintf( stderr, "within process_window\n" );
#   endif

    me->next_state = FINISHED_SAVE;
    quit:
  return OM_S_SUCCESS;
}

method get_2d_point ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    /* User hit a data point to identify a vector and a window */
    struct GRid              win_id;
    
/***************************************Courtesy of Tiesheng***********************************/
    IGRshort          four=4;
    IGRint          one=1;
    IGRlong          which_error, msg, ret_bytes, sts1;
    struct var_list       var_list[9];
#if FALSE
    struct IGRpolyline    line_poly;
    struct IGRdisplay     dis_att;
#endif
    IGRdouble          coi[3], coi_vw[3], view_angle, length, len, pts[6];
    IGRdouble          wld_to_view[16], view_volume[6];
    IGRdouble          view_rot_no_const[16];
    IGRint          gg_flags;

    struct IDlight_dyn_t  dyn_info;
    int                   IDlight_view_dyn();
/*    IGRdouble           tan(); */
/*************************************** original *********************************************/

   win_id.objid = me->event1.event.button.objid;
   win_id.osnum = me->event1.event.button.osnum;

   pts[3] = me->event1.event.button.x;
   pts[4] = me->event1.event.button.y;
   pts[5] = me->event1.event.button.z;
/***************************************Courtesy of Tiesheng***********************************/
    var_list[0].var = COI;
    var_list[0].var_ptr = (IGRchar *)coi;
    var_list[0].num_bytes = sizeof(IGRdouble)*3;
    var_list[0].bytes_returned = &ret_bytes;

    var_list[1].var = DIT_CLIP_RANGE;
    var_list[1].var_ptr = (IGRchar *)dyn_info.dit_clip_range;
    var_list[1].num_bytes = 6 * sizeof(IGRdouble);
    var_list[1].bytes_returned = &ret_bytes;

    var_list[2].var = VW_ROT_NO_CON;
    var_list[2].var_ptr = (IGRchar *)view_rot_no_const;
    var_list[2].num_bytes = 16 * sizeof(IGRdouble);
    var_list[2].bytes_returned = &ret_bytes;

    var_list[3].var = WLD_TO_VIEWPORT;
    var_list[3].var_ptr = (IGRchar *)dyn_info.wld_to_viewport;
    var_list[3].num_bytes = 16 * sizeof(IGRdouble);
    var_list[3].bytes_returned = &ret_bytes;

    var_list[4].var = WLD_TO_VIEW;
    var_list[4].var_ptr = (IGRchar *)wld_to_view;
    var_list[4].num_bytes = 16*sizeof(IGRdouble);
    var_list[4].bytes_returned = &ret_bytes;

    var_list[5].var = VW_VOLUME;
    var_list[5].var_ptr = (IGRchar *)view_volume;
    var_list[5].num_bytes = 6 * sizeof(IGRdouble);
    var_list[5].bytes_returned = &ret_bytes;

    var_list[6].var = GRAGAD_FLAGS;
    var_list[6].var_ptr = (IGRchar *)&gg_flags;
    var_list[6].num_bytes = sizeof(IGRint);
    var_list[6].bytes_returned = &ret_bytes;

    var_list[7].var = VIEW_ANGLE;
    var_list[7].var_ptr = (IGRchar *)&view_angle;
    var_list[7].num_bytes = sizeof(IGRdouble);
    var_list[7].bytes_returned = &ret_bytes;

    var_list[8].var = END_PARAM;

    status=dp$inq_set_gragad( msg = &msg,
                     inq0_set1 = 0,
                      osnum = win_id.osnum,
                      gragad_objid = win_id.objid,
                      which_error = &which_error,
                      var_list = var_list);
    if(!status&msg&1) goto error;

#if DEBUG_MATRICES
    HSdump_matrices( coi, dyn_info.dit_clip_range, view_rot_no_const,
        dyn_info.wld_to_viewport, wld_to_view, view_volume, gg_flags,
        view_angle );
#endif
    sts1 = MAinvmx( &msg, &four, view_rot_no_const, dyn_info.inv_rotation );

#if DEBUG_MATRICES
    fprintf( stderr, "sts = %d\tmsg = %d\tfour = %d\n", sts, msg, four );
#endif

    /* calculate the dynamic line's length */

    if(gg_flags & IS_PERSP) {
    /* smaller length on the active z plane */
        MAptsxform(&msg,&one,wld_to_view,coi,coi_vw);  /* pts == COI */
    length = tan(view_angle/2.0) * coi_vw[2];
    length = (length < 0.0)? -length : length;
    length = length/2.0;
    pts[0] = coi[0];
    pts[1] = coi[1];
    pts[2] = coi[2];
    }
    else {
    /* smallest length in the x,y,z directions */
    length = view_volume[3] - view_volume[0];
    if( length > (len=view_volume[4]-view_volume[1])) length = len;
    if( length > (len=view_volume[5]-view_volume[2])) length = len;
    length = length/2.0;
    pts[0] = view_volume[0] + ((view_volume[3] - view_volume[0]) / 2.0) ;
    pts[1] = view_volume[1] + ((view_volume[4] - view_volume[1]) / 2.0) ;
    pts[2] = view_volume[2] + ((view_volume[5] - view_volume[2]) / 2.0) ;
    }
    dyn_info.length = length;

#if FALSE
    /* start dynamics */
    dis_att.color = 2;
    dis_att.weight = 1;
    dis_att.style = 0;

    line_poly.points = pts;
    line_poly.num_points = 2;
 
    dp$build_dis_buffer(buffer = &dyn_info.line_ele,
           display_att = (struct IGRdisplay *)&dis_att,
           geometry = (struct IGRpolyline *)&line_poly,
           type = IGRPY );

    dp$dynamics(dyn_fun=IDlight_view_dyn, information=&dyn_info );
#endif
#if DEBUG_MATRICES
    HSdump_matrices( coi, dyn_info.dit_clip_range, dyn_info.inv_rotation,
        dyn_info.wld_to_viewport, wld_to_view, view_volume, gg_flags,
        view_angle );
#endif
    HShocus_Pocus( &dyn_info, pts );

    me->light.location[0] = pts[3];
    me->light.location[1] = pts[4];
    me->light.location[2] = pts[5];
    me->light.target[0] = pts[0];
    me->light.target[1] = pts[1];
    me->light.target[2] = pts[2];

   me->light.flags = HS_LIGHT_ENABLED | HS_LIGHT_PARALLEL;

   me->light.red =
   me->light.green =
   me->light.blue = 255;

    return(TRUE);

error:
    return(FALSE);

quit:
  return OM_S_SUCCESS;
}

method init_form_display ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    Form     form_ptr;
    int		wno;

    form_ptr = me->forms[0].form_ptr;

    /*  If what we think the hardware window is and what it  */
    /*  actually is differs, then don't do anything yet  */

    FIf_get_window(form_ptr, &wno);
    if ( (WLhwin_no)wno != me->hwin_no )
       return;

    if (me->changing_ambient)
        {
        if (me->sph_amb != NULL)
            HSdisplay_sphere( me->lwin_no, 
                              me->context_no, 
                              form_ptr, 
                              me->sph_amb, 
                              me->color_plane, 
                              &me->ambient );

        HSfill_color_square( me->lwin_no, 
                             me->context_no, 
                             form_ptr, 
                             me->save_restore,
                             (unsigned short)me->ambient.red,
                             (unsigned short)me->ambient.green,
                             (unsigned short)me->ambient.blue );
        }
    else
        {
        HSfill_color_square( me->lwin_no, 
                             me->context_no, 
                             form_ptr, 
                             me->save_restore,
                             (unsigned short)me->light.red,
                             (unsigned short)me->light.green,
                             (unsigned short)me->light.blue );
        }
    quit:
  return OM_S_SUCCESS;
}

method init_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    Form    form_ptr;
    IGRchar buff[80];
    long    msg;

    form_ptr = me->forms[0].form_ptr;

    if ( me->scale == PERCENTAGE )
       FIg_set_state_off( form_ptr, SCALE_TOGGLE );
    else
       FIg_set_state_on( form_ptr, SCALE_TOGGLE );

    if( me->changing_ambient )
       {
       /* Unattach the continuous routine to the sliders */
       FIg_set_continuous_routine( form_ptr, R_SLIDER, NULL );
       FIg_set_continuous_routine( form_ptr, G_SLIDER, NULL );
       FIg_set_continuous_routine( form_ptr, B_SLIDER, NULL );
       FIg_set_continuous_routine( form_ptr, HUE_SLIDER, NULL );
       FIg_set_continuous_routine( form_ptr, LUMINANCE_SLIDER, NULL );
       FIg_set_continuous_routine( form_ptr, SATURATION_SLIDER, NULL );

       FIg_erase( form_ptr, LIGHT_ON_OFF_TOGGLE );
       FIg_erase( form_ptr, NON_AMBIENT_GRP );
       FIg_erase( form_ptr, PLACE_MOD_TEXT );
       FIg_display( form_ptr, MOD_AMB_TEXT );
       FIg_display( form_ptr, AMB_GADG );

       if (me->changing_ambient)
          {
          HSset_slider_values( form_ptr, me->max, TRUE,
                   &me->ambient, me->sph_amb, me->color_plane,
                   me->save_restore );
          }
       }
    else
       {
       /* Attach the continuous routine to the sliders */
       FIg_set_continuous_routine( form_ptr, R_SLIDER,
                    HSplacelite_continuous_routine );
       FIg_set_continuous_routine( form_ptr, G_SLIDER,
                    HSplacelite_continuous_routine );
       FIg_set_continuous_routine( form_ptr, B_SLIDER,
                    HSplacelite_continuous_routine );
       FIg_set_continuous_routine( form_ptr, HUE_SLIDER,
                    HSplacelite_continuous_routine );
       FIg_set_continuous_routine( form_ptr, LUMINANCE_SLIDER,
                    HSplacelite_continuous_routine );
       FIg_set_continuous_routine( form_ptr, SATURATION_SLIDER,
                    HSplacelite_continuous_routine );

       FIg_erase( form_ptr, AMB_GADG );
       FIg_erase( form_ptr, MOD_AMB_TEXT );
       FIg_display( form_ptr, PLACE_MOD_TEXT );
       FIg_display( form_ptr, LIGHT_ON_OFF_TOGGLE );
       FIg_display( form_ptr, NON_AMBIENT_GRP );

       if ( me->new_light )
          {
          /* this light has not been initialized */
          me->light.flags = HS_LIGHT_ENABLED | HS_LIGHT_PARALLEL;
          me->light.red = me->light.green = me->light.blue = 255;
          ex$message( msgnumb = HS_I_DefiningNewLight, buff = buff );
          }
       else
          {
          ex$message( msgnumb = HS_I_ModifyingOldLight, buff = buff );
          }

       FIfld_set_text( form_ptr, STATUS1, 0, 0, buff, FALSE );

       }
#ifdef X11
        FIf_set_window_event_routine(form_ptr, HSwindow_event_routine);
#endif

quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

   Form      form_ptr = NULL;
   char      buff[100], buff2[100];
   int       Pos, sel_flag, int_val;
   char      sString[25];
   short     update_sliders = FALSE;
   short     update_raster = TRUE;
   short     scale_change = FALSE;
   long      msg;
   int       wno, CMsts;
   OMuword   mod_os;
            
   switch( form_label )
      {
      case 0 :

         /* main form */
         form_ptr = me->forms[0].form_ptr;
         switch ( gadget_label )
            {
            case SCALE_TOGGLE:
               update_sliders = TRUE;
               scale_change = TRUE;
               me->light_flags ^= HS_PLACE_LIGHT_SLIDER_RANGE;
               if ( me->scale == PERCENTAGE )
                  {
                  me->scale = ABSOLUTE;
                  me->max = 255.0;
                  }
               else
                  {
                  me->scale = PERCENTAGE;
                  me->max = 100.0;
                  }
               break;

            case LIGHT_TYPE_SELECT:
               FIf_display( me->forms[1].form_ptr );
               break;

            case R_KEYIN:
               update_sliders = TRUE;

               FIfld_get_text( form_ptr, 
                               R_KEYIN, 
                               0, 0, 10, 
                               sString, 
                               &sel_flag, 
                               &Pos );

               sscanf( sString, "%d", &int_val );

               if( int_val < 0 || int_val > me->max )
                  HSdisplay_form_error( form_ptr, 
                                        HS_E_InvValue, 
                                        me->new_light );
               else
                  {
                  if( me->scale == PERCENTAGE ) int_val = int_val * 2.55;

                  if ( me->changing_ambient )
                    me->ambient.red = int_val;
                  else
                     me->light.red = int_val;
                  }
               break;

            case G_KEYIN:
               update_sliders = TRUE;

               FIfld_get_text( form_ptr, 
                               G_KEYIN, 
                               0, 0, 10, 
                               sString, 
                               &sel_flag, 
                               &Pos );

               sscanf( sString, "%d", &int_val );

               if( int_val < 0 || int_val > me->max )
                  HSdisplay_form_error( form_ptr, 
                                        HS_E_InvValue, 
                                        me->new_light );
               else
                  {
                  FIg_set_value( form_ptr, G_SLIDER, (double)int_val );

                  if( me->scale == PERCENTAGE ) int_val = int_val * 2.55;

                  if ( me->changing_ambient )
                     me->ambient.green = int_val;
                  else
                     me->light.green = int_val;
                  }
               break;

            case B_KEYIN:
               update_sliders = TRUE;

               FIfld_get_text( form_ptr, 
                               B_KEYIN, 
                               0, 0, 10, 
                               sString, 
                               &sel_flag, 
                               &Pos );

               sscanf( sString, "%d", &int_val );

               if( int_val < 0 || int_val > me->max )
                  HSdisplay_form_error( form_ptr, 
                                        HS_E_InvValue, 
                                        me->new_light );
               else
                  {
                  if( me->scale == PERCENTAGE ) int_val = int_val * 2.55;

                  if ( me->changing_ambient )
                     me->ambient.blue = int_val;
                  else
                     me->light.blue = int_val;
                  }
               break;

            case R_SLIDER:
               update_sliders = TRUE;

               sprintf( buff, "%d", (int)value );
               FIg_set_text( form_ptr, R_KEYIN, buff );

               if( me->scale == PERCENTAGE ) value = value * 2.55;

               if ( me->changing_ambient )
                  me->ambient.red = value + 0.5;
               else
                  me->light.red = value + 0.5;
               break;

            case G_SLIDER:
               update_sliders = TRUE;

               sprintf( buff, "%d", (int)value );
               FIg_set_text( form_ptr, G_KEYIN, buff );

               if( me->scale == PERCENTAGE ) value = value * 2.55;

               if ( me->changing_ambient )
                  me->ambient.green = value + 0.5;
               else
                  me->light.green = value + 0.5;
               break;

            case B_SLIDER:
               update_sliders = TRUE;

               sprintf( buff, "%d", (int)value );
               FIg_set_text( form_ptr, B_KEYIN, buff );

               if( me->scale == PERCENTAGE ) value = value * 2.55;

               if ( me->changing_ambient )
                  me->ambient.blue = value + 0.5;
               else
                  me->light.blue = value + 0.5;
               break;

            case HUE_KEYIN:
               update_sliders = TRUE;

               FIfld_get_text( form_ptr, 
                               HUE_KEYIN, 
                               0, 0, 10, 
                               sString, 
                               &sel_flag, 
                               &Pos );

               sscanf( sString, "%d", &int_val );

               if( int_val < 0 || int_val > me->max )
                  HSdisplay_form_error( form_ptr, 
                                        HS_E_InvValue, 
                                        me->new_light );
               else
                  {
                  value = (int_val/me->max) * 360.0;
                  if ( me->changing_ambient )
                     HScalc_new_rgb( &me->ambient, value, -1.0, -1.0 );
                  else
                     HScalc_new_rgb( &me->light, value, -1.0, -1.0 );
                  }
               break;

            case LUMINANCE_KEYIN:
               update_sliders = TRUE;

               FIfld_get_text( form_ptr, 
                               LUMINANCE_KEYIN, 
                               0, 0, 10, 
                               sString, 
                               &sel_flag, 
                               &Pos );

               sscanf( sString, "%d", &int_val );

               if( int_val < 0 || int_val > me->max )
                  HSdisplay_form_error( form_ptr, 
                                        HS_E_InvValue, 
                                        me->new_light );
               else
                  {
                  if ( me->changing_ambient )
                     HScalc_new_rgb( &me->ambient, 
                                     -1.0, 
                                     int_val/me->max, 
                                     -1.0 );
                  else
                     HScalc_new_rgb( &me->light, 
                                     -1.0, 
                                     int_val/me->max, 
                                     -1.0 );
                  }
               break;

            case SATURATION_KEYIN:
               update_sliders = TRUE;

                FIfld_get_text( form_ptr, 
                                SATURATION_KEYIN, 
                                0, 0, 10, 
                                sString, 
                                &sel_flag, 
                                &Pos );

               sscanf( sString, "%d", &int_val );

               if( int_val < 0 || int_val > me->max )
                  HSdisplay_form_error( form_ptr, 
                                        HS_E_InvValue, 
                                        me->new_light );
               else
                  {
                  if ( me->changing_ambient )
                     HScalc_new_rgb( &me->ambient, 
                                     -1.0, -1.0, 
                                     int_val/me->max );
                  else
                     HScalc_new_rgb( &me->light, 
                                     -1.0, -1.0, 
                                     int_val/me->max );
                  }
               break;

            case HUE_SLIDER:
               update_sliders = TRUE;

               value = (value/me->max) * 360.0;

               if ( me->changing_ambient )
                  HScalc_new_rgb( &me->ambient, value, -1.0, -1.0 );
               else
                  HScalc_new_rgb( &me->light, value, -1.0, -1.0 );
               break;

            case LUMINANCE_SLIDER:
               update_sliders = TRUE;

               if ( me->changing_ambient )
                  HScalc_new_rgb( &me->ambient, -1.0, value/me->max, -1.0 );
               else
                  HScalc_new_rgb( &me->light, -1.0, value/me->max, -1.0 );
               break;

            case SATURATION_SLIDER:
               update_sliders = TRUE;

               if ( me->changing_ambient )
                  HScalc_new_rgb( &me->ambient, -1.0, -1.0, value/me->max );
               else
                  HScalc_new_rgb( &me->light, -1.0, -1.0, value/me->max );
               break;

            case LIGHT_ON_OFF_TOGGLE:
               me->light.flags ^= HS_LIGHT_ENABLED;
               break;

            case SAVE:
               hs$set_place_light_info( light_flags = me->light_flags,
                                        last_light_num = me->curr_lite );

               if ( me->changing_ambient )
                  {
                  me->next_state = SAVE_AMBIENT;
                  om$send( msg = message HSplacelite.restore_color_table(&msg),
                           targetid = my_id );
                  }
               else
                  me->next_state = GET_ORIGIN;

               FIg_set_state_off(form_ptr, gadget_label);

               _put_response( resp=EX_FORM_FINISHED );
               FIf_erase( form_ptr );
               break;

            case CANCEL: /* cancel form without saving anything */

               if ( me->changing_ambient )
                  {
                  om$send( msg = message HSplacelite.restore_color_table(&msg),
                      targetid = my_id );
                  }

               me->next_state = FINISHED;
               _put_response( resp=EX_FORM_FINISHED );
               FIf_erase( form_ptr );
               break;

            case CVRT_TO_WINDOW:
               me->save_restore = FALSE;

               /*
                *  Remove the old SR form from WL and add the new window form
                */
		     
               CMsts = CMremove_form_from_wl (me->lscreen_no, 
                                              me->lwin_no, 
                                              me->context_no);

               me->context_no = WL_DEFAULT_CONTEXT;
               FIf_get_window(form_ptr,&wno);

               me->hwin_no = (WLhwin_no)(wno);

               ex$get_cur_mod (osnum = &mod_os);
               CMsts = CMadd_form_to_wl (me->hwin_no,
                                         TRUE,     /* Share */
                                         NULL_OBJID,
                                         mod_os,
                                         (int) me->save_restore,
                                         &me->lscreen_no,
                                         &me->context_no,
                                         &me->lwin_no);
            
               WLget_context_depth( me->context_no, &me->color_plane );
               if (me->changing_ambient)
                  {
                  om$send( targetid = my_id,
                           msg = message HSplacelite.display_sphere_init(&msg));
                  }

               update_sliders = TRUE;
#              if defined (X11)
               update_raster = FALSE;
#              endif
               break;

            default:
               break;

            } /* end: switch ( gadget_label ) */

          break;

      case 1 :
         /* subform */
         form_ptr = me->forms[0].form_ptr;
         FIf_erase( me->forms[1].form_ptr );
         FIg_erase( form_ptr, LIGHT_TYPE_ICON );

         /* Message is null for anything but a spot light */

         buff2[0] = '\0';
         switch( gadget_label )
            {
            case DIRECTIONAL_VIEW_ICON:
            case DIRECTIONAL_VIEW_TEXT:
               me->light.flags = (me->light.flags & HS_LIGHT_ENABLED) | 
                                 HS_LIGHT_PARALLEL;
               ex$message(  msgnumb = HS_I_DirectLightVw, buff = buff );
               FIg_set_symbol_index( form_ptr, 
                                     LIGHT_TYPE_ICON, 
                                     DIRECTIONAL_VIEW_SYM );
               break;

            case DIRECTIONAL_DB_ICON:
            case DIRECTIONAL_DB_TEXT:
               me->light.flags = (me->light.flags & HS_LIGHT_ENABLED) | 
                                 (HS_LIGHT_PARALLEL | HS_LIGHT_DATABASE);
               ex$message(  msgnumb = HS_I_DirectLightDB, buff = buff );
               FIg_set_symbol_index( form_ptr, 
                                     LIGHT_TYPE_ICON, 
                                     DIRECTIONAL_DB_SYM );
               break;

            case POINT_ICON:
            case POINT_TEXT:
               me->light.flags = (me->light.flags & HS_LIGHT_ENABLED) | 
                                 (HS_LIGHT_POINT | HS_LIGHT_DATABASE);
               ex$message(  msgnumb = HS_I_PointLight, buff = buff );
               FIg_set_symbol_index( form_ptr, LIGHT_TYPE_ICON, POINT_SYM );
               break;

#           if PUT_RENDERING_BACK
            case PEN_ICON:
            case PEN_TEXT:
               me->light.flags = (me->light.flags & HS_LIGHT_ENABLED) | 
                                 (HS_LIGHT_PENCIL | HS_LIGHT_DATABASE);
               ex$message(  msgnumb = HS_I_PenLight, buff = buff );
               FIg_set_symbol_index( form_ptr, LIGHT_TYPE_ICON, PEN_SYM );
               break;
#              endif

            case SPOT_ICON:
            case SPOT_TEXT:
               me->light.flags = (me->light.flags & HS_LIGHT_ENABLED) | 
                                 (HS_LIGHT_SPOT | HS_LIGHT_DATABASE);
               ex$message(  msgnumb = HS_I_SpotLight, buff = buff );
               FIg_set_symbol_index( form_ptr, LIGHT_TYPE_ICON, SPOT_SYM );
               ex$message( msgnumb = HS_I_EdgeIIOnly, buff = buff2 );
               break;
            }  /* end: switch */

         /* Write a message to the status field (blank or otherwise) */
         FIfld_set_text( form_ptr, STATUS1, 0, 0, buff2, FALSE );

         FIg_display( form_ptr, LIGHT_TYPE_ICON );
         FIfld_set_text( form_ptr, LIGHT_TYPE_FIELD, 0, 0, buff, FALSE );
         break;

      }  /* end: switch ( form_label ) */

   if ( update_sliders )
      {
      if (me->changing_ambient)
         {
         HSset_slider_values( form_ptr, 
                              me->max, 
                              scale_change, 
                              &me->ambient,
                              me->sph_amb, 
                              me->color_plane, 
                              me->save_restore );

         if( update_raster )
            {
            HSdisplay_sphere( me->lwin_no, 
                              me->context_no, 
                              form_ptr, 
                              me->sph_amb, 
                              me->color_plane, 
                              &me->ambient );

            HSfill_color_square( me->lwin_no, 
                                 me->context_no, 
                                 form_ptr, 
                                 me->save_restore,
                                 (unsigned short)me->ambient.red,
                                 (unsigned short)me->ambient.green,
                                 (unsigned short)me->ambient.blue );
            }
         }
      else
         {
         HSset_slider_values( form_ptr, 
                              me->max, 
                              scale_change, 
                              &me->light,
                              me->sph_amb, 
                              me->color_plane, 
                              me->save_restore );

         if( update_raster )
            HSfill_color_square( me->lwin_no, 
                                 me->context_no, 
                                 form_ptr, 
                                 me->save_restore,
                                 (unsigned short)me->light.red,
                                 (unsigned short)me->light.green,
                                 (unsigned short)me->light.blue );
         }
      }

   quit:
  return OM_S_SUCCESS;
}

method read_light_source ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong    sts1 = OM_S_SUCCESS;

    sts1 = HSget_light( &(me->light), me->curr_lite );

    if( ! sts1 )
        me->new_light = TRUE;
    else
        me->new_light = FALSE;

    me->changing_ambient = FALSE;

quit:
  return OM_S_SUCCESS;
}

method read_ambient ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    hs$get_global_lights( ambient_light = &me->ambient );
    me->changing_ambient = TRUE;
quit:
  return OM_S_SUCCESS;
}

method store_light_source ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRdouble        len;
    IGRlong          sts1 = OM_S_SUCCESS;
    IGRlong          msg;
    IGRdouble        rotation[4][4];
    struct GRid      win_id;
    struct var_list  var_list1[3];
    IGRdouble        pts[6];
    IGRlong          num_pts, which_error;
    IGRlong          ret_bytes;

    if ( me->light.flags & (HS_LIGHT_PARALLEL |
#if PUT_RENDERING_BACK
        HS_LIGHT_PENCIL |
#endif
        HS_LIGHT_SPOT) )
    {
       me->light.direction[0] = me->light.target[0] - me->light.location[0];
       me->light.direction[1] = me->light.target[1] - me->light.location[1];
       me->light.direction[2] = me->light.target[2] - me->light.location[2];

       if( me->light.flags & HS_LIGHT_DATABASE )
       {
        len = sqrt( me->light.direction[0] * me->light.direction[0] +
                        me->light.direction[1] * me->light.direction[1] +
                        me->light.direction[2] * me->light.direction[2] );

        me->light.direction[0] /= len;
        me->light.direction[1] /= len;
        me->light.direction[2] /= len;
       }
    }

    if ( (me->light.flags & HS_LIGHT_PARALLEL) &&
         (!(me->light.flags & HS_LIGHT_DATABASE)) )
    {
        win_id.objid = me->event1.event.button.objid;
        win_id.osnum = me->event1.event.button.osnum;

        /* Get the rotation matrix */

        var_list1[0].var = VW_ROT_NO_CON;
        var_list1[0].var_ptr = (IGRchar *) rotation;
        var_list1[0].num_bytes = 16 * sizeof(IGRdouble);
        var_list1[0].bytes_returned = &ret_bytes;

        var_list1[1].var = END_PARAM;

        dp$inq_set_gragad( msg = &msg, inq0_set1 = 0, osnum = win_id.osnum, gragad_objid = win_id.objid,
            which_error = &which_error, var_list = var_list1);

#if DEBUG_TWO_D
        fprintf( stderr, "Before matrix transformation (world coordinates)\n" );
        fprintf( stderr, "light vector = %lf, %lf, %lf\n", light->direction[0],
            light->direction[1], light->direction[2] );
#endif
        /*
         * Convert the vector from World Coordinate System to View aligned.
         */

        num_pts = 2;
        pts[0] = me->light.location[0];
        pts[1] = me->light.location[1];
        pts[2] = me->light.location[2];
        pts[3] = me->light.target[0];
        pts[4] = me->light.target[1];
        pts[5] = me->light.target[2];

        me->light.direction[0] = pts[3] - pts[0];
        me->light.direction[1] = pts[4] - pts[1];
        me->light.direction[2] = pts[5] - pts[2];

        num_pts = 1;
        MAptsxform( &msg,&num_pts,rotation,me->light.direction,me->light.direction );
/*
printf("plclight: direction in VIEW \n\t%f %f %f\n",
    me->light.direction[0],me->light.direction[1],me->light.direction[2]);
*/
        /* flip Y and Z of view aligned directional lights to */
        /* get into tiler coordinate system                   */
        me->light.direction[1] *= -1.0;
        me->light.direction[2] *= -1.0;

        len = sqrt( me->light.direction[0] * me->light.direction[0] +
            me->light.direction[1] * me->light.direction[1] +
            me->light.direction[2] * me->light.direction[2] );
        me->light.direction[0] /= len;
        me->light.direction[1] /= len;
        me->light.direction[2] /= len;

        if( WITHIN_TOLERANCE(me->light.direction[2], 0.0, 0.000001) ) me->light.direction[2] = 0.0;

#if FALSE
        /* Negate vector if it points toward the eye */
        if( me->light.direction[2] < 0.0 )
        {
            ex$message( msgnumb = HS_I_NegateVector );
            sleep(3);

            me->light.direction[0] = -me->light.direction[0];
            me->light.direction[1] = -me->light.direction[1];
            me->light.direction[2] = -me->light.direction[2];
        }
#endif
            sts1 = HSput_light( &(me->light), me->curr_lite, &win_id );
    }
    else
        sts1 = HSput_light( &(me->light), me->curr_lite, (struct GRid *) NULL );

#if DEBUG
    if( !sts1 )
    fprintf( stderr, "HSput_light() returned zero\tERROR writing to light %d\n", me->curr_lite+1 );
#endif
    ex$message( msgnumb = HS_I_LightChanged, type = "%1d",
                var = `me->curr_lite+1` );

quit:
  return OM_S_SUCCESS;
}

method store_ambient ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    hs$set_global_lights( ambient_light = &me->ambient );
    IGEset_ambient_light( me->ambient.red, me->ambient.green, me->ambient.blue);
    if (IGEget_using_ramp_mode())
    {
       ige$configure_color_table( );
    }
    ex$message( msgnumb = HS_I_AmbientChanged );
    quit:
  return OM_S_SUCCESS;
}

method read_sphere ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    Form form_ptr;
       IGRint VERT;
    char msgbuf[40], filname[300];
    struct HEADER_BLOCK hdr;
    FILE *fp;
      char modelpath[256];
#ifdef BIG_ENDIAN
      int fd;
#endif
    if( me->sph_amb == NULL )
    {
         get_modtype_data("Model", NULL, NULL, NULL, NULL, modelpath);
           sprintf(filname, "%s/%s", modelpath, "config/spheres/sphamb.rgb");

           fp = (FILE*) fopen(filname, "r");
           hdr.app_type_code = -1;
           hdr.data_type_code = -1;

       form_ptr = me->forms[0].form_ptr;

       if( fp!=NULL )
           {
#ifdef BIG_ENDIAN
               fclose(fp);

               if ((fd = open(filname, O_RDONLY, 0)) != -1);
                   {
                       HSread_rasterfile_header(&fd,
                                                (short *)&hdr.data_type_code,
                                                (short *)&hdr.app_type_code,
                                                (long *)&hdr.num_cols,
                                                (long *)&hdr.num_rows,
                                                NULL,
                                                NULL );
                       close(fd);
                   }
#else
                fread(&hdr,sizeof(struct HEADER_BLOCK),1,fp);
                fclose(fp);
#endif

        if(hdr.app_type_code==9)
            VERT = 0;
        else
            VERT = 1;

        if (hdr.data_type_code == TYPE_27)
        {
            fp = (FILE*) fopen(filname, "r");
            fseek(fp, 1024, 0);

                    HSsphmem_man(&me->sph_amb, SPH_AMB, MEM_GET);

                     HSread_type27(fp, hdr.num_rows, hdr.num_cols, SPH_XMIN, 
                SPH_YMIN, SPH_XMAX, SPH_YMAX, VERT, me->sph_amb);

                    fclose(fp);
           }
           else
           {
               ex$message( msgnumb = HS_E_NotType27, buff = msgbuf );
                       FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
           }
       }
           else
           {
           ex$message( msgnumb = HS_E_FindSphAmb, buff = msgbuf );
               FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
           }
    }

quit:
  return OM_S_SUCCESS;
}

method display_sphere_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    Form       form_ptr;
    int        depth;

    form_ptr = me->forms[0].form_ptr;
    
    WLget_context_depth( me->context_no, &depth );
    me->color_plane = depth;

    quit:
  return OM_S_SUCCESS;
}

method draw_on_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    Form                   form_ptr;
    long                   msg;
    struct HS_light_source *light;

    int                    wno;
    OMuword                mod_os;

    form_ptr = me->forms[0].form_ptr;
    if (me->changing_ambient)
        {
        light = &me->ambient;
        }
    else
        { 
        light = &me->light;
        }

    /*
     *  Get the hardware window number of the form, and add it to WL, if
     *  not already active.  If the active window is not the same, then
     *  dispose of it first
     */
   
    FIf_get_window(form_ptr, &wno);
    if ( (WLhwin_no)wno != me->hwin_no )
    {
        if( me->context_no != WL_DEFAULT_CONTEXT )
        {
            CMremove_form_from_wl( me->lscreen_no, me->lwin_no, me->context_no );
            me->context_no = WL_DEFAULT_CONTEXT;
        }

        me->hwin_no = (WLhwin_no)wno;
        ex$get_cur_mod( osnum = &mod_os );
        CMadd_form_to_wl( me->hwin_no,
                          TRUE, /* Share */
                          NULL_OBJID,
                          mod_os,
                          me->save_restore,
                          &me->lscreen_no,
                          &me->context_no,
                          &me->lwin_no );
            
        WLget_context_depth( me->context_no, &me->color_plane );
    }

    if (me->changing_ambient)
       {
       om$send( targetid = my_id,
            msg = message HSplacelite.display_sphere_init( &msg ));

       /* update light color rectangle */

       HSfill_color_square( me->lwin_no, me->context_no, form_ptr, me->save_restore,
                (unsigned short)light->red,
                (unsigned short)light->green,
                (unsigned short)light->blue );

       if ( (light->flags & HS_LIGHT_TYPE) == HS_LIGHT_AMBIENT )
           {
           /* update ambient sphere display */
           if (me->sph_amb != NULL)
               HSdisplay_sphere( me->lwin_no, 
                                 me->context_no, 
                                 form_ptr, 
                                 me->sph_amb, 
                                 me->color_plane, 
                                 light);
           }
        }
    else
        {
        HSdisplay_light( me->lwin_no, 
                         me->context_no, 
                         form_ptr, 
                         me->curr_lite, 
                         me->max,
                         light, 
                         me->sph_amb, 
                         me->color_plane, 
                         me->save_restore );
        }
    quit:
  return OM_S_SUCCESS;
}

end implementation HSplacelite;
