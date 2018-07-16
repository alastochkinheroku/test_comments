/* Copyright (c) 1989-2009 by Michael J. Roberts.  All Rights Reserved. */
/* Copyright (c) modifed 2002-2011 by Andrey P. Grankin.
   All Rights Reserved by license.

  				RusRelease 27

   Copyright (c) 1989-2009  Майкл Дж. Робертс. Все права оговорены.
   Copyright (c) изменения 2002, 2009 годов произведены Андреем П. Гранкиным.
   Перевод комментариев и лицензии произведен Стасом Старковым (2003 год).
   Все права оговорены лицензией.

  stdr.t -- русская модификация стандартных приключенческих определений
  Версия 2.5.14

  Этот файл является частью TADS: Системой Разработки Текстовых
  Приключенческих Игр. Информацию по использованию этого файла вы можете
  найти в файле "LICENSE.TAD" (файл должен быть частью поставки).

  Вы можете изменять и использовать этот файл любым образом, обеспечив
  то, что в случае, если вы будете распространять измененные копии этого
  файла в форме исходных текстов, эти копии должны содержать оригинальную
  запись об авторских правах (включая этот абзац), и должны быть отчетливо
  помечены, как измененные виды оригинальной версии.

  Этот файл предоставляет определения базовых объектов и функций,
  необходимых для RTADS, но не определенных в файле "advr.t".
  Определения в "stdr.t" применимы при написании игры, однако, когда
  игра будет близка к завершению, вы, возможно, обнаружите, что хотите
  изменить некоторые определения, данные в этом файле. Этот файл
  предназначен помочь вам начать как можно скорее, предоставляя основные,
  базовые определения для функций и объектов.

  Когда вы захотите изменить эти функции и объекты для своей игры,
  уберите включение файла "stdr.t", чтобы избежать дублирования
  определений. Вместо этого, включите свою измененную версию этого
  файла, имеющего название, отличное от "stdr.t" -- это позволит вам
  избежать путаницы.


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

/* распознать данный файл, как файл с нормальными операторами TADS */
/* parse with normal TADS operators */
#pragma C-

/*
 *   Предобъявим все функции, так что компилятор будет знать, что
 *   это функции. (Это действительно важно, только если функция будет
 *   вызываться как демон (daemon) или запал (fuse) до того, как она
 *   объявлена; впрочем, не повредит объявить все функции.
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
 *   Функция die() вызывается тогда, когда игрок умирает. Она сообщает
 *   игроку насколько он преуспел в игре (через его очки), и спрашивает
 *   хотел бы он начать игру заново (или выйти совсем).
 *   
 *   The die() function is called when the player dies.  It tells the
 *   player how well he has done (with his score), and asks if he'd
 *   like to start over (the alternative being quitting the game).
 */
die: function
{
    "\b*** ВЫ ПРОИГРАЛИ! ***\b";
    "\b*** Это просто ужасно ***\b";  // Поменяйте на более подходящее
    scoreRank();
    "\bВыберите: ВОССТАНОВИТЬ сохраненную игру, начать ЗАНОВО, ВЫХОД.\n Возможна ОТМЕНА последнего действия.\n";
    while (true)
    {
        local resp;

        "\nПожалуйста, введите ВОССТАНОВИТЬ, ЗАНОВО, ВЫХОД или ОТМЕНА: >";
        resp := upper(input());
        resp := loweru(resp);
        if ((resp='restore') or (resp='восстановить'))
        {
            resp := askfile('Файл для восстановления:',
                            ASKFILE_PROMPT_OPEN, FILE_TYPE_SAVE);
            if (resp = nil)
                "Загрузка не удалась. ";
            else if (restore(resp))
                "Загрузка не удалась. ";
            else
            {
                parserGetMe().location.lookAround(true);
                scoreStatus(global.score, global.turnsofar);
                abort;
            }
        }
        else if ((resp = 'restart') or (resp='заново'))
        {
            scoreStatus(0, 0);
            restart();
        }
        else if ((resp = 'exit') or (resp='выход'))
        {
            terminate();
            quit();
            abort;
        }
        else if ((resp = 'undo') or (resp='отмена'))
        {
            if (undo())
            {
                "(Отмена одной команды)\b";
                parserGetMe().location.lookAround(true);
                scoreStatus(global.score, global.turnsofar);
                abort;
            }
            else
                "К сожалению, отменить команду уже невозможно. ";
        }
    }
}

