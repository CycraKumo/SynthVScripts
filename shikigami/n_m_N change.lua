-- スクリプトの情報
function getClientInfo()
  return {
    name = "n m N Change (Lua)",
    category = "Shikigami",
    author = "Shikigami",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()

    local myForm = {
      title = "n m N Change",
      message = "「n」と「m」と「N」を自動で振り分けるスクリプト。ノートを全部選択してから実行すること",
      buttons = "YesNoCancel",
      -- widgets = {
      --   {
      --     name = "cb1", type = "ComboBox",
      --     label = "クオンタイズ",
      --     choices = {"4分音符", "8分音符", "16分音符", "8分3連符", "32分音符", "16分3連符", "64分音符", "32分3連符", "128分音符"},
      --     default = 2
      --   },
      -- }
    }

    -- myformで設定したダイアログの表示。
    local result = SV:showCustomDialog(myForm)

    -- 音素の指定
    n = {
        ['た'] = true, ['ち'] = true,  ['つ'] = true, ['て'] = true, ['と'] = true,
        ['ら'] = true, ['り'] = true,  ['る'] = true, ['れ'] = true, ['ろ'] = true,
        ['だ'] = true, ['ぢ'] = true,  ['づ'] = true, ['で'] = true, ['ど'] = true,
        ['な'] = true, ['に'] = true,  ['ぬ'] = true, ['ね'] = true, ['の'] = true,
    }
    N = {
        ['か'] = true, ['き'] = true,  ['く'] = true, ['け'] = true, ['こ'] = true,
        ['が'] = true, ['ぎ'] = true,  ['ぐ'] = true, ['げ'] = true, ['ご'] = true,
    }
    m = {
        ['ぱ'] = true, ['ぴ'] = true,  ['ぷ'] = true, ['ぺ'] = true, ['ぽ'] = true,
        ['ま'] = true, ['み'] = true, ['む'] = true, ['め'] = true, ['も'] = true,
        ['ば'] = true, ['び'] = true, ['ぶ'] = true, ['べ'] = true, ['ぼ'] = true,
    }

    -- コンボボックスでYesが入ってきたら
    if result.status == "Yes" then
        -- ここから
        local mainEditor = SV:getMainEditor()
        local mainEditorSelection = mainEditor:getSelection()
        -- ここまでおまじないみたいなもん
        -- 選択されているノートの全取得
        local allNotesSelected = mainEditorSelection:getSelectedNotes()

        -- 中身は1からスタートするので、選択したノート全てに適応できるようにfor文を回す
        for i = 1, #allNotesSelected do
            -- ノートのリリックが「ん」のもの
            if allNotesSelected[i]:getLyrics() == 'ん' then
                if i < #allNotesSelected then
                    -- 次のノートと隣り合っているもの
                    if allNotesSelected[i]:getEnd() == allNotesSelected[i + 1]:getOnset() then
                        -- 隣のノートの音素が指定したものなら
                        if n[allNotesSelected[i + 1]:getLyrics()] then
                            -- ノートの音素を変える
                            allNotesSelected[i]:setPhonemes('n')
                        elseif N[allNotesSelected[i + 1]:getLyrics()] then
                            allNotesSelected[i]:setPhonemes('N')
                        elseif m[allNotesSelected[i + 1]:getLyrics()] then
                            allNotesSelected[i]:setPhonemes('m')
                        -- どの条件にも引っかからない場合
                        -- else
                        --     -- デフォルトのNにする
                        --     allNotesSelected[i].setPhonemes('N')
                        end
                    end
                end
            end
        end
    end
    SV:finish()
end
