#include "wl.h"
#ifdef X11

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#else

#include <tools.h>

#endif

#include "igrdef.h"
#include "igrtypedef.h"
#include "igecolor.h"
#include "msdef.h"
#include "madef.h"
#include "mapriv.h"

static IGRushort per_red_cal[256];
static IGRushort per_green_cal[256];
static IGRushort per_blue_cal[256];

static IGRushort lin_lum_red_cal[256];
static IGRushort lin_lum_green_cal[256];
static IGRushort lin_lum_blue_cal[256];

static IGRint RScalc_per_calibration();

/*
 * map to take linear data to preceptual data 
 */


static IGRushort lin_per_red_map[256] = { 0x0000,0x0100,0x0200,0x0300,
    0x0400,0x0500,0x0600,0x0700,0x0800,0x0900,0x0a00,0x0b00,0x0c00,0x0d00,0x0e00,0x0f00,
    0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700,0x1800,0x1900,0x1a00,0x1b00,
    0x1c00,0x1d00,0x1e00,0x1f00,0x2000,0x2100,0x2200,0x2300,0x2400,0x2500,0x2600,0x2700,
    0x2800,0x2900,0x2a00,0x2b00,0x2c00,0x2d00,0x2e00,0x2f00,0x3000,0x3100,0x3200,0x3300,
    0x3400,0x3500,0x3600,0x3700,0x3800,0x3900,0x3a00,0x3b00,0x3c00,0x3d00,0x3e00,0x3f00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4a00,0x4b00,
    0x4c00,0x4d00,0x4e00,0x4f00,0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x5700,
    0x5800,0x5900,0x5a00,0x5b00,0x5c00,0x5d00,0x5e00,0x5f00,0x6000,0x6100,0x6200,0x6300,
    0x6400,0x6500,0x6600,0x6700,0x6800,0x6900,0x6a00,0x6b00,0x6c00,0x6d00,0x6e00,0x6f00,
    0x7000,0x7100,0x7200,0x7300,0x7400,0x7500,0x7600,0x7700,0x7800,0x7900,0x7a00,0x7b00,
    0x7c00,0x7d00,0x7e00,0x7f00,0x8000,0x8100,0x8200,0x8300,0x8400,0x8500,0x8600,0x8700,
    0x8800,0x8900,0x8a00,0x8b00,0x8c00,0x8d00,0x8e00,0x8f00,0x9000,0x9100,0x9200,0x9300,
    0x9400,0x9500,0x9600,0x9700,0x9800,0x9900,0x9a00,0x9b00,0x9c00,0x9d00,0x9e00,0x9f00,
    0xa000,0xa100,0xa200,0xa300,0xa400,0xa500,0xa600,0xa700,0xa800,0xa900,0xaa00,0xab00,
    0xac00,0xad00,0xae00,0xaf00,0xb000,0xb100,0xb200,0xb300,0xb400,0xb500,0xb600,0xb700,
    0xb800,0xb900,0xba00,0xbb00,0xbc00,0xbd00,0xbe00,0xbf00,0xc000,0xc100,0xc200,0xc300,
    0xc400,0xc500,0xc600,0xc700,0xc800,0xc900,0xca00,0xcb00,0xcc00,0xcd00,0xce00,0xcf00,
    0xd000,0xd100,0xd200,0xd300,0xd400,0xd500,0xd600,0xd700,0xd800,0xd900,0xda00,0xdb00,
    0xdc00,0xdd00,0xde00,0xdf00,0xe000,0xe100,0xe200,0xe300,0xe400,0xe500,0xe600,0xe700,
    0xe800,0xe900,0xea00,0xeb00,0xec00,0xed00,0xee00,0xef00,0xf000,0xf100,0xf200,0xf300,
    0xf400,0xf500,0xf600,0xf700,0xf800,0xf900,0xfa00,0xfb00,0xfc00,0xfd00,0xfe00,0xff00};