/*
 *   Функция scoreRank() отображает насколько игрок преуспел в игре.
 *   По умолчанию, функция не делает ничего, кроме отображения текущих
 *   и максимально возможных очков. Некоторым авторам игр нравится также
 *   отображать уровень, соответствующий различным достигнутым очкам
 *   ("Начинающий искатель приключений", "Эксперт" и т.д.); здесь --
 *   место сделать это, если необходимо.
 *   
 *   Заметьте, что переменная "global.maxscore" определяет максимальное
 *   количество очков, возможных набрать в игре; измените член "maxscore"
 *   объекта "global", если нужно.
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
 " В сумме за "; say(global.turnsofar);
    " ход<<numok(global.turnsofar, '','а','ов')>>, вы достигли счета в ";
    say(global.score); " единиц<<numok(global.score, 'у','ы','')>>";
    " из возможных ";
    say(global.maxscore);
    ".\n";
}

/*
 *   Функция commonInit() не является необходимой для RTADS; она -- просто
 *   вспомогательная функция, которую мы объявляем, чтобы мы смогли
 *   поместить весь инициализирующий код в одном месте. Эта функция 
 *   вызывается из init() и initRestore(). А, в связи с тем, что при старте
 *   система может вызвать только init() или initRestore(), но не обе,
 *   желательно иметь одну функцию, которую обе эти функции вызывают,
 *   чтобы один и тот же код был исполнен при старте вне зависимости от
 *   того, как мы начинаем игру.
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
    // поместите общий инициализирующий код здесь
    // put common initialization code here
    // снимите комментарий, чтобы включить HTML 
    "\H+"; 
}

/*
 *   Функция init() вызывается в самом начале игры. Она должна
 *   отобразить вступительный текст игры, запустить все необходимые
 *   демоны (daemon) и запалы (fuse), и переместить персонажа игрока
 *   (объект "Me") в первоначальную локацию, которая по умолчанию имеет
 *   название "startroom".
 *   
 *   The init() function is run at the very beginning of the game.
 *   It should display the introductory text for the game, start
 *   any needed daemons and fuses, and move the player's actor ("Me")
 *   to the initial room, which defaults here to "startroom".
 */
 
 // поместите вступительный текст сюда
 // put introductory text here
 introduction: function
 {
    "\tСюда можно вставить вступление. \b";
 }
 
init: function
{
#ifdef USE_HTML_STATUS
    /* 
     *   Мы используем HTML-стиль статусной строки -- будем уверены,
     *   что используется интерпретатор достаточно новой версии, чтобы
     *   поддерживать этот код. (Код статусной строки использует
     *   systemInfo, чтобы обнаружить, поддерживает ли интерпретатор
     *   HTML или нет -- HTML не работает правильно на версиях
     *   предшествующих 2.2.4.)
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
        "\b\b\(ВНИМАНИЕ! Эта игра требует интерпретатор TADS версии
        2.2.4 или выше. Похоже, что вы используете более старую версию
        интерпретатора. Вы можете попробовать запустить эту игру, однако,
        отображение игрового экрана может не работать правильно. Если
        вы испытываете какие либо трудности, вы можете попробовать
        перейти на более новую версию интерпретатора TADS.\)\b\b";
    }
#endif

    /* выполнение общей инициализации */
    /* perform common initializations */
    commonInit();
    
    introduction();

    version.sdesc;                // показ названия и версии игры

    setdaemon(turncount, nil);         // запуск демона (deamon) счетчика ходов
                                       //         start the turn counter daemon
    setdaemon(sleepDaemon, nil);                  // запуск демона (deamon) сна
                                                  //     start the sleep daemon
    setdaemon(eatDaemon, nil);                 // запуск демона (deamon) голода
                                               //       start the hunger daemon
   //switchPlayer(newPlayer);			// Меняем стандартного игрока на нового
    parserGetMe().location := startroom;     //  переместить игрока в начальную
                                             //                         локацию
                                             // move player to initial location
    startroom.lookAround(true);            // показать игроку, где он находится
                                           //           show player where he is
    startroom.isseen := true;             // отметить, что локация была увидена
                                          //      note that we've seen the room
    scoreStatus(0, 0);                    // инициализировать отображение очков
                                          //       initialize the score display
    randomize();			  // это, если нужны случайности в игре

}

