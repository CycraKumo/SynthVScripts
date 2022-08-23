function getClientInfo()
  return {
    name = "Vibrato Setting (Lua)",
    category = "Shikigami",
    author = "Shikigami",
    versionNumber = 1,
    minEditorVersion = 65537
  }
end

function main()
  local myForm = {
    title = "Vibrato Setting",
    message = "オートビブラートセッティング",
    buttons = "YesNoCancel",
    widgets = {
      {
        name = "sl1", type = "Slider",
        label = "開始タイミング [%]",
        format = "%5.0f",
        minValue = 0,
        maxValue = 100,
        interval = 5,
        default = 25
      },
      {
        name = "sl2", type = "Slider",
        label = "周期 [/sec]",
        format = "%1.0f",
        minValue = 4,
        maxValue = 8,
        interval = 1,
        default = 6
      },
      {
        name = "sl3", type = "Slider",
        label = "振幅",
        format = "%1.0f",
        minValue = 0,
        maxValue = 1200,
        interval = 50,
        default = 50
      },
      {
        name = "cb1", type = "ComboBox",
        label = "形",
        choices = {"＜＝＞", "＜＝", "＝", "＝＞"},
        default = 0
      },
      {
        name = "sl4", type = "Slider",
        label = "「＜」の設定 [%]",
        format = "%5.0f",
        minValue = 0,
        maxValue = 50,
        interval = 5,
        default = 25
      },
      {
        name = "sl5", type = "Slider",
        label = "「＞」の設定 [%]",
        format = "%5.0f",
        minValue = 50,
        maxValue = 100,
        interval = 5,
        default = 75
      },
      {
        name = "check1", type = "CheckBox",
        text = "テンションの同期",
        default = false
      },
      {
        name = "sl6", type = "Slider",
        label = "テンションの振幅",
        format = "%5.0f",
        minValue = 0,
        maxValue = 100,
        interval = 5,
        default = 25
      },
      -- {
      --   name = "check2", type = "CheckBox",
      --   text = "しゃくり",
      --   default = false
      -- },
      -- {
      --   name = "check3", type = "CheckBox",
      --   text = "フォール",
      --   default = false
      -- },
    }
  }

  local result = SV:showCustomDialog(myForm)

  if result.status == "Yes" then

    -- インプットを変数に持っておく
    local sl1 = result.answers.sl1
    local sl2 = result.answers.sl2
    local sl3 = result.answers.sl3
    local cb1 = result.answers.cb1
    local sl4 = result.answers.sl4
    local sl5 = result.answers.sl5
    local check1 = result.answers.check1
    local sl6 = result.answers.sl6

    -- ここ以降に処理を書いていく
    -- ピアノロールの選択状態にアクセス
    local mainEditor = SV:getMainEditor()
    local mainEditorSelection = mainEditor:getSelection()
    -- 選択されているノートの全取得
    local allNotesSelected = mainEditorSelection:getSelectedNotes()

    -- ノートの選択は1個だけ
    if #allNotesSelected ~= 1 then
      SV:finish();
      SV:showMessageBox("Filled Form", "ノートは1個だけ選択してください")
    end

    -- 選択された1個のノートの範囲のピッチを書き換える
    -- 選択された1個のノートの始点と範囲を取得
    local onSet = allNotesSelected[1]:getOnset()
    local duration = allNotesSelected[1]:getDuration()

    -- いまエディターで見ているトラックの情報を取得
    local currentGroup = mainEditor:getCurrentGroup()
    local target = currentGroup:getTarget()

    -- そのトラックのピッチとテンションを取得
    local myPitchBend = target:getParameter("PitchDelta")
    local myTension = target:getParameter("Tension")

    -- 今の始点が64分音符でいくつ離れているかを計算
    local startPoint = onSet / (SV.QUARTER / 16)
    local endPoint = (onSet + duration) / (SV.QUARTER / 16)

    -- 選択されたノートがある場所のテンポを取得
    local timeAxis = SV:getProject():getTimeAxis()
    local tempo = timeAxis:getTempoMarkAt(onSet).bpm

    -- オフセット
    local offset = (endPoint - startPoint) * (sl1 / 100)

    -- どこからどこまでを線形として扱うか
    local linerBefore = (endPoint - startPoint - offset) * (sl4 / 100)
    local linerAfter = (endPoint - startPoint - offset) * (sl5 / 100)

    -- ここで実際にピッチとテンションを書き換える
    for i = startPoint, endPoint do
      -- 64分刻みで入れていく
      local x = i * SV.QUARTER / 16
      -- iがオフセットの中にあったらなにもしない
      if i >= offset + startPoint then
        -- 角度情報を算出
        local rad = math.rad((((i - (endPoint - startPoint)) / (endPoint - startPoint)) * (tempo / 60) * sl2) * 360)
        -- その角度情報をもとに正弦波を作る
        local y = 0
        --コンボボックスの値に応じて形を決める
        -- ＜＝＞
        if cb1 == 0 then
          if i < linerBefore + offset + startPoint then
            -- iが増えるほど1に近づく
            local amp = (i - offset - startPoint) / 10
            if amp > 1 then
              amp = 1
            end
            y = amp * math.sin(rad)
          elseif i > linerAfter + offset + startPoint then
            -- iが増えるほど0に近づく
            local amp = (endPoint - i) / 10
            if amp > 1 then
              amp = 1
            end
            y = amp * math.sin(rad)
          else
            -- そのまま
            y = math.sin(rad)
          end
        -- ＜＝
        elseif cb1 == 1 then
          if i < linerBefore + offset + startPoint then
            -- iが増えるほど1に近づく
            local amp = (i - offset - startPoint) / 10
            if amp > 1 then
              amp = 1
            end
            y = amp * math.sin(rad)
          else
            -- そのまま
            y = math.sin(rad)
          end
        -- ＝
        elseif cb1 == 2 then
          y = math.sin(rad)
        -- ＝＞
        else
          if i > linerAfter + offset + startPoint then
            -- iが増えるほど0に近づく
            local amp = (endPoint - i) / 10
            if amp > 1 then
              amp = 1
            end
            y = amp * math.sin(rad)
          else
            -- そのまま
            y = math.sin(rad)
          end
        end
        -- 正弦波をピッチとテンションに書く
        myPitchBend:add(x, y * sl3)
        if check1 == true then
          myTension:add(x, y * (sl6 / 1200))
        end
      -- iがオフセットの外にあったら明示的に0にする。
      else
        myPitchBend:add(x, 0)
        if check1 == true then
          myTension:add(x, 0)
        end
      end
    end

    myPitchBend:simplify(startPoint * SV.QUARTER / 16, endPoint * SV.QUARTER / 16)
    if check1 == true then
      myTension:simplify(startPoint * SV.QUARTER / 16, endPoint * SV.QUARTER / 16)
    end
  elseif result.status == "No" then
    SV:showMessageBox("Filled Form", "Ctrl+Sで保存を忘れずに")
  end
  SV:finish();
end
