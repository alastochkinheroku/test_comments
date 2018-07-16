/* Copyright (c) 2002-2011 by ������� ������ �.  All Rights Reserved. 
*                            Release 27			
*/

/*
 �������� disamvdesc ������������ ����� ����������� ����� �������,
 ������������ � ������ ����������� �������. ����� ������ �����,
 ����� �� �� ������ ���������� �������������� � ������� ��������.
 ������:

 >���
 �� �����:
 ����
 >����� ����
 ������� ���� �� ������ � ����: ���� ��� ������� ����?
 >����
 ������� ���� �� ������ � ����: ���� ��� ������� ����?
 � �.�. �.�. ����� �� ������� ���� �� ������.

 ��������� ����� vdesc="������� ����"
 >���
 �� �����:
 ������� ����
 >����� ����
 ������� ���� �� ������ � ����: ������� ���� ��� ������� ����?
 ��, ��� ����� "�������" ����� ������, ����� ���� ����� ���������.
 
 ����� ���������� ����� disamvdesc="������� ����":
 >���
 �� �����:
 ����
 >����� ����
 ������� ���� �� ������ � ����: ������� ���� ��� ������� ����?

*/ 
modify thing
disamvdesc=self.vdesc
;

/* ��� ��, ��� ����� �������� � ���������, ����� ������ ��� ������������, ��� ������ */
parseDefault: function(obj, prp)
  {
    "(";
    if (prp = nil) obj.vdesc; else
     {if (!(prp=toPrep && obj.isactor)) {prp.sdesc;" ";} }
    if (prp = atPrep or prp = inPrep) obj.vdesc;
    if (prp = withPrep) obj.rdesc;
    if (prp = overPrep) obj.tdesc;
    if (prp = onPrep) obj.mdesc;
    if (prp = offPrep or prp = fromPrep or prp = outPrep) obj.rdesc;
    if (prp = toPrep) obj.ddesc;
    ")\n";
  }

/* ��������� parseDefault, �� �������� ������ � TADS >= 2.5.8 */
parseDefaultExt: function(actor, verb, obj, prp)
  {
    "(";
    if (prp = nil) 
      {
       if (verb.parsdef) obj.(verb.parsdef);
       else obj.vdesc;
      } 
    else
     {
    if (!(prp=toPrep && obj.isactor)) {prp.sdesc;" ";} }
    if (prp = atPrep or prp = inPrep) obj.vdesc;
    if (prp = withPrep) obj.rdesc;
    if (prp = overPrep) obj.tdesc;
    if (prp = onPrep) obj.mdesc;
    if (prp = offPrep or prp = fromPrep or prp = outPrep) obj.rdesc;
    if (prp = toPrep) obj.ddesc;
    if (prp = uPrep) obj.rdesc;
    ")\n";
  }

/* ��� ������: �������(���, ��, ��, ��) ... �� ������ � ����: ... ? */
parseDisambig: function(str, lst, ...)      //������ 100-104 ����� ������
{
   local i, tot, cnt, tempstr, ret;
   "����� �� ������ ";

   // �������� "of"
   ret:=reSearch(' of ',str);
   if (ret) { str:=substr(str,1,ret[1])+' '+substr(str,ret[1]+4,length(str)); }

   " \"<< str >>\", �� ����� � ����: ";
   for (i := 1, cnt := length(lst) ; i <= cnt ; ++i)
   {
      if (dToS(lst[i],&vdesc)!=str) lst[i].vdesc; else lst[i].disamvdesc;
      if (i < cnt - 1) ", ";
      if (i + 1 = cnt) " ��� ";
   }
   "?";
}

/* ��������� � ���, ��� ������ �� ����� ��� ���������� ����� ����� */
parseError2:  function(v, d, p, i)      //������ 110-115 ����� ������
{
    "� �� ���� ��� << v.sdesc >> "; 
    if (v.pred && v.pred!=toPrep) // �� ���� ��� ����/��������/������ *�* ����-�� ���-��
        {v.pred.sdesc;" ";}
      if (d)
      {
      	if (v.pred!=nil)
       	{
		if  (v.pred=withPrep or v.pred=toPrep or v.pred=goonPrep) d.ddesc; 
		else  {d.vdesc;". ";} 
	}
      	else {d.vdesc; ". ";}
      }
      else
    {
         " ���-���� ";
         if (p) 
         {
             if (dToS(p,&sdesc)!='�') {p.sdesc;" ";}	//�����?
             if (p=toPrep or p=goonPrep) i.ddesc; else
             if (p=onPrep || p=inPrep) i.vdesc; else
             if (p=withPrep) i.rdesc; else
             if (p=aboutPrep) {"����";}
             else i.rdesc;
         }  
         else {"� "; i.ddesc;};
          ".";
    }
}