static IGRushort lin_per_green_map[256]  = { 0x0000,0x0100,0x0200,0x0300,
    0x0400,0x0500,0x0600,0x0700,0x0800,0x0900,0x0a00,0x0b00,0x0c00,0x0d00,0x0e00,0x0f00,
    0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700,0x1800,0x1900,0x1a00,0x1b00,
    0x1c00,0x1d00,0x1e00,0x1f00,0x2000,0x2100,0x2200,0x2300,0x2400,0x2500,0x2600,0x2700,
    0x2800,0x2900,0x2a00,0x2b00,0x2c00,0x2d00,0x2e00,0x2f00,0x3000,0x3100,0x3200,0x3300,
    0x3400,0x3500,0x3600,0x3700,0x3800,0x3900,0x3a00,0x3b00,0x3c00,0x3d00,0x3e00,0x3f00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4a00,0x4b00,
    0x4c00,0x4d00,0x4e00,0x4f00,0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x5700,
    0x5800,0x5900,0x5a00,0x5b00,0x5c00,0x5d00,0x5e00,0x5f00,0x6000,0x6100,0x6200,0x6300,
    0x6400,0x6500,0x6600,0x6700,0x6800,0x6900,0x6a00,0x6b00,0x6c00,0x6d00,0x6e00,0x6f00,
    0x7000,0x7100,0x7200,0x7300,0x7400,0x7500,0x7600,0x7700,0x7800,0x7900,0x7a00,0x7b00,
    0x7c00,0x7d00,0x7e00,0x7f00,0x8000,0x8100,0x8200,0x8300,0x8400,0x8500,0x8600,0x8700,
    0x8800,0x8900,0x8a00,0x8b00,0x8c00,0x8d00,0x8e00,0x8f00,0x9000,0x9100,0x9200,0x9300,
    0x9400,0x9500,0x9600,0x9700,0x9800,0x9900,0x9a00,0x9b00,0x9c00,0x9d00,0x9e00,0x9f00,
    0xa000,0xa100,0xa200,0xa300,0xa400,0xa500,0xa600,0xa700,0xa800,0xa900,0xaa00,0xab00,
    0xac00,0xad00,0xae00,0xaf00,0xb000,0xb100,0xb200,0xb300,0xb400,0xb500,0xb600,0xb700,
    0xb800,0xb900,0xba00,0xbb00,0xbc00,0xbd00,0xbe00,0xbf00,0xc000,0xc100,0xc200,0xc300,
    0xc400,0xc500,0xc600,0xc700,0xc800,0xc900,0xca00,0xcb00,0xcc00,0xcd00,0xce00,0xcf00,
    0xd000,0xd100,0xd200,0xd300,0xd400,0xd500,0xd600,0xd700,0xd800,0xd900,0xda00,0xdb00,
    0xdc00,0xdd00,0xde00,0xdf00,0xe000,0xe100,0xe200,0xe300,0xe400,0xe500,0xe600,0xe700,
    0xe800,0xe900,0xea00,0xeb00,0xec00,0xed00,0xee00,0xef00,0xf000,0xf100,0xf200,0xf300,
    0xf400,0xf500,0xf600,0xf700,0xf800,0xf900,0xfa00,0xfb00,0xfc00,0xfd00,0xfe00,0xff00};

static IGRushort lin_per_blue_map[256]  = { 0x0000,0x0100,0x0200,0x0300,
    0x0400,0x0500,0x0600,0x0700,0x0800,0x0900,0x0a00,0x0b00,0x0c00,0x0d00,0x0e00,0x0f00,
    0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700,0x1800,0x1900,0x1a00,0x1b00,
    0x1c00,0x1d00,0x1e00,0x1f00,0x2000,0x2100,0x2200,0x2300,0x2400,0x2500,0x2600,0x2700,
    0x2800,0x2900,0x2a00,0x2b00,0x2c00,0x2d00,0x2e00,0x2f00,0x3000,0x3100,0x3200,0x3300,
    0x3400,0x3500,0x3600,0x3700,0x3800,0x3900,0x3a00,0x3b00,0x3c00,0x3d00,0x3e00,0x3f00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4a00,0x4b00,
    0x4c00,0x4d00,0x4e00,0x4f00,0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x5700,
    0x5800,0x5900,0x5a00,0x5b00,0x5c00,0x5d00,0x5e00,0x5f00,0x6000,0x6100,0x6200,0x6300,
    0x6400,0x6500,0x6600,0x6700,0x6800,0x6900,0x6a00,0x6b00,0x6c00,0x6d00,0x6e00,0x6f00,
    0x7000,0x7100,0x7200,0x7300,0x7400,0x7500,0x7600,0x7700,0x7800,0x7900,0x7a00,0x7b00,
    0x7c00,0x7d00,0x7e00,0x7f00,0x8000,0x8100,0x8200,0x8300,0x8400,0x8500,0x8600,0x8700,
    0x8800,0x8900,0x8a00,0x8b00,0x8c00,0x8d00,0x8e00,0x8f00,0x9000,0x9100,0x9200,0x9300,
    0x9400,0x9500,0x9600,0x9700,0x9800,0x9900,0x9a00,0x9b00,0x9c00,0x9d00,0x9e00,0x9f00,
    0xa000,0xa100,0xa200,0xa300,0xa400,0xa500,0xa600,0xa700,0xa800,0xa900,0xaa00,0xab00,
    0xac00,0xad00,0xae00,0xaf00,0xb000,0xb100,0xb200,0xb300,0xb400,0xb500,0xb600,0xb700,
    0xb800,0xb900,0xba00,0xbb00,0xbc00,0xbd00,0xbe00,0xbf00,0xc000,0xc100,0xc200,0xc300,
    0xc400,0xc500,0xc600,0xc700,0xc800,0xc900,0xca00,0xcb00,0xcc00,0xcd00,0xce00,0xcf00,
    0xd000,0xd100,0xd200,0xd300,0xd400,0xd500,0xd600,0xd700,0xd800,0xd900,0xda00,0xdb00,
    0xdc00,0xdd00,0xde00,0xdf00,0xe000,0xe100,0xe200,0xe300,0xe400,0xe500,0xe600,0xe700,
    0xe800,0xe900,0xea00,0xeb00,0xec00,0xed00,0xee00,0xef00,0xf000,0xf100,0xf200,0xf300,
    0xf400,0xf500,0xf600,0xf700,0xf800,0xf900,0xfa00,0xfb00,0xfc00,0xfd00,0xfe00,0xff00};

