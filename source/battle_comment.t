// ������� ��������� ������������ ��� ����
// Anton Lastochkin 2017

//������ �������������:
//"<<ZAG_NOUN(pl,PADEZ_IM)>> ��������<<yao(pl)>> ������� � <<SAY_NOUN(tar,PADEZ_RO)>>.";
//������� ������� �� ����������:
//yao(thing) - �������, ������� ��������� ������� ��������� ������� ���������� �������������� ���� (������(�, �, �) )

#pragma C++

#define PADEZ_IM 1 //������������
#define PADEZ_RO 2 //�����������
#define PADEZ_DA 3 //���������
#define PADEZ_VI 4 //�����������
#define PADEZ_TV 5 //������������


globalTemplates : object
   mon = nil
   tar = nil
;

#define B_USE_ZAG   0
#define B_USE_SMALL 1
#define B_HESHE     2
#define B_HER       3

//������ ����� �� �������
GET_TEMPLATE:function(str)
{
   //������� ��� ��������� ���������� ��������
   //|�������� � ������ | ������ | ����� | ��������� ��� ��� |
   local t_table = [
	  ['(zmon_im)' globalTemplates.mon PADEZ_IM B_USE_ZAG  ]
	  ['(mon_im)'  globalTemplates.mon PADEZ_IM  B_USE_SMALL]
	  ['(zmon_ro)' globalTemplates.mon PADEZ_RO B_USE_ZAG  ]
	  ['(mon_ro)'  globalTemplates.mon PADEZ_RO  B_USE_SMALL]
	  ['(zmon_da)' globalTemplates.mon PADEZ_DA B_USE_ZAG  ]
	  ['(mon_da)'  globalTemplates.mon PADEZ_DA  B_USE_SMALL]
	  ['(zmon_vi)' globalTemplates.mon PADEZ_VI B_USE_ZAG  ]
	  ['(mon_vi)'  globalTemplates.mon PADEZ_VI  B_USE_SMALL]
	  ['(zmon_tv)' globalTemplates.mon PADEZ_TV B_USE_ZAG  ]
	  ['(mon_tv)'  globalTemplates.mon PADEZ_TV  B_USE_SMALL]
	  
	  ['(ztar_im)' globalTemplates.tar PADEZ_IM  B_USE_ZAG  ]
	  ['(tar_im)'  globalTemplates.tar PADEZ_IM   B_USE_SMALL]
	  ['(ztar_ro)' globalTemplates.tar PADEZ_RO  B_USE_ZAG  ]
	  ['(tar_ro)'  globalTemplates.tar PADEZ_RO  B_USE_SMALL]
	  ['(ztar_da)' globalTemplates.tar PADEZ_DA  B_USE_ZAG  ]
	  ['(tar_da)'  globalTemplates.tar PADEZ_DA   B_USE_SMALL]
	  ['(ztar_vi)' globalTemplates.tar PADEZ_VI  B_USE_ZAG  ]
	  ['(tar_vi)'  globalTemplates.tar PADEZ_VI  B_USE_SMALL]
	  ['(ztar_tv)' globalTemplates.tar PADEZ_TV  B_USE_ZAG  ]
	  ['(tar_tv)'  globalTemplates.tar PADEZ_TV  B_USE_SMALL]
	  
	  ['(mon_him)'  globalTemplates.mon 0  B_HER]
	  ['(tar_him)'  globalTemplates.tar 0  B_HER]
	  ['(mon_he)'  globalTemplates.mon 0  B_HESHE]
	  ['(tar_he)'  globalTemplates.tar 0  B_HESHE]
   ];
   local l_table = length(t_table);
   local ret;
   local new_str = str;
   local t_st_pos, t_len;
   local grp;
   local i;
   local str_template;
   local sel_obj;
   local padez;
   local use_z;
   local templ_part;

   for (i=1;i<=l_table;i++)
   {
	  str_template = t_table[i][1];
	  ret = reSearch(str_template, new_str);
	  if (ret != nil) {
		 grp = reGetGroup(1);
		 if (grp != nil)
		 {
			t_st_pos = grp[1];
			t_len = grp[2];
			sel_obj = t_table[i][2];
			padez = t_table[i][3];
			use_z = t_table[i][4];
			templ_part = '';
			switch(use_z){
			   case B_USE_ZAG: templ_part=ZAG_FULL(sel_obj,padez); break;
			   case B_USE_SMALL: templ_part=SAY_FULL(sel_obj,padez); break;
			   case B_HER: 
			   if (sel_obj.isHim==true) templ_part='���';
			   else templ_part='�';
			   break;
			   case B_HESHE: 
			   if (sel_obj.isHim==true) templ_part='��';
			   else templ_part='���';
			   break;
			}
			
			new_str = substr(new_str, 1, t_st_pos-1) + templ_part + substr(new_str, t_st_pos+t_len,length(new_str));
		 }
	  }
   }
   return new_str; 
}

//����������� ��� ����������� - ����� �� � ������� �����
//������� ��� ������ ������� � ����������� �� ������
SAY_PART_PADEZ:function(obj, padez, part)
{
  local i, st_w, end_w, sel_word;
  local words;
  local out_words = [];
  if ( isclass(obj,basicMe) && (part==&noun) )
  {
    if (padez==PADEZ_IM) return dToS(obj,&sdesc);
    else if (padez==PADEZ_RO) return dToS(obj,&rdesc);
    else if (padez==PADEZ_DA) return dToS(obj,&ddesc);
    else if (padez==PADEZ_VI) return dToS(obj,&vdesc);
    else if (padez==PADEZ_TV) return dToS(obj,&tdesc);
    else return '';
  }
  words = getwords(obj, part);
  for (i=1;i<=length(words);i++)
  {
     end_w = substr(words[i],length(words[i])-1,2);
	 st_w = substr(words[i],1,length(words[i])-2);
	 if ((padez==PADEZ_IM)&&(end_w == '#i')) out_words += [st_w];
	 else if ((padez==PADEZ_RO)&&(end_w == '#r')) out_words += [st_w];
	 else if ((padez==PADEZ_DA)&&(end_w == '#d')) out_words += [st_w];
	 else if ((padez==PADEZ_VI)&&(end_w == '#v')) out_words += [st_w];
	 else if ((padez==PADEZ_TV)&&(end_w == '#t')) out_words += [st_w];
  }
  if (length(out_words)==0) return '';
  else if (length(out_words)==1) return out_words[1];
  sel_word = out_words[rand(length(out_words))];
  return sel_word;
}

