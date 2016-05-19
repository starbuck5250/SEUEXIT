# SEUEXIT
SEU Exit program

This program is intended to be used with the IBM i green screen editor SEU.  SEU allows one to register a user written exit program which can handle 2 function keys (F7 and F8) as well as user-written line commands.  SEUEXIT is a proof of concept that implements a 'split' function (F7) as well as a line command ATTRxx which will insert attribute bytes into the source to highlight, underline, etc source code as rendered by SEU.

To install:
1) Create the RPGLE program:
  a) Save the source SEUEXIT to a source file like QRPGLESRC
  b) CRTBNDRPG PGM(yourlib/SEUEXIT) SRCFILE(yourlib/QRPGLESRC) SRCMBR(SEUEXIT) DBGVIEW(*LIST) REPLACE(*YES)
2) Register the exit progrsm within SEU:
  a) STRSEU
  b) F13 to show the Change Session Defaults display
  c) Page Down until you see the User Exit Program prompt
  d) For the User exit program name: SEUEXIT
  e) For the Library: yourlib
  f) Enter to save the changes
  
To use:
1) Split a line:
  a) Position the cursor in the middle of a line of code where you'd like to split the line
  b) F7
    i) This will create a new line after the current one
    ii) Move all of the text to the right of the cursor to the new line
    iii) Truncate the current line at the cursor
2) Join two lines:
  a) Position the cursor at the end of a line
  b) F7
    i) This will move the following line's text  to the current line, at the current cursor position.
3) Add a 'text display attribute':
  a) This is a line command, like C or O, and is typed over the sequence number.
  b) Attributes supported:
    i) blank - normal / no attribute
    ii) RI - reverse intensity
    iii) HI - highlight (white)
    iv) UL - underline
    v) BL - blink (red)
    vi) CS - column separator
    vii) CP - colour pink
    viii) CL - colour lavender
  c) Specifically not working for CL; where would you put the attribute byte in the source code?
  d) Over the sequence number, type ATTR then the two characters in the above list
  e) The line gets a modified attribute byte placed into column 1
    i) If your SEU window does not show column 1, the new attribute won't display
    ii) Use line command 'W1'  to shift the window to view column 1 (and see the changed rendering)