/*
 * map to take perceptual data to linear data 
 */

static IGRushort per_lin_red_map[256] = { 0x0000,0x0100,0x0200,0x0300,
    0x0400,0x0500,0x0600,0x0700,0x0800,0x0900,0x0a00,0x0b00,0x0c00,0x0d00,0x0e00,0x0f00,
    0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700,0x1800,0x1900,0x1a00,0x1b00,
    0x1c00,0x1d00,0x1e00,0x1f00,0x2000,0x2100,0x2200,0x2300,0x2400,0x2500,0x2600,0x2700,
    0x2800,0x2900,0x2a00,0x2b00,0x2c00,0x2d00,0x2e00,0x2f00,0x3000,0x3100,0x3200,0x3300,
    0x3400,0x3500,0x3600,0x3700,0x3800,0x3900,0x3a00,0x3b00,0x3c00,0x3d00,0x3e00,0x3f00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4a00,0x4b00,
    0x4c00,0x4d00,0x4e00,0x4f00,0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x5700,
    0x5800,0x5900,0x5a00,0x5b00,0x5c00,0x5d00,0x5e00,0x5f00,0x6000,0x6100,0x6200,0x6300,
    0x6400,0x6500,0x6600,0x6700,0x6800,0x6900,0x6a00,0x6b00,0x6c00,0x6d00,0x6e00,0x6f00,
    0x7000,0x7100,0x7200,0x7300,0x7400,0x7500,0x7600,0x7700,0x7800,0x7900,0x7a00,0x7b00,
    0x7c00,0x7d00,0x7e00,0x7f00,0x8000,0x8100,0x8200,0x8300,0x8400,0x8500,0x8600,0x8700,
    0x8800,0x8900,0x8a00,0x8b00,0x8c00,0x8d00,0x8e00,0x8f00,0x9000,0x9100,0x9200,0x9300,
    0x9400,0x9500,0x9600,0x9700,0x9800,0x9900,0x9a00,0x9b00,0x9c00,0x9d00,0x9e00,0x9f00,
    0xa000,0xa100,0xa200,0xa300,0xa400,0xa500,0xa600,0xa700,0xa800,0xa900,0xaa00,0xab00,
    0xac00,0xad00,0xae00,0xaf00,0xb000,0xb100,0xb200,0xb300,0xb400,0xb500,0xb600,0xb700,
    0xb800,0xb900,0xba00,0xbb00,0xbc00,0xbd00,0xbe00,0xbf00,0xc000,0xc100,0xc200,0xc300,
    0xc400,0xc500,0xc600,0xc700,0xc800,0xc900,0xca00,0xcb00,0xcc00,0xcd00,0xce00,0xcf00,
    0xd000,0xd100,0xd200,0xd300,0xd400,0xd500,0xd600,0xd700,0xd800,0xd900,0xda00,0xdb00,
    0xdc00,0xdd00,0xde00,0xdf00,0xe000,0xe100,0xe200,0xe300,0xe400,0xe500,0xe600,0xe700,
    0xe800,0xe900,0xea00,0xeb00,0xec00,0xed00,0xee00,0xef00,0xf000,0xf100,0xf200,0xf300,
    0xf400,0xf500,0xf600,0xf700,0xf800,0xf900,0xfa00,0xfb00,0xfc00,0xfd00,0xfe00,0xff00};