//������� ��������� � ������ ������� ���������
ZA_RET: function( str )	
{
   local ret;
   local out_str;
   local alph='��������������������������������';
   local ALPH='�����Ũ��������������������������';
   ret = reSearch(substr(str,1,1), alph);
   if (ret!=nil) {
	  out_str = substr(ALPH,ret[1],1) + substr(str,2,length(str));
   }
   else out_str = str;
   return out_str;
}

//������ ���������������� ������� � ����������� �� ������
SAY_NOUN:function(obj, padez)
{
  if (obj.sobst_noun!=nil) return ZA(SAY_PART_PADEZ(obj,padez,&noun));
  return SAY_PART_PADEZ(obj,padez,&noun);
}

//������ ���������������� ������� � ����������� �� ������ � ������� �����
ZAG_NOUN: function(obj, padez)
{
  return ZA_RET(SAY_PART_PADEZ(obj,padez,&noun));
}

//������ �������������� ������� � ����������� �� ������
SAY_ADJECTIVE:function(obj, padez)
{
  if (obj.sobst_adjective!=nil) return ZA(SAY_ADJECTIVE(obj,padez,&noun));
  return SAY_PART_PADEZ(obj,padez,&adjective);
}

//� ������� �����
ZAG_ADJECTIVE: function(obj, padez)
{
  return ZA_RET(SAY_PART_PADEZ(obj,padez,&adjective));
}

//������ ���������������� + ��������������� ������� � ����������� �� ������
SAY_FULL:function(obj, padez)
{
  //if (rand(2)==1) {
	//  return SAY_NOUN(obj,padez);
  //}
  //else {
	  return SAY_ADJECTIVE(obj,padez) + ' ' + SAY_NOUN(obj,padez);
  //}
}

//� ������� ����� ������ ���������������� + ��������������� ������� � ����������� �� ������
ZAG_FULL: function(obj, padez)
{
  //if (rand(2)==1) {
	//  return ZAG_NOUN(obj,padez);
  //}
  //else {
	  return ZAG_ADJECTIVE(obj,padez) + ' ' + SAY_NOUN(obj,padez);
  //}
}

// �������, ������������ ��������������� ����� �� ��������� ���������
replica: function(lexicon)
{
	local ind, len;
	len = length(lexicon.phrases);
	if(lexicon.any)
	{
		ind = rand(len);
		// ������������ ������ ����� ����� ������ ������
		if(ind == lexicon.last)
		{
			if(ind == 1)
				ind = ind + 1;
			else
				ind = ind - 1;
		}
	}
	else
	{
		// ���� �������� order ������� ��������� �������� ������ �������, �� ��������� ��� �������� ���� � ��������������� �������
		if(lexicon.order == [])
		{
			local i, numbers = [], number;
			// ������ ������ ����������� �����
			for(i = 1; i <= len; i++)
			{
				numbers = numbers + [i];
			}
			// "�������������" ����������� ����� � �������� order � ��������������� �������
			for(i = 1; i <= len; i++)
			{
				number = numbers[rand(length(numbers))];
				numbers = numbers - [number];
				lexicon.order = lexicon.order + [number];
			}
			// ������������ ������ ����� ����� ������ ������
			if(lexicon.order[1] == lexicon.last)
			{
				number = lexicon.order[1];
				lexicon.order = lexicon.order - [number];
				lexicon.order = lexicon.order + [number];
			}
		}
		ind = lexicon.order[1];
		lexicon.order = lexicon.order - [ind];
	}
	lexicon.last = ind;
	return lexicon.phrases[ind];
}

// ����� ��������� ����
class lexicon: object
	/*
	* �������� any ���������� ����� ��������� ���������.
	* ���� any = true, �� ������� replica() ����� ���������� ����� ����� (�� ����������� ��������� ������������).
	* ���� any = nil, �� ������� replica() ������� ��������������� ����� � ��������������� �������, ���������� � order, ��� ����� �� phrases, � ��� ����� ���� �� ������.
	* any = true ����� ���� ����������� � actorDesc, ��� ������ ������ �� ����� ��������.
	* �� � any = nil ������� ������������, ��������, � �������� ����������, ����� �������������� �� �������������.
	* ������, ��� any = nil, ��������������� ������� ���� ������������ ������ ��� ��-������.
	*/
	any = nil // �� ������������� �������������� � �������� �������
	phrases = [] // ������ ���� ���������
	use_templ = nil //������������� ������������
    mon = nil
    tar = nil
	//���������� ��������, � ������ ������
	print = {
	   local str = replica(self);
       globalTemplates.mon = self.mon;
       globalTemplates.tar = self.tar;
       if (self.use_templ) str = GET_TEMPLATE(str);
       say(str);
       globalTemplates.mon = nil;
       globalTemplates.tar = nil;
	}
	// �������� last � order � �������� ������� ���� ������������� �� ���������
	last = 0 // ����� ��������� ������������ �� ��������� �����
	order = [] // ������� ������� ���� ���������
;


#pragma C-