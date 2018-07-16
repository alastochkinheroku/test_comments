/*  EXTENDR.T - An Extension Set for TADS Russificated
*   �������������� ���������� �� ����� ������� (Neil deMause)
*   
*   � 25 ������ ���� ��������� ��� ��������� ���������� 
*   ���������, �������������� �� ������������� � ��������,
*   ��������� �������� ������� � �� �������� ������������
*   
*   �������� ����� �� �����:
*   ����������� � �����, ������� isinside, movefromto;
*   ������ ������������� "��" ��� ���� ������ �����
*   �����, �������, �������� (� ������ ����� ������� 
*   � errorru.t). 
*   ��� �������� (�������, ������������ �, ������,
*   ����������) - �������� � advr.t. 
*   ������: ��������� ������ ���������� (������, �����, 
*   ����������), unlisteditem (�� ������������ ��� 
*   ��������� ������� �� ���� ��� ��� ����, �������)  
*/

replace incscore: function( amount )
{
	global.score := global.score + amount;
	scoreStatus( global.score, global.turnsofar );
	global.addthis:=amount;
	if (global.incscorenotified) notify(global,&tellscore,1);
}

notifyVerb:deepverb
	sdesc="�����������"
	action(actor)=
	{
	if (not global.incscorenotified) 
		{
		"����������� �� ��������� ����� ��������. ";
		global.incscorenotified:=true;
		}
	else 
		{
		"����������� �� ��������� ����� ���������. ";
		global.incscorenotified:=nil;
		}
	}
	verb='notify'
;

modify global 
	tellscore={"\b***�� �������� <<self.addthis>> ���";
                switch (self.addthis)
                { case 1: "�"; break; case 2: {}; case 3: {}; case 4: "�"; break;  default: "��";}
                  " .***\n";}
;

/*	ISINSIDE - Search an object's entire contents hierarchy
*
*	������� ���������� ���������� �� ������ � ������,
*       ���� ���� �� ������ ����� �������. ���������� ����
*       �� ���������� ������� � ������ ������� ����������.
*
*       ������ �������:
*	if (isinside(gun,Me)) alarm.ring;
*
*	isinside() ���������� true ���� ������� ���-���� ������,  
*	� nil � ������ �������.
*/
isinside: function(item,loc)
{
	if (item.location=loc) return(true);
	else if (item.location) return(isinside(item.location,loc)); 
	else return(nil);
}


/*	MOVEFROMTO - �������� �����������
*
*	������������� ��� ����� �� ������� � ������
*/
moveFromTo: function (from, to)
{
	local l, i;
	l := from.contents;
	for (i := 1; i <= length(l); ++i)
		{
		if (!l[i].isfixed)
                  l[i].moveInto(to);  
		}
}

/*	������ �� "���"
*
*	Another one that isn't my doing, though I've 
*	unfortunately forgotten who on rec.arts.int-fiction 
*	provided this code, long ago. I've changed the 
*	defaults for take, drop, and put to allow the use of 
*	"all" (which seems logical); adding "allowall=true" 
*	to other verbs will let you use "all" with them as well.
*/

modify deepverb
doDefault (actor, prep, iobj) =
{
 if (self.allowall=nil)
 {
 if (objwords(1) = ['A'])
   {
   global.allMessage := '�� �� ������ ������������ ����� "���" � ���� ��������. ';
   return [];
   }
  pass doDefault;
  }
 else pass doDefault;
}
;


modify takeVerb
allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := '�� �� ������ ������������ ����� "���" � ���� ��������. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;

modify dropVerb
	allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := '�� �� ������ ������������ ����� "���" � ���� ��������. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;

modify putVerb
	allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := '�� �� ������ ������������ ����� "���" � ���� ��������. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;				

//  "����������" ����������� ��� ���������� ���������� ������������
emptyVerb:deepverb
	verb='����������' '����������' '�������' '�������' '����������'
	     '��������' '��������' '������' '������' '��������'
	sdesc="����������"
	doAction='Empty'
;

modify container
	verDoEmpty(actor)={if (self.isfixed) "<<ZAG(self,&vdesc)>> �� ������� ��������. ";}
	doEmpty(actor)=
	{
	if (not self.isopen) "<<ZAG(self,&sdesc)>> ������<<yao(self)>>. ";
	else 
		{
		"<<ZAG(actor,&sdesc)>> ���������<<iao(actor)>> <<self.vdesc>> �� �����. ";
		moveFromTo (self, parserGetMe.location);
		}
	}
;

/*	UNLISTEDITEM - �� �����������, �� �� ����� � ������ �����
*
*    ������ ����� ��������, ������� �� ������������� � ������
*    �������������� � �������, ���� ����� �� �� �������.
*    ����� ����� ��� ����� ���� �� ����� ������. 
*    �� �������� �������� �������� �������! 
*
*/
class unlisteditem:item
	isListed=nil
	doTake(actor)={self.isListed:=true; pass doTake;}
;

/*	����������� - ����������� ����� ��� �������, ������ � �.�.
*/
class intangible:fixeditem
	verDoTake(actor)={"��� ���������� �����. ";}
	verDoTakeWith(actor,io)={"��� ���������� �����. ";}
	verDoMove(actor)={"��� ���������� �������. ";}
	touchdesc="��� ���������� ������� ������. "
	verDoTouchWith(actor,io)={"��� ���������� ��������. ";}
	ldesc="��� ��������. "
	verDoLookbehind(actor)="��� ��������. "
	verDoAttack(actor)={"��� ���������� ����������. ";}
	verDoAttackWith(actor,io)={"��� ���������� ����������. ";}
	verIoPutOn(actor)={"�� ��� ������ �������� ���-����. ";}
;


// ���������� �� Firton'�. 
// ��������� ������ ��� ����������� �������� �������� "�����" � "�������".

modify room
    replace roomDrop(obj) =
    {
        obj.dropdesc;
        obj.moveInto(self);
    }
;

modify thing
    takedesc = { "����"; yao(self); ". \n"; }
    dropdesc = { "������"; yao(self); ". \n"; }
    replace doTake(actor) =
    {
        local totbulk, totweight;

        totbulk := addbulk(actor.contents) + self.bulk;
        totweight := addweight(actor.contents);
        if (not actor.isCarrying(self))
            totweight := totweight + self.weight + addweight(self.contents);

        if (totweight > actor.maxweight)
            "<<ZAG(actor,&fmtYour)>> ���� ������� ����. ";
        else if (totbulk > actor.maxbulk)
            "<<ZAG(parserGetMe(),&sdesc)>> ��� �� <<glok(actor,1,1,'���')>> �������� ������� ���������. ";
        else
        {
            self.takedesc;
            self.moveInto(actor);
        }
    }
;

/* ������������ ����� ������� ���, ����� � �������� ���������� ������ �������.
 * ����� ���������� ��� ���� ������ � ����. ������ ���� ������� HTML  
 * by GrAnd
*/
#ifdef USE_HTML_STATUS
modify room
dispBeginSdesc = "<b>"
dispEndSdesc = "</b>"
;
#endif

// �������� ���������� ������� "������". ��������: "*��������*, ������"
// ���������� �������� ��������� � �������� ���������� � ������
// ���-��:  ������ ����-�� with ���-�� 
extHelpVerb: deepverb
	verb = '������' '������'
	sdesc = "������" 
	action(actor)= { execCommand(actor,HelpVerb);}
        doAction = 'Help'
        pred=toPrep    
;