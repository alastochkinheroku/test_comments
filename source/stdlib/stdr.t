/* Copyright (c) 1989-2009 by Michael J. Roberts.  All Rights Reserved. */
/* Copyright (c) modifed 2002-2011 by Andrey P. Grankin.
   All Rights Reserved by license.

  				RusRelease 27

   Copyright (c) 1989-2009  ����� ��. �������. ��� ����� ���������.
   Copyright (c) ��������� 2002, 2009 ����� ����������� ������� �. ���������.
   ������� ������������ � �������� ���������� ������ ��������� (2003 ���).
   ��� ����� ��������� ���������.

  stdr.t -- ������� ����������� ����������� ��������������� �����������
  ������ 2.5.14

  ���� ���� �������� ������ TADS: �������� ���������� ���������
  ��������������� ���. ���������� �� ������������� ����� ����� �� ������
  ����� � ����� "LICENSE.TAD" (���� ������ ���� ������ ��������).

  �� ������ �������� � ������������ ���� ���� ����� �������, ���������
  ��, ��� � ������, ���� �� ������ �������������� ���������� ����� �����
  ����� � ����� �������� �������, ��� ����� ������ ��������� ������������
  ������ �� ��������� ������ (������� ���� �����), � ������ ���� ���������
  ��������, ��� ���������� ���� ������������ ������.

  ���� ���� ������������� ����������� ������� �������� � �������,
  ����������� ��� RTADS, �� �� ������������ � ����� "advr.t".
  ����������� � "stdr.t" ��������� ��� ��������� ����, ������, �����
  ���� ����� ������ � ����������, ��, ��������, ����������, ��� ������
  �������� ��������� �����������, ������ � ���� �����. ���� ����
  ������������ ������ ��� ������ ��� ����� ������, ������������ ��������,
  ������� ����������� ��� ������� � ��������.

  ����� �� �������� �������� ��� ������� � ������� ��� ����� ����,
  ������� ��������� ����� "stdr.t", ����� �������� ������������
  �����������. ������ �����, �������� ���� ���������� ������ �����
  �����, �������� ��������, �������� �� "stdr.t" -- ��� �������� ���
  �������� ��������.


  stdr.t   - russian mod of standard default adventure definitions
  Version 2.5.14
  
  This file is part of TADS:  The Text Adventure Development System.
  Please see the file LICENSE.TAD (which should be part of the TADS
  distribution) for information on using this file.

  You may modify and use this file in any way you want, provided that
  if you redistribute modified copies of this file in source form, the
  copies must include the original copyright notice (including this
  paragraph), and must be clearly marked as modified from the original
  version.

  This file provides some simple definitions for objects and functions
  that are required by TADS, but not defined in the file "adv.t".
  The definitions in "std.t" are suitable for use while a game is
  being written, but you will probably find that you will want to
  customize the definitions in this file for your game when the
  game is nearing completion.  This file is intended to help you
  get started more quickly by providing basic definitions for these
  functions and objects.

  When you decide to customize these functions and objects for
  your game, be sure to remove the inclusion of "stdr.t" to avoid
  duplicate definitions.

*/

/* ���������� ������ ����, ��� ���� � ����������� ����������� TADS */
/* parse with normal TADS operators */
#pragma C-

/*
 *   ����������� ��� �������, ��� ��� ���������� ����� �����, ���
 *   ��� �������. (��� ������������� �����, ������ ���� ������� �����
 *   ���������� ��� ����� (daemon) ��� ����� (fuse) �� ����, ��� ���
 *   ���������; �������, �� �������� �������� ��� �������.
 *   
 *   Pre-declare all functions, so the compiler knows they are functions.
 *   (This is only really necessary when a function will be referenced
 *   as a daemon or fuse before it is defined; however, it doesn't hurt
 *   anything to pre-declare all of them.)
 */
displayImage: function;
displayLink: function;
die: function;
scoreRank: function;
init: function;
terminate: function;
pardon: function;
sleepDaemon: function;
eatDaemon: function;
darkTravel: function;
mainRestore: function;
commonInit: function;
initRestore: function;

