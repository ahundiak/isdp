/* define standard property names */
#define Pfoundry		"FOUNDRY"
#define Pfamily			"FAMILY"
#define Pweight_name		"WEIGHT_NAME"
#define Pslant			"SLANT"
#define Psetwidth_name		"SETWITH_NAME"
#define Padd_style_name		"ADD_STYLE_NAME"
#define Ppixel_size		"PIXEL_SIZE"
#define Ppoint_size		"POINT_SIZE"
#define Presolution_x		"RESOLUTION_X"
#define Presolution_y		"RESOLUTION_Y"
#define Pspacing		"SPACING"
#define Paverage_width		"AVERAGE_WIDTH"
#define Pcharset_registry	"CHARSET_REGISTRY"
#define Pcharset_encoding	"CHARSET_ENCODING"



/* property value can be either a string or an integer */
union propdata {
    char    *s;
    int     n;
};

#define IntProperty	1
#define StrProperty	2

typedef struct _Property {
    char           *name;
    union propdata value;
    int            type;

} Property;


typedef struct _BDF_FontInfo
{
   char     name[256];
   char     alias[16];
   int      point_size;
   int      bbox_width;
   int      bbox_height;
   int      x_origin_offset;
   int      y_origin_offset;
   int      ascent;
   int      descent;
   int      num_chars;
   int      text_font;
   Property *proplist;
   int      nproperties;

} BDF_FontInfo;


typedef struct _BDF_CharInfo
{
   int           name;
   int           bbox_width;
   int           bbox_height;
   int           x_origin_offset;
   int           y_origin_offset;
   int           scalable_width;
   int           device_width;
   unsigned char *bitmap;

} BDF_CharInfo;

