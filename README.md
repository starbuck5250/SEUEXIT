# SEUEXIT
SEU Exit program

This program is intended to be used with the IBM i green screen editor SEU.  SEU allows one to register a user written exit program which can handle 2 function keys (F7 and F8) as well as user-written line commands.  SEUEXIT is a proof of concept that implements a 'split' function (F7) as well as a line command ATTRxx which will insert attribute bytes into the source to highlight, underline, etc source code as rendered by SEU.
