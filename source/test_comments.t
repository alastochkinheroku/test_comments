#define USE_HTML_STATUS
#define USE_HTML_PROMPT

//��������� �����������
#define GENERATOR_INCLUDED
#include <advr.t>
#include <stdr.t>
#include <errorru.t>
#include <extendr.t>
#include <generator.t>

#include <math.t>
#include <lex.t>
#include <battle_comment.t>
#pragma C++

replace commonInit: function
{
  "\H+";
   "������� ����� ��� ���������� ����������� �������� � ����� �����������, �� ��������� �� ����������� ���� �������. (����� �������� ���, ���� ������� \"�����������\")";
}

//�������� �����������, �� ������ ������/���, �� ����� ���������� ���������
//������: if (prob(50)){...}
prob : function(proc)
{
   return (rand(100/proc)==1);
}

//����
zond: basicMe
   desc = '����/��'
   noun = '����/��'
   isHim = true
   lico=3
   fmtYou="����"
   fmtToYou='�����'
   fmtYour='�����'
   fmtYours='�����'
   fmtYouve='�����'
   fmtWho='����'
   fmtMe='����' 
   validActor = true
;

//���
kit: basicMe
  lico=3
  desc = '���/��'
  noun = '���/��'
  //adjective = '�������/1��' '������/1��'
  ldesc="��� ����� ������������, ��������� ������������ �� ���� �����."
  isHim = true
  fmtYou="���"
  fmtToYou='����'
  fmtYour='����'
  fmtYours='����'
  fmtYouve='����'
  fmtWho='���'
  fmtMe='����'
  validActor = true  
  
  //����� ������� ����
  sayHitTo(who) = {
	  globalTemplates.mon = who;
	  globalTemplates.tar = self;
	  //������ ��������� ���� ����� ����������
	  if (prob(33)) kitBeforeActTemplates.print;
	  //������ ���������
	  kitShootTemplate.mon = who;
	  kitShootTemplate.print;
  }
  
  //������� �� �������
  sayWhenHit = {
      kitWhenHitTemplate.print;
  }
;


//�������� �������� ������
levelLitDesc: lexicon
    use_templ = nil
	phrases = [
	  '������� ���������� ����� ��������. '
	  '����������� ��� ���� ������� ����� �� �������� ��������� ����.'
	  '��������� ����� �������� �� ������ ������� ����������� ��������� ������-��������.'
	  '����� ����� �����, ������ ������ ������� ������� ������������ ��� ������.'
	]
;

Monster : Actor
   //������ ����� �� ���������. mon - ������(����������), tar - ��������(������)
   
   //����� ������� ����
   sayHitTo(who) = {
	  if (!isclass(who,basicMe))
	  {
		 //������ ���������
		 bykHitTemplatesMonster.mon = self;
		 bykHitTemplatesMonster.tar = who;
		 bykHitTemplatesMonster.print;
	  }
	  else
	  {
		 bykBeforeActTemplates.mon = self;
		 //������ ��������� ���� ����� ����������
		 if (prob(30)) bykBeforeActTemplates.print;
		 //������ ���������
		 bykHitTemplatesPerson.mon = self;
		 bykHitTemplatesPerson.tar = who;
		 bykHitTemplatesPerson.print;
		 //������� �� �������
		 if (prob(30)) who.sayWhenHit;
	  }
   }
   sayDead = {
	  bykDieLexicon.mon = self;
	  bykDieLexicon.print;
   }
;

//�������
monster1Level1 : Monster
   desc = '������/1�� ���/1��'
   noun = '���/1��' '������/��'
   adjective = '������/1��' '�����������/1��' '����������/1��'
   ldesc="���-������ �������� ������� �������, ���� ��� ������ ���� ����� ���������."
   isHim = true
;

monster2Level1 : Monster
   desc = '�������/1�� ���/1��'
   noun = '���/1��' '������/��'
   adjective = '�������/1��' '�����������/1��' '��������/1��' '��������/1��'
   ldesc="������� � ������� ���-������."
   isHim = true
;

monster3Level1 : Monster
   desc = '�����/1�� ���/1��'
   noun = '���/1��' '������/��'
   adjective = '�����/1��' '���������/1��' '��������/1��'
   ldesc="���-������ ����� � ��������."
   isHim = true
;

monsterFrLevel1 : Monster
   desc = '������/1�� ���/1��'
   noun = '���/1��' '������/��'
   adjective = '������/1��' '����������/1��' '�������/1��'
   ldesc="���-������ ���� � ����, �� ������."
   isHim = true
;

startroom: room
   sdesc="������ ������� ����� �����"
   ldesc = {
      //������� �������:
      //�������       ������
	  //�������       ���
	  //�����         ����
	
       //�������� ������� � ������ ���� �����
      if (prob(20)) levelLitDesc.print;
      
      //�������
	  monster1Level1.sayHitTo(monsterFrLevel1); "<br>";
	  monsterFrLevel1.sayDead; "<br>";
	  kit.sayHitTo(monster2Level1); "<br>";
	  monster2Level1.sayDead; "<br>";
	  monster3Level1.sayHitTo(kit); "<br>";
   }
;