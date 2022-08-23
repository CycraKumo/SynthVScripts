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
  local myForm = {
    title = "Auto Harmonize",
    message = "黒鍵盤に対応したアルファベット（下記対応）と、何度ハモりかを数値で書いてください。\n\n------------------------♯-----------------------\n|  　　　　　　　　　　　　なし：C  |\n|  　　　　　　　　　　　　ファ：G  |\n|  　　　　　　　　　　ファ、ド：D  |\n|  　　　　　　　　ファ、ド、ソ：A  |\n|  　　　　　　ファ、ド、ソ、レ：E  |\n|  　　　　ファ、ド、ソ、レ、ラ：B  |\n|  　　ファ、ド、ソ、レ、ラ、ミ：F+ |\n|  ファ、ド、ソ、レ、ラ、ミ、シ：C+ |\n-------------------------------------------------\n\n------------------------♭-----------------------\n|  　　　　　　　　　　　　なし：C  |\n|  　　　　　　　　　　　　　シ：F  |\n|  　　　　　　　　　　　シ、ミ：B- |\n|  　　　　　　　　　シ、ミ、ラ：E- |\n|  　　　　　　　シ、ミ、ラ、レ：A- |\n|  　　　　　シ、ミ、ラ、レ、ソ：D- |\n|  　　　シ、ミ、ラ、レ、ソ、ド：G- |\n|  シ、ミ、ラ、レ、ソ、ド、ファ：C- |\n-------------------------------------------------\n\n------数値-----\n| +：上ハモり |\n| -：下ハモり |\n---------------\n\n8でオクターブハモり",
    buttons = "YesNoCancel",
    widgets = {
      {
        name = "cb1", type = "ComboBox",
        label = "Key",
        choices = {"C- (♭×7)", "G- (♭×6)", "D- (♭×5)", "A- (♭×4)", "E- (♭×3)", "B- (♭×2)", "F (♭×1)", "C", "G (♯×1)", "D (♯×2)", "A (♯×3)", "E (♯×4)", "B (♯×5)", "F+ (♯×6)", "C+ (♯×7)"},
        default = 7
      },
      {
        name = "cb2", type = "ComboBox",
        label = "Number",
        choices = {"+8", "+7", "+6", "+5", "+4", "+3", "+2", "+1", "0", "-1", "-2", "-3", "-4", "-5", "-6", "-7", "-8"},
        default = 8
      },
    }
  }

  local result = SV:showCustomDialog(myForm)

  if result.status == "Yes" then
    -- インプットを変数に持っておく
    local key = result.answers.cb1
    local number = result.answers.cb2

    SV:showMessageBox("Filled Form",
      "ComboBox values: " .. tostring(key) ..
      " and " .. tostring(number))

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

    newTrack:setName('Harmonize:'..number - 8)

    if key == 7 then
      move = 0
    elseif key == 2 then
      move = 1
    elseif key == 9 then
      move = 2
    elseif key == 4 then
      move = 3
    elseif key == 11 then
      move = 4
    elseif key == 6 then
      move = 5
    elseif key == 13 or key == 1 then
      move = 6
    elseif key == 8 then
      move = 7
    elseif key == 3 then
      move = 8
    elseif key == 10 then
      move = 9
    elseif key == 5 then
      move = 10
    elseif key == 12 or key == 0 then
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

    if number == 7 then
      moveNote = 0
    elseif number == 6 then
      moveNote = 2
      threeFlg = true
      sevenFlg = true
    elseif number == 5 then
      moveNote = 4
      twoFlg = true
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    elseif number == 4 then
      moveNote = 5
      fourFlg = true
    elseif number == 3 then
      moveNote = 7
      sevenFlg = true
    elseif number == 2 then
      moveNote = 9
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    elseif number == 1 then
      moveNote = 11
      twoFlg = true
      threeFlg = true
      fiveFlg = true
      sixFlg = true
      sevenFlg = true
    elseif number == 0 then
      moveNote = 12
    elseif number == 9 then
      moveNote = 0
    elseif number == 10 then
      moveNote = -1
      twoFlg = true
      threeFlg = true
      fiveFlg = true
      sixFlg = true
      sevenFlg = true
    elseif number == 11 then
      moveNote = -3
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    elseif number == 12 then
      moveNote = -5
      sevenFlg = true
    elseif number == 13 then
      moveNote = -7
      fourFlg = true
    elseif number == 14 then
      moveNote = -8
      twoFlg = true
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    elseif number == 15 then
      moveNote = -10
      threeFlg = true
      sevenFlg = true
    elseif number == 16 then
      moveNote = -12
    elseif number == 8 then
      moveNote = 0
    else
      SV:showMessageBox('', 'ハモりがおかしいです')
      SV:finish()
      return
    end

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
  elseif result.status == "No" then
    SV:showMessageBox("Filled Form", "The form returned \"No\".")
  end
  SV:finish();
end