/*
 *   Система вызывает функцию initRestore() автоматически при старте игры,
 *   если игрок указал сохраненную игру для восстановления в командной
 *   строке интерпретатора (или через другой механизм, зависящий от
 *   конкретного интерпретатора). Мы просто восстановим игру нормальным
 *   образом.
 *   
 *   initRestore() - the system calls this function automatically at game
 *   startup if the player specifies a saved game to restore on the
 *   run-time command line (or through another appropriate
 *   system-dependent mechanism).  We'll simply restore the game in the
 *   normal way.
 */
initRestore: function(fname)
{
    /* произвести общую инициализацию */
    /* perform common initializations */
    commonInit();

    /* сообщить игроку, что мы восстанавливаем игру */
    /* tell the player we're restoring a game */
    "\b[Возвращение к сохраненной позиции...]\b";

    /* и действительно восстановить игру нормальным образом */
    /* go restore the game in the normal way */
    mainRestore(fname);
}


/*
 *   preinit() вызывается после компиляции игры, но до того как она
 *   записывается в файл игры (.gam) в двоичной форме.  Она производит все
 *   инициализирующие действия, которые могут быть сделаны статически до
 *   записи игрового файла; это убыстряет загрузку игры т.к. вся работа
 *   была сделана заблаговременно.
 *   
 *   Эта функция заносит все объекты-фонари (lamp objects) (объекты,
 *   имеющие islamp = true) в список global.lamplist. Этот список
 *   проверяется, при выяснении содержит ли темная локация какие
 *   либо источники света.
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
 *   Функция terminate() вызывается как раз перед окончанием игры. Она
 *   обычно отображает прощальное сообщение. По умолчанию, она ничего
 *   не делает. Заметьте, что эта функция вызывается только тогда, когда
 *   игрок покидает игру, но НЕ после его смерти, не перед начинанием
 *   игры заново ли где-нибудь еще.
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
 *   Функция pardon() вызывается всякий раз, как игрок вводит пустую строку.
 *   Эта функция обычно просто выводит сообщение ("Говорите" или что либо
 *   подобное). По умолчанию она просто говорит "Вы что-то сказали?".
 *   
 *   The pardon() function is called any time the player enters a blank
 *   line.  The function generally just prints a message ("Speak up" or
 *   some such).  This default version just says "I beg your pardon?"
 */
pardon: function
{
    "Вы что-то сказали? ";
}