displayImage: function( imageName, objectToCheck, centre )
{
  if ( not objectToCheck.imageSeen or ( not global.displayGraphicsOnce ) )
  {
    "<IMG SRC=\"";
    say( imageName );
    "\"";
    if ( not centre )
      " ALIGN=RIGHT HSPACE=30";
    if ( centre )  
      " ALIGN=LEFT HSPACE=5 ";    
    ">";
    if ( objectToCheck <> nil )
      objectToCheck.imageSeen := true;
  }
}

displayLink: function( command, text )
{
  if ( not global.displayLinks or command = '' )
    say( text );
  else
  {
    "<A HREF=\"";
    say( command );
    "\">";
    say( text );
    "</A>";
  }
}

/*
 *   ������� die() ���������� �����, ����� ����� �������. ��� ��������
 *   ������ ��������� �� �������� � ���� (����� ��� ����), � ����������
 *   ����� �� �� ������ ���� ������ (��� ����� ������).
 *   
 *   The die() function is called when the player dies.  It tells the
 *   player how well he has done (with his score), and asks if he'd
 *   like to start over (the alternative being quitting the game).
 */
die: function
{
    "\b*** �� ���������! ***\b";
    "\b*** ��� ������ ������ ***\b";  // ��������� �� ����� ����������
    scoreRank();
    "\b��������: ������������ ����������� ����, ������ ������, �����.\n �������� ������ ���������� ��������.\n";
    while (true)
    {
        local resp;

        "\n����������, ������� ������������, ������, ����� ��� ������: >";
        resp := upper(input());
        resp := loweru(resp);
        if ((resp='restore') or (resp='������������'))
        {
            resp := askfile('���� ��� ��������������:',
                            ASKFILE_PROMPT_OPEN, FILE_TYPE_SAVE);
            if (resp = nil)
                "�������� �� �������. ";
            else if (restore(resp))
                "�������� �� �������. ";
            else
            {
                parserGetMe().location.lookAround(true);
                scoreStatus(global.score, global.turnsofar);
                abort;
            }
        }
        else if ((resp = 'restart') or (resp='������'))
        {
            scoreStatus(0, 0);
            restart();
        }
        else if ((resp = 'exit') or (resp='�����'))
        {
            terminate();
            quit();
            abort;
        }
        else if ((resp = 'undo') or (resp='������'))
        {
            if (undo())
            {
                "(������ ����� �������)\b";
                parserGetMe().location.lookAround(true);
                scoreStatus(global.score, global.turnsofar);
                abort;
            }
            else
                "� ���������, �������� ������� ��� ����������. ";
        }
    }
}

/*
 *   ������� scoreRank() ���������� ��������� ����� �������� � ����.
 *   �� ���������, ������� �� ������ ������, ����� ����������� �������
 *   � ����������� ��������� �����. ��������� ������� ��� �������� �����
 *   ���������� �������, ��������������� ��������� ����������� �����
 *   ("���������� �������� �����������", "�������" � �.�.); ����� --
 *   ����� ������� ���, ���� ����������.
 *   
 *   ��������, ��� ���������� "global.maxscore" ���������� ������������
 *   ���������� �����, ��������� ������� � ����; �������� ���� "maxscore"
 *   ������� "global", ���� �����.
 *   
 *   The scoreRank() function displays how well the player is doing.
 *   This default definition doesn't do anything aside from displaying
 *   the current and maximum scores.  Some game designers like to
 *   provide a ranking that goes with various scores ("Novice Adventurer,"
 *   "Expert," and so forth); this is the place to do so if desired.
 *
 *   Note that "global.maxscore" defines the maximum number of points
 *   possible in the game; change the property in the "global" object
 *   if necessary.
 */
scoreRank: function
{
 " � ����� �� "; say(global.turnsofar);
    " ���<<numok(global.turnsofar, '','�','��')>>, �� �������� ����� � ";
    say(global.score); " ������<<numok(global.score, '�','�','')>>";
    " �� ��������� ";
    say(global.maxscore);
    ".\n";
}

