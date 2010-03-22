20 Mar 2010

Researching the build scripts, want to reduce them down to the bare essientials
Move the files in to here as we figure out what they do

system.env

SYSTEM_BUILD=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc
SYSTEM_BUILD_ROOT=/home/impd3/isdp/xforms/build
SYSTEM_DELIVER=/home/impd3/isdp/xforms/deliver/sunos/5.10/i86pc/ws_s
SYSTEM_DELIVER_ROOT=/home/impd3/isdp/xforms/deliver
SYSTEM_INFORMATION=/home/impd3/isdp/xforms/source/sysinfo10
SYSTEM_LOCATION=/home/impd3/isdp/xforms
SYSTEM_LOG=/home/impd3/isdp/xforms/source/log
SYSTEM_NAME=xforms
SYSTEM_NAME_KEY=XFORMS
SYSTEM_PACKAGE=/home/impd3/isdp/xforms/package/sunos/5.10/i86pc
SYSTEM_PACKAGE_ROOT=/home/impd3/isdp/xforms/package
SYSTEM_PRODUCT_INFORMATION=/home/impd3/isdp/xforms/source/prodinfo
SYSTEM_RELEASE=/home/impd3/isdp/xforms/release/sunos/5.10/i86pc
SYSTEM_RELEASE_ROOT=/home/impd3/isdp/xforms/release
SYSTEM_ROOT=/home/impd3/isdp/xforms
SYSTEM_SOURCE=/home/impd3/isdp/xforms/source
SYSTEM_VERSION=01.02.05.13
SYSTEM_VERSION_NUMBER=01020513
SYSTEM_VERSION_STRING=01.02.05.13



PROJECT_NAME=xforms10
STRIP=1

SUNOS_VERSION=SUNOS5
SUNOS_PACKAGE_LIST=SUNOS5

OS_KEY=SUNOS5
OS_KEY_INITIALIZATION_LIST='SUNOS4 SUNOS5 IRIX CLIX SCO HPUX'
SUPPORTED_OS_KEY_INITIALIZATION_LIST='SUNOS4 SUNOS5 IRIX CLIX SCO HPUX'

CURRENT_PROC_TYPE=i86pc
CURRENT_PROC_TYPE_KEY=I86PC
DEFAULT_PROC_TYPE=i86pc
DEFAULT_PROC_TYPE_KEY=I86PC
PROC_TYPE_LIST=i86pc
PROC_TYPE_PACKAGE_LIST=i86pc
SUPPORTED_PROC_TYPE_LIST='c100 c400 sun4 mips'

OSDIR=sunos
OSVER=5.10
OSVERLIST=5.10

DLVRPROC
DLVRPROCLIST
PROD_DLVR=/home/impd3/xforms/deliver///i86pc/ws_s/

export PROJINFO SYSINFO PRODINFO SYSLOG SYSSRC SYSBLD
PRODINFO=/home/impd3/isdp/xforms/source/prodinfo
PROD_INFO_DIR=/home/impd3/isdp/xforms/source/prodinfo/
PROJINFO - Commented out

SYSBLD=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc
SYSINFO=/home/impd3/isdp/xforms/source/sysinfo10
SYSLOG=/home/impd3/isdp/xforms/source/log
SYSSRC=/home/impd3/isdp/xforms/source

PROD_BLD=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc
PROD_DLVR=/home/impd3/isdp/xforms/deliver/sunos/5.10/i86pc/ws_s/
PROD_INFO_DIR=/home/impd3/isdp/xforms/source/prodinfo/
PROD_REL=/home/impd3/isdp/xforms/release/sunos/5.10/i86pc/
PROD_SRC=/home/impd3/isdp/xforms/source

# proddata
UMS
XC
license tool directory

export UMS FS FS_INCLUDE XC LICTOOL_DIR LICTOOL_LIB LICTOOL_INCLUDE_FILE

XFORMS=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc
XFORMSDP=/opt/ingr/xformsdp

export XFI XFB XMB XFUTIL
XFI=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/xfi
XFI_INC_DIR=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/xfi/include

XFB=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/xfb
XFB_INC_DIR=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/xfb/include

XMB=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/xmb

XFUTIL=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/util

LIB_DIR=/home/impd3/isdp/xforms/build/sunos/5.10/i86pc/xfi/lib/i86pc

UMS_ARLIB_DIR=/lib/i86pc
UMS_LIB_DIR=/lib

Compiler options for SUNOS5 i386
CC=cc
COPT=' -Xc -W0,-xd -xO1 -Dlicensing_off=1 -DFI_USE_INGRHOME=1 -Dsun=1'
COMPOPT='-xCC -Xa -m32 -Kpic -features=no%conststrings -g'

Key off off DBG
COPT = -g or not
STRIP = 1 or 0 for DBG

DOPT=' -DSUNOS -DSUNOS5 -DSYSV'
MKDOPT='-DDEBUG -DX11 -DNOT_SHARABLE -DINTEL -DLITTLE_ENDIAN -DSYSV -DSYS5
  -Di386 -D__i386 -D__i386__ -DINGR -DRUN_X=1 -DSVR4 -DSUNOS -DSUNOS5 -DSUNOS58
  -DUNIX -D__BUILTIN_VA_ARG_INCR'

# Dont really need this, X11 is already linked under /usr/include
X11_INCLUDE_LOC=/usr/openwin/share/include
ANSI_INCLUDE=/usr/include

MAKEMAKE='makemake -DSUNOS5'
MOPT='-Di86pc=1 -D__i86pc__=1'