/*
 *   Функция sleepDaemon() -- демон (daemon), запущенный из init(),
 *   следит за тем, как много ходов прошло с тех пор, когда игрок последний
 *   раз спал. Если главный персонаж слишком долго не спал, функция
 *   предупредит несколько раз перед тем, как главный персонаж окончательно
 *   устанет, что приведет к его падению в обморок и сну. Единственное
 *   наказание, которое последует, если ГП (главный персонаж) потеряет
 *   сознание -- это то, что он бросит на землю все предметы, находящиеся
 *   в его владении. Некоторые игры могут принимать во внимание тот факт,
 *   что во время сна ГП пройдет несколько часов; например, счетчик
 *   времени нахождения ГП без еды может быть увеличен.
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
        "\b<<ZA(dToS(parserGetMe(),&sdesc))>> уже устал<<iao(parserGetMe())>>, надо найти место, где можно отдохнуть. ";
    else if (a = s + 25 or a = s + 30)
        "\b<<ZA(dToS(parserGetMe(),&ddesc))>> нужно поспать, иначе <<parserGetMe().sdesc>> упад<<glok(parserGetMe(),1,2)>> от истощения! ";
    else if (a >= s + 35)
    {
        global.awakeTime := 0;
        if (parserGetMe().location.isbed or parserGetMe().location.ischair)
        {
            "\b В голове у <<parserGetMe().vdesc>> неожиданно все померкло, и <<parserGetMe().sdesc>>, не в силах удержать себя на ногах, 
              упал<<iao(parserGetMe())>>.
              По счастью, <<parserGetMe().sdesc>> наход<<glok(parserGetMe(),2,2)>>ся << parserGetMe().location.statusPrep >> << parserGetMe().location.mdesc >>,
              поэтому <<parserGetMe().sdesc>> просто уш<<ella(parserGetMe())>> в глубокий бесчувственный сон.
              \b* * * * *
              \bНекоторое время спустя <<parserGetMe().sdesc>> проснул<<saas(parserGetMe())>>, чувствуя себя значительно лучше.\n ";
        }
        else
        {
            local itemRem, thisItem;
            
            "\b<<ZAG(parserGetMe(),&sdesc)>>, наконец, потерял<<iao(parserGetMe())>> силы бороться со сном, и без чувств упал<<iao(parserGetMe())>> на землю.
             \b* * * * *
             \bПроснувшись, <<parserGetMe().sdesc>> почувствовал<<iao(parserGetMe())>> себя ужасно.\n";
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
 *   Функция eatDeamon -- демон, запущенный из init(), следит за тем
 *   сколько ходов прошло с тех пор, как ГП последний раз что либо ел.
 *   Если ГП длительное время ничего не ел, функция несколько раз предупредит
 *   об этом игрока, перед тем как ГП умрет от истощения.
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
        "\bПора перекусить. ";
    else if (l = e + 15 or l = e + 20 or l = e + 25)
        "\b<<ZAG(parserGetMe(),&sdesc)>> чувству<<glok(parserGetMe(),1,1)>> терзающий голод -- необходимо поесть, чтобы не умереть с голоду. ";
    else if (l = e + 30 or l = e + 35)
        "\bГолод становится невыносимым. ";
    else if (l >= e + 40)
    {
        "\b<<ZAG(parserGetMe(),&sdesc)>> умер";
        if (parserGetMe().gender!=1) ella(parserGetMe());
        " от истощения. ";
        die();
    }
}

/*
 *   Объект numObj служит для передачи числа игре в случае, если игрок
 *   использует число в своей команде. Например, "повернуть шкалу
 *   на 621" приведет к тому, что член "value" косвенного объекта numObj
 *   будет содержать значение 621.
 *   
 *   The numObj object is used to convey a number to the game whenever
 *   the player uses a number in his command.  For example, "turn dial
 *   to 621" results in an indirect object of numObj, with its "value"
 *   property set to 621.
 */
numObj: basicNumObj  // используем объявление из advr.t по умолчанию
                     // use default definition from adv.t
;

/*
 *   strObj работает так же как и numObj, но для строк. Т.о. если
 *   ГП наберет "привет" на клавиатуре в игре, член "value" объекта strObj 
 *   будет содержать строку 'привет'.
 *   
 *   Заметим, что т.к. прямой объект строки используется при сохранении и
 *   восстановлении игры, а также в сценарных командах, этот объект должен
 *   обрабатывать эти команды. 
 *   
 *   strObj works like numObj, but for strings.  So, a player command of
 *   type "hello" on the keyboard will result in a direct object of strObj, 
 *   with its "value" property set to the string 'hello'.
 *
 *   Note that, because a string direct object is used in the save, restore,
 *   and script commands, this object must handle those commands.
 */