/*
 *   ������� commonInit() �� �������� ����������� ��� RTADS; ��� -- ������
 *   ��������������� �������, ������� �� ���������, ����� �� ������
 *   ��������� ���� ���������������� ��� � ����� �����. ��� ������� 
 *   ���������� �� init() � initRestore(). �, � ����� � ���, ��� ��� ������
 *   ������� ����� ������� ������ init() ��� initRestore(), �� �� ���,
 *   ���������� ����� ���� �������, ������� ��� ��� ������� ��������,
 *   ����� ���� � ��� �� ��� ��� �������� ��� ������ ��� ����������� ��
 *   ����, ��� �� �������� ����.
 *   
 *   commonInit() - this is not a system-required function; this is simply
 *   a helper function that we define so that we can put common
 *   initialization code in a single place.  Both init() and initRestore()
 *   call this.  Since the system may call either init() or initRestore()
 *   during game startup, but not both, it's desirable to have a single
 *   function that both of those functions call for code that must be
 *   performed at startup regardless of how we're starting. 
 */
commonInit: function
{
    // ��������� ����� ���������������� ��� �����
    // put common initialization code here
    // ������� �����������, ����� �������� HTML 
    "\H+"; 
}

/*
 *   ������� init() ���������� � ����� ������ ����. ��� ������
 *   ���������� ������������� ����� ����, ��������� ��� �����������
 *   ������ (daemon) � ������ (fuse), � ����������� ��������� ������
 *   (������ "Me") � �������������� �������, ������� �� ��������� �����
 *   �������� "startroom".
 *   
 *   The init() function is run at the very beginning of the game.
 *   It should display the introductory text for the game, start
 *   any needed daemons and fuses, and move the player's actor ("Me")
 *   to the initial room, which defaults here to "startroom".
 */
 
 // ��������� ������������� ����� ����
 // put introductory text here
 introduction: function
 {
    "\t���� ����� �������� ����������. \b";
 }
 
init: function
{
#ifdef USE_HTML_STATUS
    /* 
     *   �� ���������� HTML-����� ��������� ������ -- ����� �������,
     *   ��� ������������ ������������� ���������� ����� ������, �����
     *   ������������ ���� ���. (��� ��������� ������ ����������
     *   systemInfo, ����� ����������, ������������ �� �������������
     *   HTML ��� ��� -- HTML �� �������� ��������� �� �������
     *   �������������� 2.2.4.)
     *   
     *   We're using the adv.t HTML-style status line - make sure the
     *   run-time version is recent enough to support this code.  (The
     *   status line code uses systemInfo to detect whether the run-time
     *   is HTML-enabled or not, which doesn't work properly before
     *   version 2.2.4.)  
     */
    if (systemInfo(__SYSINFO_SYSINFO) != true
        || systemInfo(__SYSINFO_VERSION) < '2.2.4')
    {
        "\b\b\(��������! ��� ���� ������� ������������� TADS ������
        2.2.4 ��� ����. ������, ��� �� ����������� ����� ������ ������
        ��������������. �� ������ ����������� ��������� ��� ����, ������,
        ����������� �������� ������ ����� �� �������� ���������. ����
        �� ����������� ����� ���� ���������, �� ������ �����������
        ������� �� ����� ����� ������ �������������� TADS.\)\b\b";
    }
#endif

    /* ���������� ����� ������������� */
    /* perform common initializations */
    commonInit();
    
    introduction();

    version.sdesc;                // ����� �������� � ������ ����

    setdaemon(turncount, nil);         // ������ ������ (deamon) �������� �����
                                       //         start the turn counter daemon
    setdaemon(sleepDaemon, nil);                  // ������ ������ (deamon) ���
                                                  //     start the sleep daemon
    setdaemon(eatDaemon, nil);                 // ������ ������ (deamon) ������
                                               //       start the hunger daemon
   //switchPlayer(newPlayer);			// ������ ������������ ������ �� ������
    parserGetMe().location := startroom;     //  ����������� ������ � ���������
                                             //                         �������
                                             // move player to initial location
    startroom.lookAround(true);            // �������� ������, ��� �� ���������
                                           //           show player where he is
    startroom.isseen := true;             // ��������, ��� ������� ���� �������
                                          //      note that we've seen the room
    scoreStatus(0, 0);                    // ���������������� ����������� �����
                                          //       initialize the score display
    randomize();			  // ���, ���� ����� ����������� � ����

}

