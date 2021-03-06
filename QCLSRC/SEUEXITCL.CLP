/* Create SEUEXIT message file */
/* parameter is the name of the library where you want */
/* to install the message file */
pgm &tgtlib

dcl &tgtlib *char 10

monmsg cpf2112 /* MSGF already exists */
monmsg cpf2412 /* MSG already exists */

CRTMSGF MSGF(&tgtlib/SEUEXIT) TEXT('SEU Exit program messages') CCSID(*MSGD)

ADDMSGD MSGID(SEU0001) MSGF(SEUEXIT) MSG('Cursor is not positioned within  a +
          source statement.')
ADDMSGD MSGID(SEU0002) MSGF(SEUEXIT) MSG('Line split complete.')
ADDMSGD MSGID(SEU0003) MSGF(SEUEXIT) MSG('Line join complete.')
ADDMSGD MSGID(SEU0004) MSGF(SEUEXIT) MSG('Cannot update in Browse mode.')
ADDMSGD MSGID(SEU0005) MSGF(SEUEXIT) MSG('ATTR command processed.')
ADDMSGD MSGID(SEU0006) MSGF(SEUEXIT) MSG('ATTR command not valid for this +
          member type.')
ADDMSGD MSGID(SEU0007) MSGF(SEUEXIT) MSG('&1') FMT((*CHAR 80))

endpgm
