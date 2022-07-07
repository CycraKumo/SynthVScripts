-- スクリプトの情報
function getClientInfo()
  return {
    name = "Duration Quantize (Lua)",
    category = "Duration",
    author = "Shikigami",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()

    local myForm = {
      title = "Duration Quantize",
      message = "クオンタイズ自動調整。一番細かいクオンタイズに合わせること。",
      buttons = "YesNoCancel",
      widgets = {
        {
          name = "cb1", type = "ComboBox",
          label = "クオンタイズ",
          choices = {"4分音符", "8分音符", "16分音符", "8分3連符", "32分音符", "16分3連符", "64分音符", "32分3連符", "128分音符"},
          default = 2
        },
      }
    }

    -- "4分音符" => 0, "8分音符" => 1, "16分音符" => 2, "8分3連符" => 3,
    -- "32分音符" => 4, "16分3連符" => 5, "64分音符" => 6, "32分3連符" => 7, "128分音符" => 8

    -- myformで設定したダイアログの表示。コンボボックス。
    local result = SV:showCustomDialog(myForm)

    -- 入力された値を取得。0~8
    cb1 = result.answers.cb1

    -- クオンタイズの基準値用変数宣言
    quantize = 0

    -- コンボボックスからの値に応じて、クオンタイズする値を決める。多分ここ計算で出してもいい。
    if cb1 == 0 then
        quantize = 705600000
    elseif cb1 == 1 then
        quantize = 352800000
    elseif cb1 == 2 then
        quantize = 176400000
    elseif cb1 == 3 then
        quantize = 117600000
    elseif cb1 == 4 then
        quantize = 88200000
    elseif cb1 == 5 then
        quantize = 58800000
    elseif cb1 == 6 then
        quantize = 44100000
    elseif cb1 == 7 then
        quantize = 29400000
    elseif cb1 == 8 then
        quantize = 22050000
    end

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
            -- ノートの長さを取得
            local duration = allNotesSelected[i]:getDuration()
            -- 一番近いクオンタイズの倍数を入れる変数
            local near = 0
            -- もし一番近いクオンタイズの倍数を入れる変数が選択されたノートの長さを超えたら
            -- -> 一番近いクオンタイズ（後ろ側）の値がnearに入る
            while duration > near do
                near = near + quantize
            end
            -- そのnearを長さ情報として渡してやる
            allNotesSelected[i]:setDuration(near)
        end
    end
    SV:finish()
end