/*
 *   ������� �������� ������� initRestore() ������������� ��� ������ ����,
 *   ���� ����� ������ ����������� ���� ��� �������������� � ���������
 *   ������ �������������� (��� ����� ������ ��������, ��������� ��
 *   ����������� ��������������). �� ������ ����������� ���� ����������
 *   �������.
 *   
 *   initRestore() - the system calls this function automatically at game
 *   startup if the player specifies a saved game to restore on the
 *   run-time command line (or through another appropriate
 *   system-dependent mechanism).  We'll simply restore the game in the
 *   normal way.
 */
initRestore: function(fname)
{
    /* ���������� ����� ������������� */
    /* perform common initializations */
    commonInit();

    /* �������� ������, ��� �� ��������������� ���� */
    /* tell the player we're restoring a game */
    "\b[����������� � ����������� �������...]\b";

    /* � ������������� ������������ ���� ���������� ������� */
    /* go restore the game in the normal way */
    mainRestore(fname);
}


/*
 *   preinit() ���������� ����� ���������� ����, �� �� ���� ��� ���
 *   ������������ � ���� ���� (.gam) � �������� �����.  ��� ���������� ���
 *   ���������������� ��������, ������� ����� ���� ������� ���������� ��
 *   ������ �������� �����; ��� ��������� �������� ���� �.�. ��� ������
 *   ���� ������� ���������������.
 *   
 *   ��� ������� ������� ��� �������-������ (lamp objects) (�������,
 *   ������� islamp = true) � ������ global.lamplist. ���� ������
 *   �����������, ��� ��������� �������� �� ������ ������� �����
 *   ���� ��������� �����.
 *   
 *   preinit() is called after compiling the game, before it is written
 *   to the binary game file.  It performs all the initialization that can
 *   be done statically before storing the game in the file, which speeds
 *   loading the game, since all this work has been done ahead of time.
 *
 *   This routine puts all lamp objects (those objects with islamp = true) into
 *   the list global.lamplist.  This list is consulted when determining whether
 *   a dark room contains any light sources.
 */
preinit: function
{
    local o;
    
    global.lamplist := [];
    o := firstobj();
    while(o <> nil)
    {
        if (o.islamp)
            global.lamplist := global.lamplist + o;
        o := nextobj(o);
    }
    initSearch();

#ifdef GENERATOR_INCLUDED    
    generation();
#endif    

#ifdef GAMEINFO_INCLUDED
    writeGameInfo(getGameInfo());
#endif
}

/*
 *   ������� terminate() ���������� ��� ��� ����� ���������� ����. ���
 *   ������ ���������� ���������� ���������. �� ���������, ��� ������
 *   �� ������. ��������, ��� ��� ������� ���������� ������ �����, �����
 *   ����� �������� ����, �� �� ����� ��� ������, �� ����� ����������
 *   ���� ������ �� ���-������ ���.
 *   
 *   The terminate() function is called just before the game ends.  It
 *   generally displays a good-bye message.  The default version does
 *   nothing.  Note that this function is called only when the game is
 *   about to exit, NOT after dying, before a restart, or anywhere else.
 */
terminate: function
{
}

/*
 *   ������� pardon() ���������� ������ ���, ��� ����� ������ ������ ������.
 *   ��� ������� ������ ������ ������� ��������� ("��������" ��� ��� ����
 *   ��������). �� ��������� ��� ������ ������� "�� ���-�� �������?".
 *   
 *   The pardon() function is called any time the player enters a blank
 *   line.  The function generally just prints a message ("Speak up" or
 *   some such).  This default version just says "I beg your pardon?"
 */
pardon: function
{
    "�� ���-�� �������? ";
}

