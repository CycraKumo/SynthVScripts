-- スクリプトの情報
function getClientInfo()
  return {
    -- スクリプトのところに表示される名前
    name = "Auto Harmonize (Lua)",
    -- フォルダの名前
    category = "Shikigami",
    -- 作った人の名前。エラー文に出る、誰々に連絡しろって使い方っぽい。
    author = "Twitter: @0Shikigami",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

-- ローカライズ
function getTranslations(langCode)
  -- 翻訳はただDeepl翻訳やGoogle翻訳に通しただけ。
  -- ドイツ語
  if langCode == "de-de" then
    return {
      {"Auto Harmonize", "Automatisch harmonisieren"}
    }
  -- チリスペイン語
  elseif langCode == "es-cl" then
    return {
      {"Auto Harmonize", "Armonización automática"}
    }
  -- スペイン語
  elseif langCode == "es-la" then
    return {
      {"Auto Harmonize", "Armonización automática"}
    }
  -- フランス語
  elseif langCode == "fr-fr" then
    return {
      {"Auto Harmonize", "Harmonisation automatique"}
    }
  -- 日本語
  elseif langCode == "ja-jp" then
    return {
      {"Auto Harmonize", "自動ハモリ生成"}
    }
  -- 韓国語
  elseif langCode == "ko-kr" then
    return {
      {"Auto Harmonize", "자동 조화"}
    }
  -- ポルトガル語
  elseif langCode == "pt-br" then
    return {
      {"Auto Harmonize", "Auto Harmonizar"}
    }
  -- ロシア語
  elseif langCode == "ru-ru" then
    return {
      {"Auto Harmonize", "Автоматическая гармонизация"}
    }
  -- ベトナム語
  elseif langCode == "vi-vn" then
    return {
      {"Auto Harmonize", "Tự động hài hòa"}
    }
  -- 中国語（簡体字）
  elseif langCode == "zh-cn" then
    return {
      {"Auto Harmonize", "自动生成哈莫里"}
    }
  -- 中国語（繁体字）
  elseif langCode == "zh-tw" then
    return {
      {"Auto Harmonize", "自動協調"}
    }
  end
  return {}
end

function isInScale(pitch, scale)
  local usekey = {0, 2, 4, 5, 7, 9, 11}

  for i = 1, #usekey do
    if pitch % 12 == (usekey[i] + scale) % 12 then
      return true
    end
  end
  return false
end

-- メインロジック
function main()
  -- フォームの情報を決定
  local myForm = {
    -- タイトル
    title = SV:T("Auto Harmonize"),
    -- メッセージ。画面の大きさによっては表示が崩れるかも
    message = "ローカライズはDeepl翻訳、Google翻訳を使用。\n\n黒鍵盤に対応したアルファベット（下記対応）と、何度ハモりかを下から選んでください。\n\n------------------------♯-----------------------\n|  　　　　　　　　　　　　なし：C  |\n|  　　　　　　　　　　　　ファ：G  |\n|  　　　　　　　　　　ファ、ド：D  |\n|  　　　　　　　　ファ、ド、ソ：A  |\n|  　　　　　　ファ、ド、ソ、レ：E  |\n|  　　　　ファ、ド、ソ、レ、ラ：B  |\n|  　　ファ、ド、ソ、レ、ラ、ミ：F+ |\n|  ファ、ド、ソ、レ、ラ、ミ、シ：C+ |\n-------------------------------------------------\n\n------------------------♭-----------------------\n|  　　　　　　　　　　　　なし：C  |\n|  　　　　　　　　　　　　　シ：F  |\n|  　　　　　　　　　　　シ、ミ：B- |\n|  　　　　　　　　　シ、ミ、ラ：E- |\n|  　　　　　　　シ、ミ、ラ、レ：A- |\n|  　　　　　シ、ミ、ラ、レ、ソ：D- |\n|  　　　シ、ミ、ラ、レ、ソ、ド：G- |\n|  シ、ミ、ラ、レ、ソ、ド、ファ：C- |\n-------------------------------------------------\n\n------数値-----\n| +：上ハモり |\n| -：下ハモり |\n---------------\n\n8でオクターブハモり",
    -- ボタンがいくつあるか。基本こう書いていればいい
    buttons = "YesNoCancel",
    -- どんな要素を操作者が入力できるか
    widgets = {
      {
        -- 名前。値の受け取りに使う
        name = "cb1",
        -- コンボボックス。人によってはセレクトボックスとか言う。
        type = "ComboBox",
        -- こっちは操作者に見える方の名前
        label = "Key",
        -- 値
        choices = {"C- (♭×7)", "G- (♭×6)", "D- (♭×5)", "A- (♭×4)", "E- (♭×3)", "B- (♭×2)", "F (♭×1)", "C", "G (♯×1)", "D (♯×2)", "A (♯×3)", "E (♯×4)", "B (♯×5)", "F+ (♯×6)", "C+ (♯×7)"},
        -- デフォルト値がどこか。一番左を0として順に増えてく。
        default = 7
      },
      {
        -- 名前。値の受け取りに使う
        name = "cb2",
        -- コンボボックス。人によってはセレクトボックスとか言う。
        type = "ComboBox",
        -- こっちは操作者に見える方の名前
        label = "Number",
        -- 値
        choices = {"+8", "+7", "+6", "+5", "+4", "+3", "+2", "-2", "-3", "-4", "-5", "-6", "-7", "-8"},
        -- デフォルト値がどこか。一番左を0として順に増えてく。
        default = 8
      },
    }
  }

  -- フォームの表示と返り値の取得
  local result = SV:showCustomDialog(myForm)

  -- Yesボタンが押されたならば
  if result.status == "Yes" then
    -- 入力された値を変数に持っておく
    local key = result.answers.cb1
    local number = result.answers.cb2

    -- ピアノロールの UI 状態オブジェクトを取得
    local mainEditor = SV:getMainEditor()
    -- ピアノロールの選択状態オブジェクトを取得
    local mainEditorSelection = mainEditor:getSelection()

    -- ノートが選択されていないときの処理
    if mainEditorSelection:hasSelectedNotes() == false then
      -- メッセージを出力して終了
      SV:showMessageBox('', 'ノートを選択してください')
      SV:finish()
      return
    end

    -- 選択されているノートを取得。返り値は配列。先頭から順に。
    local allNotesSelected = mainEditorSelection:getSelectedNotes()

    -- 以下で新しいトラックの情報を決定する
    -- 現在開いているプロジェクトを取得
    local mainProject = SV:getProject()

    -- トラック、ノートグループ、ノートグループリファレンスの概念を変数として扱えるようにする
    local newTrack = SV:create("Track")
    local newGroup = SV:create("NoteGroup")
    local newGroupReference = SV:create("NoteGroupReference")

    -- トラック、ノートグループ、ノートグループリファレンスの実体を作成する
    mainProject:addNoteGroup(newGroup, 1)
    newGroupReference:setTarget(newGroup)
    newTrack:addGroupReference(newGroupReference)

    -- トラック名をセット
    newTrack:setName('Harmonize:'..number - 8)

    -- キーによって選択されたノートを全体としてどれだけ動かすかを返す
    -- "C- (♭×7)", "G- (♭×6)", "D- (♭×5)", "A- (♭×4)", "E- (♭×3)", "B- (♭×2)", "F (♭×1)", "C", "G (♯×1)", "D (♯×2)", "A (♯×3)", "E (♯×4)", "B (♯×5)", "F+ (♯×6)", "C+ (♯×7)"
    -- C
    if key == 7 then
      move = 0
    -- D♭
    elseif key == 2 then
      move = 1
    -- D
    elseif key == 9 then
      move = 2
    -- E♭
    elseif key == 4 then
      move = 3
    -- E
    elseif key == 11 then
      move = 4
    -- F
    elseif key == 6 then
      move = 5
    -- F♯ or G♭
    elseif key == 13 or key == 1 then
      move = 6
    -- G
    elseif key == 8 then
      move = 7
    -- A♭
    elseif key == 3 then
      move = 8
    -- A
    elseif key == 10 then
      move = 9
    -- B♭
    elseif key == 5 then
      move = 10
    -- B or C♭
    elseif key == 12 or key == 0 then
      move = 11
    -- セレクトボックスにしたことでなくなったけれど、一応例外処理
    else
      SV:showMessageBox('', 'キーがおかしいです')
      SV:finish()
      return
    end

    -- そのキーにおいて、2度,3度,4度,5度,6度,7度の音階がキーCからずれているかどうかを決め打ちする
    -- ここ配列で持ってていい気がしなくもない
    twoFlg = false
    threeFlg = false
    fourFlg = false
    fiveFlg = false
    sixFlg = false
    sevenFlg = false

    -- ハモリが何度かに応じて、もとのノートからいくつ動かすかを決定する
    -- "+8", "+7", "+6", "+5", "+4", "+3", "+2", "-2", "-3", "-4", "-5", "-6", "-7", "-8"
    -- +2
    if number == 6 then
      moveNote = 2
      threeFlg = true
      sevenFlg = true
    -- +3
    elseif number == 5 then
      moveNote = 4
      twoFlg = true
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    -- +4
    elseif number == 4 then
      moveNote = 5
      fourFlg = true
    -- +5
    elseif number == 3 then
      moveNote = 7
      sevenFlg = true
    -- +6
    elseif number == 2 then
      moveNote = 9
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    -- +7
    elseif number == 1 then
      moveNote = 11
      twoFlg = true
      threeFlg = true
      fiveFlg = true
      sixFlg = true
      sevenFlg = true
    -- +8
    elseif number == 0 then
      moveNote = 12
    -- -2
    elseif number == 7 then
      moveNote = -1
      twoFlg = true
      threeFlg = true
      fiveFlg = true
      sixFlg = true
      sevenFlg = true
    -- -3
    elseif number == 8 then
      moveNote = -3
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    -- -4
    elseif number == 9 then
      moveNote = -5
      sevenFlg = true
    -- -5
    elseif number == 10 then
      moveNote = -7
      fourFlg = true
    -- -6
    elseif number == 11 then
      moveNote = -8
      twoFlg = true
      threeFlg = true
      sixFlg = true
      sevenFlg = true
    -- -7
    elseif number == 12 then
      moveNote = -10
      threeFlg = true
      sevenFlg = true
    -- -8
    elseif number == 13 then
      moveNote = -12
    -- こっちセレクトボックスを採用したことで一応なくなったけど例外処理を書いておく
    else
      SV:showMessageBox('', 'ハモりがおかしいです')
      SV:finish()
      return
    end

    -- ハモリのノートを作成していく
    -- 選択されたノート1個1個に対して操作を行う
    for i = 1, #allNotesSelected do
      -- ノートの概念を作成。以下で詳しいパラメータを決定していく
      local n = SV:create("Note")

      -- そのノートの長さ。これはもとのノートそのまま
      n:setTimeRange(allNotesSelected[i]:getOnset(), allNotesSelected[i]:getDuration())

      -- そのノートがキーCにおいてどこの高さにいるかを調べる
      local check = allNotesSelected[i]:getPitch() - move

      -- ハモリに応じて決定された、追加で下げる必要があるかどうかに対して、
      -- 先ほど取得したピッチ情報を12で割ったあまりをもとに、そのノートがキーCにおいてどの高さにいるかをチェック
      -- これは臨時記号には対応していない点に注意
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

      -- そのノートの歌詞。もとのノートのそのまま。
      n:setLyrics(allNotesSelected[i]:getLyrics())

      -- ノートグループにノートの実態を追加していく
      newGroup:addNote(n)
    end

    -- 新しいトラックとしてプロジェクトにハモリ用トラックを追加する
    mainProject:addTrack(newTrack)
  -- ノーが選択されたら
  elseif result.status == "No" then
    -- ノーが選択されたよと表示してそのまま処理終了
    SV:showMessageBox("Filled Form", "The form returned \"No\".")
  end
  -- 全部終わったら終了処理を入れておく
  SV:finish();
end
