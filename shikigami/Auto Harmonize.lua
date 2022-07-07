-- スクリプトの
function getClientInfo()
  return {
    name = "Auto Harmonize (Lua)",
    category = "Shikigami",
    author = "Shikigami",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()
  SV:showInputBoxAsync("Auto Harmonize",
    "黒鍵盤に対応したアルファベット（下記対応）と、何度ハモりかを数値で書いてください。\n\n------------------------♯-----------------------\n|  　　　　　　　　　　　　なし：C  |\n|  　　　　　　　　　　　　ファ：G  |\n|  　　　　　　　　　　ファ、ド：D  |\n|  　　　　　　　　ファ、ド、ソ：A  |\n|  　　　　　　ファ、ド、ソ、レ：E  |\n|  　　　　ファ、ド、ソ、レ、ラ：B  |\n|  　　ファ、ド、ソ、レ、ラ、ミ：F+ |\n|  ファ、ド、ソ、レ、ラ、ミ、シ：C+ |\n-------------------------------------------------\n\n------------------------♭-----------------------\n|  　　　　　　　　　　　　なし：C  |\n|  　　　　　　　　　　　　　シ：F  |\n|  　　　　　　　　　　　シ、ミ：B- |\n|  　　　　　　　　　シ、ミ、ラ：E- |\n|  　　　　　　　シ、ミ、ラ、レ：A- |\n|  　　　　　シ、ミ、ラ、レ、ソ：D- |\n|  　　　シ、ミ、ラ、レ、ソ、ド：G- |\n|  シ、ミ、ラ、レ、ソ、ド、ファ：C- |\n-------------------------------------------------\n\n------数値-----\n| +：上ハモり |\n| -：下ハモり |\n---------------\n\n8でオクターブハモり\n\n初期値は黒鍵盤がシだけの3度下ハモり", "F:-3", next)
end

function split(str, ts)
  -- 引数がないときは空tableを返す
  if ts == nil then return {} end

  local t = {} ;
  i=1
  for s in string.gmatch(str, "([^"..ts.."]+)") do
    t[i] = s
    i = i + 1
  end

  return t
end

function next(keyAndNumber)
  if keyAndNumber == "" then
    SV:showMessageBox('', '入力値が空です')
    SV:finish()
    return
  end

  key = split(keyAndNumber, ":")[1]
  number = split(keyAndNumber, ":")[2]

  if key == "" or number == "" then
    SV:showMessageBox('', '入力値がおかしいです')
    SV:finish()
    return
  end

  local mainEditor = SV:getMainEditor()
  local mainEditorNoteGroup = mainEditor:getCurrentGroup()
  local mainEditorSelection = mainEditor:getSelection()

  if mainEditorSelection:hasSelectedNotes() == false then
    SV:showMessageBox('', 'ノートを選択してください')
    SV:finish()
    return
  end

  local allNotesSelected = mainEditorSelection:getSelectedNotes()

  local mainProject = SV:getProject()
  local newTrack = SV:create("Track")
  local newGroup = SV:create("NoteGroup")
  local newGroupReference = SV:create("NoteGroupReference")
  mainProject:addNoteGroup(newGroup, 1)
  newGroupReference:setTarget(newGroup)
  newTrack:addGroupReference(newGroupReference)

  newTrack:setName('Harmonize:'..number)

  if key == 'C' or key == 'B+' then
    move = 0
  elseif key == 'C+' or key == 'D-' then
    move = 1
  elseif key == 'D' then
    move = 2
  elseif key == 'D+' or key == 'E-' then
    move = 3
  elseif key == 'E' then
    move = 4
  elseif key == 'E+' or key == 'F' then
    move = 5
  elseif key == 'F+' or key == 'G-' then
    move = 6
  elseif key == 'G' then
    move = 7
  elseif key == 'G+' or key == 'A-' then
    move = 8
  elseif key == 'A' then
    move = 9
  elseif key == 'A+' or key == 'B-' then
    move = 10
  elseif key == 'B' then
    move = 11
  else
    SV:showMessageBox('', 'キーがおかしいです')
    SV:finish()
    return
  end
  twoFlg = false
  threeFlg = false
  fourFlg = false
  fiveFlg = false
  sixFlg = false
  sevenFlg = false

  if number == '+1' then
    moveNote = 0
  elseif number == '+2' then
    moveNote = 2
    threeFlg = true
    sevenFlg = true
  elseif number == '+3' then
    moveNote = 4
    twoFlg = true
    threeFlg = true
    sixFlg = true
    sevenFlg = true
  elseif number == '+4' then
    moveNote = 5
    fourFlg = true
  elseif number == '+5' then
    moveNote = 7
    sevenFlg = true
  elseif number == '+6' then
    moveNote = 9
    threeFlg = true
    sixFlg = true
    sevenFlg = true
  elseif number == '+7' then
    moveNote = 11
    twoFlg = true
    threeFlg = true
    fiveFlg = true
    sixFlg = true
    sevenFlg = true
  elseif number == '+8' then
    moveNote = 12
  elseif number == '-1' then
    moveNote = 0
  elseif number == '-2' then
    moveNote = -1
    twoFlg = true
    threeFlg = true
    fiveFlg = true
    sixFlg = true
    sevenFlg = true
  elseif number == '-3' then
    moveNote = -3
    threeFlg = true
    sixFlg = true
    sevenFlg = true
  elseif number == '-4' then
    moveNote = -5
    sevenFlg = true
  elseif number == '-5' then
    moveNote = -7
    fourFlg = true
  elseif number == '-6' then
    moveNote = -8
    twoFlg = true
    threeFlg = true
    sixFlg = true
    sevenFlg = true
  elseif number == '-7' then
    moveNote = -10
    threeFlg = true
    sevenFlg = true
  elseif number == '-8' then
    moveNote = -12
  else
    SV:showMessageBox('', 'ハモりがおかしいです')
    SV:finish()
    return
  end

  plusminus = string.sub(number, 1, 1)

  for i = 1, #allNotesSelected do
    local n = SV:create("Note")
    n:setTimeRange(allNotesSelected[i]:getOnset(), allNotesSelected[i]:getDuration())

    local check = allNotesSelected[i]:getPitch() - move

    if twoFlg == true and check % 12 == 2 then
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote - 1)
    elseif threeFlg == true and check % 12 == 4 then
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote - 1)
    elseif fourFlg == true and check % 12 == 5 then
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote + 1)
    elseif fiveFlg == true and check % 12 == 7 then
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote - 1)
    elseif sixFlg == true and check % 12 == 9 then
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote - 1)
    elseif sevenFlg == true and check % 12 == 11 then
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote - 1)
    else
      n:setPitch(allNotesSelected[i]:getPitch() + moveNote)
    end

    n:setLyrics(allNotesSelected[i]:getLyrics())
    newGroup:addNote(n)
  end

  mainProject:addTrack(newTrack)
  SV:finish()
end