/*
 *   ������� sleepDaemon() -- ����� (daemon), ���������� �� init(),
 *   ������ �� ���, ��� ����� ����� ������ � ��� ���, ����� ����� ���������
 *   ��� ����. ���� ������� �������� ������� ����� �� ����, �������
 *   ����������� ��������� ��� ����� ���, ��� ������� �������� ������������
 *   �������, ��� �������� � ��� ������� � ������� � ���. ������������
 *   ���������, ������� ���������, ���� �� (������� ��������) ��������
 *   �������� -- ��� ��, ��� �� ������ �� ����� ��� ��������, �����������
 *   � ��� ��������. ��������� ���� ����� ��������� �� �������� ��� ����,
 *   ��� �� ����� ��� �� ������� ��������� �����; ��������, �������
 *   ������� ���������� �� ��� ��� ����� ���� ��������.
 *   
 *   This function is a daemon, started by init(), that monitors how long
 *   it has been since the player slept.  It provides warnings for a while
 *   before the player gets completely exhausted, and causes the player
 *   to pass out and sleep when it has been too long.  The only penalty
 *   exacted if the player passes out is that he drops all his possessions.
 *   Some games might also wish to consider the effects of several hours
 *   having passed; for example, the time-without-food count might be
 *   increased accordingly.
 */
sleepDaemon: function(parm)
{
    local a, s;

    global.awakeTime := global.awakeTime + 1;
    a := global.awakeTime;
    s := global.sleepTime;

    if (a = s or a = s + 10 or a = s + 20)
        "\b<<ZA(dToS(parserGetMe(),&sdesc))>> ��� �����<<iao(parserGetMe())>>, ���� ����� �����, ��� ����� ���������. ";
    else if (a = s + 25 or a = s + 30)
        "\b<<ZA(dToS(parserGetMe(),&ddesc))>> ����� �������, ����� <<parserGetMe().sdesc>> ����<<glok(parserGetMe(),1,2)>> �� ���������! ";
    else if (a >= s + 35)
    {
        global.awakeTime := 0;
        if (parserGetMe().location.isbed or parserGetMe().location.ischair)
        {
            "\b � ������ � <<parserGetMe().vdesc>> ���������� ��� ��������, � <<parserGetMe().sdesc>>, �� � ����� �������� ���� �� �����, 
              ����<<iao(parserGetMe())>>.
              �� �������, <<parserGetMe().sdesc>> �����<<glok(parserGetMe(),2,2)>>�� << parserGetMe().location.statusPrep >> << parserGetMe().location.mdesc >>,
              ������� <<parserGetMe().sdesc>> ������ ��<<ella(parserGetMe())>> � �������� �������������� ���.
              \b* * * * *
              \b��������� ����� ������ <<parserGetMe().sdesc>> �������<<saas(parserGetMe())>>, �������� ���� ����������� �����.\n ";
        }
        else
        {
            local itemRem, thisItem;
            
            "\b<<ZAG(parserGetMe(),&sdesc)>>, �������, �������<<iao(parserGetMe())>> ���� �������� �� ����, � ��� ������ ����<<iao(parserGetMe())>> �� �����.
             \b* * * * *
             \b�����������, <<parserGetMe().sdesc>> ������������<<iao(parserGetMe())>> ���� ������.\n";
            itemRem := parserGetMe().contents;
            while (car(itemRem))
            {
                thisItem := car(itemRem);
                if (not thisItem.isworn)
                    thisItem.moveInto(parserGetMe().location);
                itemRem := cdr(itemRem);
            }
        }
    }
}

/*
 *   ������� eatDeamon -- �����, ���������� �� init(), ������ �� ���
 *   ������� ����� ������ � ��� ���, ��� �� ��������� ��� ��� ���� ��.
 *   ���� �� ���������� ����� ������ �� ��, ������� ��������� ��� �����������
 *   �� ���� ������, ����� ��� ��� �� ����� �� ���������.
 *   
 *   This function is a daemon, set running by init(), which monitors how
 *   long it has been since the player has had anything to eat.  It will
 *   provide warnings for some time prior to the player's expiring from
 *   hunger, and will kill the player if he should go too long without
 *   heeding these warnings.
 */