static IGRushort per_lin_green_map[256] = { 0x0000,0x0100,0x0200,0x0300,
    0x0400,0x0500,0x0600,0x0700,0x0800,0x0900,0x0a00,0x0b00,0x0c00,0x0d00,0x0e00,0x0f00,
    0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700,0x1800,0x1900,0x1a00,0x1b00,
    0x1c00,0x1d00,0x1e00,0x1f00,0x2000,0x2100,0x2200,0x2300,0x2400,0x2500,0x2600,0x2700,
    0x2800,0x2900,0x2a00,0x2b00,0x2c00,0x2d00,0x2e00,0x2f00,0x3000,0x3100,0x3200,0x3300,
    0x3400,0x3500,0x3600,0x3700,0x3800,0x3900,0x3a00,0x3b00,0x3c00,0x3d00,0x3e00,0x3f00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4a00,0x4b00,
    0x4c00,0x4d00,0x4e00,0x4f00,0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x5700,
    0x5800,0x5900,0x5a00,0x5b00,0x5c00,0x5d00,0x5e00,0x5f00,0x6000,0x6100,0x6200,0x6300,
    0x6400,0x6500,0x6600,0x6700,0x6800,0x6900,0x6a00,0x6b00,0x6c00,0x6d00,0x6e00,0x6f00,
    0x7000,0x7100,0x7200,0x7300,0x7400,0x7500,0x7600,0x7700,0x7800,0x7900,0x7a00,0x7b00,
    0x7c00,0x7d00,0x7e00,0x7f00,0x8000,0x8100,0x8200,0x8300,0x8400,0x8500,0x8600,0x8700,
    0x8800,0x8900,0x8a00,0x8b00,0x8c00,0x8d00,0x8e00,0x8f00,0x9000,0x9100,0x9200,0x9300,
    0x9400,0x9500,0x9600,0x9700,0x9800,0x9900,0x9a00,0x9b00,0x9c00,0x9d00,0x9e00,0x9f00,
    0xa000,0xa100,0xa200,0xa300,0xa400,0xa500,0xa600,0xa700,0xa800,0xa900,0xaa00,0xab00,
    0xac00,0xad00,0xae00,0xaf00,0xb000,0xb100,0xb200,0xb300,0xb400,0xb500,0xb600,0xb700,
    0xb800,0xb900,0xba00,0xbb00,0xbc00,0xbd00,0xbe00,0xbf00,0xc000,0xc100,0xc200,0xc300,
    0xc400,0xc500,0xc600,0xc700,0xc800,0xc900,0xca00,0xcb00,0xcc00,0xcd00,0xce00,0xcf00,
    0xd000,0xd100,0xd200,0xd300,0xd400,0xd500,0xd600,0xd700,0xd800,0xd900,0xda00,0xdb00,
    0xdc00,0xdd00,0xde00,0xdf00,0xe000,0xe100,0xe200,0xe300,0xe400,0xe500,0xe600,0xe700,
    0xe800,0xe900,0xea00,0xeb00,0xec00,0xed00,0xee00,0xef00,0xf000,0xf100,0xf200,0xf300,
    0xf400,0xf500,0xf600,0xf700,0xf800,0xf900,0xfa00,0xfb00,0xfc00,0xfd00,0xfe00,0xff00};