strObj: basicStrObj     // используем объявление из advr.t по умолчанию
                        // use default definition from adv.t
;

/*
 *   
 *   Объект "global" -- служит для хранения всех элементов данных, которые
 *   не подходят ни к каким другим объектам. Члены этого объекта, которые
 *   особенно важны для объектов и функций, объявлены здесь; если вы
 *   замените этот объект, но сохраните неизменными остальные части этого
 *   файла, обязательно вставьте в него все члены, объявленные здесь.
 *   
 *   Заметим, что awakeTime установлен на ноль; если вы хотите, чтобы
 *   ГП начинал игру уставшим, повысьте значение этой переменной
 *   ближе к значению sleepTime (которое указывает интервал между
 *   периодами сна). Та же самая ситуация и со значением lastMealTime:
 *   увеличьте значение этой переменной ближе к значению eatTime, если вы
 *   хотите, чтобы ГП начинал игру голодным. Для каждой из этих
 *   переменных, игрок начнет получать предупреждения, когда затраченное
 *   время (awakeTime, lastMealTime) достигнет интервала 
 *   (sleepTime, eatTime); однако, ГП не обязан немедленно съесть что либо
 *   или заснуть -- до тех пор пока не будут сделаны несколько предупреждений.
 *   Более конкретные детали смотрите в функциях eatDaemon и sleepDaemon.
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
    turnsofar = 0                        // пока не было сделано ни одного хода
                                         //     no turns have transpired so far
    score = 0                         // пока не было заработано ни одного очка
                                      //    no points have been accumulated yet
    maxscore = 100                    // максимально возможное количество очков
                                      //                 maximum possible score
    verbose = nil                     // в настоящий момент мы в КРАТКОМ режиме
                                      //         we are currently in TERSE mode
    awakeTime = 0               //  время, истекшее с момента последнего сна ГП
                                // time that has elapsed since the player slept
    sleepTime = 400     //     интервал между периодами сна (максимальное время
                        //                                       бодрствования)
                        // interval between sleeping times (longest time awake)
    lastMealTime = 0              //      время, прошедшее с момента последнего
                                  //                             приема пищи ГП
                                  // time that has elapsed since the player ate
    eatTime = 200         //  интервал между приемами пищи (максимальное время,
                          //               которое ГП может обходиться без еды)
                          // interval between meals (longest time without food)
    lamplist = []              // список всех известных источников света в игре
                               // list of all known light providers in the game
    vinpadcont = 1	 //Индикатор, выводить инвентарь в винит. или им. падеже

    glpad=0                 // Флаг, указывающий на поддержку текущим глаголом
                            // определённого падежа
    displayLinks = true  //Индикатор, выводить гиперссылки по умолчанию, или нет
;

/*
 *   Объект "version" через свой член "sdesc" определяет имя и версию
 *   игры. Измените его на соответствующее название вашей игры.
 *   
 *   The "version" object defines, via its "sdesc" property, the name and
 *   version number of the game.  Change this to a suitable name for your
 *   game.
 */
version: object
    sdesc = {
            "<b>Моя игра</b>\n Просто новая игра. Наберите ПОМОЩЬ при необходимости. \n
             Написал Я. \n Версия 0.0\b \b";
            } 
;