eatDaemon: function(parm)
{
    local e, l;

    global.lastMealTime := global.lastMealTime + 1;
    e := global.eatTime;
    l := global.lastMealTime;

    if (l = e or l = e + 5 or l = e + 10)
        "\b���� ����������. ";
    else if (l = e + 15 or l = e + 20 or l = e + 25)
        "\b<<ZAG(parserGetMe(),&sdesc)>> �������<<glok(parserGetMe(),1,1)>> ��������� ����� -- ���������� ������, ����� �� ������� � ������. ";
    else if (l = e + 30 or l = e + 35)
        "\b����� ���������� �����������. ";
    else if (l >= e + 40)
    {
        "\b<<ZAG(parserGetMe(),&sdesc)>> ����";
        if (parserGetMe().gender!=1) ella(parserGetMe());
        " �� ���������. ";
        die();
    }
}

/*
 *   ������ numObj ������ ��� �������� ����� ���� � ������, ���� �����
 *   ���������� ����� � ����� �������. ��������, "��������� �����
 *   �� 621" �������� � ����, ��� ���� "value" ���������� ������� numObj
 *   ����� ��������� �������� 621.
 *   
 *   The numObj object is used to convey a number to the game whenever
 *   the player uses a number in his command.  For example, "turn dial
 *   to 621" results in an indirect object of numObj, with its "value"
 *   property set to 621.
 */
numObj: basicNumObj  // ���������� ���������� �� advr.t �� ���������
                     // use default definition from adv.t
;

/*
 *   strObj �������� ��� �� ��� � numObj, �� ��� �����. �.�. ����
 *   �� ������� "������" �� ���������� � ����, ���� "value" ������� strObj 
 *   ����� ��������� ������ '������'.
 *   
 *   �������, ��� �.�. ������ ������ ������ ������������ ��� ���������� �
 *   �������������� ����, � ����� � ��������� ��������, ���� ������ ������
 *   ������������ ��� �������. 
 *   
 *   strObj works like numObj, but for strings.  So, a player command of
 *   type "hello" on the keyboard will result in a direct object of strObj, 
 *   with its "value" property set to the string 'hello'.
 *
 *   Note that, because a string direct object is used in the save, restore,
 *   and script commands, this object must handle those commands.
 */
strObj: basicStrObj     // ���������� ���������� �� advr.t �� ���������
                        // use default definition from adv.t
;

/*
 *   
 *   ������ "global" -- ������ ��� �������� ���� ��������� ������, �������
 *   �� �������� �� � ����� ������ ��������. ����� ����� �������, �������
 *   �������� ����� ��� �������� � �������, ��������� �����; ���� ��
 *   �������� ���� ������, �� ��������� ����������� ��������� ����� �����
 *   �����, ����������� �������� � ���� ��� �����, ����������� �����.
 *   
 *   �������, ��� awakeTime ���������� �� ����; ���� �� ������, �����
 *   �� ������� ���� ��������, �������� �������� ���� ����������
 *   ����� � �������� sleepTime (������� ��������� �������� �����
 *   ��������� ���). �� �� ����� �������� � �� ��������� lastMealTime:
 *   ��������� �������� ���� ���������� ����� � �������� eatTime, ���� ��
 *   ������, ����� �� ������� ���� ��������. ��� ������ �� ����
 *   ����������, ����� ������ �������� ��������������, ����� �����������
 *   ����� (awakeTime, lastMealTime) ��������� ��������� 
 *   (sleepTime, eatTime); ������, �� �� ������ ���������� ������ ��� ����
 *   ��� ������� -- �� ��� ��� ���� �� ����� ������� ��������� ��������������.
 *   ����� ���������� ������ �������� � �������� eatDaemon � sleepDaemon.
 *   
 *   The "global" object is the dumping ground for any data items that
 *   don't fit very well into any other objects.  The properties of this
 *   object that are particularly important to the objects and functions
 *   are defined here; if you replace this object, but keep other parts
 *   of this file, be sure to include the properties defined here.
 *
 *   Note that awakeTime is set to zero; if you wish the player to start
 *   out tired, just move it up around the sleepTime value (which specifies
 *   the interval between sleeping).  The same goes for lastMealTime; move
 *   it up to around eatTime if you want the player to start out hungry.
 *   With both of these values, the player only starts getting warnings
 *   when the elapsed time (awakeTime, lastMealTime) reaches the interval
 *   (sleepTime, eatTime); the player isn't actually required to eat or
 *   sleep until several warnings have been issued.  Look at the eatDaemon
 *   and sleepDaemon functions for details of the timing.
 */
