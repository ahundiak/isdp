
# This file is used to set up raster variables used by DBAccess.
# In order to for DBAccess to use this file you need to:
#
# export DBA_RASTER=/usr/ip32/dba/support/raster.ctl
#                         or
# set DBA_RASTER=c:\win32app\ingr\dba\support\raster.ctl
#
# Each user can make a copy of this file to their own directory and modify
# DBA_RASTER to point to their directory / file.
#
# Also note that everything is case sensitive.

# Window origin

X1: 30
Y1: 10           

# Width and Height of window

Width:  400
Height: 400

# "Windows" mode of how the graphics windows will be displayed.
# Valid values are: CASCADE or QUADRANT

Windows: CASCADE

# The offset values are used only if you have set the variable Windows
# to CASCADE

Offset_x: 10
Offset_y: 10

# There is a little button menu that has some read only graphics functions
# like Fit, Window Area, Zoom In etc...  The menu is displayed by the
# when the user types a "v".
#
# There are three valid "Menu" commands:
# PERMANENT
#    Once the raster command menu is displayed it will stay displayed until
#    the user hits the cancel button.
# POP_UP
#    An soon as the user hits a button the menu will be erased.
# NONE
#    The raster menu will not be displayed when the user hits the "v" key.

Menu: PERMANENT

# The Hot Keys setting determines whether or not DBA will react when the keys
# listed in doc/hot_keys.txt are depressed.  The default is "ON".

# Hot_keys: OFF

# Highlight, Foreground, Background, File_Link_Color, Note_Link_Color,
# User_Link_Color, and Database_Link_Color control the colors of the
# window and the DBA Links.
#   The valid colors are:
#       LIGHT CYAN          0
#       DARK GRAY           1
#       BLACK               2
#       YELLOW              3
#       LIGHT GRAY          4
#       DARK CYAN           5
#       WHITE               6
#       LIGHT RED           7
#       LIGHT GREEN         8
#       LIGHT BLUE          9
#       BROWN               10
#       DARK RED            11
#       DARK GREEN          12
#       DARK BLUE           13
#       DARK MAGENTA        14
#       LIGHT MAGENTA       15

Highlight:  4
Foreground: 2
Background: 6
File_Link_Color: 11
Note_Link_Color: 9
User_Link_Color: 3
Database_Link_Color: 8

# If you want the DBAccess database redlines/links to be displayed everytime
# the graphics image is repainted set Auto_Display_links to "ON" the
# default value is "OFF"

Auto_Display_Links: OFF

# You can specify the type of text redline font that you want to use.
# The font should be one that is available on the machine you are running on.

# Font: mono821b

# Files_Table, Links_Table, Points_Table, and Strings_Table tells DBAccess
# the name of the tables that you want the graphics and redline info stored.

# Files_Table:   dba_files
# Links_Table:   dba_links
# Points_Table:  dba_points
# Strings_Table: dba_strings

# If you want to save and load redlines from redlines file dbaccess needs
# to know where to look for the redline files.  If you do not set
# the Redline_Path it will:
#    a) if you are on the clipper it will use the users current working
#       directory as the redline storage area.
#    b) if you are on the pc the default redline storage area will be read
#       from the dmredl.ini file found in your windows directory.

# Redline_Path: /usr/redlines                   (on clipper)
# Redline_Path: c:\usr\redlines                 (on pc)

# In order to be able view database links between unix and dos two global
# pointers have been set up.  DB Access stores the original location
# of a file in the database (dba_files).  When a user displays a file
# that file is checked against dba_files table to see if it already has
# a file number assigned to it.  DB Access will check for three file
# combination based on the above pointers.
#
#   1) drive_path_filename           to database
#   2) dba_files_path/filename       to database
#   3) dba_files_drive/path_filename to database
#
#   where drive_path_filename is:
#
#      /usr/files/demo.tg4
#                 or
#      c:\files\demo.tg4
#
#   where dba_files_path is:
#
#      /usr/files
#          or
#      c:\files
#
#   where dba_files_drive is:
#
#       /usr
#        or
#        c
#
#   If after three attempts to make a match fail, a new entry will
#   be put into the database.

# Files_Path: c:\usr\files
# Files_Drive: c

# Redline_Mode variable will have an effect on the following
# "dba standard buttons":
#
#                                 Draw Arc
#                                 Draw Arrow
#                                 Draw Circle
#                                 Draw Ellipse
#                                 Draw Filled Circle
#                                 Draw Filled Ellipse
#                                 Draw Filled Rectangle
#                                 Draw Filled Shape
#                              *  Draw Freehand
#                                 Draw Line
#                                 Draw Rectangle
#                                 Draw Shape
#                              *  Draw Symbol
#                                 Draw Text
#                              ** Copy Redline
#                              ** Delete Redline
#                              ** Move Redline
#                              *  Select Redline
#                              ** Undo Redline
#
# *   Draw Freehand, Draw Symbol and Select Redline only work on the pc
#     version of dba.
#
# **  Copy, Delete, Move, and Undo redlines only work on dm redlines.
#     They will NOT work on dba database redlines.
#
# If Redline_Mode is set to 0 then the dba buttons above will do DM/Redline
# calls to that you can save your redlines to a file.  If Redline_Mode
# is set to 1 then all redlines from the buttons above will be to the
# database.

Redline_Mode: 0

# The Plot_Queue is used on the Clipper only.  You use this variable to
# specify which queue you wish the displayed graphics to be plotted to.

# Plot_Queue: laser

# Graphics window information only used on pc DBA

Graphics_Window_x: 10
Graphics_Window_y: 10
Graphics_Window_Width:  550
Graphics_Window_Height: 450