/*
 *   Объект "Me" (написано латинскими буквами) -- это начальное действующее
 *   лицо игрока; синтаксический анализатор (парсер) автоматически использует
 *   в начале игры объект, имеющий имя "Me", как объект, представляющий ГП.
 *   Мы просто создадим персонажа "по умолчанию", наследующего все свойства
 *   от основного объекта (класса) ГП -- basicMe -- объявленного в "advr.t".
 *   
 *   Заметьте, что вы можете заменить объект главного персонажа (ГП) в
 *   любое время игры, вызвав функцию parserSetMe(newMe), где newMe является
 *   новым объектом, будущим представлять ГП в игре. Также, вы можете
 *   создать дополнительный объект, представляющий главного персонажа, если
 *   вы хотите позволить игроку взять на себя роль нескольких различных
 *   персонажей в ходе игры; вы можете сделать это, создав объект, 
 *   наследующий от basicMe. (Впрочем, наследование от basicMe не
 *   требуется от объекта, представляющего ГП, -- вы можете создать свой
 *   собственный объект ГП с "чистого листа", однако, гораздо проще
 *   наследовать от basicMe т.к этот класс уже содержит большое количество
 *   кода, который просто необходим для нормального "существования" ГП в игре.
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
isHim = true       //По умолчанию герой мужского пола.
// Раскройте комментарий после этой строки, если хотите обращения на "Вы".
/*sdesc="Вы"    
  rdesc="Вас"
  ddesc="вам"
  vdesc="Вас"
  tdesc="вами"
  pdesc="Вас"
  isThem=true
  fmtYou="Вы"
  fmtToYou="Вам"
  fmtYour="ваш"
  fmtYours="ваши"
  fmtYouve="Ваc"
  fmtWho="Вы"
  fmtMe="Вас"  
*/
;

/*
 *   Функция darkTravel() вызывается всякий раз, как игрок пытается
 *   переместиться из одной темной локации в другую темную локацию. По
 *   умолчанию, функция просто сообщает "Пошарив во тьме, ты так и не
 *   нашел дороги.", но она также может произвести более фатальные для ГП
 *   действия: например, убить ГП.
 *   
 *   darkTravel() is called whenever the player attempts to move from a dark
 *   location into another dark location.  By default, it just says "You
 *   stumble around in the dark," but it could certainly cast the player into
 *   the jaws of a grue, whatever that is...
 */
darkTravel: function
{
    "Пошарив во тьме, <<parserGetMe().sdesc>> так и не
 наш<<ella(parserGetMe())>> дороги. ";
}

goToSleep: function
{
    "***\b<<parserGetMe().sdesc>> проснул<<saas(parserGetMe())>>
  некоторое время спустя, ощущая себя свежо и бодро. ";
    global.awakeTime := 0;
}


#ifdef USE_HTML_PROMPT
/*
 *   Функция commandPrompt отображает командную строку. Для игр, имеющих
 *   поддержку HTML, мы переключаемся на специальный шрифт TADS-Input,
 *   что позволяет игроку выбирать шрифт для командной строки, используя
 *   средства интерпретатора игр TADS.
 *   
 *   commandPrompt - this displays the command prompt.  For HTML games, we
 *   switch to the special TADS-Input font, which lets the player choose
 *   the font for command input through the preferences dialog.
 */
commandPrompt: function(code)
{
    "<font face='TADS-Input'>";
    // Снимите следующий комментарий, чтобы появлялся вопрос для начинающих.
    /*
    if (global.prompt_count = nil) global.prompt_count := 0; 		
    global.prompt_count++;						
    if (global.prompt_count < 5)					
	"\nЧто теперь <<parserGetMe().ddesc>> делать?\b";		
    else if (global.prompt_count = 5)					
	"\nБольше вечный вопрос \"Что делать?\" докучать не будет.\n	
         Теперь готовность программы к приему новой команды будет означать появление значка \">\".\b";
    */
    "\b&gt;";
}


/*
 *   Функция commandAfterRead вызывается как раз после того, как какая либо
 *   команда введена. Для игр, имеющих поддержку HTML, мы просто переключаемся
 *   назад на тот шрифт, который был установлен перед тем, как мы установили
 *   новый шрифт для командной строки (TADS-Input) в функции commandPrompt.
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