global: object
    turnsofar = 0                        // ���� �� ���� ������� �� ������ ����
                                         //     no turns have transpired so far
    score = 0                         // ���� �� ���� ���������� �� ������ ����
                                      //    no points have been accumulated yet
    maxscore = 100                    // ����������� ��������� ���������� �����
                                      //                 maximum possible score
    verbose = nil                     // � ��������� ������ �� � ������� ������
                                      //         we are currently in TERSE mode
    awakeTime = 0               //  �����, �������� � ������� ���������� ��� ��
                                // time that has elapsed since the player slept
    sleepTime = 400     //     �������� ����� ��������� ��� (������������ �����
                        //                                       �������������)
                        // interval between sleeping times (longest time awake)
    lastMealTime = 0              //      �����, ��������� � ������� ����������
                                  //                             ������ ���� ��
                                  // time that has elapsed since the player ate
    eatTime = 200         //  �������� ����� �������� ���� (������������ �����,
                          //               ������� �� ����� ���������� ��� ���)
                          // interval between meals (longest time without food)
    lamplist = []              // ������ ���� ��������� ���������� ����� � ����
                               // list of all known light providers in the game
    vinpadcont = 1	 //���������, �������� ��������� � �����. ��� ��. ������

    glpad=0                 // ����, ����������� �� ��������� ������� ��������
                            // ������������ ������
    displayLinks = true  //���������, �������� ����������� �� ���������, ��� ���
;

/*
 *   ������ "version" ����� ���� ���� "sdesc" ���������� ��� � ������
 *   ����. �������� ��� �� ��������������� �������� ����� ����.
 *   
 *   The "version" object defines, via its "sdesc" property, the name and
 *   version number of the game.  Change this to a suitable name for your
 *   game.
 */
version: object
    sdesc = {
            "<b>��� ����</b>\n ������ ����� ����. �������� ������ ��� �������������. \n
             ������� �. \n ������ 0.0\b \b";
            } 
;

/*
 *   ������ "Me" (�������� ���������� �������) -- ��� ��������� �����������
 *   ���� ������; �������������� ���������� (������) ������������� ����������
 *   � ������ ���� ������, ������� ��� "Me", ��� ������, �������������� ��.
 *   �� ������ �������� ��������� "�� ���������", ������������ ��� ��������
 *   �� ��������� ������� (������) �� -- basicMe -- ������������ � "advr.t".
 *   
 *   ��������, ��� �� ������ �������� ������ �������� ��������� (��) �
 *   ����� ����� ����, ������ ������� parserSetMe(newMe), ��� newMe ��������
 *   ����� ��������, ������� ������������ �� � ����. �����, �� ������
 *   ������� �������������� ������, �������������� �������� ���������, ����
 *   �� ������ ��������� ������ ����� �� ���� ���� ���������� ���������
 *   ���������� � ���� ����; �� ������ ������� ���, ������ ������, 
 *   ����������� �� basicMe. (�������, ������������ �� basicMe ��
 *   ��������� �� �������, ��������������� ��, -- �� ������ ������� ����
 *   ����������� ������ �� � "������� �����", ������, ������� �����
 *   ����������� �� basicMe �.� ���� ����� ��� �������� ������� ����������
 *   ����, ������� ������ ��������� ��� ����������� "�������������" �� � ����.
 *   
 *   "Me" is the initial player's actor; the parser automatically uses the
 *   object named "Me" as the player character object at the beginning of
 *   the game.  We'll provide a default definition simply by creating an
 *   object that inherits from the basic player object, basicMe, defined
 *   in "adv.t".
 *   
 *   Note that you can change the player character object at any time
 *   during the game by calling parserSetMe(newMe).  You can also create
 *   additional player character objects, if you want to let the player
 *   take the role of different characters in the course of the game, by
 *   creating additional objects that inherit from basicMe.  (Inheriting
 *   from basicMe isn't required for player character objects -- you can
 *   define your own objects from scratch -- but it makes it a lot easier,
 *   since basicMe has a lot of code pre-defined for you.)  
 */