static IGRushort per_lin_blue_map[256] = { 0x0000,0x0100,0x0200,0x0300,
    0x0400,0x0500,0x0600,0x0700,0x0800,0x0900,0x0a00,0x0b00,0x0c00,0x0d00,0x0e00,0x0f00,
    0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700,0x1800,0x1900,0x1a00,0x1b00,
    0x1c00,0x1d00,0x1e00,0x1f00,0x2000,0x2100,0x2200,0x2300,0x2400,0x2500,0x2600,0x2700,
    0x2800,0x2900,0x2a00,0x2b00,0x2c00,0x2d00,0x2e00,0x2f00,0x3000,0x3100,0x3200,0x3300,
    0x3400,0x3500,0x3600,0x3700,0x3800,0x3900,0x3a00,0x3b00,0x3c00,0x3d00,0x3e00,0x3f00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4a00,0x4b00,
    0x4c00,0x4d00,0x4e00,0x4f00,0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x5700,
    0x5800,0x5900,0x5a00,0x5b00,0x5c00,0x5d00,0x5e00,0x5f00,0x6000,0x6100,0x6200,0x6300,
    0x6400,0x6500,0x6600,0x6700,0x6800,0x6900,0x6a00,0x6b00,0x6c00,0x6d00,0x6e00,0x6f00,
    0x7000,0x7100,0x7200,0x7300,0x7400,0x7500,0x7600,0x7700,0x7800,0x7900,0x7a00,0x7b00,
    0x7c00,0x7d00,0x7e00,0x7f00,0x8000,0x8100,0x8200,0x8300,0x8400,0x8500,0x8600,0x8700,
    0x8800,0x8900,0x8a00,0x8b00,0x8c00,0x8d00,0x8e00,0x8f00,0x9000,0x9100,0x9200,0x9300,
    0x9400,0x9500,0x9600,0x9700,0x9800,0x9900,0x9a00,0x9b00,0x9c00,0x9d00,0x9e00,0x9f00,
    0xa000,0xa100,0xa200,0xa300,0xa400,0xa500,0xa600,0xa700,0xa800,0xa900,0xaa00,0xab00,
    0xac00,0xad00,0xae00,0xaf00,0xb000,0xb100,0xb200,0xb300,0xb400,0xb500,0xb600,0xb700,
    0xb800,0xb900,0xba00,0xbb00,0xbc00,0xbd00,0xbe00,0xbf00,0xc000,0xc100,0xc200,0xc300,
    0xc400,0xc500,0xc600,0xc700,0xc800,0xc900,0xca00,0xcb00,0xcc00,0xcd00,0xce00,0xcf00,
    0xd000,0xd100,0xd200,0xd300,0xd400,0xd500,0xd600,0xd700,0xd800,0xd900,0xda00,0xdb00,
    0xdc00,0xdd00,0xde00,0xdf00,0xe000,0xe100,0xe200,0xe300,0xe400,0xe500,0xe600,0xe700,
    0xe800,0xe900,0xea00,0xeb00,0xec00,0xed00,0xee00,0xef00,0xf000,0xf100,0xf200,0xf300,
    0xf400,0xf500,0xf600,0xf700,0xf800,0xf900,0xfa00,0xfb00,0xfc00,0xfd00,0xfe00,0xff00};

static IGRint		 per_lum = 0;  
				/* 0 = linear luminance calibration,  
				   1 = preceptually uniform calibration */

static IGRdouble rw = 1.0, gw = 1.0, bw = 1.0;

static IGRboolean initialized = FALSE;

int RSloadvlt( 
int vsno,
#ifdef X11
XColor          *vlt,
#else
struct vlt_slot *vlt,
#endif
int nslots
)
{
	IGRlong i;
	IGRlong value;
	IGRint  per_tc_vlt_no;
	IGRint  lin_lum_tc_vlt_no;
#ifdef X11        
        XColor                  per_tcvlt[256];
        XColor                  lin_lum_tcvlt[256];
        Colormap                col_map;
        Display                 *xdisplay;
#else
	struct  vlt_slot	per_tcvlt[256];
	struct  vlt_slot	lin_lum_tcvlt[256];

	extern int Loadvlt();
#endif

#ifdef X11
        RSgetxinfo(&xdisplay,NULL,NULL,NULL,NULL,&col_map);
#endif

	if (initialized)
	{
	  for (i = 0; i < nslots; i++)
	  {
#ifdef X11
	    value = per_red_cal[vlt[i].red >> 8];
	    vlt[i].red = value;	  
	    value = per_green_cal[vlt[i].green >> 8];
	    vlt[i].green = value;	  
	    value = per_blue_cal[vlt[i].blue >> 8];
	    vlt[i].blue = value;	  
#else
	    value = per_red_cal[vlt[i].v_red >> 8];
	    vlt[i].v_red = value;	  
	    value = per_green_cal[vlt[i].v_green >> 8];
	    vlt[i].v_green = value;	  
	    value = per_blue_cal[vlt[i].v_blue >> 8];
	    vlt[i].v_blue = value;	  
#endif
	  }

#ifndef X11
	  if (RSis_true_color() && (nslots > 1))
	  {
  /* on true color workstation load different vlt for rgb and cmyk  */

		for (i = 0; i < 256; i++)
		{
		    per_tcvlt[i].v_red = per_red_cal[i];
		    per_tcvlt[i].v_green = per_green_cal[i];
		    per_tcvlt[i].v_blue = per_blue_cal[i];
		    per_tcvlt[i].v_slot = i;
		}

		for (i = 0; i < 256; i++)
		{
		    lin_lum_tcvlt[i].v_red = lin_lum_red_cal[i];
		    lin_lum_tcvlt[i].v_green = lin_lum_green_cal[i];
		    lin_lum_tcvlt[i].v_blue = lin_lum_blue_cal[i];
		    lin_lum_tcvlt[i].v_slot = i;
		}
	  
	  }
#endif
	}

#ifdef X11
        XStoreColors(xdisplay,col_map,vlt,nslots);
#else
	Loadvlt(vsno,vlt,nslots);
#endif

#ifndef X11
	if (RSis_true_color() && initialized && (nslots > 1))
	{
	    RSget_tc_vlt(&per_tc_vlt_no,&lin_lum_tc_vlt_no);
	    Load_allocated_vlt(vsno,per_tc_vlt_no,per_tcvlt,256);
	    Load_allocated_vlt(vsno,lin_lum_tc_vlt_no,lin_lum_tcvlt,256);
	}
#endif
	return(0);


}