parseAskobjActor: function(a, v, ...)
{
    if (argcount = 3)
    {
       if (getarg(3)=aboutPrep) "�"; else               // � ���
       if (getarg(3)!=toPrep or v.padezh_type !=2) ZAG(getarg(3),&sdesc);
       
       if (getarg(3)=onPrep or getarg(3)=thruPrep or getarg(3)=inPrep or getarg(3)=atPrep) 
       {
         if (getarg(3)=inPrep) "�";     //�(�) ���
         " ��� ";
       }
       else  if ((getarg(3)=underPrep) or (getarg(3)=behindPrep) or (getarg(3)=overPrep)
             or (getarg(3)=betweenPrep) or (getarg(3)=aboutPrep)) " ��� ";
       else  if (getarg(3)=goonPrep) " ���� ";
       else if (getarg(3)=toPrep)
         {
          if (v.padezh_type =2) "���� ";
           else " ���� ";
         }
        else if (v=askforVerb) " ���� ";
       else " ���� ";
        
       if (a <> parserGetMe() or a.lico=3)
        {
         a.sdesc;" ";"����<<ok(a,'��','��','��','��')>> ";
        }
        else "�� ������ ";
        v.sdesc;" ";
        if (getarg(3)!=aboutPrep)
        {
         if (v.pred) v.pred.sdesc;
         " ���?";
        }
        else (v=tellVerb)?"����� ���������?":"����� ���������?";
     }
     else
     {
        ZAG(v,&vopr);
        if (a <> parserGetMe() || a.lico=3 || a.lico=1) 
         {
          a.sdesc;" ";"����<<ok(a,'��','��','��','��')>> ";
         }
         else "<<parserGetMe().sdesc>> <<glok(parserGetMe(),'������')>> "; 
        "<<v.sdesc>>?";
    }
}

parseError: function(errnum, str)
  {
    // if there's an allMessage waiting, use it instead of the default
    if (global.allMessage <> nil)
        {
        local r;
        r := global.allMessage;
        global.allMessage := nil;
        return r;
        }
    else
    switch (errnum)
    {
    case 1: return '� �� ������� ����� ����������: "%c".'; break;
    case 2: return '� ���������, ����� "%s" ��� ����������.'; break;
    case 3: return '����� "%s" ��������� � ������� �������� ����� ��������.'; break;
    case 4: return '� �����, �� ���������� �������� ����� ���������������� �����������.';  break;
    case 5: return '� �����, �� ���������� �������� ����������� ����� "���".'; break;
    case 6: return '� ������ ��������������� ����� ��������, ��������� ��������� ��������.'; break;
    case 7: return '������ �����7. ��� ��� ������, �������� ��� ��� ��������!';break;
    case 9: return '� �� ���� ����� ������ "%s".'; break;
    case 10: return '�� ���������� �� ������� ������� ���������� �������� ������ "%s".';break;
    case 11: return '�� ���������� �� ������� ������� ���������� ��������.'; break;
    case 12: return '�� ������ �������� ������ � ����� �������� ������������.';break;
    case 13: return '� �� ���� �� ��� �� ���������� ������ "%s".';  break;
    case 14: return '� �� ���� �� ��� �� ����������.';  break;
    case 15: return '� �� ���� ��, �� ��� �� ����������.'; break;
    case 16: return '� �� ���� ����� �����.'; break;
    case 17: return '� ���� ����������� ��� �������!';   break;
    case 18: return '� �� ������� ��� �����������.';  break;
    case 19: return //'����� ����� ������� �� ������� �����.'; break;
    '� ����� ����� ������� ���� �����, ������� � �� ���� ������������.'; break;
    case 20: return '�� ���� ��� ������������ ����� "%s" ����� �������.'; break;
    case 21: return '����� ����� ������� ���� ������ �����.';  break;
    case 22: return '������, ����� ����� ������� ���� ������ �����.';  break;
    case 24: return '� �� ������� ��� �����������.';  break;
    case 25: return '������ ������������ ����� ��������� ��������.';  break;
    case 26: return '��� ������� ��� ����������.';  break;
    case 27: return '��� ������� ������ ���������.'; break;
    case 28: return '��� ������� ������ ��������� � ��������� ��������.';break;
    case 29: return '� �����, �� ���������� �������� ����������� ����� "�����".'; break;
    case 30: return '� ���� ������ %d �� ���.';   break;
    case 31: return '� ���� ������ �������������.';   break;
    case 38: return '����� ������ ����� �� �����.'; break;
    case 39: return '����� ����� �� �����.';   break;
    case 160: return '��� �������� ��������� ������� ����� "%s" �� ������ � ����.';   break;
    default:  return nil;
    }
  }