Me: basicMe
isHim = true       //�� ��������� ����� �������� ����.
// ��������� ����������� ����� ���� ������, ���� ������ ��������� �� "��".
/*sdesc="��"    
  rdesc="���"
  ddesc="���"
  vdesc="���"
  tdesc="����"
  pdesc="���"
  isThem=true
  fmtYou="��"
  fmtToYou="���"
  fmtYour="���"
  fmtYours="����"
  fmtYouve="��c"
  fmtWho="��"
  fmtMe="���"  
*/
;

/*
 *   ������� darkTravel() ���������� ������ ���, ��� ����� ��������
 *   ������������� �� ����� ������ ������� � ������ ������ �������. ��
 *   ���������, ������� ������ �������� "������� �� ����, �� ��� � ��
 *   ����� ������.", �� ��� ����� ����� ���������� ����� ��������� ��� ��
 *   ��������: ��������, ����� ��.
 *   
 *   darkTravel() is called whenever the player attempts to move from a dark
 *   location into another dark location.  By default, it just says "You
 *   stumble around in the dark," but it could certainly cast the player into
 *   the jaws of a grue, whatever that is...
 */
darkTravel: function
{
    "������� �� ����, <<parserGetMe().sdesc>> ��� � ��
 ���<<ella(parserGetMe())>> ������. ";
}

goToSleep: function
{
    "***\b<<parserGetMe().sdesc>> �������<<saas(parserGetMe())>>
  ��������� ����� ������, ������ ���� ����� � �����. ";
    global.awakeTime := 0;
}


#ifdef USE_HTML_PROMPT
/*
 *   ������� commandPrompt ���������� ��������� ������. ��� ���, �������
 *   ��������� HTML, �� ������������� �� ����������� ����� TADS-Input,
 *   ��� ��������� ������ �������� ����� ��� ��������� ������, ���������
 *   �������� �������������� ��� TADS.
 *   
 *   commandPrompt - this displays the command prompt.  For HTML games, we
 *   switch to the special TADS-Input font, which lets the player choose
 *   the font for command input through the preferences dialog.
 */
commandPrompt: function(code)
{
    "<font face='TADS-Input'>";
    // ������� ��������� �����������, ����� ��������� ������ ��� ����������.
    /*
    if (global.prompt_count = nil) global.prompt_count := 0; 		
    global.prompt_count++;						
    if (global.prompt_count < 5)					
	"\n��� ������ <<parserGetMe().ddesc>> ������?\b";		
    else if (global.prompt_count = 5)					
	"\n������ ������ ������ \"��� ������?\" �������� �� �����.\n	
         ������ ���������� ��������� � ������ ����� ������� ����� �������� ��������� ������ \">\".\b";
    */
    "\b&gt;";
}


/*
 *   ������� commandAfterRead ���������� ��� ��� ����� ����, ��� ����� ����
 *   ������� �������. ��� ���, ������� ��������� HTML, �� ������ �������������
 *   ����� �� ��� �����, ������� ��� ���������� ����� ���, ��� �� ����������
 *   ����� ����� ��� ��������� ������ (TADS-Input) � ������� commandPrompt.
 *   
 *   commandAfterRead - this is called just after each command is entered.
 *   For HTML games, we'll switch back to the original font that was in
 *   effect before commandPrompt switched to TADS-Input. 
 */
commandAfterRead: function(code)
{
    "</font>";
}
#endif /* USE_HTML_PROMPT */