IGRboolean RScalccalib(
IGRlong   *message,
IGRdouble *red_exponent,
IGRdouble *green_exponent,
IGRdouble *blue_exponent)
{

	IGRdouble base,value,tbase;
	IGRulong lvalue;
	IGRlong	  i;
	IGRlong	  msg;
	IGRdouble per_red_exponent;
	IGRdouble per_green_exponent;
	IGRdouble per_blue_exponent;
	IGRdouble lin_per_red_exponent;
	IGRdouble lin_per_green_exponent;
	IGRdouble lin_per_blue_exponent;
	IGRdouble per_lin_red_exponent;
	IGRdouble per_lin_green_exponent;
	IGRdouble per_lin_blue_exponent;

	extern IGRdouble MApower();

	*message = MSSUCC;


	if ((*red_exponent > 0) && (*green_exponent > 0) &&
	    (*blue_exponent > 0))
	{
	  for (i = 0; i <= 255; i++)
	  {
	    base = i / 255.0;

	    tbase = base * rw;
	    value = MApower(&msg,&tbase,red_exponent) * 65535;
	    lvalue = MAnint(value);
	    lin_lum_red_cal[i] = lvalue;

	    tbase = base * gw;
	    value = MApower(&msg,&tbase,green_exponent) * 65535;
	    lvalue = MAnint(value);
	    lin_lum_green_cal[i] = lvalue;

	    tbase = base * bw;
	    value = MApower(&msg,&tbase,blue_exponent) * 65535;
	    lvalue = MAnint(value);
	    lin_lum_blue_cal[i] = lvalue;

	  }

	  if (per_lum)
	  {
  /*
   * since rgb data is stored in a X^3 power curve, calculate rgb calibration
   * when cmyk data is convert to to rgb values, the rgb values are converted
   * to linear luminance rgb values. In order to display using rgb power curve,
   * an inverse map is created which will map the rgb values so that after 
   * going through the rgb calibration, the data will display properly
   */


	      per_red_exponent = 3 * *red_exponent;
	      per_green_exponent = 3 * *green_exponent;
	      per_blue_exponent = 3 * *blue_exponent;
	
	      lin_per_red_exponent= 1/3.0;
	      lin_per_green_exponent= 1/3.0;
	      lin_per_blue_exponent= 1/3.0;

	      per_lin_red_exponent= 3.0;
	      per_lin_green_exponent= 3.0;
	      per_lin_blue_exponent= 3.0;

              for (i = 0; i <= 255; i++)
              {
                base = i / 255.0;

		tbase = base * rw;
                value = MApower(&msg,&tbase,&per_red_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_red_cal[i] = lvalue;
		
		tbase = base;
		value = MApower(&msg,&tbase,&lin_per_red_exponent) * 
                        65535;
                lvalue = MAnint(value);
                lin_per_red_map[i] = lvalue;

		tbase = base;
		value = MApower(&msg,&tbase,&per_lin_red_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_lin_red_map[i] = lvalue;
		
		tbase = base * gw;
                value = MApower(&msg,&tbase,&per_green_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_green_cal[i] = lvalue;

		tbase = base;
		value = MApower(&msg,&tbase,&lin_per_green_exponent) * 
			65535;
                lvalue = MAnint(value);
                lin_per_green_map[i] = lvalue;

		tbase = base;
		value = MApower(&msg,&tbase,&per_lin_green_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_lin_green_map[i] = lvalue;

		tbase = base * bw;
                value = MApower(&msg,&tbase,&per_blue_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_blue_cal[i] = lvalue;

		tbase = base;
		value = MApower(&msg,&tbase,&lin_per_blue_exponent) * 
			65535;
                lvalue = MAnint(value);
                lin_per_blue_map[i] = lvalue;

		tbase = base;
		value = MApower(&msg,&tbase,&per_lin_blue_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_lin_blue_map[i] = lvalue;
              }

	  }
	  else
	  {

              for (i = 0; i <= 255; i++)
              {
                per_red_cal[i] = lin_lum_red_cal[i];
                per_green_cal[i] = lin_lum_green_cal[i];
                per_blue_cal[i] = lin_lum_blue_cal[i];
              }
	
              for (i = 0; i <= 255; i++)
              {
                lin_per_red_map[i] = i * 257;
                lin_per_green_map[i] = i * 257;
                lin_per_blue_map[i] = i * 257;
                per_lin_red_map[i] = i * 257;
                per_lin_green_map[i] = i * 257;
                per_lin_blue_map[i] = i * 257;
              }
	   }

	  initialized = TRUE;
	}
	else
	{
	  *message = MSFAIL;
	}

	return(1 & *message);
}

IGRboolean RSloadcalib(
IGRlong   *message,
IGRushort  *red_table,
IGRushort  *green_table,
IGRushort  *blue_table)

{

	IGRlong	  i;

	*message = MSSUCC;

	for (i = 0; i <= 255; i++)
	{
	  lin_lum_red_cal[i] = red_table[i];
	  lin_lum_green_cal[i] = green_table[i];
	  lin_lum_blue_cal[i] = blue_table[i];
	}


        RScalc_per_calibration();

	initialized = TRUE;

	return(TRUE);

}



IGRboolean RSretcalib(
IGRlong   *message,
IGRushort *red_table,
IGRushort *green_table,
IGRushort *blue_table)

{

	IGRlong	  i;

	*message = MSSUCC;

	if (initialized)
	{
	  for (i = 0; i <= 255; i++)
	  {
	    red_table[i] = per_red_cal[i];
	    green_table[i] = per_green_cal[i];
	    blue_table[i] = per_blue_cal[i];
	  }
	}
	else
	{
	  *message = MSFAIL;
	}

	return(1 & *message);

}


IGRboolean RSretlinearcalib(
IGRulong   *message,
IGRushort  *red_table,
IGRushort  *green_table,
IGRushort  *blue_table)
{

	IGRlong	  i;

	*message = MSSUCC;

	if (initialized)
	{
	  for (i = 0; i <= 255; i++)
	  {
	    red_table[i] = lin_lum_red_cal[i];
	    green_table[i] = lin_lum_green_cal[i];
	    blue_table[i] = lin_lum_blue_cal[i];
	  }
	}
	else
	{
	  *message = MSFAIL;
	}

	return(1 & *message);

}

IGRboolean RSretlinpercalibptrs(
IGRlong   *message,
IGRushort  **red_table,
IGRushort  **green_table,
IGRushort  **blue_table)

{
	*message = MSSUCC;

	*red_table = lin_per_red_map;
	*green_table = lin_per_green_map;
	*blue_table = lin_per_blue_map;

	return(1 & *message);

}

IGRboolean RSretperlincalibptrs(
IGRlong   *message,
IGRushort **red_table,
IGRushort **green_table,
IGRushort **blue_table)

{
	*red_table = per_lin_red_map;
	*green_table = per_lin_green_map;
	*blue_table = per_lin_blue_map;

	return(1 & *message);

}


void	RSset_calibration_mode(IGRint	mode)
{
	per_lum = mode;
	RScalc_per_calibration();
}

IGRint	RSget_calibration_mode(IGRint	*mode)

{
	*mode = per_lum;
	return(1);
}

IGRint  RSset_white_point_factors(
IGRdouble *red, 
IGRdouble *green, 
IGRdouble *blue)
{
	rw = *red;
	gw = *green;
	bw = *blue;

	return(1);
}

static IGRint    RScalc_per_calibration()
{

	IGRdouble per_red_exponent;
	IGRdouble per_green_exponent;
	IGRdouble per_blue_exponent;
	IGRdouble lin_per_red_exponent;
	IGRdouble lin_per_green_exponent;
	IGRdouble lin_per_blue_exponent;
	IGRdouble per_lin_red_exponent;
	IGRdouble per_lin_green_exponent;
	IGRdouble per_lin_blue_exponent;
	IGRdouble base,value;
#ifdef INTERPOLATE
	IGRdouble t;
#endif
	IGRulong lvalue;
  	IGRlong   msg;
	IGRlong	  i;
	extern	  IGRdouble MApower();

/* NEED TO ADD RW, GW, BW CODE !!!!!!!!!!!!!!!!!!!!!!!!!!!!	*/

	if (per_lum)
	{

	      per_red_exponent = 3;
	      per_green_exponent = 3;
	      per_blue_exponent = 3;

  /*
   * since rgb data is stored in a X^3 power curve, calculate rgb calibration
   * when cmyk data is convert to to rgb values, the rgb values are converted
   * to linear luminance rgb values. In order to display using rgb power curve,
   * an inverse map is created which will map the rgb values so that after 
   * going through the rgb calibration, the data will display properly
   */

	      lin_per_red_exponent = 1/3.0;
	      lin_per_green_exponent = 1/3.0;
	      lin_per_blue_exponent = 1/3.0;

	      per_lin_red_exponent = 3.0;
	      per_lin_green_exponent = 3.0;
	      per_lin_blue_exponent = 3.0;

              for (i = 0; i <= 255; i++)
              {
#ifdef INTERPOLATE
/*
 * Case for general curve already stored in lin_lum_red_cal.  Some 
 * problems may exist with truncation due to integer curves.  This is
 * why this version is conditionally compiled out at this point.
 * Need to debug,  improve, and deliver for use with Sequel calibrator.
 */

	  	base = i / 255.0;

		value = MApower(&msg,&base,&per_red_exponent);
		lvalue = value * 255;
		if (lvalue >= 255)
		{
		  per_red_cal[i] = lin_lum_red_cal[255];
		}
		else
		{
		  t = 255 * value - lvalue;
		  per_red_cal[i] = lin_lum_red_cal[lvalue] + 
				   t * (lin_lum_red_cal[lvalue + 1] -
				   lin_lum_red_cal[lvalue]) + 0.5;
		}

		value = MApower(&msg,&base,&per_green_exponent);
		lvalue = value * 255;
		if (lvalue >= 255)
		{
		  per_green_cal[i] = lin_lum_green_cal[255];
		}
		else
		{
		  t = 255 * value - lvalue;
		  per_green_cal[i] = lin_lum_green_cal[lvalue] + 
				   t * (lin_lum_green_cal[lvalue + 1] -
				   lin_lum_green_cal[lvalue]) + 0.5;
		}

		value = MApower(&msg,&base,&per_blue_exponent);
		lvalue = value * 255;
		if (lvalue >= 255)
		{
		  per_blue_cal[i] = lin_lum_blue_cal[255];
		}
		else
		{
		  t = 255 * value - lvalue;
		  per_blue_cal[i] = lin_lum_blue_cal[lvalue] + 
				   t * (lin_lum_blue_cal[lvalue + 1] -
				   lin_lum_blue_cal[lvalue]) + 0.5;
		}
#else
/*
 *  Special case where lin_lum_red_cal is known to be a power function.
 */

                base = lin_lum_red_cal[i] / 65535.0;
                value = MApower(&msg,&base,&per_red_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_red_cal[i] = lvalue;;

                base = lin_lum_green_cal[i] / 65535.0;
                value = MApower(&msg,&base,&per_green_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_green_cal[i] = lvalue;

                base = lin_lum_blue_cal[i] / 65535.0;
                value = MApower(&msg,&base,&per_blue_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_blue_cal[i] = lvalue;
#endif

                base = i / 255.0;

                value = MApower(&msg,&base,&lin_per_red_exponent) * 
			65535;
                lvalue = MAnint(value);
                lin_per_red_map[i] = lvalue;

                value = MApower(&msg,&base,&lin_per_green_exponent) * 
			65535;
                lvalue = MAnint(value);
                lin_per_green_map[i] = lvalue;

                value = MApower(&msg,&base,&lin_per_blue_exponent) * 
			65535;
                lvalue = MAnint(value);
                lin_per_blue_map[i] = lvalue;

                value = MApower(&msg,&base,&per_lin_red_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_lin_red_map[i] = lvalue;

                value = MApower(&msg,&base,&per_lin_green_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_lin_green_map[i] = lvalue;

                value = MApower(&msg,&base,&per_lin_blue_exponent) * 
			65535;
                lvalue = MAnint(value);
                per_lin_blue_map[i] = lvalue;
	      }


	}
	else
	{
            for (i = 0; i <= 255; i++)
            {
              per_red_cal[i] = lin_lum_red_cal[i];
              per_green_cal[i] = lin_lum_green_cal[i];
              per_blue_cal[i] = lin_lum_blue_cal[i];
            }

            for (i = 0; i <= 255; i++)
            {
              lin_per_red_map[i] = i * 257;
              lin_per_green_map[i] = i * 257;
              lin_per_blue_map[i] = i * 257;
              per_lin_red_map[i] = i * 257;
              per_lin_green_map[i] = i * 257;
              per_lin_blue_map[i] = i * 257;
            }
	}

	return(1);
}

