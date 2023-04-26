{
  Create Conditions for selected COBJ, uses CNTO Values
  Created by Guizz
  v1.0
}

unit UserScript;

function Process(e: IInterface): integer;
var
  i: integer;
  items, conds, ctda: IInterface;
begin
  if Signature(e) = 'TES4' then
    Exit;

  if Signature(e) <> 'COBJ' then
    Exit;

  conds := ElementByName(e, 'Conditions');
  items := ElementByName(e, 'Items');
  for i := 0 to ElementCount(items) - 1 do begin
    if not Assigned(conds) then begin
      ctda := ElementByIndex(Add(e, 'Conditions', False), 0);
    end else begin
      ctda := ElementAssign(conds, HighInteger, nil, False);
    end;
    SetElementEditValues(ctda, 'CTDA\Type', '11000000');
    SetElementEditValues(ctda, 'CTDA\Comparison Value', 1);
    SetElementEditValues(ctda, 'CTDA\Function', 'GetItemCount');
    SetElementEditValues(ctda, 'CTDA\Inventory Object', GetElementEditValues(ElementByIndex(items, i), 'CNTO\Item'));
  end;

end;

end.