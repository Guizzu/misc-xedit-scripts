{
  Create Spell, Book and MGEF for selected Perks
  To be used with PerkTomes.esp
  Created by Guizz
  v1.0
}

unit UserScript;

const
  pTomes = 'PerkTomes.esp';

var
  basespell, basebook, basemgef, plug, f: IInterface;
  str: string;
  int: integer;
  
//============================================================================
function Initialize: integer;
begin
  for int := 0 to FileCount - 1 do begin
    f := FileByIndex(int);
    str := GetFileName(f);
    if SameText(str, pTomes) then plug := f;
  end;

  if not Assigned(plug) then begin
    AddMessage('Can not find ' + pTomes);
    Result := 1;
    Exit;
  end;

  basespell := RecordByFormID(plug, $05000806, True);
  basebook := RecordByFormID(plug, $05000807, True);
  basemgef := RecordByFormID(plug, $05000801, True);
  if not Assigned(basespell) or not Assigned(basebook) or not Assigned(basemgef) then begin
    AddMessage('Can not find base record');
    Result := 1;
    Exit;
  end;
end;

//============================================================================
function Process(e: IInterface): integer;
var
  spell, book, mgef, conditions, ctda, avif: IInterface;
  i: integer;
  t, skill: string;
begin  
  if Signature(e) = 'PERK' then begin
    // Add MGEF
    conditions := ElementByName(e, 'Conditions');
    for i := 0 to ElementCount(conditions) - 1 do begin
      ctda := ElementByIndex(conditions, i);
      t := GetElementEditValues(ctda, 'CTDA\Actor Value');
      if t <> '' then skill := t;
    end;
    if skill = '' then Exit;
    mgef := wbCopyElementToFile(basemgef, plug, True, True);
    SetElementEditValues(mgef, 'Magic Effect Data\DATA\Magic Skill', skill);
    SetElementEditValues(mgef, 'Magic Effect Data\DATA\Perk to Apply', IntToHex(GetLoadOrderFormID(e), 8));
    SetElementEditValues(mgef, 'FULL', 'Add Perk: ' + GetElementEditValues(e, 'FULL'));
    SetElementEditValues(mgef, 'EDID', 'PKTM_VK_MGEF_' + stringReplace(GetElementEditValues(e, 'FULL'), ' ', '', [rfReplaceAll, rfIgnoreCase]));

    // Add SPEL
    spell := wbCopyElementToFile(basespell, plug, True, True);
    SetElementEditValues(spell, 'Effects\Effect #0\EFID', IntToHex(GetLoadOrderFormID(mgef), 8));
    SetElementEditValues(spell, 'DESC', GetElementEditValues(e, 'DESC'));
    SetElementEditValues(spell, 'FULL', GetElementEditValues(e, 'FULL') + ' (Perk)');
    SetElementEditValues(spell, 'EDID', 'PKTM_VK_SPEL_' + stringReplace(GetElementEditValues(e, 'FULL'), ' ', '', [rfReplaceAll, rfIgnoreCase]));

    // Add BOOK
    book := wbCopyElementToFile(basebook, plug, True, True);
    SetElementEditValues(book, 'DATA\Spell', IntToHex(GetLoadOrderFormID(spell), 8));
    SetElementEditValues(book, 'DESC', '<font face''$HandwrittenFont''><font size=''40''><p align=''center''> ' + GetElementEditValues(e, 'FULL'));
    SetElementEditValues(book, 'FULL', 'Perk Tome: ' + GetElementEditValues(e, 'FULL'));
    SetElementEditValues(book, 'EDID', 'PKTM_VK_BOOK_' + stringReplace(GetElementEditValues(e, 'FULL'), ' ', '', [rfReplaceAll, rfIgnoreCase]));
  end;
end;

end.